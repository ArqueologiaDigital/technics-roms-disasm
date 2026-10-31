# ic21-own probes

The probes behind every figure in the header of `kn7000/src/ic21own/ic21.s` and in
`kn7000/notes/ic21-own/README.md`: what Felipe's own KN7000 IC21 read holds. The first five
were written 2026-10-19 in the private `real_dump_v1.3_b893/ic21-analysis/` folder beside the
read; on 2026-10-31 (lane ic21-own) they were copied here with their paths changed to this
repository's (`_paths.py`), and `templates.py` and `name_fields.py` were added.

Inputs (`_paths.py`): the chip `kn7000/baserom/kn7000_ic21_own.bin` (git-ignored, copied from the
private read with its SHA-1 checked, `IC21_OWN_REF=` overrides), the nine factory banks
`kn7000/baserom/customdata/*.ic21` and the Initial Data Disk `kn7000/baserom/idd7000.img` (both
made by `make -C kn7000 verify-customdata`), programs 893 / 941 and table 80 from the romset's
EPROM halves (`ROMSET_DIR=`, default `~/compartilhado/technics_romsets/kn7000`) and the tracked
KN5000 program `original_ROMs/kn5000_v10_program.rom`. They only print.

    make -C kn7000 ic21-own-probes          # all of them, in this order
    python3 -I kn7000/notes/ic21-own-probes/<script>.py

| script            | question it answers                                                                                     |
|-------------------|---------------------------------------------------------------------------------------------------------|
| `regions.py`      | which parts below `0x20000` are used, and do they equal the Initial Data Disk files?                    |
| `regions2.py`     | where exactly the home-page block differs; what the `0x6000` block and the extra 0x4000 records hold    |
| `templates.py`    | does each block below `0x20000` equal the default the firmware writes there (programs 893 and 941)?     |
| `custom.py`       | how much of the CUSTOM bank occurs in the nine factory banks; its text that none of them has            |
| `names_kn5000.py` | where each text run of the CUSTOM bank comes from (KN5000 program, KN7000 firmware, factory sets)       |
| `name_fields.py`  | the same for every NAME FIELD of the 20 records, read from their structure: did anyone type a name?     |
| `marker.py`       | where the firmware refers to the `A5A55A5A` constant and to `0x96806000`                                |

## What the output means (2026-10-31, worktree of branch open2/ic21-own)

- `regions.py`: "trimmed" spans `0x4000-0x4aa4`, `0x6000-0x8000`, `0x10000-0x10198`, `0x11000-0x15442`
  are the used parts below the bank (end exclusive; the 64-byte-step spans round them up).
  `0x04000 vs 02UMDINI.MD ... 640 bytes equal (100.0%)`, `0x10000 vs 03FAVINI.FAV ... 408 (100.0%)`,
  `0x11000 vs 04HPGINI.HMP ... 17421 bytes equal (99.7%)`; the byte-swapped lines are the control
  (the chip is not stored byte-swapped).
- `regions2.py`: `HPG: differing bytes 53 in 1 runs` (runs merged across gaps of up to 8 equal bytes),
  all `+0x0008..+0x0053`; `inside the 0x18C-byte record: 53 ; inside the BMP: 0`.
  `0x6000-0x7FFF all a5a55a5a: True`. The `UMD past 640 B` rows dump the Custom Panel and the system
  settings (`0x4280..`); they end at `0x4aa4`, then 0xFF.
- `templates.py`: `equal to program <address>` = the block is byte for byte that program's default; else
  the best candidate found by the block's first 8 bytes and how many bytes equal it. Program 893:
  .MD part `0x486162a0`, FAVORITES `0x48604390`, BMP `0x48743e5c` equal; Custom Panel 1935 of 2032
  (candidate 893 `0x4858b0d4`, 941 `0x4858cbcc` = `Str_empty_1431`), settings tail 42 of 52 (941
  `0x4858d6fc`, the halfword `func_4C023EC9_Table` and the 25 of `func_4C023F9B_Table` after it), home-page
  record 344 of 396 (941 `0x485f9584`, HpFlashCheck's template).
- `custom.py`: every used 64 KB sector of the bank (`0x20000`..`0xf0000`) shows `-` (no factory bank holds
  it); `256-byte chunks ... 969 of 3472 occur in a known set (27.9%)`.
- `names_kn5000.py` (text runs split on double spaces): `KN5000 program: 39`, `KN7000 firmware/table only:
  17`, `known KN7000 sets only: 0`, `none of these: 79`. Of those 79, 78 are event bytes that happen to be
  printable (`nnjiinriA` ...) and one is `Jazz At 3.00am`; this is why `name_fields.py` exists.
- `name_fields.py`: `340 name fields in 20 records`; `KN5000 program: 208 fields, 116 distinct`; `KN7000
  program/table: 127 fields, 18 distinct`; `none of these: 4` (`3/4 Played By 4`, `Disco - Techni`,
  `Metallic Dance`, `Sentimntal Solo`); `KN5000 program, ':' written '.': 1` (`Jazz At 3.00am`). By hand
  (2026-10-31): the KN5000 v5-v10 programs hold `3/4 Played by 4`, `Disco-Techni` and `Sentimental Solo`;
  `Metallic Dance` is in no KN5000, KN6000, KN6500, KN2400 or KN7000 image of this repository, and in no
  softlist floppy image as plain text.
- `marker.py`: `a5a55a5a` once in each program (893 `0x4849fb0c`, 941 `0x4849fd19`: the `mov 0x5a5aa5a5, d0`
  of the flash test), `0x96806000` once (893 `0x4849fb28`, 941 `0x4849fd35`).

The residue figures of the CUSTOM bank (`donor 117903, stream 35260, events 32210, opaque 2256` bytes)
are printed by `make -C kn7000 ic21-own-src` (`gen_customdata_s.py`'s last line).
