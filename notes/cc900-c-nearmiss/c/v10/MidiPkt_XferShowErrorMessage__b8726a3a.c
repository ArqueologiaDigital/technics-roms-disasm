/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_11m286a.c (2026-11-19-83-p6-r56)
   sha256 b8726a3a71982a43615d796ffa19dae43be9729704e50c7da2beb12b58280117 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: MidiPkt_XferShowErrorMsg=MidiPkt_XferShowErrorMessage */
struct mq;
typedef struct mq *mqp;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
#define TT_MESAGE 0xee
extern unsigned char __near GLOBAL_ERROR_CODE;
extern unsigned char MidiRx_PartLookup_ByteMap[];
extern void UI_InterruptTitleByIndex(unsigned int);
void MidiPkt_XferShowErrorMsg(void)
{
	GLOBAL_ERROR_CODE = MidiRx_PartLookup_ByteMap[SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4)];
	UI_InterruptTitleByIndex(TT_MESAGE);
}
