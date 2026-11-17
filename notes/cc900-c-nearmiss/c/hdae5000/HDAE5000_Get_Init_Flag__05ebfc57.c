/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_boot.c (2026-11-16-98-hd-r22)
   sha256 05ebfc57a7544b6cdef09ea1442db94c79706ff4e30dfd199f8c28056fb65a35 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_RAM_HdPresent;
unsigned char HDAE5000_Get_Init_Flag(void)
{
    return HDAE5000_RAM_HdPresent;
}
