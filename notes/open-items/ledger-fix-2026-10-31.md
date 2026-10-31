# Lane ledger-fix (2026-10-31): the three coverage ledgers on merged main

Base: main at 4d68fa99c. Every gate passed there, but two of the three ledgers did not measure cleanly:
`build_maps.py` crashed on `hdae_v110`, `census.py --compare` reported rises for `hdae_v201` / `hdae_v115`, and
`doc_quality_census.py --compare` reported 18 rises. This note gives the cause of each, the fix where one was
small and obviously right, and the reason for every rise left. The integrator writes the snapshots and badges.

## 1. `build_maps.py` IndexError on `hdae_v110`: a stale census mirror, not a path-resolution bug

The census assembles a marked copy (the "mirror") of each tree. Its marks are `(file, line index)` pairs into
the files the assembler read, and `Sources()` reads the current repository file at that index.
`census_image()` (`scripts/analysis/data_range_census.py`) reused a mirror whenever its directory existed in the
scratch. Two cases:

- The three HD-AE5000 version images have `xmirrors`, and since cf8b62847 their mirror names were fixed
  (`mirror_hdae_v201`, `mirror_hdae_v115`, `mirror_hdae_v110`). In the shared default
  `$TMPDIR/dispatch-table-census/work/`, those mirrors were made at 07:42-07:43 on 2026-10-31. Every later run
  assembled that morning's sources and read the current files with the morning's line numbers.
  - The stale copy of `hdae5000_v1_10i/hdae5000_data_tables.s` had 3,994 lines. After cce6ddbec (15:56) the
    file has 3,980 lines, so a mark fell past its end: the IndexError.
  - The census does resolve files the way the assembler does. A file reached through an `xmirror` is named
    `../hdae5000_v1_15i/...` and is read from that path. The marks came from the files the assembler really
    read; only their age was wrong.
- The other images' mirror names held `str hash()`, which Python randomises in each process. They were never
  reused, and each run left one more mirror behind: 459 `mirror_*` entries, 5.4 GB, in the shared scratch.

**Fix (570ce9038).** Every mirror now has a deterministic name and a `.fingerprint` file: a sha1 over each tree's
absolute path, every file name, and every `.s` file's bytes. A mirror whose fingerprint differs is removed and
built again; the removal first asserts that the path lies inside the scratch. `build_maps.py` now checks that
each mark lies inside its file and says "stale mirror" if it does not, instead of raising IndexError. Tested by
building `hdae_v110` twice: the second run reused the mirror in 1.3 s. After the fingerprint file was corrupted,
the next run rebuilt the mirror (2.4 s).

With a fresh `DISPATCH_CENSUS_DIR`, all 19 maps build and every mirror is inert (`build_maps.py` saves no map
for a mirror that does not rebuild the dump).

## 2. The `hdae_v201` / `hdae_v115` ROSE: the same stale mirrors, not dropped labels

Run on main's sources with fresh mirrors, `census.py --compare docs/coverage/dispatch-census-2026-10-31-02.json`
prints `nothing rose`. Every HD-AE5000 row reads NOT = newT = newT(x) = spellT = 0, U-NOT = U-newT = 0 and
D-unres = 0, `hdae_v110` included. The rises (not_used 0->1, 11 and 13 "nolabel" targets, unframed 0->3 / 0->2)
came from labels read from the wrong lines. The edits made since 07:43 had shifted lines in 13 of the 19 `.s`
files mirrored for `hdae_v201` and in 13 of the 20 mirrored for `hdae_v115`. That comparison of the shared
mirrors (marker lines stripped) against the current files is in the lane's scratch. `hdae5000` itself, whose
mirror had a hash name and so was rebuilt on every run, showed no rise.

So no label had been lost. `rename_open4_hdae.sed` (kn5000-b), kn5000-a's `.L` changes and kn5000-ports'
v1.x prose and replay edits only shifted line numbers. No source change was made for this item.

## 3. doc-quality rises against `doc-quality-2026-10-31-02`

Found with the new `--byte-runs KEY` listing, `--routines KEY` and `--files KEY`, each run on a worktree at the
snapshot's head (6ca33e656) and on this branch, then diffed.

| image(s)                | figure that rose                    | change          | cause (commit)                                                                                                                                                                                                                                                                                                                                                                                                                  | outcome                                                                                                                                                                       |
|-------------------------|-------------------------------------|-----------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| v10, v9, v8             | (d) runs / bytes after a terminator | +1 / +36 B      | 5a842de81 (lane kn5000-b-midi): in `display/scoop_display.s` the six rhythm-mode bytes `SqStep_ButtonRhythmModeBytes` (`0x50 0x40 0x30 0x20 0x10 0x00`) were `.ascii "P@0 "` + `.byte`. They are not text, so they are now `.byte`, and the three inline tables after `SystemInit_StepHandler_0_Return: ret` (24 + 6 + 6 B) form one `.byte` run between instructions.                                                          | kept: typed inline data, correctly spelled (string-literal policy: only readable text is `.ascii`)                                                                            |
| v10, v9, v8, v7, v6, v5 | (d) bytes after fall-through        | +14 B gross     | 3832a6dfc (lane kn5000-a, "data spelled as code respelled"): `RhythmBuf_BarQuartersByTimeSig` in `sequencer/accompaniment_engine.s` was 20 bytes spelled as instructions (`push sr`, `ld (1:8), 2:io`, `max`, `halt`, ...) with two `.byte` runs (2 B, 1 B). It is now the 20-byte table it is. It follows the `nop` pad `AccFill_AdvanceAndCheck_Pad`, which is not a terminator, so the census calls it "after fall-through". | kept: the fix the census asks for (No Faux-Instructions); code spelled as data would be the debt, and this is data spelled as data                                            |
| (same)                  | (same, the net)                     | +8 / +10 / +7 B | The net per image is +14 minus runs that the same lanes removed: `boot/system_handlers.s` -4 B (all six), `audio/note_voice_mapping.s` -2 B (v10, v9, v8), `storage/fdc_routines.s` -3 B (v6, v5). Net: v10 / v9 / v8 +8, v7 +10, v6 / v5 +7. The run counts after fall-through fell by 5 or 6 in every tree.                                                                                                                   | explained                                                                                                                                                                     |
| v142, v141, v140        | (a) routines without a header       | +1              | e89259d38 (split of the payload core into 14 files, join/split phase A4) made `TaskSched_Wait` and `RingBuf_Init_512` cross-file jump targets (`xfile_jump`), so both now count as routines; both lacked a header. `Voice_Apply_GateRouting` had gained one meanwhile: net +1.                                                                                                                                                  | **fixed** in dfae0194b: headers for `TaskSched_Wait` and `RingBuf_Init_1K` / `_256` / `_512`; v141 / v140 regenerated. Now 155 -> 152, call targets without a header 90 -> 87 |
| kn2400                  | (a) routines without a header       | +1              | 95d554468 + ff5eafe8c (lane mn10300-rest): `FxSpeedNudge` (0x4863B51E, `kn2400_manual.sym`) labels a block that was unlabelled, after `retf` (the generator's banner says no traced path reaches it; "nothing calls it")                                                                                                                                                                                                        | explained: `gen_image_s.py` writes no header comments, so any newly named routine in these trees counts as header-less (2 of kn6500's 19,073 routines have one)               |
| kn6000                  | (a) routines without a header       | +1              | same commits: `XaprIsrGroup24` (0x4C172AA2, `kn6000_manual.sym`) labels an interrupt handler that `XaprInstallIsrs` passes to `def_int` as a number (`mov 0x4c172aa2, d0`)                                                                                                                                                                                                                                                      | explained, as kn2400                                                                                                                                                          |
| kn6500                  | (a) routines without a header       | +1              | same commits: `XaprIsrGroup27` (0x4C1732DF, `kn6500_manual.sym`), the same `def_int`'d handler                                                                                                                                                                                                                                                                                                                                  | explained, as kn2400                                                                                                                                                          |

**Left for later, not done here.** Two changes would remove the sibling rises for good, and neither is a
ledger fix:

- `kn7000/tools/gen_image_s.py` could write each `*_manual.sym` comment as a header above its label.
- `XaprInstallIsrs`'s `mov 0x4c172aa2, d0` / `mov 0x4c172add, d0` could be spelled as symbols.

The first is a generator change that regenerates four large files; the second would only move the routines to
reason `address`, so they would still have no header.

## How to reproduce

    export DISPATCH_CENSUS_DIR=$HOME/compartilhado/tmp/<your-lane>/dtc     # one per worktree / per run
    python3 scripts/analysis/dispatch_table_census/build_maps.py
    python3 scripts/analysis/dispatch_table_census/census.py --compare docs/coverage/dispatch-census-2026-10-31-02.json
    python3 scripts/analysis/doc_quality_census.py --compare docs/coverage/doc-quality-2026-10-31-02.json
    python3 scripts/analysis/doc_quality_census.py --byte-runs v10          # every (d) run, file:line
    python3 scripts/analysis/data_incbin_census.py --compare docs/coverage/data-incbin-2026-10-31-02.json

## Found on the way (fresh worktree)

- `make gate-wsa1` needs `wsa1/rebuilt_ROMs/wsa1_prom_a.llvm.elf` / `_b`, which `make wsa1` does not make
  since the joint link (B3). `gui_menu_map.py --check` stops with "build first". Workaround:
  `make -C wsa1 rebuilt_ROMs/wsa1_prom_a.llvm.elf rebuilt_ROMs/wsa1_prom_b.llvm.elf`. Not changed here.
- `gate-kn7000` in a worktree also needs `EXTRACT_DIR` / `DISKS_DIR` overrides, or a copy of the main checkout's
  git-ignored `kn7000/baserom/`.
- The shared default scratch `~/compartilhado/tmp/dispatch-table-census/` (5.4 GB, mostly leaked hash-named
  mirrors) was left alone, because other lanes may be using it. It is regenerable. Once no census run is
  active, delete it with `rm -rf -- /home/fsanches/compartilhado/tmp/dispatch-table-census`.

## Final figures on open5/ledger-fix

Gates, with `kn7000/build/*.labels` deleted first: `make gate` exits 0, `make gate-wsa1` exits 0 (after the ELF workaround
above), and `make gate-kn7000 gate-kn6000 gate-kn6500 gate-kn2400 gate-hdsx3` and `make -C kn7000 symbols-check`
exit 0.

- **Dispatch census.** All 19 maps build, every mirror inert.
  `census.py --compare docs/coverage/dispatch-census-2026-10-31-02.json` prints
  `compared with docs/coverage/dispatch-census-2026-10-31-02.json: nothing rose` (exit 0).
- **Data-incbin census.** `data_incbin_census.py --compare docs/coverage/data-incbin-2026-10-31-02.json` exits 0
  with no ROSE line; generic = 0 and unsized = 0 in every tree.
- **Doc-quality census.** `doc_quality_census.py --compare docs/coverage/doc-quality-2026-10-31-02.json` exits 1
  with the 15 rises explained in section 3 (44 figures fell; v142 / v141 / v140 no longer rise):

        ROSE  v10        (d) ... their bytes                      151 -> 159
        ROSE  v10        (d) .byte runs after a terminator        93 -> 94
        ROSE  v10        (d) ... their bytes                      3001 -> 3037
        ROSE  v9         (d) ... their bytes                      156 -> 164
        ROSE  v9         (d) .byte runs after a terminator        97 -> 98
        ROSE  v9         (d) ... their bytes                      3313 -> 3349
        ROSE  v8         (d) ... their bytes                      156 -> 164
        ROSE  v8         (d) .byte runs after a terminator        97 -> 98
        ROSE  v8         (d) ... their bytes                      3313 -> 3349
        ROSE  v7         (d) ... their bytes                      1017 -> 1027
        ROSE  v6         (d) ... their bytes                      1530 -> 1537
        ROSE  v5         (d) ... their bytes                      1458 -> 1465
        new   program935 (not in docs/coverage/doc-quality-2026-10-31-02.json)
        new   program893 (not in docs/coverage/doc-quality-2026-10-31-02.json)
        ROSE  kn2400     (a) routines without a header            21242 -> 21243
        ROSE  kn6000     (a) routines without a header            19021 -> 19022
        ROSE  kn6500     (a) routines without a header            19070 -> 19071
        compared with docs/coverage/doc-quality-2026-10-31-02.json: 15 figure(s) ROSE
          (a rise is a regression unless the commit message says why, e.g. converted passthrough adds routines)
