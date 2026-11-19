/* Functions of hdae5000_hd_driver.s.  (hdae5000_misc3_hd_driver.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_misc3_hd_driver.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern char *__cdecl HDAE5000_StrNCpy(char *, const char *, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

extern int HDAE5000_ATA_SoftReset_Status(void);
extern int HDAE5000_ATA_Standby_Status(void);
extern int HDAE5000_HD_LoadSettings(void);

struct ParaBlk { unsigned char pad[14]; long value; char *str; };
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)

extern unsigned char HDAE5000_RAM_PcLinkStatusText[];
extern char HDAE5000_Fmt_1d_LyricJumpEditCheck[];
extern char HDAE5000_Str_Timb[];

void HDAE5000_PPORT_Svc26_ShowStatus(char *s)
{
    unsigned int n;

    n = HDAE5000_StrLen(s);
    if (n > 25)
        n = 25;
    HDAE5000_StrNCpy(&HDAE5000_RAM_PcLinkStatusText[7], s, n);
    CALLV(ROOT->ApPostEvent)(OBJ_PP_STATUS, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_PcLinkStatusText));
    CALLV(ROOT->ApPostEvent)(OBJ_PP_STATUS, EVT_PARA_DRAW, -1L);
}

/* no label in the tree: the procedure at 0x285f8b */
