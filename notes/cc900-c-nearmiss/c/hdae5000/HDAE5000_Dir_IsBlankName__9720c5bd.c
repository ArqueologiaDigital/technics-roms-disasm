/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_small2.c (2026-11-17-11-hd-r40-staged)
   sha256 9720c5bd440dde0ba99b3ee0be198f6910a51baaf45d9b55174a5404d21744d5 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int __cdecl HDAE5000_StrLen(char *);
extern int __cdecl HDAE5000_StrNCmp(char *, char *, unsigned int);
extern unsigned char HDAE5000_RAM_DirNames[];
extern char ram_2f8de0[];
int HDAE5000_Dir_IsBlankName(unsigned int dir)
{
    int ret = 0;

    if (HDAE5000_StrNCmp(&HDAE5000_RAM_DirNames[(unsigned long)dir * 16], ram_2f8de0, HDAE5000_StrLen(ram_2f8de0)) == 0)
        ret = -1;
    return ret;
}
