/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_35r1m3a.c (2026-11-22-23-p6-r90)
   sha256 b352980aa6ad946f727cb7c605bae87edc7d62a938a47619ffaf66b83175174a (tar-sha256); compiled at -O3 -Xr */
extern void Flash_ProgramWord(int, unsigned int *, unsigned int);
extern void Flash_IdentifyChip(int);
void Flash_WriteFromMemory(unsigned char chip, unsigned int *src, unsigned int *dst)
{
    register unsigned int i;

    *(unsigned long *)&dst &= 0xff0000;
    for (i = 0; i < 0x8000; i++)
        Flash_ProgramWord(chip, dst++, *src++);
    for (i = 0; i < 0x1000; i++)
        ;
    Flash_IdentifyChip(chip);
}
