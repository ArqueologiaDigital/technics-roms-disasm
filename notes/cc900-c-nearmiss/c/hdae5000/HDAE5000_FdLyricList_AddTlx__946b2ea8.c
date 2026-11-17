/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r20_uih.c (2026-11-16-95-hd-r20)
   sha256 946b2ea8d3f36cfe8eb2ded438f5e96fd9a71641f0dd441edb812286efbff191 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern unsigned int __cdecl HDAE5000_StrLen(char *);
extern int __cdecl HDAE5000_StrNCmp(char *, char *, unsigned int);
extern int __cdecl HDAE5000_StrPrefixCmp(char *, char *);
extern char *__cdecl HDAE5000_StrRev(char *);
extern char *__cdecl HDAE5000_StrUpr(char *);
extern unsigned char HDAE5000_RAM_FdLyricNames[][9];
extern unsigned int HDAE5000_RAM_FdLyricCount;
extern char HDAE5000_Str_XLT[];
long HDAE5000_FdLyricList_AddTlx(char *name)
{
    int j;
    int k;
    char base[50];
    char tmp[50];

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
            if (HDAE5000_StrPrefixCmp(base, (char *)HDAE5000_RAM_FdLyricNames[j]) < 0) {
                for (k = HDAE5000_RAM_FdLyricCount; k > j; k--)
                    HDAE5000_StrCpy((char *)HDAE5000_RAM_FdLyricNames[k], (char *)HDAE5000_RAM_FdLyricNames[k - 1]);
                HDAE5000_StrCpy((char *)HDAE5000_RAM_FdLyricNames[j], base);
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
