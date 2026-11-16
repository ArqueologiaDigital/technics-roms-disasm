/* lane_hd round 4, helper h_small, group 4, form b: hd_r4_g4.c's functions (same names) with the page-text
   destinations as constant offsets into one array (`&ram_22b2f6[22]` ...) instead of separate ram_<hex> arrays,
   and CopyVersionString void (the ROM leaves StrLen's HL either way).
   cc900-name: SetupPage_BuildDriveInfo=HDAE5000_SetupPage_BuildDriveInfo */
#include "hdae_ws.h"
#include "hdae_ids.h"

struct HdGeom { unsigned int cyl; unsigned int heads; unsigned int spt; unsigned long usable; char model[42]; };
struct DiskUsage { unsigned long drive; unsigned long system; unsigned long data; unsigned long free; };

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, const char *, ...);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern char *__cdecl HDAE5000_IToA(int, char *, int);
extern void HDAE5000_HD_GetGeometry(struct HdGeom *);
extern void HDAE5000_HD_GetDiskUsage(struct DiskUsage *);
extern int HDAE5000_HD_StoreSettings(int);

extern unsigned char HDAE5000_RAM_WriteProtect;
extern char HDAE5000_DriveInfo_Template[];
extern float HDAE5000_Float_100_DriveInfo;
extern float HDAE5000_Float_100_DriveInfo_2;
extern float HDAE5000_Float_100_DriveInfo_3;
extern char ram_22b2f6[];   /* the drive-info page text; rows of 39 from +22 */
extern unsigned char ram_22ad9c[];   /* 10 bytes cleared by SetupP2SwCatch; HDAE5000_RAM_FormatCodeDigits at +2 */

#define FMT_61F_A ((const char *)0x2e2cbeL)   /* HDAE5000_Fmt_6_1f, "%6.1f" */
#define FMT_61F_B ((const char *)0x2e2cc4L)   /* HDAE5000_Fmt_6_1f_SetupPage_BuildDriveInfo */
#define FMT_61F_C ((const char *)0x2e2ccaL)   /* HDAE5000_Fmt_6_1f_SetupPage_BuildDriveInfo_2 */
#define VERSION ((char *)0x2e1c82L)          /* HDAE5000_Str_V206i, "V2.06i" */

void HDAE5000_CopyVersionString(char *dst);

void SetupPage_BuildDriveInfo(void)
{
    struct HdGeom geom;
    struct DiskUsage usage;
    char buf[16];

    HDAE5000_MemCopy(ram_22b2f6, HDAE5000_DriveInfo_Template, 0x139);
    HDAE5000_HD_GetGeometry(&geom);
    HDAE5000_MemCopy(&ram_22b2f6[22], geom.model, 16);
    HDAE5000_IToA(geom.cyl, buf, 10);
    HDAE5000_MemCopy(&ram_22b2f6[61], buf, HDAE5000_StrLen(buf));
    HDAE5000_IToA(geom.heads, buf, 10);
    HDAE5000_MemCopy(&ram_22b2f6[100], buf, HDAE5000_StrLen(buf));
    HDAE5000_IToA(geom.spt, buf, 10);
    HDAE5000_MemCopy(&ram_22b2f6[139], buf, HDAE5000_StrLen(buf));
    HDAE5000_HD_GetDiskUsage(&usage);
    HDAE5000_MemFill(buf, 0, 16);
    HDAE5000_SPrintf(buf, FMT_61F_A, usage.drive / HDAE5000_Float_100_DriveInfo);
    HDAE5000_MemCopy(&ram_22b2f6[178], buf, HDAE5000_StrLen(buf));
    HDAE5000_MemFill(buf, 0, 16);
    HDAE5000_SPrintf(buf, FMT_61F_B, usage.system / HDAE5000_Float_100_DriveInfo_2);
    HDAE5000_MemCopy(&ram_22b2f6[217], buf, HDAE5000_StrLen(buf));
    HDAE5000_MemFill(buf, 0, 16);
    HDAE5000_SPrintf(buf, FMT_61F_C, usage.free / HDAE5000_Float_100_DriveInfo_3);
    HDAE5000_MemCopy(&ram_22b2f6[256], buf, HDAE5000_StrLen(buf));
    HDAE5000_MemFill(buf, 0, 16);
    HDAE5000_CopyVersionString(buf);
    HDAE5000_MemCopy(&ram_22b2f6[295], buf, HDAE5000_StrLen(buf));
    CALLV(ROOT->ApPostEvent)(OBJ_HD_INFO_LIST, EVT_HDAE_SET_STR_ADR, ram_22b2f6);
    CALLV(ROOT->ApPostEvent)(OBJ_HD_INFO_LIST, EVT_PARA_DRAW, -1L);
}

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
            SetupPage_BuildDriveInfo();
            CALLV(ROOT->ApPostEvent)(OBJ_SETUP_HDINFO, EVT_SHOW, 0L);
            break;
        }
    }
    return 0;
}

void HDAE5000_CopyVersionString(char *dst)
{
    unsigned int i;
    for (i = 0; i < 7; i++)
        *dst++ = VERSION[i];
    HDAE5000_StrLen(VERSION);
}
