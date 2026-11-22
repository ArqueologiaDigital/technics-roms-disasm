/* lane_p6 helper L, round 28r1, form a: module 302 (audio/note_voice_mapping.s), the ring-buffer block movers,
   unoptimised code (-Xr) beside the built byte movers of cc900/note_voice_mapping_xr.c:
   - families28_L's SeqFile_ValidateAndStore / SeqFile_ReadTrackData (2 x 58 B): read a length byte from a ring
     (StoreAndAdvance_LoadDRAM / SysexRingBuf_ReadByte), then that many bytes (StoreAndAdvance_Prologue /
     SysexRingBuf_ReadBytes) into the buffer, terminated; on any failure the buffer is emptied;
   - families28_L's StoreAndAdvance_Prologue / SysexRingBuf_ReadBytes (2 x 55 B): read N bytes from the ring into
     the buffer, -1 when the ring runs dry;
   - their unprobed writers SysexRingBuf_WriteBytes / StoreAndAdvance_Prologue2 (re-initialise the ring when N
     exceeds its free count, `call ugt`) and MidiRingBuf_WriteBytes (-1 when N does not fit).
   The byte writers are called with the byte widened (`extz wa`): declared with an int parameter here.
   Form a: the natural spelling, a plain `c` local for the read byte, if / else for MidiRingBuf_WriteBytes's final
   test (the ROM's shared `ldw hl, 0xffff` before the epilogue).
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
	if (n < 0) {
		*s = 0;
		return;
	}
	if (SysexRingBuf_ReadBytes(n, s) < 0) {
		*s = 0;
		return;
	}
	s[n] = 0;
}

void SeqFile_ValidateAndStore(unsigned char *s)
{
	int n;

	n = StoreAndAdvance_LoadDRAM();
	if (n < 0) {
		*s = 0;
		return;
	}
	if (StoreAndAdvance_Prologue(n, s) < 0) {
		*s = 0;
		return;
	}
	s[n] = 0;
}

int MidiRingBuf_WriteBytes(unsigned int n, unsigned char *buf)
{
	unsigned int i;

	if (n == 0)
		return 0;
	if (n > ram_d0ac)
		return -1;
	if (ram_d0ac > n) {
		for (i = 0; i < n; i++)
			RingBuffer_WriteByte(buf[i]);
		return 0;
	} else
		return -1;
}

int SysexRingBuf_ReadBytes(unsigned int n, unsigned char *buf)
{
	unsigned int i;
	int c;

	for (i = 0; i < n; i++) {
		c = SysexRingBuf_ReadByte();
		if (c < 0)
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
		c = StoreAndAdvance_LoadDRAM();
		if (c < 0)
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

/* The same module's other unprobed readers: ReadVariableLengthDa_Prologue / CalcAddrOffset_Data, two more twins of
   SysexRingBuf_ReadBytes (TaskBuf_ReadNextByte, absolute; RingBuffer_ReadByte); Seq_CalcAddrOffset, the MIDI
   ring's used count (2047 - free); FileIO_ReadMultiByteRecord, a MIDI variable-length number (long, -1 at the
   end of data); DirectReturn_LoadDRAM, a switch on the source kind at 0xe9e4 (cases in reverse compare order). */
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

	v = FileIO_ReadNextRecord();
	if (v < 0)
		return -1L;
	if (v & 0x80) {
		v &= 0x7f;
		do {
			c = FileIO_ReadNextRecord();
			if (c < 0)
				return -1L;
			v = (v << 7) + (c & 0x7f);
		} while (c & 0x80);
	}
	return v;
}

int ReadVariableLengthDa_Prologue(unsigned int n, unsigned char *buf)
{
	unsigned int i;
	int c;

	for (i = 0; i < n; i++) {
		c = TaskBuf_ReadNextByte();
		if (c < 0)
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
	}
	ram_11f5 = 120;
}

int Seq_CalcAddrOffset(void)
{
	return 2047 - ram_d0ac;
}

int CalcAddrOffset_Data(unsigned int n, unsigned char *buf)
{
	unsigned int i;
	int c;

	for (i = 0; i < n; i++) {
		c = RingBuffer_ReadByte();
		if (c < 0)
			return -1;
		buf[i] = c;
	}
	return 0;
}
