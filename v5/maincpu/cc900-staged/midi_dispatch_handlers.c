/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

void SeqBuf_WaitForEmpty(void)
{
    unsigned int n = 0xfffe;
    do {
        if (SeqBuf_MidiOut_CheckEmpty() == 0) return;
    } while (n--);
}

void TGReg_WriteCC12_Assign(void)
{
    unsigned char d[4];
    for (d[0] = 0; d[0] <= 15; d[0]++) {
        d[1] = 0xc;
        d[2] = 0;
        d[3] = 0x10;
        MidiTG_WriteRegByDescriptor(d);
    }
}

void TGReg_WriteCC3_Expression(void)
{
    unsigned char d[4];
    d[1] = 3;
    d[2] = 0x64;
    d[3] = 0x7f;
    for (d[0] = 0; d[0] <= 15; d[0]++) MidiTG_WriteRegByDescriptor(d);
}

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
struct T3_s {
	unsigned char g0[2];
	unsigned char p2_7 : 1;
	unsigned char f2_6 : 1;
	unsigned char f2_5 : 1;
	unsigned char f2_4 : 1;
	unsigned char f2_3 : 1;
	unsigned char f2_2 : 1;
	unsigned char f2_0 : 2;
	unsigned char p3_7 : 4;
	unsigned char f3_3 : 1;
	unsigned char p3_2 : 3;
	unsigned char p4_7 : 3;
	unsigned char f4_3 : 2;
	unsigned char f4_2 : 1;
	unsigned char p4_1 : 2;
	unsigned char f5_7 : 1;
	unsigned char f5_6 : 1;
	unsigned char p5_5 : 3;
	unsigned char f5_2 : 1;
	unsigned char p5_1 : 1;
	unsigned char f5_0 : 1;
	unsigned char p6_7 : 2;
	unsigned char f6_5 : 1;
	unsigned char f6_0 : 5;
	unsigned char p7_7 : 2;
	unsigned char f7_5 : 1;
	unsigned char f7_4 : 1;
	unsigned char f7_0 : 4;
	unsigned char f8_7 : 1;
	unsigned char f8_6 : 1;
	unsigned char f8_5 : 1;
	unsigned char f8_4 : 1;
	unsigned char f8_3 : 1;
	unsigned char f8_2 : 1;
	unsigned char f8_1 : 1;
	unsigned char f8_0 : 1;
	unsigned char f9_7 : 1;
	unsigned char f9_6 : 1;
	unsigned char f9_5 : 1;
	unsigned char f9_4 : 1;
	unsigned char f9_3 : 1;
	unsigned char f9_2 : 1;
	unsigned char f9_1 : 1;
	unsigned char f9_0 : 1;
	unsigned char f10_7 : 1;
	unsigned char f10_6 : 1;
	unsigned char f10_5 : 1;
	unsigned char f10_4 : 1;
	unsigned char f10_3 : 1;
	unsigned char f10_2 : 1;
	unsigned char f10_1 : 1;
	unsigned char f10_0 : 1;
	unsigned char f11_7 : 1;
	unsigned char f11_6 : 1;
	unsigned char f11_5 : 1;
	unsigned char f11_4 : 1;
	unsigned char f11_3 : 1;
	unsigned char f11_2 : 1;
	unsigned char f11_1 : 1;
	unsigned char f11_0 : 1;
};
struct T3_d {
	unsigned char g0[2];
	unsigned char p2_7 : 1;
	unsigned char f2_6 : 1;
	unsigned char f2_5 : 1;
	unsigned char f2_4 : 1;
	unsigned char f2_3 : 1;
	unsigned char f2_2 : 1;
	unsigned char f2_0 : 2;
	unsigned char p3_7 : 4;
	unsigned char f3_3 : 1;
	unsigned char p3_2 : 3;
	unsigned char p4_7 : 3;
	unsigned char f4_3 : 2;
	unsigned char f4_2 : 1;
	unsigned char p4_1 : 2;
	unsigned char f5_7 : 1;
	unsigned char f5_6 : 1;
	unsigned char p5_5 : 3;
	unsigned char f5_2 : 1;
	unsigned char p5_1 : 1;
	unsigned char f5_0 : 1;
	unsigned char p6_7 : 2;
	unsigned char f6_5 : 1;
	unsigned char f6_0 : 5;
	unsigned char p7_7 : 2;
	unsigned char f7_5 : 1;
	unsigned char f7_4 : 1;
	unsigned char f7_0 : 4;
	unsigned char f8_7 : 1;
	unsigned char f8_6 : 1;
	unsigned char f8_5 : 1;
	unsigned char f8_4 : 1;
	unsigned char f8_3 : 1;
	unsigned char f8_2 : 1;
	unsigned char f8_1 : 1;
	unsigned char f8_0 : 1;
	unsigned char f9_7 : 1;
	unsigned char f9_6 : 1;
	unsigned char f9_5 : 1;
	unsigned char f9_4 : 1;
	unsigned char f9_3 : 1;
	unsigned char f9_2 : 1;
	unsigned char f9_1 : 1;
	unsigned char f9_0 : 1;
	unsigned char f10_7 : 1;
	unsigned char f10_6 : 1;
	unsigned char f10_5 : 1;
	unsigned char f10_4 : 1;
	unsigned char f10_3 : 1;
	unsigned char f10_2 : 1;
	unsigned char f10_1 : 1;
	unsigned char f10_0 : 1;
	unsigned char f11_7 : 1;
	unsigned char f11_6 : 1;
	unsigned char f11_5 : 1;
	unsigned char f11_4 : 1;
	unsigned char f11_3 : 1;
	unsigned char f11_2 : 1;
	unsigned char f11_1 : 1;
	unsigned char f11_0 : 1;
};
struct T4_s {
	unsigned char g0[2];
	unsigned char b2;
	unsigned char p3_7 : 1;
	unsigned char f3_0 : 7;
	unsigned char p4_7 : 1;
	unsigned char f4_0 : 7;
	unsigned char f5_7 : 1;
	unsigned char f5_0 : 7;
	unsigned char f6_7 : 1;
	unsigned char f6_6 : 1;
	unsigned char p6_5 : 1;
	unsigned char f6_4 : 1;
	unsigned char f6_3 : 1;
	unsigned char f6_0 : 3;
	unsigned char p7_7 : 1;
	unsigned char f7_0 : 7;
	unsigned char f8_7 : 1;
	unsigned char f8_0 : 7;
	unsigned char p9_7 : 1;
	unsigned char f9_0 : 7;
	unsigned char p10_7 : 1;
	unsigned char f10_0 : 7;
	unsigned char p11_7 : 1;
	unsigned char f11_0 : 7;
	unsigned char b12;
	unsigned char p13_7 : 1;
	unsigned char f13_0 : 7;
	unsigned char f14_6 : 2;
	unsigned char f14_5 : 1;
	unsigned char f14_4 : 1;
	unsigned char f14_3 : 1;
	unsigned char f14_0 : 3;
	unsigned char f15_7 : 1;
	unsigned char f15_6 : 1;
	unsigned char f15_5 : 1;
	unsigned char f15_4 : 1;
	unsigned char f15_0 : 4;
	unsigned char f16_7 : 1;
	unsigned char f16_0 : 7;
	unsigned char b17;
	unsigned char b18;
	unsigned char f19_7 : 1;
	unsigned char f19_0 : 7;
	unsigned char f20_7 : 1;
	unsigned char f20_0 : 7;
	unsigned char f21_7 : 1;
	unsigned char f21_0 : 7;
	unsigned char f22_7 : 1;
	unsigned char f22_0 : 7;
	unsigned char b23;
};
struct T4_d {
	unsigned char g0[2];
	unsigned char b2;
	unsigned char p3_7 : 1;
	unsigned char f3_0 : 7;
	unsigned char p4_7 : 1;
	unsigned char f4_0 : 7;
	unsigned char f5_7 : 1;
	unsigned char f5_0 : 7;
	unsigned char f6_7 : 1;
	unsigned char f6_6 : 1;
	unsigned char p6_5 : 1;
	unsigned char f6_4 : 1;
	unsigned char f6_3 : 1;
	unsigned char f6_0 : 3;
	unsigned char p7_7 : 1;
	unsigned char f7_0 : 7;
	unsigned char f8_7 : 1;
	unsigned char f8_0 : 7;
	unsigned char p9_7 : 1;
	unsigned char f9_0 : 7;
	unsigned char p10_7 : 1;
	unsigned char f10_0 : 7;
	unsigned char p11_7 : 1;
	unsigned char f11_0 : 7;
	unsigned char b12;
	unsigned char p13_7 : 1;
	unsigned char f13_0 : 7;
	unsigned char f14_6 : 2;
	unsigned char f14_5 : 1;
	unsigned char f14_4 : 1;
	unsigned char f14_3 : 1;
	unsigned char f14_0 : 3;
	unsigned char f15_7 : 1;
	unsigned char f15_6 : 1;
	unsigned char f15_5 : 1;
	unsigned char f15_4 : 1;
	unsigned char f15_0 : 4;
	unsigned char f16_7 : 1;
	unsigned char f16_0 : 7;
	unsigned char b17;
	unsigned char b18;
	unsigned char f19_7 : 1;
	unsigned char f19_0 : 7;
	unsigned char f20_7 : 1;
	unsigned char f20_0 : 7;
	unsigned char f21_7 : 1;
	unsigned char f21_0 : 7;
	unsigned char f22_7 : 1;
	unsigned char f22_0 : 7;
	unsigned char b23;
};
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

/* cc900-name: VoiceParam_CopyBf_LargeBlock=VoiceParam_CopyBitfields_LargeBlock (35 characters) */
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

void DataBuf_CopyMixerBlock12(struct T3_s *s, struct T3_d *d)
{
	d->f2_6 = s->f2_6;
	d->f2_5 = s->f2_5;
	d->f2_4 = s->f2_4;
	d->f2_3 = s->f2_3;
	d->f2_2 = s->f2_2;
	d->f2_0 = s->f2_0;
	d->f3_3 = s->f3_3;
	d->f4_3 = s->f4_3;
	d->f4_2 = s->f4_2;
	d->f5_7 = s->f5_7;
	d->f5_6 = s->f5_6;
	d->f5_2 = s->f5_2;
	d->f5_0 = s->f5_0;
	d->f6_5 = s->f6_5;
	d->f6_0 = s->f6_0;
	d->f7_5 = s->f7_5;
	d->f7_4 = s->f7_4;
	d->f7_0 = s->f7_0;
	d->f8_7 = s->f8_7;
	d->f8_6 = s->f8_6;
	d->f8_5 = s->f8_5;
	d->f8_4 = s->f8_4;
	d->f8_3 = s->f8_3;
	d->f8_2 = s->f8_2;
	d->f8_1 = s->f8_1;
	d->f8_0 = s->f8_0;
	d->f9_7 = s->f9_7;
	d->f9_6 = s->f9_6;
	d->f9_5 = s->f9_5;
	d->f9_4 = s->f9_4;
	d->f9_3 = s->f9_3;
	d->f9_2 = s->f9_2;
	d->f9_1 = s->f9_1;
	d->f9_0 = s->f9_0;
	d->f10_7 = s->f10_7;
	d->f10_6 = s->f10_6;
	d->f10_5 = s->f10_5;
	d->f10_4 = s->f10_4;
	d->f10_3 = s->f10_3;
	d->f10_2 = s->f10_2;
	d->f10_1 = s->f10_1;
	d->f10_0 = s->f10_0;
	d->f11_7 = s->f11_7;
	d->f11_6 = s->f11_6;
	d->f11_5 = s->f11_5;
	d->f11_4 = s->f11_4;
	d->f11_3 = s->f11_3;
	d->f11_2 = s->f11_2;
	d->f11_1 = s->f11_1;
	d->f11_0 = s->f11_0;
}

void DataBuf_CopyVoiceBlock24(struct T4_s *s, struct T4_d *d)
{
	d->b2 = s->b2;
	d->f3_0 = s->f3_0;
	d->f4_0 = s->f4_0;
	d->f5_7 = s->f5_7;
	d->f5_0 = s->f5_0;
	d->f6_7 = s->f6_7;
	d->f6_6 = s->f6_6;
	d->f6_4 = s->f6_4;
	d->f6_3 = s->f6_3;
	d->f6_0 = s->f6_0;
	d->f7_0 = s->f7_0;
	d->f8_7 = s->f8_7;
	d->f8_0 = s->f8_0;
	d->f9_0 = s->f9_0;
	d->f10_0 = s->f10_0;
	d->f11_0 = s->f11_0;
	d->b12 = s->b12;
	d->f13_0 = s->f13_0;
	d->f14_6 = s->f14_6;
	d->f14_5 = s->f14_5;
	d->f14_4 = s->f14_4;
	d->f14_3 = s->f14_3;
	d->f14_0 = s->f14_0;
	d->f15_7 = s->f15_7;
	d->f15_6 = s->f15_6;
	d->f15_5 = s->f15_5;
	d->f15_4 = s->f15_4;
	d->f15_0 = s->f15_0;
	d->f16_7 = s->f16_7;
	d->f16_0 = s->f16_0;
	d->b17 = s->b17;
	d->b18 = s->b18;
	d->f19_7 = s->f19_7;
	d->f19_0 = s->f19_0;
	d->f20_7 = s->f20_7;
	d->f20_0 = s->f20_0;
	d->f21_7 = s->f21_7;
	d->f21_0 = s->f21_0;
	d->f22_7 = s->f22_7;
	d->f22_0 = s->f22_0;
	d->b23 = s->b23;
}

void VoiceParam_CopyBf_LargeBlock(struct T5_s *s, struct T5_d *d)
{
	d->f15_0 = s->f0_0;
	d->f15_5 = s->f0_5;
	d->f15_6 = s->f0_6;
	d->f15_7 = s->f0_6;
	d->f14_0 = s->f1_0;
}
