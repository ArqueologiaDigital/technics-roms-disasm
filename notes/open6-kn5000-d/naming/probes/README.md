# Probes of the open6/kn5000-d naming sub-lane

All run from the repository root, read-only.

| script                    | question it answers                                                                                                                 | command                                                                                             |
|---------------------------|-------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| `table_reader_scan.py`    | Does any 24/32-bit value or LDAR in a program image point into a labelled table? (kn5000-j8z: none for StyleSection_GroupBaseTable) | `python3 notes/open6-kn5000-d/naming/probes/table_reader_scan.py StyleSection_GroupBaseTable 30 32` |
| `swbt_listener_owners.py` | Which SwbtWr bank-2 code (panel TLV tag) registers each HdaeRom_* / SwbtB2_* listener, per tree?                                    | `python3 notes/open6-kn5000-d/naming/probes/swbt_listener_owners.py ['regex']`                      |
| `voiceslot_family.py`     | Which VoiceSlot_* labels are routines (call / pointer / other file) and which are branch targets?                                   | `python3 notes/open6-kn5000-d/naming/probes/voiceslot_family.py v10 [--prefix P]`                   |
| `rld_record_status.py`    | What became of the 100 "not reviewed" records of the 2026-10-07 generic batches (v10 address then, label there now)?                | `python3 notes/open6-kn5000-d/naming/probes/rld_record_status.py [--json OUT]`                      |

`table_reader_scan.py` uses a window from LABEL - SLACK: with slack 32 its only hit in every tree is the call of
`RhythmProc_CopySlotData` (0x1B bytes before the table in v10), i.e. no reference into the table itself.
`swbt_listener_owners.py` and `voiceslot_family.py` were run before the renames; after them, pass the new
prefixes (`'^(PanelTag|SwbtB2_Code)'`, `--prefix SeqTrack_`).
