/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_1b.c (2026-11-16-31-p6-r1b)
   sha256 3f150caa4e8af344bb960480c9e2d9301aeff28c615c172cb13fb76c7a3f84d7 (tar-sha256); compiled at -Xr */
void SeqRec_OverflowCleanup(unsigned char *p, unsigned char n, unsigned char b)
{
    unsigned char *q;
    q = p + 1;
    if (n < 0xf0 && n >= 0x80 && b == 7)
        n = 0x58;
    else if (n >= 0xf0)
        n = 0;
    else {
        *p = n;
        *q = b & 0x7f;
        return;
    }
    *p = n;
    *q = 0;
}
