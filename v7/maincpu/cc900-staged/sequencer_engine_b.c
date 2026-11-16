/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_29f8[];
extern unsigned char __near SEQ_SONG_RECORD[];
extern unsigned char SEQ_SONG_SLOTS[];

unsigned char MIDI_GetEventSize(unsigned char a)
{
  unsigned char n;
  switch (a & 0xf0) {
  case 0x90: n = 6; break;
  case 0xb0: case 0xc0: n = 6; break;
  default:
    switch (a) {
    case 0x80: n = 4; break;
    case 0x85: case 0x86: n = 2; break;
    case 0xd0: case 0xd1: n = 3; break;
    case 0xd2: n = 4; break;
    case 0xd3: n = 3; break;
    default: n = 1;
    }
  }
  return n;
}

void Part_CopyBlock16(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *q, *e;
  if (a == 0) p = SEQ_SONG_RECORD + 256;
  else p = SEQ_SONG_SLOTS + (unsigned long)((unsigned char *)((unsigned long)(unsigned char)(a - 1) << 11) + 256);
  q = buf; e = buf + 16;
  do *p++ = *q++; while (q < e);
}

void SeqData_CopyBlock2K(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *q, *e;
  if (a == 0) p = SEQ_SONG_RECORD + 256;
  else p = SEQ_SONG_SLOTS + (unsigned long)((unsigned char *)((unsigned long)(unsigned char)(a - 1) << 11) + 256);
  q = buf; e = buf + 16;
  do *q++ = *p++; while (q < e);
}

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


