/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_14a.c (2026-11-16-100-p6-r19)
   sha256 85fbeeab11365f896e371bcac755fbdcf9888c9c7500cb9a0ebbc1e1bd869b02 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near GLOBAL_ERROR_CODE;
void SeqError_MapToGlobal(unsigned char *t)
{
  GLOBAL_ERROR_CODE = t[SEQ_ERROR_CODE];
}
