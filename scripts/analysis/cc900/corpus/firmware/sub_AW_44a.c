/* sub_AW_44a.c -- lane_sub helper AW, round 44, form a (KN5000 sub-CPU payload v1.42, core/08).
   Only Audio_Cmd_ToneEdit_Write_And_Reply (one function from its label to the end of
   Audio_Cmd_ToneEdit_Reply_Send; span_refs.py with its two case tables: all 8 inner labels inner-only).
   Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address).  No __IZ / __XIZ, no inline assembly.

   From run 2026-11-20-5-2026-11-20-6-sub-r43a (idiff_full.py on sub_AW_43a/c): the locals d (0x1e0000) and n (58),
   declared d first, now give the ROM's `ld xde,0x1e0000; ld bc,58` before the offset; everything up to the last
   add matches.  Left: V4.23 added the int offset to the pointer with `lda xde,(xde+wa)` (pointer + int through the
   16-bit index mode); the ROM sign-extends the offset to 32 bits and adds it as a long (`exts xwa; add xwa,xde`)
   before moving the sum to XDE.  So the offset is a long: form a `d + (long)off` in the argument.

   cc900-options: -Xr
*/

extern unsigned char ram_4136e[];
extern unsigned char *ram_4531c;

extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern void InterCPU_E1_DMA_Transfer(unsigned char *d, unsigned int n, unsigned char *s);
extern unsigned char *Voice_Query_PartVoices(int part);
extern unsigned char *Voice_AllocateForSustain(int part);
extern void Voice_AllNotes_SustainRetrigger(unsigned char *list, unsigned char flag);
extern void AudioChannel_AllVoices_UpdVar3(unsigned char *list);
void DSP_SlotParam_Write_From_Cache_B(unsigned char slot);
void DSP_SlotParam_Read_To_Cache_B(unsigned char part, unsigned char slot);

/* cc900-name: AudioChannel_AllVoices_UpdVar3=AudioChannel_AllVoices_Update_Variant3 */
/* cc900-module: Audio_Cmd_ToneEdit_Write_And_Reply DSP_SlotParam_Write_From_Cache_B DSP_SlotParam_Read_To_Cache_B */
/* cc900-data: Audio_Cmd_ToneEdit_Write_And_Reply 1 = AUDIO_CMD_TONEEDIT_REPLY_CASEMAP */
/* cc900-data: Audio_Cmd_ToneEdit_Write_And_Reply 2 = AUDIO_CMD_TONEEDIT_REPLY_JUMPTABLE */

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
    InterCPU_E1_DMA_Transfer(buf, n, d + (long)((int)ram_4531c[29351] * 80 + 19111));
}
