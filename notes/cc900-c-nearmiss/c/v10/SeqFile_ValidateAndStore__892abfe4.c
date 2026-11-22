/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_L_28r1m302b.c (2026-11-22-9-p6-r76)
   sha256 892abfe478a4939b9053f36a0f90bb459d501e4b096acc589bd3ecbbdf307d46 (tar-sha256); compiled at -O3 -Xr */
/* lane_p6 helper L, round 28r1, form b: module 302 (audio/note_voice_mapping.s), the ring-buffer block movers
   SeqFile_ValidateAndStore / SeqFile_ReadTrackData, StoreAndAdvance_Prologue / SysexRingBuf_ReadBytes,
   SysexRingBuf_WriteBytes / StoreAndAdvance_Prologue2 and MidiRingBuf_WriteBytes (see p6_L_28r1m302a.c).
   Form b: the read byte assigned inside the test (`(c = ...) < 0`), the SeqFile pair as one if / else-if / else
   chain, MidiRingBuf_WriteBytes's tests as an else-if chain ending in the shared -1.
   cc900-options: -Xr
*/
/* cc900-module: FileIO_InitTrackSlots FileIO_ReadNextRecord MidiRingBuf_WriteByte RingBuffer_ReadByte RingBuffer_WriteByte StoreAndAdvance_LoadDRAM StoreAndAdvance_Prologue SysexRingBuf_ReadByte SysexRingBuf_ReadBytes SysexRingBuf_WriteByte */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near ram_d0ac;
extern unsigned int __near ram_d8b2;
extern unsigned int __near ram_e0b8;
extern int StoreAndAdvance_LoadDRAM(void);
extern int SysexRingBuf_ReadByte(void);
extern int RingBuffer_WriteByte(int);
extern int SysexRingBuf_WriteByte(int);
extern int MidiRingBuf_WriteByte(int);
extern void SysexRingBuf_Init(void);
extern void MidiRingBuf_Init(void);
int StoreAndAdvance_Prologue(unsigned int n, unsigned char *buf);
int SysexRingBuf_ReadBytes(unsigned int n, unsigned char *buf);

void SeqFile_ReadTrackData(unsigned char *s)
{
	int n;

	n = SysexRingBuf_ReadByte();
	if (n < 0)
		*s = 0;
	else if (SysexRingBuf_ReadBytes(n, s) < 0)
		*s = 0;
	else
		s[n] = 0;
}

void SeqFile_ValidateAndStore(unsigned char *s)
{
	int n;

	n = StoreAndAdvance_LoadDRAM();
	if (n < 0)
		*s = 0;
	else if (StoreAndAdvance_Prologue(n, s) < 0)
		*s = 0;
	else
		s[n] = 0;
}

int MidiRingBuf_WriteBytes(unsigned int n, unsigned char *buf)
{
	unsigned int i;

	if (n == 0)
		return 0;
	else if (n > ram_d0ac)
		return -1;
	else if (ram_d0ac > n) {
		for (i = 0; i < n; i++)
			RingBuffer_WriteByte(buf[i]);
		return 0;
	}
	return -1;
}

int SysexRingBuf_ReadBytes(unsigned int n, unsigned char *buf)
{
	unsigned int i;
	int c;

	for (i = 0; i < n; i++) {
		if ((c = SysexRingBuf_ReadByte()) < 0)
			return -1;
		buf[i] = c;
	}
	return 0;
}

int SysexRingBuf_WriteBytes(unsigned int n, unsigned char *buf)
{
	unsigned int i;

	if (n == 0)
		return 0;
	if (n > ram_d8b2)
		SysexRingBuf_Init();
	for (i = 0; i < n; i++)
		SysexRingBuf_WriteByte(buf[i]);
	return 0;
}

int StoreAndAdvance_Prologue(unsigned int n, unsigned char *buf)
{
	unsigned int i;
	int c;

	for (i = 0; i < n; i++) {
		if ((c = StoreAndAdvance_LoadDRAM()) < 0)
			return -1;
		buf[i] = c;
	}
	return 0;
}

int StoreAndAdvance_Prologue2(unsigned int n, unsigned char *buf)
{
	unsigned int i;

	if (n == 0)
		return 0;
	if (n > ram_e0b8)
		MidiRingBuf_Init();
	for (i = 0; i < n; i++)
		MidiRingBuf_WriteByte(buf[i]);
	return 0;
}

/* ReadVariableLengthDa_Prologue / CalcAddrOffset_Data, Seq_CalcAddrOffset, FileIO_ReadMultiByteRecord,
   DirectReturn_LoadDRAM (see form a).  Form b: the reads assigned inside the tests, the variable-length step as
   `(c & 0x7f) + (v << 7)` (the ROM masks the byte before it shifts), the free count as an unsigned difference. */
extern int TaskBuf_ReadNextByte(void);
extern int RingBuffer_ReadByte(void);
extern int FileIO_ReadNextRecord(void);
extern void FDC_DrainQueuesAndReset(void);
extern void SndTable_LookupC(void);
extern void FileIO_InitTrackSlots(void);
extern unsigned char __near ram_e9e4;
extern unsigned int __near ram_11f5;

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
			v = (c & 0x7f) + (v << 7);
		} while (c & 0x80);
	}
	return v;
}

int ReadVariableLengthDa_Prologue(unsigned int n, unsigned char *buf)
{
	unsigned int i;
	int c;

	for (i = 0; i < n; i++) {
		if ((c = TaskBuf_ReadNextByte()) < 0)
			return -1;
		buf[i] = c;
	}
	return 0;
}

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
	default:
		break;
	}
	ram_11f5 = 120;
}

unsigned int Seq_CalcAddrOffset(void)
{
	return 2047 - ram_d0ac;
}

int CalcAddrOffset_Data(unsigned int n, unsigned char *buf)
{
	unsigned int i;
	int c;

	for (i = 0; i < n; i++) {
		if ((c = RingBuffer_ReadByte()) < 0)
			return -1;
		buf[i] = c;
	}
	return 0;
}
