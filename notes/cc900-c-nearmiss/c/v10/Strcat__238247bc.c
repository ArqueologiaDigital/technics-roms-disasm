/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Z_22r1m307b.c (2026-11-21-21-p6-r66)
   sha256 238247bc100ddeac6e00d1b869293ee7839a56eb26517b7d0b406474560e83aa (tar-sha256); compiled at -O3 -Xr */
char *__cdecl Strcat(char *d, char *s)
{
  char *r;
  r = d;
  while (*d != 0)
    d++;
  while (*s != 0)
    *d++ = *s++;
  *d = 0;
  return r;
}
