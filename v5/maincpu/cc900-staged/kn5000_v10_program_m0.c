/* Functions of kn5000_v5_program.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char SubCPU_SendPayloadEnableFlag;
extern unsigned char SubCPU_FlashPayloadEnableFlag;
extern unsigned int __near ram_404;
extern void InterCPU_E1_Bulk_Transfer();
extern int SLIDE_Parse_Header(long, long);
extern void SubCPU_Send_Payload(void);

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
