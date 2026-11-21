/* Functions of sequencer/sequencer_ui.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SMFMute_ClearBit0 SMFMute_GetBit0Status SMFMute_GetBit1Status SMFMute_GetUpperBits SqAftSet_LookupTableEntry */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned char TrAsGrid_LookupByteTable(unsigned char i);
extern unsigned char ram_21082;
unsigned char TrAsGrid_CheckTrackType(unsigned char sel, unsigned char trk);
extern unsigned char TrAsGrid_CheckTrackType(unsigned char sel, unsigned char trk);
extern unsigned int ram_21086;
extern unsigned int SqAftSet_LookupTableEntry_Table[];
void SqAftSet_LookupTableEntry(unsigned char a);
extern void SqAftSet_LookupTableEntry(unsigned char a);

unsigned char TrAsGrid_LookupByteTable(unsigned char i)
{
	return SEQ_TRACK_ASSIGN[i];
}

unsigned char TrAsGrid_CheckTrackType(unsigned char sel, unsigned char trk)
{
	if (sel == 0) {
		unsigned char t = SEQ_TRACK_ASSIGN[trk];
		if (t == 0xe || t == 0xd) return 1;
	} else {
		unsigned char t = ram_21082;
		if (t == 0xe || t == 0xd) return 1;
	}
	return 0;
}

void SqAftSet_LookupTableEntry(unsigned char a)
{
	ram_21086 = SqAftSet_LookupTableEntry_Table[a];
}
