/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_10m286a.c (2026-11-19-76-p6-r55)
   sha256 7078994bc8d5ea567e3965fcd1602e028f6c96eaf52924812658af3cc5f58202 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct mq;
typedef struct mq *mqp;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char *__near ram_bcb4;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void SeqBuf_FlushNoteOffs(unsigned char *, unsigned int);
extern void MidiStream_PrevBankCheck(void);
extern unsigned char SysEx_Msg_35A0[];
void MidiPkt_SendGroupEnd(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		ram_bcb4[3]++;
		SeqBuf_FlushNoteOffs(SysEx_Msg_35A0, 5);
		MidiStream_PrevBankCheck();
	}
}
