/* Functions of hd-ae5000_v2_01i.s.  (hdae5000_small2_hd-ae5000_v2_01i.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_small2_hd-ae5000_v2_01i.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_TypeSel_Init HDAE5000_FlsRecord_Address HDAE5000_NameHistory_AfterPushNop
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct TypeSel { unsigned int mask; unsigned char flag[10]; };
struct NameHist { unsigned char count; unsigned char recall; unsigned char next; unsigned char pad; char names[5][27]; };
struct XapDesc { char tag[4]; long arg; long limit; long gap; long base; };

extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_IToA(int, char *, int);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern unsigned int __cdecl HDAE5000_StrLen(char *);
extern int __cdecl HDAE5000_StrNCmp(char *, char *, unsigned int);
extern int __cdecl HDAE5000_StrPrefixCmp(char *, char *);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int flag);
extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);
extern void HDAE5000_NameHistory_AfterPushNop(unsigned char *hist);
extern int HDAE5000_ATA_SoftReset_Status(void);
extern int HDAE5000_ATA_Standby_Status(void);
extern int HDAE5000_HD_ReadTables_Status(void);
extern int HDAE5000_HD_SaveSettings(void);
extern int HDAE5000_HD_Format(void);
extern int HDAE5000_HD_WriteFile(void *, unsigned long, void *);
extern int HDAE5000_HD_AppendFile(void *, unsigned long, void *);
extern int HDAE5000_RAM_XAP_FLASH_ENTRY();              /* the tree's .equ 0x23feb0: code in main-CPU RAM */

extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern struct TypeSel HDAE5000_RAM_DeleteOptions;
extern unsigned char HDAE5000_DelOpt_TemplateBlank[];
extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char ram_22ad9c[];                      /* [0] = digits typed; the digits from +2 */
extern unsigned char HDAE5000_RAM_FormatCodeDigits[];   /* ram_22ad9c + 2 */
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern long *HDAE5000_RAM_HdStreamSlot;
extern unsigned char HDAE5000_RAM_HdStreamState;

extern char HDAE5000_Fmt_2_2d[];
extern char HDAE5000_Str_HdFormatCode[];
extern char HDAE5000_Str_Track0RecoverCode[];
extern char HDAE5000_Str_XAP[];
extern char ram_2f8de0[];                               /* HDAE5000_Dir_IsBlankName_Str_Blank16 */
extern char ram_2f8df2[];                               /* HDAE5000_Fls_IsBlankName_Str_Blank16 */

/* ---- 0x28043c ---- */
long HDAE5000_AcWindowPage1Proc(long obj, long ev, long arg)
{
    if (ev == EVT_SHOW)
        CALLV(ROOT->SendEvent)(obj, EVT_SET_PAGE, 1L);
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}

/* ---- 0x2827a8 ---- */
long HDAE5000_HDTitleMenuProc(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_PARA_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(OBJ_HD_MENU_BMP, EVT_DRAW, 0L);
        return 0;
    }
}

/* ---- 0x282e3c ---- */
int HDAE5000_FdName_SongNumber(char *name)
{
    char buf[4];
    int i;

    for (i = 1; i <= 20; i++) {
        HDAE5000_SPrintf(buf, HDAE5000_Fmt_2_2d, i);
        if (HDAE5000_StrNCmp(buf, name, HDAE5000_StrLen(buf)) == 0)
            return i - 1;
    }
    return -1;
}

/* ---- 0x2865de ---- */

/* ---- 0x28a5d3 ---- */

/* ---- 0x28b33e ---- */
/* the history: +0 count (up to 5), +1 recall index, +2 next slot, +4 five names of 27 */

/* ---- 0x28f308 ---- */

/* ---- 0x28f90c ---- */

/* ---- 0x28f9ad ---- */

/* ---- 0x28fae9 ---- */

/* ---- 0x293e88 ---- */

/* ---- 0x293f3c ---- */

/* ---- 0x29429e ---- */
