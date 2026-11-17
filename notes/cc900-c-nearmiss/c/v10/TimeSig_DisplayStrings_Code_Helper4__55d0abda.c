/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_1a.c (2026-11-16-31-p6-r1b)
   sha256 55d0abda1f1ad176b6cda9b0417d1d509cf0856109b356f9c81748eff869e473 (tar-sha256); compiled at -Xr */
extern unsigned char __near CMP_RECORD_PART;
extern unsigned char __near ram_37c9;
void TimeSig_DisplayStrings_Code_Helper4(void)
{
    CMP_RECORD_PART = 1;
    if (ram_37c9 & 0x10) return;
    CMP_RECORD_PART = 2;
    if (ram_37c9 & 0x20) return;
    CMP_RECORD_PART = 4;
    if (ram_37c9 & 0x40) return;
    CMP_RECORD_PART = 8;
    if (ram_37c9 & 0x08) return;
    CMP_RECORD_PART = 16;
}
