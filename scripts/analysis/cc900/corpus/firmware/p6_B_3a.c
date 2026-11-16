/* Phase 6, helper B, round 3, form a.  Misses of rounds 1-2 re-read at -O3 -Xr (sequencer_engine.s) / -Xr
   (note_voice_mapping.s), and new note_voice_mapping.s functions.  Odd-sized records are char arrays; a row
   pointer (p = t[i]; p[k]) gives the firmware's "address, then displacement" shape. */

/* ---- sequencer/sequencer_engine.s (-O3 -Xr) ---- */

struct sbent { unsigned char f[4]; unsigned int pos; unsigned char g[4]; unsigned char prev, next; };
struct sbhdr { unsigned char head, tail; };
extern struct sbent __near ram_1ffa[];
extern struct sbhdr __near ram_1ff6;
extern struct sbhdr __near ram_1ff8;
extern unsigned char __near ram_e38a;
extern unsigned char __near ram_2868;

unsigned char SeqBuffer_RemoveLastEntry(void)
{
  struct sbhdr *h = &ram_1ff8;
  struct sbent *t;
  unsigned char l, n;
  l = h->head;
  if (l == 0xff) return l;
  t = ram_1ffa;
  n = t[l].next;
  if (n != 0xff) t[n].prev = 0xff;
  h->head = n;
  if (n == 0xff) ram_2868 = l;
  return l;
}

void SeqBuffer_InsertAtHead(unsigned char a)
{
  struct sbhdr *h = &ram_1ff6;
  unsigned char *tl = &h->tail;
  unsigned char w = *tl;
  int k = a;
  unsigned char *pv = &ram_1ffa[k].prev;
  if (w == 0xff) { h->head = a; *pv = 0xff; }
  else { ram_1ffa[w].next = a; *pv = w; }
  *tl = a;
  ram_1ffa[k].next = 0xff;
}

void SeqBuffer_MoveEntryToHead(unsigned char a)
{
  struct sbhdr *h;
  unsigned char *tl, *pv;
  unsigned char w;
  int k;
  if (a == 0xff) ram_e38a = 0xff;
  h = &ram_1ff8;
  tl = &h->tail;
  w = *tl;
  k = a;
  pv = &ram_1ffa[k].prev;
  if (w == 0xff) { h->head = a; *pv = 0xff; }
  else { ram_1ffa[w].next = a; *pv = w; }
  *tl = a;
  ram_1ffa[k].next = 0xff;
}

struct nm9hdr { unsigned char h1, t1, h2, t2; };
extern unsigned char __near ram_1db6[][9];
extern struct nm9hdr __near ram_1db2;

void NoteMap_RemoveHeadEntry(unsigned char a)
{
  unsigned char (*t)[9];
  unsigned char *p;
  unsigned char e;
  t = ram_1db6;
  p = t[a];
  e = p[1];
  ram_1db2.h2 = e;
  if (e != 0xff) t[e][0] = 0xff;
  else ram_1db2.t2 = e;
}

extern unsigned char __near ram_29f8[];
unsigned char VoiceAlloc_TestBitInMap(unsigned int n)
{
  unsigned int i;
  unsigned char m;
  n--; i = n >> 3; n &= 7;
  m = 1 << n;
  return ram_29f8[i] & m;
}
void VoiceAlloc_SetBitInMap(unsigned int n)
{
  unsigned int i;
  unsigned char m;
  n--; i = n >> 3; n &= 7;
  m = 1 << n;
  ram_29f8[i] |= m;
}

/* song slots: the byte accessors (matched) index a char array at SEQ_SONG_SLOTS; the word accessors load the base
   with ld, which V4.23 writes for an array of structs (ram_ab000 is the same address) */
struct song { unsigned char b[0x800]; };
extern unsigned char __near SEQ_SONG_RECORD[];
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned char SEQ_SONG_SLOTS[];
extern struct song ram_ab000[];

unsigned int Part_ReadWord(unsigned char a, unsigned int o)
{
  unsigned char *p;
  if (a == 0) p = &SEQ_SONG_RECORD[o];
  else p = &ram_ab000[(unsigned char)(a - 1)].b[o];
  return *(unsigned int *)p;
}

void Part_WriteWord(unsigned char a, unsigned int o, unsigned int v)
{
  unsigned char *p;
  if (a == 0) p = &SEQ_SONG_RECORD[o];
  else p = &ram_ab000[(unsigned char)(a - 1)].b[o];
  *(unsigned int *)p = v;
}

/* slot offset + constant as a pointer (lda), then the base added */
unsigned char Part_ReadSubBlock32(unsigned char a, unsigned char i)
{
  unsigned char *p;
  if (a == 0) p = SEQ_TRACK_ASSIGN;
  else p = SEQ_SONG_SLOTS + (unsigned long)((unsigned char *)((unsigned long)(unsigned char)(a - 1) << 11) + 32);
  p += i;
  return p[-1];
}

void SeqData_CopyBlock2K(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *q, *e;
  if (a == 0) p = SEQ_SONG_RECORD + 256;
  else p = SEQ_SONG_SLOTS + (unsigned long)((unsigned char *)((unsigned long)(unsigned char)(a - 1) << 11) + 256);
  q = buf; e = buf + 16;
  do *q++ = *p++; while (q < e);
}

void Part_CopyBlock16(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *q, *e;
  if (a == 0) p = SEQ_SONG_RECORD + 256;
  else p = SEQ_SONG_SLOTS + (unsigned long)((unsigned char *)((unsigned long)(unsigned char)(a - 1) << 11) + 256);
  q = buf; e = buf + 16;
  do *p++ = *q++; while (q < e);
}

void Part_CopyToBuffer(unsigned char a, unsigned char c)
{
  unsigned char *s, *d;
  unsigned int i;
  if (a == 0) s = SEQ_SONG_RECORD + 736;
  else s = SEQ_SONG_SLOTS + (unsigned long)((unsigned char *)((unsigned long)(unsigned char)(a - 1) << 11) + 736);
  if (c == 0) d = SEQ_SONG_RECORD + 736;
  else d = SEQ_SONG_SLOTS + (unsigned long)((unsigned char *)((unsigned long)(unsigned char)(c - 1) << 11) + 736);
  i = 0;
  do { *d++ = *s++; i++; } while (i < 0x520);
}

/* switches: the first case body duplicates a later one, so V4.23 does not fall into it after the compares */
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

int SeqLoad_ValidateFormat(unsigned char *p)
{
  if (p[5] == 1) {
    switch (p[6]) { case 8: return p[4]; case 7: case 6: case 3: return p[4]; }
  }
  return -102;
}

/* ---- audio/note_voice_mapping.s, the part built without -O (-Xr) ---- */

struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
struct lnk { unsigned char a, b; };
extern unsigned char __near ram_c5ca[][3];
extern struct lnk __near ram_e7e8[];
extern unsigned char NoteMap_LinkByte_Table[];

unsigned char NoteMap_FindLinkedSlotByKey(struct nrec *r, unsigned char idx)
{
  unsigned char (*t)[3];
  struct lnk *lk;
  unsigned char *q;
  unsigned char h, key, l;
  t = ram_c5ca;
  lk = ram_e7e8;
  h = NoteMap_LinkByte_Table[r->b3];
  key = r->ent[idx][0];
  l = lk[h].b;
  if (l != h) do {
    q = t[l];
    if (q[1] == key) return l;
    l = lk[l].b;
  } while (l != h);
  return l;
}

/* five 56-byte part records at offset 8 of the block at 0x3c0fa */
struct prec { unsigned int v; unsigned int f2; unsigned int arr[17]; unsigned int f38; unsigned char pad[4];
  unsigned int n; unsigned char rest[10]; };
struct pdbs { unsigned char hdr[8]; struct prec rec[5]; };
extern struct pdbs ram_3c0fa;

int SendPartDataBlock_InitVal(unsigned int p, unsigned int v)
{
  int r = 0;
  if (p >= 5 || v > 99) r = -1;
  else ram_3c0fa.rec[p].v = v;
  return r;
}

int SendPartDataBlock_InitVal2(unsigned int p, unsigned int v)
{
  int r = 0;
  if (p >= 5) r = -1;
  else ram_3c0fa.rec[p].n = v;
  return r;
}

int SendPartDataBlock_InitVal3(unsigned int p, unsigned int v)
{
  int r = 0;
  if (p >= 5) r = -1;
  else ram_3c0fa.rec[p].f38 = v;
  return r;
}

int SendPartDataBlock_Prologue(unsigned int p, unsigned int i, unsigned int v)
{
  int r = 0;
  struct prec *q;
  if (p >= 5) r = -1;
  else {
    q = &ram_3c0fa.rec[p];
    if (i >= q->n) r = -1;
    else ram_3c0fa.rec[p].arr[i] = v;
  }
  return r;
}

long MidiSysMsg_DecodeDeltaTime(unsigned char a, unsigned char *p)
{
  long r;
  unsigned char lo, hi;
  switch (a) {
  case 0xf3:
    r = (unsigned long)(p[0] & 0x7f);
    break;
  case 0xf4:
    lo = p[0] & 0x7f;
    hi = p[1] & 0x7f;
    lo |= hi << 7;
    hi >>= 1;
    r = (int)((hi << 8) + lo);
    break;
  default:
    r = 0;
  }
  return r;
}

unsigned long Param_SignExtendRetu_Data(unsigned char *p)
{
  return ((unsigned long)p[6] << 14) | ((unsigned long)(p[7] & 0x7f) << 7) | (unsigned long)(p[8] & 0x7f);
}
