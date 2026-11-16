/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
extern unsigned char __near ram_42e;
extern unsigned int __near ram_28c3;
extern unsigned int __near SEQ_COUNT_IN;
unsigned char Rhythm_CheckHighBitFlag(void) { return (ram_42e & 0x80) >> 7; }
void SeqAcc_UpdateEndPosition(void) { unsigned int e = ram_28c3; if (SEQ_COUNT_IN > e) SEQ_COUNT_IN = e; }

extern unsigned char __near ram_f1d2;
extern unsigned char __near SQEDT_TRKMRG_TRACK_A;
extern unsigned char __near SQEDT_TRKMRG_TRACK_B;
extern unsigned char __near SQEDT_TRKMRG_TRACK_C;
extern unsigned char __near SQEDT_MDEL_TRACK;
extern unsigned char __near SQEDT_MERS_TRACK;
extern unsigned char __near SQEDT_MERS_CHOICE;
extern unsigned char __near SQEDT_MINS_TRACK_A;
extern unsigned char __near SQEDT_MINS_TRACK_B;
extern unsigned char __near SQEDT_MINS_REPEAT;
extern unsigned char __near SQEDT_MCP_TRACK_A;
extern unsigned char __near SQEDT_MCP_TRACK_B;
extern unsigned char __near SQEDT_MCP_REPEAT;
extern unsigned char __near SQEDT_VELOCNG_TRACK;
extern unsigned char __near ram_f22d;
extern unsigned char __near SQEDT_VELOCNG_AMOUNT;
extern unsigned char __near ram_f233;
extern unsigned char __near ram_f234;
extern unsigned char __near SQEDT_QTZ_TRACK;
extern unsigned char __near SQEDT_QTZ_VALUE;
extern unsigned char __near ram_25e6;
extern unsigned char __near SQEDT_QTZ_STRENGTH;
extern unsigned char __near SQEDT_QTZ_WINDOW;
extern unsigned char __near SQEDT_NOTECNG_TRACK;
extern unsigned char __near ram_2616;
extern unsigned char __near ram_2658;
extern unsigned char __near SQEDT_TRNS_TRACK;
extern unsigned char __near ram_2622;
extern unsigned char __near ram_2624;
extern unsigned char __near SQEDT_ADVDLY_TRACK;
extern unsigned char __near ram_260c;
extern unsigned int __near SQEDT_TRKCLR_MASK;
extern unsigned int __near SQEDT_MDEL_FROM;
extern unsigned int __near ram_f1d9;
extern unsigned int __near SQEDT_MDEL_LAST;
extern unsigned int __near SQEDT_MERS_FROM;
extern unsigned int __near ram_f1de;
extern unsigned int __near SQEDT_MERS_LAST;
extern unsigned int __near SQEDT_MINS_FROM;
extern unsigned int __near ram_f1e4;
extern unsigned int __near SQEDT_MINS_AT;
extern unsigned int __near SQEDT_MINS_LAST;
extern unsigned int __near SQEDT_MCP_FROM;
extern unsigned int __near ram_f1ec;
extern unsigned int __near SQEDT_MCP_AT;
extern unsigned int __near SQEDT_MCP_LAST;
extern unsigned int __near SQEDT_VELOCNG_FROM;
extern unsigned int __near ram_f22b;
extern unsigned int __near SQEDT_VELOCNG_LAST;
extern unsigned int __near SQEDT_QTZ_FROM;
extern unsigned int __near ram_f1f4;
extern unsigned int __near SQEDT_QTZ_LAST;
extern unsigned int __near SQEDT_NOTECNG_FROM;
extern unsigned int __near SQEDT_NOTECNG_LAST;
extern unsigned int __near ram_2614;
extern unsigned int __near ram_261a;
extern unsigned int __near SQEDT_TRNS_FROM;
extern unsigned int __near SQEDT_TRNS_LAST;
extern unsigned int __near SQEDT_ADVDLY_FROM;
extern unsigned int __near SQEDT_ADVDLY_LAST;
extern unsigned int __near ram_260a;
extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned char __near ram_2524;
extern unsigned char __near ram_1d5e;
extern unsigned char __near ram_e386;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near SEQ_TRACK_ASSIGN[];
struct evq { unsigned int w; unsigned char c, e; };
extern struct evq __near ram_e390[];
extern unsigned int __near ram_e3b8;

void PartCtrl_AppendToEventQueue(unsigned char w, unsigned char c, unsigned char e)
{
  if (ram_e3b8 >= 10) return;
  ram_e390[ram_e3b8].w = w;
  ram_e390[ram_e3b8].c = c;
  ram_e390[ram_e3b8].e = e;
  ram_e3b8++;
}

void Part_CheckAndSetModifiedFlags(unsigned char *r)
{
  if (r[2] & 0x80) { r[2] &= ~0x80; r[0] |= 0x04; }
  if (r[4] & 0x80) { r[4] &= ~0x80; r[0] |= 0x01; }
  if (r[5] & 0x80) { r[5] &= ~0x80; r[0] |= 0x02; }
}

void SeqParams_InitDefaults(void)
{
  ram_f1d2 = 0; SQEDT_TRKCLR_MASK = 0; SQEDT_TRKMRG_TRACK_A = 1; SQEDT_TRKMRG_TRACK_B = 2; SQEDT_TRKMRG_TRACK_C = 3; SQEDT_MDEL_TRACK = 1;
  SQEDT_MDEL_FROM = 1; ram_f1d9 = 1; SQEDT_MDEL_LAST = 1; SQEDT_MERS_TRACK = 1; SQEDT_MERS_FROM = 1; ram_f1de = 1;
  SQEDT_MERS_LAST = 1; SQEDT_MERS_CHOICE = 0; SQEDT_MINS_TRACK_A = 1; SQEDT_MINS_FROM = 1; ram_f1e4 = 1; SQEDT_MINS_TRACK_B = 1;
  SQEDT_MINS_AT = 1; SQEDT_MINS_LAST = 1; SQEDT_MINS_REPEAT = 0; SQEDT_MCP_TRACK_A = 1; SQEDT_MCP_FROM = 1; ram_f1ec = 1;
  SQEDT_MCP_TRACK_B = 1; SQEDT_MCP_AT = 1; SQEDT_MCP_REPEAT = 0; SQEDT_MCP_LAST = 1; SQEDT_VELOCNG_TRACK = 1; SQEDT_VELOCNG_FROM = 1;
  ram_f22b = 1; SQEDT_VELOCNG_LAST = 1; ram_f22d = 0; SQEDT_VELOCNG_AMOUNT = 0; ram_f233 = 0; ram_f234 = 0;
  SQEDT_QTZ_TRACK = 1; SQEDT_QTZ_FROM = 1; ram_f1f4 = 1; SQEDT_QTZ_LAST = 1; SQEDT_QTZ_VALUE = 3; ram_25e6 = 0;
  SQEDT_QTZ_STRENGTH = 100; SQEDT_QTZ_WINDOW = 100; SQEDT_NOTECNG_TRACK = 1; SQEDT_NOTECNG_FROM = 1; SQEDT_NOTECNG_LAST = 1; ram_2614 = 1;
  ram_2616 = 60; ram_2658 = 60; ram_261a = 1; SQEDT_TRNS_TRACK = 1; SQEDT_TRNS_FROM = 1; SQEDT_TRNS_LAST = 1;
  ram_2622 = 0; ram_2624 = 1; SQEDT_ADVDLY_TRACK = 1; SQEDT_ADVDLY_FROM = 1; SQEDT_ADVDLY_LAST = 1; ram_260a = 1;
  ram_260c = 0;
}

void SeqPlay_InitStartState(void)
{
  SEQ_CONTROL_FLAGS |= 0x10;
  SEQ_RTMCFG |= 0x04;
  ram_2524 = 1;
  if (SEQ_START_MEASURE != 1) { ram_1d5e = 250; SEQ_RTMCFG |= 0x08; }
  else {
    if (CURRENT_TITLE == 0x85 || CURRENT_TITLE == 0x86) {
      if (SEQ_CYCLE_FLAGS & 0x02) ram_1d5e = 250; else ram_1d5e = 0;
    } else if (CURRENT_TITLE == 0x87 || CURRENT_TITLE == 0x88) ram_1d5e = 0;
    else if (SEQ_CYCLE_FLAGS & 0x01) ram_1d5e = 250; else ram_1d5e = 0;
    SEQ_RTMCFG &= ~0x08;
  }
  ram_e386 = 1;
}

void SeqPlay_ResetStartState(void)
{
  SEQ_CONTROL_FLAGS &= ~0x10;
  ram_1d5e = 0;
  ram_2524 = 0;
  if (CURRENT_TITLE == 142) return;
  if (ram_e386 == 1) SEQ_RTMCFG &= ~0x04;
  ram_e386 = 0;
}

unsigned char SeqVoice_FindDrumPartIndex(void)
{
  unsigned char i;
  SEQ_EDIT_FLAGS &= ~0x04;
  i = 0;
  do {
    if (SEQ_TRACK_ASSIGN[i] == 0x10) { SEQ_EDIT_FLAGS |= 0x04; return i + 1; }
    i++;
  } while (i < 16);
  return 0;
}

unsigned char Seq_ComputePercentClamped99(void)
{
  unsigned int d = 0x4d8, n = SEQ_FREE_BLOCKS;
  unsigned char r;
  if (n > 0x258) do { d >>= 1; n >>= 1; } while (n > 0x258);
  r = n * 100 / d;
  if (r == 100) r = 99;
  return r;
}

unsigned char VoiceAlloc_TestBitHigh(void)
{
  unsigned char i = 0, t;
  do {
    if ((1 << i) & SEQ_TRACK_MASK) {
      t = SEQ_TRACK_ASSIGN[i];
      if (t == 15) return 15;
      if (t == 16) return 16;
    }
    i++;
  } while (i < 16);
  return i;
}

extern unsigned int __near ram_2526[];
extern unsigned int __near ram_2590;
extern unsigned char __near ram_2546[];
extern unsigned char __near ram_2592;
extern unsigned char __near SEQ_SONG_RECORD[];
extern unsigned char SEQ_SONG_SLOTS[][0x800];

unsigned char Part_ReadByteDirect(unsigned char a, unsigned int o)
{
  unsigned char *p;
  if (a == 0) p = &SEQ_SONG_RECORD[o];
  else p = &SEQ_SONG_SLOTS[(unsigned char)(a - 1)][o];
  return *p;
}

void Part_WriteByte(unsigned char a, unsigned int o, unsigned char v)
{
  unsigned char *p;
  if (a == 0) p = &SEQ_SONG_RECORD[o];
  else p = &SEQ_SONG_SLOTS[(unsigned char)(a - 1)][o];
  *p = v;
}

void SeqScan_ClearMatchingBarSlots(void)
{
  unsigned int i = 0;
  do {
    if (ram_2546[i] == ram_2592 && ram_2526[i] == ram_2590) { ram_2526[i] = 0xffff; ram_2546[i] = 0xff; }
    i++;
  } while (i < 16);
}

extern unsigned char __near CURRENT_MODE;
extern unsigned int __near ram_232a;
extern unsigned int __near ram_232c;

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

unsigned char SeqPlay_CheckRepeatActive(void)
{
  unsigned char r = 0, m;
  unsigned int b, w;
  if (CURRENT_TITLE != 0x87 && CURRENT_TITLE != 0x88) {
    b = ram_232c; w = ram_232a; m = CURRENT_MODE;
    if (m == 0x0b) { if (SEQ_CYCLE_FLAGS & 0x02) { if (b <= w) r = 1; } }
    else if (m != 0x13) { if (SEQ_CYCLE_FLAGS & 0x01) { if (b <= w) r = 1; } }
  }
  return r;
}

struct sbent { unsigned char f[4]; unsigned int pos; unsigned char g[4]; unsigned char prev, next; };
struct sbhdr { unsigned char head, tail; };
extern struct sbent __near ram_1ffa[];
extern struct sbhdr __near ram_1ff6;
extern unsigned int __near ram_22fa;

unsigned char Chan_IsActive(unsigned char a)
{
  unsigned int m, t;
  if (a >= 1 && a <= 16) {
    m = 1 << (a - 1);
    t = SEQ_TRACK_MASK;
    if ((t & m) == 0) return 0;
  }
  return 1;
}

void SeqBuffer_FindMinPosition(void)
{
  struct sbent *t;
  unsigned char i = ram_1ff6.head;
  unsigned int m = 0xffff, v;
  if (i != 0xff) {
    t = ram_1ffa;
    do {
      v = t[i].pos;
      if (v < m) m = v;
      i = t[i].next;
    } while (i != 0xff);
  }
  ram_22fa = m;
}
