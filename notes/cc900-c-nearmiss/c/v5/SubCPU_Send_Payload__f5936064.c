/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/kn5000_v10_program_m0.c (2026-11-17-6-p6-r30-staged)
   sha256 f593606427d71af1c20163e62885bae1c8a0985808c49789fb06e074770b57eb (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
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
