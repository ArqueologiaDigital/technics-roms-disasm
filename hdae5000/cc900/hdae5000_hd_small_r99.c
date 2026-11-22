/* Functions of hdae5000_ui_display.s.  (hdae5000_hd_small_r99.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_hd_small_r99.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern unsigned long HDAE5000_RAM_HdVersionKeyWord;
extern long ram_229c60;                         /* the same cell, as a signed long (form b) */
extern unsigned char HDAE5000_RAM_HdStatusBytes[10];

void HDAE5000_HD_ResetVersionKeyWord(void)
{
    HDAE5000_RAM_HdVersionKeyWord = 0xffeeUL;
}

void HDAE5000_HD_ClearStatusBytes(void)
{
    HDAE5000_RAM_HdStatusBytes[0] = 0;
    HDAE5000_RAM_HdStatusBytes[1] = 0;
    HDAE5000_RAM_HdStatusBytes[2] = 0;
    HDAE5000_RAM_HdStatusBytes[3] = 0;
    HDAE5000_RAM_HdStatusBytes[4] = 0;
    HDAE5000_RAM_HdStatusBytes[5] = 0;
    HDAE5000_RAM_HdStatusBytes[6] = 0;
    HDAE5000_RAM_HdStatusBytes[7] = 0;
    HDAE5000_RAM_HdStatusBytes[8] = 0;
    HDAE5000_RAM_HdStatusBytes[9] = 0;
}

struct HdStatus { unsigned char b[10]; };
extern struct HdStatus ram_229daf;              /* the same ten bytes, as a structure (form b) */
