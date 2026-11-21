/* hd_r88_cd.c (lane_hd round 88, 2026-11-20): HDAE5000_FormatDialog_CodeDigit (136 B), the index's home.
   cc900-options: -Xr
   cc900-name: CodeDigit_s=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_t=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_u=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_v=HDAE5000_FormatDialog_CodeDigit
   Runs hd-r50 .. hd-r54: an index local i alone gets DE and the indexed store's base XBC; a pointer local p
   declared before i puts i in BC and p in XDE (the ROM's registers) but p is assigned through WA (`lda xwa,ram;
   ld xde,xwa`), where the ROM loads the base straight into XDE (`lda xde,ram`), the way V4.23 loads the base of an
   indexed access.  So the ROM's XDE is probably the store's base, not a variable, and i sits in BC for another
   reason.  Forms:
     CodeDigit_s  the parameter reused as the index: digit = (unsigned int)ram[0]; digit += 2; ram[digit] = ..
     CodeDigit_t  the same without the cast
     CodeDigit_u  `register int i;` alone, ram[i] = ..
     CodeDigit_v  i declared first (before ret and buf)
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

int CodeDigit_s(int digit)
{
    int ret;
    char buf[8];

    HDAE5000_IToA(digit, buf, 10);
    digit = (unsigned int)ram_22ad9c[0];
    digit += 2;
    ram_22ad9c[digit] = buf[0];
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

int CodeDigit_t(int digit)
{
    int ret;
    char buf[8];

    HDAE5000_IToA(digit, buf, 10);
    digit = ram_22ad9c[0];
    digit += 2;
    ram_22ad9c[digit] = buf[0];
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

int CodeDigit_u(int digit)
{
    int ret;
    char buf[8];
    register int i;

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

int CodeDigit_v(int digit)
{
    int i;
    int ret;
    char buf[8];

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
