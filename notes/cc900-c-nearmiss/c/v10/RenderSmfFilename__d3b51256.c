/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_2a.c (2026-11-16-35-p6-r3)
   sha256 d3b51256cb6766ba5ee356b2f9ad6f2a91b76a80223fa8ae1385d53c17b0fdaa (tar-sha256); compiled at -Xr */
extern unsigned char CType_ClassTable[];
void RenderSmfFilename(unsigned char *name, unsigned char len)
{
	int i;
	unsigned char *q, *t;
	unsigned char c;

	name[len] = 0;
	i = 0;
	t = CType_ClassTable;
	while (i < 8 && (c = *(q = &name[i])) != 0) {
		if (!(t[c] & 7)) *q = 0x5f;
		i++;
	}
	for (; i < 8; i++) name[i] = 0x5f;
}
