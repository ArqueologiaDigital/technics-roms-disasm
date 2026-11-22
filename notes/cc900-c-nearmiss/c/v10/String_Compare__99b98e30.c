/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m307a.c (2026-11-21-2-p6-r58)
   sha256 99b98e304807ae3543daf327f95da8f578393edfba64070a709bad6359118be0 (tar-sha256); compiled at -O3 -XS -Xr */
int __cdecl String_Compare(unsigned char *s1, unsigned char *s2, unsigned int n)
{
  char r;
  for (; n != 0 && *s2 == *s1; s1++, s2++, n--)
    if (*s1 == 0) return 0;
  r = 0;
  if (n != 0) r = *s1 - *s2;
  return r;
}
