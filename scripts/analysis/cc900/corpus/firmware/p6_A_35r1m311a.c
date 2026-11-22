/* Probe round 35r1, helper A, form a: audio/sprintf_core.s (module 311), xr_screen family.
   Sprintf_StringNSearch(dst, src, c, n): memccpy: find c in the first n bytes of src, copy up to and including it
   (all n bytes when absent) to dst, return the found pointer (0 when absent).  n is a `register` parameter (IZ). */

extern void *__cdecl Sprintf_MemChr(void *, int, unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern char *__cdecl Sprintf_StringNSearch(void *, char *, int, unsigned int);

char *__cdecl Sprintf_StringNSearch(void *dst, char *src, int c, register unsigned int n)
{
    char *p;

    p = Sprintf_MemChr(src, c, n);
    Mem_Copy(dst, src, p == 0 ? n : p - src + 1);
    return p;
}
