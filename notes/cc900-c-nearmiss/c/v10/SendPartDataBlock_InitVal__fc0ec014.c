/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_3b.c (2026-11-16-38-p6-r6)
   sha256 fc0ec014df313a4af627cbf7507f0e11cc3de64de9b914dbdf302199fac3bcf2 (tar-sha256); compiled at -O3 -XS -Xr */
struct prec { unsigned int v; unsigned int f2; unsigned int arr[17]; unsigned int f38; unsigned char pad[4];
  unsigned int n; unsigned char rest[10]; };
struct pdbs { unsigned char hdr[8]; struct prec rec[5]; };
extern struct pdbs ram_3c0fa;
int SendPartDataBlock_InitVal(unsigned int p, unsigned int v)
{
  int r = 0;
  if (p < 5 && v <= 99) ram_3c0fa.rec[p].v = v;
  else r = -1;
  return r;
}
