/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_1a.c (2026-11-16-31-p6-r1b)
   sha256 55d0abda1f1ad176b6cda9b0417d1d509cf0856109b356f9c81748eff869e473 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near SEQ_TRACK_ASSIGN[];
char Part_IsPercussionType(unsigned char a)
{
    unsigned char t;
    t = SEQ_TRACK_ASSIGN[(unsigned char)(a - 1)];
    if (t == 0xd || t == 0xe || t == 0xf || t == 0x10)
        return 1;
    return 0;
}
