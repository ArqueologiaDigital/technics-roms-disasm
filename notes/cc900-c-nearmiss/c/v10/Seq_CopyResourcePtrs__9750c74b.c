/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_1a.c (2026-11-16-31-p6-r1b)
   sha256 9750c74bf124b2aa99540b8b4b6fdaab7ef7968b5c9e4dc00f22f063b001454d (tar-sha256); compiled at -O3 -XS -Xr */
struct res12 { long a; char *p; long c; };
extern char Seq_CopyResourcePtrs_Str_Empty[];
extern char *ram_249cc, *ram_249d0, *ram_249d4;
void Seq_CopyResourcePtrs(int n)
{
	char **p, **e;
	char *s;

	p = (char **)0x24fd8; s = Seq_CopyResourcePtrs_Str_Empty; e = p + 127;
	do *p++ = s; while (p <= e);
	if (n >= 18 && n <= 18) ram_249cc = ((struct res12 *)0x880000)[n - 18].p;
	else ram_249cc = ram_249d0;
	ram_249d4 = ram_249cc;
}
