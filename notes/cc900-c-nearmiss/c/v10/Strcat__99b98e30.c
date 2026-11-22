/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m307a.c (2026-11-21-2-p6-r58)
   sha256 99b98e304807ae3543daf327f95da8f578393edfba64070a709bad6359118be0 (tar-sha256); compiled at -O3 -XS -Xr */
char *__cdecl Strcat(char *d, char *s)
{
  char *p;
  p = d;
  while (*p != 0)
    p++;
  while (*s != 0)
    *p++ = *s++;
  *p = 0;
  return d;
}
