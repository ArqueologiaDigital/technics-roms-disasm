/* Functions of sequencer/seq_event_playback.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

#define EVT_GET_LANGUAGE_PTR          0x1e0009fL
extern long StsSplitCheck_PtrTable[];
#define EVT_SHOW                      0x1c00001L
#define EVT_CHANGE_MODE               0x1c00014L
#define EVT_SET_NOT_DRAW_FLAG         0x1e0009eL
#define TITLE_MESAGE                  0x1a000eeL
#define NAKA_MODE_MD_NORMAL           0x1800001L
extern long SendEvent(long, long, long);
extern long PostEvent(long, long, long);
extern long GetTitleOld(void);

long StsSplitCheck(long obj, long evt, long param)
{
    if (evt == EVT_GET_LANGUAGE_PTR) return (long)StsSplitCheck_PtrTable;
    return 0;
}

long TtMdGm(long obj, long evt, long param)
{
    if (evt == EVT_SHOW && GetTitleOld() == TITLE_MESAGE) {
        SendEvent(-1, EVT_SET_NOT_DRAW_FLAG, 1);
        PostEvent(-1, EVT_SET_NOT_DRAW_FLAG, 0);
        PostEvent(-1, EVT_CHANGE_MODE, NAKA_MODE_MD_NORMAL);
    }
    return 0;
}
