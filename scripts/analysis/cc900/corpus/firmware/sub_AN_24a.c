/* lane_sub helper AN, round 24, form a (KN5000 sub-CPU payload v1.42, core/13_audio_process_dsp_and_effects.s).
   Audio_Process_DSP as ONE function (span_refs.py: no outside reference to its 56 inner labels).  Starts from round
   23's form a (sub_lane_23na.c, run 2026-11-19-18-sub-r23r-apdsp, DIFF at +1), which matched the ROM's instructions
   almost everywhere; changed where the instruction diff (MAME disassembly of both sides) still differed:
   - the two cc900-data numbers swapped: V4.23 emits the 0x2c table as its FIRST constant object;
   - entry: `DSP_StoreBufferCount((r = &DSP2_RingBuffer)->n);` (the ROM uses XWA after the store, no reload);
   - the length byte's address in integers only, `(unsigned long)idx + 6 + (unsigned long)r` (the ROM's
     `add xwa,(xsp+4)`; a pointer operand made V4.23 load r into XBC and add XBC,XWA);
   - the payload buffer as an argument `(unsigned char *)(void *)ram_4370` (the ROM's `lda xwa,..; ld xbc,xwa`,
     as Voice_Retire_ToFreePool's); `&ram_4370[0]` of a __near array gave `lda xbc` directly;
   - DSP_AlgoSelect unprototyped with `(unsigned char)ch` (round 23 b matched the ROM's `ld a,izl; ld e,a; extz de`);
   - the echo: InterCPU_DMA_Send prototyped as the built ToneGen_Process_Notes caller has it, `n += 8;` first (the
     ROM loads XDE before BC = HL; prototyped calls load the pointer first);
   - 0x2d single-slot: the compare result through a byte local f before DSP_ApplyConfig (the nested call made V4.23
     evaluate the other arguments first and keep &0x4370 on the stack; round 23 b got the ROM's order) and the
     buffer through the void cast (frees WA, so the slot number goes to IX as in the ROM);
   - FRAME: round 23 had r +4, part +8, p +10 fixed and c after them (+14 / +16); the ROM has c at +12 sharing p's
     slot, i.e. p is a spilled register candidate like c.  Here p is block-scoped in each block that uses it (the
     0x2b and 0x2c 0x7f blocks, the 0x2d single-slot block): three short-lived pointers.
   Still open from round 23 (not addressed in this form): the 0x2b write path, where the ROM keeps the first 14-bit
   field in QIZ and the channel in IZ, V4.23 gave the field IZ and spilled the channel (sel in QIZH looked live).
   Form b: sel declared per case block.  Form c: p at the case-block level and `n + 8` as the argument.
   cc900-options: -Xr
*/

struct ring2k { unsigned int w, r, n; unsigned char buf[2048]; };
extern struct ring2k __near DSP2_RingBuffer;
extern unsigned int __near ram_448c;
extern unsigned char __near ram_4368[];
extern unsigned char __near ram_4369;
extern unsigned char __near ram_436a;
extern unsigned char __near ram_436b;
extern unsigned char __near ram_436e;
extern unsigned char __near ram_4370[];

extern void DSP_StoreBufferCount(unsigned int);
extern void DSP_Cmd_DequeueHeader(struct ring2k *);
extern unsigned char DSP_RingBuf_ReadAndCompare(struct ring2k *, unsigned char *);
extern void DSP_RingBuf_Skip(struct ring2k *);
extern int DSP_RingBuf_Read(struct ring2k *);
extern unsigned int Extract_14Bit_VoiceParam(unsigned char *);
extern unsigned int Extract_14Bit_PayloadSize(unsigned char *);
extern int DSP_Cmd_LoadEffectPreset(struct ring2k *);

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
/* cc900-module: Audio_Process_DSP DSP_StoreBufferCount DSP_Cmd_DequeueHeader DSP_RingBuf_ReadAndCompare DSP_RingBuf_Skip DSP_RingBuf_Read Extract_14Bit_VoiceParam Extract_14Bit_PayloadSize DSP_Cmd_LoadEffectPreset */
/* cc900-data: Audio_Process_DSP 1 = CmdHandler2C_DispatchOffsets */
/* cc900-data: Audio_Process_DSP 2 = DSP_Cmd2B_DispatchOffsets */
void Audio_Process_DSP(void)
{
    struct ring2k *r;
    unsigned char part;
    int c;
    unsigned char sel;
    int ch;
    int k;
    unsigned char f;
    unsigned int n;

    DSP_StoreBufferCount((r = &DSP2_RingBuffer)->n);
    if (ram_448c != 0)
        return;
    while ((c = DSP_RingBuf_Read(r)) >= 0) {
        if (*(unsigned char *)((unsigned long)((r->r + 5) & 0x7ff) + 6 + (unsigned long)r) > r->n) {
            r->r--;
            r->n++;
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
                        if (ram_436e <= r->n) {
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
