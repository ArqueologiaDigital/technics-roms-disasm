/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/note_voice_mapping_m298_xr.c (2026-11-16-111-p6-r22-staged)
   sha256 694b755091315d99b390daad955b1ed214ffc2463a183aeb1a97d5145f80845f (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
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
