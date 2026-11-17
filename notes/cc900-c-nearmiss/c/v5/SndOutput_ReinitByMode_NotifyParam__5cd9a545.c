/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/ui_mode_handlers_m275.c (2026-11-16-68-p6-r12)
   sha256 5cd9a5458a6c39f518515f77b1f773e5a1e4e576a34a6ed48d21fc96c6931288 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: SndOutput_ReinitByMode_Notify=SndOutput_ReinitByMode_NotifyParam */
extern void SoundParam_NotifyChange(long, unsigned int, unsigned int);
extern unsigned char __near ram_8c9c;
extern unsigned char __near ram_8c9a;
void SndOutput_ReinitByMode_Notify(void)
{
	unsigned char a;

	SoundParam_NotifyChange(0x300, (unsigned char)(ram_8c9c + 1), 3);
	a = ram_8c9a;
	if (a & 0x20) {
		a |= 4;
		ram_8c9a = a;
	}
	a = ram_8c9a;
	if (!(a & 8)) return;
	a |= 2;
	ram_8c9a = a;
}
