/* lane_sub round 48 form c (gen_lane_48.py, from sub_AW_47c.c) */
/* sub_AW_47c.c, form c.  Changes from form a: ToneEdit's converted address passed straight as the argument,
   `(unsigned char *)(unsigned long)&d[(int)(unsigned int)off]` (no reassignment); Set_Tone_Option's o in two
   statements and the store with the operands swapped, `*(ram_44fce + o) = v`.  Form a's head follows.

   sub_AW_47a.c -- lane_sub helper AW, round 47, form a (KN5000 sub-CPU payload v1.42, core/08).
   Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address).  No __IZ / __XIZ, no inline assembly.

   - Audio_Cmd_ToneEdit_Write_And_Reply (one function to the end of Audio_Cmd_ToneEdit_Reply_Send; 8 inner labels,
     all inner-only).  From run 2026-11-21-1-sub-r43c (idiff_full.py on sub_AW_44a/b/c): everything matches up to
     the reply's last add.  The ROM sign-extends the offset, adds d (XDE) INTO the offset's register XWA and moves
     the sum back to XDE.  44c (`d = (long)off + d;`) added in place (`add xde,xwa`), 44a (`d + (long)off` in the
     argument) moved d to XHL, 44b (`&d[(int)(unsigned int)off]`) folded to `lda xde,(xde+wa)`.  That
     exts / add-into-XWA / move-back shape is exactly what the matched DSPUnit row gives when a converted address
     of a row is assigned to the pointer local that holds the base (43a: `p = (unsigned char *)((unsigned int
     *)&ram_44fce[...])`, XBC base and target): so here `d = (unsigned char *)((unsigned int *)&d[(int)(unsigned
     int)off]);`, d then passed alone.
   - VoiceParam_Set_Tone_Option: ONE function from its label through VoiceParam_Set_Tone_Option_Epilogue
     (span_refs.py with VOICEPARAM_TONE_OPTION_JUMPTABLE: the 8 inner labels, the case base
     VoiceParam_Set_Tone_Option_CutoffOffset included, are inner-only).  Earlier attempts (helpers C, H, K, N, T, AE;
     best sub_AE_20b, +21) differ only in the option-array store: the ROM computes the index in DE
     (`ld de,wa; add de,472`, the shape of an int LOCAL assigned `(int)(unsigned int)idx + 472`) and loads the base
     straight into XHL.  V4.23 gives the first-declared local the HL family and the second the DE family (sub_T_18*:
     o alone in HL; sub_AE_20a: o HL, q XDE; 20b: q XHL, o DE, but q's `= ram_44fce` went through XWA).  So the
     first local is case 6's list pointer r (Voice_AllocateForSustain's result, already in XHL; the ROM passes it
     with `ld xwa,xhl`), o second; the store indexes the array itself, `ram_44fce[o] = v`.  Form a: o in one
     statement.

   cc900-options: -Xr
*/

extern unsigned char ram_4136e[];
extern unsigned char ram_44fce[];
extern unsigned char *ram_4531c;

extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern void InterCPU_E1_DMA_Transfer(unsigned char *d, unsigned int n, unsigned char *s);
extern unsigned char *Voice_Query_PartVoices(int part);
extern unsigned char *Voice_AllocateForSustain(int part);
extern void Voice_AllNotes_SustainRetrigger(unsigned char *list, unsigned char flag);
extern void AudioChannel_AllVoices_UpdVar3(unsigned char *list);
void DSP_SlotParam_Write_From_Cache_B(unsigned char slot);
void DSP_SlotParam_Read_To_Cache_B(unsigned char part, unsigned char slot);
extern void Voice_ActiveFlag_CheckAndLoad();
extern void Voice_Part_ResetSlotRouting();
extern void DSP_SlotParam_Write_Slot0();
extern void DSP_SlotParam_Write_Slot1();
extern void DSP_SlotParam_Write_Slot2();
extern void DSP_SlotParam_Write_Slot3();
extern void DSP_SlotParam_Write_Slot4();
extern void VoiceAlloc_Apply_Algo_Group0();

/* cc900-name: AudioChannel_AllVoices_UpdVar3=AudioChannel_AllVoices_Update_Variant3 */
/* cc900-module: Audio_Cmd_ToneEdit_Write_And_Reply DSP_SlotParam_Write_From_Cache_B DSP_SlotParam_Read_To_Cache_B */
/* cc900-module: VoiceParam_Set_Tone_Option VoiceAlloc_Apply_Algo_Group0 */
/* cc900-data: Audio_Cmd_ToneEdit_Write_And_Reply 1 = AUDIO_CMD_TONEEDIT_REPLY_CASEMAP */
/* cc900-data: Audio_Cmd_ToneEdit_Write_And_Reply 2 = AUDIO_CMD_TONEEDIT_REPLY_JUMPTABLE */
/* cc900-data: VoiceParam_Set_Tone_Option 1 = VOICEPARAM_TONE_OPTION_JUMPTABLE */

void Audio_Cmd_ToneEdit_Write_And_Reply(register unsigned char *m)
{
    unsigned char *buf;
    unsigned char *d;
    unsigned int n;

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
    d = (unsigned char *)0x1e0000;
    n = 58;
    InterCPU_E1_DMA_Transfer(buf, n,
                             (unsigned char *)(unsigned long)&d[(int)(unsigned int)((int)ram_4531c[29351] * 80 + 19111)]);
}

void VoiceParam_Set_Tone_Option(unsigned char part, unsigned char idx, unsigned char v)
{
    unsigned char *r;
    register int o;

    o = (int)(unsigned int)idx;
    o += 472;
    *(ram_44fce + o) = v;
    switch (idx) {
    case 0:
        Voice_ActiveFlag_CheckAndLoad(part);
        break;
    case 1:
        Voice_Part_ResetSlotRouting(part);
        if (v != 0xf5) DSP_SlotParam_Write_Slot0(part);
        VoiceAlloc_Apply_Algo_Group0(part, 0);
        break;
    case 2:
        DSP_SlotParam_Write_Slot1(part);
        VoiceAlloc_Apply_Algo_Group0(part, 0);
        break;
    case 3:
        DSP_SlotParam_Write_Slot2(part);
        VoiceAlloc_Apply_Algo_Group0(part, 0);
        break;
    case 5:
        DSP_SlotParam_Write_Slot3(part);
        break;
    case 6:
        DSP_SlotParam_Write_Slot4(part);
        r = Voice_AllocateForSustain(part);
        Voice_AllNotes_SustainRetrigger(r, 1);
        break;
    }
}
