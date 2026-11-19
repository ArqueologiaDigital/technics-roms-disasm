/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AN_25a.c (2026-11-19-27-sub-r25a)
   sha256 7f2690879dc4b9a3a1179a8089620a5ba1aeb983e13762db391b09b3c4efcfc9 (name+funcs); compiled at -Xr
   cc900-options: -Xr
   cc900-name: Voice_AllVoices_PortaUpdate=Voice_AllVoices_PortamentoUpdate */
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
void Audio_Process_DSP(void)
{
    unsigned char *r;
    unsigned char part;
    int c;
    unsigned char sel;
    int ch;
    int k;
    unsigned char f;
    unsigned int n;
    unsigned char *q;

    (void)&c;
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
                    unsigned char *p;
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
                    case 0x24:
                        n = DSP_SetVoiceCoefficients(ram_4370[0], ram_4370[1], p);
                        break;
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
                    ch = k;
                    ch &= 0xf;
                    n = DSP_WriteVoiceParam(ch, Extract_14Bit_VoiceParam(ram_4368),
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
                    unsigned char *p;
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
                    unsigned char *p;
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
