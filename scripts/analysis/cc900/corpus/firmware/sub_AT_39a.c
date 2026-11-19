/* lane_sub helper AT, round 39, form a (KN5000 sub-CPU payload v1.42): Voice_ParamFinalize, never compiled before.
   One function from Voice_ParamFinalize to DSP_WriteVoiceParam (span_refs.py with both case tables: all 33 inner
   labels inner-only), 1,016 B: the 6-byte packet's status bit 3 picks one of two jump-table switches on status & 7.
   - c = status & 7 is computed once before the bit-3 test (the ROM's `and a,7` precedes `bit 3,(xiz)`): an unsigned
     char local, promoted at each switch.
   - Two case tables.  V4.23 emits a function's jump tables in reverse code order (HDAE5000_LyricBoxProc: the later
     switch's CaseTable2 is data object 1, at the lower address), so object 1 is the query table (0xFB1E) and object
     2 the action table (0xFB2E), which matches their addresses.
   - Actions (bit 3 set): calls, then out with no reply.  Two of them hold a byte switch on p[2] & 0x80 (compares in
     reverse source order: case 0 first in the source).
   - Queries (bit 3 clear): each case copies p[3] bytes into the reply payload (ram_45216) and sets n = p[3] (the ROM
     loads p[3] straight into L after the copy); the copy's source is the call's second argument written inline
     (V4.23 evaluates it first, as in DSP_WriteVoiceParam's ROM); cases 2-4 pick the source pointer in a byte switch
     into a local s.  Case 1's fixup: `ram_45216[0] |= cond ? 0x80 : 0` (address first, the 0 arm preloaded, as in the
     built DSP_VoiceParamReadWrite's ternary).  Case 7: q (the record) and k (the slot) are locals.
   - Tail: copy the 6 request bytes to ram_45210, then InterCPU_DMA_Send(p[4], n + 6, &ram_45210[0]).
   Callees through calr on the module line; ToneDB_Find_SubToneRecord, WaveSel_StageA1_FromToneSlot and
   InterCPU_DMA_Send are absolute calls (not on it).
   cc900-options: -Xr
*/

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
void Voice_ParamFinalize(unsigned char *p);

/* cc900-module: Voice_ParamFinalize Audio_Cmd_ToneEdit_Dispatch VoiceAlloc_CheckAndInit Audio_Cmd_EffectParam_Dispatch Audio_Cmd_DSPUnit_Param Audio_Cmd_DSPGlobal_Param_Store Audio_Cmd_PatchByte_Write_And_Echo Audio_Cmd_ToneEdit_Write_And_Reply Audio_Cmd_ToneEdit_Field_Write_And_Reply DSP_SetCoeff_MasterConfig DSP_ParamWrite_BlockCopy */
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
            DSP_ParamWrite_BlockCopy(p[3], *(unsigned char **)(ram_4136e + p[1] * 0x11f) + p[2], &ram_45216[0]);
            if (p[2] == 93) {
                ram_45216[0] &= ~0x80;
                ram_45216[0] |= (*(unsigned int *)(ram_41372 + p[1] * 0x11f) & 0x4000) ? 0x80 : 0;
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
            DSP_ParamWrite_BlockCopy(p[3], s + (p[2] & 0x7f), &ram_45216[0]);
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
            DSP_ParamWrite_BlockCopy(p[3], s + (p[2] & 0x7f), &ram_45216[0]);
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
            DSP_ParamWrite_BlockCopy(p[3], s + (p[2] & 0x3f), &ram_45216[0]);
            n = p[3];
            break;
        case 5:
            DSP_ParamWrite_BlockCopy(p[3], *(unsigned char **)(ram_4136e + p[1] * 0x11f) + p[2], &ram_45216[0]);
            n = p[3];
            break;
        case 6:
            DSP_ParamWrite_BlockCopy(p[3], ToneDB_Find_SubToneRecord(*(unsigned char **)(ram_4136e + p[1] * 0x11f),
                                     ram_4531c[29351], p[1]) + p[2], &ram_45216[0]);
            n = p[3];
            break;
        case 7:
            q = ToneDB_Find_SubToneRecord(*(unsigned char **)(ram_4136e + p[1] * 0x11f), ram_4531c[29351], p[1]);
            k = (p[2] & 0xc0) >> 6;
            q += (int)k * 21 + 16;
            DSP_ParamWrite_BlockCopy(p[3], WaveSel_StageA1_FromToneSlot(k, q, ram_4531c[29351], p[1]) + (p[2] & 0x3f),
                                     &ram_45216[0]);
            n = p[3];
            break;
        }
        for (i = 0; i < 6; i++)
            ram_45210[i] = p[i];
        InterCPU_DMA_Send(p[4], n + 6, &ram_45210[0]);
    }
}
