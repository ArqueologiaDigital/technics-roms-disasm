/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_30a.c (2026-11-19-45-sub-r30a)
   sha256 9984735da8afde8bd92737bd7ebfc29ebb14694c3b7af603b8e89cea32513e4f (name+funcs); compiled at -Xr
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
#define K0(c) k = (c)
#define K4(c) k = (unsigned int)(c) + 4
#define K8(c) k = (unsigned int)(c) + 8
void VoiceState_FullReset(void)
{
    unsigned char i;
    unsigned char j;
    unsigned int k;

    for (i = 0; i < 0x40; i++)
        for (j = 0; j < 4; j++) {
            K8(j);
            *(R(i) + k) = 0xff;
            K0(j);
            *(R(i) + k) = i;
            K4(j);
            *(R(i) + k) = i;
        }
    for (i = 0; i < 0xc0; i++) {
        ram_2126[(int)i * 5] = i;
        ram_2127[(int)i * 5] = i;
        ram_2128[(int)i * 5] = 0;
        ram_2129[(int)i * 5] = 0;
        ram_212a[(int)i * 5] = 0xff;
    }
    for (i = 0; i < 27; i++)
        for (j = 0; j < 27; j++) {
            K0(j);
            *(R27(i) + k) = 0xff;
        }
    for (i = 0; i < 0xc0; i++)
        VoiceSlot_UpdateNoteSource(i, 0x1a, Quad_Decode_A_To_L(i));
}
