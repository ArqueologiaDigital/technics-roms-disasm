/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/ui_mode_handlers_m275.c (2026-11-16-68-p6-r12)
   sha256 8ebddfbd1e9e5d426e99f9c6b645d85fd6c73baf767b0eaa605104b62cf85d94 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: SndOutput_ReinitByMode_Notify=SndOutput_ReinitByMode_NotifyParam */
extern void SoundParam_NotifyChange(long, unsigned int, unsigned int);
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
