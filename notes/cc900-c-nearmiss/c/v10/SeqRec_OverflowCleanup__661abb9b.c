/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_1b.c (2026-11-16-30-p6-r1)
   sha256 661abb9b1607433d32862ee68a6f8b4ea5a2c002087e5a7b864f5b7e199c0570 (tar-sha256); compiled at -Xr */
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
