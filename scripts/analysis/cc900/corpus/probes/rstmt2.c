/* Every statement line of random2 alone in its own function (gen_rstmt.py corpus/random2 2): rs_<A>_<BB>_<CC>_<k> is line k of
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

void rs_2_00_00_0(double a, char *b) {
	gp[1] &= gs.c / 3;
}
void rs_2_00_00_1(double a, char *b) {
	--gl2;
}
void rs_2_00_00_2(double a, char *b) {
	guc--;
}
void rs_2_00_00_3(double a, char *b) {
	b[1] = gc ^ (b[1] - gca[2]);
}
long rs_2_00_00_4(double a, char *b) {
	return rl(gl);
}
void rs_2_00_01_0(long a) {
	switch (gi3) { case 0: case 1: v0(); break; case 2: v1(gpi[3]); break; case 3: gul = gula[7] = gula[3] | gul; break; case 4: gc = (char)gula[5]; break; case 5: gc = -gc; break; default: v1(gi); break; }
}
void rs_2_00_01_1(long a) {
	gc %= 16;
}
void rs_2_00_01_2(long a) {
	gda[3] = -gd;
}
void rs_2_00_01_3(long a) {
	if (guca[5] != guca[0] && !guca[0]) { gi = gi2 << 3; gpi = &gia[6]; if (gc2 != 0) gc = gc % gc2; }
}
void rs_2_00_01_4(long a) {
	guca[0] = guc << 6;
}
int rs_2_00_01_5(long a) {
	return (int)gs.c + 432;
}
void rs_2_00_02_1(void) {
	double t = gd2 * (double)*gpl;
	jd = t;
}
void rs_2_00_02_2(void) {
	guc = guca[7] % 16;
}
void rs_2_00_02_3(void) {
	guca[2] -= 153 % 3;
}
void rs_2_00_02_4(void) {
	double t = jd;
	vd(t);
}
void rs_2_00_02_5(void) {
	gu %= 10;
}
void rs_2_00_02_6(void) {
	gua[6] = gu2 * 5;
}
void rs_2_00_02_7(void) {
	int i = ji;
	v0();
	for (i = 0; i < 6; i++) { vs(gps); if (gua[i] != 0) gs.u = gua[i] / gua[i]; ++gi2; }
}
int rs_2_00_02_8(void) {
	return 16;
}
void rs_2_00_03_0(int a, char b) {
	double t = gs.d;
	jd = t;
}
void rs_2_00_03_1(int a, char b) {
	double t = jd;
	gd = t;
}
void rs_2_00_03_2(int a, char b) {
	guc = -guca[a] / 10;
}
void rs_2_00_03_3(int a, char b) {
	gp = gp + a;
}
void rs_2_00_03_4(int a, char b) {
	gia[3] &= r2(gpi[1], gi);
}
void rs_2_00_03_5(int a, char b) {
	v2(~255, gi);
}
char rs_2_00_03_6(int a, char b) {
	return gps->c << (a & 7);
}
void rs_2_00_04_0(unsigned char a, int *b) {
	int t = r1(*gpi);
	ji = t;
}
void rs_2_00_04_1(unsigned char a, int *b) {
	unsigned char u = a;
	v0();
	juc = u;
}
void rs_2_00_04_2(unsigned char a, int *b) {
	if (gl != 0) gpl[3] = gpl[0] % gl;
}
void rs_2_00_04_3(unsigned char a, int *b) {
	unsigned char u = juc;
	v0();
	gu ^= gu + gps->u;
}
void rs_2_00_04_4(unsigned char a, int *b) {
	switch (gs.c) { case 2: gc = gps->c; break; case 16: v0(); break; case 20: gc ^= gca[a]; break; }
}
void rs_2_00_04_5(unsigned char a, int *b) {
	int t = ji;
	v0();
	v1(t);
}
void rs_2_00_04_6(unsigned char a, int *b) {
	gps->p = gp;
}
int * rs_2_00_04_7(unsigned char a, int *b) {
	return &gia[2];
}
void rs_2_00_05_0(char a, long b) {
	char t = gp[2] >> 7;
	jc = t;
}
void rs_2_00_05_1(char a, long b) {
	int *u = gpi;
	jpi = u;
}
unsigned long rs_2_00_05_2(char a, long b) {
	if (gul != 0x10000UL) return rul(gul);
}
void rs_2_00_05_3(char a, long b) {
	char t = jc;
	v0();
	if (gua[7] <= gu) { if (t != 0) gca[t] = gc2 / t; } else { --gp; gi3 <<= 12; v2(gi2 - 2, gi); }
}
void rs_2_00_05_4(char a, long b) {
	int *u = jpi;
	v0();
	++u;
}
void rs_2_00_05_5(char a, long b) {
	int *u = jpi;
	v0();
	gs.u = ru(gu2 & 1);
}
void rs_2_00_05_6(char a, long b) {
	if (gi3 != 0) gi = gi / gi3;
}
unsigned long rs_2_00_05_7(char a, long b) {
	return gul;
}
void rs_2_00_06_1(char a, unsigned int b, unsigned char c) {
	int t = gi2;
	ji = t;
}
void rs_2_00_06_2(char a, unsigned int b, unsigned char c) {
	int t = ji;
	gc2 = (gca[4] >> 5) & (gca[t] + 'z');
}
void rs_2_00_06_3(char a, unsigned int b, unsigned char c) {
	gula[c] &= gul;
}
void rs_2_00_06_4(char a, unsigned int b, unsigned char c) {
	int i = ji;
	i = 0; while (i < 12) { gca[i] = *gp << 4; i++; }
}
long rs_2_00_06_5(char a, unsigned int b, unsigned char c) {
	return (long)!(gca[7] / 3);
}
void rs_2_00_07_0(unsigned int a, unsigned long b) {
	unsigned long t = b / 3UL;
	jul = t;
}
void rs_2_00_07_1(unsigned int a, unsigned long b) {
	unsigned long t = jul;
	if (!t) { if (*gp != 0) gca[7] = gca[0] % *gp; gps->l &= gla[a] * 0L; if (gu != 0) gua[a] = a % gu; } else { t >>= 14; if (gula[4] != 0) t = gula[6] % gula[4]; vc((char)!gia[0]); }
}
void rs_2_00_07_2(unsigned int a, unsigned long b) {
	gul = 0x10000UL;
}
void rs_2_00_07_3(unsigned int a, unsigned long b) {
	guc -= (unsigned char)!((unsigned long)gua[7]);
}
void rs_2_00_07_4(unsigned int a, unsigned long b) {
	if (!gu) { if (*gp != 0) gc = gca[1] % *gp; gpi = gpi + a; v1((16 < gi2)); }
}
int * rs_2_00_07_5(unsigned int a, unsigned long b) {
	if (gps->l & 0x80) return gpi;
}
int * rs_2_00_07_6(unsigned int a, unsigned long b) {
	return gpi;
}
void rs_2_00_08_0(int a) {
	unsigned int t = 8843 >> 5;
	ju = t;
}
void rs_2_00_08_1(int a) {
	gua[4] = -gua[a];
}
void rs_2_00_08_2(int a) {
	unsigned int t = ju;
	gp = gps->p + t;
}
void rs_2_00_09_1(long a, unsigned int b) {
	unsigned char t = ((unsigned char)gu2) / 4;
	juc = t;
}
void rs_2_00_09_2(long a, unsigned int b) {
	unsigned char t = juc;
	v1(t);
}
void rs_2_00_09_3(long a, unsigned int b) {
	b = (unsigned int)(long)2;
}
void rs_2_00_09_4(long a, unsigned int b) {
	int i = ji;
	v0();
	for (i = 0; i < 16; i++) { if (gc != 0) gc2 = (char)gl / gc; if (gua[4] != 0) gps->u = gua[i] % gua[4]; if (gps->u != 0) b = gu2 / gps->u; }
}
void rs_2_00_10_1(void) {
	int t = gps->a[0] + gi2;
	ji = t;
}
void rs_2_00_10_2(void) {
	vl((long)gul ^ gs.l);
}
void rs_2_00_10_3(void) {
	if (gul != 0) gula[7] = 0x10000UL / gul;
}
void rs_2_00_10_4(void) {
	int t = ji;
	v0();
	gu2 = ru(gua[t]) | 1;
}
void rs_2_00_10_5(void) {
	int i = ji;
	v0();
	for (i = 0; i < 14; i++) { gl2++; if (gu2 != 0) gu2 = gua[i] / gu2; if (gc2 != 0) gc2 = gca[i] % gc2; }
}
int rs_2_00_10_6(void) {
	return -8 ^ ~255;
}
void rs_2_00_11_1(long a, unsigned long b, char c) {
	unsigned char t = guc + guca[2];
	juc = t;
}
void rs_2_00_11_2(long a, unsigned long b, char c) {
	char *u = rp();
	jp = u;
}
void rs_2_00_11_3(long a, unsigned long b, char c) {
	unsigned char t = juc;
	v0();
	gul = gula[t] = (gula[6] | gula[5]) / 7UL;
}
void rs_2_00_11_4(long a, unsigned long b, char c) {
	char *u = jp;
	v0();
	if (gp[1] != 0) c = u[3] / gp[1];
}
void rs_2_00_11_5(long a, unsigned long b, char c) {
	vu(9149 - ((unsigned int)gpi[3]));
}
void rs_2_00_11_6(long a, unsigned long b, char c) {
	int i = ji;
	v0();
	i = 5; do { if (a != 0) gla[7] = gla[i] / a; } while (--i > 0);
}
int rs_2_00_11_7(long a, unsigned long b, char c) {
	return gi;
}
void rs_2_00_12_0(unsigned int a, int b, char *c) {
	guc >>= (a & 7);
}
void rs_2_00_12_1(unsigned int a, int b, char *c) {
	gd = (gd / 10.0) - -gda[3];
}
void rs_2_00_12_2(unsigned int a, int b, char *c) {
	guca[6] = guca[a] - guca[1];
}
unsigned long rs_2_00_12_3(unsigned int a, int b, char *c) {
	return gula[2];
}
void rs_2_00_13_0(char a) {
	char t = gc2;
	jc = t;
}
void rs_2_00_13_1(char a) {
	int u = gi3;
	ji = u;
}
void rs_2_00_13_2(char a) {
	gp = rp();
}
void rs_2_00_13_3(char a) {
	v0();
}
void rs_2_00_13_4(char a) {
	int u = ji;
	v0();
	v1(u);
}
void rs_2_00_13_5(char a) {
	char t = jc;
	v0();
	gc = t;
}
int rs_2_00_13_6(char a) {
	int u = ji;
	v0();
	return (u == 2 ? gi3 : (16 - 255));
}
void rs_2_00_14_1(char *a) {
	unsigned char t = (unsigned char)!gl;
	juc = t;
}
void rs_2_00_14_2(char *a) {
	long u = *gpl;
	jl = u;
}
void rs_2_00_14_3(char *a) {
	a[2] -= gca[5] * 6;
}
void rs_2_00_14_4(char *a) {
	long u = jl;
	vl(u);
}
void rs_2_00_14_5(char *a) {
	gi = gi2;
}
void rs_2_00_14_6(char *a) {
	int i = ji;
	v0();
	i = 12; do { gpi++; if (gula[i] != 0) gul = gul % gula[i]; gc ^= (-94367L != 65536L ? gca[i] : a[i]); } while (--i > 0);
}
void rs_2_00_14_7(char *a) {
	unsigned char t = juc;
	v0();
	gd = (!t ? (gd2 * 2.5) : (0.25 - 2.5));
}
void rs_2_00_14_8(char *a) {
	gps->p = a;
}
int rs_2_00_14_9(char *a) {
	return gia[1];
}
void rs_2_00_15_0(void) {
	if (guc) { gpl[1] = (long)32767; v2(-gi3, gi); if (gi3 != 0) gia[1] = gi % gi3; }
}
void rs_2_00_15_1(void) {
	gs.a[5] = ~gia[0];
}
int rs_2_00_15_2(void) {
	return gia[2];
}
void rs_2_00_16_0(int a, unsigned char b) {
	gc2 = (gp[3] % 2) - (gca[6] >> 7);
}
void rs_2_00_16_1(int a, unsigned char b) {
	gu2 ^= 1;
}
void rs_2_00_16_2(int a, unsigned char b) {
	v0();
}
int rs_2_00_16_3(int a, unsigned char b) {
	if (!gla[1]) return *gpi % 7;
}
void rs_2_00_16_4(int a, unsigned char b) {
	gd2 += gd2 - gd2;
}
int rs_2_00_16_5(int a, unsigned char b) {
	return (int)gua[4];
}
void rs_2_00_17_0(unsigned int a, char b, unsigned char c) {
	gc2 = (char)gul * gc2;
}
void rs_2_00_17_1(unsigned int a, char b, unsigned char c) {
	if (((unsigned long)gu2) < gula[4] && (gula[b] = 2UL) == 29714UL) gl <<= 25;
}
void rs_2_00_18_0(char a, int b) {
	gula[b] ^= gula[b] << 23;
}
void rs_2_00_18_1(char a, int b) {
	++guc;
}
void rs_2_00_18_2(char a, int b) {
	a |= gc;
}
char rs_2_00_18_3(char a, int b) {
	return -(-63 % 3);
}
void rs_2_00_19_0(void) {
	guca[4] <<= 3;
}
void rs_2_00_19_1(void) {
	switch (gi3) { case 0: gl2 |= (long)gu; break; case 1: gl %= 7L; break; }
}
void rs_2_00_19_2(void) {
	--guc;
}
void rs_2_00_19_3(void) {
	while (gi > 0) { gc += *gp++; gi--; }
}
long rs_2_00_19_4(void) {
	return gl;
}
void rs_2_01_00_0(long a, unsigned long b, char c) {
	unsigned char t = ~guc;
	juc = t;
}
void rs_2_01_00_1(long a, unsigned long b, char c) {
	long u = ~gl;
	jl = u;
}
void rs_2_01_00_2(long a, unsigned long b, char c) {
	long u = jl;
	gl = u;
}
void rs_2_01_00_3(long a, unsigned long b, char c) {
	gul = 18764UL;
}
void rs_2_01_00_4(long a, unsigned long b, char c) {
	gi--;
}
void rs_2_01_00_5(long a, unsigned long b, char c) {
	unsigned char t = juc;
	gia[t] = !1;
}
void rs_2_01_00_6(long a, unsigned long b, char c) {
	gp = &gca[1];
}
void rs_2_01_00_7(long a, unsigned long b, char c) {
	while (gi-- > 0) *gpi++ = 100;
}
void rs_2_01_01_1(unsigned int a) {
	int t = -gi2;
	ji = t;
}
void rs_2_01_01_2(unsigned int a) {
	gps->u = a - gu2;
}
void rs_2_01_01_3(unsigned int a) {
	int i = ji;
	int t = ji;
	for (i = 6; i > 0; i--) { vl((long)('A' == (char)t)); }
}
void rs_2_01_01_4(unsigned int a) {
	int t = ji;
	v0();
	if (gla[t]) vc(gc);
}
void rs_2_01_01_5(unsigned int a) {
	vc(gca[6]);
}
int rs_2_01_01_6(unsigned int a) {
	int t = ji;
	v0();
	return (gl ? 8 : t) - (t >> 4);
}
void rs_2_01_02_0(char *a, double b) {
	unsigned int t = gu;
	ju = t;
}
void rs_2_01_02_1(char *a, double b) {
	int *u = gpi;
	jpi = u;
}
void rs_2_01_02_2(char *a, double b) {
	unsigned int t = ju;
	int *u = jpi;
	if (r0()) { u++; vu(gs.u ^ 1); } else { gul = rul((!*a ? gul : gula[t])); gps->a[6] += gia[t] & gia[1]; if (gpl[2] != 0) gs.l = 65536L / gpl[2]; }
}
void rs_2_01_02_3(char *a, double b) {
	gc2 <<= 1;
}
void rs_2_01_02_4(char *a, double b) {
	gpi = &gia[6];
}
void rs_2_01_02_5(char *a, double b) {
	unsigned int t = ju;
	v0();
	if (gula[5] < 6UL || gl <= gpl[0]) if (t != 0) gua[t] = gu2 % t;
}
int * rs_2_01_02_6(char *a, double b) {
	int *u = jpi;
	v0();
	return u;
}
void rs_2_01_03_1(unsigned char a, char b) {
	char *t = rp();
	jp = t;
}
void rs_2_01_03_2(unsigned char a, char b) {
	unsigned long u = rul(gula[a]);
	v0();
	jul = u;
}
void rs_2_01_03_3(unsigned char a, char b) {
	unsigned long u = jul;
	v0();
	guca[b] = (unsigned char)!(0UL | u);
}
void rs_2_01_03_4(unsigned char a, char b) {
	char *t = jp;
	v0();
	switch (gu2) { case 0: v1(256); break; case 1: case 2: guc = a = (unsigned char)(gla[7] == gl); case 3: gpl[2] %= 10L; break; case 4: t[2] = gs.c + t[3]; break; }
}
void rs_2_01_03_5(unsigned char a, char b) {
	char *t = jp;
	v0();
	t--;
}
void rs_2_01_03_6(unsigned char a, char b) {
	int i = ji;
	v0();
	for (i = 0; i < 13; i++) { gula[i] <<= (b & 15); v2(gi2, gps->i << 1); }
}
int rs_2_01_03_7(unsigned char a, char b) {
	return -127;
}
void rs_2_01_04_0(int a, long *b) {
	int t = a | 1;
	ji = t;
}
void rs_2_01_04_1(int a, long *b) {
	int u = gs.i - gps->a[1];
	ji = u;
}
void rs_2_01_04_2(int a, long *b) {
	int u = ji;
	v1(u);
}
void rs_2_01_04_3(int a, long *b) {
	gul = rul(gula[0] / 7UL);
}
void rs_2_01_04_4(int a, long *b) {
	int t = ji;
	v0();
	guca[6] = (unsigned char)(gula[t] < 1UL ? gul : gul);
}
void rs_2_01_04_5(int a, long *b) {
	guc++;
}
char * rs_2_01_04_6(int a, long *b) {
	return gps->p;
}
void rs_2_01_05_0(long a) {
	gl = gla[7] * 6L;
}
void rs_2_01_05_1(long a) {
	if (gs.c & 4) { gu2 = ~gua[5] + gua[1]; gps->l = -(~a); } else { guc /= 16; gu = 32767; }
}
int rs_2_01_05_2(long a) {
	return gia[7] & (gl >= (long)gp[0]);
}
void rs_2_01_06_0(int a, int *b) {
	gpl[2] = gl2;
}
void rs_2_01_06_1(int a, int *b) {
	if (a != 0) gps->i = gps->a[a] % a;
}
int rs_2_01_06_2(int a, int *b) {
	if (gula[a] > 0x10000UL) return gi3;
}
int rs_2_01_06_3(int a, int *b) {
	return (gps->a[a] = gps->i);
}
void rs_2_01_07_0(int a, int *b, unsigned long c) {
	int *t = rpi(b[4]);
	jpi = t;
}
void rs_2_01_07_1(int a, int *b, unsigned long c) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_2_01_07_2(int a, int *b, unsigned long c) {
	gd2 = 100.0;
}
void rs_2_01_07_3(int a, int *b, unsigned long c) {
	gp[0] -= 'A';
}
void rs_2_01_07_4(int a, int *b, unsigned long c) {
	gp = &gca[a];
}
void rs_2_01_07_5(int a, int *b, unsigned long c) {
	gd = (gia[6] < 8 ? (gul <= gula[a] ? 1.0 : gd) : -(double)*gpi);
}
int rs_2_01_07_6(int a, int *b, unsigned long c) {
	return gi2;
}
void rs_2_01_08_1(int *a) {
	gu2 = 25813;
}
void rs_2_01_08_2(int *a) {
	int i = ji;
	i = 0; while (i < 14) { gs.p = gps->p; vc(-7); if (gu2 != 0) gs.u = gu / gu2; i++; }
}
void rs_2_01_08_3(int *a) {
	*a = a[1];
}
void rs_2_01_08_4(int *a) {
	if ((gc = 0) < 5 || r2(gi2, (int)gs.l)) { gua[0] = gps->u = (100.0 <= gda[2] ? gu2 : 1) << 3; if (gps->l != 0) gl2 = gl2 % gps->l; gp = gs.p; }
}
int rs_2_01_08_5(int *a) {
	return (gs.a[4] = a[1]);
}
void rs_2_01_09_0(unsigned int a, unsigned char b, unsigned long c) {
	gula[4] <<= 3;
}
void rs_2_01_09_1(unsigned int a, unsigned char b, unsigned long c) {
	gi >>= 4;
}
void rs_2_01_09_2(unsigned int a, unsigned char b, unsigned long c) {
	gu2 = (unsigned int)gc2;
}
void rs_2_01_09_3(unsigned int a, unsigned char b, unsigned long c) {
	v2(8 & gpi[3], gi);
}
long rs_2_01_09_4(unsigned int a, unsigned char b, unsigned long c) {
	return (long)(~gl2 < gl);
}
void rs_2_01_10_0(int a) {
	char t = gc ^ gc2;
	jc = t;
}
void rs_2_01_10_1(int a) {
	gul = gula[2];
}
void rs_2_01_10_2(int a) {
	char t = jc;
	gua[t] ^= gu2 * 12;
}
void rs_2_01_10_3(int a) {
	char t = jc;
	gpl[1] = gl2 = (long)((guca[t] | ((unsigned char)gps->c)) < (1 + guc));
}
void rs_2_01_10_4(int a) {
	char t = jc;
	t <<= 7;
}
int rs_2_01_10_5(int a) {
	return 2;
}
void rs_2_01_11_0(unsigned int a) {
	int *t = gpi;
	jpi = t;
}
void rs_2_01_11_1(unsigned int a) {
	gi3++;
}
void rs_2_01_11_2(unsigned int a) {
	++gi;
}
void rs_2_01_11_3(unsigned int a) {
	gc = ((' ') % 16) & (*gp & gc);
}
void rs_2_01_11_4(unsigned int a) {
	vc((char)255);
}
void rs_2_01_11_5(unsigned int a) {
	int *t = jpi;
	v0();
	v1(*t);
}
char rs_2_01_11_6(unsigned int a) {
	return (29553 > gua[a] || (gps->u = gu) >= 256 ? gs.c : (gc2 + gp[1]));
}
void rs_2_01_12_0(void) {
	int t = gia[5] | gps->i;
	ji = t;
}
void rs_2_01_12_1(void) {
	int t = ji;
	gp = gps->p + t;
}
void rs_2_01_12_2(void) {
	++gp;
}
char * rs_2_01_12_3(void) {
	return &gca[5];
}
void rs_2_01_13_1(void) {
	char t = 9;
	jc = t;
}
void rs_2_01_13_2(void) {
	char u = -92 - gc;
	jc = u;
}
void rs_2_01_13_3(void) {
	int i = ji;
	for (i = 0; i < 16; i++) { gpl[0] &= gl2; gps->p = rp(); if (gpl[2] != 0) gl = (long)gs.c % gpl[2]; }
}
void rs_2_01_13_4(void) {
	vd(gda[1] * gd);
}
void rs_2_01_13_5(void) {
	char u = jc;
	v0();
	vc(u);
}
void rs_2_01_13_6(void) {
	char t = jc;
	v0();
	vc(t);
}
int rs_2_01_13_7(void) {
	return gi3;
}
void rs_2_01_14_0(char a, unsigned long b, unsigned long c) {
	long t = (long)a;
	jl = t;
}
void rs_2_01_14_1(char a, unsigned long b, unsigned long c) {
	long t = jl;
	vl(t);
}
void rs_2_01_14_2(char a, unsigned long b, unsigned long c) {
	gc2 = (gps->c % 4) >> 6;
}
void rs_2_01_14_3(char a, unsigned long b, unsigned long c) {
	vu(ru(255));
}
void rs_2_01_14_4(char a, unsigned long b, unsigned long c) {
	guc = (guca[4] ^ guca[2]) - ((unsigned char)!6);
}
unsigned int rs_2_01_14_5(char a, unsigned long b, unsigned long c) {
	return ((unsigned int)!gps->u) * 3;
}
void rs_2_01_15_0(unsigned int a) {
	if (gl != 0) gpl[3] = gl2 / gl;
}
void rs_2_01_15_1(unsigned int a) {
	vc(gc2 - gca[2]);
}
unsigned long rs_2_01_15_2(unsigned int a) {
	return gul;
}
void rs_2_01_16_0(int a) {
	vl((long)gula[a] - gpl[3]);
}
void rs_2_01_16_1(int a) {
	gul += gula[a] * 7UL;
}
void rs_2_01_16_2(int a) {
	if (gps->l) { vd((double)gl); } else { ++gul; gua[3] >>= 2; if (gl2 != 0) gl = gla[a] / gl2; }
}
int rs_2_01_16_3(int a) {
	return (~2270UL > (gul + 86638UL));
}
void rs_2_01_17_0(void) {
	guca[6] = 128;
}
void rs_2_01_17_1(void) {
	gs.l = gl = gl2 ^ -gpl[1];
}
char rs_2_01_17_2(void) {
	return ~gc2 & (*gp * -90);
}
void rs_2_01_18_0(unsigned long a, long b) {
	switch (gl2) { case 0L: guc = guca[5] ^ guca[7]; break; case 1L: guca[7] = guc = ~guca[4]; break; case 2L: gu2 += gu; break; case 3L: gu -= gu2; break; case 4L: case 5L: vu(gua[4]); break; }
}
void rs_2_01_18_1(unsigned long a, long b) {
	gpi = &gia[3];
}
void rs_2_01_18_2(unsigned long a, long b) {
	--gpi;
}
void rs_2_01_19_0(void) {
	double t = gda[0] * gda[3];
	jd = t;
}
void rs_2_01_19_1(void) {
	vp(gp);
}
void rs_2_01_19_2(void) {
	double t = jd;
	v0();
	gd = t;
}
void rs_2_01_19_3(void) {
	gula[4] -= gula[5];
}
int rs_2_01_19_4(void) {
	return (16 - gi2) % 3;
}
void rs_2_02_00_1(void) {
	gula[2] <<= 3;
}
void rs_2_02_00_2(void) {
	gul = gula[4] = 0UL;
}
void rs_2_02_00_3(void) {
	if ((gps->u = ((unsigned int)gula[3])) >= 255) gul = (unsigned long)guc;
}
void rs_2_02_00_4(void) {
	if (guc) { gp = &gca[5]; gua[3] += 5990 >> 5; gca[5] = -'9'; }
}
void rs_2_02_00_5(void) {
	int i = ji;
	i = 15; do { guca[i] = (unsigned char)gs.c; guca[i] += guc << 3; } while (--i > 0);
}
int * rs_2_02_00_6(void) {
	return gpi;
}
void rs_2_02_01_0(int a) {
	if (gi3 <= 127) gula[a] = rul(gula[a]);
}
void rs_2_02_01_1(int a) {
	gc--;
}
void rs_2_02_01_2(int a) {
	v2(gi2, !guca[3]);
}
int rs_2_02_01_3(int a) {
	return gpi[0] * 8;
}
void rs_2_02_02_0(unsigned int a, unsigned char b, long *c) {
	int t = 2;
	ji = t;
}
void rs_2_02_02_1(unsigned int a, unsigned char b, long *c) {
	char *u = gs.p;
	jp = u;
}
void rs_2_02_02_2(unsigned int a, unsigned char b, long *c) {
	gula[0] /= 3UL;
}
void rs_2_02_02_3(unsigned int a, unsigned char b, long *c) {
	int t = ji;
	char *u = jp;
	if (gl) { t = t * 3; ++gl; if (gc != 0) u[1] = gs.c % gc; }
}
void rs_2_02_02_4(unsigned int a, unsigned char b, long *c) {
	gc2--;
}
int rs_2_02_02_5(unsigned int a, unsigned char b, long *c) {
	return (gs.i = gps->i);
}
void rs_2_02_03_0(unsigned char a) {
	if (gi != 0) gps->i = gpi[3] % gi;
}
void rs_2_02_03_1(unsigned char a) {
	gc2 = rc(gps->a[3]);
}
void rs_2_02_03_2(unsigned char a) {
	vl(-65536L);
}
void rs_2_02_03_3(unsigned char a) {
	++a;
}
int rs_2_02_03_4(unsigned char a) {
	return gi3 + ((int)gpl[3] % 16);
}
unsigned long rs_2_02_04_0(int a, int b, int c) {
	if (r0()) return gul >> 10;
}
void rs_2_02_04_1(int a, int b, int c) {
	guc -= guc + guca[6];
}
void rs_2_02_04_2(int a, int b, int c) {
	switch (gps->i) { case 0: gd2 -= gda[1]; break; case 1: gi2 ^= b; break; default: gca[b] = *gp = *gp ^ gca[c]; break; }
}
unsigned long rs_2_02_04_3(int a, int b, int c) {
	return gula[2] ^ (gula[a] / 4UL);
}
void rs_2_02_05_0(char a, long *b, int *c) {
	char *t = gs.p + a;
	jp = t;
}
void rs_2_02_05_1(char a, long *b, int *c) {
	v2(gia[a], gi);
}
void rs_2_02_05_2(char a, long *b, int *c) {
	vu(gu ^ gps->u);
}
void rs_2_02_05_3(char a, long *b, int *c) {
	char *t = jp;
	v0();
	*t = t[2] << 7;
}
int rs_2_02_05_4(char a, long *b, int *c) {
	return (gpi[1] + (int)gua[5]) ^ (gi / 100);
}
void rs_2_02_06_0(void) {
	gps->u -= gu;
}
void rs_2_02_06_1(void) {
	guc = guc >> 1;
}
int rs_2_02_06_2(void) {
	return ((int)gc2 & gi) >> 3;
}
void rs_2_02_07_0(unsigned long a, int b, double c) {
	gul = rul(rul(gula[2]));
}
long rs_2_02_07_1(unsigned long a, int b, double c) {
	if (gula[b] != 0x10000UL || *gp >= 'A') return gps->l;
}
void rs_2_02_07_2(unsigned long a, int b, double c) {
	gpi = &gia[0];
}
long rs_2_02_07_3(unsigned long a, int b, double c) {
	return gl;
}
void rs_2_02_08_0(long *a, unsigned char b, char c) {
	double t = 2.5 * gs.d;
	jd = t;
}
void rs_2_02_08_1(long *a, unsigned char b, char c) {
	double t = jd;
	if (gu2) { gd2 *= (r2(1, gi) ? t : 0.5); --gpi; if (gu2 != 0) gs.u = 255 / gu2; }
}
void rs_2_02_08_2(long *a, unsigned char b, char c) {
	if (gs.d >= gd2 && *gpl) gul = gula[0] = (gul + gula[3]) + ((unsigned long)gl);
}
unsigned int rs_2_02_08_3(long *a, unsigned char b, char c) {
	if (gca[b] != *gp) return gs.u - gu2;
}
void rs_2_02_08_4(long *a, unsigned char b, char c) {
	if (gca[c] != 0) c = gca[6] % gca[c];
}
unsigned int rs_2_02_08_5(long *a, unsigned char b, char c) {
	return 256;
}
void rs_2_02_09_0(int a, long b, int c) {
	int t = gi3 + c;
	ji = t;
}
void rs_2_02_09_1(int a, long b, int c) {
	unsigned int u = ~gu;
	ju = u;
}
void rs_2_02_09_2(int a, long b, int c) {
	v2(gi2, gia[4] / 2);
}
void rs_2_02_09_3(int a, long b, int c) {
	gul += (unsigned long)gu2;
}
void rs_2_02_09_4(int a, long b, int c) {
	unsigned int u = ju;
	v0();
	u /= 16;
}
void rs_2_02_09_5(int a, long b, int c) {
	while (a-- > 0) *gpi++ = 100;
}
void rs_2_02_09_6(int a, long b, int c) {
	int t = ji;
	unsigned int u = ju;
	v0();
	gi2 = !u - r2(t, gi);
}
int * rs_2_02_09_7(int a, long b, int c) {
	return gpi;
}
void rs_2_02_10_0(double a, int b) {
	int *t = gpi + b;
	jpi = t;
}
void rs_2_02_10_1(double a, int b) {
	int *t = jpi;
	v1(*t);
}
void rs_2_02_10_2(double a, int b) {
	if (gua[b] != 0) gu2 = 255 / gua[b];
}
void rs_2_02_10_3(double a, int b) {
	if (a < gd2) if (gpl[3] != 0) gl = gps->l / gpl[3];
}
void rs_2_02_10_4(double a, int b) {
	gps->c *= 7;
}
int rs_2_02_10_5(double a, int b) {
	return gs.a[b] - (16 << (b & 15));
}
void rs_2_02_11_0(int a, struct st *b) {
	unsigned long t = (unsigned long)!guc;
	jul = t;
}
void rs_2_02_11_1(int a, struct st *b) {
	double u = (double)gia[2];
	jd = u;
}
void rs_2_02_11_2(int a, struct st *b) {
	unsigned long t = jul;
	t = gula[a] / 4UL;
}
void rs_2_02_11_3(int a, struct st *b) {
	unsigned long t = jul;
	if (gu & 0x80) gi3 = ((gul + t) < -gul);
}
void rs_2_02_11_4(int a, struct st *b) {
	vu((gs.a[4] != 256 ? gua[1] : gu2));
}
void rs_2_02_11_5(int a, struct st *b) {
	double u = jd;
	v0();
	gps->u = 32767;
}
unsigned long rs_2_02_11_6(int a, struct st *b) {
	return (unsigned long)!gc2;
}
void rs_2_02_12_1(void) {
	char *t = gps->p;
	jp = t;
}
void rs_2_02_12_2(void) {
	vl(65536L);
}
void rs_2_02_12_3(void) {
	int i = ji;
	v0();
	i = 12; do { gps->u = gu2 ^ gps->u; v2(gi2, (i != (int)gu2 ? gia[i] : 100)); gd += (gu2 == 32767 ? gda[2] : gda[1]); } while (--i > 0);
}
void rs_2_02_12_4(void) {
	char *t = jp;
	v0();
	if (128 == guc) t[1] = (char)gla[2] >> 5;
}
unsigned int rs_2_02_12_5(void) {
	return 256;
}
void rs_2_02_13_0(void) {
	unsigned int t = (unsigned int)!gula[3];
	ju = t;
}
void rs_2_02_13_1(void) {
	unsigned char u = 75 * guc;
	juc = u;
}
void rs_2_02_13_2(void) {
	unsigned int t = ju;
	gp = gs.p + t;
}
void rs_2_02_13_3(void) {
	unsigned char u = juc;
	if (gpi[2] != 0) gs.a[u] = gpi[2] % gpi[2];
}
void rs_2_02_13_4(void) {
	unsigned char u = juc;
	guc = guca[0] = u;
}
void rs_2_02_13_5(void) {
	gs.l = rl(*gpl);
}
void rs_2_02_13_6(void) {
	unsigned char u = juc;
	v0();
	gs.u = gua[4];
}
unsigned int rs_2_02_13_7(void) {
	unsigned int t = ju;
	v0();
	return ru(gu2) + t;
}
void rs_2_02_14_0(unsigned char a, int *b) {
	unsigned long t = (unsigned long)(1 >= gps->c);
	jul = t;
}
void rs_2_02_14_1(unsigned char a, int *b) {
	gi2 = gi = !(~gla[5]);
}
void rs_2_02_14_2(unsigned char a, int *b) {
	unsigned long t = jul;
	gul = t;
}
void rs_2_02_14_3(unsigned char a, int *b) {
	gul <<= 16;
}
void rs_2_02_14_4(unsigned char a, int *b) {
	if (*gpl != gpl[3]) { a %= 10; vc(gca[a] + gc2); v2(127, gi); }
}
unsigned long rs_2_02_14_5(unsigned char a, int *b) {
	return (unsigned long)(gc2 + 5);
}
void rs_2_02_15_0(int a, int b) {
	char t = 42;
	jc = t;
}
void rs_2_02_15_1(int a, int b) {
	double u = (gul & 2 ? gd : gd);
	jd = u;
}
void rs_2_02_15_2(int a, int b) {
	v2(gi2, 904);
}
void rs_2_02_15_3(int a, int b) {
	double u = jd;
	v0();
	if (((unsigned int)*gpl) == gs.u) if (gul != 0) gul = gul % gul;
}
int rs_2_02_15_4(int a, int b) {
	if ((gu2 = 1) == 1) return a + *gpi;
}
void rs_2_02_15_5(int a, int b) {
	char t = jc;
	v0();
	vc(t);
}
void rs_2_02_15_6(int a, int b) {
	gula[b] %= 2UL;
}
int rs_2_02_15_7(int a, int b) {
	return (gula[1] == gul) & b;
}
void rs_2_02_16_0(void) {
	switch (gc2) { case 2: vl(gs.l); case 16: gu += gua[6]; break; case 20: gula[1] = -gula[1]; break; case 100: guca[0] *= 4; break; }
}
void rs_2_02_16_1(void) {
	vp(gp + 1);
}
void rs_2_02_16_2(void) {
	if (gi3 != 255 || gl2 >= gla[2]) { --gl2; } else { gu *= 2; gi3 -= gia[0] & gi3; --gul; }
}
void rs_2_02_16_3(void) {
	gda[0] *= (gul < 0x10000UL ? gd2 : gda[2]);
}
void rs_2_02_16_4(void) {
	if (r0()) { guca[4] <<= 2; if (gi != 0) *gpi = gi2 / gi; }
}
int rs_2_02_16_5(void) {
	return *gpi;
}
void rs_2_02_17_0(int a, char b) {
	if (guca[a] < 128 && !gc) { gula[5] = gul; if (gu != 0) gua[a] = 256 / gu; gul = gul % 10UL; }
}
void rs_2_02_17_1(int a, char b) {
	gl2 &= *gpl & gl;
}
int rs_2_02_17_2(int a, char b) {
	if (gul < 4UL) return gps->i * gi2;
}
int rs_2_02_17_3(int a, char b) {
	return ((gca[a] & gc2) <= gp[0]);
}
void rs_2_02_18_1(unsigned char a, unsigned char b, unsigned int c) {
	--c;
}
void rs_2_02_18_2(unsigned char a, unsigned char b, unsigned int c) {
	v0();
}
void rs_2_02_18_3(unsigned char a, unsigned char b, unsigned int c) {
	int i = ji;
	v0();
	i = 0; while (i < 14) { gc2 += gps->c; gs.u = c = -gs.u ^ (*gp == '9' ? c : gua[i]); i++; }
}
void rs_2_02_19_0(void) {
	int *t = &gia[3];
	jpi = t;
}
void rs_2_02_19_1(void) {
	int u = !gi2;
	ji = u;
}
void rs_2_02_19_2(void) {
	gc2 = *gp;
}
void rs_2_02_19_3(void) {
	int *t = jpi;
	gpi = t;
}
void rs_2_02_19_4(void) {
	int u = ji;
	guc = (guca[u] / 7) * (128 >> 5);
}
void rs_2_02_19_5(void) {
	if (gua[1] != 0) gua[1] = gua[2] % gua[1];
}
void rs_2_02_19_6(void) {
	int u = ji;
	gp = &gca[u];
}
char rs_2_02_19_7(void) {
	int u = ji;
	return rc(u) % 7;
}
void rs_2_03_00_0(char a, unsigned int b) {
	double t = gd;
	jd = t;
}
void rs_2_03_00_1(char a, unsigned int b) {
	gia[0] = gi - gps->i;
}
void rs_2_03_00_2(char a, unsigned int b) {
	double t = jd;
	vd(t);
}
void rs_2_03_00_3(char a, unsigned int b) {
	--gul;
}
void rs_2_03_00_4(char a, unsigned int b) {
	gs.a[2] <<= (a & 15);
}
void rs_2_03_00_5(char a, unsigned int b) {
	gs.d += gd;
}
int rs_2_03_00_6(char a, unsigned int b) {
	return gps->a[2] & (guc != 4);
}
void rs_2_03_01_0(int a, int b) {
	int t = gs.a[b];
	ji = t;
}
void rs_2_03_01_1(int a, int b) {
	gps->l = (long)!*gp;
}
void rs_2_03_01_2(int a, int b) {
	gu = ((unsigned int)!guca[3]) - ru(gua[3]);
}
void rs_2_03_01_3(int a, int b) {
	int t = ji;
	v0();
	v1(t);
}
int * rs_2_03_01_4(int a, int b) {
	return &gia[b];
}
void rs_2_03_02_1(char *a, long *b) {
	unsigned char t = -128;
	juc = t;
}
void rs_2_03_02_2(char *a, long *b) {
	int i = ji;
	for (i = 0; i < 16; i++) { gul = rul(gula[i]); if (gi3 != 0) gs.a[i] = gs.i % gi3; }
}
void rs_2_03_02_3(char *a, long *b) {
	int i = ji;
	unsigned char t = juc;
	v0();
	switch (gps->i) { case 3: gula[0] += gula[t]; break; case 8: gu2 = gu | gps->u; case 16: guc = t = 5; case 100: case 200: v0(); break; default: gu = (unsigned int)((unsigned long)t); break; }
}
void rs_2_03_02_4(char *a, long *b) {
	if (gu > gps->u) { if (gpl[2] != 0) gl2 = gl2 / gpl[2]; gpi = rpi(gi3 + gi); ++gpi; }
}
void rs_2_03_02_5(char *a, long *b) {
	unsigned char t = juc;
	v0();
	if (gi & 2) { gula[t] |= (unsigned long)gu; gi3--; guca[1] = 128 + t; } else { if (gca[2] != 0) gc = (char)gla[t] % gca[2]; gp--; gpi = gpi + t; }
}
void rs_2_03_02_6(char *a, long *b) {
	unsigned char t = juc;
	v0();
	a = gp + t;
}
unsigned long rs_2_03_02_7(char *a, long *b) {
	return (69782UL & gul) - gul;
}
void rs_2_03_03_1(unsigned char a, int b, int c) {
	if (gca[c] != gca[0]) { guca[5] /= 2; vu(-gua[4]); gl2 /= 16L; } else { guca[a] = (unsigned char)gc; gl /= 7L; if (gul != 0) gula[c] = gul / gul; }
}
void rs_2_03_03_2(unsigned char a, int b, int c) {
	vl(rl(65536L));
}
void rs_2_03_03_3(unsigned char a, int b, int c) {
	*gpl = gs.l;
}
void rs_2_03_03_4(unsigned char a, int b, int c) {
	int i = ji;
	v0();
	i = 0; while (i < 11) { gul = (unsigned long)a; i++; }
}
char rs_2_03_03_5(unsigned char a, int b, int c) {
	return gc;
}
void rs_2_03_04_1(long a, double b) {
	long t = (long)!gu2;
	jl = t;
}
void rs_2_03_04_2(long a, double b) {
	unsigned char u = guc >> 7;
	juc = u;
}
void rs_2_03_04_3(long a, double b) {
	gs.c = (char)gul;
}
void rs_2_03_04_4(long a, double b) {
	long t = jl;
	gl = t;
}
void rs_2_03_04_5(long a, double b) {
	unsigned char u = juc;
	u -= guca[u];
}
void rs_2_03_04_6(long a, double b) {
	unsigned char u = juc;
	guc += u + 128;
}
void rs_2_03_04_7(long a, double b) {
	int i = ji;
	for (i = 0; i < 16; i++) { vl(*gpl); gc2 *= 9; }
}
void rs_2_03_05_0(char a, char *b) {
	while (gi-- > 0) { if (*b == 24) break; b++; }
}
void rs_2_03_05_1(char a, char *b) {
	gd -= gd - gda[0];
}
void rs_2_03_05_2(char a, char *b) {
	gd = (gda[1] / 10.0) + (guc <= 128 ? gd : 0.5);
}
int rs_2_03_05_3(char a, char *b) {
	return (gi3 ^ gi2) - (gs.a[3] << 9);
}
void rs_2_03_06_0(unsigned long a, int b) {
	int t = gi3 >> 14;
	ji = t;
}
void rs_2_03_06_1(unsigned long a, int b) {
	int t = ji;
	*gpl ^= 6L & gla[t];
}
void rs_2_03_06_2(unsigned long a, int b) {
	a++;
}
unsigned long rs_2_03_06_3(unsigned long a, int b) {
	return (a = gul);
}
void rs_2_03_07_0(void) {
	switch (gl2) { case 1L: case 3L: vp(&gca[6]); break; case 8L: case 10L: gi = gs.a[6]; break; case 200L: gs.a[5] *= 7; break; }
}
void rs_2_03_07_1(void) {
	while (gi-- > 0) *gpi++ = 127;
}
void rs_2_03_07_2(void) {
	vs(gps);
}
void rs_2_03_07_3(void) {
	gul = gula[7];
}
int rs_2_03_07_4(void) {
	return gs.a[0];
}
void rs_2_03_08_0(void) {
	unsigned int t = gps->u + 1;
	ju = t;
}
void rs_2_03_08_1(void) {
	unsigned int t = ju;
	switch (gi) { case 0: gul += 0x10000UL; break; case 1: gd += gda[2]; break; case 2: case 3: gl = (long)!guca[t]; break; case 4: gia[6] /= 3; break; case 5: guca[t] = guca[5]; break; default: gs.a[t] = r2(gi, gi); break; }
}
void rs_2_03_08_2(void) {
	if (gul < 9UL) gs.u &= gu - gu2;
}
void rs_2_03_08_3(void) {
	gp--;
}
unsigned long rs_2_03_08_4(void) {
	return 5UL;
}
void rs_2_03_09_1(unsigned int a, double b) {
	char t = rc(2);
	jc = t;
}
void rs_2_03_09_2(unsigned int a, double b) {
	char *u = gp;
	v0();
	jp = u;
}
void rs_2_03_09_3(unsigned int a, double b) {
	char t = jc;
	v0();
	gc = t;
}
void rs_2_03_09_4(unsigned int a, double b) {
	char *u = jp;
	v0();
	gp = u;
}
void rs_2_03_09_5(unsigned int a, double b) {
	int i = ji;
	v0();
	for (i = 16; i > 0; i--) { vd(b / 1.0); if (i != 0) gi = (int)gca[i] / i; }
}
void rs_2_03_09_6(unsigned int a, double b) {
	gi3++;
}
unsigned int rs_2_03_09_7(unsigned int a, double b) {
	return (gu2 - 1) & ((unsigned int)guca[5]);
}
void rs_2_03_10_1(char *a) {
	gc--;
}
void rs_2_03_10_2(char *a) {
	int i = ji;
	for (i = 0; i < 16; i++) { if (gpl[3] != 0) gpl[0] = gl % gpl[3]; }
}
int * rs_2_03_10_3(char *a) {
	return gpi;
}
void rs_2_03_11_0(int a, long b, long c) {
	char t = gc2;
	jc = t;
}
void rs_2_03_11_1(int a, long b, long c) {
	int *u = gpi;
	jpi = u;
}
void rs_2_03_11_2(int a, long b, long c) {
	++gc2;
}
void rs_2_03_11_3(int a, long b, long c) {
	char t = jc;
	t ^= gc2;
}
void rs_2_03_11_4(int a, long b, long c) {
	char t = jc;
	gula[t] = (unsigned long)(gd > (double)gc2);
}
void rs_2_03_11_5(int a, long b, long c) {
	char t = jc;
	int *u = jpi;
	gs.u = ~(!t ? gua[5] : gu2);
}
unsigned int rs_2_03_11_6(int a, long b, long c) {
	int *u = jpi;
	return gs.u;
}
void rs_2_03_12_0(char a) {
	gd2 *= -gda[0];
}
void rs_2_03_12_1(char a) {
	vu(gu);
}
void rs_2_03_12_2(char a) {
	if (gps->u) v2(gia[a], gi);
}
void rs_2_03_12_3(char a) {
	gia[2] = 255 * gi3;
}
void rs_2_03_12_4(char a) {
	++gc2;
}
unsigned long rs_2_03_12_5(char a) {
	return (gula[a] = gula[1]);
}
void rs_2_03_13_0(unsigned int a, char b) {
	guca[0] = guc = (guc * guc) + (guc | 128);
}
void rs_2_03_13_1(unsigned int a, char b) {
	gps->l = gpl[1] & 65536L;
}
void rs_2_03_13_2(unsigned int a, char b) {
	v2(gi, gi);
}
void rs_2_03_13_3(unsigned int a, char b) {
	gi %= 7;
}
void rs_2_03_13_4(unsigned int a, char b) {
	gl &= gla[2] | 6L;
}
int rs_2_03_13_5(unsigned int a, char b) {
	return 2;
}
void rs_2_03_14_1(void) {
	double t = gs.d + 10.0;
	jd = t;
}
void rs_2_03_14_2(void) {
	int u = 255 - gi;
	ji = u;
}
void rs_2_03_14_3(void) {
	int u = ji;
	switch (gs.u) { case 1: gla[u] *= 12L; break; case 100: gps->a[u] >>= 15; break; default: gs.a[u] = gps->a[2] | gpi[0]; break; }
}
void rs_2_03_14_4(void) {
	++gi2;
}
void rs_2_03_14_5(void) {
	int i = ji;
	for (i = 0; i < 3; i++) { gi = (gu != 1 ? *gpi : (gl == gpl[2] ? 100 : i)); gps->p = gs.p; vl(gl2 ^ gla[i]); }
}
void rs_2_03_14_6(void) {
	guca[6] = guc;
}
void rs_2_03_14_7(void) {
	double t = jd;
	v0();
	vd(t);
}
unsigned long rs_2_03_14_8(void) {
	int u = ji;
	v0();
	return gula[u];
}
void rs_2_03_15_0(struct st *a, long b) {
	a->c <<= 1;
}
void rs_2_03_15_1(struct st *a, long b) {
	a->p = gs.p;
}
void rs_2_03_15_2(struct st *a, long b) {
	gpl[0] = gl;
}
void rs_2_03_16_0(unsigned int a) {
	double t = gs.d - gda[3];
	jd = t;
}
void rs_2_03_16_1(unsigned int a) {
	int u = (gla[6] > -40543L ? gia[4] : 2);
	ji = u;
}
void rs_2_03_16_2(unsigned int a) {
	vs(gps);
}
void rs_2_03_16_3(unsigned int a) {
	gps->l -= *gpl << 20;
}
void rs_2_03_16_4(unsigned int a) {
	int u = ji;
	v0();
	gi = u;
}
void rs_2_03_16_5(unsigned int a) {
	double t = jd;
	v0();
	vd(t);
}
unsigned long rs_2_03_16_6(unsigned int a) {
	return (unsigned long)(a - 255);
}
void rs_2_03_17_1(struct st *a, char b, unsigned char c) {
	int i = ji;
	i = 0; while (i < 9) { gi = 4; gl2 = (c ? gl2 : gla[i]); if (a->c != 0) gca[i] = (char)i % a->c; i++; }
}
void rs_2_03_17_2(struct st *a, char b, unsigned char c) {
	gula[0] = (gula[5] ? gul : gula[3]);
}
void rs_2_03_17_3(struct st *a, char b, unsigned char c) {
	if (c) { guca[4] = guca[b] << 6; v0(); if (gps->c != 0) *gp = gp[2] / gps->c; }
}
void rs_2_03_17_4(struct st *a, char b, unsigned char c) {
	int i = ji;
	v0();
	for (i = 0; i < 3; i++) { gca[i] = b = ((char)gps->l >> 7) * gp[2]; gula[i] = (unsigned long)!gu; }
}
char rs_2_03_17_5(struct st *a, char b, unsigned char c) {
	return gca[c];
}
void rs_2_03_18_1(long a) {
	gu++;
}
void rs_2_03_18_2(long a) {
	gu2++;
}
void rs_2_03_18_3(long a) {
	int i = ji;
	i = 0; while (i < 7) { gpi = &gia[i]; guca[1] = guca[i] + 7; v0(); i++; }
}
int rs_2_03_18_4(long a) {
	return (255 / 2) ^ (gia[5] >> 8);
}
void rs_2_03_19_0(long a, unsigned char b) {
	int *t = gpi + b;
	jpi = t;
}
void rs_2_03_19_1(long a, unsigned char b) {
	int *t = jpi;
	v1(*t);
}
void rs_2_03_19_2(long a, unsigned char b) {
	guc = (unsigned char)((gl + gla[5]) == rl(gpl[0]));
}
void rs_2_03_19_3(long a, unsigned char b) {
	if (*gpi == (int)gca[0]) if (gp[0] != 0) gs.c = gc2 / gp[0];
}
char * rs_2_03_19_4(long a, unsigned char b) {
	return &gca[b];
}
void rs_2_04_00_0(unsigned long a, struct st *b, unsigned char c) {
	double t = -gda[0];
	jd = t;
}
int rs_2_04_00_1(unsigned long a, struct st *b, unsigned char c) {
	if (gl < 2L) return ~gi3;
}
void rs_2_04_00_2(unsigned long a, struct st *b, unsigned char c) {
	gl--;
}
void rs_2_04_00_3(unsigned long a, struct st *b, unsigned char c) {
	switch (gi) { case 1: case 2: vl(b->l); break; case 8: gps->l *= 8L; break; default: gia[1] = gps->i = (gu <= 0); break; }
}
void rs_2_04_00_4(unsigned long a, struct st *b, unsigned char c) {
	double t = jd;
	v0();
	gd = t;
}
int rs_2_04_00_5(unsigned long a, struct st *b, unsigned char c) {
	if (gul != a) return gia[6] << 10;
}
int rs_2_04_00_6(unsigned long a, struct st *b, unsigned char c) {
	return !c;
}
void rs_2_04_01_0(unsigned long a) {
	vc(gca[7]);
}
void rs_2_04_01_1(unsigned long a) {
	gda[3] *= gd2;
}
void rs_2_04_01_2(unsigned long a) {
	gpi[2] <<= 11;
}
unsigned long rs_2_04_01_3(unsigned long a) {
	return gula[6] >> 15;
}
void rs_2_04_02_0(void) {
	long t = gs.l - 7L;
	jl = t;
}
void rs_2_04_02_1(void) {
	long t = jl;
	t = gps->l;
}
void rs_2_04_02_2(void) {
	gi3 = (1 + 255) ^ r1(gs.a[4]);
}
void rs_2_04_02_3(void) {
	long t = jl;
	v0();
	t |= gl2 / 10L;
}
void rs_2_04_02_4(void) {
	gula[3] += rul(gul);
}
void rs_2_04_02_5(void) {
	switch (gs.u) { case 0: guca[1] = guc << 7; break; case 1: gca[6] /= 3; break; case 2: gs.a[7] = gs.i = gia[5] + gia[1]; break; case 3: guca[6] |= guc; }
}
char rs_2_04_02_6(void) {
	return gps->c;
}
void rs_2_04_03_0(char a, int b, int c) {
	unsigned long t = (unsigned long)*gp;
	jul = t;
}
void rs_2_04_03_1(char a, int b, int c) {
	long u = (long)!gs.i;
	jl = u;
}
void rs_2_04_03_2(char a, int b, int c) {
	v0();
}
void rs_2_04_03_3(char a, int b, int c) {
	switch (gu2) { case 0: v1(gi3); break; case 1: v1(gi); break; case 2: vs(gps); break; case 3: vs(gps); break; default: gpi = gpi + c; break; }
}
void rs_2_04_03_4(char a, int b, int c) {
	gu -= gu2 * 3;
}
void rs_2_04_03_5(char a, int b, int c) {
	long u = jl;
	v0();
	if (r0()) { a = (char)(gps->u ^ 255); }
}
void rs_2_04_03_6(char a, int b, int c) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
void rs_2_04_03_7(char a, int b, int c) {
	gda[2] = gd * gd2;
}
char * rs_2_04_03_8(char a, int b, int c) {
	return gp + b;
}
void rs_2_04_04_0(char *a, struct st *b) {
	gu = (gua[2] % 100) * gu;
}
void rs_2_04_04_1(char *a, struct st *b) {
	v0();
}
void rs_2_04_04_2(char *a, struct st *b) {
	gi2 = gia[6];
}
void rs_2_04_04_3(char *a, struct st *b) {
	gps->l = gl;
}
void rs_2_04_04_4(char *a, struct st *b) {
	gs.l = gl << 18;
}
int rs_2_04_04_5(char *a, struct st *b) {
	return gi2 + (gia[4] + gi3);
}
void rs_2_04_05_0(int *a) {
	gua[1] ^= gu | 255;
}
void rs_2_04_05_1(int *a) {
	gps->u = gua[4];
}
int rs_2_04_05_2(int *a) {
	return r2(gi2, a[7]) & -gi2;
}
void rs_2_04_06_0(int *a, long b) {
	unsigned long t = gula[2];
	jul = t;
}
void rs_2_04_06_1(int *a, long b) {
	int u = 255 - gi2;
	ji = u;
}
void rs_2_04_06_2(int *a, long b) {
	int u = ji;
	gu = -(gs.u >> 5);
}
void rs_2_04_06_3(int *a, long b) {
	unsigned long t = jul;
	int u = ji;
	if (gp[1]) { guca[6] &= 246 ^ guca[u]; if (gula[u] != 0) t = t / gula[u]; } else { guca[u] = (gi3 < 127 ? guc : guc) + (guc + guca[4]); if (gia[6] != 0) u = gia[u] % gia[6]; }
}
void rs_2_04_06_4(int *a, long b) {
	gpi++;
}
void rs_2_04_06_5(int *a, long b) {
	int u = ji;
	if (b & 2) { --gp; if (u != 0) u = gs.a[u] / u; gpl[3] = gla[7] = gla[u]; }
}
void rs_2_04_06_6(int *a, long b) {
	if ((gl2 = gl)) { if (gu2 != 0) gu2 = 32767 % gu2; } else { if (gs.i != 0) gi2 = *gpi % gs.i; }
}
unsigned int rs_2_04_06_7(int *a, long b) {
	return (unsigned int)a[2];
}
void rs_2_04_07_0(int a, char b, char *c) {
	unsigned long t = gula[2];
	jul = t;
}
void rs_2_04_07_1(int a, char b, char *c) {
	gpi = rpi((int)gu);
}
void rs_2_04_07_2(int a, char b, char *c) {
	unsigned long t = jul;
	v0();
	switch (gs.l) { case 0L: t ^= 21005UL; break; case 1L: *gpl %= 10L; break; case 2L: t = (unsigned long)gps->c; default: vu(gua[2]); break; }
}
void rs_2_04_07_3(int a, char b, char *c) {
	gps->c = 9;
}
void rs_2_04_07_4(int a, char b, char *c) {
	gi3 = (gi3 << 7) + gi2;
}
unsigned long rs_2_04_07_5(int a, char b, char *c) {
	unsigned long t = jul;
	v0();
	return gul - rul(t);
}
void rs_2_04_08_0(unsigned int a, char b, unsigned long c) {
	int t = 16;
	ji = t;
}
void rs_2_04_08_1(unsigned int a, char b, unsigned long c) {
	a = gu * (255 << 14);
}
void rs_2_04_08_2(unsigned int a, char b, unsigned long c) {
	guc = 255;
}
void rs_2_04_08_3(unsigned int a, char b, unsigned long c) {
	int t = ji;
	v1(t);
}
char * rs_2_04_08_4(unsigned int a, char b, unsigned long c) {
	return gps->p;
}
void rs_2_04_09_0(int a, int b) {
	int *t = gpi;
	jpi = t;
}
void rs_2_04_09_1(int a, int b) {
	v0();
}
void rs_2_04_09_2(int a, int b) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_2_04_09_3(int a, int b) {
	if (gul & 0x8) { if (gu != 0) gu = gua[2] / gu; } else { --gul; gc2 <<= (a & 7); if (gi != 0) gia[b] = gi / gi; }
}
void rs_2_04_09_4(int a, int b) {
	switch (a) { case 0: a = gs.i & gi3; break; case 1: vs(gps); break; default: gs.c = gc = '9' * gc2; break; }
}
void rs_2_04_09_5(int a, int b) {
	gps->l = rl(gl2);
}
int rs_2_04_09_6(int a, int b) {
	return (7L < gl2 ? a : b) - (gi2 + gpi[2]);
}
void rs_2_04_10_1(unsigned int a) {
	if (gl < 65536L) { gda[0] = -(double)gia[a]; gi3 = gi2 / 4; } else { if (gps->c != 0) gca[4] = gs.c % gps->c; if (gul != 0) gul = gul / gul; }
}
void rs_2_04_10_2(unsigned int a) {
	if (gp[3] != 0) gp[2] = 64 % gp[3];
}
void rs_2_04_10_3(unsigned int a) {
	gla[1] = gpl[0] ^ gps->l;
}
void rs_2_04_10_4(unsigned int a) {
	if (gi2) guca[a] += 255;
}
void rs_2_04_10_5(unsigned int a) {
	int i = ji;
	for (i = 6; i > 0; i--) { if (gul != 0) gula[a] = 7UL % gul; gs.d = gd; guc = 128; }
}
unsigned int rs_2_04_10_6(unsigned int a) {
	return (gps->u == 1 ? gua[0] : 32767) & (gua[a] & 255);
}
void rs_2_04_11_0(int a, long b) {
	unsigned int t = gu2 - 256;
	ju = t;
}
void rs_2_04_11_1(int a, long b) {
	unsigned int t = ju;
	char *u = gp + t;
	jp = u;
}
void rs_2_04_11_2(int a, long b) {
	char *u = jp;
	gp = u;
}
void rs_2_04_11_3(int a, long b) {
	unsigned int t = ju;
	gu = t;
}
void rs_2_04_11_4(int a, long b) {
	gula[5] = gul = (unsigned long)gi2;
}
void rs_2_04_11_5(int a, long b) {
	gs.d += 1.0 * gs.d;
}
unsigned long rs_2_04_11_6(int a, long b) {
	return (2UL + gul) - (gul % 100UL);
}
void rs_2_04_12_1(char a, unsigned char b, long *c) {
	char t = gc2 << 7;
	jc = t;
}
void rs_2_04_12_2(char a, unsigned char b, long *c) {
	int *u = rpi(9);
	jpi = u;
}
void rs_2_04_12_3(char a, unsigned char b, long *c) {
	int i = ji;
	v0();
	for (i = 0; i < 6; i++) { gs.d += gda[0]; if (gpl[2] != 0) gpl[3] = gl % gpl[2]; gu2 -= 32767; }
}
void rs_2_04_12_4(char a, unsigned char b, long *c) {
	char t = jc;
	v0();
	gula[5] = rul(gula[1]) >> (t & 15);
}
void rs_2_04_12_5(char a, unsigned char b, long *c) {
	int *u = jpi;
	v0();
	gpi = u;
}
void rs_2_04_12_6(char a, unsigned char b, long *c) {
	vp(gps->p + a);
}
int rs_2_04_12_7(char a, unsigned char b, long *c) {
	char t = jc;
	v0();
	return -((int)gul ^ gia[t]);
}
void rs_2_04_13_0(void) {
	int *t = gpi + 1;
	jpi = t;
}
void rs_2_04_13_1(void) {
	int *t = jpi;
	if (!gul) { gla[7] /= 16L; t = gpi; if (gps->u != 0) gu = gua[0] / gps->u; } else { *gpl = gla[2] = (gc < gs.c ? (1L + gl) : -gla[0]); gl2 -= gs.l / 3L; v0(); }
}
void rs_2_04_13_2(void) {
	*gp = gca[2] / 3;
}
unsigned int rs_2_04_13_3(void) {
	return (gps->u + gs.u) >> 3;
}
void rs_2_04_14_1(int a, char b, unsigned long c) {
	unsigned long t = rul(gul);
	jul = t;
}
void rs_2_04_14_2(int a, char b, unsigned long c) {
	vc(~gca[a]);
}
void rs_2_04_14_3(int a, char b, unsigned long c) {
	gs.u = 32767;
}
void rs_2_04_14_4(int a, char b, unsigned long c) {
	unsigned long t = jul;
	v0();
	gul = t;
}
void rs_2_04_14_5(int a, char b, unsigned long c) {
	int i = ji;
	v0();
	i = 0; while (i < 8) { if (*gpl != 0) *gpl = gl % *gpl; if (gl != 0) gl2 = gpl[3] / gl; if (gi != 0) a = (int)gs.l % gi; i++; }
}
void rs_2_04_14_6(int a, char b, unsigned long c) {
	if (r0()) v0();
}
void rs_2_04_14_7(int a, char b, unsigned long c) {
	gp[2] = gc;
}
int * rs_2_04_14_8(int a, char b, unsigned long c) {
	return gpi;
}
void rs_2_04_15_0(unsigned char a, long *b) {
	unsigned int t = gu;
	ju = t;
}
void rs_2_04_15_1(unsigned char a, long *b) {
	gla[3] = (gs.l % 3L) - rl(gla[6]);
}
void rs_2_04_15_2(unsigned char a, long *b) {
	unsigned int t = ju;
	v0();
	gia[t] <<= 15;
}
int * rs_2_04_15_3(unsigned char a, long *b) {
	return &gia[0];
}
void rs_2_04_16_0(unsigned int a, unsigned int b) {
	if (gs.l != 0) gps->l = gl % gs.l;
}
void rs_2_04_16_1(unsigned int a, unsigned int b) {
	gca[1] -= 0;
}
void rs_2_04_16_2(unsigned int a, unsigned int b) {
	gua[1] += -32767;
}
void rs_2_04_16_3(unsigned int a, unsigned int b) {
	gua[1] >>= 8;
}
void rs_2_04_16_4(unsigned int a, unsigned int b) {
	if (gi2) if (gl2 != 0) gla[1] = gla[a] / gl2;
}
int rs_2_04_16_5(unsigned int a, unsigned int b) {
	return gs.a[4];
}
void rs_2_04_17_0(void) {
	--gl2;
}
void rs_2_04_17_1(void) {
	gs.p = gps->p;
}
void rs_2_04_17_2(void) {
	vu(((unsigned int)gpl[0]) << 15);
}
void rs_2_04_17_3(void) {
	gl2 = gla[5];
}
unsigned long rs_2_04_17_4(void) {
	return gula[4] | (gula[3] + gula[7]);
}
void rs_2_04_18_0(void) {
	unsigned int t = ru(gu);
	ju = t;
}
void rs_2_04_18_1(void) {
	vp(&gca[4]);
}
void rs_2_04_18_2(void) {
	++gi3;
}
void rs_2_04_18_3(void) {
	unsigned int t = ju;
	v0();
	vu(t);
}
int rs_2_04_18_4(void) {
	return -gpi[0] % 10;
}
void rs_2_04_19_1(void) {
	guca[4] = ~guca[2];
}
void rs_2_04_19_2(void) {
	gu2 = gua[4];
}
void rs_2_04_19_3(void) {
	int i = ji;
	for (i = 12; i > 0; i--) { guca[i] = guc = ~139 * ((unsigned char)!gc2); }
}
void rs_2_04_19_4(void) {
	gla[3] = 65536L >> 4;
}
void rs_2_04_19_5(void) {
	v1(*gpi);
}
void rs_2_05_00_0(unsigned char a, int b, int c) {
	v1(gi3 + gps->a[1]);
}
void rs_2_05_00_1(unsigned char a, int b, int c) {
	if (gu != 0) gua[b] = gu % gu;
}
void rs_2_05_00_2(unsigned char a, int b, int c) {
	vu(gu2 << 11);
}
void rs_2_05_00_3(unsigned char a, int b, int c) {
	guca[b] <<= 1;
}
void rs_2_05_00_4(unsigned char a, int b, int c) {
	gc2 = ~'a';
}
void rs_2_05_01_0(void) {
	char t = gc2 * gca[1];
	jc = t;
}
void rs_2_05_01_1(void) {
	char t = jc;
	long u = (gia[t] > 256 ? gl : gla[2]);
	jl = u;
}
void rs_2_05_01_2(void) {
	gps->c = ((char)guc % 7) | (gps->i <= gs.i ? gc2 : gs.c);
}
void rs_2_05_01_3(void) {
	long u = jl;
	gl = u;
}
void rs_2_05_01_4(void) {
	char t = jc;
	gs.p = gp + t;
}
void rs_2_05_01_5(void) {
	gd *= gs.d;
}
void rs_2_05_02_1(int a) {
	int *t = gpi;
	jpi = t;
}
void rs_2_05_02_2(int a) {
	unsigned long u = 39867UL;
	jul = u;
}
void rs_2_05_02_3(int a) {
	int i = ji;
	for (i = 0; i < 9; i++) { vl(gps->l + gs.l); ++gc2; if (gc2 != 0) gc = gca[i] / gc2; }
}
void rs_2_05_02_4(int a) {
	int *t = jpi;
	v0();
	v1(*t);
}
int rs_2_05_02_5(int a) {
	if (((unsigned long)gia[4]) > 89152UL && gc2 >= gs.c) return gia[3] % 3;
}
void rs_2_05_02_6(int a) {
	while (a-- > 0) *gpi++ = 127;
}
void rs_2_05_02_7(int a) {
	unsigned long u = jul;
	v0();
	vl((long)u);
}
int rs_2_05_02_8(int a) {
	return (gia[6] * 2) * 9;
}
void rs_2_05_03_0(int *a) {
	guca[5] = (unsigned char)(r0() > (gi | a[3]));
}
void rs_2_05_03_1(int *a) {
	a[6] %= 2;
}
char rs_2_05_03_2(int *a) {
	return (gca[7] + gc2) % 3;
}
void rs_2_05_04_0(int *a, long b) {
	int *t = a;
	jpi = t;
}
void rs_2_05_04_1(int *a, long b) {
	int *t = jpi;
	gpi = t;
}
void rs_2_05_04_2(int *a, long b) {
	gua[6] = ((unsigned int)(gua[1] <= gu)) << 15;
}
void rs_2_05_04_3(int *a, long b) {
	gula[7] = gul;
}
void rs_2_05_04_4(int *a, long b) {
	v2(gi2, gi3 ^ gpi[0]);
}
void rs_2_05_05_0(void) {
	unsigned int t = ru(gu2);
	ju = t;
}
void rs_2_05_05_1(void) {
	unsigned int t = ju;
	long u = 65536L - gla[t];
	v0();
	jl = u;
}
void rs_2_05_05_2(void) {
	unsigned int t = ju;
	long u = jl;
	v0();
	if (255 > guc) { gs.l >>= 27; v2(1 & (int)t, gi); u = gs.l; } else { if (gl != 0) u = u % gl; }
}
void rs_2_05_05_3(void) {
	*gpl = 65536L;
}
void rs_2_05_05_4(void) {
	unsigned int t = ju;
	v0();
	guca[t] = 255;
}
void rs_2_05_05_5(void) {
	unsigned int t = ju;
	v0();
	++t;
}
void rs_2_05_05_6(void) {
	switch (gs.c) { case 0: vp(rp()); case 1: gc2 -= 7; break; default: gp = gps->p; break; }
}
int * rs_2_05_05_7(void) {
	return gpi;
}
void rs_2_05_06_0(void) {
	unsigned int t = 32767 & 255;
	ju = t;
}
void rs_2_05_06_1(void) {
	double u = (guc & 0x8 ? gs.d : gd2);
	jd = u;
}
void rs_2_05_06_2(void) {
	gl -= gl2 ^ gs.l;
}
void rs_2_05_06_3(void) {
	double u = jd;
	gd = u;
}
void rs_2_05_06_4(void) {
	gpl[2] = gla[5] & (long)gul;
}
void rs_2_05_06_5(void) {
	unsigned int t = ju;
	gp = gs.p + t;
}
void rs_2_05_07_1(char a, long *b) {
	long t = rl(*gpl);
	jl = t;
}
void rs_2_05_07_2(char a, long *b) {
	guca[a] = (unsigned char)(gc2 + 2);
}
void rs_2_05_07_3(char a, long *b) {
	int i = ji;
	v0();
	for (i = 0; i < 4; i++) { vu(gu); ++gpi; }
}
void rs_2_05_07_4(char a, long *b) {
	while (gi-- > 0) { if (*b == 6L) break; b++; }
}
void rs_2_05_07_5(char a, long *b) {
	long t = jl;
	v0();
	vl(t);
}
void rs_2_05_07_6(char a, long *b) {
	int i = ji;
	v0();
	switch (gu2) { case 0: gla[5] = (long)!gu2; break; case 1: vc(2); break; case 2: gs.i <<= 11; break; case 3: gc2 = gc = 3; break; default: vl(gla[4]); break; }
}
void rs_2_05_07_7(char a, long *b) {
	gp = gps->p;
}
unsigned int rs_2_05_07_8(char a, long *b) {
	return (gu = 1);
}
void rs_2_05_08_0(unsigned int a, double b, unsigned int c) {
	long t = -59655L / 16L;
	jl = t;
}
void rs_2_05_08_1(unsigned int a, double b, unsigned int c) {
	int u = gps->a[1] & 16;
	ji = u;
}
void rs_2_05_08_2(unsigned int a, double b, unsigned int c) {
	int u = ji;
	u %= 16;
}
void rs_2_05_08_3(unsigned int a, double b, unsigned int c) {
	gs.p = gp;
}
void rs_2_05_08_4(unsigned int a, double b, unsigned int c) {
	gul = (gul | 8UL) >> 7;
}
void rs_2_05_08_5(unsigned int a, double b, unsigned int c) {
	vd(0.5 * 2.5);
}
void rs_2_05_08_6(unsigned int a, double b, unsigned int c) {
	long t = jl;
	v0();
	gl = t;
}
void rs_2_05_08_7(unsigned int a, double b, unsigned int c) {
	vu(ru(gua[7]));
}
unsigned long rs_2_05_08_8(unsigned int a, double b, unsigned int c) {
	return (unsigned long)c;
}
void rs_2_05_09_0(long a) {
	if (guca[7]) if (gca[2] != 0) *gp = gc2 % gca[2];
}
void rs_2_05_09_1(long a) {
	if (!*gpl) { if (gu != 0) gua[4] = gu2 % gu; }
}
void rs_2_05_09_2(long a) {
	gs.u = gu2;
}
int rs_2_05_09_3(long a) {
	return r0() + (gi2 * 7);
}
void rs_2_05_10_1(int a) {
	int t = *gpi + a;
	ji = t;
}
void rs_2_05_10_2(int a) {
	unsigned char u = guca[6];
	juc = u;
}
void rs_2_05_10_3(int a) {
	unsigned char u = juc;
	gpi = &gia[u];
}
void rs_2_05_10_4(int a) {
	int i = ji;
	unsigned char u = juc;
	i = 0; while (i < 16) { if (gp[0] != 0) gc = gca[i] / gp[0]; gu = gps->u; if (gs.c != 0) gs.c = 6 % gs.c; i++; }
}
void rs_2_05_10_5(int a) {
	int t = ji;
	v1(t);
}
void rs_2_05_10_6(int a) {
	*gpl = -33775L;
}
int rs_2_05_10_7(int a) {
	return 256;
}
void rs_2_05_11_0(int *a, int b) {
	char *t = gps->p;
	jp = t;
}
void rs_2_05_11_1(int *a, int b) {
	if (gi3) vs(gps);
}
void rs_2_05_11_2(int *a, int b) {
	char *t = jp;
	v0();
	if (gc == *t) { gu2 = (!gula[b] ? (gps->u * 256) : gua[3]); if (gca[b] != 0) gca[6] = gs.c / gca[b]; gula[7] <<= 17; } else { if (gc2 != 0) gps->c = gc / gc2; *gp <<= (b & 7); }
}
int rs_2_05_11_3(int *a, int b) {
	return (b >> 6) << 9;
}
void rs_2_05_12_1(void) {
	int t = 256;
	ji = t;
}
void rs_2_05_12_2(void) {
	char u = gc2 << 3;
	jc = u;
}
void rs_2_05_12_3(void) {
	char u = jc;
	guca[u] |= ~guc;
}
void rs_2_05_12_4(void) {
	int t = ji;
	char u = jc;
	gs.u = (unsigned int)((guc - 255) < (guc ^ guca[t]));
}
void rs_2_05_12_5(void) {
	if (!gc) { gpi[3] += gs.a[7]; } else { gpi = rpi(gi << 13); gua[7] /= 7; }
}
void rs_2_05_12_6(void) {
	int i = ji;
	char u = jc;
	v0();
	i = 0; while (i < 13) { guc = ((unsigned char)u) * ((unsigned char)gl2); --gu; ++gp; i++; }
}
void rs_2_05_12_7(void) {
	vd(gd * gd);
}
char rs_2_05_12_8(void) {
	char u = jc;
	v0();
	return u;
}
void rs_2_05_13_0(unsigned int a, unsigned long b, unsigned int c) {
	a = gu2 = ((unsigned int)!gla[7]) - (gua[c] - gs.u);
}
void rs_2_05_13_1(unsigned int a, unsigned long b, unsigned int c) {
	gi2 = gs.i = gi3;
}
void rs_2_05_13_2(unsigned int a, unsigned long b, unsigned int c) {
	vd(gd);
}
void rs_2_05_13_3(unsigned int a, unsigned long b, unsigned int c) {
	b = -(gul >> (c & 15));
}
char * rs_2_05_13_4(unsigned int a, unsigned long b, unsigned int c) {
	return gps->p;
}
void rs_2_05_14_0(unsigned int a, long b) {
	char *t = gp;
	jp = t;
}
void rs_2_05_14_1(unsigned int a, long b) {
	char *t = jp;
	gp = t;
}
void rs_2_05_14_2(unsigned int a, long b) {
	a /= 16;
}
void rs_2_05_14_3(unsigned int a, long b) {
	guc = (guca[1] - guca[a]) * guca[a];
}
void rs_2_05_14_4(unsigned int a, long b) {
	switch (gc) { case 0: gs.u >>= 11; break; case 1: gd2 += gda[2]; break; }
}
void rs_2_05_14_5(unsigned int a, long b) {
	v1((guca[a] > guc));
}
void rs_2_05_14_6(unsigned int a, long b) {
	guca[3] = guc;
}
char rs_2_05_14_7(unsigned int a, long b) {
	char *t = jp;
	v0();
	return (t[0] << (a & 7)) - (gc + gp[2]);
}
void rs_2_05_15_1(unsigned long a, int b) {
	int *t = gpi;
	jpi = t;
}
void rs_2_05_15_2(unsigned long a, int b) {
	unsigned char u = guc;
	juc = u;
}
void rs_2_05_15_3(unsigned long a, int b) {
	int i = ji;
	for (i = b; i > 0; i--) { if (gps->c != 0) gp[0] = '9' % gps->c; }
}
void rs_2_05_15_4(unsigned long a, int b) {
	gda[2] -= gda[2] * gs.d;
}
void rs_2_05_15_5(unsigned long a, int b) {
	unsigned char u = juc;
	guc = u;
}
void rs_2_05_15_6(unsigned long a, int b) {
	int *t = jpi;
	v1(*t);
}
char * rs_2_05_15_7(unsigned long a, int b) {
	unsigned char u = juc;
	v0();
	return gp + u;
}
void rs_2_05_16_0(int a) {
	unsigned char t = guc;
	juc = t;
}
void rs_2_05_16_1(int a) {
	long u = gla[7];
	jl = u;
}
void rs_2_05_16_2(int a) {
	guc++;
}
void rs_2_05_16_3(int a) {
	unsigned char t = juc;
	guc = t;
}
void rs_2_05_16_4(int a) {
	gula[5] = gul;
}
void rs_2_05_16_5(int a) {
	gu2 %= 2;
}
void rs_2_05_16_6(int a) {
	long u = jl;
	gu = ~(gs.u + ((unsigned int)a));
}
void rs_2_05_16_7(int a) {
	gi = (gi2 - 1) << 6;
}
int rs_2_05_16_8(int a) {
	return (gda[2] <= gda[3]) ^ (gi2 ^ 16);
}
void rs_2_05_17_0(char a) {
	v0();
}
void rs_2_05_17_1(char a) {
	vu(gs.u - gua[5]);
}
unsigned long rs_2_05_17_2(char a) {
	return gul ^ (gul ^ 3UL);
}
void rs_2_05_18_1(int a) {
	int i = ji;
	i = 5; do { gul = (gul | gula[i]) % 2UL; if (gca[6] != 0) gca[i] = gc % gca[6]; } while (--i > 0);
}
void rs_2_05_18_2(int a) {
	gu2 = 1;
}
void rs_2_05_18_3(int a) {
	vp(gps->p + a);
}
void rs_2_05_18_4(int a) {
	gpi--;
}
unsigned int rs_2_05_18_5(int a) {
	return (gps->u | 20120) % 3;
}
void rs_2_05_19_1(unsigned int a, unsigned char b) {
	long t = -(long)gula[b];
	jl = t;
}
void rs_2_05_19_2(unsigned int a, unsigned char b) {
	int i = ji;
	long t = jl;
	i = 0; while (i < 14) { if (gps->c != 0) gc = gp[1] / gps->c; gula[i] = gul = (gula[b] + 8UL) << (i & 15); t &= 65536L * *gpl; i++; }
}
void rs_2_05_19_3(unsigned int a, unsigned char b) {
	gd += (guca[a] & 0x8 ? gs.d : (double)gl2);
}
void rs_2_05_19_4(unsigned int a, unsigned char b) {
	switch (gc2) { case 0: case 1: gps->c &= gc2; break; case 2: gi3 = gps->a[a]; break; }
}
int rs_2_05_19_5(unsigned int a, unsigned char b) {
	int i = ji;
	return gs.i;
}
void rs_2_06_00_0(void) {
	unsigned long t = gula[4] / 3UL;
	jul = t;
}
void rs_2_06_00_1(void) {
	unsigned int u = gu;
	ju = u;
}
void rs_2_06_00_2(void) {
	gl2 = rl(gpl[3]);
}
void rs_2_06_00_3(void) {
	unsigned int u = ju;
	v0();
	vu(u);
}
void rs_2_06_00_4(void) {
	*gpl = (long)(gu2 + gua[5]);
}
void rs_2_06_00_5(void) {
	gi2 %= 3;
}
void rs_2_06_00_6(void) {
	unsigned long t = jul;
	v0();
	gul = t;
}
void rs_2_06_00_7(void) {
	if (gps->c != 0) gc2 = 'a' / gps->c;
}
int rs_2_06_00_8(void) {
	return !(256 / 16);
}
void rs_2_06_01_0(unsigned long a, long *b) {
	double t = gda[1];
	jd = t;
}
void rs_2_06_01_1(unsigned long a, long *b) {
	double u = 1.0 * (double)gc2;
	jd = u;
}
void rs_2_06_01_2(unsigned long a, long *b) {
	a = gul ^ (((unsigned long)gps->c) ^ a);
}
void rs_2_06_01_3(unsigned long a, long *b) {
	double u = jd;
	vd(u);
}
void rs_2_06_01_4(unsigned long a, long *b) {
	gu2 = ru(gu) | (11273 >> 4);
}
void rs_2_06_01_5(unsigned long a, long *b) {
	gla[4] %= 7L;
}
void rs_2_06_01_6(unsigned long a, long *b) {
	gi3 = gi2;
}
void rs_2_06_01_7(unsigned long a, long *b) {
	double t = jd;
	v0();
	switch (gu2) { case 0: v1(gi); break; case 1: gu2 = (unsigned int)gps->a[3]; break; case 2: guc = guca[2] >> 1; break; case 3: gd = (r0() ? t : gda[2]); break; }
}
int rs_2_06_01_8(unsigned long a, long *b) {
	return 127 % 16;
}
void rs_2_06_02_1(long a, int b) {
	if (gula[b]) { if (gc != 0) gps->c = 'z' % gc; if (gca[1] != 0) gp[3] = gs.c / gca[1]; guc >>= (b & 7); } else { guc = guc >> (b & 7); }
}
void rs_2_06_02_2(long a, int b) {
	int i = ji;
	for (i = 0; i < 10; i++) { gua[i] = (unsigned int)!gul; vp(&gca[i]); }
}
void rs_2_06_02_3(long a, int b) {
	gula[0] = 48234UL;
}
int rs_2_06_02_4(long a, int b) {
	int i = ji;
	v0();
	return ~gps->i;
}
void rs_2_06_03_0(unsigned int a) {
	char t = -gc2;
	jc = t;
}
void rs_2_06_03_1(unsigned int a) {
	vs(gps);
}
void rs_2_06_03_2(unsigned int a) {
	if (*gp > 73) { if (a != 0) gu = gps->u / a; if (*gpl != 0) gs.l = gl2 / *gpl; gl2 = gl; }
}
void rs_2_06_03_3(unsigned int a) {
	char t = jc;
	v0();
	gc = t;
}
void rs_2_06_03_4(unsigned int a) {
	switch (gps->i) { case 3: gs.p = gps->p + a; break; case 5: guca[a] = guc | 181; break; case 8: vl(-62961L); case 16: case 20: case 1000: vu(gs.u); }
}
char * rs_2_06_03_5(unsigned int a) {
	return gs.p;
}
void rs_2_06_04_1(void) {
	int t = 255 - gi2;
	ji = t;
}
void rs_2_06_04_2(void) {
	gul = (unsigned long)(*gp != gc);
}
void rs_2_06_04_3(void) {
	++gl2;
}
void rs_2_06_04_4(void) {
	int t = ji;
	gul = (gula[6] << (t & 15)) % 4UL;
}
void rs_2_06_04_5(void) {
	gu--;
}
void rs_2_06_04_6(void) {
	int i = ji;
	for (i = 2; i > 0; i--) { gpi = rpi(gi * 2); }
}
unsigned int rs_2_06_04_7(void) {
	return (gu = gs.u);
}
void rs_2_06_05_0(void) {
	long t = gpl[2];
	jl = t;
}
void rs_2_06_05_1(void) {
	v2(gi2, 8);
}
void rs_2_06_05_2(void) {
	gca[2] = gca[6] * gca[0];
}
void rs_2_06_05_3(void) {
	long t = jl;
	v0();
	gl = t;
}
void rs_2_06_05_4(void) {
	gpi++;
}
void rs_2_06_05_5(void) {
	gu2 = ru(gu);
}
void rs_2_06_05_6(void) {
	gps->u = gu = (256 - ((unsigned int)gl)) | ((unsigned int)!*gpl);
}
char * rs_2_06_05_7(void) {
	return gps->p + 1;
}
void rs_2_06_06_1(long *a) {
	gd = gd2;
}
void rs_2_06_06_2(long *a) {
	guc = (gps->u ? 9 : -guca[3]);
}
void rs_2_06_06_3(long *a) {
	vp(&gca[3]);
}
void rs_2_06_06_4(long *a) {
	int i = ji;
	v0();
	for (i = 2; i > 0; i--) { if (gula[i] != 0) gul = gula[i] / gula[i]; if (gua[i] != 0) gua[i] = ((unsigned int)gla[i]) % gua[i]; }
}
void rs_2_06_07_0(void) {
	int *t = gpi;
	jpi = t;
}
void rs_2_06_07_1(void) {
	double u = 2.5 / 3.0;
	jd = u;
}
void rs_2_06_07_2(void) {
	if (guca[1] > guc) gu2++;
}
void rs_2_06_07_3(void) {
	int *t = jpi;
	v1(*t);
}
void rs_2_06_07_4(void) {
	vc(gp[0]);
}
void rs_2_06_07_5(void) {
	double u = jd;
	v0();
	vd(u);
}
unsigned int rs_2_06_07_6(void) {
	return (gu * gu2) ^ (gua[1] & gu);
}
void rs_2_06_08_1(unsigned int a) {
	gula[a] = (unsigned long)(guc - 255);
}
void rs_2_06_08_2(unsigned int a) {
	if (gps->c || -86400L > 65536L) { if (gia[a] != 0) gi = gia[a] / gia[a]; gu2 /= 10; if (gu != 0) gps->u = gu2 / gu; }
}
void rs_2_06_08_3(unsigned int a) {
	if (!a) vl(~gl2);
}
int rs_2_06_08_4(unsigned int a) {
	if (!gul) return gi >> 3;
}
void rs_2_06_08_5(unsigned int a) {
	int i = ji;
	v0();
	for (i = 11; i > 0; i--) { if (gul != 0) gul = gula[i] % gul; if (gua[i] != 0) gu = gua[i] % gua[i]; }
}
int rs_2_06_08_6(unsigned int a) {
	return (int)gula[5] / 7;
}
void rs_2_06_09_1(unsigned int a) {
	int t = 255;
	ji = t;
}
void rs_2_06_09_2(unsigned int a) {
	gpi = &gia[0];
}
void rs_2_06_09_3(unsigned int a) {
	int t = ji;
	v1(t);
}
void rs_2_06_09_4(unsigned int a) {
	gs.c = (!gua[4] ? (' ') : gc2);
}
void rs_2_06_09_5(unsigned int a) {
	int i = ji;
	v0();
	i = 0; while (i < 7) { if (gla[i] != 0) gl2 = gs.l % gla[i]; i++; }
}
void rs_2_06_09_6(unsigned int a) {
	gl = rl(gs.l);
}
void rs_2_06_09_7(unsigned int a) {
	int i = ji;
	v0();
	for (i = 0; i < 14; i++) { if (gl2 != 0) gl2 = 65536L / gl2; }
}
int rs_2_06_09_8(unsigned int a) {
	int i = ji;
	int t = ji;
	v0();
	return (gs.i - t) ^ (gs.i << 3);
}
void rs_2_06_10_0(int a, int b, unsigned long c) {
	char t = (91 < -39 ? 3 : gs.c);
	jc = t;
}
void rs_2_06_10_1(int a, int b, unsigned long c) {
	char t = jc;
	gul >>= (t & 15);
}
void rs_2_06_10_2(int a, int b, unsigned long c) {
	gs.p = rp();
}
void rs_2_06_10_3(int a, int b, unsigned long c) {
	guca[1] = 255;
}
long rs_2_06_10_4(int a, int b, unsigned long c) {
	return *gpl + 9L;
}
void rs_2_06_11_0(void) {
	char *t = &gca[1];
	jp = t;
}
void rs_2_06_11_1(void) {
	char *t = jp;
	vp(t);
}
void rs_2_06_11_2(void) {
	++gpi;
}
void rs_2_06_11_3(void) {
	gu2 = (gu2 + gps->u) - gu2;
}
unsigned long rs_2_06_11_4(void) {
	return 0x10000UL;
}
void rs_2_06_12_1(unsigned long a, char *b, long c) {
	long t = (long)(166 > guc);
	jl = t;
}
void rs_2_06_12_2(unsigned long a, char *b, long c) {
	int i = ji;
	for (i = 10; i > 0; i--) { gula[i] /= 16UL; if (gia[i] != 0) gia[i] = gi3 % gia[i]; a = gula[i] = ((unsigned long)(gua[3] <= gu2)) ^ gul; }
}
void rs_2_06_12_3(unsigned long a, char *b, long c) {
	int i = ji;
	long t = jl;
	for (i = 0; i < 15; i++) { gl2 += ~t; gs.l = gla[i] = (long)(gu2 != (255 + gua[i])); gu2 = (*gpi ? gu : gu) << (i & 15); }
}
unsigned long rs_2_06_12_4(unsigned long a, char *b, long c) {
	return (gul = a);
}
void rs_2_06_13_0(char a, unsigned long b, char *c) {
	gu = 255;
}
void rs_2_06_13_1(char a, unsigned long b, char *c) {
	gia[a] <<= 4;
}
void rs_2_06_13_2(char a, unsigned long b, char *c) {
	if (gula[a] <= gula[1]) { --gc; if (gula[5] != 0) b = b / gula[5]; }
}
void rs_2_06_13_3(char a, unsigned long b, char *c) {
	++gpi;
}
void rs_2_06_13_4(char a, unsigned long b, char *c) {
	guc <<= 4;
}
void rs_2_06_14_0(int a, int *b, char c) {
	switch (c) { case 8: vc(gc2); break; case 20: v0(); break; default: vs(gps); break; }
}
void rs_2_06_14_1(int a, int *b, char c) {
	gs.d = 100.0 - gd2;
}
void rs_2_06_14_2(int a, int *b, char c) {
	guc--;
}
void rs_2_06_14_3(int a, int *b, char c) {
	if (*b != 0) gia[1] = a / *b;
}
int * rs_2_06_14_4(int a, int *b, char c) {
	return gpi;
}
void rs_2_06_15_1(void) {
	char *t = gps->p;
	jp = t;
}
void rs_2_06_15_2(void) {
	unsigned char u = (unsigned char)(gc2 != 91);
	juc = u;
}
void rs_2_06_15_3(void) {
	char *t = jp;
	unsigned char u = juc;
	switch (gu2) { case 0: vp(t); break; case 1: gia[u] /= 10; default: vd(gd2); break; }
}
void rs_2_06_15_4(void) {
	gps->p = rp();
}
void rs_2_06_15_5(void) {
	int i = ji;
	unsigned char u = juc;
	v0();
	i = 0; while (i < 9) { if (gu != 0) gua[i] = gs.u / gu; i++; }
}
int rs_2_06_15_6(void) {
	int i = ji;
	v0();
	return gps->i;
}
void rs_2_06_16_0(void) {
	int t = !gi3;
	ji = t;
}
void rs_2_06_16_1(void) {
	int t = ji;
	if (t > 2) { gp++; }
}
void rs_2_06_16_2(void) {
	vd(gd - gd2);
}
void rs_2_06_16_3(void) {
	vc(gps->c);
}
int * rs_2_06_16_4(void) {
	int t = ji;
	v0();
	return rpi(-t);
}
void rs_2_06_17_0(int a) {
	int *t = gpi + a;
	jpi = t;
}
void rs_2_06_17_1(int a) {
	int *t = jpi;
	t = &gia[a];
}
void rs_2_06_17_2(int a) {
	if (gca[a] & 0x7 || 39 < 3) gi3 = 6;
}
void rs_2_06_17_3(int a) {
	int *t = jpi;
	t = &gia[a];
}
long rs_2_06_17_4(int a) {
	return gla[a];
}
void rs_2_06_18_0(void) {
	char *t = &gca[1];
	jp = t;
}
void rs_2_06_18_1(void) {
	int *u = gpi;
	jpi = u;
}
void rs_2_06_18_2(void) {
	vd(gd2);
}
void rs_2_06_18_3(void) {
	char *t = jp;
	v0();
	t[2] %= 2;
}
void rs_2_06_18_4(void) {
	gla[2] = gl2 = (65536L | gpl[0]) * 3L;
}
void rs_2_06_18_5(void) {
	char *t = jp;
	v0();
	vp(t + 1);
}
void rs_2_06_18_6(void) {
	int *u = jpi;
	v0();
	v1(*u);
}
void rs_2_06_19_0(void) {
	gpi = gpi + 1;
}
void rs_2_06_19_1(void) {
	vs(gps);
}
void rs_2_06_19_2(void) {
	if (gla[1] != 0) *gpl = gpl[2] / gla[1];
}
int * rs_2_06_19_3(void) {
	return gpi;
}
void rs_2_07_00_0(int a, unsigned char b, unsigned char c) {
	unsigned int t = 0 / 16;
	ju = t;
}
void rs_2_07_00_1(int a, unsigned char b, unsigned char c) {
	gl2 = rl(gl2);
}
void rs_2_07_00_2(int a, unsigned char b, unsigned char c) {
	unsigned int t = ju;
	v0();
	gu = t;
}
void rs_2_07_00_3(int a, unsigned char b, unsigned char c) {
	gul %= 16UL;
}
void rs_2_07_00_4(int a, unsigned char b, unsigned char c) {
	vp(gs.p);
}
unsigned long rs_2_07_00_5(int a, unsigned char b, unsigned char c) {
	return (gula[1] = 76263UL);
}
void rs_2_07_01_0(unsigned char a, int b, int *c) {
	if (gua[b] != 256) if (gu != 0) gu = gua[1] / gu;
}
void rs_2_07_01_1(unsigned char a, int b, int *c) {
	gla[7] = gpl[0] = (gi3 & 2 && gl2 ? ((long)(gps->u >= gua[0])) : gl2);
}
void rs_2_07_01_2(unsigned char a, int b, int *c) {
	gpi[3] += *gpi - 255;
}
void rs_2_07_01_3(unsigned char a, int b, int *c) {
	*gpl = 7L - -68821L;
}
int rs_2_07_01_4(unsigned char a, int b, int *c) {
	return -gpi[1] * 4;
}
void rs_2_07_02_0(void) {
	long t = gs.l / 7L;
	jl = t;
}
void rs_2_07_02_1(void) {
	long t = jl;
	t = rl(65536L - t);
}
void rs_2_07_02_2(void) {
	v2(gi2, -gps->a[1]);
}
char * rs_2_07_02_3(void) {
	return gs.p;
}
void rs_2_07_03_0(unsigned char a, char *b, unsigned int c) {
	int *t = gpi;
	jpi = t;
}
void rs_2_07_03_1(unsigned char a, char *b, unsigned int c) {
	unsigned int u = c;
	ju = u;
}
void rs_2_07_03_2(unsigned char a, char *b, unsigned int c) {
	gda[3] *= gda[2] * 100.0;
}
void rs_2_07_03_3(unsigned char a, char *b, unsigned int c) {
	int *t = jpi;
	t = t + a;
}
void rs_2_07_03_4(unsigned char a, char *b, unsigned int c) {
	unsigned int u = ju;
	gu = u;
}
int rs_2_07_03_5(unsigned char a, char *b, unsigned int c) {
	return gi2;
}
void rs_2_07_04_1(int a, long b) {
	gula[a] = gula[5] >> 20;
}
void rs_2_07_04_2(int a, long b) {
	a &= -*gpi;
}
void rs_2_07_04_3(int a, long b) {
	if (*gpl != 0) gps->l = gla[6] / *gpl;
}
void rs_2_07_04_4(int a, long b) {
	int i = ji;
	for (i = 0; i < 10; i++) { gs.c = gc2; ++gpi; }
}
int rs_2_07_04_5(int a, long b) {
	int i = ji;
	return gs.i;
}
void rs_2_07_05_0(long *a) {
	char t = (char)gua[7];
	jc = t;
}
void rs_2_07_05_1(long *a) {
	int *u = gpi;
	jpi = u;
}
void rs_2_07_05_2(long *a) {
	char t = jc;
	vc(t - 2);
}
void rs_2_07_05_3(long *a) {
	gp--;
}
void rs_2_07_05_4(long *a) {
	char t = jc;
	int *u = jpi;
	v0();
	if (r1(256) && gc < 10) { if (gua[t] != 0) gps->u = gua[4] / gua[t]; if (*u != 0) gia[t] = gi2 / *u; } else { vd(gd); }
}
void rs_2_07_05_5(long *a) {
	gl++;
}
void rs_2_07_05_6(long *a) {
	if (*gpi != 0) gi2 = gia[5] / *gpi;
}
int * rs_2_07_05_7(long *a) {
	char t = jc;
	v0();
	return &gia[t];
}
void rs_2_07_06_0(void) {
	--gl2;
}
void rs_2_07_06_1(void) {
	vs(gps);
}
int * rs_2_07_06_2(void) {
	return gpi;
}
void rs_2_07_07_0(unsigned long a, int *b, int *c) {
	int t = gps->a[0] ^ gia[0];
	ji = t;
}
void rs_2_07_07_1(unsigned long a, int *b, int *c) {
	gps->u = -((unsigned int)guc);
}
void rs_2_07_07_2(unsigned long a, int *b, int *c) {
	int t = ji;
	v1(t);
}
void rs_2_07_07_3(unsigned long a, int *b, int *c) {
	gda[3] -= -gda[2];
}
void rs_2_07_07_4(unsigned long a, int *b, int *c) {
	gs.p = gp;
}
void rs_2_07_07_5(unsigned long a, int *b, int *c) {
	gs.d = -gd;
}
void rs_2_07_07_6(unsigned long a, int *b, int *c) {
	if (!guca[2]) { if (gu2 != 0) gs.u = gu / gu2; } else { ++gu; if (gs.l != 0) gla[4] = gs.l % gs.l; }
}
void rs_2_07_08_0(double a, unsigned int b, int *c) {
	char *t = gp;
	jp = t;
}
void rs_2_07_08_1(double a, unsigned int b, int *c) {
	c--;
}
void rs_2_07_08_2(double a, unsigned int b, int *c) {
	char *t = jp;
	vp(t);
}
void rs_2_07_08_3(double a, unsigned int b, int *c) {
	if (a < 0.5) if (gu != 0) gs.u = b / gu;
}
void rs_2_07_08_4(double a, unsigned int b, int *c) {
	vd(gd);
}
void rs_2_07_08_5(double a, unsigned int b, int *c) {
	if (gla[b] != 0) gla[3] = 4L / gla[b];
}
void rs_2_07_08_6(double a, unsigned int b, int *c) {
	gc2 /= 7;
}
char * rs_2_07_08_7(double a, unsigned int b, int *c) {
	char *t = jp;
	v0();
	return t;
}
void rs_2_07_09_0(int a) {
	int t = gia[a];
	ji = t;
}
void rs_2_07_09_1(int a) {
	int t = ji;
	gca[7] ^= gca[t] | gc2;
}
void rs_2_07_09_2(int a) {
	--gul;
}
void rs_2_07_10_1(void) {
	int i = ji;
	for (i = 0; i < 6; i++) { vp(rp()); }
}
void rs_2_07_10_2(void) {
	gpi = gpi + 1;
}
void rs_2_07_10_3(void) {
	v1(r1(gi2));
}
long rs_2_07_10_4(void) {
	return (long)(gia[0] + gps->a[5]);
}
void rs_2_07_11_0(char *a, char b) {
	switch (gl2) { case 0L: gps->l += gl; case 1L: gs.d = -(double)*gpi; break; case 2L: gp = rp(); break; case 3L: gul = gula[b] | ((unsigned long)guc); break; case 4L: guca[3] = guca[0] % 100; break; case 5L: vu(gu2); break; }
}
void rs_2_07_11_1(char *a, char b) {
	guca[0] |= guca[b] << 3;
}
void rs_2_07_11_2(char *a, char b) {
	gu &= (gs.u & 0x80 ? gu2 : gps->u);
}
void rs_2_07_11_3(char *a, char b) {
	gul <<= 29;
}
void rs_2_07_12_1(long *a) {
	int t = r2(gi3, gi);
	ji = t;
}
void rs_2_07_12_2(long *a) {
	int t = ji;
	v0();
	gula[t] &= 73747UL;
}
void rs_2_07_12_3(long *a) {
	v0();
}
void rs_2_07_12_4(long *a) {
	int i = ji;
	v0();
	for (i = 0; i < 12; i++) { gl = a[2]; gl2 = ~(a[3] + *gpl); gs.p = gp; }
}
void rs_2_07_12_5(long *a) {
	int t = ji;
	v0();
	if (guca[t] > guc) gc2 = gca[t] = (' ') * (*gp + gc);
}
void rs_2_07_12_6(long *a) {
	int t = ji;
	v0();
	gs.a[t] = (int)gu2;
}
char rs_2_07_12_7(long *a) {
	int t = ji;
	v0();
	return (char)t;
}
void rs_2_07_13_0(int *a) {
	gd2 = ('z' == gca[0] ? gd : gs.d) - (gs.d / 100.0);
}
void rs_2_07_13_1(int *a) {
	gu++;
}
long rs_2_07_13_2(int *a) {
	return -34001L + rl(gla[0]);
}
void rs_2_07_14_0(int a, double b, unsigned long c) {
	guc = (unsigned char)*gpl;
}
void rs_2_07_14_1(int a, double b, unsigned long c) {
	guca[7] = guc = (guca[5] & guca[a]) / 10;
}
long rs_2_07_14_2(int a, double b, unsigned long c) {
	return ((gla[2] = gla[a]) <= -75293L ? ~*gpl : (gs.l | gla[5]));
}
void rs_2_07_15_0(char *a, int b, char *c) {
	char *t = a;
	jp = t;
}
void rs_2_07_15_1(char *a, int b, char *c) {
	int u = gps->a[b] + gi3;
	ji = u;
}
void rs_2_07_15_2(char *a, int b, char *c) {
	guca[4] = ~guc;
}
void rs_2_07_15_3(char *a, int b, char *c) {
	char *t = jp;
	vp(t);
}
void rs_2_07_15_4(char *a, int b, char *c) {
	int u = ji;
	v0();
	gi = u;
}
void rs_2_07_15_5(char *a, int b, char *c) {
	vu(ru(1));
}
int rs_2_07_15_6(char *a, int b, char *c) {
	return gs.i;
}
void rs_2_07_16_0(void) {
	gps->u = gu2 = (unsigned int)(gula[0] + 7UL);
}
void rs_2_07_16_1(void) {
	guca[4] = guc = 93;
}
unsigned int rs_2_07_16_2(void) {
	return gua[7] % 10;
}
void rs_2_07_17_0(unsigned long a, double b) {
	if (r2(gpi[3], gi)) vc((char)(1.0 != gda[2]));
}
void rs_2_07_17_1(unsigned long a, double b) {
	if (*gpl & 0x8) { gul += 0x10000UL - gul; if (gp[3] != 0) gca[6] = 1 % gp[3]; }
}
int * rs_2_07_17_2(unsigned long a, double b) {
	return gpi;
}
void rs_2_07_18_0(void) {
	gp = gs.p + 1;
}
void rs_2_07_18_1(void) {
	if (gs.d != gd && gs.l == 65536L) { gi3 = gia[3] = (gi3 << 3) * (gi >> 13); }
}
void rs_2_07_18_2(void) {
	++gp;
}
int * rs_2_07_18_3(void) {
	return gpi;
}
void rs_2_07_19_0(int a, unsigned long b) {
	int t = gi3;
	ji = t;
}
void rs_2_07_19_1(int a, unsigned long b) {
	gc = (gc2 >> 7) - (-29 - -85);
}
void rs_2_07_19_2(int a, unsigned long b) {
	v1(*gpi / 2);
}
void rs_2_07_19_3(int a, unsigned long b) {
	*gp |= gs.c % 2;
}
void rs_2_07_19_4(int a, unsigned long b) {
	int t = ji;
	v0();
	guca[t] -= (unsigned char)32767;
}
void rs_2_07_19_5(int a, unsigned long b) {
	int t = ji;
	v0();
	if ((gps->l = gpl[0]) < -17337L) { if (*gp != 0) gc2 = *gp / *gp; if (gula[t] != 0) b = gula[4] / gula[t]; --gl; }
}
int rs_2_07_19_6(int a, unsigned long b) {
	return gi;
}
void rs_2_08_00_0(void) {
	unsigned int t = gua[6] ^ gu2;
	ju = t;
}
void rs_2_08_00_1(void) {
	char *u = gp;
	jp = u;
}
void rs_2_08_00_2(void) {
	char *u = jp;
	vp(u);
}
void rs_2_08_00_3(void) {
	gd2 = -(-gs.d);
}
void rs_2_08_00_4(void) {
	unsigned int t = ju;
	v0();
	vu(t);
}
void rs_2_08_00_5(void) {
	if (gp[1] != 0 || (gl = gl2) != 65536L) *gpi = gs.a[0];
}
unsigned int rs_2_08_00_6(void) {
	char *u = jp;
	v0();
	return gs.u;
}
void rs_2_08_01_1(unsigned long a, char b, int *c) {
	if (gula[4]) { if (a != 0) gula[b] = a % a; } else { gda[1] = (gua[b] & 0x7 ? gda[2] : gd2); guc <<= 2; gps->c ^= gca[b]; }
}
void rs_2_08_01_2(unsigned long a, char b, int *c) {
	guc = (gua[b] & 1 ? guca[b] : (guc - 101));
}
void rs_2_08_01_3(unsigned long a, char b, int *c) {
	int i = ji;
	for (i = 0; i < 11; i++) { if (gu != 0) gu = ((unsigned int)gc2) % gu; if (gula[i] != 0) a = a / gula[i]; if (gu != 0) gua[i] = gua[5] / gu; }
}
void rs_2_08_01_4(unsigned long a, char b, int *c) {
	gd2 += gd2;
}
void rs_2_08_01_5(unsigned long a, char b, int *c) {
	gp = gps->p;
}
int rs_2_08_01_6(unsigned long a, char b, int *c) {
	return gi3;
}
void rs_2_08_02_1(char a) {
	int *t = gpi;
	jpi = t;
}
void rs_2_08_02_2(char a) {
	int *t = jpi;
	gpi = t;
}
void rs_2_08_02_3(char a) {
	vd(gd2 - gs.d);
}
void rs_2_08_02_4(char a) {
	int i = ji;
	v0();
	for (i = 9; i > 0; i--) { gi++; gla[i] = (gs.l - 5L) | gla[i]; }
}
int * rs_2_08_02_5(char a) {
	int *t = jpi;
	v0();
	return t;
}
void rs_2_08_03_1(char a, int b, int c) {
	long t = gl % 7L;
	jl = t;
}
void rs_2_08_03_2(char a, int b, int c) {
	int u = gpi[3] * 2;
	ji = u;
}
void rs_2_08_03_3(char a, int b, int c) {
	long t = jl;
	gl = t;
}
void rs_2_08_03_4(char a, int b, int c) {
	gpi--;
}
void rs_2_08_03_5(char a, int b, int c) {
	int i = ji;
	int u = ji;
	for (i = 0; i < c; i++) { if (gi2 != 0) gs.a[i] = gs.i / gi2; c = u = i; }
}
int rs_2_08_03_6(char a, int b, int c) {
	return *gpi ^ (gi / 10);
}
void rs_2_08_04_0(char *a, unsigned int b) {
	unsigned int t = gu2 & ((unsigned int)gi);
	ju = t;
}
void rs_2_08_04_1(char *a, unsigned int b) {
	unsigned int t = ju;
	int *u = gpi + t;
	jpi = u;
}
void rs_2_08_04_2(char *a, unsigned int b) {
	gl = (long)gps->c % 7L;
}
void rs_2_08_04_3(char *a, unsigned int b) {
	int *u = jpi;
	u = u + b;
}
void rs_2_08_04_4(char *a, unsigned int b) {
	gps->c = gc;
}
void rs_2_08_04_5(char *a, unsigned int b) {
	vp(&gca[b]);
}
void rs_2_08_04_6(char *a, unsigned int b) {
	unsigned int t = ju;
	int *u = jpi;
	v0();
	switch (gi3) { case 0: vp(gps->p); break; case 1: gps->l += gl2; break; case 2: case 3: gpi = u; break; case 4: vu(t); break; case 5: vs(gps); break; default: vd(gd); break; }
}
unsigned long rs_2_08_04_7(char *a, unsigned int b) {
	return gul;
}
void rs_2_08_05_0(int *a) {
	long t = gpl[2] ^ 65536L;
	jl = t;
}
void rs_2_08_05_1(int *a) {
	gpl[2] = 8L;
}
void rs_2_08_05_2(int *a) {
	long t = jl;
	gps->l = t;
}
char * rs_2_08_05_3(int *a) {
	return &gca[1];
}
void rs_2_08_06_1(long a, long *b, long c) {
	if (gu == gu2) gd = gs.d;
}
void rs_2_08_06_2(long a, long *b, long c) {
	int i = ji;
	for (i = 0; i < 13; i++) { b[3] = gl2; v2((gps->c != (char)gi), gi); vd(2.5); }
}
unsigned int rs_2_08_06_3(long a, long *b, long c) {
	return (unsigned int)!gla[4];
}
void rs_2_08_07_0(char *a, int b, unsigned long c) {
	char t = gca[0] << 2;
	jc = t;
}
void rs_2_08_07_1(char *a, int b, unsigned long c) {
	char t = jc;
	if (gpi[2] != 0) gi = gia[t] / gpi[2];
}
void rs_2_08_07_2(char *a, int b, unsigned long c) {
	char t = jc;
	guca[t] = (guc | 111) / 2;
}
void rs_2_08_07_3(char *a, int b, unsigned long c) {
	v0();
}
long rs_2_08_07_4(char *a, int b, unsigned long c) {
	return gps->l * 9L;
}
void rs_2_08_08_1(long a, int b, int c) {
	char *t = gp;
	jp = t;
}
void rs_2_08_08_2(long a, int b, int c) {
	char *t = jp;
	vp(t);
}
void rs_2_08_08_3(long a, int b, int c) {
	gpi = rpi((int)gul);
}
void rs_2_08_08_4(long a, int b, int c) {
	int i = ji;
	v0();
	for (i = 0; i < 15; i++) { v2(gi2, i * 9); if (*gpl != 0) gs.l = 7L % *gpl; if (gula[b] != 0) gula[i] = gula[i] % gula[b]; }
}
int * rs_2_08_08_5(long a, int b, int c) {
	if (100 < gi) return &gia[0];
}
int * rs_2_08_08_6(long a, int b, int c) {
	return gpi;
}
void rs_2_08_09_0(void) {
	int *t = gpi;
	jpi = t;
}
void rs_2_08_09_1(void) {
	unsigned char u = ((unsigned char)gu) - guc;
	juc = u;
}
void rs_2_08_09_2(void) {
	gl = gps->l + (19894L / 7L);
}
void rs_2_08_09_3(void) {
	unsigned char u = juc;
	gs.a[u] = r1(gi);
}
void rs_2_08_09_4(void) {
	switch (gs.i) { case 2: gl >>= 16; break; case 20: vs(gps); break; }
}
void rs_2_08_09_5(void) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_2_08_09_6(void) {
	while (gi > 0) { gc += *gp++; gi--; }
}
unsigned long rs_2_08_09_7(void) {
	return -0x10000UL;
}
void rs_2_08_10_0(unsigned long a, double b) {
	char t = -42;
	jc = t;
}
void rs_2_08_10_1(unsigned long a, double b) {
	unsigned long u = gula[4];
	jul = u;
}
void rs_2_08_10_2(unsigned long a, double b) {
	char t = jc;
	switch (gps->l) { case 2L: vc(gca[0]); break; case 5L: gd *= b; break; case 10L: gs.i <<= 13; break; case 100L: gpi = gpi + t; break; }
}
void rs_2_08_10_3(unsigned long a, double b) {
	gpl[0] = -gl;
}
void rs_2_08_10_4(unsigned long a, double b) {
	gs.l |= gla[6];
}
void rs_2_08_10_5(unsigned long a, double b) {
	char t = jc;
	unsigned long u = jul;
	v0();
	vu(gps->u * ((unsigned int)gula[t]));
}
long rs_2_08_10_6(unsigned long a, double b) {
	return (gps->l << 7) + (gps->l << 26);
}
void rs_2_08_11_0(long a, unsigned long b) {
	if (r2(gia[0], gi)) { if (gps->c != 0) gca[1] = gc2 / gps->c; gula[0] = b; guc += guca[4] - guc; }
}
void rs_2_08_11_1(long a, unsigned long b) {
	vl(gl2 << 8);
}
void rs_2_08_11_2(long a, unsigned long b) {
	gua[7] = gs.u;
}
void rs_2_08_11_3(long a, unsigned long b) {
	gl = -(~a);
}
int * rs_2_08_11_4(long a, unsigned long b) {
	return gpi + 1;
}
void rs_2_08_12_1(char *a, int *b, long c) {
	int t = ~gi2;
	ji = t;
}
void rs_2_08_12_2(char *a, int *b, long c) {
	int *u = gpi;
	jpi = u;
}
void rs_2_08_12_3(char *a, int *b, long c) {
	gs.c = ((guca[0] = guc) ? gp[1] : 3);
}
void rs_2_08_12_4(char *a, int *b, long c) {
	int i = ji;
	for (i = 0; i < 8; i++) { if (gu2 != 0) gua[i] = gua[i] % gu2; }
}
void rs_2_08_12_5(char *a, int *b, long c) {
	int t = ji;
	int *u = jpi;
	u[3] = !gps->a[t];
}
int rs_2_08_12_6(char *a, int *b, long c) {
	if (!gua[3]) return -40 - 255;
}
int rs_2_08_12_7(char *a, int *b, long c) {
	int t = ji;
	return (b[t] % 100) - (gia[t] & gi2);
}
void rs_2_08_13_1(int a, char *b, unsigned char c) {
	int i = ji;
	for (i = 0; i < a; i++) { gi >>= (a & 15); }
}
void rs_2_08_13_2(int a, char *b, unsigned char c) {
	c <<= 6;
}
void rs_2_08_13_3(int a, char *b, unsigned char c) {
	int i = ji;
	i = 0; while (i < 7) { a = r2(100, gi) << 11; i++; }
}
void rs_2_08_13_4(int a, char *b, unsigned char c) {
	v0();
}
void rs_2_08_13_5(int a, char *b, unsigned char c) {
	if (gu2 & 0x80) { guca[7] = (guca[c] + guc) >> 6; }
}
int rs_2_08_13_6(int a, char *b, unsigned char c) {
	return gia[0];
}
void rs_2_08_14_0(unsigned char a, unsigned int b, int c) {
	unsigned long t = (gul <= gula[0] ? gula[c] : gula[c]);
	jul = t;
}
void rs_2_08_14_1(unsigned char a, unsigned int b, int c) {
	gu *= 6;
}
void rs_2_08_14_2(unsigned char a, unsigned int b, int c) {
	gu2 |= gu;
}
void rs_2_08_14_3(unsigned char a, unsigned int b, int c) {
	unsigned long t = jul;
	gula[b] = t + gul;
}
void rs_2_08_14_4(unsigned char a, unsigned int b, int c) {
	vc('A');
}
void rs_2_08_14_5(unsigned char a, unsigned int b, int c) {
	gu2 = (gs.u + 13777) / 10;
}
int * rs_2_08_14_6(unsigned char a, unsigned int b, int c) {
	return gpi;
}
void rs_2_08_15_0(int a, unsigned long b) {
	a--;
}
void rs_2_08_15_1(int a, unsigned long b) {
	v2(gi2, -*gpi);
}
void rs_2_08_15_2(int a, unsigned long b) {
	gula[4] %= 7UL;
}
void rs_2_08_15_3(int a, unsigned long b) {
	gu2 = (unsigned int)(gl2 + gps->l);
}
void rs_2_08_15_4(int a, unsigned long b) {
	vd(gs.d);
}
int * rs_2_08_15_5(int a, unsigned long b) {
	return gpi + a;
}
void rs_2_08_16_0(unsigned int a) {
	int *t = &gia[a];
	jpi = t;
}
void rs_2_08_16_1(unsigned int a) {
	double u = gda[3];
	jd = u;
}
void rs_2_08_16_2(unsigned int a) {
	gps->a[a] = (gpi[1] - gi3) & (gi + *gpi);
}
void rs_2_08_16_3(unsigned int a) {
	double u = jd;
	vd(u);
}
char * rs_2_08_16_4(unsigned int a) {
	if (gula[a]) return gp;
}
void rs_2_08_16_5(unsigned int a) {
	int *t = jpi;
	v0();
	gpi = t;
}
char * rs_2_08_16_6(unsigned int a) {
	return gps->p;
}
void rs_2_08_17_0(long a, char b, int c) {
	double t = 100.0 - gda[2];
	jd = t;
}
void rs_2_08_17_1(long a, char b, int c) {
	double t = jd;
	vd(t);
}
void rs_2_08_17_2(long a, char b, int c) {
	gs.c = (char)!gul;
}
void rs_2_08_17_3(long a, char b, int c) {
	gc = gc2;
}
void rs_2_08_17_4(long a, char b, int c) {
	vu(gu2);
}
void rs_2_08_17_5(long a, char b, int c) {
	guc = guca[c];
}
int rs_2_08_17_6(long a, char b, int c) {
	return !gula[1] + gi3;
}
void rs_2_08_18_0(int a) {
	char t = rc(gi);
	jc = t;
}
void rs_2_08_18_1(int a) {
	gu = (gu2 / 100) + gps->u;
}
void rs_2_08_18_2(int a) {
	gpi = &gia[a];
}
void rs_2_08_18_3(int a) {
	v0();
}
void rs_2_08_18_4(int a) {
	char t = jc;
	v0();
	vc(t);
}
void rs_2_08_18_5(int a) {
	guca[4] = guca[a];
}
void rs_2_08_18_6(int a) {
	vd(gda[0]);
}
int * rs_2_08_18_7(int a) {
	return gpi + a;
}
void rs_2_08_19_1(int a, unsigned char b) {
	gla[b] = rl(gpl[1] << (b & 15));
}
void rs_2_08_19_2(int a, unsigned char b) {
	if (2L < 5L) { vu(gs.u); if (gul != 0) gula[a] = gula[1] / gul; vp(&gca[a]); } else { if (gl2 != 0) gla[b] = gl % gl2; if (gc != 0) gca[a] = gc / gc; if (gu != 0) gu2 = gua[4] / gu; }
}
void rs_2_08_19_3(int a, unsigned char b) {
	int i = ji;
	v0();
	for (i = 16; i > 0; i--) { if (gu != 0) gs.u = gu % gu; if (gc != 0) gps->c = gc / gc; }
}
int * rs_2_08_19_4(int a, unsigned char b) {
	return gpi + a;
}
void rs_2_09_00_0(void) {
	gd2 *= gs.d;
}
void rs_2_09_00_1(void) {
	gua[6] = gu = gua[3] * gua[7];
}
void rs_2_09_00_2(void) {
	gca[5] = gca[3];
}
void rs_2_09_00_3(void) {
	guc = ~guca[3] / 3;
}
char rs_2_09_00_4(void) {
	return rc(*gpi - gps->i);
}
void rs_2_09_01_0(int a, struct st *b) {
	int t = !((unsigned long)gs.u);
	ji = t;
}
void rs_2_09_01_1(int a, struct st *b) {
	*gp = gca[5] + '0';
}
void rs_2_09_01_2(int a, struct st *b) {
	if (gu2 & 1) gi2 -= *gpi >> 9;
}
void rs_2_09_01_3(int a, struct st *b) {
	int t = ji;
	gi = t;
}
int rs_2_09_01_4(int a, struct st *b) {
	return a - (a ^ 7);
}
void rs_2_09_02_0(int a) {
	unsigned long t = gula[3];
	jul = t;
}
void rs_2_09_02_1(int a) {
	unsigned long t = jul;
	gula[3] = (t & 0x10000UL) - ((unsigned long)guca[0]);
}
void rs_2_09_02_2(int a) {
	gua[a] = gu2;
}
void rs_2_09_03_0(long a) {
	int *t = gpi;
	jpi = t;
}
void rs_2_09_03_1(long a) {
	gca[0] >>= 2;
}
void rs_2_09_03_2(long a) {
	int *t = jpi;
	gpi = t;
}
void rs_2_09_03_3(long a) {
	v0();
}
unsigned long rs_2_09_03_4(long a) {
	return 0x10000UL / 7UL;
}
void rs_2_09_04_0(void) {
	long t = *gpl % 16L;
	jl = t;
}
void rs_2_09_04_1(void) {
	long t = jl;
	long u = t;
	jl = u;
}
void rs_2_09_04_2(void) {
	long t = jl;
	vl(t);
}
void rs_2_09_04_3(void) {
	guca[5] = -255;
}
void rs_2_09_04_4(void) {
	long u = jl;
	v0();
	gl = u;
}
void rs_2_09_04_5(void) {
	gda[1] -= (*gpl & 0x80 ? gs.d : 10.0);
}
void rs_2_09_04_6(void) {
	guc += 255;
}
void rs_2_09_04_7(void) {
	guc = guc - (128 - ((unsigned char)gs.a[7]));
}
int rs_2_09_04_8(void) {
	return r1(gps->i);
}
void rs_2_09_05_0(unsigned long a, long *b) {
	double t = gd2 * gd;
	jd = t;
}
void rs_2_09_05_1(unsigned long a, long *b) {
	unsigned long u = (gu & 4 ? gul : 0x10000UL);
	jul = u;
}
void rs_2_09_05_2(unsigned long a, long *b) {
	*b = *gpl;
}
void rs_2_09_05_3(unsigned long a, long *b) {
	double t = jd;
	gd = t;
}
void rs_2_09_05_4(unsigned long a, long *b) {
	gs.d += gd;
}
void rs_2_09_05_5(unsigned long a, long *b) {
	unsigned long u = jul;
	gua[7] = gps->u;
}
unsigned long rs_2_09_05_6(unsigned long a, long *b) {
	return (gula[7] % 4UL) / 4UL;
}
void rs_2_09_06_1(char a) {
	unsigned long t = gul << 6;
	jul = t;
}
void rs_2_09_06_2(char a) {
	v2(gi2, gi + gi3);
}
void rs_2_09_06_3(char a) {
	guc++;
}
void rs_2_09_06_4(char a) {
	int i = ji;
	unsigned long t = jul;
	v0();
	i = 4; do { gula[i] = t = rul(((unsigned long)gua[1]) & gul); guca[i] = ~((unsigned char)gl); gs.d *= gda[2]; } while (--i > 0);
}
void rs_2_09_06_5(char a) {
	if (a <= gc2) ++gp;
}
void rs_2_09_06_6(char a) {
	gl2 = (long)(((unsigned char)(gi2 <= gpi[0])) != (guca[a] >> 5));
}
long rs_2_09_06_7(char a) {
	return gl2 % 4L;
}
void rs_2_09_07_0(long a, unsigned long b) {
	char t = gc;
	jc = t;
}
void rs_2_09_07_1(long a, unsigned long b) {
	*gpi = gia[4] + gi3;
}
void rs_2_09_07_2(long a, unsigned long b) {
	gc /= 16;
}
void rs_2_09_07_3(long a, unsigned long b) {
	char t = jc;
	vc((gc & 0x10 ? t : gca[t]));
}
unsigned int rs_2_09_07_4(long a, unsigned long b) {
	return gs.u;
}
void rs_2_09_08_0(unsigned long a, double b) {
	unsigned long t = (unsigned long)gu;
	jul = t;
}
void rs_2_09_08_1(unsigned long a, double b) {
	guca[5] &= (unsigned char)!20350;
}
void rs_2_09_08_2(unsigned long a, double b) {
	gula[0] = (unsigned long)!gua[2];
}
void rs_2_09_08_3(unsigned long a, double b) {
	unsigned long t = jul;
	if (gps->u) if (t != 0) gul = t / t;
}
unsigned long rs_2_09_08_4(unsigned long a, double b) {
	unsigned long t = jul;
	return (t = 2UL);
}
void rs_2_09_09_0(struct st *a) {
	if (0UL < 0x10000UL) { gpl[2] /= 7L; if (gla[0] != 0) *gpl = 65536L % gla[0]; }
}
void rs_2_09_09_1(struct st *a) {
	if (gi3 != 0) gps->a[2] = gi2 / gi3;
}
unsigned int rs_2_09_09_2(struct st *a) {
	return gu2;
}
void rs_2_09_10_0(int a, int b) {
	int t = (int)gl2;
	ji = t;
}
void rs_2_09_10_1(int a, int b) {
	v2(gi2, gs.i);
}
void rs_2_09_10_2(int a, int b) {
	if (gula[7] != 0) gul = ((unsigned long)gca[4]) / gula[7];
}
void rs_2_09_10_3(int a, int b) {
	int t = ji;
	v0();
	gi = t;
}
void rs_2_09_10_4(int a, int b) {
	if (gu) { gs.c ^= ~gc; if (a != 0) b = a / a; vd(gd2); }
}
void rs_2_09_10_5(int a, int b) {
	guca[1] = guca[4] << 3;
}
void rs_2_09_10_6(int a, int b) {
	gi3 = (gpi[2] / 2) << 13;
}
int rs_2_09_10_7(int a, int b) {
	return -b - (*gpi + gpi[1]);
}
void rs_2_09_11_0(int *a, double b) {
	while (gi-- > 0) { if (*a == 781) break; a++; }
}
void rs_2_09_11_1(int *a, double b) {
	gca[1] = rc(gs.i);
}
void rs_2_09_11_2(int *a, double b) {
	gs.d = gd2;
}
void rs_2_09_11_3(int *a, double b) {
	vp(gp);
}
unsigned long rs_2_09_11_4(int *a, double b) {
	return rul(gula[4]);
}
void rs_2_09_12_1(unsigned int a, unsigned int b, int c) {
	guc = guca[6] = 255;
}
void rs_2_09_12_2(unsigned int a, unsigned int b, int c) {
	int i = ji;
	for (i = 0; i < c; i++) { a >>= 2; }
}
int * rs_2_09_12_3(unsigned int a, unsigned int b, int c) {
	return &gia[3];
}
void rs_2_09_13_0(unsigned int a, char b, int c) {
	long t = gpl[1] << (a & 15);
	jl = t;
}
void rs_2_09_13_1(unsigned int a, char b, int c) {
	--gpi;
}
void rs_2_09_13_2(unsigned int a, char b, int c) {
	long t = jl;
	gl2 = t;
}
void rs_2_09_13_3(unsigned int a, char b, int c) {
	long t = jl;
	gl = (guc & 4 ? *gpl : (t << (b & 15)));
}
char * rs_2_09_13_4(unsigned int a, char b, int c) {
	return rp();
}
void rs_2_09_14_0(unsigned long a) {
	while (gi-- > 0) *gpi++ = 255;
}
void rs_2_09_14_1(unsigned long a) {
	gca[1] %= 16;
}
void rs_2_09_14_2(unsigned long a) {
	*gpi = gia[4] = -(~gs.a[0]);
}
void rs_2_09_14_3(unsigned long a) {
	if (gpi[0] >= gi2 && gc != 'a') { gu2 = ru(gu2 - gs.u); } else { gi = gi3 >> 2; }
}
void rs_2_09_14_4(unsigned long a) {
	gi++;
}
char * rs_2_09_14_5(unsigned long a) {
	return &gca[3];
}
void rs_2_09_15_1(void) {
	int t = (int)guc;
	ji = t;
}
void rs_2_09_15_2(void) {
	int i = ji;
	int u = gs.i;
	ji = u;
}
void rs_2_09_15_3(void) {
	int u = ji;
	gul >>= (u & 15);
}
void rs_2_09_15_4(void) {
	gula[7] = gul;
}
void rs_2_09_15_5(void) {
	int t = ji;
	gi3 = t = gi / 3;
}
void rs_2_09_15_6(void) {
	int i = ji;
	int t = ji;
	for (i = 0; i < 3; i++) { v2((((unsigned int)guca[t]) <= gu2), gi); }
}
int * rs_2_09_15_7(void) {
	return gpi;
}
void rs_2_09_16_0(long a, int *b) {
	unsigned long t = gula[3];
	jul = t;
}
void rs_2_09_16_1(long a, int *b) {
	unsigned int u = gua[5] ^ gu2;
	ju = u;
}
void rs_2_09_16_2(long a, int *b) {
	unsigned int u = ju;
	if (r2(gi2, gs.a[u])) vp(gps->p);
}
void rs_2_09_16_3(long a, int *b) {
	unsigned long t = jul;
	v0();
	gul = t;
}
void rs_2_09_16_4(long a, int *b) {
	unsigned int u = ju;
	v0();
	gpl[3] &= 3589L & gla[u];
}
long rs_2_09_16_5(long a, int *b) {
	return (gl2 & gps->l) >> 7;
}
void rs_2_09_17_0(int a) {
	int t = r1(127);
	ji = t;
}
void rs_2_09_17_1(int a) {
	long u = gl2;
	v0();
	jl = u;
}
void rs_2_09_17_2(int a) {
	long u = jl;
	v0();
	gl = gs.l = u / 100L;
}
void rs_2_09_17_3(int a) {
	vu(gua[2]);
}
void rs_2_09_17_4(int a) {
	int t = ji;
	v0();
	t = a;
}
void rs_2_09_17_5(int a) {
	gi3 *= 8;
}
void rs_2_09_17_6(int a) {
	gia[a] += a;
}
int * rs_2_09_17_7(int a) {
	return &gia[2];
}
void rs_2_09_18_1(struct st *a, long *b) {
	int t = 16 ^ gia[2];
	ji = t;
}
void rs_2_09_18_2(struct st *a, long *b) {
	int *u = rpi(gi3);
	jpi = u;
}
void rs_2_09_18_3(struct st *a, long *b) {
	gul ^= gula[0] | gul;
}
void rs_2_09_18_4(struct st *a, long *b) {
	int *u = jpi;
	v0();
	v1(*u);
}
void rs_2_09_18_5(struct st *a, long *b) {
	int t = ji;
	v0();
	gul = gula[t] % 7UL;
}
void rs_2_09_18_6(struct st *a, long *b) {
	int i = ji;
	v0();
	i = 13; do { gp--; } while (--i > 0);
}
char rs_2_09_18_7(struct st *a, long *b) {
	return '9';
}
void rs_2_09_19_1(unsigned int a) {
	char t = -gps->c;
	jc = t;
}
void rs_2_09_19_2(unsigned int a) {
	char t = jc;
	char u = t;
	jc = u;
}
void rs_2_09_19_3(unsigned int a) {
	guca[1] &= guca[a];
}
void rs_2_09_19_4(unsigned int a) {
	char u = jc;
	if (gia[u] & 0x10) if (gia[2] != 0) gs.a[u] = 8 / gia[2];
}
void rs_2_09_19_5(unsigned int a) {
	int i = ji;
	for (i = 2; i > 0; i--) { vu(a); vd(-gd); if (gia[a] != 0) gi3 = *gpi % gia[a]; }
}
void rs_2_09_19_6(unsigned int a) {
	int i = ji;
	char t = jc;
	char u = jc;
	v0();
	if (r2(gi2, gps->i)) { if (gc2 != 0) t = t % gc2; gca[a] ^= (char)(gps->u != 256); vc(gs.c / 10); } else { gua[t] *= 12; if (gula[3] != 0) gul = gul % gula[3]; if (*gpl != 0) gla[0] = gl2 / *gpl; }
}
int * rs_2_09_19_7(unsigned int a) {
	return gpi;
}
