/* Functions of hdae5000_ui_display.s.  (hdae5000_fd_stream_ui_display__writestream_r2_r77.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_fd_stream_ui_display__writestream_r2_r77.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-name: WriteStream_d=HDAE5000_HD_WriteStream
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern int HDAE5000_HD_WriteFile();
extern int HDAE5000_HD_AppendFile();

extern unsigned char HDAE5000_RAM_HdStreamBuffer[];
extern unsigned char HDAE5000_RAM_RcmStreamState[];
extern unsigned char *HDAE5000_RAM_HdStreamFill;
extern long *HDAE5000_RAM_HdStreamSlot;      /* the open write's first-cluster slot */
extern unsigned char HDAE5000_RAM_HdStreamState;

int WriteStream_d(unsigned char *src, unsigned long n)
{
    register unsigned long room;
    unsigned long chunk;
    int r;
    r = 0;
    switch (HDAE5000_RAM_HdStreamState) {
    default:
        return -1;
    case 1:
    case 2:
        if (n == 0)
            return -1;
        break;
    }
    do {
        room = HDAE5000_RAM_RcmStreamState - HDAE5000_RAM_HdStreamFill;
        if (n <= room)
            chunk = n;
        else
            chunk = room;
        HDAE5000_MemCopy(HDAE5000_RAM_HdStreamFill, src, (unsigned int)chunk);
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
