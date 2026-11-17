/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_20b.c (2026-11-17-2-p6-r29)
   sha256 56e46f1d1791df26a1dd78ade1e5ef088d7613daa5530e6b357e997118e3b49d (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char SubCPU_SendPayloadEnableFlag;
extern unsigned char SubCPU_FlashPayloadEnableFlag;
extern unsigned int __near ram_404;
extern void InterCPU_E1_Bulk_Transfer();
extern int SLIDE_Parse_Header(long, long);
void SubCPU_Send_Payload(void)
{
    unsigned long a;
    if (SubCPU_SendPayloadEnableFlag == 0xff) {
        a = 0;
        do a++; while (a < 0x2000);
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
        a = 0;
        do a++; while (a < 0x100000L);
    }
}
