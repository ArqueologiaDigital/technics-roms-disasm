/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_vga_port.c (2026-11-16-119-hd-r30)
   sha256 7e04bdb87c243f9ed852b3a7128747dc85eb10110e3ccd099c898fa0e896a53b (tar-sha256); compiled at -Xr
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
