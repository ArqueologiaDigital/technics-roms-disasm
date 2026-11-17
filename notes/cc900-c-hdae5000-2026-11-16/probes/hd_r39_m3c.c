/* lane_hd round 39, helper h_m3: HDAE5000_SetupP2SwCatch (hdae5000_hd_driver.s) and HDAE5000_CopyToHDScreen
   (hdae5000_filesystem.s), in ROM address order, then their second forms.  Kept apart from hd_r39_m3b.c
   because their module lists belong to other calr groups.
   cc900-options: -Xr
   cc900-module: HDAE5000_SetupPage_BuildDriveInfo
   cc900-module: HDAE5000_FdList_Redisplay HDAE5000_DirList_BuildPage HDAE5000_Count_Active_Files
   cc900-name: CpToHDScreen_b=HDAE5000_CopyToHDScreen
   cc900-name: CpToHDScreen_c=HDAE5000_CopyToHDScreen
   - SetupP2SwCatch: the C of hd_r13_ng4.c (run 2026-11-16-83-hd-r16, 214 of 220 bytes) is right instruction by
     instruction.  Its only departure was the call of HDAE5000_SetupPage_BuildDriveInfo, written there under the
     short name `SetupPage_BuildDriveInfo` with a cc900-name line: the checker did not resolve that name (the
     `--show` of that run still stops on it), so the ROM's calr stayed a 4-byte call and the three jrl
     distances before it moved by one.  Here the callee is called by its tree name (33 characters, the first 31
     unique in this file; it is built from hdae5000/cc900/hdae5000_setup_hd_driver.c) and named in the module
     line.  No second form: nothing else departs.
   - CopyToHDScreen: hd_r27_a6.c (run 2026-11-16-113-hd-r27a) has the ROM's case order and loop; what departs
     is every access to the floppy list.  The ROM indexes in 32 bits and loads the list's address as an
     immediate (`extz xwa; add xwa,0x100; ld xbc,FdList; add xbc,xwa; cp (xbc),1`, and for arg `ld xwa,xde;
     add xwa,0x100; ..`, `add xde,0x114; ld xwa,FdList; add xwa,xde`); V4.23 made 16-bit sums on `lda` bases
     from the structure members (`add wa,0x100; lda xbc,(FdList); cp (xbc+wa),1`).  The matched
     HDAE5000_CopyToHd_Execute (hdae5000/cc900/hdae5000_fls_refresh.c) has the ROM's form from a flat
     `extern unsigned char ram_22aa9c[]` indexed `[(unsigned long)i + 0x114]`: used here for all six accesses.
     The jr / jrl sizes follow from the code size.
     HDAE5000_CopyToHDScreen takes arg as unsigned long and indexes with it directly;
     CpToHDScreen_b keeps `long arg` and casts it in the index; CpToHDScreen_c keeps `long arg` uncast.
   Not sure: whether a long arg in the index (forms b, c) costs a copy or a sign step.
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
long CpToHDScreen_b(long obj, long ev, long arg)
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
        if (FD_PRESENT((unsigned long)arg) == 1) {
            if (FD_SEL((unsigned long)arg) == 1)
                FD_SEL((unsigned long)arg) = 0;
            else
                FD_SEL((unsigned long)arg) = 1;
            HDAE5000_FdList_Redisplay();
        }
        break;
    case EVT_HDAE_CHANGE_SEL_NUM:
        HDAE5000_FdList_Redisplay();
        break;
    }
    return 0;
}

/* long arg, no cast */
long CpToHDScreen_c(long obj, long ev, long arg)
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
