/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/ui_mode_handlers.c (2026-11-16-55-p6-r10)
   sha256 9b2637ba9b6fb73ef8f43c0b59bfcefa4889a093b6b6875ca235d7efdda2d1e7 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: SndOutput_ReinitByMode_Notify=SndOutput_ReinitByMode_NotifyParam */
extern unsigned char __near ram_8cb8;
extern unsigned char __near ram_8cb6;
void SndOutput_ReinitByMode_Notify(void)
{
	unsigned char a;

	SoundParam_NotifyChange(0x300, (unsigned char)(ram_8cb8 + 1), 3);
	a = ram_8cb6;
	if (a & 0x20) {
		a |= 4;
		ram_8cb6 = a;
	}
	a = ram_8cb6;
	if (!(a & 8)) return;
	a |= 2;
	ram_8cb6 = a;
}
