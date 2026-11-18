/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_2m265a.c (2026-11-18-28-p6-r36)
   sha256 876f0f9bb2a84213bb5f00b373293bb10ef196047a0952ba6f144e86009fc4bc (tar-sha256); compiled at -Xr */
struct fent { char name[16]; void *data; char pad[4]; };
extern struct fent *ram_880008;
extern int __cdecl Strcmp(char *, char *);
struct fent *FDemo_LinkedListSearch(char *name)
{
	struct fent *e;

	e = ram_880008;
	while (e->data != 0) {
		if (Strcmp(name, e->name) == 0)
			break;
		e++;
	}
	if (e->data != 0)
		return e;
	return 0;
}
