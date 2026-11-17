/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_2a.c (2026-11-16-35-p6-r3)
   sha256 c97b2399af5c6580229970cea088ec622459e83731fa38d6c7f60b660d01c853 (tar-sha256); compiled at -Xr */
unsigned char MIDI_GetEventSizeFromByte(unsigned char a)
{
  unsigned char n;
  switch (a & 0xf0) {
  case 0x90: n = 5; break;
  case 0xb0: case 0xc0: n = 7; break;
  default:
    switch (a) {
    case 0x80: n = 4; break;
    case 0x85: case 0x86: n = 2; break;
    case 0xd0: case 0xd1: n = 4; break;
    case 0xd2: n = 5; break;
    case 0xd3: n = 4; break;
    case 0x81: n = 1; break;
    default: n = 0;
    }
  }
  return n;
}
