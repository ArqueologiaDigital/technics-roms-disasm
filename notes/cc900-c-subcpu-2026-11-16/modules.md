## Modules inferred from calr / call (905 calr pairs, 1756 near absolute calls)

26 boundaries, so 27 modules; 9 near calls cannot be separated (listed below).

| from   | to     | first routine                     | routines | hand source                             |
|--------|--------|-----------------------------------|----------|-----------------------------------------|
| 01f7ab | 01f8df | RING_BUFFER_HAS_OVERRUN           | 8        | subcpu_data_tables.s                    |
| 01f8df | 01fc95 | INIT_RING_BUFFERS                 | 7        | subcpu_data_tables.s                    |
| 01fc95 | 02289d | DSP_Init_Channels                 | 68       | core/02_audio_system_init.s             |
| 02289d | 027f74 | Instrument_LookupProgram_HiNibble | 128      | core/05_voice_params_and_tvf.s          |
| 027f74 | 02aa38 | ToneGen_WriteVoice_Long           | 82       | core/06_voice_envelopes_and_channels.s  |
| 02aa38 | 02b490 | Voice_PortamentoTargets_SetAll    | 25       | core/07_voice_ctrlchange.s              |
| 02b490 | 02d101 | Voice_Pitch_ClampRange            | 31       | core/07_voice_ctrlchange.s              |
| 02d101 | 02e213 | ToneGen_WriteVoiceParams          | 27       | core/08_voice_noteon_and_tonegen.s      |
| 02e213 | 031f16 | CheckStatusBits_40                | 76       | core/08_voice_noteon_and_tonegen.s      |
| 031f16 | 034c45 | ToneDB_Find_ToneRecord_CoeffPath  | 63       | core/10_dsp_voice_params.s              |
| 034c45 | 03555f | DSP_System_Init                   | 16       | core/10_dsp_voice_params.s              |
| 03555f | 03616a | DSP_ResetWriteBufferPtr           | 27       | core/11_ringbuf_and_midi_dispatch.s     |
| 03616a | 037e62 | DSP_ApplyConfig                   | 54       | core/13_audio_process_dsp_and_effects.s |
| 037e62 | 038365 | DSP_Reset_WithDebug               | 13       | core/13_audio_process_dsp_and_effects.s |
| 038365 | 039abd | Debug_Print_String                | 47       | core/13_audio_process_dsp_and_effects.s |
| 039abd | 03c253 | DSP_BiquadWarp_FP                 | 15       | core/14_dsp_control_routines.s          |
| 03c253 | 03d42e | DSP_Bytecode_NotifyStateChange    | 21       | core/14_dsp_control_routines.s          |
| 03d42e | 03d533 | FP_fabs                           | 3        | subcpu_fp_math.s                        |
| 03d533 | 03d8e0 | FP_pow                            | 3        | subcpu_fp_math.s                        |
| 03d8e0 | 03dce6 | FP_dsub                           | 3        | subcpu_fp_math.s                        |
| 03dce6 | 03de00 | FP_DP_Raw8Copy                    | 2        | subcpu_fp_math.s                        |
| 03de00 | 03df38 | FP_DP_DecodeToInt                 | 3        | subcpu_fp_math.s                        |
| 03df38 | 03e10e | FP_SP_AddMantissa                 | 4        | subcpu_fp_math.s                        |
| 03e10e | 03e2f0 | FP_dadd                           | 4        | subcpu_fp_math.s                        |
| 03e2f0 | 03ea9c | FP_DP_AlignMantissa               | 7        | subcpu_fp_math.s                        |
| 03ea9c | 03ed0e | FP_ldexp                          | 2        | subcpu_fp_math.s                        |
| 03ed0e | 03ee76 | FP_MulMantissa64x64               | 3        | subcpu_fp_math.s                        |

Near absolute calls inside one calr-joined span:

- `RingBuf_Init_256` -> `RingBuf_Reset_256`
- `RingBuf_Init_256` -> `FIFO_Engine256_Get_Marked`
- `RingBuf_Init_256` -> `FIFO_Engine256_Get_From_Mark`
- `RingBuf_Init_256` -> `RingBuf_Reset_512`
- `RingBuf_Init_256` -> `FIFO_Engine512_Get_Marked`
- `RingBuf_Init_256` -> `FIFO_Engine512_Get_From_Mark`
- `RingBuf_Init_1K` -> `RingBuf_Reset_1K`
- `RingBuf_Init_1K` -> `FIFO_Engine1K_Get_Marked`
- `RingBuf_Init_1K` -> `FIFO_Engine1K_Get_From_Mark`
