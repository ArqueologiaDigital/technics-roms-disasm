/* helper W, round 21r2, module 236 (sequencer/seq_step_routines.s), form a: SeqStep_TimerDispatchB spelled exactly
   as its built twin SeqStep_TimerDispatchC (cc900/seq_step_routines_m236.c): `(*Table[byte cell])()`, no locals.
   Run r62's best (p6_U_21r1m236b@O3Xr) differed at +6: `extz xwa; sll xwa, 2` where the ROM keeps the word index
   (`sla wa, 2; ld xhl, (xbc+wa)`).
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_22fc;
extern void (*SeqStep_TimerDispatchB_PtrTable[])(void);

void SeqStep_TimerDispatchB(void)
{
  (*SeqStep_TimerDispatchB_PtrTable[ram_22fc])();
}
