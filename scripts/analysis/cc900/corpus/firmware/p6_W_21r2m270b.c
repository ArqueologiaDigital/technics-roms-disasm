/* helper W, round 21r2, module 270, form b: as form a, the masked word in a word local first, then that local passed
   to the long parameter: two conversions in two statements, as the ROM's two steps.
   cc900-options: -O3 -Xr
*/

extern long ApPostEvent(long, long, long);

#define EVT_AICEN_SET 0x1e0006eL
#define EVT_VALEN_SET 0x1e0006fL
#define EVT_EDIT_UP_SET 0x1e00071L

void UI_PostDialEnable(unsigned int v)
{
  unsigned int w;
  w = v & 0xff;
  ApPostEvent(-1L, EVT_VALEN_SET, w);
}

void UI_PostEvent_0x6E(unsigned int v)
{
  unsigned int w;
  w = v & 0xff;
  ApPostEvent(-1L, EVT_AICEN_SET, w);
}

void UI_PostDialValueEvent(unsigned int v)
{
  unsigned int w;
  w = v & 0xff;
  ApPostEvent(-1L, EVT_EDIT_UP_SET, w);
}
