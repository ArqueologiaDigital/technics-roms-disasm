/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/system_handlers_m3.c (2026-11-21-5-p6-r60)
   sha256 c00f3bded64bc75d4f7ed30887628814d62be371751a95044f55bbfc7f881a85 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
void Flash_FillBuffer(unsigned int *p, unsigned int n)
{
  unsigned int i;
  for (i = 0; i < n; i++)
    *p++ = i;
}
