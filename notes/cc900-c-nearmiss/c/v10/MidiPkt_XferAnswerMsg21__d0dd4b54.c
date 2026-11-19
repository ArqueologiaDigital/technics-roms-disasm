/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_12m287a.c (2026-11-19-92-p6-r57)
   sha256 d0dd4b54cb317f57198717be27865010ea5a745471c4975fd1a1b159ec39d424 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
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
