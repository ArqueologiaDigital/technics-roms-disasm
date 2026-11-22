/* Probe round 35r1, helper A, form a: sequencer/sequencer_engine.s (module 235), xr_screen family.
   SeqScan_CompareAndAppend(w, c, e): queue the entry (w, c, e) and clear entry e of song slot c.
   w is used once before the first call and stays in WA; c / e live across the first call (frame slots). */
/* cc900-module: PartCtrl_AppendToEventQueue Part_ClearVoiceSlot */

extern void PartCtrl_AppendToEventQueue(unsigned int, unsigned int, unsigned int);
extern void Part_ClearVoiceSlot(unsigned int, unsigned int);
extern void SeqScan_CompareAndAppend(unsigned int, unsigned char, unsigned char);

void SeqScan_CompareAndAppend(unsigned int w, unsigned char c, unsigned char e)
{
    PartCtrl_AppendToEventQueue(w, c, e);
    Part_ClearVoiceSlot(c, e);
}
