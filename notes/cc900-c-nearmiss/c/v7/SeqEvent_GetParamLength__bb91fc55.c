/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_b.c (2026-11-16-40-p6-r8)
   sha256 bb91fc5534e321d3df1a30e2194c2b64805584e85701d3003e04357c7311bc4b (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
