/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_2m276a.c (2026-11-19-19-p6-r43)
   sha256 fca43bd802093dfcdfe570e7be9800982e4d16d94d302d970c4145f461e8fe47 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_8d6c[];
extern int PanelInput_ReadRxRecord(unsigned char *rec);
extern void EffectMode_MidiSetLEDs(unsigned char *rec);
void EffectMode_MidiParseLoop(void)
{
	unsigned char *p;

	p = ram_8d6c;
	while (PanelInput_ReadRxRecord(p) != -1)
		EffectMode_MidiSetLEDs(p);
}
