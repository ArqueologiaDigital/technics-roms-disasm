/* Phase 6, helper B, round 1, form a: leaf functions of v10's sequencer/sequencer_engine.s (an -O file) and of the
   part of audio/note_voice_mapping.s built without -O, each under its firmware name.  RAM cells reached with a
   16-bit absolute operand are __near; plain externs are 24-bit. */

/* ---- sequencer/sequencer_engine.s ---- */

extern unsigned char __near ram_f1d2, __near SQEDT_TRKMRG_TRACK_A, __near SQEDT_TRKMRG_TRACK_B, __near SQEDT_TRKMRG_TRACK_C,
  __near SQEDT_MDEL_TRACK, __near SQEDT_MERS_TRACK, __near SQEDT_MERS_CHOICE, __near SQEDT_MINS_TRACK_A,
  __near SQEDT_MINS_TRACK_B, __near SQEDT_MINS_REPEAT, __near SQEDT_MCP_TRACK_A, __near SQEDT_MCP_TRACK_B,
  __near SQEDT_MCP_REPEAT, __near SQEDT_VELOCNG_TRACK, __near ram_f22d, __near SQEDT_VELOCNG_AMOUNT, __near ram_f233,
  __near ram_f234, __near SQEDT_QTZ_TRACK, __near SQEDT_QTZ_VALUE, __near ram_25e6, __near SQEDT_QTZ_STRENGTH,
  __near SQEDT_QTZ_WINDOW, __near SQEDT_NOTECNG_TRACK, __near ram_2616, __near ram_2658, __near SQEDT_TRNS_TRACK,
  __near ram_2622, __near ram_2624, __near SQEDT_ADVDLY_TRACK, __near ram_260c;
extern unsigned int __near SQEDT_TRKCLR_MASK, __near SQEDT_MDEL_FROM, __near ram_f1d9, __near SQEDT_MDEL_LAST,
  __near SQEDT_MERS_FROM, __near ram_f1de, __near SQEDT_MERS_LAST, __near SQEDT_MINS_FROM, __near ram_f1e4,
  __near SQEDT_MINS_AT, __near SQEDT_MINS_LAST, __near SQEDT_MCP_FROM, __near ram_f1ec, __near SQEDT_MCP_AT,
  __near SQEDT_MCP_LAST, __near SQEDT_VELOCNG_FROM, __near ram_f22b, __near SQEDT_VELOCNG_LAST, __near SQEDT_QTZ_FROM,
  __near ram_f1f4, __near SQEDT_QTZ_LAST, __near SQEDT_NOTECNG_FROM, __near SQEDT_NOTECNG_LAST, __near ram_2614,
  __near ram_261a, __near SQEDT_TRNS_FROM, __near SQEDT_TRNS_LAST, __near SQEDT_ADVDLY_FROM, __near SQEDT_ADVDLY_LAST,
  __near ram_260a;

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

/* two doubly linked lists of 9-byte nodes at 0x1db6; 0x1db2 = head / tail of list 1, head / tail of list 2 */
struct nm9 { unsigned char prev, next, x[7]; };
struct nm9hdr { unsigned char h1, t1, h2, t2; };
extern struct nm9 __near ram_1db6[];
extern struct nm9hdr __near ram_1db2;

void NoteMap_RemoveAndRelink(unsigned char a)
{
  struct nm9 *p = &ram_1db6[a];
  unsigned char prev = p->prev, next = p->next;
  if (prev == 0xff && next == 0xff) { ram_1db2.h1 = 0xff; ram_1db2.t1 = 0xff; }
  else if (prev == 0xff) { ram_1db2.h1 = next; ram_1db6[next].prev = 0xff; }
  else if (next == 0xff) { ram_1db2.t1 = prev; ram_1db6[prev].next = 0xff; }
  else { ram_1db6[prev].next = next; ram_1db6[next].prev = prev; }
  if (ram_1db2.t2 == 0xff) { ram_1db2.h2 = a; p->prev = 0xff; }
  else { ram_1db6[ram_1db2.t2].next = a; p->prev = ram_1db2.t2; }
  ram_1db2.t2 = a;
  p->next = 0xff;
}

void NoteMap_RemoveHeadEntry(unsigned char a)
{
  unsigned char e = ram_1db6[a].next;
  ram_1db2.h2 = e;
  if (e == 0xff) ram_1db2.t2 = e;
  else ram_1db6[e].prev = 0xff;
}

/* 64 buffer slots of 12 bytes at 0x1ffa; 0x1ff6 = used list, 0x1ff8 = free list */
struct sbent { unsigned char f[4]; unsigned int pos; unsigned char g[4]; unsigned char prev, next; };
struct sbhdr { unsigned char head, tail; };
extern struct sbent __near ram_1ffa[];
extern struct sbhdr __near ram_1ff6, __near ram_1ff8;
extern unsigned char __near ram_e38a, __near ram_2868;
extern unsigned int __near ram_22fa;

void SeqBuffer_ClearAndInitIteration(void)
{
  unsigned char buf[6];
  unsigned char *p, *e;
  unsigned char i, j;
  e = buf; p = e; e += 6;
  do *p++ = 0xff; while (p < e);
  ram_1ff6.head = 0xff; ram_1ff6.tail = 0xff;
  ram_1ff8.head = 0; ram_1ff8.tail = 0x3f;
  i = 0;
  do {
    j = 0;
    do { ram_1ffa[i].f[j] = buf[j]; j++; } while (j < 4);
    ram_1ffa[i].prev = i - 1;
    ram_1ffa[i].next = i + 1;
    i++;
  } while (i <= 0x3f);
  ram_1ffa[0].prev = 0xff;
  ram_1ffa[63].next = 0xff;
}

void SeqBuffer_UnlinkEntry(unsigned char a)
{
  unsigned char prev = ram_1ffa[a].prev, next = ram_1ffa[a].next;
  if (prev == 0xff && next == 0xff) { ram_1ff6.head = 0xff; ram_1ff6.tail = 0xff; }
  else if (prev == 0xff) { ram_1ff6.head = next; ram_1ffa[next].prev = 0xff; }
  else if (next == 0xff) { ram_1ff6.tail = prev; ram_1ffa[prev].next = 0xff; }
  else { ram_1ffa[next].prev = prev; ram_1ffa[prev].next = next; }
}

void SeqBuffer_MoveEntryToHead(unsigned char a)
{
  unsigned char t;
  if (a == 0xff) ram_e38a = 0xff;
  t = ram_1ff8.tail;
  if (t == 0xff) { ram_1ff8.head = a; ram_1ffa[a].prev = 0xff; }
  else { ram_1ffa[t].next = a; ram_1ffa[a].prev = t; }
  ram_1ff8.tail = a;
  ram_1ffa[a].next = 0xff;
}

void SeqBuffer_InsertAtHead(unsigned char a)
{
  unsigned char t = ram_1ff6.tail;
  if (t == 0xff) { ram_1ff6.head = a; ram_1ffa[a].prev = 0xff; }
  else { ram_1ffa[t].next = a; ram_1ffa[a].prev = t; }
  ram_1ff6.tail = a;
  ram_1ffa[a].next = 0xff;
}

void SeqBuffer_RemoveLastEntry(void)
{
  unsigned char l = ram_1ff8.head, h;
  if (l == 0xff) return;
  h = ram_1ffa[l].next;
  if (h != 0xff) ram_1ffa[h].prev = 0xff;
  ram_1ff8.head = h;
  if (h == 0xff) ram_2868 = l;
}

void SeqBuffer_FindMinPosition(void)
{
  unsigned char i = ram_1ff6.head;
  unsigned int m = 0xffff;
  if (i != 0xff) do {
    if (ram_1ffa[i].pos < m) m = ram_1ffa[i].pos;
    i = ram_1ffa[i].next;
  } while (i != 0xff);
  ram_22fa = m;
}

/* event lengths from the status byte */
int SeqEvent_GetParamLength(unsigned char a)
{
  switch (a & 0xf0) { case 0x90: case 0xb0: case 0xc0: return 6; }
  switch (a) {
  case 0xd2: case 0x80: return 4;
  case 0xd0: case 0xd1: case 0xd3: case 0xa0: return 3;
  case 0x85: case 0x86: return 2;
  case 0x81: case 0x82: return 1;
  }
  return -1;
}

unsigned char MIDI_GetEventSizeFromByte(unsigned char a)
{
  switch (a & 0xf0) { case 0x90: return 5; case 0xb0: case 0xc0: return 7; }
  switch (a) {
  case 0x80: return 4;
  case 0x85: case 0x86: return 2;
  case 0xd0: case 0xd1: return 4;
  case 0xd2: return 5;
  case 0xd3: return 4;
  case 0x81: return 1;
  }
  return 0;
}

unsigned char MIDI_GetEventSize(unsigned char a)
{
  switch (a & 0xf0) { case 0x90: case 0xb0: case 0xc0: return 6; }
  switch (a) {
  case 0x80: return 4;
  case 0x85: case 0x86: return 2;
  case 0xd0: case 0xd1: return 3;
  case 0xd2: return 4;
  case 0xd3: return 3;
  }
  return 1;
}

unsigned char SeqData_GetEventByteCount(unsigned char *p)
{
  int n;
  switch (p[0] & 0xf0) {
  case 0x90: n = 4; break;
  case 0xb0: case 0xc0: n = 6; break;
  default:
    switch (p[0]) {
    case 0xd2: n = 4; break;
    case 0xd0: case 0xd1: case 0xd3: n = 3; break;
    default: return 0xff;
    }
  }
  return p[n];
}

int SeqLoad_ValidateFormat(unsigned char *p)
{
  unsigned char t;
  if (p[5] == 1) {
    t = p[6];
    if (t == 3 || t == 6 || t == 7 || t == 8) return p[4];
  }
  return -102;
}

extern unsigned char __near SEQ_CONTROL_FLAGS, __near SEQ_RTMCFG, __near CURRENT_TITLE, __near CURRENT_MODE,
  __near SEQ_CYCLE_FLAGS, __near SEQ_EDIT_FLAGS, __near ram_2524, __near ram_1d5e, __near ram_e386;
extern unsigned int __near SEQ_START_MEASURE, __near SEQ_FREE_BLOCKS, __near SEQ_TRACK_MASK, __near ram_232a, __near ram_232c;
extern unsigned char __near SEQ_TRACK_ASSIGN[];

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

unsigned char SeqPlay_CheckRepeatActive(void)
{
  unsigned char r = 0, m;
  unsigned int b, w;
  if (CURRENT_TITLE == 0x87 || CURRENT_TITLE == 0x88) return r;
  b = ram_232c; w = ram_232a; m = CURRENT_MODE;
  if (m == 0x0b) {
    if (!(SEQ_CYCLE_FLAGS & 0x02)) return r;
    if (b <= w) r = 1;
  } else {
    if (m == 0x13) return r;
    if (!(SEQ_CYCLE_FLAGS & 0x01)) return r;
    if (b <= w) r = 1;
  }
  return r;
}

/* bar slot tables: 16 words + 16 bytes */
extern unsigned int __near ram_2526[], __near ram_2556[], __near ram_2590;
extern unsigned char __near ram_2546[], __near ram_2576[], __near ram_2592;

void SeqScan_SortBarSlots(void)
{
  unsigned int best = ram_2526[0], w, i;
  unsigned char b = ram_2546[0];
  i = 1;
  do {
    if (best == 0xffff) { best = ram_2526[i]; b = ram_2546[i]; }
    else {
      w = ram_2526[i];
      if ((w > best || (w >= best && ram_2546[i] > b)) && w != 0xffff) { best = w; b = ram_2546[i]; }
    }
    i++;
  } while (i < 16);
}

void SeqScan_SortSecondBar(void)
{
  unsigned int best = ram_2556[0], w, i;
  unsigned char b = ram_2576[0];
  i = 1;
  do {
    if (best == 0xffff) { best = ram_2556[i]; b = ram_2576[i]; }
    else {
      w = ram_2556[i];
      if ((w > best || (w >= best && ram_2576[i] > b)) && w != 0xffff) { best = w; b = ram_2576[i]; }
    }
    i++;
  } while (i < 16);
}

void SeqScan_ClearMatchingBarSlots(void)
{
  unsigned int i = 0;
  unsigned char *p = ram_2546;
  do {
    if (*p == ram_2592 && ram_2526[i] == ram_2590) { ram_2526[i] = 0xffff; *p = 0xff; }
    i++; p++;
  } while (i < 16);
}

int VoiceType_CheckDrumOrControl(unsigned char a, unsigned char *p)
{
  unsigned char f = 0;
  if (p[0] == 0x82) return 0;
  if ((p[0] & 0xf0) == 0xc0) { if (p[2] == 0x48 && p[3] == 0) f = 1; }
  else if ((p[0] & 0xf0) == 0xb0 && p[2] == 0x48 && p[3] == 7) f = 1;
  if (a == 0x15) { if (f != 1) return -1; return 0; }
  if (f == 0) return 0;
  return -1;
}

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

unsigned char Chan_IsActive(unsigned char a)
{
  if (a < 1 || a > 16) return 1;
  if (SEQ_TRACK_MASK & (1 << (a - 1))) return 1;
  return 0;
}

extern unsigned char __near ram_29f8[];
unsigned char VoiceAlloc_TestBitInMap(unsigned int n) { n--; return ram_29f8[n >> 3] & (1 << (n & 7)); }
void VoiceAlloc_SetBitInMap(unsigned int n) { n--; ram_29f8[n >> 3] |= 1 << (n & 7); }

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

void Part_CheckAndSetModifiedFlags(unsigned char *r)
{
  if (r[2] & 0x80) { r[2] &= ~0x80; r[0] |= 0x04; }
  if (r[4] & 0x80) { r[4] &= ~0x80; r[0] |= 0x01; }
  if (r[5] & 0x80) { r[5] &= ~0x80; r[0] |= 0x02; }
}

/* song slots: slot 0 = the record at 0xf180, slot n = SEQ_SONG_SLOTS + (n - 1) * 0x800 */
extern unsigned char __near SEQ_SONG_RECORD[];
extern unsigned char SEQ_SONG_SLOTS[];

unsigned char Part_ReadByteDirect(unsigned char a, unsigned int o)
{
  unsigned char *p;
  if (a == 0) p = SEQ_SONG_RECORD + o;
  else { a--; p = SEQ_SONG_SLOTS + (((unsigned long)a << 11) + o); }
  return *p;
}

void Part_WriteByte(unsigned char a, unsigned int o, unsigned char v)
{
  unsigned char *p;
  if (a == 0) p = SEQ_SONG_RECORD + o;
  else { a--; p = SEQ_SONG_SLOTS + (((unsigned long)a << 11) + o); }
  *p = v;
}

unsigned int Part_ReadWord(unsigned char a, unsigned int o)
{
  unsigned char *p;
  if (a == 0) p = SEQ_SONG_RECORD + o;
  else { a--; p = (unsigned char *)(0xab000L + (((unsigned long)a << 11) + o)); }
  return *(unsigned int *)p;
}

void Part_WriteWord(unsigned char a, unsigned int o, unsigned int v)
{
  unsigned char *p;
  if (a == 0) p = SEQ_SONG_RECORD + o;
  else { a--; p = (unsigned char *)(0xab000L + (((unsigned long)a << 11) + o)); }
  *(unsigned int *)p = v;
}

unsigned char Part_ReadSubBlock32(unsigned char a, unsigned int i)
{
  unsigned char *p;
  if (a == 0) p = SEQ_TRACK_ASSIGN;
  else { a--; p = SEQ_SONG_SLOTS + (((unsigned long)a << 11) + 32); }
  return p[i - 1];
}

void SeqData_CopyBlock2K(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *q, *e;
  if (a == 0) p = SEQ_SONG_RECORD + 256;
  else { a--; p = SEQ_SONG_SLOTS + (((unsigned long)a << 11) + 256); }
  q = buf; e = buf + 16;
  do *q++ = *p++; while (q < e);
}

void Part_CopyBlock16(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *q, *e;
  if (a == 0) p = SEQ_SONG_RECORD + 256;
  else { a--; p = SEQ_SONG_SLOTS + (((unsigned long)a << 11) + 256); }
  q = buf; e = buf + 16;
  do *p++ = *q++; while (q < e);
}

void Part_CopyToBuffer(unsigned char a, unsigned char c)
{
  unsigned char *s, *d;
  unsigned int i;
  if (a == 0) s = SEQ_SONG_RECORD + 736;
  else { a--; s = SEQ_SONG_SLOTS + (((unsigned long)a << 11) + 736); }
  if (c == 0) d = SEQ_SONG_RECORD + 736;
  else { c--; d = SEQ_SONG_SLOTS + (((unsigned long)c << 11) + 736); }
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
  if (r->b3 < 2) {
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
  r->count = 0;
  return 0;
}

unsigned char Voice_LookupTableEntries(struct nrec *r)
{
  struct t3 *t = ram_c5ca;
  struct lnk *lk = ram_e7e8;
  unsigned char n = 0x20;
  unsigned char h, k;
  unsigned int i;
  if (r->b3 < 2) {
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
  r->count = 0;
  return 0;
}

unsigned char NoteMap_FindLinkedSlotByKey(struct nrec *r, unsigned char idx)
{
  struct t3 *t = ram_c5ca;
  struct lnk *lk = ram_e7e8;
  unsigned char h, key, l;
  h = NoteMap_LinkByte_Table[r->b3];
  key = r->ent[idx].e0;
  l = lk[h].b;
  if (l != h) do {
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
    if ((f[1] >> 1) > s->ent[i].e0) continue;
    if (s->ent[i].e0 > (f[0] & 0x7f)) continue;
    d->ent[n] = s->ent[i];
    n++;
  }
  return d->count = n;
}

void InitChannelState_Che_InitVal(struct nrec *r)
{
  unsigned int i;
  for (i = 0; i < r->count; i++) {
    r->ent[i].e4 = 0;
    if (r->ent[i].e1 != 0) { r->ent[i].e2 = r->ent[i].e0; r->ent[i].e3 = r->ent[i].e0; }
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

extern unsigned long __near ram_cfb4, __near ram_cfb8, __near ram_cfbc, __near ram_cfc0, __near ram_cfc4;
extern unsigned int __near ram_cfc8, __near ram_cfca, __near ram_cfcc, __near ram_cfce;
extern unsigned int __near ram_cfd0[], __near ram_d010[], __near ram_d050[];

void COMM_SendDataReturn(void)
{
  int i;
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
