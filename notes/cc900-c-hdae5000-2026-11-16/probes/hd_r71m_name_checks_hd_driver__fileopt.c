/* Functions of hdae5000_hd_driver.s.  (hdae5000_name_checks.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_name_checks.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-data: HDAE5000_FileOptNameCheck 1 = HDAE5000_FileOptNameCheck_CaseTable
   v1.15i port (h_v1misc 2026-11-19): the RAM address returned is the save-option record's +10 (flag[8], 0x22aa0e;
   8 part flags in v1.x) where v2.06i returns +11 (flag[9]).
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct TypeSel { unsigned int mask; unsigned char flag[10]; };
struct ParaBlk { unsigned char pad[14]; long value; char *str; };

extern unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song);

extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;

extern char HDAE5000_Fmt_s_FileOptNameCheck[];

long HDAE5000_FileOptNameCheck(long obj, long ev, struct ParaBlk *arg)
{
    struct ParaBlk *p;

    switch (ev) {
    case EVT_GET_RAM_STRING:
        p = arg;
        HDAE5000_SPrintf(p->str, HDAE5000_Fmt_s_FileOptNameCheck,
                         HDAE5000_SongRecord_Address(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong));
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return 0;
    case EVT_GET_MIN:
        return 0;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[8];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        return 0;
    default:
        return 0;
    }
}
