/* Functions of sequencer/seq_step_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqStep_CopyPartData SeqStep_SearchBackward SeqStep_SearchForward SeqStep_UpdateForwardLinks SeqStep_UpdateRefsAfterSwap */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeqStep_CopyPartData(unsigned int, unsigned int);
extern void SeqStep_UpdateRefsAfterSwap(unsigned int, unsigned int);
extern void SeqStep_UpdateForwardLinks(unsigned int, unsigned int);
extern unsigned int SeqStep_SearchBackward(unsigned int);
extern unsigned int SeqStep_SearchForward(unsigned int);
extern void SeqStep_SwapTwoParts(unsigned int *, unsigned int *);
extern void SeqStep_SwapTwoParts(register unsigned int *a, unsigned int *b);

void SeqStep_SwapTwoParts(register unsigned int *a, unsigned int *b)
{
    SeqStep_CopyPartData(*a, *b);
    SeqStep_UpdateRefsAfterSwap(*a, *b);
    SeqStep_UpdateForwardLinks(*a, *b);
    *a = SeqStep_SearchBackward(*a);
    *b = SeqStep_SearchForward(*b);
}
