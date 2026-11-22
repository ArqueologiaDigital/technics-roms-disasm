/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ApplyProgramChangeAs_LoadDRAM2 ApplyProgramChange_LoadDRAM FetchOscTableEntry_Prologue SoundRam_IdentifyImage */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near ram_d8b2;
extern unsigned int SysexRingBuf_GetFreeSpace(void);

unsigned int SysexRingBuf_GetFreeSpace(void)
{
  return 0x7ff - ram_d8b2;
}

/* cc900-module: FileIO_InitTrackSlots FileIO_ReadNextRecord MidiRingBuf_WriteByte RingBuffer_ReadByte RingBuffer_WriteByte StoreAndAdvance_LoadDRAM StoreAndAdvance_Prologue SysexRingBuf_ReadByte SysexRingBuf_ReadBytes SysexRingBuf_WriteByte */
extern unsigned int __near ram_d0ac;
extern int Seq_CalcAddrOffset(void);

int Seq_CalcAddrOffset(void)
{
	return 2047 - ram_d0ac;
}
