/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_1m280b.c (2026-11-19-15-p6-r42)
   sha256 3e2c2f2c8d752f18ee76e997facaf0b6a6d7b0698df2df202638db3eb051d305 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_90ea[];
extern unsigned char __near ram_90ee[];
extern void SndParam_ApplyProgramChange(unsigned char *);
extern void Rhythm_LookupTempoVelocity_Wrap(void);
void SndParam_ApplyAndFetch(void)
{
	unsigned char b[6];
	unsigned char *s;
	unsigned char *d;
	unsigned char c;

	d = b;
	s = ram_90ea;
	d[0] = s[0];
	d[1] = s[1];
	d[2] = c = s[2];
	if (c <= 0x1f) {
		SndParam_ApplyProgramChange(d);
		s = ram_90ee;
		d = b;
		s[0] = d[3];
		s[1] = d[4];
	} else if (c == 0x48)
		Rhythm_LookupTempoVelocity_Wrap();
}
