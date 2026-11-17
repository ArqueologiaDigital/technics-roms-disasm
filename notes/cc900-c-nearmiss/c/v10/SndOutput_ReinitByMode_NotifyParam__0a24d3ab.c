/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_5a.c (2026-11-16-45-p6-r9)
   sha256 0a24d3abb3ad01135d3ba1544257bdeae1dc14fc21da9794d409ad64bba47312 (tar-sha256); compiled at -Xr
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
