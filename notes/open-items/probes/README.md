# Probes behind the open-items register's figures (2026-10-31)

The register's plans quote a few measurements made while triaging the census `opaque` groups.  These are the
scripts that made them.  The WSA1R floppy references are git-ignored: `make -C floppy` (or a copy from the main
checkout) puts them in `floppy/wsa1/baserom/`.

| script                 | question it answers                                                                                                | run                                                                                                                               |
|------------------------|--------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| `wsa1_boot_sectors.py` | are the nine WSA1R floppy boot sectors (`floppy/wsa1/*/boot.s`, `census: opaque -- code`) one sector?              | `python3 notes/open-items/probes/wsa1_boot_sectors.py [repo root]`                                                                |
| `stale_tails.py`       | are the WSA1R floppy files' stale tails copies of earlier bytes of the same disk image?                            | `python3 notes/open-items/probes/stale_tails.py notes/open-items/probes/wsa1_stale.tsv <repo root>`                               |
| `wsa1_stale.tsv`       | its input: the 26 stale-tail declarations (source:line, bytes, image) as `--list opaque` printed them at 43242446d | (data)                                                                                                                            |
| `bucket.py`            | how a census listing's opaque declarations split by reason, numbers removed                                        | `python3 scripts/analysis/data_incbin_census.py --list opaque > opaque.txt; python3 notes/open-items/probes/bucket.py opaque.txt` |
| `banks.py`             | in which 64 KB bank of the image a tree's opaque bytes lie (MN10300 `.incbin_range` pieces)                        | `python3 notes/open-items/probes/banks.py opaque.txt <tree> <repo root> [rows]`                                                   |

What they printed at 43242446d (the main checkout's references):

- `wsa1_boot_sectors.py`: all nine images have OEM name `MSWIN4.1`, signature `55aa`, and one boot code
  (bytes 0x3E..0x1FD, SHA-1 `631c4b94c3526e28a7382af72f54f3907065fa22`): "distinct boot codes: 1".
- `stale_tails.py`: every `.MID` tail (13) equals the 1024 bytes before it ("prev-1024 match" = its size);
  of the 13 `.CMB` tails, 11 equal the bytes 11,264 (0x2C00) earlier and 2 the bytes 65,472 earlier
  ("best back-shift (256, k)").
