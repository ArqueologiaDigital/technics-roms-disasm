# SX-WSA1R routine survey (survey.py)

| tree        | routines | bytes  | link | link B | plain | plain B | hand marks | hand B | leaf, no hand mark | leaf B |
|-------------|----------|--------|------|--------|-------|---------|------------|--------|--------------------|--------|
| wsa1/prom_a | 5467     | 332528 | 1331 | 128294 | 4136  | 204234  | 616        | 64912  | 1621               | 53439  |
| wsa1/prom_b | 5843     | 393363 | 274  | 29423  | 5569  | 363940  | 858        | 126980 | 919                | 91049  |
| wsa1/prom_c | 1545     | 384215 | 737  | 186506 | 808   | 197709  | 710        | 187093 | 347                | 38584  |

## Smallest 60 leaf routines with a link frame (of 583)

| tree        | routine                          | file                                     | bytes | insns | locals | max arg offset |
|-------------|----------------------------------|------------------------------------------|-------|-------|--------|----------------|
| wsa1/prom_c | Queue_FreeSlots                  | midi/midi_serial_port.s                  | 13    | 5     | 0      | 8              |
| wsa1/prom_a | Var27DF_Set                      | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_a | Var27DA_Set                      | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_a | Var27DB_Set                      | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_a | Var27E9_Set                      | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_a | Var27F6_Set                      | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_a | Var27FB_Set                      | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_a | Var27FC_Set                      | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_a | sub_FDA459                       | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_a | Var2806_Set                      | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_a | Var2805_Set                      | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_a | Var2807_Set                      | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_a | Var280C_SetW                     | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_a | Var280E_SetW                     | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_a | Var2810_Set                      | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_a | Var2811_Set                      | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_a | Var2812_Set                      | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_a | Var27A0_Set                      | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_a | Var27A1_Set                      | modules/fcf000_fdffff_tone_edit_module.s | 14    | 5     | 0      | 8              |
| wsa1/prom_c | GlobalScale_StoreMode            | midi/midi_controllers.s                  | 14    | 5     | 0      | 8              |
| wsa1/prom_c | sub_FADBEE                       | midi/midi_controllers.s                  | 14    | 5     | 0      | 8              |
| wsa1/prom_c | sub_FADC3E                       | midi/midi_controllers.s                  | 14    | 5     | 0      | 8              |
| wsa1/prom_c | MidiIn_StoreRingBacklog          | voice/voice_leaf_helpers.s               | 15    | 5     | 0      | 8              |
| wsa1/prom_c | MidiNote_StoreStatusBit3         | voice/voice_leaf_helpers.s               | 15    | 5     | 0      | 8              |
| wsa1/prom_a | MIDI_Fg_StashFirstData           | modules/fa5400_fa5fff_midi_port.s        | 16    | 5     | 0      | 8              |
| wsa1/prom_a | Var207C_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var27DF_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var2250_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var27A2_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var27DA_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var27DB_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var27E9_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var27F4_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var27F6_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var27F5_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var27F9_GetW                     | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var27FB_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var27FC_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var27FE_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var2806_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var2805_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var2807_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var280C_GetW                     | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var280E_GetW                     | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var2810_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var2811_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var2812_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var27A0_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | Var27A1_Get                      | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | LCD_SetPanelDarkFlag             | modules/fcf000_fdffff_tone_edit_module.s | 16    | 6     | 0      | 8              |
| wsa1/prom_a | SoftKeyCol6_SoundEditFilterHpf12 | modules/fcf000_fdffff_tone_edit_module.s | 17    | 8     | 0      | 8              |
| wsa1/prom_a | SoftKeyCol7_SoundEditFilterHpf12 | modules/fcf000_fdffff_tone_edit_module.s | 17    | 8     | 0      | 8              |
| wsa1/prom_a | SoftKeyCol8_SoundEditFilterHpf12 | modules/fcf000_fdffff_tone_edit_module.s | 17    | 8     | 0      | 8              |
| wsa1/prom_a | LcdKeyRow1_SoundEditFilterHpf12  | modules/fcf000_fdffff_tone_edit_module.s | 17    | 8     | 0      | 8              |
| wsa1/prom_a | LcdKeyRow2_SoundEditFilterHpf12  | modules/fcf000_fdffff_tone_edit_module.s | 17    | 8     | 0      | 8              |
| wsa1/prom_a | LcdKeyRow3_SoundEditFilterHpf12  | modules/fcf000_fdffff_tone_edit_module.s | 17    | 8     | 0      | 8              |
| wsa1/prom_a | LcdKeyRow5_SoundEditFilterHpf12  | modules/fcf000_fdffff_tone_edit_module.s | 17    | 8     | 0      | 8              |
| wsa1/prom_a | LcdKeyRow1_SoundEditFilterHpf24  | modules/fcf000_fdffff_tone_edit_module.s | 17    | 8     | 0      | 8              |
| wsa1/prom_a | LcdKeyRow2_SoundEditFilterHpf24  | modules/fcf000_fdffff_tone_edit_module.s | 17    | 8     | 0      | 8              |
| wsa1/prom_a | LcdKeyRow3_SoundEditFilterHpf24  | modules/fcf000_fdffff_tone_edit_module.s | 17    | 8     | 0      | 8              |

