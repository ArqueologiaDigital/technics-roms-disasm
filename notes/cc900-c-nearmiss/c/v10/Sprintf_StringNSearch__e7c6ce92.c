/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_35r1m311b.c (2026-11-22-23-p6-r90)
   sha256 e7c6ce922bbc0a6748effb58f177428803ed0ddbf74babc41e3992db5ae93882 (tar-sha256); compiled at -O3 -Xr */
extern void *__cdecl Sprintf_MemChr(void *, int, unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
char *__cdecl Sprintf_StringNSearch(void *dst, char *src, int c, unsigned int n)
{
    char *p;

    p = Sprintf_MemChr(src, c, n);
    Mem_Copy(dst, src, p != 0 ? p - src + 1 : n);
    return p;
}
