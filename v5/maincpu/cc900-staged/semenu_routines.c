/* Functions of audio/semenu_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char GUI_DisplayStructData_0x1129[];
extern unsigned char ram_20c39[], ram_20bf3[];
extern unsigned char __near ram_6ba[];

unsigned char SeMenu_BitShiftMask_End(unsigned char a, unsigned char n)
{
	unsigned char r = a;
	unsigned int i;

	for (i = 0; i < n; i++) r >>= 1;
	return r;
}

void SeMenu_CopyNameChars(unsigned char *d, unsigned char *s, unsigned char n)
{
	unsigned char i;

	for (i = 0; i < n; i++) *d++ = *s++;
}

void SeMenu_GetNameBufferChar(unsigned char i, unsigned char *out)
{
	if (i > 15) return;
	*out = ram_20bf3[i];
}

void SeMenu_LoadParamByte(unsigned char n, unsigned char *out)
{
	*out = ram_6ba[(unsigned char)(n - 1)];
}

void SeMenu_NameCharIndexToChar(unsigned char c, unsigned char *out)
{
	if (c >= 97) {
		*out = 32;
		return;
	}
	*out = GUI_DisplayStructData_0x1129[c];
}
