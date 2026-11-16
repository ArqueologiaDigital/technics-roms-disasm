/* The setup-page module (SETUP_TOOLS_P2) of hdae5000: the functions that match.
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r13_ng4.c.
   cc900-options: -Xr
   cc900-name: SetupPage_BuildDriveInfo=HDAE5000_SetupPage_BuildDriveInfo
   cc900-module: HDAE5000_SetupPage_BuildDriveInfo HDAE5000_CopyVersionString
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct HdGeom { unsigned int cyl; unsigned int heads; unsigned int spt; unsigned long usable; char model[42]; };
struct DiskUsage { unsigned long drive; unsigned long system; unsigned long data; unsigned long free; };

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern unsigned int __cdecl HDAE5000_StrLen(char *);
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
extern char ram_22b30c[], ram_22b333[], ram_22b35a[], ram_22b381[], ram_22b3a8[], ram_22b3cf[], ram_22b3f6[],
    ram_22b41d[];
extern unsigned char ram_22ad9c[];   /* 10 bytes cleared by SetupP2SwCatch; HDAE5000_RAM_FormatCodeDigits at +2 */

/* the "%6.1f" formats and the version string as the tree's char arrays (pushw sym@hi16 / @lo16, see the header);
   the two longer labels share their first 31 characters, so they are spelled as ram_<hex> (the address) */
extern char HDAE5000_Fmt_6_1f[];
extern char ram_2e2cc4[];   /* HDAE5000_Fmt_6_1f_SetupPage_BuildDriveInfo */
extern char ram_2e2cca[];   /* HDAE5000_Fmt_6_1f_SetupPage_BuildDriveInfo_2 */
extern char HDAE5000_Str_V206i[];   /* "V2.06i" */
#define FMT_61F_A HDAE5000_Fmt_6_1f
#define FMT_61F_B ram_2e2cc4
#define FMT_61F_C ram_2e2cca
#define VERSION HDAE5000_Str_V206i
/* an array read as an lvalue member at offset 0 (hd_r9_b2.c FdList_Clear: `lda xwa,(sym); ld xde,xwa`) */
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)

int HDAE5000_CopyVersionString(char *dst);

void SetupPage_BuildDriveInfo(void)
{
    struct HdGeom geom;
    struct DiskUsage usage;
    char buf[16];

    HDAE5000_MemCopy(ram_22b2f6, HDAE5000_DriveInfo_Template, 0x139);
    HDAE5000_HD_GetGeometry(&geom);
    HDAE5000_MemCopy(ram_22b30c, geom.model, 16);
    HDAE5000_IToA(geom.cyl, buf, 10);
    HDAE5000_MemCopy(ram_22b333, buf, HDAE5000_StrLen(buf));
    HDAE5000_IToA(geom.heads, buf, 10);
    HDAE5000_MemCopy(ram_22b35a, buf, HDAE5000_StrLen(buf));
    HDAE5000_IToA(geom.spt, buf, 10);
    HDAE5000_MemCopy(ram_22b381, buf, HDAE5000_StrLen(buf));
    HDAE5000_HD_GetDiskUsage(&usage);
    HDAE5000_MemFill(buf, 0, 16);
    HDAE5000_SPrintf(buf, FMT_61F_A, usage.drive / HDAE5000_Float_100_DriveInfo);
    HDAE5000_MemCopy(ram_22b3a8, buf, HDAE5000_StrLen(buf));
    HDAE5000_MemFill(buf, 0, 16);
    HDAE5000_SPrintf(buf, FMT_61F_B, usage.system / HDAE5000_Float_100_DriveInfo_2);
    HDAE5000_MemCopy(ram_22b3cf, buf, HDAE5000_StrLen(buf));
    HDAE5000_MemFill(buf, 0, 16);
    HDAE5000_SPrintf(buf, FMT_61F_C, usage.free / HDAE5000_Float_100_DriveInfo_3);
    HDAE5000_MemCopy(ram_22b3f6, buf, HDAE5000_StrLen(buf));
    HDAE5000_MemFill(buf, 0, 16);
    HDAE5000_CopyVersionString(buf);
    HDAE5000_MemCopy(ram_22b41d, buf, HDAE5000_StrLen(buf));
    CALLV(ROOT->ApPostEvent)(OBJ_HD_INFO_LIST, EVT_HDAE_SET_STR_ADR, WRAP(ram_22b2f6));
    CALLV(ROOT->ApPostEvent)(OBJ_HD_INFO_LIST, EVT_PARA_DRAW, -1L);
}

int HDAE5000_CopyVersionString(char *dst)
{
    unsigned int i;
    for (i = 0; i < 7; i++)
        *dst++ = VERSION[i];
    return HDAE5000_StrLen(VERSION);
}
