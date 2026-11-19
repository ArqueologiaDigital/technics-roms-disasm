/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_2m289a.c (2026-11-19-19-p6-r43)
   sha256 9cda9f4ed83c5f66397996118c6e7869a4d7500752a7efbd44c102719490ebbc (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
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
