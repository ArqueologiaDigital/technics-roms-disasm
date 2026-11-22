/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: FileIO_InitTrackSlots MidiRingBuf_Init SysexRingBuf_Init */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int TaskBuf_ReadNextByte(void);
extern long FileIO_ReadVariableLengthData(unsigned int *pos, unsigned char *buf);
extern unsigned char __near ram_e9e4;
extern long __near ram_e9e7;
extern long __near ram_e9f5;
extern unsigned int __near ram_e9e5;
extern long __near ram_e9eb;
extern unsigned int __near ram_e9ef;
extern unsigned int __near ram_e9f1;
extern long __near ram_ebfd;
extern unsigned int __near ram_ec01;
extern unsigned char __near ram_e9c4;
extern void FileIO_InitTrackSlots(void);
extern void SysexRingBuf_Init(void);
extern void MidiRingBuf_Init(void);
extern void SongPlayer_ResetState(void);

long FileIO_ReadVariableLengthData(unsigned int *pos, unsigned char *buf)
{
	long v;
	int c;

	v = TaskBuf_ReadNextByte();
	if (v < 0)
		return -1;
	buf[(*pos)++] = v;
	if (v & 0x80) {
		v &= 0x7f;
		do {
			if ((c = TaskBuf_ReadNextByte()) < 0)
				return -1;
			buf[(*pos)++] = c;
			v = (v << 7) + (c & 0x7f);
		} while (c & 0x80);
	}
	return v;
}

void SongPlayer_ResetState(void)
{
	ram_e9e4 = 0;
	ram_e9e7 = 0;
	ram_e9f5 = 0;
	ram_e9e5 = 0;
	ram_e9eb = 0;
	ram_e9ef = 0;
	ram_e9f1 = 0;
	ram_ebfd = 0;
	ram_ec01 = 0;
	ram_e9c4 = 0;
	FileIO_InitTrackSlots();
	SysexRingBuf_Init();
	MidiRingBuf_Init();
}

/* cc900-module: FileIO_ReadNextRecord MidiRingBuf_WriteByte RingBuffer_ReadByte RingBuffer_WriteByte StoreAndAdvance_LoadDRAM StoreAndAdvance_Prologue SysexRingBuf_ReadByte SysexRingBuf_ReadBytes SysexRingBuf_WriteByte */
extern void FDC_DrainQueuesAndReset(void);
extern void SndTable_LookupC(void);
extern unsigned int __near ram_11f5;
extern void DirectReturn_LoadDRAM(void);

void DirectReturn_LoadDRAM(void)
{
	switch (ram_e9e4) {
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
