/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_9a.c (2026-11-16-87-p6-r15)
   sha256 55e75172a5bb6c342452c899c65ee31e2529b9a9e2c8c490404fc05efb082d4a (tar-sha256); compiled at -O3 -XS -Xr */
struct sbent { unsigned char f[4]; unsigned int pos; unsigned char g[4]; unsigned char prev, next; };
struct sbhdr { unsigned char head, tail; };
extern struct sbent __near ram_1ffa[];
extern struct sbhdr __near ram_1ff8;
extern unsigned char __near ram_2868;
#define SB_ENT(t, i) ((struct sbent *)((unsigned char *)(t) + (i) * 12))
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
