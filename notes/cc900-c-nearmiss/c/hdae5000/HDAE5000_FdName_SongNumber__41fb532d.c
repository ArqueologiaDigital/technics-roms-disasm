/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_small2.c (2026-11-17-13-hd-r42-ports)
   sha256 41fb532d04b1cddcad2b89adfb641aa4f14ab58d55121e6a1f2ac49d2d663760 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int __cdecl HDAE5000_StrLen(char *);
extern int __cdecl HDAE5000_StrNCmp(char *, char *, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern char HDAE5000_Fmt_2_2d[];
int HDAE5000_FdName_SongNumber(char *name)
{
    char buf[4];
    int i;

    for (i = 1; i <= 20; i++) {
        HDAE5000_SPrintf(buf, HDAE5000_Fmt_2_2d, i);
        if (HDAE5000_StrNCmp(buf, name, HDAE5000_StrLen(buf)) == 0)
            return i - 1;
    }
    return -1;
}
