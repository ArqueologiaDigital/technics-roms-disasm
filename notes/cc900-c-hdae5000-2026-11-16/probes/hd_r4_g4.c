/* lane_hd round 4, helper h_small, group 4 (one calr group = one module), in ROM address order:
   HDAE5000_SetupPage_BuildDriveInfo, HDAE5000_SetupP2SwCatch, HDAE5000_CopyVersionString.  Options: -Xr.
   cc900-name: SetupPage_BuildDriveInfo=HDAE5000_SetupPage_BuildDriveInfo
   Reading of the hand source:
   - BuildDriveInfo's frame (108 B): the geometry record at +56 (52 B: cylinders, heads, sectors per track, usable
     sectors, 42-byte model), the disk usage at +40 (four longs: drive, system, data, free, in 10,000-byte units),
     a 16-byte text buffer at +24, and the float / double temporaries of the three `/ 100.0` at +12 / +16 (V4.23's
     own, ULongToFloat, FloatDiv, FloatToDouble).  Locals are declared highest address first (round 3).
   - The three 100.0f operands are separate ROM constants (one per literal in the original); written as the
     tree's extern floats so that FloatDiv gets `lda xde,(sym)`.  The "%6.1f" formats are stacked constants
     (`pushw hi16/lo16`): constant pointers.
   - The page text (0x22b2f6, 0x139 bytes copied from HDAE5000_DriveInfo_Template) is addressed with `lda` at fixed
     offsets: written as ram_<hex> arrays (form b: offsets into one array).
   - SetupP2SwCatch: its switch's compares 0x0c, 0x09, 0x8c and bodies 0x8c, 0x09, 0x0c fit V4.23's reverse-source-
     order compares (AttenCpToHDSwCatch, run 49), so the source order is 0x8c, 9, 0x0c.
   - CopyVersionString: `*dst++` on the left is evaluated first (`lda xhl,(xwa+:1)`); the version string is
     indexed with `ld xde, imm` and pushed as a constant: a constant pointer. */
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
extern char ram_22b30c[], ram_22b333[], ram_22b35a[], ram_22b381[], ram_22b3a8[], ram_22b3cf[], ram_22b3f6[],
    ram_22b41d[];
extern unsigned char ram_22ad9c[];   /* 10 bytes cleared by SetupP2SwCatch; HDAE5000_RAM_FormatCodeDigits at +2 */

#define FMT_61F_A ((const char *)0x2e2cbeL)   /* HDAE5000_Fmt_6_1f, "%6.1f" */
#define FMT_61F_B ((const char *)0x2e2cc4L)   /* HDAE5000_Fmt_6_1f_SetupPage_BuildDriveInfo */
#define FMT_61F_C ((const char *)0x2e2ccaL)   /* HDAE5000_Fmt_6_1f_SetupPage_BuildDriveInfo_2 */
#define VERSION ((char *)0x2e1c82L)          /* HDAE5000_Str_V206i, "V2.06i" */

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

int HDAE5000_CopyVersionString(char *dst)
{
    unsigned int i;
    for (i = 0; i < 7; i++)
        *dst++ = VERSION[i];
    return HDAE5000_StrLen(VERSION);
}
