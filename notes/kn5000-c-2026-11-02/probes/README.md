# Probes of lane kn5000-c (2026-11-02)

Run from the repository root of a built tree (`make`).  None reads a ROM: "needed" bytes are the tree's
patched bins (the build) or `ported_c_rebase.py --need` output.

| script            | question it answers                                                                                     | run                                                                    |
|-------------------|---------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------|
| `cdiv_members.py` | which C member (DWARF of the compiled, linked blob) holds each raw byte of a tree's C-divergence json? | `python3 notes/kn5000-c-2026-11-02/probes/cdiv_members.py v6 [BIN...]` |
| `cdiv_show.py`    | what does a member compile to, and which of its bytes does the tree's build patch?                     | `python3 .../cdiv_show.py v6 naka_style_bitmaps.bin Style_g1_s7_Vars`  |
| `cdiv_kinds.py`   | is each raw byte inside a 32-bit ROM pointer, a work-RAM pointer (0x30000..0x3FFFF) or something else? | `python3 .../cdiv_kinds.py v6 $TMPDIR/need-v6`                         |
| `slice_bases.py`  | for each compiled-C bin, which blob base (address - offset) do the tree's labelled slices imply?       | `python3 .../slice_bases.py v6`                                        |

`cdiv_kinds.py` compares all bytes, placed or not; the json counts only the placed ones.  The figures the
lane README quotes were taken after commit 3f4df7a2e: v6 106 pointer / 74 work-RAM / 57 other bytes
(v5 124 / 74 / 55) over every bin, of which the json keeps 237 (v6) and 253 (v5).
