/* Phase 6, lane_p6 helper C, round 6, form b: routines with calls (none in tail position) of v10
   demo/file_demo_proc.s, boot/system_handlers.s, display/scoop_display.s, midi/midi_dispatch_handlers.s, and three
   refinements.  Form a (p6_C_6a.c) has the same names. */

typedef unsigned char *ucp;
struct ffblk { unsigned char b[266]; };
struct tgd { unsigned char ch; unsigned char reg; unsigned char val; unsigned char mask; };
struct mq { unsigned int count; unsigned char *rd; unsigned char *p6; unsigned char *wr; unsigned char buf[2]; };
typedef struct mq *mqp;
struct fdcp { unsigned int w0; unsigned int head; unsigned int side; unsigned int cyl; unsigned int sec; unsigned int n; long p; };
struct pt { int x; int y; };
struct rect { int x0; int y0; int x1; int y1; };
struct dsrc { unsigned char pad[2]; int a2; int a4; int a6; int a8; };

/* __near: the ROM reaches the cell with a 16-bit absolute operand; plain: 24-bit. */
/* cc900-name: HdrStr_G=FileIO_ReadValidateHdr_Store_Str_G */
extern char HdrStr_G[];
/* cc900-name: HdrStr_LKE=FileIO_ReadValidateHdr_Store_Str_LKE */
extern char HdrStr_LKE[];
/* cc900-name: HdrStr_H=FileIO_ReadValidateHdr_Store_Str_H */
extern char HdrStr_H[];
extern char LoadSMF_GetRecordPtr_Str_rb[];
extern char LoadSecondary_OpenFile_Str_rb[];
extern unsigned char *FileIO_HeaderAt4_ExpectedPtr;
extern unsigned char LIVE_PANEL_BLOCK;
extern unsigned int NMI_CHECKSUM_REGION1;
extern unsigned int NMI_CHECKSUM_REGION2;
extern char ram_1e53e;
extern struct fdcp __near ram_62e;
extern unsigned char __near ram_bd18;
extern unsigned char __near ram_bd00;
extern unsigned char __near ram_bd02;
extern unsigned char __near ram_bd0c;
extern unsigned char __near ram_bd0e;
extern mqp __near ram_bcb4;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char MidiRx_ToneParam_ByteMap[];
extern unsigned char __near ram_413;
extern unsigned char __near ram_422;
extern unsigned char __near ram_473;
extern unsigned char __near ram_bf39;
extern unsigned char HDAE5000_PPI__PORT_A;
extern unsigned long HDAE5000_ROM__BASE_ADDR;
extern unsigned int CUSTOM_DATA_FLASH__BASE_ADDR;
extern unsigned int ram_200000;
extern unsigned long __near SYSTEM_TIMESTAMP;
extern unsigned char DISPLAY_ENABLE_FLAG;
extern unsigned int DISPLAY_DIRTY_FLAGS;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_CURSOR_TRACK;
extern unsigned char __near ram_d54;
extern unsigned char __near ram_d6a;
extern unsigned char __near ram_10fa;
extern unsigned char __near ram_e3e2;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern unsigned char __near ram_8d88;
extern char ram_25db6;
extern unsigned char FileIO_DiskInfoInit_MediaType;
extern unsigned char __near ram_654;
extern unsigned char __near ram_628[];
typedef unsigned long *ulp;
extern ulp __near ram_646;
extern unsigned long __near ram_642;

extern void FileIO_SeekAndReadBlock(long, int);
extern int FileIO_ReadByte(void);
extern void FileIO_SeekRead_ExtReturn(void);
extern int FileIO_Search_SkipEntry(char *, char *, int);
extern unsigned int Checksum_ComputeComplement(unsigned char *, unsigned int);
extern unsigned long Math_DivideU32(unsigned long, unsigned long);
extern unsigned long Math_RemainderU32(unsigned long, unsigned long);
extern unsigned char SeqData_ReadFieldByIndex(struct mq *, int);
extern void DrawLine(struct pt *, struct pt *, int);
extern void DrawBox(struct rect *, int);
extern int GetFirstPageBase(void);
extern char *GetRecordPtrForFile(int);
extern int FileIO_OpenWithMode(char *, char *);
extern int FileIO_ReturnError(void);
extern int SMF_SelectBankAndLoad(int, int);
extern void FileIO_CloseHandle(void);
extern void FileIO_WriteRecordName(char *);
extern void AudioMix_Init(void);
extern void SeqBuf_Init(void);
extern void TempoRingBuf_Init(void);
extern void SeqMain_InitBuffer(void);
extern void RhythmBuf_Init(void);
extern void SeqBuf_MidiOut_Init(void);
extern void SeqEvtBuf_Init(void);
extern void SeqBuf2_Init(void);
extern void AltEvtBuf_Init(void);
extern void SeqBuf_NoteEvent_Flush(void);
extern void SeqBuf_VoiceMap_Flush(void);
extern void SeqBuf_NoteEvent_InitBuffer(void);
extern void SeqBuf_SoundEdit_Flush(void);
extern void SeqBuf3_Init(void);
extern void SeqBuf_DspSysEx_InitBuffer(void);
extern void Flash_ProgramByte(unsigned long *, unsigned long);
extern void Flash_ProgramWord(int, unsigned int *, unsigned int);
extern long _findfirst(char *, struct ffblk *);
extern void _findclose(long);
extern int FileIO_CopyAndOpen(char *, char *);
extern void TableDataFlash_ChipErase(void);
extern int HDAE5000_Status_Check(void);
extern void VRAM_FillRect(int, int, int);
extern void Display_UpdateRegion0(void);
extern void Display_UpdateRegion1(void);
extern void Display_UpdateRegion2(void);
extern void Display_UpdateRegion3(void);
extern void Display_UpdateRegion4(void);
extern void Display_UpdateRegion5(void);
extern void Display_UpdateRegion6(void);
extern void Display_UpdateRegion7(void);
extern void Display_UpdateRegion8(void);
extern void Display_UpdateRegion9(void);
extern void Display_UpdateRegion10(void);
extern void NoteMap_SendAllNotesOff(void);
extern void Part_ReinitAllActive(void);
extern void AccWrap_PlayModeDispatch(void);
extern void AccompSeq_StopSequence(void);
extern void AudioInit_RefreshToneBank(void);
extern void NoteMap_ProcessAndMerge(void);
extern void Voice_InitializeAll(void);
extern void Voice_InitTablePair(void);
extern void Voice_InitTableGroup(void);
extern void MIDI_SendAllSoundOff(void);
extern void MidiIn_IgnoreClockTransport(void);
extern int FileIO_GetCurrentWallpaperIndex(void);
extern char *FileIO_GetWallpaperEntry(int);
extern int Gfx_LoadSplashBMP(void);
extern void Scoop_SpecialMode_ParamCheckBound(void);
extern void SqStep_SetupCursorTrack(void);
extern void UI_InterruptTitleByIndex(int);
extern void MidiTG_WriteRegByDescriptor(unsigned char *);
extern unsigned char GetMediaType(void);

int FileIO_ReadAndValidateHeader(void)
{
    char buf[3];
    int i, c, r;
    FileIO_SeekAndReadBlock(0, 0);
    for (i = 0; i < 3; i++) {
        if ((c = FileIO_ReadByte()) < 0) c = 0;
        buf[i] = c;
    }
    FileIO_SeekRead_ExtReturn();
    r = FileIO_Search_SkipEntry(buf, HdrStr_H, 3) == 0 || FileIO_Search_SkipEntry(buf, HdrStr_G, 3) == 0
        || FileIO_Search_SkipEntry(buf, HdrStr_LKE, 3) == 0;
    return r;
}

void SubCPU_Payload_Verify(void)
{
    unsigned int s = Checksum_ComputeComplement((unsigned char *)0xf180, 0x800);
    if (s == NMI_CHECKSUM_REGION1) {
        ram_1e53e = 0;
        if (Checksum_ComputeComplement(&LIVE_PANEL_BLOCK, 0x280) != NMI_CHECKSUM_REGION2) ram_1e53e = -1;
    } else {
        ram_1e53e = -1;
        if (Checksum_ComputeComplement(&LIVE_PANEL_BLOCK, 0x280) == NMI_CHECKSUM_REGION2) ram_1e53e = 1;
    }
}

void FDC_SetupSectorParams(unsigned long lba, unsigned int n, long p)
{
    struct fdcp *f = &ram_62e;
    unsigned int t;
    t = Math_DivideU32(lba, 18);
    f->head = 0;
    f->cyl = t >> 1;
    f->side = t & 1;
    f->sec = Math_RemainderU32(lba, 18) + 1;
    f->n = n;
    f->p = p;
}

void MidiSeq_UpdateToneParam(void)
{
    unsigned char c;
    if (ram_bd18 & 0x40) {
        c = MidiRx_ToneParam_ByteMap[SeqData_ReadFieldByIndex(ram_bcb4, 3)];
        ram_bd00 = c;
        if (c != ram_bd02) ram_bd00 = c | 0x80;
    } else {
        c = MidiRx_ToneParam_ByteMap[SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 3)];
        ram_bd0c = c;
        if (c != ram_bd0e) ram_bd0c = c | 0x80;
    }
}

void Scoop_Dispatch_Nop(void)
{
}

void Scoop_Dispatch_CallFAA98A(struct dsrc *s)
{
    struct pt a, b;
    a.x = s->a2;
    a.y = s->a4;
    b.x = s->a6;
    b.y = s->a8;
    DrawLine(&a, &b, 0xff);
}

void Scoop_Dispatch_CallFAB273(struct dsrc *s)
{
    struct rect r;
    r.x0 = s->a2;
    r.y0 = s->a4;
    r.x1 = s->a6;
    r.y1 = s->a8;
    DrawBox(&r, 0xf5);
}

int LoadFileSMF(unsigned char a, unsigned char b)
{
    char *rec;
    int r, pg;
    pg = GetFirstPageBase();
    if (pg < 0) return -104;
    if (FileIO_OpenWithMode(rec = GetRecordPtrForFile(pg), LoadSMF_GetRecordPtr_Str_rb) < 0) return FileIO_ReturnError();
    r = SMF_SelectBankAndLoad(a, b);
    FileIO_CloseHandle();
    FileIO_WriteRecordName(rec);
    return r;
}

void Seq_FullInit(void)
{
    unsigned char f = 0xff;
    ram_413 = f;
    ram_422 = f;
    ram_473 = f;
    AudioMix_Init();
    SeqBuf_Init();
    TempoRingBuf_Init();
    SeqMain_InitBuffer();
    RhythmBuf_Init();
    SeqBuf_MidiOut_Init();
    SeqEvtBuf_Init();
    SeqBuf2_Init();
    AltEvtBuf_Init();
    SeqBuf_NoteEvent_Flush();
    SeqBuf_VoiceMap_Flush();
    SeqBuf_NoteEvent_InitBuffer();
    SeqBuf_SoundEdit_Flush();
    SeqBuf3_Init();
    SeqBuf_DspSysEx_InitBuffer();
    ram_bf39 = 255;
}

void Seq_InitStub_Nop1(void)
{
}

void Seq_InitStub_Nop2(void)
{
}

void Seq_InitStub_Nop3(void)
{
}

void HDAE5000_ProgramTableDataFlash(void)
{
    unsigned long *src;
    unsigned long *dst = (unsigned long *)0x800000;
    unsigned char bank;
    unsigned long i;
    bank = 0;
    do {
        HDAE5000_PPI__PORT_A = bank;
        src = &HDAE5000_ROM__BASE_ADDR;
        i = 0;
        do {
            Flash_ProgramByte(dst++, *src++);
            i++;
        } while (i < 0x20000);
        bank++;
    } while (bank < 4);
}

void HDAE5000_ProgramCustomDataFlash(void)
{
    unsigned int *src;
    unsigned int *dst = &CUSTOM_DATA_FLASH__BASE_ADDR;
    unsigned char bank;
    unsigned long i;
    bank = 0;
    do {
        HDAE5000_PPI__PORT_A = bank;
        src = &ram_200000;
        i = 0;
        do {
            Flash_ProgramWord(1, dst++, *src++);
            i++;
        } while (i < 0x40000);
        bank++;
    } while (bank < 2);
}

int SearchAndOpen(char *name)
{
    struct ffblk f;
    int pg;
    long h;
    pg = GetFirstPageBase();
    if (pg < 0) return -104;
    if ((h = _findfirst(name, &f)) >= 0) {
        _findclose(h);
        return -10;
    }
    return FileIO_CopyAndOpen(GetRecordPtrForFile(pg), name);
}

void Flash_BurnWithProgress(void)
{
    int x = 0x32;
    SYSTEM_TIMESTAMP = 0;
    TableDataFlash_ChipErase();
    if (HDAE5000_Status_Check() == -1) do {
        if (SYSTEM_TIMESTAMP > 500) {
            x += 8;
            VRAM_FillRect(x, 0xb4, 5);
            SYSTEM_TIMESTAMP = 0;
        }
    } while (HDAE5000_Status_Check() == -1);
}

void Display_UpdateDirtyRegions(void)
{
    DISPLAY_ENABLE_FLAG = 1;
    if (DISPLAY_DIRTY_FLAGS != 0) {
        Display_UpdateRegion0();
        Display_UpdateRegion5();
        Display_UpdateRegion7();
        Display_UpdateRegion8();
        Display_UpdateRegion9();
        Display_UpdateRegion1();
        Display_UpdateRegion10();
        Display_UpdateRegion6();
        Display_UpdateRegion3();
        Display_UpdateRegion4();
        Display_UpdateRegion2();
    }
    DISPLAY_DIRTY_FLAGS = 0xffff;
}

void InitializeOperationState(char a)
{
    SeqBuf_Init();
    NoteMap_SendAllNotesOff();
    Part_ReinitAllActive();
    AccWrap_PlayModeDispatch();
    if (a) SEQ_RTMCFG |= 4;
    AccompSeq_StopSequence();
    AudioInit_RefreshToneBank();
    NoteMap_ProcessAndMerge();
    Voice_InitializeAll();
    Voice_InitTablePair();
    Voice_InitTableGroup();
    MIDI_SendAllSoundOff();
    MidiIn_IgnoreClockTransport();
}

int LoadFromSecondaryPage(void)
{
    int i, r;
    i = FileIO_GetCurrentWallpaperIndex();
    if (i < 0) return -104;
    {
        char *e = FileIO_GetWallpaperEntry(i);
        if (FileIO_OpenWithMode(e, LoadSecondary_OpenFile_Str_rb) < 0) return FileIO_ReturnError();
    }
    r = Gfx_LoadSplashBMP();
    FileIO_CloseHandle();
    return r;
}

/* cc900-name: DisplayMode_Disp_Mode0_Helper=DisplayMode_Dispatch_Mode0_Helper */
void DisplayMode_Disp_Mode0_Helper(void)
{
    SEQ_TRACK = SEQ_CURSOR_TRACK;
    Scoop_SpecialMode_ParamCheckBound();
    ram_d54 &= ~0x80;
    ram_d6a = 0;
    ram_10fa = 1;
    SqStep_SetupCursorTrack();
    ram_10fa = 0;
    ram_e3e2 &= 0x6f;
    GLOBAL_ERROR_CODE = 35;
    UI_InterruptTitleByIndex(0xee);
    ram_8d88 |= 1;
}

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

int FileIO_ReadHeaderAtF(void)
{
    int ok = 1;
    int c;
    FileIO_SeekAndReadBlock(15, 0);
    c = FileIO_ReadByte();
    if (c < 0 || (char)c != 8) ok = 0;
    FileIO_SeekRead_ExtReturn();
    return ok;
}

unsigned char GetDiskSizeInfo(void)
{
    char m = ram_25db6;
    if (m == FileIO_DiskInfoInit_MediaType) ram_25db6 = GetMediaType();
    return ram_25db6;
}

void Flash_AccumWrite_Byte(unsigned char a)
{
    unsigned char *bp = ram_628;
    bp[ram_654] = a;
    if (ram_654++ == 3) {
        Flash_ProgramByte(ram_646++, *(unsigned long *)bp);
        ram_654 = 0;
    }
    ram_642 += 1;
}

void TGReg_WriteCC3_Expression(void)
{
    unsigned char d[4], *p = d;
    p[1] = 3;
    p[2] = 0x64;
    p[3] = 0x7f;
    for (*p = 0; *p <= 15; (*p)++) MidiTG_WriteRegByDescriptor(p);
}

void TGReg_WriteCC12_Assign(void)
{
    unsigned char d[4], *p = d;
    for (d[0] = 0; d[0] <= 15; d[0]++) {
        p[1] = 0xc;
        p[2] = 0;
        p[3] = 0x10;
        MidiTG_WriteRegByDescriptor(p);
    }
}
