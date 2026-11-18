/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_fls_small.c (2026-11-18-26-hd-r56-ports)
   sha256 d966fa9367b6a44f3f4eef8f158d1b95fc9f922f9dd0609401613426e6aae621 (tar-sha256); compiled at -Xr
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
