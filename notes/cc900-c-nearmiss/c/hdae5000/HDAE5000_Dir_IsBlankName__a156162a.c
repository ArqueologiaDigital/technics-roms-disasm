/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r39_m4c.c (2026-11-17-10-hd-r39)
   sha256 a156162aaeb59eb88ab8cd69df2728adb822f9731fc6c9976271bbb46e41cff9 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int __cdecl HDAE5000_StrLen(char *);
extern int __cdecl HDAE5000_StrNCmp(unsigned char *, char *, unsigned int);
extern unsigned char HDAE5000_RAM_DirNames[];
extern char ram_2f8de0[];
int HDAE5000_Dir_IsBlankName(unsigned int dir)
{
    int ret = 0;

    if (HDAE5000_StrNCmp(&HDAE5000_RAM_DirNames[(unsigned long)dir * 16], ram_2f8de0, HDAE5000_StrLen(ram_2f8de0)) == 0)
        ret = -1;
    return ret;
}
