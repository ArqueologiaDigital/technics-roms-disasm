/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_3b.c (2026-11-16-38-p6-r6)
   sha256 fc0ec014df313a4af627cbf7507f0e11cc3de64de9b914dbdf302199fac3bcf2 (tar-sha256); compiled at -O3 -XS -Xr */
struct sbent { unsigned char f[4]; unsigned int pos; unsigned char g[4]; unsigned char prev, next; };
struct sbhdr { unsigned char head, tail; };
extern struct sbent __near ram_1ffa[];
extern struct sbhdr __near ram_1ff8;
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
