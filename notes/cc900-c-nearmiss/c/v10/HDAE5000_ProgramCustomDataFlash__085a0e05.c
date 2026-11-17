/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/system_handlers_m5.c (2026-11-16-68-p6-r12)
   sha256 085a0e05eabb47549084b1b16929336fe46ee96956e247d45dbd3c4f70d0ba7a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void Flash_ProgramWord(int, unsigned int *, unsigned int);
extern unsigned char HDAE5000_PPI__PORT_A;
extern unsigned int CUSTOM_DATA_FLASH__BASE_ADDR;
extern unsigned int ram_200000;
void HDAE5000_ProgramCustomDataFlash(void)
{
    unsigned int *src;
    unsigned int *dst = &CUSTOM_DATA_FLASH__BASE_ADDR;
    unsigned char bank;
    unsigned long i;
    bank = 0;
    do {
        HDAE5000_PPI__PORT_A = bank;
        src = &ram_200000;
        i = 0;
        do {
            Flash_ProgramWord(1, dst++, *src++);
            i++;
        } while (i < 0x40000);
        bank++;
    } while (bank < 2);
}
