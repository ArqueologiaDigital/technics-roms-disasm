/* Functions of hdae5000_ui_display.s.  (hdae5000_fd_stream.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_fd_stream.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-name: WriteStream_a=HDAE5000_HD_WriteStream
   cc900-name: WriteStream_b=HDAE5000_HD_WriteStream
   cc900-name: WriteStream_c=HDAE5000_HD_WriteStream
   v1.10i port (h_v1misc 2026-11-19): HDAE5000_HD_WriteStream, three forms.  v1.10i's routine is an older shape than
   v1.15i's (214 bytes against 275):
   - the state test falls into the error return right after the compares (`cp a,2; jr z; cp a,1; jr z; ld hl,-1;
     jrl exit`): the switch's default comes first, as SaveOptSwEventCatch's;
   - there is no 0xffff split: one MemCopy of (unsigned int)chunk;
   - room lives in XIZ and chunk in the frame slot (v1.15i: chunk in XIZ, room in the slot), so room is
     `register` (a, b); form c leaves the allocation to the compiler with chunk declared first;
   - the room test uses the flags of `sub xiz,(xsp+4)` itself (no reload / or): forms b and c write it as
     `if ((room -= chunk) == 0)`, form a as two statements;
   - the buffer still goes to disk as 0x10000 bytes, as v1.15i.
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

int WriteStream_a(unsigned char *src, unsigned long n)
{
    register unsigned long room;
    int r;
    unsigned long chunk;
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

int WriteStream_b(unsigned char *src, unsigned long n)
{
    register unsigned long room;
    int r;
    unsigned long chunk;
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
        if ((room -= chunk) == 0) {
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

int WriteStream_c(unsigned char *src, unsigned long n)
{
    unsigned long chunk;
    int r;
    unsigned long room;
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
        if ((room -= chunk) == 0) {
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
