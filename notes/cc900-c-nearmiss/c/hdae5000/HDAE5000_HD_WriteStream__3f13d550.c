/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r3_ma.c (2026-11-16-49-hd-r3)
   sha256 3f13d550098112a39b7b7045a18ae8bd6eb47b816e76586d39584f65bb10463a (tar-sha256); compiled at -Xr */
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern unsigned char HDAE5000_RAM_HdStreamState;
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern unsigned long HDAE5000_RAM_HdStreamSlot;
extern unsigned char HDAE5000_RAM_HdStreamBuffer[0x8000];
extern unsigned char HDAE5000_RAM_RcmStreamState[];
extern int HDAE5000_HD_WriteFile(unsigned char *buf, unsigned long size, unsigned long slot);
extern int HDAE5000_HD_AppendFile(unsigned char *buf, unsigned long size, unsigned long slot);
int HDAE5000_HD_WriteStream(unsigned char *src, unsigned long n)
{
    unsigned long room;
    int r;
    unsigned long chunk;
    r = 0;
    switch (HDAE5000_RAM_HdStreamState) {
    case 1:
    case 2:
        if (n == 0)
            return -1;
        break;
    default:
        return -1;
    }
    do {
        room = HDAE5000_RAM_RcmStreamState - HDAE5000_RAM_HdStreamFill;
        chunk = n <= room ? n : room;
        if (chunk > 0xffff) {
            HDAE5000_MemCopy(HDAE5000_RAM_HdStreamFill, src, 0xffff);
            HDAE5000_MemCopy(HDAE5000_RAM_HdStreamFill + 0xffff, src + 0xffff, (unsigned int)(chunk - 0xffff));
        } else {
            HDAE5000_MemCopy(HDAE5000_RAM_HdStreamFill, src, (unsigned int)chunk);
        }
        src += chunk;
        HDAE5000_RAM_HdStreamFill += chunk;
        room -= chunk;
        if (room == 0) {
            if (HDAE5000_RAM_HdStreamState == 1) {
                r = HDAE5000_HD_WriteFile(HDAE5000_RAM_HdStreamBuffer, 0x8000, HDAE5000_RAM_HdStreamSlot);
                HDAE5000_RAM_HdStreamState = 2;
            } else {
                r = HDAE5000_HD_AppendFile(HDAE5000_RAM_HdStreamBuffer, 0x8000, HDAE5000_RAM_HdStreamSlot);
            }
            if (r != 0)
                break;
            HDAE5000_RAM_HdStreamFill = HDAE5000_RAM_HdStreamBuffer;
        }
        n -= chunk;
    } while (n != 0);
    return r;
}
