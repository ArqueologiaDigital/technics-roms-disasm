/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_1b.c (2026-11-16-30-p6-r1)
   sha256 661abb9b1607433d32862ee68a6f8b4ea5a2c002087e5a7b864f5b7e199c0570 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ram_34d3, SEQ_TRACK_ASSIGN[], ram_3996;
char Part_IsPercussionType(unsigned char a)
{
    unsigned char t;
    char r;
    a--;
    t = SEQ_TRACK_ASSIGN[a];
    if (t == 0xd || t == 0xe || t == 0xf || t == 0x10)
        r = 1;
    else
        r = 0;
    return r;
}
