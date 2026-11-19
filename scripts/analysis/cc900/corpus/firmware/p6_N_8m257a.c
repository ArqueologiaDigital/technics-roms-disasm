/* lane_p6 helper N, round 8, form a: module 257 (sequencer/accompaniment_engine.s), retry of p6_N_7m257a
   (p6-r51 Xr: +15).  Tempo_AdjustEndMeasure: V4.23 kept the end measure in BC and stepped a copy in WA; the ROM
   keeps it in WA and steps the copy in BC.  Form a: the step done on a second local declared before the value.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Tempo_DisplayParamCommon */

extern unsigned int __near ram_398c;
extern unsigned int __near ram_398a;
extern unsigned char __near ram_e3e0;
extern void Tempo_DisplayParamCommon(unsigned int, unsigned int);

void Tempo_AdjustEndMeasure(unsigned char down)
{
	unsigned int b;
	unsigned int e;
	unsigned int s;

	Tempo_DisplayParamCommon(0x81, 1);
	e = ram_398c;
	if (down == 0) {
		b = e;
		if (e >= 999)
			return;
		b++;
		ram_398c = b;
		e = b;
	} else {
		b = e;
		if (e <= 1)
			return;
		b--;
		ram_398c = b;
		e = ram_398c;
	}
	s = ram_398a;
	if (s > e)
		ram_398a = e;
	else if (s + 7 < e)
		ram_398a = e - 7;
	ram_e3e0 |= 0x10;
}
