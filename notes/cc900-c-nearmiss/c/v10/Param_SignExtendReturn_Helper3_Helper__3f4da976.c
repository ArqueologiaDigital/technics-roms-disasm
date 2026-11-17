/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_3a.c (2026-11-16-37-p6-r5)
   sha256 3f4da9760305cc181a03f903f54adec3de046408b1665d02d1fe4258e884294e (tar-sha256); compiled at -Xr
   cc900-name: Param_SignExt_H3_Helper=Param_SignExtendReturn_Helper3_Helper */
unsigned char Param_SignExt_H3_Helper(unsigned char *p, unsigned int n)
{
    unsigned char s = 0;
    p++;
    n--;
    while (n--) s += *p++;
    return -s & 0x7f;
}
