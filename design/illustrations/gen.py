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

# Rakaat: a prayer mat with a mihrab arch and a badge counting rakaat
sd, se = shadow(60, 110, 36, 5)
defs = sd + lg('mat', '#3FC283', '#13623F', 0, 0, 1, 1) + lg('gold', '#F6D77A', '#C08A1E') + lg('arch', '#1D7A50', '#0F5537') + lg('okb', '#58D894', '#178F55')
body = se
body += '<rect x="26" y="16" width="62" height="90" rx="7" fill="#0F4E33"/><rect x="26" y="12" width="62" height="90" rx="7" fill="url(#mat)"/>'
body += '<rect x="32" y="18" width="50" height="78" rx="4" fill="none" stroke="url(#gold)" stroke-width="2.5"/>'
body += '<path d="M40 60 L40 40 Q40 30 57 22 Q74 30 74 40 L74 60 Z" fill="url(#arch)"/>'
body += '<path d="M40 60 L40 40 Q40 30 57 22 Q74 30 74 40 L74 60" fill="none" stroke="url(#gold)" stroke-width="1.8"/>'
body += star8(57, 44, 6, '#E9BF4C')
for x in range(30, 86, 6):
    body += f'<path d="M{x} 102 L{x} 108" stroke="#C08A1E" stroke-width="1.6" stroke-linecap="round"/>'
body += '<path d="M30 70 L84 70 M30 76 L84 76" stroke="#fff" stroke-opacity="0.18" stroke-width="1.5"/>'
body += '<path d="M30 20 Q30 15 36 15 L60 15" stroke="#fff" stroke-opacity="0.35" stroke-width="2" fill="none" stroke-linecap="round"/>'
body += '<circle cx="88" cy="90" r="17" fill="#fff"/><circle cx="88" cy="90" r="14" fill="url(#okb)"/>'
for i, (dx, dy) in enumerate([(-4.5, -4.5), (4.5, -4.5), (-4.5, 4.5), (4.5, 4.5)]):
    if i < 3:
        body += f'<circle cx="{88+dx}" cy="{90+dy}" r="3" fill="#fff"/>'
    else:
        body += f'<circle cx="{88+dx}" cy="{90+dy}" r="2.4" fill="none" stroke="#fff" stroke-width="1.4"/>'
out['Rakaat'] = svg(defs, body)

# Qada: a bowl of dates under a crescent, with a badge ticking off a fast
sd, se = shadow(58, 110, 38, 5)
defs = sd + lg('moon', '#FFF0B0', '#F2B437', 0, 0, 1, 1) + lg('bowl', '#3FC283', '#13623F') + lg('rim', '#F6D77A', '#C08A1E') + lg('date', '#B5652E', '#5E2A10', 0, 0, 1, 1) + lg('ok', '#5ADB98', '#139454')
body = se
# crescent from two circles
c1, r1, c2, r2 = (40, 34), 20, (50, 28), 17
d = math.dist(c1, c2); a = (r1*r1 - r2*r2 + d*d) / (2*d); h = math.sqrt(r1*r1 - a*a)
mx, my = c1[0] + a*(c2[0]-c1[0])/d, c1[1] + a*(c2[1]-c1[1])/d
p1 = (mx + h*(c2[1]-c1[1])/d, my - h*(c2[0]-c1[0])/d); p2 = (mx - h*(c2[1]-c1[1])/d, my + h*(c2[0]-c1[0])/d)
body += f'<path d="M{p1[0]:.2f} {p1[1]:.2f} A{r1} {r1} 0 1 0 {p2[0]:.2f} {p2[1]:.2f} A{r2} {r2} 0 0 1 {p1[0]:.2f} {p1[1]:.2f} Z" fill="url(#moon)"/>'
body += sparkle(74, 20, 5, '#FFE48A') + sparkle(86, 38, 3.5, '#FFF3C4') + sparkle(16, 58, 3.5, '#FFF3C4')
# dates heaped in the bowl
for x, y, rot in [(38, 66, -25), (52, 62, 10), (66, 64, 30), (78, 69, -10), (45, 72, 20), (60, 71, -15), (72, 74, 5)]:
    body += f'<ellipse cx="{x}" cy="{y}" rx="8" ry="5" fill="url(#date)" transform="rotate({rot} {x} {y})"/>'
    body += f'<ellipse cx="{x-2}" cy="{y-1.5}" rx="3" ry="1.2" fill="#fff" fill-opacity="0.3" transform="rotate({rot} {x} {y})"/>'
# bowl
body += '<path d="M24 74 L96 74 Q94 104 60 104 Q26 104 24 74 Z" fill="url(#bowl)"/>'
body += '<rect x="20" y="71" width="80" height="7" rx="3.5" fill="url(#rim)"/>'
body += '<path d="M32 84 Q36 96 50 99" stroke="#fff" stroke-opacity="0.3" stroke-width="2.5" fill="none" stroke-linecap="round"/>'
# tick badge
body += '<circle cx="92" cy="92" r="15" fill="#fff"/><circle cx="92" cy="92" r="12" fill="url(#ok)"/>'
body += '<path d="M86 92 l4 4 l8 -8" stroke="#fff" stroke-width="3" fill="none" stroke-linecap="round" stroke-linejoin="round"/>'
out['Qada'] = svg(defs, body)

# Qada year cards: a crescent for a Ramadan still being made up, and a full
# moon with a tick once it's complete. Bold shapes so they read at 44pt.
def crescent_path(c1, r1, c2, r2):
    d = math.dist(c1, c2); a = (r1*r1 - r2*r2 + d*d) / (2*d); h = math.sqrt(r1*r1 - a*a)
    mx, my = c1[0] + a*(c2[0]-c1[0])/d, c1[1] + a*(c2[1]-c1[1])/d
    p1 = (mx + h*(c2[1]-c1[1])/d, my - h*(c2[0]-c1[0])/d); p2 = (mx - h*(c2[1]-c1[1])/d, my + h*(c2[0]-c1[0])/d)
    return f'M{p1[0]:.2f} {p1[1]:.2f} A{r1} {r1} 0 1 0 {p2[0]:.2f} {p2[1]:.2f} A{r2} {r2} 0 0 1 {p1[0]:.2f} {p1[1]:.2f} Z'

sd, se = shadow(56, 108, 30, 5)
defs = sd + lg('moon', '#FFF0B0', '#F2B437', 0, 0, 1, 1) + lg('moond', '#E0A12C', '#B87414', 0, 0, 1, 1)
body = se
body += f'<path d="{crescent_path((54, 62), 40, (74, 48), 33)}" fill="url(#moond)" transform="translate(3 4)"/>'
body += f'<path d="{crescent_path((54, 62), 40, (74, 48), 33)}" fill="url(#moon)"/>'
body += '<path d="M24 52 Q26 34 42 26" stroke="#fff" stroke-opacity="0.55" stroke-width="4" fill="none" stroke-linecap="round"/>'
body += sparkle(92, 30, 9, '#F6C94C') + sparkle(100, 58, 5, '#FFE48A') + sparkle(80, 88, 4, '#FFE48A')
out['QadaMoon'] = svg(defs, body)

sd, se = shadow(58, 110, 34, 5)
defs = sd + '<radialGradient id="fm" cx="38%" cy="32%" r="75%"><stop offset="0" stop-color="#FFF6CC"/><stop offset="0.55" stop-color="#FFD25C"/><stop offset="1" stop-color="#E39A1E"/></radialGradient>' + lg('ok', '#5ADB98', '#139454')
body = se
body += '<circle cx="58" cy="58" r="42" fill="#C98312"/><circle cx="56" cy="55" r="42" fill="url(#fm)"/>'
for cx, cy, r in [(42, 46, 7), (66, 70, 9), (70, 40, 4.5), (44, 74, 4)]:
    body += f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="#E7A93A" fill-opacity="0.28"/>'
body += '<path d="M28 44 Q34 26 52 20" stroke="#fff" stroke-opacity="0.6" stroke-width="4" fill="none" stroke-linecap="round"/>'
body += '<circle cx="90" cy="88" r="18" fill="#fff"/><circle cx="90" cy="88" r="14.5" fill="url(#ok)"/>'
body += '<path d="M83 88 l5 5 l9.5 -9.5" stroke="#fff" stroke-width="3.4" fill="none" stroke-linecap="round" stroke-linejoin="round"/>'
out['QadaMoonFull'] = svg(defs, body)

# Rakaat setup rows: a phone lying face up on a prayer mat ("How to place
# your phone"), and a phone gone dark with only a faint count (focus mode).
sd, se = shadow(60, 110, 40, 5)
defs = sd + lg('mat', '#3FC283', '#13623F', 0, 0, 1, 1) + lg('gold', '#F6D77A', '#C08A1E') + lg('rim', '#5B6660', '#1A201D', 0, 0, 1, 1) + lg('scr', '#FFFFFF', '#E6F2EB') + lg('ring', '#5ADB98', '#139454', 0, 0, 1, 1)
body = se
# mat in slight perspective
body += '<path d="M30 30 L90 30 L104 104 L16 104 Z" fill="#0F4E33" transform="translate(0 4)"/>'
body += '<path d="M30 30 L90 30 L104 104 L16 104 Z" fill="url(#mat)"/>'
body += '<path d="M36 36 L84 36 L95 98 L25 98 Z" fill="none" stroke="url(#gold)" stroke-width="2.2"/>'
# mihrab arch at the head of the mat, peeking out around the phone
body += '<path d="M38 70 L38 48 Q38 36 60 28 Q82 36 82 48 L82 70" fill="#1D7A50" fill-opacity="0.55" stroke="url(#gold)" stroke-width="2"/>'
body += '<path d="M26 84 L94 84 M24 90 L96 90" stroke="#fff" stroke-opacity="0.18" stroke-width="1.6"/>'
# phone lying on the mat near the top, where the forehead goes
body += '<g transform="rotate(-6 60 52)">'
body += '<rect x="44" y="20" width="32" height="58" rx="7" fill="#000" fill-opacity="0.25" transform="translate(2 4)"/>'
body += '<rect x="44" y="20" width="32" height="58" rx="7" fill="url(#rim)"/>'
body += '<rect x="47" y="23" width="26" height="52" rx="5" fill="url(#scr)"/>'
body += '<rect x="55" y="25" width="10" height="3" rx="1.5" fill="#1A201D"/>'
body += '<circle cx="60" cy="47" r="8" fill="none" stroke="#5ADB98" stroke-opacity="0.25" stroke-width="3"/>'
body += '<path d="M60 39 A8 8 0 0 1 66.9 51" fill="none" stroke="url(#ring)" stroke-width="3" stroke-linecap="round"/>'
body += '<rect x="52" y="62" width="16" height="2.5" rx="1.25" fill="#D5E2DA"/><rect x="54" y="67" width="12" height="2.5" rx="1.25" fill="#E4EDE7"/>'
body += '<path d="M47 30 Q47 25 52 24" stroke="#fff" stroke-opacity="0.5" stroke-width="1.5" fill="none" stroke-linecap="round"/>'
body += '</g>'
out['RakaatPhone'] = svg(defs, body)

sd, se = shadow(60, 110, 30, 5)
defs = sd + lg('rim', '#5B6660', '#1A201D', 0, 0, 1, 1) + lg('moon', '#FFF0B0', '#F2B437', 0, 0, 1, 1) + '<radialGradient id="glow" cx="50%" cy="50%" r="50%"><stop offset="0" stop-color="#5ADB98" stop-opacity="0.55"/><stop offset="1" stop-color="#5ADB98" stop-opacity="0"/></radialGradient>'
body = se
body += '<rect x="34" y="18" width="52" height="88" rx="11" fill="#000" fill-opacity="0.25" transform="translate(3 4)"/>'
body += '<rect x="34" y="18" width="52" height="88" rx="11" fill="url(#rim)"/>'
body += '<rect x="38" y="22" width="44" height="80" rx="8" fill="#050807"/>'
body += '<rect x="53" y="25" width="14" height="4" rx="2" fill="#1A201D"/>'
body += '<circle cx="60" cy="64" r="20" fill="url(#glow)"/>'
# a soft "2" drawn as a stroke, like the dimmed count
body += '<path d="M53 56 Q53 49 60 49 Q67 49 67 56 Q67 61 53 72 L68 72" stroke="#7FE6B0" stroke-opacity="0.9" stroke-width="4" fill="none" stroke-linecap="round" stroke-linejoin="round"/>'
body += '<path d="M38 34 Q38 25 46 24" stroke="#fff" stroke-opacity="0.25" stroke-width="2" fill="none" stroke-linecap="round"/>'
body += f'<path d="{crescent_path((88, 26), 15, (95, 21), 12.5)}" fill="url(#moon)"/>'
body += sparkle(104, 46, 4.5, '#FFE48A') + sparkle(24, 40, 4, '#FFF3C4')
out['RakaatFocus'] = svg(defs, body)

# How-it-works pictures for the rakaat counter. They are wider than the
# feature illustrations (200x140) and stay SVG in the catalogue.
def svg_wide(defs, body, w=200, h=140):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}"><defs>{defs}</defs>{body}</svg>'
GLOW = '<radialGradient id="glow" cx="50%" cy="50%" r="50%"><stop offset="0" stop-color="#FFFFFF" stop-opacity="0.9"/><stop offset="1" stop-color="#FFFFFF" stop-opacity="0"/></radialGradient>'
def hand(cx, cy, flip):
    # a simple palm print: palm plus four fingers and a thumb
    # thumbs point in, toward the head
    s = 1 if flip else -1
    out = f'<ellipse cx="{cx}" cy="{cy}" rx="6.5" ry="8" fill="#fff" fill-opacity="0.28"/>'
    for i, dx in enumerate((-4.5, -1.5, 1.5, 4.5)):
        out += f'<rect x="{cx+dx-1.3:.1f}" y="{cy-16+abs(i-1.5)*1.2:.1f}" width="2.6" height="9" rx="1.3" fill="#fff" fill-opacity="0.28"/>'
    out += f'<rect x="{cx-s*9-1.3:.1f}" y="{cy-4}" width="2.6" height="7.5" rx="1.3" fill="#fff" fill-opacity="0.28" transform="rotate({s*-35} {cx-s*9} {cy})"/>'
    return out

# Rakaat placement: the mat from above. Phone between the hands, top edge at the forehead spot.
defs = lg('mat', '#3FC283', '#13623F', 0, 0, 1, 1) + lg('gold', '#F6D77A', '#C08A1E') + lg('arch', '#1D7A50', '#0F5537') + lg('ph', '#3A3F45', '#15181B', 0, 0, 1, 1) + GLOW
b = ''
b += '<rect x="62" y="12" width="76" height="124" rx="7" fill="#0F4E33"/><rect x="62" y="8" width="76" height="124" rx="7" fill="url(#mat)"/>'
b += '<rect x="68" y="14" width="64" height="112" rx="4" fill="none" stroke="url(#gold)" stroke-width="2"/>'
b += '<path d="M80 40 L80 28 Q80 21 100 16 Q120 21 120 28 L120 40 Z" fill="url(#arch)" stroke="url(#gold)" stroke-width="1.5"/>'
b += star8(100, 29, 4.5, '#E9BF4C')
# forehead spot, just above the phone's top edge
b += '<ellipse cx="100" cy="52" rx="10" ry="6" fill="#fff" fill-opacity="0.22" stroke="#fff" stroke-width="1.4" stroke-dasharray="3 2.5"/>'
# hands either side
b += hand(80, 70, False) + hand(120, 70, True)
# phone, face up, top edge (sensor) toward the forehead spot
b += '<ellipse cx="100" cy="61" rx="9" ry="4.5" fill="url(#glow)"/>'
b += '<g transform="translate(100 78)"><rect x="-9" y="-17" width="18" height="34" rx="4" fill="url(#ph)"/><rect x="-7.5" y="-15.5" width="15" height="31" rx="3" fill="#2B5D49"/><rect x="-3.5" y="-13.9" width="7" height="2.4" rx="1.2" fill="#0B0D0F"/></g>'
for x in range(66, 136, 6):
    b += f'<path d="M{x} 132 L{x} 138" stroke="#C08A1E" stroke-width="1.6" stroke-linecap="round"/>'
out['RakaatPlacement'] = svg_wide(defs, b)

# Rakaat sujood: side view. The phone lies between the hands under the face;
# the forehead and nose come down over its top edge, where the sensor is.
defs = (lg('robe', '#F4F8F6', '#C9D9D1', 0, 0, 0.4, 1) + lg('robeShade', '#DDE8E3', '#AFC4BA', 0, 0, 0, 1)
        + lg('skin', '#EDC29B', '#C98F62', 0, 0, 1, 1) + lg('cap', '#2E3B36', '#141B18')
        + lg('ph', '#3A3F45', '#15181B', 0, 0, 1, 1) + lg('matside', '#3FC283', '#13623F', 0, 0, 1, 0))
b = ''
# mat and soft floor shadow
b += '<ellipse cx="96" cy="121" rx="78" ry="3.4" fill="#000" fill-opacity="0.09"/>'
b += '<rect x="12" y="115" width="176" height="5" rx="2.5" fill="url(#matside)"/>'
# far arm (behind): sleeve and hand on the far side of the head
b += '<path d="M116 86 C121 92 124 100 125 107 L131 107 C130 99 127 90 122 84 Z" fill="url(#robeShade)"/>'
b += '<path d="M124 106 C128 109 134 112 141 113.5 C142 114.6 141 115.4 139 115.4 L127 115.4 C124 114.5 123 110 124 106 Z" fill="#C08A63"/>'
# feet: toes tucked under, heels up
b += '<path d="M24 115.4 C23 111 24 106 28 104 C31 103 34 104 35 107 L36 115.4 Z" fill="url(#skin)"/>'
b += '<path d="M24 115 L36 115" stroke="#B57E55" stroke-width="0.8"/>'
# robe: shins on the mat, thighs up to the raised hips, back sloping to the shoulders
b += ('<path d="M33 115.4 C32 109 33 104 38 102 L70 101 '
      'C68 90 68 78 72 68 C76 60 84 56 92 58 '
      'C104 62 116 72 126 82 C130 86 132 90 132 95 '
      'C128 98 121 99 114 98 C104 97 96 99 90 103 '
      'C86 106 84 111 84 115.4 Z" fill="url(#robe)"/>')
# robe folds and the line between thigh and torso
b += '<path d="M72 70 C76 82 80 94 84 104" fill="none" stroke="#AFC4BA" stroke-width="1.1" stroke-linecap="round"/>'
b += '<path d="M40 108 C52 106 62 106 74 108" fill="none" stroke="#C3D4CC" stroke-width="1" stroke-linecap="round"/>'
b += '<path d="M96 64 C106 70 114 77 121 85" fill="none" stroke="#FFFFFF" stroke-opacity="0.8" stroke-width="1.4" stroke-linecap="round"/>'
# phone between the hands, under the face; sensor at its top edge (right)
b += '<rect x="108" y="111" width="31" height="4.4" rx="1.6" fill="url(#ph)"/><rect x="109.5" y="110.6" width="28" height="1.2" rx="0.6" fill="#2B5D49"/><circle cx="136.5" cy="111.2" r="0.9" fill="#0B0D0F"/>'
# neck between the collar and the head
b += '<path d="M129 92 C132 94 135 98 137 103 L134 106 C132 102 130 98 127 95 Z" fill="#D9A47A"/>'
# the sensor noticing the face: rings from the phone's top edge, drawn
# behind the head so they show in the gap between arm and face
for r, o in ((7, 0.9), (11.5, 0.55), (16, 0.3)):
    b += f'<path d="M{134-r*0.9:.1f} {111-r*0.45:.1f} A{r} {r} 0 0 1 {134+r*0.15:.1f} {111-r:.1f}" fill="none" stroke="#2FA36C" stroke-opacity="{o}" stroke-width="1.6" stroke-linecap="round"/>'
# head: a little smaller, tilted forward, forehead and nose on the mat
b += '<g transform="translate(-2.5 2.6) rotate(24 145 104)">'
b += '<ellipse cx="145" cy="104" rx="9.6" ry="8.6" fill="url(#skin)"/>'
b += '<path d="M135.6 101.5 C136 95.6 140.6 95 145.4 95.4 C150 95.8 153.6 97.4 154.4 100 C148 99 141 99.6 135.6 101.5 Z" fill="url(#cap)"/>'
b += '<path d="M141.2 103 C140 103 139.8 105.2 141 106" fill="none" stroke="#B57E55" stroke-width="0.9" stroke-linecap="round"/>'
b += '</g>'
# nose touching the mat in front of the forehead
b += '<path d="M150.4 114.2 C151.8 114 152.8 114.6 153 115.4 L150 115.4 Z" fill="#D9A47A"/>'
# near arm: sleeve from the shoulder to the raised elbow, forearm down to the hand flat beside the head
b += '<path d="M118 82 C124 86 129 92 131 99 C132 103 132 106 131 108 L125 108 C125 102 122 95 116 89 Z" fill="url(#robe)"/>'
b += '<path d="M118 84 C123 88 127 94 129 100" fill="none" stroke="#AFC4BA" stroke-width="0.9" stroke-linecap="round"/>'
b += '<path d="M125 107 C129 110 135 112.5 143 113.6 C145 114.2 145 115.4 142.5 115.6 L128 115.6 C124.5 114.8 123.5 110.5 125 107 Z" fill="url(#skin)"/>'
for x in (134, 137.5, 141):
    b += f'<path d="M{x} 113.2 L{x+2.5} 115.4" stroke="#B57E55" stroke-width="0.6" stroke-linecap="round"/>'
out['RakaatSujood'] = svg_wide(defs, b)

# Rakaat on the wrist: an Apple Watch showing the count and tapping
defs = (lg('arm', '#EDC29B', '#C98F62', 0, 0, 0, 1) + lg('sleeve', '#F4F8F6', '#C9D9D1', 0, 0, 0, 1)
        + lg('band', '#2E3B36', '#141B18', 0, 0, 1, 0) + lg('case', '#5B636B', '#22272C', 0, 0, 1, 1)
        + lg('gold', '#F6D77A', '#C08A1E'))
b = '<ellipse cx="100" cy="122" rx="78" ry="3.5" fill="#000" fill-opacity="0.08"/>'
# forearm across the picture, from the sleeve on the left to the hand on the right
b += '<path d="M14 72 C40 70 120 70 168 74 C180 75 188 80 188 88 C188 96 180 100 168 101 C120 104 40 104 14 102 Z" fill="url(#arm)"/>'
b += '<path d="M10 66 C24 64 36 65 44 67 L44 108 C36 110 24 110 10 108 Z" fill="url(#sleeve)"/>'
b += '<path d="M44 67 L44 108" stroke="#AFC4BA" stroke-width="1.2"/>'
# strap over the wrist
b += '<rect x="88" y="54" width="26" height="62" rx="5" fill="url(#band)"/>'
for y in (60, 66, 104, 110):
    b += f'<rect x="91" y="{y}" width="20" height="1.4" rx="0.7" fill="#fff" fill-opacity="0.08"/>'
# watch case, crown and screen
b += '<rect x="80" y="62" width="42" height="46" rx="12" fill="url(#case)"/>'
b += '<rect x="122" y="76" width="4" height="9" rx="2" fill="#7A838C"/>'
b += '<rect x="84" y="66" width="34" height="38" rx="9" fill="#050607"/>'
# on the screen: a progress ring two rakaat round, and the rakaat dots
cx, cy, r = 101, 82, 11
b += f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="#47B881" stroke-opacity="0.25" stroke-width="3"/>'
b += f'<path d="M{cx} {cy-r} A{r} {r} 0 0 1 {cx} {cy+r}" fill="none" stroke="#47B881" stroke-width="3" stroke-linecap="round"/>'
for i, x in enumerate((92, 98, 104, 110)):
    if i % 2 == 1:
        b += f'<circle cx="{x}" cy="98" r="2" fill="#47B881"/>'
    else:
        b += f'<circle cx="{x}" cy="98" r="1.7" fill="none" stroke="#47B881" stroke-opacity="0.6" stroke-width="0.9"/>'
# the taps: ripples either side of the watch
for d, o in ((8, 0.9), (15, 0.55), (22, 0.3)):
    b += f'<path d="M{78-d} {72} Q{72-d} {85} {78-d} {98}" fill="none" stroke="#47B881" stroke-opacity="{o}" stroke-width="2" stroke-linecap="round"/>'
    b += f'<path d="M{128+d} {72} Q{134+d} {85} {128+d} {98}" fill="none" stroke="#47B881" stroke-opacity="{o}" stroke-width="2" stroke-linecap="round"/>'
# highlight on the case
b += '<path d="M85 66 Q86 63 90 63 L110 63" stroke="#fff" stroke-opacity="0.3" stroke-width="1.2" fill="none" stroke-linecap="round"/>'
out['RakaatWatch'] = svg_wide(defs, b)

for k, v in out.items():
    open(f'{k}.svg', 'w').write(v)
