/* helper Q, round 20r1, module 307 (audio/note_voice_mapping.s): library string routines with stack arguments
   (__cdecl: plain ret, caller pops). */

int __cdecl String_Compare(unsigned char *s1, unsigned char *s2, unsigned int n)
{
  char r;
  for (; n != 0 && *s2 == *s1; s1++, s2++, n--)
    if (*s1 == 0) return 0;
  r = 0;
  if (n != 0) r = *s1 - *s2;
  return r;
}

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
