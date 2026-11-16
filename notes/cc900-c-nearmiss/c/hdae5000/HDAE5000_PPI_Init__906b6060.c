/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_hardtest.c (2026-11-16-116-hd-r27c)
   sha256 906b6060822f70a1357aaef42e9a099d024d3309ae9ab2450f5509ca7e223a79 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char HDAE5000_IO_PpiPortA;
extern unsigned char HDAE5000_IO_PpiControl;
void HDAE5000_PPI_Init(void)
{
    HDAE5000_IO_PpiControl = 0x90;
    HDAE5000_IO_PpiPortA = 0xff;
}
