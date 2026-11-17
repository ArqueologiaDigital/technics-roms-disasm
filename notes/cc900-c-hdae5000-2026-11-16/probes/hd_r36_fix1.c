/* hd_r36_fix1.c (helper h_fix1, lane_hd round 36): three functions of the HD-AE5000 v2.06i that run
   2026-11-16-119-hd-r30 compiled almost to the ROM's bytes, corrected, each with variants (cc900-name aliases).
   In ROM address order: HDAE5000_FdList_Scan (hdae5000_hd_driver.s), HDAE5000_SongScreen_Refresh (same file),
   HDAE5000_ErrMsgTimerCatchLBN (hdae5000_ui_display.s).  The C comes from hd_r27_b_drvb.c and from
   hdae5000/cc900/hdae5000_drv_screens4_ui_display.c.

   FdList_Scan: what run 119 showed against the ROM (the offset +33 is only the jrl's distance):
   - n: the ROM keeps the song number in HL and compares a copy (WA); run 119's unsigned n went to DE.  Run 95's
     `int n` stayed in HL (but compared HL itself: plain assignment).  Here: int n, assigned in the condition.
   - the "present" flag: the ROM adds 0x100 to the 16-bit index and indexes the object's start; V4.23 folded the
     member's offset into the address.  Here: the object as a flat char array of unknown length, index n + 0x100.
   - the row address: the ROM has product, then the address with 17 folded in, then the sign extension and the add;
     run 119 kept the 3 in the index (form b) or loaded the address first (form a).  Here: &flat[17] + n * 12.
   - the loop: the ROM extends the 16-bit index, adds the member offset in 32 bits and adds the object's address as
     an immediate, the shape V4.23 gives for an unsigned index into an array of UNKNOWN length (built example:
     HDAE5000_RAM_FdLyricHasMid[i] in hdae5000/cc900/hdae5000_fdlyric.c); with the sized members V4.23 used a
     16-bit add and an indexed operand.  Here: the flat array again.
   Variants: HDAE5000_FdList_Scan = flat array, the offsets written in the index ((unsigned long) index + offset in
   the loop); FdScan_p = the members as pointers into the flat array (flat + offset)[index]; FdScan_c = as the
   first, but n by plain assignment and compared through a cast, and the loop as in _p; FdScan_d = n declared
   after i, the row address as int + pointer.

   SongScreen_Refresh: the only departures are the three row addresses.  The ROM loads 30 into WA, multiplies by
   the loop variable's register, then loads the text address (+2, +0, +3 folded in), extends and adds; run 119
   kept 30 in DE (local k) and loaded the address first (integer-sum spelling).  The address is now pointer
   arithmetic (&text[K] + product: form b of FdList_Scan gave the ROM's order for that).  The constant on the left
   of a register multiply is the open idiom of DirList_BuildPage (hd_r13_nb.c lists what was tried); four untried
   spellings: SongScrRefresh_c = an enum constant; SongScr_k = a file-scope static const int; SongScr_l = a long
   product narrowed, (int)(30L * i); SongScr_q = a comma expression (0, 30), and the sum as int + pointer.

   ErrMsgTimerCatchLBN: unchanged from the built file; it is MATCH there (staged_v423.tsv, run 117).  Run 119 held
   only the ported trees' copies; its body needs HDAE5000_Lbn_ShowEntry in the module list (the ROM's calr), below.

   cc900-name: FdScan_p=HDAE5000_FdList_Scan
   cc900-name: FdScan_c=HDAE5000_FdList_Scan
   cc900-name: FdScan_d=HDAE5000_FdList_Scan
   cc900-name: SongScrRefresh_c=HDAE5000_SongScreen_Refresh
   cc900-name: SongScr_k=HDAE5000_SongScreen_Refresh
   cc900-name: SongScr_l=HDAE5000_SongScreen_Refresh
   cc900-name: SongScr_q=HDAE5000_SongScreen_Refresh
   cc900-options: -Xr
   cc900-module: HDAE5000_FdList_Clear HDAE5000_FdName_SongNumber HDAE5000_ShowErrorMessageTitle
   cc900-module: HDAE5000_PartList_Build HDAE5000_Lbn_ShowEntry
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

/* ---- library (stack arguments, caller pops) ---- */
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern char *__cdecl HDAE5000_StrNCat(char *, char *, int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

/* ---- this module (calr) ---- */
extern void HDAE5000_FdList_Clear(void);
extern int HDAE5000_FdName_SongNumber(char *name);
extern void HDAE5000_ShowErrorMessageTitle(int code);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);
extern int HDAE5000_Lbn_ShowEntry(unsigned int dir, unsigned int song, unsigned int pos, int draw);

/* ---- other modules (call) ---- */
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern char *HDAE5000_DirName_Address(unsigned int dir);
extern unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song);

/* ---- RAM ---- */
struct FdList { char label[14]; char rows[242]; char line1[20]; char line2[20]; };
extern struct FdList HDAE5000_RAM_FdList;
/* the same object (0x22aa9c) as a flat char array of unknown length: label 0, rows 14 (20 x 12), flags 0x100 and
   0x114 */
extern char ram_22aa9c[];
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern char HDAE5000_RAM_SongScreenTitle[];
extern char HDAE5000_RAM_SongListText[];

/* ---- ROM ---- */
extern char HDAE5000_Str_AllFilesPattern[];
extern char HDAE5000_Str_DIRECTORY[];
extern char ram_2e2512[];   /* HDAE5000_Str_Chr3A_SongScreen_Refresh */
extern char HDAE5000_Str_Blank0Tab[];
extern char HDAE5000_Str_Chr3A2020202020[];
extern char HDAE5000_Str_TLBN[];
extern char ram_2e250c[];   /* HDAE5000_Fmt_2_2d_SongScreen_Refresh, "%2.2d" */
extern char ram_2e2534[];   /* HDAE5000_Fmt_2_2d_SongScreen_Refresh_2 */
extern unsigned long ram_2e24e8[];   /* HDAE5000_SongScreen_Refresh_ObjIds */
extern unsigned long ram_2e24f0[];   /* HDAE5000_SongScreen_Refresh_ObjIds_2 */
extern unsigned long ram_2e24f8[];   /* HDAE5000_SongScreen_Refresh_ObjIds_3 */

/* an array read as an lvalue member at offset 0: `lda xwa,(sym); ld xde,xwa` (hd_r9_b2.c, TitleInfo_Build) */
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)

/* the main CPU's FAT driver's find block: the name at +6 */
struct FindBlk { char head[6]; char name[260]; };

/* FdScan_p: the members as pointers into the flat array */
#define FD_ROWS (ram_22aa9c + 14)
#define FD_PRESENT (ram_22aa9c + 0x100)
#define FD_SEL (ram_22aa9c + 0x114)

/* the song list's row length, for SongScreen_Refresh's variants */
enum { SONG_ROW = 30 };
static const int song_row_len = 30;

/* ------------------------------------------------------------------------------------------------------------- */

/* flat array, offsets in the index; int n assigned in its condition */
int HDAE5000_FdList_Scan(void)
{
    struct FindBlk blk;
    int ret;
    char *label;
    long h;
    int n;
    unsigned int i;

    ret = 0;
    switch (CALLR(unsigned char, HAMA->GetMediaType)()) {
    case 2:
    case 3:
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD, EVT_SHOW, -1L);
        HDAE5000_FdList_Clear();
        if ((label = CALLR(char *, HAMA->GetVolumeLabel)()) != 0)
            HDAE5000_MemCopy(HDAE5000_RAM_FdList.label, label, HDAE5000_StrLen(label));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_FdList.label);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_PARA_DRAW, -1L);
        if ((h = CALLR(long, HAMA->findfirst)((long)HDAE5000_Str_AllFilesPattern, (char *)&blk)) >= 0) {
            if ((n = HDAE5000_FdName_SongNumber(blk.name)) != -1) {
                ram_22aa9c[n + 0x100] = 1;
                HDAE5000_MemCopy(&ram_22aa9c[17] + n * 12, &blk.name[2], 6);
            }
            while (CALLR(int, HAMA->findnext)(h, (char *)&blk) == 0) {
                if ((n = HDAE5000_FdName_SongNumber(blk.name)) != -1) {
                    ram_22aa9c[n + 0x100] = 1;
                    HDAE5000_MemCopy(&ram_22aa9c[17] + n * 12, &blk.name[2], 6);
                }
            }
            CALLV(HAMA->findclose)(h);
        }
        for (i = 0; i < 20; i++) {
            ram_22aa9c[(unsigned long)(i * 12 + 10) + 14] = ' ';
            if (ram_22aa9c[(unsigned long)i + 0x114] == 1)
                ram_22aa9c[(unsigned long)(i * 12 + 10) + 14] = '*';
        }
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FdList.rows));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE1, EVT_DRAW, 0L);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE2, EVT_DRAW, 0L);
        break;
    default:
        HDAE5000_ShowErrorMessageTitle(2);
        ret = -1;
    }
    return ret;
}

/* the members as pointers into the flat array: (flat + offset)[index] */
int FdScan_p(void)
{
    struct FindBlk blk;
    int ret;
    char *label;
    long h;
    int n;
    unsigned int i;

    ret = 0;
    switch (CALLR(unsigned char, HAMA->GetMediaType)()) {
    case 2:
    case 3:
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD, EVT_SHOW, -1L);
        HDAE5000_FdList_Clear();
        if ((label = CALLR(char *, HAMA->GetVolumeLabel)()) != 0)
            HDAE5000_MemCopy(HDAE5000_RAM_FdList.label, label, HDAE5000_StrLen(label));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_FdList.label);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_PARA_DRAW, -1L);
        if ((h = CALLR(long, HAMA->findfirst)((long)HDAE5000_Str_AllFilesPattern, (char *)&blk)) >= 0) {
            if ((n = HDAE5000_FdName_SongNumber(blk.name)) != -1) {
                FD_PRESENT[n] = 1;
                HDAE5000_MemCopy(FD_ROWS + 3 + n * 12, &blk.name[2], 6);
            }
            while (CALLR(int, HAMA->findnext)(h, (char *)&blk) == 0) {
                if ((n = HDAE5000_FdName_SongNumber(blk.name)) != -1) {
                    FD_PRESENT[n] = 1;
                    HDAE5000_MemCopy(FD_ROWS + 3 + n * 12, &blk.name[2], 6);
                }
            }
            CALLV(HAMA->findclose)(h);
        }
        for (i = 0; i < 20; i++) {
            FD_ROWS[i * 12 + 10] = ' ';
            if (FD_SEL[i] == 1)
                FD_ROWS[i * 12 + 10] = '*';
        }
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FdList.rows));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE1, EVT_DRAW, 0L);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE2, EVT_DRAW, 0L);
        break;
    default:
        HDAE5000_ShowErrorMessageTitle(2);
        ret = -1;
    }
    return ret;
}

/* n by plain assignment (run 95: HL), compared through a cast (a converted result is reloaded); flat array in
   the name pass, pointer members in the loop */
int FdScan_c(void)
{
    struct FindBlk blk;
    int ret;
    char *label;
    long h;
    int n;
    unsigned int i;

    ret = 0;
    switch (CALLR(unsigned char, HAMA->GetMediaType)()) {
    case 2:
    case 3:
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD, EVT_SHOW, -1L);
        HDAE5000_FdList_Clear();
        if ((label = CALLR(char *, HAMA->GetVolumeLabel)()) != 0)
            HDAE5000_MemCopy(HDAE5000_RAM_FdList.label, label, HDAE5000_StrLen(label));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_FdList.label);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_PARA_DRAW, -1L);
        if ((h = CALLR(long, HAMA->findfirst)((long)HDAE5000_Str_AllFilesPattern, (char *)&blk)) >= 0) {
            n = HDAE5000_FdName_SongNumber(blk.name);
            if ((unsigned int)n != 0xffff) {
                ram_22aa9c[n + 0x100] = 1;
                HDAE5000_MemCopy(&ram_22aa9c[17] + n * 12, &blk.name[2], 6);
            }
            while (CALLR(int, HAMA->findnext)(h, (char *)&blk) == 0) {
                n = HDAE5000_FdName_SongNumber(blk.name);
                if ((unsigned int)n != 0xffff) {
                    ram_22aa9c[n + 0x100] = 1;
                    HDAE5000_MemCopy(&ram_22aa9c[17] + n * 12, &blk.name[2], 6);
                }
            }
            CALLV(HAMA->findclose)(h);
        }
        for (i = 0; i < 20; i++) {
            FD_ROWS[i * 12 + 10] = ' ';
            if (FD_SEL[i] == 1)
                FD_ROWS[i * 12 + 10] = '*';
        }
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FdList.rows));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE1, EVT_DRAW, 0L);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE2, EVT_DRAW, 0L);
        break;
    default:
        HDAE5000_ShowErrorMessageTitle(2);
        ret = -1;
    }
    return ret;
}

/* n declared after i; the row address as int + pointer; the rest as the first form */
int FdScan_d(void)
{
    struct FindBlk blk;
    int ret;
    char *label;
    long h;
    unsigned int i;
    int n;

    ret = 0;
    switch (CALLR(unsigned char, HAMA->GetMediaType)()) {
    case 2:
    case 3:
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD, EVT_SHOW, -1L);
        HDAE5000_FdList_Clear();
        if ((label = CALLR(char *, HAMA->GetVolumeLabel)()) != 0)
            HDAE5000_MemCopy(HDAE5000_RAM_FdList.label, label, HDAE5000_StrLen(label));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_FdList.label);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_PARA_DRAW, -1L);
        if ((h = CALLR(long, HAMA->findfirst)((long)HDAE5000_Str_AllFilesPattern, (char *)&blk)) >= 0) {
            if ((n = HDAE5000_FdName_SongNumber(blk.name)) != -1) {
                ram_22aa9c[n + 0x100] = 1;
                HDAE5000_MemCopy(n * 12 + &ram_22aa9c[17], &blk.name[2], 6);
            }
            while (CALLR(int, HAMA->findnext)(h, (char *)&blk) == 0) {
                if ((n = HDAE5000_FdName_SongNumber(blk.name)) != -1) {
                    ram_22aa9c[n + 0x100] = 1;
                    HDAE5000_MemCopy(n * 12 + &ram_22aa9c[17], &blk.name[2], 6);
                }
            }
            CALLV(HAMA->findclose)(h);
        }
        for (i = 0; i < 20; i++) {
            ram_22aa9c[(unsigned long)(i * 12 + 10) + 14] = ' ';
            if (ram_22aa9c[(unsigned long)i + 0x114] == 1)
                ram_22aa9c[(unsigned long)(i * 12 + 10) + 14] = '*';
        }
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FdList.rows));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE1, EVT_DRAW, 0L);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE2, EVT_DRAW, 0L);
        break;
    default:
        HDAE5000_ShowErrorMessageTitle(2);
        ret = -1;
    }
    return ret;
}

/* ------------------------------------------------------------------------------------------------------------- */

/* the row length as an enum constant; the row address as pointer + product */
void SongScrRefresh_c(unsigned char page, unsigned char skip)
{
    char buf[22];
    int i;
    unsigned int m;
    const void *rec;

    if (skip == 0) {
        HDAE5000_MemFill(HDAE5000_RAM_SongScreenTitle, 0, 32);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_DIRECTORY);
        HDAE5000_SPrintf(buf, ram_2e250c, HDAE5000_RAM_CurDir + 1);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, buf);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, ram_2e2512);
        HDAE5000_StrNCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_DirName_Address(HDAE5000_RAM_CurDir), 16);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_Blank0Tab);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24e8[page], EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_SongScreenTitle);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24e8[page], EVT_PARA_DRAW, -1L);
    }
    if (skip == 0) {
        for (i = 0; i < 16; i++) {
            HDAE5000_MemCopy(&HDAE5000_RAM_SongListText[2] + SONG_ROW * i, HDAE5000_Str_Chr3A2020202020, 28);
            HDAE5000_SPrintf(buf, ram_2e2534, i + 1);
            HDAE5000_MemCopy(&HDAE5000_RAM_SongListText[0] + SONG_ROW * i, buf, 2);
            rec = HDAE5000_SongRecord_Address(HDAE5000_RAM_CurDir, i);
            HDAE5000_MemCopy(&HDAE5000_RAM_SongListText[3] + SONG_ROW * i, rec, 26);
        }
        CALLV(ROOT->ApPostEvent)((long)ram_2e24f0[page], EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_SongListText);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24f0[page], EVT_PARA_DRAW, -1L);
    }
    if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
        HDAE5000_PartList_Build(ram_2e24f8[page], HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, m);
    else
        HDAE5000_PartList_Build(ram_2e24f8[page], 0xffff, 0xffff, 0xffff);
}

/* the row length as a file-scope static const int */
void SongScr_k(unsigned char page, unsigned char skip)
{
    char buf[22];
    int i;
    unsigned int m;
    const void *rec;

    if (skip == 0) {
        HDAE5000_MemFill(HDAE5000_RAM_SongScreenTitle, 0, 32);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_DIRECTORY);
        HDAE5000_SPrintf(buf, ram_2e250c, HDAE5000_RAM_CurDir + 1);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, buf);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, ram_2e2512);
        HDAE5000_StrNCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_DirName_Address(HDAE5000_RAM_CurDir), 16);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_Blank0Tab);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24e8[page], EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_SongScreenTitle);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24e8[page], EVT_PARA_DRAW, -1L);
    }
    if (skip == 0) {
        for (i = 0; i < 16; i++) {
            HDAE5000_MemCopy(&HDAE5000_RAM_SongListText[2] + song_row_len * i, HDAE5000_Str_Chr3A2020202020, 28);
            HDAE5000_SPrintf(buf, ram_2e2534, i + 1);
            HDAE5000_MemCopy(&HDAE5000_RAM_SongListText[0] + song_row_len * i, buf, 2);
            rec = HDAE5000_SongRecord_Address(HDAE5000_RAM_CurDir, i);
            HDAE5000_MemCopy(&HDAE5000_RAM_SongListText[3] + song_row_len * i, rec, 26);
        }
        CALLV(ROOT->ApPostEvent)((long)ram_2e24f0[page], EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_SongListText);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24f0[page], EVT_PARA_DRAW, -1L);
    }
    if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
        HDAE5000_PartList_Build(ram_2e24f8[page], HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, m);
    else
        HDAE5000_PartList_Build(ram_2e24f8[page], 0xffff, 0xffff, 0xffff);
}

/* a long product narrowed to int */
void SongScr_l(unsigned char page, unsigned char skip)
{
    char buf[22];
    int i;
    unsigned int m;
    const void *rec;

    if (skip == 0) {
        HDAE5000_MemFill(HDAE5000_RAM_SongScreenTitle, 0, 32);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_DIRECTORY);
        HDAE5000_SPrintf(buf, ram_2e250c, HDAE5000_RAM_CurDir + 1);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, buf);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, ram_2e2512);
        HDAE5000_StrNCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_DirName_Address(HDAE5000_RAM_CurDir), 16);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_Blank0Tab);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24e8[page], EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_SongScreenTitle);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24e8[page], EVT_PARA_DRAW, -1L);
    }
    if (skip == 0) {
        for (i = 0; i < 16; i++) {
            HDAE5000_MemCopy(&HDAE5000_RAM_SongListText[2] + (int)(30L * i), HDAE5000_Str_Chr3A2020202020, 28);
            HDAE5000_SPrintf(buf, ram_2e2534, i + 1);
            HDAE5000_MemCopy(&HDAE5000_RAM_SongListText[0] + (int)(30L * i), buf, 2);
            rec = HDAE5000_SongRecord_Address(HDAE5000_RAM_CurDir, i);
            HDAE5000_MemCopy(&HDAE5000_RAM_SongListText[3] + (int)(30L * i), rec, 26);
        }
        CALLV(ROOT->ApPostEvent)((long)ram_2e24f0[page], EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_SongListText);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24f0[page], EVT_PARA_DRAW, -1L);
    }
    if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
        HDAE5000_PartList_Build(ram_2e24f8[page], HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, m);
    else
        HDAE5000_PartList_Build(ram_2e24f8[page], 0xffff, 0xffff, 0xffff);
}

/* the row length as the value of a comma expression; the row address as product + pointer */
void SongScr_q(unsigned char page, unsigned char skip)
{
    char buf[22];
    int i;
    unsigned int m;
    const void *rec;

    if (skip == 0) {
        HDAE5000_MemFill(HDAE5000_RAM_SongScreenTitle, 0, 32);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_DIRECTORY);
        HDAE5000_SPrintf(buf, ram_2e250c, HDAE5000_RAM_CurDir + 1);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, buf);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, ram_2e2512);
        HDAE5000_StrNCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_DirName_Address(HDAE5000_RAM_CurDir), 16);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_Blank0Tab);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24e8[page], EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_SongScreenTitle);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24e8[page], EVT_PARA_DRAW, -1L);
    }
    if (skip == 0) {
        for (i = 0; i < 16; i++) {
            HDAE5000_MemCopy((0, 30) * i + &HDAE5000_RAM_SongListText[2], HDAE5000_Str_Chr3A2020202020, 28);
            HDAE5000_SPrintf(buf, ram_2e2534, i + 1);
            HDAE5000_MemCopy((0, 30) * i + &HDAE5000_RAM_SongListText[0], buf, 2);
            rec = HDAE5000_SongRecord_Address(HDAE5000_RAM_CurDir, i);
            HDAE5000_MemCopy((0, 30) * i + &HDAE5000_RAM_SongListText[3], rec, 26);
        }
        CALLV(ROOT->ApPostEvent)((long)ram_2e24f0[page], EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_SongListText);
        CALLV(ROOT->ApPostEvent)((long)ram_2e24f0[page], EVT_PARA_DRAW, -1L);
    }
    if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
        HDAE5000_PartList_Build(ram_2e24f8[page], HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, m);
    else
        HDAE5000_PartList_Build(ram_2e24f8[page], 0xffff, 0xffff, 0xffff);
}

/* ------------------------------------------------------------------------------------------------------------- */

/* unchanged from hdae5000/cc900/hdae5000_drv_screens4_ui_display.c (MATCH there) */
long HDAE5000_ErrMsgTimerCatchLBN(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_TLBN);
        return 0;
    case EVT_HDAE_TIMER_BACK:
        CALLV(ROOT->PostEvent)(arg, EVT_SHOW, 0L);
        HDAE5000_Lbn_ShowEntry(0, 0, 6, 1);
        return 0;
    }
}
