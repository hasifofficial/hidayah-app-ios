# Draws the What's New illustrations (320x220, light and dark) from the
# 3D-style feature illustrations that gen.py writes, so both sets match.
# Run from this folder after gen.py:  python3 gen.py && python3 gen_whatsnew.py
import math, os, re

W, H = 320, 220
OUT = 'whatsnew'

THEMES = {
    'light': dict(blob='#E6F4EC', blob2='#D3ECDF', phone='#1C2420', screen=('#FFFFFF', '#EEF5F0'),
                  card=('#FFFFFF', '#F1F6F3'), line='#D5E2DA', line2='#E4EDE7', ground='#0F2A1C', ground_op=0.10),
    'dark': dict(blob='#16291F', blob2='#1C3528', phone='#0B0F0D', screen=('#24302A', '#18211C'),
                 card=('#2C3832', '#202A25'), line='#3E4C45', line2='#34413A', ground='#000000', ground_op=0.35),
}

def read_art(name):
    """The inner defs and body of a gen.py illustration, with its ids prefixed."""
    s = open(f'{name}.svg').read()
    inner = re.sub(r'^<svg[^>]*>|</svg>$', '', s)
    p = name.lower() + '_'
    inner = re.sub(r'id="([^"]+)"', lambda m: f'id="{p}{m.group(1)}"', inner)
    inner = re.sub(r'url\(#([^)]+)\)', lambda m: f'url(#{p}{m.group(1)})', inner)
    return inner

def art(name, x, y, size):
    """Places a 120x120 illustration with its top-left at (x, y), `size` points wide."""
    return f'<g transform="translate({x:.1f} {y:.1f}) scale({size / 120:.4f})">{read_art(name)}</g>'

def lg(id, c1, c2, x1=0, y1=0, x2=0, y2=1):
    return f'<linearGradient id="{id}" x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}"><stop offset="0" stop-color="{c1}"/><stop offset="1" stop-color="{c2}"/></linearGradient>'

def sparkle(x, y, r, c='#E6B54A', op=1):
    return f'<path d="M{x} {y-r} Q{x} {y} {x+r} {y} Q{x} {y} {x} {y+r} Q{x} {y} {x-r} {y} Q{x} {y} {x} {y-r} Z" fill="{c}" fill-opacity="{op}"/>'

def backdrop(t):
    return (f'<ellipse cx="160" cy="118" rx="138" ry="92" fill="{t["blob"]}"/>'
            f'<ellipse cx="206" cy="78" rx="62" ry="44" fill="{t["blob2"]}" opacity="0.8"/>'
            f'<ellipse cx="160" cy="200" rx="104" ry="8" fill="{t["ground"]}" opacity="{t["ground_op"]}"/>')

def sparkles(points):
    return ''.join(sparkle(*p) for p in points)

def doc(t, defs, body):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">'
            f'<defs>{defs}</defs>{backdrop(t)}{body}</svg>')

def phone(t, x, y, w, h, uid):
    """A phone with a soft bezel and an empty screen; returns (defs, body, screen rect)."""
    defs = lg(f'{uid}scr', *t['screen']) + lg(f'{uid}rim', '#5B6660', '#1A201D', 0, 0, 1, 1)
    r = w * 0.2
    body = (f'<rect x="{x+3}" y="{y+6}" width="{w}" height="{h}" rx="{r}" fill="#000" fill-opacity="0.18"/>'
            f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="url(#{uid}rim)"/>'
            f'<rect x="{x+2}" y="{y+2}" width="{w-4}" height="{h-4}" rx="{r-2}" fill="{t["phone"]}"/>')
    sx, sy, sw, sh = x + 6, y + 6, w - 12, h - 12
    body += f'<rect x="{sx}" y="{sy}" width="{sw}" height="{sh}" rx="{r-6}" fill="url(#{uid}scr)"/>'
    body += f'<rect x="{x + w/2 - w*0.16}" y="{y + 10}" width="{w*0.32}" height="{h*0.045}" rx="{h*0.0225}" fill="#000"/>'
    return defs, body, (sx, sy, sw, sh)

def card(t, x, y, w, h, uid, r=12):
    defs = lg(f'{uid}c', *t['card'])
    body = (f'<rect x="{x+2}" y="{y+5}" width="{w}" height="{h}" rx="{r}" fill="#000" fill-opacity="0.14"/>'
            f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="url(#{uid}c)"/>')
    return defs, body

def ring(cx, cy, r, frac, uid, width=6):
    defs = lg(f'{uid}ring', '#5ADB98', '#139454', 0, 0, 1, 1)
    a = math.radians(-90 + 360 * frac)
    x, y = cx + math.cos(a) * r, cy + math.sin(a) * r
    large = 1 if frac > 0.5 else 0
    body = (f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="#5ADB98" stroke-opacity="0.22" stroke-width="{width}"/>'
            f'<path d="M{cx} {cy - r} A{r} {r} 0 {large} 1 {x:.2f} {y:.2f}" fill="none" stroke="url(#{uid}ring)" stroke-width="{width}" stroke-linecap="round"/>')
    return defs, body

def lines(t, x, y, widths, gap=8, h=4.5):
    return ''.join(f'<rect x="{x}" y="{y + i*gap}" width="{w}" height="{h}" rx="{h/2}" fill="{t["line"] if i == 0 else t["line2"]}"/>'
                   for i, w in enumerate(widths))

def flame(x, y, s):
    defs = lg('flo', '#FFB347', '#F2541B') + lg('fli', '#FFF3B0', '#FFC23A')
    body = (f'<g transform="translate({x} {y}) scale({s})">'
            '<path d="M0 -26 C10 -14 18 -6 18 6 C18 17 10 24 0 24 C-10 24 -18 17 -18 6 C-18 -3 -12 -9 -8 -14 C-7 -6 -4 -3 -1 -3 C-2 -11 -2 -19 0 -26 Z" fill="url(#flo)"/>'
            '<path d="M0 -2 C6 4 9 8 9 13 C9 19 5 22 0 22 C-5 22 -9 19 -9 13 C-9 8 -4 5 0 -2 Z" fill="url(#fli)"/>'
            '<path d="M-12 2 C-12 -4 -8 -9 -5 -12" stroke="#fff" stroke-opacity="0.45" stroke-width="2.5" fill="none" stroke-linecap="round"/></g>')
    return defs, body

def check_badge(cx, cy, r, uid):
    defs = lg(f'{uid}ok', '#5ADB98', '#139454', 0, 0, 1, 1)
    body = (f'<circle cx="{cx}" cy="{cy}" r="{r + 3}" fill="#fff"/><circle cx="{cx}" cy="{cy}" r="{r}" fill="url(#{uid}ok)"/>'
            f'<path d="M{cx - r*0.45} {cy} l{r*0.32} {r*0.34} l{r*0.58} {-r*0.64}" stroke="#fff" stroke-width="{r*0.24:.1f}" fill="none" stroke-linecap="round" stroke-linejoin="round"/>')
    return defs, body

scenes = {}

# Mathurat: the morning and evening scenes side by side, with a ticked dhikr card.
def mathurat(t):
    cd, cb = card(t, 112, 146, 96, 40, 'm', 12)
    kd, kb = check_badge(190, 166, 9, 'm')
    body = art('Mathurat', 34, 26, 140) + art('MathuratEvening', 146, 26, 140)
    body += cb + lines(t, 124, 156, (46, 34), 9) + kb
    body += sparkles([(36, 56, 6), (290, 148, 5), (162, 30, 4, '#E6B54A', 0.8)])
    return doc(t, cd + kd, body)
scenes['mathurat'] = mathurat

# Mushaf: the open Quran on its stand, large, with a red bookmark ribbon.
def mushaf(t):
    # The ribbon is drawn last so it hangs in front, over the top of the
    # right page.
    body = art('Quran', 70, 4, 180) + art('Bookmark', 192, 40, 42)
    body += sparkles([(58, 60, 7), (272, 140, 5), (92, 160, 4, '#E6B54A', 0.8)])
    return doc(t, '', body)
scenes['mushaf'] = mushaf

# A fresh new look: a phone showing the new feature tiles.
def refresh(t):
    pd, pb, (sx, sy, sw, sh) = phone(t, 112, 14, 96, 186, 'r')
    defs = pd + lg('rhead', '#45C98A', '#167049', 0, 0, 1, 1)
    body = pb
    body += f'<rect x="{sx+8}" y="{sy+22}" width="{sw-16}" height="26" rx="8" fill="url(#rhead)"/>'
    body += f'<rect x="{sx+15}" y="{sy+30}" width="34" height="4" rx="2" fill="#fff" fill-opacity="0.9"/><rect x="{sx+15}" y="{sy+38}" width="22" height="3.5" rx="1.75" fill="#fff" fill-opacity="0.6"/>'
    tiles = ['Quran', 'Mathurat', 'Tasbih', 'Tracker']
    tw = (sw - 16 - 6) / 2
    for i, name in enumerate(tiles):
        tx, ty = sx + 8 + (i % 2) * (tw + 6), sy + 56 + (i // 2) * (tw + 6)
        d, b = card(t, tx, ty, tw, tw, f'r{i}', 8)
        defs += d
        body += b + art(name, tx + 3, ty + 3, tw - 6)
    body += lines(t, sx + 8, sy + 56 + 2 * (tw + 6) + 2, (sw - 16, sw - 30), 9)
    body += art('All', 44, 64, 70) + art('Search', 216, 92, 62)
    body += sparkles([(60, 46, 7), (262, 56, 5), (240, 176, 4, '#E6B54A', 0.8)])
    return doc(t, defs, body)
scenes['refresh'] = refresh

# Tasbih: the bead loop with its tassel, and a counter card filling up.
def tasbih(t):
    cd, cb = card(t, 210, 116, 62, 62, 't', 16)
    rd, rb = ring(241, 147, 18, 0.36, 't', 7)
    body = art('Tasbih', 70, 6, 180) + cb + rb + f'<circle cx="241" cy="147" r="5" fill="#E6B54A"/>'
    body += sparkles([(64, 54, 7), (268, 66, 5), (96, 170, 4, '#E6B54A', 0.8)])
    return doc(t, cd + rd, body)
scenes['tasbih'] = tasbih

# Istiqamah tracker: the clipboard, a calendar behind it and a streak flame.
def tracker(t):
    fd, fb = flame(92, 132, 1.25)
    body = art('Calendar', 176, 46, 108) + art('Tracker', 92, 22, 160) + fb
    body += sparkles([(56, 58, 7), (282, 152, 5), (170, 28, 4, '#E6B54A', 0.8)])
    return doc(t, fd, body)
scenes['tracker'] = tracker

# Widgets: a phone with the tracker and Quick Surahs widgets lifting off it.
def widgets(t):
    pd, pb, (sx, sy, sw, sh) = phone(t, 124, 14, 96, 186, 'w')
    defs = pd
    body = pb
    # Home Screen app icons, faint.
    for r in range(3):
        for c in range(4):
            ix, iy = sx + 9 + c * 19, sy + 104 + r * 21
            body += f'<rect x="{ix}" y="{iy}" width="13" height="13" rx="4" fill="{t["line2"]}"/>'
    # Tracker widget, front left.
    d, b = card(t, 48, 50, 118, 58, 'wt', 14); defs += d; body += b
    d, b = ring(76, 79, 15, 0.72, 'wt', 6); defs += d; body += b
    d, b = check_badge(76, 79, 6.5, 'wt2'); defs += d
    body += b + lines(t, 102, 66, (50, 40, 46), 9)
    # Quick Surahs widget, front right.
    d, b = card(t, 172, 112, 118, 58, 'wq', 14); defs += d; body += b
    body += art('QuranClosed', 178, 116, 50) + lines(t, 228, 126, (48, 36, 42), 9)
    body += sparkles([(40, 140, 7), (290, 58, 5), (110, 186, 4, '#E6B54A', 0.8)])
    return doc(t, defs, body)
scenes['widgets'] = widgets

# Qibla: the gold compass pointing to the Kaaba, with a map pin and Makkah's distance arc.
def qibla(t):
    defs = lg('qpin', '#FF6B63', '#B8232B', 0, 0, 1, 1)
    body = art('Qibla', 84, 14, 156)
    # A dashed route from a pin to the compass.
    body += '<path d="M64 158 Q70 112 104 96" stroke="#E6B54A" stroke-width="3" stroke-dasharray="2 7" stroke-linecap="round" fill="none"/>'
    body += ('<g transform="translate(60 162)"><ellipse cx="0" cy="12" rx="10" ry="3" fill="#000" fill-opacity="0.18"/>'
             '<path d="M0 10 C-4 4 -12 -2 -12 -10 A12 12 0 0 1 12 -10 C12 -2 4 4 0 10 Z" fill="url(#qpin)"/>'
             '<circle cx="0" cy="-10" r="4.5" fill="#fff"/></g>')
    body += sparkles([(270, 56, 7), (262, 160, 5), (100, 40, 4, '#E6B54A', 0.8)])
    return doc(t, defs, body)
scenes['qibla'] = qibla

# Apple Watch: a watch showing the tracker ring, with Tasbih and Qibla beside it.
def watch(t):
    defs = lg('wstrap', '#3B4541', '#1C2220') + lg('wcase', '#6A7470', '#232A27', 0, 0, 1, 1)
    cx, cy, w, h = 160, 108, 92, 108
    x, y = cx - w / 2, cy - h / 2
    # Straps, case, crown and glass.
    body = (f'<rect x="{cx-34}" y="{y-44}" width="68" height="{h+88}" rx="18" fill="url(#wstrap)"/>'
            f'<rect x="{x+w-2}" y="{cy-22}" width="9" height="22" rx="4" fill="#A4ACA8"/>'
            f'<rect x="{x+w-2}" y="{cy+8}" width="6" height="18" rx="3" fill="#7E8682"/>'
            f'<rect x="{x+3}" y="{y+7}" width="{w}" height="{h}" rx="30" fill="#000" fill-opacity="0.22"/>'
            f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="30" fill="url(#wcase)"/>'
            f'<rect x="{x+7}" y="{y+7}" width="{w-14}" height="{h-14}" rx="24" fill="#05080A"/>')
    rd, rb = ring(cx, cy - 4, 25, 0.27, 'w', 8)
    defs += rd
    body += rb
    body += f'<rect x="{cx-12}" y="{cy-7}" width="24" height="5" rx="2.5" fill="#fff" fill-opacity="0.85"/>'
    body += f'<rect x="{cx-8}" y="{cy+1}" width="16" height="4" rx="2" fill="#fff" fill-opacity="0.45"/>'
    body += f'<rect x="{cx-20}" y="{cy+32}" width="40" height="5" rx="2.5" fill="#5ADB98" fill-opacity="0.8"/>'
    body += art('Tasbih', 34, 70, 84) + art('Qibla', 216, 66, 76)
    body += sparkles([(64, 52, 7), (274, 160, 5), (230, 40, 4, '#E6B54A', 0.8)])
    return doc(t, defs, body)
scenes['watch'] = watch

os.makedirs(OUT, exist_ok=True)
for name, make in scenes.items():
    for theme, t in THEMES.items():
        with open(f'{OUT}/whatsnew_{name}_{theme}.svg', 'w') as f:
            f.write(make(t))
print('wrote', len(scenes) * len(THEMES), 'files to', OUT)
