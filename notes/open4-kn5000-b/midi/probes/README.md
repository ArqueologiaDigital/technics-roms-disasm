# Probes of sub-lane `midi` (lane kn5000-b, 2026-10-31)

Each reads the git-ignored reference images in `original_ROMs/` (copied by `make`) and the symbol files in
`symbols/`; none writes anything.  Run from the repository root.

| script                        | question it answers                                                                                                                                                                                      | command                                                                     |
|-------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| `sysex_rx_catalogue.py`       | Which incoming SysEx byte strings does the v10 main CPU recognise (trie `SysExRx_TrieRoot`), and which two routines (`SeqChan_CommandHandlers[id]`, `SeqData_Handlers[id]`) does each message id select? | `python3 notes/open4-kn5000-b/midi/probes/sysex_rx_catalogue.py --md`       |
| `technics_param_addresses.py` | Which panel-memory record field (tag, byte, mask, range) does each Technics parameter-change / request address reach, through `MidiCtl_SelectTable*` and the 20-byte MIDI control records?               | `python3 notes/open4-kn5000-b/midi/probes/technics_param_addresses.py --md` |
| `sound_desc_slots_30_34.py`   | What do sound-descriptor slots +0x30 and +0x34 hold (grouped by value), is +0x30 a GS drum-set map, and is the voice index a bank-0 program number? Asserts v10 == v9 == v7.                             | `python3 notes/open4-kn5000-b/midi/probes/sound_desc_slots_30_34.py`        |

Signals read: the trie is 6-byte `{key, action, next}` entries, key 0xFF ends a list, 0xFE matches any byte, a
non-zero action ends the match and is the message id.  A MIDI control record is 20 bytes; +0..+2 = SysEx address,
+6 = panel-memory record tag, +7 byte, +8 mask, +9/+10 bounds, +17 / +18 handler indices.  Descriptor slots are
read through `SoundData_CategoryDescPtr`.

The panel sound catalogue is a generator, not a probe: `scripts/generators/gen_sound_patch_catalogue.py`
(`--check notes/open4-kn5000-b/midi/sound-patch-catalogue.md`).  Its "GM voice map" section is the evidence for
the +0x34 voice names quoted in the README and in `audio/sound_data.s`.
