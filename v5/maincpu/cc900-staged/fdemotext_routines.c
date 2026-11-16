/* Functions of demo/fdemotext_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

struct fdlay { unsigned int x, y; };
extern long ram_25b40[];
extern unsigned int ram_25b3e, ram_25b60, ram_25b62[], ram_25b72;
extern struct fdlay ram_25b3a;
extern unsigned char ram_25b74[], ram_251da[][40];

void FDemoText_ResetLayoutState(void)
{
	int i, j;

	for (i = 0; i < 60; i++)
		for (j = 0; j < 40; j++) ram_251da[i][j] = 84;
	ram_25b3a.x = 0;
	ram_25b3a.y = 0;
	ram_25b3e = 0;
	ram_25b60 = 0;
	ram_25b72 = 0;
	for (i = 0; i < 8; i++) {
		ram_25b40[i] = 5;
		ram_25b62[i] = 0xff;
		ram_25b74[i] = 1;
	}
}

struct res12 { long a; char *p; long c; };
extern char Seq_CopyResourcePtrs_Str_Empty[];
extern char *ram_249cc, *ram_249d0, *ram_249d4;
extern char *ram_24fd8[];

void Seq_CopyResourcePtrs(int n)
{
	int i;

	for (i = 0; i <= 127; i++) ram_24fd8[i] = Seq_CopyResourcePtrs_Str_Empty;
	if (n >= 18 && n <= 18) ram_249cc = ((struct res12 *)0x880000)[n - 18].p;
	else ram_249cc = ram_249d0;
	ram_249d4 = ram_249cc;
}
