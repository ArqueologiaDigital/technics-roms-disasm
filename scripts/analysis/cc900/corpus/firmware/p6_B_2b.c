/* Phase 6, helper B, round 2, form b: the functions of p6_B_2a.c, other C shapes (temporaries, early returns,
   2-D arrays instead of struct members, global instead of local table pointers). */

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
  unsigned char *t;
  unsigned char f, i;
  f = SEQ_EDIT_FLAGS & ~0x04;
  SEQ_EDIT_FLAGS = f;
  i = 0;
  t = SEQ_TRACK_ASSIGN;
  do {
    if (t[i] == 0x10) { SEQ_EDIT_FLAGS = f | 0x04; return i + 1; }
    i++;
  } while (i < 16);
  return 0;
}

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

extern unsigned char __near ram_29f8[];
unsigned char VoiceAlloc_TestBitInMap(unsigned int n)
{
  unsigned int i;
  n--; i = n >> 3;
  return ram_29f8[i] & (1 << (n & 7));
}
void VoiceAlloc_SetBitInMap(unsigned int n)
{
  unsigned int i;
  n--; i = n >> 3;
  ram_29f8[i] |= 1 << (n & 7);
}

extern unsigned char __near SEQ_SONG_RECORD[];
extern unsigned char SEQ_SONG_SLOTS[][0x800];

unsigned int Part_ReadWord(unsigned char a, unsigned int o)
{
  unsigned int *p;
  if (a == 0) p = (unsigned int *)(SEQ_SONG_RECORD + o);
  else p = (unsigned int *)((unsigned char *)0xab000 + (((unsigned long)(unsigned char)(a - 1) << 11) + o));
  return *p;
}

void Part_WriteWord(unsigned char a, unsigned int o, unsigned int v)
{
  unsigned int *p;
  if (a == 0) p = (unsigned int *)(SEQ_SONG_RECORD + o);
  else p = (unsigned int *)((unsigned char *)0xab000 + (((unsigned long)(unsigned char)(a - 1) << 11) + o));
  *p = v;
}

unsigned char Part_ReadSubBlock32(unsigned char a, unsigned char i)
{
  unsigned char *p;
  if (a == 0) p = SEQ_TRACK_ASSIGN;
  else p = SEQ_SONG_SLOTS[(unsigned char)(a - 1)] + 32;
  return (p + i)[-1];
}

void SeqData_CopyBlock2K(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *q, *e;
  if (a == 0) p = SEQ_SONG_RECORD + 256;
  else p = SEQ_SONG_SLOTS[(unsigned char)(a - 1)] + 256;
  q = buf; e = buf + 16;
  do *q++ = *p++; while (q < e);
}

void Part_CopyBlock16(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *q, *e;
  if (a == 0) p = SEQ_SONG_RECORD + 256;
  else p = SEQ_SONG_SLOTS[(unsigned char)(a - 1)] + 256;
  q = buf; e = buf + 16;
  do *p++ = *q++; while (q < e);
}

void Part_CopyToBuffer(unsigned char a, unsigned char c)
{
  unsigned int i;
  unsigned char *d, *s;
  if (a == 0) s = SEQ_SONG_RECORD + 736;
  else s = SEQ_SONG_SLOTS[(unsigned char)(a - 1)] + 736;
  if (c == 0) d = SEQ_SONG_RECORD + 736;
  else d = SEQ_SONG_SLOTS[(unsigned char)(c - 1)] + 736;
  i = 0;
  do { *d++ = *s++; i++; } while (i < 0x520);
}

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
  struct sbent *t;
  unsigned char l = ram_1ff8.head, n;
  if (l == 0xff) return;
  t = ram_1ffa;
  n = t[l].next;
  if (n != 0xff) t[n].prev = 0xff;
  ram_1ff8.head = n;
  if (n == 0xff) ram_2868 = l;
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

void SeqBuffer_InsertAtHead(unsigned char a)
{
  struct sbent *t = ram_1ffa;
  unsigned char w = ram_1ff6.tail;
  if (w == 0xff) { ram_1ff6.head = a; t[a].prev = 0xff; }
  else { t[w].next = a; t[a].prev = w; }
  ram_1ff6.tail = a;
  t[a].next = 0xff;
}

void SeqBuffer_MoveEntryToHead(unsigned char a)
{
  struct sbent *t;
  unsigned char w;
  if (a == 0xff) ram_e38a = 0xff;
  t = ram_1ffa;
  w = ram_1ff8.tail;
  if (w == 0xff) { ram_1ff8.head = a; t[a].prev = 0xff; }
  else { t[w].next = a; t[a].prev = w; }
  ram_1ff8.tail = a;
  t[a].next = 0xff;
}

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
  else ram_1db2.t2 = 0xff;
}

int SeqEvent_GetParamLength(unsigned char a)
{
  int n;
  switch (a & 0xf0) {
  default:
    switch (a) {
    case 0xd2: case 0x80: n = 4; break;
    case 0xd0: case 0xd1: case 0xd3: case 0xa0: n = 3; break;
    case 0x85: case 0x86: n = 2; break;
    case 0x81: case 0x82: n = 1; break;
    default: n = -1;
    }
    break;
  case 0x90: case 0xb0: case 0xc0: n = 6;
  }
  return n;
}

unsigned char MIDI_GetEventSizeFromByte(unsigned char a)
{
  unsigned char n = 0;
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
    }
  }
  return n;
}

unsigned char MIDI_GetEventSize(unsigned char a)
{
  unsigned char n = 1;
  switch (a & 0xf0) {
  case 0x90: case 0xb0: case 0xc0: n = 6; break;
  default:
    switch (a) {
    case 0x80: n = 4; break;
    case 0x85: case 0x86: n = 2; break;
    case 0xd0: case 0xd1: n = 3; break;
    case 0xd2: n = 4; break;
    case 0xd3: n = 3; break;
    }
  }
  return n;
}

unsigned char SeqData_GetEventByteCount(unsigned char *p)
{
  unsigned int n;
  unsigned char r;
  switch (p[0] & 0xf0) {
  case 0x90: n = 4; break;
  case 0xb0: case 0xc0: n = 6; break;
  default:
    switch (p[0]) {
    case 0xd0: case 0xd1: case 0xd3: n = 3; break;
    case 0xd2: n = 4; break;
    default: n = 0;
    }
  }
  if (n) r = p[n]; else r = 0xff;
  return r;
}

int SeqLoad_ValidateFormat(unsigned char *p)
{
  unsigned char t;
  if (p[5] != 1) return -102;
  t = p[6];
  if (t == 3 || t == 6 || t == 7 || t == 8) return p[4];
  return -102;
}

struct evq { unsigned int w; unsigned char c, e; };
extern struct evq __near ram_e390[];
extern unsigned int __near ram_e3b8;

void PartCtrl_AppendToEventQueue(unsigned char w, unsigned char c, unsigned char e)
{
  unsigned int n;
  if (ram_e3b8 >= 10) return;
  ram_e390[ram_e3b8].w = w;
  ram_e390[ram_e3b8].c = c;
  ram_e390[ram_e3b8].e = e;
  n = ram_e3b8;
  ram_e3b8 = n + 1;
}

unsigned char SeqPlay_CheckRepeatActive(void)
{
  unsigned char r = 0, m;
  unsigned int b, w;
  if (CURRENT_TITLE == 0x87) return r;
  if (CURRENT_TITLE == 0x88) return r;
  b = ram_232c; w = ram_232a; m = CURRENT_MODE;
  if (m == 0x0b) {
    if (SEQ_CYCLE_FLAGS & 0x02) { if (b <= w) r = 1; }
  } else if (m != 0x13 && (SEQ_CYCLE_FLAGS & 0x01) && b <= w) r = 1;
  return r;
}

void Part_CheckAndSetModifiedFlags(unsigned char *r)
{
  unsigned char *q;
  unsigned char c;
  q = r + 2; if ((c = *q) & 0x80) { *q = c & ~0x80; *r |= 0x04; }
  q = r + 4; if ((c = *q) & 0x80) { *q = c & ~0x80; *r |= 0x01; }
  q = r + 5; if ((c = *q) & 0x80) { *q = c & ~0x80; *r |= 0x02; }
}

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
    if (r->ent[i][1]) {
      r->ent[i][2] = r->ent[i][0];
      r->ent[i][3] = r->ent[i][0];
    }
  }
}

unsigned char NoteMap_FindLinkedSlotByKey(struct nrec *r, unsigned char idx)
{
  unsigned char (*t)[3] = ram_c5ca;
  struct lnk *lk = ram_e7e8;
  unsigned char h, key, l;
  h = NoteMap_LinkByte_Table[r->b3];
  key = r->ent[idx][0];
  l = lk[h].b;
  if (l != h) do {
    if (t[l][1] == key) return l;
    l = lk[l].b;
  } while (l != h);
  return l;
}

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
  if (ram_d0a8 == ram_d0aa) return -1;
  r = ram_d0ae[ram_d0aa];
  ram_d0ac++;
  if (ram_d0aa == 2047) ram_d0aa = 0; else ram_d0aa++;
  return r;
}

int RingBuffer_WriteByte(unsigned char a)
{
  if (ram_d0ac == 0) return -1;
  ram_d0ae[ram_d0a8] = a;
  ram_d0ac--;
  if (ram_d0a8 == 2047) ram_d0a8 = 0; else ram_d0a8++;
  return 0;
}

int SysexRingBuf_ReadByte(void)
{
  int r;
  if (ram_d8ae == ram_d8b0) return -1;
  r = ram_d8b4[ram_d8b0];
  ram_d8b2++;
  if (ram_d8b0 == 2047) ram_d8b0 = 0; else ram_d8b0++;
  return r;
}

int SysexRingBuf_WriteByte(unsigned char a)
{
  if (ram_d8b2 == 0) return -1;
  ram_d8b4[ram_d8ae] = a;
  ram_d8b2--;
  if (ram_d8ae == 2047) ram_d8ae = 0; else ram_d8ae++;
  return 0;
}

int StoreAndAdvance_LoadDRAM(void)
{
  int r;
  if (ram_e0b4 == ram_e0b6) return -1;
  r = ram_e0ba[ram_e0b6];
  ram_e0b8++;
  if (ram_e0b6 == 127) ram_e0b6 = 0; else ram_e0b6++;
  return r;
}

int MidiRingBuf_WriteByte(unsigned char a)
{
  if (ram_e0b8 == 0) return -1;
  ram_e0ba[ram_e0b4] = a;
  ram_e0b8--;
  if (ram_e0b4 == 127) ram_e0b4 = 0; else ram_e0b4++;
  return 0;
}

struct pdb { unsigned char x[8]; unsigned int v; unsigned char y[46]; };
extern struct pdb ram_3c126[];
extern struct pdb ram_3c120[];

int SendPartDataBlock_InitVal(unsigned int p, unsigned int v)
{
  int r = 0;
  if (p < 5 && v <= 99) ((struct pdb *)0x3c0fa)[p].v = v;
  else r = -1;
  return r;
}

int SendPartDataBlock_InitVal2(unsigned int p, unsigned int v)
{
  int r = 0;
  if (p < 5) ram_3c126[p].v = v;
  else r = -1;
  return r;
}

int SendPartDataBlock_InitVal3(unsigned int p, unsigned int v)
{
  int r = 0;
  if (p < 5) ram_3c120[p].v = v;
  else r = -1;
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

extern unsigned int __near ACTIVE_TITLE;

unsigned char CommPort_StatusCheck_Compare(unsigned char a, unsigned char c)
{
  unsigned char t;
  if (a == c) {
    t = ACTIVE_TITLE;
    if (t == 0xd6 || t == 0x0e || t == 0x0c || t == 0x0b || t == 0x0a) return 0;
  }
  return 0xff;
}
