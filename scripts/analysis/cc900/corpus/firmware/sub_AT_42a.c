/* lane_sub helper AT, round 42 (KN5000 sub-CPU payload v1.42): Voice_ParamFinalize, from sub_AT_41a.c (run
   2026-11-19-91-sub-r41t; idiff_full.py over 41a/b/c):
   - the offsets now come after the pointer in every case (round 41's split statements did that), and 41a/41b's
     fixup through q gives the ROM's `lda xhl,0x45216` (41c's conversion did not): 41a is the base.
   - but the register allocation moved away from 40a's (which was the ROM's): c went to C (ROM: A), s to XHL (ROM:
     XBC, sharing XHL with q), n to WA (ROM: HL), so every query case and the tail differ.  40a to 41c changed only the
     split statements; cases 1 and 5 now read like cases 2-4 (which coexisted with the right allocation in 40a), so
     the suspects are cases 6 and 7's new `s = call(...)`: s assigned straight from a call result (XHL) seems to make
     V4.23 give s XHL.  The ROM copies the result to XBC (`ld xbc,xhl`) before adding the offset.
   FORM a's one change: cases 6 and 7 keep the call's result in q (already XHL) and set `s = q + (unsigned int)...`
   (s is never assigned straight from a call).
   Round 41's notes follow.
   Round 41 (KN5000 sub-CPU payload v1.42): Voice_ParamFinalize, from sub_AT_40a.c (run
   2026-11-19-88-sub-r40t; idiff_full.py over 40a/b/c):
   - 40a's copy loop `*(unsigned char *)((unsigned long)p + i)` matches the ROM (40c's spelling did not): kept.
   - `s += (unsigned int)(p[2] & 0x7f)` after s holds the pointer (cases 2-4) matches; a pointer plus
     `(unsigned int)p[2]` in ONE expression (cases 1, 5, 6, 7) computed the offset first into DE.  Common change of
     round 41: every query case assigns s first and adds the offset in a second statement (the pointer loads
     themselves already matched in 40 and keep their spelling; cases 6 and 7 assign s the call's result).
   - the Find argument spelled as in DSP_SetCoeff_FullPipeline now matches: kept.
   - case 1's fixup: 39/40a `ram_45216[0] |=` builds the address in XWA and copies it to XHL, 40b `*ram_45216 |=`
     uses the direct operand `or (0x45216),e`; the ROM builds it straight in XHL.  Each form tries one spelling.
   FORM a's one change: the fixup through the pointer local q (XHL in case 7), `q = &ram_45216[0]; *q |= ...`.
   Round 40's notes follow.
   Changes common to forms a, b and c of round 40 (each answers a difference idiff_full.py showed in 39b):
   - every byte offset added to a pointer is cast `(unsigned int)`: 39b's int offsets gave the 16-bit indexed
     `lda xbc,xbc+wa`, the ROM zero-extends to 32 bits and adds (`extz xwa; add xbc,xwa`), as for DSP_WriteVoiceParam's
     unsigned int offset;
   - the part's patch pointer is read as `(unsigned char *)*(unsigned long *)(ram_4136e + (int)p[1] * 287)` (the
     spelling of the built DSP_SetCoeff_FullPipeline, whose ROM loads it into XHL first, then `ld xwa,xhl`; 39b's
     `*(unsigned char **)` loaded it last, straight into XWA through an XIX + HL index).
   FORM a's one change: the 6-byte copy's source as `*(unsigned char *)((unsigned long)p + i)`.  39b evaluated the
   destination first (i in DE, `ld xbc,0x45210` then `add xwa,xiz`); the ROM evaluates the source first
   (`ld xbc,xiz; add xbc,xwa`, p copied as the sum's left operand), the destination into XDE, i in IX.
   39's description (still true) follows.  Round 39: Voice_ParamFinalize, never compiled before.
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
            s = (unsigned char *)*(unsigned long *)(ram_4136e + (int)p[1] * 287);
            s += (unsigned int)p[2];
            DSP_ParamWrite_BlockCopy(p[3], s, &ram_45216[0]);
            if (p[2] == 93) {
                ram_45216[0] &= ~0x80;
                q = &ram_45216[0];
                *q |= (*(unsigned int *)(ram_41372 + p[1] * 0x11f) & 0x4000) ? 0x80 : 0;
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
            q = ToneDB_Find_SubToneRecord((unsigned char *)*(unsigned long *)(ram_4136e + (int)p[1] * 287),
                                          ram_4531c[29351], p[1]);
            s = q + (unsigned int)p[2];
            DSP_ParamWrite_BlockCopy(p[3], s, &ram_45216[0]);
            n = p[3];
            break;
        case 7:
            q = ToneDB_Find_SubToneRecord((unsigned char *)*(unsigned long *)(ram_4136e + (int)p[1] * 287),
                                          ram_4531c[29351], p[1]);
            k = (p[2] & 0xc0) >> 6;
            q += (int)k * 21 + 16;
            q = WaveSel_StageA1_FromToneSlot(k, q, ram_4531c[29351], p[1]);
            s = q + (unsigned int)(p[2] & 0x3f);
            DSP_ParamWrite_BlockCopy(p[3], s, &ram_45216[0]);
            n = p[3];
            break;
        }
        for (i = 0; i < 6; i++)
            ram_45210[i] = *(unsigned char *)((unsigned long)p + i);
        InterCPU_DMA_Send(p[4], n + 6, &ram_45210[0]);
    }
}
