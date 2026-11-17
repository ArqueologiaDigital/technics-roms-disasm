/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_small2.c (2026-11-17-13-hd-r42-ports)
   sha256 a5dcf1ce5b279649b03b5cebea6798906b6a1ce58e00f0d70c4310c57b9f95dc (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: PP_Svc28=HDAE5000_PPORT_Svc28_FlashXapFile */
struct XapDesc { char tag[4]; long arg; long limit; long gap; long base; };
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern int HDAE5000_RAM_XAP_FLASH_ENTRY();
extern char HDAE5000_Str_XAP[];
void PP_Svc28(long a, long b)
{
    struct XapDesc d;

    HDAE5000_StrCpy(d.tag, HDAE5000_Str_XAP);
    d.arg = b;
    d.base = 0x280000L;
    d.limit = 0x2f0000L;
    HDAE5000_RAM_XAP_FLASH_ENTRY(a, *(long *)d.tag);
}
