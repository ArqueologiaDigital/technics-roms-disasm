/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: FileIO_InitTrackSlots FileIO_ReadNextRecord MidiRingBuf_WriteByte RingBuffer_ReadByte RingBuffer_WriteByte StoreAndAdvance_LoadDRAM StoreAndAdvance_Prologue SysexRingBuf_ReadByte SysexRingBuf_ReadBytes SysexRingBuf_WriteByte */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void FDC_DrainQueuesAndReset(void);
extern void SndTable_LookupC(void);
extern void FileIO_InitTrackSlots(void);
extern unsigned char __near ram_e8fa;
extern unsigned int __near ram_11f5;
extern void DirectReturn_LoadDRAM(void);

void DirectReturn_LoadDRAM(void)
{
	switch (ram_e8fa) {
	case 1:
		FDC_DrainQueuesAndReset();
		FileIO_InitTrackSlots();
		break;
	case 2:
	case 3:
		FDC_DrainQueuesAndReset();
		break;
	case 4:
		SndTable_LookupC();
		FileIO_InitTrackSlots();
		break;
	}
	ram_11f5 = 120;
}
