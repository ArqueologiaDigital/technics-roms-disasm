/* Phase 6, helper B, round 2, form a.  Refinements of round 1's misses (sequencer/sequencer_engine.s, -O) and of
   note_voice_mapping.s (no -O), plus new note_voice_mapping.s functions (ring buffers, part-data setters).
   Tables of odd-sized records are char arrays: V4.23 pads every struct to an even size, the firmware does not.
   Tables are reached through local pointers, which V4.23 indexes with a signed multiply as the ROM does. */

extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned int __near ram_232a;
extern unsigned int __near ram_232c;

unsigned char SeqVoice_FindDrumPartIndex(void)
{
  unsigned char f, i;
  f = SEQ_EDIT_FLAGS;
  f &= ~0x04;
  SEQ_EDIT_FLAGS = f;
  i = 0;
  do {
    if (SEQ_TRACK_ASSIGN[i] == 0x10) { f |= 0x04; SEQ_EDIT_FLAGS = f; return i + 1; }
    i++;
  } while (i < 16);
  return 0;
}

unsigned char Chan_IsActive(unsigned char a)
{
  if (a >= 1 && a <= 16 && !(SEQ_TRACK_MASK & (1 << (a - 1)))) return 0;
  return 1;
}

extern unsigned char __near ram_29f8[];
unsigned char VoiceAlloc_TestBitInMap(unsigned int n)
{
  unsigned int i;
  n--; i = n >> 3; n &= 7;
  return ram_29f8[i] & (1 << n);
}
void VoiceAlloc_SetBitInMap(unsigned int n)
{
  unsigned int i;
  n--; i = n >> 3; n &= 7;
  ram_29f8[i] |= 1 << n;
}

/* song slots: slot 0 = the record at 0xf180, slot n = 0xab000 + (n - 1) * 0x800 */
struct song { unsigned char h[32]; unsigned char tbl[224]; unsigned char blk[480]; unsigned char part[0x800 - 736]; };
extern unsigned char __near SEQ_SONG_RECORD[];
extern struct song SEQ_SONG_SLOTS[];

unsigned int Part_ReadWord(unsigned char a, unsigned int o)
{
  unsigned char *p;
  if (a == 0) p = &SEQ_SONG_RECORD[o];
  else p = &((unsigned char (*)[0x800])0xab000)[(unsigned char)(a - 1)][o];
  return *(unsigned int *)p;
}

void Part_WriteWord(unsigned char a, unsigned int o, unsigned int v)
{
  unsigned char *p;
  if (a == 0) p = &SEQ_SONG_RECORD[o];
  else p = &((unsigned char (*)[0x800])0xab000)[(unsigned char)(a - 1)][o];
  *(unsigned int *)p = v;
}

unsigned char Part_ReadSubBlock32(unsigned char a, unsigned char i)
{
  unsigned char *p;
  if (a == 0) p = SEQ_TRACK_ASSIGN;
  else p = SEQ_SONG_SLOTS[(unsigned char)(a - 1)].tbl;
  return p[i - 1];
}

void SeqData_CopyBlock2K(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *q, *e;
  if (a == 0) p = SEQ_SONG_RECORD + 256;
  else p = SEQ_SONG_SLOTS[(unsigned char)(a - 1)].blk;
  q = buf; e = buf + 16;
  do *q++ = *p++; while (q < e);
}

void Part_CopyBlock16(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *q, *e;
  if (a == 0) p = SEQ_SONG_RECORD + 256;
  else p = SEQ_SONG_SLOTS[(unsigned char)(a - 1)].blk;
  q = buf; e = buf + 16;
  do *p++ = *q++; while (q < e);
}

void Part_CopyToBuffer(unsigned char a, unsigned char c)
{
  unsigned char *s, *d;
  unsigned int i;
  if (a == 0) s = SEQ_SONG_RECORD + 736;
  else s = SEQ_SONG_SLOTS[(unsigned char)(a - 1)].part;
  if (c == 0) d = SEQ_SONG_RECORD + 736;
  else d = SEQ_SONG_SLOTS[(unsigned char)(c - 1)].part;
  i = 0;
  do { *d++ = *s++; i++; } while (i < 0x520);
}

/* 12-byte buffer slots at 0x1ffa; 0x1ff6 = used list, 0x1ff8 = free list */
struct sbent { unsigned char f[4]; unsigned int pos; unsigned char g[4]; unsigned char prev, next; };
struct sbhdr { unsigned char head, tail; };
extern struct sbent __near ram_1ffa[];
extern struct sbhdr __near ram_1ff6;
extern struct sbhdr __near ram_1ff8;
extern unsigned char __near ram_e38a;
extern unsigned char __near ram_2868;
extern unsigned int __near ram_22fa;

void SeqBuffer_RemoveLastEntry(void)
{
  struct sbhdr *h = &ram_1ff8;
  struct sbent *t;
  unsigned char l, n;
  l = h->head;
  if (l == 0xff) return;
  t = ram_1ffa;
  n = t[l].next;
  if (n != 0xff) t[n].prev = 0xff;
  h->head = n;
  if (n == 0xff) ram_2868 = l;
}

void SeqBuffer_FindMinPosition(void)
{
  struct sbent *t, *e;
  unsigned char i = ram_1ff6.head;
  unsigned int m = 0xffff;
  if (i != 0xff) {
    t = ram_1ffa;
    do {
      e = &t[i];
      if (e->pos < m) m = e->pos;
      i = e->next;
    } while (i != 0xff);
  }
  ram_22fa = m;
}

void SeqBuffer_InsertAtHead(unsigned char a)
{
  struct sbhdr *h = &ram_1ff6;
  unsigned char *tl = &h->tail;
  struct sbent *t, *p;
  unsigned char w = *tl;
  t = ram_1ffa;
  p = &t[a];
  if (w == 0xff) { h->head = a; p->prev = 0xff; }
  else { t[w].next = a; p->prev = w; }
  *tl = a;
  ram_1ffa[a].next = 0xff;
}

void SeqBuffer_MoveEntryToHead(unsigned char a)
{
  struct sbhdr *h;
  unsigned char *tl;
  struct sbent *t, *p;
  unsigned char w;
  if (a == 0xff) ram_e38a = 0xff;
  h = &ram_1ff8;
  tl = &h->tail;
  w = *tl;
  t = ram_1ffa;
  p = &t[a];
  if (w == 0xff) { h->head = a; p->prev = 0xff; }
  else { t[w].next = a; p->prev = w; }
  *tl = a;
  t[a].next = 0xff;
}

/* 9-byte note-map nodes at 0x1db6 {prev, next, ...}; 0x1db2 = head / tail of list 1, head / tail of list 2 */
struct nm9hdr { unsigned char h1, t1, h2, t2; };
extern unsigned char __near ram_1db6[][9];
extern struct nm9hdr __near ram_1db2;

void NoteMap_RemoveHeadEntry(unsigned char a)
{
  unsigned char (*t)[9] = ram_1db6;
  unsigned char e;
  e = t[a][1];
  ram_1db2.h2 = e;
  if (e != 0xff) t[e][0] = 0xff;
  else ram_1db2.t2 = e;
}

/* event lengths: a result variable and one exit, cases in the firmware's order */
int SeqEvent_GetParamLength(unsigned char a)
{
  int n;
  switch (a & 0xf0) {
  case 0x90: case 0xb0: case 0xc0: n = 6; break;
  default:
    switch (a) {
    case 0xd2: case 0x80: n = 4; break;
    case 0xd0: case 0xd1: case 0xd3: case 0xa0: n = 3; break;
    case 0x85: case 0x86: n = 2; break;
    case 0x81: case 0x82: n = 1; break;
    default: n = -1;
    }
  }
  return n;
}

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

unsigned char MIDI_GetEventSize(unsigned char a)
{
  unsigned char n;
  switch (a & 0xf0) {
  case 0x90: case 0xb0: case 0xc0: n = 6; break;
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

unsigned char SeqData_GetEventByteCount(unsigned char *p)
{
  int n = 4;
  switch (p[0] & 0xf0) {
  case 0x90: break;
  case 0xb0: case 0xc0: n = 6; break;
  default:
    switch (p[0]) {
    case 0xd0: case 0xd1: case 0xd3: n = 3; break;
    case 0xd2: break;
    default: return 0xff;
    }
  }
  return p[n];
}

int SeqLoad_ValidateFormat(unsigned char *p)
{
  if (p[5] == 1) {
    switch (p[6]) { case 8: case 7: case 6: case 3: return p[4]; }
  }
  return -102;
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
  ram_e3b8 += 1;
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

void Part_CheckAndSetModifiedFlags(unsigned char *r)
{
  unsigned char *q;
  unsigned char c;
  q = r + 2; c = *q; if (c & 0x80) { c &= ~0x80; *q = c; *r |= 0x04; }
  q = r + 4; c = *q; if (c & 0x80) { c &= ~0x80; *q = c; *r |= 0x01; }
  q = r + 5; c = *q; if (c & 0x80) { c &= ~0x80; *q = c; *r |= 0x02; }
}

/* ---- audio/note_voice_mapping.s, the part built without -O ---- */

struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
struct lnk { unsigned char a, b; };
extern unsigned char __near ram_c5ca[][3];
extern struct lnk __near ram_e7e8[];
extern unsigned char NoteMap_LinkByte_Table[];

void InitChannelState_Che_InitVal(struct nrec *r)
{
  unsigned int i;
  for (i = 0; i < r->count; i++) {
    r->ent[i][4] = 0;
    if (r->ent[i][1] != 0) { r->ent[i][2] = r->ent[i][0]; r->ent[i][3] = r->ent[i][0]; }
  }
}

unsigned char NoteMap_FindLinkedSlotByKey(struct nrec *r, unsigned char idx)
{
  struct lnk *lk;
  unsigned char (*t)[3];
  unsigned char h, key, l;
  t = ram_c5ca;
  lk = ram_e7e8;
  h = NoteMap_LinkByte_Table[r->b3];
  key = r->ent[idx][0];
  l = lk[h].b;
  if (l != h) do {
    if (t[l][1] == key) return l;
    l = lk[l].b;
  } while (l != h);
  return l;
}

/* ring buffers: write index, read index, count (free or used), data */
extern unsigned int __near ram_d0a8;
extern unsigned int __near ram_d0aa;
extern unsigned int __near ram_d0ac;
extern unsigned char __near ram_d0ae[];
extern unsigned int __near ram_d8ae;
extern unsigned int __near ram_d8b0;
extern unsigned int __near ram_d8b2;
extern unsigned char __near ram_d8b4[];
extern unsigned int __near ram_e0b4;
extern unsigned int __near ram_e0b6;
extern unsigned int __near ram_e0b8;
extern unsigned char __near ram_e0ba[];

int RingBuffer_ReadByte(void)
{
  int r;
  if (ram_d0a8 == ram_d0aa) r = -1;
  else {
    r = ram_d0ae[ram_d0aa];
    ram_d0ac++;
    if (ram_d0aa == 2047) ram_d0aa = 0; else ram_d0aa++;
  }
  return r;
}

int RingBuffer_WriteByte(unsigned char a)
{
  int r;
  if (ram_d0ac == 0) r = -1;
  else {
    ram_d0ae[ram_d0a8] = a;
    ram_d0ac--;
    if (ram_d0a8 == 2047) ram_d0a8 = 0; else ram_d0a8++;
    r = 0;
  }
  return r;
}

int SysexRingBuf_ReadByte(void)
{
  int r;
  if (ram_d8ae == ram_d8b0) r = -1;
  else {
    r = ram_d8b4[ram_d8b0];
    ram_d8b2++;
    if (ram_d8b0 == 2047) ram_d8b0 = 0; else ram_d8b0++;
  }
  return r;
}

int SysexRingBuf_WriteByte(unsigned char a)
{
  int r;
  if (ram_d8b2 == 0) r = -1;
  else {
    ram_d8b4[ram_d8ae] = a;
    ram_d8b2--;
    if (ram_d8ae == 2047) ram_d8ae = 0; else ram_d8ae++;
    r = 0;
  }
  return r;
}

int StoreAndAdvance_LoadDRAM(void)
{
  int r;
  if (ram_e0b4 == ram_e0b6) r = -1;
  else {
    r = ram_e0ba[ram_e0b6];
    ram_e0b8++;
    if (ram_e0b6 == 127) ram_e0b6 = 0; else ram_e0b6++;
  }
  return r;
}

int MidiRingBuf_WriteByte(unsigned char a)
{
  int r;
  if (ram_e0b8 == 0) r = -1;
  else {
    ram_e0ba[ram_e0b4] = a;
    ram_e0b8--;
    if (ram_e0b4 == 127) ram_e0b4 = 0; else ram_e0b4++;
    r = 0;
  }
  return r;
}

/* five 56-byte part records; a word at +8 */
struct pdb { unsigned char x[8]; unsigned int v; unsigned char y[46]; };
extern struct pdb ram_3c126[];
extern struct pdb ram_3c120[];

int SendPartDataBlock_InitVal(unsigned int p, unsigned int v)
{
  int r = 0;
  if (p >= 5 || v > 99) r = -1;
  else ((struct pdb *)0x3c0fa)[p].v = v;
  return r;
}

int SendPartDataBlock_InitVal2(unsigned int p, unsigned int v)
{
  int r = 0;
  if (p >= 5) r = -1;
  else ram_3c126[p].v = v;
  return r;
}

int SendPartDataBlock_InitVal3(unsigned int p, unsigned int v)
{
  int r = 0;
  if (p >= 5) r = -1;
  else ram_3c120[p].v = v;
  return r;
}

unsigned long Param_SignExtendReturn_Helper(unsigned char *p)
{
  return ((unsigned long)(p[9] & 0x7f) << 14) | ((unsigned long)(p[10] & 0x7f) << 7) | (unsigned long)(p[11] & 0x7f);
}

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
