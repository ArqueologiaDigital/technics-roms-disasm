/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_1b.c (2026-11-16-31-p6-r1b)
   sha256 3f150caa4e8af344bb960480c9e2d9301aeff28c615c172cb13fb76c7a3f84d7 (tar-sha256); compiled at -Xr */
extern unsigned char __near CMP_RECORD_PART;
extern unsigned char __near ram_37c9;
void TimeSig_DisplayStrings_Code_Helper4(void)
{
    CMP_RECORD_PART = 1;
    if ((ram_37c9 & 0x10) == 0) {
        CMP_RECORD_PART = 2;
        if ((ram_37c9 & 0x20) == 0) {
            CMP_RECORD_PART = 4;
            if ((ram_37c9 & 0x40) == 0) {
                CMP_RECORD_PART = 8;
                if ((ram_37c9 & 0x08) == 0)
                    CMP_RECORD_PART = 16;
            }
        }
    }
}
