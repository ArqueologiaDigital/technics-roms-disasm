/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_15i/hdae5000_setup_ui_display__version_v1_r81.c (2026-11-19-85-hd-r86-staged)
   sha256 0578739e4bc9cd77a645d1af95ef8f0f31a79b1077e8ef4e60eba3ce1f3b0b04 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int __cdecl HDAE5000_StrLen(char *);
extern char HDAE5000_Str_V115i[];
#define VERSION HDAE5000_Str_V115i
int HDAE5000_CopyVersionString(char *dst)
{
    unsigned int i;
    for (i = 0; i < 7; i++)
        *dst++ = VERSION[i];
    return HDAE5000_StrLen(VERSION);
}
