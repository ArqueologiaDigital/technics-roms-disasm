/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiPkt_ArpConfigChain_Data_Helper10 MidiPkt_ArpConfigChain_Data_Helper8 MidiPkt_ArpConfigChain_Data_Helper9 MidiPkt_ArpConfigChain_Data_Join MidiPkt_SendBlock_AccompAreaHeader MidiPkt_SendBlock_AccompBankTables MidiPkt_SendBlock_AccompBlockPool MidiPkt_SendBlock_LivePanel MidiPkt_SendBlock_PanelMemories MidiPkt_SendBlock_SoundRamData MidiPkt_SendBlock_SoundRamId MidiPkt_SendGroupEnd MidiPkt_SendGroup_AccompBlocks MidiPkt_SendGroup_Panel MidiPkt_SendGroup_SoundRam MidiPkt_SendGroup_StyleImage */   /* scripts/analysis/cc900/module_calls.py v10 */

struct mq;
typedef struct mq *mqp;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void SeqBuf_FlushNoteOffs(unsigned char *, unsigned int);
extern void MidiStream_PrevBankCheck(void);
extern unsigned char SysEx_Msg_35A6[];
extern unsigned char SysEx_Msg_35AC[];
extern void SysEx_FinishBulkSend(void);

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
