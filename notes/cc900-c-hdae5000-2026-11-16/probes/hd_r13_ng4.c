/* lane_hd round 13, helper h_near2, form a: HDAE5000_SetupPage_BuildDriveInfo, HDAE5000_SetupP2SwCatch,
   HDAE5000_CopyVersionString (one calr group, ROM address order), from hd_r4_g4.c.  Options: -Xr.
   cc900-module: HDAE5000_SetupPage_BuildDriveInfo HDAE5000_CopyVersionString
   cc900-name: SetupPage_BuildDriveInfo=HDAE5000_SetupPage_BuildDriveInfo
   SetupP2SwCatch matches (unchanged).  hd_r4_g4.c's reading of the hand source still applies.  Run 2026-11-16-59:
   - BuildDriveInfo (+238): only the three "%6.1f" formats (ROM `pushw Fmt@hi16 / pushw Fmt@lo16`, V4.23 `ld xwa,imm;
     push xwa` for the constant pointer) and the last ApPostEvent's text argument (ROM `lda xwa,(text); ld xde,xwa`,
     V4.23 `lda xde,(text)`) differ.  V4.23 pushes an array symbol as the pushw pair when the argument needs no
     conversion (hd_r9_nl's lyrics module): the formats are now char arrays and SPrintf's format parameter a plain
     char *; the text argument goes through the offset-0 member (WRAP, FdList_Clear's matched spelling);
   - CopyVersionString (+0): the loop variable is in IX in the ROM, in HL in V4.23, and the ROM pushes the string
     for StrLen as the pushw pair and reads it as `ld xde,Str; add xde,xbc` (V4.23 `add xbc,imm` for the constant
     pointer).  The string is now the tree's char array (StrLen(char *)), which also needs a base register in the
     loop: that may be what moves i out of XHL (the ROM uses XHL for the dst++ temporary).  Form b declares i
     `register` as well. */
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

int HDAE5000_CopyVersionString(char *dst)
{
    unsigned int i;
    for (i = 0; i < 7; i++)
        *dst++ = VERSION[i];
    return HDAE5000_StrLen(VERSION);
}
