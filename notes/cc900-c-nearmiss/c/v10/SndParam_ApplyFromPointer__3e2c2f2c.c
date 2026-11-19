/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_1m280b.c (2026-11-19-15-p6-r42)
   sha256 3e2c2f2c8d752f18ee76e997facaf0b6a6d7b0698df2df202638db3eb051d305 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_90ea[];
extern unsigned char __near ram_90ee[];
extern void SndParam_ApplyProgramChange(unsigned char *);
extern void Rhythm_LookupTempoVelocity_Wrap(void);
void SndParam_ApplyFromPointer(unsigned char *r)
{
	unsigned char *t = r + 2;
	unsigned char *b;

	if (*t <= 0x1f)
		SndParam_ApplyProgramChange(r);
	else if (*t == 0x48) {
		b = ram_90ea;
		b[0] = r[0];
		b[1] = r[1];
		b[2] = *t;
		Rhythm_LookupTempoVelocity_Wrap();
		b = ram_90ee;
		r[3] = b[0];
		r[4] = b[1];
	}
}
