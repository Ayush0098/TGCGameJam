"""Produce the requested voice pack locally; no speech models enter src/.

Run with .codex/tools/voice/env/Scripts/python.exe assets/audio/generate_voice_pack.py
--request PATH. MP3 files retain the exact requested names; lossless cache is local.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import re
from pathlib import Path
import numpy as np
import soundfile as sf
from kokoro_onnx import Kokoro
from generate_reference import prepare_model, MODELS

ROOT = Path(__file__).resolve().parents[2]
SR = 44100
PROFILES = {
    'narr': {'voice':'af_heart','lang':'en-us','speed':.96,'pitch':1.0},
    'narr15': {'voice':'bm_fable','lang':'en-gb','speed':.92,'pitch':1.0},
    'boss': {'voice':'bm_george','lang':'en-gb','speed':.95,'pitch':.98},
    'grandma': {'voice':'bf_lily','lang':'en-gb','speed':.91,'pitch':1.0},
    'kid': {'voice':'af_sky','lang':'en-us','speed':1.08,'pitch':1.14},
    'intern': {'voice':'am_puck','lang':'en-us','speed':1.02,'pitch':1.07},
    'dog': {'voice':'am_santa','lang':'en-us','speed':1.05,'pitch':.80},
    'cat': {'voice':'af_nicole','lang':'en-us','speed':.98,'pitch':1.07},
    'mouse': {'voice':'af_sky','lang':'en-us','speed':1.08,'pitch':1.48},
}

def parse_request(path):
    request = path.read_text(encoding='utf-8-sig')
    cues=[]
    act=0
    for line in request.splitlines():
        section=re.match(r'^### F([123]):',line.strip())
        if section: act=int(section[1])
        match = re.match(r'^([a-z][a-z0-9_]+)\.mp3\s+(.*)$',line.strip())
        if not match or '_blip_' in match[1]:
            continue
        cue_id, tail = match.groups()
        quote=re.search(r'"(.*?)"',tail)
        direction='; '.join(re.findall(r'\[(.*?)\]',tail))
        if not quote and not direction:
            continue
        quoted=quote[1] if quote else ''
        spoken=re.sub(r'\s*\[[^\]]*\]\s*',' ',quoted).strip()
        record={'id':cue_id,'text':spoken, 'direction':direction,
                'speaker':cue_id.split('_')[0], 'kind':'spoken' if quote else 'vocal'}
        if quoted!=spoken: record['performance_text']=quoted
        if cue_id.startswith('narr15_'):
            explicit_act=re.fullmatch(r'narr15_act([123])',cue_id)
            record['act']=int(explicit_act[1]) if explicit_act else act
        # Later request sections explicitly replace earlier lines with the same ID.
        previous=next((i for i,c in enumerate(cues) if c['id']==cue_id),None)
        if previous is None: cues.append(record)
        else: cues[previous]=record
    for speaker in ['boss','grandma','kid','intern','dog','cat','mouse']:
        for i, syllable in enumerate(['ba','bo','mi','pu'],1):
            cues.append({'id':f'{speaker}_blip_{i}','speaker':speaker,'text':'',
                         'syllable':syllable,'direction':'short nonsense vocal syllable', 'kind':'blip'})
    assert len(cues)==len({c['id'] for c in cues}) and len(cues)>=115
    return cues

def speakable(text):
    # The phonemizer spells short all-caps words as letters (CAT -> C-A-T).
    # Real acronyms stay; everything else is read as a word.
    return re.sub(r"[A-Z][A-Z']+", lambda m: m[0] if m[0] in {'HR'} else m[0].capitalize(), text)

def resample(samples, old_rate, pitch=1.0):
    # Linear-phase windowed sinc interpolation, also handles deliberate cartoon pitch.
    ratio=old_rate*pitch/SR
    positions=np.arange(int(len(samples)/ratio))*ratio
    centres=positions.astype(np.int64)
    output=np.zeros(len(positions),dtype=np.float64)
    norm=np.zeros(len(positions),dtype=np.float64)
    cutoff=min(1.,1./ratio)
    for offset in range(-16,17):
        indices=centres+offset
        distance=positions-indices
        weight=cutoff*np.sinc(cutoff*distance)*np.where(abs(distance)<17,.5+.5*np.cos(np.pi*distance/17),0)
        valid=(indices>=0)&(indices<len(samples))
        output+=samples[np.clip(indices,0,len(samples)-1)]*weight*valid
        norm+=weight*valid
    return output/np.maximum(norm,1e-8)

def finish(samples, blip=False):
    x=np.asarray(samples,dtype=np.float64)
    assert len(x) and np.isfinite(x).all()
    x-=np.mean(x)
    # Detect leading/trailing silence with 5ms RMS blocks, retain quiet consonants.
    block=220
    rms=np.array([np.sqrt(np.mean(x[i:i+block]**2)) for i in range(0,len(x),block)])
    active=np.where(rms>max(.00035,rms.max()*.012))[0]
    if not len(active): raise ValueError('Silent synthesis')
    start=max(0,int(active[0])*block-440)
    end=min(len(x),(int(active[-1])+1)*block+440)
    x=x[start:end]
    if blip:
        # Choose a voiced portion; keep the original character pitch.
        width=int(SR*.15)
        energy=np.convolve(x*x,np.ones(min(width,len(x)))/min(width,len(x)),mode='valid')
        start=int(np.argmax(energy)) if len(x)>width else 0
        x=x[start:start+width]
        if len(x)<width: x=np.pad(x,(0,width-len(x)))
    fade=min(int(SR*(.012 if blip else .004)),len(x)//4)
    x[:fade]*=np.linspace(0,1,fade)
    x[-fade:]*=np.linspace(1,0,fade)
    # Gentle peak compression before active-speech RMS matching; no hard clipping.
    active=x[np.abs(x)>max(.001,np.max(np.abs(x))*.035)]
    gain=10**(-21/20)/np.sqrt(np.mean(active*active))
    x*=gain
    x=.85*np.tanh(x/.85)
    active=x[np.abs(x)>.003]
    gain=10**(-21/20)/np.sqrt(np.mean(active*active))
    x*=min(gain,.85/max(np.max(np.abs(x)),1e-8))
    return x

def metrics(path):
    x,sr=sf.read(path,always_2d=True)
    assert sr==SR and x.shape[1]==1 and np.isfinite(x).all()
    x=x[:,0]; peak=float(np.max(np.abs(x)))
    assert 0<peak<.98
    threshold=max(.0008,peak*.008)
    nz=np.flatnonzero(abs(x)>threshold)
    assert len(nz)
    leading=nz[0]/sr; trailing=(len(x)-1-nz[-1])/sr
    assert leading<=.1 and trailing<=.1, f'{path.name} silence {leading}/{trailing}'
    active=x[np.abs(x)>max(.003,peak*.035)]
    return {'duration_seconds':round(len(x)/sr,4),'sample_rate':sr,'channels':1,
            'peak':round(peak,5),'active_rms_dbfs':round(20*np.log10(np.sqrt(np.mean(active**2))),2),
            'leading_silence_seconds':round(leading,4),'trailing_silence_seconds':round(trailing,4),
            'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}

def main():
    parser=argparse.ArgumentParser(); parser.add_argument('--request',type=Path,required=True)
    parser.add_argument('--only',default=''); args=parser.parse_args()
    cues=parse_request(args.request)
    directory=ROOT/'assets/audio/voice'; directory.mkdir(parents=True,exist_ok=True)
    (directory/'request.md').write_text(args.request.read_text(encoding='utf-8-sig'),encoding='utf-8')
    cache=ROOT/'.codex/tools/voice/production_masters'; cache.mkdir(parents=True,exist_ok=True)
    hashes={name:prepare_model(ROOT/'.codex/tools/voice'/name,sha,False) for name,sha in MODELS.items()}
    previous_path=directory/'manifest.json'
    previous=json.loads(previous_path.read_text()) if previous_path.exists() else {}
    previous_cues={c['id']:c for c in previous.get('cues',[])}
    model=None; delivered=[]
    for cue in cues:
        if args.only and cue['id'] not in args.only.split(','): continue
        profile=PROFILES[cue['speaker']].copy()
        if cue['speaker']=='narr15':
            profile['speed']={1:.92,2:.98,3:1.04}.get(cue.get('act'),.92)
            if cue['id'].endswith('_original'): profile['speed']*=.97
        if 'slow' in cue['direction'] or cue['id'].endswith('_sleep'): profile['speed']*=.88
        elif any(word in cue['direction'] for word in ['excited','panicking','fierce','triumphant']): profile['speed']*=1.06
        filename=cue['id']+'.mp3'
        output=directory/('narrator' if cue['speaker'].startswith('narr') else 'characters')/filename
        output.parent.mkdir(parents=True,exist_ok=True)
        key=hashlib.sha256(json.dumps({'cue':cue,'profile':profile,'models':hashes,'script':hashlib.sha256(Path(__file__).read_bytes()).hexdigest()},sort_keys=True).encode()).hexdigest()
        master=cache/(cue['id']+'.wav'); keyfile=cache/(cue['id']+'.key')
        prior=previous_cues.get(cue['id'],{})
        compatible=(previous.get('models_sha256')==hashes and prior.get('profile')==profile
                    and all(prior.get(field)==value for field,value in cue.items())
                    and output.exists() and hashlib.sha256(output.read_bytes()).hexdigest()==prior.get('sha256'))
        cached=master.exists() and output.exists() and keyfile.exists() and keyfile.read_text()==key
        if not (cached or compatible):
            if cue['kind']=='vocal' or (cue['kind']=='blip' and cue['speaker'] in ['dog','cat','mouse']):
                from animal_vocals import generate_vocal
                samples=generate_vocal(cue['id'],SR)
            else:
                if model is None: model=Kokoro(str(ROOT/'.codex/tools/voice/kokoro-v1.0.onnx'),str(ROOT/'.codex/tools/voice/voices-v1.0.bin'))
                text=cue.get('syllable') if cue['kind']=='blip' else speakable(cue['text'])
                if cue['id']=='narr15_finale_win' and cue.get('performance_text'):
                    segments=re.split(r'(\[[^\]]*\])',cue['performance_text'])
                    performance=[]
                    for segment in segments:
                        if segment.startswith('['):
                            # Nonverbal laughter from the same narrator profile;
                            # direction words themselves are never pronounced.
                            laugh={'[snort]':'hə','[wheeze]':'hə hə','[laughing helplessly]':'hɑ hɑ hɑ'}.get(segment)
                            if laugh:
                                vocal,rate=model.create(laugh,voice=profile['voice'],lang=profile['lang'],speed=1.15,is_phonemes=True,sentence_pause=.10)
                                performance.append(vocal*.72)
                            performance.append(np.zeros(2400))
                        elif segment.strip():
                            vocal,rate=model.create(speakable(segment.strip()),voice=profile['voice'],lang=profile['lang'],speed=profile['speed'],sentence_pause=.22,clause_pause=.13)
                            performance.append(vocal)
                    samples=np.concatenate(performance)
                else:
                    samples,rate=model.create(text,voice=profile['voice'],lang=profile['lang'],speed=1.8 if cue['kind']=='blip' else profile['speed'],sentence_pause=.24 if cue['speaker']=='narr15' else .20,clause_pause=.13 if cue['speaker']=='narr15' else .10)
                samples=resample(samples,rate,profile['pitch'])
            samples=finish(samples,blip=cue['kind']=='blip')
            sf.write(master,samples,SR,subtype='PCM_16')
            sf.write(output,samples,SR,format='MP3',subtype='MPEG_LAYER_III')
            keyfile.write_text(key)
        record={**cue,'profile':profile,'audio':output.relative_to(ROOT).as_posix(),**metrics(output)}
        delivered.append(record)
        print(f"{cue['id']}: {record['duration_seconds']:.2f}s / {record['active_rms_dbfs']}dBFS",flush=True)
    manifest={'version':1,'generator':'local Kokoro ONNX + original synthesized nonverbal animal vocals',
              'request_sha256':hashlib.sha256((directory/'request.md').read_bytes()).hexdigest(),
              'models_sha256':hashes,'voices':PROFILES,'format':'MP3 mono44100Hz','cues':delivered,
              'quality_note':'Waveform checks do not establish acting/pronunciation quality; human audition required. Four nonverbal animal cues and animal blips are original synthesis.'}
    (directory/('audition_manifest.json' if args.only else 'manifest.json')).write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print(f'COMPLETE {len(delivered)} files; decoded waveform checks passed.',flush=True)

if __name__=='__main__': main()
