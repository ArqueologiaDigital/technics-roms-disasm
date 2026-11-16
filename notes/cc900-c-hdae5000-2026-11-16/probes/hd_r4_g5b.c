/* lane_hd round 4, helper h_small, group 5, form b: hd_r4_g5.c's functions (same names) with the title-text
   destinations as constant offsets into HDAE5000_RAM_TitleInfoText (`&HDAE5000_RAM_TitleInfoText[20]` ...)
   instead of separate ram_<hex> arrays, and the free space divided by 100L. */
#include "hdae_ws.h"
#include "hdae_ids.h"

struct DiskUsage { unsigned long drive; unsigned long system; unsigned long data; unsigned long free; };

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, const char *, ...);
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

#define FMT_S_A ((const char *)0x2e235cL)   /* HDAE5000_Fmt_s, "%s" */
#define FMT_S_B ((const char *)0x2e2360L)   /* HDAE5000_Fmt_s_TitleInfo_Build */
#define FMT_D_A ((const char *)0x2e2364L)   /* HDAE5000_Fmt_d */
#define FMT_D_B ((const char *)0x2e236aL)   /* HDAE5000_Fmt_d_TitleInfo_Build */
#define FMT_D_C ((const char *)0x2e2372L)   /* HDAE5000_Fmt_d_TitleInfo_Build_2 */
#define FMT_MB ((const char *)0x2e237aL)    /* HDAE5000_Fmt_4ldMB, "%4ldMB" */

void HDAE5000_TitleInfo_Build(void)
{
    struct DiskUsage usage;
    char s[6];
    char mb[10];

    HDAE5000_MemCopy(HDAE5000_RAM_TitleInfoText, HDAE5000_TitleInfo_Template, 0x97);
    HDAE5000_SPrintf(s, FMT_S_A, HDAE5000_TextPtrs_OFF_ON[HDAE5000_RAM_WriteProtect]);
    HDAE5000_MemCopy(&HDAE5000_RAM_TitleInfoText[20], s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_S_B, HDAE5000_TextPtrs_OFF_ON[HDAE5000_RAM_WriteConfirm]);
    HDAE5000_MemCopy(&HDAE5000_RAM_TitleInfoText[70], s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_D_A, HDAE5000_RAM_LoadByNumberMode);
    HDAE5000_MemCopy(&HDAE5000_RAM_TitleInfoText[120], s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_D_B, HDAE5000_RAM_QuickLoadMode);
    HDAE5000_MemCopy(&HDAE5000_RAM_TitleInfoText[43], s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_D_C, HDAE5000_RAM_JumpAfterLoad);
    HDAE5000_MemCopy(&HDAE5000_RAM_TitleInfoText[93], s, HDAE5000_StrLen(s));
    HDAE5000_HD_GetDiskUsage(&usage);
    HDAE5000_SPrintf(mb, FMT_MB, usage.free / 100L);
    HDAE5000_MemCopy(&HDAE5000_RAM_TitleInfoText[143], mb, HDAE5000_StrLen(mb));
    CALLV(ROOT->SendEvent)(OBJ_HARD_DISK_OPT, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_TitleInfoText);
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
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, HDAE5000_Str_HDAE);
        return 0;
    }
}
