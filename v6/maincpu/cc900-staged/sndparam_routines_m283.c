/* Functions of audio/sndparam_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SndParam_EncodeAddress SndParam_LookupByKey SoundParam_NotifyChange */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned long SndParam_EncodeAddress(unsigned int a, unsigned int b);
extern void SoundParam_NotifyChange(long, int, int);
extern void SndParam_NotifyAndReturn(unsigned int a, unsigned int b, int c, int d);
extern int SndParam_LookupByKey(long, int, int);
extern void SndParam_WrapNotify2(unsigned int a, unsigned int b, int c, int d);

void SndParam_NotifyAndReturn(unsigned int a, unsigned int b, int c, int d)
{
	SoundParam_NotifyChange(SndParam_EncodeAddress(a, b), c, d);
}

void SndParam_WrapNotify2(unsigned int a, unsigned int b, int c, int d)
{
	SndParam_LookupByKey(SndParam_EncodeAddress(a, b), c, d);
}
