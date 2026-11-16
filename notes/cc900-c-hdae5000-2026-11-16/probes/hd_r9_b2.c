/* lane_hd round 9, helper h_big2, form a: seven functions with no calr (survey kind C?), in ROM address order --
   FdList_Clear, DirList_BuildPage, FlsList_BuildPage, LoadSong_Pmt, LoadSong_Sqt, SaveSong_Sqt, HD_WriteStream.
   None calls another, so they share one file without any call becoming calr.
   - A RAM array the ROM loads as `lda xwa,(sym); ld xde,xwa` (or parks in a stack temporary before a later argument
     with calls) is written through a pointer-cast member at offset 0, WRAP(x) below: in run 49 FdList.label (a member
     at offset 0) gave that shape, while a plain array and FdList.rows (offset 14) gave `lda xde,(sym)` / no temp
     (FdList_Clear +114, TitleInfo_Build, LoadSong_Cmp +69).
   - The rows' `ld wa,21; muls/mul xwa,iz` (the constant in the accumulator, the index register as the source): V4.23
     swaps a literal on the left (run 49's `21 * i` gave `ld wa,iz; muls wa,21`), so the constant is written as a
     sizeof here; variants _c ((char)21) and _r (register loop variable) try other spellings.
   - FlsList: `&arr[k]` with an unsigned k as an argument gives the ROM's `ld xbc,sym; add xbc,xwa` (brief).
   - LoadSong_Pmt / _Sqt / SaveSong_Sqt: from LoadSong_Tm (hd_r7_la.c, matched): ResInfo with an unsigned long addr,
     the HD file calls unprototyped, SLOT/HAS integer addresses, CALLV/CALLR table calls.
   - HD_WriteStream: run 49's form a with `if (n <= room) chunk = n; else chunk = room;` (the ROM tests ugt and takes
     n on the fall-through); everything else in run 49's listing already had the ROM's shape.
   cc900-name: DirListBP_c=HDAE5000_DirList_BuildPage
   cc900-name: DirListBP_r=HDAE5000_DirList_BuildPage
   cc900-name: FlsListBP_c=HDAE5000_FlsList_BuildPage
   cc900-name: FlsListBP_r=HDAE5000_FlsList_BuildPage
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, const char *, ...);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern unsigned char *HDAE5000_DirName_Address(unsigned int dir);
extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);
extern int HDAE5000_HD_ReadFile();
extern int HDAE5000_HD_WriteFile();
extern int HDAE5000_HD_AppendFile();

/* an array read as an lvalue member at offset 0 (see the header comment) */
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)

struct FdList { char label[14]; char rows[242]; char line1[20]; char line2[20]; };
extern struct FdList HDAE5000_RAM_FdList;
extern char HDAE5000_Str_Blank12Tab[];
extern char HDAE5000_FdList_RowsTemplate[];

typedef char DirRow[21];
typedef char FlsRow[21];
extern char HDAE5000_RAM_DirListText[];
extern char HDAE5000_RAM_FlsListText[];
extern unsigned int HDAE5000_RAM_DirPageBase;
extern unsigned int HDAE5000_RAM_FlsPageBase;
extern char HDAE5000_Str_Chr2020203A2020[];
extern char HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage[];
/* the formats are pushed as 32-bit constants (pushw hi16 / pushw lo16), as SeparateOutput_Apply's (hd_r4_g3.c) */
#define FMT_DIR ((const char *)0x2e23d2L)   /* HDAE5000_Fmt_3_3d, "%3.3d" */
#define FMT_FLS ((const char *)0x2e2e76L)   /* HDAE5000_Fmt_3_3d_FlsList_BuildPage, "%3.3d" */

struct ResInfo { unsigned long addr; unsigned long size; };
struct SqtHdr { unsigned char pad[199]; unsigned char bank; };
struct SqtBlk { unsigned char pad[78]; unsigned int len[1]; };

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_HdStreamBuffer[0x8000];
extern unsigned char HDAE5000_RAM_RcmStreamState[];
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern long *HDAE5000_RAM_HdStreamSlot;      /* the open write's first-cluster slot */
extern unsigned char HDAE5000_RAM_HdStreamState;

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define HAS(k, d, s) (*(unsigned char *)((unsigned long)&HDAE5000_RAM_DirNames[26 + (k)] + SONG_OFS(d, s)))
/* the workspace's object 0x148 (ws + 0x11fa), function +0x18 (hd_r4_ppa.c PP_Svc16 gave the single load, run 56) */
#define OBJ148_FN6 (((void **)HDAE5000_RAM_MainWorkspacePtr->tab[0x148].fns)[6])

void HDAE5000_FdList_Clear(void)
{
    HDAE5000_MemCopy(HDAE5000_RAM_FdList.label, HDAE5000_Str_Blank12Tab, 14);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_FdList.label);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_PARA_DRAW, -1L);
    HDAE5000_MemCopy(HDAE5000_RAM_FdList.rows, HDAE5000_FdList_RowsTemplate, 0xf1);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FdList.rows));
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_PARA_DRAW, -1L);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE1, EVT_DRAW, 0L);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE2, EVT_DRAW, 0L);
    HDAE5000_MemFill(HDAE5000_RAM_FdList.line1, 0, 20);
    HDAE5000_MemFill(HDAE5000_RAM_FdList.line2, 0, 20);
}

void HDAE5000_DirList_BuildPage(long obj)
{
    char num[22];
    int i;
    HDAE5000_MemFill(HDAE5000_RAM_DirListText, 0, 0x1f9);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText + (int)sizeof(DirRow) * i, HDAE5000_Str_Chr2020203A2020, 21);
        HDAE5000_SPrintf(num, FMT_DIR, i + HDAE5000_RAM_DirPageBase + 1);
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText + (int)sizeof(DirRow) * i, num, 3);
        HDAE5000_MemCopy(&HDAE5000_RAM_DirListText[4] + (int)sizeof(DirRow) * i,
                         HDAE5000_DirName_Address(HDAE5000_RAM_DirPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_DirListText));
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}

void DirListBP_c(long obj)
{
    char num[22];
    int i;
    HDAE5000_MemFill(HDAE5000_RAM_DirListText, 0, 0x1f9);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText + (char)21 * i, HDAE5000_Str_Chr2020203A2020, 21);
        HDAE5000_SPrintf(num, FMT_DIR, i + HDAE5000_RAM_DirPageBase + 1);
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText + (char)21 * i, num, 3);
        HDAE5000_MemCopy(&HDAE5000_RAM_DirListText[4] + (char)21 * i,
                         HDAE5000_DirName_Address(HDAE5000_RAM_DirPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_DirListText));
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}

void DirListBP_r(long obj)
{
    char num[22];
    register int i;
    HDAE5000_MemFill(HDAE5000_RAM_DirListText, 0, 0x1f9);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText + 21 * i, HDAE5000_Str_Chr2020203A2020, 21);
        HDAE5000_SPrintf(num, FMT_DIR, i + HDAE5000_RAM_DirPageBase + 1);
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText + 21 * i, num, 3);
        HDAE5000_MemCopy(&HDAE5000_RAM_DirListText[4] + 21 * i,
                         HDAE5000_DirName_Address(HDAE5000_RAM_DirPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_DirListText));
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}

void HDAE5000_FlsList_BuildPage(void)
{
    char num[22];
    unsigned int i;
    HDAE5000_MemFill(HDAE5000_RAM_FlsListText, 0, 0x781);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[sizeof(FlsRow) * i],
                         HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage, 21);
        HDAE5000_SPrintf(num, FMT_FLS, HDAE5000_RAM_FlsPageBase + i + 1);
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[sizeof(FlsRow) * i], num, HDAE5000_StrLen(num));
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[sizeof(FlsRow) * i + 4],
                         HDAE5000_FlsRecord_Address(HDAE5000_RAM_FlsPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FlsListText));
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_PARA_DRAW, -1L);
}

void FlsListBP_c(void)
{
    char num[22];
    unsigned int i;
    HDAE5000_MemFill(HDAE5000_RAM_FlsListText, 0, 0x781);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[(unsigned char)21 * i],
                         HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage, 21);
        HDAE5000_SPrintf(num, FMT_FLS, HDAE5000_RAM_FlsPageBase + i + 1);
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[(unsigned char)21 * i], num, HDAE5000_StrLen(num));
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[(unsigned char)21 * i + 4],
                         HDAE5000_FlsRecord_Address(HDAE5000_RAM_FlsPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FlsListText));
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_PARA_DRAW, -1L);
}

void FlsListBP_r(void)
{
    char num[22];
    register unsigned int i;
    HDAE5000_MemFill(HDAE5000_RAM_FlsListText, 0, 0x781);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[21 * i], HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage, 21);
        HDAE5000_SPrintf(num, FMT_FLS, HDAE5000_RAM_FlsPageBase + i + 1);
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[21 * i], num, HDAE5000_StrLen(num));
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[21 * i + 4],
                         HDAE5000_FlsRecord_Address(HDAE5000_RAM_FlsPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FlsListText));
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_PARA_DRAW, -1L);
}

/* part 1 (PMT): a 16-byte header first; header byte 15 == 8 marks the old 0x1eb0-byte layout, which is loaded and
   then given the new mark 0x50 and the header copied over the loaded data's start */
int HDAE5000_LoadSong_Pmt(unsigned int dir, unsigned int song)
{
    int ret = 0;
    unsigned char hdr[16];
    struct ResInfo info;
    int old = 0;

    if (SLOT(1, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(2, (char *)&info);
        ret = HDAE5000_HD_ReadFile(hdr, 0x10L, &SLOT(1, dir, song));
        if (hdr[15] == 8) {
            old = 1;
            info.size = 0x1eb0L;
        }
        CALLV(HAMA->PrePmLoad)();
        ret = HDAE5000_HD_ReadFile(info.addr, info.size, &SLOT(1, dir, song));
        if (old == 1) {
            hdr[15] = 0x50;
            HDAE5000_MemCopy((unsigned char *)info.addr, hdr, 0x10);
        }
        CALLV(HAMA->PostPmLoad)(ret);
    }
    return ret;
}

/* part 2 (SQT): a 0x5000-byte read into the stream buffer gives the length word of the current bank (header byte 199
   selects a 2048-byte bank; the word at +78 of it, in 16-byte units), added to resource 3's size */
int HDAE5000_LoadSong_Sqt(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info4;
    struct ResInfo info3;
    unsigned long size;

    if (SLOT(2, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(3, (char *)&info3);
        CALLV(HAMA->GetResouceInfo)(4, (char *)&info4);
        if (HDAE5000_HD_ReadFile(WRAP(HDAE5000_RAM_HdStreamBuffer), 0x5000L, &SLOT(2, dir, song)) == -1)
            return -1;
        size = ((struct SqtBlk *)((unsigned int *)HDAE5000_RAM_HdStreamBuffer
               + (((struct SqtHdr *)HDAE5000_RAM_HdStreamBuffer)->bank << 10)))->len[0];
        size <<= 4;
        size += info3.size;
        CALLV(HAMA->SeqLoadPre)();
        ret = HDAE5000_HD_ReadFile(info3.addr, size, &SLOT(2, dir, song));
        CALLV(HAMA->SeqLoadPost)(ret);
        CALLV(OBJ148_FN6)(-1L, EVT_ACTIVATE_STATE, 0L);
    }
    return ret;
}

/* ret is never assigned in the ROM: the WriteFile result is only compared, and SeqSavePost / the return read the
   uninitialised slot */
int HDAE5000_SaveSong_Sqt(unsigned int dir, unsigned int song)
{
    int ret;
    unsigned long size;
    struct ResInfo info4;
    struct ResInfo info3;

    CALLV(HAMA->GetResouceInfo)(3, (char *)&info3);
    CALLV(HAMA->GetResouceInfo)(4, (char *)&info4);
    size = info3.size + CALLR(unsigned long, HAMA->SeqSavePre)();
    if (HDAE5000_HD_WriteFile(info3.addr, size, &SLOT(2, dir, song)) != -1)
        HAS(2, dir, song) = 1;
    CALLV(HAMA->SeqSavePost)(ret);
    return ret;
}

int HDAE5000_HD_WriteStream(unsigned char *src, unsigned long n)
{
    unsigned long room;
    int r;
    unsigned long chunk;
    r = 0;
    switch (HDAE5000_RAM_HdStreamState) {
    case 1:
    case 2:
        if (n == 0)
            return -1;
        break;
    default:
        return -1;
    }
    do {
        room = HDAE5000_RAM_RcmStreamState - HDAE5000_RAM_HdStreamFill;
        if (n <= room)
            chunk = n;
        else
            chunk = room;
        if (chunk > 0xffff) {
            HDAE5000_MemCopy(HDAE5000_RAM_HdStreamFill, src, 0xffff);
            HDAE5000_MemCopy(HDAE5000_RAM_HdStreamFill + 0xffff, src + 0xffff, (unsigned int)(chunk - 0xffff));
        } else {
            HDAE5000_MemCopy(HDAE5000_RAM_HdStreamFill, src, (unsigned int)chunk);
        }
        src += chunk;
        HDAE5000_RAM_HdStreamFill += chunk;
        room -= chunk;
        if (room == 0) {
            if (HDAE5000_RAM_HdStreamState == 1) {
                r = HDAE5000_HD_WriteFile(HDAE5000_RAM_HdStreamBuffer, 0x8000L, HDAE5000_RAM_HdStreamSlot);
                HDAE5000_RAM_HdStreamState = 2;
            } else {
                r = HDAE5000_HD_AppendFile(HDAE5000_RAM_HdStreamBuffer, 0x8000L, HDAE5000_RAM_HdStreamSlot);
            }
            if (r != 0)
                break;
            HDAE5000_RAM_HdStreamFill = HDAE5000_RAM_HdStreamBuffer;
        }
        n -= chunk;
    } while (n != 0);
    return r;
}
