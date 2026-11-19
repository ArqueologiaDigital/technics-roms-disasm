/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midi_dispatch_handlers_m287.c (2026-11-19-92-p6-r57)
   sha256 944a55f3bc5f742fcf4a78c20ebd3c5bfd0d44472049d52655f5be6b3e2e0618 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct mq;
typedef struct mq *mqp;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void SeqBuf_FlushNoteOffs(unsigned char *, unsigned int);
extern void MidiStream_PrevBankCheck(void);
extern unsigned char SysEx_Msg_35A6[];
extern unsigned char SysEx_Msg_35AC[];
void SysEx_FinishBulkSend(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		SeqBuf_FlushNoteOffs(SysEx_Msg_35A6, 5);
		MidiStream_PrevBankCheck();
		if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 24)
			SeqBuf_FlushNoteOffs(SysEx_Msg_35AC, 5);
	} else {
		if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 24)
			SeqBuf_FlushNoteOffs(SysEx_Msg_35AC, 5);
	}
}
