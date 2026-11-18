/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_2m265a.c (2026-11-18-28-p6-r36)
   sha256 876f0f9bb2a84213bb5f00b373293bb10ef196047a0952ba6f144e86009fc4bc (tar-sha256); compiled at -O3 -Xr */
struct fent { char name[16]; void *data; char pad[4]; };
extern struct fent ram_249d8[];
extern char *__cdecl Strcpy(char *, char *);
int FDemo_RegisterLoadedFile(char *name, void *data)
{
	struct fent *e;
	int i;

	e = ram_249d8;
	for (i = 0; i < 63; i++, e++)
		if (e->data == 0)
			break;
	if (i == 63)
		return 0;
	Strcpy(e->name, name);
	e->data = data;
	return 1;
}
