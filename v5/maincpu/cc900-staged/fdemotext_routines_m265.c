/* Functions of demo/fdemotext_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FDemoText_CheckVoiceState FDemoText_LookupTableEntry */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char *FDemoText_LookupTableEntry(unsigned int);
extern unsigned char FDemoText_CheckVoiceState(unsigned int);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);
extern void FDemoText_UpdateChannelVoice(unsigned char ch);

void FDemoText_UpdateChannelVoice(unsigned char ch)
{
	unsigned char *e, *e2;
	unsigned char s;
	unsigned int w;

	e = FDemoText_LookupTableEntry(ch);
	e += 5;
	s = FDemoText_CheckVoiceState(ch);
	w = ch;
	if (s != 1) {
		*e = 0;
		AddswbWr(w, 5, 0, 0x7f);
		return;
	}
	if (*e != 0) return;
	*e = 0x50;
	AddswbWr(w, 5, 0x50, 0x7f);
	e2 = e + 2;
	if (*e2 == 0) return;
	*e2 = 0;
	AddswbWr(ch, 7, 0, 0x7f);
}
