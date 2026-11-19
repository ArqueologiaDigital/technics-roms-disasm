/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hd_r71m_fd_stream_ui_display__writestream.c (2026-11-19-59-hd-r71-v1misc)
   sha256 f7705698642cfb6c7762dae6e31bc8989d3d7011c660fba323eb26407cec7737 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern int HDAE5000_HD_WriteFile();
extern int HDAE5000_HD_AppendFile();
extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern unsigned char HDAE5000_RAM_RcmStreamState[];
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern long *HDAE5000_RAM_HdStreamSlot;
extern unsigned char HDAE5000_RAM_HdStreamState;
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
        if (n <= room)
            chunk = n;
        else
            chunk = room;
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
                r = HDAE5000_HD_WriteFile(HDAE5000_RAM_HdStreamBuffer, 0x10000L, HDAE5000_RAM_HdStreamSlot);
                HDAE5000_RAM_HdStreamState = 2;
            } else {
                r = HDAE5000_HD_AppendFile(HDAE5000_RAM_HdStreamBuffer, 0x10000L, HDAE5000_RAM_HdStreamSlot);
            }
            if (r != 0)
                break;
            HDAE5000_RAM_HdStreamFill = HDAE5000_RAM_HdStreamBuffer;
        }
        n -= chunk;
    } while (n != 0);
    return r;
}
