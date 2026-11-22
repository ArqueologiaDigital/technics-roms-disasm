/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/system_handlers_m3.c (2026-11-21-5-p6-r60)
   sha256 c00f3bded64bc75d4f7ed30887628814d62be371751a95044f55bbfc7f881a85 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void Copy_DE_words_from_XBC_to_XWA(unsigned long, unsigned long, unsigned long);
void Flash_CopyROMToBuffer(unsigned long a)
{
  Copy_DE_words_from_XBC_to_XWA(0x69800L, a & 0xff0000L, 0x8000L);
}
