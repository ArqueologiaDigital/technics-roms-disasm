# Probes of sub-lane `subcmd` (lane open6/kn5000-d, 2026-11-02)

One script, `subcmd_probe.py`, three questions.  Run from the repository root; it reads
`original_ROMs/kn5000_v10_program.rom`, `symbols/maincpu_v10_symbols_reference.txt` and the `v10/maincpu`
sources (as bytes), and writes only to stdout.

| command                                                                 | question it answers                                                                                                                                                                       | what "pass" looks like                                                                                                                             |
|-------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| `python3 notes/open6-kn5000-d/subcmd/probes/subcmd_probe.py registry`   | Which panel bit is system parameter key 0x00C0, the key `SndParam_ApplySystemParam` turns into sub-CPU sub-command 0x09?  (`SndParam_Registry` 0xEE01A0, 0x3CC pointers, keys < 0x100)    | row `0x00c0 0x91 3 0x04 0 1 2 0x00 1`: record 0x91 (`PANEL_GM`) field 3 bit 2, range 0..1, shift 2, no inversion, handler type 1                   |
| `python3 notes/open6-kn5000-d/subcmd/probes/subcmd_probe.py recordmap`  | Which song event does the recorder write for each controller panel record 0xB0-0xB4?  (`SeqTrackAssign_RecordMapTable` 0xFCBA47, emitter indices of `MidiStream_ProcessorDispatchC_Data`) | sound tracks: `{0xb4,tag}->D0 {0xb1,tag}->D2 {0xb2,tag}->D1 {0xb3,tag}->D3`; TRACK ASSIGN 12 (DRUMS) only `0xb3`; 15 (CONTROL) only `{0xb0,1}->D3` |
| `python3 notes/open6-kn5000-d/subcmd/probes/subcmd_probe.py syssenders` | Which main-CPU calls send a sub-CPU system record F0 b1 sub value, and with which sub-command?                                                                                            | exactly two lines with `sub-command=0x09`, both `byte1=0x7f` (note_voice_mapping.s, `SndParam_ApplySystemParam` and `COMM_WriteAndCheck`)          |

`syssenders` matches the sender by either name (`SeqVoice_CheckAndRet_Prologue` now,
`SubCPU_SendSystemRecord` after `rename_subcmd.sed`), so it keeps working after the rename.  Lines printed with
`sub-command=?` are the computed sub-commands 0xA4-0xAF (`wa + 164`, scale-tune user offsets).
