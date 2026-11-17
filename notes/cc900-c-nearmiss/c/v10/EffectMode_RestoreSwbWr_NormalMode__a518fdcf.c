/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_F_1b.c (2026-11-16-55-p6-r10)
   sha256 a518fdcf192eae41509fa2813337216e1a2cc69827c693dcbb511205ae502c10 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near PANEL_PART_RT1[];
extern unsigned char __near PANEL_TOUCH[];
extern void AddswbWr(int, int, int, int);
void EffectMode_RestoreSwbWr_NormalMode(void)
{
    unsigned char *p;

    p = PANEL_PART_RT1;
    *p = 0x40;
    p++;
    *p &= 0x80;
    *PANEL_TOUCH &= 0xf0;
    AddswbWr(0, 1, *p, 0x7f);
    AddswbWr(0, 0, 0x40, 0xff);
    AddswbWr(0x93, 0, 0, 0xf);
}
