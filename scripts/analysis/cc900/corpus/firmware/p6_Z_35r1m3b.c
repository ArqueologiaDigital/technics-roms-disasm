/* Probe round 35r1, helper Z, form b: boot/system_handlers.s (module 3).  As form a, the busy wait written as
   an if around a do / while (the ROM tests once, then loops on a second call). */
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
    if (Flash_CheckReady() == 0xffff)
        do
            ;
        while (Flash_CheckReady() == 0xffff);
    Flash_WriteFromMemory(chip, src, dst);
}
