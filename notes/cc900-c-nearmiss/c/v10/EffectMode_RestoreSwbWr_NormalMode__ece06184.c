/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_1a.c (2026-11-16-55-p6-r10)
   sha256 ece06184ca870f3eb6c12fa1d8cc3c5914bcde7e5e780156071ffba817b7601d (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near PANEL_PART_RT1[];
extern unsigned char __near PANEL_TOUCH[];
extern void AddswbWr(int, int, int, int);
void EffectMode_RestoreSwbWr_NormalMode(void)
{
    unsigned char *p;

    p = PANEL_PART_RT1;
    *p++ = 0x40;
    *p &= 0x80;
    PANEL_TOUCH[0] &= 0xf0;
    AddswbWr(0, 1, *p, 0x7f);
    AddswbWr(0, 0, 0x40, 0xff);
    AddswbWr(0x93, 0, 0, 0xf);
}
