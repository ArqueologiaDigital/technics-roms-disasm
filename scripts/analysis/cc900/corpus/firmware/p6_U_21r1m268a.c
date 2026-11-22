/* helper U, round 21r1, module 268, form a: FileIO_CheckMediaIsWritable with `return -1` first (the ROM's
   order: both compares jump to the `return 0` placed last), i.e. the negated test. */

extern unsigned char GetMediaType(void);

int FileIO_CheckMediaIsWritable(void)
{
  unsigned char t;
  t = GetMediaType();
  if (t != 2 && t != 3) return -1;
  return 0;
}
