/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PartCtrl_ReadWord */   /* staged module names, repair_module_lines.py */

extern unsigned char __near SEQ_RTMCFG;
extern unsigned int __near SEQ_TRACK_MASK;
extern void Audio_CheckSubsystemReady(void);
extern unsigned int __near ram_2859;
extern unsigned char __near ram_2889;
extern void SeqAcc_InitPlaybackState(void);
extern void CtrlPanel_SetIndicatorBit(int);

void SeqAcc_RestorePlaybackState(void)
{
  unsigned int m = ram_2859;
  SEQ_TRACK_MASK = m;
  Audio_CheckSubsystemReady();
  if (m != 0) {
    SEQ_RTMCFG &= ~0x08;
    SeqAcc_InitPlaybackState();
    Audio_CheckSubsystemReady();
    ram_2889 |= 0x01;
  } else ram_2889 &= ~0x01;
  CtrlPanel_SetIndicatorBit(0x4c);
}

extern unsigned char ram_b0000[];
extern unsigned int PartCtrl_ReadWord(unsigned int n);

unsigned int PartCtrl_ReadWord(unsigned int n)
{
  return *(unsigned int *)((unsigned long)ram_b0000 + (((unsigned long)(n - 1) << 8) + 3));
}

extern unsigned char __near ram_1d7e;
extern unsigned char __near ram_1d80;
extern int SeqBuf_GetWritePos(void);
extern void SeqBuf_FlushAndReinit_NoteEvents(void);
extern void SeqBuf_FlushAndReinit_VoiceCCEvents(void);
extern void __cdecl SeqBuf_WriteBytes(unsigned int n, unsigned char *p);
extern void SeqBuf_WriteMidiEvent(unsigned char *ev, unsigned char n);

void SeqBuf_WriteMidiEvent(unsigned char *ev, unsigned char n)
{
	if ((*ev & 0xf0) == 0x90) {
		if (ram_1d80 != 0)
			SeqBuf_FlushAndReinit_VoiceCCEvents();
		if (SeqBuf_GetWritePos() < 15)
			SeqBuf_FlushAndReinit_NoteEvents();
		SeqBuf_WriteBytes(n, ev);
		ram_1d7e = 1;
	} else {
		if (ram_1d7e != 0)
			SeqBuf_FlushAndReinit_NoteEvents();
		if (SeqBuf_GetWritePos() < 15)
			SeqBuf_FlushAndReinit_VoiceCCEvents();
		SeqBuf_WriteBytes(n, ev);
		ram_1d80 = 1;
	}
}
