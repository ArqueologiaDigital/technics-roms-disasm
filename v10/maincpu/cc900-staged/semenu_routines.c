/* Functions of audio/semenu_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
extern unsigned char ram_20c33, ram_20c35, ram_20bf3[];
extern unsigned char __near SEQ_RTMCFG;
int SeMenu_CheckObjEnabled(unsigned char a) { int r = -1; if (ram_20c33 == a) r = 0; return r; }
int SeMenu_CheckObjValid(unsigned char a) { int r = -1; if (ram_20c35 == a) r = 0; return r; }
void SeMenu_SetEditEnable(unsigned char a) { if (a == 1) SEQ_RTMCFG |= 0x04; else SEQ_RTMCFG &= ~0x04; }
void SeMenu_SetNameBufferChar(unsigned char i, unsigned char c) { if (i > 15) return; ram_20bf3[i] = c; }

extern unsigned char __near ram_68d;
extern unsigned char __near ram_68e;
extern unsigned char __near ram_68f;

void SeLfo_GetSelectedLfo(unsigned char m, unsigned char *out)
{
	unsigned char v;

	if (m == 1) {
		if (ram_68e < 1 || ram_68e > 4) ram_68e = 1;
		v = ram_68e;
	} else if (m == 0) {
		if (ram_68d < 1 || ram_68d > 4) ram_68d = 1;
		v = ram_68d;
	} else if (m == 2) {
		if (ram_68f < 1 || ram_68f > 4) ram_68f = 1;
		v = ram_68f;
	} else {
		v = 1;
	}
	*out = v;
}
