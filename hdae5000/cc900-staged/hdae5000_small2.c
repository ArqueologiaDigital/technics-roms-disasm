/* Small functions of several modules.
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r39_m4b.c.
   cc900-options: -Xr
   cc900-name: NameHistPush_s=HDAE5000_NameHistory_Push
   cc900-name: PP_Svc28=HDAE5000_PPORT_Svc28_FlashXapFile
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
void HDAE5000_DelOpt_InitFromSong(unsigned int dir, unsigned int song, int all)
{
    unsigned int m;

    if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
        HDAE5000_TypeSel_Init(&HDAE5000_RAM_DeleteOptions, m, HDAE5000_DelOpt_TemplateBlank, 2);
    else
        HDAE5000_TypeSel_Init(&HDAE5000_RAM_DeleteOptions, 0, HDAE5000_DelOpt_TemplateBlank, 2);
    HDAE5000_RAM_DeleteOptions.mask = 0;
}

/* ---- 0x28b33e ---- */
/* the history: +0 count (up to 5), +1 recall index, +2 next slot, +4 five names of 27 */

void NameHistPush_s(struct NameHist *hist, char *name)
{
    HDAE5000_StrCpy(hist->names[hist->next], name);
    hist->recall = hist->next;
    if (++hist->next >= 5)
        hist->next = 0;
    if (hist->count < 5)
        hist->count++;
    HDAE5000_NameHistory_AfterPushNop((unsigned char *)hist);
}

/* ---- 0x28f308 ---- */
void PP_Svc28(long a, long b)
{
    struct XapDesc d;

    HDAE5000_StrCpy(d.tag, HDAE5000_Str_XAP);
    d.arg = b;
    d.base = 0x280000L;
    d.limit = 0x2f0000L;
    HDAE5000_RAM_XAP_FLASH_ENTRY(a, *(long *)d.tag);
}

/* ---- 0x28f90c ---- */
int HDAE5000_HD_FormatDrive(int sleep)
{
    int st;

    CALLV(HAMA->PlayHalt)(1);
    if (sleep == 1)
        CALLV(ROOT->SleepMainTask)();
    st = HDAE5000_HD_Format();
    if (sleep == 1)
        CALLV(ROOT->WakeUpMainTask)();
    CALLV(HAMA->PlayStandBy)();
    CALLV(HAMA->EditSwRefresh)();
    return st;
}

/* ---- 0x28f9ad ---- */
int HDAE5000_Dir_IsBlankName(unsigned int dir)
{
    int ret = 0;

    if (HDAE5000_StrNCmp(&HDAE5000_RAM_DirNames[(unsigned long)dir * 16], ram_2f8de0, HDAE5000_StrLen(ram_2f8de0)) == 0)
        ret = -1;
    return ret;
}

/* ---- 0x28fae9 ---- */
unsigned int HDAE5000_Fls_IsBlankName(unsigned int fls)
{
    unsigned int ret = 0;

    if (HDAE5000_StrNCmp(HDAE5000_FlsRecord_Address(fls), ram_2f8df2, HDAE5000_StrLen(ram_2f8df2)) == 0)
        ret = 0xffff;
    return ret;
}

/* ---- 0x293e88 ---- */
int HDAE5000_HD_LoadTables(int keep)
{
    int st;

    CALLV(HAMA->PlayHalt)(1);
    st = HDAE5000_ATA_SoftReset_Status();
    st |= HDAE5000_HD_ReadTables_Status();
    if (keep != 1)
        st |= HDAE5000_ATA_Standby_Status();
    CALLV(HAMA->PlayStandBy)();
    CALLV(HAMA->EditSwRefresh)();
    return st;
}

/* ---- 0x293f3c ---- */
int HDAE5000_HD_StoreSettings(int keep)
{
    int st;

    CALLV(HAMA->PlayHalt)(1);
    st = HDAE5000_ATA_SoftReset_Status();
    st |= HDAE5000_HD_SaveSettings();
    if (keep != 1)
        st |= HDAE5000_ATA_Standby_Status();
    CALLV(HAMA->PlayStandBy)();
    CALLV(HAMA->EditSwRefresh)();
    return st;
}

/* ---- 0x29429e ---- */
void HDAE5000_HD_WriteClose(void)
{
    if (HDAE5000_RAM_HdStreamBuffer != HDAE5000_RAM_HdStreamFill) {
        if (HDAE5000_RAM_HdStreamState == 1) {
            HDAE5000_HD_WriteFile(HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamSlot);
            HDAE5000_RAM_HdStreamState = 2;
        } else {
            HDAE5000_HD_AppendFile(HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamSlot);
        }
    }
    HDAE5000_RAM_HdStreamState = 0;
}
