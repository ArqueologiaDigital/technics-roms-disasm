/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_1b.c (2026-11-16-30-p6-r1)
   sha256 bd6e4557c8e04a2edcf7c0a4f18652e01cf59f735fd3362c0cbe758f01080833 (tar-sha256); compiled at -Xr */
struct nent { unsigned char e0, e1, e2, e3, e4; };
struct nrec { unsigned char b0, count, b2, b3; struct nent ent[32]; };
struct t3 { unsigned char k, f1, f2; };
struct lnk { unsigned char a, b; };
extern struct t3 __near ram_c5ca[];
extern struct lnk __near ram_e7e8[];
extern unsigned char NoteMap_LinkByte_Table[];
unsigned char NoteMap_FindLinkedSlotByKey(struct nrec *r, unsigned char idx)
{
  struct t3 *t = ram_c5ca;
  struct lnk *lk = ram_e7e8;
  unsigned char h, key, l;
  h = NoteMap_LinkByte_Table[r->b3];
  key = r->ent[idx].e0;
  l = lk[h].b;
  if (l == h) return l;
  do {
    if (t[l].f1 == key) return l;
    l = lk[l].b;
  } while (l != h);
  return l;
}
