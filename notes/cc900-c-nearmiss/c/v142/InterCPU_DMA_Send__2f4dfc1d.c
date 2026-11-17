/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_X_18a.c (2026-11-17-7-sub-r18)
   sha256 2f4dfc1d8ac8c3544bcd465502dc201e2b0fa76d164bd67b38a298482bf828df (name+funcs); compiled at -Xr */
extern void InterCPU_DMA_SendDataPacket(unsigned char ch, unsigned int n, unsigned char *buf);
void InterCPU_DMA_Send(unsigned char ch, unsigned int len, unsigned char *buf)
{
    while (len > 0x20) {
        InterCPU_DMA_SendDataPacket(ch, 0x20, buf);
        buf += 0x20;
        len -= 0x20;
    }
    InterCPU_DMA_SendDataPacket(ch, (unsigned char)len, buf);
}
