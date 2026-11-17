/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_F_1a.c (2026-11-16-55-p6-r10)
   sha256 ece06184ca870f3eb6c12fa1d8cc3c5914bcde7e5e780156071ffba817b7601d (tar-sha256); compiled at -O3 -Xr */
/* lane_p6 helper F, round 1, form a: larger routines with calls, from demo/file_demo_proc.s,
   file_io/single_load.s, ui/ui_mode_handlers.s, sequencer/seq_event_playback.s and sequencer/sequencer_ui.s.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named.  __near: the ROM reaches the cell with a
   16-bit absolute operand; plain: 24-bit (or a ROM label).  One declarator per __near declaration.
   Event and object ids are the tree's .equ values. */

#define EVT_SHOW                      0x1c00001L
#define EVT_HIDE                      0x1c00002L
#define EVT_PAINT                     0x1c0000bL
#define EVT_CHANGE_MODE               0x1c00014L
#define EVT_INTERRUPT_TITLE           0x1c00016L
#define EVT_INDEXSW_UP                0x1c00017L
#define EVT_INDEXSW_DOWN              0x1c00018L
#define EVT_LYRICS_RENEW              0x1c7000bL
#define EVT_GET_LARGE_STEP            0x1e0003eL
#define EVT_GET_SMALL_STEP            0x1e0003fL
#define EVT_GET_LSW_ADDRESS           0x1e00040L
#define EVT_GET_LSW_OUTPUT            0x1e00041L
#define EVT_GET_LSW_STRING            0x1e00042L
#define EVT_GET_PARAM                 0x1e0006bL
#define EVT_RESET_INTERRUPT_TIME      0x1e00078L
#define EVT_SET_NOT_DRAW_FLAG         0x1e0009eL
#define EVT_GET_LANGUAGE_PTR          0x1e0009fL
#define EVT_DRAW_KEY                  0x1e30002L
#define EVT_SET_SELECTED_FILE_NUMBER  0x1e50002L
#define EVT_GET_SELECTED_FILE_NUMBER  0x1e50003L
#define EVT_PS_FILE_NAME_BOX_ID       0x1e50004L
#define TITLE_MESAGE                  0x1a000eeL
#define NAKA_MODE_MD_NORMAL           0x1800001L
#define NAKA_VIEW_TEST51              0xf80006L
#define NAKA_VIEW_TEST52              0xf80008L
#define NAKA_VIEW_TEST53              0xf8000aL
#define NAKA_VIEW_TEST54              0xf8000cL
#define NAKA_VIEW_TEST55              0xf8000eL
#define NAKA_VIEW_TEST56              0xf80010L

extern long SendEvent(long, long, long);
extern long PostEvent(long, long, long);
extern long ApPostEvent(long, long, long);
extern long ApFuncCall(long, long, long);

/* ---- demo/file_demo_proc.s: the file-set copy / verify / save routines ---- */

struct FileS { char pad[6]; int flag; };
typedef struct FileS *FileP;
extern FileP __cdecl FileOpen(char *, char *);
extern int __cdecl FileRead(char *, int, int, FileP);
extern int __cdecl FileWrite(char *, int, int, FileP);
extern int __cdecl FileClose(FileP);

struct Path16 { char s[16]; };
extern struct Path16 FileIO_CompareFiles_Path2Init;
extern struct Path16 FileIO_CompareFiles_PathInitB;
extern char FileIO_CompareFiles_Str_wb[];
extern char FileIO_Compare_Mismatch_Str_rb[];
extern int FILE_ERROR;
extern FileP __near ram_7f44;

extern void FileIO_BuildFilePath(char *, char *);
extern int GetCurrentFileIndex(void);
extern void *GetFileEntryPtr(int);
extern void FileIO_FormatFileIndex(char *, int, void *);
extern unsigned char FileIO_CheckRecordValid(unsigned char);
extern unsigned char FileIO_CheckRecordByFile(int, unsigned char);
extern unsigned char FileIO_FormatName_Return(unsigned char);
extern long UpdateFileEntry(int, unsigned char);
extern long FileIO_GetDiskFreeSpace(void);
extern void FileIO_ReadHeader(char *, char *, unsigned char);
extern int FileIO_OpenDefault(char *);
extern int FileIO_CopyAndOpen(char *, char *);
extern void *FileIO_GetRecordByType(void);
extern unsigned char FileIO_TypeProbeOrder[];

struct SaveRec { unsigned char type; char pad; int (*fn)(char *); };
extern struct SaveRec SaveAll_RegionSaveRecs[];

int FileIO_CompareFiles(char *dst, char *src)
{
    struct Path16 pb;
    struct Path16 pa;
    char *buf;
    int r;
    FileP fo;
    FileP fi;
    int n;

    r = 0;
    pb = FileIO_CompareFiles_Path2Init;
    pa = FileIO_CompareFiles_PathInitB;
    FileIO_BuildFilePath(pa.s, dst);
    fo = FileOpen(pa.s, FileIO_CompareFiles_Str_wb);
    if (fo == 0) {
        if (FILE_ERROR == 31) return -11;
        return -3;
    }
    FileIO_BuildFilePath(pb.s, src);
    fi = FileOpen(pb.s, FileIO_Compare_Mismatch_Str_rb);
    if (fi == 0) {
        FileClose(fo);
        return -2;
    }
    buf = (char *)0x69800;
    for (;;) {
        n = FileRead(buf, 1, 0x1000, fi);
        if (n <= 0) break;
        if (FileWrite(buf, 1, n, fo) != n) {
            if ((ram_7f44->flag & 0x7fff) == 0x1f) r = -11;
            else r = -3;
            goto done;
        }
    }
    if (r >= 0 && !(fi->flag & 0x8000)) r = -2;
done:
    FileClose(fi);
    FileClose(fo);
    return r;
}

int WriteFileWithVerify(int idx)
{
    char name1[10];
    char name2[10];
    char hdr1[14];
    char hdr2[14];
    long total;
    int r;
    int cur;
    int i;
    void *e;

    r = 0;
    cur = GetCurrentFileIndex();
    if (cur < 0) return -104;
    total = 0;
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordValid(FileIO_TypeProbeOrder[i]) != 0)
            total += UpdateFileEntry(cur, FileIO_TypeProbeOrder[i]);
    }
    if (FileIO_GetDiskFreeSpace() < total) return -101;
    FileIO_FormatFileIndex(name1, (unsigned char)idx, GetFileEntryPtr(idx));
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordByFile(idx, FileIO_TypeProbeOrder[i]) != 0) {
            FileIO_ReadHeader(hdr1, name1, FileIO_TypeProbeOrder[i]);
            r = FileIO_OpenDefault(hdr1);
            if (r < 0) return r;
        }
    }
    e = GetFileEntryPtr(cur);
    FileIO_FormatFileIndex(name1, (unsigned char)cur, e);
    FileIO_FormatFileIndex(name2, (unsigned char)idx, e);
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordValid(FileIO_TypeProbeOrder[i]) != 0) {
            FileIO_ReadHeader(hdr1, name1, FileIO_TypeProbeOrder[i]);
            FileIO_ReadHeader(hdr2, name2, FileIO_TypeProbeOrder[i]);
            r = FileIO_CompareFiles(hdr2, hdr1);
            if (r < 0) break;
        }
    }
    return r;
}

int ReadDualFileEx(int idx)
{
    char name1[10];
    char name2[10];
    char hdr1[14];
    char hdr2[14];
    void *eb;
    void *ea;
    int cur;
    int i;
    int r;

    r = 0;
    cur = GetCurrentFileIndex();
    if (cur < 0) return -104;
    ea = GetFileEntryPtr(cur);
    eb = GetFileEntryPtr(idx);
    FileIO_FormatFileIndex(name1, (unsigned char)idx, eb);
    FileIO_FormatFileIndex(name2, 20, eb);
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordByFile(idx, FileIO_TypeProbeOrder[i]) != 0) {
            FileIO_ReadHeader(hdr1, name1, FileIO_TypeProbeOrder[i]);
            FileIO_ReadHeader(hdr2, name2, FileIO_TypeProbeOrder[i]);
            r = FileIO_CopyAndOpen(hdr1, hdr2);
            if (r < 0) return r;
        }
    }
    FileIO_FormatFileIndex(name1, (unsigned char)cur, ea);
    FileIO_FormatFileIndex(name2, (unsigned char)idx, ea);
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordValid(FileIO_TypeProbeOrder[i]) != 0) {
            FileIO_ReadHeader(hdr1, name1, FileIO_TypeProbeOrder[i]);
            FileIO_ReadHeader(hdr2, name2, FileIO_TypeProbeOrder[i]);
            r = FileIO_CopyAndOpen(hdr1, hdr2);
            if (r < 0) return r;
        }
    }
    FileIO_FormatFileIndex(name1, 20, eb);
    FileIO_FormatFileIndex(name2, (unsigned char)cur, eb);
    for (i = 0; i < 10; i++) {
        if (FileIO_CheckRecordByFile(idx, FileIO_TypeProbeOrder[i]) != 0) {
            FileIO_ReadHeader(hdr1, name1, FileIO_TypeProbeOrder[i]);
            FileIO_ReadHeader(hdr2, name2, FileIO_TypeProbeOrder[i]);
            r = FileIO_CopyAndOpen(hdr1, hdr2);
            if (r < 0) return r;
        }
    }
    return r;
}

int FileIO_SaveAllRegions(void)
{
    char name[10];
    char hdr[14];
    int r;
    int cur;
    int i;

    r = 0;
    cur = GetCurrentFileIndex();
    if (cur < 0) return -104;
    FileIO_FormatFileIndex(name, (unsigned char)cur, GetFileEntryPtr(cur));
    for (i = 0; i < 8; i++) {
        if (FileIO_CheckRecordValid(SaveAll_RegionSaveRecs[i].type) != 0) {
            FileIO_ReadHeader(hdr, name, SaveAll_RegionSaveRecs[i].type);
            r = FileIO_OpenDefault(hdr);
            if (r < 0) return r;
        }
    }
    FileIO_ReadHeader(hdr, name, 8);
    FileIO_OpenDefault(hdr);
    FileIO_ReadHeader(hdr, name, 9);
    FileIO_OpenDefault(hdr);
    FileIO_FormatFileIndex(name, (unsigned char)cur, FileIO_GetRecordByType());
    for (i = 0; i < 8; i++) {
        if (FileIO_FormatName_Return(SaveAll_RegionSaveRecs[i].type) != 0) {
            r = SaveAll_RegionSaveRecs[i].fn(name);
            if (r < 0) break;
        }
    }
    if (r < 0) {
        for (i = 0; i < 8; i++) {
            if (FileIO_FormatName_Return(SaveAll_RegionSaveRecs[i].type) != 0) {
                FileIO_ReadHeader(hdr, name, SaveAll_RegionSaveRecs[i].type);
                FileIO_OpenDefault(hdr);
            }
        }
    }
    return r;
}

/* ---- sequencer/seq_event_playback.s: GM reset confirmation and the split-point view ---- */

extern void MainLswPut(long, int, int);
extern long GetTitleOld(void);
extern unsigned char __near GLOBAL_ERROR_CODE;
extern long StsSplitCheck_PtrTable[];

long GMYesFunc(long obj, long evt, long param)
{
    MainLswPut(0xc0, SendEvent(0x580001L, EVT_GET_PARAM, 0), 1);
    PostEvent(-1, EVT_HIDE, 0);
    GLOBAL_ERROR_CODE = 35;
    PostEvent(-1, EVT_INTERRUPT_TITLE, TITLE_MESAGE);
    return 0;
}

long TtMdGm(long obj, long evt, long param)
{
    if (evt == EVT_SHOW && GetTitleOld() == TITLE_MESAGE) {
        SendEvent(-1, EVT_SET_NOT_DRAW_FLAG, 1);
        PostEvent(-1, EVT_SET_NOT_DRAW_FLAG, 0);
        PostEvent(-1, EVT_CHANGE_MODE, NAKA_MODE_MD_NORMAL);
    }
    return 0;
}

long StsSplitCheck(long obj, long evt, long param)
{
    if (evt == EVT_GET_LANGUAGE_PTR) return (long)StsSplitCheck_PtrTable;
    return 0;
}

struct SpPos { int x; int y; };
struct LswStr { long id; int note; int pad; char *buf; };
extern struct SpPos SplitPointFunc_LocalInit;
extern char SplitPointFunc_LocalInit_Strings[];
extern unsigned char Bitmap_SplitPoint_B[];
extern unsigned char Bitmap_SplitPoint_no_split[];
extern unsigned char *SplitPoint_BitmapTable[];
extern char *SplitPoint_NoteNameTable[];
extern void SoundParam_NotifyChange(long, int, int);
extern void DrawBitmapSPFast(struct SpPos *, unsigned char *, int, int);
extern void SetNeedUpdate(int);
extern void UpdateScreen(void);
extern int __cdecl Sprintf_Locked(char *, char *, ...);

long SplitPointFunc(long obj, long evt, long param)
{
    struct SpPos pos;
    unsigned char n;
    unsigned int i;
    struct LswStr *s;

    pos = SplitPointFunc_LocalInit;
    switch (evt) {
    case EVT_DRAW_KEY:
        SoundParam_NotifyChange(0x4180, 0, 1);
        n = (unsigned char)param;
        if (n < 0x24 || n > 0x60) n = 0x3c;
        for (i = 0; i < (unsigned char)(n / 12 - 3); i++) {
            DrawBitmapSPFast(&pos, Bitmap_SplitPoint_B, 0x39, 0x34);
            pos.x += 0x38;
        }
        if (n < 0x60) {
            DrawBitmapSPFast(&pos, SplitPoint_BitmapTable[n % 12], 0x39, 0x34);
            pos.x += 0x38;
            for (i++; i < 5; i++) {
                DrawBitmapSPFast(&pos, Bitmap_SplitPoint_no_split, 0x39, 0x34);
                pos.x += 0x38;
            }
        }
        SetNeedUpdate(1);
        UpdateScreen();
        SetNeedUpdate(0);
        SendEvent(-1, EVT_RESET_INTERRUPT_TIME, 0);
        break;
    case EVT_GET_LSW_STRING:
        s = (struct LswStr *)param;
        Sprintf_Locked(s->buf, SplitPointFunc_LocalInit_Strings, SplitPoint_NoteNameTable[s->note % 12],
                       s->note / 12 - 2);
        ApFuncCall(obj, EVT_DRAW_KEY, (long)((struct LswStr *)param)->note);
        return obj;
    case EVT_GET_LSW_ADDRESS:
        return 0x4181;
    case EVT_GET_LSW_OUTPUT:
    case EVT_GET_LARGE_STEP:
    case EVT_GET_SMALL_STEP:
        return 1;
    }
    return 0;
}

/* ---- ui/ui_mode_handlers.s: effect-mode panel bits, the normal-mode switch reset, the diagnostic timer ---- */

struct FieldMap { long off; unsigned char add; unsigned char n; };
extern struct FieldMap EffectMode_PresetFieldMap[];
extern unsigned char __near PANEL_RECORDS[];
extern unsigned char __near PANEL_PART_RT1[];
extern unsigned char __near PANEL_PART_RT2[];
extern unsigned char __near PANEL_PART_LEFT[];
extern unsigned char __near PANEL_PART_PT4[];
extern unsigned char __near PANEL_PLAY_SETTINGS[];
extern unsigned char __near PANEL_EFFECT_SWITCHES[];
extern unsigned char __near PANEL_TOUCH[];
extern unsigned char __near DIAG_ANIM_STEP;
typedef unsigned char *BytePtr;
extern BytePtr __near ram_8d60;
extern void AddswbWr(int, int, int, int);
extern int CtrlPanel_GetSelectionState(void);

#define EM_XL(a) ((unsigned char *)0x3c2c4 + ((a) - PANEL_RECORDS))

void EffectMode_UpdateBitFlags(void)
{
    unsigned char save[4];
    unsigned char *p[4];
    unsigned char *p4;
    unsigned char *p5;
    unsigned char *src;
    unsigned char *dst;
    struct FieldMap *m;
    unsigned int i;
    unsigned char j;
    unsigned char s6;
    unsigned char s4;
    unsigned char c;

    p[0] = EM_XL(PANEL_PART_RT1 + 4);
    save[0] = *p[0] & 0x20;
    p[1] = EM_XL(PANEL_PART_RT2 + 4);
    save[1] = *p[1] & 0x20;
    p[2] = EM_XL(PANEL_PART_LEFT + 4);
    save[2] = *p[2] & 0x20;
    p[3] = EM_XL(PANEL_PART_PT4 + 4);
    save[3] = *p[3] & 0x20;
    p4 = EM_XL(PANEL_PLAY_SETTINGS);
    s4 = *p4 & 0x3b;
    p5 = EM_XL(PANEL_EFFECT_SWITCHES + 1);
    s6 = *p5 & 0x20;
    src = ram_8d60;
    for (i = 0; (m = &EffectMode_PresetFieldMap[i])->off != 0xff; i++) {
        dst = (unsigned char *)0x3c2c4 + (m->off + m->add);
        for (j = 0; j < m->n; j++) *dst++ = *src++;
    }
    c = *p[0]; c &= ~0x20; *p[0] = c; c |= save[0]; *p[0] = c;
    c = *p[1]; c &= ~0x20; *p[1] = c; c |= save[1]; *p[1] = c;
    c = *p[2]; c &= ~0x20; *p[2] = c; c |= save[2]; *p[2] = c;
    c = *p[3]; c &= ~0x20; *p[3] = c; c |= save[3]; *p[3] = c;
    c = *p4; c &= 0xc4; *p4 = c; c |= s4; *p4 = c;
    c = *p5; c &= ~0x20; *p5 = c; c |= s6; *p5 = c;
}

void EffectMode_RestoreSwbWr_NormalMode(void)
{
    unsigned char *p;

    p = PANEL_PART_RT1;
    *p++ = 0x40;
    *p &= 0x80;
    PANEL_TOUCH[0] &= 0xf0;
    AddswbWr(0, 1, *p, 0x7f);
    AddswbWr(0, 0, 0x40, 0xff);
    AddswbWr(0x93, 0, 0, 0xf);
}

void EffectMode_HandleTimerEvents(void)
{
    if (CtrlPanel_GetSelectionState() != 0) return;
    switch (DIAG_ANIM_STEP) {
    case 0:
        ApPostEvent(NAKA_VIEW_TEST54, EVT_SHOW, 0);
        DIAG_ANIM_STEP += 2;
        break;
    case 0x1e:
        ApPostEvent(NAKA_VIEW_TEST55, EVT_SHOW, 0);
        DIAG_ANIM_STEP += 2;
        break;
    case 0x3c:
        ApPostEvent(NAKA_VIEW_TEST56, EVT_SHOW, 0);
        DIAG_ANIM_STEP += 2;
        break;
    case 0x5a:
        ApPostEvent(NAKA_VIEW_TEST51, EVT_SHOW, 0);
        DIAG_ANIM_STEP += 2;
        break;
    case 0x78:
        ApPostEvent(NAKA_VIEW_TEST52, EVT_SHOW, 0);
        DIAG_ANIM_STEP += 2;
        break;
    case 0x96:
        ApPostEvent(NAKA_VIEW_TEST53, EVT_SHOW, 0);
        DIAG_ANIM_STEP = 220;
        break;
    default:
        DIAG_ANIM_STEP += 2;
        break;
    }
}

/* ---- sequencer/sequencer_ui.s: the lyric editor's line break ---- */

struct LyrCur { int col; int line; };
#define LYR_CUR0 ((struct LyrCur *)0x20e46)
#define LYR_CUR  ((struct LyrCur *)0x20e4a)
#define LYR_INPUT ((char *)0x20e4e)
extern char LYRIC_LINES[];
extern char *__cdecl Strncpy(char *, char *, unsigned int);

char SongEdit_CheckBounds(unsigned char c)
{
    if (c + LYR_CUR->col < 34) {
        Strncpy(LYRIC_LINES + (LYR_CUR->line * 64 + LYR_CUR->col), LYR_INPUT, (unsigned char)(c + 1));
        LYR_CUR->col += c;
        *LYR_INPUT = 0;
        SendEvent(0x6f0027L, EVT_LYRICS_RENEW, 0);
        return 0;
    }
    if (LYR_CUR->line >= 4) return -1;
    LYRIC_LINES[LYR_CUR->line * 64 + LYR_CUR->col] = 0x0d;
    LYR_CUR->col++;
    LYRIC_LINES[LYR_CUR->line * 64 + LYR_CUR->col] = 0;
    LYR_CUR->col++;
    SendEvent(0x6f0027L, EVT_LYRICS_RENEW, 0);
    LYR_CUR0->line++;
    LYR_CUR0->col = 0;
    LYR_CUR->line++;
    LYR_CUR->col = 0;
    Strncpy(LYRIC_LINES + (LYR_CUR->line * 64 + LYR_CUR->col), LYR_INPUT, (unsigned char)(c + 1));
    LYR_CUR->col += c;
    *LYR_INPUT = 0;
    SendEvent(0x6f0027L, EVT_LYRICS_RENEW, 0);
    return 0;
}

/* ---- file_io/single_load.s: the composer single-load source list ---- */

extern long __near ram_81f4;
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SINGLE_LOAD_ALL;
extern long (*CmpSingleLoadSrc_ListProcByMode[])(long, long, long);

long CmpSingleLoadSrcFunc(long obj, long evt, long param)
{
    switch (evt) {
    case EVT_PS_FILE_NAME_BOX_ID:
        ram_81f4 = param;
        ApPostEvent(ram_81f4, EVT_SET_SELECTED_FILE_NUMBER, -1);
        break;
    case EVT_PAINT:
        ApPostEvent(ram_81f4, EVT_SET_SELECTED_FILE_NUMBER, -1);
        CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, evt, param);
        break;
    case EVT_INDEXSW_UP:
    case EVT_INDEXSW_DOWN:
        if (param == 5) {
            ApPostEvent(ram_81f4, EVT_SET_SELECTED_FILE_NUMBER, 1);
            CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, evt, param);
        } else if (param == 6) {
            if (SINGLE_LOAD_ALL == 0) {
                ApPostEvent(ram_81f4, EVT_SET_SELECTED_FILE_NUMBER, 3);
                CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, evt, param);
            } else {
                ApPostEvent(ram_81f4, EVT_SET_SELECTED_FILE_NUMBER, -1);
                CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, evt, param);
            }
        } else if (param == 7) {
            ApPostEvent(ram_81f4, EVT_SET_SELECTED_FILE_NUMBER, -1);
            CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, evt, param);
        } else if (param == 8 && SINGLE_LOAD_ALL == 0) {
            ApPostEvent(ram_81f4, EVT_SET_SELECTED_FILE_NUMBER, -1);
            CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, evt, param);
        } else if (param == 0x28) {
            CmpSingleLoadSrc_ListProcByMode[SINGLE_LOAD_AREA](ram_81f4, evt, param);
        }
        break;
    case EVT_GET_SELECTED_FILE_NUMBER:
        return -1;
    }
    return 0;
}
