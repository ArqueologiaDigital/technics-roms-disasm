/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_2b.c (2026-11-16-35-p6-r3)
   sha256 b13624c69fcb835af433e38ef56581fa94d5aa79da286905b3f16a25d5e2a17d (tar-sha256); compiled at -Xr */
extern unsigned char CType_ClassTable[];
void RenderSmfFilename(unsigned char *name, unsigned char len)
{
	int i;
	unsigned char c;

	name[len] = 0;
	for (i = 0; i < 8 && (c = name[i]) != 0; i++)
		if (!(CType_ClassTable[c] & 7)) name[i] = 0x5f;
	if (i < 8) do { name[i] = 0x5f; i++; } while (i < 8);
}
