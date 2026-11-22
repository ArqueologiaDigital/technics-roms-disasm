/* hd_r99_scr.c (lane_hd round 99, 2026-11-22): the two routines of hd_screen.py's candidates (screen/hd_2026-11-22)
   whose bodies carry no sign of hand assembly at all.  The other 24 candidates are the Toshiba library (FltDec_*,
   Int_To_*, DoPrintf_*, UMod32: no C is written for library routines) or disk-driver routines with hand signs the
   screen's marks do not catch (absolute `jp cc`, arguments in XHL / XIX, `call` + `ret` where V4.23 jumps).
   cc900-options: -Xr
   cc900-name: HdRstKey_b=HDAE5000_HD_ResetVersionKeyWord
   cc900-name: HdClrStat_b=HDAE5000_HD_ClearStatusBytes
     HDAE5000_HD_ResetVersionKeyWord  ROM `ld xwa,0xffee; ld (key),xwa; ret`: an unsigned long store (b: long)
     HDAE5000_HD_ClearStatusBytes     ROM ten `ld (bytes+N:24),0`: ten stores (b: through a pointer to the array)
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

void HdRstKey_b(void)
{
    ram_229c60 = 0xffeeL;
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

void HdClrStat_b(void)
{
    ram_229daf.b[0] = 0;
    ram_229daf.b[1] = 0;
    ram_229daf.b[2] = 0;
    ram_229daf.b[3] = 0;
    ram_229daf.b[4] = 0;
    ram_229daf.b[5] = 0;
    ram_229daf.b[6] = 0;
    ram_229daf.b[7] = 0;
    ram_229daf.b[8] = 0;
    ram_229daf.b[9] = 0;
}
