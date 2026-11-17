/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_14m129a.c (2026-11-16-100-p6-r19)
   sha256 701b50862cea8afdb7d4731ed7801af5090888e61b80a277453a14a39b81a886 (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
void SeMenu_InitObjEntry(unsigned char *e)
{
    unsigned char p;
    SeMenu_ValidatePartNumber(&p);
    *e = p;
    *e = p << 4;
    (*e)++;
}
