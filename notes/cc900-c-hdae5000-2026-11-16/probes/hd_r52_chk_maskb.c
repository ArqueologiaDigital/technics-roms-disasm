/* lane_hd round 52, helper h_chk: mask-push variants for the Sfx / LBN RAM_DATA_REQ arm, on SfxLswBitCheck only
   (its sole run-51 difference was that push).  The ROM loads the mask into WA and pushes WA (`ld wa,(mem);
   pushw wa`); V4.23 pushed it from memory.  hd_r52_chk_sfx.c casts it to (int); here:
   SfxLsw_c: PartList_Build's prototype takes `int mask` (the implicit unsigned -> int conversion), no cast;
   SfxLsw_d: the same prototype, and the mask read through a local m (`m = mask; ...(m)`).
   cc900-options: -Xr
   cc900-name: SfxLsw_c=HDAE5000_SfxLswBitCheck
   cc900-name: SfxLsw_d=HDAE5000_SfxLswBitCheck
   cc900-module: HDAE5000_TypeSel_BuildMask HDAE5000_PartList_Build
   cc900-data: HDAE5000_SfxLswBitCheck 1 = HDAE5000_SfxLswBitCheck_CaseTable
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct TypeSel { unsigned int mask; unsigned char flag[10]; };
struct ParaBlk { unsigned char pad[14]; long value; char *str; };

extern void HDAE5000_TypeSel_BuildMask(struct TypeSel *rec);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, int mask);

extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;

extern char *HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[];
extern char HDAE5000_Fmt_s_SfxLswBitCheck[];

long SfxLsw_c(long obj, long ev, struct ParaBlk *arg)
{
    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_SfxLswBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_SaveOptions.flag[0] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_SaveOptions.flag[0] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[0];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
        HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong,
                                HDAE5000_RAM_SaveOptions.mask);
        return 0;
    default:
        return 0;
    }
}

long SfxLsw_d(long obj, long ev, struct ParaBlk *arg)
{
    unsigned int m;

    switch (ev) {
    case EVT_GET_RAM_STRING:
        HDAE5000_SPrintf(arg->str, HDAE5000_Fmt_s_SfxLswBitCheck, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES[arg->value]);
        return obj;
    case EVT_GET_LARGE_STEP:
        return 1;
    case EVT_GET_SMALL_STEP:
        return 1;
    case EVT_GET_MAX:
        return HDAE5000_RAM_SaveOptions.flag[0] == 0 ? 0L : 2L;
    case EVT_GET_MIN:
        return HDAE5000_RAM_SaveOptions.flag[0] == 0 ? 0L : 1L;
    case EVT_GET_RAM_ADDRESS:
        return (long)&HDAE5000_RAM_SaveOptions.flag[0];
    case EVT_GET_RAM_SIZE:
        return 1;
    case EVT_RAM_DATA_REQ:
        HDAE5000_TypeSel_BuildMask(&HDAE5000_RAM_SaveOptions);
        m = HDAE5000_RAM_SaveOptions.mask;
        HDAE5000_PartList_Build(OBJ_HD_FILE_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, m);
        return 0;
    default:
        return 0;
    }
}
