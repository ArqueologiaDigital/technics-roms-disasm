/* Functions of ui/ui_mode_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void SoundParam_NotifyChange(long, unsigned int, unsigned int);
extern unsigned char __near ram_8c9c;
extern unsigned char __near ram_8c9a;

/* cc900-name: SndOutput_ReinitByMode_Notify=SndOutput_ReinitByMode_NotifyParam (34 characters) */
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
