/* helper Z, round 22r1, module 307 (audio/note_voice_mapping.s), form a: String_Compare and Strcat (library string
   routines with stack arguments, __cdecl).
   String_Compare: run r58's p6_Q_20r1m307a@Xr differed at +29 only in which string is loaded and which compared
   from memory (V4.23 `ld a, (xix); cp a, (xde)`, the ROM `ld a, (xde); cp a, (xix)`): V4.23 loads the right
   operand of `==`, so here the operands are swapped, `*s1 == *s2`.
   Strcat: the ROM keeps the return value in a copy (`ld xde, d; ld xhl, xde`) and walks the parameter itself; both
   of its loops are entered by a jump to the test at the bottom (no duplicated guard as V4.23 writes for a while
   loop).  Here the copy is a local and the loops are spelled with goto in exactly that shape.
   Form b: Strcat with the copy local and ordinary while loops (only the register spot changed). */

int __cdecl String_Compare(unsigned char *s1, unsigned char *s2, unsigned int n)
{
  char r;
  for (; n != 0 && *s1 == *s2; s1++, s2++, n--)
    if (*s1 == 0) return 0;
  r = 0;
  if (n != 0) r = *s1 - *s2;
  return r;
}

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
