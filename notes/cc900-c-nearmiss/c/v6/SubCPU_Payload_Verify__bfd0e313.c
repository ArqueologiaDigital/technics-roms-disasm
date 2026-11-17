/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/system_handlers.c (2026-11-16-55-p6-r10)
   sha256 bfd0e3133bebfcc5ff281e0beca2cca883c22f692506e95295fcea794dc731b6 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char LIVE_PANEL_BLOCK;
extern unsigned int NMI_CHECKSUM_REGION1;
extern unsigned int NMI_CHECKSUM_REGION2;
extern char ram_1e53e;
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
