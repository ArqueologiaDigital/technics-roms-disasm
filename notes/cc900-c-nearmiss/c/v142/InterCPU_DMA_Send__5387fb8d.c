/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_E_7a.c (2026-11-16-79-sub-r7)
   sha256 5387fb8dc1a4a10ac803200b808b9746db79da03261b93a1784389397bca675d (name+funcs); compiled at -Xr */
extern void InterCPU_DMA_SendDataPacket(int ch, int n, unsigned char *buf);
void InterCPU_DMA_Send(unsigned char ch, unsigned int len, unsigned char *buf)
{
    while (len > 0x20) {
        InterCPU_DMA_SendDataPacket(ch, 0x20, buf);
        buf += 0x20;
        len -= 0x20;
    }
    InterCPU_DMA_SendDataPacket(ch, (unsigned char)len, buf);
}
