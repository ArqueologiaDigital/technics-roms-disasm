## Per hand source (v142/subcpu)

| file                                    | routines | bytes  | class C | class hand | leaf | leaf not hand | lda N:16 | ld xR,N |
|-----------------------------------------|----------|--------|---------|------------|------|---------------|----------|---------|
| subcpu_data_tables.s                    | 9        | 308    | 105     | 153        | 5    | 86            | 1        | 8       |
| core/02_audio_system_init.s             | 9        | 433    | 0       | 139        | 4    | 26            | 0        | 2       |
| core/03_task_scheduler_kernel.s         | 18       | 858    | 0       | 297        | 16   | 132           | 0        | 0       |
| core/04_intercpu_link.s                 | 5        | 935    | 69      | 866        | 3    | 0             | 10       | 1       |
| core/05_voice_params_and_tvf.s          | 124      | 17872  | 16914   | 0          | 60   | 3434          | 99       | 17      |
| core/06_voice_envelopes_and_channels.s  | 118      | 19289  | 18213   | 0          | 62   | 4034          | 0        | 5       |
| core/07_voice_ctrlchange.s              | 63       | 11397  | 11108   | 220        | 15   | 1023          | 18       | 3       |
| core/08_voice_noteon_and_tonegen.s      | 80       | 13985  | 9657    | 0          | 34   | 4957          | 1        | 18      |
| core/09_dsp_algo_select.s               | 9        | 1425   | 1393    | 0          | 7    | 1255          | 0        | 0       |
| core/10_dsp_voice_params.s              | 83       | 15710  | 15415   | 0          | 39   | 5719          | 0        | 17      |
| core/11_ringbuf_and_midi_dispatch.s     | 22       | 2844   | 2192    | 0          | 12   | 621           | 15       | 5       |
| core/12_dsp2_init.s                     | 10       | 609    | 522     | 0          | 6    | 326           | 2        | 0       |
| core/13_audio_process_dsp_and_effects.s | 79       | 10442  | 7769    | 1180       | 14   | 3333          | 112      | 4       |
| core/14_dsp_control_routines.s          | 77       | 20542  | 17940   | 572        | 21   | 437           | 3        | 54      |
| subcpu_fp_math.s                        | 36       | 6496   | 1939    | 4293       | 10   | 369           | 0        | 0       |
| total                                   | 742      | 123145 | 103236  | 7720       | 308  | 25752         | 261      | 134     |

## Candidates: leaf or absolute-call-only, not hand, no memory-to-memory move (largest 80 of 480, 54802 B)

| routine                                  | file                                    | bytes | insns | kind | class | calls | erp | nop | calr group |
|------------------------------------------|-----------------------------------------|-------|-------|------|-------|-------|-----|-----|------------|
| EFF_DspChannel_InitFlags                 | core/13_audio_process_dsp_and_effects.s | 1844  | 626   | leaf | C     | 0     | 0   | 0   | 187        |
| DSP_WriteOscParam_Offset                 | core/14_dsp_control_routines.s          | 1229  | 428   | abs  | C     | 68    | 0   | 0   | 218        |
| DSP_ParamEQ_Curve_FP                     | core/14_dsp_control_routines.s          | 1170  | 365   | abs  | C     | 77    | 0   | 0   | 241        |
| FP_pow                                   | subcpu_fp_math.s                        | 796   | 264   | abs  | C     | 42    | 1   | 0   | 268        |
| ToneGen_WriteVoiceParams                 | core/08_voice_noteon_and_tonegen.s      | 794   | 306   | leaf | ?     | 0     | 0   | 92  | 100        |
| DSP_FilterLUT_Fetch                      | core/14_dsp_control_routines.s          | 787   | 262   | abs  | C     | 29    | 0   | 0   | 246        |
| DSP_EFFParam_DiffAllAndFlag              | core/13_audio_process_dsp_and_effects.s | 643   | 245   | leaf | C     | 0     | 0   | 0   | 187        |
| DSP_BiquadWarp_FP                        | core/14_dsp_control_routines.s          | 617   | 203   | abs  | C     | 34    | 0   | 0   | 239        |
| ToneGen_WriteGlobalConfig                | core/08_voice_noteon_and_tonegen.s      | 591   | 233   | leaf | ?     | 0     | 0   | 76  | 100        |
| Partial_Build_Present_Word               | core/10_dsp_voice_params.s              | 550   | 167   | leaf | C     | 0     | 0   | 0   | 133        |
| DSP_VolumeParam_Scale                    | core/14_dsp_control_routines.s          | 542   | 163   | abs  | ?     | 15    | 0   | 0   | 227        |
| DSP_VolScale_B                           | core/14_dsp_control_routines.s          | 542   | 163   | abs  | ?     | 15    | 0   | 0   | 243        |
| DSP_SetCoeff_FullPipeline                | core/10_dsp_voice_params.s              | 519   | 199   | abs  | C     | 2     | 4   | 0   | 121        |
| DSP_DetuneCurve_SignedFP                 | core/14_dsp_control_routines.s          | 495   | 160   | abs  | C     | 20    | 7   | 0   | 238        |
| DSP_VoiceCoeffRoute2                     | core/09_dsp_algo_select.s               | 430   | 159   | leaf | C     | 0     | 3   | 0   | 121        |
| DSP2_SPI_BusIdle                         | core/13_audio_process_dsp_and_effects.s | 423   | 274   | abs  | ?     | 0     | 0   | 134 | 185        |
| Voice_Allocate_Typed                     | core/07_voice_ctrlchange.s              | 417   | 143   | abs  | C     | 6     | 5   | 0   | 91         |
| Voice_NoteOn_Type3                       | core/07_voice_ctrlchange.s              | 404   | 129   | abs  | C     | 1     | 0   | 0   | 91         |
| DSP_AlgoType_Dispatch1_Arms              | core/10_dsp_voice_params.s              | 396   | 135   | leaf | C     | 0     | 0   | 0   | 136        |
| Audio_Cmd_EffParam_Grp0                  | core/08_voice_noteon_and_tonegen.s      | 395   | 131   | abs  | C     | 7     | 14  | 0   | 127        |
| Voice_Allocate_1of4                      | core/07_voice_ctrlchange.s              | 392   | 137   | abs  | C     | 6     | 7   | 0   | 91         |
| EFF_SlotActive_UpdateFlags               | core/13_audio_process_dsp_and_effects.s | 370   | 136   | leaf | C     | 0     | 0   | 0   | 187        |
| AudioMod_Apply_BusRouting                | core/06_voice_envelopes_and_channels.s  | 368   | 137   | leaf | C     | 0     | 0   | 0   | 67         |
| DSP_AlgoType_Dispatch2_Arms              | core/10_dsp_voice_params.s              | 366   | 127   | leaf | C     | 0     | 0   | 0   | 137        |
| DSP_VoiceCoeffRoute                      | core/09_dsp_algo_select.s               | 365   | 135   | leaf | C     | 0     | 2   | 0   | 121        |
| DSP_ParamInterp_MultiStep                | core/14_dsp_control_routines.s          | 361   | 140   | abs  | C     | 20    | 0   | 0   | 245        |
| DSP_SetCoeff_RouteComplex                | core/10_dsp_voice_params.s              | 344   | 134   | leaf | C     | 0     | 2   | 0   | 121        |
| DSP_SlotParam_Write_From_Cache_B         | core/08_voice_noteon_and_tonegen.s      | 341   | 133   | leaf | C     | 0     | 0   | 0   | 129        |
| Voice_Part_SetStateAndReinit             | core/08_voice_noteon_and_tonegen.s      | 339   | 105   | abs  | C     | 5     | 1   | 0   | 121        |
| Voice_Poly_NoteOn                        | core/11_ringbuf_and_midi_dispatch.s     | 335   | 125   | leaf | C     | 0     | 21  | 16  | 160        |
| DSP_SlotParam_Write_From_Cache           | core/08_voice_noteon_and_tonegen.s      | 332   | 132   | leaf | C     | 0     | 0   | 0   | 128        |
| DSP_VolumeCurve_FP                       | core/14_dsp_control_routines.s          | 329   | 102   | abs  | C     | 20    | 0   | 0   | 231        |
| DSP_SOS_LUT_Fetch                        | core/14_dsp_control_routines.s          | 321   | 109   | abs  | C     | 11    | 0   | 0   | 247        |
| EFF_ParamIterator_Process                | core/13_audio_process_dsp_and_effects.s | 314   | 120   | abs  | C     | 2     | 5   | 0   | 187        |
| DSP_ParamInterp_FPComplex                | core/14_dsp_control_routines.s          | 305   | 98    | abs  | C     | 19    | 1   | 0   | 236        |
| DSP_AlgoType_D3_Arm_Types0to5_7          | core/10_dsp_voice_params.s              | 304   | 103   | leaf | C     | 0     | 0   | 0   | 142        |
| AudioMod_Apply_Slot_Field29              | core/06_voice_envelopes_and_channels.s  | 298   | 121   | leaf | C     | 0     | 3   | 0   | 68         |
| DSP_ReverbCurve_FP                       | core/14_dsp_control_routines.s          | 297   | 94    | abs  | C     | 18    | 0   | 0   | 235        |
| DSP_SetCoeff_RouteWithCallback           | core/10_dsp_voice_params.s              | 291   | 110   | abs  | C     | 1     | 3   | 0   | 121        |
| EFF_VolumeLoop                           | core/13_audio_process_dsp_and_effects.s | 283   | 113   | abs  | C     | 1     | 0   | 0   | 187        |
| AudioMod_Apply_Slot_Field2A              | core/06_voice_envelopes_and_channels.s  | 281   | 112   | leaf | C     | 0     | 3   | 0   | 68         |
| VoiceState_SwapSlot_HL_IY                | core/05_voice_params_and_tvf.s          | 279   | 122   | leaf | C     | 0     | 0   | 0   | 29         |
| DSP_SetVoiceCoefficients                 | core/10_dsp_voice_params.s              | 277   | 99    | abs  | C     | 2     | 1   | 0   | 130        |
| RoutingFlag_Encode                       | core/10_dsp_voice_params.s              | 263   | 98    | leaf | C     | 0     | 2   | 0   | 133        |
| VoiceAlloc_Apply_Algo_Group0             | core/08_voice_noteon_and_tonegen.s      | 262   | 98    | abs  | C     | 8     | 9   | 0   | 122        |
| VoiceAlloc_Apply_Algo_Group1             | core/08_voice_noteon_and_tonegen.s      | 261   | 99    | abs  | C     | 8     | 9   | 0   | 122        |
| AlgoFlag_Write                           | core/10_dsp_voice_params.s              | 256   | 95    | leaf | C     | 0     | 0   | 0   | 133        |
| AlgoFlag_Write_Bit3                      | core/10_dsp_voice_params.s              | 256   | 95    | leaf | C     | 0     | 0   | 0   | 133        |
| ToneDB_Find_PatchRecord                  | core/10_dsp_voice_params.s              | 254   | 78    | abs  | C     | 3     | 0   | 0   | 133        |
| ToneGen_WriteExtParams_15_Banked         | core/08_voice_noteon_and_tonegen.s      | 252   | 98    | leaf | ?     | 0     | 0   | 24  | 116        |
| VoiceAlloc_Apply_Algo_Group2             | core/08_voice_noteon_and_tonegen.s      | 251   | 97    | abs  | C     | 8     | 9   | 0   | 122        |
| DSP_MixerCoeff_Compute                   | core/14_dsp_control_routines.s          | 250   | 87    | abs  | C     | 18    | 0   | 0   | 248        |
| EFF_VolumeUpdate_WithDebug               | core/13_audio_process_dsp_and_effects.s | 247   | 96    | abs  | C     | 6     | 0   | 0   | 201        |
| Voice_AllVoices_UpdateVelocity           | core/06_voice_envelopes_and_channels.s  | 245   | 82    | abs  | C     | 6     | 0   | 0   | 67         |
| DSP_InitChannelSlot                      | core/11_ringbuf_and_midi_dispatch.s     | 243   | 89    | abs  | C     | 3     | 0   | 0   | 153        |
| DSP_VoiceParamReadWrite                  | core/10_dsp_voice_params.s              | 242   | 78    | abs  | C     | 5     | 0   | 0   | 121        |
| Voice_Freq_WriteRight                    | core/05_voice_params_and_tvf.s          | 239   | 80    | abs  | C     | 2     | 0   | 0   | 36         |
| Voice_LoadPitchTable_Ch                  | core/06_voice_envelopes_and_channels.s  | 239   | 80    | abs  | C     | 6     | 0   | 0   | 36         |
| Voice_LoadFilterTable_Ch                 | core/06_voice_envelopes_and_channels.s  | 239   | 80    | abs  | C     | 6     | 0   | 0   | 36         |
| Voice_DSP_OutputConfig                   | core/06_voice_envelopes_and_channels.s  | 237   | 88    | abs  | C     | 6     | 0   | 0   | 63         |
| Voice_DSP_OutputConfig2                  | core/06_voice_envelopes_and_channels.s  | 237   | 88    | abs  | C     | 6     | 0   | 0   | 64         |
| WaveSel_StageB_Build_Reg040_Footage      | core/05_voice_params_and_tvf.s          | 233   | 87    | abs  | C     | 4     | 0   | 0   | 43         |
| Pitch_Bend_Ramp_Tick                     | core/06_voice_envelopes_and_channels.s  | 231   | 59    | leaf | C     | 0     | 0   | 0   | 36         |
| FP_exp                                   | subcpu_fp_math.s                        | 230   | 75    | abs  | C     | 15    | 0   | 0   | 287        |
| Audio_Cmd_ToneEdit_Field_Write_And_Reply | core/08_voice_noteon_and_tonegen.s      | 227   | 78    | abs  | C     | 3     | 3   | 0   | 121        |
| Voice_Slot_FindOctaveOffset              | core/07_voice_ctrlchange.s              | 226   | 80    | leaf | C     | 0     | 0   | 0   | 84         |
| DSP_ChanFreq_WritePacket1                | core/10_dsp_voice_params.s              | 224   | 71    | leaf | C     | 0     | 0   | 0   | 133        |
| Voice_Reload_Levels                      | core/07_voice_ctrlchange.s              | 219   | 73    | abs  | C     | 14    | 0   | 0   | 91         |
| DSP_PanCurve_PiecewiseLin                | core/14_dsp_control_routines.s          | 219   | 60    | abs  | ?     | 12    | 0   | 0   | 237        |
| Voice_NoteState_Clear                    | core/10_dsp_voice_params.s              | 217   | 75    | leaf | C     | 0     | 0   | 0   | 133        |
| ToneGen_WriteVoice_6Words                | core/06_voice_envelopes_and_channels.s  | 216   | 85    | leaf | ?     | 0     | 0   | 24  | 67         |
| ToneGen_WriteLevelBurst                  | core/08_voice_noteon_and_tonegen.s      | 216   | 85    | leaf | ?     | 0     | 0   | 24  | 101        |
| ToneDB_Resolve_NamedToneRecord           | core/10_dsp_voice_params.s              | 216   | 70    | abs  | C     | 1     | 0   | 0   | 135        |
| DSP_BytecodeInterpreter_Init             | core/14_dsp_control_routines.s          | 213   | 83    | abs  | C     | 0     | 0   | 0   | 253        |
| EFF_Change_WithDebug                     | core/13_audio_process_dsp_and_effects.s | 208   | 71    | abs  | C     | 12    | 0   | 0   | 198        |
| DSP_VoiceState_Dispatch                  | core/11_ringbuf_and_midi_dispatch.s     | 207   | 66    | abs  | C     | 4     | 16  | 0   | 155        |
| Partial_GetBaseKey                       | core/10_dsp_voice_params.s              | 198   | 65    | leaf | C     | 0     | 0   | 0   | 133        |
| DSP_WriteParameter                       | core/14_dsp_control_routines.s          | 195   | 75    | abs  | C     | 3     | 0   | 0   | 251        |
| ToneGen_WriteLevelPair                   | core/08_voice_noteon_and_tonegen.s      | 194   | 81    | leaf | ?     | 0     | 0   | 20  | 102        |
| Voice_InitVoiceState                     | core/06_voice_envelopes_and_channels.s  | 192   | 34    | leaf | C     | 0     | 0   | 0   | 36         |

