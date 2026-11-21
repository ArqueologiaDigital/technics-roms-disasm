/* Functions of ui/ui_control_panel.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern long ApPostEvent(long, long, long);
#define EVT_VALEN_SET 0x1e0006fL
extern void UI_PostDialEnable(unsigned char a);
#define EVT_EDIT_UP_SET 0x1e00071L
extern void UI_PostDialValueEvent(unsigned char a);
#define EVT_AICEN_SET 0x1e0006eL
extern void UI_PostEvent_0x6E(unsigned char a);

void UI_PostDialEnable(unsigned char a)
{
  ApPostEvent(-1L, EVT_VALEN_SET, a);
}

void UI_PostDialValueEvent(unsigned char a)
{
  ApPostEvent(-1L, EVT_EDIT_UP_SET, a);
}

void UI_PostEvent_0x6E(unsigned char a)
{
  ApPostEvent(-1L, EVT_AICEN_SET, a);
}
