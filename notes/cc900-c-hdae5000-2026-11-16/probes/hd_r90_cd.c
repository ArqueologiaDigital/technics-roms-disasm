/* hd_r90_cd.c (lane_hd round 90, 2026-11-20): HDAE5000_FormatDialog_CodeDigit (136 B), a second parameter.
   cc900-options: -Xr
   cc900-name: CodeDigit_w=HDAE5000_FormatDialog_CodeDigit
   cc900-name: CodeDigit_x=HDAE5000_FormatDialog_CodeDigit
   Run 2026-11-20-3-hd-r88-staged (hd_r88_cd.c): with the parameter digit reused as the index (forms s, t) V4.23
   kept it in its argument register WA and loaded the store's base straight into XDE (`lda xde,ram`, the ROM's);
   the only difference left was the index's register, WA where the ROM has BC (`extz wa; ld bc,wa; inc 2,bc;
   ld a,(xsp+2); ld (xde+bc),a`).  BC is the second argument's register, so the function had a second parameter,
   reused as the index (its callers' BC is never read):
     CodeDigit_w  i = (unsigned int)ram[0];  i += 2;  ram[i] = buf[0];
     CodeDigit_x  the same without the cast
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

int CodeDigit_w(int digit, int i)
{
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

int CodeDigit_x(int digit, int i)
{
    int ret;
    char buf[8];

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
