/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_28b.c (2026-11-19-41-sub-r28a)
   sha256 3dc7f81bcb04dd968f911614020f26fe69c5883124f3ad30e4f6d2b6865e50e3 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_24e6[][12];
extern unsigned char __near ram_1e4d[][27];
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

    for (i = 0; i < 0x40; i++)
        for (j = 0; j < 4; j++) {
            ram_24e6[(int)i][(unsigned long)((unsigned int)j + 8)] = 0xff;
            ram_24e6[(int)i][(unsigned long)(unsigned int)j] = i;
            ram_24e6[(int)i][(unsigned long)((unsigned int)j + 4)] = i;
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
            ram_1e4d[(int)i][(unsigned long)(unsigned int)j] = 0xff;
    for (i = 0; i < 0xc0; i++)
        VoiceSlot_UpdateNoteSource(i, 0x1a, Quad_Decode_A_To_L(i));
}
