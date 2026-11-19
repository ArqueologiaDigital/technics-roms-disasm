/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_29c.c (2026-11-19-44-sub-r29a)
   sha256 1c2c9bb0078c73cebb681f1e8876d7a9d84b153151bd30886a4c84a0395461a1 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_24e6[];
#define R(a) ((unsigned char *)(unsigned long)(ram_24e6 + (int)(a) * 12))
#define AT(r, k) (*((k) + (r)))
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
