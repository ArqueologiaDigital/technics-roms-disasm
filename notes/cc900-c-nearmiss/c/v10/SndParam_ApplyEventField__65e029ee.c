/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_1m301a.c (2026-11-19-13-p6-r41)
   sha256 65e029ee8131144d772b7817919d872bb8a446d8236fbc17c91a54b329d84377 (tar-sha256); compiled at -Xr */
extern int SndParam_ResolveWidget(unsigned char *ev, long *key, int *val);
extern int SndParam_KeyToLswPartNumber(long *key, int *part, int *sub);
extern void SndPart_SetParam(int, int, int);
extern void SndParam_ApplySystemParam(long key, int val);
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
