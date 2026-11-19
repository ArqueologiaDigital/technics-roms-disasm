/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/audio_control_engine_m0.c (2026-11-19-29-p6-r46)
   sha256 85229af2d6ca00506d1cbaaf0841dfe672f0d7e11f5cf0271e44128521e8bdd8 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_904e[];
extern unsigned char __near ram_9052[];
extern void SndParam_ApplyProgramChange(unsigned char *);
extern void Rhythm_LookupTempoVelocity_Wrap(void);
void SndParam_ApplyFromPointer(unsigned char *r)
{
	unsigned char *t = r + 2;
	unsigned char *b;

	if (*t <= 0x1f)
		SndParam_ApplyProgramChange(r);
	else if (*t == 0x48) {
		b = ram_904e;
		b[0] = r[0];
		b[1] = r[1];
		b[2] = *t;
		Rhythm_LookupTempoVelocity_Wrap();
		b = ram_9052;
		r[3] = b[0];
		r[4] = b[1];
	}
}
