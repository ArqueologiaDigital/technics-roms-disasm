/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_3a.c (2026-11-16-38-p6-r6)
   sha256 08077e5f71e6fd71c8809069ff7c2ec22415c371e919999a81e5dbe9e7f09f47 (tar-sha256); compiled at -Xr */
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
