/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_9a.c (2026-11-16-87-p6-r15)
   sha256 55e75172a5bb6c342452c899c65ee31e2529b9a9e2c8c490404fc05efb082d4a (tar-sha256); compiled at -Xr */
#define NM_ENT(r, i) ((unsigned char *)(r) + ((unsigned long)(i) * 5 + 4))
void InitChannelState_Che_InitVal(unsigned char *r)
{
  unsigned int i;
  for (i = 0; i < r[1]; i++) {
    NM_ENT(r, i)[4] = 0;
    if (NM_ENT(r, i)[1] != 0) {
      NM_ENT(r, i)[2] = NM_ENT(r, i)[0];
      NM_ENT(r, i)[3] = NM_ENT(r, i)[0];
    }
  }
}
