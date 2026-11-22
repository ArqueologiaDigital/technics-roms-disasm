/* helper Q, round 20r1, module 250 (sequencer/accompaniment_engine.s).  The ROM jumps over a jump to the call
   (jr z to the call, jr to the ret): try the if with the call in a braced block. */

extern unsigned char __near CURRENT_TITLE;
extern void AccPat_DispatchNoteChange(void);

void RhythmProc_CheckStyleSwitch(void)
{
  if (CURRENT_TITLE == 184) {
    AccPat_DispatchNoteChange();
  }
}
