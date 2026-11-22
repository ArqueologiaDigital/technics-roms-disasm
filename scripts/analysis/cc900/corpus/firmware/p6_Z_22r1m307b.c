/* helper Z, round 22r1, module 307 (audio/note_voice_mapping.s), form b: Strcat with the return value kept in a
   local copy and the parameter walked (the ROM's `ld xde, d; ld xhl, xde`), ordinary while loops; and
   String_Compare with the operands swapped as in form a but the loop as a while with the test first. */

int __cdecl String_Compare(unsigned char *s1, unsigned char *s2, unsigned int n)
{
  char r;
  while (n != 0 && *s1 == *s2) {
    if (*s1 == 0) return 0;
    s1++;
    s2++;
    n--;
  }
  r = 0;
  if (n != 0) r = *s1 - *s2;
  return r;
}

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
