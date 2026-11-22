/* Probe round 34r1, helper Y, form a: sequencer/seq_step_routines.s (module 236), unoptimised -Xr shape.
   SeqStep_SwapTwoParts(a, b): swap the two parts whose numbers a and b point at (copy the data, fix the
   references and forward links), then move each number to its part's new place (search backward / forward).
   The first pointer is a `register` parameter (XIZ), the second stays on the frame and is reloaded each time. */
/* cc900-module: SeqStep_CopyPartData SeqStep_SearchBackward SeqStep_SearchForward SeqStep_UpdateForwardLinks SeqStep_UpdateRefsAfterSwap */

extern void SeqStep_CopyPartData(unsigned int, unsigned int);
extern void SeqStep_UpdateRefsAfterSwap(unsigned int, unsigned int);
extern void SeqStep_UpdateForwardLinks(unsigned int, unsigned int);
extern unsigned int SeqStep_SearchBackward(unsigned int);
extern unsigned int SeqStep_SearchForward(unsigned int);
extern void SeqStep_SwapTwoParts(unsigned int *, unsigned int *);

void SeqStep_SwapTwoParts(register unsigned int *a, unsigned int *b)
{
    SeqStep_CopyPartData(*a, *b);
    SeqStep_UpdateRefsAfterSwap(*a, *b);
    SeqStep_UpdateForwardLinks(*a, *b);
    *a = SeqStep_SearchBackward(*a);
    *b = SeqStep_SearchForward(*b);
}
