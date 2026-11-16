/* hdae5000_v2_01i: the functions of hdae5000/cc900-staged/hdae5000_drv_screens4.c that V4.23 reproduces unchanged in HD-AE5000 v2.01i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_drv_screens4.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_FdList_Scan HDAE5000_Lbn_ShowEntry HDAE5000_TypeSel_BuildMask
   cc900-module: HDAE5000_LoadSongWithUi HDAE5000_TypeSel_Init HDAE5000_PartList_Build
   cc900-module: HDAE5000_Lbn_StepDigit HDAE5000_Lbn_TypeDigit
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct TypeSel { unsigned int mask; unsigned char flag[10]; };
struct ParaBlk { unsigned char pad[14]; long value; char *str; };

/* ---- this module (calr) ---- */
extern void HDAE5000_FdList_Scan(void);
extern int HDAE5000_Lbn_ShowEntry(unsigned int dir, unsigned int song, unsigned int pos, int draw);
extern void HDAE5000_TypeSel_BuildMask(struct TypeSel *rec);
extern int HDAE5000_LoadSongWithUi(unsigned int dir, unsigned int song, unsigned int mask, int ui, long obj);
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int n);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);
extern void HDAE5000_Lbn_TypeDigit(long obj, int digit);
void HDAE5000_Lbn_StepDigit(int dir, int song, int pos, int step);

/* ---- other modules (call) ---- */
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);

/* ---- RAM ---- */
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned int HDAE5000_RAM_LbnDigitPos;
extern unsigned int HDAE5000_RAM_LbnDir;
extern unsigned int HDAE5000_RAM_LbnSong;
extern unsigned char HDAE5000_RAM_LyricJump;
extern unsigned char HDAE5000_RAM_WriteProtect;
extern char ram_23a04e[];                        /* HDAE5000_RAM_Name_ColumnRuler (a .set, not resolvable) */

/* ---- ROM ---- */
extern char HDAE5000_Fmt_s_SaveOptNameCheck[];
extern char HDAE5000_Str_LBNS[];
extern char HDAE5000_Str_TLBN[];
extern unsigned char HDAE5000_TypeSel_TemplateBlank[];

long HDAE5000_ErrMsgTimerCatchLBN(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_TLBN);
        return 0;
    case EVT_HDAE_TIMER_BACK:
        CALLV(ROOT->PostEvent)(arg, EVT_SHOW, 0L);
        HDAE5000_Lbn_ShowEntry(0, 0, 6, 1);
        return 0;
    }
}
