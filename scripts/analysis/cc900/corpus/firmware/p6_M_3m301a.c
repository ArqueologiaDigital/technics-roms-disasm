/* Phase 6, lane_p6 helper M, round 3, module 301, form a: SndParam_ApplyEventField retry (run r41: +15 @Xr).
   The -Xr listing loads each &local argument straight into its register (lda XBC / XDE); the ROM evaluates every
   address argument into XWA and moves it (the first argument of the second call through XHL).  This form declares
   the two lookups without parameter lists (K&R), so the arguments are evaluated as unprototyped expressions. */
/* cc900-module: SndParam_ApplySystemParam SndPart_SetParam */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int SndParam_ResolveWidget();
extern int SndParam_KeyToLswPartNumber();
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
	if (SndParam_ResolveWidget(ev, &key, &val) != -1) {
		if (SndParam_KeyToLswPartNumber(&key, &part, &sub) != -1)
			SndPart_SetParam(part, sub, val);
		else
			SndParam_ApplySystemParam(key, val);
	}
	ev[3] = save;
}
