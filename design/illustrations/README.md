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
