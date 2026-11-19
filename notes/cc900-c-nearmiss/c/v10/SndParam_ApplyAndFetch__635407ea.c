/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_1m280a.c (2026-11-19-15-p6-r42)
   sha256 635407ead8b8ba7a365357d98f261256b77975d3602a7bb0c4d164c442e285a7 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_90ea[];
extern unsigned char __near ram_90ee[];
extern void SndParam_ApplyProgramChange(unsigned char *);
extern void Rhythm_LookupTempoVelocity_Wrap(void);
void SndParam_ApplyAndFetch(void)
{
	unsigned char b[6];
	unsigned char *s;

	s = ram_90ea;
	b[0] = s[0];
	b[1] = s[1];
	b[2] = s[2];
	if (b[2] <= 0x1f) {
		SndParam_ApplyProgramChange(b);
		s = ram_90ee;
		s[0] = b[3];
		s[1] = b[4];
	} else if (b[2] == 0x48)
		Rhythm_LookupTempoVelocity_Wrap();
}
