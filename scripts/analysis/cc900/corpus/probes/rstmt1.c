/* Every statement line of random alone in its own function (gen_rstmt.py corpus/random 1): rs_<A>_<BB>_<CC>_<k> is line k of
   r<A>_<BB>_<CC>; its locals are initialised from the externs j<type>, v0() comes first when an earlier line of the
   original calls, a declaration under test is followed by a store of its variable. */
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
extern char jc; extern unsigned char juc; extern int ji; extern unsigned int ju; extern long jl; extern unsigned long jul;
extern double jd; extern char *jp; extern int *jpi; extern long *jpl; extern struct st *jps;

void rs_1_00_00_1(long *a, unsigned long b) {
	int t = gpi[0] & gia[3];
	ji = t;
}
void rs_1_00_00_2(long *a, unsigned long b) {
	int t = ji;
	char *u = &gca[t];
	jp = u;
}
void rs_1_00_00_3(long *a, unsigned long b) {
	int t = ji;
	char *u = jp;
	if (gua[7] < gua[t]) { u = gp; }
}
void rs_1_00_00_4(long *a, unsigned long b) {
	gs.d = gda[3];
}
void rs_1_00_00_5(long *a, unsigned long b) {
	int t = ji;
	guca[t] = guca[t] ^ guc;
}
void rs_1_00_00_6(long *a, unsigned long b) {
	vl((long)(50304L != gla[5]));
}
void rs_1_00_00_7(long *a, unsigned long b) {
	int i = ji;
	char *u = jp;
	v0();
	i = 11; do { gua[3] = gu2; if (gu2 != 0) gua[i] = gs.u / gu2; } while (--i > 0);
}
char * rs_1_00_00_8(long *a, unsigned long b) {
	char *u = jp;
	v0();
	return u;
}
void rs_1_00_01_1(void) {
	int i = ji;
	i = 15; do { if (gps->u != 0) gs.u = 256 / gps->u; --gu2; vl(gl % 7L); } while (--i > 0);
}
void rs_1_00_01_2(void) {
	v2(gi2, gi3);
}
void rs_1_00_01_3(void) {
	guc--;
}
void rs_1_00_01_4(void) {
	vd(gs.d + gd);
}
void rs_1_00_01_5(void) {
	gul = gula[7];
}
char * rs_1_00_01_6(void) {
	return gp;
}
void rs_1_00_02_1(void) {
	int i = ji;
	unsigned long t = (unsigned long)(gi3 > gs.i);
	jul = t;
}
void rs_1_00_02_2(void) {
	double u = gs.d;
	jd = u;
}
void rs_1_00_02_3(void) {
	unsigned long t = jul;
	gul = t;
}
void rs_1_00_02_4(void) {
	--guc;
}
void rs_1_00_02_5(void) {
	int i = ji;
	double u = jd;
	i = 3; do { gs.a[3] = r2(gi2, (int)guc); if (gua[i] != 0) gs.u = 8 % gua[i]; } while (--i > 0);
}
void rs_1_00_02_6(void) {
	int i = ji;
	double u = jd;
	v0();
	i = 14; do { if (gla[0] != 0) *gpl = gs.l / gla[0]; if (gs.u != 0) gps->u = gs.u / gs.u; } while (--i > 0);
}
void rs_1_00_02_7(void) {
	++gl2;
}
int rs_1_00_02_8(void) {
	int i = ji;
	unsigned long t = jul;
	v0();
	return (t < 0UL ? (int)gs.l : gs.i) >> 12;
}
void rs_1_00_03_1(double a, char *b) {
	int t = r1(*gpi);
	ji = t;
}
void rs_1_00_03_2(double a, char *b) {
	int t = ji;
	int u = t % 4;
	v0();
	ji = u;
}
void rs_1_00_03_3(double a, char *b) {
	gd = (0.25 + a) - 2.5;
}
void rs_1_00_03_4(double a, char *b) {
	int i = ji;
	int t = ji;
	int u = ji;
	v0();
	if (gl2 > 52252L && b[u]) { guca[u] = (unsigned char)(gul ^ gula[t]); } else { if (gu != 0) gu2 = gu2 % gu; if (gps->i != 0) u = 8 % gps->i; if (gla[0] != 0) gps->l = gpl[3] / gla[0]; }
}
void rs_1_00_03_5(double a, char *b) {
	int i = ji;
	v0();
	for (i = 0; i < 11; i++) { gs.p = b; }
}
void rs_1_00_03_6(double a, char *b) {
	int t = ji;
	v0();
	++t;
}
unsigned long rs_1_00_03_7(double a, char *b) {
	return ~(gul & 19515UL);
}
void rs_1_00_04_0(void) {
	gl -= gs.l / 100L;
}
void rs_1_00_04_1(void) {
	vp(rp());
}
char rs_1_00_04_2(void) {
	return 53;
}
void rs_1_00_05_0(long *a) {
	gl2 = (long)!(61613L * gl2);
}
void rs_1_00_05_1(long *a) {
	gpl[0] = (long)gul;
}
void rs_1_00_05_2(long *a) {
	if (65536L != gla[7]) gula[3] = gul = gula[2];
}
void rs_1_00_06_0(char a, long *b) {
	gl = (long)(rul(gula[a]) <= (gc ? gula[5] : gul));
}
void rs_1_00_06_1(char a, long *b) {
	if (gi3 & 1 && guca[a] != 2) { gca[7] = (gula[a] ? (a / 16) : -(char)guca[a]); gi3--; guca[0] = guc; } else { gu++; vp(rp()); }
}
void rs_1_00_06_2(char a, long *b) {
	gul = (gula[4] % 10UL) * 3UL;
}
void rs_1_00_06_3(char a, long *b) {
	++guc;
}
void rs_1_00_06_4(char a, long *b) {
	guc = (gc ? 255 : guca[1]) ^ (gul <= 1UL ? guc : guc);
}
int rs_1_00_06_5(char a, long *b) {
	return gs.i;
}
void rs_1_00_07_0(unsigned char a, unsigned char b, char *c) {
	int *t = gpi;
	jpi = t;
}
void rs_1_00_07_1(unsigned char a, unsigned char b, char *c) {
	gla[a] -= 65536L;
}
void rs_1_00_07_2(unsigned char a, unsigned char b, char *c) {
	int *t = jpi;
	gpi = t;
}
int rs_1_00_07_3(unsigned char a, unsigned char b, char *c) {
	if (r2(gi2, gi)) return gi;
}
void rs_1_00_07_4(unsigned char a, unsigned char b, char *c) {
	gps->c = gc = (*c - gc) - (gps->c / 100);
}
int rs_1_00_07_5(unsigned char a, unsigned char b, char *c) {
	return (gda[0] <= (double)gs.l ? (int)gc2 : 255) | (gia[0] >> 4);
}
void rs_1_00_08_1(void) {
	gd = (2.5 + gda[3]) * (gd2 * gd2);
}
void rs_1_00_08_2(void) {
	gs.c = gps->c;
}
void rs_1_00_08_3(void) {
	int i = ji;
	i = 7; do { gia[i] = 100 + gi3; gc2 ^= 8 & gc; } while (--i > 0);
}
int rs_1_00_08_4(void) {
	return (gi3 = (int)guca[7]);
}
void rs_1_00_09_1(void) {
	unsigned int t = gua[3] * gua[4];
	ju = t;
}
void rs_1_00_09_2(void) {
	int i = ji;
	unsigned int t = ju;
	for (i = 9; i > 0; i--) { if (t != 0) gu = 255 / t; v0(); }
}
void rs_1_00_09_3(void) {
	if (r1(gia[7])) --gc;
}
void rs_1_00_10_0(unsigned long a, int b) {
	unsigned int t = (unsigned int)3;
	ju = t;
}
void rs_1_00_10_1(unsigned long a, int b) {
	unsigned int t = ju;
	++t;
}
void rs_1_00_10_2(unsigned long a, int b) {
	v1(gpi[1] + 2);
}
void rs_1_00_10_3(unsigned long a, int b) {
	guca[4] = guc & 255;
}
int * rs_1_00_10_4(unsigned long a, int b) {
	return gpi;
}
void rs_1_00_11_0(char *a, long b, long c) {
	gu /= 10;
}
void rs_1_00_11_1(char *a, long b, long c) {
	vc(gca[0] + gp[1]);
}
void rs_1_00_11_2(char *a, long b, long c) {
	switch (gs.c) { case 1: vp(&gca[6]); break; case 20: gi2 %= 7; break; default: vp(gs.p); break; }
}
void rs_1_00_12_1(int a, int b, long *c) {
	unsigned int t = gu - 1;
	ju = t;
}
void rs_1_00_12_2(int a, int b, long *c) {
	int u = !gl2;
	ji = u;
}
void rs_1_00_12_3(int a, int b, long *c) {
	int i = ji;
	unsigned int t = ju;
	int u = ji;
	for (i = 0; i < a; i++) { if (*gpi != 0) a = u % *gpi; gps->c = gs.c + 7; t = gua[i] & (gu2 >> 10); }
}
void rs_1_00_12_4(int a, int b, long *c) {
	v1(4);
}
void rs_1_00_12_5(int a, int b, long *c) {
	int u = ji;
	v0();
	guc |= guc >> (u & 7);
}
void rs_1_00_12_6(int a, int b, long *c) {
	int i = ji;
	int u = ji;
	v0();
	for (i = 0; i < 8; i++) { ++gul; *gp = ('0' * gp[0]) >> 5; u = gi2; }
}
unsigned int rs_1_00_12_7(int a, int b, long *c) {
	return (gu2 | 1) * 2;
}
void rs_1_00_13_0(char a) {
	gc2 ^= 41;
}
void rs_1_00_13_1(char a) {
	a <<= 1;
}
void rs_1_00_13_2(char a) {
	guc++;
}
void rs_1_00_13_3(char a) {
	switch (gi) { case 0: case 1: gs.d -= (double)gu; default: gp = gs.p + a; break; }
}
unsigned long rs_1_00_13_4(char a) {
	return (gul - 60080UL) % 3UL;
}
void rs_1_00_14_0(unsigned int a, unsigned int b) {
	double t = gd2;
	jd = t;
}
void rs_1_00_14_1(unsigned int a, unsigned int b) {
	long u = rl(gla[6]);
	jl = u;
}
void rs_1_00_14_2(unsigned int a, unsigned int b) {
	gi2 -= 100 << 7;
}
void rs_1_00_14_3(unsigned int a, unsigned int b) {
	double t = jd;
	v0();
	gd2 *= t / 3.0;
}
void rs_1_00_14_4(unsigned int a, unsigned int b) {
	long u = jl;
	v0();
	vl(u);
}
void rs_1_00_14_5(unsigned int a, unsigned int b) {
	double t = jd;
	v0();
	if (gca[a] != gca[b]) { if (gps->c != 0) gca[a] = gc % gps->c; gl2 = (long)((gca[b] == -81 ? gd : t) > gd2); }
}
void rs_1_00_14_6(unsigned int a, unsigned int b) {
	gi3 = r1(gi2 % 2);
}
void rs_1_00_14_7(unsigned int a, unsigned int b) {
	vc(~gca[a]);
}
int rs_1_00_14_8(unsigned int a, unsigned int b) {
	return (gs.i ^ gs.a[b]) * (gs.a[b] | gpi[1]);
}
void rs_1_00_15_0(unsigned char a, long b) {
	int t = 256 + 8;
	ji = t;
}
void rs_1_00_15_1(unsigned char a, long b) {
	if (guc >= guca[0]) gc2--;
}
void rs_1_00_15_2(unsigned char a, long b) {
	while (gi-- > 0) *gp++ = 5;
}
void rs_1_00_15_3(unsigned char a, long b) {
	int t = ji;
	v2(gi2, t - gia[a]);
}
void rs_1_00_15_4(unsigned char a, long b) {
	gula[7] &= rul(1UL);
}
void rs_1_00_15_5(unsigned char a, long b) {
	int t = ji;
	v0();
	if (gua[t] & 0x80 || t) gia[a] = (gd == (double)b) >> 13;
}
char rs_1_00_15_6(unsigned char a, long b) {
	return rc(100 | gs.i);
}
void rs_1_00_16_1(double a) {
	vs(gps);
}
void rs_1_00_16_2(double a) {
	int i = ji;
	v0();
	i = 14; do { gul = rul(gul); gula[i] = rul(gul) - -1UL; if (gula[i] != 0) gula[i] = gul / gula[i]; } while (--i > 0);
}
void rs_1_00_16_3(double a) {
	gp = gps->p;
}
long rs_1_00_16_4(double a) {
	return 2L * (32767 >= ((unsigned int)guc) ? gs.l : gl);
}
void rs_1_00_17_1(void) {
	int i = ji;
	if (r2(gi2, gi)) { if (gi3 != 0) gps->i = gps->i / gi3; gd += gd / 100.0; }
}
void rs_1_00_17_2(void) {
	gula[0] -= -gul;
}
void rs_1_00_17_3(void) {
	int i = ji;
	v0();
	i = 0; while (i < 15) { gca[1] -= gc / 16; i++; }
}
void rs_1_00_17_4(void) {
	gu = ((unsigned int)!gl) - (gu << 12);
}
void rs_1_00_17_5(void) {
	if (r2(gpi[0], gi)) guc = guca[3] = 112 - (guca[2] & guc);
}
int rs_1_00_17_6(void) {
	return (75 > guca[0]) * (gi ^ gs.a[1]);
}
void rs_1_00_18_1(int a, struct st *b, char c) {
	int t = gpi[1];
	ji = t;
}
void rs_1_00_18_2(int a, struct st *b, char c) {
	int i = ji;
	i = 0; while (i < a) { gs.u /= 10; i++; }
}
void rs_1_00_18_3(int a, struct st *b, char c) {
	int t = ji;
	gs.a[6] &= t ^ 694;
}
void rs_1_00_18_4(int a, struct st *b, char c) {
	gu = (guc ? gua[c] : gps->u);
}
void rs_1_00_18_5(int a, struct st *b, char c) {
	guc = (255 & guc) % 100;
}
unsigned long rs_1_00_18_6(int a, struct st *b, char c) {
	return 3UL & gula[7];
}
void rs_1_00_19_1(int a, char b) {
	gp[3] = gca[a] = (gca[b] - (char)gs.a[a]) + (*gp | gc);
}
void rs_1_00_19_2(int a, char b) {
	switch (gi) { case 0: gp = rp(); break; case 1: guc = guca[0] << 1; break; case 2: guc += 255; break; }
}
void rs_1_00_19_3(int a, char b) {
	if (gul != 0) gul = gula[4] % gul;
}
void rs_1_00_19_4(int a, char b) {
	int i = ji;
	v0();
	i = a; do { gs.u = gua[b] + (29164 % 2); gula[i] = (gps->l ? gul : gul); } while (--i > 0);
}
void rs_1_00_19_5(int a, char b) {
	while (a-- > 0) *gpi++ = 16;
}
void rs_1_01_00_0(char a, char b, unsigned char c) {
	double t = -3.0;
	jd = t;
}
void rs_1_01_00_1(char a, char b, unsigned char c) {
	int *u = gpi;
	jpi = u;
}
void rs_1_01_00_2(char a, char b, unsigned char c) {
	c = guca[6] % 100;
}
void rs_1_01_00_3(char a, char b, unsigned char c) {
	int *u = jpi;
	gpi = u;
}
void rs_1_01_00_4(char a, char b, unsigned char c) {
	double t = jd;
	t += t + t;
}
void rs_1_01_00_5(char a, char b, unsigned char c) {
	gu2 += 32767;
}
void rs_1_01_00_6(char a, char b, unsigned char c) {
	gpi[2] = 127 - gia[a];
}
unsigned int rs_1_01_00_7(char a, char b, unsigned char c) {
	int *u = jpi;
	return (gs.u = 3706);
}
void rs_1_01_01_0(void) {
	unsigned char t = guc + 212;
	juc = t;
}
void rs_1_01_01_1(void) {
	unsigned char t = juc;
	switch (gi3) { case 5: t %= 3; break; case 20: *gpi *= 2; break; }
}
void rs_1_01_01_2(void) {
	while (gi-- > 0) { if (*gp == -19) break; gp++; }
}
void rs_1_01_01_3(void) {
	unsigned char t = juc;
	if (((unsigned long)t) == gul) { if (gul != 0) gul = 0x10000UL / gul; } else { gs.p = &gca[1]; if (*gpi != 0) gs.i = gi % *gpi; }
}
void rs_1_01_01_4(void) {
	v0();
}
void rs_1_01_02_1(unsigned long a) {
	gpi = gpi + 1;
}
void rs_1_01_02_2(unsigned long a) {
	a = ((unsigned long)(gla[6] != 65536L)) | (2UL + gul);
}
void rs_1_01_02_3(unsigned long a) {
	gia[3] = 255;
}
void rs_1_01_02_4(unsigned long a) {
	int i = ji;
	for (i = 0; i < 11; i++) { if (gpl[3] != 0) gps->l = gl2 / gpl[3]; if (a != 0) a = 1UL / a; }
}
void rs_1_01_02_5(unsigned long a) {
	guca[3] = -((unsigned char)gua[0]);
}
char rs_1_01_02_6(unsigned long a) {
	return (gc * gc) >> 7;
}
void rs_1_01_03_0(int a, struct st *b, unsigned int c) {
	gul += rul(gula[4]);
}
void rs_1_01_03_1(int a, struct st *b, unsigned int c) {
	gia[6] %= 16;
}
void rs_1_01_03_2(int a, struct st *b, unsigned int c) {
	gs.l = gl2 = rl(gl) * 4L;
}
void rs_1_01_03_3(int a, struct st *b, unsigned int c) {
	gs.i ^= gi2 >> 1;
}
void rs_1_01_04_0(unsigned long a, long *b, int c) {
	char t = '9' >> 7;
	jc = t;
}
void rs_1_01_04_1(unsigned long a, long *b, int c) {
	unsigned char u = guc;
	juc = u;
}
void rs_1_01_04_2(unsigned long a, long *b, int c) {
	char t = jc;
	if ((char)gua[4] > '9') { if (gl2 != 0) gl = 2L / gl2; } else { if (t != gp[0]) gul++; }
}
void rs_1_01_04_3(unsigned long a, long *b, int c) {
	unsigned char u = juc;
	switch (gs.u) { case 2: v1(gi2); break; case 20: gs.p = &gca[5]; break; case 200: gda[0] *= 0.25; break; default: gda[1] = gd2; break; }
}
void rs_1_01_04_4(unsigned long a, long *b, int c) {
	vd(gda[1] - gda[0]);
}
void rs_1_01_04_5(unsigned long a, long *b, int c) {
	char t = jc;
	v0();
	if ((gp[0] = t)) { gul -= ~7UL; guca[5] = ((unsigned char)(gps->c <= gc2)) + ((unsigned char)(gda[3] < 100.0)); gpi = &gia[0]; } else { gpi = &gia[0]; gl++; gul = (unsigned long)(-gula[t] < a); }
}
long rs_1_01_04_6(unsigned long a, long *b, int c) {
	return -(gla[c] % 4L);
}
void rs_1_01_05_0(long *a, unsigned char b) {
	unsigned char t = b - guc;
	juc = t;
}
void rs_1_01_05_1(long *a, unsigned char b) {
	*gpl = gl = 65536L;
}
void rs_1_01_05_2(long *a, unsigned char b) {
	gul = gula[4] = 0x10000UL;
}
void rs_1_01_05_3(long *a, unsigned char b) {
	v2(gps->i, gi);
}
void rs_1_01_05_4(long *a, unsigned char b) {
	gl = rl(gl) ^ *gpl;
}
char * rs_1_01_05_5(long *a, unsigned char b) {
	if ((long)gi != gla[b]) return rp();
}
void rs_1_01_05_6(long *a, unsigned char b) {
	unsigned char t = juc;
	v0();
	guc = t;
}
char * rs_1_01_05_7(long *a, unsigned char b) {
	return gps->p;
}
void rs_1_01_06_0(int a, unsigned char b, unsigned char c) {
	vl(gpl[0]);
}
void rs_1_01_06_1(int a, unsigned char b, unsigned char c) {
	gd2 -= gs.d - 100.0;
}
void rs_1_01_06_2(int a, unsigned char b, unsigned char c) {
	gs.l = gla[a];
}
int rs_1_01_06_3(int a, unsigned char b, unsigned char c) {
	return (gps->a[b] = 127);
}
void rs_1_01_07_0(void) {
	if (gul < 0x10000UL) { --gp; gpi = &gia[5]; } else { if (gc2) v2(gi2, (int)gul * 8); }
}
void rs_1_01_07_1(void) {
	if (guc == 6) { gl = (guc ? (gpl[1] << 10) : (gpl[1] & (long)gs.c)); gula[5] /= 2UL; if (gu2 != 0) gu2 = gps->u % gu2; } else { gc2 /= 2; gul++; }
}
void rs_1_01_07_2(void) {
	vl(gps->l << 3);
}
void rs_1_01_07_3(void) {
	vu(ru(gs.u));
}
char * rs_1_01_07_4(void) {
	return gp;
}
void rs_1_01_08_0(long a, unsigned long b, long *c) {
	int t = gia[2];
	ji = t;
}
void rs_1_01_08_1(long a, unsigned long b, long *c) {
	char *u = gs.p;
	jp = u;
}
void rs_1_01_08_2(long a, unsigned long b, long *c) {
	int t = ji;
	gps->i |= t >> 10;
}
void rs_1_01_08_3(long a, unsigned long b, long *c) {
	--gu;
}
void rs_1_01_08_4(long a, unsigned long b, long *c) {
	char *u = jp;
	gu2 = ru(4 | gs.u);
}
void rs_1_01_08_5(long a, unsigned long b, long *c) {
	if (b != 0) gul = gul % b;
}
int * rs_1_01_08_6(long a, unsigned long b, long *c) {
	return gpi;
}
void rs_1_01_09_0(void) {
	if (guca[5] == 75) if (gl != 0) gl = 65536L / gl;
}
void rs_1_01_09_1(void) {
	v1(gi2 - gi);
}
void rs_1_01_09_2(void) {
	while (gi-- > 0) { if (*gp == 5) break; gp++; }
}
int rs_1_01_09_3(void) {
	return (r0() ? gi3 : gia[3]) / 7;
}
void rs_1_01_10_1(long *a) {
	gpi = gpi + 1;
}
void rs_1_01_10_2(long *a) {
	gl2 = a[2];
}
void rs_1_01_10_3(long *a) {
	int i = ji;
	i = 0; while (i < 15) { guca[i] = guc; *gpi = -gi3; if (gs.u != 0) gua[i] = gps->u / gs.u; i++; }
}
char * rs_1_01_10_4(long *a) {
	return rp();
}
void rs_1_01_11_0(unsigned char a) {
	long t = gs.l;
	jl = t;
}
void rs_1_01_11_1(unsigned char a) {
	int u = -gps->a[a];
	ji = u;
}
void rs_1_01_11_2(unsigned char a) {
	--gul;
}
void rs_1_01_11_3(unsigned char a) {
	int u = ji;
	if (u & 4) { gu2 &= 256; gd2 += -gs.d; vd(gd2 + gs.d); } else { v2(gia[6] & (int)gul, gi); vp(gp); }
}
void rs_1_01_11_4(unsigned char a) {
	gc2 = gca[a];
}
void rs_1_01_11_5(unsigned char a) {
	int u = ji;
	v0();
	if ((double)gs.u == (double)gu) if (gu2 != 0) gu = 255 % gu2;
}
void rs_1_01_11_6(unsigned char a) {
	guc = a;
}
void rs_1_01_11_7(unsigned char a) {
	long t = jl;
	v0();
	gl = t;
}
int rs_1_01_11_8(unsigned char a) {
	return (2 >> 4) - (gi & 255);
}
void rs_1_01_12_0(int a) {
	vp(&gca[4]);
}
void rs_1_01_12_1(int a) {
	vl((gca[5] != '9' ? gla[a] : gl2));
}
void rs_1_01_12_2(int a) {
	if (guca[3]) { gda[2] *= -gd; vl((long)(char)gps->a[6]); *gpl = gla[a]; }
}
void rs_1_01_12_3(int a) {
	gs.u = -gs.u;
}
long rs_1_01_12_4(int a) {
	if (r0()) return ~65536L;
}
long rs_1_01_12_5(int a) {
	return ~*gpl & (*gpl - 6L);
}
void rs_1_01_13_0(int a) {
	int t = gia[a] / 2;
	ji = t;
}
void rs_1_01_13_1(int a) {
	gl = *gpl = gl2;
}
void rs_1_01_13_2(int a) {
	int t = ji;
	if (gps->a[t] != 0) a = a % gps->a[t];
}
void rs_1_01_13_3(int a) {
	int t = ji;
	if (1 == 0 && gpi[1] > 100) { gda[2] = (2.5 + gs.d) / 0.5; gs.l = *gpl; if (gpl[2] != 0) gpl[1] = 65536L / gpl[2]; } else { t *= 10; guca[t] &= 109; gula[2] = (16354UL + ((unsigned long)guc)) - (gul + 0x10000UL); }
}
void rs_1_01_13_4(int a) {
	v0();
}
void rs_1_01_13_5(int a) {
	a <<= 1;
}
unsigned long rs_1_01_13_6(int a) {
	return (unsigned long)((gda[0] * 10.0) <= (gd / 2.5));
}
void rs_1_01_14_0(int a, unsigned long b, int c) {
	int t = !gc2;
	ji = t;
}
void rs_1_01_14_1(int a, unsigned long b, int c) {
	gula[3] = rul((unsigned long)((unsigned char)gua[0]));
}
void rs_1_01_14_2(int a, unsigned long b, int c) {
	int t = ji;
	v0();
	t = (8 ^ gia[a]) / 3;
}
void rs_1_01_14_3(int a, unsigned long b, int c) {
	if (*gpl >= (long)gc || (gu = gs.u) == 256) { if (gpl[3] != 0) gl2 = gs.l % gpl[3]; if (gi != 0) a = a / gi; if (gi != 0) c = gia[7] % gi; }
}
void rs_1_01_14_4(int a, unsigned long b, int c) {
	gu2--;
}
void rs_1_01_15_0(void) {
	unsigned int t = 32767;
	ju = t;
}
void rs_1_01_15_1(void) {
	unsigned long u = rul(gul);
	jul = u;
}
void rs_1_01_15_2(void) {
	unsigned int t = ju;
	unsigned long u = jul;
	v0();
	t = gps->u;
}
void rs_1_01_15_3(void) {
	unsigned long u = jul;
	v0();
	gul = rul(63926UL) + (u / 2UL);
}
void rs_1_01_15_4(void) {
	unsigned int t = ju;
	unsigned long u = jul;
	v0();
	if (u) t = gu >> 10;
}
void rs_1_01_15_5(void) {
	gp--;
}
int rs_1_01_15_6(void) {
	unsigned int t = ju;
	v0();
	return (int)gua[t];
}
void rs_1_01_16_1(int a, int *b) {
	unsigned char t = 202;
	juc = t;
}
void rs_1_01_16_2(int a, int *b) {
	unsigned char t = juc;
	gula[3] = gula[t] - gul;
}
void rs_1_01_16_3(int a, int *b) {
	v0();
}
void rs_1_01_16_4(int a, int *b) {
	if (gi3 != 0) gi2 = a / gi3;
}
void rs_1_01_16_5(int a, int *b) {
	int i = ji;
	v0();
	for (i = 0; i < 8; i++) { vl(gl2 << 28); gu2 *= 5; gps->l = gpl[3] = rl(gl2) % 3L; }
}
void rs_1_01_16_6(int a, int *b) {
	vu(gu2);
}
char rs_1_01_16_7(int a, int *b) {
	return rc(!7);
}
void rs_1_01_17_0(int a) {
	gula[a] = gula[5];
}
void rs_1_01_17_1(int a) {
	vs(gps);
}
int * rs_1_01_17_2(int a) {
	if (9 < gca[0]) return gpi + a;
}
int * rs_1_01_17_3(int a) {
	return gpi;
}
void rs_1_01_18_0(void) {
	char *t = gp;
	jp = t;
}
void rs_1_01_18_1(void) {
	long u = 65536L ^ gpl[2];
	jl = u;
}
void rs_1_01_18_2(void) {
	gi2 = gia[6] << 10;
}
void rs_1_01_18_3(void) {
	gpi = gpi + 1;
}
void rs_1_01_18_4(void) {
	gc--;
}
void rs_1_01_18_5(void) {
	char *t = jp;
	t++;
}
void rs_1_01_18_6(void) {
	gul = gula[4] = ((unsigned long)!((unsigned int)gps->a[2])) - rul(gula[3]);
}
void rs_1_01_18_7(void) {
	long u = jl;
	v0();
	vl(u);
}
char rs_1_01_18_8(void) {
	return gca[6] + (gca[6] | *gp);
}
void rs_1_01_19_1(int a) {
	v2(gi2, gi2 & gia[4]);
}
void rs_1_01_19_2(int a) {
	int i = ji;
	v0();
	i = 12; do { if (gca[i] != 0) gc = gc2 / gca[i]; } while (--i > 0);
}
void rs_1_01_19_3(int a) {
	int i = ji;
	v0();
	v2(~gps->i, gi);
}
void rs_1_01_19_4(int a) {
	switch (gu) { case 3: case 16: gps->u >>= 7; break; case 20: case 100: case 1000: vu(gps->u); }
}
void rs_1_01_19_5(int a) {
	gia[0] = r2(gps->a[7], gi);
}
char * rs_1_01_19_6(int a) {
	return &gca[3];
}
void rs_1_02_00_0(long a) {
	v2(gi2, gi ^ 1);
}
void rs_1_02_00_1(long a) {
	a %= 2L;
}
void rs_1_02_00_2(long a) {
	v0();
}
void rs_1_02_00_3(long a) {
	guca[2] = guc / 100;
}
unsigned long rs_1_02_00_4(long a) {
	return ~0x10000UL >> 3;
}
void rs_1_02_01_0(unsigned char a) {
	unsigned char t = ((unsigned char)gula[7]) & 128;
	juc = t;
}
void rs_1_02_01_1(unsigned char a) {
	char u = -gs.c;
	jc = u;
}
void rs_1_02_01_2(unsigned char a) {
	unsigned char t = juc;
	char u = jc;
	if (gula[1] & 0x8) { gca[a] = (char)t; gpi = &gia[t]; } else { gul++; gua[2] = (unsigned int)(gca[u] >= *gp); }
}
void rs_1_02_01_3(unsigned char a) {
	unsigned char t = juc;
	a = -guca[0] - t;
}
char rs_1_02_01_4(unsigned char a) {
	char u = jc;
	return (u = gca[3]);
}
void rs_1_02_02_0(void) {
	unsigned char t = guca[4] - 128;
	juc = t;
}
void rs_1_02_02_1(void) {
	int u = gps->i - gia[6];
	ji = u;
}
void rs_1_02_02_2(void) {
	gu2 = 256;
}
void rs_1_02_02_3(void) {
	vp(gp);
}
void rs_1_02_02_4(void) {
	unsigned char t = juc;
	v0();
	if ((*gpl = 9L) >= 65536L && gul == 96849UL) { if (gca[3] != 0) *gp = 'A' % gca[3]; if (gula[t] != 0) gul = gul % gula[t]; }
}
void rs_1_02_02_5(void) {
	gps->l = gl;
}
void rs_1_02_02_6(void) {
	int u = ji;
	v0();
	gi = u;
}
unsigned long rs_1_02_02_7(void) {
	unsigned char t = juc;
	int u = ji;
	v0();
	return (gula[u] = gula[t]);
}
void rs_1_02_03_0(unsigned int a) {
	gd *= gda[1] - gs.d;
}
void rs_1_02_03_1(unsigned int a) {
	gi3 = gi - 1;
}
void rs_1_02_04_0(unsigned char a, double b, struct st *c) {
	char *t = gp;
	jp = t;
}
void rs_1_02_04_1(unsigned char a, double b, struct st *c) {
	unsigned int u = ru(gua[4]);
	ju = u;
}
void rs_1_02_04_2(unsigned char a, double b, struct st *c) {
	*gpl = ~gpl[0];
}
void rs_1_02_04_3(unsigned char a, double b, struct st *c) {
	v1(gi2 % 4);
}
void rs_1_02_04_4(unsigned char a, double b, struct st *c) {
	unsigned int u = ju;
	v0();
	vu(u);
}
void rs_1_02_04_5(unsigned char a, double b, struct st *c) {
	char *t = jp;
	v0();
	gp = t;
}
long rs_1_02_04_6(unsigned char a, double b, struct st *c) {
	return rl(gpl[3]);
}
void rs_1_02_05_1(unsigned long a, long b) {
	int t = gi;
	ji = t;
}
void rs_1_02_05_2(unsigned long a, long b) {
	char u = *gp ^ gs.c;
	jc = u;
}
void rs_1_02_05_3(unsigned long a, long b) {
	int t = ji;
	v1(t);
}
void rs_1_02_05_4(unsigned long a, long b) {
	int i = ji;
	char u = jc;
	v0();
	for (i = 0; i < 4; i++) { gu2 ^= gps->u << 5; gps->p = gps->p + i; gla[i] >>= 12; }
}
void rs_1_02_05_5(unsigned long a, long b) {
	char u = jc;
	v0();
	vc(u + gs.c);
}
void rs_1_02_05_6(unsigned long a, long b) {
	guc = ~guca[6] | (((unsigned char)gla[6]) ^ ((unsigned char)a));
}
void rs_1_02_05_7(unsigned long a, long b) {
	if (!gul) gd = (gda[3] - gd2) - (gs.d / 1.0);
}
unsigned int rs_1_02_05_8(unsigned long a, long b) {
	char u = jc;
	v0();
	return -(gps->a[6] != 256 ? 256 : gs.u);
}
void rs_1_02_06_0(void) {
	int *t = gpi;
	jpi = t;
}
void rs_1_02_06_1(void) {
	int *t = jpi;
	gpi = t;
}
void rs_1_02_06_2(void) {
	vl(3L / 3L);
}
void rs_1_02_06_3(void) {
	guca[3] = 233 - ((unsigned char)gula[3]);
}
void rs_1_02_06_4(void) {
	gu2 = (gi2 ? (gu + 256) : (gu % 4));
}
char * rs_1_02_06_5(void) {
	return &gca[5];
}
void rs_1_02_07_0(char a, char b) {
	if (gs.a[7] != 0) gs.a[3] = gs.a[3] / gs.a[7];
}
void rs_1_02_07_1(char a, char b) {
	gs.p = gp;
}
int * rs_1_02_07_2(char a, char b) {
	return gpi;
}
void rs_1_02_08_0(int *a, unsigned char b) {
	gul = gula[2] = 4UL;
}
void rs_1_02_08_1(int *a, unsigned char b) {
	if (gi3 == 16 && gla[2] > 65536L) --gc;
}
void rs_1_02_08_2(int *a, unsigned char b) {
	gp = rp();
}
void rs_1_02_08_3(int *a, unsigned char b) {
	if (gi2 != 0) gs.i = gi2 / gi2;
}
char * rs_1_02_08_4(int *a, unsigned char b) {
	return rp();
}
void rs_1_02_09_0(void) {
	char *t = &gca[2];
	jp = t;
}
void rs_1_02_09_1(void) {
	--gpi;
}
void rs_1_02_09_2(void) {
	char *t = jp;
	*t = gs.c = (gua[3] < 4 ? gs.c : (char)!gu);
}
void rs_1_02_09_3(void) {
	v0();
}
long rs_1_02_09_4(void) {
	return 6L / 16L;
}
void rs_1_02_10_0(void) {
	unsigned long t = 0x10000UL & gula[7];
	jul = t;
}
void rs_1_02_10_1(void) {
	v0();
}
void rs_1_02_10_2(void) {
	unsigned long t = jul;
	v0();
	--t;
}
unsigned int rs_1_02_10_3(void) {
	return ru(~gu2);
}
void rs_1_02_11_0(unsigned int a, double b) {
	unsigned int t = gu2 ^ gua[3];
	ju = t;
}
void rs_1_02_11_1(unsigned int a, double b) {
	unsigned int u = (unsigned int)(((unsigned int)gul) == a);
	ju = u;
}
void rs_1_02_11_2(unsigned int a, double b) {
	unsigned int t = ju;
	vu(t);
}
void rs_1_02_11_3(unsigned int a, double b) {
	guca[a] *= 11;
}
void rs_1_02_11_4(unsigned int a, double b) {
	unsigned int u = ju;
	v0();
	if (r0() && guca[u] > guc) { guc = ((unsigned char)(14128 <= ((unsigned int)gl))) - (255 % 2); gp[1] = gps->c | ~gp[1]; } else { if (gia[5] != 0) gi = gia[a] % gia[5]; vc(gca[u]); }
}
void rs_1_02_11_5(unsigned int a, double b) {
	gc2 = (char)gu2;
}
unsigned int rs_1_02_11_6(unsigned int a, double b) {
	return ru(gu2) + ((unsigned int)(gul > gula[5]));
}
void rs_1_02_12_0(int a, char b, char c) {
	if (gc2 != 0) gca[6] = c / gc2;
}
void rs_1_02_12_1(int a, char b, char c) {
	vu(ru(gu2));
}
int * rs_1_02_12_2(int a, char b, char c) {
	return gpi + c;
}
void rs_1_02_13_0(void) {
	char *t = gp;
	jp = t;
}
void rs_1_02_13_1(void) {
	gs.u = gu;
}
void rs_1_02_13_2(void) {
	char *t = jp;
	vp(t);
}
void rs_1_02_13_3(void) {
	gpi[3] = 255 - gps->a[4];
}
char rs_1_02_13_4(void) {
	return rc(gi);
}
void rs_1_02_14_1(unsigned long a, unsigned long b) {
	int t = !255;
	ji = t;
}
void rs_1_02_14_2(unsigned long a, unsigned long b) {
	int t = ji;
	gu2 = gu = (gua[t] & gua[4]) | (!gca[t] ? 32767 : ((unsigned int)gpl[1]));
}
void rs_1_02_14_3(unsigned long a, unsigned long b) {
	int i = ji;
	int t = ji;
	i = 0; while (i < 11) { *gpi = gi2 = -(1 - t); gi = 8 + (t + 256); if (gua[i] != 0) gua[3] = gua[i] / gua[i]; i++; }
}
void rs_1_02_14_4(unsigned long a, unsigned long b) {
	int i = ji;
	int t = ji;
	if (r2(t, gi)) { v0(); a /= 3UL; } else { gi2 = gpi[0] = t | (gia[t] << 12); *gpi = gs.i = !256 / 16; }
}
int rs_1_02_14_5(unsigned long a, unsigned long b) {
	return 256;
}
int rs_1_02_15_0(void) {
	if (gi2 != 2) return gps->a[0] + gps->i;
}
void rs_1_02_15_1(void) {
	gla[2] %= 3L;
}
int rs_1_02_15_2(void) {
	return (100 ^ gs.a[3]) | (gi2 | 6);
}
void rs_1_02_16_0(void) {
	if (gps->u < 256 || guc >= 0) { gc = '9'; } else { if (gula[3] != 0) gul = 4UL / gula[3]; ++gp; guca[1] = guca[2] + 8; }
}
void rs_1_02_16_1(void) {
	gpi = gpi + 1;
}
void rs_1_02_16_2(void) {
	gula[6] = 0x10000UL;
}
void rs_1_02_16_3(void) {
	gl2 >>= 24;
}
void rs_1_02_16_4(void) {
	if ((gi2 = gi3)) { if (gc != 0) gs.c = gs.c / gc; if (gula[4] != 0) gul = gul / gula[4]; if (gc2 != 0) gc2 = gca[5] % gc2; } else { gps->c &= (gl != 9L ? gs.c : gc2); if (gua[5] != 0) gua[3] = gu2 % gua[5]; }
}
int rs_1_02_16_5(void) {
	return gia[1];
}
void rs_1_02_17_0(long a) {
	unsigned char t = 128;
	juc = t;
}
void rs_1_02_17_1(long a) {
	unsigned long u = gul;
	jul = u;
}
void rs_1_02_17_2(long a) {
	gc <<= 6;
}
void rs_1_02_17_3(long a) {
	unsigned char t = juc;
	t = (unsigned char)!(gca[t] ^ gc);
}
void rs_1_02_17_4(long a) {
	unsigned long u = jul;
	u += gul;
}
char rs_1_02_17_5(long a) {
	return 6;
}
void rs_1_02_18_0(unsigned long a, unsigned long b) {
	guc /= 10;
}
void rs_1_02_18_1(unsigned long a, unsigned long b) {
	switch (gs.u) { case 1: case 2: gl = -1916L ^ gl; break; case 5: case 8: *gpl = gla[7] << 3; case 16: vs(gps); break; case 1000: vs(gps); break; }
}
void rs_1_02_18_2(unsigned long a, unsigned long b) {
	gs.u += ~gps->u;
}
void rs_1_02_18_3(unsigned long a, unsigned long b) {
	vd(gd * gda[3]);
}
int * rs_1_02_18_4(unsigned long a, unsigned long b) {
	return gpi + 1;
}
void rs_1_02_19_0(char a) {
	gpi++;
}
void rs_1_02_19_1(char a) {
	vd(gd2);
}
void rs_1_02_19_2(char a) {
	gua[a] = gua[a] + gua[6];
}
int rs_1_02_19_3(char a) {
	return gi3 / 16;
}
void rs_1_03_00_0(unsigned int a, unsigned char b) {
	b++;
}
void rs_1_03_00_1(unsigned int a, unsigned char b) {
	if (gca[1] <= gps->c && gda[2] != gda[3]) { gl2 = gl = rl(gps->l) | (long)!gs.i; if (gla[6] != 0) *gpl = 65536L / gla[6]; } else { gul &= gula[1]; gu2 = (unsigned int)((gda[0] / 3.0) > (gs.d + gd)); }
}
void rs_1_03_00_2(unsigned int a, unsigned char b) {
	if (gps->a[b] != 0) *gpi = gps->a[2] % gps->a[b];
}
int rs_1_03_00_3(unsigned int a, unsigned char b) {
	return 1;
}
void rs_1_03_01_0(void) {
	int t = gi2;
	ji = t;
}
void rs_1_03_01_1(void) {
	unsigned char u = guca[4];
	juc = u;
}
void rs_1_03_01_2(void) {
	int t = ji;
	gi = t;
}
void rs_1_03_01_3(void) {
	*gpl = 7L * 10L;
}
void rs_1_03_01_4(void) {
	gs.p = rp();
}
void rs_1_03_01_5(void) {
	unsigned char u = juc;
	v0();
	guc = u;
}
void rs_1_03_01_6(void) {
	gpi--;
}
void rs_1_03_01_7(void) {
	*gpl ^= 6L + gs.l;
}
char rs_1_03_01_8(void) {
	return gc2;
}
void rs_1_03_02_1(long a, long *b) {
	int i = ji;
	int t = -gps->i;
	ji = t;
}
void rs_1_03_02_2(long a, long *b) {
	unsigned char u = 11;
	juc = u;
}
void rs_1_03_02_3(long a, long *b) {
	--gu2;
}
void rs_1_03_02_4(long a, long *b) {
	unsigned char u = juc;
	gp = &gca[u];
}
void rs_1_03_02_5(long a, long *b) {
	unsigned char u = juc;
	if (gula[u] != 0) gula[3] = gul / gula[u];
}
void rs_1_03_02_6(long a, long *b) {
	int i = ji;
	int t = ji;
	for (i = 0; i < 13; i++) { if (t != 0) gps->i = gi3 % t; }
}
unsigned int rs_1_03_02_7(long a, long *b) {
	unsigned char u = juc;
	return gs.u;
}
void rs_1_03_03_1(unsigned long a, char b, char *c) {
	int i = ji;
	i = 0; while (i < 6) { gps->l = gs.l - gl2; gua[i] = (((unsigned int)gl2) / 100) * 5; i++; }
}
void rs_1_03_03_2(unsigned long a, char b, char *c) {
	int i = ji;
	gps->i = !gps->l;
}
void rs_1_03_03_3(unsigned long a, char b, char *c) {
	v0();
}
unsigned int rs_1_03_03_4(unsigned long a, char b, char *c) {
	return (gu2 = gua[b]);
}
void rs_1_03_04_0(int *a) {
	unsigned char t = guc >> 7;
	juc = t;
}
void rs_1_03_04_1(int *a) {
	unsigned char t = juc;
	double u = (t > 6 ? gd2 : gd);
	jd = u;
}
void rs_1_03_04_2(int *a) {
	unsigned char t = juc;
	gul >>= (t & 15);
}
void rs_1_03_04_3(int *a) {
	gpi[1] = ~gi;
}
void rs_1_03_04_4(int *a) {
	double u = jd;
	gd = u;
}
char * rs_1_03_04_5(int *a) {
	return rp();
}
void rs_1_03_05_0(unsigned int a) {
	char *t = gs.p;
	jp = t;
}
void rs_1_03_05_1(unsigned int a) {
	gps->l = 3L;
}
void rs_1_03_05_2(unsigned int a) {
	gpi = rpi(gi - 127);
}
void rs_1_03_05_3(unsigned int a) {
	gul = gula[0] = gul % 7UL;
}
void rs_1_03_05_4(unsigned int a) {
	char *t = jp;
	v0();
	t[1] = gc % 4;
}
int rs_1_03_05_5(unsigned int a) {
	return -74;
}
void rs_1_03_06_0(char a, char *b) {
	int t = gps->i >> (a & 15);
	ji = t;
}
void rs_1_03_06_1(char a, char *b) {
	char u = gca[a] - *gp;
	jc = u;
}
void rs_1_03_06_2(char a, char *b) {
	int t = ji;
	t = gi2 << 13;
}
void rs_1_03_06_3(char a, char *b) {
	char u = jc;
	vc(u);
}
void rs_1_03_06_4(char a, char *b) {
	int t = ji;
	v0();
	if (gd == gs.d) { guc++; if (gs.a[t] != 0) gi2 = t / gs.a[t]; if (t != 0) gi3 = t % t; } else { gula[t] = (unsigned long)!gc; if (gps->l != 0) gl2 = gps->l / gps->l; gu = gu2; }
}
int rs_1_03_06_5(char a, char *b) {
	return (1 >= -463);
}
void rs_1_03_07_0(void) {
	if (*gpi > 8 || gs.a[7] == 8) { vd(gd + gs.d); }
}
void rs_1_03_07_1(void) {
	gpi = rpi(r0());
}
void rs_1_03_07_2(void) {
	switch (gl2) { case 2L: v2(gi2, gia[0]); break; case 3L: v2(gi3, gi); break; case 5L: gd2 += gd; break; case 8L: v0(); break; case 1000L: gula[3] *= 11UL; break; }
}
void rs_1_03_07_3(void) {
	guca[3] = (unsigned char)gu2;
}
int rs_1_03_07_4(void) {
	return (gi2 - (int)gs.u) % 100;
}
void rs_1_03_08_0(void) {
	char *t = gp;
	jp = t;
}
void rs_1_03_08_1(void) {
	int u = gpi[0] % 100;
	ji = u;
}
void rs_1_03_08_2(void) {
	int u = ji;
	gu2 = (unsigned int)!(*gp > gca[u] ? gc2 : '0');
}
void rs_1_03_08_3(void) {
	char *t = jp;
	gp = t;
}
void rs_1_03_08_4(void) {
	int u = ji;
	--u;
}
long rs_1_03_08_5(void) {
	int u = ji;
	return (gul == 19991UL ? gla[u] : gl2) + ((long)(gi == u));
}
void rs_1_03_09_0(double a) {
	int *t = gpi;
	jpi = t;
}
void rs_1_03_09_1(double a) {
	int *t = jpi;
	gpi = t;
}
void rs_1_03_09_2(double a) {
	gla[2] /= 3L;
}
void rs_1_03_09_3(double a) {
	guc = guca[5];
}
int rs_1_03_09_4(double a) {
	return !gca[5];
}
void rs_1_03_10_0(int a, char b) {
	if (gi2) if (gua[7] != 0) gua[a] = gu % gua[7];
}
void rs_1_03_10_1(int a, char b) {
	gul = (unsigned long)(rl(gla[a]) != (*gpl & 3L));
}
void rs_1_03_10_2(int a, char b) {
	switch (a) { case 2: gps->i = gps->a[3] = a; break; case 3: gu2 *= 12; break; case 20: guca[3] = guca[b] % 10; break; case 100: gul = (guca[a] & 2 ? 15749UL : 9UL); case 1000: *gpl %= 7L; }
}
long rs_1_03_10_3(int a, char b) {
	return (gul & 0x80 ? -gla[b] : (256 < 1 ? 65536L : (long)gul));
}
void rs_1_03_11_0(unsigned char a) {
	double t = gs.d;
	jd = t;
}
void rs_1_03_11_1(unsigned char a) {
	gul = (((unsigned long)*gpl) / 4UL) | (gula[1] + 3UL);
}
void rs_1_03_11_2(unsigned char a) {
	gula[a] = 24395UL & gul;
}
void rs_1_03_11_3(unsigned char a) {
	double t = jd;
	gul = (unsigned long)((double)gps->a[a] >= (t / 10.0));
}
void rs_1_03_11_4(unsigned char a) {
	v2(gi2, gs.a[0]);
}
unsigned long rs_1_03_11_5(unsigned char a) {
	return ~gula[4];
}
void rs_1_03_12_0(int a, unsigned char b) {
	char *t = gp;
	jp = t;
}
void rs_1_03_12_1(int a, unsigned char b) {
	gda[1] *= gs.d / 3.0;
}
void rs_1_03_12_2(int a, unsigned char b) {
	char *t = jp;
	*t = gca[3] & gc;
}
void rs_1_03_12_3(int a, unsigned char b) {
	vd(gs.d);
}
void rs_1_03_12_4(int a, unsigned char b) {
	if (52254L < -21903L) gi3 = (127 << 12) + r0();
}
int * rs_1_03_12_5(int a, unsigned char b) {
	return gpi + b;
}
void rs_1_03_13_0(void) {
	int t = r0();
	ji = t;
}
void rs_1_03_13_1(void) {
	int t = ji;
	v0();
	gu = gua[t] + ((unsigned int)293);
}
void rs_1_03_13_2(void) {
	gu = gu2;
}
long rs_1_03_13_3(void) {
	int t = ji;
	v0();
	return (gla[t] = gl);
}
void rs_1_03_14_0(void) {
	if (gca[7] != 0) gps->c = gps->c / gca[7];
}
void rs_1_03_14_1(void) {
	vd(gd2 / 3.0);
}
void rs_1_03_14_2(void) {
	gc++;
}
char * rs_1_03_14_3(void) {
	return gps->p;
}
void rs_1_03_15_0(unsigned int a, unsigned long b, unsigned long c) {
	gpi = rpi(gps->i);
}
void rs_1_03_15_1(unsigned int a, unsigned long b, unsigned long c) {
	gps->p = gp;
}
void rs_1_03_15_2(unsigned int a, unsigned long b, unsigned long c) {
	gu = 1 / 100;
}
void rs_1_03_15_3(unsigned int a, unsigned long b, unsigned long c) {
	--gpi;
}
unsigned int rs_1_03_15_4(unsigned int a, unsigned long b, unsigned long c) {
	return (unsigned int)((unsigned char)!0);
}
void rs_1_03_16_0(int a) {
	char t = gca[7] - gps->c;
	jc = t;
}
void rs_1_03_16_1(int a) {
	a = (int)guc;
}
void rs_1_03_16_2(int a) {
	*gp = rc(gpi[0]);
}
void rs_1_03_16_3(int a) {
	v2(gi2, (gu ? gs.a[a] : a));
}
void rs_1_03_16_4(int a) {
	char t = jc;
	v0();
	gula[t] = gul = ((gi = gps->i) ? ((unsigned long)gua[a]) : (gul + gula[t]));
}
unsigned long rs_1_03_16_5(int a) {
	return gula[a];
}
void rs_1_03_17_0(void) {
	gul = gula[5];
}
void rs_1_03_17_1(void) {
	while (gi > 0) { gc2 += *gp++; gi--; }
}
unsigned long rs_1_03_17_2(void) {
	return gul;
}
void rs_1_03_18_0(char a) {
	gu = -((unsigned int)gi2);
}
void rs_1_03_18_1(char a) {
	gi2 <<= (a & 15);
}
void rs_1_03_18_2(char a) {
	guc <<= (a & 7);
}
unsigned int rs_1_03_18_3(char a) {
	return ((unsigned int)(100.0 == gd)) / 3;
}
void rs_1_03_19_0(struct st *a, unsigned char b, long c) {
	c >>= 24;
}
void rs_1_03_19_1(struct st *a, unsigned char b, long c) {
	if ((gi2 = a->a[b]) != 1) { gul &= 0UL + gula[7]; gla[5] &= (long)(gu2 <= 256); gi <<= 5; }
}
void rs_1_03_19_2(struct st *a, unsigned char b, long c) {
	gc |= ~'A';
}
unsigned int rs_1_03_19_3(struct st *a, unsigned char b, long c) {
	return (unsigned int)(gc & gca[b]);
}
void rs_1_04_00_1(int a) {
	gul %= 7UL;
}
void rs_1_04_00_2(int a) {
	int i = ji;
	i = 0; while (i < 16) { gul--; gua[i] = 255; --gl; i++; }
}
void rs_1_04_00_3(int a) {
	v2(!gs.l, gi);
}
void rs_1_04_00_4(int a) {
	gul = gula[a];
}
unsigned long rs_1_04_00_5(int a) {
	return gula[6] << 13;
}
void rs_1_04_01_0(char a) {
	gula[a] = ((unsigned long)gua[4]) ^ gul;
}
void rs_1_04_01_1(char a) {
	--gc2;
}
void rs_1_04_01_2(char a) {
	vu(~gua[a]);
}
unsigned long rs_1_04_01_3(char a) {
	return gula[a] + rul(gul);
}
void rs_1_04_02_0(char a, long b) {
	int *t = gpi;
	jpi = t;
}
void rs_1_04_02_1(char a, long b) {
	v0();
}
void rs_1_04_02_2(char a, long b) {
	vp(gs.p + a);
}
void rs_1_04_02_3(char a, long b) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_1_04_02_4(char a, long b) {
	gul |= 0x10000UL | gula[4];
}
unsigned int rs_1_04_02_5(char a, long b) {
	return (unsigned int)gul;
}
void rs_1_04_03_0(struct st *a, int b, int c) {
	int t = c / 7;
	ji = t;
}
void rs_1_04_03_1(struct st *a, int b, int c) {
	int t = ji;
	guc |= guca[t] ^ 229;
}
void rs_1_04_03_2(struct st *a, int b, int c) {
	guc = ((a->l = gps->l) ? 29 : guca[5]) ^ ((unsigned char)gua[6]);
}
void rs_1_04_03_3(struct st *a, int b, int c) {
	gula[c] = ((unsigned long)guc) % 3UL;
}
void rs_1_04_03_4(struct st *a, int b, int c) {
	gl--;
}
unsigned long rs_1_04_03_5(struct st *a, int b, int c) {
	int t = ji;
	return (gul + 0x10000UL) | rul(gula[t]);
}
void rs_1_04_04_0(char *a, char b) {
	unsigned int t = gua[0] << (b & 15);
	ju = t;
}
void rs_1_04_04_1(char *a, char b) {
	unsigned long u = gul;
	jul = u;
}
void rs_1_04_04_2(char *a, char b) {
	unsigned int t = ju;
	gi3 <<= (t & 15);
}
void rs_1_04_04_3(char *a, char b) {
	vs(gps);
}
void rs_1_04_04_4(char *a, char b) {
	unsigned int t = ju;
	v0();
	switch (gc) { case 0: vp(gp + t); break; case 1: *gp = gc2 | gca[5]; break; case 2: case 3: t = gua[b] + 1; break; case 4: vp(gp); break; case 5: v2(gi2, (int)gula[2]); break; default: gi2 = gi = gs.a[5] - gpi[1]; break; }
}
void rs_1_04_04_5(char *a, char b) {
	unsigned long u = jul;
	v0();
	vl((long)u);
}
char rs_1_04_04_6(char *a, char b) {
	unsigned int t = ju;
	v0();
	return (char)!(t * gu);
}
void rs_1_04_05_0(int a, int *b, char c) {
	unsigned int t = gua[c] & 32767;
	ju = t;
}
void rs_1_04_05_1(int a, int *b, char c) {
	v0();
}
void rs_1_04_05_2(int a, int *b, char c) {
	guc = (guca[a] | 128) % 2;
}
void rs_1_04_05_3(int a, int *b, char c) {
	gd2 = (3.0 / 0.25) / 0.25;
}
void rs_1_04_05_4(int a, int *b, char c) {
	unsigned int t = ju;
	v0();
	vu(t);
}
unsigned int rs_1_04_05_5(int a, int *b, char c) {
	unsigned int t = ju;
	v0();
	return (t = 255);
}
void rs_1_04_06_1(void) {
	if ((gi2 = 256) > 255) { if (gul != 0) gul = gul % gul; vd(gd * gda[3]); } else { gul %= 10UL; }
}
void rs_1_04_06_2(void) {
	gul *= 4UL;
}
void rs_1_04_06_3(void) {
	int i = ji;
	v0();
	i = 11; do { gl = gla[i]; } while (--i > 0);
}
void rs_1_04_06_4(void) {
	gpi = rpi(-2);
}
char rs_1_04_06_5(void) {
	return 7;
}
void rs_1_04_07_0(int a, char b, int *c) {
	unsigned char t = (gul <= 0x10000UL ? guca[b] : 8);
	juc = t;
}
void rs_1_04_07_1(int a, char b, int *c) {
	unsigned char t = juc;
	unsigned char u = guca[t] - t;
	juc = u;
}
void rs_1_04_07_2(int a, char b, int *c) {
	vp(rp());
}
void rs_1_04_07_3(int a, char b, int *c) {
	if (gd <= gs.d) { gd2 += 0.25 - 10.0; } else { gpi[2] = *c = (a != gi3) >> (a & 15); }
}
void rs_1_04_07_4(int a, char b, int *c) {
	unsigned char t = juc;
	v0();
	guc = t;
}
void rs_1_04_07_5(int a, char b, int *c) {
	gc /= 16;
}
void rs_1_04_07_6(int a, char b, int *c) {
	vc(-gc);
}
void rs_1_04_07_7(int a, char b, int *c) {
	unsigned char u = juc;
	v0();
	gl2 = gps->l = (long)gia[u] | rl(gs.l);
}
char * rs_1_04_07_8(int a, char b, int *c) {
	return gs.p;
}
void rs_1_04_08_1(char a, struct st *b, unsigned char c) {
	unsigned char t = c;
	juc = t;
}
void rs_1_04_08_2(char a, struct st *b, unsigned char c) {
	long u = rl(gla[a]);
	jl = u;
}
void rs_1_04_08_3(char a, struct st *b, unsigned char c) {
	int i = ji;
	v0();
	i = 0; while (i < 12) { if (gula[i] != 0) gul = gul / gula[i]; gi3 = r0(); if (gca[3] != 0) gp[1] = gps->c / gca[3]; i++; }
}
void rs_1_04_08_4(char a, struct st *b, unsigned char c) {
	gp = gps->p + c;
}
void rs_1_04_08_5(char a, struct st *b, unsigned char c) {
	unsigned char t = juc;
	long u = jl;
	v0();
	switch (gps->u) { case 0: u = *gpl * 6L; break; case 1: *gp = (char)(t == c); break; case 2: case 3: case 4: gp = gps->p; break; default: vp(b->p); break; }
}
void rs_1_04_08_6(char a, struct st *b, unsigned char c) {
	vd(gd / 100.0);
}
void rs_1_04_08_7(char a, struct st *b, unsigned char c) {
	gd += gda[2] + gd2;
}
unsigned int rs_1_04_08_8(char a, struct st *b, unsigned char c) {
	return -(gua[a] - gu);
}
void rs_1_04_09_0(void) {
	guc >>= 3;
}
void rs_1_04_09_1(void) {
	gl = (long)gul;
}
void rs_1_04_09_2(void) {
	gc = 'z';
}
void rs_1_04_09_3(void) {
	gi = (int)rc(2);
}
void rs_1_04_09_4(void) {
	v2(gi2, gi3 >> 2);
}
int * rs_1_04_09_5(void) {
	return gpi;
}
void rs_1_04_10_0(char a) {
	unsigned char t = guca[7];
	juc = t;
}
void rs_1_04_10_1(char a) {
	unsigned int u = 255 | gua[a];
	ju = u;
}
void rs_1_04_10_2(char a) {
	unsigned int u = ju;
	if (r1(16)) { gps->u = (gu - ((unsigned int)gl2)) << 14; gps->c = ~gc; }
}
void rs_1_04_10_3(char a) {
	++gp;
}
void rs_1_04_10_4(char a) {
	++gpi;
}
void rs_1_04_10_5(char a) {
	gs.d = gs.d - gd2;
}
void rs_1_04_10_6(char a) {
	unsigned int u = ju;
	v0();
	v1(gi - gs.a[u]);
}
void rs_1_04_10_7(char a) {
	unsigned char t = juc;
	v0();
	guc = t;
}
long rs_1_04_10_8(char a) {
	return gpl[2];
}
void rs_1_04_11_0(int a) {
	int t = ~16;
	ji = t;
}
void rs_1_04_11_1(int a) {
	int u = a << 8;
	ji = u;
}
void rs_1_04_11_2(int a) {
	int t = ji;
	gula[t] *= 6UL;
}
void rs_1_04_11_3(int a) {
	int u = ji;
	v1(u);
}
void rs_1_04_11_4(int a) {
	gu2 <<= 14;
}
char rs_1_04_11_5(int a) {
	return 'A';
}
void rs_1_04_12_0(long *a, long b, long *c) {
	unsigned long t = gula[5];
	jul = t;
}
void rs_1_04_12_1(long *a, long b, long *c) {
	gp = gs.p;
}
void rs_1_04_12_2(long *a, long b, long *c) {
	guc++;
}
void rs_1_04_12_3(long *a, long b, long *c) {
	guc -= 128;
}
void rs_1_04_12_4(long *a, long b, long *c) {
	*gp = (char)(guc != 1);
}
void rs_1_04_12_5(long *a, long b, long *c) {
	unsigned long t = jul;
	vl((long)t);
}
int rs_1_04_12_6(long *a, long b, long *c) {
	return (gi | gi3) / 10;
}
void rs_1_04_13_0(char a, int b, int c) {
	gd += gda[2] / 3.0;
}
void rs_1_04_13_1(char a, int b, int c) {
	gl |= gps->l;
}
void rs_1_04_13_2(char a, int b, int c) {
	gi3 %= 10;
}
void rs_1_04_13_3(char a, int b, int c) {
	guca[b] = guc ^ guca[c];
}
void rs_1_04_13_4(char a, int b, int c) {
	if (gula[c] != 0) gul = gul / gula[c];
}
int * rs_1_04_13_5(char a, int b, int c) {
	return rpi(gpi[1] / 3);
}
void rs_1_04_14_0(int a) {
	int t = *gpi % 3;
	ji = t;
}
void rs_1_04_14_1(int a) {
	v2(!gu2, gi);
}
void rs_1_04_14_2(int a) {
	gpi = gpi + a;
}
void rs_1_04_14_3(int a) {
	gps->l = gps->l + gla[1];
}
void rs_1_04_14_4(int a) {
	int t = ji;
	v0();
	if (gua[t] != 0) gu2 = 1 % gua[t];
}
void rs_1_04_15_0(struct st *a, long b, int c) {
	int *t = gpi + c;
	jpi = t;
}
void rs_1_04_15_1(struct st *a, long b, int c) {
	gula[c] <<= 23;
}
void rs_1_04_15_2(struct st *a, long b, int c) {
	int *t = jpi;
	gpi = t;
}
void rs_1_04_15_3(struct st *a, long b, int c) {
	if (gul != 0) gula[c] = gula[1] % gul;
}
void rs_1_04_15_4(struct st *a, long b, int c) {
	vp(gp + c);
}
int rs_1_04_15_5(struct st *a, long b, int c) {
	return ~(gi2 >> 9);
}
void rs_1_04_16_0(int a, double b, unsigned char c) {
	unsigned int t = ((unsigned int)gi) - gps->u;
	ju = t;
}
char rs_1_04_16_1(int a, double b, unsigned char c) {
	if (gua[c] >= gu) return gca[6] ^ *gp;
}
void rs_1_04_16_2(int a, double b, unsigned char c) {
	gua[5] = gu2 = gu2 / 100;
}
void rs_1_04_16_3(int a, double b, unsigned char c) {
	gc = rc(255 ^ gpi[2]);
}
void rs_1_04_16_4(int a, double b, unsigned char c) {
	unsigned int t = ju;
	v0();
	gu = t;
}
char rs_1_04_16_5(int a, double b, unsigned char c) {
	return gs.c;
}
void rs_1_04_17_0(unsigned int a, char b, unsigned int c) {
	double t = gs.d / 100.0;
	jd = t;
}
void rs_1_04_17_1(unsigned int a, char b, unsigned int c) {
	gi2 |= 0 * 1;
}
void rs_1_04_17_2(unsigned int a, char b, unsigned int c) {
	while (gi-- > 0) *gpi++ = 256;
}
void rs_1_04_17_3(unsigned int a, char b, unsigned int c) {
	double t = jd;
	vd(t);
}
void rs_1_04_17_4(unsigned int a, char b, unsigned int c) {
	gul = -gul;
}
void rs_1_04_17_5(unsigned int a, char b, unsigned int c) {
	if (r0()) *gpl = gl2;
}
void rs_1_04_17_6(unsigned int a, char b, unsigned int c) {
	if (gi != 0) gi2 = gs.i / gi;
}
unsigned long rs_1_04_17_7(unsigned int a, char b, unsigned int c) {
	return ~gul;
}
void rs_1_04_18_1(void) {
	unsigned int t = ru(gu2);
	ju = t;
}
void rs_1_04_18_2(void) {
	char *u = gp;
	v0();
	jp = u;
}
void rs_1_04_18_3(void) {
	unsigned int t = ju;
	v0();
	gla[t] = (long)gi2;
}
void rs_1_04_18_4(void) {
	gl = -(long)gi3 - (long)!32767;
}
void rs_1_04_18_5(void) {
	char *u = jp;
	v0();
	u[0] /= 10;
}
void rs_1_04_18_6(void) {
	int i = ji;
	v0();
	i = 11; do { v1(-100); if (gul != 0) gul = 88499UL / gul; guca[i] = (gu >= gua[7] ? guc : guc); } while (--i > 0);
}
char * rs_1_04_18_7(void) {
	return gp;
}
void rs_1_04_19_0(struct st *a, char b) {
	double t = gd;
	jd = t;
}
void rs_1_04_19_1(struct st *a, char b) {
	char *u = gp + b;
	jp = u;
}
void rs_1_04_19_2(struct st *a, char b) {
	gp++;
}
void rs_1_04_19_3(struct st *a, char b) {
	char *u = jp;
	vu(a->u);
}
void rs_1_04_19_4(struct st *a, char b) {
	gula[b] = (unsigned long)gps->l;
}
void rs_1_04_19_5(struct st *a, char b) {
	v0();
}
void rs_1_04_19_6(struct st *a, char b) {
	double t = jd;
	v0();
	gd = t;
}
void rs_1_04_19_7(struct st *a, char b) {
	vs(a);
}
char * rs_1_04_19_8(struct st *a, char b) {
	char *u = jp;
	v0();
	return u;
}
void rs_1_05_00_0(int a, unsigned long b, unsigned int c) {
	long t = rl((long)gia[2]);
	jl = t;
}
void rs_1_05_00_1(int a, unsigned long b, unsigned int c) {
	int *u = gpi;
	v0();
	jpi = u;
}
void rs_1_05_00_2(int a, unsigned long b, unsigned int c) {
	gul %= 7UL;
}
void rs_1_05_00_3(int a, unsigned long b, unsigned int c) {
	guc /= 2;
}
void rs_1_05_00_4(int a, unsigned long b, unsigned int c) {
	long t = jl;
	v0();
	gl = t;
}
void rs_1_05_00_5(int a, unsigned long b, unsigned int c) {
	int *u = jpi;
	v0();
	gpi = u;
}
int rs_1_05_00_6(int a, unsigned long b, unsigned int c) {
	return (gca[a] == (70 | 45));
}
void rs_1_05_01_0(unsigned char a, int b, unsigned int c) {
	double t = (a ? gda[3] : gd2);
	jd = t;
}
void rs_1_05_01_1(unsigned char a, int b, unsigned int c) {
	*gp *= 2;
}
void rs_1_05_01_2(unsigned char a, int b, unsigned int c) {
	if (b < 100 && gia[6] == 100) gl = ~(gl2 + (long)gs.c);
}
void rs_1_05_01_3(unsigned char a, int b, unsigned int c) {
	double t = jd;
	gd = t;
}
void rs_1_05_01_4(unsigned char a, int b, unsigned int c) {
	gul &= ((unsigned long)gl2) & gul;
}
int rs_1_05_01_5(unsigned char a, int b, unsigned int c) {
	return (a > 255 ? gi3 : b) * 2;
}
void rs_1_05_02_0(int a) {
	gc = (char)(256 >= (gu >> (a & 15)));
}
void rs_1_05_02_1(int a) {
	guca[7] = (255 % 7) << 6;
}
void rs_1_05_02_2(int a) {
	gia[a] = r2(gi2, (int)gl2);
}
void rs_1_05_03_1(void) {
	int i = ji;
	i = 0; while (i < 5) { if (gc != 0) gp[3] = gp[2] / gc; if (gl != 0) gl2 = gl2 % gl; i++; }
}
void rs_1_05_03_2(void) {
	*gpi %= 10;
}
void rs_1_05_03_3(void) {
	int i = ji;
	gs.i = (int)gu << 8;
}
void rs_1_05_03_4(void) {
	gc = gc2 = rc(gi2 + gs.a[1]);
}
void rs_1_05_03_5(void) {
	int i = ji;
	v0();
	for (i = 3; i > 0; i--) { vd(100.0); vs(gps); }
}
char * rs_1_05_03_6(void) {
	return gs.p;
}
void rs_1_05_04_0(void) {
	v0();
}
void rs_1_05_04_1(void) {
	guc = (unsigned char)(gula[2] < ((unsigned long)(gs.a[7] > 256)));
}
void rs_1_05_04_2(void) {
	gi3 ^= gi2;
}
void rs_1_05_04_3(void) {
	gs.p = &gca[0];
}
void rs_1_05_04_4(void) {
	if (gl2 & 4) if (gc2 != 0) gca[2] = 0 % gc2;
}
int * rs_1_05_04_5(void) {
	return gpi;
}
void rs_1_05_05_0(struct st *a) {
	char t = gp[2];
	jc = t;
}
void rs_1_05_05_1(struct st *a) {
	gi2 = 148 - gi2;
}
void rs_1_05_05_2(struct st *a) {
	char t = jc;
	if (gula[4] > gul) { gps->l = 94899L; } else { vc(t); }
}
void rs_1_05_05_3(struct st *a) {
	char t = jc;
	v0();
	gula[0] = (gla[t] <= gl2 ? gul : (gula[6] / 2UL));
}
void rs_1_05_05_4(struct st *a) {
	gs.d *= gd * (double)gi2;
}
unsigned long rs_1_05_05_5(struct st *a) {
	return (unsigned long)((gd * gs.d) != (gda[0] * gs.d));
}
void rs_1_05_06_0(unsigned char a) {
	gul = gula[a] = 0UL;
}
void rs_1_05_06_1(unsigned char a) {
	gc2 = (char)gps->l & gp[3];
}
void rs_1_05_06_2(unsigned char a) {
	if (*gp) { gu2 = (gu & 255) | gua[a]; gda[0] += (double)gi3; if (gs.l != 0) *gpl = gl % gs.l; }
}
char rs_1_05_06_3(unsigned char a) {
	return -31;
}
void rs_1_05_07_0(int a, char b, long *c) {
	char *t = gp;
	jp = t;
}
void rs_1_05_07_1(int a, char b, long *c) {
	int u = gia[a] & gs.a[a];
	ji = u;
}
char * rs_1_05_07_2(int a, char b, long *c) {
	char *t = jp;
	int u = ji;
	if (gi2 > u) return t + b;
}
void rs_1_05_07_3(int a, char b, long *c) {
	if (gul != 0) gul = gul / gul;
}
char * rs_1_05_07_4(int a, char b, long *c) {
	return gs.p;
}
void rs_1_05_08_1(void) {
	int t = (2 == 255);
	ji = t;
}
void rs_1_05_08_2(void) {
	int i = ji;
	gi3 = ((int)gc2 & gi2) + r1(gps->i);
}
void rs_1_05_08_3(void) {
	int t = ji;
	v0();
	gs.c &= (char)(guca[t] == 5);
}
void rs_1_05_08_4(void) {
	int i = ji;
	v0();
	for (i = 0; i < 4; i++) { if (gula[i] != 0) gula[i] = gula[i] / gula[i]; if (gpl[2] != 0) gl2 = 65536L / gpl[2]; if (gc2 != 0) gc = *gp / gc2; }
}
void rs_1_05_08_5(void) {
	*gp = gc2;
}
void rs_1_05_08_6(void) {
	guc++;
}
int rs_1_05_08_7(void) {
	return (gi3 = 1);
}
void rs_1_05_09_0(unsigned long a, unsigned long b) {
	double t = -100.0;
	jd = t;
}
void rs_1_05_09_1(unsigned long a, unsigned long b) {
	double t = jd;
	gd = t;
}
void rs_1_05_09_2(unsigned long a, unsigned long b) {
	if (gps->u != 0) gu2 = gu / gps->u;
}
void rs_1_05_09_3(unsigned long a, unsigned long b) {
	if (gc2 != 0) gca[2] = gs.c % gc2;
}
void rs_1_05_09_4(unsigned long a, unsigned long b) {
	gula[3] = rul(gul);
}
int rs_1_05_09_5(unsigned long a, unsigned long b) {
	return (gul <= (gul | 21158UL));
}
void rs_1_05_10_0(void) {
	v0();
}
void rs_1_05_10_1(void) {
	gula[5] = 88009UL;
}
long rs_1_05_10_2(void) {
	return (long)((gl2 + 65536L) >= (gl2 ^ gs.l));
}
void rs_1_05_11_1(long a) {
	unsigned long t = gula[2];
	jul = t;
}
void rs_1_05_11_2(long a) {
	int i = ji;
	int u = gps->i * 11;
	ji = u;
}
void rs_1_05_11_3(long a) {
	int u = ji;
	gua[6] = ru(gua[u]);
}
void rs_1_05_11_4(long a) {
	int i = ji;
	v0();
	for (i = 0; i < 5; i++) { if (a != 0) gl2 = gl2 / a; }
}
void rs_1_05_11_5(long a) {
	unsigned long t = jul;
	v0();
	if (guca[6] & 1) { guc = ~(guc & 0); if (t != 0) gula[7] = 0x10000UL / t; gps->l = gl2; }
}
int rs_1_05_11_6(long a) {
	return r2(gi2, gia[5]);
}
void rs_1_05_12_0(double a) {
	char t = (char)gua[6];
	jc = t;
}
void rs_1_05_12_1(double a) {
	char t = jc;
	switch (gs.l) { case 1L: gula[t] = gula[5]; break; case 1000L: vd(gs.d); break; default: gs.i = gi = r2(gps->i, gi); break; }
}
void rs_1_05_12_2(double a) {
	char t = jc;
	v0();
	gul = (gula[4] >> (t & 15)) << (t & 15);
}
void rs_1_05_12_3(double a) {
	gi3 = 100;
}
void rs_1_05_12_4(double a) {
	--gul;
}
void rs_1_05_12_5(double a) {
	gi3 = gs.a[6];
}
int rs_1_05_12_6(double a) {
	char t = jc;
	v0();
	return gi - (gi3 - gs.a[t]);
}
void rs_1_05_13_0(unsigned char a, unsigned int b) {
	gd2 += 1.0;
}
void rs_1_05_13_1(unsigned char a, unsigned int b) {
	gps->u = gu = gu2;
}
long rs_1_05_13_2(unsigned char a, unsigned int b) {
	return gpl[3] ^ (gla[a] | -54089L);
}
void rs_1_05_14_0(void) {
	char t = gs.c + gc2;
	jc = t;
}
void rs_1_05_14_1(void) {
	int u = gi3 >> 12;
	ji = u;
}
void rs_1_05_14_2(void) {
	int u = ji;
	u = 2;
}
void rs_1_05_14_3(void) {
	++gl2;
}
void rs_1_05_14_4(void) {
	char t = jc;
	if (gl2) { gpi = gpi + t; } else { if (gs.a[t] != 0) gps->a[3] = 1 % gs.a[t]; }
}
int rs_1_05_14_5(void) {
	int u = ji;
	return ~(u + 8);
}
void rs_1_05_15_0(void) {
	int *t = rpi(gps->i);
	jpi = t;
}
void rs_1_05_15_1(void) {
	long u = gps->l;
	v0();
	jl = u;
}
void rs_1_05_15_2(void) {
	int *t = jpi;
	v0();
	if (r2(t[3], gi)) { gp++; gu2 -= 1; if (gi2 != 0) gs.i = t[2] / gi2; }
}
void rs_1_05_15_3(void) {
	long u = jl;
	v0();
	u = (gl | gl2) - (gl2 * 2L);
}
void rs_1_05_15_4(void) {
	*gp = gp[1] >> 7;
}
void rs_1_05_15_5(void) {
	if (gul != 0) gula[0] = gula[2] / gul;
}
void rs_1_05_15_6(void) {
	gi += gi3 % 100;
}
int rs_1_05_15_7(void) {
	return 127;
}
void rs_1_05_16_1(unsigned int a, unsigned int b, long *c) {
	char t = -67 ^ gc2;
	jc = t;
}
void rs_1_05_16_2(unsigned int a, unsigned int b, long *c) {
	unsigned long u = 4UL;
	jul = u;
}
void rs_1_05_16_3(unsigned int a, unsigned int b, long *c) {
	unsigned long u = jul;
	gul = u;
}
void rs_1_05_16_4(unsigned int a, unsigned int b, long *c) {
	gula[a] |= 0x10000UL << 7;
}
void rs_1_05_16_5(unsigned int a, unsigned int b, long *c) {
	int i = ji;
	i = 0; while (i < 13) { gpi = rpi(r1(gpi[3])); gua[i] = ((unsigned int)(5L < 65536L)) - gua[i]; i++; }
}
void rs_1_05_16_6(unsigned int a, unsigned int b, long *c) {
	a = gu2;
}
void rs_1_05_16_7(unsigned int a, unsigned int b, long *c) {
	char t = jc;
	v0();
	vc(t);
}
long rs_1_05_16_8(unsigned int a, unsigned int b, long *c) {
	return gpl[2];
}
void rs_1_05_17_0(void) {
	int *t = gpi + 1;
	jpi = t;
}
void rs_1_05_17_1(void) {
	gc2++;
}
void rs_1_05_17_2(void) {
	if (gps->c != 0) gca[7] = gp[1] % gps->c;
}
void rs_1_05_17_3(void) {
	int *t = jpi;
	gpi = t;
}
void rs_1_05_17_4(void) {
	gl2 = rl(gl) << 24;
}
void rs_1_05_17_5(void) {
	gl = (long)gul;
}
void rs_1_05_17_6(void) {
	gua[6] &= (unsigned int)gc2;
}
int * rs_1_05_17_7(void) {
	int *t = jpi;
	v0();
	return t + 1;
}
void rs_1_05_18_0(struct st *a) {
	*gpl = gl2;
}
void rs_1_05_18_1(struct st *a) {
	guc = ~(0 % 3);
}
void rs_1_05_18_2(struct st *a) {
	v2(gi >> 7, gi);
}
void rs_1_05_18_3(struct st *a) {
	*gp = gc2 >> 4;
}
unsigned int rs_1_05_18_4(struct st *a) {
	return (unsigned int)((128 - guc) != (guca[7] - guc));
}
void rs_1_05_19_0(int a) {
	unsigned char t = guc + 255;
	juc = t;
}
unsigned int rs_1_05_19_1(int a) {
	if (gps->c > gc2) return gu2;
}
void rs_1_05_19_2(int a) {
	gp = gps->p;
}
void rs_1_05_19_3(int a) {
	gl2 = rl(*gpl + gpl[1]);
}
void rs_1_05_19_4(int a) {
	v0();
}
void rs_1_05_19_5(int a) {
	unsigned char t = juc;
	v0();
	guc = t;
}
unsigned int rs_1_05_19_6(int a) {
	return gu;
}
void rs_1_06_00_0(unsigned long a, long b, int c) {
	double t = gd2;
	jd = t;
}
void rs_1_06_00_1(unsigned long a, long b, int c) {
	unsigned char u = (gc != 0 ? 230 : guca[c]);
	juc = u;
}
void rs_1_06_00_2(unsigned long a, long b, int c) {
	switch (gu) { case 0: case 1: vl(gps->l); }
}
void rs_1_06_00_3(unsigned long a, long b, int c) {
	unsigned char u = juc;
	v0();
	u = (guca[1] << 6) << 2;
}
void rs_1_06_00_4(unsigned long a, long b, int c) {
	guc = 128 + (guc / 2);
}
void rs_1_06_00_5(unsigned long a, long b, int c) {
	double t = jd;
	v0();
	vd(t);
}
int rs_1_06_00_6(unsigned long a, long b, int c) {
	return r1(gia[3]);
}
void rs_1_06_01_0(unsigned char a, int b) {
	int *t = gpi + b;
	jpi = t;
}
void rs_1_06_01_1(unsigned char a, int b) {
	int *t = jpi;
	gpi = t;
}
void rs_1_06_01_2(unsigned char a, int b) {
	a = guca[a] ^ (a + 8);
}
void rs_1_06_01_3(unsigned char a, int b) {
	gula[b] += gul;
}
void rs_1_06_01_4(unsigned char a, int b) {
	gia[2] = r1(!gps->c);
}
void rs_1_06_02_0(long a) {
	long t = gps->l + gla[2];
	jl = t;
}
void rs_1_06_02_1(long a) {
	unsigned long u = gula[1] % 3UL;
	jul = u;
}
void rs_1_06_02_2(long a) {
	long t = jl;
	gl = t;
}
void rs_1_06_02_3(long a) {
	guc += 255;
}
void rs_1_06_02_4(long a) {
	gs.d *= 10.0;
}
void rs_1_06_02_5(long a) {
	unsigned long u = jul;
	gul = u;
}
void rs_1_06_02_6(long a) {
	a = gl2 = gl;
}
unsigned int rs_1_06_02_7(long a) {
	return 4;
}
void rs_1_06_03_1(struct st *a, unsigned char b) {
	int i = ji;
	i = 13; do { gca[i] >>= (i & 7); gc2 = (gp[2] + a->c) | (char)!b; gca[1] = rc(i) / 7; } while (--i > 0);
}
void rs_1_06_03_2(struct st *a, unsigned char b) {
	v0();
}
int * rs_1_06_03_3(struct st *a, unsigned char b) {
	return gpi;
}
void rs_1_06_04_1(int a, char *b, double c) {
	guca[a] = guc << 5;
}
void rs_1_06_04_2(int a, char *b, double c) {
	if (gula[3] != 0) gul = gul % gula[3];
}
void rs_1_06_04_3(int a, char *b, double c) {
	int i = ji;
	for (i = 0; i < a; i++) { gd = (gs.u ? gd2 : c) / 1.0; gpl[3] += gl2; }
}
void rs_1_06_04_4(int a, char *b, double c) {
	gi = -(gi2 + (int)gua[a]);
}
void rs_1_06_04_5(int a, char *b, double c) {
	guca[2] = (unsigned char)(gia[0] <= gps->a[5]);
}
int rs_1_06_04_6(int a, char *b, double c) {
	return (gi3 = 256);
}
void rs_1_06_05_1(int a, unsigned int b) {
	int *t = &gia[2];
	jpi = t;
}
void rs_1_06_05_2(int a, unsigned int b) {
	switch (gs.c) { case 0: case 1: gl = gl2; break; }
}
void rs_1_06_05_3(int a, unsigned int b) {
	int i = ji;
	for (i = 0; i < a; i++) { if (gi2 != 0) gia[i] = i / gi2; guca[i] /= 10; gi = gi2 = ((5L * -89060L) == rl(gla[b])); }
}
int rs_1_06_05_4(int a, unsigned int b) {
	int i = ji;
	v0();
	if (5L <= gl2) return gps->i;
}
void rs_1_06_05_5(int a, unsigned int b) {
	int *t = jpi;
	v0();
	gpi = t;
}
int rs_1_06_05_6(int a, unsigned int b) {
	return (b == ((unsigned int)gl) ? r2(gi2, gi2) : a);
}
void rs_1_06_06_0(unsigned char a) {
	int *t = gpi;
	jpi = t;
}
void rs_1_06_06_1(unsigned char a) {
	if (r2(gs.a[a], gi)) { gc |= gca[a] - 5; } else { if (gpi[0] != 0) gi3 = gps->a[5] % gpi[0]; }
}
void rs_1_06_06_2(unsigned char a) {
	switch (gu2) { case 3: vl(gl); break; case 5: case 8: gc = gca[7] = -gc; break; }
}
void rs_1_06_06_3(unsigned char a) {
	gla[6] ^= gl2;
}
void rs_1_06_06_4(unsigned char a) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_1_06_07_1(long a, long *b, char c) {
	gs.d -= gda[2] / 1.0;
}
void rs_1_06_07_2(long a, long *b, char c) {
	guc = -((unsigned char)(gi2 <= gia[7]));
}
void rs_1_06_07_3(long a, long *b, char c) {
	int i = ji;
	i = 0; while (i < 9) { gu--; gca[i] = *gp; gula[i] = 68986UL; i++; }
}
void rs_1_06_07_4(long a, long *b, char c) {
	gda[1] += -gd;
}
int rs_1_06_07_5(long a, long *b, char c) {
	return -8;
}
void rs_1_06_08_0(char *a, char b, unsigned char c) {
	if (128 == guca[0] || gula[c] < 98662UL) { *gpi /= 7; gi2 <<= 13; }
}
void rs_1_06_08_1(char *a, char b, unsigned char c) {
	if (gua[b] > gs.u) { gd = gda[3] - (gd2 * gda[2]); v1(gi3 & gpi[0]); } else { if (gula[0] & 4) if (gla[6] != 0) gl = 2L / gla[6]; }
}
int * rs_1_06_08_2(char *a, char b, unsigned char c) {
	return gpi;
}
void rs_1_06_09_0(double a) {
	double t = gd2;
	jd = t;
}
void rs_1_06_09_1(double a) {
	--gu;
}
void rs_1_06_09_2(double a) {
	if (gul != 0) gula[6] = 7UL / gul;
}
void rs_1_06_09_3(double a) {
	while (gi > 0) { gi2 += *gpi++; gi--; }
}
void rs_1_06_09_4(double a) {
	double t = jd;
	gd = t;
}
int rs_1_06_09_5(double a) {
	return ~gia[5];
}
void rs_1_06_10_0(char a, int b) {
	double t = gs.d + gda[0];
	jd = t;
}
void rs_1_06_10_1(char a, int b) {
	gul = gula[a] * 6UL;
}
void rs_1_06_10_2(char a, int b) {
	a = gca[7];
}
void rs_1_06_10_3(char a, int b) {
	*gp = rc(7);
}
void rs_1_06_10_4(char a, int b) {
	double t = jd;
	v0();
	gd = t;
}
void rs_1_06_10_5(char a, int b) {
	gul = rul(gula[7] & ((unsigned long)gps->c));
}
int rs_1_06_10_6(char a, int b) {
	return !3UL;
}
void rs_1_06_11_0(void) {
	unsigned long t = gul;
	jul = t;
}
void rs_1_06_11_1(void) {
	guc = guca[6];
}
void rs_1_06_11_2(void) {
	unsigned long t = jul;
	gul = t;
}
void rs_1_06_11_3(void) {
	gp = &gca[6];
}
void rs_1_06_11_4(void) {
	vu(gua[3] - gu2);
}
char rs_1_06_11_5(void) {
	return *gp;
}
void rs_1_06_12_0(unsigned int a, struct st *b, int c) {
	int t = 2;
	ji = t;
}
void rs_1_06_12_1(unsigned int a, struct st *b, int c) {
	guc++;
}
void rs_1_06_12_2(unsigned int a, struct st *b, int c) {
	vd(gd2);
}
void rs_1_06_12_3(unsigned int a, struct st *b, int c) {
	int t = ji;
	v0();
	v1(t);
}
unsigned int rs_1_06_12_4(unsigned int a, struct st *b, int c) {
	return (gu2 = a);
}
void rs_1_06_13_0(int a, long b, int c) {
	char t = -(' ');
	jc = t;
}
void rs_1_06_13_1(int a, long b, int c) {
	gua[6] %= 3;
}
void rs_1_06_13_2(int a, long b, int c) {
	gpl[0] = gl2 >> 10;
}
void rs_1_06_13_3(int a, long b, int c) {
	char t = jc;
	gc = t;
}
unsigned long rs_1_06_13_4(int a, long b, int c) {
	return gul;
}
void rs_1_06_14_0(unsigned int a) {
	guc = (unsigned char)((gd2 * gs.d) >= (gd - (double)gu2));
}
void rs_1_06_14_1(unsigned int a) {
	vs(gps);
}
char * rs_1_06_14_2(unsigned int a) {
	if ((*gp = gc2)) return gs.p;
}
char * rs_1_06_14_3(unsigned int a) {
	return gps->p;
}
void rs_1_06_15_0(void) {
	v1(!gc);
}
void rs_1_06_15_1(void) {
	v1(*gpi << 10);
}
void rs_1_06_15_2(void) {
	++gu2;
}
int rs_1_06_15_3(void) {
	return (gi3 = 8);
}
void rs_1_06_16_0(long a, long b, unsigned long c) {
	int *t = &gia[3];
	jpi = t;
}
void rs_1_06_16_1(long a, long b, unsigned long c) {
	int *u = rpi(100);
	jpi = u;
}
void rs_1_06_16_2(long a, long b, unsigned long c) {
	gl2 = (gla[7] & 2L) / 4L;
}
void rs_1_06_16_3(long a, long b, unsigned long c) {
	v1(1 >> 14);
}
void rs_1_06_16_4(long a, long b, unsigned long c) {
	if (!guca[7]) if (gula[0] != 0) gula[5] = c % gula[0];
}
void rs_1_06_16_5(long a, long b, unsigned long c) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_1_06_16_6(long a, long b, unsigned long c) {
	vd(gda[0]);
}
void rs_1_06_16_7(long a, long b, unsigned long c) {
	int *u = jpi;
	v0();
	gpi = u;
}
int rs_1_06_16_8(long a, long b, unsigned long c) {
	return (gs.i = gs.a[3]);
}
void rs_1_06_17_1(void) {
	int t = gs.a[5] & 127;
	ji = t;
}
void rs_1_06_17_2(void) {
	char u = gc;
	jc = u;
}
void rs_1_06_17_3(void) {
	gul *= 7UL;
}
void rs_1_06_17_4(void) {
	int t = ji;
	char u = jc;
	if (u & 0x10) { gua[7] = (unsigned int)108; vu(255 + gu2); } else { if (gp[0] != 0) u = (char)gul % gp[0]; if (gla[t] != 0) gpl[1] = 65536L / gla[t]; if (gps->u != 0) gua[6] = gu % gps->u; }
}
void rs_1_06_17_5(void) {
	gpi = &gia[5];
}
void rs_1_06_17_6(void) {
	gia[3] = gi = gi2;
}
void rs_1_06_17_7(void) {
	int i = ji;
	v0();
	i = 0; while (i < 5) { vd((!gs.i ? gd2 : gd)); i++; }
}
int rs_1_06_17_8(void) {
	int t = ji;
	v0();
	return (t * 3) | (256 ^ 8);
}
void rs_1_06_18_0(long a) {
	int *t = gpi;
	jpi = t;
}
void rs_1_06_18_1(long a) {
	gc2 ^= 1;
}
void rs_1_06_18_2(long a) {
	gula[1] = (unsigned long)(a < 6L);
}
void rs_1_06_18_3(long a) {
	int *t = jpi;
	gpi = t;
}
void rs_1_06_18_4(long a) {
	gua[3] -= (unsigned int)!gc2;
}
void rs_1_06_18_5(long a) {
	if (gula[0] != 0) gul = gul % gula[0];
}
int rs_1_06_18_6(long a) {
	return gi3;
}
void rs_1_06_19_0(int a, int *b) {
	*gpl = gla[5];
}
void rs_1_06_19_1(int a, int *b) {
	vc(gc << (a & 7));
}
void rs_1_06_19_2(int a, int *b) {
	gc /= 3;
}
void rs_1_06_19_3(int a, int *b) {
	gu2 = -(~32767);
}
int rs_1_06_19_4(int a, int *b) {
	return r1(a) - gi3;
}
void rs_1_07_00_0(void) {
	guc = ~(((unsigned char)gi) - guc);
}
void rs_1_07_00_1(void) {
	if (gi2) { gp = gp + 1; if (gl != 0) *gpl = gps->l / gl; if (gs.u != 0) gu2 = gu2 / gs.u; }
}
void rs_1_07_01_0(int a, int b, int c) {
	double t = (r0() ? gd2 : gd);
	jd = t;
}
void rs_1_07_01_1(int a, int b, int c) {
	long u = 7L + gl;
	v0();
	jl = u;
}
void rs_1_07_01_2(int a, int b, int c) {
	--gul;
}
void rs_1_07_01_3(int a, int b, int c) {
	double t = jd;
	v0();
	t = (t + t) * ((double)gia[b] * t);
}
void rs_1_07_01_4(int a, int b, int c) {
	long u = jl;
	v0();
	gps->u = gu2 - gs.u;
}
unsigned int rs_1_07_01_5(int a, int b, int c) {
	return ru((unsigned int)gps->c);
}
void rs_1_07_02_1(unsigned char a, long *b) {
	char *t = &gca[7];
	jp = t;
}
void rs_1_07_02_2(unsigned char a, long *b) {
	gi3--;
}
void rs_1_07_02_3(unsigned char a, long *b) {
	char *t = jp;
	vp(t);
}
void rs_1_07_02_4(unsigned char a, long *b) {
	*gpi ^= gi3;
}
void rs_1_07_02_5(unsigned char a, long *b) {
	int i = ji;
	v0();
	i = 0; while (i < 8) { gs.d *= gs.d; i++; }
}
int * rs_1_07_02_6(unsigned char a, long *b) {
	return gpi;
}
void rs_1_07_03_0(double a) {
	gpi[3] = r1(gs.a[1]);
}
void rs_1_07_03_1(double a) {
	gda[0] = gda[1] + gd2;
}
void rs_1_07_03_2(double a) {
	guca[2] = guc;
}
void rs_1_07_03_3(double a) {
	gps->p = gp;
}
void rs_1_07_03_4(double a) {
	if (gc >= 2) if (gula[2] != 0) gul = gul / gula[2];
}
void rs_1_07_04_0(char *a, char b, unsigned int c) {
	int t = gs.i >> 2;
	ji = t;
}
void rs_1_07_04_1(char *a, char b, unsigned int c) {
	unsigned char u = guc;
	juc = u;
}
void rs_1_07_04_2(char *a, char b, unsigned int c) {
	unsigned char u = juc;
	gu = (gu2 + ((unsigned int)u)) * gu2;
}
void rs_1_07_04_3(char *a, char b, unsigned int c) {
	unsigned char u = juc;
	u = 235;
}
void rs_1_07_04_4(char *a, char b, unsigned int c) {
	int t = ji;
	unsigned char u = juc;
	if (gs.u) { gs.l += gl; gla[0] = (-69703L + 8L) * 3L; gu++; } else { b = (gca[t] - 0) - *gp; if (gps->u != 0) gu2 = gu2 % gps->u; *gpi = gi * 7; }
}
void rs_1_07_04_5(char *a, char b, unsigned int c) {
	gul <<= (b & 15);
}
int rs_1_07_04_6(char *a, char b, unsigned int c) {
	return gi2 >> (b & 15);
}
void rs_1_07_05_0(long a) {
	int *t = rpi(gps->a[6]);
	jpi = t;
}
void rs_1_07_05_1(long a) {
	int *t = jpi;
	v0();
	t++;
}
void rs_1_07_05_2(long a) {
	gu++;
}
int rs_1_07_05_3(long a) {
	int *t = jpi;
	v0();
	return (*t + gs.a[4]) + gs.a[2];
}
void rs_1_07_06_0(void) {
	gps->c = *gp - gc2;
}
void rs_1_07_06_1(void) {
	v1(gi - 100);
}
void rs_1_07_06_2(void) {
	gula[6] = gul >> 19;
}
void rs_1_07_06_3(void) {
	--gp;
}
long rs_1_07_06_4(void) {
	return ((long)(gps->l >= gla[3])) & gpl[2];
}
void rs_1_07_07_0(char a) {
	unsigned int t = ~gua[3];
	ju = t;
}
void rs_1_07_07_1(char a) {
	int u = !gua[0];
	ji = u;
}
void rs_1_07_07_2(char a) {
	unsigned int t = ju;
	if (t <= 13484) if (gl != 0) gla[3] = gs.l % gl;
}
void rs_1_07_07_3(char a) {
	unsigned int t = ju;
	vu(t ^ gu);
}
void rs_1_07_07_4(char a) {
	gl2 = ~(-(long)gc2);
}
void rs_1_07_07_5(char a) {
	int u = ji;
	v0();
	v1(u * gps->i);
}
void rs_1_07_07_6(char a) {
	unsigned int t = ju;
	v0();
	t += (unsigned int)(gi <= 2);
}
unsigned int rs_1_07_07_7(char a) {
	unsigned int t = ju;
	v0();
	return t;
}
void rs_1_07_08_0(void) {
	int t = (int)gca[7] >> 3;
	ji = t;
}
void rs_1_07_08_1(void) {
	gu2--;
}
void rs_1_07_08_2(void) {
	if (gl != 0) *gpl = gla[7] % gl;
}
void rs_1_07_08_3(void) {
	int t = ji;
	gpi = gpi + t;
}
int rs_1_07_08_4(void) {
	return (int)guca[5];
}
void rs_1_07_09_0(long a, int b) {
	++guc;
}
void rs_1_07_09_1(long a, int b) {
	gua[b] -= gu ^ 3;
}
void rs_1_07_10_0(void) {
	char t = ~gca[7];
	jc = t;
}
void rs_1_07_10_1(void) {
	char t = jc;
	t |= rc(gi);
}
void rs_1_07_10_2(void) {
	gp = rp();
}
void rs_1_07_10_3(void) {
	gs.c = gc;
}
int rs_1_07_10_4(void) {
	return (int)255;
}
void rs_1_07_11_0(void) {
	int t = (int)gu2;
	ji = t;
}
void rs_1_07_11_1(void) {
	unsigned int u = ru(gu);
	ju = u;
}
void rs_1_07_11_2(void) {
	int t = ji;
	v0();
	t = r2((int)guca[3] % 3, gi);
}
void rs_1_07_11_3(void) {
	v0();
}
void rs_1_07_11_4(void) {
	unsigned int u = ju;
	v0();
	gu = u;
}
unsigned int rs_1_07_11_5(void) {
	unsigned int u = ju;
	v0();
	return (u & gu2) + -32767;
}
void rs_1_07_12_0(void) {
	gpi = &gia[2];
}
void rs_1_07_12_1(void) {
	gd2 -= gd - gd2;
}
void rs_1_07_12_2(void) {
	gl = gps->l * (gpl[3] + gl);
}
void rs_1_07_12_3(void) {
	if (gca[2] < gps->c) { if (gu != 0) gu2 = gs.u % gu; gula[4] += 30675UL | gul; if (gu != 0) gps->u = 255 % gu; } else { gua[2] = gu; }
}
void rs_1_07_12_4(void) {
	gc2 = (gca[0] | -14) & -gca[2];
}
char * rs_1_07_12_5(void) {
	return gs.p;
}
void rs_1_07_13_0(long a) {
	while (gi-- > 0) *gpi++ = 100;
}
void rs_1_07_13_1(long a) {
	gd = (guca[3] ? (0.5 + (double)*gp) : gd2);
}
void rs_1_07_13_2(long a) {
	gua[6] = 2 - gu2;
}
unsigned int rs_1_07_13_3(long a) {
	return (gu2 = gua[1]);
}
void rs_1_07_14_0(unsigned long a, long b, long c) {
	++a;
}
void rs_1_07_14_1(unsigned long a, long b, long c) {
	switch (gl) { case 2L: guc += guca[6]; case 8L: gi3 %= 7; case 100L: vl(3L); break; }
}
void rs_1_07_14_2(unsigned long a, long b, long c) {
	switch (gi2) { case 0: v2(gi2, 127); break; case 1: gda[3] *= gd2; break; case 2: gps->i |= gps->a[0]; break; }
}
void rs_1_07_14_3(unsigned long a, long b, long c) {
	gs.c = gca[3] | 'a';
}
void rs_1_07_14_4(unsigned long a, long b, long c) {
	guca[2] = (~((unsigned char)gl)) & (5 + guca[6]);
}
int * rs_1_07_14_5(unsigned long a, long b, long c) {
	return &gia[0];
}
void rs_1_07_15_0(int a, unsigned char b, long *c) {
	long t = gps->l / 7L;
	jl = t;
}
void rs_1_07_15_1(int a, unsigned char b, long *c) {
	long t = jl;
	gul = (*c <= t ? (gul << (a & 15)) : gula[a]);
}
void rs_1_07_15_2(int a, unsigned char b, long *c) {
	gi2 = gi;
}
int rs_1_07_15_3(int a, unsigned char b, long *c) {
	return (gs.a[b] = 255);
}
void rs_1_07_16_1(char *a, unsigned long b) {
	double t = (gu2 ? gd2 : gda[2]);
	jd = t;
}
void rs_1_07_16_2(char *a, unsigned long b) {
	int i = ji;
	for (i = 0; i < 14; i++) { v0(); gca[i] = gc2 >> 2; if (gps->u != 0) gu = gu / gps->u; }
}
void rs_1_07_16_3(char *a, unsigned long b) {
	int i = ji;
	v0();
	v1(gs.i * 4);
}
void rs_1_07_16_4(char *a, unsigned long b) {
	double t = jd;
	v0();
	vd(t);
}
void rs_1_07_16_5(char *a, unsigned long b) {
	if (gula[0] != 0) b = gul % gula[0];
}
int rs_1_07_16_6(char *a, unsigned long b) {
	return gi;
}
void rs_1_07_17_1(unsigned char a, unsigned char b, int c) {
	int *t = gpi + a;
	jpi = t;
}
void rs_1_07_17_2(unsigned char a, unsigned char b, int c) {
	unsigned int u = gu2 >> 3;
	ju = u;
}
void rs_1_07_17_3(unsigned char a, unsigned char b, int c) {
	int i = ji;
	unsigned int u = ju;
	for (i = 0; i < c; i++) { if (gua[2] != 0) gu2 = u / gua[2]; if (gula[i] != 0) gula[i] = gula[i] % gula[i]; }
}
void rs_1_07_17_4(unsigned char a, unsigned char b, int c) {
	gula[b] = gul / 10UL;
}
void rs_1_07_17_5(unsigned char a, unsigned char b, int c) {
	if (gca[c] != 0) gs.c = gc / gca[c];
}
void rs_1_07_17_6(unsigned char a, unsigned char b, int c) {
	unsigned int u = ju;
	gua[b] = gu = (gs.u - u) | (u % 3);
}
void rs_1_07_17_7(unsigned char a, unsigned char b, int c) {
	int *t = jpi;
	gpi = t;
}
void rs_1_07_17_8(unsigned char a, unsigned char b, int c) {
	gula[7] %= 16UL;
}
int * rs_1_07_17_9(unsigned char a, unsigned char b, int c) {
	return &gia[2];
}
void rs_1_07_18_0(long a, long b, char c) {
	char t = 7 - gp[1];
	jc = t;
}
void rs_1_07_18_1(long a, long b, char c) {
	char t = jc;
	char u = t;
	jc = u;
}
void rs_1_07_18_2(long a, long b, char c) {
	char t = jc;
	if (gu & 0x10) if (t != 0) t = 2 / t;
}
void rs_1_07_18_3(long a, long b, char c) {
	gua[3] = gu + ~255;
}
void rs_1_07_18_4(long a, long b, char c) {
	char t = jc;
	t %= 3;
}
void rs_1_07_18_5(long a, long b, char c) {
	char t = jc;
	gul = gula[t] = gula[c];
}
void rs_1_07_18_6(long a, long b, char c) {
	char t = jc;
	char u = jc;
	gla[1] = gs.l = ((long)(t < u)) + (long)!8794;
}
void rs_1_07_19_0(long *a, int b, int c) {
	unsigned int t = (unsigned int)!gca[5];
	ju = t;
}
void rs_1_07_19_1(long *a, int b, int c) {
	unsigned int t = ju;
	gs.p = gp + t;
}
void rs_1_07_19_2(long *a, int b, int c) {
	if (*a != 0) gl = gl2 % *a;
}
void rs_1_07_19_3(long *a, int b, int c) {
	a[1] = gps->l >> 31;
}
void rs_1_07_19_4(long *a, int b, int c) {
	if (!gla[1]) gula[1] = gul;
}
void rs_1_07_19_5(long *a, int b, int c) {
	vc(gs.c);
}
void rs_1_08_00_0(unsigned int a, unsigned long b) {
	char *t = gs.p;
	jp = t;
}
void rs_1_08_00_1(unsigned int a, unsigned long b) {
	gula[a] &= (unsigned long)gps->l;
}
void rs_1_08_00_2(unsigned int a, unsigned long b) {
	char *t = jp;
	if (0x10000UL != gula[5]) { guca[7] = guca[a]; } else { if (gpl[0]) if (gc2 != 0) t[2] = gca[7] / gc2; }
}
void rs_1_08_00_3(unsigned int a, unsigned long b) {
	gps->c &= *gp % 3;
}
void rs_1_08_01_1(unsigned long a) {
	a -= a / 10UL;
}
void rs_1_08_01_2(unsigned long a) {
	if ((gula[0] = gula[3]) != 23094UL) { gs.u = gu2; gd = (gd / 0.5) * gs.d; }
}
void rs_1_08_01_3(unsigned long a) {
	if (gs.l >= 9L) gu2 &= ru((unsigned int)gc);
}
void rs_1_08_01_4(unsigned long a) {
	int i = ji;
	v0();
	for (i = 0; i < 14; i++) { if (gla[i] != 0) gl2 = gl2 % gla[i]; }
}
char rs_1_08_01_5(unsigned long a) {
	return 3 - gp[0];
}
void rs_1_08_02_0(unsigned char a) {
	gi3 = *gpi;
}
void rs_1_08_02_1(unsigned char a) {
	vl(gs.l);
}
void rs_1_08_02_2(unsigned char a) {
	gu2 = (gu & gua[5]) - (gu | 256);
}
void rs_1_08_02_3(unsigned char a) {
	if (r0()) { if (gi2 != 0) gi3 = gps->i / gi2; if (gs.a[a] != 0) gi3 = gi3 % gs.a[a]; gul %= 2UL; }
}
void rs_1_08_02_4(unsigned char a) {
	gps->c -= -gca[a];
}
unsigned int rs_1_08_02_5(unsigned char a) {
	return -32767 | ((unsigned int)!65536L);
}
void rs_1_08_03_0(double a) {
	char t = gc2 / 3;
	jc = t;
}
void rs_1_08_03_1(double a) {
	gl |= gpl[3] >> 26;
}
void rs_1_08_03_2(double a) {
	char t = jc;
	vc(t);
}
void rs_1_08_03_3(double a) {
	gd2 = gda[2];
}
void rs_1_08_04_1(char a, char *b) {
	int *t = gpi;
	jpi = t;
}
void rs_1_08_04_2(char a, char *b) {
	int u = gi % 2;
	ji = u;
}
void rs_1_08_04_3(char a, char *b) {
	int i = ji;
	i = 0; while (i < 15) { guc = guca[i] = ~(((unsigned char)gul) >> 1); i++; }
}
void rs_1_08_04_4(char a, char *b) {
	int *t = jpi;
	v1(*t);
}
void rs_1_08_04_5(char a, char *b) {
	int u = ji;
	v0();
	v1(u);
}
void rs_1_08_04_6(char a, char *b) {
	gul = gula[a];
}
void rs_1_08_04_7(char a, char *b) {
	int i = ji;
	v0();
	v2(256 + gps->i, gi);
}
void rs_1_08_04_8(char a, char *b) {
	gps->p = gp;
}
unsigned int rs_1_08_04_9(char a, char *b) {
	return (unsigned int)gul;
}
void rs_1_08_05_0(unsigned long a, long b, long c) {
	switch (gi2) { case 1: gpi = gpi + 1; break; case 8: gs.a[7] ^= gi3; break; }
}
void rs_1_08_05_1(unsigned long a, long b, long c) {
	v1(gi + gps->i);
}
unsigned long rs_1_08_05_2(unsigned long a, long b, long c) {
	return rul(-50474UL);
}
void rs_1_08_06_0(long *a) {
	char *t = rp();
	jp = t;
}
void rs_1_08_06_1(long *a) {
	char *t = jp;
	v0();
	v2(gi2, gpi[2] | (int)*t);
}
void rs_1_08_06_2(long *a) {
	vs(gps);
}
void rs_1_08_06_3(long *a) {
	char *t = jp;
	v0();
	gps->c = t[2] + t[0];
}
void rs_1_08_06_4(long *a) {
	gl2--;
}
unsigned int rs_1_08_06_5(long *a) {
	return ((unsigned int)*gp) / 10;
}
void rs_1_08_07_1(unsigned long a) {
	unsigned long t = a / 7UL;
	jul = t;
}
void rs_1_08_07_2(unsigned long a) {
	int *u = gpi + 1;
	jpi = u;
}
void rs_1_08_07_3(unsigned long a) {
	gs.l = gl2 - gpl[2];
}
void rs_1_08_07_4(unsigned long a) {
	guca[5] -= 128;
}
void rs_1_08_07_5(unsigned long a) {
	unsigned long t = jul;
	gul = t;
}
void rs_1_08_07_6(unsigned long a) {
	int *u = jpi;
	gpi = u;
}
void rs_1_08_07_7(unsigned long a) {
	gul = 0x10000UL;
}
void rs_1_08_07_8(unsigned long a) {
	int i = ji;
	for (i = 0; i < 14; i++) { if (gu != 0) gua[i] = 255 / gu; gula[i] = 0x10000UL & (((unsigned long)gu2) | 9UL); }
}
void rs_1_08_07_9(unsigned long a) {
	if (gca[1] != 0) gca[1] = (' ') / gca[1];
}
int rs_1_08_07_10(unsigned long a) {
	return (int)(255 ^ guca[4]);
}
void rs_1_08_08_0(long a) {
	int t = gpi[1] ^ 1;
	ji = t;
}
void rs_1_08_08_1(long a) {
	int t = ji;
	guc = guca[t];
}
void rs_1_08_08_2(long a) {
	int t = ji;
	if (gul != 0) gula[t] = gula[t] % gul;
}
void rs_1_08_08_3(long a) {
	if (gla[6] != 0) gps->l = gla[2] / gla[6];
}
void rs_1_08_08_4(long a) {
	while (gi > 0) { gi += *gpi++; gi--; }
}
char rs_1_08_08_5(long a) {
	return (gp[0] = gps->c);
}
void rs_1_08_09_0(int a) {
	double t = gd2;
	jd = t;
}
void rs_1_08_09_1(int a) {
	if (gula[a] < gul) { guca[3] = (unsigned char)(gps->c <= 0); gps->l = *gpl; gu = (unsigned int)((gp[3] | gc2) == (gca[1] >> 5)); }
}
void rs_1_08_09_2(int a) {
	if (gi & 0x7) gla[a] = ~gl2;
}
void rs_1_08_09_3(int a) {
	double t = jd;
	vd(t);
}
void rs_1_08_09_4(int a) {
	gc2 &= (char)gi;
}
void rs_1_08_09_5(int a) {
	gps->c -= (char)(100.0 > 2.5);
}
int rs_1_08_09_6(int a) {
	return gi2;
}
void rs_1_08_10_1(char a, int b, long c) {
	unsigned long t = gul - gula[5];
	jul = t;
}
void rs_1_08_10_2(char a, int b, long c) {
	double u = (double)gp[1];
	jd = u;
}
void rs_1_08_10_3(char a, int b, long c) {
	if (a > -92) { if (c != 0) c = gl2 / c; guc = guca[a] * (guc - 226); }
}
void rs_1_08_10_4(char a, int b, long c) {
	unsigned long t = jul;
	vl((long)t);
}
void rs_1_08_10_5(char a, int b, long c) {
	int i = ji;
	v0();
	if (gs.i & 4) { gp[1] = gps->c; }
}
void rs_1_08_10_6(char a, int b, long c) {
	gs.a[b] %= 3;
}
void rs_1_08_10_7(char a, int b, long c) {
	int i = ji;
	v0();
	i = 10; do { v2(b - gpi[1], gi); guca[i] += ~guc; } while (--i > 0);
}
void rs_1_08_10_8(char a, int b, long c) {
	double u = jd;
	v0();
	vd(u);
}
long rs_1_08_10_9(char a, int b, long c) {
	return gla[b];
}
void rs_1_08_11_1(unsigned long a, long b, int c) {
	double t = gda[1];
	jd = t;
}
void rs_1_08_11_2(unsigned long a, long b, int c) {
	int i = ji;
	i = 0; while (i < 15) { gl = (long)!rc(gi); if (gula[1] != 0) a = 0x10000UL % gula[1]; i++; }
}
void rs_1_08_11_3(unsigned long a, long b, int c) {
	gps->a[3] = 100;
}
void rs_1_08_11_4(unsigned long a, long b, int c) {
	int i = ji;
	v0();
	if (gs.i != 0) gi = gps->i / gs.i;
}
void rs_1_08_11_5(unsigned long a, long b, int c) {
	double t = jd;
	v0();
	switch (gps->c) { case 0: t *= t; break; case 1: gul *= 11UL; break; case 2: v1(112); case 3: gc = gc - *gp; case 4: gl *= 6L; break; case 5: vu(gu); break; }
}
int rs_1_08_11_6(unsigned long a, long b, int c) {
	return gi;
}
void rs_1_08_12_0(void) {
	guca[1] = guc;
}
void rs_1_08_12_1(void) {
	gl2--;
}
void rs_1_08_12_2(void) {
	if (r2(gs.a[2], gi)) ++gc2;
}
void rs_1_08_12_3(void) {
	guc = guca[7];
}
unsigned long rs_1_08_12_4(void) {
	return gul;
}
void rs_1_08_13_0(char *a, struct st *b) {
	int t = (gula[5] > 3UL);
	ji = t;
}
void rs_1_08_13_1(char *a, struct st *b) {
	int t = ji;
	guc = guca[t] = (guca[t] / 7) * 7;
}
void rs_1_08_13_2(char *a, struct st *b) {
	int t = ji;
	if (b->l != 0) gla[t] = gpl[3] % b->l;
}
void rs_1_08_13_3(char *a, struct st *b) {
	int t = ji;
	v1(t ^ gi3);
}
void rs_1_08_13_4(char *a, struct st *b) {
	int t = ji;
	v0();
	gul -= -gula[t];
}
void rs_1_08_13_5(char *a, struct st *b) {
	if (gc2 != 0) gp[3] = gs.c / gc2;
}
long rs_1_08_13_6(char *a, struct st *b) {
	return *gpl / 2L;
}
void rs_1_08_14_0(unsigned long a) {
	unsigned int t = -gu;
	ju = t;
}
void rs_1_08_14_1(unsigned long a) {
	int *u = gpi;
	jpi = u;
}
void rs_1_08_14_2(unsigned long a) {
	unsigned int t = ju;
	gu = t;
}
void rs_1_08_14_3(unsigned long a) {
	int *u = jpi;
	gpi = u;
}
int rs_1_08_14_4(unsigned long a) {
	if (0x10000UL >= 4UL) return (45718UL <= gul ? gps->i : gi);
}
void rs_1_08_14_5(unsigned long a) {
	if (!gl2) a = (gul % 100UL) / 2UL;
}
int rs_1_08_14_6(unsigned long a) {
	unsigned int t = ju;
	int *u = jpi;
	return (gi + u[t]) | (gi2 - *gpi);
}
void rs_1_08_15_0(long *a, unsigned char b, unsigned char c) {
	switch (gc2) { case 0: vd(gs.d); break; case 1: vp(gs.p); break; case 2: vp(gp); break; case 3: c *= 3; break; case 4: b &= c; break; }
}
void rs_1_08_15_1(long *a, unsigned char b, unsigned char c) {
	gpi[1] = ~255;
}
void rs_1_08_15_2(long *a, unsigned char b, unsigned char c) {
	vd(gd + gda[3]);
}
void rs_1_08_15_3(long *a, unsigned char b, unsigned char c) {
	if (!gu2) if (gps->u != 0) gua[0] = gu / gps->u;
}
void rs_1_08_15_4(long *a, unsigned char b, unsigned char c) {
	gula[3] = -gul;
}
char * rs_1_08_15_5(long *a, unsigned char b, unsigned char c) {
	return gs.p;
}
void rs_1_08_16_0(void) {
	unsigned char t = 6 & guca[2];
	juc = t;
}
void rs_1_08_16_1(void) {
	unsigned char t = juc;
	unsigned char u = guca[t] & t;
	juc = u;
}
void rs_1_08_16_2(void) {
	unsigned char t = juc;
	unsigned char u = juc;
	t = guca[2] = u;
}
void rs_1_08_16_3(void) {
	gi = r1(gi2) % 2;
}
void rs_1_08_16_4(void) {
	unsigned char u = juc;
	v0();
	gs.p = gp + u;
}
void rs_1_08_17_0(int a, unsigned long b) {
	long t = gl - gpl[2];
	jl = t;
}
void rs_1_08_17_1(int a, unsigned long b) {
	unsigned int u = gu2 >> 6;
	ju = u;
}
void rs_1_08_17_2(int a, unsigned long b) {
	unsigned int u = ju;
	gc2 = *gp = (char)!gs.u / 7;
}
void rs_1_08_17_3(int a, unsigned long b) {
	unsigned int u = ju;
	if (gi3) { b = ((unsigned long)(gu < 255)) * 12UL; if (gps->u != 0) u = ((unsigned int)gi2) % gps->u; }
}
void rs_1_08_17_4(int a, unsigned long b) {
	long t = jl;
	vl(t);
}
int rs_1_08_17_5(int a, unsigned long b) {
	return (gi3 = a);
}
void rs_1_08_18_1(unsigned long a) {
	char *t = rp();
	jp = t;
}
void rs_1_08_18_2(unsigned long a) {
	int u = *gpi - gi;
	v0();
	ji = u;
}
void rs_1_08_18_3(unsigned long a) {
	int i = ji;
	int u = ji;
	v0();
	i = 0; while (i < 11) { if (u != 0) gia[i] = gi2 / u; vs(gps); u = (1 * gi2) + (gia[i] >> (u & 15)); i++; }
}
void rs_1_08_18_4(unsigned long a) {
	int u = ji;
	v0();
	u = ((int)guca[u] ^ gps->a[u]) | (gia[6] ^ u);
}
void rs_1_08_18_5(unsigned long a) {
	char *t = jp;
	v0();
	gp = t;
}
void rs_1_08_18_6(unsigned long a) {
	gl = (gl >> 16) | gpl[3];
}
void rs_1_08_18_7(unsigned long a) {
	int u = ji;
	v0();
	vc(27 >> (u & 7));
}
void rs_1_08_18_8(unsigned long a) {
	int u = ji;
	v0();
	v2(255 - u, gi);
}
int rs_1_08_18_9(unsigned long a) {
	return ~(gi3 - (int)gul);
}
void rs_1_08_19_0(unsigned int a, int *b) {
	a = ru(((unsigned int)gula[a]) + gua[a]);
}
void rs_1_08_19_1(unsigned int a, int *b) {
	*gpl *= 6L;
}
void rs_1_08_19_2(unsigned int a, int *b) {
	gi3 *= 10;
}
void rs_1_08_19_3(unsigned int a, int *b) {
	v0();
}
void rs_1_08_19_4(unsigned int a, int *b) {
	++gc;
}
void rs_1_09_00_0(unsigned long a, long b, long c) {
	int t = gi3 >> 14;
	ji = t;
}
void rs_1_09_00_1(unsigned long a, long b, long c) {
	int t = ji;
	int *u = &gia[t];
	jpi = u;
}
void rs_1_09_00_2(unsigned long a, long b, long c) {
	int *u = jpi;
	gpi = u;
}
void rs_1_09_00_3(unsigned long a, long b, long c) {
	vl(4L << 3);
}
void rs_1_09_00_4(unsigned long a, long b, long c) {
	int t = ji;
	v0();
	v1(t);
}
int rs_1_09_00_5(unsigned long a, long b, long c) {
	int t = ji;
	int *u = jpi;
	v0();
	return ~((gps->u = gua[6]) < 1 ? t : 16);
}
void rs_1_09_01_0(int a, int b, struct st *c) {
	double t = gd2 + gs.d;
	jd = t;
}
void rs_1_09_01_1(int a, int b, struct st *c) {
	gi2 >>= 8;
}
void rs_1_09_01_2(int a, int b, struct st *c) {
	double t = jd;
	gd = t;
}
void rs_1_09_01_3(int a, int b, struct st *c) {
	c->p = rp();
}
char rs_1_09_01_4(int a, int b, struct st *c) {
	return (gc * -21) * ~gc;
}
void rs_1_09_02_0(int a, unsigned int b) {
	vc(9);
}
void rs_1_09_02_1(int a, unsigned int b) {
	if ((guc = ((unsigned char)gs.u)) <= 255) if (gpi[0] != 0) gps->a[5] = (int)gl2 % gpi[0];
}
int rs_1_09_02_2(int a, unsigned int b) {
	return gpi[3];
}
void rs_1_09_03_0(unsigned long a) {
	int t = gs.i / 7;
	ji = t;
}
void rs_1_09_03_1(unsigned long a) {
	int u = gi2 - 6;
	ji = u;
}
void rs_1_09_03_2(unsigned long a) {
	if (gla[5] != 0) gs.l = gl2 / gla[5];
}
void rs_1_09_03_3(unsigned long a) {
	int t = ji;
	gi = t;
}
void rs_1_09_03_4(unsigned long a) {
	int u = ji;
	v1(u);
}
void rs_1_09_03_5(unsigned long a) {
	gu2++;
}
void rs_1_09_03_6(unsigned long a) {
	gi2 <<= 4;
}
void rs_1_09_03_7(unsigned long a) {
	gl2--;
}
void rs_1_09_03_8(unsigned long a) {
	gda[1] = gda[0] - (double)*gpl;
}
int rs_1_09_03_9(unsigned long a) {
	return 1;
}
void rs_1_09_04_1(void) {
	*gpl = gla[4] / 7L;
}
void rs_1_09_04_2(void) {
	if (gl > 61417L) if (gps->l != 0) gs.l = gl2 % gps->l;
}
char * rs_1_09_04_3(void) {
	if (gula[6] > gula[2]) return gps->p + 1;
}
void rs_1_09_04_4(void) {
	int i = ji;
	i = 0; while (i < 9) { gs.c = (gca[0] % 10) - *gp; i++; }
}
char * rs_1_09_04_5(void) {
	return &gca[2];
}
void rs_1_09_05_0(char *a, unsigned char b, unsigned long c) {
	if (gla[1] != 39633L) { if (gps->i != 0) gi3 = 100 / gps->i; }
}
void rs_1_09_05_1(char *a, unsigned char b, unsigned long c) {
	gul -= 8UL;
}
void rs_1_09_05_2(char *a, unsigned char b, unsigned long c) {
	gc2 = a[6] | ~gc2;
}
void rs_1_09_05_3(char *a, unsigned char b, unsigned long c) {
	vl(gps->l - 3L);
}
void rs_1_09_05_4(char *a, unsigned char b, unsigned long c) {
	gul--;
}
unsigned int rs_1_09_05_5(char *a, unsigned char b, unsigned long c) {
	return gua[1];
}
void rs_1_09_06_0(char a, int b) {
	unsigned long t = (unsigned long)gua[a];
	jul = t;
}
void rs_1_09_06_1(char a, int b) {
	vp(gs.p);
}
void rs_1_09_06_2(char a, int b) {
	unsigned long t = jul;
	v0();
	gul = t;
}
void rs_1_09_06_3(char a, int b) {
	unsigned long t = jul;
	v0();
	gula[b] = t = rul(t >> (b & 15));
}
void rs_1_09_06_4(char a, int b) {
	gs.i = 16 / 100;
}
void rs_1_09_06_5(char a, int b) {
	gpi = gpi + a;
}
long rs_1_09_06_6(char a, int b) {
	return (6L + gl) << 9;
}
void rs_1_09_07_0(long *a, unsigned int b, char *c) {
	int t = gi3 ^ gia[b];
	ji = t;
}
void rs_1_09_07_1(long *a, unsigned int b, char *c) {
	unsigned int u = gua[6];
	ju = u;
}
void rs_1_09_07_2(long *a, unsigned int b, char *c) {
	gua[4] *= 9;
}
void rs_1_09_07_3(long *a, unsigned int b, char *c) {
	int t = ji;
	gi = t;
}
void rs_1_09_07_4(long *a, unsigned int b, char *c) {
	if (guca[7] > guc) { gula[b] = gul; *c >>= 1; }
}
void rs_1_09_07_5(long *a, unsigned int b, char *c) {
	if (gul != 0) gula[6] = gula[5] / gul;
}
void rs_1_09_07_6(long *a, unsigned int b, char *c) {
	unsigned int u = ju;
	gu = u;
}
void rs_1_09_07_7(long *a, unsigned int b, char *c) {
	--gp;
}
unsigned long rs_1_09_07_8(long *a, unsigned int b, char *c) {
	return (gula[5] = gula[0]);
}
void rs_1_09_08_0(unsigned char a, int *b) {
	int t = gi2;
	ji = t;
}
void rs_1_09_08_1(unsigned char a, int *b) {
	vc(rc((int)gula[5]));
}
void rs_1_09_08_2(unsigned char a, int *b) {
	if (guca[7]) if (gula[2] != 0) gul = gul % gula[2];
}
void rs_1_09_08_3(unsigned char a, int *b) {
	while (gi-- > 0) *b++ = 16;
}
void rs_1_09_08_4(unsigned char a, int *b) {
	int t = ji;
	v0();
	if ((double)gl2 < (double)gps->u) { ++gp; if (gua[t] != 0) gu = ((unsigned int)t) / gua[t]; gula[a] += 0x10000UL * 10UL; } else { if (gc2 < gc) gda[0] = (1.0 + gs.d) - (gi2 == 26 ? gs.d : gd); }
}
unsigned int rs_1_09_08_5(unsigned char a, int *b) {
	return ru(32767 - 1);
}
void rs_1_09_09_1(unsigned char a) {
	gp[0] = gs.c >> (a & 7);
}
void rs_1_09_09_2(unsigned char a) {
	int i = ji;
	i = 11; do { if (gu != 0) gua[i] = gu % gu; } while (--i > 0);
}
long rs_1_09_09_3(unsigned char a) {
	return 8L;
}
void rs_1_09_10_0(unsigned int a, int b, long *c) {
	int t = (int)a;
	ji = t;
}
void rs_1_09_10_1(unsigned int a, int b, long *c) {
	char *u = gp;
	jp = u;
}
void rs_1_09_10_2(unsigned int a, int b, long *c) {
	gula[b] = (gula[0] - 0x10000UL) / 16UL;
}
void rs_1_09_10_3(unsigned int a, int b, long *c) {
	char *u = jp;
	--u;
}
void rs_1_09_10_4(unsigned int a, int b, long *c) {
	int t = ji;
	if (gula[0] != 0) gula[t] = gul % gula[0];
}
void rs_1_09_10_5(unsigned int a, int b, long *c) {
	char *u = jp;
	u = gp;
}
void rs_1_09_10_6(unsigned int a, int b, long *c) {
	gpi = gpi + a;
}
unsigned int rs_1_09_10_7(unsigned int a, int b, long *c) {
	return (((unsigned int)gl2) - gu2) / 2;
}
void rs_1_09_11_1(unsigned int a, int b, unsigned int c) {
	unsigned char t = (unsigned char)!gu2;
	juc = t;
}
void rs_1_09_11_2(unsigned int a, int b, unsigned int c) {
	double u = 2.5;
	jd = u;
}
void rs_1_09_11_3(unsigned int a, int b, unsigned int c) {
	int i = ji;
	i = 0; while (i < b) { gul = (r0() ? (gula[i] >> 29) : (gula[i] + ((unsigned long)i))); if (gul != 0) gul = gula[i] % gul; gula[i] = (gul % 2UL) | (gul % 100UL); i++; }
}
void rs_1_09_11_4(unsigned int a, int b, unsigned int c) {
	gc += 'A' / 16;
}
void rs_1_09_11_5(unsigned int a, int b, unsigned int c) {
	unsigned char t = juc;
	v0();
	v1(t);
}
void rs_1_09_11_6(unsigned int a, int b, unsigned int c) {
	while (b-- > 0) { if (*gpi == -95) break; gpi++; }
}
void rs_1_09_11_7(unsigned int a, int b, unsigned int c) {
	int i = ji;
	double u = jd;
	v0();
	for (i = 0; i < 6; i++) { gpi = gpi + a; if (gs.u != 0) gu = 8 / gs.u; }
}
char rs_1_09_11_8(unsigned int a, int b, unsigned int c) {
	unsigned char t = juc;
	v0();
	return gca[t];
}
void rs_1_09_12_0(int a) {
	gps->p = rp();
}
void rs_1_09_12_1(int a) {
	--guc;
}
void rs_1_09_12_2(int a) {
	gc2 = gca[4] >> 1;
}
void rs_1_09_12_3(int a) {
	gs.u &= 1 ^ gs.u;
}
int rs_1_09_12_4(int a) {
	return (gi / 3) - (gs.a[4] << 14);
}
void rs_1_09_13_0(unsigned int a, unsigned char b, long c) {
	unsigned int t = gu2 / 10;
	ju = t;
}
void rs_1_09_13_1(unsigned int a, unsigned char b, long c) {
	double u = gda[2] - 1.0;
	jd = u;
}
void rs_1_09_13_2(unsigned int a, unsigned char b, long c) {
	gc2 = gca[b] = gp[1];
}
void rs_1_09_13_3(unsigned int a, unsigned char b, long c) {
	gp = rp();
}
void rs_1_09_13_4(unsigned int a, unsigned char b, long c) {
	double u = jd;
	v0();
	gd = u;
}
void rs_1_09_13_5(unsigned int a, unsigned char b, long c) {
	unsigned int t = ju;
	v0();
	gu = t;
}
void rs_1_09_13_6(unsigned int a, unsigned char b, long c) {
	gi2 -= gps->a[a];
}
long rs_1_09_13_7(unsigned int a, unsigned char b, long c) {
	return rl(-28215L ^ c);
}
void rs_1_09_14_1(void) {
	int t = gi2;
	ji = t;
}
void rs_1_09_14_2(void) {
	if (gu != 0) gu2 = ((unsigned int)guca[0]) / gu;
}
void rs_1_09_14_3(void) {
	gua[4] ^= gu2 / 3;
}
void rs_1_09_14_4(void) {
	int i = ji;
	int t = ji;
	for (i = 15; i > 0; i--) { gi = !(gs.l << (t & 15)); }
}
void rs_1_09_14_5(void) {
	gl2 <<= 9;
}
unsigned long rs_1_09_14_6(void) {
	return (unsigned long)!guca[0];
}
void rs_1_09_15_0(void) {
	int t = 8 * 4;
	ji = t;
}
void rs_1_09_15_1(void) {
	long u = (long)gul;
	jl = u;
}
void rs_1_09_15_2(void) {
	long u = jl;
	u = (gda[2] < gd ? (long)gp[2] : (u | 1L));
}
void rs_1_09_15_3(void) {
	vs(gps);
}
void rs_1_09_15_4(void) {
	int t = ji;
	v0();
	gi = t;
}
int rs_1_09_15_5(void) {
	int t = ji;
	v0();
	return ~t + (t >> (t & 15));
}
void rs_1_09_16_0(long a, unsigned int b, int *c) {
	int t = *c - 7;
	ji = t;
}
void rs_1_09_16_1(long a, unsigned int b, int *c) {
	if ((gul = ((unsigned long)gc2)) <= 46843UL) vp(gs.p);
}
void rs_1_09_16_2(long a, unsigned int b, int *c) {
	int t = ji;
	v0();
	v1(t);
}
void rs_1_09_16_3(long a, unsigned int b, int *c) {
	if (255 != 4313) { vc((char)!1); }
}
int rs_1_09_16_4(long a, unsigned int b, int *c) {
	return gs.i;
}
void rs_1_09_17_0(char a) {
	unsigned long u = jul;
	unsigned int t = (guc & 4 ? gs.u : gu);
	ju = t;
}
void rs_1_09_17_1(char a) {
	unsigned long u = gul + 9UL;
	jul = u;
}
void rs_1_09_17_2(char a) {
	unsigned int t = ju;
	unsigned long u = jul;
	if (255 != gs.a[0]) { t++; u = u - (60340UL / 100UL); gs.a[5] = (gl < 8L); }
}
void rs_1_09_17_3(char a) {
	unsigned int t = ju;
	gs.a[t] = (guca[1] > guca[0]) - !guca[7];
}
void rs_1_09_17_4(char a) {
	gs.c = rc(gi2);
}
void rs_1_09_17_5(char a) {
	guc = (unsigned char)!((unsigned int)(gi3 <= *gpi));
}
char rs_1_09_17_6(char a) {
	return rc(gi3 * gi2);
}
void rs_1_09_18_0(char *a, int b, long c) {
	int t = gi3 + gi2;
	ji = t;
}
void rs_1_09_18_1(char *a, int b, long c) {
	vu(19872 - gu);
}
void rs_1_09_18_2(char *a, int b, long c) {
	gi2 = gps->i = 255;
}
void rs_1_09_18_3(char *a, int b, long c) {
	switch (gc2) { case 1: gua[b] ^= 255; break; case 3: gl2 = gpl[3] - gs.l; break; case 5: guc = guca[1]; case 8: case 10: case 100: a = gp; break; default: gps->p = gp; break; }
}
void rs_1_09_18_4(char *a, int b, long c) {
	int t = ji;
	v0();
	v1(t);
}
void rs_1_09_18_5(char *a, int b, long c) {
	v0();
}
long rs_1_09_18_6(char *a, int b, long c) {
	return (*gpl = 65536L);
}
void rs_1_09_19_1(char a) {
	int i = ji;
	i = 0; while (i < 7) { gps->i = 2 | gi3; gl2--; i++; }
}
void rs_1_09_19_2(char a) {
	if (gula[4] != 0) gula[a] = gul % gula[4];
}
int * rs_1_09_19_3(char a) {
	return &gia[a];
}
