/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_S_17b.c (2026-11-16-126-sub-r17)
   sha256 36b65b7fa74bf76e430515ae6a5b836fab357ad55369f5243cb9d009f7d94d07 (name+funcs); compiled at -Xr */
extern void InterCPU_DMA_SendDataPacket(int ch, unsigned char n, unsigned char *buf);
void InterCPU_DMA_Send(unsigned char ch, unsigned int len, unsigned char *buf)
{
    while (len > 0x20) {
        InterCPU_DMA_SendDataPacket(ch, 0x20, buf);
        buf += 0x20;
        len -= 0x20;
    }
    InterCPU_DMA_SendDataPacket(ch, len, buf);
}
