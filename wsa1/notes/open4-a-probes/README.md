# open4-a probes: prom_c voice / L7A1429 items (lane open4/wsa1-a, 2026-10-31)

Every script reads the converted prom_c sources (following `prom_c/wsa1_prom_c.s`'s `.include`s, as
bytes) and, where it says so, `wsa1/original_ROMs/*`.  Run from `wsa1/`; each exits 0 on PASS and
non-zero on drift.  The findings are written up in `notes/FINDINGS-l7a1429-write-sequencing.md` §10,
`FINDINGS-l7a1429-e093-block.md` §9, `FINDINGS-l7a1429-curve-tables.md` §7a,
`FINDINGS-l7a1429-editor-pages.md` (last open bullet) and `FINDINGS-prom_c-dev10c-sibling-register-map.md` §5.

| script                        | question it answers                                                                                  | item                  | command                                                        |
|-------------------------------|------------------------------------------------------------------------------------------------------|-----------------------|----------------------------------------------------------------|
| `prom_c_callgraph.py`         | the static call graph (calls, tail jumps, computed-goto tables) other probes import                  | (library)             | `python3 notes/open4-a-probes/prom_c_callgraph.py --callers X` |
| `part_mode_kind.py`           | what byte selects MidiNote_OnByPartMode's arms, and what arm 0xC0 does                               | N-fa489241 N-33cdb04f | `python3 notes/open4-a-probes/part_mode_kind.py`               |
| `voice_builder_tag.py`        | what the Z test at 0xFB3946 tests (the builder tag of voice byte +0x01), and that it is always clear | N-75855f8f            | `python3 notes/open4-a-probes/voice_builder_tag.py`            |
| `ctrl_dest_names.py`          | what target codes 29, 30, 37 are (prom_b ControllerDestinationNames), and factory use                | N-b85f7365            | `python3 notes/open4-a-probes/ctrl_dest_names.py`              |
| `second_burst_stores.py`      | can anything between the two 19-register bursts write the 0x00D7A2 struct                            | N-de8d3a35            | `python3 notes/open4-a-probes/second_burst_stores.py`          |
| `isr_reach_param_dispatch.py` | can an interrupt handler reach Voice_ApplyParamChange_Dispatch                                       | N-ecb9e1d8            | `python3 notes/open4-a-probes/isr_reach_param_dispatch.py`     |
| `detune_writer_order.py`      | which writer of P[+0x12]/P[+0x14] runs last, per caller                                              | N-88076f49            | `python3 notes/open4-a-probes/detune_writer_order.py`          |
| `wavesel_field_readers.py`    | who reads wave-select p0, p1, p2, p12 (and p20)                                                      | N-bfa65687 N-aa8525ae | `python3 notes/open4-a-probes/wavesel_field_readers.py --all`  |
| `zone_bias_census.py`         | the (0x00E08C) bias over every factory key zone, and what the cutoff-floor table's 27 values are     | N-03a03c49 N-4d6ac76a | `python3 notes/open4-a-probes/zone_bias_census.py`             |
| `envelope_rate_lowbytes.py`   | are 0x0840/0x0880/0x08C0's low bytes from Voice_EnvelopeRate_Table, as 0x0800's is                   | N-216e88ae            | `python3 notes/open4-a-probes/envelope_rate_lowbytes.py`       |

## What is read, and what passing means

* `part_mode_kind.py`: source anchors at 0xFB3872..0xFB387A and 0xFB47DC..0xFB47F6; the census of
  32-bit stores `ld (xRR+0x1523),xRR` (six, one of them part +0x00); prom_d's tone-head byte +0x10
  over the 274 records of `ToneDB_ToneOffsetTable` (file 0xB80).  PASS = kinds {0x10: 248,
  0x00: 6, 0x80: 18, 0x71: 2} and the 0xFB3C0E arm holds no call.
* `voice_builder_tag.py`: every staging store to element +0x01 (+0x45/+0x89/+0xCD) inside
  `VoiceParams_Compute_A..D` and their orphan twins, with the instruction that forms its low byte;
  the copy-loop / walk-loop anchors; a literal census (0x3BCF, 0x5A53) of the callees between the
  copy and the test.  PASS = the four tags 0x04 / 0x08 / 0x10 / 0x12 and one bit-1 test (0xFB393A).
* `ctrl_dest_names.py`: prom_b bytes at 0xF33022 + 13k; the dispatcher's table rows and arm bodies
  in `prom_c/midi/midi_controllers.s`; prom_d tone heads' controller slots (+0x17.. +0x28, byte +1
  & 0x3F).  PASS = names POSITION / POS.DEPTH / SUB GAIN and the census {CC02a: 119, CC02b: 33}.
* `second_burst_stores.py`: every store in the closure of the routines run between the bursts,
  classified frame / absolute / register-based; PASS = no absolute in 0x00D7A2..0x00D7C7 and every
  register base explained in the probe's REG_BASES table.
* `isr_reach_param_dispatch.py`: vector table rows in `boot/reset_and_vectors.s`; PASS = neither the
  dispatcher nor its 18 transitive callers in the ISR closure, MAIN the only caller root.
* `detune_writer_order.py`: call order of `Pack104_LoadElementWaveSelRec` and
  `Pack104_DispatchByResoMode_ForPart` per routine; PASS = the dispatcher follows every loader call
  in the 7 routines that call both, and the loader-only set is the 13 listed.
* `wavesel_field_readers.py`: a forward, intra-routine register tracker from three pointer sources
  (part element +0x8C, P[+0x03], named argument slots).  ⚠ LIMITS: a pointer passed in a register
  or through an unnamed argument slot, or copied through memory other than the routine's own frame,
  is not followed; so "no reader of +0x0C" is a searched negative, graded STRONG, not PROVEN.
* `zone_bias_census.py`: prom_d descriptors at directory +0x30 / +0x38 / +0x70 (14 bytes, array
  end = smallest pool offset), every note 0..127; prom_c bytes 0xFDFF96..+256.  PASS = b in
  {0} U [-32,-2] and the floor table is the ramp described.
* `envelope_rate_lowbytes.py`: 39 instruction anchors in `voice_parameters.s`, and
  `Voice_EnvelopeRate_Table`'s bytes; PASS = every anchor and max byte <= 0x7F.
