/* Phase 6, helper B, round 13, form b: as p6_B_13a.c, with the link pointer declared first and the table rows as
   a 2-D array indexed by the byte (struct-array indexing gives V4.23's signed multiply). */

struct nent5 { unsigned char e0, e1, e2, e3, e4; };
struct row3 { unsigned char k, f1, f2; };
struct lnk { unsigned char a, b; };
#define NM_E(r, i) ((struct nent5 *)((unsigned char *)(r) + ((unsigned long)(i) * 5 + 4)))
extern unsigned char __near ram_c5ca[][3];
extern struct lnk __near ram_e7e8[];
extern unsigned char NoteMap_LinkByte_Table[];

unsigned char NoteMap_LookupAndMergeVoice(unsigned char *r)
{
  struct lnk *lk = ram_e7e8;
  unsigned char (*t)[3] = ram_c5ca;
  unsigned char n = 0x20;
  unsigned char h, k;
  unsigned int i;
  if (r[3] < 2) {
    h = NoteMap_LinkByte_Table[r[3]];
    i = 0;
    k = lk[h].a;
    while (k != h) {
      NM_E(r, i)->e0 = ((struct row3 *)t[k])->f1;
      NM_E(r, i)->e1 = ((struct row3 *)t[k])->f2;
      NM_E(r, i)->e4 = 0;
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
  struct lnk *lk = ram_e7e8;
  unsigned char (*t)[3] = ram_c5ca;
  unsigned char n = 0x20;
  unsigned char h, k;
  unsigned int i;
  if (r[3] < 2) {
    h = NoteMap_LinkByte_Table[r[3]];
    i = 0;
    k = lk[h].a;
    while (k != h) {
      NM_E(r, i)->e0 = ((struct row3 *)t[k])->f1;
      NM_E(r, i)->e1 = 0;
      NM_E(r, i)->e4 = 0;
      k = lk[k].a;
      i++;
    }
    return r[1] = i;
  }
  r[1] = 0;
  return 0;
}
