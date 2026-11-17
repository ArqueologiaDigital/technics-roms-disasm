/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_2a.c (2026-11-16-35-p6-r3)
   sha256 c97b2399af5c6580229970cea088ec622459e83731fa38d6c7f60b660d01c853 (tar-sha256); compiled at -Xr */
struct nrec { unsigned char b0, count, b2, b3; unsigned char ent[32][5]; };
struct lnk { unsigned char a, b; };
extern unsigned char __near ram_c5ca[][3];
extern struct lnk __near ram_e7e8[];
extern unsigned char NoteMap_LinkByte_Table[];
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
