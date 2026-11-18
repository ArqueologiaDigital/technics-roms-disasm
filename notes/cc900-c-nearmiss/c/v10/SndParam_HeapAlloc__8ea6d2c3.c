/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_3m283c.c (2026-11-18-28-p6-r36)
   sha256 8ea6d2c31951a8fb07ab0c5baba695d08cb138b40e412c162bf85082e359977e (tar-sha256); compiled at -O3 -Xr */
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
