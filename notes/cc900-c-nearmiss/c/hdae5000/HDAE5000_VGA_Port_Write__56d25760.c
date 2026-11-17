/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_vga_port.c (2026-11-16-117-hd-r29-staged)
   sha256 56d257603b6b5ecf07f6b5b761a4f385c2d25b456d3d83dbddac68b651290b32 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern void HDAE5000_Delay_Loop(unsigned long n);
#define IO_VGA_PORTS 0x170000L    /* HDAE5000_IO_VgaPorts */
void HDAE5000_VGA_Port_Write(unsigned int port, unsigned char v)
{
    unsigned char *p;

    HDAE5000_Delay_Loop(0x100);
    p = (unsigned char *)((unsigned long)port + IO_VGA_PORTS);
    *p = v;
}
