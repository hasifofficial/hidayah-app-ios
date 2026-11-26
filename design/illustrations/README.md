# Feature illustrations

Sources for the 3D-style illustrations on Home, Explore and Reading
(`hidayah-app/Resources/Assets.xcassets/Illustrations`).

`gen.py` draws each illustration as a 120×120 SVG, and `render.swift`
renders each SVG to a 360×360 PNG beside it. Each image set holds that one PNG for every scale (no `scale` key), so 2x devices such as the Watch and iPads get it too; an image marked `3x` only is left out of their builds.

To change one, edit `gen.py`, then from this folder run:

```bash
python3 gen.py && swift render.swift *.svg
```

Copy each `<Name>.png` over
`Illustrations/Illustration<Name>.imageset/Illustration<Name>.png`.

The rakaat counter's how-it-works pictures (`RakaatPlacement`,
`RakaatSujood`) are 200×140 and stay SVG in the catalogue, which keeps
them sharp: copy each `<Name>.svg` over
`Illustrations/Illustration<Name>.imageset/Illustration<Name>.svg`.

## What's New

`gen_whatsnew.py` builds the What's New pages' 320×220 illustrations
from the SVGs `gen.py` writes, in a light and a dark version, into
`whatsnew/`. They stay SVG in the catalogue (`Assets.xcassets/WhatsNew`),
which keeps them as vectors. From this folder run:

```bash
python3 gen.py && python3 gen_whatsnew.py
```

Copy each `whatsnew/whatsnew_<name>_<light|dark>.svg` over the file of
the same name in `WhatsNew/WhatsNew<Name>.imageset/`. Keep them free of
`<text>`, since SVG text isn't reliable once Xcode compiles the catalogue.
