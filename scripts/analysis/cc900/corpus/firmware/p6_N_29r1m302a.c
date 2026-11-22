/* lane_p6 helper N, round 29r1, form a: module 302 (audio/note_voice_mapping.s), the ring-buffer block movers
   (helper L's p6_L_28r1m302a / b, run r76, Xr: +4 .. +24).  One spot per function:
   - the readers SysexRingBuf_ReadBytes / StoreAndAdvance_Prologue / ReadVariableLengthDa_Prologue /
     CalcAddrOffset_Data (+11): an int counter (the ROM copies it to WA for the unsigned compare with n and
     stores through `(xwa+iz)`, a signed index);
   - the writers SysexRingBuf_WriteBytes / StoreAndAdvance_Prologue2 / MidiRingBuf_WriteBytes (+4): the count n in
     IZ and the counter on the stack, `(xbc+wa)` (a register parameter n, an int counter);
   - SeqFile_ReadTrackData / SeqFile_ValidateAndStore (+12): the count assigned inside the test (`ld wa, iz` copy);
   - FileIO_ReadMultiByteRecord (+24): L's form b's reads with form a's step `(v << 7) + (c & 0x7f)`.
   cc900-options: -Xr
*/
/* cc900-module: FileIO_ReadNextRecord MidiRingBuf_WriteByte RingBuffer_ReadByte RingBuffer_WriteByte StoreAndAdvance_LoadDRAM StoreAndAdvance_Prologue SysexRingBuf_ReadByte SysexRingBuf_ReadBytes SysexRingBuf_WriteByte */   /* scripts/analysis/cc900/module_calls.py v10 */
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
extern int TaskBuf_ReadNextByte(void);
extern int RingBuffer_ReadByte(void);
extern int FileIO_ReadNextRecord(void);
int StoreAndAdvance_Prologue(unsigned int n, unsigned char *buf);
int SysexRingBuf_ReadBytes(unsigned int n, unsigned char *buf);

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

int MidiRingBuf_WriteBytes(register unsigned int n, unsigned char *buf)
{
	int i;

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
	int i;
	int c;

	for (i = 0; i < n; i++) {
		if ((c = SysexRingBuf_ReadByte()) < 0)
			return -1;
		buf[i] = c;
	}
	return 0;
}

int SysexRingBuf_WriteBytes(register unsigned int n, unsigned char *buf)
{
	int i;

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
	int i;
	int c;

	for (i = 0; i < n; i++) {
		if ((c = StoreAndAdvance_LoadDRAM()) < 0)
			return -1;
		buf[i] = c;
	}
	return 0;
}

int StoreAndAdvance_Prologue2(register unsigned int n, unsigned char *buf)
{
	int i;

	if (n == 0)
		return 0;
	if (n > ram_e0b8)
		MidiRingBuf_Init();
	for (i = 0; i < n; i++)
		MidiRingBuf_WriteByte(buf[i]);
	return 0;
}

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

int CalcAddrOffset_Data(unsigned int n, unsigned char *buf)
{
	int i;
	int c;

	for (i = 0; i < n; i++) {
		if ((c = RingBuffer_ReadByte()) < 0)
			return -1;
		buf[i] = c;
	}
	return 0;
}
