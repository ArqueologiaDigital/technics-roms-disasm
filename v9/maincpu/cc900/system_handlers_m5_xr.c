/* Functions of boot/system_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char HDAE5000_PPI__PORT_A;
extern unsigned long HDAE5000_ROM__BASE_ADDR;
extern void Flash_ProgramByte(unsigned long *, unsigned long);

void HDAE5000_ProgramTableDataFlash(void)
{
    unsigned long *src;
    unsigned long *dst = (unsigned long *)0x800000;
    unsigned char bank;
    unsigned long i;
    bank = 0;
    do {
        HDAE5000_PPI__PORT_A = bank;
        src = &HDAE5000_ROM__BASE_ADDR;
        i = 0;
        do {
            Flash_ProgramByte(dst++, *src++);
            i++;
        } while (i < 0x20000);
        bank++;
    } while (bank < 4);
}
