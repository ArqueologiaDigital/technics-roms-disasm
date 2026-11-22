/* Probe round 34r1, helper Y, form b: sequencer/seq_step_routines.s (module 236).
   As form a (SeqStep_SwapTwoParts), with one spot changed: no `register` on the first parameter. */
/* cc900-module: SeqStep_CopyPartData SeqStep_SearchBackward SeqStep_SearchForward SeqStep_UpdateForwardLinks SeqStep_UpdateRefsAfterSwap */

extern void SeqStep_CopyPartData(unsigned int, unsigned int);
extern void SeqStep_UpdateRefsAfterSwap(unsigned int, unsigned int);
extern void SeqStep_UpdateForwardLinks(unsigned int, unsigned int);
extern unsigned int SeqStep_SearchBackward(unsigned int);
extern unsigned int SeqStep_SearchForward(unsigned int);
extern void SeqStep_SwapTwoParts(unsigned int *, unsigned int *);

void SeqStep_SwapTwoParts(unsigned int *a, unsigned int *b)
{
    SeqStep_CopyPartData(*a, *b);
    SeqStep_UpdateRefsAfterSwap(*a, *b);
    SeqStep_UpdateForwardLinks(*a, *b);
    *a = SeqStep_SearchBackward(*a);
    *b = SeqStep_SearchForward(*b);
}
