/* lane_hd round 50, helper h_chk: the delete-option edit checks of hdae5000_filesystem.s, in ROM order:
   HDAE5000_DelOptNameCheck and the nine Del*EditCheck procedures (one per part kind: flag[0..8] of the delete
   options, HDAE5000_RAM_DeleteOptions+2..+10).  Each answers the numeric-edit events of an object: RAM_STRING
   ("---"/OFF/DEL), LARGE/SMALL_STEP, MAX/MIN (0 when the part is absent), RAM_ADDRESS, RAM_SIZE and
   RAM_DATA_REQ (rebuild the delete mask).  DelTlxEditCheck's MIN is 2 when its flag is 1, else 1 (a general-form
   ?: in the false arm of the preload-form one).  DelOptNameCheck's RAM_ADDRESS is the SAVE options' byte +11, as
   in the ROM (the same as FileOptNameCheck's).
   cc900-options: -Xr
   cc900-module: HDAE5000_TypeSel_BuildMask
   cc900-data: HDAE5000_DelOptNameCheck 1 = HDAE5000_DelOptNameCheck_CaseTable
   cc900-data: HDAE5000_DelLswEditCheck 1 = HDAE5000_DelLswEditCheck_CaseTable
   cc900-data: HDAE5000_DelPmtEditCheck 1 = HDAE5000_DelPmtEditCheck_CaseTable
   cc900-data: HDAE5000_DelSqtEditCheck 1 = HDAE5000_DelSqtEditCheck_CaseTable
   cc900-data: HDAE5000_DelCmpEditCheck 1 = HDAE5000_DelCmpEditCheck_CaseTable
   cc900-data: HDAE5000_DelTmEditCheck 1 = HDAE5000_DelTmEditCheck_CaseTable
   cc900-data: HDAE5000_DelMspEditCheck 1 = HDAE5000_DelMspEditCheck_CaseTable
   cc900-data: HDAE5000_DelRcmEditCheck 1 = HDAE5000_DelRcmEditCheck_CaseTable
   cc900-data: HDAE5000_DelMdEditCheck 1 = HDAE5000_DelMdEditCheck_CaseTable
   cc900-data: HDAE5000_DelTlxEditCheck 1 = HDAE5000_DelTlxEditCheck_CaseTable
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct TypeSel { unsigned int mask; unsigned char flag[10]; };
struct ParaBlk { unsigned char pad[14]; long value; char *str; };

/* ---- this module (calr) ---- */
extern void HDAE5000_TypeSel_BuildMask(struct TypeSel *rec);

/* ---- other modules (call) ---- */
extern unsigned char *HDAE5000_SongRecord_Address(unsigned int dir, unsigned int song);

/* ---- RAM ---- */
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern struct TypeSel HDAE5000_RAM_DeleteOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;

/* ---- ROM ---- */
extern char *HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[];
extern char HDAE5000_Fmt_s_DelOptNameCheck[];
extern char HDAE5000_Fmt_s_DelLswEditCheck[];
extern char HDAE5000_Fmt_s_DelPmtEditCheck[];
extern char HDAE5000_Fmt_s_DelSqtEditCheck[];
extern char HDAE5000_Fmt_s_DelCmpEditCheck[];
extern char HDAE5000_Fmt_s_DelTmEditCheck[];
extern char HDAE5000_Fmt_s_DelMspEditCheck[];
extern char HDAE5000_Fmt_s_DelRcmEditCheck[];
extern char HDAE5000_Fmt_s_DelMdEditCheck[];
extern char HDAE5000_Fmt_s_DelTlxEditCheck[];

long HDAE5000_DelOptNameCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_DelOptNameCheck,
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

long HDAE5000_DelLswEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_DelLswEditCheck, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_DeleteOptions.flag[0] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_DeleteOptions.flag[0] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_DeleteOptions.flag[0];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_DeleteOptions);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_DelPmtEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_DelPmtEditCheck, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_DeleteOptions.flag[1] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_DeleteOptions.flag[1] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_DeleteOptions.flag[1];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_DeleteOptions);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_DelSqtEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_DelSqtEditCheck, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_DeleteOptions.flag[2] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_DeleteOptions.flag[2] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_DeleteOptions.flag[2];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_DeleteOptions);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_DelCmpEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_DelCmpEditCheck, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_DeleteOptions.flag[3] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_DeleteOptions.flag[3] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_DeleteOptions.flag[3];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_DeleteOptions);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_DelTmEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_DelTmEditCheck, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_DeleteOptions.flag[4] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_DeleteOptions.flag[4] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_DeleteOptions.flag[4];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_DeleteOptions);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_DelMspEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_DelMspEditCheck, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_DeleteOptions.flag[5] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_DeleteOptions.flag[5] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_DeleteOptions.flag[5];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_DeleteOptions);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_DelRcmEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_DelRcmEditCheck, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_DeleteOptions.flag[6] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_DeleteOptions.flag[6] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_DeleteOptions.flag[6];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_DeleteOptions);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_DelMdEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_DelMdEditCheck, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_DeleteOptions.flag[7] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_DeleteOptions.flag[7] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_DeleteOptions.flag[7];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_DeleteOptions);
        return 0;
    default:
        return 0;
    }
}

long HDAE5000_DelTlxEditCheck(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_DelTlxEditCheck, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_DeleteOptions.flag[8] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_DeleteOptions.flag[8] == 0 ? 0L
               : (HDAE5000_RAM_DeleteOptions.flag[8] == 1 ? 2L : 1L);
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_DeleteOptions.flag[8];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_DeleteOptions);
        return 0;
    default:
        return 0;
    }
}
