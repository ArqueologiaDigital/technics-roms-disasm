/* Probe round 35r1, helper A, form b: audio/sprintf_core.s (module 311), xr_screen family.
   Sprintf_StringNSearch as form a, with n a plain parameter and the test written `p != 0` (arms swapped). */

extern void *__cdecl Sprintf_MemChr(void *, int, unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern char *__cdecl Sprintf_StringNSearch(void *, char *, int, unsigned int);

char *__cdecl Sprintf_StringNSearch(void *dst, char *src, int c, unsigned int n)
{
    char *p;

    p = Sprintf_MemChr(src, c, n);
    Mem_Copy(dst, src, p != 0 ? p - src + 1 : n);
    return p;
}
