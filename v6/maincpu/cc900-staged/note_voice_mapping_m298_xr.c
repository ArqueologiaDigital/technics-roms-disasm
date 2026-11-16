/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct nent5 { unsigned char e0, e1, e2, e3, e4; };
#define NM_E(r, i) ((struct nent5 *)((unsigned char *)(r) + ((unsigned long)(i) * 5 + 4)))
extern void InitChannelState_Che_InitVal(unsigned char *r);

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
