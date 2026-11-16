/* Phase 6, helper B, round 1, form b: the same functions as p6_B_1a.c, other C shapes (temporaries, loop forms,
   switch versus if chains, compare order).  RAM cells reached with a 16-bit absolute operand are __near. */

/* ---- sequencer/sequencer_engine.s ---- */

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

struct nm9 { unsigned char prev, next, x[7]; };
struct nm9hdr { unsigned char h1, t1, h2, t2; };
extern struct nm9 __near ram_1db6[];
extern struct nm9hdr __near ram_1db2;

void NoteMap_RemoveAndRelink(unsigned char a)
{
  struct nm9 *p = &ram_1db6[a];
  unsigned char *q = &p->next;
  unsigned char prev = p->prev, next = *q, t;
  if (prev == 0xff && next == 0xff) { ram_1db2.h1 = 0xff; ram_1db2.t1 = 0xff; }
  else {
    struct nm9 *z = &ram_1db6[next];
    if (prev == 0xff) { ram_1db2.h1 = next; z->prev = prev; }
    else {
      unsigned char *y = &ram_1db6[prev].next;
      if (next == 0xff) { ram_1db2.t1 = prev; *y = 0xff; }
      else { *y = next; z->prev = prev; }
    }
  }
  t = ram_1db2.t2;
  if (t == 0xff) ram_1db2.h2 = a; else ram_1db6[t].next = a;
  p->prev = t;
  ram_1db2.t2 = a;
  *q = 0xff;
}

void NoteMap_RemoveHeadEntry(unsigned char a)
{
  unsigned char e = ram_1db6[a].next;
  ram_1db2.h2 = e;
  if (e == 0xff) ram_1db2.t2 = 0xff;
  else ram_1db6[e].prev = 0xff;
}

struct sbent { unsigned char f[4]; unsigned int pos; unsigned char g[4]; unsigned char prev, next; };
struct sbhdr { unsigned char head, tail; };
extern struct sbent __near ram_1ffa[];
extern struct sbhdr __near ram_1ff6;
extern struct sbhdr __near ram_1ff8;
extern unsigned char __near ram_e38a;
extern unsigned char __near ram_2868;
extern unsigned int __near ram_22fa;

void SeqBuffer_ClearAndInitIteration(void)
{
  unsigned char buf[6];
  unsigned char *p;
  unsigned char i, j;
  p = buf;
  do *p++ = 0xff; while (p < buf + 6);
  ram_1ff6.head = 0xff; ram_1ff6.tail = 0xff;
  ram_1ff8.head = 0; ram_1ff8.tail = 0x3f;
  for (i = 0; i <= 0x3f; i++) {
    for (j = 0; j < 4; j++) ram_1ffa[i].f[j] = buf[j];
    ram_1ffa[i].prev = i - 1;
    ram_1ffa[i].next = i + 1;
  }
  ram_1ffa[0].prev = 0xff;
  ram_1ffa[63].next = 0xff;
}

void SeqBuffer_UnlinkEntry(unsigned char a)
{
  struct sbent *e = &ram_1ffa[a];
  unsigned char prev = e->prev, next = e->next;
  if (prev == 0xff && next == 0xff) { ram_1ff6.head = 0xff; ram_1ff6.tail = 0xff; return; }
  if (prev == 0xff) { ram_1ff6.head = next; ram_1ffa[next].prev = 0xff; return; }
  if (next == 0xff) { ram_1ff6.tail = prev; ram_1ffa[prev].next = 0xff; return; }
  ram_1ffa[next].prev = prev;
  ram_1ffa[prev].next = next;
}

void SeqBuffer_MoveEntryToHead(unsigned char a)
{
  struct sbent *p;
  unsigned char t;
  if (a == 0xff) ram_e38a = 0xff;
  t = ram_1ff8.tail;
  p = &ram_1ffa[a];
  if (t == 0xff) { ram_1ff8.head = a; p->prev = 0xff; }
  else { ram_1ffa[t].next = a; p->prev = t; }
  ram_1ff8.tail = a;
  ram_1ffa[a].next = 0xff;
}

void SeqBuffer_InsertAtHead(unsigned char a)
{
  struct sbent *p;
  unsigned char t = ram_1ff6.tail;
  p = &ram_1ffa[a];
  if (t == 0xff) { ram_1ff6.head = a; p->prev = 0xff; }
  else { ram_1ffa[t].next = a; p->prev = t; }
  ram_1ff6.tail = a;
  ram_1ffa[a].next = 0xff;
}

void SeqBuffer_RemoveLastEntry(void)
{
  struct sbhdr *h = &ram_1ff8;
  unsigned char l = h->head, n;
  if (l == 0xff) return;
  n = ram_1ffa[l].next;
  if (n != 0xff) ram_1ffa[n].prev = 0xff;
  h->head = n;
  if (n == 0xff) ram_2868 = l;
}

void SeqBuffer_FindMinPosition(void)
{
  unsigned char i = ram_1ff6.head;
  unsigned int m = 0xffff;
  while (i != 0xff) {
    if (ram_1ffa[i].pos < m) m = ram_1ffa[i].pos;
    i = ram_1ffa[i].next;
  }
  ram_22fa = m;
}

int SeqEvent_GetParamLength(unsigned char a)
{
  unsigned char c = a & 0xf0;
  if (c == 0xc0 || c == 0xb0 || c == 0x90) return 6;
  if (a == 0x82 || a == 0x81) return 1;
  if (a == 0x86 || a == 0x85) return 2;
  if (a == 0xa0 || a == 0xd3 || a == 0xd1 || a == 0xd0) return 3;
  if (a == 0x80 || a == 0xd2) return 4;
  return -1;
}

unsigned char MIDI_GetEventSizeFromByte(unsigned char a)
{
  unsigned char c = a & 0xf0;
  if (c == 0xc0 || c == 0xb0) return 7;
  if (c == 0x90) return 5;
  if (a == 0x81) return 1;
  if (a == 0xd3) return 4;
  if (a == 0xd2) return 5;
  if (a == 0xd1 || a == 0xd0) return 4;
  if (a == 0x86 || a == 0x85) return 2;
  if (a == 0x80) return 4;
  return 0;
}

unsigned char MIDI_GetEventSize(unsigned char a)
{
  unsigned char c = a & 0xf0;
  if (c == 0xc0 || c == 0xb0 || c == 0x90) return 6;
  if (a == 0xd3) return 3;
  if (a == 0xd2) return 4;
  if (a == 0xd1 || a == 0xd0) return 3;
  if (a == 0x86 || a == 0x85) return 2;
  if (a == 0x80) return 4;
  return 1;
}

unsigned char SeqData_GetEventByteCount(unsigned char *p)
{
  unsigned char e = p[0] & 0xf0;
  if (e == 0xc0 || e == 0xb0) return p[6];
  if (e == 0x90) return p[4];
  if (p[0] == 0xd2) return p[4];
  if (p[0] == 0xd3 || p[0] == 0xd1 || p[0] == 0xd0) return p[3];
  return 0xff;
}

int SeqLoad_ValidateFormat(unsigned char *p)
{
  if (p[5] == 1) {
    switch (p[6]) { case 3: case 6: case 7: case 8: return p[4]; }
  }
  return -102;
}

extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned char __near ram_2524;
extern unsigned char __near ram_1d5e;
extern unsigned char __near ram_e386;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int __near ram_232a;
extern unsigned int __near ram_232c;
extern unsigned char __near SEQ_TRACK_ASSIGN[];

void SeqPlay_InitStartState(void)
{
  SEQ_CONTROL_FLAGS |= 0x10;
  SEQ_RTMCFG |= 0x04;
  ram_2524 = 1;
  if (SEQ_START_MEASURE != 1) { ram_1d5e = 250; SEQ_RTMCFG |= 0x08; }
  else {
    switch (CURRENT_TITLE) {
    case 0x85: case 0x86:
      if (SEQ_CYCLE_FLAGS & 0x02) ram_1d5e = 250; else ram_1d5e = 0;
      break;
    case 0x87: case 0x88:
      ram_1d5e = 0;
      break;
    default:
      if (SEQ_CYCLE_FLAGS & 0x01) ram_1d5e = 250; else ram_1d5e = 0;
    }
    SEQ_RTMCFG &= ~0x08;
  }
  ram_e386 = 1;
}

void SeqPlay_ResetStartState(void)
{
  SEQ_CONTROL_FLAGS &= ~0x10;
  ram_1d5e = 0;
  ram_2524 = 0;
  if (CURRENT_TITLE != 142) {
    if (ram_e386 == 1) SEQ_RTMCFG &= ~0x04;
    ram_e386 = 0;
  }
}

unsigned char SeqPlay_CheckRepeatActive(void)
{
  unsigned char r = 0;
  if (CURRENT_TITLE != 0x87 && CURRENT_TITLE != 0x88) {
    if (CURRENT_MODE == 0x0b) { if ((SEQ_CYCLE_FLAGS & 0x02) && ram_232c <= ram_232a) r = 1; }
    else if (CURRENT_MODE != 0x13 && (SEQ_CYCLE_FLAGS & 0x01) && ram_232c <= ram_232a) r = 1;
  }
  return r;
}

extern unsigned int __near ram_2526[];
extern unsigned int __near ram_2556[];
extern unsigned int __near ram_2590;
extern unsigned char __near ram_2546[];
extern unsigned char __near ram_2576[];
extern unsigned char __near ram_2592;

void SeqScan_SortBarSlots(void)
{
  unsigned int *w = ram_2526;
  unsigned int best = w[0], v, i;
  unsigned char *c = ram_2546;
  unsigned char b = c[0];
  i = 1;
  do {
    if (best == 0xffff) { best = w[i]; b = c[i]; }
    else {
      v = w[i];
      if (v > best || (v >= best && c[i] > b)) {
        if (v != 0xffff) { best = v; b = c[i]; }
      }
    }
    i++;
  } while (i < 16);
}

void SeqScan_SortSecondBar(void)
{
  unsigned int *w = ram_2556;
  unsigned int best = w[0], v, i;
  unsigned char *c = ram_2576;
  unsigned char b = c[0];
  i = 1;
  do {
    if (best == 0xffff) { best = w[i]; b = c[i]; }
    else {
      v = w[i];
      if (v > best || (v >= best && c[i] > b)) {
        if (v != 0xffff) { best = v; b = c[i]; }
      }
    }
    i++;
  } while (i < 16);
}

void SeqScan_ClearMatchingBarSlots(void)
{
  unsigned int i = 0;
  do {
    if (ram_2546[i] == ram_2592 && ram_2526[i] == ram_2590) { ram_2526[i] = 0xffff; ram_2546[i] = 0xff; }
    i++;
  } while (i < 16);
}

int VoiceType_CheckDrumOrControl(unsigned char a, unsigned char *p)
{
  unsigned char f = 0;
  if (*p == 0x82) return 0;
  if ((*p & 0xf0) == 0xc0) { if (p[2] == 0x48 && p[3] == 0) f = 1; }
  else if ((*p & 0xf0) == 0xb0) { if (p[2] == 0x48 && p[3] == 7) f = 1; }
  if (a == 0x15) return f == 1 ? 0 : -1;
  return f == 0 ? 0 : -1;
}

struct evq { unsigned int w; unsigned char c, e; };
extern struct evq __near ram_e390[];
extern unsigned int __near ram_e3b8;

void PartCtrl_AppendToEventQueue(unsigned char w, unsigned char c, unsigned char e)
{
  if (ram_e3b8 < 10) {
    ram_e390[ram_e3b8].w = w;
    ram_e390[ram_e3b8].c = c;
    ram_e390[ram_e3b8].e = e;
    ram_e3b8 = ram_e3b8 + 1;
  }
}

unsigned char VoiceAlloc_TestBitHigh(void)
{
  unsigned char i = 0, t;
  do {
    if (SEQ_TRACK_MASK & (1 << i)) {
      t = SEQ_TRACK_ASSIGN[i];
      if (t == 15) return 15;
      if (t == 16) return 16;
    }
    i++;
  } while (i < 16);
  return i;
}

unsigned char Chan_IsActive(unsigned char a)
{
  if (a < 1 || a > 16 || ((1 << (a - 1)) & SEQ_TRACK_MASK)) return 1;
  return 0;
}

extern unsigned char __near ram_29f8[];
unsigned char VoiceAlloc_TestBitInMap(unsigned int n) { return ram_29f8[(n - 1) >> 3] & (1 << ((n - 1) & 7)); }
void VoiceAlloc_SetBitInMap(unsigned int n) { ram_29f8[(n - 1) >> 3] |= 1 << ((n - 1) & 7); }

unsigned char SeqVoice_FindDrumPartIndex(void)
{
  unsigned char i;
  SEQ_EDIT_FLAGS &= ~0x04;
  for (i = 0; i < 16; i++)
    if (SEQ_TRACK_ASSIGN[i] == 0x10) { SEQ_EDIT_FLAGS |= 0x04; return i + 1; }
  return 0;
}

unsigned char Seq_ComputePercentClamped99(void)
{
  unsigned int d = 0x4d8, n = SEQ_FREE_BLOCKS;
  unsigned char r;
  while (n > 0x258) { d >>= 1; n >>= 1; }
  r = n * 100 / d;
  if (r == 100) return 99;
  return r;
}

void Part_CheckAndSetModifiedFlags(unsigned char *r)
{
  unsigned char *q;
  q = r + 2; if (*q & 0x80) { *q &= ~0x80; *r |= 0x04; }
  q = r + 4; if (*q & 0x80) { *q &= ~0x80; *r |= 0x01; }
  q = r + 5; if (*q & 0x80) { *q &= ~0x80; *r |= 0x02; }
}

/* song slots as a 2-D array */
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

unsigned int Part_ReadWord(unsigned char a, unsigned int o)
{
  unsigned long p;
  if (a == 0) p = (unsigned long)&SEQ_SONG_RECORD[o];
  else p = 0xab000L + ((unsigned long)(unsigned char)(a - 1) << 11) + o;
  return *(unsigned int *)p;
}

void Part_WriteWord(unsigned char a, unsigned int o, unsigned int v)
{
  unsigned long p;
  if (a == 0) p = (unsigned long)&SEQ_SONG_RECORD[o];
  else p = 0xab000L + ((unsigned long)(unsigned char)(a - 1) << 11) + o;
  *(unsigned int *)p = v;
}

unsigned char Part_ReadSubBlock32(unsigned char a, unsigned int i)
{
  unsigned char *p;
  if (a == 0) p = SEQ_TRACK_ASSIGN;
  else p = &SEQ_SONG_SLOTS[(unsigned char)(a - 1)][32];
  return *(p + i - 1);
}

void SeqData_CopyBlock2K(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *e;
  if (a == 0) p = &SEQ_SONG_RECORD[256];
  else p = &SEQ_SONG_SLOTS[(unsigned char)(a - 1)][256];
  e = buf + 16;
  do *buf++ = *p++; while (buf < e);
}

void Part_CopyBlock16(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *e;
  if (a == 0) p = &SEQ_SONG_RECORD[256];
  else p = &SEQ_SONG_SLOTS[(unsigned char)(a - 1)][256];
  e = buf + 16;
  do *p++ = *buf++; while (buf < e);
}

void Part_CopyToBuffer(unsigned char a, unsigned char c)
{
  unsigned char *s, *d;
  unsigned int i;
  if (a == 0) s = &SEQ_SONG_RECORD[736];
  else s = &SEQ_SONG_SLOTS[(unsigned char)(a - 1)][736];
  if (c == 0) d = &SEQ_SONG_RECORD[736];
  else d = &SEQ_SONG_SLOTS[(unsigned char)(c - 1)][736];
  i = 0;
  do { *d++ = *s++; i++; } while (i < 0x520);
}

/* ---- audio/note_voice_mapping.s, the part built without -O ---- */

struct nent { unsigned char e0, e1, e2, e3, e4; };
struct nrec { unsigned char b0, count, b2, b3; struct nent ent[32]; };
struct t3 { unsigned char k, f1, f2; };
struct lnk { unsigned char a, b; };
extern struct t3 __near ram_c5ca[];
extern struct lnk __near ram_e7e8[];
extern unsigned char NoteMap_LinkByte_Table[];

unsigned char NoteMap_LookupAndMergeVoice(struct nrec *r)
{
  struct t3 *t = ram_c5ca;
  struct lnk *lk = ram_e7e8;
  unsigned char n = 0x20;
  unsigned char h, k;
  unsigned int i;
  if (r->b3 >= 2) { r->count = 0; return 0; }
  h = NoteMap_LinkByte_Table[r->b3];
  i = 0;
  k = lk[h].a;
  if (k != h) do {
    r->ent[i].e0 = t[k].f1;
    r->ent[i].e1 = t[k].f2;
    r->ent[i].e4 = 0;
    k = lk[k].a;
    i++;
  } while (k != h);
  return r->count = i;
}

unsigned char Voice_LookupTableEntries(struct nrec *r)
{
  struct t3 *t = ram_c5ca;
  struct lnk *lk = ram_e7e8;
  unsigned char n = 0x20;
  unsigned char h, k;
  unsigned int i;
  if (r->b3 >= 2) { r->count = 0; return 0; }
  h = NoteMap_LinkByte_Table[r->b3];
  i = 0;
  k = lk[h].a;
  if (k != h) do {
    r->ent[i].e0 = t[k].f1;
    r->ent[i].e1 = 0;
    r->ent[i].e4 = 0;
    k = lk[k].a;
    i++;
  } while (k != h);
  return r->count = i;
}

unsigned char NoteMap_FindLinkedSlotByKey(struct nrec *r, unsigned char idx)
{
  struct t3 *t = ram_c5ca;
  struct lnk *lk = ram_e7e8;
  unsigned char h, key, l;
  h = NoteMap_LinkByte_Table[r->b3];
  key = r->ent[idx].e0;
  l = lk[h].b;
  if (l == h) return l;
  do {
    if (t[l].f1 == key) return l;
    l = lk[l].b;
  } while (l != h);
  return l;
}

unsigned char NoteMap_MergeEntries(struct nrec *d, struct nrec *s, unsigned char *f)
{
  unsigned int n, i;
  d->b0 = s->b0;
  d->b2 = s->b2;
  d->b3 = s->b3;
  n = 0;
  for (i = 0; i < s->count; i++) {
    if (s->ent[i].e0 >= (f[1] >> 1) && s->ent[i].e0 <= (f[0] & 0x7f)) {
      d->ent[n] = s->ent[i];
      n++;
    }
  }
  d->count = n;
  return n;
}

void InitChannelState_Che_InitVal(struct nrec *r)
{
  unsigned int i;
  for (i = 0; i < r->count; i++) {
    r->ent[i].e4 = 0;
    if (r->ent[i].e1) {
      r->ent[i].e2 = r->ent[i].e0;
      r->ent[i].e3 = r->ent[i].e0;
    }
  }
}

void NoteMap_LinkVoiceSlots(struct lnk *lk, unsigned char c, unsigned char e)
{
  lk[c].b = lk[e].b;
  lk[c].a = e;
  lk[lk[e].b].a = c;
  lk[e].b = c;
}

void NoteMap_SwapVoiceLinks(struct lnk *lk, unsigned char c)
{
  lk[lk[c].a].b = lk[c].b;
  lk[lk[c].b].a = lk[c].a;
}

extern unsigned long __near ram_cfb4;
extern unsigned long __near ram_cfb8;
extern unsigned long __near ram_cfbc;
extern unsigned long __near ram_cfc0;
extern unsigned long __near ram_cfc4;
extern unsigned int __near ram_cfc8;
extern unsigned int __near ram_cfca;
extern unsigned int __near ram_cfcc;
extern unsigned int __near ram_cfce;
extern unsigned int __near ram_cfd0[];
extern unsigned int __near ram_d010[];
extern unsigned int __near ram_d050[];

void COMM_SendDataReturn(void)
{
  unsigned int i;
  ram_cfb4 = 0xffffffff; ram_cfb8 = 0xffffffff; ram_cfbc = 0xffffffff; ram_cfc0 = 0xffffffff; ram_cfc4 = 0xffffffff;
  ram_cfc8 = 0xffff; ram_cfca = 0xffff; ram_cfcc = 0xffff; ram_cfce = 0xffff;
  i = 0;
  if (i <= 24) do {
    ram_cfd0[i] = 0xffff;
    ram_d010[i] = 0xffff;
    ram_d050[i] = 0xffff;
    i++;
  } while (i <= 24);
}
