/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_3a.c (2026-11-16-38-p6-r6)
   sha256 08077e5f71e6fd71c8809069ff7c2ec22415c371e919999a81e5dbe9e7f09f47 (tar-sha256); compiled at -O3 -XS -Xr */
struct sbent { unsigned char f[4]; unsigned int pos; unsigned char g[4]; unsigned char prev, next; };
struct sbhdr { unsigned char head, tail; };
extern struct sbent __near ram_1ffa[];
extern struct sbhdr __near ram_1ff8;
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
