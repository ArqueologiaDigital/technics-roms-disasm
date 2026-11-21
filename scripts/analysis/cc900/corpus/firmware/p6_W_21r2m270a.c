/* helper W, round 21r2, module 270 (ui/ui_control_panel.s), form a: UI_PostDialEnable / UI_PostEvent_0x6E /
   UI_PostDialValueEvent.  The ROM widens the byte in two steps, byte to word as `ld e, a; ld d, 0` and word to long
   as `extz xde`.  At -O3 -Xr, a byte parameter gave `extz wa; ld de, wa; extz xde` (p6_Q_20r1m270a) and an
   (unsigned char) cast of a word parameter `ld xde, 0; ld e, a` (p6_U_21r1m270a).  `ld e, a; ld d, 0` is the shape
   of a word masked with 0xff into another register: here the argument is the word parameter `& 0xff`.
   cc900-options: -O3 -Xr
*/

extern long ApPostEvent(long, long, long);

#define EVT_AICEN_SET 0x1e0006eL
#define EVT_VALEN_SET 0x1e0006fL
#define EVT_EDIT_UP_SET 0x1e00071L

void UI_PostDialEnable(unsigned int v)
{
  ApPostEvent(-1L, EVT_VALEN_SET, v & 0xff);
}

void UI_PostEvent_0x6E(unsigned int v)
{
  ApPostEvent(-1L, EVT_AICEN_SET, v & 0xff);
}

void UI_PostDialValueEvent(unsigned int v)
{
  ApPostEvent(-1L, EVT_EDIT_UP_SET, v & 0xff);
}
