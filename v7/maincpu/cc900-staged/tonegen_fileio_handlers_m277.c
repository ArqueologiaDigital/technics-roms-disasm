/* Functions of audio/tonegen_fileio_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ToneGen_DiffScanAndUpdate */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_8dd0;
extern unsigned char __near ram_8dd2;
extern unsigned char __near ram_8dd4;
extern void SoundParam_NotifyChange(long, int, int);
extern void BitMapOut_DetectChanges(void);
extern void ToneGen_DiffScanAndUpdate(void);
extern void SoundParam_NotifyMultipleChanges(void);

void SoundParam_NotifyMultipleChanges(void)
{
	SoundParam_NotifyChange(0, ram_8dd0, 0);
	SoundParam_NotifyChange(0x102, ram_8dd2, 0);
	SoundParam_NotifyChange(0x103, ram_8dd4, 0);
	BitMapOut_DetectChanges();
	ToneGen_DiffScanAndUpdate();
}
