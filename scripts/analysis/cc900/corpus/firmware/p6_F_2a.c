/* lane_p6 helper F, round 2, form a: refinements of round-1 misses outside module 266.
   FileIO_CompareFiles (module 267): while loop (round 1 form b's layout), r = 0 before the path copies, scalars
   in ascending stack order, the 0x69800 buffer pointer kept in its stack slot (volatile).
   CmpSingleLoadSrcFunc: the event `register` (the ROM keeps it in XIZ, the parameter in memory).
   SongEdit_CheckBounds: the cursor through a pointer (the ROM's lda XIX), the input buffer a symbol
   (pushed as two words).  SplitPointFunc: the format string under a short name.
   __near: 16-bit absolute operand; plain: 24-bit (or a ROM label).  One declarator per __near declaration. */

/* cc900-name: SplitFmt=SplitPointFunc_LocalInit_Strings */

#define EVT_PAINT                     0x1c0000bL
#define EVT_INDEXSW_UP                0x1c00017L
#define EVT_INDEXSW_DOWN              0x1c00018L
#define EVT_LYRICS_RENEW              0x1c7000bL
#define EVT_GET_LARGE_STEP            0x1e0003eL
#define EVT_GET_SMALL_STEP            0x1e0003fL
#define EVT_GET_LSW_ADDRESS           0x1e00040L
#define EVT_GET_LSW_OUTPUT            0x1e00041L
#define EVT_GET_LSW_STRING            0x1e00042L
#define EVT_RESET_INTERRUPT_TIME      0x1e00078L
#define EVT_DRAW_KEY                  0x1e30002L
#define EVT_SET_SELECTED_FILE_NUMBER  0x1e50002L
#define EVT_GET_SELECTED_FILE_NUMBER  0x1e50003L
#define EVT_PS_FILE_NAME_BOX_ID       0x1e50004L

extern long SendEvent(long, long, long);
extern long ApPostEvent(long, long, long);
extern long ApFuncCall(long, long, long);

/* ---- demo/file_demo_proc.s (module 267) ---- */

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

int FileIO_CompareFiles(char *dst, char *src)
{
    struct Path16 pb;
    struct Path16 pa;
    FileP fi;
    FileP fo;
    int r;
    char *volatile buf;
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
    while ((n = FileRead(buf, 1, 0x1000, fi)) > 0) {
        if (FileWrite(buf, 1, n, fo) != n) {
            if ((ram_7f44->flag & 0x7fff) == 0x1f) r = -11;
            else r = -3;
            break;
        }
    }
    if (r >= 0 && !(fi->flag & 0x8000)) r = -2;
    FileClose(fi);
    FileClose(fo);
    return r;
}

/* ---- file_io/single_load.s (module 269) ---- */

extern long __near ram_81f4;
extern unsigned char __near SINGLE_LOAD_AREA;
extern unsigned char __near SINGLE_LOAD_ALL;
extern long (*CmpSingleLoadSrc_ListProcByMode[])(long, long, long);

long CmpSingleLoadSrcFunc(long obj, register long evt, long param)
{
    switch (evt) {
    case EVT_PS_FILE_NAME_BOX_ID:
        ApPostEvent(ram_81f4 = param, EVT_SET_SELECTED_FILE_NUMBER, -1);
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

/* ---- sequencer/sequencer_ui.s (module 232) ---- */

struct LyrCur { int col; int line; };
extern char LYRIC_LINES[];
extern char ram_20e4e[];
extern char *__cdecl Strncpy(char *, char *, unsigned int);

char SongEdit_CheckBounds(unsigned char c)
{
    struct LyrCur *k;
    struct LyrCur *k0;

    k = (struct LyrCur *)0x20e4a;
    if (c + k->col < 34) {
        Strncpy(LYRIC_LINES + (k->line * 64 + k->col), ram_20e4e, (unsigned char)(c + 1));
        k = (struct LyrCur *)0x20e4a;
        k->col += c;
        ram_20e4e[0] = 0;
        SendEvent(0x6f0027L, EVT_LYRICS_RENEW, 0);
        return 0;
    }
    if (k->line >= 4) return -1;
    LYRIC_LINES[k->line * 64 + k->col] = 0x0d;
    k->col++;
    LYRIC_LINES[k->line * 64 + k->col] = 0;
    k->col++;
    SendEvent(0x6f0027L, EVT_LYRICS_RENEW, 0);
    k0 = (struct LyrCur *)0x20e46;
    k0->line++;
    k0->col = 0;
    k = (struct LyrCur *)0x20e4a;
    k->line++;
    k->col = 0;
    Strncpy(LYRIC_LINES + (k->line * 64 + k->col), ram_20e4e, (unsigned char)(c + 1));
    k = (struct LyrCur *)0x20e4a;
    k->col += c;
    ram_20e4e[0] = 0;
    SendEvent(0x6f0027L, EVT_LYRICS_RENEW, 0);
    return 0;
}

/* ---- sequencer/seq_event_playback.s (module 264) ---- */

struct SpPos { int x; int y; };
struct LswStr { long id; int note; int pad; char *buf; };
extern struct SpPos SplitPointFunc_LocalInit;
extern char SplitFmt[];
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
        Sprintf_Locked(s->buf, SplitFmt, SplitPoint_NoteNameTable[s->note % 12], s->note / 12 - 2);
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
