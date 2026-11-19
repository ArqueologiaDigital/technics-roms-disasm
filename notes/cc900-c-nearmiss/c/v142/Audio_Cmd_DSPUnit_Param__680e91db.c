/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_AL_25c.c (2026-11-19-27-sub-r25a)
   sha256 680e91dbe4d3bb7869ab1f88857f50f8ea86aeaac3846bd3459c9b40b2ef9bd0 (name+funcs); compiled at -Xr */
/* sub_AL_25c.c, form c.  Changes from form a: shadow stores as `*(idx + (char *)base)`; EffectParam with
   `default: break;` first and NO 0..16 group; DSPUnit with `default: break;` first (before the break-only group);
   the reply address `(unsigned char *)(unsigned long)0x1e0000 + (int)off`; EnvTranspose's lo `register unsigned
   int`; VelSplitPtr path 1 as `*(unsigned char **)((row + term) + 4)`.  Form a's head follows.

   sub_AL_25a.c -- lane_sub helper AL, round 25, form a.  From run 2026-11-19-24-sub-r24a (idiff_full.py):
   - shadow stores (EffectParam, DSPUnit): every round-24 spelling computed the index before the base; the ROM
     loads the base first (XWA -> XBC copy, which 24b's `(unsigned char *)(unsigned long)` gave) and then indexes:
     operands swapped, `*(idx + (unsigned char *)(unsigned long)base)`.
   - Audio_Cmd_EffectParam_Dispatch (24c +361): `case 0..16: return;` left the dead jump at the table base, but its
     range test then targets that body; the ROM's goes straight to the exit.  Here an explicit `default: break;`
     FIRST (its body the kept jump, its references threaded) and the 0..16 group back to `break;`.
   - Audio_Cmd_DSPUnit_Param (24a/24b +9): the first break-only group gave the ROM's table exactly; the ROM adds
     gap range checks (0x4c / 0x39 / 0x25 / 0x18 / 0x16 / 7) before it: an explicit `default: break;` (last here).
   - Audio_Cmd_ToneEdit_Write_And_Reply (24b +224, all before it matches with 24b's patch read): only the reply
     address; the ROM loads 0x1e0000 into XDE and 58 into BC first: `&((unsigned char *)0x1e0000)[(int)(unsigned
     int)off]` (the matched `&ram_44fce[(int)(unsigned int)...]` shape on a constant base).
   - EnvTranspose_UpdateLoop (24b +62): 24b's declaration order rec, t, k gave the ROM's frame and 24a's
     `(unsigned char)k[p]` stores the ROM's value-first stores: both here; `k[0] == k[1]` (V4.23 loaded the right
     operand first); the ROM copies lo to WA before `cp wa,0x40`: lo unsigned, compared as `(int)lo`.
   - WaveSel_Cache_VelSplitPtr (24c +30): path 1 now spelled exactly as the matched path 0 (the address computed
     before the value may give the ROM's exts / add into XDE).
   Round 24's form-a head follows (partly superseded by the list above).

   sub_AL_24a.c -- lane_sub helper AL, round 24, form a (KN5000 sub-CPU payload v1.42; core/08 and core/10).
   Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address).  No __IZ / __XIZ, no inline assembly.
   Each function starts from its best round-23 form (run 2026-11-19-11-sub-r23h-helpers; differences read with
   helper-generators/idiff.py).  Voice_Part_SetStateAndReinit matched there and is not repeated.

   - Audio_Cmd_EffectParam_Dispatch (from sub_AL_23b, +44): 23b's `(unsigned char *)(*(char **)P + K)` gave the
     ROM's XWA -> XBC -> XDE copy in the later AudioChannel_Dispatch cases (Grp0's `P + 20` is right).  Fixed:
     V4.23 numbers the data objects second switch's map 1, its table 2, the first switch's table 3 (23b's tables
     landed on each other's labels).  23a's `case 0 .. 16: break;` group gave the ROM's `cp a,16 / cp a,0` test but
     no dead jump at the table base: here that group's body is `return;` (a jump that stays as code, its table
     entries threaded to the exit).  The shadow store: every spelling of round 23 indexed the store
     (`ld (xde+bc),a`, index first); the ROM loads the base into XWA, copies it to XBC, then `lda xbc,(xbc+wa)` and
     stores through (XBC): a pointer conversion, `((char *)&ram_44fce[0])[m[2]]`.
   - Audio_Cmd_ToneEdit_Write_And_Reply (from sub_AL_23c, +14): the patch pointer must be loaded at once into XHL
     (ours deferred it to `(xix+hl)` at the call): `(unsigned char *)*(char **)(...)` (a conversion); the store
     index `(unsigned long)(unsigned int)m[2]` (ROM extz wa, extz xwa; `(unsigned long)` alone gave `ld xwa,0`);
     the reply loads 0x1e0000 into XDE and 58 into BC before the offset: the constant pointer through a comma,
     `(0, (unsigned char *)0x1e0000) + (...)` (lane_hd's comma idiom).
   - Audio_Cmd_DSPUnit_Param (from sub_AL_23b/c, +9): V4.23 gave a compare chain, the ROM a two-level table over
     0..6 and 0x26..0x38 (map entries 1 = exit): read as a FIRST break-only case group holding the in-table
     values that go to the exit (0, 4, 0x27..0x2c, 0x2e..0x35, 0x37), so the clusters are dense; 0x4d..0x50 in
     descending source order (23b: gives the ROM's ascending compares); shadow row through `(char *)`.
   - WaveSel_Cache_VelSplitPtr (from sub_AL_23c, +30; its path 0 matched): path 1 keeps the slot term as a plain
     int (computed in DE, the ROM's `ld de,wa; add de,0x6e`) and adds it to the row as an unsigned long (exts at
     the add): `(unsigned char *)((unsigned long)row + ((int)slot * 37 + 0x6e))`, +4 a displacement.
   - EnvTranspose_UpdateLoop: new (never compiled); see its own comment.  Not taken: WaveSel_StageA1_FindVelSplit,
     DSP_SetCoeff_FullPipeline (time).

   cc900-options: -Xr
*/

extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_41376[];
extern unsigned char ram_413ce[];
extern unsigned char ram_44fce[];
extern unsigned char *ram_4531c;

extern int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);
extern void Partial_Build_Present_Word(int);
void EnvTranspose_UpdateLoop(unsigned char part);
unsigned int Partial_GetBaseKey(unsigned char part, unsigned char partial);
int SignedClamp_Zero(int a);
extern void AlgoType_StateWrite(int, int);
extern void VoiceNoteParam_UpdateLoop(int);
extern void Voice_ActiveFlag_CheckAndLoad(int);
extern unsigned char Voice_SecondaryParam_Epilogue(int);
void VoiceAlloc_Apply_Algo_Group0(unsigned char part, unsigned char slot);
void VoiceAlloc_Apply_Algo_Group1(unsigned char part, unsigned char slot);
void VoiceAlloc_Apply_Algo_Group2(unsigned char part, unsigned char slot);
void DSP_EffParam_Apply_By_AlgoType(unsigned char part);
void Voice_DSPOut_Apply_A(unsigned char part);
void Voice_DSPOut_Apply_B(unsigned char part);
void Voice_DSPOut_Second_A(unsigned char part);
void Voice_DSPOut_Second_B(unsigned char part);
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern void InterCPU_E1_DMA_Transfer(unsigned char *d, unsigned int n, unsigned char *s);
extern unsigned char *Voice_Query_PartVoices(int part);
extern unsigned char *Voice_AllocateForSustain(int part);
extern void Voice_AllNotes_SustainRetrigger(unsigned char *list, unsigned char flag);
extern void AudioChannel_AllVoices_UpdVar3(unsigned char *list);
void DSP_SlotParam_Write_From_Cache_B(unsigned char slot);
void DSP_SlotParam_Read_To_Cache_B(unsigned char part, unsigned char slot);
void DSP_SlotParam_Write_From_Cache(unsigned char part, unsigned char slot);
void DSP_SlotParam_Read_To_Cache(unsigned char part, unsigned char slot);
extern void Pitch_Refresh_Sounding_Voices(unsigned char *list);
extern void Voice_AllVoices_WriteAmplitude(unsigned char *list);
extern void AlgoFlag_Write(int, int, int);
extern void AlgoFlag_Write_Bit3(int, int, int);
void EFF_RoutingInit(unsigned char part, unsigned char slot, unsigned char grp);
extern void WaveSel_Cache_SetDescPtr(unsigned char a, unsigned char c, unsigned char e);
unsigned char *WaveSel_StageA1_FromPatchBlock(unsigned char part, unsigned char slot);
void WaveSel_Cache_VelSplitPtr(unsigned char part, unsigned char slot);

#define PART_PATCH(p)   (*(unsigned char **)(ram_4136e + (p) * 287))
#define PCONV(p, k)     ((unsigned char *)(*(char **)(ram_4136e + (p) * 287) + (k)))
#define SHADOW_STORE(m) (*((m)[2] + (char *)ram_44fce) = (m)[4])
#define UNIT_STORE(m, u) (*(((m)[2] & 0x7f) + (char *)&ram_44fce[(int)(unsigned int)((int)(u) * 0x51 + 0x66)]) = (m)[4])
#define DMA_DEST(off)   ((unsigned char *)(unsigned long)0x1e0000 + (int)(off))

/* cc900-name: AudioChannel_AllVoices_UpdVar3=AudioChannel_AllVoices_Update_Variant3 */
/* cc900-module: VoiceAlloc_Apply_Algo_Group0 VoiceAlloc_Apply_Algo_Group1 VoiceAlloc_Apply_Algo_Group2 DSP_EffParam_Apply_By_AlgoType Voice_DSPOut_Apply_A Voice_DSPOut_Apply_B Voice_DSPOut_Second_A Voice_DSPOut_Second_B */
/* cc900-module: DSP_SlotParam_Write_From_Cache_B DSP_SlotParam_Read_To_Cache_B DSP_SlotParam_Write_From_Cache DSP_SlotParam_Read_To_Cache */
/* cc900-module: WaveSel_StageA1_FromPatchBlock */
/* cc900-data: Audio_Cmd_EffectParam_Dispatch 1 = AUDIO_CMD_EFFPARAM_CASEMAP */
/* cc900-data: Audio_Cmd_EffectParam_Dispatch 2 = AUDIO_CMD_EFFPARAM_JUMPTABLE */
/* cc900-data: Audio_Cmd_EffectParam_Dispatch 3 = AUDIO_CMD_EFFECTPARAM_JUMPTABLE */
/* cc900-data: Audio_Cmd_ToneEdit_Write_And_Reply 1 = AUDIO_CMD_TONEEDIT_REPLY_CASEMAP */
/* cc900-data: Audio_Cmd_ToneEdit_Write_And_Reply 2 = AUDIO_CMD_TONEEDIT_REPLY_JUMPTABLE */
/* cc900-data: Audio_Cmd_DSPUnit_Param 1 = AUDIO_CMD_DSPUNIT_CASEMAP */
/* cc900-data: Audio_Cmd_DSPUnit_Param 2 = AUDIO_CMD_DSPUNIT_JUMPTABLE */

void Audio_Cmd_EffectParam_Dispatch(unsigned char *m)
{
    unsigned char part;

    part = m[1];
    switch (m[2]) {
    case 0x15:
        AudioChannel_Dispatch(part, 0, PART_PATCH(part) + 20);
        break;
    case 0x18:
        AudioChannel_Dispatch(part, 0, PCONV(part, 23));
        break;
    case 0x1b:
        AudioChannel_Dispatch(part, 0, PCONV(part, 26));
        break;
    case 0x1e:
        AudioChannel_Dispatch(part, 0, PCONV(part, 29));
        break;
    case 0x21:
        AudioChannel_Dispatch(part, 0, PCONV(part, 32));
        break;
    case 0x24:
        AudioChannel_Dispatch(part, 0, PCONV(part, 35));
        break;
    case 0x27:
        AudioChannel_Dispatch(part, 0, PCONV(part, 38));
        break;
    }
    SHADOW_STORE(m);
    switch (m[2]) {
    default:
        break;
    case 0x11:
        Partial_Build_Present_Word(m[1]);
        EnvTranspose_UpdateLoop(m[1]);
        break;
    case 0x12:
        Partial_Build_Present_Word(m[1]);
        break;
    case 0x14:
        AudioChannel_Dispatch(part, 0, PCONV(part, 29));
        break;
    case 0x17:
        AudioChannel_Dispatch(part, 0, PCONV(part, 23));
        break;
    case 0x1a:
        AudioChannel_Dispatch(part, 0, PCONV(part, 26));
        break;
    case 0x1d:
        AudioChannel_Dispatch(part, 0, PCONV(part, 29));
        break;
    case 0x20:
        AudioChannel_Dispatch(part, 0, PCONV(part, 32));
        break;
    case 0x23:
        AudioChannel_Dispatch(part, 0, PCONV(part, 35));
        break;
    case 0x26:
        AudioChannel_Dispatch(part, 0, PCONV(part, 38));
        break;
    case 0x2b: case 0x2c: case 0x2d: case 0x2e:
        VoiceAlloc_Apply_Algo_Group0(m[1], 0);
        break;
    case 0x2f: case 0x30: case 0x31: case 0x32:
        VoiceAlloc_Apply_Algo_Group0(m[1], 1);
        break;
    case 0x33: case 0x34: case 0x35: case 0x36:
        VoiceAlloc_Apply_Algo_Group0(m[1], 2);
        break;
    case 0x37: case 0x38: case 0x39: case 0x3a:
        VoiceAlloc_Apply_Algo_Group0(m[1], 3);
        break;
    case 0x3b: case 0x3c: case 0x3d: case 0x3e:
        VoiceAlloc_Apply_Algo_Group1(m[1], 0);
        break;
    case 0x3f: case 0x40: case 0x41: case 0x42:
        VoiceAlloc_Apply_Algo_Group1(m[1], 1);
        break;
    case 0x43: case 0x44: case 0x45: case 0x46:
        VoiceAlloc_Apply_Algo_Group1(m[1], 2);
        break;
    case 0x47: case 0x48: case 0x49: case 0x4a:
        VoiceAlloc_Apply_Algo_Group1(m[1], 3);
        break;
    case 0x4b: case 0x4c: case 0x4d: case 0x4e:
        VoiceAlloc_Apply_Algo_Group2(m[1], 0);
        break;
    case 0x4f: case 0x50: case 0x51: case 0x52:
        VoiceAlloc_Apply_Algo_Group2(m[1], 1);
        break;
    case 0x53: case 0x54: case 0x55: case 0x56:
        VoiceAlloc_Apply_Algo_Group2(m[1], 2);
        break;
    case 0x57: case 0x58: case 0x59: case 0x5a:
        VoiceAlloc_Apply_Algo_Group2(m[1], 3);
        break;
    case 0x5d:
        if (m[5] == 15) {
            DSP_EffParam_Apply_By_AlgoType(m[1]);
            AlgoType_StateWrite(m[1], 0);
            Partial_Build_Present_Word(m[1]);
            EnvTranspose_UpdateLoop(m[1]);
            VoiceNoteParam_UpdateLoop(m[1]);
            Voice_DSPOut_Apply_A(m[1]);
            Voice_DSPOut_Apply_B(m[1]);
            Voice_DSPOut_Second_A(m[1]);
            Voice_DSPOut_Second_B(m[1]);
            Voice_ActiveFlag_CheckAndLoad(m[1]);
            ram_413ce[m[1] * 287] = Voice_SecondaryParam_Epilogue(m[1]);
        } else {
            Partial_Build_Present_Word(m[1]);
            EnvTranspose_UpdateLoop(m[1]);
        }
        break;
    case 0x5e:
        Voice_DSPOut_Apply_A(m[1]);
        break;
    case 0x5f:
        Voice_DSPOut_Apply_B(m[1]);
        VoiceNoteParam_UpdateLoop(m[1]);
        break;
    case 0x60:
        Voice_DSPOut_Second_A(m[1]);
        VoiceNoteParam_UpdateLoop(m[1]);
        break;
    case 0x61:
        Voice_DSPOut_Second_B(m[1]);
        VoiceNoteParam_UpdateLoop(m[1]);
        break;
    case 0x62:
        VoiceNoteParam_UpdateLoop(m[1]);
        break;
    case 0x63:
        VoiceNoteParam_UpdateLoop(m[1]);
        break;
    case 0x64:
        Voice_ActiveFlag_CheckAndLoad(m[1]);
        break;
    case 0x65:
        ram_413ce[m[1] * 287] = Voice_SecondaryParam_Epilogue(m[1]);
        break;
    }
}

void Audio_Cmd_ToneEdit_Write_And_Reply(register unsigned char *m)
{
    unsigned char *buf;

    buf = ToneDB_Find_SubToneRecord((unsigned char *)*(unsigned long *)(ram_4136e + (int)m[1] * 287),
                                    ram_4531c[29351], m[1]);
    buf[(unsigned long)(unsigned int)m[2]] = m[4];
    switch (m[2]) {
    case 0x19: case 0x1b: case 0x2e: case 0x30:
        AudioChannel_AllVoices_UpdVar3(Voice_Query_PartVoices(m[1]));
        break;
    case 0x1d: case 0x32:
        Voice_AllNotes_SustainRetrigger(Voice_AllocateForSustain(m[1]), 1);
        break;
    case 0x1f:
        if (m[5] == 7)
            DSP_SlotParam_Write_From_Cache_B(0);
        break;
    case 0x34:
        if (m[5] == 7)
            DSP_SlotParam_Write_From_Cache_B(1);
        break;
    case 0x21: case 0x22: case 0x23: case 0x24:
        DSP_SlotParam_Read_To_Cache_B(m[1], 0);
    case 0x36: case 0x37: case 0x38: case 0x39:
        DSP_SlotParam_Read_To_Cache_B(m[1], 1);
        break;
    }
    InterCPU_E1_DMA_Transfer(buf, 58, DMA_DEST((int)ram_4531c[29351] * 80 + 19111));
}

void Audio_Cmd_DSPUnit_Param(unsigned char *m, unsigned char unit)
{
    unsigned int i;

    UNIT_STORE(m, unit);
    switch (m[2] & 0x7f) {
    default:
        break;
    case 0: case 4:
    case 0x27: case 0x28: case 0x29: case 0x2a: case 0x2b: case 0x2c:
    case 0x2e: case 0x2f: case 0x30: case 0x31: case 0x32: case 0x33: case 0x34: case 0x35:
    case 0x37:
        break;
    case 1:
        EnvTranspose_UpdateLoop(m[1]);
        break;
    case 2: case 3:
        WaveSel_Cache_VelSplitPtr(m[1], unit);
        for (i = 0; i < 4; i++)
            WaveSel_Cache_SetDescPtr(m[1], unit, (unsigned char)i);
        break;
    case 5:
        Pitch_Refresh_Sounding_Voices(Voice_Query_PartVoices(m[1]));
        break;
    case 6:
        for (i = 0; i < 4; i++) {
            AlgoFlag_Write_Bit3(m[1], 0, (unsigned char)i);
            AlgoFlag_Write(m[1], 0, (unsigned char)i);
        }
        EFF_RoutingInit(m[1], unit, 0);
        break;
    case 0x17:
        Voice_AllVoices_WriteAmplitude(Voice_Query_PartVoices(m[1]));
        break;
    case 0x26:
        for (i = 0; i < 4; i++) {
            AlgoFlag_Write_Bit3(m[1], 1, (unsigned char)i);
            AlgoFlag_Write(m[1], 1, (unsigned char)i);
        }
        EFF_RoutingInit(m[1], unit, 1);
        break;
    case 0x2d:
        Voice_AllNotes_SustainRetrigger(Voice_AllocateForSustain(m[1]), 1);
        break;
    case 0x36:
        if (m[5] == 7)
            DSP_SlotParam_Write_From_Cache(m[1], unit);
        break;
    case 0x38:
        for (i = 0; i < 4; i++) {
            AlgoFlag_Write_Bit3(m[1], 2, (unsigned char)i);
            AlgoFlag_Write(m[1], 2, (unsigned char)i);
        }
        EFF_RoutingInit(m[1], unit, 2);
        break;
    case 0x50: case 0x4f: case 0x4e: case 0x4d:
        DSP_SlotParam_Read_To_Cache(m[1], unit);
        break;
    }
}

/* EnvTranspose_UpdateLoop (new, 439 B): frame keys[4] at +10, t at +8, rec at +4, part spilled at +18; the
   partial counter p in QIZH and reused for the patch byte +0x5d (the ROM stores that byte into QIZH too); lo in
   IZ; the clamp result hi used from HL.  The bit-15 test as `& 0x8000L` (extz xwa, as in Partial_GetBaseKey). */
/* cc900-module: Partial_GetBaseKey SignedClamp_Zero */
void EnvTranspose_UpdateLoop(unsigned char part)
{
    unsigned char *rec;
    int t;
    int k[4];
    unsigned char p;
    register unsigned int lo;
    int hi;

    rec = (unsigned char *)(unsigned long)(ram_41368 + part * 0x11f);
    t = (signed char)(ram_41376[part * 0x11f] - 0x40);
    for (p = 0; p < 4; p++) {
        if ((k[p] = Partial_GetBaseKey(part, p)) != 0x80)
            k[p] = SignedClamp_Zero(k[p] + t);
        ((unsigned char *)(unsigned long)(rec + ((int)p * 37 + 0x6e)))[35] = (unsigned char)k[p];
        ((unsigned char *)(unsigned long)(rec + ((int)p * 37 + 0x6e)))[36] = (unsigned char)k[p];
    }
    p = (*(unsigned char **)(ram_4136e + part * 0x11f))[93];
    if ((*(unsigned int *)(rec + 10) & 0x8000L) && (p & 0x40) && k[0] == k[1] && k[0] != 0x80) {
        lo = k[0];
        if ((int)lo < 0x40) {
            lo = SignedClamp_Zero(lo - 0x10);
            hi = SignedClamp_Zero(lo + 0x28);
        } else {
            lo = SignedClamp_Zero(lo + 0x10);
            hi = SignedClamp_Zero(lo - 0x28);
        }
        if ((p & 0xf) == 9) {
            rec[145] = lo;
            rec[182] = lo;
            rec[146] = hi;
            rec[183] = hi;
        } else if ((p & 0xf) < 10) {
            rec[145] = lo;
            rec[182] = hi;
        }
    }
}

void WaveSel_Cache_VelSplitPtr(unsigned char part, unsigned char slot)
{
    if (*(unsigned int *)&ram_41368[part * 0x11f] & 1) {
        *(unsigned char **)(((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f) + ((int)slot * 37 + 0x6e)) + 4) =
            &ram_44fce[(int)(unsigned int)((int)slot * 11 + 0x1aa)];
    } else {
        *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f)
                                                              + ((int)slot * 37 + 0x6e)))[4] =
            WaveSel_StageA1_FromPatchBlock(part, slot);
    }
}
