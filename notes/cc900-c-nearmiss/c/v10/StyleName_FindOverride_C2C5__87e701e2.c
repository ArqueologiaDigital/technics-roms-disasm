/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_3b.c (2026-11-16-37-p6-r5)
   sha256 87e701e28dc0ffe6e2c00b6fe7f01531d2c1c5e103ce52a0a7404b5d93a5dc63 (tar-sha256); compiled at -O3 -Xr */
struct sname { int key; char name[16]; };
extern struct sname StyleNameOverride_C2C5[], StyleNameOverride_Default[];
char *StyleName_FindOverride_C2C5(int key)
{
	unsigned int i;
	struct sname *e;

	for (i = 0; i < 22; i++) {
		e = &StyleNameOverride_C2C5[i];
		if (key == e->key) return e->name;
	}
	return (char *)-1L;
}
