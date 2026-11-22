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
extern unsigned char __near ram_e91e;
extern long __near ram_e921;
extern long __near ram_e92f;
extern unsigned int __near ram_e91f;
extern long __near ram_e925;
extern unsigned int __near ram_e929;
extern unsigned int __near ram_e92b;
extern long __near ram_eb37;
extern unsigned int __near ram_eb3b;
extern unsigned char __near ram_e8fe;
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
	ram_e91e = 0;
	ram_e921 = 0;
	ram_e92f = 0;
	ram_e91f = 0;
	ram_e925 = 0;
	ram_e929 = 0;
	ram_e92b = 0;
	ram_eb37 = 0;
	ram_eb3b = 0;
	ram_e8fe = 0;
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
	switch (ram_e91e) {
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

extern int FileIO_ReadNextRecord(void);
extern long FileIO_ReadMultiByteRecord(void);
extern int ReadVariableLengthDa_Prologue(unsigned int n, unsigned char *buf);
extern int SysexRingBuf_ReadByte(void);
int SysexRingBuf_ReadBytes(unsigned int n, unsigned char *buf);
extern void SeqFile_ReadTrackData(unsigned char *s);
extern int SysexRingBuf_ReadBytes(unsigned int n, unsigned char *buf);
extern int StoreAndAdvance_LoadDRAM(void);
int StoreAndAdvance_Prologue(unsigned int n, unsigned char *buf);
extern void SeqFile_ValidateAndStore(unsigned char *s);
extern int StoreAndAdvance_Prologue(unsigned int n, unsigned char *buf);

long FileIO_ReadMultiByteRecord(void)
{
	long v;
	int c;

	if ((v = FileIO_ReadNextRecord()) < 0)
		return -1L;
	if (v & 0x80) {
		v &= 0x7f;
		do {
			if ((c = FileIO_ReadNextRecord()) < 0)
				return -1L;
			v = (v << 7) + (c & 0x7f);
		} while (c & 0x80);
	}
	return v;
}
int ReadVariableLengthDa_Prologue(unsigned int n, unsigned char *buf)
{
	int i;
	int c;

	for (i = 0; i < n; i++) {
		if ((c = TaskBuf_ReadNextByte()) < 0)
			return -1;
		buf[i] = c;
	}
	return 0;
}
void SeqFile_ReadTrackData(unsigned char *s)
{
	int n;

	if ((n = SysexRingBuf_ReadByte()) < 0)
		*s = 0;
	else if (SysexRingBuf_ReadBytes(n, s) < 0)
		*s = 0;
	else
		s[n] = 0;
}
void SeqFile_ValidateAndStore(unsigned char *s)
{
	int n;

	if ((n = StoreAndAdvance_LoadDRAM()) < 0)
		*s = 0;
	else if (StoreAndAdvance_Prologue(n, s) < 0)
		*s = 0;
	else
		s[n] = 0;
}
