/* Functions of sequencer/seq_event_playback.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

#define EVT_HIDE                      0x1c00002L
#define EVT_INTERRUPT_TITLE           0x1c00016L
#define EVT_GET_PARAM                 0x1e0006bL
#define TITLE_MESAGE                  0x1a000eeL
extern long SendEvent(long, long, long);
extern long PostEvent(long, long, long);
extern void MainLswPut(long, int, int);
extern unsigned char __near GLOBAL_ERROR_CODE;

long GMYesFunc(long obj, long evt, long param)
{
    MainLswPut(0xc0, SendEvent(0x580001L, EVT_GET_PARAM, 0), 1);
    PostEvent(-1, EVT_HIDE, 0);
    GLOBAL_ERROR_CODE = 35;
    PostEvent(-1, EVT_INTERRUPT_TITLE, TITLE_MESAGE);
    return 0;
}
