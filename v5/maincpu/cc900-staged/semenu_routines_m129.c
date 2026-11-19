/* Functions of audio/semenu_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeMenu_BitShiftMask SeMenu_FlushDisplayObj SeMenu_LoadMasterPtr SeMenu_LoadObjEntries SeMenu_RegisterElement_Extended SeMenu_SetObjectFlags SeMenu_SetupDisplayObject_Alt1 SeMenu_StepParamField SeMenu_StorePartParam */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int SeMenu_RegisterElement_Extended(unsigned char id, unsigned char field, unsigned char *v, unsigned int mask);
extern unsigned char SeMenu_StepParamField(unsigned char *f);
extern void SeMenu_LoadObjEntries(unsigned char *);
extern unsigned char SeMenu_BitShiftMask(int, int);
extern void SeMenu_SetupDisplayObject_Alt1(unsigned char, unsigned char, unsigned char *, unsigned int);
extern void SeMenu_StorePartParam(int, int);
extern void __cdecl SeTitle_DrawField(int, int);
extern unsigned char SeMenu_StepParamFieldAndSend(unsigned char t, unsigned char part, unsigned char id, unsigned char field, unsigned char *f);

unsigned char SeMenu_StepParamFieldAndSend(unsigned char t, unsigned char part, unsigned char id,
                                           unsigned char field, unsigned char *f)
{
	unsigned char obj;
	unsigned int m;

	if ((unsigned int)SeMenu_StepParamField(f) == 0)
		return 0;
	SeMenu_LoadObjEntries(&obj);
	m = SeMenu_BitShiftMask(f[6], f[7]);
	if (obj == 0)
		SeMenu_RegisterElement_Extended(id, field, &f[3], m);
	else
		SeMenu_SetupDisplayObject_Alt1(id, field, &f[3], m);
	SeMenu_StorePartParam(part, f[3]);
	SeTitle_DrawField(t, part);
	return 1;
}
