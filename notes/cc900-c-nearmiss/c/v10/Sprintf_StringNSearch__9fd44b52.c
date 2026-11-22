/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_35r1m311a.c (2026-11-22-23-p6-r90)
   sha256 9fd44b5216ed024b9e4eb215221e5b4614e7615a13e8b647d0683927e92f8c5b (tar-sha256); compiled at -O3 -Xr */
extern void *__cdecl Sprintf_MemChr(void *, int, unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
char *__cdecl Sprintf_StringNSearch(void *dst, char *src, int c, register unsigned int n)
{
    char *p;

    p = Sprintf_MemChr(src, c, n);
    Mem_Copy(dst, src, p == 0 ? n : p - src + 1);
    return p;
}
