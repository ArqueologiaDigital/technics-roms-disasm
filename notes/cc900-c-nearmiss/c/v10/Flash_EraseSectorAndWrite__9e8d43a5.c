/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Z_35r1m3a.c (2026-11-22-23-p6-r90)
   sha256 9e8d43a5b49a727904dec5004ce1f2139dd2df1f4799baadb65ef3eb3949422d (tar-sha256); compiled at -O3 -XS -Xr */
extern void Flash_IdentifyChip(unsigned int);
extern void Flash_EraseSectorWithBankSelect(unsigned int, unsigned char *);
extern unsigned int Flash_CheckReady(void);
extern void Flash_WriteFromMemory(unsigned int, unsigned char *, unsigned char *);
void Flash_EraseSectorAndWrite(unsigned char chip, unsigned char *src, unsigned char *dst)
{
    Flash_IdentifyChip(chip);
    Flash_EraseSectorWithBankSelect(chip, dst);
    while (Flash_CheckReady() == 0xffff)
        ;
    Flash_WriteFromMemory(chip, src, dst);
}
