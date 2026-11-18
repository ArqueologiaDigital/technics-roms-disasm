/* Phase 6, lane_p6 helper K, round 2, module 265 (demo/file_demo_proc.s, demo/fdemotext_routines.s), form a;
   the module's matched C is -O3 -Xr (cc900/fdemotext_routines_m265.c).
   The Feature Demo's loaded-file table: 24-byte records {name[16], data pointer, 4 more bytes}.
   FDemo_RegisterLoadedFile(name, data): the first of 63 records at 0x249d8 with no data gets the name (Strcpy) and
   the pointer; 1, or 0 when the table is full.
   FDemo_LinkedListSearch(name): walks the record list whose start pointer is the long at 0x880008 (table data ROM;
   spelled ram_880008 here, there is no label) until the data pointer is 0 or Strcmp matches; the record or 0.
   FDemoText_CalcTextExtent(p): scales p down and up again (FDemoText_ScaleDownCoords / _ScaleUpCoords), then
   widens by 8 for every following 'T' cell of the 40-column text grid at 0x251da (row index hoisted). */
/* cc900-module: FDemoText_ScaleDownCoords FDemoText_ScaleUpCoords */   /* scripts/analysis/cc900/module_calls.py v10 */

struct fent { char name[16]; void *data; char pad[4]; };
struct pt { int x, y; };

extern struct fent ram_249d8[];
extern struct fent *ram_880008;
extern char ram_251da[];
extern char *__cdecl Strcpy(char *, char *);
extern int __cdecl Strcmp(char *, char *);
extern void FDemoText_ScaleDownCoords(struct pt *, struct pt *);
extern void FDemoText_ScaleUpCoords(struct pt *, struct pt *);

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

int FDemoText_CalcTextExtent(struct pt *p)
{
	struct pt a;
	struct pt b;
	int i;
	int w;

	FDemoText_ScaleDownCoords(p, &a);
	FDemoText_ScaleUpCoords(&a, &b);
	i = a.x + 1;
	w = b.x + 8 - p->x;
	for (; i < 40; i++) {
		if (ram_251da[a.y * 40 + i] != 'T')
			break;
		w += 8;
	}
	return w;
}
