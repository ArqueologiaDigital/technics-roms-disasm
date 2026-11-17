/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_9b.c (2026-11-16-87-p6-r15)
   sha256 5e8b58d00e7ea44f19f75c57696df9a15178cfdb7df2be5742c6f7750a660f72 (tar-sha256); compiled at -Xr */
#define NM_ENT(r, i) ((unsigned char *)(r) + ((unsigned long)(i) * 5 + 4))
void InitChannelState_Che_InitVal(unsigned char *r)
{
  unsigned int i;
  for (i = 0; i < r[1]; i++) {
    NM_ENT(r, i)[4] = 0;
    if (NM_ENT(r, i)[1]) {
      NM_ENT(r, i)[2] = NM_ENT(r, i)[0];
      NM_ENT(r, i)[3] = NM_ENT(r, i)[0];
    }
  }
}
