/* Every statement line of random12 alone in its own function (gen_rstmt.py corpus/random12 12): rs_<A>_<BB>_<CC>_<k> is line k of
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

void rs_12_00_00_1(int a, unsigned char b) {
	int t = gi3 / 2;
	ji = t;
}
void rs_12_00_00_2(int a, unsigned char b) {
	int i = ji;
	for (i = 0; i < 16; i++) { gp[0] = rc(gia[i]) + (gp[2] + gc); vd(gs.d - 0.5); gla[i] &= gl2; }
}
void rs_12_00_00_3(int a, unsigned char b) {
	gi = a;
}
void rs_12_00_00_4(int a, unsigned char b) {
	int t = ji;
	v0();
	gi = t;
}
unsigned long rs_12_00_00_5(int a, unsigned char b) {
	return gula[6];
}
void rs_12_00_01_0(void) {
	switch (gps->i) { case 1: vs(gps); break; case 10: vc(gc2); break; default: guc = -((unsigned char)gua[0]); break; }
}
void rs_12_00_01_1(void) {
	*gp %= 7;
}
void rs_12_00_01_2(void) {
	if (!gla[7]) { vp(gp); if (gul != 0) gula[2] = gul % gul; gpi = gpi + 1; } else { gd2 = gd; guc = guca[1] = 255; if (*gpi != 0) gpi[3] = gi / *gpi; }
}
int * rs_12_00_01_3(void) {
	return gpi;
}
void rs_12_00_02_0(char a, unsigned char b, char c) {
	long t = gpl[0] - (long)gc2;
	jl = t;
}
void rs_12_00_02_1(char a, unsigned char b, char c) {
	int *u = gpi + a;
	jpi = u;
}
void rs_12_00_02_2(char a, unsigned char b, char c) {
	gda[0] += gs.d - gd2;
}
void rs_12_00_02_3(char a, unsigned char b, char c) {
	int *u = jpi;
	gpi = u;
}
void rs_12_00_02_4(char a, unsigned char b, char c) {
	long t = jl;
	t >>= 8;
}
void rs_12_00_02_5(char a, unsigned char b, char c) {
	v0();
}
void rs_12_00_02_6(char a, unsigned char b, char c) {
	gc2 = (char)(gul >= -gul);
}
void rs_12_00_02_7(char a, unsigned char b, char c) {
	*gpl = (long)!(gua[0] - gu);
}
int rs_12_00_02_8(char a, unsigned char b, char c) {
	return (gi = 127);
}
void rs_12_00_03_0(void) {
	gps->a[0] = gs.i;
}
void rs_12_00_03_1(void) {
	vd(-gd2);
}
unsigned long rs_12_00_03_2(void) {
	return (gula[6] ^ gul) - (gula[3] & gul);
}
void rs_12_00_04_0(unsigned int a, int b, struct st *c) {
	double t = (gia[a] & 0x8 ? gs.d : 100.0);
	jd = t;
}
void rs_12_00_04_1(unsigned int a, int b, struct st *c) {
	gl2 = (gc ? *gpl : gpl[1]) * (-69917L - 6L);
}
void rs_12_00_04_2(unsigned int a, int b, struct st *c) {
	double t = jd;
	gd = t;
}
void rs_12_00_04_3(unsigned int a, int b, struct st *c) {
	gca[a] = gc << 3;
}
int rs_12_00_04_4(unsigned int a, int b, struct st *c) {
	return ((guc == 128 ? guca[6] : guca[b]) < (r1(b) ? guc : guca[b]));
}
void rs_12_00_05_1(struct st *a, unsigned long b) {
	int i = ji;
	i = 15; do { gs.d = -gs.d; } while (--i > 0);
}
void rs_12_00_05_2(struct st *a, unsigned long b) {
	guc = (unsigned char)gl2;
}
void rs_12_00_05_3(struct st *a, unsigned long b) {
	gul--;
}
int * rs_12_00_05_4(struct st *a, unsigned long b) {
	return gpi;
}
void rs_12_00_06_0(int a) {
	int *t = gpi;
	jpi = t;
}
void rs_12_00_06_1(int a) {
	if ((gia[a] = gi2)) { if (gua[4] != 0) gu = ((unsigned int)gp[1]) % gua[4]; }
}
void rs_12_00_06_2(int a) {
	gu = ru(-gps->u);
}
void rs_12_00_06_3(int a) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_12_00_06_4(int a) {
	*gpl = gps->l;
}
int rs_12_00_06_5(int a) {
	return (100 * 4) - gi3;
}
void rs_12_00_07_0(char a, int b, unsigned int c) {
	int *t = gpi + c;
	jpi = t;
}
void rs_12_00_07_1(char a, int b, unsigned int c) {
	vc(rc(gi));
}
void rs_12_00_07_2(char a, int b, unsigned int c) {
	if (gpl[2] != 0) gla[a] = *gpl % gpl[2];
}
void rs_12_00_07_3(char a, int b, unsigned int c) {
	gs.l *= 12L;
}
void rs_12_00_07_4(char a, int b, unsigned int c) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_12_00_07_5(char a, int b, unsigned int c) {
	gl = gl2 = (gl == gs.l ? gl2 : gl2);
}
void rs_12_00_07_6(char a, int b, unsigned int c) {
	gs.p = gp;
}
int rs_12_00_07_7(char a, int b, unsigned int c) {
	return 100;
}
void rs_12_00_08_0(char *a) {
	unsigned int t = 32767;
	ju = t;
}
void rs_12_00_08_1(char *a) {
	vu(7531);
}
void rs_12_00_08_2(char *a) {
	v1((int)gpl[3]);
}
void rs_12_00_08_3(char *a) {
	if (r1(gps->i)) { gp = a; }
}
void rs_12_00_08_4(char *a) {
	gp[0] = (char)gia[0] - 5;
}
void rs_12_00_08_5(char *a) {
	unsigned int t = ju;
	v0();
	gu = t;
}
void rs_12_00_08_6(char *a) {
	gula[6] = -0x10000UL;
}
int * rs_12_00_08_7(char *a) {
	return gpi;
}
void rs_12_00_09_0(void) {
	int *t = gpi;
	jpi = t;
}
void rs_12_00_09_1(void) {
	int u = 856;
	ji = u;
}
void rs_12_00_09_2(void) {
	gu = gua[7] = ((unsigned int)4) ^ (gu + 26078);
}
void rs_12_00_09_3(void) {
	vp(rp());
}
void rs_12_00_09_4(void) {
	gl2 = gl;
}
void rs_12_00_09_5(void) {
	int *t = jpi;
	int u = ji;
	v0();
	v1(*t >> (u & 15));
}
int * rs_12_00_09_6(void) {
	int *t = jpi;
	int u = ji;
	v0();
	return t + u;
}
void rs_12_00_10_0(unsigned int a, long b) {
	int t = (gs.a[a] >= gia[a]);
	ji = t;
}
void rs_12_00_10_1(unsigned int a, long b) {
	unsigned int u = 20681;
	ju = u;
}
void rs_12_00_10_2(unsigned int a, long b) {
	unsigned int u = ju;
	if (0x10000UL != gula[a]) { if (gula[6] != 0) gul = 0x10000UL % gula[6]; } else { if (gi != 0) *gpi = 16 / gi; if (a != 0) gua[a] = u % a; if (gca[u] != 0) gca[2] = gps->c % gca[u]; }
}
void rs_12_00_10_3(unsigned int a, long b) {
	int t = ji;
	gi = t;
}
void rs_12_00_10_4(unsigned int a, long b) {
	unsigned int u = ju;
	gu = -u;
}
void rs_12_00_10_5(unsigned int a, long b) {
	if (gl2 != 0) gl = gps->l % gl2;
}
long rs_12_00_10_6(unsigned int a, long b) {
	return *gpl;
}
void rs_12_00_11_0(char a, unsigned char b) {
	gla[b] <<= (b & 15);
}
void rs_12_00_11_1(char a, unsigned char b) {
	switch (gi) { case 0: gl2 = gla[0] - gs.l; break; case 1: v1(2); case 2: gs.l = gps->l & gla[a]; break; case 3: *gp = rc(gi3); break; default: b = guc / 4; break; }
}
void rs_12_00_11_2(char a, unsigned char b) {
	if (guc) if (gps->c != 0) gc = a / gps->c;
}
void rs_12_00_11_3(char a, unsigned char b) {
	++gi;
}
void rs_12_00_11_4(char a, unsigned char b) {
	vp(gps->p);
}
unsigned int rs_12_00_11_5(char a, unsigned char b) {
	return (gua[6] = gu);
}
void rs_12_00_12_1(void) {
	v0();
}
void rs_12_00_12_2(void) {
	int i = ji;
	v0();
	for (i = 0; i < 2; i++) { if (gul != 0) gul = gul / gul; }
}
void rs_12_00_12_3(void) {
	gula[3] <<= 7;
}
void rs_12_00_12_4(void) {
	--gu;
}
int rs_12_00_12_5(void) {
	return gps->a[0] >> 3;
}
void rs_12_00_13_1(int a, long b, int c) {
	double t = gd2 + gs.d;
	jd = t;
}
void rs_12_00_13_2(int a, long b, int c) {
	double u = gs.d * 100.0;
	jd = u;
}
void rs_12_00_13_3(int a, long b, int c) {
	double t = jd;
	gd = t;
}
void rs_12_00_13_4(int a, long b, int c) {
	int i = ji;
	double u = jd;
	i = 0; while (i < a) { u -= gs.d; gs.c = (guca[i] >= guc ? gc : rc(256)); v0(); i++; }
}
void rs_12_00_13_5(int a, long b, int c) {
	double u = jd;
	v0();
	switch (gps->u) { case 0: v2(gi2, gia[6]); break; case 1: vs(gps); break; case 2: vs(gps); break; case 3: v2(gi2, 255); break; case 4: v0(); break; default: v0(); break; }
}
void rs_12_00_13_6(int a, long b, int c) {
	gc2 <<= 3;
}
void rs_12_00_13_7(int a, long b, int c) {
	double u = jd;
	v0();
	u = gd;
}
int rs_12_00_13_8(int a, long b, int c) {
	return gi3 << (a & 15);
}
void rs_12_00_14_0(char a) {
	char t = rc(16);
	jc = t;
}
void rs_12_00_14_1(char a) {
	char t = jc;
	v0();
	t += rc(826);
}
void rs_12_00_14_2(char a) {
	char t = jc;
	v0();
	guca[t] = (unsigned char)!(~gps->l);
}
void rs_12_00_14_3(char a) {
	while (gi-- > 0) *gpi++ = 6;
}
unsigned long rs_12_00_14_4(char a) {
	return gul;
}
void rs_12_00_15_1(double a, unsigned char b, double c) {
	long t = gla[b] - gl;
	jl = t;
}
void rs_12_00_15_2(double a, unsigned char b, double c) {
	double u = -c;
	jd = u;
}
void rs_12_00_15_3(double a, unsigned char b, double c) {
	int i = ji;
	for (i = 0; i < 5; i++) { ++gc; }
}
void rs_12_00_15_4(double a, unsigned char b, double c) {
	guc = ((unsigned char)gul) + (guca[b] / 2);
}
int * rs_12_00_15_5(double a, unsigned char b, double c) {
	if (gpi[1]) return &gia[b];
}
void rs_12_00_15_6(double a, unsigned char b, double c) {
	double u = jd;
	gd = u;
}
void rs_12_00_15_7(double a, unsigned char b, double c) {
	long t = jl;
	vl(t);
}
void rs_12_00_15_8(double a, unsigned char b, double c) {
	vd(-gd2);
}
int * rs_12_00_15_9(double a, unsigned char b, double c) {
	return gpi + b;
}
void rs_12_00_16_0(int *a, long b, int c) {
	v2(gps->a[c] << 5, gi);
}
void rs_12_00_16_1(int *a, long b, int c) {
	gul = gula[2] = 12705UL >> (c & 15);
}
void rs_12_00_16_2(int *a, long b, int c) {
	if (gs.c) { gi3 = c; gi2 <<= 1; ++b; } else { if (2UL <= ((unsigned long)gps->u)) guca[c] = (unsigned char)!*gp; }
}
void rs_12_00_16_3(int *a, long b, int c) {
	if (gul != 0) gul = gula[c] / gul;
}
char rs_12_00_16_4(int *a, long b, int c) {
	return (gc2 + gca[0]) * (gc & gs.c);
}
void rs_12_00_17_0(unsigned long a, unsigned long b) {
	int *t = gpi;
	jpi = t;
}
void rs_12_00_17_1(unsigned long a, unsigned long b) {
	int *t = jpi;
	int *u = t + 1;
	jpi = u;
}
void rs_12_00_17_2(unsigned long a, unsigned long b) {
	int *u = jpi;
	gpi = u;
}
void rs_12_00_17_3(unsigned long a, unsigned long b) {
	int *t = jpi;
	gpi = t;
}
void rs_12_00_17_4(unsigned long a, unsigned long b) {
	gu++;
}
void rs_12_00_17_5(unsigned long a, unsigned long b) {
	guc = ~128 + (236 % 4);
}
char * rs_12_00_17_6(unsigned long a, unsigned long b) {
	return gs.p;
}
void rs_12_00_18_0(long a, unsigned char b, unsigned int c) {
	b -= 128;
}
void rs_12_00_18_1(long a, unsigned char b, unsigned int c) {
	--b;
}
void rs_12_00_18_2(long a, unsigned char b, unsigned int c) {
	switch (gl) { case 1L: guc %= 3; break; case 5L: gd = gs.d + gs.d; break; }
}
void rs_12_00_18_3(long a, unsigned char b, unsigned int c) {
	gca[c] = rc(gi2);
}
char rs_12_00_18_4(long a, unsigned char b, unsigned int c) {
	return gc2 | (7 - (char)gu2);
}
void rs_12_00_19_0(int a, unsigned long b, unsigned long c) {
	char *t = gs.p;
	jp = t;
}
void rs_12_00_19_1(int a, unsigned long b, unsigned long c) {
	gu2 = ((unsigned int)!c) << (a & 15);
}
void rs_12_00_19_2(int a, unsigned long b, unsigned long c) {
	gula[a] = 8UL % 4UL;
}
void rs_12_00_19_3(int a, unsigned long b, unsigned long c) {
	vd(gd2 / 100.0);
}
void rs_12_00_19_4(int a, unsigned long b, unsigned long c) {
	if (gps->c == gp[3]) guc = (!gl ? (guc | guca[a]) : (guc * guca[a]));
}
void rs_12_00_19_5(int a, unsigned long b, unsigned long c) {
	char *t = jp;
	v0();
	gp = t;
}
unsigned int rs_12_00_19_6(int a, unsigned long b, unsigned long c) {
	return -((unsigned int)!guc);
}
void rs_12_01_00_1(double a, unsigned int b) {
	unsigned char t = guca[2] % 7;
	juc = t;
}
void rs_12_01_00_2(double a, unsigned int b) {
	int i = ji;
	unsigned char t = juc;
	for (i = 0; i < 10; i++) { t ^= -guc; }
}
void rs_12_01_00_3(double a, unsigned int b) {
	gula[7] = 20759UL;
}
int rs_12_01_00_4(double a, unsigned int b) {
	int i = ji;
	return gi2 + (gps->i + gpi[1]);
}
void rs_12_01_01_0(unsigned int a) {
	int *t = gpi;
	jpi = t;
}
void rs_12_01_01_1(unsigned int a) {
	gs.l >>= 24;
}
void rs_12_01_01_2(unsigned int a) {
	if (gl != 0) gpl[3] = gs.l / gl;
}
void rs_12_01_01_3(unsigned int a) {
	vs(gps);
}
void rs_12_01_01_4(unsigned int a) {
	int *t = jpi;
	v0();
	t[0] = 2 - gs.i;
}
unsigned long rs_12_01_01_5(unsigned int a) {
	return ((unsigned long)2) + gul;
}
void rs_12_01_02_1(struct st *a, char b) {
	guc /= 16;
}
void rs_12_01_02_2(struct st *a, char b) {
	int i = ji;
	for (i = 6; i > 0; i--) { if (b != 0) b = (char)gu % b; gula[b] |= gula[i] | gul; }
}
void rs_12_01_02_3(struct st *a, char b) {
	if (!a->u && gi2) gla[3] |= gla[b];
}
void rs_12_01_02_4(struct st *a, char b) {
	gc = -b - ~gc;
}
char * rs_12_01_02_5(struct st *a, char b) {
	return gp;
}
void rs_12_01_03_0(unsigned char a, struct st *b, int c) {
	switch (c) { case 1: vs(b); break; case 3: gia[2] += gi3; break; case 5: gda[1] += gd; break; case 16: gu2 |= gua[1]; break; case 100: vu(16756); break; default: vu(gua[a]); break; }
}
void rs_12_01_03_1(unsigned char a, struct st *b, int c) {
	vd(gd2);
}
int rs_12_01_03_2(unsigned char a, struct st *b, int c) {
	return (c - b->a[c]) + (gi - 8);
}
void rs_12_01_04_0(int a, char *b) {
	unsigned int t = gu * 8;
	ju = t;
}
void rs_12_01_04_1(int a, char *b) {
	gi ^= a - 1;
}
void rs_12_01_04_2(int a, char *b) {
	unsigned int t = ju;
	gu = t;
}
void rs_12_01_04_3(int a, char *b) {
	while (a-- > 0) { if (*b == -94) break; b++; }
}
int * rs_12_01_04_4(int a, char *b) {
	return gpi + a;
}
void rs_12_01_05_0(double a, unsigned char b, unsigned char c) {
	int t = r2(gi2, gi2);
	ji = t;
}
void rs_12_01_05_1(double a, unsigned char b, unsigned char c) {
	vs(gps);
}
void rs_12_01_05_2(double a, unsigned char b, unsigned char c) {
	switch (gps->u) { case 0: gp = gp + c; case 1: gu2 %= 2; break; case 2: gu2 = gua[0]; break; case 3: *gp = gc + *gp; break; }
}
void rs_12_01_05_3(double a, unsigned char b, unsigned char c) {
	gpl[2] = gl;
}
void rs_12_01_05_4(double a, unsigned char b, unsigned char c) {
	int t = ji;
	v0();
	switch (t) { case 2: case 20: gia[2] ^= gia[0]; break; }
}
void rs_12_01_05_5(double a, unsigned char b, unsigned char c) {
	v2(gps->i, gi);
}
char rs_12_01_05_6(double a, unsigned char b, unsigned char c) {
	int t = ji;
	v0();
	return (gp[1] * gps->c) >> (t & 7);
}
void rs_12_01_06_1(unsigned long a) {
	*gp = gc2 = (gp[1] != gs.c ? 14 : (gc2 ? gca[6] : gps->c));
}
void rs_12_01_06_2(unsigned long a) {
	int i = ji;
	for (i = 5; i > 0; i--) { gs.d = (1.0 / 10.0) + (gda[0] + gd2); if (gia[i] != 0) gi3 = 8 % gia[i]; gu = gua[i]; }
}
int rs_12_01_06_3(unsigned long a) {
	return -gi3 + (int)a;
}
void rs_12_01_07_0(struct st *a, long b) {
	int t = 1;
	ji = t;
}
void rs_12_01_07_1(struct st *a, long b) {
	a->p = gp;
}
void rs_12_01_07_2(struct st *a, long b) {
	int t = ji;
	gpi = gpi + t;
}
void rs_12_01_07_3(struct st *a, long b) {
	gd2 *= ((gula[7] = 38173UL) ? gda[0] : gd);
}
char * rs_12_01_07_4(struct st *a, long b) {
	return rp();
}
void rs_12_01_08_0(void) {
	int t = (gps->u < ((unsigned int)guc));
	ji = t;
}
void rs_12_01_08_1(void) {
	--gl;
}
void rs_12_01_08_2(void) {
	gl -= gl + gla[2];
}
void rs_12_01_08_3(void) {
	gul += 6UL;
}
void rs_12_01_08_4(void) {
	int t = ji;
	if (gd2 > 10.0) gs.u >>= (t & 15);
}
void rs_12_01_08_5(void) {
	int t = ji;
	gula[t] = -12185UL * gul;
}
int rs_12_01_08_6(void) {
	int t = ji;
	return (t = 8);
}
void rs_12_01_09_0(struct st *a, unsigned int b, long c) {
	int t = gi3;
	ji = t;
}
void rs_12_01_09_1(struct st *a, unsigned int b, long c) {
	char *u = gs.p;
	jp = u;
}
void rs_12_01_09_2(struct st *a, unsigned int b, long c) {
	int t = ji;
	if (guca[b]) { guca[t] = guc | 128; gi3 = a->i; if (gua[b] != 0) gu2 = ((unsigned int)gul) % gua[b]; } else { if (gca[0] != 0) *gp = gp[3] % gca[0]; if (gu2 != 0) gu2 = gu / gu2; if (t != 0) t = *gpi % t; }
}
void rs_12_01_09_3(struct st *a, unsigned int b, long c) {
	while (gi-- > 0) { if (*gp == 4) break; gp++; }
}
void rs_12_01_09_4(struct st *a, unsigned int b, long c) {
	char *u = jp;
	gp = u;
}
void rs_12_01_09_5(struct st *a, unsigned int b, long c) {
	if ((double)gi > gd2) if (gc != 0) a->c = gc / gc;
}
int rs_12_01_09_6(struct st *a, unsigned int b, long c) {
	return gps->i;
}
void rs_12_01_10_1(int *a) {
	gd = gs.d;
}
void rs_12_01_10_2(int *a) {
	if (gca[2] != 0) gp[2] = *gp / gca[2];
}
void rs_12_01_10_3(int *a) {
	int i = ji;
	for (i = 0; i < 5; i++) { gs.l <<= 6; if (gs.l != 0) gl2 = gla[i] % gs.l; if (gula[i] != 0) gula[i] = gula[i] % gula[i]; }
}
void rs_12_01_10_4(int *a) {
	int i = ji;
	i = 12; do { ++gpi; if (gc != 0) gc2 = *gp % gc; } while (--i > 0);
}
void rs_12_01_10_5(int *a) {
	gpi = gpi + 1;
}
int rs_12_01_10_6(int *a) {
	return (gia[5] + *gpi) << 11;
}
void rs_12_01_11_0(unsigned char a) {
	char t = rc(gi);
	jc = t;
}
void rs_12_01_11_1(unsigned char a) {
	char t = jc;
	v0();
	gc = t;
}
void rs_12_01_11_2(unsigned char a) {
	gpi = gpi + a;
}
void rs_12_01_11_3(unsigned char a) {
	if (!gp[0]) { v0(); }
}
void rs_12_01_11_4(unsigned char a) {
	v0();
}
void rs_12_01_11_5(unsigned char a) {
	gpl[0] |= gl2 + gl;
}
char * rs_12_01_11_6(unsigned char a) {
	return rp();
}
void rs_12_01_12_0(long a, unsigned char b) {
	gs.d += (double)a;
}
void rs_12_01_12_1(long a, unsigned char b) {
	guc = b;
}
int rs_12_01_12_2(long a, unsigned char b) {
	return *gpi - gi2;
}
void rs_12_01_13_0(unsigned int a, long *b) {
	double t = gd2;
	jd = t;
}
void rs_12_01_13_1(unsigned int a, long *b) {
	unsigned int u = gua[a] / 2;
	ju = u;
}
void rs_12_01_13_2(unsigned int a, long *b) {
	while (gi-- > 0) *b++ = 65536L;
}
void rs_12_01_13_3(unsigned int a, long *b) {
	v0();
}
void rs_12_01_13_4(unsigned int a, long *b) {
	unsigned int u = ju;
	v0();
	vu(u);
}
void rs_12_01_13_5(unsigned int a, long *b) {
	guca[a] += guc % 10;
}
void rs_12_01_13_6(unsigned int a, long *b) {
	double t = jd;
	v0();
	vd(t);
}
void rs_12_01_14_0(void) {
	vs(gps);
}
void rs_12_01_14_1(void) {
	gp = rp();
}
void rs_12_01_14_2(void) {
	gu = ~255 | (gs.u | gu2);
}
void rs_12_01_14_3(void) {
	gul = ~gul + rul(gula[5]);
}
int * rs_12_01_14_4(void) {
	return gpi + 1;
}
void rs_12_01_15_0(void) {
	unsigned long t = ((unsigned long)gc2) - gula[6];
	jul = t;
}
void rs_12_01_15_1(void) {
	gc2++;
}
int rs_12_01_15_2(void) {
	if ((gl2 = gl) < 1L) return (int)guc;
}
void rs_12_01_15_3(void) {
	unsigned long t = jul;
	--t;
}
void rs_12_01_15_4(void) {
	unsigned long t = jul;
	gs.c = (char)t + (char)gu;
}
int rs_12_01_15_5(void) {
	return ~(~gi3);
}
void rs_12_01_16_0(unsigned char a, long b) {
	unsigned char t = a;
	juc = t;
}
void rs_12_01_16_1(unsigned char a, long b) {
	if (gula[a] != 0) gul = gula[0] / gula[a];
}
void rs_12_01_16_2(unsigned char a, long b) {
	unsigned char t = juc;
	switch (gi3) { case 0: vl(*gpl); break; case 1: gu2 = gu ^ 255; break; case 2: gps->u = gua[a] * 32767; break; case 3: gps->i = *gpi = ~gs.a[t]; break; case 4: v1(gi3); break; case 5: t += 129; break; default: v0(); break; }
}
int * rs_12_01_16_3(unsigned char a, long b) {
	return gpi + a;
}
void rs_12_01_17_0(void) {
	v2(gi2, gia[2] ^ 67);
}
void rs_12_01_17_1(void) {
	v2(gi2, 256 >> 11);
}
void rs_12_01_17_2(void) {
	gps->c += gps->c - gca[4];
}
int rs_12_01_17_3(void) {
	return gs.i;
}
void rs_12_01_18_1(int a, long *b) {
	gpi++;
}
void rs_12_01_18_2(int a, long *b) {
	gul = (gula[a] * ((unsigned long)guc)) + (gula[7] * 11UL);
}
void rs_12_01_18_3(int a, long *b) {
	int i = ji;
	i = 13; do { *gpl <<= 12; gpi = gpi + a; } while (--i > 0);
}
void rs_12_01_18_4(int a, long *b) {
	guca[a] &= 128;
}
void rs_12_01_18_5(int a, long *b) {
	*gp = gps->c;
}
unsigned int rs_12_01_18_6(int a, long *b) {
	return ru(32767) << 11;
}
void rs_12_01_19_0(char a) {
	unsigned char t = guca[4];
	juc = t;
}
void rs_12_01_19_1(char a) {
	gp = &gca[a];
}
void rs_12_01_19_2(char a) {
	unsigned char t = juc;
	if (t & 4) if (gi2 != 0) gi = gps->a[2] % gi2;
}
void rs_12_02_00_1(void) {
	if (gla[0] != 0) *gpl = *gpl % gla[0];
}
void rs_12_02_00_2(void) {
	gs.d = 0.5 / 0.25;
}
void rs_12_02_00_3(void) {
	gul = gula[7] = 0x10000UL / 100UL;
}
void rs_12_02_00_4(void) {
	int i = ji;
	for (i = 0; i < 7; i++) { if (gl2 != 0) gl = gpl[0] % gl2; }
}
void rs_12_02_00_5(void) {
	if (gia[7] != 0) gi = 1 / gia[7];
}
int * rs_12_02_00_6(void) {
	return rpi(r1(gia[5]));
}
void rs_12_02_01_0(struct st *a) {
	a->p = gp;
}
void rs_12_02_01_1(struct st *a) {
	if (gu2 != 0) a->u = gu2 % gu2;
}
unsigned int rs_12_02_01_2(struct st *a) {
	return gua[4] >> 3;
}
void rs_12_02_02_0(long a) {
	char t = (char)1L;
	jc = t;
}
void rs_12_02_02_1(long a) {
	gi2 = (((unsigned int)!gu2) >= ~27293);
}
void rs_12_02_02_2(long a) {
	gul--;
}
void rs_12_02_02_3(long a) {
	char t = jc;
	if (gs.i == gi3) { guc = guca[0] = guca[t] ^ guc; gpi = &gia[t]; } else { gu = gu << 13; gia[t] = gi3; }
}
unsigned long rs_12_02_02_4(long a) {
	return (gul + 0x10000UL) / 16UL;
}
void rs_12_02_03_0(char a, int b) {
	switch (gps->l) { case 0L: v2(gi, gi); break; case 1L: case 2L: gca[2] = gc2 << 3; break; case 3L: gps->u += gu; break; default: gps->u = gs.u; break; }
}
void rs_12_02_03_1(char a, int b) {
	if (16 >= gs.i) { gua[a] = gu = gs.u; gs.l = (long)256; *gpl *= 11L; }
}
void rs_12_02_03_2(char a, int b) {
	gua[6] = gu2 ^ gs.u;
}
int rs_12_02_03_3(char a, int b) {
	return (16 >> 5) << 1;
}
void rs_12_02_04_0(char *a, int b) {
	long t = 4L * 5L;
	jl = t;
}
void rs_12_02_04_1(char *a, int b) {
	vl(rl(65536L));
}
void rs_12_02_04_2(char *a, int b) {
	++guc;
}
void rs_12_02_04_3(char *a, int b) {
	long t = jl;
	v0();
	gl = t;
}
void rs_12_02_04_4(char *a, int b) {
	gla[b] = *gpl;
}
void rs_12_02_04_5(char *a, int b) {
	gia[b] = 100 ^ gs.i;
}
int rs_12_02_04_6(char *a, int b) {
	return (gia[3] ^ 1) >> (b & 15);
}
void rs_12_02_05_0(int a, double b, unsigned int c) {
	int t = gia[1];
	ji = t;
}
void rs_12_02_05_1(int a, double b, unsigned int c) {
	char *u = rp();
	jp = u;
}
void rs_12_02_05_2(int a, double b, unsigned int c) {
	++gul;
}
void rs_12_02_05_3(int a, double b, unsigned int c) {
	char *u = jp;
	v0();
	vp(u);
}
void rs_12_02_05_4(int a, double b, unsigned int c) {
	int t = ji;
	v0();
	t = gi3 >> 15;
}
void rs_12_02_05_5(int a, double b, unsigned int c) {
	gl ^= rl(59812L);
}
void rs_12_02_05_6(int a, double b, unsigned int c) {
	int t = ji;
	v0();
	if (gula[2] != 0) gula[t] = gul / gula[2];
}
unsigned int rs_12_02_05_7(int a, double b, unsigned int c) {
	return (gua[5] = gu2);
}
void rs_12_02_06_1(unsigned char a, unsigned char b) {
	int t = gi | gs.a[4];
	ji = t;
}
void rs_12_02_06_2(unsigned char a, unsigned char b) {
	unsigned char u = (unsigned char)gu2;
	juc = u;
}
void rs_12_02_06_3(unsigned char a, unsigned char b) {
	unsigned char u = juc;
	if (gu != gu2) { v0(); gps->u = 256; }
}
void rs_12_02_06_4(unsigned char a, unsigned char b) {
	gula[b] <<= 27;
}
void rs_12_02_06_5(unsigned char a, unsigned char b) {
	int i = ji;
	int t = ji;
	v0();
	i = 0; while (i < 10) { gu2 /= 2; gpl[1] |= (long)(t >= gi3); i++; }
}
void rs_12_02_06_6(unsigned char a, unsigned char b) {
	switch (gl2) { case 0L: gc2 = 'A' - gc2; case 1L: gpi = rpi(gia[7]); break; }
}
unsigned int rs_12_02_06_7(unsigned char a, unsigned char b) {
	return gu & ru(gu2);
}
void rs_12_02_07_0(int a) {
	if (r1(gi)) { gpi = rpi((int)gc); if (gla[a] != 0) gs.l = gpl[3] % gla[a]; } else { if (gula[3] != 0) gul = 9UL / gula[3]; gc2 |= (' ') + *gp; }
}
void rs_12_02_07_1(int a) {
	if (gc2) { gl2 = ~gl & *gpl; if (gu2 != 0) gu2 = ((unsigned int)gul) % gu2; }
}
char rs_12_02_07_2(int a) {
	return (3 - gps->c) & (*gp & 4);
}
void rs_12_02_08_0(int a) {
	unsigned long t = gul;
	jul = t;
}
void rs_12_02_08_1(int a) {
	int u = gi2 ^ gia[4];
	ji = u;
}
void rs_12_02_08_2(int a) {
	unsigned long t = jul;
	t = rul(t) << 24;
}
void rs_12_02_08_3(int a) {
	++gp;
}
void rs_12_02_08_4(int a) {
	vs(gps);
}
void rs_12_02_08_5(int a) {
	int u = ji;
	v0();
	gi = u;
}
void rs_12_02_09_0(long *a, unsigned char b, unsigned int c) {
	char *t = gp;
	jp = t;
}
void rs_12_02_09_1(long *a, unsigned char b, unsigned int c) {
	int u = gia[c] / 3;
	ji = u;
}
void rs_12_02_09_2(long *a, unsigned char b, unsigned int c) {
	char *t = jp;
	t[1] = ~gca[6];
}
void rs_12_02_09_3(long *a, unsigned char b, unsigned int c) {
	gpi = gpi + b;
}
void rs_12_02_09_4(long *a, unsigned char b, unsigned int c) {
	char *t = jp;
	++t;
}
void rs_12_02_09_5(long *a, unsigned char b, unsigned int c) {
	gp[0] &= 66 / 100;
}
void rs_12_02_09_6(long *a, unsigned char b, unsigned int c) {
	int u = ji;
	gu = c + (c != 255 ? c : gps->u);
}
int rs_12_02_09_7(long *a, unsigned char b, unsigned int c) {
	return !(68047L / 10L);
}
void rs_12_02_10_0(char a, int b, unsigned long c) {
	unsigned int t = -gua[a];
	ju = t;
}
void rs_12_02_10_1(char a, int b, unsigned long c) {
	unsigned long u = (unsigned long)guc;
	jul = u;
}
void rs_12_02_10_2(char a, int b, unsigned long c) {
	vc(gc2 >> (a & 7));
}
void rs_12_02_10_3(char a, int b, unsigned long c) {
	unsigned int t = ju;
	v0();
	gu = t;
}
void rs_12_02_10_4(char a, int b, unsigned long c) {
	gca[b] = a + gc2;
}
void rs_12_02_10_5(char a, int b, unsigned long c) {
	unsigned long u = jul;
	v0();
	vl((long)u);
}
unsigned int rs_12_02_10_6(char a, int b, unsigned long c) {
	unsigned int t = ju;
	unsigned long u = jul;
	v0();
	return (gs.u = t);
}
void rs_12_02_11_0(unsigned int a, int *b) {
	unsigned char t = -118;
	juc = t;
}
void rs_12_02_11_1(unsigned int a, int *b) {
	unsigned char t = juc;
	int *u = &gia[t];
	jpi = u;
}
void rs_12_02_11_2(unsigned int a, int *b) {
	unsigned char t = juc;
	b[3] = gia[t];
}
void rs_12_02_11_3(unsigned int a, int *b) {
	int *u = jpi;
	gpi = u;
}
void rs_12_02_11_4(unsigned int a, int *b) {
	v1(gi3 - *gpi);
}
char * rs_12_02_11_5(unsigned int a, int *b) {
	if (gua[4]) return gps->p;
}
void rs_12_02_11_6(unsigned int a, int *b) {
	v0();
}
char * rs_12_02_11_7(unsigned int a, int *b) {
	return gps->p + a;
}
void rs_12_02_12_0(void) {
	double t = 10.0;
	jd = t;
}
void rs_12_02_12_1(void) {
	unsigned long u = ((unsigned long)gs.c) * gul;
	jul = u;
}
void rs_12_02_12_2(void) {
	double t = jd;
	vd(t);
}
void rs_12_02_12_3(void) {
	unsigned long u = jul;
	v0();
	if (u != 0) u = u % u;
}
void rs_12_02_12_4(void) {
	unsigned long u = jul;
	v0();
	gul -= u;
}
int * rs_12_02_12_5(void) {
	return rpi(gs.a[6]);
}
void rs_12_02_13_0(long a) {
	unsigned char t = guca[7] | 1;
	juc = t;
}
void rs_12_02_13_1(long a) {
	--gl2;
}
void rs_12_02_13_2(long a) {
	gps->u = gu2 + 255;
}
void rs_12_02_13_3(long a) {
	unsigned char t = juc;
	gca[t] = gca[1];
}
int rs_12_02_13_4(long a) {
	unsigned char t = juc;
	return (((char)t & gca[t]) <= (gc2 + gca[3]));
}
void rs_12_02_14_1(void) {
	unsigned int t = 1;
	ju = t;
}
void rs_12_02_14_2(void) {
	unsigned int t = ju;
	if (gul != 55664UL) *gp = gs.c = (guc != guca[t] ? ((char)guca[t] - gp[1]) : (*gp * gca[t]));
}
void rs_12_02_14_3(void) {
	int i = ji;
	for (i = 0; i < 11; i++) { if (gl2 != 0) gl = 0L / gl2; gc >>= (i & 7); gl &= 70918L - gpl[2]; }
}
unsigned long rs_12_02_14_4(void) {
	return ((unsigned long)(gla[5] != gl2)) << 6;
}
void rs_12_02_15_1(int a) {
	unsigned long t = gul >> 24;
	jul = t;
}
void rs_12_02_15_2(int a) {
	guc <<= 5;
}
void rs_12_02_15_3(int a) {
	int i = ji;
	i = 0; while (i < a) { if (gu2 != 0) gs.u = gu2 % gu2; vl(gs.l & gl); gu = ((unsigned int)gc) % 100; i++; }
}
void rs_12_02_15_4(int a) {
	unsigned long t = jul;
	v0();
	gul = t;
}
int rs_12_02_15_5(int a) {
	return (127 & 2) % 10;
}
void rs_12_02_16_0(void) {
	++gpi;
}
void rs_12_02_16_1(void) {
	if (gl != 0) *gpl = gs.l % gl;
}
void rs_12_02_16_2(void) {
	gl = (gps->l & (long)gi2) << 3;
}
int rs_12_02_16_3(void) {
	return (int)((unsigned int)gl);
}
void rs_12_02_17_0(long a, unsigned long b) {
	if (*gpi && gc != gc2) vc(gca[2] - gca[6]);
}
void rs_12_02_17_1(long a, unsigned long b) {
	switch (gc2) { case 0: gs.l |= gla[5]; break; case 1: vd(10.0); break; default: gu2 = ((unsigned int)gpl[1]) + gua[7]; break; }
}
void rs_12_02_17_2(long a, unsigned long b) {
	--a;
}
void rs_12_02_17_3(long a, unsigned long b) {
	if ((int)guc == gi2) if (gu2 != 0) gps->u = gua[7] / gu2;
}
void rs_12_02_17_4(long a, unsigned long b) {
	gula[0] ^= 0UL;
}
char rs_12_02_17_5(long a, unsigned long b) {
	return (gps->c * gp[1]) | (0 - 'a');
}
void rs_12_02_18_0(char *a, long b) {
	long t = gps->l & gl;
	jl = t;
}
void rs_12_02_18_1(char *a, long b) {
	long t = jl;
	int u = !(int)t;
	ji = u;
}
void rs_12_02_18_2(char *a, long b) {
	int u = ji;
	if (guc == 243 && guc) { gps->l = gla[u] = (gul < 0x10000UL ? -13964L : rl(gl)); gs.l = b; } else { b >>= 20; }
}
void rs_12_02_18_3(char *a, long b) {
	--gi3;
}
void rs_12_02_18_4(char *a, long b) {
	long t = jl;
	v0();
	gl = t;
}
void rs_12_02_18_5(char *a, long b) {
	gd2 = (gula[3] >= ((unsigned long)gu2) ? -10.0 : -gda[0]);
}
void rs_12_02_18_6(char *a, long b) {
	int u = ji;
	v0();
	vu(ru(gps->u));
}
void rs_12_02_18_7(char *a, long b) {
	vd(gd / 100.0);
}
int rs_12_02_18_8(char *a, long b) {
	int u = ji;
	v0();
	return ~(u * gs.a[7]);
}
void rs_12_02_19_0(void) {
	long t = gpl[2];
	jl = t;
}
void rs_12_02_19_1(void) {
	unsigned char u = guca[6] + 114;
	juc = u;
}
int rs_12_02_19_2(void) {
	if (guc) return gps->a[0] % 100;
}
void rs_12_02_19_3(void) {
	while (gi > 0) { gi2 += *gpi++; gi--; }
}
void rs_12_02_19_4(void) {
	unsigned char u = juc;
	guc = u;
}
void rs_12_02_19_5(void) {
	long t = jl;
	gl = t;
}
void rs_12_02_19_6(void) {
	if (gd2 != 100.0) if (gi != 0) gi = gps->i % gi;
}
int rs_12_02_19_7(void) {
	unsigned char u = juc;
	return (gs.i = gs.a[u]);
}
void rs_12_03_00_0(void) {
	gs.d *= gs.d + gd;
}
void rs_12_03_00_1(void) {
	gd2 = (gc > *gp && !gu ? (double)gi : -gd2);
}
void rs_12_03_00_2(void) {
	gps->p = gp;
}
void rs_12_03_00_3(void) {
	gps->p = rp();
}
char * rs_12_03_00_4(void) {
	return gp;
}
void rs_12_03_01_0(double a, unsigned long b, int c) {
	gpl[3] = ((' ') == 'z' ? gl : -88823L);
}
void rs_12_03_01_1(double a, unsigned long b, int c) {
	gd2 *= a;
}
void rs_12_03_01_2(double a, unsigned long b, int c) {
	switch (gl) { case 10L: gca[0] ^= gc; break; case 200L: gl2 = gla[2] = gl; break; case 1000L: gu = gua[c] / 2; break; default: gi3 = gia[6] = gi << 15; break; }
}
void rs_12_03_01_3(double a, unsigned long b, int c) {
	++gi;
}
void rs_12_03_01_4(double a, unsigned long b, int c) {
	gp = rp();
}
int rs_12_03_01_5(double a, unsigned long b, int c) {
	return (5 - 2) | (*gpi & gia[1]);
}
void rs_12_03_02_0(unsigned int a, int b, long c) {
	char *t = &gca[a];
	jp = t;
}
void rs_12_03_02_1(unsigned int a, int b, long c) {
	char *t = jp;
	vp(t);
}
void rs_12_03_02_2(unsigned int a, int b, long c) {
	if (gl2 != 0) gs.l = *gpl % gl2;
}
void rs_12_03_02_3(unsigned int a, int b, long c) {
	gpi = rpi(gi3 / 3);
}
void rs_12_03_03_0(int a, int *b, int c) {
	gs.l = gl2;
}
void rs_12_03_03_1(int a, int *b, int c) {
	gl = 8L;
}
unsigned int rs_12_03_03_2(int a, int *b, int c) {
	if (guca[c] > guc) return ~gu;
}
unsigned int rs_12_03_03_3(int a, int *b, int c) {
	return gu2;
}
void rs_12_03_04_0(void) {
	double t = 10.0;
	jd = t;
}
void rs_12_03_04_1(void) {
	*gpi = gps->i * gi;
}
void rs_12_03_04_2(void) {
	gps->c = rc(gi3);
}
void rs_12_03_04_3(void) {
	*gpi = gs.i = -gia[7];
}
void rs_12_03_04_4(void) {
	v2(gi2, ~gs.i);
}
void rs_12_03_04_5(void) {
	double t = jd;
	v0();
	vd(t);
}
int rs_12_03_04_6(void) {
	return 127 - -gia[3];
}
void rs_12_03_05_0(int a) {
	int t = (int)gula[5];
	ji = t;
}
void rs_12_03_05_1(int a) {
	unsigned char u = guc;
	juc = u;
}
void rs_12_03_05_2(int a) {
	unsigned char u = juc;
	vu(((unsigned int)gpi[2]) - ((unsigned int)u));
}
void rs_12_03_05_3(int a) {
	unsigned char u = juc;
	v0();
	gs.u >>= 4;
}
void rs_12_03_05_4(int a) {
	gul = rul(gul >> 16);
}
void rs_12_03_05_5(int a) {
	int t = ji;
	unsigned char u = juc;
	v0();
	if (gc == 0) { gula[t] = gul = 81447UL; if (gps->u != 0) gua[t] = gu / gps->u; if (gl2 != 0) gl2 = *gpl / gl2; } else { if (gi3 != 1) vd(gd * gs.d); }
}
void rs_12_03_05_6(int a) {
	gia[6] = r0();
}
void rs_12_03_06_0(unsigned char a, long *b, long c) {
	if (guc >= 128) { ++a; if (gs.a[a] != 0) gi2 = gi2 % gs.a[a]; if (*gp != 0) gc2 = gc2 % *gp; }
}
void rs_12_03_06_1(unsigned char a, long *b, long c) {
	gc = ~*gp & (gc2 & gc);
}
void rs_12_03_06_2(unsigned char a, long *b, long c) {
	gc = gc2 = (gu2 <= 255 ? (char)gs.l : gc) | (*gp * (char)gul);
}
int * rs_12_03_06_3(unsigned char a, long *b, long c) {
	return gpi;
}
void rs_12_03_07_0(void) {
	char *t = gs.p;
	jp = t;
}
void rs_12_03_07_1(void) {
	gi2 = gi2 % 3;
}
void rs_12_03_07_2(void) {
	char *t = jp;
	vp(t);
}
int rs_12_03_07_3(void) {
	if (gp[2] > -30) return ~gs.a[0];
}
void rs_12_03_07_4(void) {
	char *t = jp;
	v0();
	++t;
}
int rs_12_03_07_5(void) {
	return -gps->i;
}
void rs_12_03_08_0(void) {
	double t = gs.d + 100.0;
	jd = t;
}
void rs_12_03_08_1(void) {
	char u = (gps->u & 0x8 ? 2 : 5);
	jc = u;
}
void rs_12_03_08_2(void) {
	char u = jc;
	gc = u;
}
void rs_12_03_08_3(void) {
	gia[0] = -gia[7];
}
void rs_12_03_08_4(void) {
	double t = jd;
	gd = t;
}
void rs_12_03_08_5(void) {
	if (((unsigned int)gula[7]) > 256) gd += 2.5 / 0.25;
}
void rs_12_03_08_6(void) {
	while (gi-- > 0) { if (*gp == -92) break; gp++; }
}
int rs_12_03_08_7(void) {
	char u = jc;
	return ~(gps->a[u] % 7);
}
void rs_12_03_09_0(char a, unsigned int b) {
	gu2 = (23952 - gps->u) + ru(32767);
}
void rs_12_03_09_1(char a, unsigned int b) {
	--gp;
}
void rs_12_03_09_2(char a, unsigned int b) {
	gda[3] = -(gs.d + gda[2]);
}
void rs_12_03_09_3(char a, unsigned int b) {
	if (gps->a[2] != 0) gs.i = (int)gu2 / gps->a[2];
}
long rs_12_03_09_4(char a, unsigned int b) {
	return (gps->l / 7L) % 100L;
}
void rs_12_03_10_0(void) {
	int *t = gpi;
	jpi = t;
}
void rs_12_03_10_1(void) {
	--gc;
}
void rs_12_03_10_2(void) {
	if (gul != 0) gula[6] = gul % gul;
}
void rs_12_03_10_3(void) {
	gs.u = ru(gu);
}
void rs_12_03_10_4(void) {
	int *t = jpi;
	v0();
	v1(*t);
}
unsigned long rs_12_03_10_5(void) {
	return gula[2];
}
void rs_12_03_11_0(unsigned long a) {
	int t = r2(gi2, gs.a[4]);
	ji = t;
}
void rs_12_03_11_1(unsigned long a) {
	int t = ji;
	long u = gla[t];
	v0();
	jl = u;
}
void rs_12_03_11_2(unsigned long a) {
	int t = ji;
	v0();
	guca[t] = guc = (guca[1] - guc) - (gc2 == 2 ? guc : guc);
}
void rs_12_03_11_3(unsigned long a) {
	long u = jl;
	v0();
	gps->u = gs.u;
}
void rs_12_03_11_4(unsigned long a) {
	gd += gda[2];
}
char * rs_12_03_11_5(unsigned long a) {
	return rp();
}
void rs_12_03_12_0(long *a, unsigned long b) {
	gca[0] <<= 5;
}
void rs_12_03_12_1(long *a, unsigned long b) {
	if (guc) { ++gp; gps->i = gpi[0] / 2; vu(gu2); }
}
void rs_12_03_12_2(long *a, unsigned long b) {
	if (gi2 <= gps->i) { --gp; b = rul(gul) / 7UL; gp = &gca[3]; } else { gu = gu2 | gua[4]; }
}
void rs_12_03_12_3(long *a, unsigned long b) {
	gc2--;
}
void rs_12_03_12_4(long *a, unsigned long b) {
	gs.a[6] = gi2 = (int)a[2];
}
int * rs_12_03_12_5(long *a, unsigned long b) {
	return gpi;
}
void rs_12_03_13_0(void) {
	unsigned int t = 29517 % 100;
	ju = t;
}
void rs_12_03_13_1(void) {
	vp(gs.p);
}
int rs_12_03_13_2(void) {
	if (gs.l) return gi % 3;
}
void rs_12_03_13_3(void) {
	unsigned int t = ju;
	v0();
	if (gla[t] & 0x7) if (gu2 != 0) gu = t % gu2;
}
void rs_12_03_13_4(void) {
	*gpi |= gps->i;
}
int rs_12_03_13_5(void) {
	return 256;
}
void rs_12_03_14_0(long *a, long b, char c) {
	++gp;
}
void rs_12_03_14_1(long *a, long b, char c) {
	gps->u = gps->u + gs.u;
}
void rs_12_03_14_2(long *a, long b, char c) {
	gpl[3] += gla[4];
}
void rs_12_03_14_3(long *a, long b, char c) {
	gua[4] &= 256 % 16;
}
void rs_12_03_14_4(long *a, long b, char c) {
	gd += 0.5;
}
char * rs_12_03_14_5(long *a, long b, char c) {
	return gp;
}
void rs_12_03_15_0(int a, int b) {
	gd2 -= gd;
}
void rs_12_03_15_1(int a, int b) {
	++gp;
}
int rs_12_03_15_2(int a, int b) {
	if (gc & 4 || r0()) return b | gps->i;
}
void rs_12_03_15_3(int a, int b) {
	gl = -29798L;
}
int rs_12_03_15_4(int a, int b) {
	return gi - (int)gpl[0];
}
void rs_12_03_16_0(char a, char b) {
	switch (gs.l) { case 0L: case 1L: gs.u <<= 13; break; case 2L: v0(); break; }
}
void rs_12_03_16_1(char a, char b) {
	vc(9 & a);
}
char rs_12_03_16_2(char a, char b) {
	return gc2;
}
void rs_12_03_17_0(void) {
	vu(-gs.u);
}
void rs_12_03_17_1(void) {
	if (r1(gi3)) { --gu; if (gua[2] != 0) gps->u = gua[7] % gua[2]; }
}
void rs_12_03_17_2(void) {
	v2(gi2, (int)7L);
}
void rs_12_03_17_3(void) {
	gps->c -= gc2 % 100;
}
void rs_12_03_17_4(void) {
	vs(gps);
}
unsigned long rs_12_03_17_5(void) {
	return (gula[3] % 100UL) % 2UL;
}
void rs_12_03_18_0(char a) {
	int t = gi2 + 16;
	ji = t;
}
char rs_12_03_18_1(char a) {
	if (gia[a]) return rc((int)gps->u);
}
void rs_12_03_18_2(char a) {
	int t = ji;
	v0();
	gs.d = (guca[a] > 128 ? (double)gi3 : (double)t) - gs.d;
}
void rs_12_03_18_3(char a) {
	gl <<= 20;
}
char rs_12_03_18_4(char a) {
	int t = ji;
	v0();
	return (guca[0] <= 255 ? (char)guca[t] : gc) << (t & 7);
}
void rs_12_03_19_0(char *a) {
	gpi = rpi(gs.i & 3);
}
void rs_12_03_19_1(char *a) {
	gi2++;
}
int * rs_12_03_19_2(char *a) {
	if (gi3 > 255 || gula[1] != 97000UL) return gpi;
}
int * rs_12_03_19_3(char *a) {
	return gpi;
}
void rs_12_04_00_0(int a) {
	long t = 7L - gs.l;
	jl = t;
}
void rs_12_04_00_1(int a) {
	gps->u = gu;
}
void rs_12_04_00_2(int a) {
	vu(gu);
}
void rs_12_04_00_3(int a) {
	long t = jl;
	v0();
	t++;
}
void rs_12_04_00_4(int a) {
	gs.c /= 10;
}
int rs_12_04_00_5(int a) {
	return r2(gi2, 100) << 10;
}
void rs_12_04_01_1(int a, long b, int *c) {
	if ((gula[a] = 50256UL)) { gs.d = gd2; if (gi3 != 0) gia[a] = c[a] % gi3; } else { if (gul != 0) gul = gula[a] / gul; if (gu != 0) gu = gu2 % gu; gs.a[a] += c[a] + 256; }
}
void rs_12_04_01_2(int a, long b, int *c) {
	int i = ji;
	for (i = 16; i > 0; i--) { gpi = c; }
}
void rs_12_04_01_3(int a, long b, int *c) {
	vs(gps);
}
void rs_12_04_01_4(int a, long b, int *c) {
	gla[2] /= 7L;
}
char rs_12_04_01_5(int a, long b, int *c) {
	return (gu == 1 ? gc : (gca[5] * gca[a]));
}
void rs_12_04_02_1(long *a, int b) {
	unsigned char t = guc / 3;
	juc = t;
}
void rs_12_04_02_2(long *a, int b) {
	unsigned char t = juc;
	guc = t;
}
void rs_12_04_02_3(long *a, int b) {
	int i = ji;
	for (i = b; i > 0; i--) { if (gs.u != 0) gu2 = gu % gs.u; if (gps->i != 0) gi2 = gia[i] % gps->i; }
}
void rs_12_04_02_4(long *a, int b) {
	gd2 *= gd * gda[1];
}
unsigned int rs_12_04_02_5(long *a, int b) {
	return (unsigned int)!gp[1];
}
void rs_12_04_03_0(long a) {
	int t = gi ^ gi3;
	ji = t;
}
void rs_12_04_03_1(long a) {
	int u = gi3;
	ji = u;
}
void rs_12_04_03_2(long a) {
	int u = ji;
	gua[u] %= 10;
}
void rs_12_04_03_3(long a) {
	int t = ji;
	int u = ji;
	if ((gul = 0x10000UL)) { if (gu2 != 0) gs.u = gua[3] / gu2; } else { gd = gd2; vc((gula[2] ? gc : gc)); if (t != 0) t = u % t; }
}
void rs_12_04_03_4(long a) {
	gl = gs.l;
}
void rs_12_04_03_5(long a) {
	vl(rl(gla[5]));
}
unsigned int rs_12_04_03_6(long a) {
	return (gu2 = gu);
}
void rs_12_04_04_0(unsigned char a, int b) {
	char t = gp[3] - *gp;
	jc = t;
}
void rs_12_04_04_1(unsigned char a, int b) {
	unsigned int u = (unsigned int)!16;
	ju = u;
}
void rs_12_04_04_2(unsigned char a, int b) {
	gs.l = gs.l + 22014L;
}
void rs_12_04_04_3(unsigned char a, int b) {
	guc--;
}
void rs_12_04_04_4(unsigned char a, int b) {
	char t = jc;
	gc = t;
}
void rs_12_04_04_5(unsigned char a, int b) {
	unsigned int u = ju;
	if (gla[u] >= gs.l) { gi3 /= 10; gpi[0] = gs.i; if (gi2 != 0) gs.i = (int)guca[b] / gi2; }
}
int rs_12_04_04_6(unsigned char a, int b) {
	return gs.i;
}
void rs_12_04_05_0(struct st *a, struct st *b) {
	--gp;
}
void rs_12_04_05_1(struct st *a, struct st *b) {
	gla[2] *= 10L;
}
int * rs_12_04_05_2(struct st *a, struct st *b) {
	return gpi + 1;
}
void rs_12_04_06_0(unsigned char a, int *b) {
	if (gula[1] != 0) gula[2] = gula[a] / gula[1];
}
void rs_12_04_06_1(unsigned char a, int *b) {
	v2(b[a] | gia[3], gi);
}
void rs_12_04_06_2(unsigned char a, int *b) {
	gua[3] = gps->u = gs.u;
}
long rs_12_04_06_3(unsigned char a, int *b) {
	return ~44052L + (long)gul;
}
void rs_12_04_07_1(unsigned char a) {
	long t = gla[4] + (long)gula[a];
	jl = t;
}
void rs_12_04_07_2(unsigned char a) {
	int i = ji;
	i = 0; while (i < 6) { if (gul != 0) gul = 0x10000UL / gul; if (gia[1] != 0) gi = gia[i] / gia[1]; if (gul != 0) gul = gula[i] / gul; i++; }
}
void rs_12_04_07_3(unsigned char a) {
	long t = jl;
	gl = t;
}
void rs_12_04_07_4(unsigned char a) {
	gps->u /= 16;
}
void rs_12_04_07_5(unsigned char a) {
	*gp = (gia[0] ? (gps->c - gp[3]) : (gc & 'A'));
}
int rs_12_04_07_6(unsigned char a) {
	return *gpi;
}
void rs_12_04_08_0(int a) {
	int t = (gua[7] >= gu2);
	ji = t;
}
void rs_12_04_08_1(int a) {
	int *u = gpi + a;
	jpi = u;
}
void rs_12_04_08_2(int a) {
	int *u = jpi;
	gua[3] = ~gps->u;
}
void rs_12_04_08_3(int a) {
	int t = ji;
	v1(t);
}
void rs_12_04_08_4(int a) {
	guca[1] = guca[5] / 100;
}
char * rs_12_04_08_5(int a) {
	return gps->p;
}
void rs_12_04_09_0(void) {
	vs(gps);
}
void rs_12_04_09_1(void) {
	vs(gps);
}
unsigned long rs_12_04_09_2(void) {
	return (gul + gula[5]) - (gul / 2UL);
}
void rs_12_04_10_1(void) {
	int *t = gpi;
	jpi = t;
}
void rs_12_04_10_2(void) {
	char *u = rp();
	jp = u;
}
void rs_12_04_10_3(void) {
	char *u = jp;
	v0();
	vp(u);
}
void rs_12_04_10_4(void) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_12_04_10_5(void) {
	int i = ji;
	v0();
	i = 0; while (i < 8) { gla[i] = *gpl & 65536L; if (i != 0) gi3 = gi2 / i; gps->i = (int)187; i++; }
}
int rs_12_04_10_6(void) {
	return (guc & 2 && gu2 >= gua[2] ? (gi << 10) : ~gi);
}
void rs_12_04_11_1(unsigned int a, struct st *b) {
	unsigned char t = (unsigned char)gp[1];
	juc = t;
}
void rs_12_04_11_2(unsigned int a, struct st *b) {
	unsigned char t = juc;
	t = guca[a];
}
void rs_12_04_11_3(unsigned int a, struct st *b) {
	int i = ji;
	unsigned char t = juc;
	i = 0; while (i < 12) { if (gu2 != 0) a = gu % gu2; guc = (t % 100) ^ (t / 4); i++; }
}
void rs_12_04_12_0(struct st *a, char *b) {
	if (gua[4] < 256) { v0(); }
}
void rs_12_04_12_1(struct st *a, char *b) {
	gula[3] <<= 3;
}
int rs_12_04_12_2(struct st *a, char *b) {
	return (gul < 0UL && r2(gia[3], gi) ? r2(gi2, gia[1]) : (int)b[2]);
}
void rs_12_04_13_0(int a, unsigned long b, long *c) {
	gu = gua[a] << 3;
}
void rs_12_04_13_1(int a, unsigned long b, long *c) {
	if (guca[3] & 0x7) { vs(gps); } else { gca[5] = gps->c = *gp << 7; guc = guca[2] = (unsigned char)!(gps->c + *gp); if (gula[a] != 0) b = gul / gula[a]; }
}
void rs_12_04_13_2(int a, unsigned long b, long *c) {
	gs.u = ru(32767);
}
void rs_12_04_13_3(int a, unsigned long b, long *c) {
	gd = (gs.d + gd2) * gda[2];
}
void rs_12_04_13_4(int a, unsigned long b, long *c) {
	if (r2(gi2, a)) { gda[3] *= gd / 3.0; gl = c[3] ^ 2L; } else { if (gc != 0) gc2 = (char)guc % gc; gula[a] = b = ~(gul * b); }
}
long rs_12_04_13_5(int a, unsigned long b, long *c) {
	return gl2 * 7L;
}
void rs_12_04_14_0(void) {
	gl2--;
}
void rs_12_04_14_1(void) {
	++gul;
}
unsigned int rs_12_04_14_2(void) {
	return (0 & gu) - (gua[3] - 256);
}
void rs_12_04_15_0(void) {
	gi3++;
}
void rs_12_04_15_1(void) {
	gs.c = 1;
}
int rs_12_04_15_2(void) {
	return (gs.i >> 13) & gi2;
}
void rs_12_04_16_0(int a) {
	if (r0() && gul) { gs.i = gi2 / 2; if (gl != 0) gl2 = gs.l % gl; }
}
void rs_12_04_16_1(int a) {
	gu2 ^= ru(gu);
}
void rs_12_04_16_2(int a) {
	gul = (gul * 10UL) - (gul * ((unsigned long)gu));
}
char * rs_12_04_16_3(int a) {
	return gp;
}
void rs_12_04_17_0(unsigned long a, unsigned char b) {
	if (a != 0) gula[7] = gul / a;
}
void rs_12_04_17_1(unsigned long a, unsigned char b) {
	if (gul & 0x8 || !gl2) gp[1] = 67 & gca[2];
}
void rs_12_04_17_2(unsigned long a, unsigned char b) {
	gda[0] -= gd2 - (double)gs.a[b];
}
void rs_12_04_17_3(unsigned long a, unsigned char b) {
	++gpi;
}
void rs_12_04_18_0(unsigned char a, long b, unsigned long c) {
	int t = 8 - gi;
	ji = t;
}
void rs_12_04_18_1(unsigned char a, long b, unsigned long c) {
	char u = (char)(gps->l > gs.l);
	jc = u;
}
void rs_12_04_18_2(unsigned char a, long b, unsigned long c) {
	char u = jc;
	gu2 = gs.u;
}
void rs_12_04_18_3(unsigned char a, long b, unsigned long c) {
	gla[3] = *gpl << 10;
}
void rs_12_04_18_4(unsigned char a, long b, unsigned long c) {
	v2(gi2, 1);
}
void rs_12_04_18_5(unsigned char a, long b, unsigned long c) {
	int t = ji;
	v0();
	v1(t);
}
int rs_12_04_18_6(unsigned char a, long b, unsigned long c) {
	int t = ji;
	v0();
	return t;
}
void rs_12_04_19_0(unsigned long a, unsigned int b) {
	--gp;
}
void rs_12_04_19_1(unsigned long a, unsigned int b) {
	if (gula[0]) if (gu != 0) gu2 = gu2 / gu;
}
void rs_12_04_19_2(unsigned long a, unsigned int b) {
	gi = (*gpi & gpi[0]) * 9;
}
void rs_12_04_19_3(unsigned long a, unsigned int b) {
	gs.p = gp;
}
char * rs_12_04_19_4(unsigned long a, unsigned int b) {
	return gp + b;
}
void rs_12_05_00_0(void) {
	guc &= guca[1];
}
void rs_12_05_00_1(void) {
	gd2 *= (gca[4] != -32 ? 10.0 : gd2);
}
void rs_12_05_00_2(void) {
	gla[5] = -9L;
}
void rs_12_05_00_3(void) {
	gla[2] = gs.l | 39322L;
}
void rs_12_05_00_4(void) {
	if (gula[1] != 0) gula[5] = 0x10000UL / gula[1];
}
unsigned long rs_12_05_00_5(void) {
	return rul(22898UL);
}
void rs_12_05_01_0(char a) {
	vu(gu2 - 32767);
}
void rs_12_05_01_1(char a) {
	gpi = rpi((*gpl ? 127 : (int)gps->u));
}
void rs_12_05_01_2(char a) {
	gu <<= 12;
}
void rs_12_05_01_3(char a) {
	if (gula[1] != 0) gul = ((unsigned long)gc2) / gula[1];
}
char rs_12_05_01_4(char a) {
	return gps->c / 10;
}
void rs_12_05_02_0(void) {
	unsigned int t = gu2;
	ju = t;
}
void rs_12_05_02_1(void) {
	gla[6] = ~(gpl[1] + 7L);
}
void rs_12_05_02_2(void) {
	unsigned int t = ju;
	if (37 == 68) t |= gu2;
}
int rs_12_05_02_3(void) {
	unsigned int t = ju;
	return ((*gpi | gi) >= (gps->a[t] + gpi[1]));
}
void rs_12_05_03_0(unsigned int a) {
	gs.d *= gd2 / 100.0;
}
void rs_12_05_03_1(unsigned int a) {
	gu2 <<= 3;
}
char * rs_12_05_03_2(unsigned int a) {
	return gp + a;
}
void rs_12_05_04_1(struct st *a, unsigned int b) {
	v2(gi / 16, gi);
}
void rs_12_05_04_2(struct st *a, unsigned int b) {
	int i = ji;
	v0();
	switch (a->i) { case 3: case 20: gps->u /= 16; break; }
}
void rs_12_05_04_3(struct st *a, unsigned int b) {
	int i = ji;
	v0();
	i = 0; while (i < 3) { gl &= -gla[i]; gd2 = 10.0; i++; }
}
int rs_12_05_04_4(struct st *a, unsigned int b) {
	return 2 & (gi3 * 12);
}
void rs_12_05_05_1(long a, unsigned long b, unsigned char c) {
	int t = 3 ^ gpi[0];
	ji = t;
}
void rs_12_05_05_2(long a, unsigned long b, unsigned char c) {
	if (gca[5]) gp[2] = gps->c = (char)c - (char)b;
}
void rs_12_05_05_3(long a, unsigned long b, unsigned char c) {
	int i = ji;
	i = 0; while (i < 11) { v2(gps->a[i], gi); i++; }
}
void rs_12_05_05_4(long a, unsigned long b, unsigned char c) {
	if (gla[c] != 0) a = a % gla[c];
}
void rs_12_05_05_5(long a, unsigned long b, unsigned char c) {
	gua[1] -= gs.u / 7;
}
void rs_12_05_05_6(long a, unsigned long b, unsigned char c) {
	int t = ji;
	v0();
	gi = t;
}
void rs_12_05_06_1(long a) {
	unsigned int t = ru(gps->u);
	ju = t;
}
void rs_12_05_06_2(long a) {
	vc((char)(gps->u == gua[7]));
}
void rs_12_05_06_3(long a) {
	int i = ji;
	v0();
	i = 0; while (i < 15) { gpl[1] = (a < gla[i] ? gps->l : (long)gps->i); gpi = gpi + i; i++; }
}
void rs_12_05_06_4(long a) {
	v2(gi2, 127 | gpi[0]);
}
void rs_12_05_06_5(long a) {
	gd2 -= gd * gd2;
}
void rs_12_05_06_6(long a) {
	unsigned int t = ju;
	v0();
	gu = t;
}
int rs_12_05_06_7(long a) {
	return gi3;
}
void rs_12_05_07_0(int a) {
	gp--;
}
void rs_12_05_07_1(int a) {
	guc <<= 1;
}
void rs_12_05_07_2(int a) {
	vs(gps);
}
void rs_12_05_07_3(int a) {
	gp = gps->p;
}
long rs_12_05_07_4(int a) {
	return gla[a];
}
void rs_12_05_08_0(long *a, unsigned long b, double c) {
	unsigned long t = rul(gula[5]);
	jul = t;
}
void rs_12_05_08_1(long *a, unsigned long b, double c) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
void rs_12_05_08_2(long *a, unsigned long b, double c) {
	gl2 = (gl ^ 74699L) - (-56242L & gl);
}
void rs_12_05_08_3(long *a, unsigned long b, double c) {
	c = -(gs.d - (double)gs.l);
}
unsigned long rs_12_05_08_4(long *a, unsigned long b, double c) {
	unsigned long t = jul;
	v0();
	return t >> 21;
}
void rs_12_05_09_0(long a) {
	gps->a[4] >>= 4;
}
void rs_12_05_09_1(long a) {
	gps->i = (int)gc & gpi[3];
}
void rs_12_05_09_2(long a) {
	guc = (((unsigned char)gi3) * guc) - (guca[2] << 6);
}
void rs_12_05_09_3(long a) {
	*gpi = *gpi * 12;
}
void rs_12_05_09_4(long a) {
	if (((unsigned int)gc) <= gs.u) { if (gl2 != 0) gl2 = gps->l / gl2; if (gia[4] != 0) gi = gi % gia[4]; --gul; } else { if (gul != 0) gul = gula[0] % gul; }
}
int * rs_12_05_09_5(long a) {
	return rpi(r0());
}
void rs_12_05_10_0(int a, char *b, int c) {
	char *t = &gca[c];
	jp = t;
}
void rs_12_05_10_1(int a, char *b, int c) {
	gc++;
}
void rs_12_05_10_2(int a, char *b, int c) {
	switch (a) { case 1: gl2 *= 9L; break; case 5: vp(gps->p); break; case 16: gps->a[4] = !128; break; case 20: gs.i = 8 * 6; break; case 100: gs.u = gu; break; }
}
void rs_12_05_10_3(int a, char *b, int c) {
	char *t = jp;
	v0();
	vp(t);
}
void rs_12_05_10_4(int a, char *b, int c) {
	if (gul != 0) gula[c] = gula[4] / gul;
}
char * rs_12_05_10_5(int a, char *b, int c) {
	return b;
}
void rs_12_05_11_1(char a, int b, long c) {
	gua[a] = gs.u % 10;
}
void rs_12_05_11_2(char a, int b, long c) {
	int i = ji;
	for (i = 0; i < 16; i++) { gps->a[i] <<= 10; gd2 = -(gd2 * gda[0]); }
}
void rs_12_05_11_3(char a, int b, long c) {
	c ^= gl >> 2;
}
unsigned int rs_12_05_11_4(char a, int b, long c) {
	return ~(gu * gu2);
}
void rs_12_05_12_0(unsigned char a, int b) {
	int t = 127 + gia[a];
	ji = t;
}
void rs_12_05_12_1(unsigned char a, int b) {
	int t = ji;
	int u = gia[t];
	ji = u;
}
void rs_12_05_12_2(unsigned char a, int b) {
	int u = ji;
	v1(u);
}
void rs_12_05_12_3(unsigned char a, int b) {
	gla[1] = gl = (3L | gl) - rl(gla[3]);
}
void rs_12_05_12_4(unsigned char a, int b) {
	v0();
}
void rs_12_05_12_5(unsigned char a, int b) {
	int t = ji;
	v0();
	gi2 = t;
}
int rs_12_05_12_6(unsigned char a, int b) {
	int u = ji;
	v0();
	return gi3 + (gi3 - u);
}
void rs_12_05_13_0(void) {
	char t = 9;
	jc = t;
}
void rs_12_05_13_1(void) {
	char t = jc;
	guca[t] -= guc ^ guca[6];
}
void rs_12_05_13_2(void) {
	char t = jc;
	if (t < gca[4] || gu2 > 32767) { gu2--; if (*gpl != 0) gla[t] = gla[t] / *gpl; }
}
void rs_12_05_13_3(void) {
	char t = jc;
	guc = guca[t] + (guc << 5);
}
int rs_12_05_13_4(void) {
	char t = jc;
	return (gi2 = gs.a[t]);
}
void rs_12_05_14_0(unsigned char a, unsigned char b) {
	gula[b] = gul = rul(0x10000UL) % 16UL;
}
void rs_12_05_14_1(unsigned char a, unsigned char b) {
	v0();
}
void rs_12_05_14_2(unsigned char a, unsigned char b) {
	gs.d *= 2.5;
}
void rs_12_05_14_3(unsigned char a, unsigned char b) {
	vc(rc(gps->a[a]));
}
long rs_12_05_14_4(unsigned char a, unsigned char b) {
	return *gpl >> 11;
}
void rs_12_05_15_0(long *a) {
	unsigned int t = ru(gu2);
	ju = t;
}
void rs_12_05_15_1(long *a) {
	char *u = rp();
	v0();
	jp = u;
}
void rs_12_05_15_2(long *a) {
	vc(*gp);
}
void rs_12_05_15_3(long *a) {
	unsigned int t = ju;
	v0();
	gu = t;
}
void rs_12_05_15_4(long *a) {
	gc++;
}
void rs_12_05_15_5(long *a) {
	char *u = jp;
	v0();
	gp = u;
}
void rs_12_05_15_6(long *a) {
	v0();
}
int rs_12_05_15_7(long *a) {
	unsigned int t = ju;
	v0();
	return ((long)gul == 0L ? (int)t : gi2) % 4;
}
void rs_12_05_16_0(void) {
	double t = gd2 + gs.d;
	jd = t;
}
void rs_12_05_16_1(void) {
	vl(gl2 ^ gl);
}
void rs_12_05_16_2(void) {
	gp[1] = ((gu = 32767) > 27610 ? gca[6] : gca[0]);
}
void rs_12_05_16_3(void) {
	if (gul != 0) gul = gul / gul;
}
void rs_12_05_16_4(void) {
	gu = gu - (gps->u + gu);
}
void rs_12_05_16_5(void) {
	double t = jd;
	v0();
	gd = t;
}
void rs_12_05_16_6(void) {
	guca[7] = guc = guca[0];
}
char * rs_12_05_16_7(void) {
	return gp;
}
void rs_12_05_17_0(long a, char b, int c) {
	gu = (gula[5] > 34812UL ? ~gu : (gs.u ^ gua[0]));
}
int rs_12_05_17_1(long a, char b, int c) {
	if (c & 0x8) return gi - gi3;
}
int rs_12_05_17_2(long a, char b, int c) {
	return -gps->a[1] * 8;
}
void rs_12_05_18_0(long *a, int *b, char c) {
	if (gula[c] != 0) gul = gula[c] % gula[c];
}
void rs_12_05_18_1(long *a, int *b, char c) {
	guc = (guc ^ 3) % 7;
}
unsigned long rs_12_05_18_2(long *a, int *b, char c) {
	return gul + 41951UL;
}
void rs_12_05_19_1(long a, int b, long c) {
	int i = ji;
	for (i = 0; i < b; i++) { v1(i % 7); vp(gps->p); gps->i = -gps->a[i]; }
}
void rs_12_05_19_2(long a, int b, long c) {
	if (gps->u != 0) gps->u = gps->u / gps->u;
}
long rs_12_05_19_3(long a, int b, long c) {
	return a % 4L;
}
void rs_12_06_00_0(int a, unsigned int b) {
	double t = (gd > gs.d ? gd2 : 10.0);
	jd = t;
}
void rs_12_06_00_1(int a, unsigned int b) {
	int *u = gpi + a;
	jpi = u;
}
void rs_12_06_00_2(int a, unsigned int b) {
	int *u = jpi;
	gpi = u;
}
void rs_12_06_00_3(int a, unsigned int b) {
	if (0.25 < 0.5) { gi = (gia[4] + gi2) ^ (gi / 7); } else { v0(); gs.i = 8 + gi2; }
}
void rs_12_06_00_4(int a, unsigned int b) {
	double t = jd;
	v0();
	vd(t);
}
char * rs_12_06_00_5(int a, unsigned int b) {
	if (gula[2] <= gula[a]) return gs.p;
}
void rs_12_06_00_6(int a, unsigned int b) {
	*gp >>= 1;
}
char * rs_12_06_00_7(int a, unsigned int b) {
	return gp;
}
void rs_12_06_01_0(void) {
	char *t = gp + 1;
	jp = t;
}
void rs_12_06_01_1(void) {
	char u = gc >> 3;
	jc = u;
}
void rs_12_06_01_2(void) {
	char u = jc;
	gpi = gpi + u;
}
void rs_12_06_01_3(void) {
	gda[0] = gd2;
}
void rs_12_06_01_4(void) {
	char u = jc;
	gu = (unsigned int)!(guc * guca[u]);
}
void rs_12_06_01_5(void) {
	char *t = jp;
	gp = t;
}
void rs_12_06_01_6(void) {
	guca[2] = -guc;
}
unsigned long rs_12_06_01_7(void) {
	char u = jc;
	return (unsigned long)!guca[u];
}
void rs_12_06_02_0(long *a) {
	gc++;
}
void rs_12_06_02_1(long *a) {
	gul *= 12UL;
}
unsigned long rs_12_06_02_2(long *a) {
	return gul;
}
void rs_12_06_03_1(int a, struct st *b, unsigned char c) {
	char t = gca[1];
	jc = t;
}
int rs_12_06_03_2(int a, struct st *b, unsigned char c) {
	if (gc2) return r2(gi2, gps->a[4]);
}
void rs_12_06_03_3(int a, struct st *b, unsigned char c) {
	gula[0] %= 10UL;
}
void rs_12_06_03_4(int a, struct st *b, unsigned char c) {
	int i = ji;
	v0();
	b->i = !0x10000UL;
}
void rs_12_06_03_5(int a, struct st *b, unsigned char c) {
	int i = ji;
	v0();
	for (i = 8; i > 0; i--) { if (gul != 0) gula[i] = gul / gul; }
}
void rs_12_06_03_6(int a, struct st *b, unsigned char c) {
	char t = jc;
	v0();
	if (gul == 94746UL) { if (b->c != 0) t = t / b->c; if (gua[0] != 0) gua[1] = gu2 % gua[0]; }
}
int rs_12_06_03_7(int a, struct st *b, unsigned char c) {
	return gi3 * ((int)gla[a] + gi3);
}
void rs_12_06_04_1(int a, int *b, int *c) {
	gula[a] = gul;
}
void rs_12_06_04_2(int a, int *b, int *c) {
	gua[a] += gps->u | gua[a];
}
void rs_12_06_04_3(int a, int *b, int *c) {
	vd(gda[0]);
}
void rs_12_06_04_4(int a, int *b, int *c) {
	if (gua[a] != gu) { if (*gp != 0) gps->c = gc2 % *gp; c = c + a; }
}
void rs_12_06_04_5(int a, int *b, int *c) {
	int i = ji;
	v0();
	for (i = 0; i < 13; i++) { gula[i] -= rul((unsigned long)gpl[1]); gla[i] <<= 23; if (gl2 != 0) gpl[0] = gl2 % gl2; }
}
int rs_12_06_04_6(int a, int *b, int *c) {
	return (255 <= guca[0]) | (int)guca[5];
}
void rs_12_06_05_1(unsigned char a) {
	unsigned char t = (unsigned char)(gul == 0x10000UL);
	juc = t;
}
void rs_12_06_05_2(unsigned char a) {
	unsigned char t = juc;
	v1(t);
}
void rs_12_06_05_3(unsigned char a) {
	while (gi-- > 0) *gp++ = 4;
}
void rs_12_06_05_4(unsigned char a) {
	int i = ji;
	v0();
	for (i = 0; i < 14; i++) { if (gia[1] != 0) gps->a[i] = 5 / gia[1]; gs.u = gu2; }
}
void rs_12_06_05_5(unsigned char a) {
	v1(-730 + gi2);
}
void rs_12_06_05_6(unsigned char a) {
	if (65536L > 65536L) { v2(gi2, gi2); if (gul != 0) gula[a] = gul / gul; } else { vl(7L + 5L); gps->c = gc; gp = gps->p; }
}
unsigned int rs_12_06_05_7(unsigned char a) {
	if (239 >= ((unsigned char)gul)) return gu | gs.u;
}
unsigned int rs_12_06_05_8(unsigned char a) {
	return gua[5];
}
void rs_12_06_06_0(void) {
	char t = gca[5] & gc2;
	jc = t;
}
void rs_12_06_06_1(void) {
	++guc;
}
void rs_12_06_06_2(void) {
	guc ^= -128;
}
void rs_12_06_06_3(void) {
	char t = jc;
	if (guc != 8) { gul = ~gula[t] | 0UL; guca[0] = guca[1] >> 5; gda[3] *= -gd2; }
}
void rs_12_06_06_4(void) {
	gul = rul(0UL ^ gul);
}
void rs_12_06_06_5(void) {
	*gpl = gl;
}
unsigned int rs_12_06_06_6(void) {
	return ru(gu2) + (gps->u & 28489);
}
void rs_12_06_07_0(void) {
	double t = gd + gd;
	jd = t;
}
void rs_12_06_07_1(void) {
	switch (gi2) { case 2: gpi = gpi + 1; break; case 3: *gpi = (int)gula[6]; break; case 10: v1(1); case 100: case 1000: v2(*gpi, gi); break; }
}
void rs_12_06_07_2(void) {
	*gpi = gi2 = -gs.i + (gia[5] + 1);
}
void rs_12_06_07_3(void) {
	double t = jd;
	v0();
	t *= gda[1];
}
long rs_12_06_07_4(void) {
	return ((long)(gl >= 65536L)) - rl(gla[1]);
}
void rs_12_06_08_0(int a) {
	double t = gd - gda[3];
	jd = t;
}
void rs_12_06_08_1(int a) {
	gpi++;
}
void rs_12_06_08_2(int a) {
	double t = jd;
	gd = t;
}
void rs_12_06_08_3(int a) {
	if (guca[a] & 0x8) { if (gi != 0) gi3 = gi2 / gi; if (gla[a] != 0) gl = gla[a] / gla[a]; }
}
char rs_12_06_08_4(int a) {
	return (gca[a] = *gp);
}
void rs_12_06_09_0(unsigned char a, int *b) {
	int t = gi2 | gs.a[0];
	ji = t;
}
void rs_12_06_09_1(unsigned char a, int *b) {
	int u = gi | 255;
	ji = u;
}
void rs_12_06_09_2(unsigned char a, int *b) {
	int u = ji;
	v2(gi2, b[u] + 100);
}
void rs_12_06_09_3(unsigned char a, int *b) {
	int t = ji;
	v0();
	if (gul == gula[t]) a--;
}
void rs_12_06_09_4(unsigned char a, int *b) {
	gp = gs.p;
}
void rs_12_06_09_5(unsigned char a, int *b) {
	--gc2;
}
void rs_12_06_10_1(char a) {
	unsigned char t = (unsigned char)((unsigned int)*gp);
	juc = t;
}
void rs_12_06_10_2(char a) {
	unsigned char t = juc;
	t = 162;
}
void rs_12_06_10_3(char a) {
	int i = ji;
	for (i = 0; i < 10; i++) { if (gul != 0) gul = gul % gul; if (gps->i != 0) gpi[2] = gs.i / gps->i; }
}
void rs_12_06_10_4(char a) {
	unsigned char t = juc;
	gps->u += gua[t] ^ gps->u;
}
void rs_12_06_10_5(char a) {
	if (gs.u && gca[6]) { gpi = rpi(*gpi << 1); }
}
void rs_12_06_11_0(unsigned char a, int b) {
	unsigned char t = (gul & 2 ? guc : ((unsigned char)gl));
	juc = t;
}
void rs_12_06_11_1(unsigned char a, int b) {
	char u = *gp;
	jc = u;
}
void rs_12_06_11_2(unsigned char a, int b) {
	vs(gps);
}
void rs_12_06_11_3(unsigned char a, int b) {
	if (gps->i) gpi = &gia[1];
}
void rs_12_06_11_4(unsigned char a, int b) {
	char u = jc;
	v0();
	vc(u);
}
void rs_12_06_11_5(unsigned char a, int b) {
	vd(gs.d - gd2);
}
void rs_12_06_11_6(unsigned char a, int b) {
	unsigned char t = juc;
	v0();
	gp = &gca[t];
}
void rs_12_06_11_7(unsigned char a, int b) {
	gi3 = gps->i;
}
unsigned long rs_12_06_11_8(unsigned char a, int b) {
	return gula[b];
}
void rs_12_06_12_0(long a, int b) {
	unsigned int t = 13983;
	ju = t;
}
void rs_12_06_12_1(long a, int b) {
	unsigned int t = ju;
	unsigned long u = gula[t] >> (b & 15);
	jul = u;
}
void rs_12_06_12_2(long a, int b) {
	guc = guca[4] + guc;
}
void rs_12_06_12_3(long a, int b) {
	*gp += gc ^ gca[b];
}
void rs_12_06_12_4(long a, int b) {
	gp = &gca[4];
}
void rs_12_06_12_5(long a, int b) {
	gl2 = gps->l;
}
void rs_12_06_12_6(long a, int b) {
	unsigned long u = jul;
	gul = u;
}
void rs_12_06_12_7(long a, int b) {
	unsigned int t = ju;
	t %= 3;
}
int * rs_12_06_12_8(long a, int b) {
	return gpi + b;
}
void rs_12_06_13_0(void) {
	int *t = gpi;
	jpi = t;
}
void rs_12_06_13_1(void) {
	if (gia[7] != 0) gi = gps->a[4] % gia[7];
}
void rs_12_06_13_2(void) {
	int *t = jpi;
	gpi = t;
}
void rs_12_06_13_3(void) {
	v2(!65536L, gi);
}
long rs_12_06_13_4(void) {
	return gs.l;
}
void rs_12_06_14_1(unsigned long a) {
	int *t = gpi;
	jpi = t;
}
void rs_12_06_14_2(unsigned long a) {
	int *u = &gia[0];
	jpi = u;
}
void rs_12_06_14_3(unsigned long a) {
	int *t = jpi;
	gpi = t;
}
void rs_12_06_14_4(unsigned long a) {
	int i = ji;
	for (i = 0; i < 14; i++) { v2(gi2, gpi[2] * 127); }
}
void rs_12_06_14_5(unsigned long a) {
	int *u = jpi;
	v0();
	gpi = u;
}
void rs_12_06_14_6(unsigned long a) {
	gc2 = (char)(gc != gps->c);
}
void rs_12_06_14_7(unsigned long a) {
	if (guc < guca[3]) gula[7] = -6UL;
}
void rs_12_06_15_0(int *a, unsigned char b) {
	char t = (char)(gps->c <= gc2);
	jc = t;
}
void rs_12_06_15_1(int *a, unsigned char b) {
	unsigned int u = ((guca[b] = b) > 2 ? gu2 : gu2);
	ju = u;
}
void rs_12_06_15_2(int *a, unsigned char b) {
	char t = jc;
	unsigned int u = ju;
	if (t & 0x80) { gla[u] = *gpl | gla[u]; } else { guc = (255 > u ? guc : guca[b]) ^ (4 * guca[1]); if (t != 0) t = gp[2] % t; if (t != 0) gp[1] = (char)gul / t; }
}
void rs_12_06_15_3(int *a, unsigned char b) {
	gula[1] = gul;
}
void rs_12_06_15_4(int *a, unsigned char b) {
	char t = jc;
	if (gps->a[b] & 0x10) { b = (b + guc) + b; if (gc2 != 0) t = gps->c / gc2; }
}
void rs_12_06_15_5(int *a, unsigned char b) {
	unsigned int u = ju;
	u = (gps->u ? (gua[u] & gua[3]) : -5413);
}
char rs_12_06_15_6(int *a, unsigned char b) {
	return (char)(guc < 0 ? gpi[0] : gi2);
}
void rs_12_06_16_0(struct st *a) {
	long t = gpl[0] >> 12;
	jl = t;
}
void rs_12_06_16_1(struct st *a) {
	if (gu2) gula[6] = gula[1] + 94025UL;
}
void rs_12_06_16_2(struct st *a) {
	long t = jl;
	gl = t;
}
void rs_12_06_16_3(struct st *a) {
	while (gi-- > 0) { if (*gp == 6) break; gp++; }
}
void rs_12_06_16_4(struct st *a) {
	v0();
}
void rs_12_06_16_5(struct st *a) {
	if ((long)gi3 != 65536L) { if (gc2 != 0) gc2 = (char)gi2 % gc2; gi2 *= 3; if (gps->u != 0) gs.u = gps->u % gps->u; } else { if (gi3 != 0) gia[0] = 256 % gi3; gu += gu2 * gu; }
}
char rs_12_06_16_6(struct st *a) {
	return (gc = gca[4]);
}
void rs_12_06_17_1(unsigned int a, int b) {
	int i = ji;
	for (i = 0; i < b; i++) { if (gca[i] != 0) gc2 = gc / gca[i]; }
}
void rs_12_06_17_2(unsigned int a, int b) {
	if (gua[6] & 1) { gs.p = gp + a; if (gua[a] != 0) gua[2] = gu % gua[a]; }
}
void rs_12_06_17_3(unsigned int a, int b) {
	gpi = rpi(r1(b));
}
long rs_12_06_17_4(unsigned int a, int b) {
	return (long)(gua[2] != (gs.u - gu));
}
void rs_12_06_18_0(void) {
	long t = *gpl >> 3;
	jl = t;
}
void rs_12_06_18_1(void) {
	while (gi-- > 0) *gp++ = -37;
}
void rs_12_06_18_2(void) {
	gd += gd2 + gd2;
}
void rs_12_06_18_3(void) {
	gula[5] = (unsigned long)gp[2];
}
void rs_12_06_18_4(void) {
	gi2 = gs.i = (gpi[1] + gi3) + (gi3 >> 2);
}
void rs_12_06_18_5(void) {
	gpi[0] = gi = (!gul ? (gps->i | gi) : gia[2]);
}
void rs_12_06_18_6(void) {
	long t = jl;
	vl(t);
}
unsigned long rs_12_06_18_7(void) {
	return rul(gul);
}
void rs_12_06_19_0(void) {
	gul <<= 3;
}
void rs_12_06_19_1(void) {
	++gp;
}
void rs_12_06_19_2(void) {
	if (((unsigned char)gi2) < 126) { if (gl2 != 0) gl = gl / gl2; if (gula[5] != 0) gul = 0x10000UL / gula[5]; if (gca[7] != 0) gca[3] = gc2 / gca[7]; }
}
void rs_12_06_19_3(void) {
	guc = guca[3];
}
void rs_12_07_00_0(unsigned int a, long *b, char *c) {
	int t = gpi[0];
	ji = t;
}
void rs_12_07_00_1(unsigned int a, long *b, char *c) {
	int t = ji;
	v2((r2(gs.i, gi) ? t : gps->i), gi);
}
void rs_12_07_00_2(unsigned int a, long *b, char *c) {
	int t = ji;
	v0();
	gs.i = r1(gpi[3] | t);
}
long rs_12_07_00_3(unsigned int a, long *b, char *c) {
	int t = ji;
	v0();
	return (gs.l ^ b[t]) << 9;
}
void rs_12_07_01_0(unsigned char a) {
	int t = gpi[3];
	ji = t;
}
void rs_12_07_01_1(unsigned char a) {
	int t = ji;
	if (gda[3] < 10.0) { gi3 %= 7; gpi = rpi((gl2 != -22739L ? *gpi : gia[a])); gd2 -= gs.d / 10.0; } else { if (gula[a] != 0) gul = gula[a] / gula[a]; gla[t] = -0L; }
}
void rs_12_07_01_2(unsigned char a) {
	if (gu2) { vc(gc + '0'); }
}
char rs_12_07_01_3(unsigned char a) {
	return (gc2 - (char)gla[5]) / 3;
}
void rs_12_07_02_1(int a) {
	long t = gps->l - gs.l;
	jl = t;
}
void rs_12_07_02_2(int a) {
	gula[0] = 7UL;
}
void rs_12_07_02_3(int a) {
	guca[0] = (unsigned char)((int)guca[7] >= ~gi2);
}
void rs_12_07_02_4(int a) {
	if (gda[1] == 100.0 || (char)gi > 46) { gc2 = (gi2 != a ? gc2 : (gu > 32767 ? '9' : gp[3])); v1(~a); }
}
void rs_12_07_02_5(int a) {
	int i = ji;
	long t = jl;
	v0();
	for (i = 0; i < a; i++) { vl(5L); if (gla[i] != 0) t = t % gla[i]; }
}
int rs_12_07_02_6(int a) {
	return gi3;
}
void rs_12_07_03_1(int a, char b, struct st *c) {
	int *t = gpi;
	jpi = t;
}
void rs_12_07_03_2(int a, char b, struct st *c) {
	int *t = jpi;
	v1(*t);
}
void rs_12_07_03_3(int a, char b, struct st *c) {
	gp = c->p + b;
}
void rs_12_07_03_4(int a, char b, struct st *c) {
	int i = ji;
	v0();
	i = 0; while (i < a) { if (gua[i] != 0) gua[i] = ((unsigned int)guc) % gua[i]; gia[i] = gs.a[i]; c->i = ~gps->i; i++; }
}
void rs_12_07_03_5(int a, char b, struct st *c) {
	b = *gp;
}
void rs_12_07_03_6(int a, char b, struct st *c) {
	vc((char)!(char)c->l);
}
char rs_12_07_03_7(int a, char b, struct st *c) {
	return gc2;
}
void rs_12_07_04_0(char a, char b) {
	int t = (int)9500;
	ji = t;
}
void rs_12_07_04_1(char a, char b) {
	int t = ji;
	switch (b) { case 1: v0(); case 3: case 20: gla[2] >>= 19; break; case 100: v1(t); break; default: vs(gps); break; }
}
void rs_12_07_04_2(char a, char b) {
	if (gua[a] != 0) gua[a] = 32767 % gua[a];
}
void rs_12_07_04_3(char a, char b) {
	if (gi2 != 0) gps->i = gi / gi2;
}
int rs_12_07_04_4(char a, char b) {
	int t = ji;
	v0();
	return t;
}
void rs_12_07_05_1(double a, unsigned char b) {
	guca[b] = ((unsigned char)gc) | b;
}
void rs_12_07_05_2(double a, unsigned char b) {
	gi2 += 1;
}
void rs_12_07_05_3(double a, unsigned char b) {
	guca[b] ^= 255 & 255;
}
void rs_12_07_05_4(double a, unsigned char b) {
	gua[b] = gu2 | gps->u;
}
void rs_12_07_05_5(double a, unsigned char b) {
	int i = ji;
	for (i = 12; i > 0; i--) { gla[2] |= rl(gl); gi2 = (gi2 % 10) | (gca[i] >= gc2); guca[i] -= 128; }
}
char * rs_12_07_05_6(double a, unsigned char b) {
	return gs.p;
}
void rs_12_07_06_1(int *a) {
	double t = gd2 - gd;
	jd = t;
}
void rs_12_07_06_2(int *a) {
	int i = ji;
	for (i = 2; i > 0; i--) { if (gu != 0) gu2 = gu % gu; gu++; }
}
void rs_12_07_06_3(int *a) {
	if (gpl[0]) { if (gps->u != 0) gu = gu2 / gps->u; }
}
void rs_12_07_06_4(int *a) {
	gul--;
}
void rs_12_07_06_5(int *a) {
	double t = jd;
	vd(t);
}
unsigned long rs_12_07_06_6(int *a) {
	if (gi2 & 1 || gl2 > gl) return (unsigned long)gi;
}
unsigned long rs_12_07_06_7(int *a) {
	return rul(~gul);
}
void rs_12_07_07_0(unsigned int a, unsigned char b, int c) {
	long t = -gs.l;
	jl = t;
}
void rs_12_07_07_1(unsigned int a, unsigned char b, int c) {
	if (gpi[1] & 0x7) vs(gps);
}
void rs_12_07_07_2(unsigned int a, unsigned char b, int c) {
	long t = jl;
	v0();
	gca[4] = (t ? gc : '9');
}
unsigned int rs_12_07_07_3(unsigned int a, unsigned char b, int c) {
	return 8;
}
void rs_12_07_08_0(int a, int b, long c) {
	unsigned long u = jul;
	unsigned int t = gu ^ gps->u;
	ju = t;
}
void rs_12_07_08_1(int a, int b, long c) {
	unsigned long u = gul;
	jul = u;
}
void rs_12_07_08_2(int a, int b, long c) {
	unsigned long u = jul;
	gul = u;
}
void rs_12_07_08_3(int a, int b, long c) {
	unsigned int t = ju;
	vp(gp + t);
}
void rs_12_07_08_4(int a, int b, long c) {
	guc = (unsigned char)(~7 <= (gca[b] / 2));
}
int * rs_12_07_08_5(int a, int b, long c) {
	return gpi;
}
void rs_12_07_09_0(unsigned long a) {
	if (gul != 0) gul = a % gul;
}
void rs_12_07_09_1(unsigned long a) {
	switch (gc2) { case 2: guca[6] %= 3; break; case 3: gp[3] = gca[1] = gca[3]; break; case 16: gp = &gca[3]; break; case 100: vd((double)gc); break; default: guc = guc >> 2; break; }
}
void rs_12_07_09_2(unsigned long a) {
	gula[3] = ~a;
}
void rs_12_07_09_3(unsigned long a) {
	gu /= 10;
}
void rs_12_07_10_1(int *a) {
	unsigned long t = gul;
	jul = t;
}
void rs_12_07_10_2(int *a) {
	guc = guc | (120 + guca[2]);
}
void rs_12_07_10_3(int *a) {
	int i = ji;
	unsigned long t = jul;
	for (i = 0; i < 4; i++) { if (gl != 0) gl2 = gl % gl; t = gul = ~gula[i]; if (gu != 0) gps->u = gu % gu; }
}
void rs_12_07_10_4(int *a) {
	int i = ji;
	for (i = 0; i < 13; i++) { if (gp[3] != 0) gca[i] = gp[3] % gp[3]; gc2 -= (gc == gca[i] ? gca[i] : 0); }
}
void rs_12_07_10_5(int *a) {
	unsigned long t = jul;
	gc = (char)((1 | gua[2]) <= ((unsigned int)(t == 8257UL)));
}
char * rs_12_07_10_6(int *a) {
	return gps->p;
}
void rs_12_07_11_0(void) {
	char t = *gp + gca[1];
	jc = t;
}
void rs_12_07_11_1(void) {
	unsigned long u = gul;
	jul = u;
}
void rs_12_07_11_2(void) {
	char t = jc;
	gl = gla[t];
}
char rs_12_07_11_3(void) {
	if (gp[3]) return gp[2];
}
void rs_12_07_11_4(void) {
	unsigned long u = jul;
	gul = u;
}
void rs_12_07_11_5(void) {
	gi3 = r2(gi & 1, gi);
}
char rs_12_07_11_6(void) {
	char t = jc;
	v0();
	return t ^ (gps->c & (' '));
}
void rs_12_07_12_1(void) {
	int t = gs.a[2] << 3;
	ji = t;
}
void rs_12_07_12_2(void) {
	int t = ji;
	char *u = &gca[t];
	jp = u;
}
void rs_12_07_12_3(void) {
	int i = ji;
	for (i = 0; i < 16; i++) { gps->l = gl2 - gla[i]; }
}
void rs_12_07_12_4(void) {
	int t = ji;
	*gp = (char)guc >> (t & 7);
}
void rs_12_07_12_5(void) {
	char *u = jp;
	gp = u;
}
void rs_12_07_12_6(void) {
	gi2 = gia[2];
}
void rs_12_07_12_7(void) {
	*gp >>= 1;
}
void rs_12_07_12_8(void) {
	gu = gu2 = 32767;
}
unsigned int rs_12_07_12_9(void) {
	return (gua[1] + 1) - gu2;
}
void rs_12_07_13_0(long a, long *b) {
	gps->a[6] = (int)b[2];
}
void rs_12_07_13_1(long a, long *b) {
	vc(5);
}
void rs_12_07_13_2(long a, long *b) {
	v0();
}
int rs_12_07_13_3(long a, long *b) {
	return (gps->i & gi3) + (100 - gi3);
}
void rs_12_07_14_0(double a, unsigned int b) {
	double t = gd * gd;
	jd = t;
}
void rs_12_07_14_1(double a, unsigned int b) {
	gca[5] |= (char)*gpl;
}
void rs_12_07_14_2(double a, unsigned int b) {
	double t = jd;
	vd(t);
}
void rs_12_07_14_3(double a, unsigned int b) {
	if ((gca[b] = '9')) { gu2 |= 256 | gua[b]; } else { v2(gi2, gi2); gps->l += gl2 / 16L; gs.u = gu + 10540; }
}
void rs_12_07_14_4(double a, unsigned int b) {
	*gpl %= 7L;
}
void rs_12_07_14_5(double a, unsigned int b) {
	gu2++;
}
unsigned long rs_12_07_14_6(double a, unsigned int b) {
	return (unsigned long)!b;
}
void rs_12_07_15_1(unsigned int a) {
	unsigned int t = -a;
	ju = t;
}
void rs_12_07_15_2(unsigned int a) {
	unsigned long u = rul(gul);
	jul = u;
}
void rs_12_07_15_3(unsigned int a) {
	v2(gi3, gi);
}
void rs_12_07_15_4(unsigned int a) {
	int i = ji;
	unsigned int t = ju;
	v0();
	for (i = 0; i < 16; i++) { if (gua[i] != 0) t = 8 / gua[i]; guc++; }
}
void rs_12_07_15_5(unsigned int a) {
	unsigned long u = jul;
	v0();
	gul = u;
}
void rs_12_07_15_6(unsigned int a) {
	unsigned int t = ju;
	v0();
	switch (gc) { case 0: case 1: t ^= 1; break; default: gl = gpl[0] = gps->l; break; }
}
char rs_12_07_15_7(unsigned int a) {
	return (gs.c = 29);
}
void rs_12_07_16_1(void) {
	double t = gs.d - gs.d;
	jd = t;
}
void rs_12_07_16_2(void) {
	double t = jd;
	t += (double)gia[5];
}
void rs_12_07_16_3(void) {
	int i = ji;
	double t = jd;
	for (i = 10; i > 0; i--) { gl = 65536L; if (gi3 != 0) gi2 = gs.a[i] % gi3; t -= (gul <= 0x10000UL ? 3.0 : gd); }
}
void rs_12_07_16_4(void) {
	gl2++;
}
void rs_12_07_16_5(void) {
	gi2 = ~(*gpi - 256);
}
char * rs_12_07_16_6(void) {
	return gps->p + 1;
}
void rs_12_07_17_0(struct st *a, long *b) {
	int *t = gpi + 1;
	jpi = t;
}
void rs_12_07_17_1(struct st *a, long *b) {
	int *t = jpi;
	v1(*t);
}
void rs_12_07_17_2(struct st *a, long *b) {
	vd(gd2 - gs.d);
}
void rs_12_07_17_3(struct st *a, long *b) {
	while (gi-- > 0) { if (*b == 65536L) break; b++; }
}
void rs_12_07_17_4(struct st *a, long *b) {
	guc--;
}
int rs_12_07_17_5(struct st *a, long *b) {
	return 2 / 7;
}
void rs_12_07_18_1(unsigned char a) {
	char t = rc(gi);
	jc = t;
}
void rs_12_07_18_2(unsigned char a) {
	vs(gps);
}
void rs_12_07_18_3(unsigned char a) {
	gl = (gpl[2] + gl) >> 6;
}
void rs_12_07_18_4(unsigned char a) {
	gl = gl2;
}
char * rs_12_07_18_5(unsigned char a) {
	if (!gc) return gs.p;
}
void rs_12_07_18_6(unsigned char a) {
	int i = ji;
	v0();
	for (i = 0; i < 16; i++) { if (gula[i] != 0) gul = gul % gula[i]; v2(gi2, gi2); gu = gs.u = -(gu2 ^ gs.u); }
}
void rs_12_07_18_7(unsigned char a) {
	char t = jc;
	v0();
	gc = t;
}
char * rs_12_07_18_8(unsigned char a) {
	return gp;
}
void rs_12_07_19_0(void) {
	gul = rul(gul) >> 3;
}
void rs_12_07_19_1(void) {
	gs.i = gi3 + gi;
}
void rs_12_07_19_2(void) {
	gl2 ^= 65536L + gpl[1];
}
int rs_12_07_19_3(void) {
	return 256 / 4;
}
void rs_12_08_00_0(unsigned char a, struct st *b) {
	double t = gd / 2.5;
	jd = t;
}
void rs_12_08_00_1(unsigned char a, struct st *b) {
	double t = jd;
	gd = t;
}
void rs_12_08_00_2(unsigned char a, struct st *b) {
	switch (gu2) { case 0: gc2 = gca[a] << 1; case 1: gu2 = ((unsigned int)gps->l) - gps->u; break; case 2: gs.p = gp; break; case 3: *gpi = (!gc ? gi : 100); break; case 4: v1(*gpi); break; case 5: gul = 0x10000UL % 3UL; break; }
}
void rs_12_08_00_3(unsigned char a, struct st *b) {
	gca[a] %= 10;
}
void rs_12_08_00_4(unsigned char a, struct st *b) {
	v0();
}
char * rs_12_08_00_5(unsigned char a, struct st *b) {
	return rp();
}
void rs_12_08_01_1(unsigned long a, long b) {
	char *t = gs.p;
	jp = t;
}
void rs_12_08_01_2(unsigned long a, long b) {
	int i = ji;
	i = 0; while (i < 11) { if (gula[i] != 0) gul = a / gula[i]; vs(gps); i++; }
}
void rs_12_08_01_3(unsigned long a, long b) {
	gla[6] = b = 0L;
}
void rs_12_08_01_4(unsigned long a, long b) {
	char *t = jp;
	v0();
	vp(t);
}
void rs_12_08_01_5(unsigned long a, long b) {
	int i = ji;
	v0();
	for (i = 0; i < 12; i++) { if (gi != 0) gs.a[i] = i / gi; }
}
void rs_12_08_01_6(unsigned long a, long b) {
	gs.c = -31;
}
unsigned long rs_12_08_01_7(unsigned long a, long b) {
	return (((unsigned int)gula[4]) > gps->u ? (gul << 23) : a);
}
void rs_12_08_02_0(double a, long b, char c) {
	gi2 ^= gi2 % 100;
}
void rs_12_08_02_1(double a, long b, char c) {
	gu2 = gua[c];
}
long rs_12_08_02_2(double a, long b, char c) {
	if (gula[1] < 0x10000UL) return 0L;
}
void rs_12_08_02_3(double a, long b, char c) {
	gpi = gpi + c;
}
long rs_12_08_02_4(double a, long b, char c) {
	return rl(gps->l) - rl(b);
}
void rs_12_08_03_0(char *a, char b) {
	char *t = gps->p;
	jp = t;
}
void rs_12_08_03_1(char *a, char b) {
	if (-14876L == gl) { gla[5] = gl = ~(long)gul + (long)gula[2]; } else { if (gul != 0) gul = ((unsigned long)guc) / gul; if (*gpi != 0) gia[b] = (int)gpl[0] % *gpi; gi = gi + *gpi; }
}
void rs_12_08_03_2(char *a, char b) {
	gula[b] = 4UL / 2UL;
}
void rs_12_08_03_3(char *a, char b) {
	switch (gs.u) { case 0: vu(gu); break; case 1: vu(255); break; default: gua[4] = (gula[b] ? gu2 : gu); break; }
}
void rs_12_08_03_4(char *a, char b) {
	char *t = jp;
	v0();
	gps->p = t;
}
char * rs_12_08_03_5(char *a, char b) {
	char *t = jp;
	v0();
	return t;
}
void rs_12_08_04_0(void) {
	guc = (guc / 2) + (128 & guc);
}
void rs_12_08_04_1(void) {
	if (gl2) { if (gs.a[0] != 0) gi = 16 / gs.a[0]; vs(gps); if (gul != 0) gula[5] = 26019UL % gul; } else { if (gs.a[1] != 0) gi2 = gi / gs.a[1]; gpi = &gia[4]; }
}
char rs_12_08_04_2(void) {
	return (guc & 0x80 ? (' ') : (gca[3] & gc));
}
void rs_12_08_05_0(int a, unsigned long b) {
	char *t = rp();
	jp = t;
}
void rs_12_08_05_1(int a, unsigned long b) {
	double u = gd2 * gd2;
	v0();
	jd = u;
}
void rs_12_08_05_2(int a, unsigned long b) {
	char *t = jp;
	v0();
	t[3] = -*gp;
}
void rs_12_08_05_3(int a, unsigned long b) {
	gc2 += *gp - gs.c;
}
void rs_12_08_05_4(int a, unsigned long b) {
	double u = jd;
	v0();
	guc = (unsigned char)!(gu2 + gps->u);
}
long rs_12_08_05_5(int a, unsigned long b) {
	return gla[2];
}
void rs_12_08_06_1(char a, char b, unsigned char c) {
	if (gs.u & 4) { gl2++; }
}
void rs_12_08_06_2(char a, char b, unsigned char c) {
	int i = ji;
	for (i = 6; i > 0; i--) { guc -= 8; }
}
void rs_12_08_06_3(char a, char b, unsigned char c) {
	if (gi3) { gp[2] = gca[a] + a; }
}
long rs_12_08_06_4(char a, char b, unsigned char c) {
	return (gpl[1] / 100L) & 65536L;
}
void rs_12_08_07_0(long a, int *b) {
	switch (gi3) { case 0: gpi[3] = r2(gia[6], gi); case 1: gua[6] = (guc & 0x7 ? 255 : gua[4]); break; case 2: v0(); break; case 3: gc = gc * gca[0]; break; case 4: vu(gu); break; case 5: vs(gps); break; }
}
void rs_12_08_07_1(long a, int *b) {
	gul = gula[4] & rul(gula[4]);
}
void rs_12_08_07_2(long a, int *b) {
	gul = gula[4];
}
long rs_12_08_07_3(long a, int *b) {
	return (gl & *gpl) % 3L;
}
void rs_12_08_08_0(char a, unsigned int b, char c) {
	if (!gc2) v1(gs.a[a]);
}
void rs_12_08_08_1(char a, unsigned int b, char c) {
	guc = (gi > *gpi ? guc : 128) + guca[2];
}
void rs_12_08_08_2(char a, unsigned int b, char c) {
	vu(ru(gua[b]));
}
void rs_12_08_08_3(char a, unsigned int b, char c) {
	switch (gps->c) { case 3: vc(a); break; case 8: case 10: gda[3] = gs.d + gd2; break; case 16: case 20: gd = (gs.c > 50 ? gda[3] : gd2); break; case 100: vs(gps); break; }
}
void rs_12_08_08_4(char a, unsigned int b, char c) {
	while (gi > 0) { gi3 += *gpi++; gi--; }
}
unsigned int rs_12_08_08_5(char a, unsigned int b, char c) {
	return gu;
}
void rs_12_08_09_1(char a, struct st *b) {
	int *t = gpi + a;
	jpi = t;
}
void rs_12_08_09_2(char a, struct st *b) {
	double u = 1.0 + gda[3];
	jd = u;
}
void rs_12_08_09_3(char a, struct st *b) {
	double u = jd;
	vd(u);
}
void rs_12_08_09_4(char a, struct st *b) {
	int *t = jpi;
	v0();
	*t = gia[a];
}
void rs_12_08_09_5(char a, struct st *b) {
	int i = ji;
	v0();
	for (i = 12; i > 0; i--) { gd2 = -(-(double)gp[0]); }
}
void rs_12_08_10_1(unsigned char a, char *b) {
	char t = gc2;
	jc = t;
}
void rs_12_08_10_2(unsigned char a, char *b) {
	double u = 0.25;
	jd = u;
}
void rs_12_08_10_3(unsigned char a, char *b) {
	int i = ji;
	for (i = 0; i < 7; i++) { gia[i] = gi - 1; }
}
void rs_12_08_10_4(unsigned char a, char *b) {
	if (gu != 0) gu2 = 255 % gu;
}
void rs_12_08_10_5(unsigned char a, char *b) {
	double u = jd;
	gps->u |= gu * 8;
}
void rs_12_08_10_6(unsigned char a, char *b) {
	int i = ji;
	gs.i -= (int)guc;
}
void rs_12_08_10_7(unsigned char a, char *b) {
	switch (gl) { case 0L: a ^= guc; break; case 1L: gula[6] -= gul; break; case 2L: v0(); break; case 3L: vs(gps); break; }
}
void rs_12_08_10_8(unsigned char a, char *b) {
	char t = jc;
	v0();
	vc(t);
}
char * rs_12_08_10_9(unsigned char a, char *b) {
	char t = jc;
	v0();
	return gps->p + t;
}
void rs_12_08_11_0(void) {
	char *t = gps->p;
	jp = t;
}
void rs_12_08_11_1(void) {
	v1(100 + gi3);
}
void rs_12_08_11_2(void) {
	gula[0] *= 4UL;
}
void rs_12_08_11_3(void) {
	gc %= 10;
}
void rs_12_08_11_4(void) {
	char *t = jp;
	v0();
	gp = t;
}
int rs_12_08_11_5(void) {
	return (gps->i / 16) >> 9;
}
void rs_12_08_12_1(int a, unsigned char b) {
	unsigned long t = rul(gul);
	jul = t;
}
void rs_12_08_12_2(int a, unsigned char b) {
	unsigned long t = jul;
	v0();
	if ((t = gul) <= 15947UL) *gpl = gla[3] = 64180L;
}
void rs_12_08_12_3(int a, unsigned char b) {
	gi3 = 100;
}
void rs_12_08_12_4(int a, unsigned char b) {
	int i = ji;
	v0();
	for (i = 3; i > 0; i--) { gps->l = gla[i]; gu = (unsigned int)!(char)gua[b]; guca[4] = guc << 7; }
}
void rs_12_08_12_5(int a, unsigned char b) {
	guca[4] = guc;
}
void rs_12_08_12_6(int a, unsigned char b) {
	unsigned long t = jul;
	v0();
	if (gua[a] & 4) { v0(); if (gua[6] != 0) gu2 = gu / gua[6]; if (gc2 != 0) gc2 = gca[7] / gc2; } else { gu2 = ((unsigned int)gc2) % 3; --gpi; t %= 2UL; }
}
int rs_12_08_12_7(int a, unsigned char b) {
	return gi3;
}
void rs_12_08_13_1(char *a) {
	int t = gia[1];
	ji = t;
}
void rs_12_08_13_2(char *a) {
	int t = ji;
	gc2 >>= (t & 7);
}
void rs_12_08_13_3(char *a) {
	int i = ji;
	for (i = 0; i < 2; i++) { vc(gca[i]); gula[i] |= (unsigned long)((unsigned int)gc); if (gps->u != 0) gps->u = gu2 % gps->u; }
}
char * rs_12_08_13_4(char *a) {
	return a;
}
void rs_12_08_14_0(void) {
	v2(gps->a[5], gi);
}
void rs_12_08_14_1(void) {
	while (gi > 0) { gi += *gpi++; gi--; }
}
void rs_12_08_14_2(void) {
	vd(gd);
}
char * rs_12_08_14_3(void) {
	return rp();
}
void rs_12_08_15_0(unsigned char a) {
	int *t = gpi + a;
	jpi = t;
}
void rs_12_08_15_1(unsigned char a) {
	v0();
}
void rs_12_08_15_2(unsigned char a) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_12_08_15_3(unsigned char a) {
	v0();
}
void rs_12_08_16_1(int a, long b) {
	int i = ji;
	for (i = 0; i < 11; i++) { gpi = rpi(i ^ gi3); gl = gla[i] | (*gpl * 65536L); }
}
void rs_12_08_16_2(int a, long b) {
	if (480UL <= gula[a]) { if (*gpl != 0) b = gl % *gpl; b -= (long)guca[5]; }
}
void rs_12_08_16_3(int a, long b) {
	gpi = gpi + a;
}
void rs_12_08_16_4(int a, long b) {
	guca[5] *= 8;
}
void rs_12_08_16_5(int a, long b) {
	if (gula[7] <= gul) gda[3] = (double)gi - gda[3];
}
int rs_12_08_16_6(int a, long b) {
	return !4;
}
void rs_12_08_17_0(int a) {
	long t = (long)!256;
	jl = t;
}
void rs_12_08_17_1(int a) {
	double u = gda[1];
	jd = u;
}
void rs_12_08_17_2(int a) {
	gul = (unsigned long)*gpl;
}
void rs_12_08_17_3(int a) {
	guc = guca[7] * -guca[1];
}
void rs_12_08_17_4(int a) {
	long t = jl;
	gl = t;
}
void rs_12_08_17_5(int a) {
	double u = jd;
	gs.u = (unsigned int)!(255 + gps->u);
}
char rs_12_08_17_6(int a) {
	return (char)!gi2;
}
void rs_12_08_18_0(void) {
	char t = rc(gi3);
	jc = t;
}
void rs_12_08_18_1(void) {
	unsigned long u = (gs.a[2] ? gul : gul);
	v0();
	jul = u;
}
void rs_12_08_18_2(void) {
	gp = rp();
}
void rs_12_08_18_3(void) {
	char t = jc;
	v0();
	guc = guca[t] = 128;
}
void rs_12_08_18_4(void) {
	unsigned long u = jul;
	v0();
	gu2 = gps->u = (8 != gia[2] && guc >= 8 ? (gs.u ^ gu2) : (gu - 255));
}
unsigned int rs_12_08_18_5(void) {
	unsigned long u = jul;
	v0();
	return ((unsigned int)!u) + (-((unsigned int)gi2));
}
void rs_12_08_19_0(char a) {
	int *t = gpi + a;
	jpi = t;
}
void rs_12_08_19_1(char a) {
	gc = -(gp[2] ^ gc);
}
void rs_12_08_19_2(char a) {
	int *t = jpi;
	v1(*t);
}
unsigned int rs_12_08_19_3(char a) {
	if (gl) return 11544 - gua[a];
}
void rs_12_08_19_4(char a) {
	gul >>= 10;
}
unsigned int rs_12_08_19_5(char a) {
	return (1 | gu) - (gua[a] + gu2);
}
void rs_12_09_00_1(long a, int *b, unsigned long c) {
	int i = ji;
	for (i = 0; i < 16; i++) { if (gu2 != 0) gu2 = 256 / gu2; guc = ((unsigned char)(*gp != gca[i])) - (guca[i] + 7); }
}
void rs_12_09_00_2(long a, int *b, unsigned long c) {
	gc2 = ~gc;
}
void rs_12_09_00_3(long a, int *b, unsigned long c) {
	gp--;
}
void rs_12_09_00_4(long a, int *b, unsigned long c) {
	gps->p = gs.p;
}
int rs_12_09_00_5(long a, int *b, unsigned long c) {
	return (*gpi - gi3) + (int)'9';
}
void rs_12_09_01_0(void) {
	double t = gd2 + 10.0;
	jd = t;
}
void rs_12_09_01_1(void) {
	switch (gl) { case 1L: gd = -gd; break; case 200L: vp(gp + 1); break; default: vl(gl); break; }
}
void rs_12_09_01_2(void) {
	double t = jd;
	v0();
	vd(t);
}
void rs_12_09_01_3(void) {
	gpi = rpi(gpi[0]);
}
int * rs_12_09_01_4(void) {
	return &gia[4];
}
void rs_12_09_02_0(unsigned char a, int b) {
	char t = gca[6];
	jc = t;
}
void rs_12_09_02_1(unsigned char a, int b) {
	char t = jc;
	gc = t;
}
void rs_12_09_02_2(unsigned char a, int b) {
	gi3 -= *gpi + gs.i;
}
void rs_12_09_02_3(unsigned char a, int b) {
	if (gps->l != 0) gs.l = gps->l % gps->l;
}
int rs_12_09_02_4(unsigned char a, int b) {
	return (gi2 = 100);
}
void rs_12_09_03_1(int a, struct st *b) {
	char t = gc2 ^ '9';
	jc = t;
}
void rs_12_09_03_2(int a, struct st *b) {
	gl = (b->u != 8 && gla[6] == 65536L ? -gl2 : (2L >> 29));
}
void rs_12_09_03_3(int a, struct st *b) {
	++guc;
}
void rs_12_09_03_4(int a, struct st *b) {
	char t = jc;
	t *= 6;
}
void rs_12_09_03_5(int a, struct st *b) {
	int i = ji;
	for (i = 0; i < a; i++) { vl((long)(gi3 >= 8)); vc(gc2); }
}
int * rs_12_09_03_6(int a, struct st *b) {
	return gpi;
}
void rs_12_09_04_0(void) {
	unsigned char u = juc;
	unsigned int t = (gl2 >= gla[0] ? gua[0] : gps->u);
	ju = t;
}
void rs_12_09_04_1(void) {
	unsigned char u = guc | 6;
	juc = u;
}
void rs_12_09_04_2(void) {
	gi3--;
}
void rs_12_09_04_3(void) {
	unsigned int t = ju;
	vu(t);
}
void rs_12_09_04_4(void) {
	gd = -gd;
}
void rs_12_09_04_5(void) {
	unsigned char u = juc;
	v0();
	guc = u;
}
void rs_12_09_05_1(void) {
	int t = (((unsigned int)gula[2]) != gua[0]);
	ji = t;
}
void rs_12_09_05_2(void) {
	gua[3] %= 7;
}
void rs_12_09_05_3(void) {
	int i = ji;
	int t = ji;
	i = 12; do { if (gul != 0) gul = gula[t] / gul; gc2++; gps->l = gs.l; } while (--i > 0);
}
void rs_12_09_05_4(void) {
	int t = ji;
	switch (gc) { case 0: gd *= gda[3]; case 1: gula[1] += gula[0]; break; case 2: case 3: vl(gpl[0]); break; case 4: guc = guc ^ guca[t]; break; }
}
void rs_12_09_05_5(void) {
	gu |= ru(6);
}
unsigned long rs_12_09_05_6(void) {
	return ~(gula[1] / 10UL);
}
void rs_12_09_06_1(char a, long b, unsigned char c) {
	unsigned int t = gua[0];
	ju = t;
}
void rs_12_09_06_2(char a, long b, unsigned char c) {
	int u = gi3 % 7;
	ji = u;
}
void rs_12_09_06_3(char a, long b, unsigned char c) {
	int u = ji;
	u = u - 8;
}
void rs_12_09_06_4(char a, long b, unsigned char c) {
	int i = ji;
	int u = ji;
	i = 16; do { u += (int)guc; gul++; vc(rc(gi3)); } while (--i > 0);
}
void rs_12_09_06_5(char a, long b, unsigned char c) {
	v2(gi2, gi3);
}
void rs_12_09_06_6(char a, long b, unsigned char c) {
	unsigned int t = ju;
	v0();
	gu = t;
}
void rs_12_09_06_7(char a, long b, unsigned char c) {
	if (gps->c < 3) if (gul != 0) gul = gul % gul;
}
void rs_12_09_06_8(char a, long b, unsigned char c) {
	int u = ji;
	v0();
	v2(('z' <= 7 ? u : *gpi), gi);
}
void rs_12_09_07_0(unsigned int a, long b, int c) {
	double t = gd * gd2;
	jd = t;
}
void rs_12_09_07_1(unsigned int a, long b, int c) {
	while (c-- > 0) *gpi++ = 100;
}
void rs_12_09_07_2(unsigned int a, long b, int c) {
	gps->c = *gp = gca[6] & gc2;
}
void rs_12_09_07_3(unsigned int a, long b, int c) {
	if (!guc && gl2) { gpi = gpi + a; gca[c] = gca[a] - gc; if (b != 0) gs.l = b / b; }
}
void rs_12_09_07_4(unsigned int a, long b, int c) {
	gi2 = ((char)gl2 > 7);
}
void rs_12_09_07_5(unsigned int a, long b, int c) {
	double t = jd;
	vd(t);
}
long rs_12_09_07_6(unsigned int a, long b, int c) {
	return (gla[2] - gl2) / 4L;
}
void rs_12_09_08_0(int *a) {
	long t = (long)(*a >= gi);
	jl = t;
}
void rs_12_09_08_1(int *a) {
	unsigned int u = gu;
	ju = u;
}
void rs_12_09_08_2(int *a) {
	gda[0] = gs.d;
}
void rs_12_09_08_3(int *a) {
	gda[0] -= gda[1];
}
void rs_12_09_08_4(int *a) {
	unsigned int u = ju;
	gu = u;
}
void rs_12_09_08_5(int *a) {
	gi2 = r0();
}
void rs_12_09_08_6(int *a) {
	long t = jl;
	v0();
	gl = t;
}
long rs_12_09_08_7(int *a) {
	return (gl = -59870L);
}
void rs_12_09_09_0(long *a, int b) {
	int t = r2(gi2, gi);
	ji = t;
}
void rs_12_09_09_1(long *a, int b) {
	int t = ji;
	v0();
	switch (b) { case 3: case 16: vp(&gca[7]); break; case 20: gpi = rpi(*gpi); break; case 200: gi = (int)gul; break; default: gua[t] = gu; break; }
}
void rs_12_09_09_2(long *a, int b) {
	if (gul != 0) gul = gul / gul;
}
void rs_12_09_09_3(long *a, int b) {
	int t = ji;
	v0();
	gc2 = (gl2 != a[t] || gi3 == 127 ? ((char)(gps->u == 255)) : gc2);
}
int rs_12_09_09_4(long *a, int b) {
	return gs.i;
}
void rs_12_09_10_1(unsigned long a) {
	int i = ji;
	for (i = 0; i < 16; i++) { gp = gs.p; guca[i] /= 10; gpi = gpi + i; }
}
void rs_12_09_10_2(unsigned long a) {
	gps->a[0] = (guca[0] == 128 ? gi3 : gi2);
}
void rs_12_09_10_3(unsigned long a) {
	v0();
}
int * rs_12_09_10_4(unsigned long a) {
	return gpi;
}
void rs_12_09_11_1(void) {
	int t = gi;
	ji = t;
}
void rs_12_09_11_2(void) {
	unsigned char u = guc / 2;
	juc = u;
}
void rs_12_09_11_3(void) {
	vu(gu);
}
void rs_12_09_11_4(void) {
	int t = ji;
	v0();
	v1(t);
}
void rs_12_09_11_5(void) {
	guc++;
}
void rs_12_09_11_6(void) {
	gd = gda[3] / 0.5;
}
void rs_12_09_11_7(void) {
	int i = ji;
	unsigned char u = juc;
	v0();
	i = 0; while (i < 12) { gd2 *= (double)gi3; gc = (*gpl > gpl[3] ? gs.c : -73) & gp[2]; u = (guca[i] >> 6) / 10; i++; }
}
unsigned int rs_12_09_11_8(void) {
	return ru(gu / 16);
}
void rs_12_09_12_0(char a, double b) {
	unsigned char t = 237 / 2;
	juc = t;
}
void rs_12_09_12_1(char a, double b) {
	gpi = rpi(gi2);
}
void rs_12_09_12_2(char a, double b) {
	vu((unsigned int)!gul);
}
void rs_12_09_12_3(char a, double b) {
	gula[a] = gul;
}
void rs_12_09_12_4(char a, double b) {
	unsigned char t = juc;
	v0();
	gu2 = (16908 / 3) << (t & 15);
}
void rs_12_09_12_5(char a, double b) {
	gul--;
}
char rs_12_09_12_6(char a, double b) {
	return *gp;
}
void rs_12_09_13_0(int a, unsigned int b, int c) {
	char t = gca[a];
	jc = t;
}
void rs_12_09_13_1(int a, unsigned int b, int c) {
	int u = gi2 + gia[6];
	ji = u;
}
void rs_12_09_13_2(int a, unsigned int b, int c) {
	char t = jc;
	if (gc2 == 'z' || gula[3] != ((unsigned long)guc)) { if (c != 0) gpi[1] = gi2 % c; a = 9 - *gpi; } else { v0(); gd2 = (!gul ? 0.5 : 0.5) + (0.25 - gd); if (t != 0) gca[0] = gps->c % t; }
}
void rs_12_09_13_3(int a, unsigned int b, int c) {
	gps->a[0] >>= 6;
}
void rs_12_09_13_4(int a, unsigned int b, int c) {
	while (a > 0) { gi2 += *gpi++; a--; }
}
void rs_12_09_13_5(int a, unsigned int b, int c) {
	gs.p = gps->p;
}
void rs_12_09_13_6(int a, unsigned int b, int c) {
	int u = ji;
	v0();
	gi = u;
}
char * rs_12_09_13_7(int a, unsigned int b, int c) {
	return gs.p;
}
void rs_12_09_14_0(struct st *a, int *b, int c) {
	char *t = gp;
	jp = t;
}
void rs_12_09_14_1(struct st *a, int *b, int c) {
	while (c-- > 0) { if (*b == 256) break; b++; }
}
void rs_12_09_14_2(struct st *a, int *b, int c) {
	vc(*gp + 'z');
}
void rs_12_09_14_3(struct st *a, int *b, int c) {
	v0();
}
void rs_12_09_14_4(struct st *a, int *b, int c) {
	char *t = jp;
	v0();
	t = a->p;
}
void rs_12_09_14_5(struct st *a, int *b, int c) {
	char *t = jp;
	v0();
	if (!gula[1]) { gul = rul(gul) ^ (gula[c] + gul); guc = (unsigned char)gula[7]; t[2] = gc = ((char)gua[c] / 16) / 4; }
}
void rs_12_09_15_1(double a, int *b) {
	int *t = b;
	jpi = t;
}
void rs_12_09_15_2(double a, int *b) {
	char *u = rp();
	jp = u;
}
void rs_12_09_15_3(double a, int *b) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_12_09_15_4(double a, int *b) {
	int i = ji;
	v0();
	i = 0; while (i < 16) { gua[6] += gu; if (gs.l != 0) gps->l = gpl[2] / gs.l; i++; }
}
void rs_12_09_15_5(double a, int *b) {
	gs.c |= gs.c / 4;
}
void rs_12_09_15_6(double a, int *b) {
	if (a == 0.25) { gda[0] += (double)gp[2] - gda[1]; gu2 <<= 15; } else { guca[0] = (unsigned char)(gi - 16); }
}
void rs_12_09_15_7(double a, int *b) {
	char *u = jp;
	v0();
	if (u[5] > gc2) { if (gul != 0) gul = gul / gul; if (gula[1] != 0) gula[0] = gul / gula[1]; } else { gps->u = (unsigned int)!(int)u[7]; vu(((unsigned int)guc) ^ gu2); }
}
long rs_12_09_15_8(double a, int *b) {
	if (2.5 >= gda[3]) return gl ^ 65536L;
}
long rs_12_09_15_9(double a, int *b) {
	return gl;
}
void rs_12_09_16_0(int a, long b, unsigned int c) {
	double t = gs.d / 0.5;
	jd = t;
}
void rs_12_09_16_1(int a, long b, unsigned int c) {
	char u = 5 + gca[a];
	jc = u;
}
void rs_12_09_16_2(int a, long b, unsigned int c) {
	double t = jd;
	gd = t;
}
void rs_12_09_16_3(int a, long b, unsigned int c) {
	if (!gla[c]) { --gpi; } else { gia[2] = r1(gps->i + gi3); }
}
void rs_12_09_16_4(int a, long b, unsigned int c) {
	gul = -(gul / 2UL);
}
void rs_12_09_16_5(int a, long b, unsigned int c) {
	char u = jc;
	v0();
	if (u != 0) gca[u] = gca[6] % u;
}
char rs_12_09_16_6(int a, long b, unsigned int c) {
	char u = jc;
	v0();
	return u & (u / 2);
}
void rs_12_09_17_1(unsigned int a) {
	char t = -gc;
	jc = t;
}
void rs_12_09_17_2(unsigned int a) {
	int i = ji;
	for (i = 0; i < 5; i++) { if (gs.l != 0) gl = gl2 / gs.l; v1(256); if (*gpl != 0) gps->l = gs.l % *gpl; }
}
void rs_12_09_17_3(unsigned int a) {
	char t = jc;
	v0();
	gpi = gpi + t;
}
void rs_12_09_17_4(unsigned int a) {
	int i = ji;
	v0();
	i = 0; while (i < 13) { gl2 %= 2L; gpi = rpi(gia[i]); i++; }
}
void rs_12_09_17_5(unsigned int a) {
	switch (gc) { case 3: *gpl = gs.l - gla[0]; break; case 5: gul = 2UL; break; default: vu(gu); break; }
}
void rs_12_09_17_6(unsigned int a) {
	char t = jc;
	v0();
	gi2 = gia[7] = gia[t] << 9;
}
unsigned int rs_12_09_17_7(unsigned int a) {
	return 256;
}
void rs_12_09_18_1(void) {
	if (gul != 0) gula[5] = 7UL / gul;
}
void rs_12_09_18_2(void) {
	int i = ji;
	for (i = 0; i < 16; i++) { if (gps->l != 0) gla[i] = gl2 % gps->l; }
}
void rs_12_09_18_3(void) {
	guc = ((unsigned char)gu2) % 16;
}
unsigned int rs_12_09_18_4(void) {
	return gps->u & (gu2 + gs.u);
}
void rs_12_09_19_0(void) {
	gs.c = gp[2];
}
void rs_12_09_19_1(void) {
	gi2 = -gpi[0] | (gi % 2);
}
long rs_12_09_19_2(void) {
	return gpl[1];
}
