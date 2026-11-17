/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_2a.c (2026-11-16-33-p6-r2)
   sha256 daff6a210ae1d585590cbca49a5d49ac10efb93aef3c1766c7663df3000edf26 (tar-sha256); compiled at -Xr */
extern unsigned char __near SQSTEP_CURSOR_STEP;
extern unsigned char __near ram_39b9;
void AccDraw_Secondary_Helper11(void)
{
    unsigned char s;
    unsigned char d;
    s = SQSTEP_CURSOR_STEP;
    if (s != 0)
        s--;
    d = 32;
    ram_39b9 = (unsigned int)(s & 127) / d;
}
