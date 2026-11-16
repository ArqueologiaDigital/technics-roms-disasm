/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_3a.c (2026-11-16-37-p6-r5)
   sha256 3186bc0bbe1ff510f5c448c06940ec3afa58641942c0c826f244eafcbc9d2b38 (tar-sha256); compiled at -O3 -Xr */
struct sname { int key; char name[16]; };
extern struct sname StyleNameOverride_C2C5[], StyleNameOverride_Default[];
char *StyleName_FindOverride_C2C5(int key)
{
	unsigned int i;
	struct sname *t, *e;

	t = StyleNameOverride_C2C5;
	for (i = 0; i < 22; i++) {
		e = &t[i];
		if (key == e->key) return e->name;
	}
	return (char *)-1L;
}
