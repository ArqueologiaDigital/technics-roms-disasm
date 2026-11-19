/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

struct mq;
typedef struct mq *mqp;
extern int AccWrap_ReturnZero(int);
extern unsigned char __near ram_b7e7;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near PANEL_MIDI;
extern unsigned char SysEx_Msg_35CC[];
extern void SeqBuf_FlushNoteOffs(unsigned char *, unsigned int);
extern unsigned int __near ram_bd3a;
extern void ArpQueue_Enqueue(unsigned char *s, unsigned int n);
extern void SeqOut_FlushTimedBuffer(mqp q);
extern void ArpQueue_SwapBuffers(void);
extern mqp __near ram_bc5c;
extern void SeqData_DispatchLoop_Done(void);

/* cc900-data: SeqData_DispatchLoop_Done 1 = SeqData_OutTemplate */
void SeqData_DispatchLoop_Done(void)
{
	unsigned char m[3] = { 0x08, 0x07, 0xf7 };

	if (AccWrap_ReturnZero(0) == -1)
		return;
	if (ram_b7e7 & 0x01)
		return;
	if (CURRENT_TITLE == 87)
		return;
	if (PANEL_MIDI & 0x14)
		return;
	SeqBuf_FlushNoteOffs(SysEx_Msg_35CC, 3);
	if (ram_bd3a < 40)
		ram_bd3a = 40;
	else if (ram_bd3a > 300)
		ram_bd3a = 300;
	m[0] = ram_bd3a & 0x0f;
	m[1] = (ram_bd3a >> 4) & 0x1f;
	ArpQueue_Enqueue(m, 3);
	SeqOut_FlushTimedBuffer(ram_bc5c);
	ArpQueue_SwapBuffers();
}
