/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_3a.c (2026-11-16-38-p6-r6)
   sha256 08077e5f71e6fd71c8809069ff7c2ec22415c371e919999a81e5dbe9e7f09f47 (tar-sha256); compiled at -Xr */
int SeqEvent_GetParamLength(unsigned char a)
{
  int n;
  switch (a & 0xf0) {
  case 0x90: n = 6; break;
  case 0xb0: case 0xc0: n = 6; break;
  default:
    switch (a) {
    case 0xd2: n = 4; break;
    case 0x80: n = 4; break;
    case 0xd0: case 0xd1: case 0xd3: case 0xa0: n = 3; break;
    case 0x85: case 0x86: n = 2; break;
    case 0x81: case 0x82: n = 1; break;
    default: n = -1;
    }
  }
  return n;
}
