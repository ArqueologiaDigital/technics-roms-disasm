/* Functions of audio/presentation_sound_nav.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned int DIAL_ENABLE;
extern long DIAL_FOCUS;

long GetDialFocus(void)
{
	if (DIAL_ENABLE == 0) return -1;
	return DIAL_FOCUS;
}

/* cc900-module: DrawTitleBar ScreenProc */
extern void ChangeWallPalette(int n);
extern void SetWallColor(int c);

void SetWallColor(int c)
{
	int n;

	switch (c) {
	default:
		n = 0;
		break;
	case 0xf8:
		n = 2;
		break;
	case 2:
		n = 4;
		break;
	case 0xf9:
		n = 6;
		break;
	case 1:
		n = 8;
		break;
	}
	ChangeWallPalette(n);
}

/* cc900-module: SetDialFocus */
extern long DIAL_UP_CALLBACK;
extern long DIAL_UP_EVENT;
extern long DIAL_UP_PARAM;
extern void SetDialFocus(long);
extern void SetDialUp(long cb, long ev, long par);
extern long DIAL_DOWN_CALLBACK;
extern long DIAL_DOWN_EVENT;
extern long DIAL_DOWN_PARAM;
extern void SetDialDown(long cb, long ev, long p);

void SetDialUp(long cb, long ev, long par)
{
  DIAL_UP_CALLBACK = cb;
  DIAL_UP_EVENT = ev;
  DIAL_UP_PARAM = par;
  SetDialFocus(cb);
}
void SetDialDown(long cb, long ev, long p)
{
  DIAL_DOWN_CALLBACK = cb;
  DIAL_DOWN_EVENT = ev;
  DIAL_DOWN_PARAM = p;
  SetDialFocus(cb);
}
