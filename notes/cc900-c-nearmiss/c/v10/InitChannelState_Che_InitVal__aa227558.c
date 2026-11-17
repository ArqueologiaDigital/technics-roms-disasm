/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_11a.c (2026-11-16-92-p6-r18)
   sha256 aa227558529a43e6feafcf5b6736308bb0bfdad7c116dc793b1a88a0e5ff34c3 (tar-sha256); compiled at -Xr */
struct nent5 { unsigned char e0, e1, e2, e3, e4; };
#define NM_E(r, i) ((struct nent5 *)((unsigned char *)(r) + ((unsigned long)(i) * 5 + 4)))
void InitChannelState_Che_InitVal(unsigned char *r)
{
  unsigned int i;
  for (i = 0; i < r[1]; i++) {
    NM_E(r, i)->e4 = 0;
    if (NM_E(r, i)->e1 != 0) {
      NM_E(r, i)->e2 = NM_E(r, i)->e0;
      NM_E(r, i)->e3 = NM_E(r, i)->e0;
    }
  }
}
