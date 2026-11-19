/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midi_dispatch_handlers_m286.c (2026-11-19-92-p6-r57)
   sha256 70946f375194e4553de5aa2408bf7bca4fc8c361e17088ad61466f276943f5b4 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct mq;
typedef struct mq *mqp;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char *__near ram_bc18;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void SeqBuf_FlushNoteOffs(unsigned char *, unsigned int);
extern void MidiStream_PrevBankCheck(void);
extern unsigned char SysEx_Msg_35A0[];
void MidiPkt_SendGroupEnd(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		ram_bc18[3]++;
		SeqBuf_FlushNoteOffs(SysEx_Msg_35A0, 5);
		MidiStream_PrevBankCheck();
	}
}
