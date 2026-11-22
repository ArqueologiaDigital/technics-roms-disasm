/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/midi_dispatch_handlers_m0.c (2026-11-21-2-p6-r58)
   sha256 e72dff7161fa6727050df114348e0a3ed7c329a3e94f0fe86c0f0516c4ab601e (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_bd20;
extern unsigned char SysEx_Msg_35C4[];
extern void SeqBuf_FlushNoteOffs(unsigned char *, unsigned int);
void MidiPkt_XferAnswerMsg21(void)
{
	if (ram_bd20 == 0) {
		ram_bd20 = 1;
		SeqBuf_FlushNoteOffs(SysEx_Msg_35C4, 7);
	}
}
