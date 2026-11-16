int FileIO_ReadAndValidateHeader(void)
{
    char buf[3];
    int i, c, r;
    FileIO_SeekAndReadBlock(0, 0);
    i = 0;
    do {
        c = FileIO_ReadByte();
        if (c < 0) c = 0;
        buf[i] = c;
        i++;
    } while (i < 3);
    FileIO_SeekRead_ExtReturn();
    r = 0;
    if (FileIO_Search_SkipEntry(buf, HdrStr_H, 3) == 0 || FileIO_Search_SkipEntry(buf, HdrStr_G, 3) == 0
        || FileIO_Search_SkipEntry(buf, HdrStr_LKE, 3) == 0) r = 1;
    return r;
}

void SubCPU_Payload_Verify(void)
{
    unsigned int s = Checksum_ComputeComplement((unsigned char *)0xf180, 0x800);
    unsigned char *p = &LIVE_PANEL_BLOCK;
    if (s == NMI_CHECKSUM_REGION1) {
        ram_1e53e = 0;
        if (Checksum_ComputeComplement(p, 0x280) != NMI_CHECKSUM_REGION2) ram_1e53e = -1;
    } else {
        ram_1e53e = -1;
        if (Checksum_ComputeComplement(p, 0x280) == NMI_CHECKSUM_REGION2) ram_1e53e = 1;
    }
}

void FDC_SetupSectorParams(unsigned long lba, unsigned int n, long p)
{
    struct fdcp *f;
    unsigned int t = Math_DivideU32(lba, 18);
    f = &ram_62e;
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
        if (c == ram_bd02) return;
        ram_bd00 = c | 0x80;
    } else {
        c = MidiRx_ToneParam_ByteMap[SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 3)];
        ram_bd0c = c;
        if (c == ram_bd0e) return;
        ram_bd0c = c | 0x80;
    }
}

void Scoop_Dispatch_Nop(void)
{
}

void Scoop_Dispatch_CallFAA98A(struct dsrc *s)
{
    struct pt b, a;
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
    rec = GetRecordPtrForFile(pg);
    if (FileIO_OpenWithMode(rec, LoadSMF_GetRecordPtr_Str_rb) < 0) return FileIO_ReturnError();
    r = SMF_SelectBankAndLoad(a, b);
    FileIO_CloseHandle();
    FileIO_WriteRecordName(rec);
    return r;
}

void Seq_FullInit(void)
{
    ram_413 = 0xff;
    ram_422 = 0xff;
    ram_473 = 0xff;
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
    h = _findfirst(name, &f);
    if (h < 0) return FileIO_CopyAndOpen(GetRecordPtrForFile(pg), name);
    _findclose(h);
    return -10;
}

void Flash_BurnWithProgress(void)
{
    int x = 0x32;
    SYSTEM_TIMESTAMP = 0;
    TableDataFlash_ChipErase();
    while (HDAE5000_Status_Check() == -1) {
        if (SYSTEM_TIMESTAMP > 500) {
            x += 8;
            VRAM_FillRect(x, 0xb4, 5);
            SYSTEM_TIMESTAMP = 0;
        }
    }
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

int LoadFromSecondaryPage(void)
{
    int i, r;
    i = FileIO_GetCurrentWallpaperIndex();
    if (i < 0) return -104;
    if (FileIO_OpenWithMode(FileIO_GetWallpaperEntry(i), LoadSecondary_OpenFile_Str_rb) < 0) return FileIO_ReturnError();
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
    if (c < 0 || (unsigned char)c != *FileIO_HeaderAt4_ExpectedPtr) ok = 0;
    FileIO_SeekRead_ExtReturn();
    return ok;
}

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

unsigned char GetDiskSizeInfo(void)
{
    if (ram_25db6 == FileIO_DiskInfoInit_MediaType) ram_25db6 = GetMediaType();
    return ram_25db6;
}

void Flash_AccumWrite_Byte(unsigned char a)
{
    unsigned long *q;
    ram_628[ram_654] = a;
    if (ram_654++ == 3) {
        q = ram_646++;
        Flash_ProgramByte(q, *(unsigned long *)ram_628);
        ram_654 = 0;
    }
    ram_642 += 1;
}

void TGReg_WriteCC3_Expression(void)
{
    unsigned char d[4];
    d[1] = 3;
    d[2] = 0x64;
    d[3] = 0x7f;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC12_Assign(void)
{
    unsigned char d[4];
    for (d[0] = 0; d[0] <= 15; d[0]++) {
        d[1] = 0xc;
        d[2] = 0;
        d[3] = 0x10;
        MidiTG_WriteRegByDescriptor(d);
    }
}
