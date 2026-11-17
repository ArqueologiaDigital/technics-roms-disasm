/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_17m277.c (2026-11-16-123-p6-r25)
   sha256 7751f93ec9223016fc23b4a3fbc34d5540843fec89c86b3623e5f7b4557e38fa (tar-sha256); compiled at -Xr */
extern void PanelEvent_Post(unsigned char *);
extern int SndParam_LookupViaEncode(unsigned int, unsigned int);
extern unsigned char __near ram_90f9;
extern unsigned char __near ram_918d[];
extern unsigned char __near PART_SELECT;
void ExtDev_SndParam_ConfigAndWrite(unsigned char *e)
{
	if (!(e[2] & e[3])) return;
	ram_90f9 |= 2;
	e[0] = PART_SELECT;
	e[1] = 5;
	if (SndParam_LookupViaEncode(PART_SELECT, 93) == 0) e[2] = ram_918d[PART_SELECT];
	else e[2] = 0;
	e[3] = 127;
	PanelEvent_Post(e);
}
