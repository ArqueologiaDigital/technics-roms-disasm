/* Functions of hdae5000_hd_driver.s.  (hdae5000_setup_copy.c)
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
long HDAE5000_SetupP2SwCatch(long obj, long ev, long arg)
{
    if (ev == EVT_SW_IN) {
        switch (CALLR(long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID)) {
        case 0x8c:
            CALLV(ROOT->ApPostEvent)(OBJ_HD_PLEASE, EVT_SHOW, 5L);
            HDAE5000_HD_StoreSettings(0);
            CALLV(ROOT->ApPostEvent)(OBJ_SETUPS_TOOLS, EVT_SHOW, 0L);
            break;
        case 9:
            HDAE5000_MemFill(ram_22ad9c, 0, 10);
            if (HDAE5000_RAM_WriteProtect == 0)
                CALLV(ROOT->ApPostEvent)(OBJ_ATTEN_HD_FORMAT, EVT_SHOW, 0L);
            break;
        case 0x0c:
            HDAE5000_SetupPage_BuildDriveInfo();
            CALLV(ROOT->ApPostEvent)(OBJ_SETUP_HDINFO, EVT_SHOW, 0L);
            break;
        }
    }
    return 0;
}

/* the copy-to-HD screen (the floppy's song list): mark all present songs, go on to the directory selection,
   toggle one song's mark */

/* ---- second forms ---- */

/* long arg, cast in the index */

/* long arg, no cast */
