/* Phase 6, lane_p6 helper L, round 3, form a: module 129 (semenu_routines.s), retries at O3Xr.
   - SeMenu_SetFilterType (+39): Alt1's second parameter plain `char` (the ROM passes it in C with no extz), and the
     byte offset as pointer arithmetic: row i decays to char *, then + 15 (the ROM adds 16 and 15 as two 32-bit
     lda's after the extz, where round 1 folded the 15 into the 16-bit index).
   - SeMenu_ClampAndScaleEnvLevel (+44): the negated factor used straight from the assignment (the ROM does not
     reload it after the store), and the product negated in place (`v *= ...; v = -v;`). */
/* cc900-module: SeMenu_LoadObjEntries SeMenu_LoadPartParam SeMenu_LoadRawAddr SeMenu_RegisterElement_Extended SeMenu_SetupDisplayObject_Alt1 SeMenu_ValidatePartNumber */   /* scripts/analysis/cc900/module_calls.py v10 */

struct semrows { char pad[16]; char row[8][21]; };
extern unsigned char __near ram_68c;
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *obj);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void SeMenu_SetupDisplayObject_Alt1(int, char, unsigned char *, unsigned int);
extern int SeMenu_SetFilterType(unsigned char type);

int SeMenu_SetFilterType(unsigned char type)
{
	unsigned char part;
	unsigned char obj;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadObjEntries(&obj);
	if (obj == 0)
		SeMenu_RegisterElement_Extended(part, 54, &type, 7);
	else
		SeMenu_SetupDisplayObject_Alt1(0,
			(char)(long)(((struct semrows *)0)->row[(unsigned char)(part - 1)] + 15), &type, 7);
	ram_68c = type;
	return 0;
}

extern void SeMenu_LoadRawAddr(unsigned char *k);
extern void SeMenu_LoadPartParam(int, char *);
extern void SeMenu_ClampAndScaleEnvLevel(char *p);

void SeMenu_ClampAndScaleEnvLevel(char *p)
{
	char s;
	unsigned char k;
	int v;

	SeMenu_LoadRawAddr(&k);
	if (*p > 50)
		*p = 50;
	if (*p < -50)
		*p = -50;
	SeMenu_LoadPartParam(1, &s);
	v = *p;
	if (k == 55)
		return;
	if (s >= 0)
		v *= s;
	else {
		v *= (s = -s);
		v = -v;
	}
	*p = v / 50;
}
