# `.SLD` decompression probes

`tools/sld_decompress.py` uses pylzss (the `lzss` module in `../../kn7000_extraction/venv`)
when it can import it, and otherwise a pure-Python decoder of its own. With that fallback, the
MN10300 sibling trees (`kn2400/`, `kn6000/`, `kn6500/`, `hdsx3/`) can regenerate their
reference images with nothing outside the standard library.

| script                 | question it answers                                                            |
|------------------------|--------------------------------------------------------------------------------|
| `lzss_equivalence.py`  | Does the pure-Python decoder give the same bytes as pylzss on every payload?  |

Run it from `kn7000/` with the venv interpreter:

    ../../kn7000_extraction/venv/bin/python notes/sld-decompress-probes/lzss_equivalence.py \
        ../../technics_roms/sources/*/*.SLD

On 2026-10-24 it printed `pure_equal=True` for all ten files there: KN2400 `LKG1`/`LKG2`,
KN6000 `IK1`/`IK2`, KN6500 `IKV1`/`IKV2`, and KN7000 `JK1`/`JK2`/`JKT1`/`JKT2`. Each
decompressed length equals the size declared in its header. The HD-SX3 `EXTAPR.SLD` is not
in that folder. It is checked by `hdsx3/Makefile`, which records the SHA-1 of the decoded
image.
