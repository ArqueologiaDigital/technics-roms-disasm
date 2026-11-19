/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_15i/hdae5000_fls_small.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 51dd788aea17b382e8faa5d7b368b48d94f4d8d9283f2518143304a7b6d99295 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_22aa9c[];
unsigned int HDAE5000_Count_Active_Files(void)
{
    unsigned int n;
    unsigned int i;

    n = 0;
    for (i = 0; i < 20; i++)
        if (ram_22aa9c[(unsigned long)i + 0x114] == 1)
            n++;
    return n;
}
