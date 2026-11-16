/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

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

unsigned long Param_SignExtendReturn_Helper(unsigned char *p)
{
  unsigned long a, b, c;
  a = (unsigned long)(p[9] & 0x7f) << 14;
  b = (unsigned long)(p[10] & 0x7f) << 7;
  c = p[11] & 0x7f;
  return a | b | c;
}
