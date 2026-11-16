/* lane_hd round 3 (round 2 with every function-table call cast, CALLV), form a (lane_hd's own functions): round-1 misses retried with the function tables as struct
   members (hdae_ws.h), constant pointers where the ROM loads an address as an immediate, and new functions.
   Options: -Xr (run 2026-11-16-44-hd-r1: HD_GetBlockInfo and SwapBytes32 match only there). */
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, const char *, ...);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern unsigned char *HDAE5000_DirName_Address(unsigned int dir);
extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);

extern unsigned int ram_23085e;
#define LYRIC_BUF ((unsigned char *)0x22b430L)
#define FLS_LIST_TEXT ((char *)0x22a2caL)

struct FdList { char label[14]; char rows[242]; char line1[20]; char line2[20]; };
extern struct FdList HDAE5000_RAM_FdList;
extern char HDAE5000_Str_Blank12Tab[];
extern char HDAE5000_FdList_RowsTemplate[];
extern char HDAE5000_RAM_DirListText[24][21];
extern unsigned int HDAE5000_RAM_DirPageBase;
extern unsigned int HDAE5000_RAM_FlsPageBase;
extern char HDAE5000_Str_Chr2020203A2020[];
extern char HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage[];
extern char HDAE5000_Fmt_3_3d[];
extern char HDAE5000_Fmt_3_3d_FlsList_BuildPage[];

void HDAE5000_RequestMode(unsigned char mode)
{
    CALLV(ROOT->DeleteEvent)(-1L, EVT_CHANGE_MODE);
    CALLV(ROOT->ApPostEvent)(-1L, EVT_CHANGE_MODE, (long)mode + NAKA_MODE_MD_PS);
}

void HDAE5000_RequestTitle15(unsigned char title)
{
    CALLV(ROOT->DeleteEvent)(-1L, EVT_CHANGE_TITLE);
    CALLV(ROOT->ApPostEvent)(-1L, EVT_CHANGE_TITLE, (long)title + TITLE_PS);
}

void HDAE5000_RequestTitle16(unsigned char title)
{
    CALLV(ROOT->DeleteEvent)(-1L, EVT_INTERRUPT_TITLE);
    CALLV(ROOT->ApPostEvent)(-1L, EVT_INTERRUPT_TITLE, (long)title + TITLE_PS);
}

void HDAE5000_YieldUntilSem1Zero(void)
{
    while (CALLR(int, HAMA->ref_sem_X)(1) != 0)
        CALLV(HAMA->rot_rdq_X)(3);
}

long HDAE5000_Lyrics_ReadVarLen(unsigned int pos)
{
    long v = 0;
    unsigned int i;
    for (i = 0; i < 4; i++) {
        v += LYRIC_BUF[pos + i + 22L] & 0x7f;
        if (LYRIC_BUF[pos + i + 22L] < 0x80) {
            ram_23085e = i + 1;
            return v;
        }
        v <<= 7;
    }
    return -1L;
}

unsigned int HDAE5000_SwapBytes16(unsigned int x)
{
    unsigned int r;
    r = x & 0xff;
    x >>= 8;
    r <<= 8;
    r += x;
    return r;
}

unsigned int HDAE5000_Smf_SwapBytes16(unsigned int x)
{
    unsigned int r;
    r = x & 0xff;
    x >>= 8;
    r <<= 8;
    r += x & 0xff;
    return r;
}

unsigned long HDAE5000_Smf_SwapBytes32(unsigned long x)
{
    unsigned long t, r;
    t = x;
    r = t & 0xff;
    t >>= 8; r <<= 8; r += t & 0xff;
    t >>= 8; r <<= 8; r += t & 0xff;
    t >>= 8; r <<= 8; r += t & 0xff;
    return r;
}

void HDAE5000_FdList_Clear(void)
{
    HDAE5000_MemCopy(HDAE5000_RAM_FdList.label, HDAE5000_Str_Blank12Tab, 14);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_FdList.label);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_PARA_DRAW, -1L);
    HDAE5000_MemCopy(HDAE5000_RAM_FdList.rows, HDAE5000_FdList_RowsTemplate, 0xf1);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_FdList.rows);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_PARA_DRAW, -1L);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE1, EVT_DRAW, 0L);
    CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE2, EVT_DRAW, 0L);
    HDAE5000_MemFill(HDAE5000_RAM_FdList.line1, 0, 20);
    HDAE5000_MemFill(HDAE5000_RAM_FdList.line2, 0, 20);
}

void HDAE5000_Set_Menu_Visibility(unsigned char hide)
{
    int v;
    if (hide == 0)
        v = 1;
    else
        v = 0;
    CALLV(ROOT->SetVisible)(OBJ_SELECT_DIR_SW_EDIT, v);
    CALLV(ROOT->SetVisible)(OBJ_HD_FILE_LOAD_SW_SAVE, v);
    CALLV(ROOT->SetVisible)(OBJ_HD_FILE_LOAD_SW_DEL, v);
    CALLV(ROOT->SetVisible)(OBJ_FLS_SELECT_SW_EDIT, v);
    CALLV(ROOT->SetVisible)(OBJ_FLS_FILE_LOAD_SW_EDIT, v);
    CALLV(ROOT->SetVisible)(OBJ_HD_FILE_LOAD_SW_DELFILE, v);
    CALLV(ROOT->SetVisible)(OBJ_CP_FD_HDSWTO, v);
    CALLV(ROOT->SetVisible)(OBJ_CP_FD_HDSWSEL, v);
    CALLV(ROOT->SetVisible)(OBJ_SW_HD_FORMAT, v);
}

void HDAE5000_DirList_BuildPage(long obj)
{
    char num[22];
    int i;
    HDAE5000_MemFill(HDAE5000_RAM_DirListText, 0, 0x1f9);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText[i], HDAE5000_Str_Chr2020203A2020, 21);
        HDAE5000_SPrintf(num, HDAE5000_Fmt_3_3d, i + HDAE5000_RAM_DirPageBase + 1);
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText[i], num, 3);
        HDAE5000_MemCopy(&HDAE5000_RAM_DirListText[i][4], HDAE5000_DirName_Address(HDAE5000_RAM_DirPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_DirListText);
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}

void HDAE5000_FlsList_BuildPage(void)
{
    char num[22];
    unsigned int i;
    HDAE5000_MemFill(FLS_LIST_TEXT, 0, 0x781);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(FLS_LIST_TEXT + 21 * i, HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage, 21);
        HDAE5000_SPrintf(num, HDAE5000_Fmt_3_3d_FlsList_BuildPage, HDAE5000_RAM_FlsPageBase + i + 1);
        HDAE5000_MemCopy(FLS_LIST_TEXT + 21 * i, num, HDAE5000_StrLen(num));
        HDAE5000_MemCopy(FLS_LIST_TEXT + (21 * i + 4), HDAE5000_FlsRecord_Address(HDAE5000_RAM_FlsPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_STR_ADR, FLS_LIST_TEXT);
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_PARA_DRAW, -1L);
}

extern unsigned char HDAE5000_RAM_HdStreamState;
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern unsigned long HDAE5000_RAM_HdStreamSlot;
extern unsigned char HDAE5000_RAM_HdStreamBuffer[0x8000];
extern unsigned char HDAE5000_RAM_RcmStreamState[];
extern int HDAE5000_HD_WriteFile(unsigned char *buf, unsigned long size, unsigned long slot);
extern int HDAE5000_HD_AppendFile(unsigned char *buf, unsigned long size, unsigned long slot);

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
        chunk = n <= room ? n : room;
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
                r = HDAE5000_HD_WriteFile(HDAE5000_RAM_HdStreamBuffer, 0x8000, HDAE5000_RAM_HdStreamSlot);
                HDAE5000_RAM_HdStreamState = 2;
            } else {
                r = HDAE5000_HD_AppendFile(HDAE5000_RAM_HdStreamBuffer, 0x8000, HDAE5000_RAM_HdStreamSlot);
            }
            if (r != 0)
                break;
            HDAE5000_RAM_HdStreamFill = HDAE5000_RAM_HdStreamBuffer;
        }
        n -= chunk;
    } while (n != 0);
    return r;
}
