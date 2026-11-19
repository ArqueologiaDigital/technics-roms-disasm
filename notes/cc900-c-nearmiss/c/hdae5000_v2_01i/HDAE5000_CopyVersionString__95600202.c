/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_setup_ui_display__version_r74.c (2026-11-19-64-hd-r76-staged)
   sha256 95600202c5aad8998c0d745e5331d7b6f6dbb086a438c6113d7a2fa0d6e85de0 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int __cdecl HDAE5000_StrLen(char *);
extern char HDAE5000_Str_V201i[];
#define VERSION HDAE5000_Str_V201i
int HDAE5000_CopyVersionString(char *dst)
{
    unsigned int i;
    for (i = 0; i < 7; i++)
        *dst++ = VERSION[i];
    return HDAE5000_StrLen(VERSION);
}
