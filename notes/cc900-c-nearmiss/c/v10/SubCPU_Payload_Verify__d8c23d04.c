/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_6b.c (2026-11-16-45-p6-r9)
   sha256 d8c23d04522aec171aa28df55c10e94ff12aceb37e57c0c9258fc07955f44d2f (tar-sha256); compiled at -Xr */
extern unsigned char LIVE_PANEL_BLOCK;
extern unsigned int NMI_CHECKSUM_REGION1;
extern unsigned int NMI_CHECKSUM_REGION2;
extern char ram_1e53e;
extern unsigned int Checksum_ComputeComplement(unsigned char *, unsigned int);
void SubCPU_Payload_Verify(void)
{
    unsigned int s = Checksum_ComputeComplement((unsigned char *)0xf180, 0x800);
    if (s == NMI_CHECKSUM_REGION1) {
        ram_1e53e = 0;
        if (Checksum_ComputeComplement(&LIVE_PANEL_BLOCK, 0x280) != NMI_CHECKSUM_REGION2) ram_1e53e = -1;
    } else {
        ram_1e53e = -1;
        if (Checksum_ComputeComplement(&LIVE_PANEL_BLOCK, 0x280) == NMI_CHECKSUM_REGION2) ram_1e53e = 1;
    }
}
