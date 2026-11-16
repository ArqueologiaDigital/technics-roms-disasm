/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine.c (2026-11-16-36-p6-staged-r4)
   sha256 cf87d12a4ad49fb769655d9972af2f92b36f5db5a8af9024f75c9fbf40b4ef31 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
