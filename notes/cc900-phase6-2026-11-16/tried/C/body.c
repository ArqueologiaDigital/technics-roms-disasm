void SwbtWr_ReinitBothBanks(void)
{
    if (SWBTWR_EVENT_QUEUE == 255) return;
    SwbtWr_InitBank1();
    SwbtWr_InitBank2();
    SWBTWR_EVENT_QUEUE = 255;
    SWBTWR_WRITE_INDEX = 0;
}

void SwbtWr_ReinitOutputBank(void)
{
    if (SWBTWR_EVENT_QUEUE == 255) return;
    SwbtWr_InitBank2();
    SWBTWR_EVENT_QUEUE = 255;
    SWBTWR_WRITE_INDEX = 0;
}

void SeqBuf_WaitForEmpty(void)
{
    unsigned int n = 0xfffe;
    do {
        if (SeqBuf_MidiOut_CheckEmpty() == 0) return;
    } while (n--);
}

#define TG_LOOP(NAME, R, V, M) \
void NAME(void) \
{ \
    struct tgd d; \
    TG_INIT(R, V, M) \
}

TGFUNCS

void TGReg_WriteCC12_Assign(void)
{
    struct tgd d;
    for (d.ch = 0; d.ch <= 15; d.ch++) {
        d.reg = 0xc;
        d.val = 0;
        d.mask = 0x10;
        MidiTG_WriteRegByDescriptor(&d);
    }
}

void TGReg_WriteCC0_Volume(void)
{
    struct tgd d;
    for (d.ch = 0; d.ch <= 15; d.ch++) {
        d.reg = 0;
        d.val = 0;
        d.mask = 0xff;
        MidiTG_WriteRegByDescriptor(&d);
        d.reg = 1;
        d.val = 0;
        d.mask = 0x7f;
        MidiTG_WriteRegByDescriptor(&d);
    }
    d.ch = 15;
    d.reg = 0;
    d.val = 0;
    d.mask = 0xff;
    MidiTG_WriteRegByDescriptor(&d);
    d.ch = 15;
    d.reg = 1;
    d.val = 0x78;
    d.mask = 0x7f;
    MidiTG_WriteRegByDescriptor(&d);
}

void TGReg_WriteCC0_AltMask(void)
{
    struct tgd d;
    for (d.ch = 0; d.ch <= 15; d.ch++) {
        d.reg = 0;
        d.val = 0;
        d.mask = 0xff;
        MidiTG_WriteRegByDescriptor(&d);
        d.reg = 1;
        d.val = 0;
        d.mask = 0x7f;
        MidiTG_WriteRegByDescriptor(&d);
    }
    d.ch = 15;
    d.reg = 0;
    d.val = 0xf0;
    d.mask = 0xff;
    MidiTG_WriteRegByDescriptor(&d);
    d.ch = 15;
    d.reg = 1;
    d.val = 0;
    d.mask = 0x7f;
    MidiTG_WriteRegByDescriptor(&d);
}

unsigned char GetDiskSizeInfo(void)
{
    if (FileIO_DiskInfoInit_MediaType == ram_25db6) ram_25db6 = GetMediaType();
    return ram_25db6;
}

long GetEncodedFreeSpaceData(void)
{
    long *p = &ram_25d6c;
    if (FileIO_DiskInfoInit == *p) GetDiskFreeSpace(p, p + 1);
    return ram_25d6c;
}

int FileIO_ValidateRecord_CheckSize(unsigned char a)
{
    if (format_FD(a) != 0) return 0;
    if (FILE_ERROR == 31) return -11;
    return -6;
}

void Demo_ParseSlideHeader(unsigned char i)
{
    long v = ((long *)0x9c4000)[i];
    if (v == 0) return;
    SLIDE_Parse_Header(v, (unsigned char *)0x69800);
}

void SeqEvt_CheckExpiry(void)
{
    unsigned char a;
    ram_422 &= 0x7f;
    a = ram_e9bc;
    if (a == 0) return;
    ram_e9bc = --a;
    if (a != 0) return;
    if (NoteMap_FindBestMatch() == 0xff) return;
    VoiceEvent_DispatchTable();
}

void Display_RegionUpdateFromHW(void)
{
    ram_d6d = DISPLAY_CHORD_ROOT;
    ram_d6e = DISPLAY_CHORD_TYPE;
    ram_1127 = DISPLAY_CHORD_BASS;
    SNS_Init_Startup();
    Display_UpdateRegion3();
}

void Interrupt_ClearRegsAndInit(void)
{
    ZEROS
    SNS_Init_Startup();
    Display_UpdateRegion3();
}

void PerfMode_ParamHandler_7_Helper(void)
{
    ram_ef0 = 1;
    PERF_STEP_FIELD = 2;
    PerfMode_Evt01_NoteNumberDial_Helper7();
    DisplayStr_WriteTempoValue();
    Display_UpdateRegion3();
    ram_e3e2 |= 8;
}

void PerfMode_ParamHandler_7_Helper2(void)
{
    ram_ef0 = 0xffff;
    PERF_STEP_FIELD = 2;
    PerfMode_Evt01_NoteNumberDial_Helper7();
    DisplayStr_WriteTempoValue();
    Display_UpdateRegion3();
    ram_e3e2 |= 8;
}

void SoundMode_ApplyVoiceParams(void)
{
    unsigned char *p, *e;
    SysEx_ApplyVoiceParam_49(2, (unsigned char *)0xf980);
    SysEx_ApplyVoiceParam_4B(4, (unsigned char *)0xf980);
    p = ram_918d;
    e = p + 31;
    do *p++ = 0x23; while (p <= e);
}

void Flash_AccumWrite_Word(unsigned char a)
{
    ram_62c[ram_654] = a;
    if (ram_654++ == 1) {
        Flash_ProgramWord(1, ram_656++, *(unsigned int *)ram_62c);
        ram_654 = 0;
    }
    ram_642 += 1;
}

void Flash_AccumWrite_Byte(unsigned char a)
{
    ram_628[ram_654] = a;
    if (ram_654++ == 3) {
        Flash_ProgramByte(ram_646++, *(unsigned long *)ram_628);
        ram_654 = 0;
    }
    ram_642 += 1;
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

unsigned char FileIO_CheckFileExists(char *name)
{
    struct ffblk f;
    long h = _findfirst(name, &f);
    if (h < 0) return 0;
    _findclose(h);
    return 1;
}

void Display_UpdateRegion1(void)
{
    if (!(DISPLAY_ENABLE_FLAG & 1)) {
        DISPLAY_DIRTY_FLAGS |= 2;
        return;
    }
    if (DISPLAY_DIRTY_FLAGS & 2) Display_RedrawTitleBar();
}

void Display_UpdateRegion3(void)
{
    if (!(DISPLAY_ENABLE_FLAG & 1)) {
        DISPLAY_DIRTY_FLAGS |= 8;
        return;
    }
    if (DISPLAY_DIRTY_FLAGS & 8) Display_RedrawMainContent();
}

void Display_UpdateRegion5(void)
{
    if (!(DISPLAY_ENABLE_FLAG & 1)) DISPLAY_DIRTY_FLAGS |= 0x40;
    if (DISPLAY_DIRTY_FLAGS & 0x40) Display_RedrawMenu();
}

void Display_UpdateRegion8(void)
{
    if (!(DISPLAY_ENABLE_FLAG & 1)) ram_205e5 |= 2;
    if (ram_205e5 & 2) Display_RedrawValues();
}

void Display_UpdateRegions0To4(void)
{
    Display_UpdateRegion0();
    Display_UpdateRegion1();
    Display_UpdateRegion4();
    Display_UpdateRegion3();
    Display_UpdateRegion2();
}

void UIState_UpdateMultiRegions(void)
{
    Display_UpdateRegion7();
    Display_UpdateRegion8();
    Display_UpdateRegion9();
    Display_UpdateRegion1();
    Display_UpdateRegion10();
    Display_UpdateRegion2();
}

void MemConfig_Handler_5_Helper11(void)
{
    Display_UpdateRegion0();
    Display_UpdateRegion1();
    Display_UpdateRegion6();
    Display_UpdateRegion3();
    SqStep_UpdateChordCellCursor();
    Display_UpdateRegion2();
}
