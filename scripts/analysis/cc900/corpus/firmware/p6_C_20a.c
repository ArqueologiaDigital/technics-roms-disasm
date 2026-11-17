/* Phase 6, lane_p6 helper C, round 20, form a: SubCPU_Send_Payload (new, memory-to-memory pool, 259 B, v10
   kn5000_v10_program.s, module 0; its callees are reached by 24-bit calls, so no module line).
   When SubCPU_SendPayloadEnableFlag is 0xff: wait, send the tone database (0x830000..0x87ffff) to sub-CPU
   0x50000..0x9ffff in five 64 KB InterCPU_E1_Bulk_Transfer calls, pick the payload base (0x800000, or the
   decompressed update at 0x50000 when SubCPU_FlashPayloadEnableFlag is 0xff and the SLIDE header of 0x3e0000
   parses), copy the payload's word at +0x100 to 0x404, send its three parts to 0xf000 / 0x1f000 / 0x2f000 and its
   first 256 bytes to 0x400, and wait again.
   The ROM keeps one 32-bit value in XIZ for both delay counters and the payload base, and passes the transfer
   length in XBC when it needs 32 bits (0x10000) but in BC when it fits 16 bits (0xff00, 0x100), while the
   destination 0x400 is 32-bit: the transfer is called without a prototype, with long / unsigned / int constants
   and long destinations.
   Form b (p6_C_20b.c): the delay loops as do-while. */

extern unsigned char SubCPU_SendPayloadEnableFlag;
extern unsigned char SubCPU_FlashPayloadEnableFlag;
extern unsigned int __near ram_404;

extern void InterCPU_E1_Bulk_Transfer();
extern int SLIDE_Parse_Header(long, long);

void SubCPU_Send_Payload(void)
{
    unsigned long a;
    if (SubCPU_SendPayloadEnableFlag != 0xff) return;
    for (a = 0; a < 0x2000; a++)
        ;
    InterCPU_E1_Bulk_Transfer(0x830000L, 0x10000L, 0x50000L);
    InterCPU_E1_Bulk_Transfer(0x840000L, 0x10000L, 0x60000L);
    InterCPU_E1_Bulk_Transfer(0x850000L, 0x10000L, 0x70000L);
    InterCPU_E1_Bulk_Transfer(0x860000L, 0x10000L, 0x80000L);
    InterCPU_E1_Bulk_Transfer(0x870000L, 0x10000L, 0x90000L);
    a = 0x800000L;
    if (SubCPU_FlashPayloadEnableFlag == 0xff) {
        a = 0x50000L;
        if (SLIDE_Parse_Header(0x3e0000L, 0x50000L) == -1) a = 0x800000L;
    }
    ram_404 = *(unsigned int *)(a + 0x100);
    InterCPU_E1_Bulk_Transfer(a + 0x100, 0x10000L, 0xf000L);
    InterCPU_E1_Bulk_Transfer(a + 0x10100L, 0x10000L, 0x1f000L);
    InterCPU_E1_Bulk_Transfer(a + 0x20100L, 0xff00, 0x2f000L);
    InterCPU_E1_Bulk_Transfer(a, 0x100, 0x400L);
    for (a = 0; a < 0x100000L; a++)
        ;
}
