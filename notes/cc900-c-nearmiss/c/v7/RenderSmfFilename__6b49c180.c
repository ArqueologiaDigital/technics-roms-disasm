/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/smf_operations.c (2026-11-16-33-p6-r2)
   sha256 6b49c1807201fa1ffb4b3f26e90c0e7c13fb9f675965c520361955ca2bad6b37 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char CType_ClassTable[];
void RenderSmfFilename(unsigned char *name, unsigned char len)
{
	int i;

	name[len] = 0;
	for (i = 0; i < 8 && name[i] != 0; i++)
		if (!(CType_ClassTable[name[i]] & 7)) name[i] = 0x5f;
	if (i < 8) do { name[i] = 0x5f; i++; } while (i < 8);
}
