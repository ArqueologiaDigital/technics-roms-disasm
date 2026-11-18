/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AH_20b.c (2026-11-18-18-sub-r21a)
   sha256 1a38294d9608c2cdcfb43a7ec910017dec23940711db7c62016a80b94617f566 (tar-sha256); compiled at -Xr */
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
    unsigned char i;
    unsigned char j;
    unsigned int n;

    for (i = 0; i < 0x40; i++)
        for (j = 0; j < 4; j++) {
            *(ram_24e6 + (int)i * 12 + (j + 8u)) = 0xff;
            *(ram_24e6 + (int)i * 12 + (j + 0u)) = i;
            *(ram_24e6 + (int)i * 12 + (j + 4u)) = i;
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
            *(ram_1e4d + (int)i * 27 + (j + 0u)) = 0xff;
    for (i = 0; i < 0xc0; i++) {
        n = i;
        VoiceSlot_UpdateNoteSource(n, 0x1a, Quad_Decode_A_To_L(i));
    }
}
