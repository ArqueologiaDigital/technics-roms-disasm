/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_12m287a.c (2026-11-19-92-p6-r57)
   sha256 d0dd4b54cb317f57198717be27865010ea5a745471c4975fd1a1b159ec39d424 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
struct mq;
typedef struct mq *mqp;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char __near ram_bd18;
extern unsigned char SysEx_Msg_3594[];
extern unsigned char SysEx_Msg_359A[];
extern unsigned char SysEx_Msg_35B2[];
extern void SeqBuf_FlushNoteOffs(unsigned char *, unsigned int);
extern void ArpQueue_SwapBuffers(void);
void MidiTable_FlushArpNotes(void)
{
	unsigned char a;

	if (ram_bd18 & 0x80) {
		ArpQueue_SwapBuffers();
		a = ((unsigned char *)MIDISEQ_ACTIVE_BUF_PTR)[4];
		if (a == 0)
			SeqBuf_FlushNoteOffs(SysEx_Msg_3594, 5);
		else if (a == 0x16)
			SeqBuf_FlushNoteOffs(SysEx_Msg_35B2, 5);
		else
			SeqBuf_FlushNoteOffs(SysEx_Msg_359A, 5);
	}
}
