/* hd_r20_drvb.c (helper h_drv, lane_hd round 20), form b: alternatives to hd_r20_drva.c for four functions (same
   names; variants under cc900-name aliases).  Declarations as in form a.
   - HDAE5000_FdList_Scan: the media test as a local and `||` instead of `case 2: case 3:` (the ROM's `cp l,3; jr z;
     cp l,2; jrl nz` fits both), and findfirst's pattern as WRAP(...) instead of (long) (the ROM parks it in XDE
     before computing &blk).
   - HDAE5000_SEL_DIR_Screen: the page base on the left of the sum, DirPageBase + (int)arg (the ROM loads the base
     first in both SELECT arms).
   - HDAE5000_SongScreen_Refresh: the two parameters as unsigned char in the prototype (the callee stores C and A;
     only the callee is in this file, so the callers' WA/BC loads do not matter here), and WRAP for the text
     addresses.  SongScrRefresh_k: the same with an old-style (K&R) definition, which is what lets the callers load
     WA/BC in one file (brief: the build cannot parse K&R yet; this is for the VM listing only).
   - HDAE5000_LBNLoadSwCatch: the part mask assigned in its own statement before the test.
   cc900-options: -Xr
   cc900-name: SongScrRefresh_k=HDAE5000_SongScreen_Refresh
   cc900-module: HDAE5000_FdList_Clear HDAE5000_FdName_SongNumber HDAE5000_ShowErrorMessageTitle
   cc900-module: HDAE5000_SongScreen_Refresh HDAE5000_DirList_BuildPage HDAE5000_PartList_Build
   cc900-module: HDAE5000_TypeSel_Init HDAE5000_LoadSongWithUi HDAE5000_Lbn_ShowEntry
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern char *__cdecl HDAE5000_StrNCat(char *, char *, int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct TypeSel { unsigned int mask; unsigned char flag[10]; };
extern void HDAE5000_FdList_Clear(void);
extern int HDAE5000_FdName_SongNumber(char *name);
extern void HDAE5000_ShowErrorMessageTitle(int code);
extern void HDAE5000_DirList_BuildPage(long obj);
extern int HDAE5000_Lbn_ShowEntry(unsigned int dir, unsigned int song, unsigned int pos, int draw);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int n);
extern int HDAE5000_LoadSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, long obj, int ui);
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern char *HDAE5000_DirName_Address(unsigned int dir);
extern unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song);
void HDAE5000_SongScreen_Refresh(unsigned char page, unsigned char skip);

struct FdList { char label[14]; char rows[242]; char line1[20]; char line2[20]; };
extern struct FdList HDAE5000_RAM_FdList;
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern int HDAE5000_RAM_DirPageBase;
extern unsigned int HDAE5000_RAM_LbnDigitPos;
extern unsigned char HDAE5000_RAM_LyricJump;
extern char HDAE5000_RAM_SongScreenTitle[];
extern char HDAE5000_RAM_SongListText[];

extern char HDAE5000_Str_AllFilesPattern[];
extern char HDAE5000_Str_DIRECTORY[];
extern char HDAE5000_Str_Chr3A_SongScreen_Refresh[];
extern char HDAE5000_Str_Blank0Tab[];
extern char HDAE5000_Str_Chr3A2020202020[];
extern char HDAE5000_Str_LBN[];
extern char ram_2e250c[];   /* HDAE5000_Fmt_2_2d_SongScreen_Refresh */
extern char ram_2e2534[];   /* HDAE5000_Fmt_2_2d_SongScreen_Refresh_2 */
extern long ram_2e24e8[];   /* HDAE5000_SongScreen_Refresh_ObjIds */
extern long ram_2e24f0[];   /* HDAE5000_SongScreen_Refresh_ObjIds_2 */
extern long ram_2e24f8[];   /* HDAE5000_SongScreen_Refresh_ObjIds_3 */
extern unsigned char HDAE5000_TypeSel_TemplateBlank[];

struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)
#define APFUNC_HDD_DIRNAMECHECK 0x012a0002L
struct FindBlk { char head[6]; char name[260]; };

int HDAE5000_FdList_Scan(void)
{
    struct FindBlk blk;
    int ret;
    unsigned char t;
    char *label;
    long h;
    int n;
    unsigned int i;

    ret = 0;
    t = CALLR(unsigned char, HAMA->GetMediaType)();
    if (t == 3 || t == 2) {
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD, EVT_SHOW, -1L);
        HDAE5000_FdList_Clear();
        label = CALLR(char *, HAMA->GetVolumeLabel)();
        if (label != 0)
            HDAE5000_MemCopy(HDAE5000_RAM_FdList.label, label, HDAE5000_StrLen(label));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_FdList.label);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_VOLLABEL, EVT_PARA_DRAW, -1L);
        h = CALLR(long, HAMA->findfirst)(WRAP(HDAE5000_Str_AllFilesPattern), (char *)&blk);
        if (h >= 0) {
            n = HDAE5000_FdName_SongNumber(blk.name);
            if (n != -1) {
                HDAE5000_RAM_FdList.line1[n] = 1;
                HDAE5000_MemCopy((void *)((unsigned long)&HDAE5000_RAM_FdList.rows[3] + n * 12), &blk.name[2], 6);
            }
            while (CALLR(int, HAMA->findnext)(h, (char *)&blk) == 0) {
                n = HDAE5000_FdName_SongNumber(blk.name);
                if (n != -1) {
                    HDAE5000_RAM_FdList.line1[n] = 1;
                    HDAE5000_MemCopy((void *)((unsigned long)&HDAE5000_RAM_FdList.rows[3] + n * 12), &blk.name[2], 6);
                }
            }
            CALLV(HAMA->findclose)(h);
        }
        for (i = 0; i < 20; i++) {
            HDAE5000_RAM_FdList.rows[i * 12 + 10] = ' ';
            if (HDAE5000_RAM_FdList.line2[i] == 1)
                HDAE5000_RAM_FdList.rows[i * 12 + 10] = '*';
        }
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FdList.rows));
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LIST, EVT_PARA_DRAW, -1L);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE1, EVT_DRAW, 0L);
        CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_LINE2, EVT_DRAW, 0L);
    } else {
        HDAE5000_ShowErrorMessageTitle(2);
        ret = -1;
    }
    return ret;
}

long HDAE5000_SEL_DIR_Screen(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 0:
            HDAE5000_RAM_DirPageBase = 0;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        case 1:
            HDAE5000_RAM_DirPageBase = 24;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        case 5:
            HDAE5000_RAM_DirPageBase = 48;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        case 6:
            HDAE5000_RAM_DirPageBase = 72;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        case 7:
            HDAE5000_RAM_DirPageBase = 96;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            break;
        }
        break;
    case EVT_HDAE_SELECT_OK:
    case EVT_HDAE_SELECT_OK2:
        HDAE5000_RAM_CurDir = HDAE5000_RAM_DirPageBase + (int)arg;
        HDAE5000_SongScreen_Refresh(0, 0);
        CALLV(ROOT->ApPostEvent)(OBJ_SELECT_FILE, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_SELECT_SAVE:
        CALLV(ROOT->ApFuncCall)(APFUNC_HDD_DIRNAMECHECK, EVT_SET_STRING,
                                HDAE5000_DirName_Address(HDAE5000_RAM_CurDir = HDAE5000_RAM_DirPageBase + (int)arg));
        CALLV(ROOT->ApPostEvent)(OBJ_HDD_DIR_NAMING, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_UNDER_FLOW:
        if (HDAE5000_RAM_DirPageBase >= 24) {
            HDAE5000_RAM_DirPageBase -= 24;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            CALLV(ROOT->ApPostEvent)(OBJ_SEL_DIR, EVT_HDAE_SET_SEL_NUM, arg + 24);
        }
        break;
    case EVT_HDAE_OVER_FLOW:
        if (HDAE5000_RAM_DirPageBase < 96) {
            HDAE5000_RAM_DirPageBase += 24;
            HDAE5000_DirList_BuildPage(OBJ_SEL_DIR);
            CALLV(ROOT->ApPostEvent)(OBJ_SEL_DIR, EVT_HDAE_SET_SEL_NUM, arg - 24);
        }
        break;
    }
    return 0;
}

void HDAE5000_SongScreen_Refresh(unsigned char page, unsigned char skip)
{
    char buf[22];
    int i;
    unsigned int m;

    if (skip == 0) {
        HDAE5000_MemFill(HDAE5000_RAM_SongScreenTitle, 0, 32);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_DIRECTORY);
        HDAE5000_SPrintf(buf, ram_2e250c, HDAE5000_RAM_CurDir + 1);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, buf);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_Chr3A_SongScreen_Refresh);
        HDAE5000_StrNCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_DirName_Address(HDAE5000_RAM_CurDir), 16);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_Blank0Tab);
        CALLV(ROOT->ApPostEvent)(ram_2e24e8[page], EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_SongScreenTitle));
        CALLV(ROOT->ApPostEvent)(ram_2e24e8[page], EVT_PARA_DRAW, -1L);
    }
    if (skip == 0) {
        for (i = 0; i < 16; i++) {
            HDAE5000_MemCopy((void *)((unsigned long)&HDAE5000_RAM_SongListText[2] + 30 * i),
                             HDAE5000_Str_Chr3A2020202020, 28);
            HDAE5000_SPrintf(buf, ram_2e2534, i + 1);
            HDAE5000_MemCopy((void *)((unsigned long)&HDAE5000_RAM_SongListText[0] + 30 * i), buf, 2);
            HDAE5000_MemCopy((void *)((unsigned long)&HDAE5000_RAM_SongListText[3] + 30 * i),
                             HDAE5000_SongRecord_Address(HDAE5000_RAM_CurDir, i), 26);
        }
        CALLV(ROOT->ApPostEvent)(ram_2e24f0[page], EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_SongListText));
        CALLV(ROOT->ApPostEvent)(ram_2e24f0[page], EVT_PARA_DRAW, -1L);
    }
    if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
        HDAE5000_PartList_Build(ram_2e24f8[page], HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, m);
    else
        HDAE5000_PartList_Build(ram_2e24f8[page], 0xffff, 0xffff, 0xffff);
}

void SongScrRefresh_k(page, skip)
unsigned char page, skip;
{
    char buf[22];
    int i;
    unsigned int m;

    if (skip == 0) {
        HDAE5000_MemFill(HDAE5000_RAM_SongScreenTitle, 0, 32);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_DIRECTORY);
        HDAE5000_SPrintf(buf, ram_2e250c, HDAE5000_RAM_CurDir + 1);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, buf);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_Chr3A_SongScreen_Refresh);
        HDAE5000_StrNCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_DirName_Address(HDAE5000_RAM_CurDir), 16);
        HDAE5000_StrCat(HDAE5000_RAM_SongScreenTitle, HDAE5000_Str_Blank0Tab);
        CALLV(ROOT->ApPostEvent)(ram_2e24e8[page], EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_SongScreenTitle);
        CALLV(ROOT->ApPostEvent)(ram_2e24e8[page], EVT_PARA_DRAW, -1L);
    }
    if (skip == 0) {
        for (i = 0; i < 16; i++) {
            HDAE5000_MemCopy((void *)((unsigned long)&HDAE5000_RAM_SongListText[2] + 30 * i),
                             HDAE5000_Str_Chr3A2020202020, 28);
            HDAE5000_SPrintf(buf, ram_2e2534, i + 1);
            HDAE5000_MemCopy((void *)((unsigned long)&HDAE5000_RAM_SongListText[0] + 30 * i), buf, 2);
            HDAE5000_MemCopy((void *)((unsigned long)&HDAE5000_RAM_SongListText[3] + 30 * i),
                             HDAE5000_SongRecord_Address(HDAE5000_RAM_CurDir, i), 26);
        }
        CALLV(ROOT->ApPostEvent)(ram_2e24f0[page], EVT_HDAE_SET_STR_ADR, (long)HDAE5000_RAM_SongListText);
        CALLV(ROOT->ApPostEvent)(ram_2e24f0[page], EVT_PARA_DRAW, -1L);
    }
    if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
        HDAE5000_PartList_Build(ram_2e24f8[page], HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, m);
    else
        HDAE5000_PartList_Build(ram_2e24f8[page], 0xffff, 0xffff, 0xffff);
}

long HDAE5000_LBNLoadSwCatch(long obj, long ev, long arg)
{
    unsigned int m;

    switch (ev) {
    case EVT_SHOW:
        m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong);
        if (m != 0xffff)
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, m, HDAE5000_TypeSel_TemplateBlank, 2);
        else
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0, HDAE5000_TypeSel_TemplateBlank, 2);
        break;
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_LBN);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 8:
        case 9:
            if (HDAE5000_RAM_LbnDigitPos == 5) {
                HDAE5000_LoadSongWithUi(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, HDAE5000_RAM_SaveOptions.mask,
                                        OBJ_LOAD_BY_NUM, 1);
                HDAE5000_Lbn_ShowEntry(0, 0, 6, 1);
                if (HDAE5000_RAM_LyricJump == 2 && (HDAE5000_RAM_SaveOptions.mask & 0x100) == 0x100)
                    CALLV(ROOT->ApPostEvent)(OBJ_Tech_lyrics, EVT_SHOW, 0L);
            }
        }
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}
