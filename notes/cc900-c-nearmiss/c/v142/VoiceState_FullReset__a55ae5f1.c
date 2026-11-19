/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_29b.c (2026-11-19-44-sub-r29a)
   sha256 a55ae5f11b1cdc917e1826e26eb3dfeabfe43735bd6f36b238ef5f067a4fa57a (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_24e6[];
extern unsigned char __near ram_1e4d[];
extern unsigned char __near ram_2126[];
extern unsigned char __near ram_2127[];
extern unsigned char __near ram_2128[];
extern unsigned char __near ram_2129[];
extern unsigned char __near ram_212a[];
unsigned char Quad_Decode_A_To_L(int a);
void VoiceSlot_UpdateNoteSource(int a, int c, int e);
#define R(a) ((unsigned char *)(unsigned long)(ram_24e6 + (int)(a) * 12))
#define R27(a) ((unsigned char *)(unsigned long)(ram_1e4d + (int)(a) * 27))
#define AT(r, k) ((r)[k])
void VoiceState_FullReset(void)
{
    unsigned char i;
    unsigned char j;

    for (i = 0; i < 0x40; i++)
        for (j = 0; j < 4; j++) {
            AT(R(i), ((unsigned int)j + 8)) = 0xff;
            AT(R(i), (unsigned int)j) = i;
            AT(R(i), ((unsigned int)j + 4)) = i;
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
            AT(R27(i), (unsigned int)j) = 0xff;
    for (i = 0; i < 0xc0; i++)
        VoiceSlot_UpdateNoteSource(i, 0x1a, Quad_Decode_A_To_L(i));
}
