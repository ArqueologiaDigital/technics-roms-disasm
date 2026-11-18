/* hd_r51_cd.c (lane_hd round 51): HDAE5000_FormatDialog_CodeDigit (136 B), five more spellings of the store.
   cc900-options: -Xr
   cc900-name: CodeDigit_g=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_h=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_m=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_n=HDAE5000_FormatDialog_CodeDigit
   Run 2026-11-18-4-hd-r50 (hd_r50_cd.c): the comma idiom does NOT keep the 2 out of the fold in an index
   (`ram[(int)ram[0] + (0, 2)]` gives `ld c,a; extz bc; lda xde,ram+2`); `(int)(ram[0] + (0, 2))` adds in A
   before the widening; a cast on the local's assignment (`i = (int)ram[0]`) changes nothing (i in DE).
   ROM: `ld a,(ram); extz wa; ld bc,wa; inc 2,bc; lda xde,ram; ld a,(xsp+2); ld (xde+bc),a`: the count widened
   in WA (an int value first), then copied to the local's register BC; the base in XDE.  Forms:
     HDAE5000_FormatDialog_CodeDigit  i = (unsigned int)ram[0]; i += 2; ram[i] = ..   (int i: two conversions)
     CodeDigit_g                      a base pointer local p declared before i: p = ram; p[i] = ..
     CodeDigit_h                      the same, p declared after i
     CodeDigit_m                      i = +ram[0];  (a unary plus: an int expression)
     CodeDigit_n                      ram[(i = ram[0], i += 2)] = ..
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

/* one digit of the format dialog's code: appended to the typed digits; with six typed, 2 = the format
   code, 3 = the track 0 recovery code, 1 = neither (the digits are cleared), else 0 */
int CodeDigit_g(int digit)
{
    int ret;
    char buf[8];
    unsigned char *p;
    int i;

    HDAE5000_IToA(digit, buf, 10);
    i = ram_22ad9c[0];
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
int CodeDigit_h(int digit)
{
    int ret;
    char buf[8];
    int i;
    unsigned char *p;

    HDAE5000_IToA(digit, buf, 10);
    i = ram_22ad9c[0];
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
int CodeDigit_m(int digit)
{
    int ret;
    char buf[8];
    int i;

    HDAE5000_IToA(digit, buf, 10);
    i = +ram_22ad9c[0];
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

/* one digit of the format dialog's code: appended to the typed digits; with six typed, 2 = the format
   code, 3 = the track 0 recovery code, 1 = neither (the digits are cleared), else 0 */
int CodeDigit_n(int digit)
{
    int ret;
    char buf[8];
    int i;

    HDAE5000_IToA(digit, buf, 10);
    ram_22ad9c[(i = ram_22ad9c[0], i += 2)] = buf[0];
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
