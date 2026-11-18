/* hdae5000_v2_01i: the functions of hdae5000/cc900-staged/hdae5000_name_checks.c that V4.23 reproduces unchanged in HD-AE5000 v2.01i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_name_checks.c.
   cc900-options: -Xr
   cc900-data: HDAE5000_FileOptNameCheck 1 = HDAE5000_FileOptNameCheck_CaseTable
   cc900-data: HDAE5000_FileLBNNameCheck 1 = HDAE5000_FileLBNNameCheck_CaseTable
   cc900-data: HDAE5000_DelOptNameCheck 1 = HDAE5000_DelOptNameCheck_CaseTable
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern char *__cdecl HDAE5000_StrCpy(char *, char *);

struct TypeSel { unsigned int mask; unsigned char flag[10]; };
struct ParaBlk { unsigned char pad[14]; long value; char *str; };

extern unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song);

extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned int HDAE5000_RAM_LbnDigitPos;

extern char HDAE5000_Str_Blank26[];
extern char HDAE5000_Fmt_s_FileOptNameCheck[];
extern char HDAE5000_Fmt_s_FileLBNNameCheck[];
extern char HDAE5000_Fmt_s_DelOptNameCheck[];

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
        return (long)&HDAE5000_RAM_SaveOptions.flag[9];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_FileLBNNameCheck(long obj, long ev, struct ParaBlk *arg)
{
    struct ParaBlk *p;

    switch (ev) {
    case EVT_GET_RAM_STRING:
        p = arg;
        if (HDAE5000_RAM_LbnDigitPos == 5)
            HDAE5000_SPrintf(p->str, HDAE5000_Fmt_s_FileLBNNameCheck,
                             HDAE5000_SongRecord_Address(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong));
        else
            HDAE5000_StrCpy(p->str, HDAE5000_Str_Blank26);
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
        return (long)&HDAE5000_RAM_SaveOptions.flag[9];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_DelOptNameCheck(long obj, long ev, struct ParaBlk *arg)
{
    struct ParaBlk *p;

    switch (ev) {
    case EVT_GET_RAM_STRING:
        p = arg;
        HDAE5000_SPrintf(p->str, HDAE5000_Fmt_s_DelOptNameCheck,
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
        return (long)&HDAE5000_RAM_SaveOptions.flag[9];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        return 0;
    default:
        return 0;
    }
}
