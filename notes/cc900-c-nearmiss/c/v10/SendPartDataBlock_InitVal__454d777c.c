/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_2b.c (2026-11-16-35-p6-r3)
   sha256 454d777c57a47bdce681897b54082758f1f7c5ab8c73314b6fddcdcbecf34fe5 (tar-sha256); compiled at -O3 -Xr */
struct pdb { unsigned char x[8]; unsigned int v; unsigned char y[46]; };
int SendPartDataBlock_InitVal(unsigned int p, unsigned int v)
{
  int r = 0;
  if (p < 5 && v <= 99) ((struct pdb *)0x3c0fa)[p].v = v;
  else r = -1;
  return r;
}
