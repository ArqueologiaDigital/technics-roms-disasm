/* Phase 6, lane_p6 helper C, round 23, module 265 (modules_v10.tsv) of v10 demo/fdemotext_routines.s, form a: four
   small routines from poolnew_C's FDemoText_LookupTableEntry entry (its 223 B span them).
   - FDemoText_LookupTableEntry: part p's RAM record from PART_RECORD_PTRS (the 4-byte pointer table).
   - FDemoText_ByteData_VoiceProbeA / B / C: the switch-button payload (SWBTWR_PAYLOAD_1 / _3, SWBTWR_EVENT_TYPE)
     marks parts for resending in the bytes 0x247ec / 0x247ee / 0x247f2, through FDemoText_PartFlagBit,
     FDemoText_FullSendBitByPart and FDemoText_PartialResendBit.  ProbeC's 7-way switch reads the tree's
     FDemoText_ByteData_VoiceProbeC_CaseTable; for kinds 3..7 the ROM picks a table pointer (loaded as an
     immediate) and ORs the part's byte in a shared tail, so the table is a pointer local here.
   Form b (p6_C_23m265b.c): ProbeC with the table read in each case, ProbeA's index through a local. */
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
    return PART_RECORD_PTRS[ch];
}

void FDemoText_ByteData_VoiceProbeA(void)
{
    switch (SWBTWR_PAYLOAD_1) {
    case 0:
    case 1:
        ram_247ee |= FDemoText_PartFlagBit[SWBTWR_EVENT_TYPE];
        break;
    case 5:
        if (FDemoText_LookupTableEntry(SWBTWR_EVENT_TYPE)[5] != 0) return;
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
