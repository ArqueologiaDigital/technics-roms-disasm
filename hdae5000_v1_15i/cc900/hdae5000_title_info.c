/* Functions of hdae5000_hd_driver.s.  (hdae5000_title_info.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_title_info.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_TitleInfo_Build
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct DiskUsage { unsigned long drive; unsigned long system; unsigned long data; unsigned long free; };

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern void HDAE5000_HD_GetDiskUsage(struct DiskUsage *);

extern unsigned char HDAE5000_RAM_WriteProtect;
extern unsigned char HDAE5000_RAM_WriteConfirm;
extern unsigned char HDAE5000_RAM_LoadByNumberMode;
extern unsigned char HDAE5000_RAM_QuickLoadMode;
extern unsigned char HDAE5000_RAM_JumpAfterLoad;
extern char HDAE5000_RAM_TitleInfoText[];
extern char HDAE5000_TitleInfo_Template[];
extern char *HDAE5000_TextPtrs_OFF_ON[];
extern char HDAE5000_Str_HDAE[];
extern char ram_22ad72[], ram_22ada4[], ram_22add6[], ram_22ad89[], ram_22adbb[], ram_22aded[];

/* the formats as the tree's char arrays: pushed as `pushw sym@hi16 / pushw sym@lo16` (see the header);
   HDAE5000_Fmt_d_TitleInfo_Build_2 is over 31 characters and spelled by its address */
extern char HDAE5000_Fmt_s[];
extern char HDAE5000_Fmt_s_TitleInfo_Build[];
extern char HDAE5000_Fmt_d[];
extern char HDAE5000_Fmt_d_TitleInfo_Build[];
extern char ram_2caaec[];   /* HDAE5000_Fmt_d_TitleInfo_Build_2 */
extern char HDAE5000_Fmt_4ldMB[];
#define FMT_S_A HDAE5000_Fmt_s
#define FMT_S_B HDAE5000_Fmt_s_TitleInfo_Build
#define FMT_D_A HDAE5000_Fmt_d
#define FMT_D_B HDAE5000_Fmt_d_TitleInfo_Build
#define FMT_D_C ram_2caaec
#define FMT_MB HDAE5000_Fmt_4ldMB
/* an array read as an lvalue member at offset 0 (hd_r9_b2.c FdList_Clear: `lda xwa,(sym); ld xde,xwa`) */
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)

void HDAE5000_TitleInfo_Build(void)
{
    struct DiskUsage usage;
    char s[16];

    HDAE5000_MemCopy(HDAE5000_RAM_TitleInfoText, HDAE5000_TitleInfo_Template, 0x97);
    HDAE5000_SPrintf(s, FMT_S_A, HDAE5000_TextPtrs_OFF_ON[HDAE5000_RAM_WriteProtect]);
    HDAE5000_MemCopy(ram_22ad72, s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_S_B, HDAE5000_TextPtrs_OFF_ON[HDAE5000_RAM_WriteConfirm]);
    HDAE5000_MemCopy(ram_22ada4, s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_D_A, HDAE5000_RAM_LoadByNumberMode);
    HDAE5000_MemCopy(ram_22add6, s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_D_B, HDAE5000_RAM_QuickLoadMode);
    HDAE5000_MemCopy(ram_22ad89, s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_D_C, HDAE5000_RAM_JumpAfterLoad);
    HDAE5000_MemCopy(ram_22adbb, s, HDAE5000_StrLen(s));
    HDAE5000_HD_GetDiskUsage(&usage);
    HDAE5000_SPrintf(s, FMT_MB, usage.free / 100);
    HDAE5000_MemCopy(ram_22aded, s, HDAE5000_StrLen(s));
    CALLV(ROOT->SendEvent)(OBJ_HARD_DISK_OPT, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_TitleInfoText));
    CALLV(ROOT->SendEvent)(OBJ_HARD_DISK_OPT, EVT_PARA_DRAW, -1L);
}

long HDAE5000_HdTitleEventCatch(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        HDAE5000_TitleInfo_Build();
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_HDAE);
        return 0;
    }
}
