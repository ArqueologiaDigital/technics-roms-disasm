/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_1a.c (2026-11-16-31-p6-r1b)
   sha256 55d0abda1f1ad176b6cda9b0417d1d509cf0856109b356f9c81748eff869e473 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned char __near ram_3996;
void MIDIChan_ScanForFree(void)
{
    unsigned char *p;
    unsigned char i;
    p = SEQ_TRACK_ASSIGN;
    for (i = 1; i <= 0x11; i++) {
        if (*p == 0x10)
            break;
        p++;
    }
    if (i > 0x10)
        ram_3996 = 0;
    else
        ram_3996 = i;
}
