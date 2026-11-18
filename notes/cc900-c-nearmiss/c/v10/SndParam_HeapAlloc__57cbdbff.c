/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_1m283a.c (2026-11-18-12-p6-r35)
   sha256 57cbdbffd88d34c66267424c88a9ee6cb625d0ced6fde122c581a18d4cc9d1bb (tar-sha256); compiled at -O3 -Xr */
struct sheap { unsigned int used; unsigned char data[0x4000]; };
extern struct sheap ram_380f8;
unsigned char *SndParam_HeapAlloc(unsigned int n)
{
    unsigned char *p;

    if (n == 0 || ram_380f8.used + n >= 0x4000)
        return 0;
    p = &ram_380f8.data[ram_380f8.used];
    ram_380f8.used += n;
    return p;
}
