/* Phase 6, helper B, round 3, form b: the functions of p6_B_3a.c, other C shapes (global arrays indexed through
   an int, local table pointers assigned late, result variables, pointer + constant forms). */

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
  unsigned char l, n;
  int k;
  l = h->head;
  if (l == 0xff) return l;
  k = l;
  n = ram_1ffa[k].next;
  if (n != 0xff) { k = n; ram_1ffa[k].prev = 0xff; }
  h->head = n;
  if (n == 0xff) ram_2868 = l;
  return l;
}

void SeqBuffer_InsertAtHead(unsigned char a)
{
  struct sbhdr *h = &ram_1ff6;
  unsigned char *tl = &h->tail;
  unsigned char w = *tl;
  struct sbent *t, *p;
  int o = a * 12;
  t = ram_1ffa;
  p = (struct sbent *)((unsigned char *)t + o);
  if (w == 0xff) { h->head = a; p->prev = 0xff; }
  else { t[w].next = a; p->prev = w; }
  *tl = a;
  ((struct sbent *)((unsigned char *)ram_1ffa + o))->next = 0xff;
}

void SeqBuffer_MoveEntryToHead(unsigned char a)
{
  struct sbhdr *h;
  unsigned char *tl;
  unsigned char w;
  struct sbent *t, *p;
  int o;
  if (a == 0xff) ram_e38a = 0xff;
  h = &ram_1ff8;
  tl = &h->tail;
  w = *tl;
  o = a * 12;
  t = ram_1ffa;
  p = (struct sbent *)((unsigned char *)t + o);
  if (w == 0xff) { h->head = a; p->prev = 0xff; }
  else { t[w].next = a; p->prev = w; }
  *tl = a;
  ((struct sbent *)((unsigned char *)t + o))->next = 0xff;
}

struct nm9hdr { unsigned char h1, t1, h2, t2; };
extern unsigned char __near ram_1db6[][9];
extern struct nm9hdr __near ram_1db2;

void NoteMap_RemoveHeadEntry(unsigned char a)
{
  unsigned char (*t)[9];
  unsigned char e;
  e = (t = ram_1db6)[a][1];
  ram_1db2.h2 = e;
  if (e != 0xff) t[e][0] = 0xff;
  else ram_1db2.t2 = e;
}

extern unsigned char __near ram_29f8[];
unsigned char VoiceAlloc_TestBitInMap(unsigned int n)
{
  unsigned int i, m;
  n--; i = n >> 3; n &= 7;
  m = 1 << n;
  return ram_29f8[i] & m;
}
void VoiceAlloc_SetBitInMap(unsigned int n)
{
  unsigned int i, m;
  n--; i = n >> 3; n &= 7;
  m = 1 << n;
  ram_29f8[i] |= m;
}

struct song { unsigned char h[32]; unsigned char tbl[224]; unsigned char blk[480]; unsigned char part[0x800 - 736]; };
extern unsigned char __near SEQ_SONG_RECORD[];
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned char SEQ_SONG_SLOTS[];
extern struct song ram_ab000[];

unsigned int Part_ReadWord(unsigned char a, unsigned int o)
{
  unsigned char *p;
  if (a == 0) p = &SEQ_SONG_RECORD[o];
  else p = (unsigned char *)&ram_ab000[(unsigned char)(a - 1)] + o;
  return *(unsigned int *)p;
}

void Part_WriteWord(unsigned char a, unsigned int o, unsigned int v)
{
  unsigned char *p;
  if (a == 0) p = &SEQ_SONG_RECORD[o];
  else p = (unsigned char *)&ram_ab000[(unsigned char)(a - 1)] + o;
  *(unsigned int *)p = v;
}

unsigned char Part_ReadSubBlock32(unsigned char a, unsigned char i)
{
  unsigned char *p;
  if (a == 0) p = SEQ_TRACK_ASSIGN;
  else p = SEQ_SONG_SLOTS + ((unsigned long)(unsigned char)(a - 1) << 11) + 32;
  return *(p + i - 1);
}

void SeqData_CopyBlock2K(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *q, *e;
  if (a == 0) p = SEQ_SONG_RECORD + 256;
  else p = SEQ_SONG_SLOTS + ((unsigned long)(unsigned char)(a - 1) << 11) + 256;
  q = buf; e = buf + 16;
  do *q++ = *p++; while (q < e);
}

void Part_CopyBlock16(unsigned char a, unsigned char *buf)
{
  unsigned char *p, *q, *e;
  if (a == 0) p = SEQ_SONG_RECORD + 256;
  else p = SEQ_SONG_SLOTS + ((unsigned long)(unsigned char)(a - 1) << 11) + 256;
  q = buf; e = buf + 16;
  do *p++ = *q++; while (q < e);
}

void Part_CopyToBuffer(unsigned char a, unsigned char c)
{
  unsigned char *s, *d;
  unsigned int i;
  if (a == 0) s = SEQ_SONG_RECORD + 736;
  else s = SEQ_SONG_SLOTS + ((unsigned long)(unsigned char)(a - 1) << 11) + 736;
  if (c == 0) d = SEQ_SONG_RECORD + 736;
  else d = SEQ_SONG_SLOTS + ((unsigned long)(unsigned char)(c - 1) << 11) + 736;
  i = 0;
  do { *d++ = *s++; i++; } while (i < 0x520);
}

int SeqEvent_GetParamLength(unsigned char a)
{
  int n;
  switch (a & 0xf0) {
  case 0x90: case 0xb0: n = 6; break;
  case 0xc0: n = 6; break;
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
  case 0x90: case 0xb0: n = 6; break;
  case 0xc0: n = 6; break;
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
  int r;
  if (p[5] == 1) {
    switch (p[6]) { case 8: r = p[4]; break; case 7: case 6: case 3: r = p[4]; break; default: r = -102; }
  } else r = -102;
  return r;
}

struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
struct lnk { unsigned char a, b; };
extern unsigned char __near ram_c5ca[][3];
extern struct lnk __near ram_e7e8[];
extern unsigned char NoteMap_LinkByte_Table[];

unsigned char NoteMap_FindLinkedSlotByKey(struct nrec *r, unsigned char idx)
{
  unsigned char *t;
  struct lnk *lk;
  unsigned char h, key, l;
  t = (unsigned char *)ram_c5ca;
  lk = ram_e7e8;
  h = NoteMap_LinkByte_Table[r->b3];
  key = r->ent[idx][0];
  l = lk[h].b;
  if (l != h) do {
    if ((t + l * 3)[1] == key) return l;
    l = lk[l].b;
  } while (l != h);
  return l;
}

struct prec { unsigned int v; unsigned int f2; unsigned int arr[17]; unsigned int f38; unsigned char pad[4];
  unsigned int n; unsigned char rest[10]; };
struct pdbs { unsigned char hdr[8]; struct prec rec[5]; };
extern struct pdbs ram_3c0fa;

int SendPartDataBlock_InitVal(unsigned int p, unsigned int v)
{
  int r = 0;
  if (p < 5 && v <= 99) ram_3c0fa.rec[p].v = v;
  else r = -1;
  return r;
}

int SendPartDataBlock_InitVal2(unsigned int p, unsigned int v)
{
  int r = 0;
  if (p < 5) ram_3c0fa.rec[p].n = v;
  else r = -1;
  return r;
}

int SendPartDataBlock_InitVal3(unsigned int p, unsigned int v)
{
  int r = 0;
  if (p < 5) ram_3c0fa.rec[p].f38 = v;
  else r = -1;
  return r;
}

int SendPartDataBlock_Prologue(unsigned int p, unsigned int i, unsigned int v)
{
  int r = 0;
  struct prec *q;
  if (p < 5) {
    q = &ram_3c0fa.rec[p];
    if (i < q->n) ram_3c0fa.rec[p].arr[i] = v;
    else r = -1;
  } else r = -1;
  return r;
}

long MidiSysMsg_DecodeDeltaTime(unsigned char a, unsigned char *p)
{
  long r;
  unsigned char lo, hi;
  if (a == 0xf4) {
    lo = p[0] & 0x7f;
    hi = p[1] & 0x7f;
    lo |= hi << 7;
    hi >>= 1;
    r = (int)((hi << 8) + lo);
  } else if (a == 0xf3) r = (unsigned long)(p[0] & 0x7f);
  else r = 0;
  return r;
}

unsigned long Param_SignExtendRetu_Data(unsigned char *p)
{
  unsigned long a, b, c;
  a = 0;
  a = p[6];
  a <<= 14;
  b = (unsigned long)(p[7] & 0x7f) << 7;
  c = p[8] & 0x7f;
  return a | b | c;
}
