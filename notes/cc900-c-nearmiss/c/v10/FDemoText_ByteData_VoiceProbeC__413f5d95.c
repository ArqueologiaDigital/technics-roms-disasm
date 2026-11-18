/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_23m265a.c (2026-11-18-1-p6-r33)
   sha256 413f5d95ed8f0e4a40f33c4506fe427642d79b6efad60ade79fdd7da75c66e84 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near SWBTWR_PAYLOAD_1;
extern unsigned char __near SWBTWR_PAYLOAD_3;
extern unsigned char __near SWBTWR_EVENT_TYPE;
extern unsigned char ram_247ec;
extern unsigned char FDemoText_FullSendBitByPart[];
extern unsigned char FDemoText_PartialResendBit[];
void FDemoText_ByteData_VoiceProbeC(void)
{
    unsigned char e;
    unsigned char *p;
    e = SWBTWR_EVENT_TYPE - 0x44;
    switch (SWBTWR_PAYLOAD_1) {
    case 1:
    case 2:
        ram_247ec |= 0x40;
        return;
    case 3:
    case 4:
    case 5:
    case 6:
        p = FDemoText_FullSendBitByPart;
        break;
    case 7:
        if (SWBTWR_PAYLOAD_3 & 0x0f) ram_247ec |= FDemoText_FullSendBitByPart[e];
        if (!(SWBTWR_PAYLOAD_3 & 0x30)) return;
        p = FDemoText_PartialResendBit;
        break;
    default:
        return;
    }
    ram_247ec |= p[e];
}
