/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/note_voice_mapping.c (2026-11-16-36-p6-staged-r4)
   sha256 1f85ccedcbd346e18afa103bff51278a551efa3f1e842ef18149fa12ac4b3b73 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near ACTIVE_TITLE;
unsigned char CommPort_StatusCheck_Compare(unsigned char a, unsigned char c)
{
  unsigned char r;
  if (a == c) {
    switch ((unsigned char)ACTIVE_TITLE) {
    case 0x0a: case 0x0b: case 0x0c: case 0x0e: case 0xd6: r = 0; break;
    default: r = 0xff;
    }
  } else r = 0xff;
  return r;
}
