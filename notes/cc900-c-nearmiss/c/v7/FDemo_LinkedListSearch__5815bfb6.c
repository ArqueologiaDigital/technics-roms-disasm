/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/file_demo_proc_m265.c (2026-11-18-33-p6-r37)
   sha256 5815bfb6487a8a62b9af623d35f1b05fc495e729b4332f30b084673403e7e213 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
