/* helper Q, round 20r1, module 268 (demo/file_demo_proc.s): writable-media check. */

extern unsigned char GetMediaType(void);

int FileIO_CheckMediaIsWritable(void)
{
  unsigned char t;
  t = GetMediaType();
  if (t == 2 || t == 3) return 0;
  return -1;
}
