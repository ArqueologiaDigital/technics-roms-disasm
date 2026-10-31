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

    make -C kn7000 ic21-own-probes          # all of them but name_search.py, in this order
    python3 -I kn7000/notes/ic21-own-probes/<script>.py
    python3 -I kn7000/notes/ic21-own-probes/name_search.py [root ...]   # a few minutes; walks the private dumps

| script            | question it answers                                                                                  |
|-------------------|------------------------------------------------------------------------------------------------------|
| `regions.py`      | which parts below `0x20000` are used, and do they equal the Initial Data Disk files?                 |
| `regions2.py`     | where exactly the home-page block differs; what the `0x6000` block and the extra 0x4000 records hold |
| `templates.py`    | does each block below `0x20000` equal the default the firmware writes there (programs 893 and 941)?  |
| `custom.py`       | how much of the CUSTOM bank occurs in the nine factory banks; its text that none of them has         |
| `names_kn5000.py` | where each text run of the CUSTOM bank comes from (KN5000 program, KN7000 firmware, factory sets)    |
| `name_fields.py`  | the same for every NAME FIELD of the 20 records, read from their structure: did anyone type a name?  |
| `marker.py`       | where the firmware refers to the `A5A55A5A` constant and to `0x96806000`                             |
| `name_search.py`  | is any of the five respelled names anywhere in the dumps, floppies and installers we hold?           |
| `name_origin.py`  | are each slot's four setting names the KN5000 MUSIC DATABASE titles of its style, in order?          |
| `ots_origin.py`   | why no setting holds 941's part tails: 893 vs 941 writer, and the KN6000-file conversion's shape     |
| `hp_parts.py`     | what the home-page parts are (kind name, x, y) in the chip, the `.HMP` file and the ROM template     |
| `section_map.py`  | which settings field is section n of `func_4C024030`, and which fields no routine names              |
| `stream_rules.py` | which position rules and stream sizes the live event streams keep (the residue typer's rules)        |

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
  record 344 of 396 (941 `0x485f9584`, HpFlashCheck's template). The `disk` lines: `02UMDINI.MD`,
  `03FAVINI.FAV` and the `.HMP`'s BMP equal the programs' defaults; the `.HMP` record has 395 of 396.
- `custom.py`: every used 64 KB sector of the bank (`0x20000`..`0xf0000`) shows `-` (no factory bank holds
  it); `256-byte chunks ... 969 of 3472 occur in a known set (27.9%)`.
- `names_kn5000.py` (text runs split on double spaces): `KN5000 program: 39`, `KN7000 firmware/table only:
  17`, `known KN7000 sets only: 0`, `none of these: 79`. Of those 79, 78 are event bytes that happen to be
  printable (`nnjiinriA` ...) and one is `Jazz At 3.00am`; this is why `name_fields.py` exists.
- `name_fields.py`: `340 name fields in 20 records`; `KN5000 program: 208 fields, 116 distinct`; `KN7000
  program/table: 127 fields, 18 distinct`; `none of these: 4` (`3/4 Played By 4`, `Disco - Techni`,
  `Metallic Dance`, `Sentimntal Solo`); `KN5000 program, ':' written '.': 1` (`Jazz At 3.00am`). The
  probe compares whole fields with KN5000 program text, so it counts `Harry J.& Co` (KN5000 `Harry J.& Co.`)
  as a KN5000 name: `name_origin.py` compares them title by title.
- `marker.py`: `a5a55a5a` once in each program (893 `0x4849fb0c`, 941 `0x4849fd19`: the `mov 0x5a5aa5a5, d0`
  of the flash test), `0x96806000` once (893 `0x4849fb28`, 941 `0x4849fd35`).

The residue figures of the CUSTOM bank (`donor 117903, stream 35260, events 32210, opaque 2256` bytes)
are printed by `make -C kn7000 ic21-own-src` (`gen_customdata_s.py`'s last line).

## What the new probes print (2026-10-31, lane ic21-rest, worktree of branch open3/ic21-rest)

- `name_search.py`: `3903 blobs searched under 4 roots` (this repository's `original_ROMs`, the private
  `technics_romsets` and `technics_roms/roms`, the `ca-software-mirror` files; zip / self-extracting zip
  members, `.AST` inflated, PDFs through `pdftotext`, `.cab` / `.msi` through `7z`, EPROM halves interleaved).
  `metallic dance`, `sentimntal solo`, `disco - techni` and `jazz at 3.00am` occur only in Felipe's own reads
  (`real_dump_v1.3_b893` pass1 IC21 and the pass4 / pass5 `R5480000.BIN` / `R5680000.BIN`, the same bank);
  `3/4 played by 4` also in the KN5000 table data and programs, case aside. `metalic dance` is in the KN5000
  table data (`0x15DA09`, a MUSIC DATABASE record of style "Straight Dance") and the KN5000 v5-v10 programs.
- `name_origin.py`: `KN5000 table data: 1000 MUSIC DATABASE records`; for every slot the KN5000 has exactly four
  records of that style, and the slot's four setting names are their titles, in the table's order;
  `setting names equal to the KN5000 title: 75; spelled differently: 5` (`Metallic Dance` for `Metalic Dance`,
  `Disco - Techni` for `Disco-Techni`, `Sentimntal Solo` for `Sentimental Solo`, `Harry J.& Co` for
  `Harry J.& Co.`, `3/4 Played By 4` for `3/4 Played by 4`).
- `ots_origin.py`: the field-map tables of 893 and 941 are `identical`, so are the writers (their sources differ
  only in labels); `func_48485B52_Block at 0x48738fb8`; Felipe's bank `80 settings; shape of func_48485B52's
  conversion ...: 80; with 941 part tails ...: 0`; the factory banks 0 conversions, with tails 4 (01ctmini) and 80
  (the other eight); the KN6000 bank's 80 settings of 0x90 bytes all end FF FF.
- `hp_parts.py`: the chip's record type 0, three parts (TITLE BAR NORM 0,-1; RIGHT COMBI 1 8,0; BALANCE NORM 1
  0,4); the `.HMP` file and the ROM template the same twelve parts (type 5 and 0); in each, the one negative
  coordinate is a TITLE BAR part's y = -1.
- `section_map.py`: the 23 cases (n 5 language ... n 10 contrast, 11 r_a94, 12 r_a96, 13 / 14 the CUSTOM PANEL,
  15 data_protect, 16 the `.MD` part, 17 cus_mem_mode, 18 acc_reverb_mask, 19 rsp_select, 20 / 21 none,
  22 panel_sw); r_a94 and r_a96 are named only by the section code, in 893, 935 and 941.
- `stream_rules.py`: `10 banks: rise 221122, equal 43611, decrease 1, pos after pos 0, status w/o pos 220000`;
  `largest stream count: 0x23b9`.
