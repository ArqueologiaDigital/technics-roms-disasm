/* Phase 6, helper B, round 13, form a: NoteMap_LookupAndMergeVoice and Voice_LookupTableEntries of v10's
   audio/note_voice_mapping.s (-Xr), with the idiom that matched InitChannelState_Che_InitVal in run -92: entry and
   table-row fields as members of a struct pointer made from the byte offset (the field stays a displacement).
   Locals declared table pointer first, link pointer second. */

struct nent5 { unsigned char e0, e1, e2, e3, e4; };
struct row3 { unsigned char k, f1, f2; };
struct lnk { unsigned char a, b; };
#define NM_E(r, i) ((struct nent5 *)((unsigned char *)(r) + ((unsigned long)(i) * 5 + 4)))
#define ROW(t, k) ((struct row3 *)((unsigned char *)(t) + (k) * 3))
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
      NM_E(r, i)->e0 = ROW(t, (int)k)->f1;
      NM_E(r, i)->e1 = ROW(t, (int)k)->f2;
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
      NM_E(r, i)->e0 = ROW(t, (int)k)->f1;
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
