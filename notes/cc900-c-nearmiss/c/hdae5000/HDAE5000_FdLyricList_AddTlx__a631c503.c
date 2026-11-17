/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_fdlyric_addtlx.c (2026-11-16-120-hd-r31-staged)
   sha256 a631c50300468b05c9e8a94c627fa0baae0a989227c1c76a6e1c30c561b87c20 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: AddTlx_b=HDAE5000_FdLyricList_AddTlx */
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern int __cdecl HDAE5000_StrNCmp(char *, char *, unsigned int);
extern int __cdecl HDAE5000_StrPrefixCmp(char *, char *);
extern char *__cdecl HDAE5000_StrRev(char *);
extern char *__cdecl HDAE5000_StrUpr(char *);
extern unsigned char HDAE5000_RAM_FdLyricNames[][9];
extern unsigned int HDAE5000_RAM_FdLyricCount;
extern char ram_230884[], ram_23087b[];
extern char HDAE5000_Str_XLT[];
long AddTlx_b(char *name)
{
    int j;
    int k;
    char tmp[50];
    char base[50];

    HDAE5000_StrCpy(tmp, name);
    HDAE5000_StrRev(tmp);
    HDAE5000_StrUpr(tmp);
    if (HDAE5000_StrNCmp(tmp, HDAE5000_Str_XLT, 4) == 0) {
        if (HDAE5000_RAM_FdLyricCount >= 40)
            return -1L;
        HDAE5000_StrRev(tmp);
        HDAE5000_StrCpy(base, tmp);
        base[HDAE5000_StrLen(base) - 4] = 0;
        if (HDAE5000_RAM_FdLyricCount == 0) {
            HDAE5000_StrCpy((char *)HDAE5000_RAM_FdLyricNames, base);
            HDAE5000_RAM_FdLyricCount++;
            return 0;
        }
        for (j = 0; j < HDAE5000_RAM_FdLyricCount; j++) {
            if (HDAE5000_StrPrefixCmp(base, &ram_230884[j * 9]) < 0) {
                for (k = HDAE5000_RAM_FdLyricCount; k > j; k--)
                    HDAE5000_StrCpy(&ram_230884[k * 9], &ram_23087b[k * 9]);
                HDAE5000_StrCpy(&ram_230884[j * 9], base);
                HDAE5000_RAM_FdLyricCount++;
                return 0;
            }
        }
        HDAE5000_StrCpy((char *)HDAE5000_RAM_FdLyricNames[HDAE5000_RAM_FdLyricCount], base);
        HDAE5000_RAM_FdLyricCount++;
        return 0;
    }
    return 0;
}
