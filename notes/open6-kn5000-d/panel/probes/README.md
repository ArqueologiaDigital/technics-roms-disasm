# Probes of sub-lane open6-kn5000-d/panel

Run from the repository root.  None of them writes into the source trees except where the command says `--apply` /
`--json` into a spec.

| script                  | question it answers                                                                                                                                            | command                                                                                                                                                  |
|-------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|
| `panel_byte_values.py`  | Which values does each panel-record byte hold in the 14 floppies' saved panels (default: only the bytes still named `f<offset>`)?                              | `python3 notes/open6-kn5000-d/panel/probes/panel_byte_values.py [--tags 72,93] [--all]`                                                                  |
| `panel_base_reads.py`   | Which v10 instructions reach a panel-record byte through a base register loaded with a panel address (`ld xR, PANEL_X` then `(xR + d)`)? A lower bound.        | `python3 notes/open6-kn5000-d/panel/probes/panel_base_reads.py [--tree v10] [--tags 60,68,...]`                                                          |
| `dsp_slot_packing.py`   | Which payload byte(s) and bits hold parameter k of DSP effect e (DSPCfg_ReadMultiField / DSPCfg_ReadField), and do all saved DSP slot records decode in range? | `python3 notes/open6-kn5000-d/panel/probes/dsp_slot_packing.py original_ROMs/kn5000_v10_program.rom --check-floppy . --json notes/floppy-kn5000-2026-10-29/specs/dsp_effect_params.json` |
| `se_page_names.py`      | Which SOUND EDIT caption is each envelope / LFO byte of the 470-byte sound record (the element each page handler sends)? `--apply` renames the TM spec's fields. | `python3 notes/open6-kn5000-d/panel/probes/se_page_names.py --table` / `--apply notes/floppy-kn5000-2026-10-29/specs/tm_sound_record.json`                |

Signals read:

- `dsp_slot_packing.py`: ROM tables at v10 addresses DspFxParamCountTable 0xEE5FE0 (u8 x 100), DSPCfg_LookupAndExtract_PtrTable
  0xEE6044 (u32 x 100 -> 6-byte {min BE, max BE, x, name index}), DspFxRecListPtrTable 0xEE75F6 (u32 x 100 -> the record
  list: BE16 length, op letter at +2, operand nibbles at +4, end 0xF0), DspParamName_Table 0xE324C4 (86 x 17),
  DspEffectName_PtrTable 0xE32A7A.  Pass = every value of a record inside its {min, max}; result 2026-11-02: every typed
  DSP slot record (23,434 of the 23,441 `ptlv_dsp_slot` lines; the other 7 are NO OPERATION, which has no record list)
  decodes in range, for every effect.
- `panel_byte_values.py` reads the generated floppy sources, so it reflects the committed `floppy/kn5000/**/*.s`.
- `se_page_names.py` carries its evidence in its PAGES table (handler, cache byte, caption, element, edit range).
