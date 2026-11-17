/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_X_18b.c (2026-11-17-7-sub-r18)
   sha256 4cb6419b219c04611a2f0cd41db9021edc090635685d23af8b08ee039d16493c (name+funcs); compiled at -Xr */
extern void InterCPU_DMA_SendDataPacket();
void InterCPU_DMA_Send(unsigned char ch, unsigned int len, unsigned char *buf)
{
    while (len > 0x20) {
        InterCPU_DMA_SendDataPacket(ch, 0x20, buf);
        buf += 0x20;
        len -= 0x20;
    }
    InterCPU_DMA_SendDataPacket(ch, (unsigned char)len, buf);
}
