/* helper U, round 21r1, module 268, form b: FileIO_CheckMediaIsWritable as a two-case switch falling to -1. */

extern unsigned char GetMediaType(void);

int FileIO_CheckMediaIsWritable(void)
{
  switch (GetMediaType()) {
  case 2:
  case 3:
    return 0;
  }
  return -1;
}
