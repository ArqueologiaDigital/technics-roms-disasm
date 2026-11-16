/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_2a.c (2026-11-16-35-p6-r3)
   sha256 d3b51256cb6766ba5ee356b2f9ad6f2a91b76a80223fa8ae1385d53c17b0fdaa (tar-sha256); compiled at -Xr */
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
