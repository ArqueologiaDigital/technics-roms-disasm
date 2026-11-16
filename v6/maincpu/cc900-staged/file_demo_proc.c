/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern long ram_25d6c;
extern long FileIO_DiskInfoInit;
extern unsigned int FILE_ERROR;

int FileIO_ValidateRecord_CheckSize(unsigned char a)
{
    if (format_FD(a) != 0) return 0;
    if (FILE_ERROR == 31) return -11;
    return -6;
}

long GetEncodedFreeSpaceData(void)
{
    long *p = &ram_25d6c;
    if (FileIO_DiskInfoInit == *p) GetDiskFreeSpace(p, p + 1);
    return ram_25d6c;
}

int ReadVariableLengthInt(void)
{
    unsigned long v = 0;
    int c;
    while ((c = FileIO_ReadByte()) > 0x7f) {
        v += (long)(c & 0x7f);
        v <<= 7;
    }
    if (c < 0) return -1;
    v += (long)c;
    return (int)(v > 0x7fff ? 0x7fff : v);
}

void Demo_ParseSlideHeader(unsigned char i)
{
    long v;
    if ((v = ((long *)0x9c4000)[i]) != 0) SLIDE_Parse_Header(v, (unsigned char *)0x69800);
}

extern unsigned char __near SEQ_RTMCFG;

int FileIO_ReadHeaderAtF(void)
{
    int ok = 1;
    int c;
    FileIO_SeekAndReadBlock(15, 0);
    c = FileIO_ReadByte();
    if (c < 0 || (unsigned char)c != 8) ok = 0;
    FileIO_SeekRead_ExtReturn();
    return ok;
}

void InitializeOperationState(unsigned char a)
{
    SeqBuf_Init();
    NoteMap_SendAllNotesOff();
    Part_ReinitAllActive();
    AccWrap_PlayModeDispatch();
    if (a != 0) SEQ_RTMCFG |= 4;
    AccompSeq_StopSequence();
    AudioInit_RefreshToneBank();
    NoteMap_ProcessAndMerge();
    Voice_InitializeAll();
    Voice_InitTablePair();
    Voice_InitTableGroup();
    MIDI_SendAllSoundOff();
    MidiIn_IgnoreClockTransport();
}

extern unsigned char *FileIO_HeaderAt4_ExpectedPtr;

int FileIO_ReadHeaderAt4(void)
{
    int ok = 1;
    int c;
    FileIO_SeekAndReadBlock(4, 0);
    c = FileIO_ReadByte();
    if (c < 0 || (char)c != (char)*FileIO_HeaderAt4_ExpectedPtr) ok = 0;
    FileIO_SeekRead_ExtReturn();
    return ok;
}
