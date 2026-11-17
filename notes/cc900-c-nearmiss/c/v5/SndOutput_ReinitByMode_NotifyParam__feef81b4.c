/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/ui_mode_handlers.c (2026-11-16-55-p6-r10)
   sha256 feef81b489138637ae2edb729d68bee7cfa563f22f5f1d9df96c1a210ad48d73 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: SndOutput_ReinitByMode_Notify=SndOutput_ReinitByMode_NotifyParam */
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
