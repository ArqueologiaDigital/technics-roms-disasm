/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: FileIO_ReadNextRecord MidiRingBuf_WriteByte RingBuffer_ReadByte RingBuffer_WriteByte StoreAndAdvance_LoadDRAM StoreAndAdvance_Prologue SysexRingBuf_ReadByte SysexRingBuf_ReadBytes SysexRingBuf_WriteByte */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int FileIO_ReadNextRecord(void);
extern long FileIO_ReadMultiByteRecord(void);
extern int TaskBuf_ReadNextByte(void);
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
