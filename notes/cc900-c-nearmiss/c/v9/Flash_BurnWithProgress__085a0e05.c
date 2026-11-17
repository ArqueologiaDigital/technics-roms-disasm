/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/system_handlers_m5.c (2026-11-16-68-p6-r12)
   sha256 085a0e05eabb47549084b1b16929336fe46ee96956e247d45dbd3c4f70d0ba7a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned long __near SYSTEM_TIMESTAMP;
extern void TableDataFlash_ChipErase(void);
extern int HDAE5000_Status_Check(void);
extern void VRAM_FillRect(int, int, int);
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
