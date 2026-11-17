/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_C_5b.c (2026-11-16-40-p6-r8)
   sha256 0925ac3d7624e564a79643524eac0977811cc2828328dc740296e5ffc2f35240 (tar-sha256); compiled at -O3 -XS -Xr */
/* Phase 6, lane_p6 helper C, round 5, form b: routines WITH calls of v10 midi/midi_dispatch_handlers.s,
   display/scoop_display.s, demo/file_demo_proc.s, boot/system_handlers.s.  Form a (p6_C_5a.c) has the same names.
   Form a declares every callee with a prototype; form b declares the callees without arguments unprototyped
   (`extern void f();`), to see whether V4.23 then keeps `call f` + `ret` instead of a tail jump. */

typedef unsigned int *uip;
typedef unsigned long *ulp;
struct tgd { unsigned char ch; unsigned char reg; unsigned char val; unsigned char mask; };
struct ffblk { unsigned char b[266]; };

/* __near: the ROM reaches the cell with a 16-bit absolute operand; plain: 24-bit. */
extern unsigned char __near SWBTWR_EVENT_QUEUE;
extern unsigned int __near SWBTWR_WRITE_INDEX;
extern unsigned char FileIO_DiskInfoInit_MediaType;
extern char ram_25db6;
extern long ram_25d6c;
extern long FileIO_DiskInfoInit;
extern unsigned int FILE_ERROR;
extern unsigned char __near ram_422;
extern unsigned char __near ram_e9bc;
extern unsigned char __near ram_d6d;
extern unsigned char __near ram_d6e;
extern unsigned char __near ram_d61;
extern unsigned char __near ram_1127;
extern unsigned char __near DISPLAY_CHORD_ROOT;
extern unsigned char __near DISPLAY_CHORD_TYPE;
extern unsigned char __near DISPLAY_CHORD_BASS;
extern unsigned int __near ram_ef0;
extern unsigned char __near PERF_STEP_FIELD;
extern unsigned char __near ram_e3e2;
extern unsigned char __near ram_918d[];
extern unsigned char __near ram_654;
extern unsigned char __near ram_62c[];
extern unsigned char __near ram_628[];
extern uip __near ram_656;
extern ulp __near ram_646;
extern unsigned long __near ram_642;
extern unsigned char DISPLAY_ENABLE_FLAG;
extern unsigned char DISPLAY_DIRTY_FLAGS;
extern unsigned char ram_205e5;

extern void MidiTG_WriteRegByDescriptor(struct tgd *);
extern void GetDiskFreeSpace(long *, long *);
extern int format_FD(unsigned int);
extern void SLIDE_Parse_Header(long, unsigned char *);
extern void SysEx_ApplyVoiceParam_49(int, unsigned char *);
extern void SysEx_ApplyVoiceParam_4B(int, unsigned char *);
extern void Flash_ProgramWord(int, unsigned int *, unsigned int);
extern void Flash_ProgramByte(unsigned long *, unsigned long);
extern long _findfirst(char *, struct ffblk *);
extern void _findclose(long);
extern void SwbtWr_InitBank1();
extern void SwbtWr_InitBank2();
extern void VoiceEvent_DispatchTable();
extern void SNS_Init_Startup();
/* cc900-name: PerfMode_Evt01_NNDial_H7=PerfMode_Evt01_NoteNumberDial_Helper7 */
extern void PerfMode_Evt01_NNDial_H7();
extern void DisplayStr_WriteTempoValue();
extern void Display_RedrawTitleBar();
extern void Display_RedrawMainContent();
extern void Display_RedrawMenu();
extern void Display_RedrawValues();
extern void Display_UpdateRegion0();
extern void Display_UpdateRegion2();
extern void Display_UpdateRegion4();
extern void Display_UpdateRegion6();
extern void Display_UpdateRegion7();
extern void Display_UpdateRegion8();
extern void Display_UpdateRegion9();
extern void Display_UpdateRegion10();
extern void SqStep_UpdateChordCellCursor();
extern void Display_UpdateRegion1();
extern void Display_UpdateRegion3();
extern int SeqBuf_MidiOut_CheckEmpty();
extern unsigned char GetMediaType();
extern unsigned char NoteMap_FindBestMatch();
extern int FileIO_ReadByte();

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

void TGReg_WriteCC3_Expression(void)
{
    struct tgd d, *p = &d;
    p->reg = 0x3;
    p->val = 0x64;
    p->mask = 0x7f;
    for (p->ch = 0; p->ch <= 15; p->ch++) MidiTG_WriteRegByDescriptor(p);
}

void TGReg_WriteCC4_Pan(void)
{
    struct tgd d, *p = &d;
    p->reg = 0x4;
    p->val = 0x0;
    p->mask = 0x8;
    for (p->ch = 0; p->ch <= 15; p->ch++) MidiTG_WriteRegByDescriptor(p);
}

void TGReg_WriteCC4_Sustain(void)
{
    struct tgd d, *p = &d;
    p->reg = 0x4;
    p->val = 0x0;
    p->mask = 0x40;
    for (p->ch = 0; p->ch <= 15; p->ch++) MidiTG_WriteRegByDescriptor(p);
}

void TGReg_WriteCC5_Modulation(void)
{
    struct tgd d, *p = &d;
    p->reg = 0x5;
    p->val = 0x0;
    p->mask = 0x7f;
    for (p->ch = 0; p->ch <= 15; p->ch++) MidiTG_WriteRegByDescriptor(p);
}

void TGReg_WriteCC7_Reverb(void)
{
    struct tgd d, *p = &d;
    p->reg = 0x7;
    p->val = 0x28;
    p->mask = 0x7f;
    for (p->ch = 0; p->ch <= 15; p->ch++) MidiTG_WriteRegByDescriptor(p);
}

void TGReg_WriteCC8_Chorus(void)
{
    struct tgd d, *p = &d;
    p->reg = 0x8;
    p->val = 0x40;
    p->mask = 0x7f;
    for (p->ch = 0; p->ch <= 15; p->ch++) MidiTG_WriteRegByDescriptor(p);
}

void TGReg_WriteCC9_Variation(void)
{
    struct tgd d, *p = &d;
    p->reg = 0x9;
    p->val = 0x40;
    p->mask = 0x7f;
    for (p->ch = 0; p->ch <= 15; p->ch++) MidiTG_WriteRegByDescriptor(p);
}

void TGReg_WriteCC10_KeyShift(void)
{
    struct tgd d, *p = &d;
    p->reg = 0xa;
    p->val = 0x80;
    p->mask = 0xff;
    for (p->ch = 0; p->ch <= 15; p->ch++) MidiTG_WriteRegByDescriptor(p);
}

void TGReg_WriteCC11_PartMode(void)
{
    struct tgd d, *p = &d;
    p->reg = 0xb;
    p->val = 0x2;
    p->mask = 0x7f;
    for (p->ch = 0; p->ch <= 15; p->ch++) MidiTG_WriteRegByDescriptor(p);
}

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
    if (FileIO_DiskInfoInit == ram_25d6c) GetDiskFreeSpace(&ram_25d6c, &ram_25d6c + 1);
    return ram_25d6c;
}

int FileIO_ValidateRecord_CheckSize(unsigned char a)
{
    if (format_FD(a) == 0) {
        if (FILE_ERROR == 31) return -11;
        return -6;
    }
    return 0;
}

void Demo_ParseSlideHeader(unsigned char i)
{
    long v;
    if ((v = ((long *)0x9c4000)[i]) != 0) SLIDE_Parse_Header(v, (unsigned char *)0x69800);
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
    unsigned char z = 0;
    ram_d6d = z;
    ram_d6e = z;
    ram_d61 = z;
    ram_1127 = z;
    SNS_Init_Startup();
    Display_UpdateRegion3();
}

void PerfMode_ParamHandler_7_Helper(void)
{
    ram_ef0 = 1;
    PERF_STEP_FIELD = 2;
    PerfMode_Evt01_NNDial_H7();
    DisplayStr_WriteTempoValue();
    Display_UpdateRegion3();
    ram_e3e2 |= 8;
}

void PerfMode_ParamHandler_7_Helper2(void)
{
    ram_ef0 = 0xffff;
    PERF_STEP_FIELD = 2;
    PerfMode_Evt01_NNDial_H7();
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
