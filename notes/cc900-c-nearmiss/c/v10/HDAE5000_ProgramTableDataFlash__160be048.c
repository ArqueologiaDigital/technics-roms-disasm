/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/system_handlers_xr.c (2026-11-16-55-p6-r10)
   sha256 160be0488bf9197d413edfeece0ef97f95227c20a2d17f3b4d429be143f7131d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_PPI__PORT_A;
extern unsigned long HDAE5000_ROM__BASE_ADDR;
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
