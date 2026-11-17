/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/system_handlers_m0.c (2026-11-16-68-p6-r12)
   sha256 06b7695f3250962b2dca428d03af273c088d26feb738224936164292fbe503a0 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char LIVE_PANEL_BLOCK;
extern unsigned int NMI_CHECKSUM_REGION1;
extern unsigned int NMI_CHECKSUM_REGION2;
extern char ram_1e53e;
extern unsigned int Checksum_ComputeComplement(unsigned char *, unsigned int);
void SubCPU_Payload_Verify(void)
{
    unsigned int s = Checksum_ComputeComplement((unsigned char *)0xf180, 0x800);
    unsigned char *p = &LIVE_PANEL_BLOCK;
    if (s == NMI_CHECKSUM_REGION1) {
        ram_1e53e = 0;
        if (Checksum_ComputeComplement(p, 0x280) != NMI_CHECKSUM_REGION2) ram_1e53e = -1;
    } else {
        ram_1e53e = -1;
        if (Checksum_ComputeComplement(p, 0x280) == NMI_CHECKSUM_REGION2) ram_1e53e = 1;
    }
}
