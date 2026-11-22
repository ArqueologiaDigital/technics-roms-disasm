/* Functions of boot/system_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Flash_CheckReady Flash_EraseSectorWithBankSelect Flash_IdentifyChip Flash_WriteFromMemory */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void Flash_IdentifyChip(unsigned int);
extern void Flash_EraseSectorWithBankSelect(unsigned int, unsigned char *);
extern unsigned int Flash_CheckReady(void);
extern void Flash_WriteFromMemory(unsigned int, unsigned char *, unsigned char *);
extern void Flash_EraseSectorAndWrite(unsigned char, unsigned char *, unsigned char *);
extern void Flash_EraseSectorAndWrite(unsigned char chip, unsigned char *src, unsigned char *dst);

void Flash_EraseSectorAndWrite(unsigned char chip, unsigned char *src, unsigned char *dst)
{
    Flash_IdentifyChip(chip);
    Flash_EraseSectorWithBankSelect(chip, dst);
    while (Flash_CheckReady() == 0xffff)
        ;
    Flash_WriteFromMemory(chip, src, dst);
}
