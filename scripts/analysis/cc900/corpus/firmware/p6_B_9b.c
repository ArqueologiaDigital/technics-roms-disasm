/* Phase 6, helper B, round 9, form b: the functions of p6_B_9a.c with other C shapes (global base instead of a
   local, no index temporaries, returns instead of gotos, if + do-while loops). */

/* ---- sequencer/sequencer_engine.s ---- */

int VoiceType_CheckDrumOrControl(unsigned char a, unsigned char *p)
{
  unsigned char f = 0;
  if (p[0] == 0x82) return 0;
  if ((p[0] & 0xf0) == 0xc0) { if (p[2] == 0x48 && p[3] == 0) f = 1; }
  else if ((p[0] & 0xf0) == 0xb0 && p[2] == 0x48 && p[3] == 7) f = 1;
  if (a == 0x15 ? f == 1 : f == 0) return 0;
  return -1;
}

struct sbent { unsigned char f[4]; unsigned int pos; unsigned char g[4]; unsigned char prev, next; };
struct sbhdr { unsigned char head, tail; };
extern struct sbent __near ram_1ffa[];
extern struct sbhdr __near ram_1ff6;
extern struct sbhdr __near ram_1ff8;
extern unsigned char __near ram_e38a;
extern unsigned char __near ram_2868;
#define SB_AT(i) ((struct sbent *)((unsigned char *)ram_1ffa + (i) * 12))

void SeqBuffer_UnlinkEntry(unsigned char a)
{
  struct sbent *e = SB_AT(a);
  unsigned char prev = e->prev, next = e->next;
  struct sbhdr *h = &ram_1ff6;
  unsigned char *tl = &h->tail;
  unsigned char *pn, *pp;
  if (prev == 0xff && next == 0xff) { h->head = 0xff; *tl = 0xff; return; }
  pn = &SB_AT(next)->prev;
  if (prev == 0xff) { h->head = next; *pn = 0xff; return; }
  pp = &SB_AT(prev)->next;
  if (next == 0xff) { *tl = prev; *pp = 0xff; return; }
  *pn = prev;
  *pp = next;
}

void SeqBuffer_InsertAtHead(unsigned char a)
{
  struct sbhdr *h = &ram_1ff6;
  unsigned char *tl = &h->tail;
  unsigned char w = *tl;
  unsigned char *pv = &SB_AT(a)->prev;
  if (w == 0xff) { h->head = a; *pv = 0xff; }
  else { SB_AT(w)->next = a; *pv = w; }
  *tl = a;
  *((unsigned char *)&ram_1ffa[0].next + a * 12) = 0xff;
}

void SeqBuffer_MoveEntryToHead(unsigned char a)
{
  struct sbhdr *h;
  unsigned char *tl, *pv;
  unsigned char w;
  if (a == 0xff) ram_e38a = 0xff;
  h = &ram_1ff8;
  tl = &h->tail;
  w = *tl;
  pv = &SB_AT(a)->prev;
  if (w == 0xff) { h->head = a; *pv = 0xff; }
  else { SB_AT(w)->next = a; *pv = w; }
  *tl = a;
  SB_AT(a)->next = 0xff;
}

unsigned char SeqBuffer_RemoveLastEntry(void)
{
  struct sbhdr *h = &ram_1ff8;
  unsigned char l, n;
  l = h->head;
  if (l == 0xff) return l;
  n = SB_AT(l)->next;
  if (n != 0xff) SB_AT(n)->prev = 0xff;
  h->head = n;
  if (n == 0xff) ram_2868 = l;
  return l;
}

extern unsigned char __near ram_1db6[];
extern unsigned char __near ram_1db2[];

void NoteMap_RemoveHeadEntry(unsigned char a)
{
  unsigned char *t = ram_1db6;
  unsigned char e;
  e = *(t + a * 9 + 1);
  ram_1db2[2] = e;
  if (e != 0xff) *(t + e * 9) = 0xff;
  else ram_1db2[3] = e;
}

void NoteMap_RemoveAndRelink(unsigned char a)
{
  unsigned char *t = ram_1db6;
  unsigned char *p = t + a * 9;
  unsigned char *q = p + 1;
  unsigned char prev = p[0], next = *q, w;
  unsigned char *h, *tl;
  if (prev == 0xff && next == 0xff) { h = ram_1db2; h[0] = 0xff; h[1] = 0xff; }
  else if (prev == 0xff) { h = ram_1db2; h[0] = next; *(t + next * 9) = 0xff; }
  else if (next == 0xff) { h = ram_1db2; h[1] = prev; (t + prev * 9)[1] = 0xff; }
  else { (t + prev * 9)[1] = next; *(t + next * 9) = prev; }
  h = ram_1db2;
  tl = h + 3;
  w = *tl;
  if (w == 0xff) h[2] = a;
  else (t + w * 9)[1] = a;
  p[0] = w;
  *tl = a;
  *q = 0xff;
}

/* ---- audio/note_voice_mapping.s (-Xr) ---- */

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
  if (r[3] >= 2) { r[1] = 0; return 0; }
  h = NoteMap_LinkByte_Table[r[3]];
  i = 0;
  k = lk[h].a;
  if (k != h) do {
    NM_ENT(r, i)[0] = (t + k * 3)[1];
    NM_ENT(r, i)[1] = (t + k * 3)[2];
    NM_ENT(r, i)[4] = 0;
    k = lk[k].a;
    i++;
  } while (k != h);
  return r[1] = i;
}

unsigned char Voice_LookupTableEntries(unsigned char *r)
{
  unsigned char *t = ram_c5ca;
  struct lnk *lk = ram_e7e8;
  unsigned char n = 0x20;
  unsigned char h, k;
  unsigned int i;
  if (r[3] >= 2) { r[1] = 0; return 0; }
  h = NoteMap_LinkByte_Table[r[3]];
  i = 0;
  k = lk[h].a;
  if (k != h) do {
    NM_ENT(r, i)[0] = (t + k * 3)[1];
    NM_ENT(r, i)[1] = 0;
    NM_ENT(r, i)[4] = 0;
    k = lk[k].a;
    i++;
  } while (k != h);
  return r[1] = i;
}

void InitChannelState_Che_InitVal(unsigned char *r)
{
  unsigned int i;
  for (i = 0; i < r[1]; i++) {
    NM_ENT(r, i)[4] = 0;
    if (NM_ENT(r, i)[1]) {
      NM_ENT(r, i)[2] = NM_ENT(r, i)[0];
      NM_ENT(r, i)[3] = NM_ENT(r, i)[0];
    }
  }
}
