/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/audio_control_engine_m0.c (2026-11-19-29-p6-r46)
   sha256 7c79944a522f8289075fa63d7b698d586127d67be0f3d7bffb77b3611da613f8 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_902a[];
extern unsigned char __near ram_902e[];
extern void SndParam_ApplyProgramChange(unsigned char *);
extern void Rhythm_LookupTempoVelocity_Wrap(void);
void SndParam_ApplyFromPointer(unsigned char *r)
{
	unsigned char *t = r + 2;
	unsigned char *b;

	if (*t <= 0x1f)
		SndParam_ApplyProgramChange(r);
	else if (*t == 0x48) {
		b = ram_902a;
		b[0] = r[0];
		b[1] = r[1];
		b[2] = *t;
		Rhythm_LookupTempoVelocity_Wrap();
		b = ram_902e;
		r[3] = b[0];
		r[4] = b[1];
	}
}
