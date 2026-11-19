/* Functions of hdae5000_ui_display.s.  (hdae5000_pport_services.c, v1.10i port of HDAE5000_PPORT_Svc25_ReadFileHD)
   cc900-options: -Xr
   cc900-name: PP_Svc25=HDAE5000_PPORT_Svc25_ReadFileHD
   cc900-module: HDAE5000_DebugTrace
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern unsigned char HDAE5000_RAM_PportInfoBlock[];
extern unsigned char HDAE5000_RAM_PportReadState;

#define PPIB HDAE5000_RAM_PportInfoBlock

/* trace banner (HDAE5000_PPORT_Svc25_ReadFileHD_Str_ReadFileHD), passed in XWA: lda */
extern char ram_2e0cc0[];                                                 /* Svc25 */

extern int HDAE5000_HD_ReadFile(void *dst, unsigned long n, unsigned long *slot);
extern int HDAE5000_HD_ReadFileNext(void *dst, unsigned long n, unsigned long *slot);
extern void HDAE5000_DebugTrace(char *s);

/* v1.10i: the read slot pointer (set by Svc24) lives at PportInfoBlock + 4288 (0x23c4c0; v2.06i +206) */
int PP_Svc25(void *dst, unsigned long n)
{
    int ret;

    ret = 1;
    HDAE5000_DebugTrace(ram_2e0cc0);
    if (HDAE5000_RAM_PportReadState == 1) {
        HDAE5000_RAM_PportReadState = 2;
        if (HDAE5000_HD_ReadFile(dst, n, *(unsigned long **)(PPIB + 4288)) != -1)
            ret = 0;
    } else if (HDAE5000_RAM_PportReadState == 2) {
        if (HDAE5000_HD_ReadFileNext(dst, n, *(unsigned long **)(PPIB + 4288)) != -1)
            ret = 0;
    } else
        HDAE5000_RAM_PportReadState = 0;
    return ret;
}
