/* helper Q, round 20r1, module 271 (ui/ui_control_panel.s, audio/presentation_sound_nav.s). */
/* cc900-module: SetDialFocus */

extern long DIAL_UP_CALLBACK;
extern long DIAL_UP_EVENT;
extern long DIAL_UP_PARAM;
extern void SetDialFocus(long);

int BoxRightCheck(int x)
{
  if (x > 0xa8 || x < 0xa0) return 0;
  return 1;
}

void SetDialUp(long cb, long ev, long par)
{
  DIAL_UP_CALLBACK = cb;
  DIAL_UP_EVENT = ev;
  DIAL_UP_PARAM = par;
  SetDialFocus(cb);
}
