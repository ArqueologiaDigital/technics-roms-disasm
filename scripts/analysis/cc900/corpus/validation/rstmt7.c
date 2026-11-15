/* Every statement line of random7 alone in its own function (gen_rstmt.py corpus/validation/random7 7): rs_<A>_<BB>_<CC>_<k> is line k of
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

void rs_7_00_00_1(unsigned char a) {
	unsigned int t = gu;
	ju = t;
}
void rs_7_00_00_2(unsigned char a) {
	int u = !gula[a];
	ji = u;
}
void rs_7_00_00_3(unsigned char a) {
	int u = ji;
	if (u != 0) gi2 = gps->a[5] % u;
}
void rs_7_00_00_4(unsigned char a) {
	guca[3] = (unsigned char)!(gc2 > ' ' ? gla[a] : gl2);
}
void rs_7_00_00_5(unsigned char a) {
	unsigned int t = ju;
	int u = ji;
	switch (u) { case 0: vl(gla[t]); break; case 1: gs.d -= gd2; break; case 2: guc = guc + 255; break; case 3: vs(gps); break; case 4: gd2 *= (double)gla[6]; break; }
}
void rs_7_00_00_6(unsigned char a) {
	vc((char)(gla[3] >= gl));
}
void rs_7_00_00_7(unsigned char a) {
	int i = ji;
	unsigned int t = ju;
	v0();
	i = 0; while (i < 3) { vl(gl2); gula[0] = gul & (gula[t] + 7UL); i++; }
}
int rs_7_00_00_8(unsigned char a) {
	int u = ji;
	v0();
	return (gi ^ -997) ^ (2 | u);
}
void rs_7_00_01_1(void) {
	double t = gda[2];
	jd = t;
}
void rs_7_00_01_2(void) {
	long u = gpl[2] + (long)gul;
	jl = u;
}
void rs_7_00_01_3(void) {
	vu(~9);
}
void rs_7_00_01_4(void) {
	double t = jd;
	v0();
	gd = t;
}
void rs_7_00_01_5(void) {
	int i = ji;
	v0();
	for (i = 10; i > 0; i--) { gc = gps->c = (gc | gc2) % 10; gpi = gpi + i; }
}
void rs_7_00_01_6(void) {
	long u = jl;
	v0();
	gl = u;
}
void rs_7_00_01_7(void) {
	gd2 -= 100.0;
}
void rs_7_00_01_8(void) {
	long u = jl;
	v0();
	if (u <= -20067L) { if (gc != 0) gca[7] = gca[1] % gc; }
}
long rs_7_00_01_9(void) {
	return (gl = 8L);
}
void rs_7_00_02_0(void) {
	int t = (int)((unsigned char)gla[1]);
	ji = t;
}
void rs_7_00_02_1(void) {
	int t = ji;
	gul = gula[t] + rul(0x10000UL);
}
void rs_7_00_02_2(void) {
	gd = (1.0 + gd) / 2.5;
}
void rs_7_00_02_3(void) {
	gp[3] = -gc;
}
char rs_7_00_02_4(void) {
	return (char)(long)!gp[3];
}
void rs_7_00_03_1(int a, struct st *b, double c) {
	vl(9L);
}
void rs_7_00_03_2(int a, struct st *b, double c) {
	int i = ji;
	v0();
	i = 0; while (i < 6) { if (gl2 != 0) gpl[3] = 65536L / gl2; v1(a << (i & 15)); gc2 = gps->c + (gc - 50); i++; }
}
void rs_7_00_03_3(int a, struct st *b, double c) {
	gs.d = -gd2;
}
void rs_7_00_03_4(int a, struct st *b, double c) {
	gul -= gula[a] + gul;
}
int * rs_7_00_03_5(int a, struct st *b, double c) {
	return gpi;
}
void rs_7_00_04_0(int a) {
	gs.d -= gd2 - gda[0];
}
void rs_7_00_04_1(int a) {
	gp = gs.p;
}
void rs_7_00_04_2(int a) {
	guc >>= 6;
}
void rs_7_00_04_3(int a) {
	v0();
}
int rs_7_00_04_4(int a) {
	return -gi3;
}
void rs_7_00_05_0(void) {
	unsigned char t = guc + guca[1];
	juc = t;
}
void rs_7_00_05_1(void) {
	unsigned char t = juc;
	unsigned char u = t;
	juc = u;
}
void rs_7_00_05_2(void) {
	vs(gps);
}
void rs_7_00_05_3(void) {
	unsigned char u = juc;
	v0();
	v1(u);
}
void rs_7_00_05_4(void) {
	unsigned char t = juc;
	v0();
	gul = gula[t] = -(9UL - gula[7]);
}
unsigned long rs_7_00_05_5(void) {
	return (gul = 55379UL);
}
void rs_7_00_06_1(int *a, long b) {
	int t = !128;
	ji = t;
}
void rs_7_00_06_2(int *a, long b) {
	int t = ji;
	if (gula[t] != 11178UL) if (gul != 0) gul = gul % gul;
}
void rs_7_00_06_3(int *a, long b) {
	int i = ji;
	int t = ji;
	for (i = 0; i < 12; i++) { if (gs.l != 0) gla[t] = gl2 % gs.l; }
}
long rs_7_00_06_4(int *a, long b) {
	return 67666L << 24;
}
void rs_7_00_07_1(double a, char b) {
	int *t = rpi(gi2);
	jpi = t;
}
void rs_7_00_07_2(double a, char b) {
	unsigned long u = gula[b];
	v0();
	jul = u;
}
void rs_7_00_07_3(double a, char b) {
	gp[0] = '9' & gca[b];
}
void rs_7_00_07_4(double a, char b) {
	unsigned long u = jul;
	v0();
	vl((long)u);
}
void rs_7_00_07_5(double a, char b) {
	int i = ji;
	v0();
	for (i = 12; i > 0; i--) { ++gu2; gda[1] = a; v0(); }
}
void rs_7_00_07_6(double a, char b) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_7_00_07_7(double a, char b) {
	gs.d -= a;
}
void rs_7_00_07_8(double a, char b) {
	vs(gps);
}
void rs_7_00_07_9(double a, char b) {
	gl2 = (long)!128 * 6L;
}
unsigned long rs_7_00_07_10(double a, char b) {
	unsigned long u = jul;
	v0();
	return u;
}
void rs_7_00_08_0(void) {
	char t = ~gc;
	jc = t;
}
void rs_7_00_08_1(void) {
	char t = jc;
	if (t > 46) { gps->i = gia[4] = gs.i; gu++; }
}
void rs_7_00_08_2(void) {
	char t = jc;
	if (!gca[0]) { gu = (*gp != '9' && guc == 9 ? ~gs.u : (32767 / 100)); if (gl2 != 0) gl2 = (long)gps->a[0] / gl2; if (gl2 != 0) gl2 = *gpl % gl2; } else { gu2 = (gu2 + gs.u) * 3; if (gi2 != 0) gps->a[1] = gps->i % gi2; if (gla[2] != 0) gla[t] = gla[5] % gla[2]; }
}
int rs_7_00_08_3(void) {
	return (gi2 = gs.a[7]);
}
void rs_7_00_09_0(char *a) {
	int t = gi;
	ji = t;
}
void rs_7_00_09_1(char *a) {
	double u = gs.d;
	jd = u;
}
void rs_7_00_09_2(char *a) {
	*gpl = *gpl & gl2;
}
void rs_7_00_09_3(char *a) {
	int t = ji;
	v1(t);
}
void rs_7_00_09_4(char *a) {
	if (gu2 <= ((unsigned int)gi)) { gl = gps->l = 65536L; if (gul != 0) gula[7] = gul / gul; }
}
void rs_7_00_09_5(char *a) {
	double u = jd;
	v0();
	gd = u;
}
char rs_7_00_09_6(char *a) {
	int t = ji;
	v0();
	return (char)((long)a[t] - gl2);
}
void rs_7_00_10_1(struct st *a) {
	unsigned long t = gula[2] - 28726UL;
	jul = t;
}
void rs_7_00_10_2(struct st *a) {
	unsigned long t = jul;
	gul = t;
}
void rs_7_00_10_3(struct st *a) {
	int i = ji;
	for (i = 0; i < 12; i++) { gda[3] -= gd - (double)gpi[1]; a->c = gca[i] << 1; --gl2; }
}
void rs_7_00_10_4(struct st *a) {
	gc2 = gs.c = -(gc2 & (char)gl);
}
void rs_7_00_10_5(struct st *a) {
	guc = (128 / 100) ^ 128;
}
void rs_7_00_10_6(struct st *a) {
	v2(gi2, (int)gl2 >> 13);
}
int rs_7_00_10_7(struct st *a) {
	return (*gpi = gi);
}
void rs_7_00_11_0(void) {
	int *t = gpi;
	jpi = t;
}
void rs_7_00_11_1(void) {
	double u = gd;
	jd = u;
}
void rs_7_00_11_2(void) {
	int *t = jpi;
	if (gl == 68964L && gl2 & 2) { vu(gu | ((unsigned int)gl)); } else { gs.i = gps->a[2] - *t; vu(gu2 / 2); if (gul != 0) gula[3] = ((unsigned long)*gpl) % gul; }
}
void rs_7_00_11_3(void) {
	double u = jd;
	v0();
	switch (gl) { case 0L: gul = (unsigned long)!gps->l; break; case 1L: u *= u; break; case 2L: v2(gs.i, gi); break; case 3L: vl(2L); break; case 4L: gua[2] = gu - gu2; break; case 5L: guc -= 128; break; default: vs(gps); break; }
}
void rs_7_00_11_4(void) {
	if (gul == 1UL && gul < 0x10000UL) vu(255 ^ gua[2]);
}
unsigned int rs_7_00_11_5(void) {
	double u = jd;
	v0();
	return gps->u;
}
void rs_7_00_12_0(void) {
	if ((gul = ((unsigned long)gl2))) { gula[3] = gul; ++guc; }
}
void rs_7_00_12_1(void) {
	gula[4] /= 3UL;
}
void rs_7_00_12_2(void) {
	vu(gps->u);
}
int * rs_7_00_12_3(void) {
	return gpi;
}
void rs_7_00_13_0(unsigned long a, unsigned int b, char *c) {
	gc = c[b] * (gs.c ^ 64);
}
void rs_7_00_13_1(unsigned long a, unsigned int b, char *c) {
	switch (gl2) { case 0L: a /= 16UL; break; case 1L: gpl[1] = (guca[b] == 3 ? gla[2] : (long)guc); break; case 2L: vu((unsigned int)guca[5]); break; default: vd(10.0); break; }
}
void rs_7_00_13_2(unsigned long a, unsigned int b, char *c) {
	*gp = gc2;
}
void rs_7_00_13_3(unsigned long a, unsigned int b, char *c) {
	guca[5] = ((unsigned char)gu2) / 16;
}
void rs_7_00_13_4(unsigned long a, unsigned int b, char *c) {
	if (gs.i & 0x8) { gu = b; if (gula[0] != 0) gula[b] = gul % gula[0]; } else { gd *= gda[0] - gd; }
}
long rs_7_00_13_5(unsigned long a, unsigned int b, char *c) {
	return gps->l;
}
void rs_7_00_14_1(int a) {
	char t = *gp;
	jc = t;
}
void rs_7_00_14_2(int a) {
	gl2 <<= 15;
}
void rs_7_00_14_3(int a) {
	int i = ji;
	char t = jc;
	for (i = a; i > 0; i--) { if (i != 0) gi = a % i; gs.l >>= (a & 15); gca[4] = t = gp[2]; }
}
void rs_7_00_14_4(int a) {
	gps->u >>= 13;
}
void rs_7_00_14_5(int a) {
	char t = jc;
	t++;
}
void rs_7_00_14_6(int a) {
	int i = ji;
	i = 0; while (i < a) { ++gi3; i++; }
}
void rs_7_00_15_1(long a) {
	int *t = gpi;
	jpi = t;
}
void rs_7_00_15_2(long a) {
	int i = ji;
	int u = gs.i;
	ji = u;
}
void rs_7_00_15_3(long a) {
	int i = ji;
	for (i = 0; i < 9; i++) { gl2 = ~(long)*gpi; if (gc2 != 0) gc = *gp % gc2; }
}
void rs_7_00_15_4(long a) {
	--gu;
}
void rs_7_00_15_5(long a) {
	int u = ji;
	if (gula[u] != 0) gul = gul % gula[u];
}
void rs_7_00_15_6(long a) {
	int i = ji;
	int *t = jpi;
	i = 2; do { gu >>= 7; gps->a[i] = *t; } while (--i > 0);
}
int rs_7_00_15_7(long a) {
	return 127;
}
void rs_7_00_16_1(unsigned long a, unsigned int b, unsigned char c) {
	int t = gi2 & 8;
	ji = t;
}
void rs_7_00_16_2(unsigned long a, unsigned int b, unsigned char c) {
	int t = ji;
	gi = t;
}
void rs_7_00_16_3(unsigned long a, unsigned int b, unsigned char c) {
	vl(~gpl[2]);
}
void rs_7_00_16_4(unsigned long a, unsigned int b, unsigned char c) {
	int i = ji;
	v0();
	i = 3; do { if (gla[c] != 0) gl2 = gps->l / gla[c]; } while (--i > 0);
}
void rs_7_00_16_5(unsigned long a, unsigned int b, unsigned char c) {
	gs.d = -gs.d;
}
int rs_7_00_16_6(unsigned long a, unsigned int b, unsigned char c) {
	return gi2 * 7;
}
void rs_7_00_17_0(long a) {
	char *t = gp;
	jp = t;
}
void rs_7_00_17_1(long a) {
	a = (gps->u != 256 || gu2 ? (gla[1] * 5L) : (gla[1] & 1L));
}
void rs_7_00_17_2(long a) {
	*gpi = gps->a[1];
}
void rs_7_00_17_3(long a) {
	gca[0] >>= 3;
}
void rs_7_00_17_4(long a) {
	char *t = jp;
	if (guc) { guca[1] = (guca[4] ^ guca[2]) * ((unsigned char)(gc < 4)); gp = t; gua[7] = gua[5] | gua[3]; } else { if (r2(gi2, 218) && gs.u & 0x8) guc += guc ^ 255; }
}
unsigned long rs_7_00_17_5(long a) {
	return 4UL;
}
void rs_7_00_18_0(char a) {
	gda[3] = gd - gs.d;
}
void rs_7_00_18_1(char a) {
	vd((gc < gc2 ? gd2 : gd));
}
void rs_7_00_18_2(char a) {
	gp = gps->p;
}
void rs_7_00_18_3(char a) {
	gula[0] = 61603UL;
}
void rs_7_00_18_4(char a) {
	gula[a] = gul - 1UL;
}
int * rs_7_00_18_5(char a) {
	return gpi + a;
}
void rs_7_00_19_1(void) {
	char t = 4;
	jc = t;
}
void rs_7_00_19_2(void) {
	double u = gs.d - gda[1];
	jd = u;
}
void rs_7_00_19_3(void) {
	gps->a[2] += gi & gs.a[6];
}
void rs_7_00_19_4(void) {
	char t = jc;
	vc(t);
}
void rs_7_00_19_5(void) {
	gl++;
}
void rs_7_00_19_6(void) {
	int i = ji;
	double u = jd;
	v0();
	i = 8; do { if (gu2 != 0) gps->u = gu2 / gu2; if (gl != 0) gpl[3] = *gpl / gl; gpi[2] = *gpi / 10; } while (--i > 0);
}
int rs_7_00_19_7(void) {
	int i = ji;
	v0();
	return (gs.i & (int)gu) % 100;
}
void rs_7_01_00_0(unsigned char a, char b, double c) {
	unsigned int t = gua[3] >> 9;
	ju = t;
}
void rs_7_01_00_1(unsigned char a, char b, double c) {
	unsigned int t = ju;
	switch (gps->c) { case 0: gl = -7602L * 5L; break; case 1: gps->c = gc2 = b; break; case 2: gi = *gpi << (t & 15); break; case 3: v1(256); break; case 4: gs.a[t] -= gi; break; case 5: c += 2.5; break; }
}
void rs_7_01_00_2(unsigned char a, char b, double c) {
	gia[3] = gi3 & 16;
}
int * rs_7_01_00_3(unsigned char a, char b, double c) {
	unsigned int t = ju;
	v0();
	return &gia[t];
}
void rs_7_01_01_0(void) {
	int t = ~2;
	ji = t;
}
void rs_7_01_01_1(void) {
	gps->u = (unsigned int)5UL;
}
void rs_7_01_01_2(void) {
	switch (gs.i) { case 2: vd(gs.d); break; case 3: gula[3] /= 2UL; break; case 10: v0(); break; default: gul = gul | 0x10000UL; break; }
}
void rs_7_01_01_3(void) {
	int t = ji;
	v0();
	gps->c = (gca[t] + gc) - gs.c;
}
int * rs_7_01_01_4(void) {
	int t = ji;
	v0();
	return gpi + t;
}
void rs_7_01_02_0(int a, unsigned int b, int c) {
	unsigned long t = gula[a] - gula[7];
	jul = t;
}
void rs_7_01_02_1(int a, unsigned int b, int c) {
	vu(gu << 5);
}
void rs_7_01_02_2(int a, unsigned int b, int c) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
void rs_7_01_02_3(int a, unsigned int b, int c) {
	++b;
}
unsigned int rs_7_01_02_4(int a, unsigned int b, int c) {
	return ((unsigned int)guc) >> (c & 15);
}
void rs_7_01_03_0(unsigned int a, int b) {
	gul <<= 25;
}
void rs_7_01_03_1(unsigned int a, int b) {
	if (gpl[1] != 0) gpl[2] = gpl[2] % gpl[1];
}
void rs_7_01_03_2(unsigned int a, int b) {
	gl2 = gps->l = 62405L;
}
void rs_7_01_03_3(unsigned int a, int b) {
	switch (gi2) { case 0: v0(); break; case 1: v2(gi2, gi2); break; case 2: case 3: vs(gps); break; case 4: gi2 = 256 | (int)gca[1]; break; default: b = *gpi ^ gs.i; break; }
}
void rs_7_01_03_4(unsigned int a, int b) {
	gpi = &gia[2];
}
int rs_7_01_03_5(unsigned int a, int b) {
	return (((unsigned char)gla[b]) > ((unsigned char)(guc != 141)));
}
void rs_7_01_04_0(unsigned int a) {
	gua[a] = gua[5] + gu2;
}
void rs_7_01_04_1(unsigned int a) {
	if ((gi = gs.i) < 16) { if (a != 0) gps->u = 1 / a; }
}
unsigned long rs_7_01_04_2(unsigned int a) {
	return gula[a] + (0x10000UL | gula[a]);
}
void rs_7_01_05_1(void) {
	char t = (char)(127 <= gpi[2]);
	jc = t;
}
void rs_7_01_05_2(void) {
	guc = guca[7] - -guc;
}
void rs_7_01_05_3(void) {
	int i = ji;
	char t = jc;
	for (i = 0; i < 2; i++) { t &= gps->c * gc2; }
}
unsigned long rs_7_01_05_4(void) {
	return rul(gul) | ((unsigned long)((unsigned char)gps->c));
}
void rs_7_01_06_0(int a, long b) {
	int t = 87 >> (a & 15);
	ji = t;
}
void rs_7_01_06_1(int a, long b) {
	gul = gula[7];
}
void rs_7_01_06_2(int a, long b) {
	gul = ((unsigned long)gu2) << 9;
}
void rs_7_01_06_3(int a, long b) {
	int t = ji;
	guca[a] = guca[t] * guca[0];
}
void rs_7_01_06_4(int a, long b) {
	gia[0] = gi3;
}
int rs_7_01_06_5(int a, long b) {
	return gi2;
}
void rs_7_01_07_1(unsigned char a) {
	int *t = gpi;
	jpi = t;
}
void rs_7_01_07_2(unsigned char a) {
	char *u = gp;
	jp = u;
}
void rs_7_01_07_3(unsigned char a) {
	int i = ji;
	char *u = jp;
	for (i = 5; i > 0; i--) { v2(r2(gi2, gi3), gi); --gc2; if (u[3] != 0) *gp = gca[i] % u[3]; }
}
void rs_7_01_07_4(unsigned char a) {
	int i = ji;
	char *u = jp;
	v0();
	for (i = 0; i < 10; i++) { if (gul != 0) gul = ((unsigned long)gps->u) % gul; vl(gla[i] << 31); gu = ru(gps->u) + gs.u; }
}
void rs_7_01_07_5(unsigned char a) {
	vc(gp[3]);
}
void rs_7_01_07_6(unsigned char a) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_7_01_07_7(unsigned char a) {
	char *u = jp;
	v0();
	if (guca[a]) { v2(gi2, 1 << 7); if (gula[a] != 0) gula[a] = gul / gula[a]; if (gu2 != 0) gua[a] = gps->u / gu2; } else { vc(gc2 | 8); if (gula[a] != 0) gul = gul % gula[a]; *gp >>= 6; }
}
long rs_7_01_07_8(unsigned char a) {
	return gs.l;
}
void rs_7_01_08_0(long a, int b, unsigned char c) {
	unsigned int t = ru(0);
	ju = t;
}
void rs_7_01_08_1(long a, int b, unsigned char c) {
	int u = gs.i & (int)gul;
	v0();
	ji = u;
}
void rs_7_01_08_2(long a, int b, unsigned char c) {
	unsigned int t = ju;
	v0();
	t += t + 256;
}
void rs_7_01_08_3(long a, int b, unsigned char c) {
	int u = ji;
	v0();
	v1(u);
}
void rs_7_01_08_4(long a, int b, unsigned char c) {
	vl(gl2 + -80113L);
}
void rs_7_01_08_5(long a, int b, unsigned char c) {
	if (!b) { guca[2] = c + guca[b]; gc--; guc = (unsigned char)!(-23501L & a); }
}
void rs_7_01_08_6(long a, int b, unsigned char c) {
	gd -= gd2 - gs.d;
}
int rs_7_01_08_7(long a, int b, unsigned char c) {
	return (-gd2 >= (r0() ? gd : gd));
}
void rs_7_01_09_0(unsigned char a, unsigned int b, unsigned long c) {
	while (gi-- > 0) *gpi++ = 256;
}
void rs_7_01_09_1(unsigned char a, unsigned int b, unsigned long c) {
	if (*gpl != 0) *gpl = -54855L % *gpl;
}
void rs_7_01_09_2(unsigned char a, unsigned int b, unsigned long c) {
	gpl[2] = gpl[0] - gps->l;
}
void rs_7_01_09_3(unsigned char a, unsigned int b, unsigned long c) {
	gd -= gd / 10.0;
}
int rs_7_01_09_4(unsigned char a, unsigned int b, unsigned long c) {
	return ~(gs.a[0] << 14);
}
void rs_7_01_10_0(unsigned int a, char b) {
	unsigned long t = gul << 23;
	jul = t;
}
void rs_7_01_10_1(unsigned int a, char b) {
	unsigned long t = jul;
	t = gul;
}
void rs_7_01_10_2(unsigned int a, char b) {
	--a;
}
void rs_7_01_10_3(unsigned int a, char b) {
	unsigned long t = jul;
	t |= gul;
}
void rs_7_01_10_4(unsigned int a, char b) {
	v0();
}
void rs_7_01_10_5(unsigned int a, char b) {
	unsigned long t = jul;
	v0();
	gula[3] = t = rul(6UL + 44953UL);
}
char * rs_7_01_10_6(unsigned int a, char b) {
	return gp + b;
}
void rs_7_01_11_0(void) {
	++gu2;
}
void rs_7_01_11_1(void) {
	if (gps->c & 4) gi3 = gia[4] + (int)gul;
}
int rs_7_01_11_2(void) {
	return !gula[4];
}
void rs_7_01_12_0(void) {
	gca[2] = 42;
}
void rs_7_01_12_1(void) {
	if (32767 == ((unsigned int)guc)) gul = gul % 3UL;
}
void rs_7_01_12_2(void) {
	gl &= (long)(3L != gps->l);
}
void rs_7_01_12_3(void) {
	if (gps->i != 0) gia[4] = 1 / gps->i;
}
int rs_7_01_12_4(void) {
	return gpi[1];
}
void rs_7_01_13_0(unsigned int a) {
	unsigned long t = gula[a] + gula[0];
	jul = t;
}
void rs_7_01_13_1(unsigned int a) {
	unsigned long t = jul;
	--t;
}
void rs_7_01_13_2(unsigned int a) {
	gpi = &gia[6];
}
void rs_7_01_13_3(unsigned int a) {
	if (gi3 < 16) { if (gpl[3] != 0) *gpl = 99874L / gpl[3]; } else { gi3 = r2(gi2, gi); if (gca[2] != 0) gca[a] = gc / gca[2]; }
}
void rs_7_01_13_4(unsigned int a) {
	unsigned long t = jul;
	v0();
	if (gi) { gs.p = gps->p + a; t = (unsigned long)(guca[4] > (guca[a] * guc)); } else { gu2--; }
}
void rs_7_01_13_5(unsigned int a) {
	gpi = rpi(gps->i);
}
int rs_7_01_13_6(unsigned int a) {
	return ~(int)45;
}
void rs_7_01_14_0(long a, unsigned int b, unsigned long c) {
	unsigned char t = guc;
	juc = t;
}
void rs_7_01_14_1(long a, unsigned int b, unsigned long c) {
	gu2 = ru(-gu);
}
void rs_7_01_14_2(long a, unsigned int b, unsigned long c) {
	gp--;
}
void rs_7_01_14_3(long a, unsigned int b, unsigned long c) {
	unsigned char t = juc;
	v0();
	t -= 128 ^ t;
}
void rs_7_01_14_4(long a, unsigned int b, unsigned long c) {
	vs(gps);
}
unsigned int rs_7_01_14_5(long a, unsigned int b, unsigned long c) {
	return b - ((unsigned int)gc2);
}
void rs_7_01_15_1(int a, long b, long c) {
	int i = ji;
	for (i = 0; i < a; i++) { guca[0] = guc >> 6; }
}
void rs_7_01_15_2(int a, long b, long c) {
	if (*gpi != 0) gi = 100 % *gpi;
}
void rs_7_01_15_3(int a, long b, long c) {
	gpi = &gia[a];
}
void rs_7_01_15_4(int a, long b, long c) {
	gda[2] = gd;
}
void rs_7_01_15_5(int a, long b, long c) {
	gp--;
}
char rs_7_01_15_6(int a, long b, long c) {
	return (char)!gua[2];
}
void rs_7_01_16_0(int a, long b, double c) {
	int *t = rpi(255);
	jpi = t;
}
void rs_7_01_16_1(int a, long b, double c) {
	int *t = jpi;
	v0();
	t[a] = gs.i % 100;
}
void rs_7_01_16_2(int a, long b, double c) {
	v2(gi2, (255 >= guca[1]));
}
void rs_7_01_16_3(int a, long b, double c) {
	gu2 = ru(gu) * 6;
}
void rs_7_01_16_4(int a, long b, double c) {
	gc = -(char)a;
}
int rs_7_01_16_5(int a, long b, double c) {
	int *t = jpi;
	v0();
	return (gi2 | t[a]) % 10;
}
void rs_7_01_17_0(unsigned long a, long *b) {
	int t = gi2;
	ji = t;
}
void rs_7_01_17_1(unsigned long a, long *b) {
	unsigned long u = rul(gula[0]);
	jul = u;
}
void rs_7_01_17_2(unsigned long a, long *b) {
	++guc;
}
void rs_7_01_17_3(unsigned long a, long *b) {
	if (!gps->i) vp(rp());
}
void rs_7_01_17_4(unsigned long a, long *b) {
	int t = ji;
	v0();
	if (gi2 != 0) t = gi % gi2;
}
void rs_7_01_17_5(unsigned long a, long *b) {
	int t = ji;
	unsigned long u = jul;
	v0();
	u >>= (t & 15);
}
long rs_7_01_17_6(unsigned long a, long *b) {
	return (gl2 = b[1]);
}
void rs_7_01_18_0(unsigned char a) {
	int *t = gpi;
	jpi = t;
}
unsigned int rs_7_01_18_1(unsigned char a) {
	if (r0() || gul) return (guca[a] & 0x7 ? gps->u : 5);
}
void rs_7_01_18_2(unsigned char a) {
	gla[a] = gpl[3] << 30;
}
void rs_7_01_18_3(unsigned char a) {
	if (gpl[2] >= gla[2]) { gc2 &= gca[0]; if (gu != 0) gs.u = 4801 / gu; } else { if (gc2 != 0) gc = 6 / gc2; gs.i = *gpi = 4; }
}
void rs_7_01_18_4(unsigned char a) {
	if (r2(gi2, gi)) { vl((long)gula[a] << 17); }
}
void rs_7_01_18_5(unsigned char a) {
	gps->i = 256;
}
void rs_7_01_18_6(unsigned char a) {
	int *t = jpi;
	v0();
	v1(*t);
}
unsigned int rs_7_01_18_7(unsigned char a) {
	return (unsigned int)(char)!*gpl;
}
void rs_7_01_19_0(unsigned char a, long b, long c) {
	char t = (char)gu2;
	jc = t;
}
void rs_7_01_19_1(unsigned char a, long b, long c) {
	unsigned long u = gula[a];
	jul = u;
}
void rs_7_01_19_2(unsigned char a, long b, long c) {
	char t = jc;
	unsigned long u = jul;
	u = gula[t] = 9UL;
}
void rs_7_01_19_3(unsigned char a, long b, long c) {
	gs.d -= gd2 / 10.0;
}
void rs_7_01_19_4(unsigned char a, long b, long c) {
	gi3++;
}
void rs_7_01_19_5(unsigned char a, long b, long c) {
	switch (gu) { case 0: vp(gp); case 1: case 2: v0(); break; }
}
void rs_7_02_00_1(int a, unsigned int b, int *c) {
	unsigned int t = b << 3;
	ju = t;
}
void rs_7_02_00_2(int a, unsigned int b, int *c) {
	gul = (gul / 3UL) >> (b & 15);
}
void rs_7_02_00_3(int a, unsigned int b, int *c) {
	int i = ji;
	for (i = 9; i > 0; i--) { if (gula[i] != 0) gul = gula[i] / gula[i]; }
}
void rs_7_02_00_4(int a, unsigned int b, int *c) {
	unsigned int t = ju;
	gu = t;
}
int * rs_7_02_00_5(int a, unsigned int b, int *c) {
	return rpi(gpi[2] % 4);
}
void rs_7_02_01_0(int a, long *b) {
	guc = guc ^ 1;
}
void rs_7_02_01_1(int a, long *b) {
	gp[3] = (char)(65536L > gs.l);
}
void rs_7_02_01_2(int a, long *b) {
	v1(1 % 2);
}
void rs_7_02_01_3(int a, long *b) {
	guc -= guca[a] + 128;
}
char rs_7_02_01_4(int a, long *b) {
	return rc(gps->a[2]);
}
void rs_7_02_02_0(long a, int *b, double c) {
	char *t = gp;
	jp = t;
}
void rs_7_02_02_1(long a, int *b, double c) {
	long u = a;
	jl = u;
}
void rs_7_02_02_2(long a, int *b, double c) {
	long u = jl;
	vl(u);
}
void rs_7_02_02_3(long a, int *b, double c) {
	char *t = jp;
	v0();
	gp = t;
}
unsigned int rs_7_02_02_4(long a, int *b, double c) {
	if (c == 0.25 || gps->a[6]) return (unsigned int)gula[5];
}
void rs_7_02_02_5(long a, int *b, double c) {
	vu(gu);
}
void rs_7_02_02_6(long a, int *b, double c) {
	gula[6] = gul = (unsigned long)!gca[7];
}
unsigned int rs_7_02_02_7(long a, int *b, double c) {
	long u = jl;
	v0();
	return (gu2 + gu) - gs.u;
}
void rs_7_02_03_1(int a) {
	char *t = &gca[a];
	jp = t;
}
void rs_7_02_03_2(int a) {
	while (a > 0) { gc2 += *gp++; a--; }
}
void rs_7_02_03_3(int a) {
	int i = ji;
	char *t = jp;
	for (i = a; i > 0; i--) { t[3] = 4 ^ t[i]; if (gs.u != 0) gu2 = gua[i] / gs.u; *gp = (16439 == gu2 ? gps->c : (' ')); }
}
void rs_7_02_03_4(int a) {
	gul = gula[a] = 11736UL;
}
int rs_7_02_03_5(int a) {
	return -gi / 16;
}
void rs_7_02_04_0(int a) {
	v1(gi3 + gi2);
}
void rs_7_02_04_1(int a) {
	gs.i = (int)gla[a];
}
void rs_7_02_04_2(int a) {
	gs.a[1] = gia[5] - gi3;
}
void rs_7_02_04_3(int a) {
	guc = 190;
}
void rs_7_02_04_4(int a) {
	if (gua[5]) { gul = (r2(a, gi) ? gul : 23906UL) >> 29; gps->a[a] *= 6; if (gca[a] != 0) gca[5] = 'a' / gca[a]; } else { gpi = gpi + a; if (*gp != 0) gc2 = gs.c % *gp; if (gla[6] != 0) gs.l = *gpl % gla[6]; }
}
long rs_7_02_04_5(int a) {
	return rl(-(-73264L));
}
void rs_7_02_05_0(void) {
	while (gi-- > 0) *gp++ = 94;
}
void rs_7_02_05_1(void) {
	gp[2] -= rc(gi);
}
int * rs_7_02_05_2(void) {
	if (guca[6] == guca[7]) return rpi(gpi[3]);
}
void rs_7_02_05_3(void) {
	if (49880UL >= gula[0]) { gs.p = &gca[0]; gps->a[1] = (int)gl2 % 4; gs.u *= 8; }
}
int * rs_7_02_05_4(void) {
	return gpi + 1;
}
void rs_7_02_06_0(char a, unsigned int b) {
	v1(gs.a[6]);
}
void rs_7_02_06_1(char a, unsigned int b) {
	switch (gps->i) { case 0: case 1: gp = gps->p; break; default: v2(gi2, gi); break; }
}
void rs_7_02_06_2(char a, unsigned int b) {
	if (*gp > a) if (gps->l != 0) gl2 = gl2 / gps->l;
}
void rs_7_02_06_3(char a, unsigned int b) {
	gs.p = rp();
}
void rs_7_02_06_4(char a, unsigned int b) {
	if (b >= gu2) { if (gl != 0) gl = gl2 / gl; gps->u /= 2; } else { gs.u *= 7; }
}
char rs_7_02_06_5(char a, unsigned int b) {
	return gps->c;
}
void rs_7_02_07_1(unsigned long a, char *b) {
	gua[6] %= 7;
}
void rs_7_02_07_2(unsigned long a, char *b) {
	int i = ji;
	for (i = 0; i < 6; i++) { if (gu != 0) gu2 = gu % gu; gul = gula[i] = gula[i] % 16UL; if (gc != 0) gps->c = 8 / gc; }
}
void rs_7_02_07_3(unsigned long a, char *b) {
	vp(b + 1);
}
char * rs_7_02_07_4(unsigned long a, char *b) {
	if (0x10000UL > gul) return gp + 1;
}
void rs_7_02_07_5(unsigned long a, char *b) {
	guc &= (unsigned char)(gul > 6UL);
}
char * rs_7_02_07_6(unsigned long a, char *b) {
	return rp();
}
void rs_7_02_08_0(char a, struct st *b) {
	gua[6] = gua[a];
}
void rs_7_02_08_1(char a, struct st *b) {
	b->l = gl2 >> 13;
}
void rs_7_02_09_0(int a) {
	int *t = gpi + a;
	jpi = t;
}
void rs_7_02_09_1(int a) {
	char u = (char)gua[1];
	jc = u;
}
void rs_7_02_09_2(int a) {
	gps->l = 5L * 8L;
}
void rs_7_02_09_3(int a) {
	v0();
}
void rs_7_02_09_4(int a) {
	char u = jc;
	v0();
	vc(u);
}
void rs_7_02_09_5(int a) {
	int *t = jpi;
	v0();
	gpi = t;
}
int rs_7_02_09_6(int a) {
	return r2(gi2, ~gi2);
}
void rs_7_02_10_0(void) {
	gp[1] = rc(r2(gi2, gi));
}
void rs_7_02_10_1(void) {
	gpi = &gia[1];
}
void rs_7_02_10_2(void) {
	gul = ~(73062UL >> 14);
}
long rs_7_02_10_3(void) {
	if (gi & 1) return (long)gula[5];
}
void rs_7_02_10_4(void) {
	guc--;
}
long rs_7_02_10_5(void) {
	return *gpl;
}
void rs_7_02_11_0(double a, double b) {
	int t = ~gs.a[2];
	ji = t;
}
void rs_7_02_11_1(double a, double b) {
	b = a;
}
void rs_7_02_11_2(double a, double b) {
	int t = ji;
	gula[t] = gul = (gula[1] << 29) << (t & 15);
}
void rs_7_02_11_3(double a, double b) {
	int t = ji;
	guca[t] ^= 8 | 128;
}
int rs_7_02_11_4(double a, double b) {
	int t = ji;
	return t << 11;
}
void rs_7_02_12_0(void) {
	char *t = gp + 1;
	jp = t;
}
void rs_7_02_12_1(void) {
	v2((gc2 ? 256 : gps->a[3]), gi);
}
void rs_7_02_12_2(void) {
	gp[3] = gp[3] << 2;
}
void rs_7_02_12_3(void) {
	char *t = jp;
	v0();
	if (guc < 152) *t /= 2;
}
void rs_7_02_12_4(void) {
	gl += rl((long)gc2);
}
unsigned int rs_7_02_12_5(void) {
	return gua[4];
}
void rs_7_02_13_1(unsigned long a, unsigned long b) {
	int t = gi;
	ji = t;
}
void rs_7_02_13_2(unsigned long a, unsigned long b) {
	int u = ~gpi[0];
	ji = u;
}
void rs_7_02_13_3(unsigned long a, unsigned long b) {
	int t = ji;
	v1(t);
}
void rs_7_02_13_4(unsigned long a, unsigned long b) {
	guca[0] = guc = (guca[4] >> 4) * (0 * guca[6]);
}
void rs_7_02_13_5(unsigned long a, unsigned long b) {
	int u = ji;
	v0();
	gi = u;
}
void rs_7_02_13_6(unsigned long a, unsigned long b) {
	int i = ji;
	v0();
	i = 0; while (i < 14) { if (gc2 != 0) gp[3] = gc2 % gc2; if (gia[i] != 0) gia[i] = gps->i % gia[i]; guc++; i++; }
}
void rs_7_02_13_7(unsigned long a, unsigned long b) {
	*gpl = gpl[1];
}
void rs_7_02_13_8(unsigned long a, unsigned long b) {
	gs.c = -gc2;
}
unsigned long rs_7_02_13_9(unsigned long a, unsigned long b) {
	return 0x10000UL;
}
void rs_7_02_14_1(int *a) {
	unsigned long t = 4UL >> 3;
	jul = t;
}
void rs_7_02_14_2(int *a) {
	char *u = gs.p;
	jp = u;
}
void rs_7_02_14_3(int *a) {
	gi2 /= 3;
}
void rs_7_02_14_4(int *a) {
	gu--;
}
void rs_7_02_14_5(int *a) {
	int i = ji;
	for (i = 0; i < 15; i++) { *gp = gc2 = gc - gca[i]; gi2 = (gi3 % 2) >> 3; }
}
void rs_7_02_14_6(int *a) {
	if (gl != 0) gs.l = gl % gl;
}
void rs_7_02_14_7(int *a) {
	int i = ji;
	char *u = jp;
	for (i = 0; i < 8; i++) { ++gl2; *u = (char)gps->i; }
}
void rs_7_02_14_8(int *a) {
	unsigned long t = jul;
	gul = t;
}
int rs_7_02_14_9(int *a) {
	return gi2 | 127;
}
void rs_7_02_15_1(char a, struct st *b, unsigned int c) {
	int i = ji;
	gps->i = 1 >> (c & 15);
}
void rs_7_02_15_2(char a, struct st *b, unsigned int c) {
	gul >>= 6;
}
void rs_7_02_15_3(char a, struct st *b, unsigned int c) {
	int i = ji;
	i = 0; while (i < 15) { v2(1 << 6, gi); i++; }
}
void rs_7_02_15_4(char a, struct st *b, unsigned int c) {
	int i = ji;
	v0();
	if (r2(gi2, b->i)) { --gl2; guc--; }
}
void rs_7_02_15_5(char a, struct st *b, unsigned int c) {
	b->u = -gu2;
}
unsigned int rs_7_02_15_6(char a, struct st *b, unsigned int c) {
	return b->u;
}
void rs_7_02_16_0(long a, int *b, long c) {
	unsigned char t = guc;
	juc = t;
}
void rs_7_02_16_1(long a, int *b, long c) {
	v1(r2((int)*gpl, gi));
}
void rs_7_02_16_2(long a, int *b, long c) {
	unsigned char t = juc;
	v0();
	if (gl2 != 65536L && !gul) { b = gpi; gps->u <<= (t & 15); }
}
void rs_7_02_17_0(double a, long b) {
	b -= (long)(gu2 == gua[4]);
}
void rs_7_02_17_1(double a, long b) {
	b--;
}
void rs_7_02_17_2(double a, long b) {
	vu(gps->u ^ 26657);
}
void rs_7_02_17_3(double a, long b) {
	gul = (gul % 10UL) ^ ((unsigned long)gi3);
}
void rs_7_02_17_4(double a, long b) {
	gca[6] = (' ') | '0';
}
char * rs_7_02_17_5(double a, long b) {
	return gps->p + 1;
}
void rs_7_02_18_0(struct st *a, char b, long *c) {
	long t = *gpl * 2L;
	jl = t;
}
void rs_7_02_18_1(struct st *a, char b, long *c) {
	char u = gca[1];
	jc = u;
}
void rs_7_02_18_2(struct st *a, char b, long *c) {
	vd(gda[3] / 100.0);
}
void rs_7_02_18_3(struct st *a, char b, long *c) {
	gula[0] = gul << (b & 15);
}
void rs_7_02_18_4(struct st *a, char b, long *c) {
	long t = jl;
	v0();
	vl(t);
}
void rs_7_02_18_5(struct st *a, char b, long *c) {
	gp = rp();
}
void rs_7_02_18_6(struct st *a, char b, long *c) {
	char u = jc;
	v0();
	vc(u);
}
void rs_7_02_19_1(double a) {
	double t = -a;
	jd = t;
}
void rs_7_02_19_2(double a) {
	--gp;
}
void rs_7_02_19_3(double a) {
	v2(255, gi);
}
void rs_7_02_19_4(double a) {
	double t = jd;
	v0();
	vd(t);
}
void rs_7_02_19_5(double a) {
	if (*gpl > gl) { gl--; if (gul != 0) gul = gul / gul; } else { vu(gua[7] | gps->u); gu = ru(gu ^ gu2); }
}
void rs_7_02_19_6(double a) {
	int i = ji;
	v0();
	i = 13; do { gula[i] = 0x10000UL; gla[6] = 53013L << 21; gu2 = gua[i] = gu2 * 2; } while (--i > 0);
}
void rs_7_02_19_7(double a) {
	if (!gu) v2(gi2, gpi[0] | gi2);
}
int * rs_7_02_19_8(double a) {
	return rpi(gia[4]);
}
void rs_7_03_00_0(int a) {
	if (100 < gps->i) { gd = gd - (gs.d + (double)gl); if (gs.c != 0) gca[0] = gs.c / gs.c; } else { if (gla[0] != 0) gpl[2] = gps->l % gla[0]; gps->u = gua[2]; }
}
void rs_7_03_00_1(int a) {
	gl2--;
}
void rs_7_03_00_2(int a) {
	if (gi3 != 0) gs.i = gps->a[a] / gi3;
}
void rs_7_03_00_3(int a) {
	if (!gu2) gp = &gca[a];
}
void rs_7_03_00_4(int a) {
	gula[4] = gul = rul(gul) >> 27;
}
long rs_7_03_00_5(int a) {
	return (gs.l * 6L) & -gl;
}
void rs_7_03_01_0(void) {
	long t = gla[1] - (long)gca[4];
	jl = t;
}
void rs_7_03_01_1(void) {
	if ((gi = gs.i) && gps->i < 127) { guca[2] = guc; ++gu; gul += rul(0x10000UL); } else { gu--; guca[5] /= 10; }
}
void rs_7_03_01_2(void) {
	long t = jl;
	v0();
	gl = t;
}
void rs_7_03_01_3(void) {
	gu2 |= gu2 - gs.u;
}
void rs_7_03_01_4(void) {
	if (gul) vp(gs.p + 1);
}
void rs_7_03_01_5(void) {
	--gul;
}
int rs_7_03_01_6(void) {
	return (int)(gc2 & gca[2]);
}
void rs_7_03_02_0(void) {
	int t = (int)gula[3];
	ji = t;
}
void rs_7_03_02_1(void) {
	int t = ji;
	gi = t;
}
void rs_7_03_02_2(void) {
	guca[0] = (unsigned char)gul;
}
void rs_7_03_02_3(void) {
	--gpi;
}
void rs_7_03_02_4(void) {
	gu2++;
}
void rs_7_03_02_5(void) {
	gs.d = gd2 + gda[2];
}
void rs_7_03_02_6(void) {
	gs.d += gs.d + gs.d;
}
char * rs_7_03_02_7(void) {
	int t = ji;
	return gp + t;
}
void rs_7_03_03_0(void) {
	unsigned char t = guc ^ 128;
	juc = t;
}
void rs_7_03_03_1(void) {
	unsigned char t = juc;
	gla[t] += *gpl;
}
void rs_7_03_03_2(void) {
	guc |= 255;
}
char * rs_7_03_03_3(void) {
	return gps->p;
}
void rs_7_03_04_0(void) {
	char *t = gs.p;
	jp = t;
}
void rs_7_03_04_1(void) {
	unsigned char u = guca[7];
	juc = u;
}
void rs_7_03_04_2(void) {
	gul %= 7UL;
}
void rs_7_03_04_3(void) {
	char *t = jp;
	gp = t;
}
void rs_7_03_04_4(void) {
	v0();
}
void rs_7_03_04_5(void) {
	if (gs.l != 0) gs.l = *gpl % gs.l;
}
void rs_7_03_04_6(void) {
	unsigned char u = juc;
	v0();
	v1(u);
}
void rs_7_03_04_7(void) {
	if (gia[3] >= gpi[1]) gs.d += 0.25;
}
void rs_7_03_04_8(void) {
	--gi3;
}
char rs_7_03_04_9(void) {
	return ('a' + gc) % 3;
}
void rs_7_03_05_0(int a) {
	unsigned int t = gs.u - gua[6];
	ju = t;
}
void rs_7_03_05_1(int a) {
	vp(&gca[a]);
}
void rs_7_03_05_2(int a) {
	unsigned int t = ju;
	v0();
	t = 13981 + (256 + 1);
}
void rs_7_03_05_3(int a) {
	v1(gi + a);
}
void rs_7_03_05_4(int a) {
	if (gul != 0) gula[5] = gul / gul;
}
unsigned long rs_7_03_05_5(int a) {
	return ~(gul + gula[5]);
}
void rs_7_03_06_0(void) {
	while (gi-- > 0) *gpi++ = 1;
}
void rs_7_03_06_1(void) {
	gua[5] = gua[7] << 2;
}
int rs_7_03_06_2(void) {
	return ~(gi << 11);
}
void rs_7_03_07_0(void) {
	unsigned long u = jul;
	unsigned int t = gps->u;
	ju = t;
}
void rs_7_03_07_1(void) {
	unsigned int t = ju;
	unsigned long u = rul(gula[t]);
	jul = u;
}
void rs_7_03_07_2(void) {
	gl = gps->l = gpl[3];
}
void rs_7_03_07_3(void) {
	gu--;
}
void rs_7_03_07_4(void) {
	gc *= 10;
}
void rs_7_03_07_5(void) {
	unsigned int t = ju;
	v0();
	vu(t);
}
void rs_7_03_07_6(void) {
	unsigned long u = jul;
	v0();
	vl((long)u);
}
int rs_7_03_07_7(void) {
	return gi3;
}
void rs_7_03_08_0(void) {
	unsigned char t = guca[2] ^ guca[1];
	juc = t;
}
void rs_7_03_08_1(void) {
	unsigned char t = juc;
	if (t & 2) { --gul; gpi = gpi + t; gla[5] = 26149L & gl; } else { gul = (unsigned long)((gps->i < gs.a[t] ? 0.5 : gd2) == 0.5); }
}
void rs_7_03_08_2(void) {
	switch (gs.l) { case 3L: case 20L: v0(); break; }
}
char * rs_7_03_08_3(void) {
	unsigned char t = juc;
	v0();
	if (gula[t] == 0x10000UL) return gp;
}
char * rs_7_03_08_4(void) {
	unsigned char t = juc;
	v0();
	return &gca[t];
}
void rs_7_03_09_1(void) {
	int t = gi2;
	ji = t;
}
void rs_7_03_09_2(void) {
	gu = (unsigned int)gi;
}
void rs_7_03_09_3(void) {
	gu2++;
}
void rs_7_03_09_4(void) {
	int i = ji;
	for (i = 0; i < 13; i++) { gu = gps->u; }
}
void rs_7_03_09_5(void) {
	int t = ji;
	guc = guca[t];
}
int rs_7_03_09_6(void) {
	return 2;
}
void rs_7_03_10_0(unsigned int a, long *b) {
	char *t = &gca[a];
	jp = t;
}
void rs_7_03_10_1(unsigned int a, long *b) {
	int u = 127;
	ji = u;
}
void rs_7_03_10_2(unsigned int a, long *b) {
	gul = (gula[a] - gul) + (gula[a] - 13698UL);
}
void rs_7_03_10_3(unsigned int a, long *b) {
	char *t = jp;
	t++;
}
void rs_7_03_10_4(unsigned int a, long *b) {
	while (gi-- > 0) { if (*b == 81351L) break; b++; }
}
void rs_7_03_10_5(unsigned int a, long *b) {
	int u = ji;
	gc = gp[1] >> (u & 7);
}
int rs_7_03_10_6(unsigned int a, long *b) {
	int u = ji;
	if (guc || guca[u] < ((unsigned char)gs.l)) return r0();
}
int rs_7_03_10_7(unsigned int a, long *b) {
	return -351;
}
void rs_7_03_11_0(void) {
	double t = gda[0] * gd2;
	jd = t;
}
void rs_7_03_11_1(void) {
	double t = jd;
	switch (gs.i) { case 1: v1(*gpi); case 3: vp(gp + 1); break; case 16: case 20: vu(gps->u); case 100: v2(gia[3], gi); break; case 200: vd(t); break; default: gi3 = 256 - gi2; break; }
}
void rs_7_03_11_2(void) {
	guca[0] >>= 3;
}
void rs_7_03_11_3(void) {
	gc2 = *gp = gp[3];
}
void rs_7_03_11_4(void) {
	if (gia[1]) { if (gs.i != 0) gia[0] = gps->i / gs.i; } else { if (gpl[0] != 0) gla[6] = gpl[2] % gpl[0]; if (gula[6] != 0) gul = gula[3] / gula[6]; if (gua[1] != 0) gu = 255 % gua[1]; }
}
void rs_7_03_11_5(void) {
	vl(gl2 + -33274L);
}
int rs_7_03_11_6(void) {
	return (*gpi = 256);
}
void rs_7_03_12_0(unsigned int a, long b, int c) {
	long t = (long)gs.c;
	jl = t;
}
void rs_7_03_12_1(unsigned int a, long b, int c) {
	gu2 = gu = ((unsigned int)gca[c]) & ((unsigned int)guca[a]);
}
void rs_7_03_12_2(unsigned int a, long b, int c) {
	long t = jl;
	switch (gps->c) { case 1: vl(t); break; case 8: vs(gps); break; case 10: vl(gla[5]); case 16: vd(gd); break; case 20: v2(gi2, 256); break; case 100: c <<= (a & 15); }
}
void rs_7_03_12_3(unsigned int a, long b, int c) {
	gc += gs.c;
}
void rs_7_03_12_4(unsigned int a, long b, int c) {
	guca[2] = guca[c] >> 6;
}
unsigned int rs_7_03_12_5(unsigned int a, long b, int c) {
	return gua[1] / 16;
}
void rs_7_03_13_0(unsigned char a, char b) {
	int *t = gpi;
	jpi = t;
}
void rs_7_03_13_1(unsigned char a, char b) {
	unsigned char u = ~guc;
	juc = u;
}
void rs_7_03_13_2(unsigned char a, char b) {
	if (gs.d > 10.0) if (gula[7] != 0) gul = gula[b] % gula[7];
}
void rs_7_03_13_3(unsigned char a, char b) {
	int *t = jpi;
	switch (gl2) { case 1L: gd2 *= gd; break; case 200L: t = gpi + b; break; }
}
void rs_7_03_13_4(unsigned char a, char b) {
	unsigned char u = juc;
	vu(gs.u + gua[a]);
}
long rs_7_03_13_5(unsigned char a, char b) {
	return gps->l;
}
void rs_7_03_14_1(int a, long *b) {
	int t = ~gi3;
	ji = t;
}
void rs_7_03_14_2(int a, long *b) {
	int u = gi3 >> 6;
	ji = u;
}
void rs_7_03_14_3(int a, long *b) {
	if (gps->c != 0) gca[a] = gs.c / gps->c;
}
void rs_7_03_14_4(int a, long *b) {
	if (*gpl) gs.d = gda[3] + gda[2];
}
void rs_7_03_14_5(int a, long *b) {
	int i = ji;
	int t = ji;
	for (i = 12; i > 0; i--) { gul = (unsigned long)(((unsigned char)gca[i]) << (t & 7)); }
}
void rs_7_03_14_6(int a, long *b) {
	int i = ji;
	int u = ji;
	i = 0; while (i < 3) { if (gu != 0) gua[a] = gps->u % gu; gps->c = ~*gp + ('A' - 64); gpi = gpi + u; i++; }
}
int * rs_7_03_14_7(int a, long *b) {
	return gpi;
}
void rs_7_03_15_0(long a, int b, char c) {
	unsigned long t = gul / 10UL;
	jul = t;
}
void rs_7_03_15_1(long a, int b, char c) {
	unsigned char u = guca[5] & guca[c];
	juc = u;
}
void rs_7_03_15_2(long a, int b, char c) {
	switch (b) { case 8: v2(gi2, 255); break; case 20: vl(gpl[2]); break; }
}
void rs_7_03_15_3(long a, int b, char c) {
	unsigned long t = jul;
	v0();
	v1((t >= 0x10000UL));
}
void rs_7_03_15_4(long a, int b, char c) {
	unsigned char u = juc;
	v0();
	guc = u;
}
char * rs_7_03_15_5(long a, int b, char c) {
	return gs.p;
}
void rs_7_03_16_1(long a, char b) {
	int t = 16;
	ji = t;
}
void rs_7_03_16_2(long a, char b) {
	int t = ji;
	if (gla[t] == *gpl || gc2) vc(rc(t));
}
void rs_7_03_16_3(long a, char b) {
	gla[7] = a;
}
void rs_7_03_16_4(long a, char b) {
	int i = ji;
	v0();
	i = 10; do { gul = (r2(256, gi) ? gula[i] : gul) + gula[i]; if (gi3 != 0) gia[i] = gpi[1] % gi3; } while (--i > 0);
}
void rs_7_03_16_5(long a, char b) {
	int t = ji;
	v0();
	if (54 != 128) guca[7] = guca[t];
}
int * rs_7_03_16_6(long a, char b) {
	return gpi;
}
void rs_7_03_17_0(long a, unsigned char b) {
	if ((gi = 127)) guca[1] |= guc - 0;
}
void rs_7_03_17_1(long a, unsigned char b) {
	gula[2] = rul((gula[6] == 0UL ? gul : gul));
}
int * rs_7_03_17_2(long a, unsigned char b) {
	return rpi(gi3);
}
void rs_7_03_18_0(int a, double b) {
	unsigned char t = (((unsigned long)a) > 4UL ? guca[a] : guca[a]);
	juc = t;
}
void rs_7_03_18_1(int a, double b) {
	unsigned char t = juc;
	char *u = gps->p + t;
	jp = u;
}
void rs_7_03_18_2(int a, double b) {
	vu(gua[a]);
}
void rs_7_03_18_3(int a, double b) {
	unsigned char t = juc;
	v0();
	gpi = gpi + t;
}
void rs_7_03_18_4(int a, double b) {
	unsigned char t = juc;
	char *u = jp;
	v0();
	if (gula[t] >= 0x10000UL) { gpl[3] = gpl[2] + gl; } else { gula[3] += 0UL; gp = u; }
}
unsigned int rs_7_03_18_5(int a, double b) {
	return ru(1 >> 6);
}
void rs_7_03_19_0(char a, long b, int c) {
	unsigned long t = ~gul;
	jul = t;
}
void rs_7_03_19_1(char a, long b, int c) {
	vs(gps);
}
void rs_7_03_19_2(char a, long b, int c) {
	unsigned long t = jul;
	v0();
	gul = t;
}
void rs_7_03_19_3(char a, long b, int c) {
	if ((gl2 = gps->l)) { vu((unsigned int)(gua[2] < gs.u)); }
}
int rs_7_03_19_4(char a, long b, int c) {
	return ~r1(gpi[0]);
}
void rs_7_04_00_0(void) {
	unsigned int t = gu >> 7;
	ju = t;
}
void rs_7_04_00_1(void) {
	unsigned long u = gul;
	jul = u;
}
void rs_7_04_00_2(void) {
	unsigned int t = ju;
	vu(t);
}
void rs_7_04_00_3(void) {
	unsigned long u = jul;
	v0();
	vl((long)u);
}
void rs_7_04_00_4(void) {
	gc2 = gc = ('a' + -42) | ((char)(gl < 3L));
}
void rs_7_04_00_5(void) {
	guc = -(guca[1] & guc);
}
void rs_7_04_00_6(void) {
	gd2 += gs.d - gd;
}
int rs_7_04_00_7(void) {
	return (gi2 >= 2 ? gia[0] : -66) | (gc2 == 4 ? gs.i : gs.a[4]);
}
void rs_7_04_01_0(int a, char b, double c) {
	double t = (double)gl;
	jd = t;
}
void rs_7_04_01_1(int a, char b, double c) {
	++gu2;
}
void rs_7_04_01_2(int a, char b, double c) {
	b = '0';
}
void rs_7_04_01_3(int a, char b, double c) {
	++gl2;
}
void rs_7_04_01_4(int a, char b, double c) {
	double t = jd;
	gda[2] = (gu2 & 0x8 ? t : t);
}
void rs_7_04_01_5(int a, char b, double c) {
	gua[5] /= 2;
}
int rs_7_04_01_6(int a, char b, double c) {
	return gia[a];
}
void rs_7_04_02_0(int a, int b, unsigned char c) {
	unsigned long t = gula[4] >> (b & 15);
	jul = t;
}
void rs_7_04_02_1(int a, int b, unsigned char c) {
	unsigned long t = jul;
	vl((long)t);
}
void rs_7_04_02_2(int a, int b, unsigned char c) {
	if (gi2 & 2 || gi3 != b) gl2 = (long)!(gi + 256);
}
void rs_7_04_02_3(int a, int b, unsigned char c) {
	vs(gps);
}
void rs_7_04_02_4(int a, int b, unsigned char c) {
	gula[c] = 0x10000UL * 3UL;
}
unsigned int rs_7_04_02_5(int a, int b, unsigned char c) {
	return (unsigned int)!(gs.u / 100);
}
void rs_7_04_03_0(int *a, struct st *b) {
	int t = gia[1];
	ji = t;
}
void rs_7_04_03_1(int *a, struct st *b) {
	unsigned long u = -gula[6];
	jul = u;
}
void rs_7_04_03_2(int *a, struct st *b) {
	unsigned long u = jul;
	vl((long)u);
}
void rs_7_04_03_3(int *a, struct st *b) {
	int t = ji;
	v0();
	gi = t;
}
void rs_7_04_03_4(int *a, struct st *b) {
	guc = 246;
}
void rs_7_04_03_5(int *a, struct st *b) {
	gd -= gs.d;
}
void rs_7_04_03_6(int *a, struct st *b) {
	gl /= 2L;
}
void rs_7_04_03_7(int *a, struct st *b) {
	vs(b);
}
unsigned long rs_7_04_03_8(int *a, struct st *b) {
	int t = ji;
	v0();
	return (unsigned long)(guca[t] & guc);
}
void rs_7_04_04_0(void) {
	unsigned int t = 1;
	ju = t;
}
void rs_7_04_04_1(void) {
	char u = gps->c;
	jc = u;
}
void rs_7_04_04_2(void) {
	char u = jc;
	gc = u;
}
void rs_7_04_04_3(void) {
	unsigned int t = ju;
	switch (t) { case 8: case 10: case 200: case 1000: guc |= 99; break; }
}
void rs_7_04_04_4(void) {
	gps->p = gs.p;
}
void rs_7_04_04_5(void) {
	unsigned int t = ju;
	gul = (unsigned long)!(guca[t] % 10);
}
unsigned long rs_7_04_04_6(void) {
	return (gul = 99116UL);
}
void rs_7_04_05_0(void) {
	long t = gla[0];
	jl = t;
}
void rs_7_04_05_1(void) {
	gula[6] -= gul / 10UL;
}
void rs_7_04_05_2(void) {
	while (gi-- > 0) { if (*gp == '9') break; gp++; }
}
void rs_7_04_05_3(void) {
	long t = jl;
	vl(t);
}
int rs_7_04_05_4(void) {
	return (gs.i + 256) * r0();
}
void rs_7_04_06_1(char a) {
	int t = 16;
	ji = t;
}
void rs_7_04_06_2(char a) {
	int u = ~gia[1];
	ji = u;
}
void rs_7_04_06_3(char a) {
	int u = ji;
	if (guca[u]) *gpl = (long)gi;
}
void rs_7_04_06_4(char a) {
	gda[1] = gd - gs.d;
}
void rs_7_04_06_5(char a) {
	int i = ji;
	int t = ji;
	for (i = 0; i < 8; i++) { vd(gd2); if (gca[i] != 0) gc = gca[t] % gca[i]; vp(gs.p + i); }
}
int rs_7_04_06_6(char a) {
	int t = ji;
	v0();
	return r2(gi2, r1(t));
}
void rs_7_04_07_0(char a, char b) {
	int t = !gi3;
	ji = t;
}
void rs_7_04_07_1(char a, char b) {
	long u = gla[b] - gpl[3];
	jl = u;
}
void rs_7_04_07_2(char a, char b) {
	if (gu2 != 0) gua[a] = gua[2] % gu2;
}
void rs_7_04_07_3(char a, char b) {
	while (gi > 0) { gc += *gp++; gi--; }
}
void rs_7_04_07_4(char a, char b) {
	int t = ji;
	if ((gc2 = b) == -46) v1(16 & t);
}
void rs_7_04_07_5(char a, char b) {
	int t = ji;
	long u = jl;
	v0();
	if (gua[t] > gu) { gd2 = gd; *gpl = u = (long)gula[5]; }
}
long rs_7_04_07_6(char a, char b) {
	long u = jl;
	v0();
	return u;
}
void rs_7_04_08_0(int *a, unsigned long b) {
	double t = -10.0;
	jd = t;
}
void rs_7_04_08_1(int *a, unsigned long b) {
	int u = (int)gps->u * gi2;
	ji = u;
}
void rs_7_04_08_2(int *a, unsigned long b) {
	int u = ji;
	gi = u;
}
void rs_7_04_08_3(int *a, unsigned long b) {
	vd((!gc ? gd2 : gs.d));
}
void rs_7_04_08_4(int *a, unsigned long b) {
	gca[3] = 'a' - gc;
}
void rs_7_04_08_5(int *a, unsigned long b) {
	gca[6] = (char)(gi2 >= gps->a[6]);
}
void rs_7_04_08_6(int *a, unsigned long b) {
	double t = jd;
	v0();
	gd = t;
}
void rs_7_04_08_7(int *a, unsigned long b) {
	gpi = &gia[0];
}
void rs_7_04_08_8(int *a, unsigned long b) {
	guc--;
}
unsigned int rs_7_04_08_9(int *a, unsigned long b) {
	return (gu2 % 3) >> 5;
}
void rs_7_04_09_1(void) {
	int *t = gpi;
	jpi = t;
}
void rs_7_04_09_2(void) {
	double u = -gda[1];
	jd = u;
}
void rs_7_04_09_3(void) {
	switch (gps->c) { case 0: guc = guca[6] + guca[1]; break; case 1: gul %= 3UL; break; case 2: gs.p = gp; break; case 3: vu(gu2); break; case 4: gd2 += gd2; break; case 5: gu2 %= 16; break; }
}
void rs_7_04_09_4(void) {
	gula[5] /= 10UL;
}
void rs_7_04_09_5(void) {
	int i = ji;
	v0();
	for (i = 0; i < 11; i++) { gula[2] = ~9UL; }
}
void rs_7_04_09_6(void) {
	double u = jd;
	v0();
	vd(u);
}
void rs_7_04_09_7(void) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_7_04_10_0(void) {
	char t = (char)!gca[3];
	jc = t;
}
void rs_7_04_10_1(void) {
	char t = jc;
	gca[2] = gc = gca[t] / 100;
}
void rs_7_04_10_2(void) {
	if (gps->l != 0) gps->l = 65536L / gps->l;
}
int rs_7_04_10_3(void) {
	char t = jc;
	return -((int)gl2 >> (t & 15));
}
void rs_7_04_11_0(void) {
	gc2 = (char)!255;
}
void rs_7_04_11_1(void) {
	gl2 -= ~gl2;
}
void rs_7_04_11_2(void) {
	vs(gps);
}
void rs_7_04_12_0(char a, unsigned char b) {
	double t = -(double)gi3;
	jd = t;
}
void rs_7_04_12_1(char a, unsigned char b) {
	double t = jd;
	gd = t;
}
void rs_7_04_12_2(char a, unsigned char b) {
	vu(gu - 256);
}
void rs_7_04_12_3(char a, unsigned char b) {
	vl(*gpl ^ gps->l);
}
void rs_7_04_12_4(char a, unsigned char b) {
	a--;
}
char * rs_7_04_12_5(char a, unsigned char b) {
	return gs.p;
}
void rs_7_04_13_0(unsigned long a, double b, int c) {
	int t = ~1;
	ji = t;
}
void rs_7_04_13_1(unsigned long a, double b, int c) {
	gpi[0] = gia[2];
}
void rs_7_04_13_2(unsigned long a, double b, int c) {
	int t = ji;
	if (a) { guc -= ((char)gs.i == 86 ? guc : guca[t]); --a; v2(gi2, t); } else { gpi[3] /= 10; if (gla[6] != 0) gl2 = 65536L / gla[6]; }
}
int rs_7_04_13_3(unsigned long a, double b, int c) {
	return r2(gia[1], gi) | !gs.i;
}
void rs_7_04_14_1(int a, int *b, long *c) {
	double t = gs.d + gs.d;
	jd = t;
}
void rs_7_04_14_2(int a, int *b, long *c) {
	unsigned char u = guca[6];
	juc = u;
}
void rs_7_04_14_3(int a, int *b, long *c) {
	double t = jd;
	vd(t);
}
void rs_7_04_14_4(int a, int *b, long *c) {
	int i = ji;
	v0();
	for (i = 0; i < 2; i++) { if (gu2 != 0) gua[4] = gu2 % gu2; if (gul != 0) gul = gul % gul; }
}
void rs_7_04_14_5(int a, int *b, long *c) {
	unsigned char u = juc;
	v0();
	--u;
}
unsigned long rs_7_04_14_6(int a, int *b, long *c) {
	return (unsigned long)gi;
}
void rs_7_04_15_0(unsigned int a, unsigned int b, int c) {
	unsigned char t = (unsigned char)(gla[a] == (long)gca[a]);
	juc = t;
}
void rs_7_04_15_1(unsigned int a, unsigned int b, int c) {
	unsigned char u = 128 << 3;
	juc = u;
}
void rs_7_04_15_2(unsigned int a, unsigned int b, int c) {
	unsigned char t = juc;
	unsigned char u = juc;
	t = u;
}
int rs_7_04_15_3(unsigned int a, unsigned int b, int c) {
	if (r1(gi3)) return ~gs.i;
}
int rs_7_04_15_4(unsigned int a, unsigned int b, int c) {
	return gs.a[6] + gi;
}
void rs_7_04_16_1(unsigned char a) {
	int *t = rpi(gi3);
	jpi = t;
}
void rs_7_04_16_2(unsigned char a) {
	int u = r1(gi);
	v0();
	ji = u;
}
void rs_7_04_16_3(unsigned char a) {
	int i = ji;
	v0();
	for (i = 13; i > 0; i--) { guc += (gpi[1] ? guc : 255); }
}
void rs_7_04_16_4(unsigned char a) {
	int u = ji;
	v0();
	gca[u] = (char)gu;
}
void rs_7_04_16_5(unsigned char a) {
	int u = ji;
	v0();
	switch (gl) { case 0L: gc2 += gc; break; case 1L: gda[2] += gs.d; break; case 2L: gps->u -= gua[u]; break; default: gl = (long)(u > gi3); break; }
}
void rs_7_04_16_6(unsigned char a) {
	vs(gps);
}
void rs_7_04_16_7(unsigned char a) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_7_04_16_8(unsigned char a) {
	int i = ji;
	v0();
	for (i = 0; i < 16; i++) { vc(-gc2); ++gu; }
}
char rs_7_04_16_9(unsigned char a) {
	return (*gp + 0) & (gc ^ '0');
}
void rs_7_04_17_1(struct st *a, unsigned long b) {
	int i = ji;
	i = 0; while (i < 15) { if (gs.l != 0) gla[7] = 39321L / gs.l; i++; }
}
void rs_7_04_17_2(struct st *a, unsigned long b) {
	int i = ji;
	for (i = 0; i < 6; i++) { b++; gu = gua[i]; }
}
void rs_7_04_17_3(struct st *a, unsigned long b) {
	guca[1] -= guca[2] + guc;
}
void rs_7_04_17_4(struct st *a, unsigned long b) {
	gps->u = (unsigned int)(gda[3] >= gd2);
}
int rs_7_04_17_5(struct st *a, unsigned long b) {
	return (int)guca[1];
}
void rs_7_04_18_0(unsigned int a, unsigned int b, unsigned char c) {
	b -= (unsigned int)(gs.d == 100.0);
}
void rs_7_04_18_1(unsigned int a, unsigned int b, unsigned char c) {
	if (gc2 != 0) gps->c = gc / gc2;
}
void rs_7_04_18_2(unsigned int a, unsigned int b, unsigned char c) {
	gs.l *= 7L;
}
void rs_7_04_18_3(unsigned int a, unsigned int b, unsigned char c) {
	vd(gs.d * gs.d);
}
void rs_7_04_18_4(unsigned int a, unsigned int b, unsigned char c) {
	gd2 *= gd * gs.d;
}
unsigned long rs_7_04_18_5(unsigned int a, unsigned int b, unsigned char c) {
	return (gula[b] % 3UL) / 4UL;
}
void rs_7_04_19_0(void) {
	unsigned int t = gu + gu2;
	ju = t;
}
void rs_7_04_19_1(void) {
	unsigned int t = ju;
	++t;
}
void rs_7_04_19_2(void) {
	unsigned int t = ju;
	switch (gc2) { case 0: vs(gps); break; case 1: gps->p = gp; break; case 2: guca[t] |= guc; break; case 3: vu(9); break; case 4: gd += gd; break; default: gp = gs.p + t; break; }
}
void rs_7_04_19_3(void) {
	unsigned int t = ju;
	v0();
	gla[t] = gl = (gpl[1] * 4L) * 6L;
}
void rs_7_04_19_4(void) {
	unsigned int t = ju;
	v0();
	gul = gula[t] = (gul / 2UL) - -4UL;
}
unsigned int rs_7_04_19_5(void) {
	return gua[1];
}
void rs_7_05_00_0(double a, char b, int *c) {
	unsigned int t = gua[0] << (b & 15);
	ju = t;
}
void rs_7_05_00_1(double a, char b, int *c) {
	unsigned int t = ju;
	long u = gla[t] + 65536L;
	jl = u;
}
void rs_7_05_00_2(double a, char b, int *c) {
	long u = jl;
	if (guc > guca[5]) { *gp = gc2; if (*gpl != 0) gpl[0] = u % *gpl; }
}
void rs_7_05_00_3(double a, char b, int *c) {
	guca[6] >>= 1;
}
void rs_7_05_00_4(double a, char b, int *c) {
	unsigned int t = ju;
	gu = t;
}
void rs_7_05_00_5(double a, char b, int *c) {
	guca[0] %= 2;
}
long rs_7_05_00_6(double a, char b, int *c) {
	long u = jl;
	return (u = 4L);
}
void rs_7_05_01_0(int a) {
	gpi = rpi(r0());
}
void rs_7_05_01_1(int a) {
	gps->p = gp + a;
}
void rs_7_05_01_2(int a) {
	gps->u = -((unsigned int)gpl[2]);
}
void rs_7_05_01_3(int a) {
	gula[6] |= gula[a] / 10UL;
}
void rs_7_05_01_4(int a) {
	gl2--;
}
int rs_7_05_01_5(int a) {
	return (gs.a[a] == (-164 % 4));
}
int * rs_7_05_02_0(int a, struct st *b, int c) {
	if ((gula[c] = gul) && gula[c] >= gula[4]) return rpi(gia[c]);
}
void rs_7_05_02_1(int a, struct st *b, int c) {
	guc--;
}
int * rs_7_05_02_2(int a, struct st *b, int c) {
	return rpi(b->a[a] * 10);
}
void rs_7_05_03_0(unsigned long a, long b, long *c) {
	int t = 100;
	ji = t;
}
void rs_7_05_03_1(unsigned long a, long b, long *c) {
	v0();
}
void rs_7_05_03_2(unsigned long a, long b, long *c) {
	int t = ji;
	v0();
	switch (t) { case 2: vp(gp + t); break; case 5: gu2 *= 7; break; case 8: *gpi = (0x10000UL != 0x10000UL ? gi2 : 16); break; case 200: gca[7] += gp[1]; break; }
}
void rs_7_05_03_3(unsigned long a, long b, long *c) {
	int t = ji;
	v0();
	t = r2(t >> 1, gi);
}
void rs_7_05_04_0(char a) {
	int t = gi;
	ji = t;
}
void rs_7_05_04_1(char a) {
	int u = 255 * 11;
	ji = u;
}
void rs_7_05_04_2(char a) {
	gd2 = -gd;
}
void rs_7_05_04_3(char a) {
	int t = ji;
	gl2 = (*gpl - 5038L) + (*gpl ^ gla[t]);
}
void rs_7_05_04_4(char a) {
	int u = ji;
	gi3 = (u + 127) << 1;
}
void rs_7_05_04_5(char a) {
	int t = ji;
	gula[0] = (gula[t] % 10UL) << 17;
}
void rs_7_05_05_0(unsigned long a, int *b, unsigned long c) {
	guc = guca[3] % 100;
}
void rs_7_05_05_1(unsigned long a, int *b, unsigned long c) {
	switch (gps->l) { case 3L: vp(gp + 1); break; case 5L: guc -= 9; break; case 10L: guca[5] += 111; break; case 16L: vu(gu2); break; default: v2(gi2, *gpi); break; }
}
unsigned long rs_7_05_05_2(unsigned long a, int *b, unsigned long c) {
	return (c = 0x10000UL);
}
void rs_7_05_06_0(void) {
	gl2 = (gpl[1] % 7L) >> 18;
}
void rs_7_05_06_1(void) {
	gps->p = gps->p + 1;
}
void rs_7_05_06_2(void) {
	gca[0] = gp[3] % 7;
}
void rs_7_05_07_0(unsigned int a) {
	while (gi-- > 0) { if (*gpi == -626) break; gpi++; }
}
void rs_7_05_07_1(unsigned int a) {
	gpl[2] = gpl[2] >> 9;
}
void rs_7_05_07_2(unsigned int a) {
	switch (gu) { case 3: vd((double)gu); break; case 10: case 16: case 200: gl |= 65536L; break; case 1000: gu &= gps->u; default: vl(gpl[3]); break; }
}
void rs_7_05_07_3(unsigned int a) {
	gul = gula[0] = 36751UL;
}
char * rs_7_05_07_4(unsigned int a) {
	return &gca[4];
}
void rs_7_05_08_0(long *a) {
	char *t = rp();
	jp = t;
}
void rs_7_05_08_1(long *a) {
	vs(gps);
}
void rs_7_05_08_2(long *a) {
	v1(gi);
}
void rs_7_05_08_3(long *a) {
	char *t = jp;
	v0();
	gp = t;
}
void rs_7_05_08_4(long *a) {
	gu2 = gua[4] = 256 % 100;
}
void rs_7_05_08_5(long *a) {
	v0();
}
int rs_7_05_08_6(long *a) {
	return (gpi[2] = gs.a[0]);
}
void rs_7_05_09_1(long a, unsigned long b) {
	char *t = gp + 1;
	jp = t;
}
void rs_7_05_09_2(long a, unsigned long b) {
	char *t = jp;
	gp = t;
}
void rs_7_05_09_3(long a, unsigned long b) {
	int i = ji;
	for (i = 0; i < 3; i++) { if (gul != 0) gul = ((unsigned long)guc) % gul; vc(4 - gc); }
}
void rs_7_05_09_4(long a, unsigned long b) {
	++gul;
}
void rs_7_05_09_5(long a, unsigned long b) {
	int i = ji;
	v0();
	i = 0; while (i < 6) { gl /= 7L; i++; }
}
int * rs_7_05_09_6(long a, unsigned long b) {
	return rpi(gps->a[1]);
}
void rs_7_05_10_0(int a, long b) {
	char t = -(-26);
	jc = t;
}
void rs_7_05_10_1(int a, long b) {
	gula[a] -= -gul;
}
void rs_7_05_10_2(int a, long b) {
	gul--;
}
void rs_7_05_10_3(int a, long b) {
	gua[a] = gua[0] % 16;
}
void rs_7_05_10_4(int a, long b) {
	char t = jc;
	if (r2(gi2, gi2)) { if (gl != 0) gl2 = 7L % gl; gu2 = -gua[t] / 16; }
}
char rs_7_05_10_5(int a, long b) {
	char t = jc;
	v0();
	return (*gpi == gps->i ? rc((int)t) : t);
}
void rs_7_05_11_1(struct st *a, unsigned int b, int c) {
	int i = ji;
	for (i = 0; i < c; i++) { if (gps->u != 0) b = gps->u % gps->u; gu2 = gua[4] ^ (255 >> 8); if (gl != 0) gps->l = gs.l / gl; }
}
void rs_7_05_11_2(struct st *a, unsigned int b, int c) {
	gu2 = (((unsigned int)gula[7]) - gua[4]) | ru(gu);
}
char rs_7_05_11_3(struct st *a, unsigned int b, int c) {
	return 17;
}
void rs_7_05_12_0(unsigned long a) {
	gps->u += 32767;
}
void rs_7_05_12_1(unsigned long a) {
	if (gca[5] >= gca[0]) if (gi3 != 0) gia[4] = 256 % gi3;
}
void rs_7_05_12_2(unsigned long a) {
	if (gu != 0) gu2 = 9 % gu;
}
int * rs_7_05_12_3(unsigned long a) {
	return &gia[0];
}
void rs_7_05_13_0(void) {
	int t = gpi[0];
	ji = t;
}
void rs_7_05_13_1(void) {
	int t = ji;
	t = gia[t];
}
void rs_7_05_13_2(void) {
	gia[1] += gps->a[0];
}
void rs_7_05_13_3(void) {
	if (gl2) { if (gl != 0) gs.l = gl2 % gl; }
}
void rs_7_05_13_4(void) {
	int t = ji;
	guca[3] = (unsigned char)!((unsigned char)t);
}
int rs_7_05_13_5(void) {
	int t = ji;
	return t;
}
void rs_7_05_14_0(char *a, int *b) {
	gl = (gla[7] & gl2) / 10L;
}
void rs_7_05_14_1(char *a, int *b) {
	--gp;
}
void rs_7_05_14_2(char *a, int *b) {
	*a = (char)(gl2 > -81893L);
}
void rs_7_05_14_3(char *a, int *b) {
	gu2--;
}
void rs_7_05_14_4(char *a, int *b) {
	b = gpi;
}
char * rs_7_05_14_5(char *a, int *b) {
	return a;
}
void rs_7_05_15_1(char a, int b) {
	unsigned char t = (unsigned char)(guca[a] == ((unsigned char)gps->l));
	juc = t;
}
void rs_7_05_15_2(char a, int b) {
	int i = ji;
	for (i = 0; i < 14; i++) { gula[0] = (unsigned long)gl; ++gp; gi = (b >> 9) << (b & 15); }
}
void rs_7_05_15_3(char a, int b) {
	unsigned char t = juc;
	v1(t);
}
void rs_7_05_15_4(char a, int b) {
	switch (gi) { case 0: vu(gs.u); break; case 1: vd(1.0); break; case 2: gul -= 3UL; case 3: v0(); break; case 4: case 5: gc = a * 20; break; default: vl(gl); break; }
}
void rs_7_05_15_5(char a, int b) {
	while (b-- > 0) *gpi++ = 100;
}
void rs_7_05_15_6(char a, int b) {
	gula[3] = -6UL;
}
long rs_7_05_15_7(char a, int b) {
	return rl(65536L << 26);
}
void rs_7_05_16_0(int *a, long b, double c) {
	char t = (char)((char)gu2 <= gc2);
	jc = t;
}
void rs_7_05_16_1(int *a, long b, double c) {
	double u = gda[1] * gs.d;
	jd = u;
}
void rs_7_05_16_2(int *a, long b, double c) {
	gi = r0();
}
void rs_7_05_16_3(int *a, long b, double c) {
	char t = jc;
	v0();
	vl((10.0 <= (double)t ? gla[1] : 65536L));
}
void rs_7_05_16_4(int *a, long b, double c) {
	double u = jd;
	v0();
	gd = u;
}
void rs_7_05_16_5(int *a, long b, double c) {
	char t = jc;
	v0();
	guc = -((unsigned char)(t != gp[1]));
}
void rs_7_05_16_6(int *a, long b, double c) {
	char t = jc;
	v0();
	if (b == 65536L) { gl = (long)t << 6; }
}
char rs_7_05_16_7(int *a, long b, double c) {
	return gc2;
}
void rs_7_05_17_0(int a, long b) {
	char t = rc(a);
	jc = t;
}
void rs_7_05_17_1(int a, long b) {
	gu = (unsigned int)gula[a];
}
void rs_7_05_17_2(int a, long b) {
	guc <<= 4;
}
void rs_7_05_17_3(int a, long b) {
	char t = jc;
	v0();
	switch (gl2) { case 0L: gi *= 2; break; case 1L: gua[3] = gu2 << (a & 15); break; case 2L: gua[1] = gu2; case 3L: vc(t); break; case 4L: t /= 16; break; }
}
void rs_7_05_17_4(int a, long b) {
	if (gpl[2] & 2 || gi3 < *gpi) gpi = rpi(gpi[2] * gi3);
}
char rs_7_05_17_5(int a, long b) {
	return gp[0];
}
void rs_7_05_18_1(unsigned int a, long *b, unsigned int c) {
	char t = gp[0] - *gp;
	jc = t;
}
void rs_7_05_18_2(unsigned int a, long *b, unsigned int c) {
	int i = ji;
	char t = jc;
	for (i = 7; i > 0; i--) { gia[i] = gps->a[i] ^ gi; gca[i] = *gp = t; }
}
void rs_7_05_18_3(unsigned int a, long *b, unsigned int c) {
	gpi[1] = -gps->a[4];
}
void rs_7_05_18_4(unsigned int a, long *b, unsigned int c) {
	if (gs.a[5] != 0) gi2 = 2 % gs.a[5];
}
int rs_7_05_18_5(unsigned int a, long *b, unsigned int c) {
	char t = jc;
	return r1((gc == t));
}
void rs_7_05_19_0(void) {
	gul = (gula[7] | ((unsigned long)gc2)) * -gula[7];
}
void rs_7_05_19_1(void) {
	if (r1(gia[0]) && gps->l < 65536L) { gul = gula[2] = 4UL; }
}
void rs_7_05_19_2(void) {
	if (0L != gl2) { vd(1.0 / 2.5); if (gul != 0) gul = gul % gul; } else { vu(gu2 ^ gua[1]); }
}
int * rs_7_05_19_3(void) {
	return gpi;
}
void rs_7_06_00_0(void) {
	gi2 = ((int)guca[1] - (int)gps->u) >> 2;
}
void rs_7_06_00_1(void) {
	++gl;
}
void rs_7_06_00_2(void) {
	gu *= 2;
}
void rs_7_06_00_3(void) {
	gua[4] = gu2;
}
char * rs_7_06_00_4(void) {
	return gp;
}
void rs_7_06_01_0(unsigned long a, char *b, char *c) {
	gula[2] = (unsigned long)!gi3;
}
void rs_7_06_01_1(unsigned long a, char *b, char *c) {
	vc('a' + *c);
}
void rs_7_06_01_2(unsigned long a, char *b, char *c) {
	if (gs.l) { if (gs.a[1] != 0) gs.a[2] = gi3 / gs.a[1]; gda[3] += (gula[6] < 0x10000UL ? 3.0 : gd2); } else { guc %= 3; gul--; if (gul != 0) a = 8UL / gul; }
}
void rs_7_06_01_3(unsigned long a, char *b, char *c) {
	guca[5] += 128;
}
unsigned long rs_7_06_01_4(unsigned long a, char *b, char *c) {
	return (a = gul);
}
void rs_7_06_02_0(int a, unsigned int b) {
	long t = (long)gula[1] | gs.l;
	jl = t;
}
void rs_7_06_02_1(int a, unsigned int b) {
	unsigned char u = guca[a];
	juc = u;
}
void rs_7_06_02_2(int a, unsigned int b) {
	unsigned char u = juc;
	if (!u) { gula[a] = (gul - 0x10000UL) % 16UL; gula[a] = (unsigned long)-gu; } else { vd(-2.5); }
}
void rs_7_06_02_3(int a, unsigned int b) {
	unsigned char u = juc;
	v0();
	u += guca[a];
}
void rs_7_06_02_4(int a, unsigned int b) {
	unsigned char u = juc;
	v0();
	gu = gs.u;
}
void rs_7_06_02_5(int a, unsigned int b) {
	long t = jl;
	v0();
	vl(t);
}
unsigned int rs_7_06_02_6(int a, unsigned int b) {
	unsigned char u = juc;
	v0();
	return (gps->u & gu) >> (a & 15);
}
void rs_7_06_03_0(int a, unsigned long b) {
	char *t = &gca[1];
	jp = t;
}
void rs_7_06_03_1(int a, unsigned long b) {
	int u = -gs.i;
	ji = u;
}
void rs_7_06_03_2(int a, unsigned long b) {
	a -= gi2 / 2;
}
void rs_7_06_03_3(int a, unsigned long b) {
	gula[a] = gul;
}
void rs_7_06_03_4(int a, unsigned long b) {
	char *t = jp;
	gp = t;
}
void rs_7_06_03_5(int a, unsigned long b) {
	vc((char)gpl[2]);
}
void rs_7_06_03_6(int a, unsigned long b) {
	int u = ji;
	v0();
	gu2 = gs.u = 32767;
}
void rs_7_06_03_7(int a, unsigned long b) {
	int u = ji;
	v0();
	switch (gs.l) { case 2L: vd(gd); break; case 8L: gda[3] = -gs.d; case 20L: vu(gu2); break; case 100L: gs.u *= 9; break; case 200L: gul ^= 1UL; default: gul = b - 0x10000UL; break; }
}
char rs_7_06_03_8(int a, unsigned long b) {
	return gp[1] >> 4;
}
void rs_7_06_04_1(struct st *a, char b, unsigned char c) {
	gpi = gpi + c;
}
void rs_7_06_04_2(struct st *a, char b, unsigned char c) {
	gp = gs.p + c;
}
void rs_7_06_04_3(struct st *a, char b, unsigned char c) {
	gc2 = rc(gia[0]) + gc;
}
void rs_7_06_04_4(struct st *a, char b, unsigned char c) {
	--gpi;
}
void rs_7_06_04_5(struct st *a, char b, unsigned char c) {
	int i = ji;
	v0();
	for (i = 0; i < 5; i++) { a->i = gpi[2] = (i % 100) % 100; gc2 = 'A' | gc; }
}
char * rs_7_06_04_6(struct st *a, char b, unsigned char c) {
	return gp;
}
void rs_7_06_05_0(void) {
	unsigned char t = guca[5] / 3;
	juc = t;
}
void rs_7_06_05_1(void) {
	unsigned char t = juc;
	v1(t);
}
void rs_7_06_05_2(void) {
	if (gc2 >= *gp) { gps->u = gu; if (gc2 != 0) gc2 = gp[1] / gc2; }
}
void rs_7_06_05_3(void) {
	vd(gs.d);
}
void rs_7_06_05_4(void) {
	gl2++;
}
void rs_7_06_05_5(void) {
	gps->c = gps->c - gc;
}
void rs_7_06_05_6(void) {
	gps->i = gi;
}
long rs_7_06_05_7(void) {
	return -72357L;
}
void rs_7_06_06_0(void) {
	long t = gla[5] + gla[7];
	jl = t;
}
void rs_7_06_06_1(void) {
	guc += (unsigned char)32767;
}
void rs_7_06_06_2(void) {
	vs(gps);
}
void rs_7_06_06_3(void) {
	gi3--;
}
void rs_7_06_06_4(void) {
	gul <<= 3;
}
void rs_7_06_06_5(void) {
	long t = jl;
	v0();
	vl(t);
}
int rs_7_06_06_6(void) {
	return (gps->i = (int)gca[1]);
}
void rs_7_06_07_0(unsigned int a, int b, unsigned int c) {
	double t = gd2 - gs.d;
	jd = t;
}
void rs_7_06_07_1(unsigned int a, int b, unsigned int c) {
	int *u = gpi;
	jpi = u;
}
void rs_7_06_07_2(unsigned int a, int b, unsigned int c) {
	double t = jd;
	vd(t);
}
void rs_7_06_07_3(unsigned int a, int b, unsigned int c) {
	guca[7] += guca[2];
}
void rs_7_06_07_4(unsigned int a, int b, unsigned int c) {
	gula[1] = ~gul;
}
void rs_7_06_07_5(unsigned int a, int b, unsigned int c) {
	gi2 %= 16;
}
void rs_7_06_07_6(unsigned int a, int b, unsigned int c) {
	gula[a] = gul + 4849UL;
}
void rs_7_06_07_7(unsigned int a, int b, unsigned int c) {
	int *u = jpi;
	v0();
	v1(*u);
}
char rs_7_06_07_8(unsigned int a, int b, unsigned int c) {
	return (gp[1] = gs.c);
}
void rs_7_06_08_0(void) {
	int t = (int)gla[4];
	ji = t;
}
void rs_7_06_08_1(void) {
	unsigned int u = gu2;
	ju = u;
}
void rs_7_06_08_2(void) {
	--guc;
}
void rs_7_06_08_3(void) {
	gp[2] /= 16;
}
void rs_7_06_08_4(void) {
	if (gla[2] <= 65536L) gc++;
}
void rs_7_06_08_5(void) {
	int t = ji;
	gi = t;
}
void rs_7_06_08_6(void) {
	unsigned int u = ju;
	guca[u] = guc - guca[5];
}
void rs_7_06_08_7(void) {
	++guc;
}
char rs_7_06_08_8(void) {
	unsigned int u = ju;
	return (gia[u] & 0x8 ? (2 | gps->c) : (gps->c * gc2));
}
void rs_7_06_09_0(long *a, unsigned int b, int c) {
	guc = (255 - guca[2]) % 7;
}
void rs_7_06_09_1(long *a, unsigned int b, int c) {
	if (gs.a[c]) gula[b] = 39429UL * 4UL;
}
int rs_7_06_09_2(long *a, unsigned int b, int c) {
	return gia[4];
}
void rs_7_06_10_0(void) {
	unsigned int t = -256;
	ju = t;
}
void rs_7_06_10_1(void) {
	int *u = &gia[4];
	jpi = u;
}
void rs_7_06_10_2(void) {
	unsigned int t = ju;
	int *u = jpi;
	switch (gi3) { case 0: gi = gi3; break; case 1: gua[t] &= gs.u; break; case 2: guca[4] ^= guc; break; case 3: gca[0] = 'A'; break; case 4: t = gu; break; }
}
void rs_7_06_10_3(void) {
	unsigned int t = ju;
	t = (1879 - gu) - ((unsigned int)gps->c);
}
int rs_7_06_10_4(void) {
	unsigned int t = ju;
	return (gia[t] = gps->a[t]);
}
void rs_7_06_11_0(void) {
	long t = -56088L;
	jl = t;
}
void rs_7_06_11_1(void) {
	vp(gps->p + 1);
}
void rs_7_06_11_2(void) {
	gc2 = rc(!gula[6]);
}
void rs_7_06_11_3(void) {
	long t = jl;
	v0();
	gl2 = t = rl(9L) >> 20;
}
void rs_7_06_11_4(void) {
	long t = jl;
	v0();
	if (t != 0) gla[0] = 1L % t;
}
char * rs_7_06_11_5(void) {
	return gps->p;
}
void rs_7_06_12_1(int a, unsigned int b) {
	int t = gs.a[0] + gi;
	ji = t;
}
void rs_7_06_12_2(int a, unsigned int b) {
	int t = ji;
	gi = t;
}
void rs_7_06_12_3(int a, unsigned int b) {
	gc2 = gca[5];
}
void rs_7_06_12_4(int a, unsigned int b) {
	int i = ji;
	for (i = 0; i < 8; i++) { gl = (*gpl >> 4) + (gps->l ? gps->l : gl); gpi = &gia[i]; gpl[0] = (gpl[2] + -98480L) * 7L; }
}
void rs_7_06_12_5(int a, unsigned int b) {
	gula[b] = -0x10000UL;
}
long rs_7_06_12_6(int a, unsigned int b) {
	return *gpl;
}
int rs_7_06_13_0(unsigned int a, unsigned long b) {
	if ((gla[a] = 2L) == 65536L) return (int)gu2 - gi2;
}
void rs_7_06_13_1(unsigned int a, unsigned long b) {
	vp(&gca[a]);
}
void rs_7_06_13_2(unsigned int a, unsigned long b) {
	gul = b * 8UL;
}
void rs_7_06_13_3(unsigned int a, unsigned long b) {
	a %= 2;
}
int rs_7_06_13_4(unsigned int a, unsigned long b) {
	return gi;
}
void rs_7_06_14_1(void) {
	int i = ji;
	for (i = 0; i < 15; i++) { ++gi2; }
}
void rs_7_06_14_2(void) {
	--guc;
}
int rs_7_06_14_3(void) {
	return gi;
}
void rs_7_06_15_1(unsigned long a) {
	double t = -gd;
	jd = t;
}
void rs_7_06_15_2(unsigned long a) {
	unsigned long u = 8UL;
	jul = u;
}
void rs_7_06_15_3(unsigned long a) {
	gl = (long)((unsigned int)65536L);
}
void rs_7_06_15_4(unsigned long a) {
	int i = ji;
	double t = jd;
	i = 0; while (i < 8) { t = 10.0; if (gu2 != 0) gua[i] = ((unsigned int)guc) / gu2; vs(gps); i++; }
}
void rs_7_06_15_5(unsigned long a) {
	unsigned long u = jul;
	v0();
	gul = u;
}
void rs_7_06_15_6(unsigned long a) {
	gc = gp[0] = gc2;
}
char rs_7_06_15_7(unsigned long a) {
	return 1;
}
void rs_7_06_16_0(struct st *a) {
	int t = gi2 & gi;
	ji = t;
}
void rs_7_06_16_1(struct st *a) {
	unsigned int u = gu2 / 100;
	ju = u;
}
void rs_7_06_16_2(struct st *a) {
	guca[0] = 8;
}
void rs_7_06_16_3(struct st *a) {
	gd = (gd / 0.25) + (10.0 * 10.0);
}
void rs_7_06_16_4(struct st *a) {
	unsigned int u = ju;
	gu = u;
}
void rs_7_06_16_5(struct st *a) {
	int t = ji;
	v1(t);
}
int rs_7_06_16_6(struct st *a) {
	return gpi[0] >> 4;
}
void rs_7_06_17_0(char a) {
	gl = (gul & 4 ? rl(7L) : (gula[a] > 0x10000UL ? gpl[0] : 65536L));
}
void rs_7_06_17_1(char a) {
	++gpi;
}
void rs_7_06_17_2(char a) {
	if (r2(256, gi)) { if (*gpl != 0) gs.l = gps->l / *gpl; if (gs.c != 0) gp[1] = gs.c % gs.c; } else { a -= gc2 / 2; }
}
char * rs_7_06_17_3(char a) {
	return gps->p;
}
void rs_7_06_18_0(char a, int b, unsigned int c) {
	int t = -828;
	ji = t;
}
void rs_7_06_18_1(char a, int b, unsigned int c) {
	char *u = gp + b;
	jp = u;
}
void rs_7_06_18_2(char a, int b, unsigned int c) {
	char *u = jp;
	switch (gl) { case 0L: case 1L: case 2L: vs(gps); break; case 3L: vl(gla[a]); break; case 4L: gu = gps->u / 3; break; }
}
void rs_7_06_18_3(char a, int b, unsigned int c) {
	int t = ji;
	v0();
	v1(t);
}
void rs_7_06_18_4(char a, int b, unsigned int c) {
	if (!gu) ++gp;
}
long rs_7_06_18_5(char a, int b, unsigned int c) {
	return gpl[1] >> 11;
}
void rs_7_06_19_0(void) {
	gps->c = gca[3];
}
void rs_7_06_19_1(void) {
	if (gs.l & 0x8) { gda[0] = gd; }
}
void rs_7_06_19_2(void) {
	gul = gula[0] = (~((unsigned long)gca[5])) | (73562UL << 29);
}
void rs_7_06_19_3(void) {
	while (gi-- > 0) { if (*gpi == 6) break; gpi++; }
}
int rs_7_06_19_4(void) {
	return (gi + gs.a[4]) >> 3;
}
void rs_7_07_00_1(long *a, int *b, unsigned int c) {
	unsigned char t = -guc;
	juc = t;
}
void rs_7_07_00_2(long *a, int *b, unsigned int c) {
	gl2--;
}
void rs_7_07_00_3(long *a, int *b, unsigned int c) {
	int i = ji;
	unsigned char t = juc;
	for (i = 0; i < 12; i++) { gps->u = ((unsigned int)!t) + gua[c]; if (gc2 != 0) gc = gc / gc2; gps->p = &gca[i]; }
}
void rs_7_07_00_4(long *a, int *b, unsigned int c) {
	a[7] = gl2 % 4L;
}
void rs_7_07_00_5(long *a, int *b, unsigned int c) {
	unsigned char t = juc;
	t = guc = 255;
}
void rs_7_07_00_6(long *a, int *b, unsigned int c) {
	gs.u += gu;
}
int rs_7_07_00_7(long *a, int *b, unsigned int c) {
	return *gpi;
}
void rs_7_07_01_0(void) {
	vs(gps);
}
void rs_7_07_01_1(void) {
	gul *= 12UL;
}
void rs_7_07_01_2(void) {
	gpi++;
}
void rs_7_07_01_3(void) {
	guc -= ((unsigned char)gu) / 3;
}
void rs_7_07_01_4(void) {
	if (gs.c != 0) *gp = gps->c % gs.c;
}
char rs_7_07_01_5(void) {
	return (*gp | gc) - 81;
}
void rs_7_07_02_0(void) {
	char t = 3;
	jc = t;
}
void rs_7_07_02_1(void) {
	int u = (int)gul;
	ji = u;
}
void rs_7_07_02_2(void) {
	char t = jc;
	int u = ji;
	if (gul > ((unsigned long)t) || (gu = gu2) > 256) { if (gu != 0) gps->u = gs.u / gu; vu(gs.u & 10571); if (gua[7] != 0) gu2 = gu / gua[7]; }
}
void rs_7_07_02_3(void) {
	int u = ji;
	v0();
	gu <<= (u & 15);
}
void rs_7_07_02_4(void) {
	char t = jc;
	v0();
	if (((unsigned char)gul) < guca[t]) if (gula[6] != 0) gul = gul / gula[6];
}
int rs_7_07_02_5(void) {
	return -(gps->i * 7);
}
void rs_7_07_03_0(void) {
	unsigned int t = ~gu2;
	ju = t;
}
void rs_7_07_03_1(void) {
	unsigned char u = guc % 7;
	juc = u;
}
void rs_7_07_03_2(void) {
	unsigned int t = ju;
	vu(t);
}
void rs_7_07_03_3(void) {
	guc = ((unsigned char)((char)gla[5] != gp[0])) * guc;
}
void rs_7_07_03_4(void) {
	unsigned char u = juc;
	v0();
	if (255 == 8) guc -= u;
}
void rs_7_07_04_0(int *a, int b, unsigned long c) {
	unsigned long t = gul;
	jul = t;
}
void rs_7_07_04_1(int *a, int b, unsigned long c) {
	guc = guca[b] = (guc >> (b & 7)) * (guc - 28);
}
void rs_7_07_04_2(int *a, int b, unsigned long c) {
	gp--;
}
void rs_7_07_04_3(int *a, int b, unsigned long c) {
	unsigned long t = jul;
	gul = t;
}
void rs_7_07_04_4(int *a, int b, unsigned long c) {
	gu2 /= 7;
}
void rs_7_07_04_5(int *a, int b, unsigned long c) {
	*gpl = rl(65536L);
}
char * rs_7_07_04_6(int *a, int b, unsigned long c) {
	return gp;
}
void rs_7_07_05_0(void) {
	unsigned long t = gul;
	jul = t;
}
void rs_7_07_05_1(void) {
	char *u = gps->p;
	jp = u;
}
void rs_7_07_05_2(void) {
	gpi = gpi + 1;
}
void rs_7_07_05_3(void) {
	gd2 = gda[0];
}
void rs_7_07_05_4(void) {
	unsigned long t = jul;
	t *= 2UL;
}
void rs_7_07_05_5(void) {
	char *u = jp;
	gp = u;
}
void rs_7_07_05_6(void) {
	gu2 = ((unsigned int)!gla[7]) >> 8;
}
unsigned int rs_7_07_05_7(void) {
	return ru(gu);
}
void rs_7_07_06_0(long a, struct st *b, struct st *c) {
	if (gula[2] & 0x80) { gp[0] = gps->c ^ 94; if (gula[4] != 0) gul = gula[3] / gula[4]; }
}
void rs_7_07_06_1(long a, struct st *b, struct st *c) {
	while (gi > 0) { gc += *gp++; gi--; }
}
char rs_7_07_06_2(long a, struct st *b, struct st *c) {
	return gc;
}
void rs_7_07_07_1(void) {
	int i = ji;
	int t = !gs.i;
	ji = t;
}
void rs_7_07_07_2(void) {
	unsigned char u = guca[2] | guc;
	juc = u;
}
void rs_7_07_07_3(void) {
	int t = ji;
	gi = t;
}
void rs_7_07_07_4(void) {
	gl2 = gla[5] = (long)((gl + gpl[3]) <= rl(65536L));
}
void rs_7_07_07_5(void) {
	if (gua[2] & 0x7) { gpi = rpi((int)gul + gi); }
}
void rs_7_07_07_6(void) {
	int i = ji;
	unsigned char u = juc;
	v0();
	for (i = 0; i < 15; i++) { guc = (((unsigned char)gu2) & ((unsigned char)gps->l)) & (guca[i] >> 4); u = 5; u = 180 - (u ^ 255); }
}
void rs_7_07_07_7(void) {
	gu %= 2;
}
void rs_7_07_07_8(void) {
	gu++;
}
int rs_7_07_07_9(void) {
	return 1;
}
void rs_7_07_08_0(int *a, unsigned char b, int *c) {
	long t = gs.l;
	jl = t;
}
void rs_7_07_08_1(int *a, unsigned char b, int *c) {
	unsigned int u = (unsigned int)(gula[2] > 1UL);
	ju = u;
}
void rs_7_07_08_2(int *a, unsigned char b, int *c) {
	vs(gps);
}
void rs_7_07_08_3(int *a, unsigned char b, int *c) {
	unsigned int u = ju;
	v0();
	gu = gua[2] = gs.u;
}
void rs_7_07_08_4(int *a, unsigned char b, int *c) {
	long t = jl;
	v0();
	*gpl = t;
}
void rs_7_07_08_5(int *a, unsigned char b, int *c) {
	++gp;
}
void rs_7_07_08_6(int *a, unsigned char b, int *c) {
	gp--;
}
int rs_7_07_08_7(int *a, unsigned char b, int *c) {
	unsigned int u = ju;
	v0();
	return (gia[u] = gi3);
}
void rs_7_07_09_1(unsigned char a, long *b) {
	int t = -gs.a[7];
	ji = t;
}
void rs_7_07_09_2(unsigned char a, long *b) {
	int t = ji;
	a -= (unsigned char)t;
}
void rs_7_07_09_3(unsigned char a, long *b) {
	if (gu > 1) { gul = gula[a]; } else { gs.d = gd / 0.25; }
}
void rs_7_07_09_4(unsigned char a, long *b) {
	int i = ji;
	i = 0; while (i < 2) { gp[2] = rc(gps->i); vs(gps); if (gl2 != 0) gla[2] = (long)a % gl2; i++; }
}
int rs_7_07_09_5(unsigned char a, long *b) {
	int t = ji;
	v0();
	return (2 << (t & 15)) - !guc;
}
int rs_7_07_10_0(void) {
	if (((unsigned char)gla[4]) > guc) return gi3;
}
void rs_7_07_10_1(void) {
	if (guca[1] <= guc) gd = (double)gp[0];
}
int rs_7_07_10_2(void) {
	return (guc < 7);
}
void rs_7_07_11_0(char a) {
	char *t = gs.p;
	jp = t;
}
void rs_7_07_11_1(char a) {
	unsigned int u = (unsigned int)gula[a];
	ju = u;
}
void rs_7_07_11_2(char a) {
	guca[1] = guc ^ guca[a];
}
void rs_7_07_11_3(char a) {
	if (gula[a] != 0) gul = gul / gula[a];
}
void rs_7_07_11_4(char a) {
	unsigned int u = ju;
	gs.a[a] += gia[u];
}
void rs_7_07_11_5(char a) {
	char *t = jp;
	*t >>= 2;
}
char * rs_7_07_11_6(char a) {
	return &gca[3];
}
void rs_7_07_12_0(int a, int b) {
	if ((char)gul >= gc2) if (gl != 0) gpl[2] = gs.l % gl;
}
void rs_7_07_12_1(int a, int b) {
	if (gp[3] != 0) gp[0] = gca[b] / gp[3];
}
void rs_7_07_12_2(int a, int b) {
	guc += 255 << 5;
}
void rs_7_07_12_3(int a, int b) {
	guca[a] = (unsigned char)32767;
}
void rs_7_07_12_4(int a, int b) {
	gul = 0x10000UL * 11UL;
}
int * rs_7_07_12_5(int a, int b) {
	return gpi;
}
void rs_7_07_13_0(int a, struct st *b) {
	double t = gd;
	jd = t;
}
void rs_7_07_13_1(int a, struct st *b) {
	double t = jd;
	gd2 = (*gp ? -t : (2.5 + 2.5));
}
void rs_7_07_13_2(int a, struct st *b) {
	vp(gp);
}
void rs_7_07_13_3(int a, struct st *b) {
	guca[6] = guca[a] >> 2;
}
int * rs_7_07_13_4(int a, struct st *b) {
	return gpi + a;
}
void rs_7_07_14_1(long a, unsigned int b) {
	gps->l = *gpl - gs.l;
}
void rs_7_07_14_2(long a, unsigned int b) {
	vc(gc | gs.c);
}
void rs_7_07_14_3(long a, unsigned int b) {
	a = -gl * 4L;
}
void rs_7_07_14_4(long a, unsigned int b) {
	while (gi-- > 0) { if (*gp == 5) break; gp++; }
}
void rs_7_07_14_5(long a, unsigned int b) {
	int i = ji;
	v0();
	for (i = 0; i < 4; i++) { gpi = rpi(i); gs.c = 'z' / 3; if (*gpi != 0) gi2 = gps->a[i] / *gpi; }
}
void rs_7_07_15_1(void) {
	int i = ji;
	for (i = 0; i < 15; i++) { gi2 = 255; gu2 = ru(9); }
}
void rs_7_07_15_2(void) {
	guc += 2 + guc;
}
void rs_7_07_15_3(void) {
	int i = ji;
	v0();
	if (gc2 >= (char)gps->i) { if (gc2 != 0) gp[3] = gc2 % gc2; v1(1 >> 3); gp[1] = gc & -68; }
}
void rs_7_07_15_4(void) {
	guca[5] = guc = 128;
}
void rs_7_07_15_5(void) {
	if (gia[7] != 0) gi = gi / gia[7];
}
int rs_7_07_15_6(void) {
	return gi3;
}
void rs_7_07_16_1(unsigned long a, char b, int c) {
	b += *gp;
}
void rs_7_07_16_2(unsigned long a, char b, int c) {
	if (gu2 != 0) gs.u = gu2 / gu2;
}
void rs_7_07_16_3(unsigned long a, char b, int c) {
	gs.p = gp;
}
int rs_7_07_16_4(unsigned long a, char b, int c) {
	if (gl >= 6L) return gi;
}
void rs_7_07_16_5(unsigned long a, char b, int c) {
	int i = ji;
	for (i = 0; i < 15; i++) { if (gps->l != 0) gpl[3] = gpl[0] % gps->l; vl(rl(gpl[1])); --c; }
}
int rs_7_07_16_6(unsigned long a, char b, int c) {
	return gia[b];
}
void rs_7_07_17_0(void) {
	switch (gu) { case 0: v1(gs.i); break; case 1: vp(gp); break; case 2: guca[0] = guc - 255; case 3: gl *= 8L; break; case 4: gula[0] = gul | gula[3]; break; case 5: gps->u = gu2 / 3; break; default: v2(gi3, gi); break; }
}
void rs_7_07_17_1(void) {
	vd(gda[2]);
}
int rs_7_07_17_2(void) {
	return ('9' <= (char)gula[6]) % 10;
}
void rs_7_07_18_0(char a) {
	char t = gps->c >> 6;
	jc = t;
}
void rs_7_07_18_1(char a) {
	gl2 = (gpl[1] & *gpl) >> 1;
}
void rs_7_07_18_2(char a) {
	++gi3;
}
void rs_7_07_18_3(char a) {
	char t = jc;
	if (gi3 & 0x8) { guca[t] = -2; t++; }
}
void rs_7_07_18_4(char a) {
	while (gi-- > 0) { if (*gpi == 256) break; gpi++; }
}
void rs_7_07_18_5(char a) {
	vu((unsigned int)!gs.u);
}
int rs_7_07_18_6(char a) {
	char t = jc;
	v0();
	return r2(*gpi, gi) ^ (gia[t] << 8);
}
void rs_7_07_19_0(long a, int b) {
	int t = gia[7] + b;
	ji = t;
}
void rs_7_07_19_1(long a, int b) {
	int t = ji;
	unsigned long u = gula[t] - gul;
	jul = u;
}
void rs_7_07_19_2(long a, int b) {
	unsigned long u = jul;
	gul = u;
}
void rs_7_07_19_3(long a, int b) {
	vu(256 << 15);
}
void rs_7_07_19_4(long a, int b) {
	int t = ji;
	v0();
	if (-37 >= gc) gp[1] |= (char)(gu2 >= gua[t]);
}
void rs_7_07_19_5(long a, int b) {
	gu2 = gu = ru(gu);
}
void rs_7_07_19_6(long a, int b) {
	gc <<= 7;
}
long rs_7_07_19_7(long a, int b) {
	return a / 3L;
}
void rs_7_08_00_0(void) {
	long t = 65536L;
	jl = t;
}
void rs_7_08_00_1(void) {
	long t = jl;
	vl(t);
}
int rs_7_08_00_2(void) {
	if (gda[1] > gd2) return 1;
}
void rs_7_08_00_3(void) {
	gc = rc(255) - gc2;
}
int rs_7_08_00_4(void) {
	return !(255 + 255);
}
void rs_7_08_01_0(int a, int *b, unsigned long c) {
	char *t = &gca[a];
	jp = t;
}
void rs_7_08_01_1(int a, int *b, unsigned long c) {
	gpi = b + a;
}
void rs_7_08_01_2(int a, int *b, unsigned long c) {
	guc = ((unsigned char)gul) * (1L < gl ? guca[4] : 7);
}
void rs_7_08_01_3(int a, int *b, unsigned long c) {
	guc = (unsigned char)*gpl;
}
int * rs_7_08_01_4(int a, int *b, unsigned long c) {
	char *t = jp;
	if (guc & 1 && gc < t[a]) return &gia[a];
}
int * rs_7_08_01_5(int a, int *b, unsigned long c) {
	return &gia[7];
}
void rs_7_08_02_0(void) {
	gc = 96 - (gc | gca[4]);
}
void rs_7_08_02_1(void) {
	gs.c = -1;
}
int * rs_7_08_02_2(void) {
	return &gia[3];
}
void rs_7_08_03_0(long a, unsigned int b) {
	unsigned char t = (unsigned char)20849;
	juc = t;
}
void rs_7_08_03_1(long a, unsigned int b) {
	long u = (long)gul - gl2;
	jl = u;
}
void rs_7_08_03_2(long a, unsigned int b) {
	gs.c = gs.c - gp[2];
}
void rs_7_08_03_3(long a, unsigned int b) {
	unsigned char t = juc;
	guca[t] = (unsigned char)a;
}
void rs_7_08_03_4(long a, unsigned int b) {
	long u = jl;
	gl = u;
}
void rs_7_08_03_5(long a, unsigned int b) {
	unsigned char t = juc;
	t /= 7;
}
void rs_7_08_03_6(long a, unsigned int b) {
	if (gd2 != 100.0) { if (gu != 0) b = 1 / gu; }
}
int rs_7_08_03_7(long a, unsigned int b) {
	unsigned char t = juc;
	if (gl2 <= gps->l) return !t;
}
int rs_7_08_03_8(long a, unsigned int b) {
	return ~((int)gc != gi);
}
void rs_7_08_04_0(unsigned int a, long *b) {
	long t = gps->l % 10L;
	jl = t;
}
void rs_7_08_04_1(unsigned int a, long *b) {
	long t = jl;
	vl(t);
}
void rs_7_08_04_2(unsigned int a, long *b) {
	gu += gps->u & gua[a];
}
void rs_7_08_04_3(unsigned int a, long *b) {
	if (gca[3] != 0) gca[1] = (' ') / gca[3];
}
void rs_7_08_04_4(unsigned int a, long *b) {
	gla[a] *= 10L;
}
int * rs_7_08_04_5(unsigned int a, long *b) {
	return gpi + a;
}
void rs_7_08_05_0(int a, struct st *b, int c) {
	double t = (gs.l < 65536L ? gd2 : gs.d);
	jd = t;
}
void rs_7_08_05_1(int a, struct st *b, int c) {
	double t = jd;
	vd(t);
}
void rs_7_08_05_2(int a, struct st *b, int c) {
	gul = gula[a] + (gula[a] + ((unsigned long)a));
}
void rs_7_08_05_3(int a, struct st *b, int c) {
	gul = ~(gula[c] << 23);
}
void rs_7_08_05_4(int a, struct st *b, int c) {
	v0();
}
void rs_7_08_05_5(int a, struct st *b, int c) {
	guca[7] = guca[3];
}
void rs_7_08_05_6(int a, struct st *b, int c) {
	v0();
}
int rs_7_08_05_7(int a, struct st *b, int c) {
	return a;
}
void rs_7_08_06_0(int a, unsigned int b) {
	double t = gd - gs.d;
	jd = t;
}
void rs_7_08_06_1(int a, unsigned int b) {
	v1(a);
}
void rs_7_08_06_2(int a, unsigned int b) {
	gul = gula[a];
}
void rs_7_08_06_3(int a, unsigned int b) {
	if (-407 < a && gca[b] <= 3) if (gua[2] != 0) gu2 = gua[a] / gua[2];
}
void rs_7_08_06_4(int a, unsigned int b) {
	if (gps->c < 'z') gua[b] = gu2 >> 15;
}
void rs_7_08_06_5(int a, unsigned int b) {
	double t = jd;
	v0();
	vd(t);
}
int * rs_7_08_06_6(int a, unsigned int b) {
	return gpi;
}
void rs_7_08_07_0(unsigned long a, unsigned char b, int c) {
	double t = gd2;
	jd = t;
}
void rs_7_08_07_1(unsigned long a, unsigned char b, int c) {
	a -= gul;
}
void rs_7_08_07_2(unsigned long a, unsigned char b, int c) {
	double t = jd;
	vd(t);
}
void rs_7_08_07_3(unsigned long a, unsigned char b, int c) {
	c >>= 13;
}
void rs_7_08_07_4(unsigned long a, unsigned char b, int c) {
	gula[6] = gul % 16UL;
}
void rs_7_08_07_5(unsigned long a, unsigned char b, int c) {
	gu = gu2;
}
int rs_7_08_07_6(unsigned long a, unsigned char b, int c) {
	return (guca[2] ? *gpi : gi) ^ gi3;
}
void rs_7_08_08_1(int a) {
	double t = -0.5;
	jd = t;
}
void rs_7_08_08_2(int a) {
	gl2--;
}
void rs_7_08_08_3(int a) {
	if (gca[a] & 0x10) { gi3 = 16; if (gia[a] != 0) *gpi = 16 / gia[a]; if (gu != 0) gs.u = gua[a] / gu; }
}
void rs_7_08_08_4(int a) {
	int i = ji;
	i = a; do { gla[i] += (long)('a' < '0'); } while (--i > 0);
}
void rs_7_08_08_5(int a) {
	double t = jd;
	gd = t;
}
void rs_7_08_08_6(int a) {
	gs.u -= ru(gps->u);
}
void rs_7_08_08_7(int a) {
	gps->u = gu = 6;
}
int rs_7_08_08_8(int a) {
	return (a >> (a & 15)) - 325;
}
void rs_7_08_09_0(long a) {
	if (gla[2] >= gla[4]) gpl[0] = (long)!(gula[2] & gula[6]);
}
void rs_7_08_09_1(long a) {
	if (gs.d == gd2) guc--;
}
void rs_7_08_09_2(long a) {
	gda[2] -= gd;
}
void rs_7_08_10_0(char a, double b) {
	gla[a] |= *gpl;
}
void rs_7_08_10_1(char a, double b) {
	gps->c -= rc(gi2);
}
void rs_7_08_10_2(char a, double b) {
	if (gc != 0) gps->c = a % gc;
}
unsigned long rs_7_08_10_3(char a, double b) {
	return (gul - gula[a]) & gula[2];
}
void rs_7_08_11_0(void) {
	char t = gc2;
	jc = t;
}
void rs_7_08_11_1(void) {
	char t = jc;
	guc = guca[t] + (guca[2] + guc);
}
void rs_7_08_11_2(void) {
	vu(ru(gu2));
}
void rs_7_08_11_3(void) {
	char t = jc;
	v0();
	gla[1] = (long)!gla[t];
}
unsigned int rs_7_08_11_4(void) {
	char t = jc;
	v0();
	return (unsigned int)gula[t];
}
void rs_7_08_12_1(void) {
	gc = gs.c = gc2;
}
void rs_7_08_12_2(void) {
	v2(gi2, 1);
}
void rs_7_08_12_3(void) {
	int i = ji;
	v0();
	for (i = 7; i > 0; i--) { if (gul != 0) gul = 40203UL / gul; gua[i] = gu = ((unsigned int)gc2) - (gps->u ^ gu2); }
}
void rs_7_08_12_4(void) {
	if ((gs.c = gps->c) < 8) gd2 *= (!gia[5] ? gs.d : 1.0);
}
void rs_7_08_12_5(void) {
	gpi--;
}
char * rs_7_08_12_6(void) {
	return rp();
}
void rs_7_08_13_1(void) {
	int t = gi2 % 16;
	ji = t;
}
void rs_7_08_13_2(void) {
	++guc;
}
void rs_7_08_13_3(void) {
	int t = ji;
	v1(t);
}
void rs_7_08_13_4(void) {
	int i = ji;
	v0();
	for (i = 0; i < 7; i++) { gd -= gs.d; }
}
void rs_7_08_13_5(void) {
	gps->u = (unsigned int)8;
}
char * rs_7_08_13_6(void) {
	return gs.p;
}
void rs_7_08_14_1(void) {
	gi *= 12;
}
void rs_7_08_14_2(void) {
	int i = ji;
	i = 0; while (i < 2) { gul = gula[i]; i++; }
}
void rs_7_08_14_3(void) {
	if (gula[4] != 0) gul = gula[7] % gula[4];
}
void rs_7_08_14_4(void) {
	switch (gl2) { case 1L: vu(256); case 10L: gul = rul(gula[3]); case 16L: vl(gl); break; case 100L: vd(gd2); break; default: guca[5] = guc | 3; break; }
}
void rs_7_08_14_5(void) {
	vc((char)*gpi);
}
int rs_7_08_14_6(void) {
	return !(65536L >> 12);
}
void rs_7_08_15_0(int a, unsigned char b, int c) {
	gula[0] = (gul > 3UL || gca[a] ? (gula[b] + gula[c]) : (0x10000UL ^ gula[a]));
}
void rs_7_08_15_1(int a, unsigned char b, int c) {
	gl = (long)gc;
}
void rs_7_08_15_2(int a, unsigned char b, int c) {
	gu--;
}
unsigned int rs_7_08_15_3(int a, unsigned char b, int c) {
	return (unsigned int)guca[b];
}
void rs_7_08_16_1(int a, unsigned int b, int c) {
	long t = gl2 * 6L;
	jl = t;
}
void rs_7_08_16_2(int a, unsigned int b, int c) {
	char u = (char)!gca[4];
	jc = u;
}
void rs_7_08_16_3(int a, unsigned int b, int c) {
	long t = jl;
	vl(t);
}
void rs_7_08_16_4(int a, unsigned int b, int c) {
	char u = jc;
	v0();
	vc(u);
}
void rs_7_08_16_5(int a, unsigned int b, int c) {
	int i = ji;
	v0();
	for (i = 0; i < a; i++) { guc = (guc >> 2) * guc; guca[3] = (unsigned char)(gua[i] > gu); }
}
void rs_7_08_16_6(int a, unsigned int b, int c) {
	guc--;
}
int rs_7_08_16_7(int a, unsigned int b, int c) {
	return (a % 3) + (255 % 7);
}
void rs_7_08_17_0(char a) {
	*gpi = gia[a] & 256;
}
void rs_7_08_17_1(char a) {
	vc(gc2 - gp[0]);
}
int rs_7_08_17_2(char a) {
	return (256 < gu2 ? gi : gi3) - !gps->c;
}
void rs_7_08_18_0(long a, struct st *b, int c) {
	unsigned long t = gul;
	jul = t;
}
void rs_7_08_18_1(long a, struct st *b, int c) {
	int u = -gi3;
	ji = u;
}
void rs_7_08_18_2(long a, struct st *b, int c) {
	gs.p = gp;
}
void rs_7_08_18_3(long a, struct st *b, int c) {
	unsigned long t = jul;
	int u = ji;
	gula[u] ^= t;
}
void rs_7_08_18_4(long a, struct st *b, int c) {
	int u = ji;
	switch (gps->c) { case 0: gl = a - 75309L; break; case 1: *gpl = -gla[4]; break; case 2: u |= 100; case 3: vl(*gpl); break; default: gs.l = 65536L; break; }
}
void rs_7_08_18_5(long a, struct st *b, int c) {
	int u = ji;
	v0();
	if (gula[u] <= gula[7]) v0();
}
void rs_7_08_19_1(unsigned long a, char b, unsigned char c) {
	unsigned long t = -gula[b];
	jul = t;
}
void rs_7_08_19_2(unsigned long a, char b, unsigned char c) {
	gd = (double)gla[1];
}
void rs_7_08_19_3(unsigned long a, char b, unsigned char c) {
	gps->c = *gp;
}
void rs_7_08_19_4(unsigned long a, char b, unsigned char c) {
	int i = ji;
	for (i = 14; i > 0; i--) { v2(gi / 4, gi); gps->u = -gua[b] | (gu2 - gu); }
}
void rs_7_08_19_5(unsigned long a, char b, unsigned char c) {
	if (r1(gi)) { gpi = &gia[2]; if (gu2 != 0) gu2 = gu2 % gu2; } else { gula[c] = ~gula[b]; if (gl != 0) gla[b] = gl2 / gl; gca[b] = (gc % 16) / 2; }
}
void rs_7_08_19_6(unsigned long a, char b, unsigned char c) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
void rs_7_08_19_7(unsigned long a, char b, unsigned char c) {
	if (r2(gi2, gia[7])) if (gs.u != 0) gu2 = 4848 / gs.u;
}
char rs_7_08_19_8(unsigned long a, char b, unsigned char c) {
	return b;
}
void rs_7_09_00_1(void) {
	unsigned char t = 128;
	juc = t;
}
void rs_7_09_00_2(void) {
	int i = ji;
	unsigned char t = juc;
	for (i = 0; i < 10; i++) { t = guc = (t - ((unsigned char)gul)) - (t | 123); t = (255 & t) - (((unsigned char)gs.l) - t); if (gu2 != 0) gps->u = ((unsigned int)gla[i]) % gu2; }
}
void rs_7_09_00_3(void) {
	gu /= 16;
}
void rs_7_09_00_4(void) {
	vl(gs.l);
}
void rs_7_09_01_1(int *a, unsigned int b) {
	gpl[1] = (long)gi2;
}
void rs_7_09_01_2(int *a, unsigned int b) {
	guc ^= guca[2] ^ 4;
}
void rs_7_09_01_3(int *a, unsigned int b) {
	gi--;
}
void rs_7_09_01_4(int *a, unsigned int b) {
	int i = ji;
	for (i = 4; i > 0; i--) { if (gi2 != 0) gs.i = a[5] % gi2; }
}
char rs_7_09_01_5(int *a, unsigned int b) {
	return 0;
}
void rs_7_09_02_0(void) {
	int t = gps->a[1];
	ji = t;
}
void rs_7_09_02_1(void) {
	if (gul <= 5UL) { gu2 *= 11; }
}
void rs_7_09_02_2(void) {
	guc = -guc;
}
void rs_7_09_02_3(void) {
	int t = ji;
	gi = t;
}
int * rs_7_09_02_4(void) {
	return &gia[3];
}
void rs_7_09_03_0(long a, double b, unsigned int c) {
	int t = (gps->u >= gs.u);
	ji = t;
}
void rs_7_09_03_1(long a, double b, unsigned int c) {
	vd(-gd);
}
void rs_7_09_03_2(long a, double b, unsigned int c) {
	int t = ji;
	v0();
	gps->u = gu << (t & 15);
}
void rs_7_09_03_3(long a, double b, unsigned int c) {
	gula[c] = (unsigned long)(gs.u & gua[0]);
}
void rs_7_09_03_4(long a, double b, unsigned int c) {
	int t = ji;
	v0();
	if (a == *gpl) gca[t] |= 21;
}
void rs_7_09_03_5(long a, double b, unsigned int c) {
	--gi2;
}
char rs_7_09_03_6(long a, double b, unsigned int c) {
	return gps->c | 32;
}
void rs_7_09_04_0(unsigned long a, unsigned char b) {
	gla[b] |= 65536L | gl;
}
void rs_7_09_04_1(unsigned long a, unsigned char b) {
	gula[b] &= -gul;
}
void rs_7_09_04_2(unsigned long a, unsigned char b) {
	if (gul & 0x10) { if (gl2 != 0) gl2 = gpl[1] / gl2; } else { gd = (gd / 100.0) / 2.5; b = guc = (gul >= a ? guca[b] : guca[b]) << 2; }
}
void rs_7_09_04_3(unsigned long a, unsigned char b) {
	a = gula[7] = (unsigned long)(gl >> 22);
}
int * rs_7_09_04_4(unsigned long a, unsigned char b) {
	return gpi;
}
void rs_7_09_05_1(void) {
	vp(gp);
}
void rs_7_09_05_2(void) {
	gu2 <<= 3;
}
void rs_7_09_05_3(void) {
	if (((unsigned long)guca[3]) < 4UL) gu++;
}
void rs_7_09_05_4(void) {
	int i = ji;
	v0();
	for (i = 0; i < 12; i++) { gla[i] = (long)gu2; gpi = &gia[0]; gul |= gula[i] - gul; }
}
void rs_7_09_05_5(void) {
	gs.d = (double)gl - gd;
}
char * rs_7_09_05_6(void) {
	return gps->p;
}
void rs_7_09_06_0(unsigned long a) {
	double t = gd * (double)gl2;
	jd = t;
}
void rs_7_09_06_1(unsigned long a) {
	unsigned char u = guc + 128;
	juc = u;
}
void rs_7_09_06_2(unsigned long a) {
	double t = jd;
	vd(t);
}
void rs_7_09_06_3(unsigned long a) {
	gpi[1] = 127 * 8;
}
void rs_7_09_06_4(unsigned long a) {
	*gpl = *gpl & 2L;
}
void rs_7_09_06_5(unsigned long a) {
	v2(gi2, 127 + gi2);
}
void rs_7_09_06_6(unsigned long a) {
	while (gi-- > 0) { if (*gp == ' ') break; gp++; }
}
void rs_7_09_06_7(unsigned long a) {
	unsigned char u = juc;
	v0();
	guc = u;
}
void rs_7_09_06_8(unsigned long a) {
	switch (gi) { case 8: gu2 -= 1; case 20: gca[3] %= 7; break; }
}
unsigned int rs_7_09_06_9(unsigned long a) {
	return (((unsigned int)gps->l) - gu2) ^ gu2;
}
void rs_7_09_07_0(unsigned int a) {
	gua[a] >>= 5;
}
void rs_7_09_07_1(unsigned int a) {
	gu2 += a - gu;
}
unsigned long rs_7_09_07_2(unsigned int a) {
	return 97129UL;
}
void rs_7_09_08_0(int a, int *b) {
	unsigned char t = guca[6];
	juc = t;
}
void rs_7_09_08_1(int a, int *b) {
	v2(gi2, 290 + b[0]);
}
void rs_7_09_08_2(int a, int *b) {
	gu2++;
}
void rs_7_09_08_3(int a, int *b) {
	if (guc) { vp(gs.p); if (gs.u != 0) gua[5] = gu / gs.u; }
}
void rs_7_09_08_4(int a, int *b) {
	unsigned char t = juc;
	v0();
	guc = t;
}
void rs_7_09_09_1(int a, char *b, char c) {
	int i = ji;
	int t = gps->i % 2;
	ji = t;
}
void rs_7_09_09_2(int a, char *b, char c) {
	char *u = rp();
	jp = u;
}
void rs_7_09_09_3(int a, char *b, char c) {
	int i = ji;
	v0();
	i = 4; do { gl = *gpl - rl(gl2); } while (--i > 0);
}
void rs_7_09_09_4(int a, char *b, char c) {
	char *u = jp;
	v0();
	gp = u;
}
void rs_7_09_09_5(int a, char *b, char c) {
	b[1] = ((char)(c < b[2])) ^ (gc | gs.c);
}
void rs_7_09_09_6(int a, char *b, char c) {
	gc ^= ~*b;
}
void rs_7_09_09_7(int a, char *b, char c) {
	int t = ji;
	v0();
	v1(t);
}
int * rs_7_09_09_8(int a, char *b, char c) {
	return gpi;
}
void rs_7_09_10_0(void) {
	if (gps->c) { if (gs.l != 0) gl2 = gl2 / gs.l; gs.d = gd * gs.d; } else { gd2 += -(double)gl; gu2 = (gps->u + 5) ^ ((unsigned int)!gi); }
}
void rs_7_09_10_1(void) {
	v2(gi2 << 15, gi);
}
void rs_7_09_10_2(void) {
	gula[5] = ((unsigned long)gc2) - 20077UL;
}
void rs_7_09_10_3(void) {
	vp(gp + 1);
}
char * rs_7_09_10_4(void) {
	return gp + 1;
}
void rs_7_09_11_1(void) {
	double t = -gs.d;
	jd = t;
}
void rs_7_09_11_2(void) {
	double t = jd;
	gd = t;
}
void rs_7_09_11_3(void) {
	vu(~854);
}
void rs_7_09_11_4(void) {
	gula[1] = gul % 2UL;
}
void rs_7_09_11_5(void) {
	guca[0] >>= 3;
}
void rs_7_09_11_6(void) {
	guc += (unsigned char)gi;
}
void rs_7_09_11_7(void) {
	int i = ji;
	v0();
	i = 0; while (i < 15) { gc = (gp[0] + gp[3]) | (gc2 & ' '); i++; }
}
void rs_7_09_12_0(void) {
	unsigned char t = guca[3];
	juc = t;
}
void rs_7_09_12_1(void) {
	if (r2(gi2, 100)) { if (gl2 != 0) gps->l = gla[1] / gl2; }
}
void rs_7_09_12_2(void) {
	unsigned char t = juc;
	v0();
	gc = (gc2 + (char)gla[t]) ^ (gca[3] - gs.c);
}
void rs_7_09_12_3(void) {
	if (gula[2] < 44062UL) if (gu2 != 0) gu = 255 % gu2;
}
void rs_7_09_13_1(void) {
	int i = ji;
	for (i = 16; i > 0; i--) { if (gula[i] != 0) gul = gula[i] % gula[i]; gc = (gs.c * gc2) - 59; }
}
void rs_7_09_13_2(void) {
	guca[1] = 255;
}
void rs_7_09_13_3(void) {
	if (r2(gi2, gpi[0])) { if (gi3 != 0) gi = *gpi / gi3; gca[0] <<= 3; } else { if (gu2 != 0) gua[5] = gua[5] / gu2; }
}
int rs_7_09_13_4(void) {
	return gi;
}
void rs_7_09_14_0(void) {
	gd *= gd2 * gd2;
}
void rs_7_09_14_1(void) {
	gu = 3846 - ((unsigned int)(int)gl2);
}
void rs_7_09_14_2(void) {
	gla[1] = gla[5];
}
void rs_7_09_14_3(void) {
	while (gi-- > 0) { if (*gpi == 256) break; gpi++; }
}
void rs_7_09_15_0(int a, int b, unsigned int c) {
	unsigned long t = ((unsigned long)gua[7]) - gula[4];
	jul = t;
}
void rs_7_09_15_1(int a, int b, unsigned int c) {
	long u = 85176L - 66526L;
	jl = u;
}
void rs_7_09_15_2(int a, int b, unsigned int c) {
	long u = jl;
	gl = u;
}
void rs_7_09_15_3(int a, int b, unsigned int c) {
	vc((char)(gu < gua[a]));
}
void rs_7_09_15_4(int a, int b, unsigned int c) {
	unsigned long t = jul;
	v0();
	t += t / 2UL;
}
void rs_7_09_15_5(int a, int b, unsigned int c) {
	if (1 <= 255) { v0(); v2(gi2, gi | (int)gla[2]); gc = (char)((guc | guca[b]) != ((unsigned char)!gl)); } else { guc = (guc + 8) + (247 * 255); }
}
unsigned int rs_7_09_15_6(int a, int b, unsigned int c) {
	long u = jl;
	v0();
	return (((unsigned char)gu) < guca[a] ? (gu2 % 7) : (gps->u | ((unsigned int)gi)));
}
void rs_7_09_16_0(int a, int b) {
	int *t = gpi;
	jpi = t;
}
void rs_7_09_16_1(int a, int b) {
	gi3 = gpi[0];
}
void rs_7_09_16_2(int a, int b) {
	int *t = jpi;
	gpi = t;
}
int rs_7_09_16_3(int a, int b) {
	if (gs.c) return 1;
}
int rs_7_09_16_4(int a, int b) {
	return (100 - gi) | ~8;
}
void rs_7_09_17_0(int a, long b) {
	double t = gda[0] - 1.0;
	jd = t;
}
void rs_7_09_17_1(int a, long b) {
	double t = jd;
	vd(t);
}
void rs_7_09_17_2(int a, long b) {
	guca[7] /= 10;
}
void rs_7_09_17_3(int a, long b) {
	gula[a] = ((unsigned long)gua[7]) ^ gula[0];
}
void rs_7_09_17_4(int a, long b) {
	v2(gi2, *gpi + 8);
}
char rs_7_09_17_5(int a, long b) {
	return 6;
}
void rs_7_09_18_0(struct st *a, char b) {
	unsigned int t = gua[0] | gu;
	ju = t;
}
void rs_7_09_18_1(struct st *a, char b) {
	gula[b] = gul = gula[0];
}
void rs_7_09_18_2(struct st *a, char b) {
	unsigned int t = ju;
	if (gl2 >= 65536L) gu2 = -t;
}
void rs_7_09_18_3(struct st *a, char b) {
	unsigned int t = ju;
	v2((gul == ((unsigned long)gla[t]) ? gia[0] : gs.a[b]), gi);
}
void rs_7_09_18_4(struct st *a, char b) {
	vc(gc2 << 7);
}
void rs_7_09_18_5(struct st *a, char b) {
	unsigned int t = ju;
	v0();
	gul -= gula[t];
}
char rs_7_09_18_6(struct st *a, char b) {
	return gc2 ^ (2 << 4);
}
void rs_7_09_19_0(void) {
	long t = rl(gps->l);
	jl = t;
}
void rs_7_09_19_1(void) {
	int *u = rpi(gps->a[3]);
	v0();
	jpi = u;
}
void rs_7_09_19_2(void) {
	gc2 = gps->c = (9 & gs.c) + (8 / 16);
}
void rs_7_09_19_3(void) {
	int *u = jpi;
	v0();
	gps->u = gu;
}
void rs_7_09_19_4(void) {
	if (gula[7] == 0x10000UL) gc += gca[1] * gc2;
}
void rs_7_09_19_5(void) {
	gul = (gula[5] % 4UL) & (gul - ((unsigned long)*gp));
}
void rs_7_09_19_6(void) {
	gl2 %= 2L;
}
void rs_7_09_19_7(void) {
	long t = jl;
	v0();
	gl = t;
}
unsigned int rs_7_09_19_8(void) {
	return ~(256 + gu);
}
