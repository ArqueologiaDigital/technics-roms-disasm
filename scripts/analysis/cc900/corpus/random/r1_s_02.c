/* Random C89 program r1_s_02.c: gen_random.py --seed 1 --count 10 --funcs 20 --size small (file 2).
   Ours, deterministic; the docstring of gen_random.py says what it may contain and what it avoids. */
struct st { char c; int i; long l; unsigned int u; char *p; int a[8]; double d; };
extern char gc, gc2; extern unsigned char guc; extern int gi, gi2, gi3; extern unsigned int gu, gu2;
extern long gl, gl2; extern unsigned long gul; extern double gd, gd2;
extern char *gp; extern int *gpi; extern long *gpl; extern struct st gs, *gps;
extern char gca[16]; extern unsigned char guca[16]; extern int gia[16]; extern unsigned int gua[16];
extern long gla[16]; extern unsigned long gula[16]; extern double gda[4];
extern void v0(void); extern void v1(int); extern void v2(int, int); extern void vl(long); extern void vc(char);
extern void vu(unsigned int); extern void vp(char *); extern void vd(double); extern void vs(struct st *);
extern int r0(void); extern int r1(int); extern int r2(int, int); extern long rl(long); extern char rc(int);
extern unsigned int ru(unsigned int); extern unsigned long rul(unsigned long);
extern char *rp(void); extern int *rpi(int);

unsigned long r1_02_00(long a) {
	v2(gi2, gi ^ 1);
	a %= 2L;
	v0();
	guca[2] = guc / 100;
	return ~0x10000UL >> 3;
}
char r1_02_01(unsigned char a) {
	unsigned char t = ((unsigned char)gula[7]) & 128;
	char u = -gs.c;
	if (gula[1] & 0x8) { gca[a] = (char)t; gpi = &gia[t]; } else { gul++; gua[2] = (unsigned int)(gca[u] >= *gp); }
	a = -guca[0] - t;
	return (u = gca[3]);
}
unsigned long r1_02_02(void) {
	unsigned char t = guca[4] - 128;
	int u = gps->i - gia[6];
	gu2 = 256;
	vp(gp);
	if ((*gpl = 9L) >= 65536L && gul == 96849UL) { if (gca[3] != 0) *gp = 'A' % gca[3]; if (gula[t] != 0) gul = gul % gula[t]; }
	gps->l = gl;
	gi = u;
	return (gula[u] = gula[t]);
}
void r1_02_03(unsigned int a) {
	gd *= gda[1] - gs.d;
	gi3 = gi - 1;
}
long r1_02_04(unsigned char a, double b, struct st *c) {
	char *t = gp;
	unsigned int u = ru(gua[4]);
	*gpl = ~gpl[0];
	v1(gi2 % 4);
	vu(u);
	gp = t;
	return rl(gpl[3]);
}
unsigned int r1_02_05(unsigned long a, long b) {
	int i;
	int t = gi;
	char u = *gp ^ gs.c;
	v1(t);
	for (i = 0; i < 4; i++) { gu2 ^= gps->u << 5; gps->p = gps->p + i; gla[i] >>= 12; }
	vc(u + gs.c);
	guc = ~guca[6] | (((unsigned char)gla[6]) ^ ((unsigned char)a));
	if (!gul) gd = (gda[3] - gd2) - (gs.d / 1.0);
	return -(gps->a[6] != 256 ? 256 : gs.u);
}
char * r1_02_06(void) {
	int *t = gpi;
	gpi = t;
	vl(3L / 3L);
	guca[3] = 233 - ((unsigned char)gula[3]);
	gu2 = (gi2 ? (gu + 256) : (gu % 4));
	return &gca[5];
}
int * r1_02_07(char a, char b) {
	if (gs.a[7] != 0) gs.a[3] = gs.a[3] / gs.a[7];
	gs.p = gp;
	return gpi;
}
char * r1_02_08(int *a, unsigned char b) {
	gul = gula[2] = 4UL;
	if (gi3 == 16 && gla[2] > 65536L) --gc;
	gp = rp();
	if (gi2 != 0) gs.i = gi2 / gi2;
	return rp();
}
long r1_02_09(void) {
	char *t = &gca[2];
	--gpi;
	*t = gs.c = (gua[3] < 4 ? gs.c : (char)!gu);
	v0();
	return 6L / 16L;
}
unsigned int r1_02_10(void) {
	unsigned long t = 0x10000UL & gula[7];
	v0();
	--t;
	return ru(~gu2);
}
unsigned int r1_02_11(unsigned int a, double b) {
	unsigned int t = gu2 ^ gua[3];
	unsigned int u = (unsigned int)(((unsigned int)gul) == a);
	vu(t);
	guca[a] *= 11;
	if (r0() && guca[u] > guc) { guc = ((unsigned char)(14128 <= ((unsigned int)gl))) - (255 % 2); gp[1] = gps->c | ~gp[1]; } else { if (gia[5] != 0) gi = gia[a] % gia[5]; vc(gca[u]); }
	gc2 = (char)gu2;
	return ru(gu2) + ((unsigned int)(gul > gula[5]));
}
int * r1_02_12(int a, char b, char c) {
	if (gc2 != 0) gca[6] = c / gc2;
	vu(ru(gu2));
	return gpi + c;
}
char r1_02_13(void) {
	char *t = gp;
	gs.u = gu;
	vp(t);
	gpi[3] = 255 - gps->a[4];
	return rc(gi);
}
int r1_02_14(unsigned long a, unsigned long b) {
	int i;
	int t = !255;
	gu2 = gu = (gua[t] & gua[4]) | (!gca[t] ? 32767 : ((unsigned int)gpl[1]));
	i = 0; while (i < 11) { *gpi = gi2 = -(1 - t); gi = 8 + (t + 256); if (gua[i] != 0) gua[3] = gua[i] / gua[i]; i++; }
	if (r2(t, gi)) { v0(); a /= 3UL; } else { gi2 = gpi[0] = t | (gia[t] << 12); *gpi = gs.i = !256 / 16; }
	return 256;
}
int r1_02_15(void) {
	if (gi2 != 2) return gps->a[0] + gps->i;
	gla[2] %= 3L;
	return (100 ^ gs.a[3]) | (gi2 | 6);
}
int r1_02_16(void) {
	if (gps->u < 256 || guc >= 0) { gc = '9'; } else { if (gula[3] != 0) gul = 4UL / gula[3]; ++gp; guca[1] = guca[2] + 8; }
	gpi = gpi + 1;
	gula[6] = 0x10000UL;
	gl2 >>= 24;
	if ((gi2 = gi3)) { if (gc != 0) gs.c = gs.c / gc; if (gula[4] != 0) gul = gul / gula[4]; if (gc2 != 0) gc2 = gca[5] % gc2; } else { gps->c &= (gl != 9L ? gs.c : gc2); if (gua[5] != 0) gua[3] = gu2 % gua[5]; }
	return gia[1];
}
char r1_02_17(long a) {
	unsigned char t = 128;
	unsigned long u = gul;
	gc <<= 6;
	t = (unsigned char)!(gca[t] ^ gc);
	u += gul;
	return 6;
}
int * r1_02_18(unsigned long a, unsigned long b) {
	guc /= 10;
	switch (gs.u) { case 1: case 2: gl = -1916L ^ gl; break; case 5: case 8: *gpl = gla[7] << 3; case 16: vs(gps); break; case 1000: vs(gps); break; }
	gs.u += ~gps->u;
	vd(gd * gda[3]);
	return gpi + 1;
}
int r1_02_19(char a) {
	gpi++;
	vd(gd2);
	gua[a] = gua[a] + gua[6];
	return gi3 / 16;
}
