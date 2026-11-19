/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_29b.c (2026-11-19-44-sub-r29a)
   sha256 a55ae5f11b1cdc917e1826e26eb3dfeabfe43735bd6f36b238ef5f067a4fa57a (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_24e6[];
#define R(a) ((unsigned char *)(unsigned long)(ram_24e6 + (int)(a) * 12))
#define AT(r, k) ((r)[k])
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
