/* Functions of audio/sndparam_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

struct heap { unsigned int count; unsigned char data[16384]; };
extern long __near ram_973c[];
extern struct heap ram_380f8;

void SndParam_ClearHashTable(void)
{
	int i;

	for (i = 0; i < 2047; i++) ram_973c[i] = 0;
	for (i = 0; i < 16384; i++) ram_380f8.data[i] = 0;
	ram_380f8.count = 0;
}

unsigned long SndParam_EncodeAddress(unsigned int a, unsigned int b)
{
	unsigned long r;

	r = 0x8000;
	r += (unsigned int)((a & 0x3f) << 10);
	r |= b & 0x3ff;
	if (b < 0x400) return r;
	return r + 0x10000;
}
