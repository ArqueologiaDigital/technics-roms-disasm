/* Functions of core/10_dsp_voice_params.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_41356[];
extern unsigned char ram_4135a[];
extern unsigned char ram_413be[];
extern unsigned char ram_413c2[];
extern unsigned char ram_413e3[];
extern unsigned char ram_413e7[];
extern unsigned char ram_41408[];
extern unsigned char ram_4140c[];
extern unsigned char ram_4142d[];
extern unsigned char ram_41431[];
extern unsigned char ram_451f8[];
extern unsigned char ram_451fe[];
extern unsigned char *ram_45304;
extern void Audio_Cmd_ToneEdit_Dispatch(unsigned char *m);
extern void VoiceAlloc_CheckAndInit();
extern void Audio_Cmd_EffectParam_Dispatch(unsigned char *m);
extern void Audio_Cmd_DSPUnit_Param(unsigned char *m, int k);
extern void Audio_Cmd_DSPGlobal_Param_Store(unsigned char *m);
extern void Audio_Cmd_PatchByte_Write_And_Echo(unsigned char *m);
extern void Audio_Cmd_ToneEdit_Write_And_Reply(unsigned char *m);
extern void Audio_Cmd_ToneEdit_Field_Write_And_Reply(unsigned char *m);
extern unsigned int DSP_SetCoeff_MasterConfig(unsigned char *p);
extern void DSP_ParamWrite_BlockCopy(unsigned int n, unsigned char *s, unsigned char *d);
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern unsigned char *WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s);
extern void InterCPU_DMA_Send(unsigned char ch, unsigned int len, unsigned char *buf);
void Voice_ParamFinalize(unsigned char *p);

/* cc900-module: Audio_Cmd_DSPGlobal_Param_Store Audio_Cmd_DSPUnit_Param Audio_Cmd_EffectParam_Dispatch Audio_Cmd_PatchByte_Write_And_Echo Audio_Cmd_ToneEdit_Dispatch Audio_Cmd_ToneEdit_Field_Write_And_Reply Audio_Cmd_ToneEdit_Write_And_Reply DSP_ParamWrite_BlockCopy DSP_SetCoeff_MasterConfig VoiceAlloc_CheckAndInit Voice_ParamFinalize */
/* cc900-data: Voice_ParamFinalize 1 = VOICEPARAM_FINALIZE_QUERY_JUMPTABLE */
/* cc900-data: Voice_ParamFinalize 2 = VOICEPARAM_FINALIZE_ACTION_JUMPTABLE */
void Voice_ParamFinalize(unsigned char *p)
{
    unsigned char c;
    unsigned char k;
    unsigned char *s;
    unsigned char *q;
    unsigned int n;
    unsigned int i;
    c = *p & 7;
    if (*p & 8) {
        switch (c) {
        case 0:
            Audio_Cmd_ToneEdit_Dispatch(p);
            break;
        case 1:
            VoiceAlloc_CheckAndInit(p[1]);
            Audio_Cmd_EffectParam_Dispatch(p);
            break;
        case 2:
            VoiceAlloc_CheckAndInit(p[1]);
            switch (p[2] & 0x80) {
            case 0:
                Audio_Cmd_DSPUnit_Param(p, 0);
                break;
            case 0x80:
                Audio_Cmd_DSPUnit_Param(p, 1);
                break;
            }
            break;
        case 3:
            VoiceAlloc_CheckAndInit(p[1]);
            switch (p[2] & 0x80) {
            case 0:
                Audio_Cmd_DSPUnit_Param(p, 2);
                break;
            case 0x80:
                Audio_Cmd_DSPUnit_Param(p, 3);
                break;
            }
            break;
        case 4:
            VoiceAlloc_CheckAndInit(p[1]);
            Audio_Cmd_DSPGlobal_Param_Store(p);
            break;
        case 5:
            Audio_Cmd_PatchByte_Write_And_Echo(p);
            break;
        case 6:
            Audio_Cmd_ToneEdit_Write_And_Reply(p);
            break;
        case 7:
            Audio_Cmd_ToneEdit_Field_Write_And_Reply(p);
            break;
        }
    } else {
        switch (c) {
        case 0:
            n = DSP_SetCoeff_MasterConfig(p);
            break;
        case 1:
            s = (unsigned char *)*(unsigned long *)(ram_41356 + (int)p[1] * 287);
            s += (unsigned int)p[2];
            DSP_ParamWrite_BlockCopy(p[3], s, &ram_451fe[0]);
            if (p[2] == 93) {
                ram_451fe[0] &= ~0x80;
                q = &ram_451fe[0];
                *q |= (*(unsigned int *)(ram_4135a + p[1] * 0x11f) & 0x4000) ? 0x80 : 0;
            }
            n = p[3];
            break;
        case 2:
            switch (p[2] & 0x80) {
            case 0:
                s = *(unsigned char **)(ram_413be + p[1] * 0x11f);
                break;
            case 0x80:
                s = *(unsigned char **)(ram_413e3 + p[1] * 0x11f);
                break;
            }
            s += (unsigned int)(p[2] & 0x7f);
            DSP_ParamWrite_BlockCopy(p[3], s, &ram_451fe[0]);
            n = p[3];
            break;
        case 3:
            switch (p[2] & 0x80) {
            case 0:
                s = *(unsigned char **)(ram_41408 + p[1] * 0x11f);
                break;
            case 0x80:
                s = *(unsigned char **)(ram_4142d + p[1] * 0x11f);
                break;
            }
            s += (unsigned int)(p[2] & 0x7f);
            DSP_ParamWrite_BlockCopy(p[3], s, &ram_451fe[0]);
            n = p[3];
            break;
        case 4:
            switch (p[2] & 0xc0) {
            case 0:
                s = *(unsigned char **)(ram_413c2 + p[1] * 0x11f);
                break;
            case 0x40:
                s = *(unsigned char **)(ram_413e7 + p[1] * 0x11f);
                break;
            case 0x80:
                s = *(unsigned char **)(ram_4140c + p[1] * 0x11f);
                break;
            case 0xc0:
                s = *(unsigned char **)(ram_41431 + p[1] * 0x11f);
                break;
            }
            s += (unsigned int)(p[2] & 0x3f);
            DSP_ParamWrite_BlockCopy(p[3], s, &ram_451fe[0]);
            n = p[3];
            break;
        case 5:
            s = (unsigned char *)*(unsigned long *)(ram_41356 + (int)p[1] * 287);
            s += (unsigned int)p[2];
            DSP_ParamWrite_BlockCopy(p[3], s, &ram_451fe[0]);
            n = p[3];
            break;
        case 6:
            s = (unsigned char *)(unsigned long)ToneDB_Find_SubToneRecord(
                    (unsigned char *)*(unsigned long *)(ram_41356 + (int)p[1] * 287), ram_45304[29351], p[1]);
            s += (unsigned int)p[2];
            DSP_ParamWrite_BlockCopy(p[3], s, &ram_451fe[0]);
            n = p[3];
            break;
        case 7:
            q = ToneDB_Find_SubToneRecord((unsigned char *)*(unsigned long *)(ram_41356 + (int)p[1] * 287),
                                          ram_45304[29351], p[1]);
            k = (p[2] & 0xc0) >> 6;
            q += (int)k * 21 + 16;
            s = (unsigned char *)(unsigned long)WaveSel_StageA1_FromToneSlot(k, q, ram_45304[29351], p[1]);
            s += (unsigned int)(p[2] & 0x3f);
            DSP_ParamWrite_BlockCopy(p[3], s, &ram_451fe[0]);
            n = p[3];
            break;
        }
        for (i = 0; i < 6; i++)
            ram_451f8[i] = *(unsigned char *)((unsigned long)p + i);
        InterCPU_DMA_Send(p[4], n + 6, &ram_451f8[0]);
    }
}
