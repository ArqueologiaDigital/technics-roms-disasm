/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_3m283a.c (2026-11-18-28-p6-r36)
   sha256 a598c92e7e8aeb032bea859d7b7370e1a172c4cc8ac57c0f3ce2f2e9dd41a683 (tar-sha256); compiled at -O3 -Xr */
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
