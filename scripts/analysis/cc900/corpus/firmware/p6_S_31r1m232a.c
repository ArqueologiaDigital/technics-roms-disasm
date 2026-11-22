/* lane_p6 helper S, round 31r1: module 232, form a: sequencer/sequencer_engine.s's SeqPlay_ResetPlaybackState and
   sequencer/bmdredit_routines.s's velocity steppers.
   BmDrEdit_VelocityUp_Check / BmDrEdit_VelocityDown_Check: the built BmDrEdit_DurationUp_Check's test, then a tail
   jump to one of the two bodies after them (named BmDrEdit_IncrementVelocity / BmDrEdit_DecrementVelocity in the
   hand source), which step the note 0x2786 within 1..0x7f.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_DecrementVelocity BmDrEdit_IncrementVelocity BmDrEdit_NullReturn BmDrEdit_UpdateVelocityDisplay */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_295c;
extern unsigned char __near ram_295d;
extern unsigned char __near ram_295f;
extern unsigned char __near ram_2742;
extern unsigned char __near ram_2786;
extern void BmDrEdit_DrumVoiceUp(void);
extern void BmDrEdit_DrumVoiceDown(void);
extern void BmDrEdit_UpdateVelocityDisplay(void);
extern void NoteEditSy_SendScrollCmd3(void);
extern void BmDrEdit_NullReturn(void);
extern void BmDrEdit_VelocityUp_Check(void);
extern void BmDrEdit_VelocityDown_Check(void);
extern void BmDrEdit_IncrementVelocity(void);
extern void BmDrEdit_DecrementVelocity(void);

/* SeqPlay_ResetPlaybackState: clears the play state, takes the punch-in tracks, activates the recorded tracks and
   picks the transport mode 0x22fc (12 with the metronome flag, else 11); returns 0. */
extern unsigned char __near SEQ_PLAY_FLAGS;
extern unsigned int __near SEQ_RECORDED_TRACKS;
extern unsigned char __near SEQ_METRO_FLAGS;
extern unsigned char __near ram_f23c;
extern unsigned int __near SEQ_PUNCH_IN_MEASURE;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned int __near ram_2336;
extern unsigned char __near ram_22fc;
extern void TempoRingBuf_Init(void);
extern void Audio_CheckSubsystemReady(void);
extern void SeqAcc_InitPlaybackState(void);
extern int SeqPlay_ResetPlaybackState(void);

int SeqPlay_ResetPlaybackState(void)
{
  unsigned char f;
  unsigned int t;

  SEQ_PLAY_FLAGS = 0;
  SEQ_RECORDED_TRACKS = 0;
  f = SEQ_METRO_FLAGS;
  f &= ~0x04;
  f &= ~0x02;
  f &= ~0x80;
  SEQ_METRO_FLAGS = f;
  if ((ram_f23c & 1) && SEQ_PUNCH_IN_MEASURE == SEQ_START_MEASURE)
    SEQ_RECORDED_TRACKS = SEQ_REC_TRACKS;
  TempoRingBuf_Init();
  t = SEQ_REC_TRACKS;
  if (t != 0) {
    SEQ_TRACK_MASK |= t;
    SEQ_CONTROL_FLAGS |= 0x08;
    Audio_CheckSubsystemReady();
    SEQ_PLAY_FLAGS |= 0x01;
    f = SEQ_METRO_FLAGS;
    if (f & 1) {
      f |= 0x02;
      SEQ_METRO_FLAGS = f;
      ram_2336 = SEQ_START_MEASURE;
    }
  }
  SeqAcc_InitPlaybackState();
  ram_22fc = (SEQ_METRO_FLAGS & 1) ? 12 : 11;
  return 0;
}

void BmDrEdit_VelocityUp_Check(void)
{
  if ((ram_295c & 0x80) && ram_295d != 2)
    return;
  if (!(ram_295f & 1))
    return;
  if (ram_2742 & 1)
    BmDrEdit_DecrementVelocity();
  else
    BmDrEdit_IncrementVelocity();
}
void BmDrEdit_VelocityDown_Check(void)
{
  if ((ram_295c & 0x80) && ram_295d != 2)
    return;
  if (!(ram_295f & 1))
    return;
  if (ram_2742 & 1)
    BmDrEdit_IncrementVelocity();
  else
    BmDrEdit_DecrementVelocity();
}
void BmDrEdit_IncrementVelocity(void)
{
  unsigned char v;

  v = ram_2786;
  if (v >= 0x7f)
    return;
  ram_2786 = v + 1;
  if (ram_2742 & 1)
    BmDrEdit_DrumVoiceUp();
  BmDrEdit_UpdateVelocityDisplay();
  NoteEditSy_SendScrollCmd3();
  BmDrEdit_NullReturn();
  ram_295c = 0x83;
  ram_295d = 2;
}
void BmDrEdit_DecrementVelocity(void)
{
  unsigned char v;

  v = ram_2786;
  if (v == 1)
    return;
  ram_2786 = v - 1;
  if (ram_2742 & 1)
    BmDrEdit_DrumVoiceDown();
  BmDrEdit_UpdateVelocityDisplay();
  NoteEditSy_SendScrollCmd3();
  BmDrEdit_NullReturn();
  ram_295c = 0x83;
  ram_295d = 2;
}
