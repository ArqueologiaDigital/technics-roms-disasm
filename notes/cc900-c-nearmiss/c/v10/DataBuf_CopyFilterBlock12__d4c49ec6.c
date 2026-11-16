/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_7b.c (2026-11-16-53-p6-r11)
   sha256 d4c49ec65e6ff5d5b6a2efc1a98b5264aa3928746b202b91d3f49fc32a8ab63b (tar-sha256); compiled at -O3 -Xr */
struct U1_s {
	unsigned char g0[2];
	unsigned char b2;
	unsigned char p3_7 : 1;
	unsigned char f3_0 : 7;
	unsigned char p4_7 : 1;
	unsigned char f4_0 : 7;
	unsigned char p5_7 : 4;
	unsigned char f5_3 : 1;
	unsigned char f5_0 : 3;
	unsigned char f6_7 : 1;
	unsigned char f6_6 : 1;
	unsigned char f6_5 : 1;
	unsigned char f6_4 : 1;
	unsigned char p6_3 : 1;
	unsigned char f6_0 : 3;
	unsigned char f7_7 : 1;
	unsigned char f7_6 : 1;
	unsigned char f7_5 : 1;
	unsigned char f7_4 : 1;
	unsigned char f7_3 : 1;
	unsigned char f7_2 : 1;
	unsigned char f7_1 : 1;
	unsigned char f7_0 : 1;
	unsigned char f8_7 : 1;
	unsigned char f8_6 : 1;
	unsigned char f8_5 : 1;
	unsigned char f8_4 : 1;
	unsigned char f8_3 : 1;
	unsigned char f8_2 : 1;
	unsigned char p8_1 : 2;
	unsigned char g9;
	unsigned char b10;
	unsigned char p11_7 : 7;
	unsigned char f11_0 : 1;
};
struct U1_d {
	unsigned char g0[2];
	unsigned char b2;
	unsigned char p3_7 : 1;
	unsigned char f3_0 : 7;
	unsigned char b4;
	unsigned char p5_7 : 4;
	unsigned char f5_3 : 1;
	unsigned char f5_0 : 3;
	unsigned char f6_7 : 1;
	unsigned char f6_6 : 1;
	unsigned char f6_5 : 1;
	unsigned char f6_4 : 1;
	unsigned char p6_3 : 1;
	unsigned char f6_0 : 3;
	unsigned char f7_7 : 1;
	unsigned char f7_6 : 1;
	unsigned char f7_5 : 1;
	unsigned char f7_4 : 1;
	unsigned char f7_3 : 1;
	unsigned char f7_2 : 1;
	unsigned char f7_1 : 1;
	unsigned char f7_0 : 1;
	unsigned char f8_7 : 1;
	unsigned char f8_6 : 1;
	unsigned char f8_5 : 1;
	unsigned char f8_4 : 1;
	unsigned char f8_3 : 1;
	unsigned char f8_2 : 1;
	unsigned char p8_1 : 2;
	unsigned char g9;
	unsigned char b10;
	unsigned char p11_7 : 7;
	unsigned char f11_0 : 1;
};
void DataBuf_CopyFilterBlock12(struct U1_s *s, struct U1_d *d)
{
	d->b2 = s->b2;
	d->f3_0 = s->f3_0;
	d->b4 = s->f4_0;
	d->f5_3 = s->f5_3;
	d->f5_0 = s->f5_0;
	d->f6_7 = s->f6_7;
	d->f6_6 = s->f6_6;
	d->f6_5 = s->f6_5;
	d->f6_4 = s->f6_4;
	d->f6_0 = s->f6_0;
	d->f7_7 = s->f7_7;
	d->f7_6 = s->f7_6;
	d->f7_5 = s->f7_5;
	d->f7_4 = s->f7_4;
	d->f7_3 = s->f7_3;
	d->f7_2 = s->f7_2;
	d->f7_1 = s->f7_1;
	d->f7_0 = s->f7_0;
	d->f8_7 = s->f8_7;
	d->f8_6 = s->f8_6;
	d->f8_5 = s->f8_5;
	d->f8_4 = s->f8_4;
	d->f8_3 = s->f8_3;
	d->f8_2 = s->f8_2;
	{
		unsigned char t = ((unsigned char *)s)[9] & 0x30;

		((unsigned char *)d)[9] &= 0xcf;
		((unsigned char *)d)[9] |= t;
	}
	d->b10 = s->b10;
	d->f11_0 = s->f11_0;
}
