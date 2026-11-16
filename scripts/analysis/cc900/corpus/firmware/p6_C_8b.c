/* Phase 6, lane_p6 helper C, round 8, form b: the TGReg family in the array form that matched for CC3 / CC12,
   and one-spot refinements of round 6.  Form a (p6_C_8a.c) has the same names. */

struct fdcp { unsigned int w0; unsigned int head; unsigned int side; unsigned int cyl; unsigned int sec; unsigned int n; long p; };

/* __near: the ROM reaches the cell with a 16-bit absolute operand; plain: 24-bit. */
extern struct fdcp __near ram_62e;
extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_CURSOR_TRACK;
extern unsigned char __near ram_d54;
extern unsigned char __near ram_d6a;
extern unsigned char __near ram_10fa;
extern unsigned char __near ram_e3e2;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern unsigned char __near ram_8d88;
extern char ram_25db6;
extern char FileIO_DiskInfoInit_MediaType;
extern void MidiTG_WriteRegByDescriptor(unsigned char *);
extern unsigned char GetMediaType(void);
extern unsigned long Math_DivideU32(unsigned long, unsigned long);
extern unsigned long Math_RemainderU32(unsigned long, unsigned long);
extern int GetFirstPageBase(void);
extern char *GetRecordPtrForFile(int);
extern int FileIO_OpenWithMode(char *, char *);
extern int FileIO_ReturnError(void);
extern int SMF_SelectBankAndLoad(int, int);
extern void FileIO_CloseHandle(void);
extern void FileIO_WriteRecordName(char *);
extern int FileIO_GetCurrentWallpaperIndex(void);
extern char *FileIO_GetWallpaperEntry(int);
extern int Gfx_LoadSplashBMP(void);
extern void FileIO_SeekAndReadBlock(long, int);
extern int FileIO_ReadByte(void);
extern void FileIO_SeekRead_ExtReturn(void);
extern int FileIO_Search_SkipEntry(char *, char *, int);
/* cc900-name: Scoop_SpecMode_ParamCheckBound=Scoop_SpecialMode_ParamCheckBound */
extern void Scoop_SpecMode_ParamCheckBound(void);
extern void SqStep_SetupCursorTrack(void);
extern void UI_InterruptTitleByIndex(int);

void TGReg_WriteCC4_Pan(void)
{
    unsigned char d[4];
    d[1] = 0x4;
    d[2] = 0x0;
    d[3] = 0x8;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC4_Sustain(void)
{
    unsigned char d[4];
    d[1] = 0x4;
    d[2] = 0x0;
    d[3] = 0x40;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC5_Modulation(void)
{
    unsigned char d[4];
    d[1] = 0x5;
    d[2] = 0x0;
    d[3] = 0x7f;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC7_Reverb(void)
{
    unsigned char d[4];
    d[1] = 0x7;
    d[2] = 0x28;
    d[3] = 0x7f;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC8_Chorus(void)
{
    unsigned char d[4];
    d[1] = 0x8;
    d[2] = 0x40;
    d[3] = 0x7f;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC9_Variation(void)
{
    unsigned char d[4];
    d[1] = 0x9;
    d[2] = 0x40;
    d[3] = 0x7f;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC10_KeyShift(void)
{
    unsigned char d[4];
    d[1] = 0xa;
    d[2] = 0x80;
    d[3] = 0xff;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC11_PartMode(void)
{
    unsigned char d[4];
    d[1] = 0xb;
    d[2] = 0x2;
    d[3] = 0x7f;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC0_Volume(void)
{
    unsigned char d[4];
    for (d[0] = 0; d[0] <= 15; d[0]++) {
        d[1] = 0;
        d[2] = 0;
        d[3] = 0xff;
        MidiTG_WriteRegByDescriptor(d);
        d[1] = 1;
        d[2] = 0;
        d[3] = 0x7f;
        MidiTG_WriteRegByDescriptor(d);
    }
    d[0] = 15;
    d[1] = 0;
    d[2] = 0x0;
    d[3] = 0xff;
    MidiTG_WriteRegByDescriptor(d);
    d[0] = 15;
    d[1] = 1;
    d[2] = 0x78;
    d[3] = 0x7f;
    MidiTG_WriteRegByDescriptor(d);
}

void TGReg_WriteCC0_AltMask(void)
{
    unsigned char d[4];
    for (d[0] = 0; d[0] <= 15; d[0]++) {
        d[1] = 0;
        d[2] = 0;
        d[3] = 0xff;
        MidiTG_WriteRegByDescriptor(d);
        d[1] = 1;
        d[2] = 0;
        d[3] = 0x7f;
        MidiTG_WriteRegByDescriptor(d);
    }
    d[0] = 15;
    d[1] = 0;
    d[2] = 0xf0;
    d[3] = 0xff;
    MidiTG_WriteRegByDescriptor(d);
    d[0] = 15;
    d[1] = 1;
    d[2] = 0x0;
    d[3] = 0x7f;
    MidiTG_WriteRegByDescriptor(d);
}

unsigned char GetDiskSizeInfo(void)
{
    if (FileIO_DiskInfoInit_MediaType == ram_25db6) ram_25db6 = GetMediaType();
    return ram_25db6;
}

void FDC_SetupSectorParams(unsigned long lba, unsigned int n, long p)
{
    struct fdcp *f;
    unsigned int *sp;
    unsigned int t;
    f = &ram_62e;
    t = Math_DivideU32(lba, 18);
    f->head = 0;
    f->cyl = t >> 1;
    f->side = t & 1;
    sp = &f->sec;
    *sp = Math_RemainderU32(lba, 18) + 1;
    f->n = n;
    f->p = p;
}

int LoadFileSMF(int a, unsigned char b)
{
    char *rec;
    int r, pg;
    pg = GetFirstPageBase();
    if (pg < 0) return -104;
    if (FileIO_OpenWithMode(rec = GetRecordPtrForFile(pg), (char *)0xea0240) < 0) return FileIO_ReturnError();
    r = SMF_SelectBankAndLoad(a & 0xff, b);
    FileIO_CloseHandle();
    FileIO_WriteRecordName(rec);
    return r;
}

int LoadFromSecondaryPage(void)
{
    int i, r;
    i = FileIO_GetCurrentWallpaperIndex();
    if (i < 0) return -104;
    {
        char *e = FileIO_GetWallpaperEntry(i);
        if (FileIO_OpenWithMode(e, (char *)0xea0264) < 0) return FileIO_ReturnError();
    }
    r = Gfx_LoadSplashBMP();
    FileIO_CloseHandle();
    return r;
}

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
    r = 0;
    if (FileIO_Search_SkipEntry(buf, (char *)0xea017e, 3) == 0 || FileIO_Search_SkipEntry(buf, (char *)0xea0176, 3) == 0
        || FileIO_Search_SkipEntry(buf, (char *)0xea017a, 3) == 0) r = 1;
    return r;
}

/* cc900-name: DisplayMode_Disp_Mode0_Helper=DisplayMode_Dispatch_Mode0_Helper */
void DisplayMode_Disp_Mode0_Helper(void)
{
    SEQ_TRACK = SEQ_CURSOR_TRACK;
    Scoop_SpecMode_ParamCheckBound();
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
