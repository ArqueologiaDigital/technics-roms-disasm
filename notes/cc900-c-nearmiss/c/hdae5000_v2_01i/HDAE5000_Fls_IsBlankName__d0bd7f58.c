/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_small2_ui_display.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 d0bd7f58c066d59acb4500470ed3a86be2c3c62fc2868285dce4850969634256 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int __cdecl HDAE5000_StrLen(char *);
extern int __cdecl HDAE5000_StrNCmp(char *, char *, unsigned int);
extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);
extern char ram_2f8df2[];
unsigned int HDAE5000_Fls_IsBlankName(unsigned int fls)
{
    unsigned int ret = 0;

    if (HDAE5000_StrNCmp(HDAE5000_FlsRecord_Address(fls), ram_2f8df2, HDAE5000_StrLen(ram_2f8df2)) == 0)
        ret = 0xffff;
    return ret;
}
