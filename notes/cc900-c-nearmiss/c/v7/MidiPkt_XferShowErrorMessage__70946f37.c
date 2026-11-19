/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midi_dispatch_handlers_m286.c (2026-11-19-92-p6-r57)
   sha256 70946f375194e4553de5aa2408bf7bca4fc8c361e17088ad61466f276943f5b4 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: MidiPkt_XferShowErrorMsg=MidiPkt_XferShowErrorMessage */
struct mq;
typedef struct mq *mqp;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
#define TT_MESAGE 0xee
extern unsigned char __near GLOBAL_ERROR_CODE;
extern void UI_InterruptTitleByIndex(unsigned int);
extern unsigned char MidiRx_PartLookup_ByteMap[];
void MidiPkt_XferShowErrorMsg(void)
{
	GLOBAL_ERROR_CODE = MidiRx_PartLookup_ByteMap[SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4)];
	UI_InterruptTitleByIndex(TT_MESAGE);
}
