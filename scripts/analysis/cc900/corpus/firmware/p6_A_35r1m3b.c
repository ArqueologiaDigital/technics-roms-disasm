/* Probe round 35r1, helper A, form b: boot/system_handlers.s (module 3), xr_screen family.
   Flash_WriteFromMemory as form a, with dst an unsigned long masked in place and cast at the call
   (dst += 2 per word), and a plain (non-register) counter. */
/* cc900-module: Flash_IdentifyChip Flash_ProgramWord */

extern void Flash_ProgramWord(int, unsigned int *, unsigned int);
extern void Flash_IdentifyChip(int);
extern void Flash_WriteFromMemory(unsigned char, unsigned int *, unsigned int *);

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
