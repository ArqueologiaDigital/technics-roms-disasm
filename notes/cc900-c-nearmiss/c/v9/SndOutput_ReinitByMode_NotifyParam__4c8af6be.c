/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_mode_handlers_m275.c (2026-11-16-68-p6-r12)
   sha256 4c8af6be34ab43aa021b91b0984319e46772cd3421518304ad55c2a1ef5a6c5b (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: SndOutput_ReinitByMode_Notify=SndOutput_ReinitByMode_NotifyParam */
extern void SoundParam_NotifyChange(long, unsigned int, unsigned int);
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
