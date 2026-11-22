/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r88_cd.c (2026-11-20-3-hd-r88-staged)
   sha256 cc1dfde966265ee0605a059440086ad538fb7527ac0954ed9458fbba6c7ee832 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: CodeDigit_s=HDAE5000_FormatDialog_CodeDigit */
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern char *__cdecl HDAE5000_IToA(int, char *, int);
extern int __cdecl HDAE5000_StrPrefixCmp(char *, char *);
extern unsigned char ram_22ad9c[];
extern unsigned char HDAE5000_RAM_FormatCodeDigits[];
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
