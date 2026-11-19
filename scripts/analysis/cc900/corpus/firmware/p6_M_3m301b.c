/* Phase 6, lane_p6 helper M, round 3, module 301, form b: SndParam_ApplyEventField retry (alternative to
   p6_M_3m301a.c).  The address arguments cast to the callee's void * parameters (a converted address may be
   evaluated into XWA first, as the ROM does). */
/* cc900-module: SndParam_ApplySystemParam SndPart_SetParam */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int SndParam_ResolveWidget(void *ev, void *key, void *val);
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
	if (SndParam_ResolveWidget((void *)ev, (void *)&key, (void *)&val) != -1) {
		if (SndParam_KeyToLswPartNumber((void *)&key, (void *)&part, (void *)&sub) != -1)
			SndPart_SetParam(part, sub, val);
		else
			SndParam_ApplySystemParam(key, val);
	}
	ev[3] = save;
}
