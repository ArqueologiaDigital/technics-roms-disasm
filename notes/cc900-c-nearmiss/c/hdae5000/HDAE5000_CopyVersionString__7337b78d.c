/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_setup.c (2026-11-16-84-hd-r17-staged)
   sha256 7337b78d07812106f48b6584cefa0f7bfbd902272c6902f8bd0d8d520e49935a (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int __cdecl HDAE5000_StrLen(char *);
extern char HDAE5000_Str_V206i[];
#define VERSION HDAE5000_Str_V206i
int HDAE5000_CopyVersionString(char *dst)
{
    unsigned int i;
    for (i = 0; i < 7; i++)
        *dst++ = VERSION[i];
    return HDAE5000_StrLen(VERSION);
}
