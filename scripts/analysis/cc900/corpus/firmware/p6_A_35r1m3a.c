/* Probe round 35r1, helper A, form a: boot/system_handlers.s (module 3), xr_screen family.
   Flash_WriteFromMemory(chip, src, dst): program 0x8000 words from src to the 64 KB-aligned sector of dst, wait
   0x1000 counts, then identify the chip again.  The counter is a `register` local (IZ); the parameters stay on
   the frame (dst lowest), dst++ / src++ in the call as in the built HDAE5000_ProgramCustomDataFlash. */
/* cc900-module: Flash_IdentifyChip Flash_ProgramWord */

extern void Flash_ProgramWord(int, unsigned int *, unsigned int);
extern void Flash_IdentifyChip(int);
extern void Flash_WriteFromMemory(unsigned char, unsigned int *, unsigned int *);

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
