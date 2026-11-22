/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_28r1m303a.c (2026-11-22-9-p6-r76)
   sha256 6245bf7d56895d9c7d2d24f333a4af838529bf468d01dadb58eb1a942c057cde (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern int SndParam_LookupReadOnly(long);
extern void SndParam_ApplyVoiceValue(unsigned char *);
extern void SndParam_LookupOscEnvelope(unsigned char *);
void SndParam_CheckAndApplyMode(unsigned char *r)
{
	if (SndParam_LookupReadOnly(192L) == 1)
		SndParam_ApplyVoiceValue(r);
	else
		SndParam_LookupOscEnvelope(r);
}
