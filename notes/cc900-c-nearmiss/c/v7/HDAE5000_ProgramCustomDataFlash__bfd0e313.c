/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/system_handlers.c (2026-11-16-55-p6-r10)
   sha256 bfd0e3133bebfcc5ff281e0beca2cca883c22f692506e95295fcea794dc731b6 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
