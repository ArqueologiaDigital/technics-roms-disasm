/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_29a.c (2026-11-19-44-sub-r29a)
   sha256 496b616b913967a3593f5a7ea778f22ecb7e2c6118f218bf86d58e93affa5fa7 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_24e6[];
#define R(a) ((unsigned char *)(unsigned long)(ram_24e6 + (int)(a) * 12))
#define AT(r, k) (*((r) + (k)))
void VoiceState_SwapSlot_DE_BC(unsigned char a, unsigned char c)
{
    unsigned char x, y;
    x = AT(R(a), (unsigned int)c);
    y = AT(R(a), ((unsigned int)c + 4));
    AT(R(y), (unsigned int)c) = x;
    AT(R(x), ((unsigned int)c + 4)) = y;
    AT(R(a), (unsigned int)c) = a;
    AT(R(a), ((unsigned int)c + 4)) = a;
}
