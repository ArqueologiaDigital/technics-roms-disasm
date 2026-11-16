/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_10a.c (2026-11-16-90-sub-r10)
   sha256 bb499c121aaefa01b0c094dc81af9c38404b55775ff87425d47cbe4ef107bd5d (name+funcs); compiled at -Xr */
extern unsigned char __near ram_2126[];
extern unsigned char __near ram_24e6[];
void VoiceState_SwapSlot_DE_BC(int a, int c);
void VoiceState_SwapSlot_HL_IY(int a, int c, int e);
void VoiceState_SwapSlot_Guarded(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char k;
    unsigned char *r;
    unsigned char *s;
    r = ram_24e6 + (int)a * 12;
    k = r[(int)c + 8];
    if (k < 0xc0) {
        s = &ram_2126[(int)k * 5];
        if (s[4] == a) {
            if (r[c] != a) s[4] = r[c];
            else s[4] = 0xff;
        }
    }
    s = &ram_2126[(int)e * 5];
    if (s[4] > 0x40) {
        s[4] = a;
        VoiceState_SwapSlot_DE_BC(a, c);
    } else VoiceState_SwapSlot_HL_IY(a, c, s[4]);
    r[(int)c + 8] = e;
}
