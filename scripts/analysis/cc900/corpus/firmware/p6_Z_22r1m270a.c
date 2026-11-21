/* helper Z, round 22r1, module 270 (ui/ui_control_panel.s), form a: UI_PostDialEnable / UI_PostEvent_0x6E /
   UI_PostDialValueEvent.  Run r64's best (p6_W_21r2m270b@Xr) differed at +0: the ROM widens the byte as
   `ld e, a; ld d, 0; extz xde`.  That is exactly the code of their built sibling UI_PostDialRangeEvent
   (cc900/ui_control_panel_m270.c): an unsigned char parameter passed, with no cast, to ApPostEvent's long
   parameter.  Helper Q's byte-parameter form (p6_Q_20r1m270a) had an explicit (unsigned int) cast, which gave
   `extz wa; ld de, wa; extz xde`.  Here: the sibling's spelling.
   cc900-options: -O3 -Xr
*/

extern long ApPostEvent(long, long, long);

#define EVT_AICEN_SET 0x1e0006eL
#define EVT_VALEN_SET 0x1e0006fL
#define EVT_EDIT_UP_SET 0x1e00071L

void UI_PostDialEnable(unsigned char a)
{
  ApPostEvent(-1L, EVT_VALEN_SET, a);
}

void UI_PostEvent_0x6E(unsigned char a)
{
  ApPostEvent(-1L, EVT_AICEN_SET, a);
}

void UI_PostDialValueEvent(unsigned char a)
{
  ApPostEvent(-1L, EVT_EDIT_UP_SET, a);
}
