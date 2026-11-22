/* Probe round 35r1, helper Z, form a: boot/system_handlers.s (module 3), the xr_screen.py shape at -O3 -Xr.
   Flash_EraseSectorAndWrite(chip, src, dst): identify the flash chip, erase dst's sector (bank selected), wait
   while the chip reports busy (0xffff), then write from src.  All three parameters live on the frame. */
/* cc900-module: Flash_CheckReady Flash_EraseSectorWithBankSelect Flash_IdentifyChip Flash_WriteFromMemory */

extern void Flash_IdentifyChip(unsigned int);
extern void Flash_EraseSectorWithBankSelect(unsigned int, unsigned char *);
extern unsigned int Flash_CheckReady(void);
extern void Flash_WriteFromMemory(unsigned int, unsigned char *, unsigned char *);
extern void Flash_EraseSectorAndWrite(unsigned char, unsigned char *, unsigned char *);

void Flash_EraseSectorAndWrite(unsigned char chip, unsigned char *src, unsigned char *dst)
{
    Flash_IdentifyChip(chip);
    Flash_EraseSectorWithBankSelect(chip, dst);
    while (Flash_CheckReady() == 0xffff)
        ;
    Flash_WriteFromMemory(chip, src, dst);
}
