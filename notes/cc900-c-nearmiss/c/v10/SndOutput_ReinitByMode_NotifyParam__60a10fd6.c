/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/ui_mode_handlers.c (2026-11-16-55-p6-r10)
   sha256 60a10fd657f38e3147b987886ac918ce0139df81b88a61ee998701ccab02e7f8 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: SndOutput_ReinitByMode_Notify=SndOutput_ReinitByMode_NotifyParam */
extern unsigned char __near ram_8d54;
extern unsigned char __near ram_8d52;
void SndOutput_ReinitByMode_Notify(void)
{
	unsigned char a;

	SoundParam_NotifyChange(0x300, (unsigned char)(ram_8d54 + 1), 3);
	a = ram_8d52;
	if (a & 0x20) {
		a |= 4;
		ram_8d52 = a;
	}
	a = ram_8d52;
	if (!(a & 8)) return;
	a |= 2;
	ram_8d52 = a;
}
