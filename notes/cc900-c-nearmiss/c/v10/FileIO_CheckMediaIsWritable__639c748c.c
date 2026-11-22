/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m268b.c (2026-11-21-7-p6-r62)
   sha256 639c748cf41adced460766e91db3797b4249426c26f311f9fd557864e38723ca (tar-sha256); compiled at -O3 -Xr */
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
