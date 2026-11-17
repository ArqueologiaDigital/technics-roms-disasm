/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_17m277.c (2026-11-16-123-p6-r25)
   sha256 7751f93ec9223016fc23b4a3fbc34d5540843fec89c86b3623e5f7b4557e38fa (tar-sha256); compiled at -O3 -XS -Xr */
extern void PanelEvent_Post(unsigned char *);
extern int SndParam_LookupReadOnly(long);
extern unsigned char __near ram_90f9;
void ExtDev_SndParam_Write48_Block(unsigned char *e)
{
	if (SndParam_LookupReadOnly(192) != 0) return;
	ram_90f9 |= 2;
	e[0] = 72;
	e[1] = 4;
	if (e[2] & e[3]) e[2] = 64;
	else e[2] = 0;
	e[3] = 64;
	PanelEvent_Post(e);
}
