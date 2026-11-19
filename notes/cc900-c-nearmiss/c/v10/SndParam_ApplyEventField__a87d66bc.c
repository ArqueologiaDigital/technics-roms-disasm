/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_3m301b.c (2026-11-19-19-p6-r43)
   sha256 a87d66bc1211551521e8df6ad4207f442f8af7aa0b06d729e5ada458550fb06e (tar-sha256); compiled at -Xr */
extern int SndParam_ResolveWidget(void *ev, void *key, void *val);
extern int SndParam_KeyToLswPartNumber(void *key, void *part, void *sub);
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
	if (SndParam_ResolveWidget((void *)ev, (void *)&key, (void *)&val) != -1) {
		if (SndParam_KeyToLswPartNumber((void *)&key, (void *)&part, (void *)&sub) != -1)
			SndPart_SetParam(part, sub, val);
		else
			SndParam_ApplySystemParam(key, val);
	}
	ev[3] = save;
}
