/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_4m280a.c (2026-11-18-33-p6-r37)
   sha256 5f55d44e1fcc5cfde278ce226d43a9162550c27df15bdc96e8f999232bd9c3fe (tar-sha256); compiled at -O3 -Xr */
#define FACT ((unsigned char *)0x99eca0L)
extern unsigned char ram_1ed400[];
extern unsigned char SndParamRam_DefaultImage[];
extern void *__cdecl Memset(void *, int, unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
void PanelMem_InitFromFactory(unsigned int n)
{
    unsigned char *p;

    if (n >= 80)
        return;
    Memset(ram_1ed400 + (unsigned long)n * 960, 0, 0x3c0);
    Mem_Copy(p = ram_1ed400 + (unsigned long)n * 960, FACT + (unsigned long)n * 0x2a2, 0x7c);
    Mem_Copy(p += 0x7c, SndParamRam_DefaultImage + 0x7c, 0x11e);
    Mem_Copy(p + 0x11e, FACT + (unsigned long)n * 0x2a2 + 0x7c, 0x226);
}
