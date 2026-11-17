/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_2b.c (2026-11-16-33-p6-r2)
   sha256 6466b0db5cc304449e230b5c4768605e1ab3bae7d08d95327934985fddd8f094 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near RHYTHM_LOAD_PART;
extern char __near PANEL_STYLE[];
void CmpNcp_ResetPatternToVari1(void)
{
    if ((PANEL_STYLE[0] & 0xff) >= 128)
        RHYTHM_LOAD_PART = 16;
    else
        RHYTHM_LOAD_PART = 0;
}
