/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_14m129a.c (2026-11-16-100-p6-r19)
   sha256 701b50862cea8afdb7d4731ed7801af5090888e61b80a277453a14a39b81a886 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near SEMENU_PART_MASK;
extern unsigned char SeMenu_BitShiftMask(int v, int n);
int SeMenu_IsPartEnabled(unsigned char a)
{
    if (a < 1 || a > 4)
        return 0;
    return (SEMENU_PART_MASK & SeMenu_BitShiftMask(1, (unsigned char)(a + a - 2))) != 0;
}
