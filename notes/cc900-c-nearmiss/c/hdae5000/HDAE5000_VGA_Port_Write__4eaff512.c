/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r27_c2.c (2026-11-16-116-hd-r27c)
   sha256 4eaff5124d09d8fd753256fae45b448e8bec06edd9466c96cd5dfc33460d7540 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: VgaPortWrite_c=HDAE5000_VGA_Port_Write */
extern void HDAE5000_Delay_Loop(unsigned long n);
#define IO_VGA_PORTS 0x170000L    /* HDAE5000_IO_VgaPorts */
void VgaPortWrite_c(unsigned int port, unsigned char v)
{
    HDAE5000_Delay_Loop(0x100);
    *(unsigned char *)((unsigned long)port + IO_VGA_PORTS) = v;
}
