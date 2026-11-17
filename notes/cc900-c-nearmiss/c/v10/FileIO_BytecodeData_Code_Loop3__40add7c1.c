/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_18m277.c (2026-11-16-128-p6-r27)
   sha256 40add7c141b55ce6e05c86b09245a55df69b0a029f4a4b7fac3959ab22237586 (tar-sha256); compiled at -O3 -Xr */
extern void PanelEvent_Post(unsigned char *);
extern int SndParam_LookupReadOnly(long);
extern unsigned char __near ram_90f9;
extern unsigned char __near CURRENT_MODE;
void FileIO_BytecodeData_Code_Loop3(unsigned char *e)
{
	unsigned char m, v, *p;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	if (!(e[2] & e[3])) return;
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 1;
	v = SndParam_LookupReadOnly(768);
	p = e + 2;
	if (v >= 80) *p = 1;
	else *p = v + 1;
	e[3] = 127;
	PanelEvent_Post(e);
}
