/* Every statement line of random10 alone in its own function (gen_rstmt.py corpus/random10 10): rs_<A>_<BB>_<CC>_<k> is line k of
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

void rs_10_00_00_0(char a) {
	int *t = gpi;
	jpi = t;
}
void rs_10_00_00_1(char a) {
	if (gu) gul = gul / 10UL;
}
unsigned long rs_10_00_00_2(char a) {
	if (11224 != gu2) return gul;
}
void rs_10_00_00_3(char a) {
	int *t = jpi;
	if (*gpl & 0x8) { gs.i = gi3; vp(&gca[a]); t[6] -= 1; } else { v0(); vc(~gc); guca[a] >>= 5; }
}
unsigned long rs_10_00_00_4(char a) {
	return ~(gula[1] & gula[a]);
}
void rs_10_00_01_1(int a, unsigned int b) {
	double t = -10.0;
	jd = t;
}
void rs_10_00_01_2(int a, unsigned int b) {
	if (!gca[0]) { guc++; gu2 = (gu2 - 28981) & 1; } else { *gp = gs.c; --gl2; }
}
void rs_10_00_01_3(int a, unsigned int b) {
	int i = ji;
	double t = jd;
	i = 0; while (i < a) { v0(); gu ^= gu2; gd = -(gd2 - t); i++; }
}
void rs_10_00_01_4(int a, unsigned int b) {
	gu2 = ru(gu2 - gu);
}
void rs_10_00_01_5(int a, unsigned int b) {
	int i = ji;
	v0();
	i = 0; while (i < 3) { vl((long)gps->u); gu &= 8; i++; }
}
int rs_10_00_01_6(int a, unsigned int b) {
	int i = ji;
	v0();
	return gs.i;
}
void rs_10_00_02_0(int a) {
	if ((gps->c = 2) > 0) gd2 = gda[3];
}
unsigned long rs_10_00_02_1(int a) {
	if (gu) return 97064UL - 7UL;
}
unsigned long rs_10_00_02_2(int a) {
	return (0x10000UL + gul) >> 21;
}
void rs_10_00_03_0(unsigned int a) {
	long t = gl;
	jl = t;
}
void rs_10_00_03_1(unsigned int a) {
	unsigned char u = (unsigned char)gul;
	juc = u;
}
void rs_10_00_03_2(unsigned int a) {
	gul = rul(gula[6]) + gula[a];
}
void rs_10_00_03_3(unsigned int a) {
	unsigned char u = juc;
	v0();
	guc = u;
}
void rs_10_00_03_4(unsigned int a) {
	if (gi2) if (gs.a[a] != 0) gi2 = gi3 / gs.a[a];
}
void rs_10_00_03_5(unsigned int a) {
	if (gul != 0) gul = gula[6] / gul;
}
void rs_10_00_03_6(unsigned int a) {
	vs(gps);
}
void rs_10_00_03_7(unsigned int a) {
	long t = jl;
	v0();
	gl = t;
}
char * rs_10_00_03_8(unsigned int a) {
	return &gca[a];
}
void rs_10_00_04_0(unsigned int a) {
	double t = gda[3] / 100.0;
	jd = t;
}
void rs_10_00_04_1(unsigned int a) {
	long u = gla[a];
	jl = u;
}
void rs_10_00_04_2(unsigned int a) {
	gs.c = gca[0] / 16;
}
void rs_10_00_04_3(unsigned int a) {
	gi3 = gia[a] = (int)gu;
}
void rs_10_00_04_4(unsigned int a) {
	long u = jl;
	gl = u;
}
void rs_10_00_04_5(unsigned int a) {
	double t = jd;
	gd = t;
}
long rs_10_00_04_6(unsigned int a) {
	return gla[a];
}
void rs_10_00_05_1(unsigned int a, double b, int c) {
	int t = (int)gl;
	ji = t;
}
void rs_10_00_05_2(unsigned int a, double b, int c) {
	int i = ji;
	int *u = rpi(gps->i);
	jpi = u;
}
void rs_10_00_05_3(unsigned int a, double b, int c) {
	int t = ji;
	v0();
	if (*gpi != 0) gia[c] = t / *gpi;
}
void rs_10_00_05_4(unsigned int a, double b, int c) {
	int i = ji;
	v0();
	c = gs.a[7] - (127 & gps->i);
}
void rs_10_00_05_5(unsigned int a, double b, int c) {
	int *u = jpi;
	v0();
	gpi = u;
}
void rs_10_00_05_6(unsigned int a, double b, int c) {
	int i = ji;
	v0();
	i = 0; while (i < c) { gl |= gl2; gp = rp(); if (a != 0) gu = gu % a; i++; }
}
void rs_10_00_05_7(unsigned int a, double b, int c) {
	gp++;
}
int rs_10_00_05_8(unsigned int a, double b, int c) {
	int t = ji;
	v0();
	return -t - -gi;
}
void rs_10_00_06_1(void) {
	char t = (char)5;
	jc = t;
}
void rs_10_00_06_2(void) {
	char t = jc;
	vc(t);
}
void rs_10_00_06_3(void) {
	gula[5] &= ((unsigned long)*gpl) + gula[6];
}
void rs_10_00_06_4(void) {
	int i = ji;
	v0();
	for (i = 0; i < 4; i++) { if (gs.u != 0) gu = gua[i] % gs.u; }
}
char * rs_10_00_06_5(void) {
	char t = jc;
	v0();
	return gps->p + t;
}
void rs_10_00_07_1(void) {
	char t = (char)!0x10000UL;
	jc = t;
}
void rs_10_00_07_2(void) {
	double u = 0.25 - gda[2];
	jd = u;
}
void rs_10_00_07_3(void) {
	int i = ji;
	double u = jd;
	i = 8; do { gps->u = (gs.u >> 11) * 2; ++gu; if (*gpi != 0) gia[i] = gi % *gpi; } while (--i > 0);
}
void rs_10_00_07_4(void) {
	char t = jc;
	gc = t;
}
void rs_10_00_07_5(void) {
	if (2 < gi3) if (gl2 != 0) gps->l = gps->l / gl2;
}
void rs_10_00_07_6(void) {
	gc2 -= gca[7] - gca[4];
}
int rs_10_00_07_7(void) {
	char t = jc;
	return gs.a[t];
}
void rs_10_00_08_0(char a, char *b) {
	int t = gi3 + 255;
	ji = t;
}
void rs_10_00_08_1(char a, char *b) {
	if (gu2 > gua[a]) { gd -= gd2 - gd; }
}
void rs_10_00_08_2(char a, char *b) {
	gpi = gpi + a;
}
void rs_10_00_08_3(char a, char *b) {
	int t = ji;
	gi = t;
}
int rs_10_00_08_4(char a, char *b) {
	return (gi = gpi[0]);
}
void rs_10_00_09_0(void) {
	char t = (char)40212UL;
	jc = t;
}
void rs_10_00_09_1(void) {
	char t = jc;
	gua[t] = gu2 << (t & 15);
}
void rs_10_00_09_2(void) {
	gps->l = (long)gula[5] + gps->l;
}
void rs_10_00_09_3(void) {
	vl(rl(-58801L));
}
char * rs_10_00_09_4(void) {
	return gps->p;
}
void rs_10_00_10_0(char *a) {
	if (gp[1] != 0) *gp = gc2 / gp[1];
}
void rs_10_00_10_1(char *a) {
	gul = (gul - 1UL) ^ gula[1];
}
void rs_10_00_10_2(char *a) {
	if (gca[7] != 0) gca[6] = gc2 % gca[7];
}
void rs_10_00_10_3(char *a) {
	gs.l |= (long)!*gpi;
}
int rs_10_00_10_4(char *a) {
	return ((int)guc / 2) >> 7;
}
void rs_10_00_11_0(unsigned int a, unsigned int b) {
	int t = (int)gul | gps->a[7];
	ji = t;
}
char * rs_10_00_11_1(unsigned int a, unsigned int b) {
	if ((char)gu2 > gc) return gs.p;
}
void rs_10_00_11_2(unsigned int a, unsigned int b) {
	int t = ji;
	gi2 = t;
}
char * rs_10_00_11_3(unsigned int a, unsigned int b) {
	return rp();
}
void rs_10_00_12_0(long a, double b, unsigned int c) {
	if (guc) gu <<= 11;
}
void rs_10_00_12_1(long a, double b, unsigned int c) {
	guca[c] = 255 + guc;
}
void rs_10_00_12_2(long a, double b, unsigned int c) {
	if (a != 0) gl2 = 38572L % a;
}
void rs_10_00_12_3(long a, double b, unsigned int c) {
	guca[1] += ((unsigned char)gu2) - 255;
}
unsigned long rs_10_00_12_4(long a, double b, unsigned int c) {
	return gula[c];
}
void rs_10_00_13_1(int *a, unsigned char b) {
	switch (gi) { case 0: gul = (unsigned long)!a[b]; break; case 1: case 2: gi = gs.a[7] << (b & 15); break; case 3: case 4: vp(gs.p); break; case 5: gua[b] = gu + gu2; break; default: v1(gia[b]); break; }
}
void rs_10_00_13_2(int *a, unsigned char b) {
	int i = ji;
	v0();
	i = 0; while (i < 14) { if (gl2 != 0) gpl[3] = gl % gl2; gs.l = -45543L; gps->c = 1 ^ *gp; i++; }
}
void rs_10_00_13_3(int *a, unsigned char b) {
	v0();
}
void rs_10_00_13_4(int *a, unsigned char b) {
	if ((int)gul < 256) { if (gula[b] != 0) gula[5] = gul % gula[b]; gua[2] = ~(gs.u ^ 22621); } else { b <<= 5; vp(gps->p); }
}
void rs_10_00_13_5(int *a, unsigned char b) {
	v0();
}
void rs_10_00_14_0(char a) {
	if (gula[1] != 0) gul = gul % gula[1];
}
void rs_10_00_14_1(char a) {
	gu2++;
}
void rs_10_00_14_2(char a) {
	gs.i <<= (a & 15);
}
void rs_10_00_14_3(char a) {
	v0();
}
long rs_10_00_14_4(char a) {
	return gla[a];
}
void rs_10_00_15_0(char *a, unsigned char b) {
	int *t = gpi + b;
	jpi = t;
}
void rs_10_00_15_1(char *a, unsigned char b) {
	gu2 >>= 3;
}
void rs_10_00_15_2(char *a, unsigned char b) {
	gula[6] = gul = 45565UL;
}
void rs_10_00_15_3(char *a, unsigned char b) {
	if (gs.d == 3.0) { guc = (guc * 255) % 4; gula[b] = gul - 26269UL; }
}
void rs_10_00_15_4(char *a, unsigned char b) {
	guc ^= ((unsigned char)gu) - ((unsigned char)gul);
}
void rs_10_00_15_5(char *a, unsigned char b) {
	int *t = jpi;
	gpi = t;
}
void rs_10_00_15_6(char *a, unsigned char b) {
	gua[b] = gu2;
}
int * rs_10_00_15_7(char *a, unsigned char b) {
	return gpi + b;
}
void rs_10_00_16_0(long a, struct st *b) {
	unsigned char t = guc + 128;
	juc = t;
}
void rs_10_00_16_1(long a, struct st *b) {
	unsigned char t = juc;
	unsigned char u = t;
	juc = u;
}
void rs_10_00_16_2(long a, struct st *b) {
	gl2 = gla[3];
}
void rs_10_00_16_3(long a, struct st *b) {
	unsigned char t = juc;
	v1(t);
}
void rs_10_00_16_4(long a, struct st *b) {
	unsigned char u = juc;
	v0();
	guc = u;
}
void rs_10_00_16_5(long a, struct st *b) {
	v0();
}
char * rs_10_00_16_6(long a, struct st *b) {
	return gp;
}
void rs_10_00_17_0(void) {
	double t = (5L != 3L ? gd2 : gd2);
	jd = t;
}
void rs_10_00_17_1(void) {
	unsigned int u = (unsigned int)-81134L;
	ju = u;
}
void rs_10_00_17_2(void) {
	double t = jd;
	gd = t;
}
void rs_10_00_17_3(void) {
	unsigned int u = ju;
	v1((int)u);
}
void rs_10_00_17_4(void) {
	gi = gi / 100;
}
void rs_10_00_17_5(void) {
	unsigned int u = ju;
	v0();
	gia[u] |= gi3;
}
int rs_10_00_17_6(void) {
	return (int)guca[0] >> 4;
}
char * rs_10_00_18_0(void) {
	if (gl >= gl2) return gp;
}
void rs_10_00_18_1(void) {
	guc = (guca[2] | guc) ^ (guc % 100);
}
void rs_10_00_18_2(void) {
	gu2 = (r2(gi2, gps->i) ? (gu2 + gua[6]) : (gu2 << 13));
}
char * rs_10_00_18_3(void) {
	return gp + 1;
}
void rs_10_00_19_0(double a, char b, int c) {
	char t = b;
	jc = t;
}
void rs_10_00_19_1(double a, char b, int c) {
	unsigned int u = (unsigned int)gia[c];
	ju = u;
}
void rs_10_00_19_2(double a, char b, int c) {
	char t = jc;
	vc(t);
}
void rs_10_00_19_3(double a, char b, int c) {
	gp = gs.p + b;
}
void rs_10_00_19_4(double a, char b, int c) {
	gi = gs.i = gi3 | (1 - gia[6]);
}
void rs_10_00_19_5(double a, char b, int c) {
	v0();
}
int rs_10_00_19_6(double a, char b, int c) {
	if (c) return !gul;
}
void rs_10_00_19_7(double a, char b, int c) {
	unsigned int u = ju;
	v0();
	gu = u;
}
void rs_10_00_19_8(double a, char b, int c) {
	gpi = &gia[4];
}
int rs_10_00_19_9(double a, char b, int c) {
	return (gi2 + 1) + 256;
}
void rs_10_01_00_0(char *a, unsigned int b, char *c) {
	vl(gl ^ gla[b]);
}
void rs_10_01_00_1(char *a, unsigned int b, char *c) {
	gul <<= 7;
}
unsigned long rs_10_01_00_2(char *a, unsigned int b, char *c) {
	return 2UL;
}
void rs_10_01_01_0(void) {
	gd2 = (r1((int)guc) ? (gd - gd2) : (gs.d - gd));
}
void rs_10_01_01_1(void) {
	if (gul != 0) gula[3] = gula[6] % gul;
}
void rs_10_01_01_2(void) {
	gu2 <<= 6;
}
unsigned int rs_10_01_01_3(void) {
	return gps->u;
}
void rs_10_01_02_1(void) {
	unsigned char t = (unsigned char)(guca[5] < guc);
	juc = t;
}
void rs_10_01_02_2(void) {
	unsigned char t = juc;
	if (((unsigned long)gs.u) <= gul || !gp[0]) { if (gps->l != 0) gl2 = *gpl / gps->l; v1(gi / 16); *gpl = gpl[0] + gl2; } else { t = (255 - t) >> 1; }
}
void rs_10_01_02_3(void) {
	gula[0] = gul & gula[7];
}
void rs_10_01_02_4(void) {
	int i = ji;
	unsigned char t = juc;
	v0();
	i = 0; while (i < 9) { t--; vu(gu2 + 13548); i++; }
}
void rs_10_01_02_5(void) {
	unsigned char t = juc;
	v0();
	t = 3;
}
void rs_10_01_02_6(void) {
	unsigned char t = juc;
	v0();
	gc = gps->c = (gc << 7) & gca[t];
}
int * rs_10_01_02_7(void) {
	return rpi(gi2);
}
void rs_10_01_03_0(int a, char *b, int c) {
	int t = 1 - c;
	ji = t;
}
void rs_10_01_03_1(int a, char *b, int c) {
	switch (gl) { case 0L: vc(b[0]); break; case 1L: gca[a] = *gp ^ gs.c; break; case 2L: vp(b); break; case 3L: gs.d = (double)gpi[2]; break; }
}
void rs_10_01_03_2(int a, char *b, int c) {
	gpi++;
}
void rs_10_01_03_3(int a, char *b, int c) {
	int t = ji;
	v0();
	if (r2(t, gi)) { gc++; }
}
int rs_10_01_03_4(int a, char *b, int c) {
	return (gi2 = 8);
}
void rs_10_01_04_1(unsigned int a, char b, char c) {
	long t = gl2;
	jl = t;
}
void rs_10_01_04_2(unsigned int a, char b, char c) {
	long u = gla[c] << 17;
	jl = u;
}
void rs_10_01_04_3(unsigned int a, char b, char c) {
	vc(gca[6]);
}
void rs_10_01_04_4(unsigned int a, char b, char c) {
	int i = ji;
	long t = jl;
	long u = jl;
	v0();
	for (i = 0; i < 3; i++) { if (t != 0) u = gl2 % t; gu2 = gua[i] = (unsigned int)(~256 <= (gi2 % 7)); if (gu != 0) gs.u = gps->u % gu; }
}
void rs_10_01_04_5(unsigned int a, char b, char c) {
	gi2++;
}
void rs_10_01_04_6(unsigned int a, char b, char c) {
	int i = ji;
	long t = jl;
	long u = jl;
	v0();
	for (i = 0; i < 7; i++) { if (u != 0) u = gl / u; u = ~(t ^ 65536L); }
}
void rs_10_01_05_1(int a) {
	int i = ji;
	int t = gps->i;
	ji = t;
}
void rs_10_01_05_2(int a) {
	unsigned int u = 17806 + ((unsigned int)*gp);
	ju = u;
}
void rs_10_01_05_3(int a) {
	int t = ji;
	unsigned int u = ju;
	gua[t] = ru(u);
}
void rs_10_01_05_4(int a) {
	int i = ji;
	unsigned int u = ju;
	v0();
	for (i = 0; i < 4; i++) { if (gca[i] != 0) gs.c = gps->c % gca[i]; gu2 &= gs.u % 100; }
}
void rs_10_01_05_5(int a) {
	gul = rul(90412UL - gul);
}
int rs_10_01_05_6(int a) {
	int t = ji;
	v0();
	return (t - 127) << 12;
}
void rs_10_01_06_0(unsigned long a, int *b) {
	int *t = gpi + 1;
	jpi = t;
}
void rs_10_01_06_1(unsigned long a, int *b) {
	unsigned char u = 4 + guc;
	juc = u;
}
void rs_10_01_06_2(unsigned long a, int *b) {
	int *t = jpi;
	unsigned char u = juc;
	if (b[3] <= t[u] && gc != 2) { u -= u - 19; vd(-gda[3]); if (gc != 0) gc = gps->c / gc; } else { if (gia[u] != 0) gia[7] = 100 / gia[u]; }
}
void rs_10_01_06_3(unsigned long a, int *b) {
	int *t = jpi;
	unsigned char u = juc;
	v0();
	t = &gia[u];
}
void rs_10_01_06_4(unsigned long a, int *b) {
	gd = gs.d;
}
void rs_10_01_06_5(unsigned long a, int *b) {
	vs(gps);
}
void rs_10_01_06_6(unsigned long a, int *b) {
	unsigned char u = juc;
	v0();
	gpi = b + u;
}
char * rs_10_01_06_7(unsigned long a, int *b) {
	unsigned char u = juc;
	v0();
	return &gca[u];
}
void rs_10_01_07_0(void) {
	long t = gps->l * 9L;
	jl = t;
}
void rs_10_01_07_1(void) {
	unsigned long u = ((unsigned long)*gp) + 0x10000UL;
	jul = u;
}
void rs_10_01_07_2(void) {
	unsigned long u = jul;
	u = gula[4] = (unsigned long)!gua[7];
}
void rs_10_01_07_3(void) {
	guc = ~guc % 4;
}
void rs_10_01_07_4(void) {
	gc2 = -gc2 + (*gp + gc);
}
void rs_10_01_07_5(void) {
	gc %= 7;
}
void rs_10_01_07_6(void) {
	long t = jl;
	vl(t);
}
long rs_10_01_07_7(void) {
	unsigned long u = jul;
	v0();
	return (gl = (long)u);
}
void rs_10_01_08_0(char a, unsigned int b) {
	vu(gu2);
}
void rs_10_01_08_1(char a, unsigned int b) {
	vs(gps);
}
void rs_10_01_08_2(char a, unsigned int b) {
	gua[1] &= ru(gu2);
}
void rs_10_01_08_3(char a, unsigned int b) {
	vs(gps);
}
void rs_10_01_08_4(char a, unsigned int b) {
	gpl[0] += 48112L * gl2;
}
int * rs_10_01_08_5(char a, unsigned int b) {
	return gpi + a;
}
void rs_10_01_09_0(int a, int b, char *c) {
	int t = -gi3;
	ji = t;
}
void rs_10_01_09_1(int a, int b, char *c) {
	int t = ji;
	int u = gi3 ^ t;
	ji = u;
}
void rs_10_01_09_2(int a, int b, char *c) {
	int u = ji;
	gu2 = ru(gu) + (gs.u - gua[0]);
}
void rs_10_01_09_3(int a, int b, char *c) {
	gc = *c;
}
void rs_10_01_09_4(int a, int b, char *c) {
	guc--;
}
void rs_10_01_09_5(int a, int b, char *c) {
	int t = ji;
	v0();
	v1(t);
}
void rs_10_01_09_6(int a, int b, char *c) {
	gua[6] = (gua[3] & 0x7 ? 255 : gu2);
}
unsigned long rs_10_01_09_7(int a, int b, char *c) {
	return rul((!gula[7] ? gul : 82704UL));
}
void rs_10_01_10_1(unsigned long a) {
	unsigned long t = 7UL;
	jul = t;
}
void rs_10_01_10_2(unsigned long a) {
	double u = (gul ? gda[0] : gs.d);
	jd = u;
}
void rs_10_01_10_3(unsigned long a) {
	int i = ji;
	if (gu < 9 && r2(gi, gi)) { guca[6] = -((unsigned char)gps->i); gca[6] = *gp = gs.c; }
}
void rs_10_01_10_4(unsigned long a) {
	double u = jd;
	v0();
	gd = u;
}
void rs_10_01_10_5(unsigned long a) {
	unsigned long t = jul;
	v0();
	gul = t;
}
void rs_10_01_10_6(unsigned long a) {
	int i = ji;
	v0();
	i = 5; do { guc /= 3; --gl; gia[i] = -gs.a[i]; } while (--i > 0);
}
int rs_10_01_10_7(unsigned long a) {
	if ((gc2 = gc)) return gi3;
}
int rs_10_01_10_8(unsigned long a) {
	return -586;
}
void rs_10_01_11_1(int a, struct st *b) {
	gl = gla[a];
}
void rs_10_01_11_2(int a, struct st *b) {
	if (gc != 0) gca[4] = gp[1] % gc;
}
void rs_10_01_11_3(int a, struct st *b) {
	int i = ji;
	for (i = 0; i < a; i++) { if (gc != 0) gca[i] = b->c / gc; guca[i] = guca[i] + ((unsigned char)(gs.c != b->c)); }
}
void rs_10_01_12_0(void) {
	gc2 = (char)(guc == (guc | 3));
}
void rs_10_01_12_1(void) {
	gd2 = (gula[5] == 11304UL ? gda[3] : (gd2 + 0.25));
}
void rs_10_01_12_2(void) {
	v2(gi2, gia[4] - gps->a[2]);
}
void rs_10_01_12_3(void) {
	gua[1] += gu2 << 3;
}
char * rs_10_01_12_4(void) {
	return rp();
}
void rs_10_01_13_0(int a) {
	unsigned char t = guc - guca[a];
	juc = t;
}
void rs_10_01_13_1(int a) {
	unsigned char t = juc;
	v1(t);
}
void rs_10_01_13_2(int a) {
	gc++;
}
void rs_10_01_13_3(int a) {
	gpi = gpi + a;
}
int * rs_10_01_13_4(int a) {
	return &gia[2];
}
void rs_10_01_14_0(int a) {
	if (gul != 0) gul = gul % gul;
}
void rs_10_01_14_1(int a) {
	gl2 &= gl;
}
int rs_10_01_14_2(int a) {
	return a;
}
void rs_10_01_15_1(void) {
	double t = gda[0];
	jd = t;
}
void rs_10_01_15_2(void) {
	gpi++;
}
void rs_10_01_15_3(void) {
	int i = ji;
	for (i = 0; i < 13; i++) { if (gps->u != 0) gua[i] = gu % gps->u; if (*gp != 0) gc = gc2 % *gp; }
}
void rs_10_01_15_4(void) {
	*gpl = gps->l = (gpl[3] << 16) + ((long)gpi[3] + gps->l);
}
void rs_10_01_15_5(void) {
	double t = jd;
	gd = t;
}
void rs_10_01_15_6(void) {
	gi3 = (int)gps->u;
}
void rs_10_01_15_7(void) {
	gpi = &gia[1];
}
int rs_10_01_15_8(void) {
	return ~(gps->a[0] ^ gi2);
}
void rs_10_01_16_0(char a) {
	int *t = gpi;
	jpi = t;
}
void rs_10_01_16_1(char a) {
	char u = rc(8);
	jc = u;
}
void rs_10_01_16_2(char a) {
	gps->l = rl((long)(guca[a] != guc));
}
void rs_10_01_16_3(char a) {
	char u = jc;
	v0();
	gc = u;
}
void rs_10_01_16_4(char a) {
	guc = guca[a] = (guca[6] - guc) * (guc + ((unsigned char)gula[a]));
}
void rs_10_01_16_5(char a) {
	a = *gp = gca[7] + (28 ^ 3);
}
void rs_10_01_16_6(char a) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_10_01_16_7(char a) {
	guc %= 2;
}
void rs_10_01_17_1(unsigned char a) {
	unsigned int t = 25637;
	ju = t;
}
void rs_10_01_17_2(unsigned char a) {
	vc('A');
}
void rs_10_01_17_3(unsigned char a) {
	unsigned int t = ju;
	v0();
	switch (t) { case 1: gl += gps->l; break; case 10: vp(&gca[a]); break; case 16: vd(gda[2]); default: vs(gps); break; }
}
void rs_10_01_17_4(unsigned char a) {
	gula[4] = gul ^ 7UL;
}
void rs_10_01_17_5(unsigned char a) {
	unsigned int t = ju;
	v0();
	gla[t] = gs.l = (31607L - gl2) & gps->l;
}
void rs_10_01_17_6(unsigned char a) {
	int i = ji;
	unsigned int t = ju;
	v0();
	for (i = 0; i < 13; i++) { vu(t * 3); }
}
int rs_10_01_17_7(unsigned char a) {
	return 256;
}
void rs_10_01_18_0(struct st *a) {
	gpi = gpi + 1;
}
void rs_10_01_18_1(struct st *a) {
	vc((char)guca[3] - gc);
}
int rs_10_01_18_2(struct st *a) {
	return (gula[6] <= gul ? (gi2 ^ gi3) : 8);
}
void rs_10_01_19_0(unsigned int a, char *b, char c) {
	int t = gi;
	ji = t;
}
void rs_10_01_19_1(unsigned int a, char *b, char c) {
	int t = ji;
	gs.l = (long)gia[t];
}
void rs_10_01_19_2(unsigned int a, char *b, char c) {
	if (gua[a] != 0) gu2 = gua[0] / gua[a];
}
void rs_10_01_19_3(unsigned int a, char *b, char c) {
	if (*b < *gp) if (gula[a] != 0) gula[a] = 57844UL / gula[a];
}
long rs_10_01_19_4(unsigned int a, char *b, char c) {
	return gpl[0] & rl(gl);
}
void rs_10_02_00_0(unsigned int a, unsigned int b, unsigned char c) {
	unsigned char t = -guca[7];
	juc = t;
}
void rs_10_02_00_1(unsigned int a, unsigned int b, unsigned char c) {
	char u = -10 * gca[c];
	jc = u;
}
void rs_10_02_00_2(unsigned int a, unsigned int b, unsigned char c) {
	vp(gp);
}
void rs_10_02_00_3(unsigned int a, unsigned int b, unsigned char c) {
	unsigned char t = juc;
	v0();
	v1(t);
}
void rs_10_02_00_4(unsigned int a, unsigned int b, unsigned char c) {
	gpi = &gia[a];
}
void rs_10_02_00_5(unsigned int a, unsigned int b, unsigned char c) {
	while (gi-- > 0) *gp++ = -96;
}
void rs_10_02_00_6(unsigned int a, unsigned int b, unsigned char c) {
	char u = jc;
	v0();
	switch (gs.c) { case 0: u |= 'a'; break; case 1: gs.d -= gd; break; case 2: v2(gi2, gi); break; }
}
long rs_10_02_00_7(unsigned int a, unsigned int b, unsigned char c) {
	return (gs.l = (long)b);
}
void rs_10_02_01_1(long a, unsigned int b, char *c) {
	int t = (6UL > gula[1]);
	ji = t;
}
void rs_10_02_01_2(long a, unsigned int b, char *c) {
	gi3--;
}
void rs_10_02_01_3(long a, unsigned int b, char *c) {
	int i = ji;
	i = 15; do { gc2 = gps->c; if (gps->c != 0) gc = gp[2] % gps->c; } while (--i > 0);
}
void rs_10_02_01_4(long a, unsigned int b, char *c) {
	int t = ji;
	if (t != 0) gi2 = 256 % t;
}
char * rs_10_02_01_5(long a, unsigned int b, char *c) {
	return c;
}
void rs_10_02_02_0(char a, struct st *b, unsigned char c) {
	char *t = gp;
	jp = t;
}
void rs_10_02_02_1(char a, struct st *b, unsigned char c) {
	if (gua[c] != 0) gua[a] = b->u / gua[c];
}
void rs_10_02_02_2(char a, struct st *b, unsigned char c) {
	gps->i = r2(gi2, gi2);
}
void rs_10_02_02_3(char a, struct st *b, unsigned char c) {
	vd(gda[0]);
}
void rs_10_02_02_4(char a, struct st *b, unsigned char c) {
	char *t = jp;
	v0();
	gi3 = gs.i = (gps->a[c] - 111) + !t[0];
}
void rs_10_02_02_5(char a, struct st *b, unsigned char c) {
	gla[7] = (long)!gl2;
}
void rs_10_02_03_0(unsigned long a) {
	if (gu2 != 0) gua[1] = ((unsigned int)gula[3]) % gu2;
}
void rs_10_02_03_1(unsigned long a) {
	if (gp[1] != 0) gc = gca[7] / gp[1];
}
void rs_10_02_03_2(unsigned long a) {
	gul = rul(gula[3] | gul);
}
unsigned int rs_10_02_03_3(unsigned long a) {
	return gu2;
}
void rs_10_02_04_0(unsigned int a, unsigned char b, unsigned long c) {
	int *t = rpi(gi2);
	jpi = t;
}
void rs_10_02_04_1(unsigned int a, unsigned char b, unsigned long c) {
	vp(gp + b);
}
unsigned int rs_10_02_04_2(unsigned int a, unsigned char b, unsigned long c) {
	if (gs.d != gd) return gps->u / 2;
}
void rs_10_02_04_3(unsigned int a, unsigned char b, unsigned long c) {
	gd = -gd2;
}
void rs_10_02_04_4(unsigned int a, unsigned char b, unsigned long c) {
	b = (6 & guca[a]) ^ (guc | 169);
}
void rs_10_02_04_5(unsigned int a, unsigned char b, unsigned long c) {
	int *t = jpi;
	v0();
	gpi = t;
}
unsigned int rs_10_02_04_6(unsigned int a, unsigned char b, unsigned long c) {
	return gua[7];
}
void rs_10_02_05_0(double a, int *b) {
	switch (gc2) { case 0: guc -= guca[1]; case 1: v1(-39); break; default: gp[1] = gca[2] ^ gc; break; }
}
void rs_10_02_05_1(double a, int *b) {
	gl %= 16L;
}
void rs_10_02_05_2(double a, int *b) {
	if (!gula[2]) { if (gula[3] != 0) gula[4] = ((unsigned long)*gpi) % gula[3]; } else { vl(rl(gl)); }
}
char * rs_10_02_05_3(double a, int *b) {
	return rp();
}
void rs_10_02_06_1(unsigned int a) {
	double t = gs.d;
	jd = t;
}
void rs_10_02_06_2(unsigned int a) {
	int i = ji;
	for (i = 0; i < 12; i++) { gca[i] = gc - gca[i]; if (gl != 0) gl = 29990L / gl; ++gp; }
}
void rs_10_02_06_3(unsigned int a) {
	double t = jd;
	vd(t + gda[2]);
}
void rs_10_02_06_4(unsigned int a) {
	int i = ji;
	v0();
	gia[4] = -gps->i;
}
long rs_10_02_06_5(unsigned int a) {
	return (gps->l = gla[a]);
}
void rs_10_02_07_0(long *a, int b) {
	if (gi != 0) gi = gi3 % gi;
}
void rs_10_02_07_1(long *a, int b) {
	gul -= 50787UL / 2UL;
}
void rs_10_02_07_2(long *a, int b) {
	guc %= 3;
}
void rs_10_02_07_3(long *a, int b) {
	gpi = gpi + b;
}
int rs_10_02_07_4(long *a, int b) {
	return gs.i;
}
void rs_10_02_08_1(char a, unsigned long b, int *c) {
	unsigned char t = 128;
	juc = t;
}
void rs_10_02_08_2(char a, unsigned long b, int *c) {
	char *u = rp();
	jp = u;
}
void rs_10_02_08_3(char a, unsigned long b, int *c) {
	int i = ji;
	char *u = jp;
	v0();
	i = 0; while (i < 12) { u = &gca[0]; v2(gi2, (int)b); i++; }
}
void rs_10_02_08_4(char a, unsigned long b, int *c) {
	unsigned char t = juc;
	v0();
	gda[3] *= (guc <= guca[t] ? gd : gs.d);
}
void rs_10_02_08_5(char a, unsigned long b, int *c) {
	++gi3;
}
void rs_10_02_08_6(char a, unsigned long b, int *c) {
	char *u = jp;
	v0();
	u = gs.p;
}
int rs_10_02_08_7(char a, unsigned long b, int *c) {
	return c[7];
}
void rs_10_02_09_0(unsigned int a, unsigned long b) {
	gps->i = 1 % 100;
}
char * rs_10_02_09_1(unsigned int a, unsigned long b) {
	if (guc & 0x7) return &gca[a];
}
void rs_10_02_09_2(unsigned int a, unsigned long b) {
	gl2 = rl(65536L + gs.l);
}
void rs_10_02_09_3(unsigned int a, unsigned long b) {
	gc = rc((gs.i & 1 ? gps->a[0] : gi));
}
void rs_10_02_09_4(unsigned int a, unsigned long b) {
	switch (gs.c) { case 0: gc <<= (a & 7); break; case 1: v2(gps->a[a], gi); break; case 2: *gpi = 2 << 3; break; case 3: vc(gc2); break; case 4: guc = ~guca[2]; break; default: gca[a] = *gp = gc * 26; break; }
}
char * rs_10_02_09_5(unsigned int a, unsigned long b) {
	return &gca[a];
}
void rs_10_02_10_0(void) {
	int t = gi2;
	ji = t;
}
void rs_10_02_10_1(void) {
	gul++;
}
void rs_10_02_10_2(void) {
	if (gl2 != 0) gl = (long)guc / gl2;
}
void rs_10_02_10_3(void) {
	gi -= gi3;
}
void rs_10_02_10_4(void) {
	int t = ji;
	gca[t] = 72 >> 1;
}
void rs_10_02_10_5(void) {
	gula[7] |= (gul < 0x10000UL ? 0x10000UL : 0x10000UL);
}
int rs_10_02_10_6(void) {
	return (409 * 8) - (gps->i + gi3);
}
void rs_10_02_11_0(char *a, long *b) {
	char t = *gp + 96;
	jc = t;
}
void rs_10_02_11_1(char *a, long *b) {
	char t = jc;
	char *u = gp + t;
	jp = u;
}
void rs_10_02_11_2(char *a, long *b) {
	if (r2(16, gi)) if (*gpl != 0) b[6] = gla[7] % *gpl;
}
void rs_10_02_11_3(char *a, long *b) {
	if (gs.l != gl2) gia[2] <<= 11;
}
void rs_10_02_11_4(char *a, long *b) {
	char t = jc;
	v0();
	gp = gp + t;
}
void rs_10_02_11_5(char *a, long *b) {
	char *u = jp;
	v0();
	vp(u);
}
char rs_10_02_11_6(char *a, long *b) {
	char t = jc;
	v0();
	return t - 'A';
}
void rs_10_02_12_0(int a, int b, double c) {
	unsigned long t = ~((unsigned long)guca[a]);
	jul = t;
}
void rs_10_02_12_1(int a, int b, double c) {
	int u = gi2 << 10;
	ji = u;
}
void rs_10_02_12_2(int a, int b, double c) {
	v2(gi2, !gps->c);
}
void rs_10_02_12_3(int a, int b, double c) {
	int u = ji;
	v0();
	gi = u;
}
void rs_10_02_12_4(int a, int b, double c) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
void rs_10_02_12_5(int a, int b, double c) {
	gps->c *= 9;
}
char rs_10_02_12_6(int a, int b, double c) {
	return (gc2 ^ ' ') - (42 + 1);
}
void rs_10_02_13_1(int a, long b, unsigned int c) {
	int *t = gpi + a;
	jpi = t;
}
void rs_10_02_13_2(int a, long b, unsigned int c) {
	char *u = gs.p + a;
	jp = u;
}
void rs_10_02_13_3(int a, long b, unsigned int c) {
	int *t = jpi;
	gpi = t;
}
void rs_10_02_13_4(int a, long b, unsigned int c) {
	int i = ji;
	for (i = a; i > 0; i--) { gul %= 10UL; gda[0] = (gul == ((unsigned long)*gp) ? (gs.d + gda[1]) : gs.d); gul /= 10UL; }
}
void rs_10_02_13_5(int a, long b, unsigned int c) {
	char *u = jp;
	gc -= *u >> (a & 7);
}
int rs_10_02_13_6(int a, long b, unsigned int c) {
	return ~(int)gl2 - (gia[c] | 815);
}
void rs_10_02_14_1(unsigned int a) {
	char t = *gp >> 2;
	jc = t;
}
void rs_10_02_14_2(unsigned int a) {
	int i = ji;
	i = 16; do { gi = r2(r2((int)guc, gi), gi); } while (--i > 0);
}
void rs_10_02_14_3(unsigned int a) {
	gu = a % 4;
}
void rs_10_02_14_4(unsigned int a) {
	gs.d = gd * gd;
}
void rs_10_02_14_5(unsigned int a) {
	char t = jc;
	v0();
	guc = guca[t];
}
void rs_10_02_14_6(unsigned int a) {
	if (gula[5] != 0) gul = gul % gula[5];
}
char rs_10_02_14_7(unsigned int a) {
	return ~82;
}
void rs_10_02_15_0(double a, int b, unsigned int c) {
	gula[4] = gul = ((unsigned long)!gi2) % 16UL;
}
void rs_10_02_15_1(double a, int b, unsigned int c) {
	++gp;
}
void rs_10_02_15_2(double a, int b, unsigned int c) {
	if (gps->c < gs.c && guca[c]) { gc = -(9 % 10); } else { if (gul != 0) gula[4] = gul / gul; if (gul != 0) gula[c] = gula[c] % gul; gl2 >>= 10; }
}
int rs_10_02_15_3(double a, int b, unsigned int c) {
	return (gc2 < 'a' ? b : (*gpi << 13));
}
void rs_10_02_16_1(unsigned int a) {
	unsigned long t = 0x10000UL / 7UL;
	jul = t;
}
void rs_10_02_16_2(unsigned int a) {
	unsigned char u = (unsigned char)gc;
	juc = u;
}
void rs_10_02_16_3(unsigned int a) {
	unsigned char u = juc;
	if ((gua[u] = a) != 16155) { if (gpi[2] != 0) gi3 = 6 % gpi[2]; gi3 = gps->a[0] >> (a & 15); }
}
void rs_10_02_16_4(unsigned int a) {
	int i = ji;
	i = 15; do { if (a != 0) a = 3 / a; --gp; gi++; } while (--i > 0);
}
void rs_10_02_16_5(unsigned int a) {
	++gp;
}
void rs_10_02_16_6(unsigned int a) {
	unsigned long t = jul;
	unsigned char u = juc;
	gu2 = (t != 0x10000UL ? gu2 : ((unsigned int)gca[u])) - a;
}
void rs_10_02_16_7(unsigned int a) {
	int i = ji;
	gs.a[a] = gpi[0] - gs.i;
}
int rs_10_02_16_8(unsigned int a) {
	return r2(2, gi);
}
void rs_10_02_17_0(void) {
	int *t = gpi;
	jpi = t;
}
void rs_10_02_17_1(void) {
	gs.d = (!gu ? gd : gd2);
}
void rs_10_02_17_2(void) {
	int *t = jpi;
	t = &gia[2];
}
int * rs_10_02_17_3(void) {
	int *t = jpi;
	return t;
}
void rs_10_02_18_0(unsigned long a, char b, unsigned long c) {
	char *t = gps->p;
	jp = t;
}
void rs_10_02_18_1(unsigned long a, char b, unsigned long c) {
	int u = (gps->l & 2 ? gps->i : (int)gpl[1]);
	ji = u;
}
void rs_10_02_18_2(unsigned long a, char b, unsigned long c) {
	int u = ji;
	u = (gi ^ gs.i) >> 5;
}
void rs_10_02_18_3(unsigned long a, char b, unsigned long c) {
	guc = guca[2] = -(guc >> (b & 7));
}
void rs_10_02_18_4(unsigned long a, char b, unsigned long c) {
	char *t = jp;
	gp = t;
}
void rs_10_02_18_5(unsigned long a, char b, unsigned long c) {
	gu = gu2 - (((unsigned int)guca[6]) ^ gu2);
}
unsigned long rs_10_02_18_6(unsigned long a, char b, unsigned long c) {
	return (c = gul);
}
void rs_10_02_19_0(void) {
	--gul;
}
void rs_10_02_19_1(void) {
	gpi = gpi + 1;
}
void rs_10_02_19_2(void) {
	gps->u = gua[7];
}
char rs_10_02_19_3(void) {
	return (gc = gc2);
}
void rs_10_03_00_0(int *a) {
	long t = gpl[0] - 65536L;
	jl = t;
}
void rs_10_03_00_1(int *a) {
	if (guca[5] <= 161) { gia[5] = gi = (gula[5] ? gs.a[1] : a[2]) * (255 - gs.a[3]); } else { gu = (gu2 / 16) + ((unsigned int)*gp); }
}
void rs_10_03_00_2(int *a) {
	long t = jl;
	gl = t;
}
void rs_10_03_00_3(int *a) {
	vc(4);
}
void rs_10_03_01_0(int a, unsigned int b, unsigned long c) {
	char *t = &gca[5];
	jp = t;
}
void rs_10_03_01_1(int a, unsigned int b, unsigned long c) {
	double u = gd2;
	jd = u;
}
void rs_10_03_01_2(int a, unsigned int b, unsigned long c) {
	double u = jd;
	vd(u);
}
void rs_10_03_01_3(int a, unsigned int b, unsigned long c) {
	if (gi != 0) gps->a[b] = a % gi;
}
void rs_10_03_01_4(int a, unsigned int b, unsigned long c) {
	gpl[3] = (gl2 - gpl[3]) | rl(gl);
}
void rs_10_03_01_5(int a, unsigned int b, unsigned long c) {
	char *t = jp;
	v0();
	vc(t[6] * gca[a]);
}
void rs_10_03_01_6(int a, unsigned int b, unsigned long c) {
	gl2 >>= 31;
}
long rs_10_03_01_7(int a, unsigned int b, unsigned long c) {
	return (gs.l ^ gla[a]) | rl(4L);
}
void rs_10_03_02_0(void) {
	gia[3] = gi >> 5;
}
void rs_10_03_02_1(void) {
	gu2 = gua[4] = ~gu;
}
long rs_10_03_02_2(void) {
	return (gl2 = gpl[3]);
}
void rs_10_03_03_1(int a, unsigned int b) {
	int t = !1L;
	ji = t;
}
void rs_10_03_03_2(int a, unsigned int b) {
	vc(rc(256));
}
void rs_10_03_03_3(int a, unsigned int b) {
	gps->l = gl;
}
void rs_10_03_03_4(int a, unsigned int b) {
	int t = ji;
	v0();
	gi = t;
}
void rs_10_03_03_5(int a, unsigned int b) {
	int i = ji;
	v0();
	for (i = 0; i < 7; i++) { gu = gps->u; }
}
int rs_10_03_03_6(int a, unsigned int b) {
	return r2((int)gul, gi);
}
void rs_10_03_04_1(unsigned long a) {
	int *t = gpi;
	jpi = t;
}
void rs_10_03_04_2(unsigned long a) {
	int *t = jpi;
	int *u = t;
	jpi = u;
}
void rs_10_03_04_3(unsigned long a) {
	guc = ((unsigned char)33818UL) * -guc;
}
void rs_10_03_04_4(unsigned long a) {
	int *t = jpi;
	v1(*t);
}
void rs_10_03_04_5(unsigned long a) {
	if ((gs.c = -18) < -36) gda[3] += -gs.d;
}
void rs_10_03_04_6(unsigned long a) {
	gd2 += gda[0] - gda[0];
}
void rs_10_03_04_7(unsigned long a) {
	int i = ji;
	v0();
	for (i = 0; i < 5; i++) { guca[i] = ~255; }
}
void rs_10_03_04_8(unsigned long a) {
	int *u = jpi;
	v0();
	v1(*u);
}
unsigned int rs_10_03_04_9(unsigned long a) {
	return gu & 17021;
}
void rs_10_03_05_0(int *a) {
	gl2 = rl(-gs.l);
}
void rs_10_03_05_1(int *a) {
	vu(~gps->u);
}
int rs_10_03_05_2(int *a) {
	if (gl >= -57565L) return ~(int)gul;
}
void rs_10_03_05_3(int *a) {
	if (gc != 0) gca[4] = gc2 % gc;
}
int rs_10_03_05_4(int *a) {
	return (255 / 2) & r2(gi3, gi);
}
void rs_10_03_06_0(unsigned long a, unsigned long b, int *c) {
	long t = gps->l;
	jl = t;
}
void rs_10_03_06_1(unsigned long a, unsigned long b, int *c) {
	while (gi > 0) { gi2 += *c++; gi--; }
}
void rs_10_03_06_2(unsigned long a, unsigned long b, int *c) {
	gs.i = 16;
}
void rs_10_03_06_3(unsigned long a, unsigned long b, int *c) {
	long t = jl;
	vl(t);
}
void rs_10_03_06_4(unsigned long a, unsigned long b, int *c) {
	v0();
}
long rs_10_03_06_5(unsigned long a, unsigned long b, int *c) {
	long t = jl;
	v0();
	return (t ^ gla[5]) ^ 4L;
}
void rs_10_03_07_1(unsigned int a) {
	long t = 9L / 3L;
	jl = t;
}
void rs_10_03_07_2(unsigned int a) {
	double u = (double)gu2;
	jd = u;
}
void rs_10_03_07_3(unsigned int a) {
	long t = jl;
	gl = t;
}
void rs_10_03_07_4(unsigned int a) {
	gd2 += gd;
}
void rs_10_03_07_5(unsigned int a) {
	int i = ji;
	double u = jd;
	i = 9; do { gd2 -= u + gda[0]; guc &= ((unsigned char)gul) % 16; gula[i] = gul = 68046UL; } while (--i > 0);
}
void rs_10_03_07_6(unsigned int a) {
	gia[5] = -gi2;
}
void rs_10_03_07_7(unsigned int a) {
	gul = ~gula[a];
}
void rs_10_03_07_8(unsigned int a) {
	++gc2;
}
long rs_10_03_07_9(unsigned int a) {
	return (gla[7] % 3L) - gs.l;
}
void rs_10_03_08_0(void) {
	int t = gpi[2] << 14;
	ji = t;
}
long rs_10_03_08_1(void) {
	int t = ji;
	if (t > 9) return 65536L * 3L;
}
void rs_10_03_08_2(void) {
	guc = (unsigned char)!(~gl2);
}
void rs_10_03_08_3(void) {
	gc--;
}
long rs_10_03_08_4(void) {
	return (gl2 - 0L) - gl2;
}
void rs_10_03_09_1(char a, unsigned int b) {
	long t = gl;
	jl = t;
}
void rs_10_03_09_2(char a, unsigned int b) {
	double u = -gs.d;
	jd = u;
}
void rs_10_03_09_3(char a, unsigned int b) {
	int i = ji;
	i = 0; while (i < 12) { guc >>= 1; gps->p = &gca[i]; i++; }
}
void rs_10_03_09_4(char a, unsigned int b) {
	gs.d = gd * gd;
}
void rs_10_03_09_5(char a, unsigned int b) {
	guc = 128;
}
void rs_10_03_09_6(char a, unsigned int b) {
	double u = jd;
	gd = u;
}
void rs_10_03_09_7(char a, unsigned int b) {
	int i = ji;
	long t = jl;
	i = 15; do { if (t != 0) t = t / t; *gp = gca[i] + gc2; } while (--i > 0);
}
void rs_10_03_09_8(char a, unsigned int b) {
	if (gi != 0) gia[b] = 256 % gi;
}
int rs_10_03_09_9(char a, unsigned int b) {
	return (int)gua[b];
}
void rs_10_03_10_1(int a) {
	int *t = gpi;
	jpi = t;
}
void rs_10_03_10_2(int a) {
	gl2 >>= 23;
}
void rs_10_03_10_3(int a) {
	v0();
}
void rs_10_03_10_4(int a) {
	if (255 != gu2) { vp(gs.p); gs.d = gd2; if (gia[5] != 0) a = 256 / gia[5]; } else { guca[a] += guca[7] ^ guca[a]; }
}
void rs_10_03_10_5(int a) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_10_03_10_6(int a) {
	int i = ji;
	v0();
	i = a; do { gula[i] = gul; } while (--i > 0);
}
void rs_10_03_10_7(int a) {
	gca[0] = ~gp[0];
}
int * rs_10_03_10_8(int a) {
	int *t = jpi;
	v0();
	return t;
}
void rs_10_03_11_0(int a) {
	gps->p = gp;
}
void rs_10_03_11_1(int a) {
	gul = (gula[2] / 3UL) + rul(gul);
}
void rs_10_03_11_2(int a) {
	gu2 ^= 1 >> (a & 15);
}
void rs_10_03_11_3(int a) {
	gd = gda[3] / 1.0;
}
unsigned long rs_10_03_11_4(int a) {
	return (gul + gula[0]) | (gula[4] / 4UL);
}
void rs_10_03_12_0(int a, long b, int *c) {
	if (*gpi != 0) gi2 = gia[a] % *gpi;
}
void rs_10_03_12_1(int a, long b, int *c) {
	++b;
}
int * rs_10_03_12_2(int a, long b, int *c) {
	return c + a;
}
void rs_10_03_13_0(int a, unsigned char b, char *c) {
	gpi++;
}
void rs_10_03_13_1(int a, unsigned char b, char *c) {
	if (*gpl < gl) gpi = rpi(-gia[4]);
}
unsigned int rs_10_03_13_2(int a, unsigned char b, char *c) {
	return (unsigned int)((unsigned long)!gps->i);
}
void rs_10_03_14_0(int a, long b, char c) {
	if ((gl = gpl[1]) != 65536L) { b ^= b | -28768L; if (gula[1] != 0) gul = gul / gula[1]; gi2 ^= gi3; } else { if (a != 0) gi3 = a % a; if (gl2 != 0) gps->l = gla[c] / gl2; }
}
void rs_10_03_14_1(int a, long b, char c) {
	guc++;
}
void rs_10_03_14_2(int a, long b, char c) {
	if (gula[4] != 0) gula[5] = gul % gula[4];
}
void rs_10_03_14_3(int a, long b, char c) {
	gs.c = rc(gi);
}
int * rs_10_03_14_4(int a, long b, char c) {
	return gpi + c;
}
void rs_10_03_15_1(long *a, int b, int c) {
	char *t = gp;
	jp = t;
}
void rs_10_03_15_2(long *a, int b, int c) {
	int i = ji;
	char *t = jp;
	for (i = 15; i > 0; i--) { t = gps->p; }
}
void rs_10_03_15_3(long *a, int b, int c) {
	int i = ji;
	i = c; do { gl = rl(65536L / 3L); gula[i] |= gula[i] - 0x10000UL; vs(gps); } while (--i > 0);
}
void rs_10_03_15_4(long *a, int b, int c) {
	gi += ~b;
}
void rs_10_03_16_0(char a, char b, int c) {
	if (gia[b] >= gi2) *gpl = gl = (long)gul;
}
void rs_10_03_16_1(char a, char b, int c) {
	++gi2;
}
void rs_10_03_16_2(char a, char b, int c) {
	guca[b] = (unsigned char)gia[a];
}
int rs_10_03_16_3(char a, char b, int c) {
	return !gula[0];
}
void rs_10_03_17_0(int *a, unsigned int b) {
	int t = (guca[b] != 255);
	ji = t;
}
void rs_10_03_17_1(int *a, unsigned int b) {
	double u = gda[2] * 3.0;
	jd = u;
}
void rs_10_03_17_2(int *a, unsigned int b) {
	double u = jd;
	vd(u);
}
void rs_10_03_17_3(int *a, unsigned int b) {
	vl(gl);
}
void rs_10_03_17_4(int *a, unsigned int b) {
	vc(~*gp);
}
void rs_10_03_17_5(int *a, unsigned int b) {
	int t = ji;
	v0();
	gi = t;
}
int rs_10_03_17_6(int *a, unsigned int b) {
	int t = ji;
	v0();
	return (t + *gpi) >> 4;
}
void rs_10_03_18_0(int *a) {
	int t = gpi[2] >> 3;
	ji = t;
}
void rs_10_03_18_1(int *a) {
	gca[3] = gc2 / 100;
}
void rs_10_03_18_2(int *a) {
	gc = (' ') - 57;
}
void rs_10_03_18_3(int *a) {
	int t = ji;
	guca[t] = guc = (gu < 32767 && r2(a[1], gi) ? (guc ^ guca[0]) : guca[t]);
}
void rs_10_03_18_4(int *a) {
	guc ^= ~guc;
}
int * rs_10_03_18_5(int *a) {
	return rpi(gi2);
}
void rs_10_03_19_0(unsigned long a, unsigned char b) {
	gu++;
}
void rs_10_03_19_1(unsigned long a, unsigned char b) {
	gpi++;
}
void rs_10_03_19_2(unsigned long a, unsigned char b) {
	gl = gla[2] = rl(rl(gla[b]));
}
int rs_10_03_19_3(unsigned long a, unsigned char b) {
	return gpi[1];
}
void rs_10_04_00_1(unsigned int a, unsigned long b) {
	double t = gs.d * 0.25;
	jd = t;
}
void rs_10_04_00_2(unsigned int a, unsigned long b) {
	double u = -3.0;
	jd = u;
}
void rs_10_04_00_3(unsigned int a, unsigned long b) {
	int i = ji;
	double u = jd;
	for (i = 0; i < 8; i++) { if (gu2 != 0) gs.u = gu2 % gu2; vc((char)(gps->c > -64)); v1(-*gpi); }
}
void rs_10_04_00_4(unsigned int a, unsigned long b) {
	if (gc < 2 && gs.a[3] < 256) { gu2 = ~gu << 3; if (gu != 0) a = gua[4] % gu; }
}
void rs_10_04_00_5(unsigned int a, unsigned long b) {
	v1(gi & gs.a[a]);
}
void rs_10_04_00_6(unsigned int a, unsigned long b) {
	double t = jd;
	v0();
	vd(t);
}
void rs_10_04_00_7(unsigned int a, unsigned long b) {
	gp = gps->p + a;
}
long rs_10_04_00_8(unsigned int a, unsigned long b) {
	return (gl + 52055L) - (gl << 7);
}
void rs_10_04_01_1(void) {
	double t = gd2 * gd2;
	jd = t;
}
void rs_10_04_01_2(void) {
	int i = ji;
	for (i = 0; i < 12; i++) { if (gs.u != 0) gu = 8268 % gs.u; gs.d -= (double)gi3 / 3.0; }
}
void rs_10_04_01_3(void) {
	gula[1] = (unsigned long)~gc2;
}
void rs_10_04_01_4(void) {
	double t = jd;
	gd = t;
}
void rs_10_04_01_5(void) {
	if (gi & 2) --gp;
}
void rs_10_04_01_6(void) {
	gua[1] <<= 8;
}
int * rs_10_04_01_7(void) {
	return &gia[4];
}
void rs_10_04_02_0(unsigned long a) {
	unsigned char t = guca[1] - guca[4];
	juc = t;
}
void rs_10_04_02_1(unsigned long a) {
	unsigned long u = gul + a;
	jul = u;
}
void rs_10_04_02_2(unsigned long a) {
	unsigned char t = juc;
	unsigned long u = jul;
	switch (gi2) { case 0: gc = 69 / 4; break; case 1: guc -= t; break; case 2: v2(gi, gi); break; case 3: gca[t] = gc; break; case 4: gi *= 4; break; case 5: gps->u = gu; break; default: vd(gd); break; }
}
void rs_10_04_02_3(unsigned long a) {
	gpi = &gia[0];
}
int rs_10_04_02_4(unsigned long a) {
	return gps->i + (100 - gs.i);
}
void rs_10_04_03_0(void) {
	unsigned long t = gula[7] + gula[1];
	jul = t;
}
void rs_10_04_03_1(void) {
	unsigned long u = gul;
	jul = u;
}
void rs_10_04_03_2(void) {
	guc++;
}
void rs_10_04_03_3(void) {
	guca[7] = guc;
}
void rs_10_04_03_4(void) {
	unsigned long t = jul;
	gul = t;
}
void rs_10_04_03_5(void) {
	vu(gua[6]);
}
void rs_10_04_03_6(void) {
	unsigned long u = jul;
	v0();
	gul = u;
}
unsigned long rs_10_04_03_7(void) {
	return (unsigned long)!gi;
}
void rs_10_04_04_0(unsigned int a, char b) {
	char t = *gp ^ gc;
	jc = t;
}
void rs_10_04_04_1(unsigned int a, char b) {
	char t = jc;
	unsigned long u = gula[t];
	jul = u;
}
void rs_10_04_04_2(unsigned int a, char b) {
	unsigned long u = jul;
	gul = u;
}
void rs_10_04_04_3(unsigned int a, char b) {
	char t = jc;
	vc(t);
}
void rs_10_04_04_4(unsigned int a, char b) {
	gi2 = !(gla[5] - (long)gi3);
}
void rs_10_04_04_5(unsigned int a, char b) {
	while (gi > 0) { gi3 += *gpi++; gi--; }
}
char * rs_10_04_04_6(unsigned int a, char b) {
	return gp;
}
void rs_10_04_05_0(char *a) {
	double t = (r2(gi2, (int)gc2) ? gda[0] : gd);
	jd = t;
}
void rs_10_04_05_1(char *a) {
	long u = rl(*gpl);
	v0();
	jl = u;
}
void rs_10_04_05_2(char *a) {
	vc((char)(guc == 200));
}
void rs_10_04_05_3(char *a) {
	switch (gl) { case 1L: guca[0] += guc; break; case 2L: vs(gps); break; case 8L: case 1000L: gul ^= 0x10000UL; break; default: v2(gi3, gi); break; }
}
void rs_10_04_05_4(char *a) {
	double t = jd;
	v0();
	vd(t);
}
void rs_10_04_05_5(char *a) {
	gd = 3.0;
}
void rs_10_04_05_6(char *a) {
	long u = jl;
	v0();
	gl = u;
}
void rs_10_04_05_7(char *a) {
	vu(((unsigned int)gul) + gu);
}
void rs_10_04_06_0(int *a, unsigned int b) {
	unsigned long t = (unsigned long)(gua[b] >= gu2);
	jul = t;
}
void rs_10_04_06_1(int *a, unsigned int b) {
	long u = (gps->l & 0x10 ? gl : gpl[0]);
	jl = u;
}
void rs_10_04_06_2(int *a, unsigned int b) {
	unsigned long t = jul;
	long u = jl;
	t = (gps->u <= 255 ? (gul ^ 0x10000UL) : (t - 95658UL));
}
void rs_10_04_06_3(int *a, unsigned int b) {
	vp(&gca[b]);
}
void rs_10_04_06_4(int *a, unsigned int b) {
	while (gi-- > 0) *a++ = 256;
}
void rs_10_04_06_5(int *a, unsigned int b) {
	--guc;
}
void rs_10_04_06_6(int *a, unsigned int b) {
	gs.l *= 7L;
}
long rs_10_04_06_7(int *a, unsigned int b) {
	return gpl[3];
}
void rs_10_04_07_1(unsigned int a, int b) {
	char *t = gp;
	jp = t;
}
void rs_10_04_07_2(unsigned int a, int b) {
	int i = ji;
	for (i = 0; i < 8; i++) { guc = (guca[i] << 4) % 10; vd(-gd2); gula[i] = gul; }
}
void rs_10_04_07_3(unsigned int a, int b) {
	gs.u = (guca[a] == 255 ? gua[a] : 1);
}
void rs_10_04_07_4(unsigned int a, int b) {
	++gc2;
}
void rs_10_04_07_5(unsigned int a, int b) {
	gpi = &gia[7];
}
void rs_10_04_07_6(unsigned int a, int b) {
	b = (gi3 / 16) ^ gi2;
}
void rs_10_04_07_7(unsigned int a, int b) {
	char *t = jp;
	v0();
	vp(t);
}
unsigned int rs_10_04_07_8(unsigned int a, int b) {
	return (unsigned int)gul;
}
void rs_10_04_08_1(long a, int *b, char c) {
	gpi = b + c;
}
void rs_10_04_08_2(long a, int *b, char c) {
	int i = ji;
	for (i = 0; i < 7; i++) { guc = 128; vu(((unsigned int)gpl[0]) - gs.u); if (gps->u != 0) gs.u = gua[i] % gps->u; }
}
void rs_10_04_08_3(long a, int *b, char c) {
	v0();
}
void rs_10_04_08_4(long a, int *b, char c) {
	gd2 -= -gs.d;
}
unsigned int rs_10_04_08_5(long a, int *b, char c) {
	return (gu = gu2);
}
void rs_10_04_09_0(char a, long b, double c) {
	char *t = gp + a;
	jp = t;
}
void rs_10_04_09_1(char a, long b, double c) {
	unsigned int u = 8 | gu2;
	ju = u;
}
void rs_10_04_09_2(char a, long b, double c) {
	char *t = jp;
	gp = t;
}
void rs_10_04_09_3(char a, long b, double c) {
	unsigned int u = ju;
	gu = u % 4;
}
void rs_10_04_09_4(char a, long b, double c) {
	unsigned int u = ju;
	gua[u] = gu2 = gu << 3;
}
void rs_10_04_09_5(char a, long b, double c) {
	guca[a] ^= 255 | guca[a];
}
void rs_10_04_09_6(char a, long b, double c) {
	unsigned int u = ju;
	gula[u] = ~gula[6];
}
void rs_10_04_10_0(unsigned char a, int b) {
	int *t = gpi;
	jpi = t;
}
void rs_10_04_10_1(unsigned char a, int b) {
	switch (gs.c) { case 0: gla[7] ^= gpl[0]; break; case 1: gula[5] *= 7UL; break; }
}
void rs_10_04_10_2(unsigned char a, int b) {
	gps->a[b] *= 7;
}
void rs_10_04_10_3(unsigned char a, int b) {
	int *t = jpi;
	v1(*t);
}
int rs_10_04_10_4(unsigned char a, int b) {
	return b;
}
void rs_10_04_11_1(void) {
	gu &= gua[5];
}
void rs_10_04_11_2(void) {
	guc /= 2;
}
void rs_10_04_11_3(void) {
	switch (gps->l) { case 3L: v0(); break; case 5L: v0(); break; case 100L: vs(gps); break; case 1000L: gd -= gda[3]; break; default: gl2 = (long)!guca[5]; break; }
}
void rs_10_04_11_4(void) {
	int i = ji;
	v0();
	i = 12; do { vd(gd * gd2); gd2 = gda[2]; guca[i] = -guca[i]; } while (--i > 0);
}
char * rs_10_04_11_5(void) {
	return gp + 1;
}
void rs_10_04_12_1(double a) {
	gl = 65536L;
}
void rs_10_04_12_2(double a) {
	guca[4] = guc = 2;
}
void rs_10_04_12_3(double a) {
	gp = rp();
}
void rs_10_04_12_4(double a) {
	int i = ji;
	v0();
	i = 7; do { if (gula[i] != 0) gula[i] = 0x10000UL % gula[i]; gs.c = *gp >> (i & 7); guc = guc - -guca[i]; } while (--i > 0);
}
void rs_10_04_12_5(double a) {
	if (gl2 != 0) gl2 = gpl[1] % gl2;
}
int rs_10_04_12_6(double a) {
	return gi2;
}
void rs_10_04_13_0(char *a) {
	unsigned int t = gu2 >> 4;
	ju = t;
}
void rs_10_04_13_1(char *a) {
	unsigned int t = ju;
	unsigned long u = gula[t];
	jul = u;
}
void rs_10_04_13_2(char *a) {
	unsigned long u = jul;
	vl((long)u);
}
void rs_10_04_13_3(char *a) {
	gd = (gd2 * gs.d) * gda[2];
}
void rs_10_04_13_4(char *a) {
	unsigned int t = ju;
	v0();
	gpi = gpi + t;
}
void rs_10_04_13_5(char *a) {
	gi2--;
}
void rs_10_04_13_6(char *a) {
	unsigned int t = ju;
	v0();
	gl2 = (r0() ? (long)!guca[0] : ((long)guca[t] / 7L));
}
int rs_10_04_13_7(char *a) {
	return (gi > 255 ? (int)gl2 : gs.a[1]) & !7;
}
void rs_10_04_14_0(long *a, unsigned int b) {
	gu2 = ((unsigned int)!gps->u) ^ (b + gs.u);
}
void rs_10_04_14_1(long *a, unsigned int b) {
	gps->a[b] = gi3 = (gpi[0] == gps->a[7] ? (*gpi & 1 ? gi2 : gi2) : (int)gul);
}
void rs_10_04_15_0(unsigned long a, char *b, int c) {
	if (gca[c] != 0) gc = gc / gca[c];
}
void rs_10_04_15_1(unsigned long a, char *b, int c) {
	if (!gu2 && gua[c] != 32767) { guc--; gi3 = gs.i; }
}
void rs_10_04_15_2(unsigned long a, char *b, int c) {
	if ((long)guca[0] > 7L) { gs.u -= gu; } else { --guc; if (*gpi != 0) c = gi / *gpi; guc = guca[c] % 100; }
}
void rs_10_04_15_3(unsigned long a, char *b, int c) {
	gul = a = 42693UL;
}
void rs_10_04_15_4(unsigned long a, char *b, int c) {
	c %= 10;
}
long rs_10_04_15_5(unsigned long a, char *b, int c) {
	return gs.l;
}
void rs_10_04_16_0(unsigned int a, struct st *b, unsigned long c) {
	unsigned char t = guc;
	juc = t;
}
void rs_10_04_16_1(unsigned int a, struct st *b, unsigned long c) {
	unsigned int u = a + 23906;
	ju = u;
}
void rs_10_04_16_2(unsigned int a, struct st *b, unsigned long c) {
	unsigned int u = ju;
	vu(u);
}
void rs_10_04_16_3(unsigned int a, struct st *b, unsigned long c) {
	gps->c = (char)guca[a];
}
void rs_10_04_16_4(unsigned int a, struct st *b, unsigned long c) {
	vp(gp);
}
void rs_10_04_16_5(unsigned int a, struct st *b, unsigned long c) {
	unsigned char t = juc;
	v0();
	if (gl2 != 0) gl2 = gla[t] % gl2;
}
int * rs_10_04_16_6(unsigned int a, struct st *b, unsigned long c) {
	return gpi;
}
void rs_10_04_17_0(unsigned char a, struct st *b) {
	int t = gi2 << (a & 15);
	ji = t;
}
void rs_10_04_17_1(unsigned char a, struct st *b) {
	int t = ji;
	v1(t >> 7);
}
void rs_10_04_17_2(unsigned char a, struct st *b) {
	gu = gu2 = ~(32767 + gu2);
}
void rs_10_04_17_3(unsigned char a, struct st *b) {
	int t = ji;
	v0();
	t += ~t;
}
void rs_10_04_17_4(unsigned char a, struct st *b) {
	vp(gps->p);
}
void rs_10_04_17_5(unsigned char a, struct st *b) {
	int t = ji;
	v0();
	if (t != 0) gpi[2] = 8 % t;
}
int rs_10_04_17_6(unsigned char a, struct st *b) {
	return gi / 7;
}
void rs_10_04_18_1(int *a, int b) {
	long t = gla[b] - (long)gula[7];
	jl = t;
}
void rs_10_04_18_2(int *a, int b) {
	vc(((guc = 255) <= 255 ? gs.c : gca[b]));
}
void rs_10_04_18_3(int *a, int b) {
	long t = jl;
	v0();
	gl = t;
}
void rs_10_04_18_4(int *a, int b) {
	int i = ji;
	v0();
	i = 0; while (i < b) { gl <<= 27; gps->u = 256 << 1; vs(gps); i++; }
}
void rs_10_04_18_5(int *a, int b) {
	guc *= 3;
}
unsigned long rs_10_04_18_6(int *a, int b) {
	return (unsigned long)(gps->a[b] - a[0]);
}
void rs_10_04_19_0(unsigned char a, unsigned int b) {
	char *t = rp();
	jp = t;
}
void rs_10_04_19_1(unsigned char a, unsigned int b) {
	int u = 1 & *gpi;
	v0();
	ji = u;
}
void rs_10_04_19_2(unsigned char a, unsigned int b) {
	char *t = jp;
	int u = ji;
	v0();
	if (t[2] <= gca[u]) { gps->i = gia[4] = gs.a[b] & gia[b]; } else { if (gpi[2] != 0) gi2 = 16 / gpi[2]; if (gpl[2] != 0) *gpl = 65536L / gpl[2]; gl = gps->l; }
}
void rs_10_04_19_3(unsigned char a, unsigned int b) {
	guc = a;
}
void rs_10_04_19_4(unsigned char a, unsigned int b) {
	guca[6] = a = (3 >> (b & 7)) ^ guc;
}
void rs_10_04_19_5(unsigned char a, unsigned int b) {
	int u = ji;
	v0();
	switch (gps->l) { case 0L: gula[7] /= 3UL; break; case 1L: gca[a] |= gps->c; break; case 2L: gc = (char)u - *gp; break; case 3L: gps->u ^= gua[b]; break; case 4L: vu(gu2); break; }
}
int rs_10_04_19_6(unsigned char a, unsigned int b) {
	int u = ji;
	v0();
	return u;
}
void rs_10_05_00_1(void) {
	long t = (long)gi3;
	jl = t;
}
void rs_10_05_00_2(void) {
	unsigned long u = ((unsigned long)gps->c) - ((unsigned long)guc);
	jul = u;
}
void rs_10_05_00_3(void) {
	long t = jl;
	vl(t);
}
void rs_10_05_00_4(void) {
	int i = ji;
	unsigned long u = jul;
	v0();
	if (gs.u) if (gs.i != 0) gi2 = gi / gs.i;
}
void rs_10_05_00_5(void) {
	unsigned long u = jul;
	v0();
	if (gps->c != (char)u) if (gs.a[6] != 0) gia[3] = gi2 % gs.a[6];
}
void rs_10_05_00_6(void) {
	int i = ji;
	v0();
	for (i = 0; i < 6; i++) { v0(); }
}
void rs_10_05_00_7(void) {
	switch (gi2) { case 0: guc <<= 3; case 1: guc -= guca[7]; break; case 2: case 3: vc(gca[3]); break; }
}
unsigned long rs_10_05_00_8(void) {
	unsigned long u = jul;
	v0();
	return (u + 0x10000UL) ^ gul;
}
void rs_10_05_01_0(struct st *a, unsigned char b, unsigned long c) {
	int t = 16 ^ *gpi;
	ji = t;
}
void rs_10_05_01_1(struct st *a, unsigned char b, unsigned long c) {
	long u = gl2;
	jl = u;
}
void rs_10_05_01_2(struct st *a, unsigned char b, unsigned long c) {
	int t = ji;
	if (gi2 > t) if (gc2 != 0) gca[b] = (' ') % gc2;
}
void rs_10_05_01_3(struct st *a, unsigned char b, unsigned long c) {
	gc <<= 1;
}
void rs_10_05_01_4(struct st *a, unsigned char b, unsigned long c) {
	int t = ji;
	long u = jl;
	gs.u = gua[1] << (t & 15);
}
unsigned int rs_10_05_01_5(struct st *a, unsigned char b, unsigned long c) {
	return gu % 100;
}
void rs_10_05_02_0(unsigned long a) {
	int *u = jpi;
	int t = (int)gps->u;
	ji = t;
}
void rs_10_05_02_1(unsigned long a) {
	int *u = gpi;
	jpi = u;
}
void rs_10_05_02_2(unsigned long a) {
	int *u = jpi;
	switch (gps->c) { case 5: gda[1] -= gs.d; break; case 10: v2(u[2], gi); break; }
}
void rs_10_05_02_3(unsigned long a) {
	int t = ji;
	v0();
	gul = gula[t] % 3UL;
}
char * rs_10_05_02_4(unsigned long a) {
	int t = ji;
	v0();
	return gp + t;
}
void rs_10_05_03_0(int *a, unsigned char b) {
	switch (gps->l) { case 0L: vl(gl2); case 1L: case 2L: gca[b] |= gc2; break; case 3L: gla[b] = gpl[1] % 3L; break; case 4L: gca[b] = 65; break; }
}
void rs_10_05_03_1(int *a, unsigned char b) {
	--a;
}
void rs_10_05_03_2(int *a, unsigned char b) {
	gula[3] += gula[3] - gul;
}
void rs_10_05_03_3(int *a, unsigned char b) {
	if (r1(*gpi) && b > 128) gc2++;
}
unsigned long rs_10_05_03_4(int *a, unsigned char b) {
	return (gula[b] << 23) << (b & 15);
}
void rs_10_05_04_0(long a, unsigned char b) {
	char t = rc(gi2);
	jc = t;
}
void rs_10_05_04_1(long a, unsigned char b) {
	char t = jc;
	v0();
	if (gs.d != 1.0) { gi2 = (gi2 | gs.a[t]) >> 14; } else { if (gps->i != 0) *gpi = 562 % gps->i; gs.l = 4L << (b & 15); }
}
void rs_10_05_04_2(long a, unsigned char b) {
	char t = jc;
	v0();
	guca[t] += b - guca[t];
}
char * rs_10_05_04_3(long a, unsigned char b) {
	return rp();
}
void rs_10_05_05_0(unsigned int a, unsigned long b, int *c) {
	guc *= 11;
}
long rs_10_05_05_1(unsigned int a, unsigned long b, int *c) {
	if (7 <= gc2) return 5L;
}
void rs_10_05_05_2(unsigned int a, unsigned long b, int *c) {
	switch (gu2) { case 1: gd -= gd2; case 5: gula[7] = gul ^ b; break; case 16: gs.d = gs.d * gd; break; case 20: gpl[0] |= gl2; break; case 1000: vc(gca[0]); break; }
}
long rs_10_05_05_3(unsigned int a, unsigned long b, int *c) {
	return (gl = 8L);
}
void rs_10_05_06_1(long *a, char *b, int c) {
	char *t = gps->p;
	jp = t;
}
void rs_10_05_06_2(long *a, char *b, int c) {
	if (guca[c] > 3) { gul = (gula[c] << 13) - (gul % 3UL); } else { gc2--; guc = (unsigned char)gula[2]; *gpl = (long)b[2] % 10L; }
}
void rs_10_05_06_3(long *a, char *b, int c) {
	char *t = jp;
	t = t + c;
}
void rs_10_05_06_4(long *a, char *b, int c) {
	int i = ji;
	i = 12; do { gu = gua[i] = (((unsigned int)guc) + 1) & ((unsigned int)(gul < ((unsigned long)gp[2]))); } while (--i > 0);
}
void rs_10_05_06_5(long *a, char *b, int c) {
	v0();
}
void rs_10_05_06_6(long *a, char *b, int c) {
	guc = (guc >> 5) - ~guc;
}
int * rs_10_05_06_7(long *a, char *b, int c) {
	return gpi;
}
void rs_10_05_07_0(char a, unsigned int b) {
	int *t = gpi + a;
	jpi = t;
}
void rs_10_05_07_1(char a, unsigned int b) {
	if (85 == a) vp(gps->p);
}
void rs_10_05_07_2(char a, unsigned int b) {
	gl &= *gpl << 24;
}
void rs_10_05_07_3(char a, unsigned int b) {
	int *t = jpi;
	v0();
	gpi = t;
}
char rs_10_05_07_4(char a, unsigned int b) {
	return a * (char)gs.a[b];
}
void rs_10_05_08_0(unsigned int a) {
	vs(gps);
}
void rs_10_05_08_1(unsigned int a) {
	v2(gi | gi3, gi);
}
void rs_10_05_08_2(unsigned int a) {
	gc2 = (char)!(gi2 >> 7);
}
int * rs_10_05_08_3(unsigned int a) {
	if (gia[0]) return gpi;
}
void rs_10_05_08_4(unsigned int a) {
	if (gu) { if (gia[a] != 0) gi3 = gia[a] / gia[a]; if (gula[5] != 0) gul = gula[a] % gula[5]; gps->c = gca[3] + 0; }
}
int * rs_10_05_08_5(unsigned int a) {
	return &gia[a];
}
void rs_10_05_09_1(int a, long b) {
	double t = -gd;
	jd = t;
}
void rs_10_05_09_2(int a, long b) {
	int u = (gul <= gula[a] ? *gpi : a);
	ji = u;
}
void rs_10_05_09_3(int a, long b) {
	double t = jd;
	gd = t;
}
void rs_10_05_09_4(int a, long b) {
	int u = ji;
	u--;
}
void rs_10_05_09_5(int a, long b) {
	int i = ji;
	for (i = 12; i > 0; i--) { v0(); v0(); if (gs.i != 0) gpi[2] = gpi[1] % gs.i; }
}
void rs_10_05_09_6(int a, long b) {
	gia[a] -= (int)gla[a];
}
void rs_10_05_09_7(int a, long b) {
	int u = ji;
	v0();
	u /= 3;
}
int rs_10_05_09_8(int a, long b) {
	return gi;
}
void rs_10_05_10_1(unsigned char a, unsigned char b, int c) {
	gps->c = gc = gs.c;
}
void rs_10_05_10_2(unsigned char a, unsigned char b, int c) {
	int i = ji;
	for (i = 14; i > 0; i--) { gu2 = gua[0]; }
}
void rs_10_05_10_3(unsigned char a, unsigned char b, int c) {
	int i = ji;
	for (i = 0; i < 9; i++) { if (gul != 0) gula[4] = 34645UL / gul; }
}
int rs_10_05_10_4(unsigned char a, unsigned char b, int c) {
	return (gi2 = gps->a[5]);
}
void rs_10_05_11_0(char a) {
	vu(gu2 / 4);
}
void rs_10_05_11_1(char a) {
	vc((char)!gps->c);
}
void rs_10_05_11_2(char a) {
	if (gc & 4) gs.u <<= (a & 15);
}
int rs_10_05_11_3(char a) {
	return gi;
}
void rs_10_05_12_1(unsigned long a) {
	unsigned int t = gu2 - gua[4];
	ju = t;
}
void rs_10_05_12_2(unsigned long a) {
	gca[1] = gs.c;
}
void rs_10_05_12_3(unsigned long a) {
	gda[2] += gd;
}
void rs_10_05_12_4(unsigned long a) {
	unsigned int t = ju;
	gu = (t << 8) / 3;
}
void rs_10_05_12_5(unsigned long a) {
	int i = ji;
	i = 8; do { gs.l >>= 17; } while (--i > 0);
}
int rs_10_05_12_6(unsigned long a) {
	return (gia[1] * 12) + -gi3;
}
void rs_10_05_13_0(void) {
	char *t = gps->p + 1;
	jp = t;
}
void rs_10_05_13_1(void) {
	vp(gp + 1);
}
void rs_10_05_13_2(void) {
	char *t = jp;
	v0();
	switch (gps->c) { case 0: t = t + 1; break; case 1: t[5] ^= gc2; break; case 2: gps->u ^= gua[3]; break; case 3: vd(gda[0]); break; case 4: gi3 += gs.a[6]; break; default: vu(gs.u); break; }
}
char * rs_10_05_13_3(void) {
	return rp();
}
void rs_10_05_14_0(int a, double b) {
	switch (gc) { case 2: vc(gca[a]); case 3: gpi = rpi(a); case 5: gps->c = (char)(gula[a] < gul); break; case 20: vp(gps->p); break; default: vs(gps); break; }
}
void rs_10_05_14_1(int a, double b) {
	gd += 2.5 + 0.25;
}
void rs_10_05_14_2(int a, double b) {
	gu2 = (gl != gps->l ? (gs.u & 29996) : (gu | 255));
}
void rs_10_05_14_3(int a, double b) {
	gda[3] += gd2 * gda[2];
}
void rs_10_05_14_4(int a, double b) {
	guc += 8 ^ 128;
}
int rs_10_05_14_5(int a, double b) {
	return gps->i + ~gi2;
}
void rs_10_05_15_0(char a, char b, unsigned long c) {
	gc2 -= (char)gps->l - 1;
}
void rs_10_05_15_1(char a, char b, unsigned long c) {
	gp[2] = 'z';
}
void rs_10_05_15_2(char a, char b, unsigned long c) {
	vc(gc);
}
void rs_10_05_15_3(char a, char b, unsigned long c) {
	if (gula[b] < 24039UL) if (gla[0] != 0) gl = 65536L % gla[0];
}
unsigned long rs_10_05_15_4(char a, char b, unsigned long c) {
	return gula[1];
}
void rs_10_05_16_1(void) {
	int t = r2(gi2, gi2);
	ji = t;
}
void rs_10_05_16_2(void) {
	int u = gi;
	v0();
	ji = u;
}
void rs_10_05_16_3(void) {
	int i = ji;
	v0();
	i = 0; while (i < 8) { if (gua[i] != 0) gu = gua[4] / gua[i]; if (gul != 0) gula[i] = ((unsigned long)gu) % gul; if (gul != 0) gul = gul % gul; i++; }
}
void rs_10_05_16_4(void) {
	int t = ji;
	v0();
	v1(t);
}
void rs_10_05_16_5(void) {
	guca[0] = guca[4] - guca[3];
}
void rs_10_05_16_6(void) {
	gc++;
}
void rs_10_05_16_7(void) {
	int u = ji;
	v0();
	v1(u);
}
long rs_10_05_16_8(void) {
	int t = ji;
	v0();
	return (gps->l * gl) >> (t & 15);
}
void rs_10_05_17_1(void) {
	int i = ji;
	i = 16; do { gla[i] -= gl | -25271L; } while (--i > 0);
}
void rs_10_05_17_2(void) {
	int i = ji;
	for (i = 0; i < 2; i++) { gp--; guca[i] %= 7; }
}
void rs_10_05_17_3(void) {
	if (!gu2) { ++gi2; v1(1); guca[0] = guc = (guc * guc) * (guc >> 3); } else { if (!guc) *gpl = gl2; }
}
int * rs_10_05_17_4(void) {
	return gpi + 1;
}
void rs_10_05_18_0(int *a) {
	gu = (!gi3 ? gua[4] : gu) >> 1;
}
void rs_10_05_18_1(int *a) {
	gl2 |= gps->l & gs.l;
}
int * rs_10_05_18_2(int *a) {
	if (2 == gia[1]) return &gia[6];
}
void rs_10_05_18_3(int *a) {
	gi2 = gpi[2] - (int)gp[3];
}
void rs_10_05_18_4(int *a) {
	a = gpi + 1;
}
int * rs_10_05_18_5(int *a) {
	return gpi;
}
void rs_10_05_19_0(char *a) {
	unsigned int t = 1 - gua[6];
	ju = t;
}
void rs_10_05_19_1(char *a) {
	++guc;
}
void rs_10_05_19_2(char *a) {
	gi2 = r2(gi3 ^ gpi[0], gi);
}
void rs_10_05_19_3(char *a) {
	unsigned int t = ju;
	v0();
	vu(t);
}
void rs_10_06_00_0(void) {
	unsigned long t = 0x10000UL;
	jul = t;
}
void rs_10_06_00_1(void) {
	int u = ~255;
	ji = u;
}
void rs_10_06_00_2(void) {
	gd2 += gd2 * gd2;
}
void rs_10_06_00_3(void) {
	gs.l <<= 7;
}
void rs_10_06_00_4(void) {
	vp(gp);
}
void rs_10_06_00_5(void) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
char rs_10_06_00_6(void) {
	if (gp[2] < gc) return -85;
}
void rs_10_06_00_7(void) {
	v2(9 / 100, gi);
}
void rs_10_06_00_8(void) {
	int u = ji;
	v0();
	v1(u);
}
char rs_10_06_00_9(void) {
	int u = ji;
	v0();
	return (gpi[2] & 4 ? rc(gs.a[u]) : ((char)gi3 + gca[6]));
}
void rs_10_06_01_0(char *a) {
	vp(&gca[2]);
}
void rs_10_06_01_1(char *a) {
	if (gl2 != 0) gl2 = gpl[1] / gl2;
}
void rs_10_06_01_2(char *a) {
	guc = (guc >> 5) - ((unsigned char)gc);
}
void rs_10_06_01_3(char *a) {
	gia[4] |= gps->a[3] / 16;
}
void rs_10_06_01_4(char *a) {
	if (gs.u != 0) gua[6] = 256 % gs.u;
}
unsigned int rs_10_06_01_5(char *a) {
	return (unsigned int)!guca[4];
}
void rs_10_06_02_0(unsigned char a, int b, int c) {
	char *t = gs.p;
	jp = t;
}
void rs_10_06_02_1(unsigned char a, int b, int c) {
	gps->i %= 10;
}
void rs_10_06_02_2(unsigned char a, int b, int c) {
	char *t = jp;
	vp(t);
}
void rs_10_06_02_3(unsigned char a, int b, int c) {
	gu2 = ((unsigned int)!gula[3]) % 7;
}
int rs_10_06_02_4(unsigned char a, int b, int c) {
	return (gi3 / 100) % 16;
}
void rs_10_06_03_1(void) {
	int t = -gi2;
	ji = t;
}
void rs_10_06_03_2(void) {
	int i = ji;
	int t = ji;
	for (i = 0; i < 4; i++) { gpi = gpi + t; if (t != 0) gs.a[i] = gi3 % t; }
}
void rs_10_06_03_3(void) {
	int t = ji;
	t = -(gi >> 6);
}
void rs_10_06_03_4(void) {
	int i = ji;
	for (i = 11; i > 0; i--) { vu(827 >> 15); if (gu2 != 0) gu = 21105 / gu2; gu2 += gu2 | gs.u; }
}
void rs_10_06_03_5(void) {
	gul &= -8UL;
}
int rs_10_06_03_6(void) {
	int t = ji;
	v0();
	return (294 >> 12) - t;
}
void rs_10_06_04_1(unsigned long a, char b) {
	v1(gia[0]);
}
void rs_10_06_04_2(unsigned long a, char b) {
	v2(gi2, (int)guc);
}
void rs_10_06_04_3(unsigned long a, char b) {
	gul = rul(gul) % 16UL;
}
void rs_10_06_04_4(unsigned long a, char b) {
	int i = ji;
	v0();
	i = 0; while (i < 14) { gps->a[i] = i + gia[i]; i++; }
}
long rs_10_06_04_5(unsigned long a, char b) {
	return (68464L - gla[3]) - (*gpl >> 16);
}
void rs_10_06_05_0(int a, int b) {
	gu *= 6;
}
void rs_10_06_05_1(int a, int b) {
	gula[3] = rul(gul);
}
void rs_10_06_05_2(int a, int b) {
	gul = (unsigned long)!(gi2 >> (a & 15));
}
void rs_10_06_05_3(int a, int b) {
	gu2 = 256;
}
void rs_10_06_06_0(char *a, double b, int c) {
	unsigned char t = guc >> (c & 7);
	juc = t;
}
void rs_10_06_06_1(char *a, double b, int c) {
	unsigned char t = juc;
	v1(t);
}
void rs_10_06_06_2(char *a, double b, int c) {
	gpi = rpi(gps->i);
}
void rs_10_06_06_3(char *a, double b, int c) {
	gl2 = -(~*gpl);
}
unsigned int rs_10_06_06_4(char *a, double b, int c) {
	unsigned char t = juc;
	v0();
	return ru((unsigned int)t);
}
void rs_10_06_07_0(double a) {
	gu2 = (4 + gu2) >> 13;
}
void rs_10_06_07_1(double a) {
	gi3 = -(0.25 >= gda[2]);
}
long rs_10_06_07_2(double a) {
	return -(0L - gl2);
}
void rs_10_06_08_1(int a, char b) {
	char *t = gs.p;
	jp = t;
}
void rs_10_06_08_2(int a, char b) {
	int i = ji;
	for (i = 13; i > 0; i--) { gula[i] = gula[i] + gula[b]; gua[i] = 1 >> 5; if (gl2 != 0) gs.l = gl / gl2; }
}
void rs_10_06_08_3(int a, char b) {
	char *t = jp;
	b = (char)!gps->l ^ (t[2] ^ gs.c);
}
unsigned long rs_10_06_08_4(int a, char b) {
	return gula[a] + (gula[5] & gul);
}
void rs_10_06_09_1(long *a, unsigned long b, long *c) {
	char *t = &gca[5];
	jp = t;
}
void rs_10_06_09_2(long *a, unsigned long b, long *c) {
	int u = gi3;
	ji = u;
}
void rs_10_06_09_3(long *a, unsigned long b, long *c) {
	int u = ji;
	if (gula[u] != 0) b = 5UL / gula[u];
}
void rs_10_06_09_4(long *a, unsigned long b, long *c) {
	char *t = jp;
	gp = t;
}
void rs_10_06_09_5(long *a, unsigned long b, long *c) {
	while (gi > 0) { gl += *c++; gi--; }
}
void rs_10_06_09_6(long *a, unsigned long b, long *c) {
	int u = ji;
	gua[u] >>= 5;
}
void rs_10_06_09_7(long *a, unsigned long b, long *c) {
	int i = ji;
	int u = ji;
	for (i = 3; i > 0; i--) { gu2 = gs.u - (gps->u & gu2); gla[i] *= 4L; }
}
void rs_10_06_09_8(long *a, unsigned long b, long *c) {
	int i = ji;
	gi3 = gs.i = (int)gps->c;
}
int rs_10_06_09_9(long *a, unsigned long b, long *c) {
	return (int)gla[7];
}
void rs_10_06_10_0(void) {
	if (gula[7] != 0) gula[3] = gula[0] / gula[7];
}
void rs_10_06_10_1(void) {
	guc -= 128;
}
void rs_10_06_10_2(void) {
	if (gl == -25429L) guca[6] = guca[2];
}
void rs_10_06_10_3(void) {
	gi2--;
}
void rs_10_06_10_4(void) {
	v0();
}
int rs_10_06_10_5(void) {
	return r2(gi2, gps->i >> 11);
}
void rs_10_06_11_1(struct st *a, int b) {
	char *t = rp();
	jp = t;
}
void rs_10_06_11_2(struct st *a, int b) {
	vc(gc2 * gs.c);
}
void rs_10_06_11_3(struct st *a, int b) {
	char *t = jp;
	v0();
	vp(t);
}
void rs_10_06_11_4(struct st *a, int b) {
	gu = (gua[b] + gu2) * 4;
}
void rs_10_06_11_5(struct st *a, int b) {
	int i = ji;
	v0();
	i = 0; while (i < 4) { gpi = &gia[i]; if (gu != 0) gua[i] = gua[i] / gu; i++; }
}
void rs_10_06_11_6(struct st *a, int b) {
	gl = rl((long)gul);
}
void rs_10_06_11_7(struct st *a, int b) {
	int i = ji;
	v0();
	i = 0; while (i < 9) { if (gs.c != 0) gca[i] = gca[i] % gs.c; i++; }
}
void rs_10_06_12_0(int a, int *b) {
	char *u = jp;
	char t = (char)gs.u;
	jc = t;
}
void rs_10_06_12_1(int a, int *b) {
	char *u = gps->p;
	jp = u;
}
void rs_10_06_12_2(int a, int *b) {
	char t = jc;
	if (guc) if (gula[t] != 0) gul = gul % gula[t];
}
void rs_10_06_12_3(int a, int *b) {
	char *u = jp;
	--u;
}
char rs_10_06_12_4(int a, int *b) {
	char t = jc;
	return gc >> (t & 7);
}
void rs_10_06_13_0(unsigned long a, unsigned char b) {
	int t = -*gpi;
	ji = t;
}
void rs_10_06_13_1(unsigned long a, unsigned char b) {
	int t = ji;
	*gpi = (guc == ((unsigned char)(t != 1)));
}
void rs_10_06_13_2(unsigned long a, unsigned char b) {
	gi2 = *gpi = r2(gi2, (int)0x10000UL);
}
void rs_10_06_13_3(unsigned long a, unsigned char b) {
	int t = ji;
	v0();
	gula[t] = gula[7] << 3;
}
void rs_10_06_13_4(unsigned long a, unsigned char b) {
	b = guca[0] * 128;
}
int rs_10_06_13_5(unsigned long a, unsigned char b) {
	int t = ji;
	v0();
	if (t < gia[t]) return gi2 * 4;
}
int rs_10_06_13_6(unsigned long a, unsigned char b) {
	int t = ji;
	v0();
	return t;
}
void rs_10_06_14_0(unsigned int a, int *b) {
	long t = -gl2;
	jl = t;
}
void rs_10_06_14_1(unsigned int a, int *b) {
	vu(ru(a));
}
void rs_10_06_14_2(unsigned int a, int *b) {
	guca[a] = ((unsigned char)gs.i) + guca[4];
}
void rs_10_06_14_3(unsigned int a, int *b) {
	long t = jl;
	v0();
	vl(t);
}
void rs_10_06_14_4(unsigned int a, int *b) {
	vd(10.0 + 2.5);
}
void rs_10_06_14_5(unsigned int a, int *b) {
	gd2 *= gd2;
}
int * rs_10_06_14_6(unsigned int a, int *b) {
	return rpi(2 >> 2);
}
void rs_10_06_15_0(void) {
	if (gca[1] < gc) { if (*gpi != 0) gi = gi3 % *gpi; } else { gi2 = r2(gia[7] & *gpi, gi); }
}
void rs_10_06_15_1(void) {
	guca[2] = guc = (5 / 16) + (guca[6] + 0);
}
char * rs_10_06_15_2(void) {
	return &gca[4];
}
void rs_10_06_16_0(long a, unsigned int b) {
	unsigned int t = ru(gu2);
	ju = t;
}
void rs_10_06_16_1(long a, unsigned int b) {
	++guc;
}
void rs_10_06_16_2(long a, unsigned int b) {
	unsigned int t = ju;
	v0();
	gu = t;
}
void rs_10_06_16_3(long a, unsigned int b) {
	gs.d *= gda[1] / 1.0;
}
char rs_10_06_16_4(long a, unsigned int b) {
	return rc(127);
}
void rs_10_06_17_0(double a) {
	int *t = &gia[2];
	jpi = t;
}
void rs_10_06_17_1(double a) {
	unsigned int u = gu - 255;
	ju = u;
}
void rs_10_06_17_2(double a) {
	gp = gps->p;
}
void rs_10_06_17_3(double a) {
	int *t = jpi;
	unsigned int u = ju;
	t = t + u;
}
void rs_10_06_17_4(double a) {
	a -= gda[1] * gs.d;
}
void rs_10_06_17_5(double a) {
	vs(gps);
}
void rs_10_06_18_0(int a, unsigned char b) {
	switch (gi) { case 1: guc %= 7; break; case 100: vu(255); break; case 1000: gl2 %= 3L; break; }
}
void rs_10_06_18_1(int a, unsigned char b) {
	gda[0] += 2.5;
}
void rs_10_06_18_2(int a, unsigned char b) {
	gua[6] = gu2 = gu;
}
unsigned int rs_10_06_18_3(int a, unsigned char b) {
	return ru(gu);
}
void rs_10_06_19_0(char *a) {
	int t = gps->i & gia[3];
	ji = t;
}
void rs_10_06_19_1(char *a) {
	double u = 3.0;
	jd = u;
}
void rs_10_06_19_2(char *a) {
	int t = ji;
	gpl[2] -= gpl[1] - gla[t];
}
void rs_10_06_19_3(char *a) {
	int t = ji;
	guc = (guc << (t & 7)) & (((unsigned char)gu2) - guc);
}
void rs_10_06_19_4(char *a) {
	int t = ji;
	double u = jd;
	switch (gi2) { case 5: gc2 = rc(gi); break; case 8: gs.u <<= 11; break; case 10: gpl[1] <<= 5; break; case 20: t *= 8; break; case 200: case 1000: gul <<= 10; break; default: gu = ru(255); break; }
}
unsigned int rs_10_06_19_5(char *a) {
	double u = jd;
	v0();
	return (gua[6] - gps->u) % 16;
}
void rs_10_07_00_1(int a, unsigned long b) {
	int t = r2(gi2, (int)gs.c);
	ji = t;
}
void rs_10_07_00_2(int a, unsigned long b) {
	int i = ji;
	v0();
	for (i = 14; i > 0; i--) { if (gl2 != 0) gl = gl % gl2; }
}
void rs_10_07_00_3(int a, unsigned long b) {
	int t = ji;
	v0();
	guca[t] = guc + guca[t];
}
int * rs_10_07_00_4(int a, unsigned long b) {
	return &gia[3];
}
void rs_10_07_01_0(unsigned long a, unsigned long b, int c) {
	char u = jc;
	unsigned int t = gps->u << 4;
	ju = t;
}
void rs_10_07_01_1(unsigned long a, unsigned long b, int c) {
	unsigned int t = ju;
	char u = (!gps->u ? gca[t] : gp[2]);
	jc = u;
}
void rs_10_07_01_2(unsigned long a, unsigned long b, int c) {
	unsigned int t = ju;
	char u = jc;
	if (gda[3] < 3.0) { gula[t] = gul; gp--; gpi = gpi + u; }
}
void rs_10_07_01_3(unsigned long a, unsigned long b, int c) {
	++gl2;
}
void rs_10_07_01_4(unsigned long a, unsigned long b, int c) {
	char u = jc;
	gc = (u / 7) + (gp[2] * gs.c);
}
void rs_10_07_01_5(unsigned long a, unsigned long b, int c) {
	gl = gla[2] = (a > b ? (gl + (long)gua[2]) : (gl - gpl[0]));
}
void rs_10_07_01_6(unsigned long a, unsigned long b, int c) {
	gpi[1] = gi2 & 127;
}
unsigned long rs_10_07_01_7(unsigned long a, unsigned long b, int c) {
	return (0UL % 2UL) - a;
}
void rs_10_07_02_0(unsigned char a, unsigned long b) {
	double t = (a ? gd : (double)gs.u);
	jd = t;
}
void rs_10_07_02_1(unsigned char a, unsigned long b) {
	if (gi2) { gu ^= gu2; }
}
void rs_10_07_02_2(unsigned char a, unsigned long b) {
	v0();
}
void rs_10_07_02_3(unsigned char a, unsigned long b) {
	*gpl = 3L & gl;
}
void rs_10_07_02_4(unsigned char a, unsigned long b) {
	vs(gps);
}
void rs_10_07_02_5(unsigned char a, unsigned long b) {
	double t = jd;
	v0();
	gd = t;
}
void rs_10_07_02_6(unsigned char a, unsigned long b) {
	gi++;
}
void rs_10_07_03_1(unsigned long a, unsigned int b, unsigned int c) {
	unsigned long t = rul(gula[b]);
	jul = t;
}
void rs_10_07_03_2(unsigned long a, unsigned int b, unsigned int c) {
	int u = gi2 >> (b & 15);
	v0();
	ji = u;
}
void rs_10_07_03_3(unsigned long a, unsigned int b, unsigned int c) {
	gl--;
}
void rs_10_07_03_4(unsigned long a, unsigned int b, unsigned int c) {
	if ((gla[b] = gl) <= 6741L) v2(gi2, 1 >> 10);
}
void rs_10_07_03_5(unsigned long a, unsigned int b, unsigned int c) {
	guca[6] = guca[1];
}
void rs_10_07_03_6(unsigned long a, unsigned int b, unsigned int c) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
void rs_10_07_03_7(unsigned long a, unsigned int b, unsigned int c) {
	int i = ji;
	v0();
	i = 4; do { gs.c = gc2 = 4; } while (--i > 0);
}
void rs_10_07_03_8(unsigned long a, unsigned int b, unsigned int c) {
	int i = ji;
	v0();
	i = 15; do { v0(); } while (--i > 0);
}
void rs_10_07_03_9(unsigned long a, unsigned int b, unsigned int c) {
	int u = ji;
	v0();
	v1(u);
}
unsigned long rs_10_07_03_10(unsigned long a, unsigned int b, unsigned int c) {
	return (((unsigned long)gp[2]) / 7UL) << 17;
}
void rs_10_07_04_1(int a, long b) {
	--gu2;
}
void rs_10_07_04_2(int a, long b) {
	int i = ji;
	for (i = 6; i > 0; i--) { gc2 = (6 >= 128 ? -11 : 31) | ((char)gia[i] ^ gca[0]); gs.l = (long)(*gp / 3); gc2 -= gs.c & -28; }
}
void rs_10_07_04_3(int a, long b) {
	vc(0);
}
int * rs_10_07_04_4(int a, long b) {
	return gpi;
}
void rs_10_07_05_0(double a) {
	gua[1] = gu2;
}
void rs_10_07_05_1(double a) {
	if (gc2 != 0) gc2 = gc2 / gc2;
}
char rs_10_07_05_2(double a) {
	return -gc2 / 16;
}
void rs_10_07_06_0(void) {
	int t = -405 & 100;
	ji = t;
}
void rs_10_07_06_1(void) {
	int t = ji;
	switch (gc2) { case 16: gul -= gula[t]; break; case 20: gula[1] <<= 25; break; }
}
void rs_10_07_06_2(void) {
	vs(gps);
}
void rs_10_07_06_3(void) {
	int t = ji;
	v0();
	if (gp[1] >= gc2) { gu2 = gu2 & ru(1); gula[t] = gula[t] * 10UL; } else { if (gca[7] != 0) gc2 = gca[t] / gca[7]; if (gua[t] != 0) gps->u = 32767 / gua[t]; if (gl != 0) gs.l = gla[6] / gl; }
}
unsigned long rs_10_07_06_4(void) {
	int t = ji;
	v0();
	if (r2(t, gi)) return gula[t] + gul;
}
void rs_10_07_06_5(void) {
	int t = ji;
	v0();
	if (gl2 < 65536L) gi = t = gi3 - (gi & t);
}
unsigned long rs_10_07_06_6(void) {
	return 8UL * 8UL;
}
void rs_10_07_07_0(void) {
	int t = 256;
	ji = t;
}
void rs_10_07_07_1(void) {
	int t = ji;
	v1(t);
}
void rs_10_07_07_2(void) {
	gc = 6;
}
void rs_10_07_07_3(void) {
	++gul;
}
void rs_10_07_08_1(unsigned int a, unsigned int b, unsigned int c) {
	char t = gc;
	jc = t;
}
void rs_10_07_08_2(unsigned int a, unsigned int b, unsigned int c) {
	int i = ji;
	for (i = 0; i < 13; i++) { if (b != 0) gps->u = gu / b; guc -= 255; }
}
void rs_10_07_08_3(unsigned int a, unsigned int b, unsigned int c) {
	gps->c = (char)((256 | 25259) == (((unsigned int)gia[c]) / 100));
}
void rs_10_07_08_4(unsigned int a, unsigned int b, unsigned int c) {
	gul--;
}
void rs_10_07_08_5(unsigned int a, unsigned int b, unsigned int c) {
	char t = jc;
	gc = t;
}
void rs_10_07_09_0(void) {
	unsigned char t = 255 ^ 3;
	juc = t;
}
void rs_10_07_09_1(void) {
	unsigned char t = juc;
	gca[t] = (char)('0' <= *gp);
}
void rs_10_07_09_2(void) {
	unsigned char t = juc;
	if (gpi[2] & 0x10) { t = (unsigned char)((gc2 + gp[2]) <= (char)!gi); ++t; } else { gps->u >>= 7; gs.i = 2; gl = gl2 = gps->l & (gl + gl2); }
}
char * rs_10_07_09_3(void) {
	return gps->p;
}
void rs_10_07_10_0(void) {
	unsigned char t = guca[3] | guc;
	juc = t;
}
void rs_10_07_10_1(void) {
	long u = rl(gl2);
	jl = u;
}
void rs_10_07_10_2(void) {
	vl(1L * 6L);
}
void rs_10_07_10_3(void) {
	gpi[0] = r1(*gpi);
}
void rs_10_07_10_4(void) {
	long u = jl;
	v0();
	gl = u;
}
void rs_10_07_10_5(void) {
	--gl;
}
void rs_10_07_10_6(void) {
	gi |= *gpi;
}
void rs_10_07_10_7(void) {
	unsigned char t = juc;
	v0();
	v1(t);
}
void rs_10_07_11_0(void) {
	char *t = gs.p;
	jp = t;
}
void rs_10_07_11_1(void) {
	gpl[2] = gpl[0] + 0L;
}
void rs_10_07_11_2(void) {
	gua[2] = gu;
}
void rs_10_07_11_3(void) {
	gu = gu2 = gs.u % 10;
}
void rs_10_07_11_4(void) {
	char *t = jp;
	if (*t & 0x7 && guca[1] & 0x8) gc &= t[0];
}
char rs_10_07_11_5(void) {
	return gp[1] * (char)!*gpl;
}
void rs_10_07_12_0(void) {
	gps->l = *gpl;
}
void rs_10_07_12_1(void) {
	gs.p = gp;
}
void rs_10_07_12_2(void) {
	guca[3] = (unsigned char)!*gp;
}
void rs_10_07_12_3(void) {
	++gi3;
}
int rs_10_07_12_4(void) {
	return !guca[3] * gs.a[2];
}
void rs_10_07_13_0(unsigned long a, int b, char c) {
	char t = (char)b;
	jc = t;
}
void rs_10_07_13_1(unsigned long a, int b, char c) {
	unsigned int u = gps->u;
	ju = u;
}
void rs_10_07_13_2(unsigned long a, int b, char c) {
	gula[5] = a;
}
void rs_10_07_13_3(unsigned long a, int b, char c) {
	char t = jc;
	unsigned int u = ju;
	if (65536L != -16368L) { gi3 = ((c = 'A') ? (gula[3] < a ? 952 : gia[t]) : (gia[t] % 2)); gul = a = a >> 4; } else { if (u & 0x7) gi3 = gi2; }
}
int rs_10_07_13_4(unsigned long a, int b, char c) {
	return 323;
}
void rs_10_07_14_0(void) {
	double t = gda[2];
	jd = t;
}
void rs_10_07_14_1(void) {
	if (guca[1] & 2) --gl2;
}
void rs_10_07_14_2(void) {
	v2(gs.i / 4, gi);
}
void rs_10_07_14_3(void) {
	double t = jd;
	v0();
	gd = t;
}
char rs_10_07_14_4(void) {
	return (char)gu;
}
void rs_10_07_15_1(long a) {
	long t = ~gs.l;
	jl = t;
}
void rs_10_07_15_2(long a) {
	long u = gpl[3] | gl;
	jl = u;
}
void rs_10_07_15_3(long a) {
	gul = (*gp & 4 ? rul(gul) : rul(gul));
}
void rs_10_07_15_4(long a) {
	long u = jl;
	v0();
	vl(u);
}
void rs_10_07_15_5(long a) {
	int i = ji;
	long t = jl;
	v0();
	i = 0; while (i < 4) { vl(-t); gl = t = (t & gl2) - ~gl; i++; }
}
void rs_10_07_16_0(char *a, unsigned int b, char c) {
	char *t = a;
	jp = t;
}
void rs_10_07_16_1(char *a, unsigned int b, char c) {
	unsigned int u = gua[b] - b;
	ju = u;
}
void rs_10_07_16_2(char *a, unsigned int b, char c) {
	gul = 3UL ^ (3UL - gul);
}
void rs_10_07_16_3(char *a, unsigned int b, char c) {
	char *t = jp;
	gp = t;
}
void rs_10_07_16_4(char *a, unsigned int b, char c) {
	gi3 >>= 2;
}
void rs_10_07_16_5(char *a, unsigned int b, char c) {
	b = 256;
}
void rs_10_07_16_6(char *a, unsigned int b, char c) {
	gula[c] = gul = -gula[b];
}
void rs_10_07_16_7(char *a, unsigned int b, char c) {
	unsigned int u = ju;
	vu(u);
}
unsigned int rs_10_07_16_8(char *a, unsigned int b, char c) {
	unsigned int u = ju;
	v0();
	return ru(256 - u);
}
void rs_10_07_17_0(int a) {
	int *t = gpi + a;
	jpi = t;
}
void rs_10_07_17_1(int a) {
	int u = gs.i;
	ji = u;
}
void rs_10_07_17_2(int a) {
	gu2 += gu & gu2;
}
void rs_10_07_17_3(int a) {
	int u = ji;
	gi = u;
}
void rs_10_07_17_4(int a) {
	int *t = jpi;
	gi2 = (gia[2] + gpi[0]) | (t[0] * 4);
}
char rs_10_07_18_1(void) {
	int i = ji;
	if (r2(gi2, gps->i)) return rc(gps->i);
}
char rs_10_07_18_2(void) {
	if (65536L < gl || gps->u & 2) return gc << 5;
}
void rs_10_07_18_3(void) {
	int i = ji;
	v0();
	i = 0; while (i < 14) { gla[i] = (long)!gc2; guc >>= 5; i++; }
}
void rs_10_07_18_4(void) {
	*gpl = ~(-96995L);
}
char rs_10_07_18_5(void) {
	return ~(char)!*gp;
}
void rs_10_07_19_0(void) {
	double t = gda[3] - gd2;
	jd = t;
}
void rs_10_07_19_1(void) {
	--gul;
}
void rs_10_07_19_2(void) {
	double t = jd;
	gd = t;
}
void rs_10_07_19_3(void) {
	gps->a[5] = ((int)gu2 - gi2) >> 4;
}
void rs_10_07_19_4(void) {
	if (gc <= gc2) vl((guca[5] & 4 ? (long)gul : 2L));
}
void rs_10_07_19_5(void) {
	if (r0() && gps->l < gla[5]) vp(gps->p + 1);
}
void rs_10_07_19_6(void) {
	gc -= gc % 3;
}
char rs_10_07_19_7(void) {
	return (gp[1] = gc);
}
void rs_10_08_00_1(unsigned int a, unsigned char b, long c) {
	char *t = gp;
	jp = t;
}
void rs_10_08_00_2(unsigned int a, unsigned char b, long c) {
	gua[6] = a;
}
void rs_10_08_00_3(unsigned int a, unsigned char b, long c) {
	int i = ji;
	for (i = 0; i < 8; i++) { gu = ru(255) | gu; gpi++; }
}
void rs_10_08_00_4(unsigned int a, unsigned char b, long c) {
	char *t = jp;
	v0();
	vp(t);
}
char rs_10_08_00_5(unsigned int a, unsigned char b, long c) {
	return gc2;
}
void rs_10_08_01_0(struct st *a) {
	gl += gla[4] / 16L;
}
void rs_10_08_01_1(struct st *a) {
	gc = rc(256 * 4);
}
void rs_10_08_01_2(struct st *a) {
	if (guca[4]) { vc(gca[2]); }
}
void rs_10_08_01_3(struct st *a) {
	vc(-24);
}
void rs_10_08_01_4(struct st *a) {
	gps->c = gc;
}
int rs_10_08_01_5(struct st *a) {
	return !guc & -gs.i;
}
void rs_10_08_02_0(int a) {
	unsigned long t = ((unsigned long)*gp) >> 16;
	jul = t;
}
void rs_10_08_02_1(int a) {
	unsigned long t = jul;
	unsigned long u = (r1(100) ? 7UL : t);
	jul = u;
}
void rs_10_08_02_2(int a) {
	if (!gi) { if (gi2 != 0) a = a / gi2; gpi = rpi(gia[a] % 100); }
}
void rs_10_08_02_3(int a) {
	vc(gca[a]);
}
void rs_10_08_02_4(int a) {
	gc--;
}
void rs_10_08_02_5(int a) {
	unsigned long u = jul;
	v0();
	if ((guc = 255) < 3) { gps->u = gua[6] - gu2; if (gs.l != 0) gpl[1] = gla[a] % gs.l; if (gc2 != 0) gc = gca[a] % gc2; }
}
void rs_10_08_02_6(int a) {
	unsigned long t = jul;
	v0();
	gul = t;
}
char * rs_10_08_02_7(int a) {
	return gp;
}
void rs_10_08_03_0(char a, struct st *b, long *c) {
	int *t = &gia[a];
	jpi = t;
}
void rs_10_08_03_1(char a, struct st *b, long *c) {
	unsigned int u = (unsigned int)!gul;
	ju = u;
}
void rs_10_08_03_2(char a, struct st *b, long *c) {
	unsigned int u = ju;
	gua[a] = b->u = gu;
}
void rs_10_08_03_3(char a, struct st *b, long *c) {
	vu(~256);
}
void rs_10_08_03_4(char a, struct st *b, long *c) {
	if (gps->c == ' ') { v0(); }
}
void rs_10_08_03_5(char a, struct st *b, long *c) {
	unsigned int u = ju;
	v0();
	u = u - (gu2 >> 2);
}
void rs_10_08_03_6(char a, struct st *b, long *c) {
	a &= 99 ^ a;
}
void rs_10_08_03_7(char a, struct st *b, long *c) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_10_08_04_0(void) {
	unsigned int t = gu - 1;
	ju = t;
}
void rs_10_08_04_1(void) {
	unsigned int t = ju;
	unsigned int u = t ^ 256;
	ju = u;
}
void rs_10_08_04_2(void) {
	unsigned int t = ju;
	gu = t;
}
void rs_10_08_04_3(void) {
	switch (gps->c) { case 0: v2(2, gi); break; case 1: case 2: case 3: guc += guca[4]; }
}
void rs_10_08_04_4(void) {
	gpl[1] = gl2 << 7;
}
void rs_10_08_04_5(void) {
	unsigned int u = ju;
	v0();
	vu(u);
}
void rs_10_08_04_6(void) {
	gl2 /= 10L;
}
void rs_10_08_04_7(void) {
	if (gl2 != 0) gs.l = gl2 % gl2;
}
unsigned long rs_10_08_04_8(void) {
	unsigned int u = ju;
	v0();
	return rul((unsigned long)gia[u]);
}
void rs_10_08_05_0(int *a) {
	double t = (!guca[6] ? gs.d : 3.0);
	jd = t;
}
void rs_10_08_05_1(int *a) {
	long u = ~gl;
	jl = u;
}
void rs_10_08_05_2(int *a) {
	double t = jd;
	vd(t);
}
void rs_10_08_05_3(int *a) {
	long u = jl;
	v0();
	if (r2(*gpi, gi)) gpl[0] = (u - gl2) % 7L;
}
void rs_10_08_05_4(int *a) {
	gps->i = 996 ^ -156;
}
void rs_10_08_05_5(int *a) {
	--gc2;
}
char rs_10_08_05_6(int *a) {
	return gps->c;
}
int rs_10_08_06_0(int a, unsigned int b) {
	if (gia[b] & 0x10) return gi3 - gi2;
}
void rs_10_08_06_1(int a, unsigned int b) {
	gc2 += 8;
}
void rs_10_08_06_2(int a, unsigned int b) {
	gula[4] = (gula[a] - gula[1]) ^ (gula[b] / 16UL);
}
void rs_10_08_06_3(int a, unsigned int b) {
	b |= gu2 + gua[0];
}
int rs_10_08_06_4(int a, unsigned int b) {
	return 255;
}
void rs_10_08_07_0(int a) {
	unsigned char t = (unsigned char)!gul;
	juc = t;
}
void rs_10_08_07_1(int a) {
	int u = (gu2 == gua[2]);
	ji = u;
}
void rs_10_08_07_2(int a) {
	while (a > 0) { gc2 += *gp++; a--; }
}
void rs_10_08_07_3(int a) {
	unsigned char t = juc;
	if (gua[t]) { t /= 3; vu(gu2 & gua[t]); vp(&gca[t]); }
}
void rs_10_08_07_4(int a) {
	int u = ji;
	v0();
	v1(u);
}
char * rs_10_08_07_5(int a) {
	return gps->p;
}
void rs_10_08_08_0(void) {
	char t = (char)(100.0 < gs.d);
	jc = t;
}
void rs_10_08_08_1(void) {
	int u = 8;
	ji = u;
}
void rs_10_08_08_2(void) {
	gd = 100.0 - gs.d;
}
void rs_10_08_08_3(void) {
	char t = jc;
	vc(t);
}
void rs_10_08_08_4(void) {
	vs(gps);
}
void rs_10_08_08_5(void) {
	int u = ji;
	v0();
	gi = u;
}
int * rs_10_08_08_6(void) {
	char t = jc;
	v0();
	return gpi + t;
}
void rs_10_08_09_0(unsigned char a) {
	if (guca[7] & 0x8) if (gla[7] != 0) gl2 = gl % gla[7];
}
void rs_10_08_09_1(unsigned char a) {
	gla[5] = gpl[1] = (65536L / 2L) << 17;
}
void rs_10_08_09_2(unsigned char a) {
	gia[a] >>= (a & 15);
}
void rs_10_08_09_3(unsigned char a) {
	gs.l = gl2 = (gl2 & gla[1]) + (gpl[2] - 45439L);
}
int * rs_10_08_09_4(unsigned char a) {
	return rpi(100 << 14);
}
void rs_10_08_10_0(char *a, unsigned long b) {
	char t = gps->c;
	jc = t;
}
void rs_10_08_10_1(char *a, unsigned long b) {
	gu2 += ru(gu);
}
void rs_10_08_10_2(char *a, unsigned long b) {
	char t = jc;
	v0();
	vc(t);
}
int rs_10_08_10_3(char *a, unsigned long b) {
	if (gps->l || r1(gi3)) return gpi[2];
}
int rs_10_08_10_4(char *a, unsigned long b) {
	return gi2;
}
void rs_10_08_11_0(void) {
	unsigned int t = 255 - gu;
	ju = t;
}
void rs_10_08_11_1(void) {
	unsigned int t = ju;
	gu = t;
}
void rs_10_08_11_2(void) {
	gl += 65536L;
}
void rs_10_08_11_3(void) {
	if (gc2) { v0(); if (gl != 0) gl2 = gl % gl; if (gula[5] != 0) gul = gul / gula[5]; }
}
void rs_10_08_11_4(void) {
	--gi;
}
void rs_10_08_11_5(void) {
	if (gc2) v0();
}
long rs_10_08_11_6(void) {
	return gl;
}
void rs_10_08_12_0(int a, long *b, long *c) {
	char *t = gp + a;
	jp = t;
}
void rs_10_08_12_1(int a, long *b, long *c) {
	int u = gi2 | gi3;
	ji = u;
}
void rs_10_08_12_2(int a, long *b, long *c) {
	char *t = jp;
	gp = t;
}
void rs_10_08_12_3(int a, long *b, long *c) {
	if (guc == 128) { if (gl2 != 0) *c = 65536L / gl2; guc = 128; gla[1] = gl = (r2(gi2, gs.i) ? (gla[4] & *gpl) : (gpl[0] - gps->l)); }
}
void rs_10_08_12_4(int a, long *b, long *c) {
	vu((unsigned int)!gc2);
}
void rs_10_08_12_5(int a, long *b, long *c) {
	int u = ji;
	v0();
	vu((gps->a[0] ? 9958 : gps->u));
}
long rs_10_08_12_6(int a, long *b, long *c) {
	return (long)((unsigned int)(*gp <= -23));
}
void rs_10_08_13_0(long *a, char b) {
	unsigned char t = (unsigned char)!49;
	juc = t;
}
void rs_10_08_13_1(long *a, char b) {
	unsigned char t = juc;
	unsigned char u = (gul == 2UL ? t : 128);
	juc = u;
}
void rs_10_08_13_2(long *a, char b) {
	if (gi2 != 0) gi = gs.a[7] / gi2;
}
void rs_10_08_13_3(long *a, char b) {
	*a %= 2L;
}
void rs_10_08_13_4(long *a, char b) {
	unsigned char t = juc;
	if (gc2 & 2 && ((unsigned long)t) == 80712UL) gula[1] &= gul;
}
void rs_10_08_13_5(long *a, char b) {
	unsigned char t = juc;
	unsigned char u = juc;
	guc = (gula[t] & 4 ? u : u) * u;
}
long rs_10_08_13_6(long *a, char b) {
	return (gl + 65536L) - (gl >> 16);
}
void rs_10_08_14_0(char a, int b, int c) {
	double t = gda[0] + gda[2];
	jd = t;
}
void rs_10_08_14_1(char a, int b, int c) {
	switch (gu2) { case 1: case 8: gp = &gca[a]; break; case 10: *gpi *= 4; break; case 20: v2(c, gi); break; case 100: gps->l &= 94169L; break; }
}
void rs_10_08_14_2(char a, int b, int c) {
	gl = (long)!gul;
}
void rs_10_08_14_3(char a, int b, int c) {
	double t = jd;
	v0();
	gd = t;
}
void rs_10_08_14_4(char a, int b, int c) {
	if (gi == 92) { vc(gc); if (gla[5] != 0) gl2 = 25424L % gla[5]; }
}
void rs_10_08_14_5(char a, int b, int c) {
	gs.u ^= -255;
}
void rs_10_08_14_6(char a, int b, int c) {
	--guc;
}
int rs_10_08_14_7(char a, int b, int c) {
	return -(gi3 - gps->a[b]);
}
void rs_10_08_15_1(double a, unsigned long b) {
	unsigned long t = (unsigned long)(gul == b);
	jul = t;
}
void rs_10_08_15_2(double a, unsigned long b) {
	int i = ji;
	for (i = 0; i < 12; i++) { if (gla[i] != 0) gla[i] = gl / gla[i]; guca[i] = guc = -(guc | guca[i]); }
}
void rs_10_08_15_3(double a, unsigned long b) {
	unsigned long t = jul;
	t = (unsigned long)!rul(13526UL);
}
void rs_10_08_15_4(double a, unsigned long b) {
	vu(ru(gua[1]));
}
void rs_10_08_15_5(double a, unsigned long b) {
	guca[3] = guca[6] - guc;
}
int rs_10_08_15_6(double a, unsigned long b) {
	int i = ji;
	v0();
	return (gps->a[2] = gps->i);
}
void rs_10_08_16_1(void) {
	int t = gi2 >> 7;
	ji = t;
}
void rs_10_08_16_2(void) {
	int t = ji;
	unsigned long u = (unsigned long)gua[t];
	jul = u;
}
void rs_10_08_16_3(void) {
	gu2 /= 2;
}
void rs_10_08_16_4(void) {
	int i = ji;
	int t = ji;
	i = 7; do { t = gpi[2] = gi3 % 7; guc = (((unsigned int)t) == gua[i] ? guc : guc) / 2; if (gia[i] != 0) gps->a[i] = gps->a[i] % gia[i]; } while (--i > 0);
}
void rs_10_08_16_5(void) {
	unsigned long u = jul;
	gul = u;
}
int rs_10_08_16_6(void) {
	return (int)gca[7];
}
void rs_10_08_17_0(char a) {
	char *u = jp;
	int t = -(int)gs.u;
	ji = t;
}
void rs_10_08_17_1(char a) {
	char *u = gs.p;
	jp = u;
}
void rs_10_08_17_2(char a) {
	char *u = jp;
	vl((long)!*u);
}
void rs_10_08_17_3(char a) {
	int t = ji;
	v0();
	t = ~(~(int)gu);
}
void rs_10_08_17_4(char a) {
	char *u = jp;
	v0();
	gi = gi3 = (*u ? (gi3 % 7) : !gia[7]);
}
int rs_10_08_17_5(char a) {
	int t = ji;
	v0();
	return t;
}
void rs_10_08_18_0(double a, char *b, char c) {
	unsigned int t = 1;
	ju = t;
}
void rs_10_08_18_1(double a, char *b, char c) {
	char u = -gca[c];
	jc = u;
}
void rs_10_08_18_2(double a, char *b, char c) {
	guc = ((unsigned char)'z') + guc;
}
void rs_10_08_18_3(double a, char *b, char c) {
	char u = jc;
	if ((gula[u] = gul) >= 0x10000UL) { v2((int)guca[4], gi); if (gia[6] != 0) gs.i = gi2 % gia[6]; vs(gps); }
}
void rs_10_08_18_4(double a, char *b, char c) {
	char u = jc;
	v0();
	vc(gc + u);
}
void rs_10_08_18_5(double a, char *b, char c) {
	unsigned int t = ju;
	v0();
	gu = t;
}
unsigned long rs_10_08_18_6(double a, char *b, char c) {
	char u = jc;
	v0();
	return (((unsigned long)u) ^ 81444UL) ^ gul;
}
void rs_10_08_19_0(char a) {
	int t = (int)gl2;
	ji = t;
}
void rs_10_08_19_1(char a) {
	int *u = rpi(gia[7]);
	jpi = u;
}
void rs_10_08_19_2(char a) {
	if (gl < 62318L) { gul++; gc2 %= 16; } else { if (gs.l != 0) gps->l = gl % gs.l; gd -= -gda[3]; }
}
void rs_10_08_19_3(char a) {
	gd2 = gs.d;
}
void rs_10_08_19_4(char a) {
	guca[6] &= (unsigned char)5;
}
void rs_10_08_19_5(char a) {
	int t = ji;
	v0();
	v1(t);
}
void rs_10_08_19_6(char a) {
	if (r1(gi)) { vl(gl % 3L); }
}
void rs_10_08_19_7(char a) {
	int *u = jpi;
	v0();
	gpi = u;
}
unsigned int rs_10_08_19_8(char a) {
	return (gu2 >> 1) >> (a & 15);
}
void rs_10_09_00_0(struct st *a, struct st *b) {
	guc >>= 4;
}
void rs_10_09_00_1(struct st *a, struct st *b) {
	if (gla[0] >= gpl[1]) { guc *= 7; } else { gul -= 1UL >> 23; }
}
void rs_10_09_00_2(struct st *a, struct st *b) {
	v2((((unsigned char)gla[3]) > guca[0]), gi);
}
unsigned long rs_10_09_00_3(struct st *a, struct st *b) {
	return gul / 10UL;
}
void rs_10_09_01_0(int a, double b) {
	*gpl = (long)gi3 / 10L;
}
void rs_10_09_01_1(int a, double b) {
	gpl[1] *= 2L;
}
void rs_10_09_01_2(int a, double b) {
	gs.d *= b;
}
void rs_10_09_01_3(int a, double b) {
	gpi = gpi + a;
}
void rs_10_09_02_1(unsigned char a, long b, unsigned int c) {
	unsigned char t = guca[4] * 7;
	juc = t;
}
void rs_10_09_02_2(unsigned char a, long b, unsigned int c) {
	unsigned char t = juc;
	a = ~(a - t);
}
void rs_10_09_02_3(unsigned char a, long b, unsigned int c) {
	int i = ji;
	for (i = 0; i < 14; i++) { if (c != 0) gua[i] = c % c; gs.p = gs.p + a; }
}
void rs_10_09_02_4(unsigned char a, long b, unsigned int c) {
	gp[2] ^= gs.c;
}
int rs_10_09_02_5(unsigned char a, long b, unsigned int c) {
	unsigned char t = juc;
	return (t == (guca[t] + 128));
}
void rs_10_09_03_1(struct st *a, double b, int c) {
	if (!gula[0]) { vp(gs.p); a->p = a->p + c; gua[c] = gu2 = (unsigned int)(gul <= (0x10000UL + ((unsigned long)*gp))); }
}
void rs_10_09_03_2(struct st *a, double b, int c) {
	int i = ji;
	v0();
	for (i = 0; i < 15; i++) { ++gi3; }
}
void rs_10_09_03_3(struct st *a, double b, int c) {
	if (guc > guca[c]) { gl++; vs(gps); gula[0] = ((int)gula[6] != 8 ? gula[c] : gula[c]); } else { if (a->u != 0) gua[1] = gu2 % a->u; guca[2] += guc - guca[c]; guca[6] = guc; }
}
int rs_10_09_03_4(struct st *a, double b, int c) {
	return gps->a[c];
}
void rs_10_09_04_0(int a) {
	double t = gda[3];
	jd = t;
}
void rs_10_09_04_1(int a) {
	int u = 100;
	ji = u;
}
void rs_10_09_04_2(int a) {
	int u = ji;
	gla[u] %= 3L;
}
void rs_10_09_04_3(int a) {
	double t = jd;
	gd = t;
}
void rs_10_09_04_4(int a) {
	gpi = gpi + a;
}
void rs_10_09_04_5(int a) {
	int u = ji;
	guc = (unsigned char)((gc2 << (u & 7)) == *gp);
}
int rs_10_09_04_6(int a) {
	return r1(gi3) + (int)gu;
}
void rs_10_09_05_0(double a) {
	int t = gi3 + gi2;
	ji = t;
}
void rs_10_09_05_1(double a) {
	int t = ji;
	gs.d = (gs.u <= ((unsigned int)guca[t]) ? (double)gs.u : gda[1]);
}
void rs_10_09_05_2(double a) {
	int t = ji;
	gula[t] = gul = gula[7] + ((unsigned long)*gpl);
}
void rs_10_09_05_3(double a) {
	int t = ji;
	guca[t] = guc = -(-guca[t]);
}
void rs_10_09_05_4(double a) {
	int t = ji;
	v2(gia[4] + t, gi);
}
unsigned int rs_10_09_05_5(double a) {
	return (gua[6] = 1);
}
void rs_10_09_06_0(unsigned long a, unsigned int b, unsigned int c) {
	if ('0' < gp[1]) if (gula[c] != 0) gul = 0x10000UL % gula[c];
}
void rs_10_09_06_1(unsigned long a, unsigned int b, unsigned int c) {
	gul = -a * 10UL;
}
void rs_10_09_06_2(unsigned long a, unsigned int b, unsigned int c) {
	gpl[1] += ~7464L;
}
void rs_10_09_07_0(void) {
	gul = gula[7] = (unsigned long)!guc;
}
void rs_10_09_07_1(void) {
	v2(gi2, gi3 & gi);
}
void rs_10_09_07_2(void) {
	gpi = gpi + 1;
}
void rs_10_09_07_3(void) {
	gca[0] = rc(gi2);
}
char rs_10_09_07_4(void) {
	return rc(gia[5]) - (*gp * gc2);
}
void rs_10_09_08_0(char *a) {
	gula[3] -= gul + 0UL;
}
void rs_10_09_08_1(char *a) {
	gd2 = ((double)gl + gd2) / 0.5;
}
void rs_10_09_08_2(char *a) {
	if (gi) { gpl[3] /= 7L; gpi = rpi((int)a[2] + gpi[1]); gl = gla[7]; }
}
char * rs_10_09_08_3(char *a) {
	return gp;
}
unsigned int rs_10_09_09_1(char a, int b) {
	if (r2(gi2, gs.a[6])) return ru(gu);
}
void rs_10_09_09_2(char a, int b) {
	gua[a] = gu2 = (unsigned int)!(gula[0] + gula[7]);
}
void rs_10_09_09_3(char a, int b) {
	int i = ji;
	v0();
	i = 0; while (i < b) { --gul; ++gi3; i++; }
}
void rs_10_09_09_4(char a, int b) {
	vl(gs.l);
}
unsigned int rs_10_09_09_5(char a, int b) {
	return gps->u;
}
void rs_10_09_10_0(unsigned long a, unsigned long b) {
	unsigned char t = guc << 6;
	juc = t;
}
char * rs_10_09_10_1(unsigned long a, unsigned long b) {
	unsigned char t = juc;
	if (gla[t]) return &gca[t];
}
void rs_10_09_10_2(unsigned long a, unsigned long b) {
	switch (gps->l) { case 1L: gla[6] -= gs.l; break; case 200L: gul = (unsigned long)(gda[2] > gda[3]); break; }
}
char * rs_10_09_10_3(unsigned long a, unsigned long b) {
	return gp;
}
void rs_10_09_11_1(void) {
	unsigned int t = 1 + 256;
	ju = t;
}
void rs_10_09_11_2(void) {
	unsigned int u = ru(gu);
	ju = u;
}
void rs_10_09_11_3(void) {
	int i = ji;
	unsigned int t = ju;
	v0();
	for (i = 0; i < 8; i++) { v2(gia[4] ^ i, gi); ++t; }
}
void rs_10_09_11_4(void) {
	unsigned int u = ju;
	v0();
	gu = u;
}
void rs_10_09_11_5(void) {
	unsigned int u = ju;
	v0();
	gps->a[4] = (int)(gs.u << 12);
}
void rs_10_09_11_6(void) {
	if (((unsigned char)gula[6]) < guca[0]) gi2 += 8;
}
void rs_10_09_11_7(void) {
	unsigned int t = ju;
	v0();
	guca[7] += 128 * guca[t];
}
long rs_10_09_11_8(void) {
	return *gpl + (gla[0] << 15);
}
void rs_10_09_12_0(char a) {
	unsigned char t = guc ^ 31;
	juc = t;
}
void rs_10_09_12_1(char a) {
	char *u = gp;
	jp = u;
}
void rs_10_09_12_2(char a) {
	gd2 = (1.0 + gd) + gda[3];
}
void rs_10_09_12_3(char a) {
	unsigned char t = juc;
	char *u = jp;
	switch (gu2) { case 0: case 1: gula[a] = ((unsigned long)gi2) + gul; break; case 2: vc(a); default: vp(u + t); break; }
}
void rs_10_09_12_4(char a) {
	gula[a] -= -gula[a];
}
void rs_10_09_12_5(char a) {
	guc ^= guc << 2;
}
void rs_10_09_13_0(int a, int *b) {
	unsigned int t = (unsigned int)gul;
	ju = t;
}
void rs_10_09_13_1(int a, int *b) {
	unsigned int u = gu + 256;
	ju = u;
}
void rs_10_09_13_2(int a, int *b) {
	a = gi;
}
void rs_10_09_13_3(int a, int *b) {
	guc++;
}
void rs_10_09_13_4(int a, int *b) {
	unsigned int t = ju;
	vu(t);
}
void rs_10_09_13_5(int a, int *b) {
	unsigned int u = ju;
	v0();
	gu = u;
}
char rs_10_09_13_6(int a, int *b) {
	unsigned int t = ju;
	v0();
	return gs.c & rc((int)t);
}
void rs_10_09_14_0(char a, int *b) {
	unsigned int t = ru(1);
	ju = t;
}
void rs_10_09_14_1(char a, int *b) {
	double u = gs.d + gd;
	v0();
	jd = u;
}
void rs_10_09_14_2(char a, int *b) {
	vp(gp + a);
}
void rs_10_09_14_3(char a, int *b) {
	unsigned int t = ju;
	double u = jd;
	v0();
	vu((gps->a[3] > 8 ? t : gps->u));
}
void rs_10_09_14_4(char a, int *b) {
	if (r2(2, gi)) gd2 = (double)gc2;
}
void rs_10_09_14_5(char a, int *b) {
	--a;
}
int * rs_10_09_14_6(char a, int *b) {
	return b;
}
void rs_10_09_15_0(int *a, int *b, long *c) {
	char *t = rp();
	jp = t;
}
void rs_10_09_15_1(int *a, int *b, long *c) {
	double u = -gda[0];
	v0();
	jd = u;
}
void rs_10_09_15_2(int *a, int *b, long *c) {
	if (gi != 0) a[6] = *a / gi;
}
void rs_10_09_15_3(int *a, int *b, long *c) {
	gul &= 0UL;
}
void rs_10_09_15_4(int *a, int *b, long *c) {
	char *t = jp;
	v0();
	vp(t);
}
void rs_10_09_15_5(int *a, int *b, long *c) {
	double u = jd;
	v0();
	vd(u);
}
unsigned long rs_10_09_15_6(int *a, int *b, long *c) {
	return 22123UL;
}
void rs_10_09_16_0(void) {
	unsigned char t = guca[2];
	juc = t;
}
void rs_10_09_16_1(void) {
	unsigned char u = 125 << 3;
	juc = u;
}
void rs_10_09_16_2(void) {
	unsigned char t = juc;
	unsigned char u = juc;
	gua[t] ^= -gua[u];
}
void rs_10_09_16_3(void) {
	if (gs.i != 0) gi2 = *gpi % gs.i;
}
void rs_10_09_16_4(void) {
	unsigned char t = juc;
	unsigned char u = juc;
	gua[u] = gps->u + ((unsigned int)gula[t]);
}
void rs_10_09_16_5(void) {
	unsigned char t = juc;
	unsigned char u = juc;
	t &= u ^ t;
}
int rs_10_09_16_6(void) {
	return r0();
}
void rs_10_09_17_0(unsigned long a, unsigned long b, int c) {
	*gp = (gs.c << (c & 7)) + (gca[3] % 7);
}
void rs_10_09_17_1(unsigned long a, unsigned long b, int c) {
	gl2 |= *gpl - 30718L;
}
int rs_10_09_17_2(unsigned long a, unsigned long b, int c) {
	return gi3;
}
void rs_10_09_18_0(void) {
	unsigned char t = 255 % 7;
	juc = t;
}
void rs_10_09_18_1(void) {
	unsigned char t = juc;
	guca[4] = t = (t + guc) - (((unsigned char)gl) * 1);
}
void rs_10_09_18_2(void) {
	unsigned char t = juc;
	gua[t] += gu;
}
char * rs_10_09_18_3(void) {
	return gs.p;
}
void rs_10_09_19_0(unsigned int a, int b) {
	vc(rc(127));
}
void rs_10_09_19_1(unsigned int a, int b) {
	if (a != 4) gua[0] = (unsigned int)gul;
}
void rs_10_09_19_2(unsigned int a, int b) {
	gla[a] = gla[1] - gla[4];
}
long rs_10_09_19_3(unsigned int a, int b) {
	return (gl = 65536L);
}
