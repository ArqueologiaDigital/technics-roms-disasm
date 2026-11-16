/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_2a.c (2026-11-16-33-p6-r2)
   sha256 e1e5d1622a68bbc27489c801d6928dde38f9ceff8816827f2bfd0be724fc352c (tar-sha256); compiled at -Xr */
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
    c = *q;
    c &= ~1;
    *q = c;
    c |= (ram_11f5 >> 8) & 1;
    *q = c;
}
