/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FDemoText_ScaleDownCoords FDemoText_ScaleUpCoords */   /* scripts/analysis/cc900/module_calls.py v10 */

struct fent { char name[16]; void *data; char pad[4]; };
extern struct fent *ram_880008;
extern int __cdecl Strcmp(char *, char *);
extern struct fent *FDemo_LinkedListSearch(char *name);

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
