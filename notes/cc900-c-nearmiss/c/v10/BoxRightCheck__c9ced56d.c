/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m271b.c (2026-11-21-7-p6-r62)
   sha256 c9ced56dc742641d934d3c247aeffee1fcce505d06b528d9f70a819af4ff4bdc (tar-sha256); compiled at -O3 -Xr */
int BoxRightCheck(int x)
{
  int r;
  if (x <= 0xa8 && x >= 0xa0) r = 1;
  else r = 0;
  return r;
}
