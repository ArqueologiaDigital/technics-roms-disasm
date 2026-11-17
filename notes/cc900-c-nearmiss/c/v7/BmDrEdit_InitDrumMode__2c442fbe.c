/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/bmdredit_routines_m232.c (2026-11-16-111-p6-r22-staged)
   sha256 2c442fbe559902db6d1bb616a5f0a05ab1d09ee762bbda8ebc02d696d6663aa6 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_2742;
extern void BmDrEdit_InitCommon(void);
extern unsigned int __near ram_2792;
extern unsigned int __near ram_278e;
extern unsigned char __near ram_2774;
extern unsigned char __near ram_27a2;
extern void NoteEditSy_ScanAndSortEntries(void);
extern unsigned char *__cdecl Malloc(unsigned int);
typedef unsigned char *ucp;
extern ucp __near ram_1d50;
extern ucp __near ram_1d54;
extern unsigned int __near ram_2796;
void BmDrEdit_InitDrumMode(void)
{
	ram_1d54 = ram_1d50 = Malloc(0x6a4);
	NoteEditSy_ScanAndSortEntries();
	ram_278e = 10;
	ram_2792 = ram_2796;
	ram_2742 |= 1;
	ram_2774 = 7;
	ram_27a2 = 8;
	BmDrEdit_InitCommon();
}
