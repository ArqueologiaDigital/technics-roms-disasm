/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/fdemotext_routines_m0_xr.c (2026-11-18-12-p6-r35)
   sha256 aea6e84bea0f281199844e399695eb21ff672bcc3eec68ae03f667163ab6aced (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
extern unsigned char __near SWBTWR_PAYLOAD_1;
extern unsigned char __near SWBTWR_PAYLOAD_3;
extern unsigned char ram_247ee;
void FDemoText_ByteData_VoiceProbeB(void)
{
    if (SWBTWR_PAYLOAD_1 != 1) return;
    if ((SWBTWR_PAYLOAD_3 & 0x7f) == 0) return;
    ram_247ee |= 0x40;
}
