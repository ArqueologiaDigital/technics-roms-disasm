/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_2a.c (2026-11-16-33-p6-r2)
   sha256 daff6a210ae1d585590cbca49a5d49ac10efb93aef3c1766c7663df3000edf26 (tar-sha256); compiled at -O3 -Xr */
char Part_IsPercussionType(unsigned char a)
{
    unsigned char t;
    t = ((unsigned char *)0xf1a0)[(unsigned char)(a - 1)];
    if (t == 0xd || t == 0xe || t == 0xf || t == 0x10)
        return 1;
    return 0;
}
