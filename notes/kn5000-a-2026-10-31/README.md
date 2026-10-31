# Lane kn5000-a (wave 4, 2026-10-31): KN5000 / HD-AE5000 notes items and TODO groups

Base main 130735749, branch `open4/kn5000-a`.  Items: the ACTIONABLE, unowned `N-` and `T-` rows of the
`KN5000` and `HD-AE5000` sections of `notes/open-items/REGISTER.md` (not the style-bank rows, not the
tracker issues).  Probes: `probes/` here (README there).  Every rename is a sed script in `scripts/renaming/`,
applied to v10, v9 (v8 builds from it), v7, v6 and v5; every commit was rebuilt and compared (all 21
`compare_roms.py` sections 100.00%) and `l2_symbol_reference.py --check` passed.

## The three pending naming batches (N-045aedde, N-b6c6521a, N-fdf5a34c)

`analysis/kn5000-naming/pending/proposals_{hbatch_h3,sebatch_se3,corrections_c2}.json` (2026-10-17) were
re-validated and applied:

- every old label is still defined in v10, and no new name occurs in any `.s .c .h .ld` of the five maincpu
  trees, the four HD-AE5000 trees, table_data or v142 (`FDC_FormatOneTrack` is also table_data's boot-driver
  twin, a separate image; sharing the name is intended);
- 1,362 of the 1,422 file:line evidence quotes still occur word for word in the v10 source (h3 262 / 291, se3
  884 / 907, c2 216 / 224); the rest name labels renamed since;
- c2's 16 `.equ` records (encoder RAM) and 53 locals are included; c2's agent had not finished its unused-name
  check, which is the check above.

They now live as `analysis/kn5000-naming/proposals-2026-10-31-{hbatch-h3,sebatch-se3,corrections-c2}.json`.
The applier `apply_kn5000_naming_proposals.py` renames v10 only and `harmonize_version_labels.py` carries
names to v9 / v7 but not to v6 / v5, so a new tool did all five trees in one pass:
`scripts/renaming/carry_v10_renames.py` (docstring: the byte proof).  A label is renamed in a tree when the
tree defines the old name, does not define the new one and the 24 ROM bytes at the label match v10's (at least
half equal; differences only inside 3-byte ROM addresses, plus at most four runs of at most 2 bytes, the
16-bit RAM operands v7 / v6 / v5 place lower).  `.equ` names are renamed by name (the RAM lanes gave each
tree's name to its own address; v7 is 0x9c lower, v6 / v5 0xc0).  Result
(`carry-v10-renames-2026-10-31.txt`, the tool's output):

| tree | renamed | not defined there | code differs |
|------|---------|-------------------|--------------|
| v10  | 320     | 0                 | 0            |
| v9   | 320     | 0                 | 0            |
| v7   | 315     | 3                 | 2            |
| v6   | 311     | 5                 | 4            |
| v5   | 307     | 8                 | 5            |

`check_ported_labels.py` afterwards: v7 -> v6 misplaced 100, v6 -> v5 16, v7 -> v5 87 (101 / 17 / 89 in the
kn5000-ports notes): nothing rose.

Prose that still quotes old names: the historical records (older proposal files, review JSONs, census
reports) are left as they were.  The live converters were updated (`panel_button_actions_retype.py`,
`name_kn5000_ram.py`'s docstring).  technics-docs pages that quote the old names (not edited here, see the
Website page draft): `control-panel-protocol.md` (22 names, the encoder table), `memory-map.md` (24),
`data-wheel-investigation.md` (5), `audio-subsystem.md` (2), `rom-reconstruction.md`, `panel-parameter-keys.md`,
`swbwr-tone-init.md`, `subcpu-command-format.md` (1 each).

## The v7-harmonize follow-up renames (N-b4e8e54c)

`analysis/v7-harmonize-2026-10-24/caller-alignment-v7-final.tsv` (2026-10-24) lists 142 `v10-name-misparented`
rows: v10's structural label carries another routine's stem while v7's label at the same code (address
correspondence with a byte proof) has the right parent.  Re-read against the current ELFs: 133 still apply (the
v10 label is where the tsv says, v7 has a label there that v10 does not define); 8 have v7's current name on
another v10 label, so they need a person; 1 v10 label is gone.  The 133, plus the two `both-named` rows
`MasterSetup_HandleDialStop/Turn` -> v7's `AcMstStyleAlp_Boundary_OnHide/OnSwIn` (the dispatcher sends
EVT_HIDE / EVT_SW_IN there, `ui/ui_mode_handlers.s`), are
`analysis/kn5000-naming/proposals-2026-10-31-v7-reparent.json`, applied with `carry_v10_renames.py` to v10 (135)
and v9 (124; v9 does not define the 11 `Voice_FactoryPresetData_*` labels; run log
`carry-v7-reparent-2026-10-31.txt`).  v6 and v5 already had v7's names.  `sync_names_from_v10.py --tree v9`
and `--tree v7` then found 6 and 3 same-address same-bytes pairs (v9's `SeScreenData_0x216B..0x2193` are the se3
batch's `SeFilHpq1_SeFilLpq1_Field1..4_Record`); applied, and v7's 3 carried to v6 / v5 by name.

## Panel records and RAM quotes (N-4aa9f799, N-b5219071)

`scripts/tools/name_kn5000_panel_records.py` now covers all five trees (v6 / v5's `SndParam_BlockRamPtrs` and
default panel image `SndParamRam_DefaultImage` (0xEDB300 / 0xEDB2E8) are byte-identical to v7's, so the records
sit at the same RAM): it wrote `shared/ram_panel_records.s` for v6 / v5 (included from their `ram_variables.s`)
and respelled 1,022 / 1,018 memory operands and 17 pointer loads there.  It now also spells the table itself as
`.long PANEL_*` (77 entries per tree, 0 staying 0).

33 of the 35 `PANEL_REC_<tag>` placeholders take names (`rename_panel_rec_placeholders.sed` for their uses):

| tag(s)            | name                       | evidence                                                                                   |
|-------------------|----------------------------|--------------------------------------------------------------------------------------------|
| 0x78              | `PANEL_STYLIST_NAME`       | README-lsw-nonpart-records.md [CODE]: EffectMode_DisplayName_Render copies the 16-char name |
| 0x44 / 0x45 / 0x46| `PANEL_DRAWBAR_RIGHT1/2`, `_LEFT` | README-lsw-drawbar-records.md: 48 parameter ids 0x82nn / 0x86nn / 0x8Ann                |
| 0xC0..0xD4, 0xD7  | `PANEL_VARI_<part>`        | PanelTlv_CompanionOfPart's table maps part T to block 0xC0+T; MainVariSet writes it        |
| 0x49              | `PANEL_VARI_STYLE`         | PanelTlv_CompanionOfPart_Style returns it for the style record 0x48                        |
| 0x60              | `PANEL_EFFECT_SWITCHES`    | key table: acoustic illusion / equalizer / reverb on/off (+1)                              |
| 0x70              | `PANEL_PLAY_SETTINGS`      | key table: rotary speed, split point, transpose, orchestrator, TechniChord type, fade times |
| 0x71              | `PANEL_PMEMOUT_L`          | README-lsw-drawbar-records.md: bit 1 is the ON/OFF cell PmemOutLGridCheck draws            |
| 0x90              | `PANEL_CONDUCTOR`          | key table: conductor (+0), APC on bass / left hold (+3), R1R2 octave (+4)                  |
| 0x91              | `PANEL_GM`                 | key table: GM on/off (+3)                                                                  |
| 0x98              | `PANEL_PMEM_SETTINGS`      | key table: panel memory mode / number, music style arranger, metronome, memory filter      |

`PANEL_REC_68` and `PANEL_REC_9A` keep their tag: README-lsw-nonpart-records.md records that nothing but the
generic block walkers (`PanelTlv_ValidateBlock1`, `BitMapOut_CopyAuxTable_*`) reads them, and its probe
`analysis/disk-format-probes/lsw_nonpart_records.py` is the search; there is no reader to name them from.
The meaning of the C-family's index (sound group) stays the [INFERENCE] that note marks.

`scripts/tools/respell_ram_quotes_in_comments.py` names the parenthesised RAM quotes of comments, "(0x0D57)" ->
"(SQSTEP_CLOCK)", when exactly one `.equ` of the tree has the value: 728 in v10, 527 in v9 (their RAM equates
agree, 574 of 574).  v7 / v6 / v5 are not run: their headers often carry v10's text and v10's addresses.
