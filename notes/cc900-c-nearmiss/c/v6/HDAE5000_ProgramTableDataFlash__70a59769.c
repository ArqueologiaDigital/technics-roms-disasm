/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/system_handlers_m5_xr.c (2026-11-16-68-p6-r12)
   sha256 70a59769fac00587afceb29d622b7e082cf847378062a2858cc45415f23d347e (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
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
