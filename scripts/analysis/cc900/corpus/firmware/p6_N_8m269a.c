/* lane_p6 helper N, round 8, form a: module 269 (file_io/single_load.s), new function.
   SingleLoad_SyncSoundMemCursorGroup: when the source and destination cursors lie on different sides of row 2n,
   copies one into the other and redraws: kinds 7 / 8 copy the destination's into the source (source PAINT),
   kinds 5 / 6 the source's into the destination (destination PARA_DRAW).  A switch with fall-through cases
   written 5, 6, 7, 8 (the ROM compares 8, 7, 6, 5); the 4th parameter on the stack (retd 4).
   cc900-options: -O3 -Xr
*/
/* cc900-module: SingleLoadDstFunc SingleLoadSrcFunc */

#define EVT_PAINT     0x1c0000bL
#define EVT_PARA_DRAW 0x1c0000fL
extern long SingleLoadSrcFunc(long, long, long);
extern long SingleLoadDstFunc(long, long, long);

void SingleLoad_SyncSoundMemCursorGroup(long kind, unsigned char n, unsigned char *a, unsigned char *b)
{
	unsigned char l;

	l = n + n;
	if (*a < l && *b < l)
		return;
	if (*a >= l && *b >= l)
		return;
	switch (kind) {
	case 5:
	case 6:
		*b = *a;
		SingleLoadDstFunc(0, EVT_PARA_DRAW, 0);
		break;
	case 7:
	case 8:
		*a = *b;
		SingleLoadSrcFunc(0, EVT_PAINT, 0);
		break;
	}
}
