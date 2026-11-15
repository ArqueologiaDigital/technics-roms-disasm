/* Every statement line of random5 alone in its own function (gen_rstmt.py corpus/holdout/random5 5): rs_<A>_<BB>_<CC>_<k> is line k of
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

void rs_5_00_00_0(char *a, int b) {
	if (gu2 != 0) gu = gu % gu2;
}
void rs_5_00_00_1(char *a, int b) {
	gd = (gua[b] == gu2 ? (gs.d / 100.0) : (10.0 * gd2));
}
void rs_5_00_00_2(char *a, int b) {
	guc = guca[b] = guca[5];
}
void rs_5_00_00_3(char *a, int b) {
	if (1 > gu) if (gula[b] != 0) gul = gula[1] / gula[b];
}
void rs_5_00_00_4(char *a, int b) {
	gu2 = (guca[b] ? gua[b] : gua[b]) >> 14;
}
char * rs_5_00_00_5(char *a, int b) {
	return a;
}
void rs_5_00_01_0(int *a, char b) {
	gi = 147;
}
void rs_5_00_01_1(int *a, char b) {
	guc = (unsigned char)(long)gs.i;
}
void rs_5_00_01_2(int *a, char b) {
	if ((guca[b] = guca[3]) != 255) if (gca[b] != 0) gc2 = gca[5] / gca[b];
}
void rs_5_00_01_3(int *a, char b) {
	gpi = gpi + b;
}
int rs_5_00_01_4(int *a, char b) {
	return (a[0] - gia[b]) << 8;
}
void rs_5_00_02_0(void) {
	unsigned char t = 128 - guca[2];
	juc = t;
}
void rs_5_00_02_1(void) {
	v0();
}
void rs_5_00_02_2(void) {
	gca[6] = (gp[0] <= 9 ? gca[1] : gps->c);
}
void rs_5_00_02_3(void) {
	unsigned char t = juc;
	v0();
	v1(t);
}
unsigned long rs_5_00_02_4(void) {
	return gul;
}
void rs_5_00_03_1(int a, unsigned int b, int c) {
	int i = ji;
	i = 0; while (i < a) { if (gua[i] != 0) gu = gu2 % gua[i]; if (gc != 0) gca[i] = gc / gc; i++; }
}
int rs_5_00_03_2(int a, unsigned int b, int c) {
	if (guc > 5) return gi3 & a;
}
void rs_5_00_03_3(int a, unsigned int b, int c) {
	a = gi2 = -(gpi[1] - gia[c]);
}
void rs_5_00_03_4(int a, unsigned int b, int c) {
	gpi = &gia[c];
}
void rs_5_00_03_5(int a, unsigned int b, int c) {
	guc = 255;
}
int rs_5_00_03_6(int a, unsigned int b, int c) {
	return (*gpi / 10) - (gps->l == gl);
}
void rs_5_00_04_0(unsigned char a, unsigned int b, unsigned long c) {
	char *t = gps->p;
	jp = t;
}
void rs_5_00_04_1(unsigned char a, unsigned int b, unsigned long c) {
	unsigned int u = (unsigned int)gula[2];
	ju = u;
}
void rs_5_00_04_2(unsigned char a, unsigned int b, unsigned long c) {
	while (gi-- > 0) { if (*gpi == 1) break; gpi++; }
}
void rs_5_00_04_3(unsigned char a, unsigned int b, unsigned long c) {
	guca[b] = ~guca[5];
}
void rs_5_00_04_4(unsigned char a, unsigned int b, unsigned long c) {
	unsigned int u = ju;
	gu = u;
}
void rs_5_00_04_5(unsigned char a, unsigned int b, unsigned long c) {
	char *t = jp;
	vp(t);
}
int * rs_5_00_04_6(unsigned char a, unsigned int b, unsigned long c) {
	return gpi + a;
}
void rs_5_00_05_0(void) {
	long t = (long)!128;
	jl = t;
}
void rs_5_00_05_1(void) {
	long t = jl;
	long u = rl(t);
	jl = u;
}
void rs_5_00_05_2(void) {
	long u = jl;
	v0();
	gu2 ^= gu * gs.u;
}
void rs_5_00_05_3(void) {
	long t = jl;
	v0();
	gl = t;
}
void rs_5_00_05_4(void) {
	gi3--;
}
char rs_5_00_05_5(void) {
	return (gca[0] = gps->c);
}
void rs_5_00_06_0(double a, int b) {
	if (r2(gi2, gi2)) { if (gs.c != 0) gc2 = gca[b] / gs.c; } else { if (gula[4] <= gula[b]) ++gu2; }
}
void rs_5_00_06_1(double a, int b) {
	if (gca[b] != 0) gp[3] = 'A' / gca[b];
}
void rs_5_00_06_2(double a, int b) {
	switch (b) { case 2: case 3: guc /= 16; break; case 5: case 16: vu(gps->u); break; case 20: gpi = gpi + b; break; case 100: gps->c = gc; break; default: gu2 = ru(gu2); break; }
}
void rs_5_00_06_3(double a, int b) {
	gpl[3] = 11762L & gl2;
}
void rs_5_00_06_4(double a, int b) {
	guca[3] = guc & guca[0];
}
char * rs_5_00_06_5(double a, int b) {
	return gp;
}
void rs_5_00_07_0(int *a, int *b, int c) {
	int t = *b;
	ji = t;
}
void rs_5_00_07_1(int *a, int *b, int c) {
	int t = ji;
	gi = t;
}
void rs_5_00_07_2(int *a, int *b, int c) {
	vc(-5);
}
void rs_5_00_07_3(int *a, int *b, int c) {
	gul++;
}
char rs_5_00_07_4(int *a, int *b, int c) {
	return (gc2 = -58);
}
void rs_5_00_08_0(long a) {
	if (gl2) *gp = gca[7] + (char)guc;
}
void rs_5_00_08_1(long a) {
	--gp;
}
unsigned int rs_5_00_08_2(long a) {
	return (((unsigned int)*gp) % 100) + (gua[2] << 3);
}
void rs_5_00_09_0(void) {
	gula[6] = gul / 3UL;
}
void rs_5_00_09_1(void) {
	vc(gc2);
}
char * rs_5_00_09_2(void) {
	if (r0() && gul <= 0x10000UL) return &gca[2];
}
char * rs_5_00_09_3(void) {
	return gps->p;
}
void rs_5_00_10_0(void) {
	gua[6] = (unsigned int)255;
}
void rs_5_00_10_1(void) {
	switch (gl) { case 0L: vs(gps); break; case 1L: case 2L: v0(); break; case 3L: gp[3] = -27 - gca[1]; break; case 4L: case 5L: guca[7] = 255 ^ guca[4]; break; }
}
void rs_5_00_10_2(void) {
	gul *= 10UL;
}
int rs_5_00_10_3(void) {
	return 8;
}
void rs_5_00_11_0(char a, char *b) {
	unsigned char t = (unsigned char)!(int)gl2;
	juc = t;
}
void rs_5_00_11_1(char a, char *b) {
	if (a) { gl2 = gl; }
}
void rs_5_00_11_2(char a, char *b) {
	unsigned char t = juc;
	vp(gps->p + t);
}
void rs_5_00_11_3(char a, char *b) {
	if (!gu) gpi = gpi + a;
}
int rs_5_00_11_4(char a, char *b) {
	return (gi2 * gi) << 8;
}
void rs_5_00_12_0(unsigned long a) {
	if (guca[2]) { gula[0] = gul; guc = -(guca[7] - 5); } else { gpi = rpi(gi * 9); gla[3] = ~(long)guc; gps->l = 65536L; }
}
void rs_5_00_12_1(unsigned long a) {
	guca[4] = guca[2];
}
long rs_5_00_12_2(unsigned long a) {
	return 9L;
}
void rs_5_00_13_0(void) {
	char *t = gp;
	jp = t;
}
void rs_5_00_13_1(void) {
	gl2 = (long)(char)!(int)gu2;
}
void rs_5_00_13_2(void) {
	char *t = jp;
	vp(t);
}
void rs_5_00_13_3(void) {
	gula[5] |= gula[7] >> 17;
}
unsigned int rs_5_00_13_4(void) {
	return -gu / 10;
}
void rs_5_00_14_0(void) {
	long t = 65536L;
	jl = t;
}
void rs_5_00_14_1(void) {
	gi2 -= gs.i;
}
void rs_5_00_14_2(void) {
	if (gs.u != 0) gu2 = gu / gs.u;
}
void rs_5_00_14_3(void) {
	if (gd >= gd2) { gs.d = -100.0; if (gul != 0) gula[1] = 6999UL / gul; } else { if (gs.c != 0) gs.c = gc2 % gs.c; v1(*gpi); }
}
void rs_5_00_14_4(void) {
	long t = jl;
	v0();
	--t;
}
int rs_5_00_14_5(void) {
	return *gpi;
}
void rs_5_00_15_0(char *a, long b, int *c) {
	int t = (int)guca[5] / 100;
	ji = t;
}
void rs_5_00_15_1(char *a, long b, int *c) {
	int t = ji;
	switch (gu2) { case 0: gpi = c + t; break; case 1: gul -= gula[6]; break; case 2: guca[3] = guc << (t & 7); break; case 3: gul = gula[t]; case 4: gul %= 3UL; break; default: gs.u = (gpl[3] ? 255 : gua[t]); break; }
}
void rs_5_00_15_2(char *a, long b, int *c) {
	int t = ji;
	if (gul != 0UL || gs.d != 0.25) c = rpi(gia[4] & t);
}
void rs_5_00_15_3(char *a, long b, int *c) {
	gs.d = 1.0;
}
void rs_5_00_15_4(char *a, long b, int *c) {
	int t = ji;
	v0();
	if (guca[t] <= 255) { a[0] = gc = (char)!rul(gul); vc('9'); } else { if (gula[t] != 0) gula[t] = gula[2] % gula[t]; gca[t] = (char)guc >> (t & 7); }
}
int * rs_5_00_15_5(char *a, long b, int *c) {
	return &gia[6];
}
void rs_5_00_16_1(long *a, unsigned int b) {
	int t = gi2;
	ji = t;
}
void rs_5_00_16_2(long *a, unsigned int b) {
	int i = ji;
	for (i = 0; i < 6; i++) { gul++; guc = -guca[i]; gula[i] = (unsigned long)gps->c; }
}
void rs_5_00_16_3(long *a, unsigned int b) {
	if (5L > gl2) vu(gs.u - 32767);
}
void rs_5_00_16_4(long *a, unsigned int b) {
	*gpi >>= (b & 15);
}
void rs_5_00_16_5(long *a, unsigned int b) {
	int t = ji;
	v0();
	vp(gp + t);
}
char rs_5_00_16_6(long *a, unsigned int b) {
	return (char)((gula[b] ^ 0x10000UL) < gul);
}
void rs_5_00_17_0(char a) {
	gd += -gs.d;
}
void rs_5_00_17_1(char a) {
	while (gi > 0) { gc += *gp++; gi--; }
}
void rs_5_00_17_2(char a) {
	*gpl = (gps->l * 4L) + gla[a];
}
void rs_5_00_17_3(char a) {
	if (a != 0) gca[4] = a % a;
}
int rs_5_00_17_4(char a) {
	return ((long)*gpi > gpl[1]) >> 4;
}
void rs_5_00_18_1(int *a) {
	gua[4] = ((unsigned int)gla[2]) - gs.u;
}
void rs_5_00_18_2(int *a) {
	gi3 = ((gps->a[5] - gi3) == (gi >> 15));
}
void rs_5_00_18_3(int *a) {
	gd -= -gd;
}
void rs_5_00_18_4(int *a) {
	int i = ji;
	for (i = 0; i < 10; i++) { if (gps->l != 0) gl2 = 43968L % gps->l; }
}
void rs_5_00_18_5(int *a) {
	gul--;
}
char rs_5_00_18_6(int *a) {
	return (gc2 >> 4) / 7;
}
void rs_5_00_19_0(void) {
	int *t = gpi;
	jpi = t;
}
void rs_5_00_19_1(void) {
	double u = gd2 - gda[3];
	jd = u;
}
void rs_5_00_19_2(void) {
	double u = jd;
	gd = u;
}
void rs_5_00_19_3(void) {
	int *t = jpi;
	gc2 = gp[1] = (gl2 < 1L ? (gul == 0x10000UL ? gc2 : (char)t[3]) : (gu2 & 0x80 ? 51 : *gp));
}
void rs_5_00_19_4(void) {
	if (gla[5] > 5L) vu(3 | gua[4]);
}
int rs_5_00_19_5(void) {
	return r0();
}
void rs_5_01_00_0(int a) {
	double t = gd;
	jd = t;
}
void rs_5_01_00_1(int a) {
	v1((int)guc);
}
void rs_5_01_00_2(int a) {
	gl2 ^= 8L;
}
void rs_5_01_00_3(int a) {
	double t = jd;
	v0();
	vd(t);
}
void rs_5_01_00_4(int a) {
	guca[a] = guca[4] - guca[5];
}
void rs_5_01_00_5(int a) {
	vl(gl | 0L);
}
unsigned int rs_5_01_00_6(int a) {
	return ru(gua[a]) - ((unsigned int)gps->l);
}
void rs_5_01_01_0(int *a, int b) {
	gc = rc(~b);
}
void rs_5_01_01_1(int *a, int b) {
	gs.d = 100.0 + gd2;
}
void rs_5_01_01_2(int *a, int b) {
	if (guca[2] & 4) { gp[3] -= gc | gp[2]; gl2 = rl(gl2 + gl); gi = ((int)gu / 2) - (256 & gi2); } else { gpl[0] -= gla[0]; }
}
void rs_5_01_01_3(int *a, int b) {
	gul |= gul << 26;
}
char * rs_5_01_01_4(int *a, int b) {
	return gp;
}
void rs_5_01_02_1(int a, char b) {
	double t = gda[1] - gs.d;
	jd = t;
}
void rs_5_01_02_2(int a, char b) {
	char u = rc(gi3);
	jc = u;
}
void rs_5_01_02_3(int a, char b) {
	vp(&gca[3]);
}
void rs_5_01_02_4(int a, char b) {
	double t = jd;
	v0();
	gd = t;
}
void rs_5_01_02_5(int a, char b) {
	int i = ji;
	char u = jc;
	v0();
	for (i = 0; i < 3; i++) { gp--; if (gca[i] != 0) gc2 = u / gca[i]; }
}
void rs_5_01_02_6(int a, char b) {
	char u = jc;
	v0();
	if ((long)gpi[3] > (long)gula[7]) gu = (gps->u + gu) << 1;
}
unsigned int rs_5_01_02_7(int a, char b) {
	return ~17726;
}
void rs_5_01_03_0(void) {
	int u = ji;
	unsigned int t = gps->u;
	ju = t;
}
void rs_5_01_03_1(void) {
	int u = *gpi;
	ji = u;
}
void rs_5_01_03_2(void) {
	unsigned int t = ju;
	switch (gu) { case 0: t = (unsigned int)guca[1]; break; case 1: guc = guca[5] = guca[t] - 128; break; }
}
void rs_5_01_03_3(void) {
	gi3 /= 2;
}
void rs_5_01_03_4(void) {
	int u = ji;
	gps->a[u] = 8 << 6;
}
int * rs_5_01_03_5(void) {
	unsigned int t = ju;
	return gpi + t;
}
void rs_5_01_04_0(struct st *a, int b, unsigned long c) {
	unsigned long t = (unsigned long)b;
	jul = t;
}
void rs_5_01_04_1(struct st *a, int b, unsigned long c) {
	unsigned char u = guca[b] & 253;
	juc = u;
}
void rs_5_01_04_2(struct st *a, int b, unsigned long c) {
	gpi = rpi(r2(gi, gi));
}
void rs_5_01_04_3(struct st *a, int b, unsigned long c) {
	if (gl2 < -39230L) if (gps->c != 0) gs.c = gca[4] / gps->c;
}
void rs_5_01_04_4(struct st *a, int b, unsigned long c) {
	unsigned char u = juc;
	v0();
	guc = u;
}
int rs_5_01_04_5(struct st *a, int b, unsigned long c) {
	unsigned long t = jul;
	v0();
	if (t || t) return gs.a[7];
}
void rs_5_01_04_6(struct st *a, int b, unsigned long c) {
	gl++;
}
int rs_5_01_04_7(struct st *a, int b, unsigned long c) {
	return a->i;
}
void rs_5_01_05_1(double a) {
	unsigned char t = guc;
	juc = t;
}
void rs_5_01_05_2(double a) {
	unsigned char t = juc;
	char *u = gp + t;
	jp = u;
}
void rs_5_01_05_3(double a) {
	unsigned char t = juc;
	++t;
}
void rs_5_01_05_4(double a) {
	gi = -gia[7];
}
void rs_5_01_05_5(double a) {
	char *u = jp;
	gp = u;
}
void rs_5_01_05_6(double a) {
	int i = ji;
	for (i = 10; i > 0; i--) { gc2 = (gua[i] & 1 ? (char)guc : (gc2 - 3)); }
}
char rs_5_01_05_7(double a) {
	int i = ji;
	return rc(gps->i);
}
void rs_5_01_06_0(unsigned long a, unsigned long b) {
	unsigned char t = guc;
	juc = t;
}
void rs_5_01_06_1(unsigned long a, unsigned long b) {
	int u = r2(gi2, gps->i);
	ji = u;
}
void rs_5_01_06_2(unsigned long a, unsigned long b) {
	int u = ji;
	v0();
	vp(gp + u);
}
void rs_5_01_06_3(unsigned long a, unsigned long b) {
	gc |= gps->c + gca[0];
}
void rs_5_01_06_4(unsigned long a, unsigned long b) {
	unsigned char t = juc;
	int u = ji;
	v0();
	gpl[0] = gl2 = (gl & 4 && t & 0x8 ? (*gp ? (long)gs.u : 9L) : (0L / 16L));
}
void rs_5_01_06_5(unsigned long a, unsigned long b) {
	unsigned char t = juc;
	v0();
	t = (t | 128) + (guca[4] << 3);
}
int rs_5_01_06_6(unsigned long a, unsigned long b) {
	int u = ji;
	v0();
	return (-gs.u > 1);
}
void rs_5_01_07_0(int *a, long b) {
	int *t = gpi;
	jpi = t;
}
void rs_5_01_07_1(int *a, long b) {
	int *t = jpi;
	gpi = t;
}
void rs_5_01_07_2(int *a, long b) {
	gul = -(gul << 30);
}
void rs_5_01_07_3(int *a, long b) {
	++gul;
}
void rs_5_01_07_4(int *a, long b) {
	if (0x10000UL == gula[7] && gs.c) gc2 = gca[1];
}
void rs_5_01_07_5(int *a, long b) {
	if (gul != 0) gul = gula[7] % gul;
}
int rs_5_01_07_6(int *a, long b) {
	return (gul > 0x10000UL);
}
void rs_5_01_08_0(char a, long b, int c) {
	gua[4] = gps->u ^ -gu2;
}
void rs_5_01_08_1(char a, long b, int c) {
	gi3 = 255;
}
void rs_5_01_08_2(char a, long b, int c) {
	gi3 = r0();
}
unsigned long rs_5_01_08_3(char a, long b, int c) {
	return (gula[c] + gul) * 9UL;
}
void rs_5_01_09_0(int a, unsigned char b) {
	switch (gl2) { case 0L: gla[4] = 3L & gl; break; case 1L: vl(gl2); break; case 2L: gp = &gca[1]; break; case 3L: gs.c >>= 2; break; case 4L: gi2 &= gs.a[0]; break; }
}
void rs_5_01_09_1(int a, unsigned char b) {
	vs(gps);
}
void rs_5_01_09_2(int a, unsigned char b) {
	gl = (*gpl >= 65536L ? -81535L : 65536L) + (gl2 ^ 9L);
}
void rs_5_01_09_3(int a, unsigned char b) {
	gu2 = ((unsigned int)*gp) - ((unsigned int)(gl2 >= gs.l));
}
void rs_5_01_09_4(int a, unsigned char b) {
	if (b >= guca[b]) { b++; }
}
char rs_5_01_09_5(int a, unsigned char b) {
	return gc * ((char)(gula[6] >= gula[b]));
}
void rs_5_01_10_0(unsigned long a) {
	unsigned char t = guca[6];
	juc = t;
}
void rs_5_01_10_1(unsigned long a) {
	int *u = gpi;
	jpi = u;
}
void rs_5_01_10_2(unsigned long a) {
	unsigned char t = juc;
	switch (gi3) { case 8: v2(gi2, gi); break; case 10: vp(gs.p + t); break; case 16: gl *= 6L; case 100: gu = gu % 2; break; case 1000: gula[3] *= 11UL; break; }
}
void rs_5_01_10_3(unsigned long a) {
	int *u = jpi;
	v0();
	v1(*u);
}
void rs_5_01_10_4(unsigned long a) {
	gd = (gs.d * gda[3]) * (gda[1] / 0.5);
}
void rs_5_01_10_5(unsigned long a) {
	vp(gp);
}
void rs_5_01_10_6(unsigned long a) {
	if (*gpl != 0) gl = 7L % *gpl;
}
void rs_5_01_10_7(unsigned long a) {
	unsigned char t = juc;
	v0();
	guc = (guc - guca[t]) - t;
}
int * rs_5_01_10_8(unsigned long a) {
	int *u = jpi;
	v0();
	return u;
}
void rs_5_01_11_0(unsigned int a) {
	char t = (char)(1 != gu2);
	jc = t;
}
void rs_5_01_11_1(unsigned int a) {
	char t = jc;
	vc(t);
}
void rs_5_01_11_2(unsigned int a) {
	gi <<= (a & 15);
}
void rs_5_01_11_3(unsigned int a) {
	guc = guca[7] = (unsigned char)!(-a);
}
unsigned int rs_5_01_11_4(unsigned int a) {
	return -ru(255);
}
void rs_5_01_12_0(void) {
	unsigned int t = 255 / 2;
	ju = t;
}
void rs_5_01_12_1(void) {
	if (!guca[0]) if (gpl[2] != 0) gl2 = *gpl / gpl[2];
}
void rs_5_01_12_2(void) {
	unsigned int t = ju;
	gu2 = t;
}
void rs_5_01_12_3(void) {
	while (gi-- > 0) *gp++ = '0';
}
void rs_5_01_12_4(void) {
	gp = rp();
}
void rs_5_01_12_5(void) {
	unsigned int t = ju;
	v0();
	gl2 = (t != 255 ? gps->l : (long)gu) - (gps->l / 2L);
}
long rs_5_01_12_6(void) {
	return 3L;
}
void rs_5_01_13_0(void) {
	int t = gpi[3] >> 8;
	ji = t;
}
void rs_5_01_13_1(void) {
	int t = ji;
	char *u = gs.p + t;
	jp = u;
}
void rs_5_01_13_2(void) {
	int t = ji;
	gi = t;
}
void rs_5_01_13_3(void) {
	if (8 > guca[3]) { gpi = &gia[5]; }
}
void rs_5_01_13_4(void) {
	gda[3] *= gs.d;
}
void rs_5_01_13_5(void) {
	char *u = jp;
	vp(u);
}
void rs_5_01_13_6(void) {
	vc(gs.c >> 3);
}
int rs_5_01_13_7(void) {
	return gi2;
}
void rs_5_01_14_0(int a, int b, unsigned int c) {
	if (gula[c] < 8UL) { if (gpl[0] != 0) gl = gl / gpl[0]; gl = gpl[2]; }
}
void rs_5_01_14_1(int a, int b, unsigned int c) {
	gda[2] += 10.0;
}
void rs_5_01_14_2(int a, int b, unsigned int c) {
	switch (gps->i) { case 0: gla[4] += gl2; break; case 1: c = (guca[4] > guc ? gua[b] : gua[c]); break; case 2: gs.c = gca[2] + gca[c]; case 3: vp(gp); break; case 4: gda[2] += (double)*gp; break; default: vd(100.0); break; }
}
void rs_5_01_15_0(long a, long b, char c) {
	guca[c] = guc = ~guc;
}
void rs_5_01_15_1(long a, long b, char c) {
	++guc;
}
int rs_5_01_15_2(long a, long b, char c) {
	return *gpi;
}
void rs_5_01_16_0(double a, char b, long c) {
	long t = rl(c);
	jl = t;
}
void rs_5_01_16_1(double a, char b, long c) {
	unsigned int u = gua[7] % 3;
	v0();
	ju = u;
}
void rs_5_01_16_2(double a, char b, long c) {
	unsigned int u = ju;
	v0();
	guc = guca[u] | (((unsigned char)c) >> 4);
}
void rs_5_01_16_3(double a, char b, long c) {
	long t = jl;
	v0();
	vl(t);
}
void rs_5_01_16_4(double a, char b, long c) {
	unsigned int u = ju;
	v0();
	gu = (gs.u << (b & 15)) >> 14;
}
char * rs_5_01_16_5(double a, char b, long c) {
	return gp + b;
}
void rs_5_01_17_0(struct st *a) {
	int t = gia[5];
	ji = t;
}
void rs_5_01_17_1(struct st *a) {
	gi2 = gpi[3] = 127;
}
void rs_5_01_17_2(struct st *a) {
	int t = ji;
	*gp = gc = (gula[4] != 49961UL || gua[t] & 0x7 ? rc(t) : gps->c);
}
unsigned long rs_5_01_17_3(struct st *a) {
	int t = ji;
	v0();
	if (gs.l & 0x7 && gi) return gula[t] + gul;
}
unsigned long rs_5_01_17_4(struct st *a) {
	return (unsigned long)gu;
}
void rs_5_01_18_0(unsigned char a, long *b, unsigned int c) {
	char t = *gp;
	jc = t;
}
void rs_5_01_18_1(unsigned char a, long *b, unsigned int c) {
	unsigned long u = (unsigned long)!256;
	jul = u;
}
void rs_5_01_18_2(unsigned char a, long *b, unsigned int c) {
	gp = rp();
}
void rs_5_01_18_3(unsigned char a, long *b, unsigned int c) {
	char t = jc;
	v0();
	gc = t;
}
void rs_5_01_18_4(unsigned char a, long *b, unsigned int c) {
	gi %= 3;
}
void rs_5_01_18_5(unsigned char a, long *b, unsigned int c) {
	*gpl -= 71235L % 2L;
}
void rs_5_01_18_6(unsigned char a, long *b, unsigned int c) {
	gda[3] -= gd2;
}
void rs_5_01_18_7(unsigned char a, long *b, unsigned int c) {
	unsigned long u = jul;
	v0();
	gul = u;
}
unsigned long rs_5_01_18_8(unsigned char a, long *b, unsigned int c) {
	unsigned long u = jul;
	v0();
	return u;
}
void rs_5_01_19_0(void) {
	gca[7] <<= 3;
}
void rs_5_01_19_1(void) {
	gps->a[2] -= 16;
}
void rs_5_01_19_2(void) {
	gl2 = (long)!gua[7];
}
void rs_5_01_19_3(void) {
	if (gua[5] > 5) gd2 = gd;
}
void rs_5_01_19_4(void) {
	vu(gu);
}
void rs_5_02_00_1(int *a, char b) {
	int i = ji;
	gc2 = rc(gps->i);
}
void rs_5_02_00_2(int *a, char b) {
	int i = ji;
	v0();
	i = 10; do { gu2 = (gs.u - gps->u) << 10; gs.d += gd2; guca[7] = guca[i] | 118; } while (--i > 0);
}
void rs_5_02_00_3(int *a, char b) {
	a[1] = r0();
}
void rs_5_02_00_4(int *a, char b) {
	gca[2] %= 16;
}
int rs_5_02_00_5(int *a, char b) {
	return (int)gla[b];
}
void rs_5_02_01_1(double a, struct st *b) {
	int i = ji;
	switch (b->i) { case 1: gda[3] -= gs.d; break; case 5: gd2 = gs.d * gda[2]; break; case 10: gi = 1 / 4; break; case 20: gi = gi3 = b->a[7] & 127; break; case 100: v2(gi2, 16); break; default: vp(gs.p); break; }
}
int * rs_5_02_01_2(double a, struct st *b) {
	if (r2(gi2, 127) && gp[0] != 'z') return gpi;
}
void rs_5_02_01_3(double a, struct st *b) {
	if (gula[4] != ((unsigned long)gps->u)) gu2 = b->u;
}
void rs_5_02_01_4(double a, struct st *b) {
	int i = ji;
	v0();
	for (i = 14; i > 0; i--) { gula[i] = ((char)gs.i == '9' ? gul : 0x10000UL); *gpl = gl2 - 9L; if (gu != 0) b->u = ((unsigned int)gla[i]) / gu; }
}
void rs_5_02_01_5(double a, struct st *b) {
	int i = ji;
	v0();
	for (i = 14; i > 0; i--) { if (gs.u != 0) gu2 = gps->u / gs.u; if (gp[0] != 0) gp[3] = *gp / gp[0]; gc2 |= (char)gula[5]; }
}
int * rs_5_02_01_6(double a, struct st *b) {
	return gpi;
}
void rs_5_02_02_1(void) {
	unsigned long t = 7UL | gul;
	jul = t;
}
void rs_5_02_02_2(void) {
	int i = ji;
	unsigned long t = jul;
	i = 0; while (i < 9) { v2(1, gi); v1((t != 2UL)); i++; }
}
void rs_5_02_02_3(void) {
	if (gs.l != 0) gl2 = gpl[3] % gs.l;
}
long rs_5_02_02_4(void) {
	return gps->l * 7L;
}
void rs_5_02_03_0(void) {
	char *t = &gca[3];
	jp = t;
}
void rs_5_02_03_1(void) {
	char *t = jp;
	t[3] = gca[0] = gca[1] & rc(gpi[0]);
}
void rs_5_02_03_2(void) {
	gda[0] = (gs.u > gua[3] ? (gs.d - gda[2]) : (gs.d / 2.5));
}
void rs_5_02_03_3(void) {
	vc(gca[3] << 7);
}
void rs_5_02_03_4(void) {
	if (guca[3] & 0x8) if (gia[7] != 0) gi3 = gia[0] / gia[7];
}
long rs_5_02_03_5(void) {
	return rl(*gpl & gps->l);
}
void rs_5_02_04_0(int a) {
	gu2++;
}
void rs_5_02_04_1(int a) {
	guc = guca[6] = (gca[3] ? (7 << 1) : -guca[0]);
}
void rs_5_02_04_2(int a) {
	guca[a] = guc;
}
int rs_5_02_04_3(int a) {
	return gi2;
}
void rs_5_02_05_0(struct st *a) {
	double t = gd2 + gda[3];
	jd = t;
}
void rs_5_02_05_1(struct st *a) {
	if (*gpi != 0) gi3 = gi3 / *gpi;
}
void rs_5_02_05_2(struct st *a) {
	double t = jd;
	vd(t);
}
void rs_5_02_05_3(struct st *a) {
	guc = -guca[0] % 3;
}
void rs_5_02_05_4(struct st *a) {
	gs.p = rp();
}
void rs_5_02_05_5(struct st *a) {
	gl2 += gl ^ (long)gul;
}
int rs_5_02_05_6(struct st *a) {
	return gia[0];
}
void rs_5_02_06_1(int *a) {
	guca[7] = guca[4];
}
void rs_5_02_06_2(int *a) {
	gs.c = *gp;
}
void rs_5_02_06_3(int *a) {
	if (gula[4] & 4) { gp[3] |= (char)gula[4]; vl((long)*gp - gla[1]); gp = gp + 1; } else { vu(gu - 32767); --gp; a++; }
}
void rs_5_02_06_4(int *a) {
	int i = ji;
	v0();
	i = 5; do { if (gul != 0) gula[i] = gula[i] / gul; vs(gps); } while (--i > 0);
}
void rs_5_02_06_5(int *a) {
	gul = gula[1] = gula[2];
}
char rs_5_02_06_6(int *a) {
	return gs.c;
}
void rs_5_02_07_1(char a) {
	unsigned long t = 4806UL / 16UL;
	jul = t;
}
void rs_5_02_07_2(char a) {
	int i = ji;
	i = 0; while (i < 13) { gd = (gd / 3.0) * (gd / 1.0); guc = guca[i]; i++; }
}
void rs_5_02_07_3(char a) {
	unsigned long t = jul;
	gul = t;
}
void rs_5_02_07_4(char a) {
	gd -= gd2 / 2.5;
}
void rs_5_02_07_5(char a) {
	gpi = rpi(gpi[1]);
}
int rs_5_02_07_6(char a) {
	return gi;
}
void rs_5_02_08_1(void) {
	++gu2;
}
void rs_5_02_08_2(void) {
	gi3++;
}
void rs_5_02_08_3(void) {
	int i = ji;
	i = 6; do { guca[1] += guca[i] & guc; } while (--i > 0);
}
void rs_5_02_08_4(void) {
	gi = (gia[6] << 9) % 10;
}
char * rs_5_02_08_5(void) {
	return gs.p;
}
void rs_5_02_09_1(double a, struct st *b) {
	vu(gua[0]);
}
void rs_5_02_09_2(double a, struct st *b) {
	gula[2] = gula[5] + gula[7];
}
void rs_5_02_09_3(double a, struct st *b) {
	gula[4] *= 12UL;
}
void rs_5_02_09_4(double a, struct st *b) {
	int i = ji;
	v0();
	for (i = 16; i > 0; i--) { vs(b); gula[i] = gula[i] | 0x10000UL; if (gu2 != 0) gps->u = 1 / gu2; }
}
int * rs_5_02_09_5(double a, struct st *b) {
	return &gia[4];
}
void rs_5_02_10_0(void) {
	unsigned int t = (unsigned int)gps->i;
	ju = t;
}
void rs_5_02_10_1(void) {
	unsigned int t = ju;
	char *u = gp + t;
	jp = u;
}
void rs_5_02_10_2(void) {
	v0();
}
void rs_5_02_10_3(void) {
	char *u = jp;
	v0();
	guc = (unsigned char)(u[1] >> 2);
}
void rs_5_02_10_4(void) {
	unsigned int t = ju;
	v0();
	gu = t;
}
int rs_5_02_10_5(void) {
	return gps->i;
}
void rs_5_02_11_0(char a, struct st *b) {
	int *t = rpi(gpi[1]);
	jpi = t;
}
void rs_5_02_11_1(char a, struct st *b) {
	gl2 = 65536L;
}
void rs_5_02_11_2(char a, struct st *b) {
	int *t = jpi;
	v0();
	if (t[a] == gi3) gpi = t + a;
}
void rs_5_02_11_3(char a, struct st *b) {
	gd2 -= gd2 / 1.0;
}
unsigned long rs_5_02_11_4(char a, struct st *b) {
	return (gula[a] = gul);
}
void rs_5_02_12_0(void) {
	unsigned char t = guc;
	juc = t;
}
void rs_5_02_12_1(void) {
	unsigned long u = (unsigned long)gl;
	jul = u;
}
void rs_5_02_12_2(void) {
	unsigned char t = juc;
	gpi[2] = gs.a[t];
}
void rs_5_02_12_3(void) {
	gi2 -= *gpi;
}
void rs_5_02_12_4(void) {
	unsigned char t = juc;
	gs.p = gp + t;
}
void rs_5_02_12_5(void) {
	unsigned long u = jul;
	gul = u;
}
void rs_5_02_12_6(void) {
	gs.p = gps->p;
}
void rs_5_02_12_7(void) {
	unsigned char t = juc;
	gpi = &gia[t];
}
unsigned long rs_5_02_12_8(void) {
	unsigned long u = jul;
	return -(u | gul);
}
void rs_5_02_13_0(long a) {
	int *t = gpi;
	jpi = t;
}
void rs_5_02_13_1(long a) {
	int *u = gpi;
	jpi = u;
}
void rs_5_02_13_2(long a) {
	int *t = jpi;
	int *u = jpi;
	if (gc2 || gla[5]) { t = u + 1; gp[2] = (char)a & 'z'; }
}
void rs_5_02_13_3(long a) {
	int *t = jpi;
	int *u = jpi;
	u[3] = *t;
}
void rs_5_02_13_4(long a) {
	gul = gul % 4UL;
}
char * rs_5_02_13_5(long a) {
	return gp;
}
void rs_5_02_14_0(long *a, long b) {
	unsigned int t = gua[7] ^ gu2;
	ju = t;
}
void rs_5_02_14_1(long *a, long b) {
	unsigned long u = gula[1] >> 20;
	jul = u;
}
void rs_5_02_14_2(long *a, long b) {
	guc += guca[5];
}
void rs_5_02_14_3(long *a, long b) {
	unsigned long u = jul;
	vl((long)u);
}
void rs_5_02_14_4(long *a, long b) {
	guc %= 7;
}
void rs_5_02_14_5(long *a, long b) {
	unsigned int t = ju;
	v0();
	vu(t);
}
long rs_5_02_14_6(long *a, long b) {
	unsigned int t = ju;
	v0();
	return ~6L | (a[t] + 65536L);
}
void rs_5_02_15_0(void) {
	unsigned int t = 1 + ((unsigned int)guca[7]);
	ju = t;
}
void rs_5_02_15_1(void) {
	gps->a[1] %= 3;
}
void rs_5_02_15_2(void) {
	gd2 -= gda[0];
}
void rs_5_02_15_3(void) {
	gl2 = (long)gua[6] & (long)guc;
}
void rs_5_02_15_4(void) {
	gul = gula[6] = ~rul(gul);
}
void rs_5_02_15_5(void) {
	unsigned int t = ju;
	v0();
	if (gi != 0) gia[t] = -976 % gi;
}
unsigned int rs_5_02_15_6(void) {
	unsigned int t = ju;
	v0();
	return t;
}
void rs_5_02_16_0(unsigned long a, int b) {
	unsigned long t = -gula[0];
	jul = t;
}
void rs_5_02_16_1(unsigned long a, int b) {
	gp--;
}
void rs_5_02_16_2(unsigned long a, int b) {
	gp[0] = gca[b] & gps->c;
}
void rs_5_02_16_3(unsigned long a, int b) {
	vl(gl >> 4);
}
void rs_5_02_16_4(unsigned long a, int b) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
int rs_5_02_16_5(unsigned long a, int b) {
	return (gi3 = gps->a[b]);
}
void rs_5_02_17_0(int a) {
	char t = -gc;
	jc = t;
}
void rs_5_02_17_1(int a) {
	int u = gi3 >> 11;
	ji = u;
}
void rs_5_02_17_2(int a) {
	char t = jc;
	if (gla[t] < gl2) if (gi2 != 0) *gpi = gia[t] % gi2;
}
void rs_5_02_17_3(int a) {
	gd2 = -gd2 * (0.25 > 1.0 ? gda[1] : gs.d);
}
void rs_5_02_17_4(int a) {
	gpi = &gia[0];
}
void rs_5_02_17_5(int a) {
	int u = ji;
	u = (u * gs.a[5]) - (a - u);
}
void rs_5_02_17_6(int a) {
	if (r2(gpi[0], gi)) { vc(gca[a] | gc2); gpi = &gia[7]; gpl[1] = gpl[0]; }
}
int * rs_5_02_17_7(int a) {
	return gpi;
}
void rs_5_02_18_0(void) {
	double t = gda[0];
	jd = t;
}
void rs_5_02_18_1(void) {
	unsigned long u = gul / 2UL;
	jul = u;
}
void rs_5_02_18_2(void) {
	v1(gia[2] << 3);
}
void rs_5_02_18_3(void) {
	if (gla[3] != 0) gla[4] = *gpl % gla[3];
}
void rs_5_02_18_4(void) {
	unsigned long u = jul;
	v0();
	gul = u;
}
void rs_5_02_18_5(void) {
	double t = jd;
	v0();
	switch (gi2) { case 0: gs.p = gps->p; break; case 1: gda[2] *= t; break; default: gp = gs.p + 1; break; }
}
unsigned long rs_5_02_18_6(void) {
	return ((unsigned long)gs.l) - (0x10000UL & 80467UL);
}
void rs_5_02_19_0(unsigned char a) {
	gd2 = (gul ? gd2 : (double)gps->a[a]) / 2.5;
}
void rs_5_02_19_1(unsigned char a) {
	if (gi != 0) gi3 = 127 % gi;
}
void rs_5_02_19_2(unsigned char a) {
	a++;
}
void rs_5_02_19_3(unsigned char a) {
	if (gps->i <= gs.i && gl != 4L) gu = (unsigned int)(gpi[0] >= (255 % 2));
}
int rs_5_02_19_4(unsigned char a) {
	return (*gpi = gi2);
}
void rs_5_03_00_1(unsigned long a, int b) {
	unsigned int t = ~gu;
	ju = t;
}
void rs_5_03_00_2(unsigned long a, int b) {
	unsigned int t = ju;
	char *u = &gca[t];
	jp = u;
}
void rs_5_03_00_3(unsigned long a, int b) {
	guc = guc & 128;
}
void rs_5_03_00_4(unsigned long a, int b) {
	guc %= 10;
}
void rs_5_03_00_5(unsigned long a, int b) {
	int i = ji;
	unsigned int t = ju;
	char *u = jp;
	i = 16; do { if (t != 0) gps->u = ((unsigned int)gula[i]) / t; } while (--i > 0);
}
void rs_5_03_00_6(unsigned long a, int b) {
	int i = ji;
	for (i = 0; i < 8; i++) { gps->i <<= 4; }
}
void rs_5_03_00_7(unsigned long a, int b) {
	unsigned int t = ju;
	guca[t] = ((unsigned char)t) ^ guca[6];
}
void rs_5_03_01_1(void) {
	char *t = gp;
	jp = t;
}
void rs_5_03_01_2(void) {
	unsigned long u = (unsigned long)gc;
	jul = u;
}
int * rs_5_03_01_3(void) {
	if (gu != 32767) return gpi;
}
void rs_5_03_01_4(void) {
	int i = ji;
	unsigned long u = jul;
	for (i = 0; i < 16; i++) { guc += (unsigned char)(255 >= guc); gd += (u == 0x10000UL ? gda[2] : gd2); }
}
void rs_5_03_01_5(void) {
	char *t = jp;
	gp = t;
}
int * rs_5_03_01_6(void) {
	return gpi + 1;
}
void rs_5_03_02_0(unsigned int a, int b) {
	long t = -77500L;
	jl = t;
}
void rs_5_03_02_1(unsigned int a, int b) {
	unsigned long u = gul >> (b & 15);
	jul = u;
}
void rs_5_03_02_2(unsigned int a, int b) {
	guc--;
}
void rs_5_03_02_3(unsigned int a, int b) {
	guca[b] += guca[4] >> 3;
}
void rs_5_03_02_4(unsigned int a, int b) {
	gc2--;
}
void rs_5_03_02_5(unsigned int a, int b) {
	long t = jl;
	unsigned long u = jul;
	if (gs.u & 1) { if (gl != 0) t = -10598L / gl; gl2 = t; v2(gi2, *gpi + 63); }
}
void rs_5_03_02_6(unsigned int a, int b) {
	gl ^= gla[b] * 8L;
}
unsigned long rs_5_03_02_7(unsigned int a, int b) {
	unsigned long u = jul;
	v0();
	return (u >> 30) % 4UL;
}
void rs_5_03_03_1(unsigned long a) {
	char t = gca[5] * gc2;
	jc = t;
}
void rs_5_03_03_2(unsigned long a) {
	a++;
}
void rs_5_03_03_3(unsigned long a) {
	char t = jc;
	gc = t;
}
void rs_5_03_03_4(unsigned long a) {
	while (gi-- > 0) *gpi++ = 16;
}
void rs_5_03_03_5(unsigned long a) {
	int i = ji;
	i = 0; while (i < 4) { if (gc != 0) gca[i] = gps->c / gc; i++; }
}
unsigned long rs_5_03_03_6(unsigned long a) {
	return (r1(gia[3]) ? (a + gul) : a);
}
void rs_5_03_04_1(int a) {
	unsigned long t = gul;
	jul = t;
}
void rs_5_03_04_2(int a) {
	if (r2(gi2, gi)) { gs.c = gca[0] = gps->c; } else { if (gua[5] != 0) gua[a] = gu2 % gua[5]; }
}
void rs_5_03_04_3(int a) {
	unsigned long t = jul;
	v0();
	gul = t;
}
void rs_5_03_04_4(int a) {
	gpi = &gia[7];
}
void rs_5_03_04_5(int a) {
	int i = ji;
	v0();
	for (i = a; i > 0; i--) { gu = gu2; --gu; }
}
void rs_5_03_04_6(int a) {
	gu2--;
}
void rs_5_03_04_7(int a) {
	gu2++;
}
int rs_5_03_04_8(int a) {
	return (gi3 = 2);
}
void rs_5_03_05_1(unsigned long a) {
	long t = gps->l * 2L;
	jl = t;
}
void rs_5_03_05_2(unsigned long a) {
	char u = gc2 & *gp;
	jc = u;
}
void rs_5_03_05_3(unsigned long a) {
	int i = ji;
	long t = jl;
	char u = jc;
	i = 0; while (i < 14) { if (t != 0) gl = t / t; u <<= (i & 7); if (gul != 0) a = ((unsigned long)gca[i]) % gul; i++; }
}
void rs_5_03_05_4(unsigned long a) {
	vc(rc(*gpi));
}
void rs_5_03_05_5(unsigned long a) {
	*gpi *= 6;
}
void rs_5_03_05_6(unsigned long a) {
	char u = jc;
	v0();
	guca[2] = (guc ^ 0) + (guc >> (u & 7));
}
void rs_5_03_05_7(unsigned long a) {
	vs(gps);
}
unsigned int rs_5_03_05_8(unsigned long a) {
	return ~gu2 - (gu2 - gua[0]);
}
void rs_5_03_06_0(long a, long *b) {
	gps->a[2] = -gia[4];
}
void rs_5_03_06_1(long a, long *b) {
	vs(gps);
}
void rs_5_03_06_2(long a, long *b) {
	if ((gu = ((unsigned int)gula[1])) != 256) { if (gla[0] != 0) gla[7] = b[0] % gla[0]; --gi; if (gps->c != 0) gca[0] = gps->c / gps->c; } else { vp(gp); }
}
void rs_5_03_06_3(long a, long *b) {
	gda[3] += gda[2];
}
int rs_5_03_06_4(long a, long *b) {
	return (gs.a[2] <= 100 || 6 > 'A' ? (gi2 | gia[6]) : ~gpi[0]);
}
void rs_5_03_07_0(unsigned long a, unsigned char b) {
	gp = rp();
}
void rs_5_03_07_1(unsigned long a, unsigned char b) {
	gul = -a + gul;
}
char * rs_5_03_07_2(unsigned long a, unsigned char b) {
	return rp();
}
void rs_5_03_08_1(int a, long *b) {
	int t = gi2 ^ gi3;
	ji = t;
}
void rs_5_03_08_2(int a, long *b) {
	int t = ji;
	if (gl) { if (*gp != 0) gca[6] = gc / *gp; } else { gu = gs.u = (((unsigned int)t) & gua[a]) << (t & 15); }
}
void rs_5_03_08_3(int a, long *b) {
	int i = ji;
	for (i = 0; i < a; i++) { guc -= (unsigned char)(gu > 256); if (gula[i] != 0) gula[i] = gul / gula[i]; }
}
void rs_5_03_08_4(int a, long *b) {
	guca[5] = guc = (guca[a] >> 6) - guc;
}
void rs_5_03_08_5(int a, long *b) {
	int t = ji;
	gula[a] = gul - gula[t];
}
unsigned int rs_5_03_08_6(int a, long *b) {
	return -gua[3];
}
void rs_5_03_09_0(unsigned int a, int b, double c) {
	vp(rp());
}
void rs_5_03_09_1(unsigned int a, int b, double c) {
	if (guc < guca[a]) { gula[1] = gula[7] >> 4; } else { vl(-(long)gs.u); }
}
int rs_5_03_09_2(unsigned int a, int b, double c) {
	return (gia[a] = gps->a[7]);
}
void rs_5_03_10_1(unsigned char a, long b, long c) {
	char t = gps->c;
	jc = t;
}
void rs_5_03_10_2(unsigned char a, long b, long c) {
	int u = gi;
	ji = u;
}
void rs_5_03_10_3(unsigned char a, long b, long c) {
	int i = ji;
	char t = jc;
	if ((gul = gula[3]) <= 0x10000UL) { gi2 *= 6; gpi--; ++gp; } else { if (gps->a[3] != 0) gia[6] = gia[3] % gps->a[3]; if (gi3 != 0) gps->i = 256 / gi3; if (gca[t] != 0) t = -80 / gca[t]; }
}
void rs_5_03_10_4(unsigned char a, long b, long c) {
	char t = jc;
	gula[5] = gula[t];
}
void rs_5_03_10_5(unsigned char a, long b, long c) {
	int i = ji;
	int u = ji;
	for (i = 9; i > 0; i--) { gula[i] >>= 18; gpi[0] = gia[u] = (2 % 10) & (gi2 + 266); gul |= gul + 2UL; }
}
long rs_5_03_10_6(unsigned char a, long b, long c) {
	return ~gl2 - (gl << 21);
}
void rs_5_03_11_1(unsigned long a, long b, unsigned long c) {
	int t = gi;
	ji = t;
}
void rs_5_03_11_2(unsigned long a, long b, unsigned long c) {
	guc--;
}
void rs_5_03_11_3(unsigned long a, long b, unsigned long c) {
	int i = ji;
	i = 16; do { if (gps->c != 0) gc2 = gc2 % gps->c; } while (--i > 0);
}
void rs_5_03_11_4(unsigned long a, long b, unsigned long c) {
	int t = ji;
	gi = t;
}
void rs_5_03_11_5(unsigned long a, long b, unsigned long c) {
	int i = ji;
	for (i = 11; i > 0; i--) { a = rul((unsigned long)(9 > guc)); }
}
char rs_5_03_11_6(unsigned long a, long b, unsigned long c) {
	return rc(gia[0]);
}
void rs_5_03_12_0(long *a, char *b) {
	gs.c *= 9;
}
void rs_5_03_12_1(long *a, char *b) {
	if (gula[0] != 0) gula[4] = gul / gula[0];
}
void rs_5_03_12_2(long *a, char *b) {
	vu(ru(gua[4]));
}
void rs_5_03_12_3(long *a, char *b) {
	if (gs.l) guca[5] = guca[2];
}
void rs_5_03_12_4(long *a, char *b) {
	*gpl = gl;
}
char * rs_5_03_12_5(long *a, char *b) {
	return gps->p + 1;
}
void rs_5_03_13_0(unsigned char a, struct st *b, int c) {
	unsigned int t = ru(1);
	ju = t;
}
void rs_5_03_13_1(unsigned char a, struct st *b, int c) {
	unsigned int t = ju;
	v0();
	if (t) vu(t);
}
void rs_5_03_13_2(unsigned char a, struct st *b, int c) {
	vc(*gp);
}
void rs_5_03_13_3(unsigned char a, struct st *b, int c) {
	unsigned int t = ju;
	v0();
	vc(rc((int)t));
}
void rs_5_03_13_4(unsigned char a, struct st *b, int c) {
	unsigned int t = ju;
	v0();
	t--;
}
void rs_5_03_13_5(unsigned char a, struct st *b, int c) {
	vl(gl);
}
char * rs_5_03_13_6(unsigned char a, struct st *b, int c) {
	return &gca[0];
}
void rs_5_03_14_0(unsigned long a, int b, unsigned char c) {
	unsigned int t = gua[2] % 3;
	ju = t;
}
void rs_5_03_14_1(unsigned long a, int b, unsigned char c) {
	unsigned int t = ju;
	long u = (t ? gla[b] : 65536L);
	jl = u;
}
void rs_5_03_14_2(unsigned long a, int b, unsigned char c) {
	unsigned int t = ju;
	if (gua[c] != 0) t = t % gua[c];
}
void rs_5_03_14_3(unsigned long a, int b, unsigned char c) {
	long u = jl;
	gla[c] = u * 5L;
}
char rs_5_03_14_4(unsigned long a, int b, unsigned char c) {
	return gp[1];
}
void rs_5_03_15_0(char a) {
	long t = 3L;
	jl = t;
}
void rs_5_03_15_1(char a) {
	unsigned char u = guc ^ 1;
	juc = u;
}
void rs_5_03_15_2(char a) {
	long t = jl;
	vl(t);
}
void rs_5_03_15_3(char a) {
	unsigned char u = juc;
	v0();
	if (gul >= 9UL) { if (gps->u != 0) gu2 = gu % gps->u; --gl2; }
}
void rs_5_03_15_4(char a) {
	unsigned char u = juc;
	v0();
	gla[u] = gla[6];
}
void rs_5_03_15_5(char a) {
	gula[a] = gul | 2UL;
}
char rs_5_03_15_6(char a) {
	return a;
}
void rs_5_03_16_0(int *a) {
	long t = gla[3] - gl;
	jl = t;
}
void rs_5_03_16_1(int *a) {
	vp(gs.p);
}
void rs_5_03_16_2(int *a) {
	long t = jl;
	v0();
	vl(t);
}
void rs_5_03_16_3(int *a) {
	if (gi3) if (gul != 0) gul = gul % gul;
}
void rs_5_03_17_1(long *a, int b) {
	int *t = gpi;
	jpi = t;
}
int rs_5_03_17_2(long *a, int b) {
	if (r0()) return gi;
}
void rs_5_03_17_3(long *a, int b) {
	int i = ji;
	v0();
	i = 0; while (i < 16) { vd(gda[0] / 3.0); gul = rul(gula[i]); gp = gps->p; i++; }
}
void rs_5_03_17_4(long *a, int b) {
	int i = ji;
	v0();
	i = 0; while (i < 5) { --gp; if (gu2 != 0) gu = 256 % gu2; i++; }
}
void rs_5_03_17_5(long *a, int b) {
	vs(gps);
}
void rs_5_03_17_6(long *a, int b) {
	int *t = jpi;
	v0();
	v1(*t);
}
int rs_5_03_17_7(long *a, int b) {
	return (~gs.l <= (long)gia[b]);
}
void rs_5_03_18_1(unsigned long a, int b, double c) {
	int t = (int)128;
	ji = t;
}
void rs_5_03_18_2(unsigned long a, int b, double c) {
	int i = ji;
	for (i = 0; i < 2; i++) { if (*gp != 0) gps->c = 4 % *gp; gp++; if (a != 0) a = a % a; }
}
void rs_5_03_18_3(unsigned long a, int b, double c) {
	int t = ji;
	v1(t);
}
void rs_5_03_18_4(unsigned long a, int b, double c) {
	guc <<= 3;
}
int rs_5_03_18_5(unsigned long a, int b, double c) {
	return (gi + gia[6]) * (int)guca[b];
}
void rs_5_03_19_0(int a, char b, struct st *c) {
	double t = (double)c->l - gs.d;
	jd = t;
}
void rs_5_03_19_1(int a, char b, struct st *c) {
	unsigned char u = -guc;
	juc = u;
}
void rs_5_03_19_2(int a, char b, struct st *c) {
	c->p = rp();
}
void rs_5_03_19_3(int a, char b, struct st *c) {
	double t = jd;
	v0();
	gd = t;
}
void rs_5_03_19_4(int a, char b, struct st *c) {
	vl(rl(gla[2]));
}
void rs_5_03_19_5(int a, char b, struct st *c) {
	unsigned char u = juc;
	v0();
	u = (guc + u) / 3;
}
long rs_5_03_19_6(int a, char b, struct st *c) {
	return (gs.l = *gpl);
}
void rs_5_04_00_0(void) {
	int t = gi;
	ji = t;
}
void rs_5_04_00_1(void) {
	gc2 &= gs.c & gc;
}
void rs_5_04_00_2(void) {
	int t = ji;
	if (100 > t && gp[1] < 6) guca[t] = (unsigned char)(gpi[0] != gi2);
}
void rs_5_04_00_3(void) {
	while (gi-- > 0) { if (*gp == -55) break; gp++; }
}
char * rs_5_04_00_4(void) {
	return gp;
}
void rs_5_04_01_0(char *a, unsigned long b) {
	unsigned char t = guc ^ guca[5];
	juc = t;
}
void rs_5_04_01_1(char *a, unsigned long b) {
	unsigned char t = juc;
	if (r2(gi2, gps->a[t])) v1(gs.i / 4);
}
void rs_5_04_01_2(char *a, unsigned long b) {
	gs.d += 100.0;
}
void rs_5_04_01_3(char *a, unsigned long b) {
	gpi--;
}
int rs_5_04_01_4(char *a, unsigned long b) {
	return (65536L != rl(-62103L));
}
void rs_5_04_02_0(void) {
	gula[7] -= (unsigned long)gl2;
}
void rs_5_04_02_1(void) {
	guca[7] = 128 * (guc >> 7);
}
void rs_5_04_02_2(void) {
	gi2 ^= gi & gps->i;
}
int rs_5_04_02_3(void) {
	return ~gi + (gul ? gps->i : *gpi);
}
void rs_5_04_03_0(char a, char b) {
	int *t = &gia[7];
	jpi = t;
}
void rs_5_04_03_1(char a, char b) {
	double u = gs.d;
	jd = u;
}
void rs_5_04_03_2(char a, char b) {
	if (gca[a] != 0) gc2 = '0' / gca[a];
}
void rs_5_04_03_3(char a, char b) {
	if ((a = *gp)) { vs(gps); if (*gp != 0) gca[0] = (char)gul / *gp; } else { gs.l %= 16L; guc = guca[6]; }
}
void rs_5_04_03_4(char a, char b) {
	gi = -gs.i - (gi2 ^ gi);
}
void rs_5_04_03_5(char a, char b) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_5_04_03_6(char a, char b) {
	double u = jd;
	v0();
	gd = u;
}
int * rs_5_04_03_7(char a, char b) {
	return rpi(!gs.i);
}
void rs_5_04_04_0(unsigned char a) {
	unsigned char t = 255 % 16;
	juc = t;
}
void rs_5_04_04_1(unsigned char a) {
	unsigned int u = gu | gps->u;
	ju = u;
}
void rs_5_04_04_2(unsigned char a) {
	unsigned int u = ju;
	u %= 16;
}
void rs_5_04_04_3(unsigned char a) {
	vd(gd + 0.25);
}
void rs_5_04_04_4(unsigned char a) {
	unsigned char t = juc;
	v0();
	v1(t);
}
void rs_5_04_04_5(unsigned char a) {
	gd2 = -(gd + gd);
}
void rs_5_04_04_6(unsigned char a) {
	--gul;
}
void rs_5_04_04_7(unsigned char a) {
	gc2--;
}
int rs_5_04_04_8(unsigned char a) {
	return 16 * 9;
}
void rs_5_04_05_0(void) {
	unsigned int t = gua[2] * 2;
	ju = t;
}
void rs_5_04_05_1(void) {
	gul = gula[7] = ((unsigned long)((unsigned char)gpl[0])) / 100UL;
}
void rs_5_04_05_2(void) {
	unsigned int t = ju;
	t = 32767;
}
void rs_5_04_05_3(void) {
	gl2 = gl - gla[4];
}
void rs_5_04_05_4(void) {
	unsigned int t = ju;
	gul -= gula[t] >> 21;
}
void rs_5_04_05_5(void) {
	gpi++;
}
char rs_5_04_05_6(void) {
	return -(61 - (char)gul);
}
void rs_5_04_06_0(long *a, char *b) {
	int t = -423;
	ji = t;
}
void rs_5_04_06_1(long *a, char *b) {
	int t = ji;
	gi = *gpi = t;
}
void rs_5_04_06_2(long *a, char *b) {
	while (gi-- > 0) *a++ = 65536L;
}
void rs_5_04_07_0(void) {
	unsigned char t = guc;
	juc = t;
}
void rs_5_04_07_1(void) {
	unsigned char t = juc;
	if (gl2 <= gl) { if (gs.a[t] != 0) gs.i = (int)gc / gs.a[t]; gs.u = 1; }
}
void rs_5_04_07_2(void) {
	--gl;
}
void rs_5_04_07_3(void) {
	vl(gl2);
}
void rs_5_04_07_4(void) {
	gca[0] = gc2;
}
int * rs_5_04_07_5(void) {
	return gpi;
}
void rs_5_04_08_0(int a, unsigned int b, unsigned int c) {
	char t = rc(gs.a[c]);
	jc = t;
}
void rs_5_04_08_1(int a, unsigned int b, unsigned int c) {
	char t = jc;
	v0();
	vc(t);
}
void rs_5_04_08_2(int a, unsigned int b, unsigned int c) {
	if ((gs.c = gc) < 19) { guca[a] = (gps->l < gs.l ? -guca[5] : (guca[7] ^ guc)); }
}
void rs_5_04_08_3(int a, unsigned int b, unsigned int c) {
	guc <<= 5;
}
void rs_5_04_08_4(int a, unsigned int b, unsigned int c) {
	gua[2] = c = 32767 >> (b & 15);
}
void rs_5_04_08_5(int a, unsigned int b, unsigned int c) {
	if (!gl) gul++;
}
int rs_5_04_08_6(int a, unsigned int b, unsigned int c) {
	return r1(gi2) / 10;
}
void rs_5_04_09_1(void) {
	long t = gs.l << 28;
	jl = t;
}
void rs_5_04_09_2(void) {
	gul = ((unsigned long)(gd2 > 0.25)) + rul((unsigned long)gpl[2]);
}
void rs_5_04_09_3(void) {
	int i = ji;
	v0();
	i = 3; do { vl((long)gc2); if (gul != 0) gul = gul / gul; } while (--i > 0);
}
void rs_5_04_09_4(void) {
	long t = jl;
	v0();
	gl = t;
}
void rs_5_04_09_5(void) {
	if (gps->u != 0) gs.u = gua[3] % gps->u;
}
unsigned long rs_5_04_09_6(void) {
	return (unsigned long)!16;
}
void rs_5_04_10_0(unsigned char a) {
	char t = gca[1];
	jc = t;
}
void rs_5_04_10_1(unsigned char a) {
	v0();
}
void rs_5_04_10_2(unsigned char a) {
	char t = jc;
	v0();
	if (gul & 0x10) t -= 7 % 7;
}
void rs_5_04_10_3(unsigned char a) {
	if (r2(gi2, (int)gula[0])) { if (gpi[1] != 0) gps->i = 2 / gpi[1]; }
}
void rs_5_04_10_4(unsigned char a) {
	if (gul != 0) gula[7] = 8503UL / gul;
}
void rs_5_04_10_5(unsigned char a) {
	gp[3] *= 2;
}
void rs_5_04_11_0(char a, long *b) {
	if (gc2 != 0) gs.c = (char)gi2 / gc2;
}
void rs_5_04_11_1(char a, long *b) {
	gu2 >>= 3;
}
void rs_5_04_11_2(char a, long *b) {
	gps->c = rc(gi3);
}
long rs_5_04_11_3(char a, long *b) {
	return -62584L;
}
void rs_5_04_12_0(void) {
	char *t = gp;
	jp = t;
}
void rs_5_04_12_1(void) {
	gl2++;
}
void rs_5_04_12_2(void) {
	char *t = jp;
	gp = t;
}
void rs_5_04_12_3(void) {
	gla[7] = (gpl[2] <= (long)gs.u ? (gl2 ^ gs.l) : rl(gpl[0]));
}
int * rs_5_04_12_4(void) {
	return gpi + 1;
}
void rs_5_04_13_0(long *a) {
	long t = (long)(((unsigned long)gpl[3]) < gula[5]);
	jl = t;
}
void rs_5_04_13_1(long *a) {
	++gp;
}
void rs_5_04_13_2(long *a) {
	long t = jl;
	vl(t);
}
void rs_5_04_13_3(long *a) {
	switch (gu2) { case 0: gu = gps->u = gu & gua[1]; case 1: guca[3] += guca[4]; break; case 2: gc += 4; break; case 3: guca[1] = guca[2] ^ 128; }
}
void rs_5_04_13_4(long *a) {
	switch (gi2) { case 0: gla[7] = gla[4] & gl2; break; case 1: v1(127); case 2: gca[2] /= 3; break; case 3: guc = (unsigned char)gps->i; break; case 4: *gpi = gs.a[4] + gs.a[2]; break; }
}
int * rs_5_04_13_5(long *a) {
	return gpi + 1;
}
void rs_5_04_14_0(unsigned char a, unsigned long b, long c) {
	gi2 *= 7;
}
void rs_5_04_14_1(unsigned char a, unsigned long b, long c) {
	v2(gi << 5, gi);
}
char * rs_5_04_14_2(unsigned char a, unsigned long b, long c) {
	return gs.p;
}
void rs_5_04_15_1(int a, char b, long c) {
	int *t = gpi;
	jpi = t;
}
void rs_5_04_15_2(int a, char b, long c) {
	int i = ji;
	i = 13; do { ++gu; } while (--i > 0);
}
void rs_5_04_15_3(int a, char b, long c) {
	vl((gpi[3] > 127 ? gpl[2] : gs.l));
}
void rs_5_04_15_4(int a, char b, long c) {
	if (4UL < 65981UL) *gpi = (r0() ? gi3 : *gpi);
}
void rs_5_04_15_5(int a, char b, long c) {
	*gp *= 12;
}
void rs_5_04_15_6(int a, char b, long c) {
	int *t = jpi;
	v0();
	gpi = t;
}
unsigned int rs_5_04_15_7(int a, char b, long c) {
	return (gu2 | gu) - gu2;
}
void rs_5_04_16_0(unsigned char a, unsigned long b) {
	unsigned int t = gua[5] + gu;
	ju = t;
}
void rs_5_04_16_1(unsigned char a, unsigned long b) {
	unsigned int t = ju;
	unsigned int u = gu + t;
	ju = u;
}
void rs_5_04_16_2(unsigned char a, unsigned long b) {
	unsigned int t = ju;
	unsigned int u = ju;
	switch (gs.i) { case 0: a <<= (t & 7); break; case 1: vd(gd); break; case 2: v0(); break; case 3: u >>= 13; break; }
}
void rs_5_04_16_3(unsigned char a, unsigned long b) {
	unsigned int t = ju;
	v0();
	vu(ru(t));
}
void rs_5_04_16_4(unsigned char a, unsigned long b) {
	v2(gi3, gi);
}
void rs_5_04_16_5(unsigned char a, unsigned long b) {
	gi3 = gps->i = (*gpi ^ 100) / 3;
}
char rs_5_04_16_6(unsigned char a, unsigned long b) {
	return gc;
}
void rs_5_04_17_0(int a) {
	double t = gd / 2.5;
	jd = t;
}
void rs_5_04_17_1(int a) {
	gula[a] = (0x10000UL - ((unsigned long)*gpl)) - (gul >> 8);
}
void rs_5_04_17_2(int a) {
	switch (gc2) { case 0: guca[a] ^= 128; break; case 1: vc('z'); break; case 2: a += gi; break; case 3: gps->u |= gs.u; break; case 4: vc(gc2); break; }
}
void rs_5_04_17_3(int a) {
	double t = jd;
	v0();
	gd2 = -((guca[a] = 2) < 2 ? t : gd);
}
void rs_5_04_17_4(int a) {
	gi3 += a;
}
void rs_5_04_17_5(int a) {
	++gul;
}
char rs_5_04_17_6(int a) {
	return 9;
}
void rs_5_04_18_0(unsigned int a, int b) {
	gs.i += (*gpi > gia[b] ? gi3 : gs.a[b]);
}
void rs_5_04_18_1(unsigned int a, int b) {
	vp(gp);
}
void rs_5_04_18_2(unsigned int a, int b) {
	gla[a] = *gpl;
}
void rs_5_04_18_3(unsigned int a, int b) {
	vd(gda[0] / 100.0);
}
void rs_5_04_18_4(unsigned int a, int b) {
	gul &= gula[7];
}
char * rs_5_04_18_5(unsigned int a, int b) {
	return &gca[0];
}
void rs_5_04_19_0(unsigned long a, long b, int *c) {
	guca[0] = (gu < gu2 ? (9 + guca[2]) : (guc | 128));
}
void rs_5_04_19_1(unsigned long a, long b, int *c) {
	while (gi-- > 0) { if (*c == 8) break; c++; }
}
void rs_5_04_19_2(unsigned long a, long b, int *c) {
	vu(gs.u << 3);
}
void rs_5_04_19_3(unsigned long a, long b, int *c) {
	gps->p = &gca[5];
}
void rs_5_04_19_4(unsigned long a, long b, int *c) {
	guca[6] = guc = guc << 3;
}
int rs_5_04_19_5(unsigned long a, long b, int *c) {
	return (int)8;
}
void rs_5_05_00_0(struct st *a, long b) {
	int t = *gpi;
	ji = t;
}
void rs_5_05_00_1(struct st *a, long b) {
	int t = ji;
	char u = gc2 - (char)t;
	jc = u;
}
void rs_5_05_00_2(struct st *a, long b) {
	int t = ji;
	if (r0()) gu2 = (unsigned int)((255 / 100) >= (guca[t] & guca[3]));
}
void rs_5_05_00_3(struct st *a, long b) {
	guc--;
}
void rs_5_05_00_4(struct st *a, long b) {
	char u = jc;
	v0();
	vc(u);
}
int rs_5_05_00_5(struct st *a, long b) {
	int t = ji;
	v0();
	return t;
}
void rs_5_05_01_1(unsigned int a, unsigned int b) {
	unsigned long t = gul << (a & 15);
	jul = t;
}
void rs_5_05_01_2(unsigned int a, unsigned int b) {
	int i = ji;
	for (i = 10; i > 0; i--) { guca[4] = guc = 20; gs.l = gpl[2] * 11L; guca[i] /= 16; }
}
void rs_5_05_01_3(unsigned int a, unsigned int b) {
	gi2 = (gi2 + gia[a]) % 3;
}
void rs_5_05_01_4(unsigned int a, unsigned int b) {
	unsigned long t = jul;
	gul = t;
}
void rs_5_05_01_5(unsigned int a, unsigned int b) {
	vp(gs.p + a);
}
int rs_5_05_01_6(unsigned int a, unsigned int b) {
	return gi % 100;
}
void rs_5_05_02_0(unsigned int a, unsigned char b) {
	unsigned long t = gul;
	jul = t;
}
void rs_5_05_02_1(unsigned int a, unsigned char b) {
	vp(gs.p + b);
}
void rs_5_05_02_2(unsigned int a, unsigned char b) {
	unsigned long t = jul;
	v0();
	gul = t;
}
void rs_5_05_02_3(unsigned int a, unsigned char b) {
	vu(10090 % 7);
}
void rs_5_05_02_4(unsigned int a, unsigned char b) {
	gu2 >>= 6;
}
void rs_5_05_02_5(unsigned int a, unsigned char b) {
	gi2--;
}
char * rs_5_05_02_6(unsigned int a, unsigned char b) {
	return gp;
}
void rs_5_05_03_0(double a, unsigned long b) {
	gpi--;
}
void rs_5_05_03_1(double a, unsigned long b) {
	gu2 %= 2;
}
void rs_5_05_03_2(double a, unsigned long b) {
	gca[4] = (char)!gul;
}
void rs_5_05_03_3(double a, unsigned long b) {
	gl2 *= 11L;
}
void rs_5_05_03_4(double a, unsigned long b) {
	v0();
}
unsigned int rs_5_05_03_5(double a, unsigned long b) {
	return (unsigned int)!(gua[5] | 15076);
}
void rs_5_05_04_0(unsigned int a, struct st *b, int c) {
	int *t = gpi;
	jpi = t;
}
void rs_5_05_04_1(unsigned int a, struct st *b, int c) {
	gia[a] %= 7;
}
void rs_5_05_04_2(unsigned int a, struct st *b, int c) {
	v0();
}
void rs_5_05_04_3(unsigned int a, struct st *b, int c) {
	gl2 = gs.l;
}
void rs_5_05_04_4(unsigned int a, struct st *b, int c) {
	gp = &gca[1];
}
void rs_5_05_04_5(unsigned int a, struct st *b, int c) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_5_05_04_6(unsigned int a, struct st *b, int c) {
	if (!gc) { gs.d = 0.5; gc = 78; gua[a] ^= (unsigned int)!gla[1]; }
}
char * rs_5_05_04_7(unsigned int a, struct st *b, int c) {
	return &gca[a];
}
void rs_5_05_05_0(void) {
	char t = gps->c - (char)guca[4];
	jc = t;
}
void rs_5_05_05_1(void) {
	if (r2(*gpi, gi)) gpi = &gia[1];
}
void rs_5_05_05_2(void) {
	char t = jc;
	v0();
	if (!gca[t] && gula[t] == 7503UL) guc = (unsigned char)!(gl2 - *gpl);
}
void rs_5_05_05_3(void) {
	gula[4] %= 3UL;
}
char rs_5_05_05_4(void) {
	return gc;
}
void rs_5_05_06_0(void) {
	long t = *gpl;
	jl = t;
}
void rs_5_05_06_1(void) {
	char *u = rp();
	jp = u;
}
void rs_5_05_06_2(void) {
	gul = (gula[4] + gul) & (gul & 0x10000UL);
}
void rs_5_05_06_3(void) {
	char *u = jp;
	v0();
	gp = u;
}
void rs_5_05_06_4(void) {
	long t = jl;
	v0();
	vl(t);
}
void rs_5_05_06_5(void) {
	vc((gula[1] > gul ? gs.c : '9'));
}
void rs_5_05_07_0(int a) {
	double t = gs.d;
	jd = t;
}
void rs_5_05_07_1(int a) {
	gs.c = gp[1] / 100;
}
void rs_5_05_07_2(int a) {
	double t = jd;
	gd = t;
}
void rs_5_05_07_3(int a) {
	gpi = gpi + a;
}
void rs_5_05_07_4(int a) {
	if ((long)gula[a] < 9L) { if (gc2 != 0) gc2 = gp[2] % gc2; } else { gula[6] = gul << 11; if (gu2 != 0) gs.u = 7 / gu2; }
}
void rs_5_05_08_1(unsigned long a) {
	int i = ji;
	for (i = 0; i < 13; i++) { gps->c = *gp + gc2; gu2--; }
}
void rs_5_05_08_2(unsigned long a) {
	int i = ji;
	if (gi2 == gps->a[7]) { gps->a[6] ^= (gl != gps->l ? gs.i : 100); }
}
void rs_5_05_08_3(unsigned long a) {
	gps->c += ~gca[5];
}
long rs_5_05_08_4(unsigned long a) {
	return (long)(gca[0] + gs.c);
}
void rs_5_05_09_0(void) {
	unsigned long t = gul + 11043UL;
	jul = t;
}
void rs_5_05_09_1(void) {
	char *u = gp + 1;
	jp = u;
}
void rs_5_05_09_2(void) {
	gc = (gc + -43) >> 6;
}
void rs_5_05_09_3(void) {
	unsigned long t = jul;
	char *u = jp;
	if (gs.a[3] & 0x8) { t = gul = t << 26; gi2 += gi - gia[5]; *gpi += gps->i; } else { gl2 = (gs.c <= u[2] ? gl : (gl - -82807L)); }
}
void rs_5_05_09_4(void) {
	vu(~((unsigned int)gi2));
}
void rs_5_05_09_5(void) {
	char *u = jp;
	v0();
	u[3] = -*u;
}
void rs_5_05_09_6(void) {
	char *u = jp;
	v0();
	u = u + 1;
}
unsigned long rs_5_05_09_7(void) {
	unsigned long t = jul;
	v0();
	return (t / 10UL) - (t / 4UL);
}
void rs_5_05_10_0(void) {
	double t = gd2;
	jd = t;
}
void rs_5_05_10_1(void) {
	double t = jd;
	vd(t);
}
void rs_5_05_10_2(void) {
	if (guca[6] > guc && gps->l) if (gula[0] != 0) gula[3] = gul / gula[0];
}
char rs_5_05_10_3(void) {
	if (gu2 != 255) return gc % 7;
}
char rs_5_05_10_4(void) {
	return (gs.c % 2) & gca[5];
}
void rs_5_05_11_0(unsigned long a, unsigned int b) {
	char t = (char)a | gca[b];
	jc = t;
}
void rs_5_05_11_1(unsigned long a, unsigned int b) {
	char *u = gps->p;
	jp = u;
}
void rs_5_05_11_2(unsigned long a, unsigned int b) {
	char *u = jp;
	vp(u);
}
void rs_5_05_11_3(unsigned long a, unsigned int b) {
	vc(rc(gi2));
}
void rs_5_05_11_4(unsigned long a, unsigned int b) {
	char t = jc;
	v0();
	if (r2(gps->a[t], gi)) { guca[7] = guc + 255; }
}
unsigned int rs_5_05_11_5(unsigned long a, unsigned int b) {
	return (unsigned int)(int)a;
}
void rs_5_05_12_1(long *a, unsigned int b, int c) {
	gc2 = -gc2 + (char)gps->l;
}
void rs_5_05_12_2(long *a, unsigned int b, int c) {
	int i = ji;
	for (i = 8; i > 0; i--) { if (gpi[1] != 0) gps->a[i] = 255 / gpi[1]; b = (unsigned int)!b; guca[i] = guc = 128; }
}
void rs_5_05_12_3(long *a, unsigned int b, int c) {
	gca[b] = gp[1] = rc(gps->a[4]) / 2;
}
void rs_5_05_12_4(long *a, unsigned int b, int c) {
	vp(gs.p);
}
char * rs_5_05_12_5(long *a, unsigned int b, int c) {
	return gs.p;
}
void rs_5_05_13_0(unsigned int a, char b, unsigned char c) {
	char t = gca[4] ^ gc;
	jc = t;
}
void rs_5_05_13_1(unsigned int a, char b, unsigned char c) {
	int u = !gi;
	ji = u;
}
void rs_5_05_13_2(unsigned int a, char b, unsigned char c) {
	gl %= 10L;
}
void rs_5_05_13_3(unsigned int a, char b, unsigned char c) {
	char t = jc;
	int u = ji;
	t = (b + gp[1]) & ('z' | gca[u]);
}
void rs_5_05_13_4(unsigned int a, char b, unsigned char c) {
	gul++;
}
void rs_5_05_13_5(unsigned int a, char b, unsigned char c) {
	vp(&gca[6]);
}
int * rs_5_05_13_6(unsigned int a, char b, unsigned char c) {
	return gpi;
}
void rs_5_05_14_0(int *a, char b) {
	unsigned long t = gula[b] - gul;
	jul = t;
}
void rs_5_05_14_1(int *a, char b) {
	gla[b] = gla[5];
}
void rs_5_05_14_2(int *a, char b) {
	unsigned long t = jul;
	vl((long)t);
}
void rs_5_05_14_3(int *a, char b) {
	while (gi-- > 0) { if (*a == 100) break; a++; }
}
int * rs_5_05_14_4(int *a, char b) {
	return rpi((gs.d != gda[2]));
}
void rs_5_05_15_0(void) {
	int t = gi2;
	ji = t;
}
void rs_5_05_15_1(void) {
	gl = *gpl;
}
void rs_5_05_15_2(void) {
	gl -= gl + gs.l;
}
void rs_5_05_15_3(void) {
	int t = ji;
	if (gul < 63296UL) { t = !gps->i & gps->i; vp(gp); --gl2; } else { if (gs.l != 0) gpl[1] = 6L / gs.l; gp[1] *= 2; }
}
void rs_5_05_15_4(void) {
	gi2 <<= 1;
}
void rs_5_05_15_5(void) {
	gl2 = 2L;
}
int * rs_5_05_15_6(void) {
	return &gia[6];
}
void rs_5_05_16_0(unsigned long a, int b, unsigned char c) {
	gs.i = 255 - gs.a[0];
}
void rs_5_05_16_1(unsigned long a, int b, unsigned char c) {
	gs.d = gd;
}
int rs_5_05_16_2(unsigned long a, int b, unsigned char c) {
	return gs.a[0];
}
void rs_5_05_17_1(void) {
	int t = gia[7];
	ji = t;
}
void rs_5_05_17_2(void) {
	int t = ji;
	int u = gia[t];
	ji = u;
}
void rs_5_05_17_3(void) {
	int u = ji;
	v1(u);
}
void rs_5_05_17_4(void) {
	int i = ji;
	v0();
	i = 11; do { gpi = &gia[i]; } while (--i > 0);
}
void rs_5_05_17_5(void) {
	int t = ji;
	v0();
	guca[t] = (unsigned char)(gi > (int)gu2);
}
int rs_5_05_17_6(void) {
	int t = ji;
	v0();
	return (255 ^ t) + ~gpi[1];
}
void rs_5_05_18_0(char a) {
	long t = gpl[0] & gs.l;
	jl = t;
}
void rs_5_05_18_1(char a) {
	unsigned char u = 213 | 255;
	juc = u;
}
void rs_5_05_18_2(char a) {
	unsigned char u = juc;
	u = (guc ^ guca[1]) % 100;
}
void rs_5_05_18_3(char a) {
	long t = jl;
	gl = t;
}
void rs_5_05_18_4(char a) {
	gps->p = gs.p;
}
char * rs_5_05_18_5(char a) {
	return gps->p;
}
void rs_5_05_19_0(int a) {
	double t = 2.5 * (double)gla[1];
	jd = t;
}
void rs_5_05_19_1(int a) {
	unsigned char u = guca[a] / 100;
	juc = u;
}
void rs_5_05_19_2(int a) {
	gc2 = gp[2] = rc((int)gs.c + gi);
}
void rs_5_05_19_3(int a) {
	double t = jd;
	v0();
	vd(t);
}
void rs_5_05_19_4(int a) {
	unsigned char u = juc;
	v0();
	u += (gs.c & 2 ? u : u);
}
void rs_5_05_19_5(int a) {
	gul = gula[3] = (gula[5] - gul) - ((unsigned long)!gul);
}
void rs_5_05_19_6(int a) {
	if (gpi[0] != 0) gi3 = *gpi % gpi[0];
}
int rs_5_05_19_7(int a) {
	return gi3;
}
void rs_5_06_00_0(void) {
	int t = gi3;
	ji = t;
}
void rs_5_06_00_1(void) {
	unsigned int u = (gs.u <= 256 ? gu2 : gs.u);
	ju = u;
}
void rs_5_06_00_2(void) {
	gs.d -= -gda[2];
}
void rs_5_06_00_3(void) {
	int t = ji;
	unsigned int u = ju;
	if (gua[t] >= gu) { if (gula[3] != 0) gula[2] = gul / gula[3]; gs.l = (65536L & *gpl) >> 19; gs.u >>= (t & 15); } else { if (gpl[0] != gl2) gu2 = ((unsigned int)!8) + (gps->u | u); }
}
void rs_5_06_00_4(void) {
	gps->i = *gpi;
}
void rs_5_06_00_5(void) {
	int t = ji;
	unsigned int u = ju;
	v2(gps->a[t] << (u & 15), gi);
}
int rs_5_06_00_6(void) {
	int t = ji;
	v0();
	return (gps->a[t] = gi);
}
void rs_5_06_01_1(char a) {
	unsigned char t = guc;
	juc = t;
}
void rs_5_06_01_2(char a) {
	int i = ji;
	char u = (char)gps->i * gp[3];
	jc = u;
}
void rs_5_06_01_3(char a) {
	gps->l = gl;
}
void rs_5_06_01_4(char a) {
	v1(gia[3] - gpi[3]);
}
void rs_5_06_01_5(char a) {
	v0();
}
void rs_5_06_01_6(char a) {
	int i = ji;
	unsigned char t = juc;
	v0();
	for (i = 0; i < 6; i++) { t = (gl > gps->l ? ((unsigned char)a) : (255 << (a & 7))); }
}
void rs_5_06_01_7(char a) {
	unsigned char t = juc;
	v0();
	t = 0 % 4;
}
void rs_5_06_01_8(char a) {
	char u = jc;
	v0();
	vc(u);
}
void rs_5_06_02_0(void) {
	unsigned int t = gu ^ gu2;
	ju = t;
}
void rs_5_06_02_1(void) {
	unsigned int t = ju;
	gps->l = 5L >> (t & 15);
}
void rs_5_06_02_2(void) {
	gl2 -= gl >> 7;
}
void rs_5_06_02_3(void) {
	gl = rl(gps->l);
}
int rs_5_06_02_4(void) {
	return 255;
}
void rs_5_06_03_0(int a) {
	int t = gs.i >> (a & 15);
	ji = t;
}
void rs_5_06_03_1(int a) {
	if (1 == gu || r2(100, gi)) { guca[a] = 252 >> 5; vs(gps); gca[a] = gs.c; } else { a = (8 << 1) - -gi; }
}
void rs_5_06_03_2(int a) {
	if (guca[2] & 0x10) if (gla[7] != 0) gpl[0] = gla[6] / gla[7];
}
void rs_5_06_03_3(int a) {
	int t = ji;
	v0();
	switch (gl2) { case 0L: vl(gs.l); break; case 1L: v2(gi2, gi); break; case 2L: gula[t] <<= (a & 15); break; case 3L: gs.c = gc = gps->c % 16; break; }
}
int rs_5_06_03_4(int a) {
	return (gia[a] >> 14) * 8;
}
void rs_5_06_04_1(char a) {
	char t = gc;
	jc = t;
}
void rs_5_06_04_2(char a) {
	int *u = gpi;
	jpi = u;
}
void rs_5_06_04_3(char a) {
	int i = ji;
	for (i = 6; i > 0; i--) { gul -= gul - gula[i]; guc--; }
}
void rs_5_06_04_4(char a) {
	int i = ji;
	char t = jc;
	if ((gu2 = ((unsigned int)t)) >= 10431) gps->i = (gpi[1] ? gi : gi);
}
void rs_5_06_04_5(char a) {
	if (gul != 0) gula[a] = gula[a] / gul;
}
void rs_5_06_04_6(char a) {
	v0();
}
void rs_5_06_04_7(char a) {
	v1(!7UL);
}
void rs_5_06_04_8(char a) {
	int *u = jpi;
	v0();
	gpi = u;
}
char rs_5_06_04_9(char a) {
	return 8;
}
void rs_5_06_05_0(char *a, int b, int *c) {
	char u = jc;
	unsigned int t = gs.u * 2;
	ju = t;
}
void rs_5_06_05_1(char *a, int b, int *c) {
	char u = gp[2] >> 4;
	jc = u;
}
void rs_5_06_05_2(char *a, int b, int *c) {
	gul = rul(gula[4]);
}
void rs_5_06_05_3(char *a, int b, int *c) {
	char u = jc;
	v0();
	if ((gul = 0x10000UL)) { gps->l = gs.l; guc -= ((unsigned char)gia[7]) & 128; } else { gs.u = (gu ^ 32767) & ~gu; }
}
void rs_5_06_05_4(char *a, int b, int *c) {
	unsigned int t = ju;
	v0();
	gu = t;
}
void rs_5_06_05_5(char *a, int b, int *c) {
	++gp;
}
char rs_5_06_05_6(char *a, int b, int *c) {
	return (char)(guca[b] / 2);
}
void rs_5_06_06_0(double a, unsigned int b, unsigned int c) {
	gs.c = gca[c] = (gc >> 2) % 100;
}
void rs_5_06_06_1(double a, unsigned int b, unsigned int c) {
	gp[1] = gca[c] = ~gp[0] - gca[c];
}
long rs_5_06_06_2(double a, unsigned int b, unsigned int c) {
	return ~(-65536L);
}
void rs_5_06_07_1(int a, int *b) {
	int t = (gua[7] & 2 ? b[a] : *b);
	ji = t;
}
void rs_5_06_07_2(int a, int *b) {
	int i = ji;
	for (i = 0; i < 2; i++) { --gi; }
}
void rs_5_06_07_3(int a, int *b) {
	--gl2;
}
void rs_5_06_07_4(int a, int *b) {
	gul += 96876UL;
}
void rs_5_06_07_5(int a, int *b) {
	guca[a] /= 16;
}
void rs_5_06_07_6(int a, int *b) {
	int t = ji;
	gi = t;
}
void rs_5_06_07_7(int a, int *b) {
	while (a-- > 0) *b++ = 16;
}
unsigned int rs_5_06_07_8(int a, int *b) {
	return (unsigned int)((unsigned long)(gul >= 1UL));
}
void rs_5_06_08_0(char *a, int b) {
	char *t = gps->p;
	jp = t;
}
void rs_5_06_08_1(char *a, int b) {
	int *u = gpi;
	jpi = u;
}
void rs_5_06_08_2(char *a, int b) {
	char *t = jp;
	gp = t;
}
void rs_5_06_08_3(char *a, int b) {
	vl((long)!guca[2]);
}
void rs_5_06_08_4(char *a, int b) {
	int *u = jpi;
	v0();
	u++;
}
char * rs_5_06_08_5(char *a, int b) {
	return a + b;
}
void rs_5_06_09_0(int a, int b) {
	unsigned int t = gs.u - gu2;
	ju = t;
}
void rs_5_06_09_1(int a, int b) {
	unsigned int t = ju;
	gu = t;
}
void rs_5_06_09_2(int a, int b) {
	if (*gpl) vd(1.0 * gs.d);
}
void rs_5_06_09_3(int a, int b) {
	gl2 = (gl2 * 3L) + gpl[2];
}
void rs_5_06_09_4(int a, int b) {
	gca[3] = 44 + gc2;
}
void rs_5_06_09_5(int a, int b) {
	gps->p = gp;
}
void rs_5_06_09_6(int a, int b) {
	if (gul > 25741UL || (gp[2] = gc) < 4) v2((guca[3] != guca[5]), gi);
}
long rs_5_06_09_7(int a, int b) {
	return gpl[0];
}
void rs_5_06_10_0(void) {
	gi += 8 - gi3;
}
void rs_5_06_10_1(void) {
	gpi = rpi(gia[0] - 127);
}
void rs_5_06_10_2(void) {
	vp(gp + 1);
}
void rs_5_06_10_3(void) {
	switch (gps->i) { case 16: vd(gd); break; case 100: gula[1] = -gula[6]; break; }
}
void rs_5_06_10_4(void) {
	gca[2] |= gc2 + *gp;
}
long rs_5_06_10_5(void) {
	return gl2;
}
void rs_5_06_11_1(void) {
	unsigned char t = guca[0] | guc;
	juc = t;
}
void rs_5_06_11_2(void) {
	unsigned char t = juc;
	guca[t] = (!gs.l ? guca[0] : ((unsigned char)gu)) >> 6;
}
void rs_5_06_11_3(void) {
	unsigned char t = juc;
	gu = gua[t];
}
void rs_5_06_11_4(void) {
	gul = -gul / 16UL;
}
void rs_5_06_11_5(void) {
	int i = ji;
	i = 0; while (i < 7) { gc ^= rc(256); gu2 = (256 >> (i & 15)) - -gu; ++gi; i++; }
}
int rs_5_06_11_6(void) {
	unsigned char t = juc;
	v0();
	return ((5 != t ? *gp : gps->c) < rc(127));
}
void rs_5_06_12_1(int *a, int b) {
	int t = !gul;
	ji = t;
}
void rs_5_06_12_2(int *a, int b) {
	gs.l += (long)(guca[b] < 128);
}
void rs_5_06_12_3(int *a, int b) {
	gp--;
}
void rs_5_06_12_4(int *a, int b) {
	int i = ji;
	i = 8; do { if (gpl[2] != 0) gl2 = gs.l / gpl[2]; } while (--i > 0);
}
void rs_5_06_12_5(int *a, int b) {
	gul--;
}
void rs_5_06_12_6(int *a, int b) {
	int t = ji;
	v1(t);
}
int rs_5_06_12_7(int *a, int b) {
	return (int)gul % 10;
}
void rs_5_06_13_1(void) {
	int *t = gpi;
	jpi = t;
}
void rs_5_06_13_2(void) {
	int i = ji;
	gps->i = !gs.u;
}
void rs_5_06_13_3(void) {
	int i = ji;
	for (i = 12; i > 0; i--) { gul = gula[i]; }
}
void rs_5_06_13_4(void) {
	int *t = jpi;
	v1(*t);
}
void rs_5_06_13_5(void) {
	gula[5] &= gula[7] << 26;
}
char * rs_5_06_13_6(void) {
	return gp;
}
void rs_5_06_14_0(void) {
	vs(gps);
}
void rs_5_06_14_1(void) {
	gu = -(gua[3] ^ ((unsigned int)gl2));
}
void rs_5_06_14_2(void) {
	guc = (guc + guca[2]) % 4;
}
void rs_5_06_14_3(void) {
	gc2 %= 2;
}
void rs_5_06_15_1(double a) {
	char *t = rp();
	jp = t;
}
void rs_5_06_15_2(double a) {
	char *t = jp;
	v0();
	switch (gps->c) { case 0: gd *= a; break; case 1: gl2 += 90104L; break; case 2: t = &gca[3]; break; }
}
void rs_5_06_15_3(double a) {
	if (gi3 != 0) gs.a[7] = gi3 % gi3;
}
void rs_5_06_15_4(double a) {
	int i = ji;
	v0();
	for (i = 0; i < 12; i++) { vs(gps); vl(65536L); if (gu != 0) gua[i] = gs.u / gu; }
}
char rs_5_06_15_5(double a) {
	if (r2(gi2, 100)) return gc - *gp;
}
void rs_5_06_15_6(double a) {
	guca[2] = (guc >> 3) - (guca[6] ^ guca[5]);
}
char rs_5_06_15_7(double a) {
	char *t = jp;
	v0();
	return -(~*t);
}
void rs_5_06_16_0(void) {
	int t = gia[2] >> 5;
	ji = t;
}
void rs_5_06_16_1(void) {
	v2(gi2, gi);
}
void rs_5_06_16_2(void) {
	if (*gpi) { gs.d -= gs.d; }
}
void rs_5_06_16_3(void) {
	int t = ji;
	v0();
	gs.a[t] = ~(t & gs.a[3]);
}
void rs_5_06_16_4(void) {
	gu >>= 3;
}
void rs_5_06_16_5(void) {
	if (gc2 < 5) ++gl2;
}
unsigned int rs_5_06_16_6(void) {
	return gu2;
}
void rs_5_06_17_1(void) {
	int i = ji;
	i = 2; do { if (gua[i] != 0) gs.u = 256 / gua[i]; } while (--i > 0);
}
void rs_5_06_17_2(void) {
	vu(gua[2]);
}
void rs_5_06_17_3(void) {
	gc = ((char)gula[5] + gc2) * (1 * -96);
}
void rs_5_06_18_1(long a, unsigned int b, struct st *c) {
	int t = gpi[2];
	ji = t;
}
void rs_5_06_18_2(long a, unsigned int b, struct st *c) {
	unsigned char u = guca[1];
	juc = u;
}
void rs_5_06_18_3(long a, unsigned int b, struct st *c) {
	if (gu != 0) gua[1] = b % gu;
}
void rs_5_06_18_4(long a, unsigned int b, struct st *c) {
	unsigned char u = juc;
	gs.u = ru(gs.u);
}
void rs_5_06_18_5(long a, unsigned int b, struct st *c) {
	int t = ji;
	v0();
	gi = t;
}
void rs_5_06_18_6(long a, unsigned int b, struct st *c) {
	int i = ji;
	unsigned char u = juc;
	v0();
	for (i = 0; i < 12; i++) { if (a != 0) gl2 = (long)u % a; if (gps->u != 0) gu = gps->u / gps->u; }
}
void rs_5_06_18_7(long a, unsigned int b, struct st *c) {
	vd(-gs.d);
}
unsigned int rs_5_06_18_8(long a, unsigned int b, struct st *c) {
	int t = ji;
	v0();
	return ru(gua[t] * 255);
}
void rs_5_06_19_0(unsigned int a) {
	int t = 255 >> 5;
	ji = t;
}
void rs_5_06_19_1(unsigned int a) {
	char *u = gp;
	jp = u;
}
void rs_5_06_19_2(unsigned int a) {
	char *u = jp;
	gp = u;
}
void rs_5_06_19_3(unsigned int a) {
	int t = ji;
	vp(gp + t);
}
void rs_5_06_19_4(unsigned int a) {
	vu(gua[a]);
}
long rs_5_06_19_5(unsigned int a) {
	return rl(9L - 0L);
}
void rs_5_07_00_0(unsigned int a, double b) {
	if (((unsigned long)gi2) > ((unsigned long)gc)) { if (*gpl != 0) gl = gl % *gpl; gs.p = &gca[0]; if (gul != 0) gul = gul % gul; } else { guc++; v0(); gs.l = 65536L - (long)gca[6]; }
}
void rs_5_07_00_1(unsigned int a, double b) {
	if ((double)gps->l == 1.0) gs.u = 1 - gs.u;
}
void rs_5_07_00_2(unsigned int a, double b) {
	--gp;
}
void rs_5_07_01_1(long a, int b) {
	unsigned char t = guca[b] % 10;
	juc = t;
}
void rs_5_07_01_2(long a, int b) {
	long u = (long)200;
	jl = u;
}
void rs_5_07_01_3(long a, int b) {
	gpi[1] >>= (b & 15);
}
void rs_5_07_01_4(long a, int b) {
	int i = ji;
	for (i = 0; i < 8; i++) { if (gul != 0) gul = gul % gul; }
}
void rs_5_07_01_5(long a, int b) {
	unsigned char t = juc;
	long u = jl;
	switch (gs.u) { case 0: gula[t] += 0UL; break; case 1: v1(255); break; case 2: vu(gu2); break; case 3: gul -= gula[7]; default: gs.p = gp; break; }
}
long rs_5_07_01_6(long a, int b) {
	if (gps->c < -61) return gs.l;
}
long rs_5_07_01_7(long a, int b) {
	unsigned char t = juc;
	v0();
	return (long)t;
}
void rs_5_07_02_1(void) {
	int *t = gpi;
	jpi = t;
}
void rs_5_07_02_2(void) {
	guca[6] = guca[5] << 5;
}
void rs_5_07_02_3(void) {
	int *t = jpi;
	switch (gl2) { case 0L: vp(gps->p); break; case 1L: gul = gula[6] + gul; break; case 2L: v1(2); break; case 3L: gl = (long)gua[7] >> 3; break; case 4L: case 5L: gua[3] = gu2 = (unsigned int)(t[2] > 255); break; default: gla[4] = -4L; break; }
}
void rs_5_07_02_4(void) {
	int i = ji;
	v0();
	i = 4; do { if (gul != 0) gul = 0x10000UL / gul; gl2++; } while (--i > 0);
}
void rs_5_07_02_5(void) {
	gc2 = (gps->c % 7) ^ (7 + gca[5]);
}
void rs_5_07_02_6(void) {
	gs.d = gda[0];
}
char rs_5_07_02_7(void) {
	return gc;
}
void rs_5_07_03_0(int a, unsigned long b, int c) {
	int *t = rpi(gps->i);
	jpi = t;
}
void rs_5_07_03_1(int a, unsigned long b, int c) {
	v2(gi2, gia[2] / 100);
}
void rs_5_07_03_2(int a, unsigned long b, int c) {
	gc2 = gc;
}
void rs_5_07_03_3(int a, unsigned long b, int c) {
	gul++;
}
void rs_5_07_03_4(int a, unsigned long b, int c) {
	int *t = jpi;
	v0();
	gpi = t;
}
long rs_5_07_03_5(int a, unsigned long b, int c) {
	return (*gpl << 11) - gpl[2];
}
void rs_5_07_04_1(void) {
	unsigned char t = ~guc;
	juc = t;
}
void rs_5_07_04_2(void) {
	int i = ji;
	for (i = 0; i < 15; i++) { gc2++; if (gu != 0) gu = 256 / gu; gu = ru(gps->u); }
}
void rs_5_07_04_3(void) {
	gd2 *= gd2;
}
int * rs_5_07_04_4(void) {
	if (gu2 == 1) return gpi;
}
void rs_5_07_04_5(void) {
	unsigned char t = juc;
	v0();
	gul = gula[t] = (unsigned long)(24912 << 5);
}
int * rs_5_07_04_6(void) {
	return gpi;
}
void rs_5_07_05_0(void) {
	unsigned long t = rul(gul);
	jul = t;
}
void rs_5_07_05_1(void) {
	int *u = rpi(gi);
	v0();
	jpi = u;
}
void rs_5_07_05_2(void) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
void rs_5_07_05_3(void) {
	while (gi-- > 0) { if (*gpi == 127) break; gpi++; }
}
void rs_5_07_05_4(void) {
	int *u = jpi;
	v0();
	u = u + 1;
}
void rs_5_07_05_5(void) {
	while (gi-- > 0) *gpi++ = 127;
}
unsigned long rs_5_07_05_6(void) {
	int *u = jpi;
	v0();
	if (gs.c >= 5) return (unsigned long)u[7];
}
unsigned long rs_5_07_05_7(void) {
	return -(gula[0] | gul);
}
void rs_5_07_06_0(int a, int b) {
	gs.i = r2(gi2, a) + (int)gl2;
}
void rs_5_07_06_1(int a, int b) {
	vl((long)gs.u / 7L);
}
void rs_5_07_06_2(int a, int b) {
	b -= gi;
}
unsigned int rs_5_07_06_3(int a, int b) {
	return (gu = gua[a]);
}
void rs_5_07_07_0(void) {
	char *t = gps->p;
	jp = t;
}
void rs_5_07_07_1(void) {
	double u = 3.0 - gd2;
	jd = u;
}
void rs_5_07_07_2(void) {
	--gp;
}
void rs_5_07_07_3(void) {
	char *t = jp;
	gl = -gl2 + (long)t[1];
}
void rs_5_07_07_4(void) {
	double u = jd;
	vd(u);
}
void rs_5_07_08_0(int *a, unsigned char b) {
	if (gua[4] != 0) gu2 = ((unsigned int)*gp) / gua[4];
}
void rs_5_07_08_1(int *a, unsigned char b) {
	gi3 = a[2];
}
char * rs_5_07_08_2(int *a, unsigned char b) {
	return rp();
}
void rs_5_07_09_0(unsigned char a, struct st *b, unsigned char c) {
	char *t = gs.p;
	jp = t;
}
void rs_5_07_09_1(unsigned char a, struct st *b, unsigned char c) {
	unsigned long u = rul(gul);
	jul = u;
}
long rs_5_07_09_2(unsigned char a, struct st *b, unsigned char c) {
	if (gua[a] & 0x10) return gl2 - -48567L;
}
void rs_5_07_09_3(unsigned char a, struct st *b, unsigned char c) {
	if (gua[a] != 0) gu2 = 1 % gua[a];
}
void rs_5_07_09_4(unsigned char a, struct st *b, unsigned char c) {
	char *t = jp;
	v0();
	gp = t;
}
void rs_5_07_09_5(unsigned char a, struct st *b, unsigned char c) {
	if (gla[a] <= gl) gpi = rpi((int)guca[7]);
}
void rs_5_07_09_6(unsigned char a, struct st *b, unsigned char c) {
	unsigned long u = jul;
	v0();
	gul = u;
}
void rs_5_07_09_7(unsigned char a, struct st *b, unsigned char c) {
	gpl[3] = -gs.l;
}
long rs_5_07_09_8(unsigned char a, struct st *b, unsigned char c) {
	return (gl2 = gpl[3]);
}
void rs_5_07_10_0(unsigned char a, double b, long *c) {
	unsigned int t = 5;
	ju = t;
}
void rs_5_07_10_1(unsigned char a, double b, long *c) {
	char *u = &gca[1];
	jp = u;
}
void rs_5_07_10_2(unsigned char a, double b, long *c) {
	gu <<= 7;
}
void rs_5_07_10_3(unsigned char a, double b, long *c) {
	gca[6] = ' ';
}
void rs_5_07_10_4(unsigned char a, double b, long *c) {
	--gl;
}
void rs_5_07_10_5(unsigned char a, double b, long *c) {
	char *u = jp;
	gp = u;
}
void rs_5_07_10_6(unsigned char a, double b, long *c) {
	unsigned int t = ju;
	if (!gca[a]) { vl(rl(gl)); } else { gu2 = t / 3; guca[1] = guc - a; }
}
int * rs_5_07_10_7(unsigned char a, double b, long *c) {
	return gpi;
}
void rs_5_07_11_0(int *a, int *b) {
	*b = gi3 >> 3;
}
void rs_5_07_11_1(int *a, int *b) {
	if (gula[7] != 0) gula[3] = 83880UL % gula[7];
}
int rs_5_07_11_2(int *a, int *b) {
	return !(long)!gula[6];
}
void rs_5_07_12_0(char *a, int *b) {
	char *t = a + 1;
	jp = t;
}
char rs_5_07_12_1(char *a, int *b) {
	if ((gl2 = (long)gul) > 7L) return gc2;
}
void rs_5_07_12_2(char *a, int *b) {
	gu2 = (unsigned int)!*b;
}
void rs_5_07_12_3(char *a, int *b) {
	char *t = jp;
	if (((unsigned char)gl) < 28) { if (gca[1] != 0) gca[4] = t[1] / gca[1]; if (gs.l != 0) gla[1] = 65536L / gs.l; }
}
void rs_5_07_12_4(char *a, int *b) {
	if (guca[6]) gps->l = gla[1];
}
void rs_5_07_12_5(char *a, int *b) {
	char *t = jp;
	if (r1(gs.a[0])) { gps->i = gs.a[4] - gi2; t = gp; if (gi2 != 0) gia[2] = *gpi / gi2; }
}
char rs_5_07_12_6(char *a, int *b) {
	return (a[7] = gca[5]);
}
void rs_5_07_13_0(struct st *a) {
	gul--;
}
void rs_5_07_13_1(struct st *a) {
	gpi = gpi + 1;
}
char * rs_5_07_13_2(struct st *a) {
	return gp;
}
void rs_5_07_14_1(unsigned char a, unsigned long b, long *c) {
	long t = 65536L ^ -12320L;
	jl = t;
}
void rs_5_07_14_2(unsigned char a, unsigned long b, long *c) {
	double u = gd / 3.0;
	jd = u;
}
void rs_5_07_14_3(unsigned char a, unsigned long b, long *c) {
	v1(gi2);
}
void rs_5_07_14_4(unsigned char a, unsigned long b, long *c) {
	int i = ji;
	v0();
	for (i = 0; i < 9; i++) { gpi = gpi + i; gula[i] = rul(gul) | gula[i]; vu(gu); }
}
void rs_5_07_14_5(unsigned char a, unsigned long b, long *c) {
	double u = jd;
	v0();
	switch (gu) { case 0: vd(gs.d); break; case 1: gs.p = gps->p + a; break; case 2: vp(gs.p); break; case 3: gl2 -= 65536L; break; case 4: gu2 = gs.u = gua[7]; break; case 5: gc = 6 - gp[2]; break; }
}
void rs_5_07_14_6(unsigned char a, unsigned long b, long *c) {
	long t = jl;
	double u = jd;
	v0();
	if (*gp < gc2) { if (gs.l != 0) *gpl = t % gs.l; v2(~gps->a[a], gi); gi2++; } else { if (gps->u != 0) gs.u = gua[7] / gps->u; if (gula[1] != 0) gul = gul / gula[1]; }
}
int rs_5_07_14_7(unsigned char a, unsigned long b, long *c) {
	return -(-1);
}
void rs_5_07_15_0(int a, int b) {
	if (gua[2] != 0) gs.u = gua[a] / gua[2];
}
void rs_5_07_15_1(int a, int b) {
	gu2 = gua[b];
}
void rs_5_07_16_1(long a, int b, unsigned char c) {
	int t = gia[0];
	ji = t;
}
void rs_5_07_16_2(long a, int b, unsigned char c) {
	gs.u /= 16;
}
void rs_5_07_16_3(long a, int b, unsigned char c) {
	gpi = &gia[3];
}
void rs_5_07_16_4(long a, int b, unsigned char c) {
	int t = ji;
	gi = t;
}
void rs_5_07_16_5(long a, int b, unsigned char c) {
	int i = ji;
	for (i = 0; i < b; i++) { if (gu != 0) gua[6] = gps->u % gu; }
}
int rs_5_07_16_6(long a, int b, unsigned char c) {
	return !gul;
}
void rs_5_07_17_0(char *a, unsigned int b, unsigned char c) {
	unsigned long t = 0x10000UL * gula[c];
	jul = t;
}
void rs_5_07_17_1(char *a, unsigned int b, unsigned char c) {
	unsigned long t = jul;
	gi3 = (t >= 9UL) >> 2;
}
void rs_5_07_17_2(char *a, unsigned int b, unsigned char c) {
	gp[3] = (char)gula[7];
}
void rs_5_07_17_3(char *a, unsigned int b, unsigned char c) {
	guca[b] >>= 7;
}
char * rs_5_07_17_4(char *a, unsigned int b, unsigned char c) {
	return a;
}
void rs_5_07_18_1(int a) {
	char *t = gps->p;
	jp = t;
}
void rs_5_07_18_2(int a) {
	int u = gpi[3] & 256;
	ji = u;
}
void rs_5_07_18_3(int a) {
	int i = ji;
	int u = ji;
	i = 13; do { gl = gl2 = *gpl + gl2; gu |= 1 - 255; v2(u ^ gs.a[i], gi); } while (--i > 0);
}
void rs_5_07_18_4(int a) {
	v2(~a, gi);
}
void rs_5_07_18_5(int a) {
	char *t = jp;
	v0();
	gp = t;
}
int rs_5_07_18_6(int a) {
	char *t = jp;
	int u = ji;
	v0();
	return (r0() && (gs.c = *t) >= -12 ? r2(u, gi) : (gs.a[5] * gia[6]));
}
void rs_5_07_19_0(char *a, long *b, int c) {
	gp++;
}
void rs_5_07_19_1(char *a, long *b, int c) {
	vp(gs.p + c);
}
void rs_5_07_19_2(char *a, long *b, int c) {
	if (r2(gi2, gi3)) if (gula[1] != 0) gula[3] = 0x10000UL / gula[1];
}
void rs_5_07_19_3(char *a, long *b, int c) {
	v2(16, gi);
}
void rs_5_07_19_4(char *a, long *b, int c) {
	gd = (gs.d * gs.d) * (gs.d * 0.5);
}
long rs_5_07_19_5(char *a, long *b, int c) {
	return *gpl;
}
void rs_5_08_00_0(long a, long *b) {
	char t = gps->c;
	jc = t;
}
void rs_5_08_00_1(long a, long *b) {
	unsigned char u = (unsigned char)!gps->a[0];
	juc = u;
}
void rs_5_08_00_2(long a, long *b) {
	gd += (double)gps->a[6];
}
void rs_5_08_00_3(long a, long *b) {
	if (gul != 0) gul = ((unsigned long)gi3) % gul;
}
void rs_5_08_00_4(long a, long *b) {
	*b &= ~*gpl;
}
void rs_5_08_00_5(long a, long *b) {
	char t = jc;
	guca[t] = guc;
}
void rs_5_08_00_6(long a, long *b) {
	unsigned char u = juc;
	guc = u;
}
void rs_5_08_00_7(long a, long *b) {
	char t = jc;
	if (((unsigned char)gc2) < 67) gula[t] += gula[3] + 9UL;
}
unsigned long rs_5_08_00_8(long a, long *b) {
	return (gul - 3UL) + (gula[0] >> 8);
}
void rs_5_08_01_1(int a, int b, double c) {
	switch (gs.c) { case 0: gu2 <<= 12; break; case 1: case 2: gs.d -= c; case 3: vs(gps); default: vp(rp()); break; }
}
void rs_5_08_01_2(int a, int b, double c) {
	int i = ji;
	v0();
	for (i = 0; i < 8; i++) { if (gl != 0) gl2 = gl2 % gl; if (gia[3] != 0) gi = *gpi % gia[3]; }
}
void rs_5_08_01_3(int a, int b, double c) {
	int i = ji;
	v0();
	i = 0; while (i < 10) { if (gul != 0) gul = 7UL % gul; gula[i] = rul(gula[i]); guca[6] %= 3; i++; }
}
int * rs_5_08_01_4(int a, int b, double c) {
	return gpi;
}
void rs_5_08_02_0(int *a) {
	double t = (gp[3] ? gd : gd2);
	jd = t;
}
void rs_5_08_02_1(int *a) {
	gl2++;
}
void rs_5_08_02_2(int *a) {
	if (guc) if (gc != 0) gps->c = gc / gc;
}
void rs_5_08_02_3(int *a) {
	double t = jd;
	gd = t;
}
void rs_5_08_02_4(int *a) {
	guca[3] = guc = 2;
}
char rs_5_08_02_5(int *a) {
	return gc;
}
void rs_5_08_03_1(double a, long *b, int c) {
	char *t = gp;
	jp = t;
}
void rs_5_08_03_2(double a, long *b, int c) {
	int u = r1(gs.a[3]);
	ji = u;
}
void rs_5_08_03_3(double a, long *b, int c) {
	gi3--;
}
void rs_5_08_03_4(double a, long *b, int c) {
	char *t = jp;
	v0();
	vp(t);
}
void rs_5_08_03_5(double a, long *b, int c) {
	int u = ji;
	v0();
	gps->u = gu2 = (gu << 2) >> (c & 15);
}
void rs_5_08_03_6(double a, long *b, int c) {
	gl2 = -gla[c] + gps->l;
}
void rs_5_08_03_7(double a, long *b, int c) {
	int i = ji;
	v0();
	for (i = 0; i < c; i++) { ++gc; }
}
unsigned long rs_5_08_03_8(double a, long *b, int c) {
	return 50384UL;
}
void rs_5_08_04_0(unsigned int a) {
	if (gpi[2] != 0) gps->a[a] = 6 % gpi[2];
}
void rs_5_08_04_1(unsigned int a) {
	gul = (5UL << 1) | gula[0];
}
void rs_5_08_04_2(unsigned int a) {
	gs.d -= (gul & 0x10 ? gd2 : 0.25);
}
void rs_5_08_04_3(unsigned int a) {
	gl2 = rl(gl << 24);
}
void rs_5_08_04_4(unsigned int a) {
	gula[6] = gula[3];
}
int rs_5_08_04_5(unsigned int a) {
	return gs.a[a];
}
void rs_5_08_05_0(void) {
	char t = 8;
	jc = t;
}
void rs_5_08_05_1(void) {
	guc = guca[0];
}
void rs_5_08_05_2(void) {
	vu(~gu2);
}
void rs_5_08_05_3(void) {
	char t = jc;
	v0();
	switch (gps->u) { case 1: gs.a[6] -= 150; break; case 3: vp(gs.p + t); break; case 16: gs.l = gl + 65536L; break; case 20: gu2 = gu; break; case 100: t |= 64; break; case 200: vc(t); break; }
}
void rs_5_08_05_4(void) {
	char t = jc;
	v0();
	guca[t] %= 3;
}
void rs_5_08_05_5(void) {
	vs(gps);
}
int rs_5_08_05_6(void) {
	return (3 / 7) ^ (gi3 / 7);
}
void rs_5_08_06_0(int *a) {
	int t = gia[4];
	ji = t;
}
void rs_5_08_06_1(int *a) {
	int t = ji;
	guc |= guc | guca[t];
}
void rs_5_08_06_2(int *a) {
	int t = ji;
	if (256 <= 6 && guca[t] < 128) gd = gda[1] / 3.0;
}
void rs_5_08_06_3(int *a) {
	gul = (gula[4] >> 17) & (gul >> 17);
}
void rs_5_08_06_4(int *a) {
	gc++;
}
char rs_5_08_06_5(int *a) {
	return *gp;
}
void rs_5_08_07_1(unsigned long a, unsigned long b, long c) {
	unsigned long t = (unsigned long)gu2;
	jul = t;
}
void rs_5_08_07_2(unsigned long a, unsigned long b, long c) {
	int i = ji;
	int *u = rpi(gs.i);
	jpi = u;
}
void rs_5_08_07_3(unsigned long a, unsigned long b, long c) {
	int i = ji;
	unsigned long t = jul;
	v0();
	for (i = 14; i > 0; i--) { if (gua[i] != 0) gu = 1 / gua[i]; t ^= 0x10000UL; }
}
void rs_5_08_07_4(unsigned long a, unsigned long b, long c) {
	guc = (7 - guca[0]) << 4;
}
void rs_5_08_07_5(unsigned long a, unsigned long b, long c) {
	int *u = jpi;
	v0();
	v1(*u);
}
void rs_5_08_07_6(unsigned long a, unsigned long b, long c) {
	guca[6] = guc + guca[6];
}
unsigned int rs_5_08_07_7(unsigned long a, unsigned long b, long c) {
	int *u = jpi;
	v0();
	return gs.u;
}
void rs_5_08_08_0(unsigned long a, struct st *b) {
	vl(*gpl);
}
void rs_5_08_08_1(unsigned long a, struct st *b) {
	v0();
}
void rs_5_08_08_2(unsigned long a, struct st *b) {
	switch (gps->i) { case 0: b->c *= 3; break; case 1: gs.d -= gd2; break; case 2: gc = gca[1]; break; case 3: vu(gu); break; }
}
void rs_5_08_08_3(unsigned long a, struct st *b) {
	a = -0x10000UL % 7UL;
}
long rs_5_08_08_4(unsigned long a, struct st *b) {
	return 65536L % 10L;
}
void rs_5_08_09_0(void) {
	int u = ji;
	unsigned int t = gs.u % 2;
	ju = t;
}
void rs_5_08_09_1(void) {
	int u = !gc;
	ji = u;
}
void rs_5_08_09_2(void) {
	int u = ji;
	gul >>= (u & 15);
}
void rs_5_08_09_3(void) {
	vl(0L >> 13);
}
void rs_5_08_09_4(void) {
	unsigned int t = ju;
	v0();
	if ((guc = guca[7])) gp[1] >>= (t & 7);
}
int rs_5_08_09_5(void) {
	int u = ji;
	v0();
	return (gs.a[u] = 127);
}
void rs_5_08_10_0(void) {
	v0();
}
void rs_5_08_10_1(void) {
	gps->p = gp;
}
void rs_5_08_10_2(void) {
	*gp %= 7;
}
unsigned int rs_5_08_10_3(void) {
	return ((unsigned int)255) + ((unsigned int)(gps->l < -58262L));
}
void rs_5_08_11_0(char a) {
	int t = -(int)gps->c;
	ji = t;
}
void rs_5_08_11_1(char a) {
	int t = ji;
	if (2.5 < gd) { *gpi = gi; gs.c >>= (t & 7); gpi++; } else { if (gula[0] & 0x8) if (t != 0) t = gs.a[6] / t; }
}
void rs_5_08_11_2(char a) {
	gs.l = *gpl = -(65536L - gps->l);
}
void rs_5_08_11_3(char a) {
	int t = ji;
	guca[t] = guc;
}
void rs_5_08_11_4(char a) {
	gul--;
}
int * rs_5_08_11_5(char a) {
	return gpi;
}
void rs_5_08_12_0(int a, unsigned int b, unsigned char c) {
	if (c != guc) { if (gs.l != 0) gl = 65536L / gs.l; vl((long)(gl >= gpl[3])); v2(gi2, 100 >> 15); }
}
void rs_5_08_12_1(int a, unsigned int b, unsigned char c) {
	switch (gs.i) { case 0: gul = gula[7] = gula[a] + 0x10000UL; case 1: case 2: vs(gps); }
}
char * rs_5_08_12_2(int a, unsigned int b, unsigned char c) {
	return gp + a;
}
void rs_5_08_13_0(void) {
	gua[0] = 255;
}
void rs_5_08_13_1(void) {
	if (gl2 != 0) gps->l = -28178L % gl2;
}
void rs_5_08_13_2(void) {
	switch (gl2) { case 0L: *gpi /= 16; break; case 1L: *gpl >>= 14; break; case 2L: vl(gl); case 3L: gs.l = gl2; break; default: vp(gs.p); break; }
}
int * rs_5_08_13_3(void) {
	return gpi + 1;
}
void rs_5_08_14_0(unsigned int a, unsigned int b, unsigned long c) {
	unsigned long t = gul;
	jul = t;
}
void rs_5_08_14_1(unsigned int a, unsigned int b, unsigned long c) {
	char *u = gs.p;
	jp = u;
}
void rs_5_08_14_2(unsigned int a, unsigned int b, unsigned long c) {
	char *u = jp;
	u = u + b;
}
void rs_5_08_14_3(unsigned int a, unsigned int b, unsigned long c) {
	unsigned long t = jul;
	gul = t;
}
void rs_5_08_14_4(unsigned int a, unsigned int b, unsigned long c) {
	char *u = jp;
	if ((a = gua[a]) >= 256) { vd((*u ? gd2 : gd)); gp = rp(); vd((r1(gi) ? 100.0 : gd)); }
}
void rs_5_08_14_5(unsigned int a, unsigned int b, unsigned long c) {
	++gi2;
}
void rs_5_08_14_6(unsigned int a, unsigned int b, unsigned long c) {
	if (gpl[0] != 0) gl2 = gps->l / gpl[0];
}
long rs_5_08_14_7(unsigned int a, unsigned int b, unsigned long c) {
	return (gpl[2] = gl);
}
void rs_5_08_15_1(void) {
	int *t = gpi;
	jpi = t;
}
void rs_5_08_15_2(void) {
	int *t = jpi;
	int *u = t + 1;
	jpi = u;
}
void rs_5_08_15_3(void) {
	int *u = jpi;
	switch (gu2) { case 2: gps->u /= 2; break; case 10: gps->c = gp[0] = 'A'; break; case 16: vl((long)gs.c); break; }
}
void rs_5_08_15_4(void) {
	int i = ji;
	v0();
	for (i = 0; i < 9; i++) { v2(gi, gi); if (gl2 != 0) gla[3] = gl / gl2; }
}
void rs_5_08_15_5(void) {
	int *t = jpi;
	v0();
	v1(*t);
}
char * rs_5_08_15_6(void) {
	return gp + 1;
}
void rs_5_08_16_0(void) {
	int t = gi3;
	ji = t;
}
void rs_5_08_16_1(void) {
	int u = (int)gca[0] << 12;
	ji = u;
}
void rs_5_08_16_2(void) {
	int t = ji;
	gc = (gc * gc) - (char)!gs.a[t];
}
void rs_5_08_16_3(void) {
	gula[1] = 42614UL % 16UL;
}
void rs_5_08_16_4(void) {
	int t = ji;
	if (74178UL != gula[t]) { v2(gi2, 255); } else { vp(&gca[2]); guca[2] = guc * guc; vc(gc / 4); }
}
void rs_5_08_16_5(void) {
	int u = ji;
	v0();
	gi = u;
}
int rs_5_08_16_6(void) {
	return (int)*gpl;
}
void rs_5_08_17_0(void) {
	int t = 256 | (int)*gp;
	ji = t;
}
void rs_5_08_17_1(void) {
	int u = ~gi3;
	ji = u;
}
void rs_5_08_17_2(void) {
	int u = ji;
	u >>= 10;
}
void rs_5_08_17_3(void) {
	gda[2] = -(gs.l ? gda[3] : gd2);
}
void rs_5_08_17_4(void) {
	int t = ji;
	guca[t] = guca[t] / 10;
}
unsigned long rs_5_08_17_5(void) {
	int u = ji;
	return (unsigned long)r2(u, gi);
}
void rs_5_08_18_1(unsigned long a, unsigned char b, char c) {
	int i = ji;
	for (i = 0; i < 10; i++) { gu = gps->u = gu / 2; }
}
void rs_5_08_18_2(unsigned long a, unsigned char b, char c) {
	gc = gc2 - ('z' ^ gc);
}
int rs_5_08_18_3(unsigned long a, unsigned char b, char c) {
	return ~(~gi);
}
void rs_5_08_19_0(char a, double b) {
	gpi = gpi + a;
}
void rs_5_08_19_1(char a, double b) {
	vu(gs.u);
}
void rs_5_08_19_2(char a, double b) {
	gs.l = *gpl = (long)gca[a] + rl((long)gu);
}
void rs_5_08_19_3(char a, double b) {
	gl2 = rl(gs.l) >> 8;
}
void rs_5_08_19_4(char a, double b) {
	if (gula[a] < 36812UL && (gs.c = -80)) { gps->u -= (unsigned int)!256; gca[4] = gs.c = (char)!gula[4] - (gp[1] & gc); }
}
void rs_5_09_00_1(char a) {
	char t = ~gps->c;
	jc = t;
}
void rs_5_09_00_2(char a) {
	int u = 16 << 15;
	ji = u;
}
void rs_5_09_00_3(char a) {
	int u = ji;
	if (gla[u] != 0) gla[1] = gl2 % gla[u];
}
void rs_5_09_00_4(char a) {
	char t = jc;
	if (gps->a[t] != 0) gps->a[a] = gpi[0] % gps->a[t];
}
void rs_5_09_00_5(char a) {
	int u = ji;
	gps->u ^= gua[u];
}
void rs_5_09_00_6(char a) {
	gi |= (int)gul;
}
void rs_5_09_00_7(char a) {
	int i = ji;
	for (i = 7; i > 0; i--) { gda[2] = (gpi[0] >= gi3 ? -3.0 : (gpi[3] ? gs.d : gda[1])); gi = !gla[i]; gs.p = gps->p; }
}
int rs_5_09_00_8(char a) {
	return 8 + (int)gc2;
}
void rs_5_09_01_1(double a, long *b) {
	unsigned int t = gu / 16;
	ju = t;
}
void rs_5_09_01_2(double a, long *b) {
	int u = gi;
	ji = u;
}
void rs_5_09_01_3(double a, long *b) {
	if (b[3] != 0) gla[5] = 6L % b[3];
}
void rs_5_09_01_4(double a, long *b) {
	unsigned int t = ju;
	int u = ji;
	if (guca[t] && guc & 4) { if (gula[u] != 0) gula[2] = gula[u] % gula[u]; }
}
void rs_5_09_01_5(double a, long *b) {
	v1(!gs.l);
}
void rs_5_09_01_6(double a, long *b) {
	if (gi3 != 0) gi3 = 100 % gi3;
}
void rs_5_09_01_7(double a, long *b) {
	int i = ji;
	v0();
	i = 0; while (i < 14) { guc ^= guc | 255; vd((*gpl < 6L ? gd2 : a)); i++; }
}
unsigned long rs_5_09_01_8(double a, long *b) {
	return gul;
}
void rs_5_09_02_0(char *a, long b) {
	gula[0] /= 7UL;
}
void rs_5_09_02_1(char *a, long b) {
	if (gl != 0) gl2 = gl2 / gl;
}
long rs_5_09_02_2(char *a, long b) {
	return (gl2 ^ gs.l) + ~gl2;
}
void rs_5_09_03_0(int a, double b, int c) {
	gp = gp + a;
}
void rs_5_09_03_1(int a, double b, int c) {
	gpi = gpi + a;
}
void rs_5_09_03_2(int a, double b, int c) {
	gl2 = rl(-12756L);
}
char * rs_5_09_03_3(int a, double b, int c) {
	return gs.p;
}
void rs_5_09_04_0(unsigned long a, int b) {
	double t = -100.0;
	jd = t;
}
void rs_5_09_04_1(unsigned long a, int b) {
	*gp /= 10;
}
void rs_5_09_04_2(unsigned long a, int b) {
	double t = jd;
	vd(t);
}
void rs_5_09_04_3(unsigned long a, int b) {
	gi = gia[6];
}
void rs_5_09_04_4(unsigned long a, int b) {
	gul++;
}
void rs_5_09_04_5(unsigned long a, int b) {
	while (b > 0) { gi += *gpi++; b--; }
}
int rs_5_09_04_6(unsigned long a, int b) {
	return r2((int)guca[b], gi);
}
void rs_5_09_05_0(char a, char b, int c) {
	int t = gs.a[c] - gia[b];
	ji = t;
}
void rs_5_09_05_1(char a, char b, int c) {
	guca[c] = guc = (guca[b] | guca[a]) | (7 - guca[7]);
}
void rs_5_09_05_2(char a, char b, int c) {
	v1((guc > 128 ? 256 : gi2));
}
void rs_5_09_05_3(char a, char b, int c) {
	if (guc == 7) gc2--;
}
void rs_5_09_05_4(char a, char b, int c) {
	int t = ji;
	v0();
	gu2 = (2.5 < 3.0 ? gu : gu2) * ((unsigned int)gula[t]);
}
long rs_5_09_05_5(char a, char b, int c) {
	return -1512L;
}
void rs_5_09_06_1(void) {
	long t = ~5L;
	jl = t;
}
void rs_5_09_06_2(void) {
	char *u = gp + 1;
	jp = u;
}
void rs_5_09_06_3(void) {
	int i = ji;
	char *u = jp;
	i = 11; do { gc2++; gul = (gpi[0] & 2 ? gul : gul) - gul; u = gp; } while (--i > 0);
}
void rs_5_09_06_4(void) {
	gu2 &= gu >> 3;
}
void rs_5_09_06_5(void) {
	gula[2] = ~gula[3];
}
void rs_5_09_06_6(void) {
	gc = ' ';
}
void rs_5_09_06_7(void) {
	long t = jl;
	vl(t);
}
int * rs_5_09_06_8(void) {
	return rpi(gi & gpi[0]);
}
void rs_5_09_07_0(unsigned long a, int b) {
	unsigned char t = guc % 100;
	juc = t;
}
void rs_5_09_07_1(unsigned long a, int b) {
	gs.u = gu2;
}
void rs_5_09_07_2(unsigned long a, int b) {
	if (gua[0] != 0) gu2 = gu2 % gua[0];
}
void rs_5_09_07_3(unsigned long a, int b) {
	unsigned char t = juc;
	v1(t);
}
void rs_5_09_07_4(unsigned long a, int b) {
	gl2 = gla[b];
}
void rs_5_09_08_1(unsigned int a) {
	unsigned int t = a / 10;
	ju = t;
}
void rs_5_09_08_2(unsigned int a) {
	unsigned long u = 0x10000UL + gula[0];
	jul = u;
}
void rs_5_09_08_3(unsigned int a) {
	v0();
}
void rs_5_09_08_4(unsigned int a) {
	gp = gp + a;
}
void rs_5_09_08_5(unsigned int a) {
	vc(gc * gca[a]);
}
void rs_5_09_08_6(unsigned int a) {
	unsigned int t = ju;
	unsigned long u = jul;
	v0();
	if (t >= 19777 || a < t) { guc = (unsigned char)(gps->u & t); gp = rp(); }
}
void rs_5_09_08_7(unsigned int a) {
	int i = ji;
	v0();
	for (i = 3; i > 0; i--) { gp = rp(); v0(); }
}
unsigned long rs_5_09_08_8(unsigned int a) {
	return (unsigned long)((unsigned char)gu);
}
void rs_5_09_09_0(unsigned int a) {
	unsigned long t = rul(gul);
	jul = t;
}
void rs_5_09_09_1(unsigned int a) {
	gca[a] = *gp = -(gs.c / 3);
}
void rs_5_09_09_2(unsigned int a) {
	if ((gu2 = gu) || r0()) { v0(); --guc; }
}
void rs_5_09_09_3(unsigned int a) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
int rs_5_09_09_4(unsigned int a) {
	return gia[7];
}
void rs_5_09_10_1(unsigned char a) {
	unsigned char t = guca[a] % 16;
	juc = t;
}
void rs_5_09_10_2(unsigned char a) {
	int i = ji;
	int *u = rpi(gs.i);
	jpi = u;
}
void rs_5_09_10_3(unsigned char a) {
	vc(0 + 'A');
}
void rs_5_09_10_4(unsigned char a) {
	unsigned char t = juc;
	v0();
	v1(t);
}
void rs_5_09_10_5(unsigned char a) {
	gc++;
}
void rs_5_09_10_6(unsigned char a) {
	int i = ji;
	v0();
	i = 3; do { gu = gu2; gu2 = 8; if (gi3 != 0) gps->i = gi3 % gi3; } while (--i > 0);
}
void rs_5_09_10_7(unsigned char a) {
	int *u = jpi;
	v0();
	gpi = u;
}
unsigned int rs_5_09_10_8(unsigned char a) {
	int *u = jpi;
	v0();
	return gps->u << 1;
}
void rs_5_09_11_0(int a) {
	int *t = gpi + a;
	jpi = t;
}
void rs_5_09_11_1(int a) {
	int *t = jpi;
	gpi = t;
}
void rs_5_09_11_2(int a) {
	switch (gl) { case 3L: gu2 = gu2 * gua[a]; case 5L: vc(gca[a]); break; case 8L: gps->c += 81; break; case 1000L: guc >>= (a & 7); break; default: gd = gda[3] + gd2; break; }
}
void rs_5_09_11_3(int a) {
	gula[4] = gula[a];
}
unsigned int rs_5_09_11_4(int a) {
	return ~(gu ^ 32767);
}
void rs_5_09_12_1(unsigned int a, unsigned char b) {
	long t = gs.l;
	jl = t;
}
void rs_5_09_12_2(unsigned int a, unsigned char b) {
	unsigned long u = (unsigned long)gps->l;
	jul = u;
}
void rs_5_09_12_3(unsigned int a, unsigned char b) {
	guc = b = (guc % 100) - (((unsigned char)gc) - b);
}
void rs_5_09_12_4(unsigned int a, unsigned char b) {
	unsigned long u = jul;
	gu2 = gua[7] = gu2 + (gs.u ^ gu2);
}
void rs_5_09_12_5(unsigned int a, unsigned char b) {
	gpi = gpi + a;
}
void rs_5_09_12_6(unsigned int a, unsigned char b) {
	int i = ji;
	unsigned long u = jul;
	for (i = 0; i < 3; i++) { if (u != 0) u = u % u; if (gula[i] != 0) gula[i] = gula[i] / gula[i]; if (gl != 0) gl2 = *gpl / gl; }
}
void rs_5_09_12_7(unsigned int a, unsigned char b) {
	long t = jl;
	gl = t;
}
int rs_5_09_12_8(unsigned int a, unsigned char b) {
	int i = ji;
	return (gs.i * 3) + 4;
}
void rs_5_09_13_0(double a, long b) {
	gul <<= 19;
}
void rs_5_09_13_1(double a, long b) {
	gi3 &= -658;
}
void rs_5_09_13_2(double a, long b) {
	gpi[1] = gia[6] = gi3;
}
void rs_5_09_13_3(double a, long b) {
	gul = gula[0];
}
void rs_5_09_13_4(double a, long b) {
	if (gul > 88506UL || gps->c == gca[6]) if (gul != 0) gul = gula[2] / gul;
}
long rs_5_09_13_5(double a, long b) {
	return gs.l >> 18;
}
void rs_5_09_14_0(void) {
	double t = 100.0 - gd;
	jd = t;
}
void rs_5_09_14_1(void) {
	gc = ~(gc2 >> 1);
}
void rs_5_09_14_2(void) {
	gs.a[4] |= (int)gua[4];
}
void rs_5_09_14_3(void) {
	double t = jd;
	vd(t);
}
unsigned int rs_5_09_14_4(void) {
	return ru(255) - gua[2];
}
void rs_5_09_15_0(unsigned long a, long *b, char c) {
	char *t = rp();
	jp = t;
}
void rs_5_09_15_1(unsigned long a, long *b, char c) {
	int u = gi2 + gpi[0];
	v0();
	ji = u;
}
int rs_5_09_15_2(unsigned long a, long *b, char c) {
	int u = ji;
	v0();
	if (65536L != 55411L) return u;
}
void rs_5_09_15_3(unsigned long a, long *b, char c) {
	b[2] = gs.l;
}
void rs_5_09_15_4(unsigned long a, long *b, char c) {
	gla[c] = gl;
}
void rs_5_09_15_5(unsigned long a, long *b, char c) {
	int u = ji;
	v0();
	gula[u] = gul = 0x10000UL;
}
void rs_5_09_15_6(unsigned long a, long *b, char c) {
	char *t = jp;
	v0();
	vp(t);
}
int rs_5_09_15_7(unsigned long a, long *b, char c) {
	return (gi3 = gpi[2]);
}
void rs_5_09_16_0(int a, int b, struct st *c) {
	char t = 5;
	jc = t;
}
void rs_5_09_16_1(int a, int b, struct st *c) {
	switch (gl) { case 2L: gps->i = b; break; case 3L: case 8L: *gpi -= gia[0]; break; case 20L: gu2 *= 10; break; case 200L: guca[b] /= 16; break; }
}
void rs_5_09_16_2(int a, int b, struct st *c) {
	while (b-- > 0) *gp++ = 1;
}
void rs_5_09_16_3(int a, int b, struct st *c) {
	char t = jc;
	vc(t);
}
void rs_5_09_16_4(int a, int b, struct st *c) {
	gla[a] <<= 3;
}
void rs_5_09_16_5(int a, int b, struct st *c) {
	if ((guc = guca[b]) >= 255) { a = gps->a[a]; gi = 2 / 16; }
}
void rs_5_09_17_0(void) {
	long t = 7L - 8L;
	jl = t;
}
void rs_5_09_17_1(void) {
	gul -= rul(gul);
}
void rs_5_09_17_2(void) {
	gc = (gc + gca[2]) + (gc2 + gca[5]);
}
void rs_5_09_17_3(void) {
	gs.d = gd * gd2;
}
void rs_5_09_17_4(void) {
	long t = jl;
	v0();
	if (t != 2L) if (gul != 0) gul = gula[6] % gul;
}
void rs_5_09_18_0(char a, unsigned int b, unsigned int c) {
	unsigned long t = gul;
	jul = t;
}
void rs_5_09_18_1(char a, unsigned int b, unsigned int c) {
	if (gp[3] == gc2 && gps->i == gia[6]) b = gu2;
}
void rs_5_09_18_2(char a, unsigned int b, unsigned int c) {
	unsigned long t = jul;
	if (!gi2) { t &= t << (c & 15); }
}
int rs_5_09_18_3(char a, unsigned int b, unsigned int c) {
	return (1 - gi2) ^ !'a';
}
void rs_5_09_19_0(long a) {
	int *t = gpi;
	jpi = t;
}
void rs_5_09_19_1(long a) {
	if (gl2) gd2 -= gd;
}
void rs_5_09_19_2(long a) {
	int *t = jpi;
	v1(*t);
}
void rs_5_09_19_3(long a) {
	if (gc2 & 4) { guca[5] = (guc ? guca[6] : guca[4]); } else { vd(-gd2); gl |= 8983L; }
}
void rs_5_09_19_4(long a) {
	++gul;
}
void rs_5_09_19_5(long a) {
	v2((int)gps->u % 4, gi);
}
char * rs_5_09_19_6(long a) {
	return gps->p;
}
