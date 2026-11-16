/* hd_r23_fsb.c (helper h_nm3a, lane_hd round 23), form b: alternatives to hd_r23_fs.c (same names) for two of its
   functions, ROM address order.  Declarations as in form a.  Options: -Xr.
   - HDAE5000_FlsLoadScreen: FlsItemPageBase declared int here and the sum written base + (unsigned int)arg, the
     spelling that gave the ROM's `ld bc,iz; ld wa,(base); add wa,bc` for FlsPageBase in run 98 (SelectFlsScreen),
     instead of form a's (int) cast on the unsigned base.
   - HDAE5000_CopyToHd_Execute: sel[i] through pointer arithmetic, *(sel member + i), instead of form a's unsigned
     long subscript (the same alternative as hd_r23_drvb.c's FdList_Scan).
   cc900-options: -Xr
   cc900-module: HDAE5000_FlsScreen_Refresh HDAE5000_LoadSongWithUi HDAE5000_UiObj_SetCaption
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

#define APFUNC_FlsNamingCheck 0x012a0017L       /* NAKA_APFUNC_FlsNamingCheck (hdae5000_ui_tree.s) */

struct FlsItem { unsigned int dir; unsigned int song; unsigned char as; unsigned char al; };
/* +0 title, +14 the 20 rows of 12 (and 2 bytes), +0x100 present flags, +0x114 selected flags */
struct FdList { char label[14]; char rows[242]; unsigned char present[20]; unsigned char sel[20]; };
struct FindData { char b[266]; };

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);

extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);
extern unsigned int HDAE5000_FlsItem_Get(unsigned int fls, unsigned int item, void *out);
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern unsigned int HDAE5000_Song_IsUsed(unsigned int dir, unsigned int song);
extern unsigned int HDAE5000_Fls_IsBlankName(unsigned int fls);
extern unsigned int HDAE5000_FdSong_CheckFiles(char *name, unsigned int mask);
extern unsigned int HDAE5000_CopyFdSongToHd(unsigned int dir, unsigned int song, const char *name, unsigned int mask,
                                            int a, int b);
extern unsigned int HDAE5000_LoadSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, int flag, long obj);
extern void HDAE5000_UiObj_SetCaption(long obj, long caption);
extern void HDAE5000_FlsScreen_Refresh(int variant, int mode);   /* the callers load WA, BC (see form a) */

extern unsigned int HDAE5000_RAM_CurFls;
extern unsigned int HDAE5000_RAM_CurFlsItem;
extern int HDAE5000_RAM_FlsItemPageBase;                 /* int in this form */
extern unsigned int HDAE5000_RAM_FlsChainFls;
extern unsigned int HDAE5000_RAM_FlsChainItem;
extern unsigned char HDAE5000_RAM_FlsAutoLoadPending;
extern unsigned char HDAE5000_RAM_LyricJump;
extern struct FdList HDAE5000_RAM_FdList;

extern char ram_2e2f24[];                               /* HDAE5000_Fmt_2_2d_CopyToHd_Execute */
extern char HDAE5000_Str_LSW[], HDAE5000_Str_PMT[], HDAE5000_Str_SQT[], HDAE5000_Str_CMP[], HDAE5000_Str_TM[],
    HDAE5000_Str_MSP[], HDAE5000_Str_RCM[], HDAE5000_Str_MD[], HDAE5000_Str_TLX[];

/* the FLS load screen: its 32 items (pages of 16); AL items chain the next load (EVT_HDAE_AFTER_LOAD) */
long HDAE5000_FlsLoadScreen(long obj, long ev, long arg)
{
    struct FlsItem it;
    unsigned int fls;
    unsigned int item;
    int mask;

    switch (ev) {
    case EVT_SHOW:
        CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_BOX, EVT_HDAE_CHANGE_SEL_NUM, 0L);
        break;
    case EVT_HDAE_SEQ_STOP:
        CALLV(ROOT->SetApTimer)(0x53L, obj, -1L, EVT_HDAE_AFTER_LOAD, 0L);
        break;
    case EVT_HDAE_AFTER_LOAD:
        if (HDAE5000_RAM_FlsAutoLoadPending == 1) {
            fls = HDAE5000_RAM_FlsChainFls;
            if ((item = HDAE5000_RAM_FlsChainItem + 1) >= 32) {
                if (++fls >= 120)
                    fls = 0;
                item = 0;
            }
            if (HDAE5000_FlsItem_Get(fls, item, &it) != 0xffff) {
                if (it.al == 1) {
                    HDAE5000_RAM_FlsAutoLoadPending = 1;
                    HDAE5000_RAM_FlsChainFls = fls;
                    HDAE5000_RAM_FlsChainItem = item;
                } else
                    HDAE5000_RAM_FlsAutoLoadPending = 0;
                mask = HDAE5000_Song_PartMask(it.dir, it.song);
                if (HDAE5000_LoadSongWithUi(it.dir, it.song, mask, 0, OBJ_FLS_FILE_LOAD) != 0xffff) {
                    if (HDAE5000_RAM_LyricJump == 2 && (mask & 0x100) == 0x100)
                        CALLV(ROOT->ApPostEvent)(OBJ_Tech_lyrics, EVT_SHOW, 0L);
                    if (it.as == 1)
                        CALLV(HAMA->SwbtWr)(0x48, 5, 1, 1);
                }
            } else
                HDAE5000_RAM_FlsAutoLoadPending = 0;
        }
        break;
    case EVT_SW_IN:
        break;
    case EVT_HDAE_SELECT_OK:
        HDAE5000_RAM_CurFlsItem = HDAE5000_RAM_FlsItemPageBase + (unsigned int)arg;
        if (HDAE5000_FlsItem_Get(HDAE5000_RAM_CurFls, HDAE5000_RAM_CurFlsItem, &it) != 0xffff) {
            if (it.al == 1) {
                HDAE5000_RAM_FlsAutoLoadPending = 1;
                HDAE5000_RAM_FlsChainFls = HDAE5000_RAM_CurFls;
                HDAE5000_RAM_FlsChainItem = HDAE5000_RAM_CurFlsItem;
            } else
                HDAE5000_RAM_FlsAutoLoadPending = 0;
            mask = HDAE5000_Song_PartMask(it.dir, it.song);
            if (HDAE5000_LoadSongWithUi(it.dir, it.song, mask, 0, OBJ_FLS_FILE_LOAD) != 0xffff) {
                if (HDAE5000_RAM_LyricJump == 2 && (mask & 0x100) == 0x100)
                    CALLV(ROOT->ApPostEvent)(OBJ_Tech_lyrics, EVT_SHOW, 0L);
                if (it.as == 1)
                    CALLV(HAMA->SwbtWr)(0x48, 5, 1, 1);
            }
        }
        break;
    case EVT_HDAE_SELECT_SAVE:
        HDAE5000_RAM_CurFlsItem = HDAE5000_RAM_FlsItemPageBase + (unsigned int)arg;
        HDAE5000_FlsScreen_Refresh(1, 0);
        if (HDAE5000_Fls_IsBlankName(HDAE5000_RAM_CurFls) != 0xffff)
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_EDIT, EVT_SHOW, 0L);
        else {
            CALLV(ROOT->ApFuncCall)(APFUNC_FlsNamingCheck, EVT_SET_STRING,
                                    HDAE5000_FlsRecord_Address(HDAE5000_RAM_CurFls));
            CALLV(ROOT->ApPostEvent)(OBJ_HDD_FLS_NAMING2, EVT_SHOW, 0L);
        }
        break;
    case EVT_HDAE_UNDER_FLOW:
        if (HDAE5000_RAM_FlsItemPageBase == 0) {
            if (HDAE5000_RAM_CurFls != 0) {
                HDAE5000_RAM_CurFls--;
                HDAE5000_RAM_FlsItemPageBase = 16;
                HDAE5000_FlsScreen_Refresh(0, 0);
                CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_BOX, EVT_HDAE_SET_SEL_NUM, arg + 16);
            }
        } else {
            HDAE5000_RAM_FlsItemPageBase = 0;
            HDAE5000_FlsScreen_Refresh(0, 0);
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_BOX, EVT_HDAE_SET_SEL_NUM, arg + 16);
        }
        break;
    case EVT_HDAE_OVER_FLOW:
        if (HDAE5000_RAM_FlsItemPageBase != 0) {
            if (HDAE5000_RAM_CurFls < 119) {
                HDAE5000_RAM_CurFls++;
                HDAE5000_RAM_FlsItemPageBase = 0;
                HDAE5000_FlsScreen_Refresh(0, 0);
                CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_BOX, EVT_HDAE_SET_SEL_NUM, arg - 16);
            }
        } else {
            HDAE5000_RAM_FlsItemPageBase = 16;
            HDAE5000_FlsScreen_Refresh(0, 0);
            CALLV(ROOT->ApPostEvent)(OBJ_FLS_FILE_BOX, EVT_HDAE_SET_SEL_NUM, arg - 16);
        }
        break;
    case EVT_HDAE_CHANGE_SEL_NUM:
        HDAE5000_RAM_CurFlsItem = HDAE5000_RAM_FlsItemPageBase + (unsigned int)arg;
        HDAE5000_FlsScreen_Refresh(0, 1);
        break;
    }
    return 0;
}

unsigned int HDAE5000_CopyToHd_Execute(unsigned char *sel, unsigned int count, unsigned int dir)
{
    char num[14];
    char name[14];
    struct FindData ff;
    int slot;
    register unsigned int i;
    unsigned int j;
    unsigned int mask;
    long h;

    for (i = 0; i < count; i++) {
        if (*(HDAE5000_RAM_FdList.sel + i) == 1) {
            HDAE5000_MemFill(num, 0, 13);
            HDAE5000_SPrintf(num, ram_2e2f24, i + 1);
            HDAE5000_StrNCpy(&num[2], &HDAE5000_RAM_FdList.rows[i * 12 + 3], 6);
            slot = -1;
            for (j = 0; j < 16; j++) {
                if (HDAE5000_Song_IsUsed(dir, j) == 0xffff) {
                    slot = j;
                    break;
                }
            }
            if (slot != -1) {
                HDAE5000_MemCopy(name, num, 8);
                mask = 0;
                CALLV(HAMA->GetMediaType)();
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_LSW);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask = 1;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_PMT);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x002;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_SQT);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x004;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_CMP);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x008;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_TM);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x010;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_MSP);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x020;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_RCM);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x040;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_MD);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x080;
                    CALLV(HAMA->findclose)(h);
                }
                HDAE5000_StrCpy(&name[8], HDAE5000_Str_TLX);
                if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) {
                    mask |= 0x100;
                    CALLV(HAMA->findclose)(h);
                }
                if (HDAE5000_FdSong_CheckFiles(num, mask) != 0xffff) {
                    if (HDAE5000_CopyFdSongToHd(dir, slot, num, mask, 0, 0) == 0xffff) {
                        CALLV(ROOT->ApPostEvent)(OBJ_ERR_SAVE, EVT_SHOW, 0L);
                        HDAE5000_UiObj_SetCaption(OBJ_ERR_SAVE_EXIT, OBJ_CP_FD);
                        CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                        CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_SAVE_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                        return 0xffff;
                    }
                } else {
                    CALLV(ROOT->ApPostEvent)(OBJ_ERR_NO_HK_DATA, EVT_SHOW, 3L);
                    CALLV(ROOT->KillApTimer)(0x14dL, OBJ_ERR_NO_HK_DATA_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                    CALLV(ROOT->SetApTimer)(0x14dL, OBJ_ERR_NO_HK_DATA_CATCH, -1L, EVT_HDAE_TIMER_BACK, OBJ_CP_FD);
                    return 0xffff;
                }
            }
        }
    }
    return 0;
}
