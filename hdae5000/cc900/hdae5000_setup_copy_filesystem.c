/* Functions of hdae5000_filesystem.s.  (hdae5000_setup_copy.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_setup_copy.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_SetupPage_BuildDriveInfo
   cc900-module: HDAE5000_FdList_Redisplay HDAE5000_DirList_BuildPage HDAE5000_Count_Active_Files
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);

/* other modules (call) */
extern int HDAE5000_HD_StoreSettings(int keep);

/* these modules (calr, cc900-module) */
extern void HDAE5000_SetupPage_BuildDriveInfo(void);
extern void HDAE5000_FdList_Redisplay(void);
extern void HDAE5000_DirList_BuildPage(long obj);
extern unsigned int HDAE5000_Count_Active_Files(void);

extern unsigned char HDAE5000_RAM_WriteProtect;
extern unsigned char ram_22ad9c[];      /* 10 bytes: the format-code dialog's count and HDAE5000_RAM_FormatCodeDigits */
extern unsigned char ram_22aa9c[];      /* HDAE5000_RAM_FdList as a flat array: present[20] at 0x100, sel[20] at 0x114 */

#define FD_PRESENT(i) ram_22aa9c[(i) + 0x100]
#define FD_SEL(i) ram_22aa9c[(i) + 0x114]

/* the setup page 2 switches: 0x8c stores the settings, 9 opens the format attention, 0x0c the drive information */

/* the copy-to-HD screen (the floppy's song list): mark all present songs, go on to the directory selection,
   toggle one song's mark */
long HDAE5000_CopyToHDScreen(long obj, long ev, unsigned long arg)
{
    unsigned int i;

    switch (ev) {
    case EVT_HDAE_SELECT_ALL:
        for (i = 0; i < 20; i++) {
            if (FD_PRESENT((unsigned long)i) == 1) {
                FD_SEL((unsigned long)i) = 1;
                HDAE5000_FdList_Redisplay();
            }
        }
        break;
    case EVT_HDAE_SELECT_OK:
        HDAE5000_DirList_BuildPage(OBJ_CP_FD_DIRBOX);
        if (HDAE5000_Count_Active_Files() != 0)
            CALLV(ROOT->ApPostEvent)(OBJ_CP_FD_DIRSEL, EVT_SHOW, 0L);
        else
            CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_CPFD_MARK, EVT_SHOW, 0L);
        break;
    case EVT_HDAE_SELECT_SAVE:
        if (FD_PRESENT(arg) == 1) {
            if (FD_SEL(arg) == 1)
                FD_SEL(arg) = 0;
            else
                FD_SEL(arg) = 1;
            HDAE5000_FdList_Redisplay();
        }
        break;
    case EVT_HDAE_CHANGE_SEL_NUM:
        HDAE5000_FdList_Redisplay();
        break;
    }
    return 0;
}

/* ---- second forms ---- */

/* long arg, cast in the index */

/* long arg, no cast */
