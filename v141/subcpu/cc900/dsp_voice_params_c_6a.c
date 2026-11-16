/* Functions of core/10_dsp_voice_params.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int ram_4132b;
extern unsigned char ram_41350[];
extern unsigned char ram_4135a[];
extern unsigned char ram_413b7[];
extern unsigned char ram_4518c;
extern char ram_4518e;
extern unsigned char *ToneDB_Find_ToneRecord_CoeffPath(unsigned int a, unsigned int b);
extern unsigned char *ToneDB_Find_PatchRecord(unsigned int a, unsigned int b);
extern char Voice_SecondaryParam_Fetch2();
extern void Voice_NoteState_Clear();
extern void NoteState_ClearRecord();

/* cc900-module: ToneDB_Find_PatchRecord ToneDB_Find_ToneRecord_CoeffPath Voice_NoteState_Clear Voice_SecondaryParam_Fetch2 */
unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b)
{
    unsigned char *r;
    if (ram_4132b & 1) r = ToneDB_Find_ToneRecord_CoeffPath(a, b);
    else r = ToneDB_Find_PatchRecord(a, b);
    return r;
}

void VoiceSlot_ClearAll(void)
{
    unsigned int i;
    unsigned int j;
    unsigned char p;
    for (p = 0; p < 26; p++) {
        for (i = 0; i < 4; i++) {
            for (j = 0; j < 3; j++) {
                ((unsigned char *)((unsigned long)(ram_41350 + p * 0x11f) + (((unsigned long)j << 4) + ((unsigned long)i << 2))))[39] = 0;
                ((unsigned int *)((unsigned long)(ram_41350 + p * 0x11f) + ((unsigned long)i * 37 + (unsigned long)j * 2)))[68] = 0;
            }
        }
        Voice_NoteState_Clear(p);
    }
    for (i = 0; i < 64; i++) {
        for (j = 0; j < 3; j++) NoteState_ClearRecord((unsigned char)i, (unsigned char)j);
    }
    ram_4518c = 0xff;
}

void Voice_ActiveFlag_CheckAndLoad(unsigned char part)
{
    char v;
    v = 0;
    if ((*(unsigned int *)(ram_41350 + part * 0x11f) & 1) && ram_4518c == part) v = ram_4518e << 2;
    if (*(unsigned int *)(ram_4135a + part * 0x11f) & 0x8000L) v += Voice_SecondaryParam_Fetch2(part);
    ram_413b7[part * 0x11f] = v;
}
