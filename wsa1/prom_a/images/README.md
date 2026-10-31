# prom_a bitmaps as PNG

Every file here is a **lossless, exact** rendering of a range of
`original_ROMs/wsa1_prom_a.ic12`, and it is the build's input for that range:
`scripts/build/wsa1_bitmaps.py build` writes `<name>.bin` (git-ignored) beside it and the
assembly `.incbin`s that (lane media-build, 2026-10-31; until then the assembly held `.byte`
rows rewritten from the PNG).  The
dimensions are the firmware's, not a guess -- run `wsa1_bitmaps.py list` for each
file's evidence.  Ink is black.

* `SplashImage_*.png` -- the three 320x240 power-on screens.  `DitherA` and
  `DitherB` are disjoint half-tones of ONE picture (bitwise AND = 0, equal
  popcounts 3983/3983) composited by the SED1330's layer OR; opened together
  they read **`WSA`** in a brush script.  ★ That closes the "what the artwork
  says is NOT established" line in `notes/FINDINGS-prom_a-splash-bitmaps.md`.
  `Wordmark` reads `Technics`.
* `Bitmap_FF17E2.png` .. `Bitmap_FF20F4.png` -- ten 16x129 strips.  Opened, they
  are a **vertical piano-keyboard ruler labelled C-2, C-1, C0 ... C8**, the same
  keyboard at ten scroll positions -- a key-range / split-point display.
* `Widget_FC48D7.png` .. -- eight 48x15 pictograms (a flat bar, a cylinder,
  tapered wedges, a parallelogram, a spool, an arrow, a bolt).
* `Bitmap_F82BB0.png`, `Bitmap_F82C00.png` -- two op-03 targets inside prom_a.

## `CONTACT_*.png` are DERIVED, and not committed

Rebuilt from the per-range PNGs by `wsa1_bitmaps.py sheet` (`make images-sheet`), never read
back, and nothing in the build depends on them; since 2026-10-31 they are git-ignored like
every other converter output.  They exist so a person can actually look
through the set.  `CONTACT_SplashImage_Composite.png` is the one that earns its
place on content rather than convenience: DitherA and DitherB are disjoint
half-tones the SED1330 OR-composites across two layers, so **neither file alone
is the picture the panel shows** -- the composite is, and it reads `WSA`.
