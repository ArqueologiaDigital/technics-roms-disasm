/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_14m232.c (2026-11-16-100-p6-r19)
   sha256 b5c38cb9e43a3631f9fd76c608f47f2f41b66081cae679390eebe9933612b9ff (tar-sha256); compiled at -O3 -XS -Xr */
extern void NoteEditSy_ScanAndSortEntries(void);
extern void BmDrEdit_InitCommon(void);
extern unsigned char *__cdecl Malloc(unsigned int);
typedef unsigned char *ucp;
extern unsigned char __near ram_2742;
extern ucp __near ram_1d50;
extern ucp __near ram_1d54;
extern unsigned int __near ram_278e;
extern unsigned int __near ram_2792;
extern unsigned int __near ram_2796;
extern unsigned char __near ram_2774;
extern unsigned char __near ram_27a2;
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
