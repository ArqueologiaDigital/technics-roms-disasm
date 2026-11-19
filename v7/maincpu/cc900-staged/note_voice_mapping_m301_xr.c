/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
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
