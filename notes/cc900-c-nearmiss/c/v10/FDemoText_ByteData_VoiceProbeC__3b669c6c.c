/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/fdemotext_routines_m0.c (2026-11-18-12-p6-r35)
   sha256 3b669c6c47db00673f5f877140f10d3bc1cce8612c0ace761d0aba6ffa1d4c62 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SWBTWR_PAYLOAD_1;
extern unsigned char __near SWBTWR_PAYLOAD_3;
extern unsigned char __near SWBTWR_EVENT_TYPE;
extern unsigned char ram_247ec;
extern unsigned char FDemoText_FullSendBitByPart[];
extern unsigned char FDemoText_PartialResendBit[];
void FDemoText_ByteData_VoiceProbeC(void)
{
    unsigned char e;
    e = SWBTWR_EVENT_TYPE - 0x44;
    switch (SWBTWR_PAYLOAD_1) {
    case 1:
    case 2:
        ram_247ec |= 0x40;
        break;
    case 3:
    case 4:
    case 5:
    case 6:
        ram_247ec |= FDemoText_FullSendBitByPart[e];
        break;
    case 7:
        if (SWBTWR_PAYLOAD_3 & 0x0f) ram_247ec |= FDemoText_FullSendBitByPart[e];
        if (SWBTWR_PAYLOAD_3 & 0x30) ram_247ec |= FDemoText_PartialResendBit[e];
        break;
    }
}
