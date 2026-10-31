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
