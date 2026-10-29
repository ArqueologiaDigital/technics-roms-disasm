# Table-semantics probes

The measurements behind `notes/table-semantics-2026-10-29.md`. Run from `kn7000/`; they read the
git-ignored reference images in `baserom/` (`make baserom` / the SP7001 rules of the Makefile).

| script                     | question it answers                                                                                                                                                                                                                   | command                                                            |
|----------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| `table_semantics_probe.py` | For tables 84 and 83: are the GUI rows' pad bytes all 0? Do all style streams of segment 59 parse? How many pads in segment 4? Do the 'TCMP' / 'TPAD' stored checksums equal SumU16BE of their range? How varied is each 'ZZZJ' byte? | `python3 -I notes/table-semantics-probes/table_semantics_probe.py` |

Signals read: the pad byte at `pixels + row * (w + 1) + w` of every odd-width bitmap/frame row; the
u16BE at container +6 against the sum of u24BE(+0xB) big-endian halfwords from u24BE(+8);
`tools/gen_table_styles.style_file` / `event_lines`, which raise on any stream that breaks the grammar.
Output of 2026-10-29 is quoted in the notes ("Measurements").
