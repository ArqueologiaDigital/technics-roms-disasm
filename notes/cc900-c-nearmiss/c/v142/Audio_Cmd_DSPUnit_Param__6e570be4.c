/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_AL_27a.c (2026-11-19-35-sub-r27a)
   sha256 6e570be4749fe3abe4aac172c3b059bb79e3232ab0d63f49ad98bf01851740e4 (name+funcs); compiled at -Xr */
/* Copyright (C) 1991-2025 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <https://www.gnu.org/licenses/>.  */
/* This header is separate from features.h so that the compiler can
   include it implicitly at the start of every compilation.  It must
   not itself include <features.h> or any other header that includes
   <features.h> because the implicit include comes before any feature
   test macros that may be defined in a source file before it first
   explicitly includes a system header.  GCC knows the name of this
   header in order to preinclude it.  */
/* glibc's intent is to support the IEC 559 math functionality, real
   and complex.  If the GCC (4.9 and later) predefined macros
   specifying compiler intent are available, use them to determine
   whether the overall intent is to support these features; otherwise,
   presume an older compiler has intent to support these features and
   define these macros by default.  */
/* wchar_t uses Unicode 10.0.0.  Version 10.0 of the Unicode Standard is
   synchronized with ISO/IEC 10646:2017, fifth edition, plus
   the following additions from Amendment 1 to the fifth edition:
   - 56 emoji characters
   - 285 hentaigana
   - 3 additional Zanabazar Square characters */
/* sub_AL_27a.c -- lane_sub helper AL, round 27, form a (base: sub_AL_26a; run 2026-11-19-30-sub-r26a).
   What round 26 did (idiff_full.py):
   - Audio_Cmd_DSPUnit_Param: 26a's full break-only group (every value 0..0x4c without a body) reproduced the
     ROM's whole switch (range tests and table); only the shadow store differs now (and the table base by those
     2 bytes).  26b (also 0x51..0x7f) added two range tests the ROM lacks; 26c (group last) the same as 26a.
   - Audio_Cmd_EffectParam_Dispatch: only the shadow store differs (as in round 25).  None of the address-of /
     conversion spellings of round 26 changed V4.23's order: it always loads the index first and stores
     `(xbc+de)`; the ROM computes the base (XWA, copied to XBC), then the index, `lda xbc,(xbc+wa)`, store (XBC).
   - Audio_Cmd_ToneEdit_Write_And_Reply: all three reply-address spellings gave the same code (offset widened with
     extz, 0x1e0000 as an immediate); the ROM loads 0x1e0000 into XDE and 58 into BC first, exts, add.
   - WaveSel_Cache_VelSplitPtr: 26a as 25a (lda + copy); 26b / 26c folded the +4 into the slot term.
   Round 27, form a (one change per function):
   - shadow stores through a structure cast, `((struct shd *)ram_44fce)->u[unit][idx]` / `->g[idx]`: a member
     array's row is an lvalue computed before its index (the ROM's +0x66 is then the member offset);
   - InterCPU_E1_DMA_Transfer's destination an unsigned long (a main-CPU address), `0x1e0000L + (long)off`;
   - VelSplitPtr path 1's +4 as a structure member, `((struct sdesc *)(row + term))->vsel` (idiom z).
   Round 26's head follows.

   sub_AL_26a.c -- lane_sub helper AL, round 26, form a.  From run 2026-11-19-27-sub-r25a (idiff_full.py);
   EnvTranspose_UpdateLoop matched there and is dropped here (only its prototype stays).
   - Audio_Cmd_EffectParam_Dispatch: 25a / 25b (default first, or merged with the 0..16 group) match everywhere
     except the shadow store, where V4.23 still loads the index first and stores `(xbc+de)`.  The ROM materialises
     the address (base, copy XWA -> XBC, index, `lda xbc,(xbc+wa)`) and stores through (XBC): the store through an
     address taken and converted, `*(char *)&((unsigned char *)(unsigned long)base)[idx] = v` (same in DSPUnit).
   - Audio_Cmd_DSPUnit_Param: the ROM's extra tests (0x4c, 0x39, 0x25, 0x18, 0x16, 7) are RANGE tests of runs that
     go to the exit: 7..0x16, 0x18..0x25, 0x39..0x4c.  So the break-only group lists every value 0..0x4c that has
     no body of its own (the long runs become range tests, the mixed regions the table); `default:` stays last.
   - Audio_Cmd_ToneEdit_Write_And_Reply: only the reply address differs; the ROM's sum lands in the offset's
     register (exts xwa; add xwa,xde): the int offset on the LEFT, `off + (unsigned char *)0x1e0000`.
   - WaveSel_Cache_VelSplitPtr: path 1 (25a) differs only in the last step, ROM `exts xde; add xde,xwa` (the sum
     in the term's register) where ours did `lda xwa,(xwa+de)`: the int term on the LEFT of the `+`.
   Round 25's head follows.

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
extern void InterCPU_E1_DMA_Transfer(unsigned char *d, unsigned int n, unsigned long s);
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
/* the parameter shadow at 0x44fce as a structure: per-op bytes, four 0x51-byte DSP-unit rows at +0x66, the
   11-byte global groups at +0x1aa (DSPGlobal_Param_Store) */
struct shd { unsigned char g[0x66]; unsigned char u[4][0x51]; unsigned char v[4][11]; };
/* the slot descriptor inside a part record: its VSEL pointer at +4 */
struct sdesc { unsigned char pad[4]; unsigned char *vsel; };
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
        AudioChannel_Dispatch(part, 0, (*(unsigned char **)(ram_4136e + (part) * 287)) + 20);
        break;
    case 0x18:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_4136e + (part) * 287) + (23))));
        break;
    case 0x1b:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_4136e + (part) * 287) + (26))));
        break;
    case 0x1e:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_4136e + (part) * 287) + (29))));
        break;
    case 0x21:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_4136e + (part) * 287) + (32))));
        break;
    case 0x24:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_4136e + (part) * 287) + (35))));
        break;
    case 0x27:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_4136e + (part) * 287) + (38))));
        break;
    }
    (((struct shd *)ram_44fce)->g[(m)[2]] = (m)[4]);
    switch (m[2]) {
    default:
        break;
    case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8:
    case 9: case 10: case 11: case 12: case 13: case 14: case 15: case 16:
        break;
    case 0x11:
        Partial_Build_Present_Word(m[1]);
        EnvTranspose_UpdateLoop(m[1]);
        break;
    case 0x12:
        Partial_Build_Present_Word(m[1]);
        break;
    case 0x14:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_4136e + (part) * 287) + (29))));
        break;
    case 0x17:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_4136e + (part) * 287) + (23))));
        break;
    case 0x1a:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_4136e + (part) * 287) + (26))));
        break;
    case 0x1d:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_4136e + (part) * 287) + (29))));
        break;
    case 0x20:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_4136e + (part) * 287) + (32))));
        break;
    case 0x23:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_4136e + (part) * 287) + (35))));
        break;
    case 0x26:
        AudioChannel_Dispatch(part, 0, ((unsigned char *)(*(char **)(ram_4136e + (part) * 287) + (38))));
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
    InterCPU_E1_DMA_Transfer(buf, 58, (0x1e0000L + (long)((int)ram_4531c[29351] * 80 + 19111)));
}
void Audio_Cmd_DSPUnit_Param(unsigned char *m, unsigned char unit)
{
    unsigned int i;
    (((struct shd *)ram_44fce)->u[unit][(m)[2] & 0x7f] = (m)[4]);
    switch (m[2] & 0x7f) {
    case 0x00: case 0x04: case 0x07: case 0x08: case 0x09: case 0x0a: case 0x0b: case 0x0c:
    case 0x0d: case 0x0e: case 0x0f: case 0x10: case 0x11: case 0x12: case 0x13: case 0x14:
    case 0x15: case 0x16: case 0x18: case 0x19: case 0x1a: case 0x1b: case 0x1c: case 0x1d:
    case 0x1e: case 0x1f: case 0x20: case 0x21: case 0x22: case 0x23: case 0x24: case 0x25:
    case 0x27: case 0x28: case 0x29: case 0x2a: case 0x2b: case 0x2c: case 0x2e: case 0x2f:
    case 0x30: case 0x31: case 0x32: case 0x33: case 0x34: case 0x35: case 0x37: case 0x39:
    case 0x3a: case 0x3b: case 0x3c: case 0x3d: case 0x3e: case 0x3f: case 0x40: case 0x41:
    case 0x42: case 0x43: case 0x44: case 0x45: case 0x46: case 0x47: case 0x48: case 0x49:
    case 0x4a: case 0x4b: case 0x4c:
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
    default:
        break;
    }
}
void WaveSel_Cache_VelSplitPtr(unsigned char part, unsigned char slot)
{
    if (*(unsigned int *)&ram_41368[part * 0x11f] & 1) {
        ((struct sdesc *)((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f) + ((int)slot * 37 + 0x6e)))->vsel =
            &ram_44fce[(int)(unsigned int)((int)slot * 11 + 0x1aa)];
    } else {
        *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f)
                                                              + ((int)slot * 37 + 0x6e)))[4] =
            WaveSel_StageA1_FromPatchBlock(part, slot);
    }
}
