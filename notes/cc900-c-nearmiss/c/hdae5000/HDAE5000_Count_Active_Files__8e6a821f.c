/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_fls_small.c (2026-11-18-24-hd-r56)
   sha256 8e6a821fa4639e31727455fa0fbbea86b8941dad1aceeb2e120f3a022c6ec78a (tar-sha256); compiled at -Xr
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
