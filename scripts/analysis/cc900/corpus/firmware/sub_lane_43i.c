/* lane_sub, round 43, form i (gen_lane_43c.py, from form b): Audio_Process_DSP, v1.40 form (KN5000 sub-CPU payload v1.40; check with
   sub_v423.py one LISTING --tree v140/subcpu).  Written by
   notes/cc900-c-subcpu-2026-11-16/helper-generators/gen_lane_43.py from sub_AN_30c.c (its docstring says what
   each form changes).  Helper AN's notes follow.
*/
/* lane_sub helper AN, round 30, form c: Audio_Process_DSP, v1.40 form.  From 28a.  0x24 as form a (`* 2` byte
   reads).  Write path: 28a with `w = w & 0xf;` instead of `w &= 0xf;`.  See sub_AN_30a.c for round 29's result.
   Round 28 a's notes follow.
   Round 27 (run 2026-11-19-34-sub-r27n-v140), compared with v1.40's ROM over 1,491 B
   (helper-generators/dump_AN140.py): a / b differ only in (1) the 0x24 reference reads, where V4.23 put the {lo, hi}
   array at +0x28 (it word-aligns the inner 2-byte struct after the 0x27-byte pad), and (2) the 0x2b write path, where
   the ROM computes the channel straight into QIZ and the field into IZ (a / b: channel IZ, field QIZ).  The type word
   c in IZ, the frame and the jrl came out right with no C change.  27c (fields nested) put the field in IZ as the ROM
   but computed the channel into IZ and then copied it to QIZ.
   THIS FORM a = 27c with (1) the references as `unsigned char ref[8][2]` (byte alignment: +0x27), read [i][0] and
   [i][1]; (2) the write path's channel a block-local `int w` (its whole life in that block, so V4.23 may give it
   QIZ as its home), still through the int temporary k, the fields nested.  Form b: w and a block-local field v (v
   declared after w).  Form c: as b with v declared before w.
   Round 27 c's notes: form a with the write path's first field nested in the call (no block v;
   v1.40 keeps the channel in QIZ and the field in IZ): Audio_Process_DSP, v1.40 form (KN5000 sub-CPU payload v1.40,
   v140/subcpu/core/13_audio_process_dsp_and_effects.s; check with sub_v423.py one LISTING --tree v140/subcpu).
   Starts from v140/subcpu/cc900-staged/audio_process_dsp_and_effects_an_26c.c (v142's matching C with v140's cells)
   and changes only what scripts/generators/create_v140_subcpu_source.py's edit 2 changes in the source: sub-command
   0x24 (DSP_Cmd2B_SetParam) looks the part's patch record up itself and passes the record's {lo, hi} sub-tone
   reference to DSP_SetVoiceCoefficients:
       t = ToneDB_Find_ToneRecord(ram_41335[part * 0x11f], ram_41336[part * 0x11f]);   (v1.40 Payload_Bss_Start
       n = DSP_SetVoiceCoefficients(t->ref[i].lo, t->ref[i].hi, p);                     +0x250b / +0x250c)
   with part = payload[0], i = payload[1].  The ROM's index `extz wa; add wa,wa; add wa,0x27` then `(xhl+wa)` for lo
   and `exts xwa; add xwa,xhl; (xwa+1)` for hi read as a 2-byte struct array at +0x27 of the record (V4.23 scales a
   2-byte element by add, and the +1 member needs the 32-bit sum).  t is block-scoped in the case and stays in XHL.
   The other v1.40 edits (3: channel in QIZ and field in IZ in the write path; the type word c in IZ instead of the
   frame slot +12) are register allocation: no C change is made for them here, on the guess that the longer 0x24
   case moves V4.23's choices by itself.  Form b: t function-scope.  Form c: form a with the write path's field
   nested in the call again (no block v), as round 26 a.
   cc900-options: -Xr
*/

extern unsigned char ram_41335[];
extern unsigned char ram_41336[];
extern unsigned char *ToneDB_Find_ToneRecord(unsigned int, unsigned int);
extern unsigned char __near DSP2_RingBuffer[];
extern unsigned int __near ram_448c;
extern unsigned char __near ram_4368[];
extern unsigned char __near ram_4369;
extern unsigned char __near ram_436a;
extern unsigned char __near ram_436b;
extern unsigned char __near ram_436e;
extern unsigned char __near ram_4370[];
extern void DSP_StoreBufferCount(unsigned int);
extern void DSP_Cmd_DequeueHeader(unsigned char *);
extern unsigned char DSP_RingBuf_ReadAndCompare(unsigned char *, unsigned char *);
extern void DSP_RingBuf_Skip(unsigned char *);
extern int DSP_RingBuf_Read(unsigned char *);
extern unsigned int Extract_14Bit_VoiceParam(unsigned char *);
extern unsigned int Extract_14Bit_PayloadSize(unsigned char *);
extern int DSP_Cmd_LoadEffectPreset(unsigned char *);
extern int CheckStatusBits_40();
extern void Voice_Slot_CalcArticParams();
extern unsigned int DSP_AlgoSelect();
extern unsigned int DSP_EffectStateQuery();
extern unsigned int DSP_VoiceParamReadWrite();
extern unsigned int DSP_MixSendConfig();
extern unsigned int DSP_ReadVoiceParam5D();
extern unsigned int DSP_SetVoiceCoefficients();
extern unsigned int DSP_ReadVoiceParam11();
extern unsigned int DSP_WriteVoiceParam(unsigned int, unsigned int, unsigned int, unsigned char *);
extern void InterCPU_DMA_Send(unsigned char ch, unsigned int len, unsigned char *buf);
extern void Voice_SetMasterTune();
extern void DSP_Set_MixParam_45B2();
extern void DSP_Set_MixParam_45B4();
extern void ScaleTune_Set_Global_Enabled();
extern void Voice_SetPitchBendRange();
extern void DSP_Set_FadeLevel();
extern void DSP_Set_MicLevel();
extern void DSP_Set_MicSense();
extern void DSP_Set_DigitalReverbOnOff();
extern void DSP_Set_AcousticIllusionOnOff();
extern void DSP_Set_RotarySpeed();
extern void DSP_Set_MicReverbOnOff();
extern void DSP_Set_EqualizerOnOff();
extern void DSP_Reinit_VoiceSlots();
extern void DSP_VoiceState_Dispatch(int, int);
extern void Voice_AllVoices_PortaUpdate(void);
extern void DSP_ReconfigAndStatus(void);
extern unsigned char *EFF_GetSlotBuffer(unsigned int);
extern void DSP_ApplyConfig();

/* cc900-name: Voice_AllVoices_PortaUpdate=Voice_AllVoices_PortamentoUpdate */
/* cc900-module: Audio_Process_DSP DSP_Cmd_DequeueHeader DSP_Cmd_LoadEffectPreset DSP_RingBuf_Read DSP_RingBuf_ReadAndCompare DSP_RingBuf_Skip DSP_StoreBufferCount Extract_14Bit_PayloadSize Extract_14Bit_VoiceParam */
/* cc900-data: Audio_Process_DSP 1 = CmdHandler2C_DispatchOffsets */
/* cc900-data: Audio_Process_DSP 2 = DSP_Cmd2B_DispatchOffsets */
struct pair { unsigned char lo; unsigned char hi; };
void Audio_Process_DSP(void)
{
    int w;
    unsigned char *r;
    unsigned char part;
    unsigned char *p;
    int c;
    unsigned char sel;
    int ch;
    int k;
    unsigned char f;
    unsigned int n;
    unsigned char *q;

    q = DSP2_RingBuffer;
    r = q;
    DSP_StoreBufferCount(*(unsigned int *)(q + 4));
    if (ram_448c != 0)
        return;
    while ((c = DSP_RingBuf_Read(r)) >= 0) {
        if (*((unsigned long)((*(unsigned int *)(r + 2) + 5) & 0x7ff) + 6 + r) > *(unsigned int *)(r + 4)) {
            (*(unsigned int *)(r + 2))--;
            (*(unsigned int *)(r + 4))++;
            ram_448c = 1;
            return;
        }
        DSP_Cmd_DequeueHeader(r);
        switch (ram_4368[0] = c) {
        case 0x2b:
            DSP_RingBuf_ReadAndCompare(r, (unsigned char *)(void *)ram_4370);
            sel = ram_4369;
            if (sel >= 0x30 && sel <= 0x3f) {
                if (ram_436a == 0x7f) {
                    ch = sel;
                    ch &= 0xf;
                    p = &ram_4370[0];
                    switch (ram_436b) {
                    case 0:
                        if (CheckStatusBits_40(ch))
                            Voice_Slot_CalcArticParams(ch);
                        n = DSP_AlgoSelect((unsigned char)ch, ram_4370[0], p);
                        break;
                    case 3:
                        n = DSP_EffectStateQuery(part & 0xf, p);
                        break;
                    case 0x10:
                        n = DSP_VoiceParamReadWrite(part & 0xf, 0, p);
                        break;
                    case 0x11:
                        n = DSP_VoiceParamReadWrite(part & 0xf, 1, p);
                        break;
                    case 0x12:
                        n = DSP_VoiceParamReadWrite(part & 0xf, 2, p);
                        break;
                    case 0x13:
                        n = DSP_VoiceParamReadWrite(part & 0xf, 3, p);
                        break;
                    case 0x14:
                        n = DSP_VoiceParamReadWrite(part & 0xf, 4, p);
                        break;
                    case 0x15:
                        n = DSP_VoiceParamReadWrite(part & 0xf, 5, p);
                        break;
                    case 0x16:
                        n = DSP_VoiceParamReadWrite(part & 0xf, 6, p);
                        break;
                    case 0x17:
                        n = DSP_VoiceParamReadWrite(part & 0xf, 7, p);
                        break;
                    case 0x20:
                        n = DSP_MixSendConfig(ram_4370[0], ram_4370[1], p);
                        break;
                    case 0x22:
                        n = DSP_ReadVoiceParam5D(ram_4370[0], ram_4370[1], p);
                        break;
                    case 0x24: {
                        unsigned char *t;
                        t = ToneDB_Find_ToneRecord(ram_41335[ram_4370[0] * 0x11f], ram_41336[ram_4370[0] * 0x11f]);
                        n = DSP_SetVoiceCoefficients(t[(int)ram_4370[1] * 2 + 0x27], ((struct pair *)&t[(int)ram_4370[1] * 2 + 0x27])->hi, p);
                        break;
                    }
                    case 0x27:
                        n = DSP_ReadVoiceParam11(ram_4370[0], ram_4370[1], p);
                        break;
                    case 0x30:
                        n = 0;
                        break;
                    default:
                        DSP_RingBuf_Skip(r);
                        n = 0;
                        break;
                    }
                } else {
                    k = sel;
                    w = k;
                    w &= 0xf;
                    n = DSP_WriteVoiceParam(w, Extract_14Bit_VoiceParam(ram_4368),
                                            Extract_14Bit_PayloadSize(ram_4368), ram_4370);
                }
                if (n != 0) {
                    n += 8;
                    InterCPU_DMA_Send(3, n, ram_4368);
                }
            } else if (sel == 0x40) {
                DSP_RingBuf_Skip(r);
            } else {
                DSP_RingBuf_Skip(r);
            }
            break;
        case 0x2c:
            DSP_RingBuf_ReadAndCompare(r, (unsigned char *)(void *)ram_4370);
            sel = ram_4369;
            if (sel == 0) {
                if (ram_436a == 8) {
                    switch (ram_436b) {
                    case 0:
                        Voice_SetMasterTune((char)ram_4370[0]);
                        break;
                    case 1:
                        DSP_Set_MixParam_45B2(ram_4370[0]);
                        break;
                    case 2:
                        DSP_Set_MixParam_45B4(ram_4370[0]);
                        break;
                    case 3:
                        ScaleTune_Set_Global_Enabled(ram_4370[0]);
                        break;
                    case 4:
                        Voice_SetPitchBendRange((char)ram_4370[0]);
                        break;
                    case 5:
                        break;
                    case 6:
                        DSP_Set_FadeLevel(ram_4370[0]);
                        break;
                    case 7:
                        DSP_Set_MicLevel(ram_4370[0]);
                        break;
                    case 8:
                        DSP_Set_MicSense(ram_4370[0]);
                        break;
                    case 0x20:
                        break;
                    case 0x21:
                        DSP_Set_DigitalReverbOnOff(ram_4370[0]);
                        break;
                    case 0x22:
                        DSP_Set_AcousticIllusionOnOff(ram_4370[0]);
                        break;
                    case 0x23:
                        DSP_Set_RotarySpeed(ram_4370[0]);
                        break;
                    case 0x24:
                        DSP_Set_MicReverbOnOff(ram_4370[0]);
                        break;
                    case 0x25:
                        DSP_Set_EqualizerOnOff(ram_4370[0]);
                        break;
                    default:
                        DSP_RingBuf_Skip(r);
                        break;
                    }
                }
            } else if (sel >= 0x30 && sel <= 0x3f) {
                if (ram_436a == 0x7f) {
                    ch = sel;
                    ch &= 0xf;
                    p = &ram_4370[0];
                    switch (ram_436b) {
                    case 3:
                    case 0x10: case 0x11: case 0x12: case 0x13:
                    case 0x14: case 0x15: case 0x16: case 0x17:
                        break;
                    default:
                        DSP_RingBuf_Skip(r);
                        break;
                    case 4:
                        DSP_Reinit_VoiceSlots(ram_4370[0], ram_4370[1]);
                        DSP_VoiceState_Dispatch(0xff, 0xff);
                        break;
                    case 6:
                        DSP_VoiceState_Dispatch(ram_4370[0], ram_4370[1]);
                        break;
                    case 8:
                        Voice_AllVoices_PortaUpdate();
                        break;
                    }
                }
            } else if (sel == 0x40) {
                DSP_RingBuf_Skip(r);
            } else {
                DSP_RingBuf_Skip(r);
            }
            break;
        case 0x2d:
            sel = ram_4369;
            if (sel == 0) {
                sel = ram_436a;
                if (sel == 9) {
                    if (DSP_Cmd_LoadEffectPreset(r) != 0xffffffff)
                        DSP_ReconfigAndStatus();
                } else if (sel >= 0x0a && sel <= 0x0e) {
                    p = EFF_GetSlotBuffer(sel - 0x0a);
                    if (p != (unsigned char *)0xffffffff) {
                        if (ram_436e <= *(unsigned int *)(r + 4)) {
                            f = DSP_RingBuf_ReadAndCompare(r, p);
                            DSP_ApplyConfig(sel - 0x0a, (unsigned char *)(void *)ram_4370, f);
                        } else
                            DSP_RingBuf_Skip(r);
                    }
                } else {
                    DSP_RingBuf_Skip(r);
                }
            } else if (sel >= 0x30 && sel <= 0x3f) {
                DSP_RingBuf_ReadAndCompare(r, (unsigned char *)ram_4370[0]);
                if (ram_436a != 0x7f)
                    ch = sel - 0x30;
                else
                    DSP_RingBuf_Skip(r);
            } else if (sel == 0x40) {
                DSP_RingBuf_ReadAndCompare(r, (unsigned char *)ram_4370[0]);
                DSP_RingBuf_Skip(r);
            } else {
                DSP_RingBuf_Skip(r);
            }
            break;
        default:
            DSP_RingBuf_Skip(r);
            break;
        }
    }
}
