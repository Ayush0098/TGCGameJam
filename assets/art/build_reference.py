"""Original vector production masters for the first LIGHTBULB MOMENT art batch.

No imported art, fonts or dependencies. Run with Python from any directory.
Each rig part uses the same canvas; JSON pivots describe animation joints.
"""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
INK = '#453747'
DEFS = '''<defs>
<linearGradient id="skin" x2=".8" y2="1"><stop stop-color="#ffdfb0"/><stop offset="1" stop-color="#e9a478"/></linearGradient>
<linearGradient id="shirt" x2="1" y2="1"><stop stop-color="#ddf2e5"/><stop offset="1" stop-color="#8fbbae"/></linearGradient>
<linearGradient id="vest" x2=".4" y2="1"><stop stop-color="#b85266"/><stop offset="1" stop-color="#773b57"/></linearGradient>
<linearGradient id="fur" x2=".5" y2="1"><stop stop-color="#ffda86"/><stop offset="1" stop-color="#d78c42"/></linearGradient>
<linearGradient id="ear" x2="1" y2="1"><stop stop-color="#835544"/><stop offset="1" stop-color="#513946"/></linearGradient>
</defs>'''

def path(d, fill='none', stroke=INK, width=5, extra=''):
    return f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{width}" stroke-linecap="round" stroke-linejoin="round" {extra}/>'

def ellipse(cx, cy, rx, ry, fill, stroke=INK, width=5, extra=''):
    return f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="{fill}" stroke="{stroke}" stroke-width="{width}" {extra}/>'

def svg(body, size=(320,400)):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{size[0]}" height="{size[1]}" viewBox="0 0 {size[0]} {size[1]}">{DEFS}{body}</svg>\n'

boss = {
 'leg_left': ((133,298), -3, path('M111 287 Q130 278 151 290 L148 357 Q138 369 116 357 Z','#59647b')+path('M114 348 Q138 343 149 354 L148 379 Q122 386 92 378 Q89 369 103 362 Z','#493f52')+path('M105 368 Q124 373 143 366',stroke='#8d8190',width=3)),
 'leg_right': ((185,298), -2, path('M164 288 Q185 280 208 290 L209 357 Q196 368 175 358 Z','#65718a')+path('M176 351 Q195 342 210 353 L225 365 Q237 378 224 380 L176 381 Z','#493f52')+path('M183 367 Q202 373 218 366',stroke='#8d8190',width=3)),
 'arm_left': ((104,187), -1, path('M107 171 Q80 171 70 202 L67 250 Q71 260 88 261 L111 206 Z','url(#shirt)')+path('M68 241 L90 246 L87 263 L65 258 Z','#d9ede0')+path('M66 258 Q54 274 63 286 Q68 294 74 284 Q77 301 83 291 Q88 296 91 282 L90 260 Z','url(#skin)')),
 'body': ((160,218), 0, path('M116 166 Q159 149 202 167 Q241 211 224 287 Q162 317 92 284 Q83 217 116 166 Z','url(#shirt)')+path('M116 173 L146 188 L160 252 L174 188 L203 171 Q234 213 226 282 Q195 299 166 298 L160 282 L151 300 Q118 302 94 283 Q89 217 116 173 Z','url(#vest)')+path('M115 172 L143 177 L151 201 L129 198 Z','#f1f3dc')+path('M173 177 L200 170 L186 198 L168 199 Z','#f1f3dc')+path('M161 218 L161 277',stroke='#65354e',width=3)+ellipse(169,228,3,3,'#efc184',width=2)+ellipse(169,251,3,3,'#efc184',width=2)+ellipse(169,274,3,3,'#efc184',width=2)+path('M184 246 L213 243 L211 257 L188 259 Z','#73344d',width=3)+path('M119 260 Q132 279 145 276',stroke='#cf8290',width=3)),
 'arm_right': ((213,190), 1, path('M211 174 Q237 175 245 205 L249 250 Q237 262 222 253 L202 210 Z','url(#shirt)')+path('M222 243 L247 240 L250 259 L226 263 Z','#d9ede0')+path('M229 260 Q221 276 230 290 Q235 298 239 287 Q245 299 250 290 Q258 289 254 275 L248 258 Z','url(#skin)')),
 'head': ((160,114), 2, ellipse(106,116,12,18,'url(#skin)')+ellipse(214,116,12,18,'url(#skin)')+path('M106 85 Q108 46 161 44 Q213 48 215 91 L213 139 Q203 172 162 177 Q123 174 108 143 Z','url(#skin)')+path('M108 105 Q102 68 126 53 Q138 42 161 45 Q186 44 204 63 Q216 78 213 104 L205 87 Q193 75 192 64 Q179 80 151 71 Q129 67 120 90 L118 107 Z','#64505c',width=3)+path('M125 61 Q144 54 159 58',stroke='#8b727a',width=3)+ellipse(128,141,14,7,'#e88d7c',stroke='none',width=0,extra='opacity=".45"')+ellipse(196,141,14,7,'#e88d7c',stroke='none',width=0,extra='opacity=".45"')+path('M148 126 Q161 119 174 128 Q174 139 161 141 Q150 138 148 126 Z','#efbc90',width=3)),
 'bowtie': ((160,180), 3, path('M140 174 L156 180 L177 171 L179 190 L161 186 L141 192 Z','#dfab54',width=4)+ellipse(159,183,6,6,'#f0c47c',width=3)),
}

dog = {
 'tail': ((86,259), -3, path('M91 265 Q36 266 39 221 Q37 197 20 213 Q3 261 38 286 Q58 298 91 290 Z','url(#fur)')+path('M38 227 Q31 252 44 264',stroke='#ffe4a3',width=5)),
 'leg_left': ((122,299), -2, path('M104 278 Q129 270 140 288 L135 355 Q150 360 150 373 Q128 384 100 377 Q87 374 91 363 L105 352 Z','url(#fur)')+path('M105 368 L105 376 M119 367 L120 378',stroke='#9c643f',width=3)),
 'leg_right': ((218,300), -1, path('M204 277 Q228 271 241 290 L239 354 Q262 359 260 373 Q243 383 212 378 Q200 375 203 361 L211 348 Z','url(#fur)')+path('M225 368 L225 377 M240 366 L241 376',stroke='#9c643f',width=3)),
 'body': ((160,271), 0, path('M100 220 Q133 206 180 220 Q225 229 244 270 Q256 316 223 335 Q174 352 118 331 Q81 321 83 278 Q85 244 100 220 Z',fill='url(#fur)')+path('M138 235 Q171 223 194 245 Q226 275 207 310 Q172 329 138 311 Q123 276 138 235 Z','#fbe2ac',width=3)+path('M96 273 Q104 277 108 272 M226 286 Q231 279 235 282',stroke='#b67645',width=3)),
 'arm_left': ((110,245), 1, path('M102 237 Q88 249 98 279 L109 327 Q100 346 111 353 Q127 359 138 345 L131 327 L123 256 Z','url(#fur)')+path('M114 342 L115 351 M126 342 L127 352',stroke='#9c643f',width=3)),
 'arm_right': ((220,245), 1, path('M217 237 Q234 245 230 277 L222 327 Q240 340 230 351 Q213 359 202 346 L204 328 L204 260 Z','url(#fur)')+path('M212 342 L213 353 M223 341 L224 351',stroke='#9c643f',width=3)),
 'head': ((160,149), 2, path('M102 104 Q121 70 161 70 Q205 72 222 111 L217 176 Q207 215 161 222 Q115 214 105 179 Z','url(#fur)')+path('M128 87 Q137 74 148 79 M155 78 Q168 66 172 76 M183 80 Q195 80 201 91',stroke='#a66842',width=3)+ellipse(158,174,44,29,'#ffe6b9',width=4)+path('M153 172 Q158 160 172 169 Q179 181 168 188 Q155 186 153 172 Z','#513d48',width=4)+ellipse(163,171,4,2,'#ad8b88',stroke='none',width=0)),
 'ear_left': ((108,110), 3, path('M114 94 Q79 88 68 125 Q64 166 90 181 Q111 184 116 151 L123 108 Z','url(#ear)')+path('M92 108 Q79 127 82 149',stroke='#a27358',width=4)),
 'ear_right': ((211,110), 3, path('M204 94 Q239 87 249 124 Q254 161 232 178 Q212 185 205 151 L196 110 Z','url(#ear)')+path('M225 108 Q236 126 235 147',stroke='#a27358',width=4)),
 'bandana': ((160,222), 4, path('M110 204 Q158 225 214 201 L208 223 L181 249 L163 276 L139 242 L115 223 Z','#529f9a')+path('M135 226 Q154 232 177 227',stroke='#b5ded1',width=4)+ellipse(163,241,5,5,'#e8db91',width=2)),
}

def face(kind, name):
    bx, by, right = (137,111,184) if kind=='boss' else (135,137,189)
    mouth_y = 159 if kind=='boss' else 196
    out=''
    for x in (bx,right):
        if name=='sleepy':
            # Only the thin white lower crescent is visible beneath a heavy lid.
            out+=path(f'M{x-14} {by} Q{x} {by-4} {x+14} {by+2} Q{x+11} {by+14} {x-9} {by+12} Z','#fff8e8',width=3)
            out+=ellipse(x+2,by+7,4,5,INK,stroke='none',width=0)
            out+=path(f'M{x-15} {by-1} Q{x} {by-3} {x+14} {by+2}',width=6)
            out+=path(f'M{x-12} {by+16} Q{x} {by+20} {x+11} {by+16}',stroke='#c1847a',width=3)
        elif name=='pleased':
            out+=path(f'M{x-14} {by+4} Q{x} {by-17} {x+14} {by+4}',width=6)
            out+=path(f'M{x-16} {by+9} l-4 4 M{x+16} {by+9} l4 4',stroke='#c4776e',width=3)
        elif name=='angry':
            inner = 1 if x==bx else -1
            out+=path(f'M{x-14} {by-5*inner} L{x+14} {by+5*inner} Q{x+12} {by+15} {x-10} {by+12} Z','#fff8e8',width=3)
            out+=ellipse(x+inner*4,by+5,5,6,INK,stroke='none',width=0)
        else:
            rx,ry=(14,17) if name in ('frightened','surprised','hungry') else (9,11)
            out+=ellipse(x,by,rx,ry,'#fff8e8',width=3)
            pupil=8 if name=='frightened' else 5 if name in ('surprised','hungry') else 4
            px=x+5 if name=='hungry' else x
            py=by+5 if name=='hungry' else by
            out+=ellipse(px,py,pupil,pupil+1,INK,stroke='none',width=0)
            out+=ellipse(px-2,py-3,2,2,'#fff',stroke='none',width=0)
    if name=='angry':
        out+=path(f'M{bx-16} {by-17} L{bx+14} {by-7} M{right-14} {by-7} L{right+16} {by-17}',width=8)
        out+=path(f'M{right+23} {by-22} l5 -4 l4 7 M{right+27} {by-10} l6 -3',stroke='#b95758',width=3)
    elif name=='frightened':
        out+=path(f'M{bx-15} {by-21} Q{bx} {by-22} {bx+12} {by-30} M{right-12} {by-30} Q{right} {by-22} {right+15} {by-21}',width=5)
    elif name in ('surprised','hungry'):
        out+=path(f'M{bx-14} {by-23} Q{bx} {by-35} {bx+13} {by-24} M{right-13} {by-24} Q{right} {by-35} {right+14} {by-23}',width=5)
    elif name=='sleepy':
        out+=path(f'M{bx-14} {by-14} q14 5 27 2 M{right-13} {by-12} q14 -3 27 1',width=4)
    else:
        out+=path(f'M{bx-11} {by-17} q11 -5 22 -1 M{right-11} {by-18} q11 -4 22 1',width=4)
    if name=='surprised':
        out+=ellipse(161,mouth_y,12,15,'#8d4b59',width=4)
        out+=ellipse(161,mouth_y+6,6,4,'#e69398',stroke='none',width=0)
    elif name=='frightened':
        out+=path(f'M140 {mouth_y-5} Q149 {mouth_y-13} 161 {mouth_y-5} Q174 {mouth_y-13} 183 {mouth_y-4} L183 {mouth_y+7} Q174 {mouth_y+13} 161 {mouth_y+7} Q149 {mouth_y+13} 140 {mouth_y+6} Z','#fff3dc',width=4)
        out+=path(f'M143 {mouth_y+1} L180 {mouth_y+1} M153 {mouth_y-3} v10 M170 {mouth_y-3} v10',stroke='#b8867d',width=2)
        out+=path(f'M215 {by-13} Q235 {by+7} 222 {by+17} Q207 {by+14} 215 {by-13} Z','#91d6d5',width=3)
        out+=path(f'M224 {by-1} l2 7',stroke='#ddfcf3',width=3)
    elif name=='hungry':
        out+=path(f'M137 {mouth_y-5} Q160 {mouth_y+22} 186 {mouth_y-7} Q180 {mouth_y+15} 160 {mouth_y+14} Q144 {mouth_y+12} 137 {mouth_y-5} Z','#914659',width=4)
        out+=path(f'M164 {mouth_y+6} Q182 {mouth_y+5} 192 {mouth_y-6} Q199 {mouth_y+2} 190 {mouth_y+10} Q179 {mouth_y+19} 167 {mouth_y+12} Z','#ef8d96',width=3)
        out+=path(f'M191 {mouth_y+10} Q201 {mouth_y+24} 192 {mouth_y+25} Q186 {mouth_y+23} 191 {mouth_y+10} Z','#91d6d5',width=2)
    elif name=='sleepy':
        out+=ellipse(161,mouth_y,14,15,'#8d4b59',width=4)
        out+=path(f'M151 {mouth_y-8} Q161 {mouth_y-11} 171 {mouth_y-8}',stroke='#fff4dd',width=4)
        out+=ellipse(161,mouth_y+8,8,4,'#e69398',stroke='none',width=0)
    elif name=='angry':
        out+=path(f'M138 {mouth_y-2} Q161 {mouth_y-13} 184 {mouth_y-2} L180 {mouth_y+8} Q160 {mouth_y+3} 142 {mouth_y+9} Z','#fff3dc',width=4)
        out+=path(f'M143 {mouth_y+1} L180 {mouth_y+1} M151 {mouth_y-4} v10 M163 {mouth_y-5} v10 M175 {mouth_y-3} v9',stroke='#b8867d',width=2)
    elif name=='pleased':
        out+=path(f'M135 {mouth_y-8} Q161 {mouth_y+3} 188 {mouth_y-9} Q179 {mouth_y+18} 160 {mouth_y+17} Q142 {mouth_y+14} 135 {mouth_y-8} Z','#914659',width=4)
        out+=path(f'M142 {mouth_y-4} Q161 {mouth_y+2} 180 {mouth_y-5}',stroke='#fff4dd',width=6)
        out+=ellipse(161,mouth_y+11,10,4,'#e69398',stroke='none',width=0)
    else:
        out+=path(f'M146 {mouth_y} Q162 {mouth_y+8} 178 {mouth_y-1}',width=4)
    if kind=='boss':
        # A separate moustache follows each expression above its upper lip.
        my=mouth_y-12
        out+=path(f'M143 {my+2} Q154 {my-6} 161 {my} Q171 {my-7} 180 {my+1} Q182 {my+6} 168 {my+5} L161 {my+3} Q149 {my+9} 139 {my+6} Z','#6c4e53',width=2)
    return out

EXPRESSIONS=['neutral','hungry','sleepy','angry','frightened','surprised','pleased']
ACTIONS=['idle','walk','startle','run','eat','sit','sleep','bonk','ko','exit','celebrate']

def write_character(kind, layers):
    master=ROOT/'assets/art/characters'/kind
    runtime=ROOT/'src/assets/characters'/kind
    for folder in (master,runtime): folder.mkdir(parents=True,exist_ok=True)
    parts=[]
    for name,(pivot,z,body) in layers.items():
        for folder in (master,runtime): (folder/f'{name}.svg').write_text(svg(body),encoding='utf-8')
        parts.append({'name':name,'texture':f'res://assets/characters/{kind}/{name}.svg','pivot':list(pivot),'z':z})
    for exp in EXPRESSIONS:
        for folder in (master,runtime): (folder/f'face_{exp}.svg').write_text(svg(face(kind,exp)),encoding='utf-8')
    manifest={'id':kind,'canvas':[320,400],'anchor':[160,380],'parts':parts,'expressions':{x:f'res://assets/characters/{kind}/face_{x}.svg' for x in EXPRESSIONS},'animations':ACTIONS,'author':'Original LIGHTBULB MOMENT production artwork'}
    for folder in (master,runtime): (folder/'rig.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    assembled=''.join(item[2] for _,item in sorted(layers.items(),key=lambda i:i[1][1]))+face(kind,'neutral')
    (master/'assembled.svg').write_text(svg(assembled),encoding='utf-8')

def write_icons():
    # All icons are readable at small size: one silhouette and restrained ink detail.
    drawings={
      'hungry': ellipse(64,74,47,33,'#f3e5c4',width=5)+ellipse(64,74,35,22,'#fff5df',stroke='#bd966b',width=3)+path('M36 49 Q29 26 47 24 Q52 16 61 26 Q80 21 89 35 L93 57 Q84 75 58 70 L39 66 Z', '#d68b42')+path('M41 44 L86 44 L88 56 L40 55 Z','#f5c960',width=4)+path('M39 58 Q51 53 62 60 Q73 53 88 58',stroke='#689b65',width=6)+path('M30 13 L25 5 M99 18 L106 9',stroke='#cc8138',width=4),
      'sleepy': path('M66 15 Q37 20 37 51 Q38 80 66 85 Q39 102 20 79 Q-1 52 18 26 Q34 10 66 15 Z','#aac5eb')+path('M60 41 L89 41 L63 67 L92 67 L92 75 L53 75 L53 67 L79 49 L60 49 Z','#7299c8')+path('M84 16 L111 16 L91 34 L113 34 L113 41 L80 41 L80 34 L101 23 L84 23 Z','#aac5eb',width=3)+path('M89 92 l4 -9 l4 9 l9 4 l-9 4 l-4 9 l-4 -9 l-9 -4 Z','#efd492',width=3),
      'angry': path('M23 35 L40 35 L45 16 L62 30 L78 14 L83 35 L104 34 L94 56 L110 73 L87 80 L84 106 L63 93 L43 109 L38 84 L15 77 L29 59 Z','#dc7971')+path('M43 48 L62 59 L78 48 L84 56 L67 70 L50 65 Z','#fff2d6')+path('M46 83 Q63 72 81 82',stroke=INK,width=5)+path('M14 15 L22 23 M110 17 L102 24',stroke='#b24c58',width=4),
      'scared': path('M35 91 L29 57 Q28 27 63 22 Q95 24 98 54 L94 98 L79 89 L65 104 L51 91 Z','#beaddb')+ellipse(50,53,8,11,'#fff6e6',width=3)+ellipse(77,53,8,11,'#fff6e6',width=3)+ellipse(51,54,3,5,INK,width=0)+ellipse(77,54,3,5,INK,width=0)+ellipse(64,79,8,10,'#765b8c',width=3)+path('M17 40 Q6 48 17 58 M111 40 Q122 48 111 58',stroke='#9680ba',width=4)
    }
    for folder in (ROOT/'assets/art/thoughts',ROOT/'src/assets/thoughts'): folder.mkdir(parents=True,exist_ok=True)
    for name,body in drawings.items():
        for folder in (ROOT/'assets/art/thoughts',ROOT/'src/assets/thoughts'):
            (folder/f'{name}.svg').write_text(svg(body,(128,128)),encoding='utf-8')

if __name__=='__main__':
    write_character('boss',boss)
    write_character('dog',dog)
    write_icons()
    print('Produced 17 rig parts, 14 expression cutouts, four thought icons, and matching masters.')
