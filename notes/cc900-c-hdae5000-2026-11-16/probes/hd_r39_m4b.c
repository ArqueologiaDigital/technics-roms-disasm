/* lane_hd round 39, helper h_m4, file b: thirteen functions that call nothing of their own in this file, in ROM
   address order, each with variants (cc900-name aliases):
   HDAE5000_AcWindowPage1Proc, HDAE5000_HDTitleMenuProc, HDAE5000_FdName_SongNumber, HDAE5000_FormatDialog_CodeDigit,
   HDAE5000_DelOpt_InitFromSong, HDAE5000_NameHistory_Push, HDAE5000_PPORT_Svc28_FlashXapFile,
   HDAE5000_HD_FormatDrive, HDAE5000_Dir_IsBlankName, HDAE5000_Fls_IsBlankName, HDAE5000_HD_LoadTables,
   HDAE5000_HD_StoreSettings, HDAE5000_HD_WriteClose.
   Left out: HDAE5000_PPI_LoopbackByte, hand assembly (see the report: `set 4,a` / `res 7,a` on a register, the byte
   kept in L and returned in L by two `ld l,..; ret` ends, a dead `ld xwa,1000` that overwrites the accumulator).
   cc900-options: -Xr
   cc900-module: HDAE5000_TypeSel_Init HDAE5000_FlsRecord_Address HDAE5000_NameHistory_AfterPushNop
   cc900-name: AcWinPage1_s=HDAE5000_AcWindowPage1Proc
   cc900-name: AcWinPage1_d=HDAE5000_AcWindowPage1Proc
   cc900-name: HDTitleMenu_i=HDAE5000_HDTitleMenuProc
   cc900-name: HDTitleMenu_c=HDAE5000_HDTitleMenuProc
   cc900-name: FdNameNum_r=HDAE5000_FdName_SongNumber
   cc900-name: CodeDigit_l=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_p=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_s=HDAE5000_FormatDialog_CodeDigit
   cc900-name: DelOptInit_v=HDAE5000_DelOpt_InitFromSong
   cc900-name: DelOptInit_i=HDAE5000_DelOpt_InitFromSong
   cc900-name: NameHistPush_s=HDAE5000_NameHistory_Push
   cc900-name: NameHistPush_p=HDAE5000_NameHistory_Push
   cc900-name: NameHistPush_q=HDAE5000_NameHistory_Push
   cc900-name: PP_Svc28=HDAE5000_PPORT_Svc28_FlashXapFile
   cc900-name: PP_Svc28_l=HDAE5000_PPORT_Svc28_FlashXapFile
   cc900-name: PP_Svc28_r=HDAE5000_PPORT_Svc28_FlashXapFile
   cc900-name: HdFormatDrive_d=HDAE5000_HD_FormatDrive
   cc900-name: DirIsBlank_u=HDAE5000_Dir_IsBlankName
   cc900-name: DirIsBlank_n=HDAE5000_Dir_IsBlankName
   cc900-name: FlsIsBlank_i=HDAE5000_Fls_IsBlankName
   cc900-name: FlsIsBlank_n=HDAE5000_Fls_IsBlankName
   cc900-name: FlsIsBlank_s=HDAE5000_Fls_IsBlankName
   cc900-name: WrClose_c=HDAE5000_HD_WriteClose
   cc900-name: WrClose_l=HDAE5000_HD_WriteClose
   Reading of the hand source, per function (first C for all but CodeDigit and WriteClose):
   - AcWindowPage1Proc (obj, ev, arg): obj in XIZ, ev at xsp+8, arg at xsp+4; `ev == EVT_SHOW` sends EVT_SET_PAGE 1,
     then InheritedProc's result is returned (`call (xix)`, frame, no tail jump).  Main: an `if`; _s: a one-case
     switch with break; _d: the same with an explicit empty default.
   - HDTitleMenuProc: no frame, the three parameters stay in XWA / XBC / XDE; the event is copied to XHL (a switch
     value); the body laid out first is InheritedProc as a tail jump (`jp (xix)`: V4.23 -Xr wrote `jp (xhl)` for
     the staged HDAE5000_HardTest_Print), so the switch has `default:` first, as the matched ErrMsgTimerCatch.
     _i: an `if (ev != EVT_PARA_DRAW) return ...;` instead; _c: the switch with the case first and default last.
   - FdName_SongNumber (name): char buf[4] at xsp+2, name at xsp+6, i in IZ, a signed for loop 1..20; the three
     __cdecl calls are cleaned up together (`add xsp,0x18`); `return i - 1` from inside the loop, -1 after it.
     _r: the result through a local.
   - FormatDialog_CodeDigit (run 2026-11-16-60-hd-r9a, hd_r9_b1.c: ERR-resolve, the two codes were string literals,
     i.e. V4.23's own data).  Real differences read in the listing: (1) the codes: now extern arrays passed to a
     plain `char *` parameter (pushed as constants, no data of the compiler's); the first argument keeps its
     `lda / push` through a conversion (unsigned char array cast to char *); (2) the digit index: V4.23 added 2 in
     byte width (`inc 2,a; ld c,a; extz bc`), the ROM widens first (`extz wa; ld bc,wa; inc 2,bc`).  Main: the count
     cast to unsigned int before `+ 2`; _l: a local index (`i = count; i += 2;`); _p: pointer arithmetic
     `*(base + count + 2)`; _s: the count cast to (int).
   - DelOpt_InitFromSong: as the matched LBNLoadSwCatch's EVT_SHOW body (drv module): `(m = Song_PartMask(..)) !=
     0xffff` with an unsigned m gives `ld wa,hl; cp wa,0xffff` and the late `ld bc,hl`; then the mask word cleared.
     Main has the three (unused) parameters of the drv module's declaration; _v is (void); _i has `int m`.
   - NameHistory_Push (hist, name): hist in XIZ; StrCpy's destination is hist + (next * 27 + 4) with the sum in
     16 bits (`muls wa,27; inc 4,wa; exts xwa; add xwa,xiz`); `++next >= 5` through the member's address.  Main: a
     flat unsigned char history indexed `[hist[2] * 27 + 4]`; _s: a structure with names[5][27]; _p: pointer plus
     parenthesised int; _q: the post-increment form.  (hd_r39_m4c.c has the no-cast form with another StrCpy
     prototype.)
   - PPORT_Svc28_FlashXapFile (a, b): a 20-byte descriptor at xsp+4 (tag "XAP", b, limit 0x2f0000, a gap, base
     0x280000), b kept in XIZ over StrCpy, a in a stack slot; the routine at RAM 0x23feb0 gets a and the
     descriptor's first long BY VALUE (`ld xbc,(xsp+4)`).  Main: a structure and `*(long *)d.tag`; _l: `long d[5]`;
     _r: returns the routine's result.
   - HD_FormatDrive (sleep): the HD_StoreTables pattern with Sleep / WakeUp around HD_Format; sleep in IZ, the
     result in the frame slot.  _d: the result declared `unsigned int`.
   - Dir_IsBlankName / Fls_IsBlankName: StrNCmp(name address, blank, StrLen(blank)) nested; result 0 / -1.  Dir keeps
     the result in QIZ (`push xiz`), Fls in a frame slot (`pushw iz`): the difference is guessed to be the result's
     type (the r36 idiom: `int` uses all of XIZ, `unsigned int` does not), so Dir main is `int ret`, Fls main
     `unsigned int ret`; the variants swap that (_u, _i), take the parameter as int (_n) or, for Fls, compare
     through a local length (_s).
   - HD_LoadTables / HD_StoreSettings: HD_StoreTables' matched C with another middle call.
   - HD_WriteClose (best run 2026-11-16-74-hd-r13, hd_r13_nab.c, 91.9 %).  Two real differences, one cause: the
     early copy of the buffer address is in XHL in the ROM (XDE in ours), so the ROM loads XDE before it moves XHL
     back to XWA (ours had to free XDE first).  Guess: the ROM's third argument is converted too, which reserves
     XDE.  Here the callees have a prototype (void *, unsigned long, void *): main passes the unsigned char array
     and the `long *` slot unconverted in the source (two implicit conversions); _c: explicit `(void *)` casts;
     _l: the address through a local.  hd_r39_m4c.c tries the unprototyped spellings.  Unsure of all of them. */
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

long AcWinPage1_s(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_SHOW:
        CALLV(ROOT->SendEvent)(obj, EVT_SET_PAGE, 1L);
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}

long AcWinPage1_d(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_SHOW:
        CALLV(ROOT->SendEvent)(obj, EVT_SET_PAGE, 1L);
        break;
    default:
        break;
    }
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

long HDTitleMenu_i(long obj, long ev, long arg)
{
    if (ev != EVT_PARA_DRAW)
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    CALLV(ROOT->InheritedProc)(obj, ev, arg);
    CALLV(ROOT->SendEvent)(OBJ_HD_MENU_BMP, EVT_DRAW, 0L);
    return 0;
}

long HDTitleMenu_c(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_PARA_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(OBJ_HD_MENU_BMP, EVT_DRAW, 0L);
        return 0;
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
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

int FdNameNum_r(char *name)
{
    char buf[4];
    int i;

    for (i = 1; i <= 20; i++) {
        HDAE5000_SPrintf(buf, HDAE5000_Fmt_2_2d, i);
        if (HDAE5000_StrNCmp(buf, name, HDAE5000_StrLen(buf)) == 0) {
            i--;
            return i;
        }
    }
    return -1;
}

/* ---- 0x2865de ---- */
int HDAE5000_FormatDialog_CodeDigit(int digit)
{
    int ret;
    char buf[8];

    HDAE5000_IToA(digit, buf, 10);
    ram_22ad9c[(unsigned int)ram_22ad9c[0] + 2] = buf[0];
    ram_22ad9c[0]++;
    if (ram_22ad9c[0] == 6) {
        if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_HdFormatCode) == 0)
            ret = 2;
        else if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_Track0RecoverCode) == 0)
            ret = 3;
        else
            ret = 1;
        HDAE5000_MemFill(ram_22ad9c, 0, 10);
    } else {
        ret = 0;
    }
    return ret;
}

int CodeDigit_l(int digit)
{
    int ret;
    char buf[8];
    unsigned int i;

    HDAE5000_IToA(digit, buf, 10);
    i = ram_22ad9c[0];
    i += 2;
    ram_22ad9c[i] = buf[0];
    ram_22ad9c[0]++;
    if (ram_22ad9c[0] == 6) {
        if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_HdFormatCode) == 0)
            ret = 2;
        else if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_Track0RecoverCode) == 0)
            ret = 3;
        else
            ret = 1;
        HDAE5000_MemFill(ram_22ad9c, 0, 10);
    } else {
        ret = 0;
    }
    return ret;
}

int CodeDigit_p(int digit)
{
    int ret;
    char buf[8];

    HDAE5000_IToA(digit, buf, 10);
    *(ram_22ad9c + ram_22ad9c[0] + 2) = buf[0];
    ram_22ad9c[0]++;
    if (ram_22ad9c[0] == 6) {
        if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_HdFormatCode) == 0)
            ret = 2;
        else if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_Track0RecoverCode) == 0)
            ret = 3;
        else
            ret = 1;
        HDAE5000_MemFill(ram_22ad9c, 0, 10);
    } else {
        ret = 0;
    }
    return ret;
}

int CodeDigit_s(int digit)
{
    int ret;
    char buf[8];

    HDAE5000_IToA(digit, buf, 10);
    ram_22ad9c[(int)ram_22ad9c[0] + 2] = buf[0];
    ram_22ad9c[0]++;
    if (ram_22ad9c[0] == 6) {
        if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_HdFormatCode) == 0)
            ret = 2;
        else if (HDAE5000_StrPrefixCmp((char *)HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_Track0RecoverCode) == 0)
            ret = 3;
        else
            ret = 1;
        HDAE5000_MemFill(ram_22ad9c, 0, 10);
    } else {
        ret = 0;
    }
    return ret;
}

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

void DelOptInit_v(void)
{
    unsigned int m;

    if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
        HDAE5000_TypeSel_Init(&HDAE5000_RAM_DeleteOptions, m, HDAE5000_DelOpt_TemplateBlank, 2);
    else
        HDAE5000_TypeSel_Init(&HDAE5000_RAM_DeleteOptions, 0, HDAE5000_DelOpt_TemplateBlank, 2);
    HDAE5000_RAM_DeleteOptions.mask = 0;
}

void DelOptInit_i(void)
{
    int m;

    if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff)
        HDAE5000_TypeSel_Init(&HDAE5000_RAM_DeleteOptions, m, HDAE5000_DelOpt_TemplateBlank, 2);
    else
        HDAE5000_TypeSel_Init(&HDAE5000_RAM_DeleteOptions, 0, HDAE5000_DelOpt_TemplateBlank, 2);
    HDAE5000_RAM_DeleteOptions.mask = 0;
}

/* ---- 0x28b33e ---- */
/* the history: +0 count (up to 5), +1 recall index, +2 next slot, +4 five names of 27 */
void HDAE5000_NameHistory_Push(unsigned char *hist, char *name)
{
    HDAE5000_StrCpy((char *)&hist[hist[2] * 27 + 4], name);
    hist[1] = hist[2];
    if (++hist[2] >= 5)
        hist[2] = 0;
    if (hist[0] < 5)
        hist[0]++;
    HDAE5000_NameHistory_AfterPushNop(hist);
}

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

void NameHistPush_p(unsigned char *hist, char *name)
{
    HDAE5000_StrCpy((char *)hist + (hist[2] * 27 + 4), name);
    hist[1] = hist[2];
    if (++hist[2] >= 5)
        hist[2] = 0;
    if (hist[0] < 5)
        hist[0]++;
    HDAE5000_NameHistory_AfterPushNop(hist);
}

void NameHistPush_q(unsigned char *hist, char *name)
{
    HDAE5000_StrCpy((char *)&hist[hist[2] * 27 + 4], name);
    hist[1] = hist[2];
    if (hist[2]++, hist[2] >= 5)
        hist[2] = 0;
    if (hist[0] < 5)
        hist[0]++;
    HDAE5000_NameHistory_AfterPushNop(hist);
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

void PP_Svc28_l(long a, long b)
{
    long d[5];

    HDAE5000_StrCpy((char *)d, HDAE5000_Str_XAP);
    d[1] = b;
    d[4] = 0x280000L;
    d[2] = 0x2f0000L;
    HDAE5000_RAM_XAP_FLASH_ENTRY(a, d[0]);
}

int PP_Svc28_r(long a, long b)
{
    struct XapDesc d;

    HDAE5000_StrCpy(d.tag, HDAE5000_Str_XAP);
    d.arg = b;
    d.base = 0x280000L;
    d.limit = 0x2f0000L;
    return HDAE5000_RAM_XAP_FLASH_ENTRY(a, *(long *)d.tag);
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

unsigned int HdFormatDrive_d(int sleep)
{
    unsigned int st;

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

unsigned int DirIsBlank_u(unsigned int dir)
{
    unsigned int ret = 0;

    if (HDAE5000_StrNCmp(&HDAE5000_RAM_DirNames[(unsigned long)dir * 16], ram_2f8de0, HDAE5000_StrLen(ram_2f8de0)) == 0)
        ret = 0xffff;
    return ret;
}

int DirIsBlank_n(int dir)
{
    int ret = 0;

    if (HDAE5000_StrNCmp(&HDAE5000_RAM_DirNames[(unsigned long)(unsigned int)dir * 16], ram_2f8de0,
                         HDAE5000_StrLen(ram_2f8de0)) == 0)
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

int FlsIsBlank_i(unsigned int fls)
{
    int ret = 0;

    if (HDAE5000_StrNCmp(HDAE5000_FlsRecord_Address(fls), ram_2f8df2, HDAE5000_StrLen(ram_2f8df2)) == 0)
        ret = -1;
    return ret;
}

int FlsIsBlank_n(int fls)
{
    int ret = 0;

    if (HDAE5000_StrNCmp(HDAE5000_FlsRecord_Address(fls), ram_2f8df2, HDAE5000_StrLen(ram_2f8df2)) == 0)
        ret = -1;
    return ret;
}

int FlsIsBlank_s(unsigned int fls)
{
    int ret;

    ret = 0;
    if (HDAE5000_StrNCmp(HDAE5000_FlsRecord_Address(fls), ram_2f8df2, HDAE5000_StrLen(ram_2f8df2)) == 0)
        ret = -1;
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

void WrClose_c(void)
{
    if (HDAE5000_RAM_HdStreamBuffer != HDAE5000_RAM_HdStreamFill) {
        if (HDAE5000_RAM_HdStreamState == 1) {
            HDAE5000_HD_WriteFile((void *)HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                  (void *)HDAE5000_RAM_HdStreamSlot);
            HDAE5000_RAM_HdStreamState = 2;
        } else {
            HDAE5000_HD_AppendFile((void *)HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                   (void *)HDAE5000_RAM_HdStreamSlot);
        }
    }
    HDAE5000_RAM_HdStreamState = 0;
}

void WrClose_l(void)
{
    void *p;

    if (HDAE5000_RAM_HdStreamBuffer != HDAE5000_RAM_HdStreamFill) {
        if (HDAE5000_RAM_HdStreamState == 1) {
            p = (void *)HDAE5000_RAM_HdStreamBuffer;
            HDAE5000_HD_WriteFile(p, HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamSlot);
            HDAE5000_RAM_HdStreamState = 2;
        } else {
            p = (void *)HDAE5000_RAM_HdStreamBuffer;
            HDAE5000_HD_AppendFile(p, HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamSlot);
        }
    }
    HDAE5000_RAM_HdStreamState = 0;
}
