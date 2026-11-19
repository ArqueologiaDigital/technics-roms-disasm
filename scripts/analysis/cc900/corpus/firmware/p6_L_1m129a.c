/* Phase 6, lane_p6 helper L, round 1, form a: module 129 (audio/semenu_routines.s).
   The ROM's callers pass this module's char parameters as full ints (ld wa / ld bc / ldw de / pushw), so the
   callees are declared here with int parameters (their definitions were probably K&R).
   - SeMenu_HandleMenuChange: locals declared highest slot first (all address-taken).
   - SeMenu_SetFilterType: the second Alt1 argument is the low byte of an address-like expression
     (unsigned char)(part - 1) * 21 + 16 + 15 that the ROM adds with two lda's (a 0-based record table, 21-byte
     rows at +16, byte 15); ram_68c gets the type by a memory-to-memory move (__near, an -Xr routine).
   - SeMenu_ClampAndScaleEnvLevel: clamp to -50..50, scale by the signed part parameter, divide by 50. */
/* cc900-module: SeMenu_AdvanceSubIndex SeMenu_ComputeParamTableAddr SeMenu_FillEntryTable SeMenu_LoadObjEntries SeMenu_LoadPartParam SeMenu_LoadRawAddr SeMenu_ReadObjData SeMenu_ReadObjParam SeMenu_RegisterElement_Extended SeMenu_RegisterElement_Type2 SeMenu_ResetSubIndex SeMenu_SendEvent SeMenu_SetCurrentStep SeMenu_SetupDisplayObject SeMenu_SetupDisplayObject_Alt1 SeMenu_ValidatePartNumber */   /* scripts/analysis/cc900/module_calls.py v10 */

#define TT_SQDRMEDT 0x98
extern void SeMenu_ReadObjData(unsigned char *d);
extern void SeMenu_ResetSubIndex(void);
extern unsigned char SeMenu_AdvanceSubIndex(void);
extern void SeMenu_ReadObjParam(unsigned char *p);
extern void SeMenu_SetupDisplayObject(unsigned char *p);
extern int SeMenu_RegisterElement_Type2(int a, int c, int e, int s);
extern void SeMenu_SetCurrentStep(int v);
extern void SeMenu_FillEntryTable(unsigned char *t);
extern void SeMenu_ComputeParamTableAddr(int n, unsigned char *t);
extern void SeMenu_SendEvent(int title, int refresh);
extern void SeMenu_HandleMenuChange(void);

void SeMenu_HandleMenuChange(void)
{
	unsigned char d;
	unsigned char tab[16];
	unsigned char prm;

	SeMenu_ReadObjData(&d);
	if (d == 0) {
		SeMenu_ResetSubIndex();
		SeMenu_AdvanceSubIndex();
		SeMenu_ReadObjParam(&prm);
		SeMenu_SetupDisplayObject(&prm);
		SeMenu_RegisterElement_Type2(0, 0, 10, 16);
		SeMenu_SetCurrentStep(1);
		return;
	}
	SeMenu_ReadObjParam(&prm);
	SeMenu_FillEntryTable(tab);
	SeMenu_ComputeParamTableAddr(prm, tab);
	if (SeMenu_AdvanceSubIndex() <= 0x7f) {
		SeMenu_ReadObjParam(&prm);
		SeMenu_SetupDisplayObject(&prm);
		SeMenu_RegisterElement_Type2(0, 0, 10, 16);
	} else {
		SeMenu_SetCurrentStep(0);
		SeMenu_ResetSubIndex();
		SeMenu_SendEvent(TT_SQDRMEDT, 0);
	}
}

struct semrows { char pad[16]; char row[8][21]; };
extern unsigned char __near ram_68c;
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadObjEntries(unsigned char *obj);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void SeMenu_SetupDisplayObject_Alt1(int, unsigned char, unsigned char *, unsigned int);
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
			(unsigned char)(long)&((struct semrows *)0)->row[(unsigned char)(part - 1)][15], &type, 7);
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
		v = v * s;
	else {
		s = -s;
		v = -(v * s);
	}
	*p = v / 50;
}
