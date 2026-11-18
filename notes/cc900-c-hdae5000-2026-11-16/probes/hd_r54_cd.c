/* hd_r54_cd.c (lane_hd round 54): HDAE5000_FormatDialog_CodeDigit (136 B), four spellings of the base pointer.
   cc900-options: -Xr
   cc900-name: CodeDigit_p=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_q=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_r=HDAE5000_FormatDialog_CodeDigit
   Run 2026-11-18-13-hd-r52 (hd_r52_cd.c): with `unsigned char *p; int i;` and `i = (unsigned int)ram[0]` every
   instruction is the ROM's but one: p's assignment is `lda xwa,ram; ld xde,xwa`, the ROM `lda xde,ram`.  All four
   spellings of the right side (&ram[0], ram, a cast, ram + 0) gave the same.  These change how p is declared:
     HDAE5000_FormatDialog_CodeDigit  p in a block, initialised: { unsigned char *p = ram_22ad9c; p[i] = ..; }
     CodeDigit_p                      p in a block, assigned
     CodeDigit_q                      `register unsigned char *p;` declared before i
     CodeDigit_r                      p in a block, initialised with &ram_22ad9c[0]
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_IToA(int, char *, int);
extern int __cdecl HDAE5000_StrPrefixCmp(char *, char *);

extern unsigned char ram_22ad9c[];                      /* [0] = digits typed; the digits from +2 */
extern unsigned char HDAE5000_RAM_FormatCodeDigits[];   /* ram_22ad9c + 2 */
extern char HDAE5000_Str_HdFormatCode[];
extern char HDAE5000_Str_Track0RecoverCode[];

/* one digit of the format dialog's code: appended to the typed digits; with six typed, 2 = the format
   code, 3 = the track 0 recovery code, 1 = neither (the digits are cleared), else 0 */
int HDAE5000_FormatDialog_CodeDigit(int digit)
{
    int ret;
    char buf[8];
    int i;

    HDAE5000_IToA(digit, buf, 10);
    i = (unsigned int)ram_22ad9c[0];
    i += 2;
    {
        unsigned char *p = ram_22ad9c;

        p[i] = buf[0];
    }
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

/* one digit of the format dialog's code: appended to the typed digits; with six typed, 2 = the format
   code, 3 = the track 0 recovery code, 1 = neither (the digits are cleared), else 0 */
int CodeDigit_p(int digit)
{
    int ret;
    char buf[8];
    int i;

    HDAE5000_IToA(digit, buf, 10);
    i = (unsigned int)ram_22ad9c[0];
    i += 2;
    {
        unsigned char *p;

        p = ram_22ad9c;
        p[i] = buf[0];
    }
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

/* one digit of the format dialog's code: appended to the typed digits; with six typed, 2 = the format
   code, 3 = the track 0 recovery code, 1 = neither (the digits are cleared), else 0 */
int CodeDigit_q(int digit)
{
    int ret;
    char buf[8];
    register unsigned char *p;
    int i;

    HDAE5000_IToA(digit, buf, 10);
    i = (unsigned int)ram_22ad9c[0];
    i += 2;
    p = ram_22ad9c;
    p[i] = buf[0];
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

/* one digit of the format dialog's code: appended to the typed digits; with six typed, 2 = the format
   code, 3 = the track 0 recovery code, 1 = neither (the digits are cleared), else 0 */
int CodeDigit_r(int digit)
{
    int ret;
    char buf[8];
    int i;

    HDAE5000_IToA(digit, buf, 10);
    i = (unsigned int)ram_22ad9c[0];
    i += 2;
    {
        unsigned char *p = &ram_22ad9c[0];

        p[i] = buf[0];
    }
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
