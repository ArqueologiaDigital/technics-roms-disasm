/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/note_voice_mapping.c (2026-11-16-39-p6-r7)
   sha256 8a29261b94f01f7b5c23bde2a2c4bb145bf30a06de26c1637c0f6703814dcd23 (tar-sha256); compiled at -Xr
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
