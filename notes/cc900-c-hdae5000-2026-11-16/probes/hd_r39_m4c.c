/* lane_hd round 39, helper h_m4, file c: second forms of five functions of hd_r39_m4b.c, the ones whose alternative
   needs OTHER DECLARATIONS of the callees than file b has (so they cannot be variants in file b), in ROM address
   order: HDAE5000_FormatDialog_CodeDigit, HDAE5000_NameHistory_Push, HDAE5000_Dir_IsBlankName,
   HDAE5000_Fls_IsBlankName, HDAE5000_HD_WriteClose.  The readings are in hd_r39_m4b.c's header.
   cc900-options: -Xr
   cc900-module: HDAE5000_FlsRecord_Address HDAE5000_NameHistory_AfterPushNop
   cc900-name: CodeDigit_cl=HDAE5000_FormatDialog_CodeDigit
   cc900-name: NameHistPush_w=HDAE5000_NameHistory_Push
   cc900-name: DirIsBlank_cu=HDAE5000_Dir_IsBlankName
   cc900-name: FlsIsBlank_ci=HDAE5000_Fls_IsBlankName
   cc900-name: WrClose_r=HDAE5000_HD_WriteClose
   cc900-name: WrClose_v=HDAE5000_HD_WriteClose
   cc900-name: WrClose_e=HDAE5000_HD_WriteClose
   cc900-name: WrClose_a=HDAE5000_HD_WriteClose
   What differs from file b:
   - CodeDigit: StrPrefixCmp is (const char *, char *) and the typed digits are a plain char array: the first
     argument's `lda / push` then comes from the const qualification (as hd_r9_b1.c had it, run 60), the code string
     stays unconverted (pushed as a constant).  Main: the count cast to unsigned int; _cl: a local index.
   - NameHistory_Push: StrCpy is (unsigned char *, char *), so the destination needs no cast (file b's cast may
     make V4.23 evaluate it before `push xbc`; the ROM pushes the name first).  Main: `&hist[hist[2] * 27 + 4]`;
     _w: `hist + (hist[2] * 27 + 4)`.
   - Dir_IsBlankName / Fls_IsBlankName: StrNCmp is (unsigned char *, char *, unsigned int): the record address is
     not converted.  Result types as in file b (Dir `int`, Fls `unsigned int`); _cu / _ci swap them.
   - HD_WriteClose: HD_WriteFile / HD_AppendFile WITHOUT a prototype, as in the module's matched HDAE5000_HD_Write
     (hdae5000/cc900/hdae5000_fd_stream_ui_display.c) and as hd_r13_nab.c (91.9 %), whose only conversion was on
     the first argument.  Main: both pointer arguments cast to unsigned long; _r: the slot read as an unsigned long
     cell (ram_238f28) and cast to `long *`; _v: both cast to `void *`; _e: the buffer address through an
     unsigned long local, the slot plain; _a: nab's first argument and the slot through `(long *)` of a `void *` cast (a double
     conversion, but of a pointer; hd_r9_na.c's integer double cast went through XWA).  Unsure of all. */
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_IToA(int, char *, int);
extern char *__cdecl HDAE5000_StrCpy(unsigned char *, char *);
extern unsigned int __cdecl HDAE5000_StrLen(char *);
extern int __cdecl HDAE5000_StrNCmp(unsigned char *, char *, unsigned int);
extern int __cdecl HDAE5000_StrPrefixCmp(const char *, char *);

extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);
extern void HDAE5000_NameHistory_AfterPushNop(unsigned char *hist);
extern int HDAE5000_HD_WriteFile();
extern int HDAE5000_HD_AppendFile();

extern unsigned char HDAE5000_RAM_DirNames[];
extern unsigned char ram_22ad9c[];                      /* [0] = digits typed; the digits from +2 */
extern char HDAE5000_RAM_FormatCodeDigits[];            /* ram_22ad9c + 2 */
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern long *HDAE5000_RAM_HdStreamSlot;
extern unsigned long ram_238f28;                        /* HDAE5000_RAM_HdStreamSlot read as an integer */
extern unsigned char HDAE5000_RAM_HdStreamState;

extern char HDAE5000_Str_HdFormatCode[];
extern char HDAE5000_Str_Track0RecoverCode[];
extern char ram_2f8de0[];                               /* HDAE5000_Dir_IsBlankName_Str_Blank16 */
extern char ram_2f8df2[];                               /* HDAE5000_Fls_IsBlankName_Str_Blank16 */

/* ---- 0x2865de ---- */
int HDAE5000_FormatDialog_CodeDigit(int digit)
{
    int ret;
    char buf[8];

    HDAE5000_IToA(digit, buf, 10);
    ram_22ad9c[(unsigned int)ram_22ad9c[0] + 2] = buf[0];
    ram_22ad9c[0]++;
    if (ram_22ad9c[0] == 6) {
        if (HDAE5000_StrPrefixCmp(HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_HdFormatCode) == 0)
            ret = 2;
        else if (HDAE5000_StrPrefixCmp(HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_Track0RecoverCode) == 0)
            ret = 3;
        else
            ret = 1;
        HDAE5000_MemFill(ram_22ad9c, 0, 10);
    } else {
        ret = 0;
    }
    return ret;
}

int CodeDigit_cl(int digit)
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
        if (HDAE5000_StrPrefixCmp(HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_HdFormatCode) == 0)
            ret = 2;
        else if (HDAE5000_StrPrefixCmp(HDAE5000_RAM_FormatCodeDigits, HDAE5000_Str_Track0RecoverCode) == 0)
            ret = 3;
        else
            ret = 1;
        HDAE5000_MemFill(ram_22ad9c, 0, 10);
    } else {
        ret = 0;
    }
    return ret;
}

/* ---- 0x28b33e ---- */
void HDAE5000_NameHistory_Push(unsigned char *hist, char *name)
{
    HDAE5000_StrCpy(&hist[hist[2] * 27 + 4], name);
    hist[1] = hist[2];
    if (++hist[2] >= 5)
        hist[2] = 0;
    if (hist[0] < 5)
        hist[0]++;
    HDAE5000_NameHistory_AfterPushNop(hist);
}

void NameHistPush_w(unsigned char *hist, char *name)
{
    HDAE5000_StrCpy(hist + (hist[2] * 27 + 4), name);
    hist[1] = hist[2];
    if (++hist[2] >= 5)
        hist[2] = 0;
    if (hist[0] < 5)
        hist[0]++;
    HDAE5000_NameHistory_AfterPushNop(hist);
}

/* ---- 0x28f9ad ---- */
int HDAE5000_Dir_IsBlankName(unsigned int dir)
{
    int ret = 0;

    if (HDAE5000_StrNCmp(&HDAE5000_RAM_DirNames[(unsigned long)dir * 16], ram_2f8de0, HDAE5000_StrLen(ram_2f8de0)) == 0)
        ret = -1;
    return ret;
}

unsigned int DirIsBlank_cu(unsigned int dir)
{
    unsigned int ret = 0;

    if (HDAE5000_StrNCmp(&HDAE5000_RAM_DirNames[(unsigned long)dir * 16], ram_2f8de0, HDAE5000_StrLen(ram_2f8de0)) == 0)
        ret = 0xffff;
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

int FlsIsBlank_ci(unsigned int fls)
{
    int ret = 0;

    if (HDAE5000_StrNCmp(HDAE5000_FlsRecord_Address(fls), ram_2f8df2, HDAE5000_StrLen(ram_2f8df2)) == 0)
        ret = -1;
    return ret;
}

/* ---- 0x29429e ---- */
void HDAE5000_HD_WriteClose(void)
{
    if (HDAE5000_RAM_HdStreamBuffer != HDAE5000_RAM_HdStreamFill) {
        if (HDAE5000_RAM_HdStreamState == 1) {
            HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                  (unsigned long)HDAE5000_RAM_HdStreamSlot);
            HDAE5000_RAM_HdStreamState = 2;
        } else {
            HDAE5000_HD_AppendFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                   (unsigned long)HDAE5000_RAM_HdStreamSlot);
        }
    }
    HDAE5000_RAM_HdStreamState = 0;
}

void WrClose_r(void)
{
    if (HDAE5000_RAM_HdStreamBuffer != HDAE5000_RAM_HdStreamFill) {
        if (HDAE5000_RAM_HdStreamState == 1) {
            HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                  (long *)ram_238f28);
            HDAE5000_RAM_HdStreamState = 2;
        } else {
            HDAE5000_HD_AppendFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                   (long *)ram_238f28);
        }
    }
    HDAE5000_RAM_HdStreamState = 0;
}

void WrClose_v(void)
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

void WrClose_e(void)
{
    unsigned long p;

    if (HDAE5000_RAM_HdStreamBuffer != HDAE5000_RAM_HdStreamFill) {
        if (HDAE5000_RAM_HdStreamState == 1) {
            p = (unsigned long)HDAE5000_RAM_HdStreamBuffer;
            HDAE5000_HD_WriteFile(p, HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamSlot);
            HDAE5000_RAM_HdStreamState = 2;
        } else {
            p = (unsigned long)HDAE5000_RAM_HdStreamBuffer;
            HDAE5000_HD_AppendFile(p, HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamSlot);
        }
    }
    HDAE5000_RAM_HdStreamState = 0;
}

void WrClose_a(void)
{
    if (HDAE5000_RAM_HdStreamBuffer != HDAE5000_RAM_HdStreamFill) {
        if (HDAE5000_RAM_HdStreamState == 1) {
            HDAE5000_HD_WriteFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                  HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                  (long *)(void *)HDAE5000_RAM_HdStreamSlot);
            HDAE5000_RAM_HdStreamState = 2;
        } else {
            HDAE5000_HD_AppendFile((unsigned long)HDAE5000_RAM_HdStreamBuffer,
                                   HDAE5000_RAM_HdStreamFill - HDAE5000_RAM_HdStreamBuffer,
                                   (long *)(void *)HDAE5000_RAM_HdStreamSlot);
        }
    }
    HDAE5000_RAM_HdStreamState = 0;
}
