/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AT_41c.c (2026-11-19-91-sub-r41t)
   sha256 c3832ef3e259099a9d034a3657a5948804d82102b4d24507c9b7767f9c5bb1df (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4136e[];
extern unsigned char ram_41372[];
extern unsigned char ram_413d6[];
extern unsigned char ram_413da[];
extern unsigned char ram_413fb[];
extern unsigned char ram_413ff[];
extern unsigned char ram_41420[];
extern unsigned char ram_41424[];
extern unsigned char ram_41445[];
extern unsigned char ram_41449[];
extern unsigned char ram_45210[];
extern unsigned char ram_45216[];
extern unsigned char *ram_4531c;
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
            s = (unsigned char *)*(unsigned long *)(ram_4136e + (int)p[1] * 287);
            s += (unsigned int)p[2];
            DSP_ParamWrite_BlockCopy(p[3], s, &ram_45216[0]);
            if (p[2] == 93) {
                ram_45216[0] &= ~0x80;
                *(unsigned char *)(unsigned long)&ram_45216[0] |= (*(unsigned int *)(ram_41372 + p[1] * 0x11f) & 0x4000) ? 0x80 : 0;
            }
            n = p[3];
            break;
        case 2:
            switch (p[2] & 0x80) {
            case 0:
                s = *(unsigned char **)(ram_413d6 + p[1] * 0x11f);
                break;
            case 0x80:
                s = *(unsigned char **)(ram_413fb + p[1] * 0x11f);
                break;
            }
            s += (unsigned int)(p[2] & 0x7f);
            DSP_ParamWrite_BlockCopy(p[3], s, &ram_45216[0]);
            n = p[3];
            break;
        case 3:
            switch (p[2] & 0x80) {
            case 0:
                s = *(unsigned char **)(ram_41420 + p[1] * 0x11f);
                break;
            case 0x80:
                s = *(unsigned char **)(ram_41445 + p[1] * 0x11f);
                break;
            }
            s += (unsigned int)(p[2] & 0x7f);
            DSP_ParamWrite_BlockCopy(p[3], s, &ram_45216[0]);
            n = p[3];
            break;
        case 4:
            switch (p[2] & 0xc0) {
            case 0:
                s = *(unsigned char **)(ram_413da + p[1] * 0x11f);
                break;
            case 0x40:
                s = *(unsigned char **)(ram_413ff + p[1] * 0x11f);
                break;
            case 0x80:
                s = *(unsigned char **)(ram_41424 + p[1] * 0x11f);
                break;
            case 0xc0:
                s = *(unsigned char **)(ram_41449 + p[1] * 0x11f);
                break;
            }
            s += (unsigned int)(p[2] & 0x3f);
            DSP_ParamWrite_BlockCopy(p[3], s, &ram_45216[0]);
            n = p[3];
            break;
        case 5:
            s = (unsigned char *)*(unsigned long *)(ram_4136e + (int)p[1] * 287);
            s += (unsigned int)p[2];
            DSP_ParamWrite_BlockCopy(p[3], s, &ram_45216[0]);
            n = p[3];
            break;
        case 6:
            s = ToneDB_Find_SubToneRecord((unsigned char *)*(unsigned long *)(ram_4136e + (int)p[1] * 287),
                                          ram_4531c[29351], p[1]);
            s += (unsigned int)p[2];
            DSP_ParamWrite_BlockCopy(p[3], s, &ram_45216[0]);
            n = p[3];
            break;
        case 7:
            q = ToneDB_Find_SubToneRecord((unsigned char *)*(unsigned long *)(ram_4136e + (int)p[1] * 287),
                                          ram_4531c[29351], p[1]);
            k = (p[2] & 0xc0) >> 6;
            q += (int)k * 21 + 16;
            s = WaveSel_StageA1_FromToneSlot(k, q, ram_4531c[29351], p[1]);
            s += (unsigned int)(p[2] & 0x3f);
            DSP_ParamWrite_BlockCopy(p[3], s, &ram_45216[0]);
            n = p[3];
            break;
        }
        for (i = 0; i < 6; i++)
            ram_45210[i] = *(unsigned char *)((unsigned long)p + i);
        InterCPU_DMA_Send(p[4], n + 6, &ram_45210[0]);
    }
}
