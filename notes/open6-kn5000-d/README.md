# Lane open6/kn5000-d (2026-11-02): KN5000 tracing, naming and data items of the open-items register

Wave 6 lane `kn5000-d`, branch `open6/kn5000-d` from c240d1c0b.  The work was split into seven sub-lanes that
shared this worktree.  Each sub-lane has its own README with the findings, the evidence (probes with a README),
a "Website page draft" section and, for tracker issues, the proposed `issue-comment-<id>.txt` (added to
`.beads/issues.jsonl` in 42bfc712d; no issue was closed: the docs lane publishes the drafts and closes them).

| sub-lane | items                                           | README                                       |
|----------|-------------------------------------------------|----------------------------------------------|
| naming   | kn5000-j8z, kn5000-rld, kn5000-zc1, N-edb08959  | `naming/README.md`, `naming/rld-verdicts.md` |
| wsa1     | kn5000-wxn                                      | `wsa1/README.md`                             |
| panel    | N-0b145a01, N-583fb77c, N-10dad9c5 / N-b64487fc | `panel/README.md`                            |
| accomp   | kn5000-3qp, kn5000-rzg                          | `accomp/README.md`                           |
| subcmd   | kn5000-1gu, kn5000-a1f                          | `subcmd/README.md`                           |
| dsp      | kn5000-ax7, kn5000-i2m                          | `dsp/README.md` (work in `dsp/`)             |
| misc     | N-29e0f8b4, N-1fe9a5df, N-52dcf02a, N-d352b868  | `misc/README.md`                             |

## Outcomes

| item       | outcome | evidence / blocker                                                                                                                                                                                                                                             |
|------------|---------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| kn5000-1gu | CLOSED  | `subcmd/README.md` kn5000-1gu: sub-command 0x09 = GM mode (F0 7F 09 01 = mode B, 02 = mode A), senders and triggers                                                                                                                                            |
| kn5000-a1f | CLOSED  | `subcmd/README.md` kn5000-a1f: D0 pressure, D1 modulation, D2 bend, D3 expression; 0xBn / 0xCn value bytes                                                                                                                                                     |
| kn5000-3qp | CLOSED  | `accomp/README.md` A, `accomp/probes/pattern_transpose.py` (all 245,470 IC14 pattern notes)                                                                                                                                                                    |
| kn5000-rzg | CLOSED  | `accomp/README.md` B: SYNCHRO stop by chord release, ending lanes parked, stop when silent                                                                                                                                                                     |
| kn5000-j8z | CLOSED  | `naming/README.md` kn5000-j8z (c6f5dd2ad)                                                                                                                                                                                                                      |
| kn5000-rld | CLOSED  | `naming/rld-verdicts.md` (+ .json), 3439c8ba5                                                                                                                                                                                                                  |
| kn5000-zc1 | CLOSED  | `naming/README.md` kn5000-zc1 (8f576f2ea)                                                                                                                                                                                                                      |
| kn5000-wxn | CLOSED  | `wsa1/README.md`, `wsa1/probes/wsa1_wxn_refs.py` (5 leads applied; MidiFileL0ad_ kept: the ROM's own caption; MidiFileLoad_ since 2026-11-06)                                                                                                                  |
| kn5000-ax7 | BLOCKED | no observable left in this repo for the R1 cascade (`dsp/README.md` section 4, `dsp/analysis/bit11-xprod-2026-11-02.md`): bit-11 needs another uPD6383 host's firmware or a chip PC trace; ACT 0x0B / f31 3..7 need an EFFECT OUT recording from a real KN5000 |
| kn5000-i2m | BLOCKED | the reverb's 9 open words are ACT 0x0B / 0x1A and SRC 0x11 (no bit-11 words); needs an impulse response of a real KN5000 on ROOM REVERB 1 at EFFECT OUT                                                                                                        |
| N-edb08959 | CLOSED  | `naming/README.md` N-edb08959 (15c8ef88e); `notes/kn5000-style-2026-10-31/README.md` updated                                                                                                                                                                   |
| N-0b145a01 | CLOSED  | `panel/README.md` section 1: 63 named, 61 reserved (`panel/probes/panel_f_readers.py`), 0x80 +4 BLOCKED (copied, never tested: a MIDI capture from hardware)                                                                                                   |
| N-583fb77c | CLOSED  | `panel/README.md` section 2, `panel/probes/dsp_slot_packing.py` (23,434 typed DSP records decode in range)                                                                                                                                                     |
| N-10dad9c5 | CLOSED  | `panel/README.md` section 3, `panel/probes/se_page_names.py` (envelopes, LFOs, the 7 controller groups)                                                                                                                                                        |
| N-b64487fc | CLOSED  | same item as N-10dad9c5                                                                                                                                                                                                                                        |
| N-1fe9a5df | CLOSED  | `misc/README.md` section 2: the 0x09 bytes draw as blanks (Scoop_CharGlyphMap 0x01-0x0F -> 0x20, font 0)                                                                                                                                                       |
| N-29e0f8b4 | CLOSED  | `misc/README.md` section 1, `misc/probes/faj_eq_response.py`                                                                                                                                                                                                   |
| N-52dcf02a | CLOSED  | `misc/README.md` section 3, `misc/probes/ic307_record_words.py`; the directory P / Q words and the even record words of the 74 entries with no KN7000 twin are BLOCKED on a dump of IC306 (QSIGT3C32A01); the gain step needs a recording                      |
| N-d352b868 | CLOSED  | `misc/README.md` section 4, `misc/probes/ic307_unselected_entries.py`                                                                                                                                                                                          |

## Renames proposed by the sub-lanes, and how they were applied

The naming and wsa1 sub-lanes renamed in the trees they owned.  The others wrote sed files, which the lead
applied in one pass, after all sub-lanes had stopped (5a5311c56), in this order:

1. `python3 scripts/tools/add_kn5000_ram_names.py notes/open6-kn5000-d/accomp/ram-names-accomp.txt` (23 RAM
   names, v10 / v9 / v7);
2. `python3 scripts/renaming/apply_sed_renames.py [--apply] v10/maincpu v9/maincpu v7/maincpu v6/maincpu v5/maincpu --
   notes/open6-kn5000-d/accomp/rename_accomp.sed notes/open6-kn5000-d/subcmd/rename_subcmd.sed
   notes/open6-kn5000-d/panel/rename_panel.sed` (first without `--apply`: 0 problems);
3. `rename_misc.sed` over v142, then `scripts/generators/create_v141_subcpu_source.py` and `create_v140_...`;
4. `rename_naming.sed` with `sed -i -f` on the files that quote its old names (it fixes comments next to labels
   already renamed, so the checker's COLLISION is expected there), then `make -C floppy src-kn5000`;
5. `python3 scripts/analysis/l2_symbol_reference.py --regen`, `make gate`, `make gate-floppy` (all exit 0).

## Website page drafts

One per sub-lane README, section "Website page draft".  The renamed labels that technics-docs quotes are listed
in `naming/README.md` (its "Website page draft" table) and `subcmd/README.md` ("sysex-messages.md:58").
