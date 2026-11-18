/* hd_r52_cd.c (lane_hd round 52): HDAE5000_FormatDialog_CodeDigit (136 B), four spellings of the store.
   cc900-options: -Xr
   cc900-name: CodeDigit_a=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_b=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_c=HDAE5000_FormatDialog_CodeDigit
   Run 2026-11-18-7-hd-r51 (hd_r51_cd.c):
   - `i = (unsigned int)ram[0];` (int i) widens the count IN WA and copies it to the local (`extz wa; ld de,wa`):
     the ROM's shape, but the local is in DE and the base in XBC;
   - a pointer local p declared BEFORE i (`p = ram; p[i] = ..`) puts i in BC and p in XDE, the ROM's registers,
     but i was assigned without the cast (`ld c,a; extz bc`) and p as `lda xwa,ram; ld xde,xwa`.
   So both together, with four spellings of p's assignment:
     HDAE5000_FormatDialog_CodeDigit  p = &ram_22ad9c[0];
     CodeDigit_a                      p = ram_22ad9c;
     CodeDigit_b                      p = (unsigned char *)ram_22ad9c;
     CodeDigit_c                      p = ram_22ad9c + 0;
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
    unsigned char *p;
    int i;

    HDAE5000_IToA(digit, buf, 10);
    i = (unsigned int)ram_22ad9c[0];
    i += 2;
    p = &ram_22ad9c[0];
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
int CodeDigit_a(int digit)
{
    int ret;
    char buf[8];
    unsigned char *p;
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
int CodeDigit_b(int digit)
{
    int ret;
    char buf[8];
    unsigned char *p;
    int i;

    HDAE5000_IToA(digit, buf, 10);
    i = (unsigned int)ram_22ad9c[0];
    i += 2;
    p = (unsigned char *)ram_22ad9c;
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
int CodeDigit_c(int digit)
{
    int ret;
    char buf[8];
    unsigned char *p;
    int i;

    HDAE5000_IToA(digit, buf, 10);
    i = (unsigned int)ram_22ad9c[0];
    i += 2;
    p = ram_22ad9c + 0;
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
