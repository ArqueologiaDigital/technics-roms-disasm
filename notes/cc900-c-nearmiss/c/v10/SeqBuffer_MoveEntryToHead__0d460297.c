/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_1a.c (2026-11-16-30-p6-r1)
   sha256 0d4602979081b19630e392a553f4b00a47f318a801919b0bcf1285f383535a70 (tar-sha256); compiled at -O3 -XS -Xr */
struct sbent { unsigned char f[4]; unsigned int pos; unsigned char g[4]; unsigned char prev, next; };
struct sbhdr { unsigned char head, tail; };
extern struct sbent __near ram_1ffa[];
extern struct sbhdr __near ram_1ff8;
extern unsigned char __near ram_e38a;
void SeqBuffer_MoveEntryToHead(unsigned char a)
{
  unsigned char t;
  if (a == 0xff) ram_e38a = 0xff;
  t = ram_1ff8.tail;
  if (t == 0xff) { ram_1ff8.head = a; ram_1ffa[a].prev = 0xff; }
  else { ram_1ffa[t].next = a; ram_1ffa[a].prev = t; }
  ram_1ff8.tail = a;
  ram_1ffa[a].next = 0xff;
}
