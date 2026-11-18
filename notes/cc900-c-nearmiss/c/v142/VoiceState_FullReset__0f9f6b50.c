/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AH_21c.c (2026-11-18-29-sub-r21f)
   sha256 0f9f6b50e681ccdd0c79fa69a634212ad02f882d1981a6abb66195cad3ab5ac6 (tar-sha256); compiled at -Xr */
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
            *(((unsigned int)j + 8) + (unsigned char *)(unsigned long)(ram_24e6 + (int)i * 12)) = 0xff;
            *((unsigned int)j + (unsigned char *)(unsigned long)(ram_24e6 + (int)i * 12)) = i;
            *(((unsigned int)j + 4) + (unsigned char *)(unsigned long)(ram_24e6 + (int)i * 12)) = i;
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
            *((unsigned int)j + (unsigned char *)(unsigned long)(ram_1e4d + (int)i * 27)) = 0xff;
    for (i = 0; i < 0xc0; i++)
        VoiceSlot_UpdateNoteSource(i, 0x1a, Quad_Decode_A_To_L(i));
}
