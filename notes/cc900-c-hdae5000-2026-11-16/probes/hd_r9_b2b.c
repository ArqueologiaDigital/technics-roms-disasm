/* lane_hd round 9, helper h_big2, form b: second spellings of hd_r9_b2.c's FdList_Clear, DirList_BuildPage,
   FlsList_BuildPage and LoadSong_Sqt (ROM address order).
   - The arrays the ROM treats as computed arguments (`lda xwa,(sym); ld xde,xwa`, or a stack temporary before an
     argument with calls) are written `&x[0]` here instead of form a's pointer-cast member WRAP(x).
   - DirList: the text as a 2D array [24][21], rows `x[i]` / `&x[i][4]`, with a register loop variable (in case an
     explicit register variable is the one V4.23 multiplies in place: `ld wa,21; muls xwa,iz`).
   - FlsList: `&x[sizeof(FlsRow) * i]` as in form a, with the last argument `&x[0]`.
   - LoadSong_Sqt: the bank's length word as `*(p + (bank << 10) + 39)` instead of a member at +78. */
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, const char *, ...);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern unsigned char *HDAE5000_DirName_Address(unsigned int dir);
extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);
extern int HDAE5000_HD_ReadFile();

struct FdList { char label[14]; char rows[242]; char line1[20]; char line2[20]; };
extern struct FdList HDAE5000_RAM_FdList;
extern char HDAE5000_Str_Blank12Tab[];
extern char HDAE5000_FdList_RowsTemplate[];

typedef char FlsRow[21];
extern char HDAE5000_RAM_DirListText[24][21];
extern char HDAE5000_RAM_FlsListText[];
extern unsigned int HDAE5000_RAM_DirPageBase;
extern unsigned int HDAE5000_RAM_FlsPageBase;
extern char HDAE5000_Str_Chr2020203A2020[];
extern char HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage[];
#define FMT_DIR ((const char *)0x2e23d2L)   /* HDAE5000_Fmt_3_3d, "%3.3d" */
#define FMT_FLS ((const char *)0x2e2e76L)   /* HDAE5000_Fmt_3_3d_FlsList_BuildPage, "%3.3d" */

struct ResInfo { unsigned long addr; unsigned long size; };
struct SqtHdr { unsigned char pad[199]; unsigned char bank; };

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char HDAE5000_RAM_HdStreamBuffer[0x8000];

#define SONG_OFS(d, s) ((unsigned long)(d) * 0x4c0 + 0x780 + (unsigned long)(s) * 76)
#define SLOT(k, d, s) (*(long *)((unsigned long)&HDAE5000_RAM_DirNames[36 + 4 * (k)] + SONG_OFS(d, s)))
#define OBJ148_FN6 (((void **)HDAE5000_RAM_MainWorkspacePtr->tab[0x148].fns)[6])

void HDAE5000_FdList_Clear(void)
{
    HDAE5000_MemCopy(HDAE5000_RAM_FdList.label, HDAE5000_Str_Blank12Tab, 14);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_FdList.label);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_PARA_DRAW, -1L);
    HDAE5000_MemCopy(HDAE5000_RAM_FdList.rows, HDAE5000_FdList_RowsTemplate, 0xf1);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_HDAE_SET_STR_ADR, &HDAE5000_RAM_FdList.rows[0]);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_PARA_DRAW, -1L);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE1, EVT_DRAW, 0L);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE2, EVT_DRAW, 0L);
    HDAE5000_MemFill(HDAE5000_RAM_FdList.line1, 0, 20);
    HDAE5000_MemFill(HDAE5000_RAM_FdList.line2, 0, 20);
}

void HDAE5000_DirList_BuildPage(long obj)
{
    char num[22];
    register int i;
    HDAE5000_MemFill(HDAE5000_RAM_DirListText, 0, 0x1f9);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText[i], HDAE5000_Str_Chr2020203A2020, 21);
        HDAE5000_SPrintf(num, FMT_DIR, i + HDAE5000_RAM_DirPageBase + 1);
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText[i], num, 3);
        HDAE5000_MemCopy(&HDAE5000_RAM_DirListText[i][4], HDAE5000_DirName_Address(HDAE5000_RAM_DirPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, &HDAE5000_RAM_DirListText[0][0]);
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
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_STR_ADR, &HDAE5000_RAM_FlsListText[0]);
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_PARA_DRAW, -1L);
}

int HDAE5000_LoadSong_Sqt(unsigned int dir, unsigned int song)
{
    int ret = 0;
    struct ResInfo info4;
    struct ResInfo info3;
    unsigned long size;

    if (SLOT(2, dir, song) != -1L) {
        CALLV(HAMA->GetResouceInfo)(3, (char *)&info3);
        CALLV(HAMA->GetResouceInfo)(4, (char *)&info4);
        if (HDAE5000_HD_ReadFile(&HDAE5000_RAM_HdStreamBuffer[0], 0x5000L, &SLOT(2, dir, song)) == -1)
            return -1;
        size = *((unsigned int *)HDAE5000_RAM_HdStreamBuffer
                 + (((struct SqtHdr *)HDAE5000_RAM_HdStreamBuffer)->bank << 10) + 39);
        size <<= 4;
        size += info3.size;
        CALLV(HAMA->SeqLoadPre)();
        ret = HDAE5000_HD_ReadFile(info3.addr, size, &SLOT(2, dir, song));
        CALLV(HAMA->SeqLoadPost)(ret);
        CALLV(OBJ148_FN6)(-1L, EVT_ACTIVATE_STATE, 0L);
    }
    return ret;
}
