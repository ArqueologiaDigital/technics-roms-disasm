/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/system_handlers.c (2026-11-16-55-p6-r10)
   sha256 bfd0e3133bebfcc5ff281e0beca2cca883c22f692506e95295fcea794dc731b6 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned long __near SYSTEM_TIMESTAMP;
void Flash_BurnWithProgress(void)
{
    int x = 0x32;
    SYSTEM_TIMESTAMP = 0;
    TableDataFlash_ChipErase();
    while (HDAE5000_Status_Check() == -1) {
        if (SYSTEM_TIMESTAMP > 500) {
            x += 8;
            VRAM_FillRect(x, 0xb4, 5);
            SYSTEM_TIMESTAMP = 0;
        }
    }
}
