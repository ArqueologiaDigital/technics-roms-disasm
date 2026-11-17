/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_9b.c (2026-11-16-87-p6-r15)
   sha256 5e8b58d00e7ea44f19f75c57696df9a15178cfdb7df2be5742c6f7750a660f72 (tar-sha256); compiled at -O3 -XS -Xr */
struct sbent { unsigned char f[4]; unsigned int pos; unsigned char g[4]; unsigned char prev, next; };
struct sbhdr { unsigned char head, tail; };
extern struct sbent __near ram_1ffa[];
extern struct sbhdr __near ram_1ff8;
extern unsigned char __near ram_2868;
#define SB_AT(i) ((struct sbent *)((unsigned char *)ram_1ffa + (i) * 12))
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
