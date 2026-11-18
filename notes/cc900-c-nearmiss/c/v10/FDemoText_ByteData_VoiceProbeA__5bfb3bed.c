/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_C_23m265b.c (2026-11-18-1-p6-r33)
   sha256 5bfb3bed18c2eb1787aa2cd871b4bf5e41653bd645788353b0c9fac844c93ae7 (tar-sha256); compiled at -O3 -Xr */
/* Phase 6, lane_p6 helper C, round 23, module 265 (modules_v10.tsv) of v10 demo/fdemotext_routines.s, form b (form a,
   p6_C_23m265a.c, describes the four routines): ProbeC ORs the table byte in each case (V4.23 may share the tail
   itself), the lookup's index widened to int before scaling, and ProbeA's event type read once into a local. */
/* cc900-module: FDemoText_LookupTableEntry */
/* cc900-data: FDemoText_ByteData_VoiceProbeC 1 = FDemoText_ByteData_VoiceProbeC_CaseTable */

typedef unsigned char *ucp;

extern ucp *__near PART_RECORD_PTRS;
extern unsigned char __near SWBTWR_PAYLOAD_1;
extern unsigned char __near SWBTWR_PAYLOAD_3;
extern unsigned char __near SWBTWR_EVENT_TYPE;
extern unsigned char ram_247ec;
extern unsigned char ram_247ee;
extern unsigned char ram_247f2;
extern unsigned char FDemoText_PartFlagBit[];
extern unsigned char FDemoText_FullSendBitByPart[];
extern unsigned char FDemoText_PartialResendBit[];

extern unsigned char *FDemoText_LookupTableEntry(unsigned char);

unsigned char *FDemoText_LookupTableEntry(unsigned char ch)
{
    return PART_RECORD_PTRS[(int)ch];
}

void FDemoText_ByteData_VoiceProbeA(void)
{
    unsigned char t;
    t = SWBTWR_EVENT_TYPE;
    switch (SWBTWR_PAYLOAD_1) {
    case 0:
    case 1:
        ram_247ee |= FDemoText_PartFlagBit[t];
        break;
    case 5:
        if (FDemoText_LookupTableEntry(t)[5] != 0) return;
        ram_247f2 |= FDemoText_PartFlagBit[SWBTWR_EVENT_TYPE];
        break;
    }
}

void FDemoText_ByteData_VoiceProbeB(void)
{
    if (SWBTWR_PAYLOAD_1 != 1) return;
    if ((SWBTWR_PAYLOAD_3 & 0x7f) == 0) return;
    ram_247ee |= 0x40;
}

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
