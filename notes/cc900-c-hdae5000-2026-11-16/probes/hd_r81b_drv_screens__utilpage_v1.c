/* Functions of hdae5000_hd_driver.s.  (hdae5000_drv_screens.c, ported to hdae5000_v1_10i: v2.01i's matched round-2 C, its five ram_<hex> strings at v1.10i's addresses; the ROM code has the same shape)
   Firmware C (cc900 phase 6), built by Toshiba V4.23.
   cc900-options: -Xr
   cc900-name: UtilPage_a=HDAE5000_HDD_UTIL_PAGE
   cc900-name: UtilPage_b=HDAE5000_HDD_UTIL_PAGE
   cc900-module: HDAE5000_FdList_Clear HDAE5000_FdName_SongNumber HDAE5000_ShowErrorMessageTitle
   cc900-module: HDAE5000_SongScreen_Refresh HDAE5000_FlsScreen_Refresh HDAE5000_DirList_BuildPage
   cc900-module: HDAE5000_FlsList_BuildPage HDAE5000_Lbn_ShowEntry HDAE5000_PartList_Build
   cc900-module: HDAE5000_YieldUntilSem1Zero HDAE5000_DelOpt_InitFromSong HDAE5000_NameHistory_Recall
   cc900-module: HDAE5000_DirName_StoreWithUi HDAE5000_TypeSel_Init HDAE5000_TypeSel_ShowSaveFlags
   cc900-module: HDAE5000_SaveSongWithUi HDAE5000_LoadSongWithUi HDAE5000_HardTest_HddIdRead
   cc900-module: HDAE5000_HardTest_Print HDAE5000_FormatDialog_CodeDigit HDAE5000_UiObj_SetCaption
   v2.01i's utility page (the older handler):
   - switch 11 prints only four resources (LSW, SDA, PMT, SQF); v2.06i adds SEQ, CMP, TM, MSP, RCM and MD;
   - switch 9 (absent in v2.06i) formats the drive: "FORMAT TRY", "please wait", HDAE5000_HD_FormatDrive(1), then
     "FORMAT FINISHED" or "FORMAT ERROR" and "ERROR NO" + IToA(result).  The ROM compares arg with 11 first, then 9,
     and lays case 9's body first: the inner switch lists case 9 before case 11, as the outer one does;
   - the result is a byte local in QIZ, assigned in its condition: the ROM reloads it for the compare
     (`ld a,qizh; cp a,0`), as an assignment used as an operand does; round 1's separate statement gave
     `cp qizh,0` (run 2026-11-19-62, all else matched).  Form a plain local, form b `register`.
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern char *__cdecl HDAE5000_LToA(unsigned long, char *, int);
extern char *__cdecl HDAE5000_IToA(int, char *, int);

/* ---- this module (calr) ---- */
extern void HDAE5000_HardTest_HddIdRead(void);
extern void HDAE5000_HardTest_Print(char *line);

/* ---- other modules (call) ---- */
extern int HDAE5000_HD_FormatDrive(int ui);

/* ---- ROM ---- */
extern char HDAE5000_Str_UTIL[];
extern char HDAE5000_Str_FORMATTRY[], HDAE5000_Str_PleaseWait[], HDAE5000_Str_FORMATFINISHED[];
extern char HDAE5000_Str_FORMATERROR[], HDAE5000_Str_ERRORNO[];
extern char HDAE5000_Str_LSWFileInfo[], HDAE5000_Str_SDAFileInfo[], HDAE5000_Str_PMTFileInfo[];
extern char HDAE5000_Str_SQFFileInfo[];
extern char HDAE5000_Str_Adr[], HDAE5000_Str_Size[], HDAE5000_Str_Adr_HDD_UTIL_PAGE[];
extern char ram_2cac14[];   /* HDAE5000_Str_Size_HDD_UTIL_PAGE (its 31 characters are the _2 / _3 names' prefix) */
extern char ram_2cac36[], ram_2cac3e[];   /* HDAE5000_Str_Adr_HDD_UTIL_PAGE_2, HDAE5000_Str_Size_HDD_UTIL_PAGE_2 */
extern char ram_2cac60[], ram_2cac68[];   /* _3 */

long UtilPage_a(long obj, long ev, long arg)
{
    char line[64];
    char num[32];
    struct { unsigned long addr; unsigned long size; } info;
    unsigned char r;

    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_UTIL);
        return 0;
    case EVT_SW_IN:
        switch (arg) {
        case 9:
            HDAE5000_HardTest_Print(HDAE5000_Str_FORMATTRY);
            HDAE5000_HardTest_Print(HDAE5000_Str_PleaseWait);
            if ((r = HDAE5000_HD_FormatDrive(1)) == 0)
                HDAE5000_HardTest_Print(HDAE5000_Str_FORMATFINISHED);
            else {
                HDAE5000_HardTest_Print(HDAE5000_Str_FORMATERROR);
                HDAE5000_MemFill(line, 0, 64);
                HDAE5000_StrCpy(line, HDAE5000_Str_ERRORNO);
                HDAE5000_StrCat(line, HDAE5000_IToA(r, num, 10));
                HDAE5000_HardTest_Print(line);
            }
            break;
        case 0x0b:
            HDAE5000_HardTest_HddIdRead();

            CALLV(HAMA->GetResouceInfo)(0, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_LSWFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_Adr);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_Size);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(1, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_SDAFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_Adr_HDD_UTIL_PAGE);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2cac14);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(2, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_PMTFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2cac36);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2cac3e);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(3, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_SQFFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2cac60);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2cac68);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);
        }
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}


long UtilPage_b(long obj, long ev, long arg)
{
    char line[64];
    char num[32];
    struct { unsigned long addr; unsigned long size; } info;
    register unsigned char r;

    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_UTIL);
        return 0;
    case EVT_SW_IN:
        switch (arg) {
        case 9:
            HDAE5000_HardTest_Print(HDAE5000_Str_FORMATTRY);
            HDAE5000_HardTest_Print(HDAE5000_Str_PleaseWait);
            if ((r = HDAE5000_HD_FormatDrive(1)) == 0)
                HDAE5000_HardTest_Print(HDAE5000_Str_FORMATFINISHED);
            else {
                HDAE5000_HardTest_Print(HDAE5000_Str_FORMATERROR);
                HDAE5000_MemFill(line, 0, 64);
                HDAE5000_StrCpy(line, HDAE5000_Str_ERRORNO);
                HDAE5000_StrCat(line, HDAE5000_IToA(r, num, 10));
                HDAE5000_HardTest_Print(line);
            }
            break;
        case 0x0b:
            HDAE5000_HardTest_HddIdRead();

            CALLV(HAMA->GetResouceInfo)(0, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_LSWFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_Adr);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_Size);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(1, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_SDAFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_Adr_HDD_UTIL_PAGE);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2cac14);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(2, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_PMTFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2cac36);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2cac3e);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);

            CALLV(HAMA->GetResouceInfo)(3, (char *)&info);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, HDAE5000_Str_SQFFileInfo);
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2cac60);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.addr, num, 10));
            HDAE5000_HardTest_Print(line);
            HDAE5000_MemFill(line, 0, 64);
            HDAE5000_StrCpy(line, ram_2cac68);
            HDAE5000_StrCat(line, HDAE5000_LToA(info.size, num, 10));
            HDAE5000_HardTest_Print(line);
        }
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}
