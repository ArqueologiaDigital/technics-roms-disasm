/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_35r1m3b.c (2026-11-22-23-p6-r90)
   sha256 e4000d98e627be571d868b58c166a345100f3d082a54ce4f4a32a311e52982b9 (tar-sha256); compiled at -O3 -Xr */
extern void Flash_ProgramWord(int, unsigned int *, unsigned int);
extern void Flash_IdentifyChip(int);
void Flash_WriteFromMemory(unsigned char chip, unsigned int *src, unsigned int *dst)
{
    unsigned int i;

    dst = (unsigned int *)((unsigned long)dst & 0xff0000);
    for (i = 0; i < 0x8000; i++)
        Flash_ProgramWord(chip, dst++, *src++);
    for (i = 0; i < 0x1000; i++)
        ;
    Flash_IdentifyChip(chip);
}
