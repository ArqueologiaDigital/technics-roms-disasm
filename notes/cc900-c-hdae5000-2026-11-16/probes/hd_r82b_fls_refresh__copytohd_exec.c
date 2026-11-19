/* Functions of hdae5000_filesystem.s.  (hdae5000_fls_refresh.c, v1.10i port of HDAE5000_CopyToHd_Execute)
   v1.x: eight song parts, so no TLX part lookup (no ".TLX" extension, no mask bit 0x100); the floppy list
   HDAE5000_RAM_FdList is at 0x22aa54 (v2.06i 0x22aa9c); the number format and the extensions are v1.10i's labels;
   the error objects are this tree's hdae_ids.h values.
   cc900-options: -Xr
   cc900-module: HDAE5000_PartList_Build HDAE5000_NameHistory_Recall HDAE5000_FlsName_StoreWithUi
   cc900-module: HDAE5000_DirName_StoreWithUi HDAE5000_FlsList_BuildPage HDAE5000_DirList_BuildPage
   cc900-module: HDAE5000_FlsScreen_Refresh HDAE5000_SongScreen_Refresh HDAE5000_YieldUntilSem1Zero
   cc900-module: HDAE5000_LoadSongWithUi HDAE5000_SaveSongWithUi HDAE5000_UiObj_SetCaption HDAE5000_TypeSel_Init
   cc900-module: HDAE5000_DelOpt_ShowFlags HDAE5000_Count_Active_Files HDAE5000_CopyToHd_Execute
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct FindData { char b[266]; };

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);

/* other modules (call) */
/* r36: `int song`, so that CopyToHd_Execute's unsigned j is a converted argument (the ROM loads BC before WA) */
extern unsigned int HDAE5000_Song_IsUsed(unsigned int dir, int song);
extern unsigned int HDAE5000_FdSong_CheckFiles(char *name, unsigned int mask);
extern unsigned int HDAE5000_CopyFdSongToHd(unsigned int dir, unsigned int song, const char *name, unsigned int mask,
                                            int a, int b);

/* this module (calr, cc900-module) */
extern void HDAE5000_UiObj_SetCaption(long obj, long caption);

/* the floppy list (HDAE5000_RAM_FdList, 0x22aa54 in v1.x) as a flat byte array */
extern unsigned char ram_22aa54[];

/* ROM */
extern char ram_2cb398[];                               /* HDAE5000_Fmt_2_2d_CopyToHd_Execute */
extern char HDAE5000_Str_LSW[], HDAE5000_Str_PMT[], HDAE5000_Str_SQT[], HDAE5000_Str_CMP[], HDAE5000_Str_TM[],
    HDAE5000_Str_MSP[], HDAE5000_Str_RCM[], HDAE5000_Str_MD[];

/* one part file of the floppy song: name + extension looked up, its mask bit set when it exists */
#define PART(ext, setbit) \
    HDAE5000_StrCpy(&name[8], ext); \
    if ((h = CALLR(long, HAMA->findfirst)(name, (char *)&ff)) != -1L) { setbit; CALLV(HAMA->findclose)(h); }

/* the flat-array spellings of the list's members: selected flag i, and the name inside row i */
#define FD_SEL(i) ram_22aa54[(unsigned long)(i) + 0x114]
#define FD_ROWNAME(i) ((char *)&ram_22aa54[(unsigned long)((i) * 12 + 3) + 14])

/* copy the floppy songs selected in the copy screen's list into free songs of directory dir; sel (XWA) is not
   read: the list is HDAE5000_RAM_FdList itself.  j, mask, i declared in that order (the v2.06i main form). */
unsigned int HDAE5000_CopyToHd_Execute(unsigned char *sel, unsigned int count, unsigned int dir)
{
    char num[14];
    char name[14];
    struct FindData ff;
    int slot;
    unsigned int j;
    unsigned int mask;
    unsigned int i;
    long h;

    for (i = 0; i < count; i++) {
        if (FD_SEL(i) == 1) {
            HDAE5000_MemFill(num, 0, 13);
            HDAE5000_SPrintf(num, ram_2cb398, i + 1);
            HDAE5000_StrNCpy(&num[2], FD_ROWNAME(i), 6);
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
                PART(HDAE5000_Str_LSW, mask = 1)
                PART(HDAE5000_Str_PMT, mask |= 0x002)
                PART(HDAE5000_Str_SQT, mask |= 0x004)
                PART(HDAE5000_Str_CMP, mask |= 0x008)
                PART(HDAE5000_Str_TM, mask |= 0x010)
                PART(HDAE5000_Str_MSP, mask |= 0x020)
                PART(HDAE5000_Str_RCM, mask |= 0x040)
                PART(HDAE5000_Str_MD, mask |= 0x080)
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
