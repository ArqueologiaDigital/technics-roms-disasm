/* lane_p6 helper N, round 7, form a: module 257 (sequencer/accompaniment_engine.s), new function.
   Tempo_AdjustEndMeasure: steps the end measure at 0x398c up (to 999) or down (to 1), keeps the start measure at
   0x398a within the 8 measures before it, and marks 0xe3e0 bit 4 dirty.  The ROM keeps the new value in WA after
   the up step and reloads it after the down step: an assignment expression up, a reload down.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Tempo_DisplayParamCommon */

extern unsigned int __near ram_398c;
extern unsigned int __near ram_398a;
extern unsigned char __near ram_e3e0;
extern void Tempo_DisplayParamCommon(unsigned int, unsigned int);

void Tempo_AdjustEndMeasure(unsigned char down)
{
	unsigned int e;
	unsigned int s;

	Tempo_DisplayParamCommon(0x81, 1);
	e = ram_398c;
	if (down == 0) {
		if (e >= 999)
			return;
		e = ram_398c = e + 1;
	} else {
		if (e <= 1)
			return;
		ram_398c = e - 1;
		e = ram_398c;
	}
	s = ram_398a;
	if (s > e)
		ram_398a = e;
	else if (s + 7 < e)
		ram_398a = e - 7;
	ram_e3e0 |= 0x10;
}
