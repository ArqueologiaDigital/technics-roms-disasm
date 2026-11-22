/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m271a.c (2026-11-21-2-p6-r58)
   sha256 11739cac1bd716f27f2d6ed7d519853e53563673ad49d6f7f67b6e35fb57e287 (tar-sha256); compiled at -O3 -XS -Xr */
int BoxRightCheck(int x)
{
  if (x > 0xa8 || x < 0xa0) return 0;
  return 1;
}
