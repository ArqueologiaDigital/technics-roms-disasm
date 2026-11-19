/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

struct mq;
typedef struct mq *mqp;
extern int AccWrap_ReturnZero(int);
extern unsigned char __near ram_b74b;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near PANEL_MIDI;
extern unsigned char SysEx_Msg_35CC[];
extern void SeqBuf_FlushNoteOffs(unsigned char *, unsigned int);
extern unsigned int __near ram_bc9e;
extern void ArpQueue_Enqueue(unsigned char *s, unsigned int n);
extern void SeqOut_FlushTimedBuffer(mqp q);
extern void ArpQueue_SwapBuffers(void);
extern mqp __near ram_bbc0;
extern void SeqData_DispatchLoop_Done(void);

/* cc900-data: SeqData_DispatchLoop_Done 1 = SeqData_OutTemplate */
void SeqData_DispatchLoop_Done(void)
{
	unsigned char m[3] = { 0x08, 0x07, 0xf7 };

	if (AccWrap_ReturnZero(0) == -1)
		return;
	if (ram_b74b & 0x01)
		return;
	if (CURRENT_TITLE == 87)
		return;
	if (PANEL_MIDI & 0x14)
		return;
	SeqBuf_FlushNoteOffs(SysEx_Msg_35CC, 3);
	if (ram_bc9e < 40)
		ram_bc9e = 40;
	else if (ram_bc9e > 300)
		ram_bc9e = 300;
	m[0] = ram_bc9e & 0x0f;
	m[1] = (ram_bc9e >> 4) & 0x1f;
	ArpQueue_Enqueue(m, 3);
	SeqOut_FlushTimedBuffer(ram_bbc0);
	ArpQueue_SwapBuffers();
}
