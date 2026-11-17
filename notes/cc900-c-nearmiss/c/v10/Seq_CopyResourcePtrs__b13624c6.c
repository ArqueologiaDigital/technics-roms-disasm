/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_2b.c (2026-11-16-35-p6-r3)
   sha256 b13624c69fcb835af433e38ef56581fa94d5aa79da286905b3f16a25d5e2a17d (tar-sha256); compiled at -Xr */
struct res12 { long a; char *p; long c; };
extern char Seq_CopyResourcePtrs_Str_Empty[];
extern char *ram_249cc, *ram_249d0, *ram_249d4;
extern char *ram_24fd8[];
void Seq_CopyResourcePtrs(int n)
{
	char **p, **e;
	char *s;

	p = ram_24fd8; s = Seq_CopyResourcePtrs_Str_Empty; e = &ram_24fd8[127];
	do *p++ = s; while (p <= e);
	if (n >= 18 && n <= 18) ram_249cc = ((struct res12 *)0x880000)[n - 18].p;
	else ram_249cc = ram_249d0;
	ram_249d4 = ram_249cc;
}
