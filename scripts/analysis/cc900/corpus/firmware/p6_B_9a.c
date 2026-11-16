/* Phase 6, helper B, round 9, form a: routines blocked until now by byte registers (QA..QE / IXL / IYL), re-done
   with the record-address idiom (char *)base + i * N (signed multiply, as the firmware has it; V4.23 pads
   structs to an even size and multiplies an array index unsigned).
   sequencer/sequencer_engine.s: -O3 -Xr; audio/note_voice_mapping.s: -Xr. */

/* ---- sequencer/sequencer_engine.s ---- */

int VoiceType_CheckDrumOrControl(unsigned char a, unsigned char *p)
{
  unsigned char f = 0;
  if (p[0] == 0x82) goto zero;
  if ((p[0] & 0xf0) == 0xc0) { if (p[2] == 0x48 && p[3] == 0) f = 1; }
  else if ((p[0] & 0xf0) == 0xb0 && p[2] == 0x48 && p[3] == 7) f = 1;
  if (a == 0x15) {
    if (f != 1) goto neg;
  zero:
    return 0;
  }
  if (f == 0) goto zero;
neg:
  return -1;
}

/* 64 buffer slots of 12 bytes at 0x1ffa {f[4], pos, g[4], prev, next}; 0x1ff6 = used list, 0x1ff8 = free list */
struct sbent { unsigned char f[4]; unsigned int pos; unsigned char g[4]; unsigned char prev, next; };
struct sbhdr { unsigned char head, tail; };
extern struct sbent __near ram_1ffa[];
extern struct sbhdr __near ram_1ff6;
extern struct sbhdr __near ram_1ff8;
extern unsigned char __near ram_e38a;
extern unsigned char __near ram_2868;
#define SB_ENT(t, i) ((struct sbent *)((unsigned char *)(t) + (i) * 12))

void SeqBuffer_UnlinkEntry(unsigned char a)
{
  unsigned char *t = (unsigned char *)ram_1ffa;
  struct sbent *e = SB_ENT(t, a);
  unsigned char prev = e->prev, next = e->next;
  struct sbhdr *h = &ram_1ff6;
  unsigned char *tl = &h->tail;
  unsigned char *pn, *pp;
  if (prev == 0xff && next == 0xff) { h->head = 0xff; *tl = 0xff; return; }
  pn = &SB_ENT(t, next)->prev;
  if (prev == 0xff) { h->head = next; *pn = 0xff; return; }
  pp = &SB_ENT(t, prev)->next;
  if (next == 0xff) { *tl = prev; *pp = 0xff; return; }
  *pn = prev;
  *pp = next;
}

void SeqBuffer_InsertAtHead(unsigned char a)
{
  struct sbhdr *h = &ram_1ff6;
  unsigned char *tl = &h->tail;
  unsigned char w = *tl;
  int o = a * 12;
  unsigned char *t = (unsigned char *)ram_1ffa;
  unsigned char *pv = &((struct sbent *)(t + o))->prev;
  if (w == 0xff) { h->head = a; *pv = 0xff; }
  else { SB_ENT(t, w)->next = a; *pv = w; }
  *tl = a;
  *((unsigned char *)&ram_1ffa[0].next + o) = 0xff;
}

void SeqBuffer_MoveEntryToHead(unsigned char a)
{
  struct sbhdr *h;
  unsigned char *tl, *t, *pv;
  unsigned char w;
  int o;
  if (a == 0xff) ram_e38a = 0xff;
  h = &ram_1ff8;
  tl = &h->tail;
  w = *tl;
  o = a * 12;
  t = (unsigned char *)ram_1ffa;
  pv = &((struct sbent *)(t + o))->prev;
  if (w == 0xff) { h->head = a; *pv = 0xff; }
  else { SB_ENT(t, w)->next = a; *pv = w; }
  *tl = a;
  ((struct sbent *)(t + o))->next = 0xff;
}

unsigned char SeqBuffer_RemoveLastEntry(void)
{
  struct sbhdr *h = &ram_1ff8;
  unsigned char *t;
  unsigned char l, n;
  l = h->head;
  if (l == 0xff) return l;
  t = (unsigned char *)ram_1ffa;
  n = SB_ENT(t, l)->next;
  if (n != 0xff) SB_ENT(t, n)->prev = 0xff;
  h->head = n;
  if (n == 0xff) ram_2868 = l;
  return l;
}

/* two lists of 9-byte nodes {prev, next, ...} at 0x1db6; 0x1db2 = head / tail of list 1, head / tail of list 2 */
extern unsigned char __near ram_1db6[];
extern unsigned char __near ram_1db2[];

void NoteMap_RemoveHeadEntry(unsigned char a)
{
  unsigned char *t = ram_1db6;
  unsigned char *h;
  unsigned char e;
  e = (t + a * 9)[1];
  h = ram_1db2;
  h[2] = e;
  if (e != 0xff) *(t + e * 9) = 0xff;
  else h[3] = e;
}

void NoteMap_RemoveAndRelink(unsigned char a)
{
  unsigned char *t = ram_1db6;
  unsigned char *p = t + a * 9;
  unsigned char *q = p + 1;
  unsigned char prev = p[0], next = *q;
  unsigned char *h, *z, *y, *tl;
  if (prev == 0xff && next == 0xff) { h = ram_1db2; h[0] = 0xff; h[1] = 0xff; }
  else {
    z = t + next * 9;
    h = ram_1db2;
    if (prev == 0xff) { h[0] = next; prev = 0xff; }
    else {
      y = t + prev * 9 + 1;
      if (next == 0xff) { h[1] = prev; *y = 0xff; goto tail; }
      *y = next;
    }
    *z = prev;
  }
tail:
  h = ram_1db2;
  tl = h + 3;
  prev = *tl;
  if (prev == 0xff) { h[2] = a; prev = 0xff; }
  else (t + prev * 9)[1] = a;
  p[0] = prev;
  *tl = a;
  *q = 0xff;
}

/* ---- audio/note_voice_mapping.s (-Xr) ---- */

/* a note record: +1 count, +3 list selector, 5-byte entries from +4 */
#define NM_ENT(r, i) ((unsigned char *)(r) + ((unsigned long)(i) * 5 + 4))
struct lnk { unsigned char a, b; };
extern unsigned char __near ram_c5ca[];
extern struct lnk __near ram_e7e8[];
extern unsigned char NoteMap_LinkByte_Table[];

unsigned char NoteMap_LookupAndMergeVoice(unsigned char *r)
{
  unsigned char *t = ram_c5ca;
  struct lnk *lk = ram_e7e8;
  unsigned char n = 0x20;
  unsigned char h, k;
  unsigned int i;
  if (r[3] < 2) {
    h = NoteMap_LinkByte_Table[r[3]];
    i = 0;
    k = lk[h].a;
    while (k != h) {
      NM_ENT(r, i)[0] = (t + k * 3)[1];
      NM_ENT(r, i)[1] = (t + k * 3)[2];
      NM_ENT(r, i)[4] = 0;
      k = lk[k].a;
      i++;
    }
    return r[1] = i;
  }
  r[1] = 0;
  return 0;
}

unsigned char Voice_LookupTableEntries(unsigned char *r)
{
  unsigned char *t = ram_c5ca;
  struct lnk *lk = ram_e7e8;
  unsigned char n = 0x20;
  unsigned char h, k;
  unsigned int i;
  if (r[3] < 2) {
    h = NoteMap_LinkByte_Table[r[3]];
    i = 0;
    k = lk[h].a;
    while (k != h) {
      NM_ENT(r, i)[0] = (t + k * 3)[1];
      NM_ENT(r, i)[1] = 0;
      NM_ENT(r, i)[4] = 0;
      k = lk[k].a;
      i++;
    }
    return r[1] = i;
  }
  r[1] = 0;
  return 0;
}

void InitChannelState_Che_InitVal(unsigned char *r)
{
  unsigned int i;
  for (i = 0; i < r[1]; i++) {
    NM_ENT(r, i)[4] = 0;
    if (NM_ENT(r, i)[1] != 0) {
      NM_ENT(r, i)[2] = NM_ENT(r, i)[0];
      NM_ENT(r, i)[3] = NM_ENT(r, i)[0];
    }
  }
}
