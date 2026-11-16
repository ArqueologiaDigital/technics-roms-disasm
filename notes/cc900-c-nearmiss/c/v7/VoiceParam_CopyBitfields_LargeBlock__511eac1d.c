/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midi_dispatch_handlers_m285.c (2026-11-16-68-p6-r12)
   sha256 511eac1d867022aa1f418740d9cfcda07734e16af66f2282b24b3a5ae04de7be (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: VoiceParam_CopyBf_LargeBlock=VoiceParam_CopyBitfields_LargeBlock */
struct T5_s {
	unsigned char p0_7 : 1;
	unsigned char f0_6 : 1;
	unsigned char f0_5 : 1;
	unsigned char p0_4 : 1;
	unsigned char f0_0 : 4;
	unsigned char p1_7 : 5;
	unsigned char f1_0 : 3;
};
struct T5_d {
	unsigned char g0[14];
	unsigned char p14_7 : 5;
	unsigned char f14_0 : 3;
	unsigned char f15_7 : 1;
	unsigned char f15_6 : 1;
	unsigned char f15_5 : 1;
	unsigned char p15_4 : 1;
	unsigned char f15_0 : 4;
};
void VoiceParam_CopyBf_LargeBlock(struct T5_s *s, struct T5_d *d)
{
	d->f15_0 = s->f0_0;
	d->f15_5 = s->f0_5;
	d->f15_6 = s->f0_6;
	d->f15_7 = s->f0_6;
	d->f14_0 = s->f1_0;
}
