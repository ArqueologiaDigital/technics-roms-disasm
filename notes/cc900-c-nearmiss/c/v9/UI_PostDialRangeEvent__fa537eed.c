/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_control_panel_m270.c (2026-11-21-5-p6-r60)
   sha256 fa537eed37d833202096de721e4b95172023268baf02638179e1773d3aef7478 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define EVT_EDIT_DOWN_SET 0x1e00070L
extern long ApPostEvent(long, long, long);
void UI_PostDialRangeEvent(unsigned char a)
{
  ApPostEvent(-1L, EVT_EDIT_DOWN_SET, a);
}
