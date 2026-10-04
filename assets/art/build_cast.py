"""Original vector masters for the rest of the LIGHTBULB MOMENT cast and props.

Grandma, Kid and Intern share the Boss skeleton (same canvas, anchor and joint
pivots), so every authored AnimationPlayer action and expression pose works
unchanged. Faces reuse the Boss expression set without the moustache.
No imported art, fonts or dependencies. Run with Python from any directory;
it never rewrites the Boss or Dog files produced by build_reference.py.
"""
from pathlib import Path
import json

from build_reference import INK, path, ellipse, face, EXPRESSIONS, ACTIONS

ROOT = Path(__file__).resolve().parents[2]

DEFS = '''<defs>
<linearGradient id="skin_light" x2=".8" y2="1"><stop stop-color="#ffe8cf"/><stop offset="1" stop-color="#eab894"/></linearGradient>
<linearGradient id="skin_kid" x2=".8" y2="1"><stop stop-color="#f6cfa6"/><stop offset="1" stop-color="#cf8f62"/></linearGradient>
<linearGradient id="skin_deep" x2=".8" y2="1"><stop stop-color="#c9926b"/><stop offset="1" stop-color="#8c5a3d"/></linearGradient>
<linearGradient id="cardigan" x2=".4" y2="1"><stop stop-color="#c7b1e0"/><stop offset="1" stop-color="#7f68a8"/></linearGradient>
<linearGradient id="tee" x2=".4" y2="1"><stop stop-color="#ef6a5d"/><stop offset="1" stop-color="#bb3b3f"/></linearGradient>
<linearGradient id="oxford" x2="1" y2="1"><stop stop-color="#dcebfb"/><stop offset="1" stop-color="#8fb0d6"/></linearGradient>
<linearGradient id="catfur" x2=".5" y2="1"><stop stop-color="#ffb767"/><stop offset="1" stop-color="#d9772f"/></linearGradient>
<linearGradient id="mousefur" x2=".5" y2="1"><stop stop-color="#d9d4de"/><stop offset="1" stop-color="#9890a6"/></linearGradient>
</defs>'''


def svg(body, size=(320, 400)):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{size[0]}" height="{size[1]}" viewBox="0 0 {size[0]} {size[1]}">{DEFS}{body}</svg>\n'


HEAD = 'M106 85 Q108 46 161 44 Q213 48 215 91 L213 139 Q203 172 162 177 Q123 174 108 143 Z'
NOSE = 'M148 126 Q161 119 174 128 Q174 139 161 141 Q150 138 148 126 Z'


def head(skin, hair_back='', hair_front='', extra='', nose='#efbc90'):
    return (hair_back + ellipse(106, 116, 12, 18, f'url(#{skin})') + ellipse(214, 116, 12, 18, f'url(#{skin})')
            + path(HEAD, f'url(#{skin})') + hair_front
            + ellipse(128, 141, 14, 7, '#e88d7c', stroke='none', width=0, extra='opacity=".45"')
            + ellipse(196, 141, 14, 7, '#e88d7c', stroke='none', width=0, extra='opacity=".45"')
            + path(NOSE, nose, width=3) + extra)


def hand_left(skin):
    return path('M66 258 Q54 274 63 286 Q68 294 74 284 Q77 301 83 291 Q88 296 91 282 L90 260 Z', f'url(#{skin})')


def hand_right(skin):
    return path('M229 260 Q221 276 230 290 Q235 298 239 287 Q245 299 250 290 Q258 289 254 275 L248 258 Z', f'url(#{skin})')


def legs(trouser, shoe, skin=None, hem=287):
    """Boss-pivot legs; with skin set, the trouser stops at the knee (shorts/stockings)."""
    if skin:
        left = (path(f'M112 {hem} Q131 {hem-8} 151 {hem+2} L148 318 L114 318 Z', trouser)
                + path('M118 316 L145 316 L143 354 L121 354 Z', skin))
        right = (path(f'M166 {hem} Q186 {hem-8} 207 {hem+2} L207 318 L172 318 Z', trouser)
                 + path('M175 316 L203 316 L202 353 L179 353 Z', skin))
    else:
        left = path(f'M111 {hem} Q130 {hem-9} 151 {hem+3} L148 357 Q138 369 116 357 Z', trouser)
        right = path(f'M164 {hem+1} Q185 {hem-7} 208 {hem+3} L209 357 Q196 368 175 358 Z', trouser)
    left += path('M114 348 Q138 343 149 354 L148 379 Q122 386 92 378 Q89 369 103 362 Z', shoe)
    left += path('M100 372 Q122 377 146 371', stroke='#fbf1e2', width=3)
    right += path('M176 351 Q195 342 210 353 L225 365 Q237 378 224 380 L176 381 Z', shoe)
    right += path('M181 372 Q203 377 224 372', stroke='#fbf1e2', width=3)
    return left, right


def arms(sleeve, skin, short=False, cuff='#f4efe6'):
    if short:
        left = (path('M76 196 L70 250 Q71 260 88 261 L102 208 Z', f'url(#{skin})')
                + path('M107 171 Q80 171 72 202 L100 212 L112 190 Z', sleeve))
        right = (path('M244 196 L249 250 Q237 262 222 253 L216 208 Z', f'url(#{skin})')
                 + path('M211 174 Q237 175 247 203 L218 213 L204 192 Z', sleeve))
    else:
        left = path('M107 171 Q80 171 70 202 L67 250 Q71 260 88 261 L111 206 Z', sleeve) + path('M68 241 L90 246 L87 263 L65 258 Z', cuff)
        right = path('M211 174 Q237 175 245 205 L249 250 Q237 262 222 253 L202 210 Z', sleeve) + path('M222 243 L247 240 L250 259 L226 263 Z', cuff)
    return left + hand_left(skin), right + hand_right(skin)


# ------------------------------------------------------------------ Grandma
g_legs = legs('#d6c3ae', '#6b4660', skin='#e3cdb7', hem=296)
g_arms = arms('url(#cardigan)', 'skin_light', cuff='#efe3f7')
grandma = {
    'leg_left': ((133, 298), -3, g_legs[0]),
    'leg_right': ((185, 298), -2, g_legs[1]),
    'arm_left': ((104, 187), -1, g_arms[0]),
    'body': ((160, 218), 0,
             path('M118 166 Q160 152 202 167 Q234 212 238 304 Q160 326 82 304 Q86 212 118 166 Z', 'url(#cardigan)')
             + path('M160 186 L160 306', stroke='#5d4a80', width=3)
             + path('M100 260 Q160 276 222 260', stroke='#a48dc6', width=4)
             + ellipse(150, 212, 4, 4, '#f3e6fb', width=2) + ellipse(150, 236, 4, 4, '#f3e6fb', width=2) + ellipse(150, 260, 4, 4, '#f3e6fb', width=2)
             + path('M174 268 L206 266 L204 286 L176 288 Z', '#a993cc', width=3)
             + path('M132 168 Q160 192 188 168 Q178 186 160 189 Q142 186 132 168 Z', '#fbf4ea', width=3)),
    'arm_right': ((213, 190), 1, g_arms[1]),
    'head': ((160, 114), 2, head(
        'skin_light',
        hair_back=ellipse(160, 34, 30, 22, '#d6d2dd') + path('M146 20 Q160 12 174 20', stroke='#a7a1b3', width=3),
        hair_front=path('M106 104 Q98 56 160 44 Q222 56 214 104 Q206 76 186 66 Q160 78 134 66 Q114 76 106 104 Z', '#dedae4', width=4)
        + path('M122 72 Q138 62 152 70 M168 70 Q184 62 200 74', stroke='#a7a1b3', width=3),
        extra=ellipse(104, 136, 5, 5, '#f2e7ff', width=2) + ellipse(216, 136, 5, 5, '#f2e7ff', width=2))),
    'bowtie': ((160, 180), 3,
               ''.join(ellipse(132 + i * 8, 182 + (i - 3.5) ** 2 * 0.9, 5, 5, '#fbf7ee', width=2) for i in range(8))),
}

# ---------------------------------------------------------------------- Kid
k_legs = legs('#3e6fb0', '#d9473f', skin='url(#skin_kid)')
k_arms = arms('url(#tee)', 'skin_kid', short=True)
kid = {
    'leg_left': ((133, 298), -3, k_legs[0]),
    'leg_right': ((185, 298), -2, k_legs[1]),
    'arm_left': ((104, 187), -1, k_arms[0]),
    'body': ((160, 218), 0,
             path('M118 168 Q160 154 202 168 Q228 214 222 284 Q160 302 98 284 Q92 214 118 168 Z', 'url(#tee)')
             + path('M104 206 Q160 214 216 206 M101 236 Q160 244 220 236 M100 264 Q160 272 221 264', stroke='#fbefe0', width=8)
             + path('M140 168 Q160 184 180 168', stroke=INK, width=4)
             + path('M146 222 l14 -16 l14 16 l-14 16 Z', '#ffd27a', width=3)),
    'arm_right': ((213, 190), 1, k_arms[1]),
    'head': ((160, 114), 2, head(
        'skin_kid',
        hair_front=path('M104 106 Q96 62 124 50 L128 30 L146 44 L156 22 L170 42 L186 26 L190 48 Q218 58 216 104 Q206 80 190 74 Q170 88 150 76 Q126 72 118 98 Z', '#7a4a2c', width=4),
        extra=''.join(ellipse(x, 132, 2, 2, '#b06a45', stroke='none', width=0) for x in (124, 132, 128, 188, 196, 192)))),
}

# ------------------------------------------------------------------- Intern
i_legs = legs('#b9a27a', '#5a3b2c')
i_arms = arms('url(#oxford)', 'skin_deep', cuff='#eef5fd')
intern = {
    'leg_left': ((133, 298), -3, i_legs[0]),
    'leg_right': ((185, 298), -2, i_legs[1]),
    'arm_left': ((104, 187), -1, i_arms[0]),
    'body': ((160, 218), 0,
             path('M116 166 Q159 149 202 167 Q238 211 224 288 Q162 312 94 287 Q84 217 116 166 Z', 'url(#oxford)')
             + path('M118 172 L150 180 L140 200 Z M202 172 L170 180 L180 200 Z', '#f6fbff', width=3)
             + path('M184 222 L210 220 L210 240 L186 242 Z', '#c4d8ee', width=3)
             + path('M128 176 Q140 232 176 250', stroke='#2f8f6a', width=4)
             + path('M168 244 L196 240 L198 268 L170 272 Z', '#fbf7ee', width=3)
             + path('M174 252 L192 250 M175 260 L188 258', stroke='#7a8aa0', width=2)),
    'arm_right': ((213, 190), 1, i_arms[1]),
    'head': ((160, 114), 2, head(
        'skin_deep', nose='#a8704f',
        hair_front=path('M106 104 Q98 56 132 46 Q162 36 198 50 Q222 64 214 104 L206 84 Q196 66 170 66 Q140 62 124 72 Q112 84 110 106 Z', '#2c2530', width=4)
        + path('M150 46 Q146 56 150 64', stroke='#5a4f63', width=3))),
    'bowtie': ((160, 180), 3, path('M152 176 L168 176 L165 190 L174 238 L160 254 L146 238 L155 190 Z', '#c9483f', width=4)
               + path('M152 176 L168 176 L165 190 L155 190 Z', '#a8353a', width=3)),
}


# ------------------------------------------------- animals (Dog skeleton)
DOG_HEAD = 'M102 104 Q121 70 161 70 Q205 72 222 111 L217 176 Q207 215 161 222 Q115 214 105 179 Z'


def animal_limbs(fur, toe):
    return {
        'leg_left': ((122, 299), -2, path('M104 278 Q129 270 140 288 L135 355 Q150 360 150 373 Q128 384 100 377 Q87 374 91 363 L105 352 Z', fur) + path('M105 368 L105 376 M119 367 L120 378', stroke=toe, width=3)),
        'leg_right': ((218, 300), -1, path('M204 277 Q228 271 241 290 L239 354 Q262 359 260 373 Q243 383 212 378 Q200 375 203 361 L211 348 Z', fur) + path('M225 368 L225 377 M240 366 L241 376', stroke=toe, width=3)),
        'arm_left': ((110, 245), 1, path('M102 237 Q88 249 98 279 L109 327 Q100 346 111 353 Q127 359 138 345 L131 327 L123 256 Z', fur) + path('M114 342 L115 351 M126 342 L127 352', stroke=toe, width=3)),
        'arm_right': ((220, 245), 1, path('M217 237 Q234 245 230 277 L222 327 Q240 340 230 351 Q213 359 202 346 L204 328 L204 260 Z', fur) + path('M212 342 L213 353 M223 341 L224 351', stroke=toe, width=3)),
    }


WHISKERS = path('M118 182 L88 176 M118 190 L88 194 M204 182 L234 176 M204 190 L234 194', stroke=INK, width=2)
BODY = 'M100 220 Q133 206 180 220 Q225 229 244 270 Q256 316 223 335 Q174 352 118 331 Q81 321 83 278 Q85 244 100 220 Z'

cat = dict(animal_limbs('url(#catfur)', '#9c5a2a'))
cat.update({
    'tail': ((86, 259), -3, path('M92 292 Q42 292 44 246 Q46 206 30 186 Q22 176 32 170 Q56 182 62 232 Q64 268 92 270 Z', 'url(#catfur)') + path('M44 222 l14 -4 M42 246 l16 -2 M52 270 l12 -8', stroke='#b45f24', width=4)),
    'body': ((160, 271), 0, path(BODY, 'url(#catfur)') + path('M138 235 Q171 223 194 245 Q226 275 207 310 Q172 329 138 311 Q123 276 138 235 Z', '#ffe9cf', width=3) + path('M96 262 l14 4 M224 262 l-14 4 M98 290 l14 2 M226 292 l-14 2', stroke='#b45f24', width=4)),
    'head': ((160, 149), 2, path(DOG_HEAD, 'url(#catfur)') + path('M146 80 l4 18 M161 76 v20 M176 80 l-4 18', stroke='#b45f24', width=5) + ellipse(161, 186, 34, 22, '#ffe9cf', width=3) + path('M152 172 L170 172 L161 182 Z', '#e8798a', width=3) + WHISKERS),
    'ear_left': ((112, 98), 3, path('M106 104 L100 40 L148 80 Z', 'url(#catfur)') + path('M112 90 L109 58 L134 80 Z', '#f5a7b1', stroke='none', width=0)),
    'ear_right': ((210, 98), 3, path('M216 104 L222 40 L174 80 Z', 'url(#catfur)') + path('M210 90 L213 58 L188 80 Z', '#f5a7b1', stroke='none', width=0)),
    'bandana': ((160, 222), 4, path('M112 212 Q160 232 210 210 L208 224 Q160 246 114 226 Z', '#c9483f') + ellipse(161, 240, 8, 8, '#f0c45a', width=3)),
})

mouse = dict(animal_limbs('url(#mousefur)', '#6f6880'))
mouse.update({
    'tail': ((86, 259), -3, path('M94 300 Q44 330 30 276 Q24 244 52 236', stroke=INK, width=9) + path('M94 300 Q44 330 30 276 Q24 244 52 236', stroke='#f2b6c1', width=5)),
    'body': ((160, 271), 0, path(BODY, 'url(#mousefur)') + path('M138 240 Q171 228 194 248 Q222 276 205 308 Q172 326 140 310 Q125 278 138 240 Z', '#f1edf4', width=3)),
    'head': ((160, 149), 2, path(DOG_HEAD, 'url(#mousefur)') + ellipse(161, 186, 30, 20, '#f1edf4', width=3) + ellipse(161, 174, 8, 7, '#e8798a', width=3) + WHISKERS),
    'ear_left': ((112, 96), 3, ellipse(100, 82, 36, 36, 'url(#mousefur)') + ellipse(100, 82, 22, 22, '#f5b9c3', stroke='none', width=0)),
    'ear_right': ((210, 96), 3, ellipse(222, 82, 36, 36, 'url(#mousefur)') + ellipse(222, 82, 22, 22, '#f5b9c3', stroke='none', width=0)),
})


def human_face(name):
    # Boss faces end with the moustache path; the rest of the cast has none.
    out = face('boss', name)
    return out[:out.rfind('<path')]


def write_character(kind, layers, face_kind='human'):
    master = ROOT / 'assets/art/characters' / kind
    runtime = ROOT / 'src/assets/characters' / kind
    for folder in (master, runtime):
        folder.mkdir(parents=True, exist_ok=True)
    parts = []
    for name, (pivot, z, body) in layers.items():
        for folder in (master, runtime):
            (folder / f'{name}.svg').write_text(svg(body), encoding='utf-8')
        parts.append({'name': name, 'texture': f'res://assets/characters/{kind}/{name}.svg', 'pivot': list(pivot), 'z': z})
    for exp in EXPRESSIONS:
        for folder in (master, runtime):
            (folder / f'face_{exp}.svg').write_text(svg(human_face(exp) if face_kind == 'human' else face('dog', exp)), encoding='utf-8')
    manifest = {'id': kind, 'canvas': [320, 400], 'anchor': [160, 380], 'parts': parts,
                'expressions': {x: f'res://assets/characters/{kind}/face_{x}.svg' for x in EXPRESSIONS},
                'animations': ACTIONS, 'author': 'Original LIGHTBULB MOMENT production artwork'}
    for folder in (master, runtime):
        (folder / 'rig.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    assembled = ''.join(item[2] for _, item in sorted(layers.items(), key=lambda i: i[1][1])) + (human_face('neutral') if face_kind == 'human' else face('dog', 'neutral'))
    (master / 'assembled.svg').write_text(svg(assembled), encoding='utf-8')


# -------------------------------------------------------------------- props
G = '<g stroke="#4b3541" stroke-width="2.5" stroke-linejoin="round" stroke-linecap="round">'
PROPS = {
    'pie': ((96, 60), G + '<ellipse cx="48" cy="50" rx="44" ry="8" fill="#d6cfbd"/><path d="M10 34 Q48 22 86 34 L80 48 Q48 56 16 48 Z" fill="#c9844a"/><path d="M12 33 Q48 14 84 33 Q48 42 12 33 Z" fill="#e8b779"/><path d="M28 30 L36 26 M44 28 L52 24 M60 29 L68 25" stroke="#a8643a"/><path d="M40 10 q4 -6 0 -10 M50 12 q4 -6 0 -10" fill="none" stroke="#c9c2b5"/></g>'),
    'pie_empty': ((96, 60), G + '<ellipse cx="48" cy="50" rx="44" ry="8" fill="#d6cfbd"/><path d="M16 44 Q48 52 80 44" fill="none"/><circle cx="34" cy="44" r="2" fill="#c9844a"/><circle cx="58" cy="46" r="2.5" fill="#c9844a"/><circle cx="47" cy="42" r="1.8" fill="#e8b779"/></g>'),
    'armchair': ((112, 104), G + '<path d="M14 40 Q14 8 56 8 Q98 8 98 40 L98 74 L14 74 Z" fill="#7d9a86"/><path d="M4 50 Q4 38 16 38 Q26 38 26 50 L26 92 L4 92 Z" fill="#6c8a76"/><path d="M86 50 Q86 38 96 38 Q108 38 108 50 L108 92 L86 92 Z" fill="#6c8a76"/><path d="M22 70 L90 70 L90 90 L22 90 Z" fill="#9db7a3"/><path d="M10 92 L12 102 M100 92 L98 102" stroke-width="4"/><path d="M34 26 Q56 18 78 26" fill="none" stroke="#5c7966"/></g>'),
    'office_chair': ((84, 108), G + '<path d="M18 10 Q42 2 66 10 L64 56 Q42 62 20 56 Z" fill="#4f5d73"/><path d="M12 60 Q42 52 72 60 L70 72 Q42 78 14 72 Z" fill="#5d6c84"/><path d="M42 74 L42 94" stroke-width="5"/><path d="M16 100 L68 100 M42 94 L22 104 M42 94 L62 104" stroke-width="4" fill="none"/><circle cx="20" cy="104" r="3.5" fill="#2a2a33"/><circle cx="64" cy="104" r="3.5" fill="#2a2a33"/></g>'),
    'pedal': ((60, 22), G + '<path d="M6 18 L54 18 L52 22 L8 22 Z" fill="#6b6370"/><path d="M10 6 L50 2 L52 14 L10 16 Z" fill="#c64b3d"/><path d="M18 9 L44 6" stroke="#f1b3a9"/></g>'),
    'pedal_down': ((60, 22), G + '<path d="M6 18 L54 18 L52 22 L8 22 Z" fill="#6b6370"/><path d="M10 12 L50 11 L52 17 L10 18 Z" fill="#8e3329"/></g>'),
    'fish': ((96, 44), G + '<ellipse cx="48" cy="36" rx="44" ry="7" fill="#d6cfbd"/><path d="M14 22 Q34 4 62 16 L82 6 L80 34 L62 26 Q34 40 14 22 Z" fill="#7fb3d5"/><path d="M38 12 Q44 20 38 30" fill="none" stroke="#4f86ad"/><circle cx="24" cy="20" r="2.5" fill="#2b2733"/></g>'),
    'fish_empty': ((96, 44), G + '<ellipse cx="48" cy="36" rx="44" ry="7" fill="#d6cfbd"/><path d="M22 28 L70 28 M32 22 L32 34 M42 22 L42 34 M52 22 L52 34 M62 22 L62 34" fill="none" stroke="#8c8679" stroke-width="3"/><path d="M70 28 L80 20 L80 36 Z" fill="#efe9dc"/></g>'),
    'cookie': ((64, 40), G + '<ellipse cx="32" cy="32" rx="30" ry="6" fill="#d6cfbd"/><ellipse cx="32" cy="22" rx="22" ry="11" fill="#d9a05b"/><circle cx="24" cy="20" r="2.5" fill="#5a3b2c"/><circle cx="36" cy="16" r="2.2" fill="#5a3b2c"/><circle cx="40" cy="25" r="2.5" fill="#5a3b2c"/><circle cx="28" cy="27" r="2" fill="#5a3b2c"/></g>'),
    'cookie_empty': ((64, 40), G + '<ellipse cx="32" cy="32" rx="30" ry="6" fill="#d6cfbd"/><circle cx="26" cy="29" r="2" fill="#d9a05b"/><circle cx="38" cy="30" r="1.6" fill="#d9a05b"/></g>'),
    'broccoli': ((64, 70), G + '<ellipse cx="32" cy="62" rx="30" ry="6" fill="#d6cfbd"/><path d="M26 58 L28 36 L36 36 L38 58 Z" fill="#9cc77a"/><circle cx="20" cy="30" r="12" fill="#4f9a4a"/><circle cx="44" cy="30" r="12" fill="#4f9a4a"/><circle cx="32" cy="18" r="14" fill="#5fae55"/><circle cx="26" cy="16" r="3" fill="#7cc46c" stroke="none"/></g>'),
    'broccoli_empty': ((64, 70), G + '<ellipse cx="32" cy="62" rx="30" ry="6" fill="#d6cfbd"/><path d="M28 58 L29 50 L35 50 L36 58 Z" fill="#9cc77a"/></g>'),
    'cheese': ((72, 52), G + '<ellipse cx="36" cy="44" rx="34" ry="7" fill="#d6cfbd"/><path d="M8 38 L60 38 L64 18 L16 10 Z" fill="#f4c84a"/><path d="M16 10 L64 18 L60 24 L12 16 Z" fill="#ffe08a"/><circle cx="26" cy="28" r="4" fill="#d9a92e"/><circle cx="46" cy="30" r="3" fill="#d9a92e"/><circle cx="38" cy="22" r="2.5" fill="#d9a92e"/></g>'),
    'cheese_empty': ((72, 52), G + '<ellipse cx="36" cy="44" rx="34" ry="7" fill="#d6cfbd"/><circle cx="30" cy="40" r="2" fill="#f4c84a"/><circle cx="42" cy="41" r="1.6" fill="#f4c84a"/></g>'),
    'rocker': ((108, 108), G + '<path d="M14 98 Q54 112 98 92" fill="none" stroke-width="5"/><path d="M24 10 L34 10 L38 70 L26 70 Z" fill="#9a6a45"/><path d="M28 14 L84 14 L80 22 L30 22 Z" fill="#9a6a45"/><path d="M30 26 L78 26 L76 62 L34 62 Z" fill="#c69a6b"/><path d="M22 66 L92 66 L90 76 L24 76 Z" fill="#9a6a45"/><path d="M30 76 L28 98 M84 76 L86 94" stroke-width="5"/><path d="M28 70 Q60 60 88 70" fill="none" stroke="#e8c79b"/></g>'),
    'lamp_off': ((80, 72), G + '<path d="M40 0 L40 22" fill="none"/><path d="M20 22 L60 22 L76 52 L4 52 Z" fill="#5b6478"/><path d="M8 50 L72 50" stroke="#8e97aa"/><ellipse cx="40" cy="58" rx="10" ry="6" fill="#8e97aa"/></g>'),
    'lamp_on': ((80, 72), G + '<path d="M40 0 L40 22" fill="none"/><path d="M20 22 L60 22 L76 52 L4 52 Z" fill="#e7b54a"/><path d="M8 50 L72 50" stroke="#fff1c4"/><ellipse cx="40" cy="58" rx="12" ry="8" fill="#fff4d6"/></g>'),
}


def write_props():
    for folder in (ROOT / 'assets/art/props', ROOT / 'src/assets/props'):
        folder.mkdir(parents=True, exist_ok=True)
        for name, (size, body) in PROPS.items():
            (folder / f'{name}.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="{size[0]}" height="{size[1]}" viewBox="0 0 {size[0]} {size[1]}">{body}</svg>\n', encoding='utf-8')


if __name__ == '__main__':
    write_character('grandma', grandma)
    write_character('kid', kid)
    write_character('intern', intern)
    write_character('cat', cat, face_kind='dog')
    write_character('mouse', mouse, face_kind='dog')
    write_props()
    print('Produced Grandma, Kid, Intern, Cat and Mouse rigs (7 expressions each) and', len(PROPS), 'props.')
