/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Z_22r1m307a.c (2026-11-21-21-p6-r66)
   sha256 8e7c2f29cbfeb10b1e16e37516374f15a069a891ccb3c6c644f47035ae1ec099 (tar-sha256); compiled at -Xr */
char *__cdecl Strcat(char *d, char *s)
{
  char *r;
  r = d;
  goto t1;
l1:
  d++;
t1:
  if (*d != 0)
    goto l1;
  goto t2;
l2:
  *d++ = *s++;
t2:
  if (*s != 0)
    goto l2;
  *d = 0;
  return r;
}
