/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FetchOscTableEntry_LoadReg FetchOscTableEntry_LoadReg2 */   /* scripts/analysis/cc900/module_calls.py v10 */

struct sndtab { long a0; long a4; };
extern struct sndtab *__near SOUND_TABLE_BASE;
extern int SndParam_LookupReadOnly(long);
extern unsigned char GetCurrentPartSelect(void);
extern unsigned char ApplyProgramChangeAs_DoLookupRe(void);
extern void FetchOscTableEntry_LoadReg(unsigned char *);
extern void FetchOscTableEntry_LoadReg2(unsigned char *);
extern void SndParam_ApplyProgramChange(unsigned char *p);

unsigned char ApplyProgramChangeAs_DoLookupRe(void)
{
	unsigned char r;

	if (SndParam_LookupReadOnly(0xc0L) == 1) {
		if (GetCurrentPartSelect() != 15)
			r = 0x80;
		else
			r = 0x89;
	} else
		r = SOUND_TABLE_BASE->a4;
	return r;
}

void SndParam_ApplyProgramChange(unsigned char *p)
{
	if (SndParam_LookupReadOnly(0xc0L) == 1)
		FetchOscTableEntry_LoadReg2(p);
	else
		FetchOscTableEntry_LoadReg(p);
}
