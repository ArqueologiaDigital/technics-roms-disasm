/* lane_hd round 13, helper h_near2, form a: HDAE5000_TitleInfo_Build, HDAE5000_HdTitleEventCatch (one calr group,
   ROM address order), from hd_r4_g5.c.  Options: -Xr.
   cc900-module: HDAE5000_TitleInfo_Build
   hd_r4_g5.c's reading still applies except the frame.  Run 2026-11-16-59:
   - TitleInfo_Build (+43): the six formats (ROM `pushw Fmt@hi16 / pushw Fmt@lo16`, V4.23 `ld xwa,imm; push xwa` for
     a constant pointer): now the tree's char arrays with SPrintf's format parameter a plain char *, the pushw pair
     V4.23 gives an array symbol that needs no conversion (hd_r9_nl's lyrics module);
     the frame: the ROM writes every value, "%s" / "%d" and "%4ldMB" alike, to the same 16 bytes at +0 (usage at
     +16); run 59's two buffers put the 6-byte one at +10.  Now one char buf[16] (named s);
     the last SendEvent's text: ROM `lda xwa,(Text); ld xde,xwa`, V4.23 `lda xde,(Text)`: through the offset-0
     member (WRAP, FdList_Clear's matched spelling);
   - HdTitleEventCatch (+55, the jr after TitleInfo_Build's calr): the PARA_DRAW string is evaluated first in the ROM
     (`lda xwa,(Str_HDAE); ld xbc,xwa ... ld xde,xbc`): (long)Str, AttenCpToHDSwCatch's matched spelling. */
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
extern char ram_22adba[], ram_22adec[], ram_22ae1e[], ram_22add1[], ram_22ae03[], ram_22ae35[];

/* the formats as the tree's char arrays: pushed as `pushw sym@hi16 / pushw sym@lo16` (see the header);
   HDAE5000_Fmt_d_TitleInfo_Build_2 is over 31 characters and spelled by its address */
extern char HDAE5000_Fmt_s[];
extern char HDAE5000_Fmt_s_TitleInfo_Build[];
extern char HDAE5000_Fmt_d[];
extern char HDAE5000_Fmt_d_TitleInfo_Build[];
extern char ram_2e2372[];   /* HDAE5000_Fmt_d_TitleInfo_Build_2 */
extern char HDAE5000_Fmt_4ldMB[];
#define FMT_S_A HDAE5000_Fmt_s
#define FMT_S_B HDAE5000_Fmt_s_TitleInfo_Build
#define FMT_D_A HDAE5000_Fmt_d
#define FMT_D_B HDAE5000_Fmt_d_TitleInfo_Build
#define FMT_D_C ram_2e2372
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
    HDAE5000_SPrintf(s, FMT_MB, usage.free / 100);
    HDAE5000_MemCopy(ram_22ae35, s, HDAE5000_StrLen(s));
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
