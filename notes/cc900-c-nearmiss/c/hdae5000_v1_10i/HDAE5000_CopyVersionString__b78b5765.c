/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_setup_ui_display__version_v1_r81.c (2026-11-19-85-hd-r86-staged)
   sha256 b78b5765106e4358d3896c3d85b41617da46bcd6833a5a9435e77205c16786ae (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int __cdecl HDAE5000_StrLen(char *);
extern char HDAE5000_Str_V110i[];
#define VERSION HDAE5000_Str_V110i
int HDAE5000_CopyVersionString(char *dst)
{
    unsigned int i;
    for (i = 0; i < 7; i++)
        *dst++ = VERSION[i];
    return HDAE5000_StrLen(VERSION);
}
