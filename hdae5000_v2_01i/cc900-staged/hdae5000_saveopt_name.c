/* hdae5000_v2_01i: the functions of hdae5000/cc900/hdae5000_saveopt_name.c that V4.23 reproduces in HD-AE5000 v2.01i with the tree's own object ids and ram_ addresses (port_built.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_saveopt_name.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_FdList_Scan HDAE5000_Lbn_ShowEntry HDAE5000_TypeSel_BuildMask
   cc900-module: HDAE5000_LoadSongWithUi HDAE5000_TypeSel_Init HDAE5000_PartList_Build
   cc900-module: HDAE5000_Lbn_StepDigit HDAE5000_Lbn_TypeDigit
   cc900-data: HDAE5000_SaveOptNameCheck 1 = HDAE5000_SaveOptNameCheck_CaseTable
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
extern char ram_239fd6[];                        /* HDAE5000_RAM_Name_ColumnRuler (a .set, not resolvable) */

/* ---- ROM ---- */
extern char HDAE5000_Fmt_s_SaveOptNameCheck[];
extern char HDAE5000_Str_LBNS[];
extern char HDAE5000_Str_TLBN[];
extern unsigned char HDAE5000_TypeSel_TemplateBlank[];

long HDAE5000_SaveOptNameCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_SaveOptNameCheck, ram_239fd6);
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
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
        return 0;
    default:
        return 0;
    }
}
