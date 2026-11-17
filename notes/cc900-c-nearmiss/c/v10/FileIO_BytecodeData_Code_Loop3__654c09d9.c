/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_17m277b.c (2026-11-16-123-p6-r25)
   sha256 654c09d99a5ec49367bf46c872a3d17ae11010d8355594e8f87b5222da5852f1 (tar-sha256); compiled at -O3 -Xr */
extern void PanelEvent_Post(unsigned char *);
extern int SndParam_LookupReadOnly(long);
extern unsigned char __near ram_90f9;
extern unsigned char __near CURRENT_MODE;
void FileIO_BytecodeData_Code_Loop3(unsigned char *e)
{
	unsigned char m, v;

	m = CURRENT_MODE;
	if (m == 16 || m == 15 || m == 14 || m == 17 || m == 3 || m == 19) return;
	if (SndParam_LookupReadOnly(192) == 1) return;
	if (!(e[2] & e[3])) return;
	ram_90f9 |= 2;
	e[0] = 152;
	e[1] = 1;
	v = SndParam_LookupReadOnly(768);
	e[2] = v >= 80 ? 1 : v + 1;
	e[3] = 127;
	PanelEvent_Post(e);
}
