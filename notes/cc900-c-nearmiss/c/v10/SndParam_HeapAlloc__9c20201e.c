/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_3m283b.c (2026-11-18-28-p6-r36)
   sha256 9c20201e8c22eb5fd8cf9db9eddd90158cbc444546c0d55cb8cf7495c516d308 (tar-sha256); compiled at -O3 -Xr */
struct sheap { unsigned int used; unsigned char data[0x4000]; };
extern struct sheap ram_380f8;
unsigned char *SndParam_HeapAlloc(unsigned int n)
{
    unsigned char *p;

    if (n == 0 || ram_380f8.used + n >= 0x4000)
        return 0;
    p = &ram_380f8.data[(unsigned long)ram_380f8.used];
    ram_380f8.used += n;
    return p;
}
