/* Phase 6, lane_p6 helper M, round 1, module 301, form a.
   SndParam_ApplyEventField (audio/note_voice_mapping.s): set byte 3 of an event record to c for the duration of a
   widget lookup, then apply the parameter as a part parameter (SndPart_SetParam) or a system parameter.
   Frame: the saved byte lowest (plain local), then the four address-taken locals in reverse declaration order
   (key +12 long, val +10, part +8, sub +6). */
/* cc900-module: SndParam_ApplySystemParam SndPart_SetParam */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int SndParam_ResolveWidget(unsigned char *ev, long *key, int *val);
extern int SndParam_KeyToLswPartNumber(long *key, int *part, int *sub);
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
