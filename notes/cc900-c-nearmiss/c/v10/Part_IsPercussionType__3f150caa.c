/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_1b.c (2026-11-16-31-p6-r1b)
   sha256 3f150caa4e8af344bb960480c9e2d9301aeff28c615c172cb13fb76c7a3f84d7 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near SEQ_TRACK_ASSIGN[];
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
