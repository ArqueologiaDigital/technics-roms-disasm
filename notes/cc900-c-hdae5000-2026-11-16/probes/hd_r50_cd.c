/* hd_r50_cd.c (lane_hd round 50): HDAE5000_FormatDialog_CodeDigit (136 B), five spellings of the digit's store.
   cc900-options: -Xr
   cc900-name: CodeDigit_b=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_c=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_d=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_e=HDAE5000_FormatDialog_CodeDigit
   Read-out of run 2026-11-17-20-hd-r47 (hd_r41_n1c.c, all five forms): everything is the ROM's but the store.
   ROM: the count loaded into A, widened IN WA, copied to BC, 2 added in BC, the base into XDE, the store
   `(xde+bc)`.  Every local-index form gave the local DE (`ld e,a; extz de; inc 2,de`) and the base XBC, whatever
   the declaration order.  Run 2026-11-16 (hd_r39_m4b.c, _s: `ram[(int)ram[0] + 2]`) put the count in BC and the
   base in XDE as the ROM, but folded the +2 into the base address.  So: the expression form, with the 2 kept out of
   the fold by the comma idiom of SongScreen_Refresh (`(0, 30) * i`):
     HDAE5000_FormatDialog_CodeDigit  ram[(int)ram[0] + (0, 2)]
     CodeDigit_b                      ram[(0, 2) + (int)ram[0]]
     CodeDigit_c                      ram[(int)(ram[0] + (0, 2))]
     CodeDigit_d                      ram[ram[0] + (0, 2)]          (no cast)
     CodeDigit_e                      local i: `i = (int)ram[0]; i += 2; ram[i] = ..` (does the cast widen in WA?)
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

    HDAE5000_IToA(digit, buf, 10);
    ram_22ad9c[(int)ram_22ad9c[0] + (0, 2)] = buf[0];
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

    HDAE5000_IToA(digit, buf, 10);
    ram_22ad9c[(0, 2) + (int)ram_22ad9c[0]] = buf[0];
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

    HDAE5000_IToA(digit, buf, 10);
    ram_22ad9c[(int)(ram_22ad9c[0] + (0, 2))] = buf[0];
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
int CodeDigit_d(int digit)
{
    int ret;
    char buf[8];

    HDAE5000_IToA(digit, buf, 10);
    ram_22ad9c[ram_22ad9c[0] + (0, 2)] = buf[0];
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
int CodeDigit_e(int digit)
{
    int ret;
    char buf[8];
    int i;

    HDAE5000_IToA(digit, buf, 10);
    i = (int)ram_22ad9c[0];
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
