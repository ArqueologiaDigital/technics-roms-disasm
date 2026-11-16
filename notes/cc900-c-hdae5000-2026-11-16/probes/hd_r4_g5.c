/* lane_hd round 4, helper h_small, group 5 (one calr group = one module), in ROM address order:
   HDAE5000_TitleInfo_Build, HDAE5000_HdTitleEventCatch.  Options: -Xr.
   Reading of the hand source:
   - TitleInfo_Build's frame (32 B): the disk usage record at +16 (four longs; +12 = free), a 6-byte text at +10 for
     the "%s" / "%d" settings and a 10-byte text at +0 for "%4ldMB"; locals declared highest address first.
   - The title text HDAE5000_RAM_TitleInfoText (0x22ada6, 0x97 bytes from HDAE5000_TitleInfo_Template) is three
     50-byte rows with values at +20 and +43: WRITE PROTECT +20, WRITE CONFIRM +70, LOAD BY NUMBER +120, QUICK LOAD +43,
     JUMP AFTER LOAD +93, free space +143.  Each destination is an `lda` of a fixed address: ram_<hex> arrays
     (form b: offsets into the named array).
   - OFF/ON texts: HDAE5000_TextPtrs_OFF_ON[byte] (`lda xbc,(sym); ld xwa,(xbc+wa)` with an int index);
     formats pushed as 32-bit constants (`pushw hi16/lo16`): constant pointers.
   - usage.free / 100 is the library's unsigned 32-bit divide (HDAE5000_UDivMod32).
   - HdTitleEventCatch: compares DRAW then ARE_YOU_CLASS_PROC, default body first, then ARE_YOU, then DRAW: V4.23's
     reverse-source-order compares with `default:` written first (hd_r3_la AttenCpToHDSwCatch, run 49). */
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
extern char ram_22adba[], ram_22adec[], ram_22ae1e[], ram_22add1[], ram_22ae03[], ram_22ae35[];

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
    HDAE5000_MemCopy(ram_22adba, s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_S_B, HDAE5000_TextPtrs_OFF_ON[HDAE5000_RAM_WriteConfirm]);
    HDAE5000_MemCopy(ram_22adec, s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_D_A, HDAE5000_RAM_LoadByNumberMode);
    HDAE5000_MemCopy(ram_22ae1e, s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_D_B, HDAE5000_RAM_QuickLoadMode);
    HDAE5000_MemCopy(ram_22add1, s, HDAE5000_StrLen(s));
    HDAE5000_SPrintf(s, FMT_D_C, HDAE5000_RAM_JumpAfterLoad);
    HDAE5000_MemCopy(ram_22ae03, s, HDAE5000_StrLen(s));
    HDAE5000_HD_GetDiskUsage(&usage);
    HDAE5000_SPrintf(mb, FMT_MB, usage.free / 100);
    HDAE5000_MemCopy(ram_22ae35, mb, HDAE5000_StrLen(mb));
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
