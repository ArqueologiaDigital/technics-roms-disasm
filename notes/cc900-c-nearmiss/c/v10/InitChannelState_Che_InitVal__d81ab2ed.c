/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_11b.c (2026-11-16-92-p6-r18)
   sha256 d81ab2ed510917a4554387354931a99fcc0a113f9672b322cfb51e6682af2006 (tar-sha256); compiled at -Xr */
struct nent5 { unsigned char e0, e1, e2, e3, e4; };
void InitChannelState_Che_InitVal(unsigned char *r)
{
  unsigned int i;
  struct nent5 *e;
  for (i = 0; i < r[1]; i++) {
    e = (struct nent5 *)(r + ((unsigned long)i * 5 + 4));
    e->e4 = 0;
    if (e->e1 != 0) { e->e2 = e->e0; e->e3 = e->e0; }
  }
}
