/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AH_21b.c (2026-11-18-29-sub-r21f)
   sha256 0c88b057db4df86d1242b8b0aeb50e8e69981a7373919757e71b282266e1d268 (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_24e6[];
extern unsigned char __near ram_1e4d[];
extern unsigned char __near ram_2126[];
extern unsigned char __near ram_2127[];
extern unsigned char __near ram_2128[];
extern unsigned char __near ram_2129[];
extern unsigned char __near ram_212a[];
unsigned char Quad_Decode_A_To_L(int a);
void VoiceSlot_UpdateNoteSource(int a, int c, int e);
void VoiceState_FullReset(void)
{
    unsigned char j;
    unsigned char i;

    for (i = 0; i < 0x40; i++)
        for (j = 0; j < 4; j++) {
            ((unsigned char *)(unsigned long)(ram_24e6 + (int)i * 12))[(unsigned int)j + 8] = 0xff;
            ((unsigned char *)(unsigned long)(ram_24e6 + (int)i * 12))[(unsigned int)j] = i;
            ((unsigned char *)(unsigned long)(ram_24e6 + (int)i * 12))[(unsigned int)j + 4] = i;
        }
    for (i = 0; i < 0xc0; i++) {
        ram_2126[(int)i * 5] = i;
        ram_2127[(int)i * 5] = i;
        ram_2128[(int)i * 5] = 0;
        ram_2129[(int)i * 5] = 0;
        ram_212a[(int)i * 5] = 0xff;
    }
    for (i = 0; i < 27; i++)
        for (j = 0; j < 27; j++)
            ((unsigned char *)(unsigned long)(ram_1e4d + (int)i * 27))[(unsigned int)j] = 0xff;
    for (i = 0; i < 0xc0; i++)
        VoiceSlot_UpdateNoteSource(i, 0x1a, Quad_Decode_A_To_L(i));
}
