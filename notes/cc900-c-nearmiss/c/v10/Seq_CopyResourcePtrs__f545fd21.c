/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_1b.c (2026-11-16-31-p6-r1b)
   sha256 f545fd217b726e00a01edbda07882c98420980af6c0fec92898ed4803639eb58 (tar-sha256); compiled at -O3 -XS -Xr */
struct res12 { long a; char *p; long c; };
extern char Seq_CopyResourcePtrs_Str_Empty[];
extern char *ram_249cc, *ram_249d0, *ram_249d4;
extern char *ram_24fd8[];
void Seq_CopyResourcePtrs(int n)
{
	int i;

	for (i = 0; i < 128; i++) ram_24fd8[i] = Seq_CopyResourcePtrs_Str_Empty;
	if (n < 18 || n > 18) ram_249cc = ram_249d0;
	else ram_249cc = ((struct res12 *)0x880000)[n - 18].p;
	ram_249d4 = ram_249cc;
}
