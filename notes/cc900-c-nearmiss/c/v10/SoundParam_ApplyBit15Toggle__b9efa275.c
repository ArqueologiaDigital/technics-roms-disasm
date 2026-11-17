/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_2b.c (2026-11-16-33-p6-r2)
   sha256 b9efa2757706d71e6e9c9e909054c7167cfc9ddaea6d230749048ed7913a21f6 (tar-sha256); compiled at -Xr */
extern unsigned int __near ram_11f5;
extern unsigned char __near PANEL_STYLE[];
void SoundParam_ApplyBit15Toggle(void)
{
    unsigned char *p;
    unsigned char *q;
    unsigned char c;
    if (!(ram_11f5 & 0x8000)) return;
    p = PANEL_STYLE;
    p[8] = ram_11f5;
    q = p + 9;
    c = *q & ~1;
    *q = c;
    *q = c | ((ram_11f5 >> 8) & 1);
}
