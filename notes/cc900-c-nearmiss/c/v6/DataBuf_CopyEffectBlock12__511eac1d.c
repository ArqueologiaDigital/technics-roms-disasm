/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/midi_dispatch_handlers_m285.c (2026-11-16-68-p6-r12)
   sha256 511eac1d867022aa1f418740d9cfcda07734e16af66f2282b24b3a5ae04de7be (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct T1_s {
	unsigned char g0[2];
	unsigned char b2;
	unsigned char f3_4 : 4;
	unsigned char f3_0 : 4;
	unsigned char f4_4 : 4;
	unsigned char f4_0 : 4;
	unsigned char f5_4 : 4;
	unsigned char f5_0 : 4;
	unsigned char f6_4 : 4;
	unsigned char f6_0 : 4;
	unsigned char f7_4 : 4;
	unsigned char f7_0 : 4;
	unsigned char f8_4 : 4;
	unsigned char f8_0 : 4;
	unsigned char p9_7 : 2;
	unsigned char f9_5 : 1;
	unsigned char f9_4 : 1;
	unsigned char f9_0 : 4;
};
struct T1_d {
	unsigned char g0[2];
	unsigned char b2;
	unsigned char f3_4 : 4;
	unsigned char f3_0 : 4;
	unsigned char f4_4 : 4;
	unsigned char f4_0 : 4;
	unsigned char f5_4 : 4;
	unsigned char f5_0 : 4;
	unsigned char f6_4 : 4;
	unsigned char f6_0 : 4;
	unsigned char f7_4 : 4;
	unsigned char f7_0 : 4;
	unsigned char f8_4 : 4;
	unsigned char f8_0 : 4;
	unsigned char p9_7 : 2;
	unsigned char f9_5 : 1;
	unsigned char f9_4 : 1;
	unsigned char f9_0 : 4;
};
void DataBuf_CopyEffectBlock12(struct T1_s *s, struct T1_d *d)
{
	d->b2 = s->b2;
	d->f3_4 = s->f3_4;
	d->f3_0 = s->f3_0;
	d->f4_4 = s->f4_4;
	d->f4_0 = s->f4_0;
	d->f5_4 = s->f5_4;
	d->f5_0 = s->f5_0;
	d->f6_4 = s->f6_4;
	d->f6_0 = s->f6_0;
	d->f7_4 = s->f7_4;
	d->f7_0 = s->f7_0;
	d->f8_4 = s->f8_4;
	d->f8_0 = s->f8_0;
	d->f9_5 = s->f9_5;
	d->f9_4 = s->f9_4;
	d->f9_0 = s->f9_0;
}
