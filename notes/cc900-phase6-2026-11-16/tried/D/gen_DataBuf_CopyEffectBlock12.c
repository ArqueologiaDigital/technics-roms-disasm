struct DataBuf_CopyEffectBl_s {
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
struct DataBuf_CopyEffectBl_d {
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
void DataBuf_CopyEffectBlock12(struct DataBuf_CopyEffectBl_s *s, struct DataBuf_CopyEffectBl_d *d)
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
