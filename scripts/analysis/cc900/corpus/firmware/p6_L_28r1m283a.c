/* lane_p6 helper L, round 28r1, form a: module 283 (audio/sndparam_routines.s), SndParam_NotifyAndReturn /
   SndParam_WrapNotify2 (families28_L, 2 x 20 B): encode (WA, BC) into a sound-parameter address with the built
   SndParam_EncodeAddress, then pass it with the third argument (DE, kept in IZ) and the fourth (a stack word, popped
   by `retd 2`) to SoundParam_NotifyChange / SndParam_LookupByKey.
   Form a: one call expression with the encoder call as the first argument.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SndParam_EncodeAddress SndParam_LookupByKey SoundParam_NotifyChange */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned long SndParam_EncodeAddress(unsigned int a, unsigned int b);
extern void SoundParam_NotifyChange(long, int, int);
extern int SndParam_LookupByKey(long, int, int);

void SndParam_NotifyAndReturn(unsigned int a, unsigned int b, int c, int d)
{
	SoundParam_NotifyChange(SndParam_EncodeAddress(a, b), c, d);
}

void SndParam_WrapNotify2(unsigned int a, unsigned int b, int c, int d)
{
	SndParam_LookupByKey(SndParam_EncodeAddress(a, b), c, d);
}
