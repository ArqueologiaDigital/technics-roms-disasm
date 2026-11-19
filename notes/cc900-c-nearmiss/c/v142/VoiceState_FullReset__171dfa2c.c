/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_28a.c (2026-11-19-41-sub-r28a)
   sha256 171dfa2c8ce14025eecb1a203d19a14d1d04c0b671a74452bb1e26cc67652723 (name+funcs); compiled at -Xr
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
            *((unsigned int)j + 8 + ram_24e6[(int)i]) = 0xff;
            *((unsigned int)j + ram_24e6[(int)i]) = i;
            *((unsigned int)j + 4 + ram_24e6[(int)i]) = i;
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
            *((unsigned int)j + ram_1e4d[(int)i]) = 0xff;
    for (i = 0; i < 0xc0; i++)
        VoiceSlot_UpdateNoteSource(i, 0x1a, Quad_Decode_A_To_L(i));
}
