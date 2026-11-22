/* Functions of hdae5000_hd_driver.s.  (hdae5000_codedigit_r90.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_codedigit_r90.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-name: CodeDigit_w=HDAE5000_FormatDialog_CodeDigit
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

/* one digit of the format dialog's code: appended to the typed digits; with six typed, 2 = the format code, 3 = the
   track 0 recovery code, 1 = neither (the digits are cleared), else 0.  The index is a second parameter, reused: the
   ROM keeps it in BC, the second argument's register (run 2026-11-20-6-hd-r90-staged; a local index takes DE or a
   copy through WA).  Callers pass only the digit. */
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
