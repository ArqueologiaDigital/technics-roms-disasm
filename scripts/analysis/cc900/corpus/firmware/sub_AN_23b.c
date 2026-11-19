/* lane_sub helper AN, round 23, form b (KN5000 sub-CPU payload v1.42, core/13_audio_process_dsp_and_effects.s).
   Audio_Process_DSP, Audio_Process_DSP .. DSP_Process_Exit's `ret`, written as ONE function: span_refs.py (tables
   DSP_Cmd2B_DispatchOffsets, CmdHandler2C_DispatchOffsets) finds no outside reference to any of its 56 inner labels.
   Shape read from the hand source:
   - the DSP ring consumer: r = &DSP2_RingBuffer, its count to DSP_StoreBufferCount, nothing if ram_448c != 0, then a
     while loop on DSP_RingBuf_Read whose test sits at the bottom (DSP_Process_ReadNext), as MIDI_Dispatch's;
   - per message: the length byte five places past the read index against the count (un-read, ram_448c = 1, out),
     DSP_Cmd_DequeueHeader, the type byte to ram_4368 and a switch 0x2b / 0x2c / 0x2d / default (compares in reverse
     source order: the source has 0x2b first);
   - 0x2b: selector sel (QIZH) in 0x30..0x3f, else skip (the 0x40 test picks between two identical skips);
     ram_436a == 0x7f: channel ch (IZ) = sel & 0xf in two statements (the ROM's IZL + extz iz + and iz), p (frame
     +10) = &ram_4370[0], switch on ram_436b with singles 0, 3, 0x20, 0x22, 0x24, 0x27, 0x30 (compared in reverse)
     and the table range 0x10..0x17 (base = case 0's body, as DSP_SetCoeff_MasterConfig's); the result n stays in
     HL and the common tail echoes the message when n != 0;
     ram_436a != 0x7f: DSP_WriteVoiceParam(ch, Extract_14Bit_VoiceParam, Extract_14Bit_PayloadSize, &0x4370), the
     channel through an int temporary k (the ROM's `extz wa; ld iz,wa; and iz,0xf`, README round 21);
   - the 0x3 and 0x10..0x17 cases read a byte local `part` (frame +8) that nothing ever writes: the ROM does so;
   - 0x2c: selector 0 -> the global table switch (cases 0..8 and 0x20..0x25, 5 and 0x20 empty); 0x30..0x3f with
     ram_436a == 0x7f -> the per-channel switch (default body first in the layout: here the empty cases come first
     and the default next); else skip;
   - 0x2d: preset load / single-slot load (EFF_GetSlotBuffer, size check, DSP_ApplyConfig with the compare result
     as a nested argument) / per-channel (ReadAndCompare with the PAYLOAD BYTE as its pointer, the ROM's
     `ld xbc,0; ld c,a`) / 0x40 / skip.
   Frame (10 bytes): r +4, part +8, p +10, c +12 sharing p's slot.  This form declares the frame locals bottom-up
   (r, part, p, c); form b declares them top-down; form c in a natural order.
   Form a: `if (ram_448c != 0) return;`, `switch (ram_4368[0] = c)`, `n + 8` as the argument, `break` for the
   empty table cases, the int temporary k in the write path, DSP_AlgoSelect prototyped with an unsigned char first
   parameter, the LoadEffectPreset result compared with 0xffffffff.
   THIS FORM b changes, against a: frame locals declared top-down (c, p, part, r); `ram_4368[0] = c;` then
   `switch (ram_4368[0])`; `n += 8;` before the call; `continue` for the empty cases of both 0x2c switches (the
   ROM's table entries 5 / 9 and the per-channel compares go straight to DSP_Process_ReadNext, the loop test);
   the per-channel 0x2c switch with `default:` first; the write path's channel `ch = (int)sel; ch &= 0xf;`;
   DSP_AlgoSelect unprototyped with `(unsigned char)ch`; `(long)DSP_Cmd_LoadEffectPreset(r) != -1L`; the 0x2d
   compare result through a byte local f; the 0x2d per-channel pointer `(unsigned char *)(unsigned long)` byte.
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
extern void InterCPU_DMA_Send();
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
extern void Voice_AllVoices_PortamentoUpdate(void);
extern void DSP_ReconfigAndStatus(void);
extern unsigned char *EFF_GetSlotBuffer(unsigned int);
extern void DSP_ApplyConfig();

/* cc900-module: Audio_Process_DSP DSP_StoreBufferCount DSP_Cmd_DequeueHeader DSP_RingBuf_ReadAndCompare DSP_RingBuf_Skip DSP_RingBuf_Read Extract_14Bit_VoiceParam Extract_14Bit_PayloadSize DSP_Cmd_LoadEffectPreset */
/* cc900-data: Audio_Process_DSP 1 = DSP_Cmd2B_DispatchOffsets */
/* cc900-data: Audio_Process_DSP 2 = CmdHandler2C_DispatchOffsets */
void Audio_Process_DSP(void)
{
    int c;
    unsigned char *p;
    unsigned char part;
    struct ring2k *r;
    unsigned char sel;
    int ch;
    unsigned char f;
    unsigned int n;

    r = &DSP2_RingBuffer;
    DSP_StoreBufferCount(r->n);
    if (ram_448c != 0)
        return;
    while ((c = DSP_RingBuf_Read(r)) >= 0) {
        if (*((unsigned long)((r->r + 5) & 0x7ff) + 6 + (unsigned char *)r) > r->n) {
            r->r--;
            r->n++;
            ram_448c = 1;
            return;
        }
        DSP_Cmd_DequeueHeader(r);
        ram_4368[0] = c;
        switch (ram_4368[0]) {
        case 0x2b:
            DSP_RingBuf_ReadAndCompare(r, &ram_4370[0]);
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
                    ch = (int)sel;
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
            DSP_RingBuf_ReadAndCompare(r, &ram_4370[0]);
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
                        continue;
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
                        continue;
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
                    default:
                        DSP_RingBuf_Skip(r);
                        break;
                    case 3:
                    case 0x10: case 0x11: case 0x12: case 0x13:
                    case 0x14: case 0x15: case 0x16: case 0x17:
                        continue;
                    case 4:
                        DSP_Reinit_VoiceSlots(ram_4370[0], ram_4370[1]);
                        DSP_VoiceState_Dispatch(0xff, 0xff);
                        break;
                    case 6:
                        DSP_VoiceState_Dispatch(ram_4370[0], ram_4370[1]);
                        break;
                    case 8:
                        Voice_AllVoices_PortamentoUpdate();
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
                    if ((long)DSP_Cmd_LoadEffectPreset(r) != -1L)
                        DSP_ReconfigAndStatus();
                } else if (sel >= 0x0a && sel <= 0x0e) {
                    p = EFF_GetSlotBuffer(sel - 0x0a);
                    if (p != (unsigned char *)0xffffffff) {
                        if (ram_436e <= r->n) {
                            f = DSP_RingBuf_ReadAndCompare(r, p);
                            DSP_ApplyConfig(sel - 0x0a, &ram_4370[0], f);
                        } else
                            DSP_RingBuf_Skip(r);
                    }
                } else {
                    DSP_RingBuf_Skip(r);
                }
            } else if (sel >= 0x30 && sel <= 0x3f) {
                DSP_RingBuf_ReadAndCompare(r, (unsigned char *)(unsigned long)ram_4370[0]);
                if (ram_436a != 0x7f)
                    ch = sel - 0x30;
                else
                    DSP_RingBuf_Skip(r);
            } else if (sel == 0x40) {
                DSP_RingBuf_ReadAndCompare(r, (unsigned char *)(unsigned long)ram_4370[0]);
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
