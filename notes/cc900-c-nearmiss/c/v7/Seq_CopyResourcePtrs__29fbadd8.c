/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/fdemotext_routines.c (2026-11-16-36-p6-staged-r4)
   sha256 29fbadd8b1db7883b8954db96dd0d098e925d49e98cc2f7d2d7577f50ab05e30 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
