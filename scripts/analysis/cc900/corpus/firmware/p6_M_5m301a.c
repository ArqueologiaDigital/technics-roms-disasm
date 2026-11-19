/* Phase 6, lane_p6 helper M, round 5, module 301, form a: SndParam_ApplyEventField (run r43: 3m301b +15 @Xr).
   The void * casts gave the ROM's `lda xwa,&local; ld xR,xwa` argument moves; the only spot left was the event
   pointer, which 3m301b also cast (V4.23 then parked it in XHL first): here ev is passed uncast, the two locals
   cast (the second call keeps all three casts, as the ROM moves its first argument through XHL). */
/* cc900-module: SndParam_ApplySystemParam SndPart_SetParam */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int SndParam_ResolveWidget(unsigned char *ev, void *key, void *val);
extern int SndParam_KeyToLswPartNumber(void *key, void *part, void *sub);
extern void SndPart_SetParam(int, int, int);
extern void SndParam_ApplySystemParam(long key, int val);
extern void SndParam_ApplyEventField(unsigned char *ev, unsigned char c);

void SndParam_ApplyEventField(unsigned char *ev, unsigned char c)
{
	unsigned char save;
	long key;
	int val;
	int part;
	int sub;

	save = ev[3];
	ev[3] = c;
	if (SndParam_ResolveWidget(ev, (void *)&key, (void *)&val) != -1) {
		if (SndParam_KeyToLswPartNumber((void *)&key, (void *)&part, (void *)&sub) != -1)
			SndPart_SetParam(part, sub, val);
		else
			SndParam_ApplySystemParam(key, val);
	}
	ev[3] = save;
}
