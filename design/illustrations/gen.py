import math
def shadow(cx=60, cy=108, rx=38, ry=6):
    return f'''<radialGradient id="sh" cx="50%" cy="50%" r="50%"><stop offset="0" stop-color="#000" stop-opacity="0.28"/><stop offset="1" stop-color="#000" stop-opacity="0"/></radialGradient>''', f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="url(#sh)"/>'
def lg(id, c1, c2, x1=0, y1=0, x2=0, y2=1):
    return f'<linearGradient id="{id}" x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}"><stop offset="0" stop-color="{c1}"/><stop offset="1" stop-color="{c2}"/></linearGradient>'
def svg(defs, body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"><defs>{defs}</defs>{body}</svg>'

out = {}
# Quran: open book on a rehal
sd, se = shadow(60, 108, 34, 5)
defs = sd + lg('wood', '#C98A4E', '#7A4520') + lg('cover', '#38B47A', '#156447') + lg('pl', '#FFFDF6', '#E9DDBF', 0, 0, 1, 0) + lg('pr', '#EFE3C6', '#FFFCF2', 0, 0, 1, 0) + lg('gold', '#F3CF6A', '#C08A1E')
body = se
for a in (38, -38):
    body += f'<rect x="55" y="60" width="10" height="50" rx="3" fill="url(#wood)" transform="rotate({a} 60 86)"/>'
body += '<path d="M10 46 Q36 37 60 50 Q84 37 110 46 L110 86 Q84 77 60 90 Q36 77 10 86 Z" fill="url(#cover)"/>'
body += '<path d="M14 45 Q38 36 60 49 L60 86 Q38 74 14 82 Z" fill="#DCCBA4"/><path d="M106 45 Q82 36 60 49 L60 86 Q82 74 106 82 Z" fill="#DCCBA4"/>'
body += '<path d="M16 41 Q38 32 60 45 L60 82 Q38 70 16 78 Z" fill="url(#pl)"/><path d="M104 41 Q82 32 60 45 L60 82 Q82 70 104 78 Z" fill="url(#pr)"/>'
for dy in (0, 7, 14, 21):
    body += f'<path d="M24 {50+dy} Q40 {43+dy} 54 {52+dy}" stroke="#C7B48A" stroke-width="1.8" fill="none" stroke-linecap="round"/>'
    body += f'<path d="M96 {50+dy} Q80 {43+dy} 66 {52+dy}" stroke="#C7B48A" stroke-width="1.8" fill="none" stroke-linecap="round"/>'
body += '<path d="M60 45 L60 82" stroke="#BFAE86" stroke-width="1.2"/>'
body += '<path d="M57.5 80 L57.5 98 L60.25 94.5 L63 98 L63 80 Z" fill="url(#gold)"/>'
body += '<path d="M12 47 Q36 38.5 60 51" stroke="#fff" stroke-opacity="0.35" stroke-width="1.2" fill="none"/>'
out['Quran'] = svg(defs, body)

# Mathurat: sunrise over hills
sd, se = shadow(60, 108, 40, 5)
defs = sd + '<radialGradient id="sun" cx="40%" cy="35%" r="65%"><stop offset="0" stop-color="#FFF1B8"/><stop offset="0.45" stop-color="#FFC23A"/><stop offset="1" stop-color="#F27A12"/></radialGradient>' + lg('hb', '#A5E8C4', '#5CC593') + lg('hf', '#3FBF82', '#17714B') + lg('cl', '#FFFFFF', '#DCE8F5')
body = se
c = (60, 66)
for th in (180, 150, 120, 90, 60, 30, 0):
    r = math.radians(th); x1, y1 = c[0]+math.cos(r)*37, c[1]-math.sin(r)*37; x2, y2 = c[0]+math.cos(r)*47, c[1]-math.sin(r)*47
    body += f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" stroke="#FFB43A" stroke-width="5.5" stroke-linecap="round"/>'
body += '<circle cx="60" cy="66" r="30" fill="url(#sun)"/><ellipse cx="50" cy="52" rx="9" ry="5" fill="#fff" fill-opacity="0.45" transform="rotate(-30 50 52)"/>'
body += '<path d="M8 82 Q46 60 86 74 Q100 78 112 72 L112 98 L8 98 Z" fill="url(#hb)"/>'
body += '<path d="M6 88 Q36 70 66 84 Q90 96 114 82 L114 100 Q60 112 6 100 Z" fill="url(#hf)"/>'
body += '<path d="M10 86 Q36 72 62 82" stroke="#fff" stroke-opacity="0.35" stroke-width="1.5" fill="none" stroke-linecap="round"/>'
body += '<g><circle cx="84" cy="40" r="8" fill="url(#cl)"/><circle cx="94" cy="36" r="10" fill="url(#cl)"/><circle cx="104" cy="41" r="7" fill="url(#cl)"/><rect x="80" y="40" width="30" height="8" rx="4" fill="url(#cl)"/></g>'
out['Mathurat'] = svg(defs, body)

# Tasbih: loop of beads with a gold tassel
sd, se = shadow(60, 112, 30, 4)
defs = sd + '<radialGradient id="bead" cx="35%" cy="30%" r="75%"><stop offset="0" stop-color="#B9FFF0"/><stop offset="0.35" stop-color="#2FC7A9"/><stop offset="1" stop-color="#0B5F55"/></radialGradient>' + '<radialGradient id="gb" cx="35%" cy="30%" r="75%"><stop offset="0" stop-color="#FFF4C4"/><stop offset="0.4" stop-color="#E9B840"/><stop offset="1" stop-color="#8E5F10"/></radialGradient>' + lg('tas', '#F2C756', '#A9740F')
body = se
cx, cy, R = 60, 50, 31
body += f'<circle cx="{cx}" cy="{cy}" r="{R}" fill="none" stroke="#0E6E62" stroke-width="1.5"/>'
body += '<path d="M60 81 L60 90" stroke="#8E5F10" stroke-width="2"/>'
n = 16
for i in range(n):
    a = math.radians(90 + i*360/n)
    if i == 0: continue
    x, y = cx + math.cos(a)*R, cy + math.sin(a)*R
    body += f'<circle cx="{x:.1f}" cy="{y:.1f}" r="7.2" fill="url(#bead)"/>'
body += '<ellipse cx="60" cy="86" rx="6.5" ry="8" fill="url(#gb)"/>'
body += '<path d="M55 94 L65 94 L71 113 Q60 116 49 113 Z" fill="url(#tas)"/>'
for x in (54, 58, 62, 66):
    body += f'<path d="M60 96 L{x + (x-60)*0.4:.1f} 112" stroke="#8E5F10" stroke-opacity="0.45" stroke-width="1"/>'
body += '<rect x="54" y="92.5" width="12" height="4" rx="2" fill="url(#gb)"/>'
out['Tasbih'] = svg(defs, body)

# Qibla: pocket compass with a needle pointing to the Kaaba
sd, se = shadow(60, 110, 36, 5)
defs = sd + lg('rim', '#F8DC86', '#B47C14') + lg('bev', '#A9720F', '#F4D274') + '<radialGradient id="face" cx="40%" cy="35%" r="70%"><stop offset="0" stop-color="#FFFFFF"/><stop offset="1" stop-color="#DCE4EC"/></radialGradient>' + lg('nn', '#47D093', '#137049') + lg('ns', '#D3D9DF', '#8A96A2') + lg('kb', '#3A3A3A', '#0E0E0E')
body = se
body += '<circle cx="60" cy="14" r="7" fill="none" stroke="url(#rim)" stroke-width="4"/>'
body += '<circle cx="60" cy="62" r="44" fill="url(#rim)"/><circle cx="60" cy="62" r="38.5" fill="url(#bev)"/><circle cx="60" cy="62" r="35" fill="url(#face)"/>'
for k in range(12):
    a = math.radians(k*30); r1 = 30 if k % 3 == 0 else 32; 
    body += f'<line x1="{60+math.sin(a)*r1:.1f}" y1="{62-math.cos(a)*r1:.1f}" x2="{60+math.sin(a)*34:.1f}" y2="{62-math.cos(a)*34:.1f}" stroke="#9AA6B2" stroke-width="{2.2 if k%3==0 else 1.2}" stroke-linecap="round"/>'
ang = 40
body += f'<g transform="rotate({ang} 60 62)"><path d="M60 43 L65.5 62 L54.5 62 Z" fill="url(#nn)"/><path d="M60 84 L65.5 62 L54.5 62 Z" fill="url(#ns)"/><path d="M60 43 L60 62 L54.5 62 Z" fill="#fff" fill-opacity="0.18"/></g>'
body += '<circle cx="60" cy="62" r="4.5" fill="url(#rim)"/>'
a = math.radians(ang); kx, ky = 60 + math.sin(a)*25, 62 - math.cos(a)*25
body += f'<g transform="translate({kx:.1f} {ky:.1f})"><rect x="-6" y="-6" width="12" height="12" rx="1.5" fill="url(#kb)"/><rect x="-6" y="-3" width="12" height="2.2" fill="#E2B13C"/></g>'
body += '<path d="M32 46 A32 32 0 0 1 58 30" stroke="#fff" stroke-opacity="0.8" stroke-width="3" fill="none" stroke-linecap="round"/>'
out['Qibla'] = svg(defs, body)

# Tracker: clipboard checklist with a check badge
sd, se = shadow(58, 110, 34, 5)
defs = sd + lg('board', '#A78BFF', '#6A45E0') + lg('paper', '#FFFFFF', '#ECE7FF') + lg('clip', '#EEF1F5', '#A9B2BF') + lg('ok', '#5ADB98', '#139454') + lg('okb', '#58D894', '#178F55')
body = se
body += '<rect x="20" y="24" width="68" height="82" rx="13" fill="#4B2BB0"/><rect x="20" y="20" width="68" height="82" rx="13" fill="url(#board)"/>'
body += '<rect x="28" y="32" width="52" height="62" rx="7" fill="url(#paper)"/>'
body += '<rect x="41" y="13" width="26" height="13" rx="5.5" fill="url(#clip)"/><circle cx="54" cy="19" r="2.5" fill="#8C96A4"/>'
for i, y in enumerate((46, 62, 78)):
    if i < 2:
        body += f'<circle cx="38" cy="{y}" r="5.5" fill="url(#ok)"/><path d="M35.3 {y} l2 2.2 l3.6 -4" stroke="#fff" stroke-width="1.8" fill="none" stroke-linecap="round" stroke-linejoin="round"/>'
        body += f'<rect x="48" y="{y-2.5}" width="24" height="5" rx="2.5" fill="#CFC6EE"/>'
    else:
        body += f'<circle cx="38" cy="{y}" r="5" fill="none" stroke="#B6ABE2" stroke-width="1.8"/><rect x="48" y="{y-2.5}" width="18" height="5" rx="2.5" fill="#DDD7F3"/>'
body += '<circle cx="88" cy="92" r="17" fill="#fff"/><circle cx="88" cy="92" r="14" fill="url(#okb)"/><path d="M81.5 92 l4.5 4.8 l8 -9" stroke="#fff" stroke-width="3.4" fill="none" stroke-linecap="round" stroke-linejoin="round"/>'
body += '<path d="M24 34 Q24 24 34 24 L60 24" stroke="#fff" stroke-opacity="0.35" stroke-width="2" fill="none" stroke-linecap="round"/>'
out['Tracker'] = svg(defs, body)

# All: four little tiles in the features' colours
sd, se = shadow(60, 108, 38, 5)
cols = [('#4FD08F', '#1D8A58', '#13603D'), ('#FFCB5C', '#F08A1C', '#B4600B'), ('#5FE0C8', '#139A85', '#0B6457'), ('#A78BFF', '#6A45E0', '#4B2BB0')]
defs = sd + ''.join(lg(f't{i}', a, b) for i, (a, b, _) in enumerate(cols))
body = se
for i, (x, y) in enumerate([(22, 20), (62, 20), (22, 60), (62, 60)]):
    body += f'<rect x="{x}" y="{y+5}" width="36" height="36" rx="10" fill="{cols[i][2]}"/><rect x="{x}" y="{y}" width="36" height="36" rx="10" fill="url(#t{i})"/>'
    body += f'<path d="M{x+6} {y+14} Q{x+6} {y+6} {x+14} {y+6} L{x+24} {y+6}" stroke="#fff" stroke-opacity="0.5" stroke-width="2.4" fill="none" stroke-linecap="round"/>'
out['All'] = svg(defs, body)


def star8(cx, cy, r, fill):
    # Rub el Hizb: two overlapping squares
    pts = []
    for rot in (0, 45):
        corners = []
        for k in range(4):
            a = math.radians(rot + 45 + k*90)
            corners.append(f"{cx + math.cos(a)*r:.2f},{cy + math.sin(a)*r:.2f}")
        pts.append(f'<polygon points="{" ".join(corners)}" fill="{fill}"/>')
    return ''.join(pts)

# Bookmark: a red ribbon with a gold star
sd, se = shadow(62, 110, 30, 4)
defs = sd + lg('rib', '#FF6B63', '#B8232B', 0, 0, 1, 1) + lg('gold', '#F6D77A', '#C08A1E')
body = se
rib = 'M{x0} 14 Q{x0} 9 {x1} 9 L{x2} 9 Q{x3} 9 {x3} 14 L{x3} 106 L{xm} 86 L{x0} 106 Z'
body += f'<path d="{rib.format(x0=40, x1=45, x2=83, x3=88, xm=64)}" fill="#7E141B"/>'
body += f'<path d="{rib.format(x0=34, x1=39, x2=77, x3=82, xm=58)}" fill="url(#rib)"/>'
body += '<path d="M40 14 L40 92" stroke="#fff" stroke-opacity="0.35" stroke-width="3" stroke-linecap="round"/>'
body += star8(58, 44, 14, '#E9BF4C') + '<circle cx="58" cy="44" r="5.5" fill="#B8232B"/>'
body += '<path d="M34 20 L82 20" stroke="#7E141B" stroke-opacity="0.25" stroke-width="2"/>'
out['Bookmark'] = svg(defs, body)

# Closed Quran: green cover with a gold frame and star, readable when small
sd, se = shadow(60, 110, 32, 4)
defs = sd + lg('cov', '#3FC283', '#13623F', 0, 0, 1, 1) + lg('pg', '#FFFBEF', '#E3D3AE', 0, 0, 1, 0) + lg('gold', '#F6D77A', '#C08A1E')
body = se
body += '<rect x="32" y="20" width="62" height="86" rx="7" fill="url(#pg)"/>'
for y in (30, 50, 70, 90):
    body += f'<path d="M90 {y} L93 {y}" stroke="#CDBB92" stroke-width="1"/>'
body += '<rect x="24" y="12" width="64" height="88" rx="7" fill="url(#cov)"/>'
body += '<rect x="24" y="12" width="10" height="88" rx="5" fill="#0F5537" fill-opacity="0.45"/>'
body += '<rect x="40" y="22" width="40" height="68" rx="4" fill="none" stroke="url(#gold)" stroke-width="2.5"/>'
body += star8(60, 56, 12, '#E9BF4C') + '<circle cx="60" cy="56" r="5" fill="#1D7A50"/>'
body += '<path d="M38 16 L84 16" stroke="#fff" stroke-opacity="0.35" stroke-width="2" stroke-linecap="round"/>'
out['QuranClosed'] = svg(defs, body)

# Evening Mathurat: crescent moon and stars over dusky hills
sd, se = shadow(60, 108, 40, 5)
defs = sd + lg('moon', '#FFF0B0', '#F2B437', 0, 0, 1, 1) + lg('eb', '#7E8FD6', '#4A5BA8') + lg('ef', '#2F9A70', '#124D36')
body = se
# crescent from two circles
c1, r1, c2, r2 = (58, 50), 26, (70, 42), 22
d = math.dist(c1, c2); a = (r1*r1 - r2*r2 + d*d) / (2*d); h = math.sqrt(r1*r1 - a*a)
mx, my = c1[0] + a*(c2[0]-c1[0])/d, c1[1] + a*(c2[1]-c1[1])/d
p1 = (mx + h*(c2[1]-c1[1])/d, my - h*(c2[0]-c1[0])/d); p2 = (mx - h*(c2[1]-c1[1])/d, my + h*(c2[0]-c1[0])/d)
body += f'<path d="M{p1[0]:.2f} {p1[1]:.2f} A{r1} {r1} 0 1 0 {p2[0]:.2f} {p2[1]:.2f} A{r2} {r2} 0 0 1 {p1[0]:.2f} {p1[1]:.2f} Z" fill="url(#moon)"/>'
def sparkle(x, y, r, c):
    return f'<path d="M{x} {y-r} Q{x} {y} {x+r} {y} Q{x} {y} {x} {y+r} Q{x} {y} {x-r} {y} Q{x} {y} {x} {y-r} Z" fill="{c}"/>'
body += sparkle(92, 28, 7, '#FFE48A') + sparkle(100, 52, 4.5, '#FFF3C4') + sparkle(22, 34, 5, '#FFF3C4') + sparkle(84, 62, 3.5, '#FFE48A')
body += '<path d="M8 82 Q46 60 86 74 Q100 78 112 72 L112 98 L8 98 Z" fill="url(#eb)"/>'
body += '<path d="M6 88 Q36 70 66 84 Q90 96 114 82 L114 100 Q60 112 6 100 Z" fill="url(#ef)"/>'
body += '<path d="M10 86 Q36 72 62 82" stroke="#fff" stroke-opacity="0.3" stroke-width="1.5" fill="none" stroke-linecap="round"/>'
out['MathuratEvening'] = svg(defs, body)


# Calendar: a desk calendar with gold rings and a ticked day
sd, se = shadow(60, 110, 36, 5)
defs = sd + lg('calh', '#45C98A', '#167049') + lg('calb', '#FFFFFF', '#E9EEF2') + lg('gold', '#F6D77A', '#C08A1E') + lg('ok', '#5ADB98', '#139454')
body = se
body += '<rect x="18" y="26" width="84" height="80" rx="13" fill="#B9C3CC"/><rect x="18" y="22" width="84" height="80" rx="13" fill="url(#calb)"/>'
body += '<path d="M18 35 Q18 22 31 22 L89 22 Q102 22 102 35 L102 44 L18 44 Z" fill="url(#calh)"/>'
for x in (40, 80):
    body += f'<rect x="{x-3.5}" y="12" width="7" height="18" rx="3.5" fill="url(#gold)"/>'
for r in range(3):
    for c in range(4):
        x, y = 32 + c*19, 56 + r*15
        if (r, c) == (1, 2):
            body += f'<circle cx="{x}" cy="{y}" r="7.5" fill="url(#ok)"/><path d="M{x-3.5} {y} l2.5 2.6 l4.5 -5" stroke="#fff" stroke-width="2.2" fill="none" stroke-linecap="round" stroke-linejoin="round"/>'
        else:
            body += f'<rect x="{x-5}" y="{y-3.5}" width="10" height="7" rx="3" fill="#D3DAE1"/>'
body += '<path d="M24 32 Q24 27 30 27 L60 27" stroke="#fff" stroke-opacity="0.4" stroke-width="2" fill="none" stroke-linecap="round"/>'
out['Calendar'] = svg(defs, body)

# Search: a magnifying glass with a gold rim
sd, se = shadow(62, 110, 34, 5)
defs = sd + lg('rimg', '#F8DC86', '#B47C14', 0, 0, 1, 1) + '<radialGradient id="lens" cx="35%" cy="30%" r="80%"><stop offset="0" stop-color="#E8FFF4"/><stop offset="1" stop-color="#8FD9B5"/></radialGradient>' + lg('hdl', '#2FA36C', '#0F5537', 0, 0, 1, 1)
body = se
body += '<g transform="rotate(45 50 50)"><rect x="86" y="41" width="30" height="18" rx="8" fill="url(#hdl)"/><rect x="78" y="43.5" width="12" height="13" rx="3" fill="url(#rimg)"/><rect x="92" y="44" width="20" height="3" rx="1.5" fill="#fff" fill-opacity="0.3"/></g>'
body += '<circle cx="50" cy="50" r="32" fill="url(#rimg)"/><circle cx="50" cy="50" r="25" fill="url(#lens)"/>'
body += '<path d="M33 44 A18 18 0 0 1 46 31" stroke="#fff" stroke-opacity="0.9" stroke-width="4.5" fill="none" stroke-linecap="round"/><circle cx="31" cy="53" r="2.4" fill="#fff" fill-opacity="0.8"/>'
out['Search'] = svg(defs, body)

# Kaaba: seen from the left, so the door wall faces you and the Black Stone
# (Hajar Aswad) shows in its silver frame on the corner left of the door
sd, se = shadow(60, 108, 40, 5)
defs = sd + lg('kf', '#2E2E2E', '#0B0B0B') + lg('ks', '#1B1B1B', '#050505') + lg('kt', '#4A4A4A', '#2A2A2A', 0, 0, 1, 0) + lg('gold', '#F6D77A', '#C08A1E') + lg('golds', '#D9B456', '#8E6312') + lg('door', '#F3CF6A', '#A9740F') + lg('silver', '#F4F6F8', '#9AA3AD', 0, 0, 1, 1) + '<radialGradient id="stone" cx="40%" cy="35%" r="70%"><stop offset="0" stop-color="#5A4A44"/><stop offset="1" stop-color="#1C1412"/></radialGradient>'
body = se
# faces: left side, front (the door wall), top
body += '<path d="M20 26 L44 36 L44 104 L20 94 Z" fill="url(#ks)"/>'
body += '<path d="M44 36 L100 36 L100 104 L44 104 Z" fill="url(#kf)"/>'
body += '<path d="M20 26 L76 26 L100 36 L44 36 Z" fill="url(#kt)"/>'
# gold band (hizam) on the side and front
body += '<path d="M20 38 L44 48 L44 57 L20 47 Z" fill="url(#golds)"/>'
body += '<rect x="44" y="48" width="56" height="9" fill="url(#gold)"/>'
for x in range(48, 98, 6):
    body += f'<rect x="{x}" y="51" width="3.5" height="3" rx="1" fill="#8E5F10" fill-opacity="0.45"/>'
for i in range(3):
    x = 24 + i * 6.5
    y = 40.2 + i * 2.7
    body += f'<path d="M{x} {y} L{x+3.5} {y+1.4} L{x+3.5} {y+4.4} L{x} {y+3} Z" fill="#5E3F08" fill-opacity="0.45"/>'
# door, raised on the front wall toward the Black Stone corner
body += '<rect x="51" y="62" width="13" height="28" rx="2" fill="url(#door)"/>'
body += '<rect x="53.5" y="65" width="8" height="22" rx="1.2" fill="none" stroke="#8E5F10" stroke-opacity="0.55" stroke-width="1"/>'
body += '<path d="M57.5 65 L57.5 87" stroke="#8E5F10" stroke-opacity="0.55" stroke-width="1"/>'
# the Black Stone in its silver frame, on the corner and a little lower
body += '<ellipse cx="44" cy="83" rx="3.6" ry="4.8" fill="url(#silver)"/>'
body += '<ellipse cx="44" cy="83.4" rx="2" ry="2.9" fill="url(#stone)"/>'
# a soft highlight on the front edge
body += '<path d="M46 38 L98 38" stroke="#fff" stroke-opacity="0.18" stroke-width="1.5" stroke-linecap="round"/>'
out['Kaaba'] = svg(defs, body)

for k, v in out.items():
    open(f'{k}.svg', 'w').write(v)
