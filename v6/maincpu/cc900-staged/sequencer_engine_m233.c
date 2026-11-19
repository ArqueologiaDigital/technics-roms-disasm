/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqPlay_InitializePlayback SeqPlay_ScanAndStoreChannelPos */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_1d8c;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near ram_2314;
extern unsigned int __near ram_2310;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned char __near ram_1d5e;
extern unsigned int __near ram_1d60;
extern unsigned int __near ram_1d62;
extern unsigned int __near ram_1d72;
extern unsigned int __near SEQ_BEAT_COUNT;
extern unsigned char __near SEQ_BEAT_TICK;
extern void SeqBuffer_ClearAndInitIteration(void);
extern void SeqPlay_ScanAndStoreChannelPos(void);
extern void SeqPlay_InitializePlayback(void);
extern int SeqPlay_CheckDrumAndStart(void);

int SeqPlay_CheckDrumAndStart(void)
{
	unsigned char t;

	if (ram_1d8c != 1)
		return -1;
	if (SEQ_REC_TRACKS == 0)
		return -1;
	t = ram_2314;
	if (!(SEQ_TRANSPORT_STATE & 0x04)) {
		if (((1 << (t - 1)) & ram_2310) == 0)
			return -1;
	}
	SeqBuffer_ClearAndInitIteration();
	if (!(SEQ_TRANSPORT_STATE & 0x04)) {
		SeqPlay_ScanAndStoreChannelPos();
		ram_1d5e = 0;
		SeqPlay_InitializePlayback();
	}
	ram_1d5e = 1;
	ram_1d60 = SEQ_BEAT_COUNT + ram_1d72;
	ram_1d62 = SEQ_BEAT_TICK;
	return 0;
}
