struct VoiceParam_CopyBitfi_s {
	unsigned char p0_7 : 1;
	unsigned char f0_6 : 1;
	unsigned char f0_5 : 1;
	unsigned char p0_4 : 1;
	unsigned char f0_0 : 4;
	unsigned char p1_7 : 5;
	unsigned char f1_0 : 3;
};
struct VoiceParam_CopyBitfi_d {
	unsigned char g0[14];
	unsigned char p14_7 : 5;
	unsigned char f14_0 : 3;
	unsigned char f15_7 : 1;
	unsigned char f15_6 : 1;
	unsigned char f15_5 : 1;
	unsigned char p15_4 : 1;
	unsigned char f15_0 : 4;
};
void VoiceParam_CopyBitfields_LargeBlock(struct VoiceParam_CopyBitfi_s *s, struct VoiceParam_CopyBitfi_d *d)
{
	d->f15_0 = s->f0_0;
	d->f15_5 = s->f0_5;
	d->f15_6 = s->f0_6;
	d->f15_7 = s->f0_6;
	d->f14_0 = s->f1_0;
}
