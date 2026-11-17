/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_1a.c (2026-11-16-30-p6-r1)
   sha256 2722c78c13bb404ebe11ffc7bd3aada0a95be15ba6505fcf62b49ce4203309c5 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ram_34d3, SEQ_TRACK_ASSIGN[], ram_3996;
char Part_IsPercussionType(unsigned char a)
{
    unsigned char t;
    t = SEQ_TRACK_ASSIGN[(unsigned char)(a - 1)];
    if (t == 0xd || t == 0xe || t == 0xf || t == 0x10)
        return 1;
    return 0;
}
