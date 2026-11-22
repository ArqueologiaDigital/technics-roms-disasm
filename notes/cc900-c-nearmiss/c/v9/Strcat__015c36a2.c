/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/note_voice_mapping_m307_xs.c (2026-11-21-22-p6-r67)
   sha256 015c36a25bf7861aac1a159817225f43c05a9409fca15886250deadda00ee357 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -XS -Xr */
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
