/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiPkt_ArpConfigChain_Data_Helper11 MidiPkt_ArpConfigChain_Data_Helper12 MidiPkt_ArpConfigChain_Data_Helper13 MidiPkt_SendGroupEnd */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int AccWrap_ReturnZero(int);
extern void MidiPkt_SendGroupEnd(void);
extern void MidiPkt_ArpCfgChain_Helper11(void);
extern void MidiPkt_ArpCfgChain_Helper12(void);
extern void MidiPkt_ArpCfgChain_Helper13(void);
extern void MidiPkt_ArpCfgChain_Join(void);

/* cc900-name: MidiPkt_ArpCfgChain_Join=MidiPkt_ArpConfigChain_Data_Join */
/* cc900-name: MidiPkt_ArpCfgChain_Helper11=MidiPkt_ArpConfigChain_Data_Helper11 */
/* cc900-name: MidiPkt_ArpCfgChain_Helper12=MidiPkt_ArpConfigChain_Data_Helper12 */
/* cc900-name: MidiPkt_ArpCfgChain_Helper13=MidiPkt_ArpConfigChain_Data_Helper13 */
void MidiPkt_ArpCfgChain_Join(void)
{
	if (AccWrap_ReturnZero(4) != -1) {
		MidiPkt_ArpCfgChain_Helper11();
		MidiPkt_ArpCfgChain_Helper12();
		MidiPkt_ArpCfgChain_Helper13();
		MidiPkt_SendGroupEnd();
	}
}
