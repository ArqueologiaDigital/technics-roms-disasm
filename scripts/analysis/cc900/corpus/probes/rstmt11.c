/* Every statement line of random11 alone in its own function (gen_rstmt.py corpus/random11 11): rs_<A>_<BB>_<CC>_<k> is line k of
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

void rs_11_00_00_0(int a, long b, unsigned int c) {
	gps->l = -gla[0];
}
void rs_11_00_00_1(int a, long b, unsigned int c) {
	switch (gps->c) { case 0: b += 3L; break; case 1: gu2 -= c; break; case 2: vs(gps); break; case 3: gi ^= 4; break; case 4: v2(gi2, gi3); break; case 5: gla[a] -= 65536L; break; }
}
unsigned int rs_11_00_00_2(int a, long b, unsigned int c) {
	if (!guca[c]) return ru(gps->u);
}
void rs_11_00_00_3(int a, long b, unsigned int c) {
	if (gu != 0) c = c % gu;
}
unsigned int rs_11_00_00_4(int a, long b, unsigned int c) {
	return (gua[a] * 3) + ((unsigned int)gul);
}
void rs_11_00_01_0(void) {
	if (gla[2] == gl && gc & 0x8) if (gi3 != 0) gps->i = 256 % gi3;
}
void rs_11_00_01_1(void) {
	if (r2(gi3, gi)) { if (gca[5] != 0) gp[3] = gca[6] / gca[5]; gca[5] = (char)gu; if (gula[2] != 0) gula[5] = gula[4] % gula[2]; }
}
void rs_11_00_01_2(void) {
	gu++;
}
char * rs_11_00_01_3(void) {
	return rp();
}
void rs_11_00_02_1(void) {
	int t = gps->a[0] / 2;
	ji = t;
}
char rs_11_00_02_2(void) {
	if (*gpl != gl2) return gc2;
}
void rs_11_00_02_3(void) {
	if (*gp == gp[0]) { gps->c &= rc(255); }
}
void rs_11_00_02_4(void) {
	int t = ji;
	v0();
	gula[t] = gula[t] - 9UL;
}
void rs_11_00_02_5(void) {
	int i = ji;
	v0();
	i = 0; while (i < 10) { gua[i] = gu2 << 4; gi |= !gula[4]; i++; }
}
char rs_11_00_02_6(void) {
	return *gp;
}
void rs_11_00_03_0(void) {
	unsigned int t = gu2 >> 11;
	ju = t;
}
void rs_11_00_03_1(void) {
	unsigned char u = ~6;
	juc = u;
}
void rs_11_00_03_2(void) {
	unsigned char u = juc;
	guc = u;
}
void rs_11_00_03_3(void) {
	guc = ~guc;
}
void rs_11_00_03_4(void) {
	unsigned int t = ju;
	if (gu != 0) gu2 = t % gu;
}
void rs_11_00_03_5(void) {
	vs(gps);
}
void rs_11_00_03_6(void) {
	unsigned int t = ju;
	v0();
	if (guca[t] & 2) if (gl2 != 0) gl = 4L % gl2;
}
long rs_11_00_03_7(void) {
	unsigned int t = ju;
	v0();
	return gla[t] >> 11;
}
void rs_11_00_04_0(char *a, struct st *b, int c) {
	char t = a[c] / 10;
	jc = t;
}
void rs_11_00_04_1(char *a, struct st *b, int c) {
	unsigned long u = -5UL;
	jul = u;
}
void rs_11_00_04_2(char *a, struct st *b, int c) {
	char t = jc;
	unsigned long u = jul;
	if (gi & 2) { gca[1] = *gp - t; if (gula[2] != 0) u = u / gula[2]; ++u; }
}
void rs_11_00_04_3(char *a, struct st *b, int c) {
	while (c-- > 0) { if (*a == 8) break; a++; }
}
void rs_11_00_04_4(char *a, struct st *b, int c) {
	--gc2;
}
void rs_11_00_04_5(char *a, struct st *b, int c) {
	vp(gp + c);
}
void rs_11_00_04_6(char *a, struct st *b, int c) {
	v2(gi2 & gps->a[c], gi);
}
void rs_11_00_05_0(void) {
	double t = -0.25;
	jd = t;
}
void rs_11_00_05_1(void) {
	guca[1] = (unsigned char)!255;
}
void rs_11_00_05_2(void) {
	guc = (255 + guc) / 7;
}
void rs_11_00_05_3(void) {
	gul = gula[5] = (unsigned long)!(-guca[0]);
}
void rs_11_00_05_4(void) {
	gula[0] = gul = 0x10000UL;
}
void rs_11_00_05_5(void) {
	double t = jd;
	gd = t;
}
void rs_11_00_05_6(void) {
	gua[2] = ~gps->u >> 3;
}
char * rs_11_00_05_7(void) {
	return gps->p;
}
void rs_11_00_06_0(long *a, unsigned int b, int *c) {
	char t = -gc;
	jc = t;
}
void rs_11_00_06_1(long *a, unsigned int b, int *c) {
	vu((unsigned int)!a[7]);
}
void rs_11_00_06_2(long *a, unsigned int b, int *c) {
	b = gua[2] * 11;
}
void rs_11_00_06_3(long *a, unsigned int b, int *c) {
	b = gu2;
}
void rs_11_00_06_4(long *a, unsigned int b, int *c) {
	char t = jc;
	v0();
	vc(t);
}
void rs_11_00_06_5(long *a, unsigned int b, int *c) {
	v2(gi2, (gpi[3] & 0x8 ? gi2 : gia[b]));
}
int * rs_11_00_06_6(long *a, unsigned int b, int *c) {
	return gpi;
}
void rs_11_00_07_0(double a) {
	unsigned char t = guca[5];
	juc = t;
}
void rs_11_00_07_1(double a) {
	char *u = gs.p;
	jp = u;
}
void rs_11_00_07_2(double a) {
	unsigned char t = juc;
	char *u = jp;
	if (gi != 1) { if (gs.u != 0) gu = gu / gs.u; if (gu2 != 0) gu2 = gua[4] % gu2; } else { gc >>= 7; *u = (char)gula[t]; }
}
void rs_11_00_07_3(double a) {
	switch (gs.i) { case 0: gc = gc ^ gca[5]; case 1: gl2 &= -625L; break; case 2: vp(gs.p); case 3: v0(); break; case 4: vd(gs.d); break; }
}
unsigned int rs_11_00_07_4(double a) {
	if ('a' <= '9') return gu;
}
void rs_11_00_07_5(double a) {
	gd2 = gs.d;
}
void rs_11_00_07_6(double a) {
	gca[4] -= gc2;
}
unsigned int rs_11_00_07_7(double a) {
	return ((unsigned int)!gps->i) - (gu2 / 2);
}
void rs_11_00_08_1(int *a, long b, double c) {
	unsigned int t = gps->u - gua[5];
	ju = t;
}
void rs_11_00_08_2(int *a, long b, double c) {
	int i = ji;
	i = 10; do { gca[i] = 0 + gc; vl(b); } while (--i > 0);
}
void rs_11_00_08_3(int *a, long b, double c) {
	v2(gi2, 127 - gps->a[5]);
}
void rs_11_00_08_4(int *a, long b, double c) {
	unsigned int t = ju;
	v0();
	t <<= 6;
}
unsigned int rs_11_00_08_5(int *a, long b, double c) {
	return gps->u & ru(gua[1]);
}
void rs_11_00_09_1(unsigned long a, long b) {
	int i = ji;
	i = 7; do { if (gul != 0) a = a % gul; if (gs.u != 0) gu2 = gu / gs.u; } while (--i > 0);
}
void rs_11_00_09_2(unsigned long a, long b) {
	gul = 8UL;
}
char * rs_11_00_09_3(unsigned long a, long b) {
	return gs.p + 1;
}
void rs_11_00_10_0(long *a, double b, int *c) {
	char *t = &gca[2];
	jp = t;
}
void rs_11_00_10_1(long *a, double b, int *c) {
	int u = 256;
	ji = u;
}
void rs_11_00_10_2(long *a, double b, int *c) {
	char *t = jp;
	vp(t);
}
void rs_11_00_10_3(long *a, double b, int *c) {
	int u = ji;
	v0();
	if (gps->l) if (gula[u] != 0) gula[1] = gula[u] / gula[u];
}
void rs_11_00_10_4(long *a, double b, int *c) {
	int u = ji;
	v0();
	if (gua[u] > gps->u || 255 < 269) { gla[5] = gla[2] ^ gl; gi3 = ~r2(gi2, 256); vc((char)*a); } else { gul = (gula[6] ^ gul) - (0x10000UL - gul); gl %= 2L; gp[3] <<= 3; }
}
int * rs_11_00_10_5(long *a, double b, int *c) {
	return c;
}
void rs_11_00_11_0(int a, unsigned long b) {
	long t = gl2;
	jl = t;
}
void rs_11_00_11_1(int a, unsigned long b) {
	unsigned char u = ((unsigned char)gi2) ^ guca[4];
	juc = u;
}
void rs_11_00_11_2(int a, unsigned long b) {
	unsigned char u = juc;
	gi -= !gia[u];
}
void rs_11_00_11_3(int a, unsigned long b) {
	gu = gu2;
}
void rs_11_00_11_4(int a, unsigned long b) {
	long t = jl;
	vl(t);
}
void rs_11_00_11_5(int a, unsigned long b) {
	gp[0] = gca[4];
}
void rs_11_00_11_6(int a, unsigned long b) {
	unsigned char u = juc;
	v0();
	u %= 16;
}
char rs_11_00_11_7(int a, unsigned long b) {
	return gc;
}
void rs_11_00_12_1(struct st *a, unsigned char b, int *c) {
	char t = gps->c / 16;
	jc = t;
}
void rs_11_00_12_2(struct st *a, unsigned char b, int *c) {
	long u = gpl[2] * 8L;
	jl = u;
}
void rs_11_00_12_3(struct st *a, unsigned char b, int *c) {
	int i = ji;
	i = 16; do { vd(gs.d); } while (--i > 0);
}
void rs_11_00_12_4(struct st *a, unsigned char b, int *c) {
	char t = jc;
	v0();
	gc = t;
}
void rs_11_00_12_5(struct st *a, unsigned char b, int *c) {
	if (r0()) { vu(gu2); gs.p = gps->p; gl ^= rl(gl2); }
}
void rs_11_00_12_6(struct st *a, unsigned char b, int *c) {
	long u = jl;
	v0();
	gl = u;
}
void rs_11_00_12_7(struct st *a, unsigned char b, int *c) {
	gc2--;
}
char rs_11_00_12_8(struct st *a, unsigned char b, int *c) {
	char t = jc;
	v0();
	return gca[t];
}
void rs_11_00_13_0(unsigned long a) {
	unsigned char t = guca[0] * guc;
	juc = t;
}
void rs_11_00_13_1(unsigned long a) {
	unsigned char t = juc;
	v1(t);
}
void rs_11_00_13_2(unsigned long a) {
	gu = gu2 = gu2 + ((unsigned int)!gul);
}
void rs_11_00_13_3(unsigned long a) {
	gc2 |= gc2 * *gp;
}
void rs_11_00_13_4(unsigned long a) {
	vu(gs.u);
}
void rs_11_00_13_5(unsigned long a) {
	gl2 |= rl(gs.l);
}
char * rs_11_00_13_6(unsigned long a) {
	return gp;
}
void rs_11_00_14_0(long a, int b, char c) {
	guc++;
}
void rs_11_00_14_1(long a, int b, char c) {
	vp(gp);
}
unsigned int rs_11_00_14_2(long a, int b, char c) {
	return (unsigned int)!guca[7];
}
void rs_11_00_15_1(long a, unsigned long b) {
	unsigned long t = gula[3] + 0x10000UL;
	jul = t;
}
void rs_11_00_15_2(long a, unsigned long b) {
	int u = gi2;
	ji = u;
}
void rs_11_00_15_3(long a, unsigned long b) {
	gd = (2.5 / 2.5) / 1.0;
}
void rs_11_00_15_4(long a, unsigned long b) {
	gla[3] = gps->l + gs.l;
}
void rs_11_00_15_5(long a, unsigned long b) {
	int u = ji;
	gua[1] = ~gs.u;
}
void rs_11_00_15_6(long a, unsigned long b) {
	unsigned long t = jul;
	gul = t;
}
void rs_11_00_15_7(long a, unsigned long b) {
	if (gs.l != 0) gl2 = a % gs.l;
}
void rs_11_00_15_8(long a, unsigned long b) {
	int i = ji;
	for (i = 0; i < 12; i++) { vp(gp); gp--; gps->c = gc2 % 3; }
}
int rs_11_00_15_9(long a, unsigned long b) {
	return gi2;
}
void rs_11_00_16_0(void) {
	unsigned long t = 2UL - gul;
	jul = t;
}
void rs_11_00_16_1(void) {
	unsigned int u = gu2;
	ju = u;
}
void rs_11_00_16_2(void) {
	unsigned long t = jul;
	vl((long)t);
}
void rs_11_00_16_3(void) {
	unsigned int u = ju;
	v0();
	gul = (gul >> (u & 15)) + ((unsigned long)(((unsigned char)gs.c) < guca[0]));
}
void rs_11_00_16_4(void) {
	unsigned int u = ju;
	v0();
	gia[u] -= gs.a[5] & (int)guca[0];
}
void rs_11_00_16_5(void) {
	vs(gps);
}
unsigned long rs_11_00_16_6(void) {
	unsigned long t = jul;
	v0();
	return (gul = t);
}
void rs_11_00_17_0(long *a, unsigned long b) {
	++guc;
}
void rs_11_00_17_1(long *a, unsigned long b) {
	gp = &gca[1];
}
int * rs_11_00_17_2(long *a, unsigned long b) {
	if (r2(16, gi)) return rpi(gs.i);
}
int * rs_11_00_17_3(long *a, unsigned long b) {
	return gpi;
}
void rs_11_00_18_0(int a, int *b, char c) {
	unsigned char t = (unsigned char)gpl[0];
	juc = t;
}
void rs_11_00_18_1(int a, int *b, char c) {
	unsigned char t = juc;
	double u = (double)gla[t];
	jd = u;
}
void rs_11_00_18_2(int a, int *b, char c) {
	gpi = b;
}
void rs_11_00_18_3(int a, int *b, char c) {
	++gul;
}
void rs_11_00_18_4(int a, int *b, char c) {
	unsigned char t = juc;
	switch (gps->i) { case 0: gc -= (char)gl2; break; case 1: gl += -97905L; default: gla[t] = (gua[3] ? gl : (long)gu2); break; }
}
void rs_11_00_18_5(int a, int *b, char c) {
	double u = jd;
	gd = u;
}
void rs_11_00_18_6(int a, int *b, char c) {
	unsigned char t = juc;
	t = guc;
}
void rs_11_00_18_7(int a, int *b, char c) {
	vp(gp + c);
}
char rs_11_00_18_8(int a, int *b, char c) {
	double u = jd;
	v0();
	return (char)(((long)(gd2 >= u)) > 1L);
}
void rs_11_00_19_0(long a, unsigned int b) {
	gla[4] ^= a - 9L;
}
void rs_11_00_19_1(long a, unsigned int b) {
	if (gula[b]) { gu >>= 12; gla[b] >>= 18; ++b; }
}
void rs_11_00_19_2(long a, unsigned int b) {
	guc = ((unsigned char)((unsigned int)gi3)) | guca[4];
}
void rs_11_00_19_3(long a, unsigned int b) {
	gi3 = *gpi;
}
unsigned int rs_11_00_19_4(long a, unsigned int b) {
	return 255;
}
void rs_11_01_00_0(void) {
	gpl[1] |= gl;
}
void rs_11_01_00_1(void) {
	gi3 ^= ((double)gs.i != gs.d);
}
void rs_11_01_00_2(void) {
	*gp -= rc(gi3);
}
int rs_11_01_00_3(void) {
	if (guca[7]) return 1 & 255;
}
int rs_11_01_00_4(void) {
	return r0();
}
void rs_11_01_01_0(void) {
	unsigned long t = gul + gula[0];
	jul = t;
}
void rs_11_01_01_1(void) {
	guc &= (gua[0] > 32767 ? guca[5] : 128);
}
void rs_11_01_01_2(void) {
	--gu2;
}
void rs_11_01_01_3(void) {
	unsigned long t = jul;
	if (guca[5]) { gu ^= gps->u - 26682; gpl[3] = gl2 + 1L; if (gula[3] != 0) t = 0x10000UL / gula[3]; } else { gpi = &gia[0]; }
}
char rs_11_01_01_4(void) {
	return (gla[5] != gl ? (5 + gps->c) : (char)guc);
}
void rs_11_01_02_0(long *a, int b, long c) {
	gul += (unsigned long)(gi3 <= gi2);
}
void rs_11_01_02_1(long *a, int b, long c) {
	gd2 = 3.0;
}
void rs_11_01_02_2(long *a, int b, long c) {
	gc++;
}
int rs_11_01_02_3(long *a, int b, long c) {
	return 16;
}
void rs_11_01_03_1(void) {
	int t = gs.a[0];
	ji = t;
}
void rs_11_01_03_2(void) {
	int i = ji;
	if ((char)guca[1] >= (char)gl) gpi[3] = ~gps->i;
}
void rs_11_01_03_3(void) {
	int t = ji;
	if (gia[1] != 0) gps->a[t] = gia[1] % gia[1];
}
void rs_11_01_03_4(void) {
	int t = ji;
	guc |= guca[t] & 255;
}
void rs_11_01_03_5(void) {
	int i = ji;
	int t = ji;
	i = 0; while (i < 9) { gia[i] = t / 3; i++; }
}
unsigned long rs_11_01_03_6(void) {
	int t = ji;
	return gula[t];
}
void rs_11_01_04_0(long a) {
	long t = *gpl;
	jl = t;
}
void rs_11_01_04_1(long a) {
	int u = gs.a[5];
	ji = u;
}
void rs_11_01_04_2(long a) {
	gs.d = gd2;
}
void rs_11_01_04_3(long a) {
	int u = ji;
	if (gul != 0) gula[u] = gula[u] / gul;
}
void rs_11_01_04_4(long a) {
	long t = jl;
	gl = t;
}
void rs_11_01_04_5(long a) {
	int u = ji;
	gula[6] = 8UL >> (u & 15);
}
int rs_11_01_04_6(long a) {
	int u = ji;
	return (u & *gpi) >> (u & 15);
}
void rs_11_01_05_0(void) {
	int t = (int)41411UL;
	ji = t;
}
void rs_11_01_05_1(void) {
	char u = gps->c % 7;
	jc = u;
}
void rs_11_01_05_2(void) {
	char u = jc;
	if (gps->l == gl2) { vc(u + 0); }
}
void rs_11_01_05_3(void) {
	gc = (char)!(gl2 + 65536L);
}
void rs_11_01_05_4(void) {
	int t = ji;
	v0();
	if (gula[t] != 0) gul = ((unsigned long)gl2) / gula[t];
}
void rs_11_01_05_5(void) {
	char u = jc;
	v0();
	gpi = gpi + u;
}
unsigned long rs_11_01_05_6(void) {
	int t = ji;
	v0();
	return gula[t];
}
void rs_11_01_06_0(void) {
	while (gi > 0) { gi += *gpi++; gi--; }
}
void rs_11_01_06_1(void) {
	vc((char)!gua[5]);
}
unsigned int rs_11_01_06_2(void) {
	return gu2;
}
void rs_11_01_07_0(void) {
	gla[3] = 13905L;
}
void rs_11_01_07_1(void) {
	guc = (unsigned char)!(gps->u ^ gu2);
}
void rs_11_01_07_2(void) {
	if (gula[7]) gp = gp + 1;
}
unsigned int rs_11_01_07_3(void) {
	return gps->u % 2;
}
void rs_11_01_08_0(void) {
	char *t = gs.p;
	jp = t;
}
void rs_11_01_08_1(void) {
	vc(rc(gi));
}
void rs_11_01_08_2(void) {
	char *t = jp;
	v0();
	gp = t;
}
void rs_11_01_08_3(void) {
	gpi = gpi + 1;
}
char * rs_11_01_08_4(void) {
	return gs.p + 1;
}
void rs_11_01_09_0(double a, int b) {
	unsigned long t = gul;
	jul = t;
}
void rs_11_01_09_1(double a, int b) {
	int u = gi2 ^ (int)guca[3];
	ji = u;
}
void rs_11_01_09_2(double a, int b) {
	if (8L != gl) gla[1] = gps->l;
}
void rs_11_01_09_3(double a, int b) {
	if (gc == gps->c) gl2 = 15501L;
}
void rs_11_01_09_4(double a, int b) {
	unsigned long t = jul;
	--t;
}
void rs_11_01_09_5(double a, int b) {
	int u = ji;
	gi = u;
}
void rs_11_01_09_6(double a, int b) {
	gs.a[2] = ~2 | (127 * gs.i);
}
int rs_11_01_09_7(double a, int b) {
	int u = ji;
	return (u % 7) + (gi2 + (int)guc);
}
void rs_11_01_10_1(int a, char b, int c) {
	switch (gps->l) { case 2L: vp(gs.p); break; case 3L: vu(gu2); break; case 200L: vd(gs.d); }
}
char rs_11_01_10_2(int a, char b, int c) {
	if (gul & 2) return -'a';
}
void rs_11_01_10_3(int a, char b, int c) {
	gda[1] += gda[3] / 0.5;
}
void rs_11_01_10_4(int a, char b, int c) {
	gp = gp + c;
}
void rs_11_01_10_5(int a, char b, int c) {
	int i = ji;
	v0();
	for (i = 0; i < 6; i++) { gps->p = rp(); gula[i] ^= gula[i] << 8; }
}
char rs_11_01_10_6(int a, char b, int c) {
	return rc(gps->a[a]) / 2;
}
void rs_11_01_11_0(char *a, unsigned long b, struct st *c) {
	unsigned long t = gul + b;
	jul = t;
}
void rs_11_01_11_1(char *a, unsigned long b, struct st *c) {
	a[0] -= (char)gu;
}
void rs_11_01_11_2(char *a, unsigned long b, struct st *c) {
	unsigned long t = jul;
	if (b != 0) t = t / b;
}
void rs_11_01_11_3(char *a, unsigned long b, struct st *c) {
	gd2 = (3.0 + 3.0) / 0.25;
}
void rs_11_01_11_4(char *a, unsigned long b, struct st *c) {
	unsigned long t = jul;
	t = (!gps->c ? 5UL : b) * 8UL;
}
char rs_11_01_11_5(char *a, unsigned long b, struct st *c) {
	return (gca[7] = gc);
}
void rs_11_01_12_0(long *a) {
	int t = gps->a[3] | gps->a[2];
	ji = t;
}
void rs_11_01_12_1(long *a) {
	int u = gps->i + 100;
	ji = u;
}
void rs_11_01_12_2(long *a) {
	int t = ji;
	int u = ji;
	gia[t] = t & u;
}
void rs_11_01_12_3(long *a) {
	gl++;
}
void rs_11_01_12_4(long *a) {
	gia[1] |= 100;
}
void rs_11_01_13_0(unsigned long a, char b) {
	gs.d -= gda[3] + (double)gs.c;
}
void rs_11_01_13_1(unsigned long a, char b) {
	gi3 = (gl & 0x80 ? (gia[6] * *gpi) : (gi3 * 12));
}
void rs_11_01_13_2(unsigned long a, char b) {
	gp = gs.p + b;
}
int * rs_11_01_13_3(unsigned long a, char b) {
	return gpi;
}
void rs_11_01_14_1(int a, char b, char c) {
	vp(gs.p);
}
void rs_11_01_14_2(int a, char b, char c) {
	--a;
}
void rs_11_01_14_3(int a, char b, char c) {
	gp[0] *= 4;
}
void rs_11_01_14_4(int a, char b, char c) {
	gu = gu2 - (gs.u << 10);
}
void rs_11_01_14_5(int a, char b, char c) {
	int i = ji;
	v0();
	i = 8; do { gca[4] = ~b & 3; gi |= 255; } while (--i > 0);
}
long rs_11_01_14_6(int a, char b, char c) {
	return gl2;
}
void rs_11_01_15_0(long a, unsigned int b, int c) {
	int t = gps->a[b] * 10;
	ji = t;
}
void rs_11_01_15_1(long a, unsigned int b, int c) {
	int t = ji;
	int u = ~t;
	ji = u;
}
void rs_11_01_15_2(long a, unsigned int b, int c) {
	int t = ji;
	int u = ji;
	gia[u] = (t % 4) << 1;
}
void rs_11_01_15_3(long a, unsigned int b, int c) {
	int t = ji;
	int u = ji;
	if (t) gps->p = gps->p + u;
}
void rs_11_01_15_4(long a, unsigned int b, int c) {
	if (gla[1] >= (long)gps->c) { gul -= gula[c] + gul; gpi = &gia[0]; }
}
int rs_11_01_15_5(long a, unsigned int b, int c) {
	return gi3;
}
void rs_11_01_16_0(void) {
	unsigned int t = gua[1] << 3;
	ju = t;
}
void rs_11_01_16_1(void) {
	if (1 <= 23635) { gda[3] = 2.5 - gs.d; } else { gs.d = gd2; if (gi3 != 0) gi3 = gia[6] / gi3; vu(255 % 7); }
}
void rs_11_01_16_2(void) {
	unsigned int t = ju;
	v0();
	gu = t;
}
void rs_11_01_16_3(void) {
	guc = ~(guc | 3);
}
void rs_11_01_16_4(void) {
	gd2 *= gd2;
}
void rs_11_01_17_0(unsigned int a, int b) {
	if (gca[0] != gc) gi2 %= 16;
}
void rs_11_01_17_1(unsigned int a, int b) {
	a = gps->u + (gua[4] ^ 256);
}
long rs_11_01_17_2(unsigned int a, int b) {
	return (long)(gul >= (gul >> 5));
}
void rs_11_01_18_0(int a) {
	guca[2] = guca[a];
}
void rs_11_01_18_1(int a) {
	gl2 /= 7L;
}
void rs_11_01_18_2(int a) {
	gl = gs.l;
}
char * rs_11_01_18_3(int a) {
	return gs.p;
}
void rs_11_01_19_0(int a, unsigned int b) {
	char t = gca[0] + gc2;
	jc = t;
}
void rs_11_01_19_1(int a, unsigned int b) {
	char t = jc;
	t++;
}
void rs_11_01_19_2(int a, unsigned int b) {
	while (a-- > 0) { if (*gp == 69) break; gp++; }
}
void rs_11_01_19_3(int a, unsigned int b) {
	b -= gu & b;
}
int * rs_11_01_19_4(int a, unsigned int b) {
	return gpi;
}
void rs_11_02_00_0(char a) {
	gpi = &gia[7];
}
void rs_11_02_00_1(char a) {
	gp = gs.p + a;
}
void rs_11_02_00_2(char a) {
	if (7 > -85 && gua[a] < 256) v2(gi2, gi2);
}
void rs_11_02_00_3(char a) {
	gpi = rpi(gi3);
}
int rs_11_02_00_4(char a) {
	return !(~*gpl);
}
void rs_11_02_01_0(char a, double b) {
	int *t = gpi;
	jpi = t;
}
void rs_11_02_01_1(char a, double b) {
	int *t = jpi;
	gpi = t;
}
void rs_11_02_01_2(char a, double b) {
	while (gi-- > 0) { if (*gpi == 100) break; gpi++; }
}
void rs_11_02_01_3(char a, double b) {
	--gu;
}
void rs_11_02_01_4(char a, double b) {
	switch (gi) { case 8: guc = ~((unsigned char)gi); case 10: gul = rul(8UL); break; case 16: case 20: gs.c += gc; break; case 200: gla[a] |= (long)gua[a]; break; case 1000: gl ^= 65536L; break; default: vl(gps->l); break; }
}
int * rs_11_02_01_5(char a, double b) {
	return gpi;
}
void rs_11_02_02_0(int *a) {
	gda[0] = gd2 * 1.0;
}
void rs_11_02_02_1(int *a) {
	gula[6] |= -gula[7];
}
void rs_11_02_02_2(int *a) {
	gps->l -= gla[3];
}
int rs_11_02_02_3(int *a) {
	return (gi2 = gps->a[4]);
}
void rs_11_02_03_0(char a) {
	char *t = gs.p;
	jp = t;
}
void rs_11_02_03_1(char a) {
	guca[a] = guc = 128;
}
void rs_11_02_03_2(char a) {
	if (guc >= ((unsigned char)gia[5])) guc = -guc - ((unsigned char)(guca[0] >= guc));
}
void rs_11_02_03_3(char a) {
	gua[a] <<= (a & 15);
}
void rs_11_02_03_4(char a) {
	char *t = jp;
	t++;
}
int rs_11_02_03_5(char a) {
	return gi3;
}
void rs_11_02_04_0(void) {
	gd += -(double)gu;
}
void rs_11_02_04_1(void) {
	vd((gu2 > gua[3] ? gd : gd2));
}
void rs_11_02_04_2(void) {
	gl = gl2;
}
void rs_11_02_04_3(void) {
	gpi = &gia[6];
}
unsigned long rs_11_02_04_4(void) {
	return (gula[5] = 6UL);
}
void rs_11_02_05_0(unsigned int a, char *b, int c) {
	if (gua[a] > 29150) gp = rp();
}
void rs_11_02_05_1(unsigned int a, char *b, int c) {
	if (gc2 != 0) b[c] = gc2 / gc2;
}
void rs_11_02_05_2(unsigned int a, char *b, int c) {
	guc = 3;
}
void rs_11_02_05_3(unsigned int a, char *b, int c) {
	guca[7] /= 3;
}
int rs_11_02_05_4(unsigned int a, char *b, int c) {
	return gi2 >> 12;
}
void rs_11_02_06_0(struct st *a, unsigned char b) {
	long t = *gpl;
	jl = t;
}
int * rs_11_02_06_1(struct st *a, unsigned char b) {
	if (gla[1] <= *gpl) return gpi;
}
void rs_11_02_06_2(struct st *a, unsigned char b) {
	--gpi;
}
void rs_11_02_06_3(struct st *a, unsigned char b) {
	long t = jl;
	gl = t;
}
void rs_11_02_06_4(struct st *a, unsigned char b) {
	gpi = rpi((int)gu);
}
void rs_11_02_06_5(struct st *a, unsigned char b) {
	gu = (unsigned int)-0x10000UL;
}
int * rs_11_02_06_6(struct st *a, unsigned char b) {
	return gpi;
}
void rs_11_02_07_0(char a, long b) {
	if (2 <= 16) { if (gi != 0) *gpi = (int)gul % gi; if (gc2 != 0) gc = gc / gc2; a = gc2; }
}
void rs_11_02_07_1(char a, long b) {
	v0();
}
void rs_11_02_07_2(char a, long b) {
	gca[a] ^= gca[a] + gc2;
}
void rs_11_02_08_0(unsigned char a, unsigned long b, unsigned int c) {
	unsigned char t = a;
	juc = t;
}
void rs_11_02_08_1(unsigned char a, unsigned long b, unsigned int c) {
	double u = gda[0] * gs.d;
	jd = u;
}
void rs_11_02_08_2(unsigned char a, unsigned long b, unsigned int c) {
	unsigned char t = juc;
	++t;
}
void rs_11_02_08_3(unsigned char a, unsigned long b, unsigned int c) {
	if (gca[5] & 0x8 && c == 1) { if (gua[c] != 0) gu2 = gu2 % gua[c]; } else { vp(gps->p); v2(gi2, gi); }
}
void rs_11_02_08_4(unsigned char a, unsigned long b, unsigned int c) {
	gc2++;
}
void rs_11_02_08_5(unsigned char a, unsigned long b, unsigned int c) {
	a++;
}
void rs_11_02_08_6(unsigned char a, unsigned long b, unsigned int c) {
	double u = jd;
	v0();
	gd = u;
}
char rs_11_02_08_7(unsigned char a, unsigned long b, unsigned int c) {
	return rc(gi3) << (a & 7);
}
void rs_11_02_09_1(int a) {
	unsigned long t = rul(gula[4]);
	jul = t;
}
void rs_11_02_09_2(int a) {
	vu(ru(gu));
}
void rs_11_02_09_3(int a) {
	*gp = gc << 7;
}
void rs_11_02_09_4(int a) {
	guc = guca[5] = (unsigned char)gu;
}
void rs_11_02_09_5(int a) {
	int i = ji;
	v0();
	i = 0; while (i < 14) { gpi = &gia[i]; if (gl != 0) gl = gps->l / gl; i++; }
}
void rs_11_02_09_6(int a) {
	unsigned long t = jul;
	v0();
	gul = t;
}
int rs_11_02_09_7(int a) {
	return 16;
}
void rs_11_02_10_0(struct st *a) {
	unsigned char t = guc ^ ((unsigned char)gc);
	juc = t;
}
void rs_11_02_10_1(struct st *a) {
	unsigned char t = juc;
	v1(t);
}
void rs_11_02_10_2(struct st *a) {
	vs(a);
}
int rs_11_02_10_3(struct st *a) {
	if (gps->c) return 256 | 2;
}
int rs_11_02_10_4(struct st *a) {
	return gi3 >> 13;
}
void rs_11_02_11_0(double a, long b) {
	unsigned char t = guca[5] - 128;
	juc = t;
}
void rs_11_02_11_1(double a, long b) {
	unsigned char u = guca[4] >> 4;
	juc = u;
}
void rs_11_02_11_2(double a, long b) {
	unsigned char u = juc;
	if (gs.a[4] & 2) guca[2] = u = (unsigned char)gs.a[0];
}
void rs_11_02_11_3(double a, long b) {
	gpi[2] = gi3 - *gpi;
}
void rs_11_02_11_4(double a, long b) {
	gd2 = (double)gc2;
}
void rs_11_02_11_5(double a, long b) {
	unsigned char t = juc;
	guca[3] = t = ((unsigned char)256) - ((unsigned char)*gpl);
}
char * rs_11_02_11_6(double a, long b) {
	return rp();
}
void rs_11_02_12_0(unsigned long a) {
	unsigned long t = 7UL;
	jul = t;
}
void rs_11_02_12_1(unsigned long a) {
	long u = gps->l | gl;
	jl = u;
}
void rs_11_02_12_2(unsigned long a) {
	guca[6] = (unsigned char)!gu;
}
void rs_11_02_12_3(unsigned long a) {
	long u = jl;
	u--;
}
void rs_11_02_12_4(unsigned long a) {
	unsigned long t = jul;
	if (gs.c) { if (t != 0) a = t / t; if (gla[5] != 0) gps->l = gl2 % gla[5]; gp[1] >>= 7; }
}
void rs_11_02_13_0(struct st *a, long b) {
	char t = gc2 - gca[1];
	jc = t;
}
void rs_11_02_13_1(struct st *a, long b) {
	char t = jc;
	guca[t] = ((unsigned char)a->i) * 1;
}
void rs_11_02_13_2(struct st *a, long b) {
	gl2 = gl = b;
}
void rs_11_02_13_3(struct st *a, long b) {
	char t = jc;
	if (!gula[t] && gs.a[t] & 2) { guc ^= (unsigned char)gul; gul--; }
}
int rs_11_02_13_4(struct st *a, long b) {
	return 1;
}
void rs_11_02_14_0(int a, int b, int c) {
	char t = gca[a] >> 1;
	jc = t;
}
void rs_11_02_14_1(int a, int b, int c) {
	long u = ~gl;
	jl = u;
}
void rs_11_02_14_2(int a, int b, int c) {
	long u = jl;
	vl(u);
}
void rs_11_02_14_3(int a, int b, int c) {
	char t = jc;
	v0();
	--t;
}
char rs_11_02_14_4(int a, int b, int c) {
	char t = jc;
	v0();
	if (t > 52) return t - gc;
}
char rs_11_02_14_5(int a, int b, int c) {
	char t = jc;
	v0();
	return t;
}
void rs_11_02_15_0(struct st *a, char b, struct st *c) {
	unsigned long t = rul(gul);
	jul = t;
}
unsigned long rs_11_02_15_1(struct st *a, char b, struct st *c) {
	unsigned long t = jul;
	v0();
	if (r2(gi, gi)) return t + gula[b];
}
void rs_11_02_15_2(struct st *a, char b, struct st *c) {
	gia[b] = gi;
}
unsigned long rs_11_02_15_3(struct st *a, char b, struct st *c) {
	return -((unsigned long)b);
}
void rs_11_02_16_0(long *a, int b, char c) {
	int *t = gpi;
	jpi = t;
}
void rs_11_02_16_1(long *a, int b, char c) {
	int u = gpi[0] % 4;
	ji = u;
}
void rs_11_02_16_2(long *a, int b, char c) {
	int u = ji;
	u--;
}
void rs_11_02_16_3(long *a, int b, char c) {
	vp(gps->p);
}
void rs_11_02_16_4(long *a, int b, char c) {
	int *t = jpi;
	v0();
	v1(*t);
}
unsigned int rs_11_02_16_5(long *a, int b, char c) {
	int u = ji;
	v0();
	return gu & ru(gs.u);
}
void rs_11_02_17_1(unsigned int a) {
	int *t = gpi;
	jpi = t;
}
void rs_11_02_17_2(unsigned int a) {
	long u = gl - gps->l;
	jl = u;
}
void rs_11_02_17_3(unsigned int a) {
	gula[a] = rul(gul);
}
void rs_11_02_17_4(unsigned int a) {
	int i = ji;
	v0();
	i = 0; while (i < 11) { gda[3] -= gd2 - gda[3]; vp(gs.p); gu %= 2; i++; }
}
void rs_11_02_17_5(unsigned int a) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_11_02_17_6(unsigned int a) {
	int i = ji;
	long u = jl;
	v0();
	for (i = 4; i > 0; i--) { *gpl |= u * gl2; gul *= 9UL; if (gu != 0) gu2 = 20224 % gu; }
}
void rs_11_02_18_0(int *a, int b) {
	gi3 -= ~gpi[3];
}
void rs_11_02_18_1(int *a, int b) {
	guca[5] = 255;
}
void rs_11_02_18_2(int *a, int b) {
	guca[3] ^= guca[b] - guc;
}
void rs_11_02_18_3(int *a, int b) {
	gc++;
}
char * rs_11_02_18_4(int *a, int b) {
	return gp;
}
void rs_11_02_19_0(unsigned long a, char *b, char c) {
	double t = (guc != guca[0] ? gd : 10.0);
	jd = t;
}
void rs_11_02_19_1(unsigned long a, char *b, char c) {
	gca[0] = gc2 = c;
}
void rs_11_02_19_2(unsigned long a, char *b, char c) {
	gl2 %= 3L;
}
void rs_11_02_19_3(unsigned long a, char *b, char c) {
	guca[c] = guc = guc | (guc - 128);
}
void rs_11_02_19_4(unsigned long a, char *b, char c) {
	double t = jd;
	switch (gi) { case 5: t = 0.5 * t; case 8: gl2 = ~gl; break; case 20: v0(); break; case 100: guc /= 7; break; }
}
long rs_11_02_19_5(unsigned long a, char *b, char c) {
	if (gpl[0]) return rl(gps->l);
}
long rs_11_02_19_6(unsigned long a, char *b, char c) {
	return 5L;
}
void rs_11_03_00_0(unsigned long a, char b, int c) {
	int t = gps->i - gi3;
	ji = t;
}
void rs_11_03_00_1(unsigned long a, char b, int c) {
	int t = ji;
	v1(t);
}
void rs_11_03_00_2(unsigned long a, char b, int c) {
	if ((gl2 = gl)) vc(gc2);
}
void rs_11_03_00_3(unsigned long a, char b, int c) {
	gu2 += gu;
}
unsigned long rs_11_03_00_4(unsigned long a, char b, int c) {
	return gula[3] + (4UL + gul);
}
void rs_11_03_01_0(void) {
	unsigned char t = guca[2];
	juc = t;
}
void rs_11_03_01_1(void) {
	gc |= (*gpl > 65536L ? (' ') : gp[3]);
}
void rs_11_03_01_2(void) {
	if (gca[2] != 0) gs.c = gc / gca[2];
}
void rs_11_03_01_3(void) {
	unsigned char t = juc;
	v1(t);
}
int * rs_11_03_01_4(void) {
	unsigned char t = juc;
	v0();
	return gpi + t;
}
void rs_11_03_02_0(unsigned long a, unsigned long b, unsigned long c) {
	char *t = gps->p;
	jp = t;
}
void rs_11_03_02_1(unsigned long a, unsigned long b, unsigned long c) {
	char *t = jp;
	gp = t;
}
void rs_11_03_02_2(unsigned long a, unsigned long b, unsigned long c) {
	gd2 = gd;
}
void rs_11_03_02_3(unsigned long a, unsigned long b, unsigned long c) {
	if (r2(8, gi)) gua[3] = ((unsigned int)a) << 3;
}
void rs_11_03_02_4(unsigned long a, unsigned long b, unsigned long c) {
	b = a = gul;
}
void rs_11_03_02_5(unsigned long a, unsigned long b, unsigned long c) {
	c++;
}
void rs_11_03_02_6(unsigned long a, unsigned long b, unsigned long c) {
	vp(gs.p);
}
char * rs_11_03_02_7(unsigned long a, unsigned long b, unsigned long c) {
	char *t = jp;
	v0();
	return t;
}
void rs_11_03_03_0(int a, long *b) {
	gpi--;
}
void rs_11_03_03_1(int a, long *b) {
	guc >>= 6;
}
void rs_11_03_03_2(int a, long *b) {
	if (guca[6]) { if (gia[a] != 0) gi = gps->a[a] % gia[a]; }
}
void rs_11_03_03_3(int a, long *b) {
	gda[3] = gs.d;
}
int rs_11_03_03_4(int a, long *b) {
	return gi2;
}
void rs_11_03_04_1(long a) {
	int *t = gpi;
	jpi = t;
}
void rs_11_03_04_2(long a) {
	int *t = jpi;
	gpi = t;
}
void rs_11_03_04_3(long a) {
	gu2 <<= 6;
}
void rs_11_03_04_4(long a) {
	guca[1] = guc = (gu2 ? 7 : (guc % 4));
}
void rs_11_03_04_5(long a) {
	int i = ji;
	i = 8; do { guca[i] += 70; vc(gc); } while (--i > 0);
}
void rs_11_03_04_6(long a) {
	gu += ~32767;
}
void rs_11_03_04_7(long a) {
	gda[2] -= gd;
}
char rs_11_03_04_8(long a) {
	return gc;
}
void rs_11_03_05_1(unsigned int a, char b) {
	unsigned char t = guc >> 4;
	juc = t;
}
void rs_11_03_05_2(unsigned int a, char b) {
	unsigned char t = juc;
	unsigned int u = gua[t] + gua[a];
	ju = u;
}
void rs_11_03_05_3(unsigned int a, char b) {
	if (gpl[2] != 0) gs.l = gl2 / gpl[2];
}
void rs_11_03_05_4(unsigned int a, char b) {
	gula[a] = gul;
}
void rs_11_03_05_5(unsigned int a, char b) {
	int i = ji;
	unsigned char t = juc;
	for (i = 11; i > 0; i--) { ++t; gi3 = 100; gula[i] = 0x10000UL - gula[i]; }
}
void rs_11_03_05_6(unsigned int a, char b) {
	unsigned int u = ju;
	gu = u;
}
void rs_11_03_05_7(unsigned int a, char b) {
	gp = rp();
}
unsigned long rs_11_03_05_8(unsigned int a, char b) {
	return gul;
}
void rs_11_03_06_1(int a, unsigned long b) {
	int i = ji;
	i = 13; do { gs.u = (unsigned int)i; gc2 = gc; gs.u <<= 10; } while (--i > 0);
}
void rs_11_03_06_2(int a, unsigned long b) {
	b = 0UL;
}
void rs_11_03_06_3(int a, unsigned long b) {
	gl++;
}
void rs_11_03_06_4(int a, unsigned long b) {
	gca[a] = (char)!a;
}
void rs_11_03_06_5(int a, unsigned long b) {
	int i = ji;
	for (i = 16; i > 0; i--) { gi++; if (gula[2] != 0) gula[i] = gul / gula[2]; gpi = &gia[1]; }
}
int rs_11_03_06_6(int a, unsigned long b) {
	return !rc(a);
}
void rs_11_03_07_0(char a, long b) {
	int *t = gpi;
	jpi = t;
}
void rs_11_03_07_1(char a, long b) {
	unsigned long u = (unsigned long)gua[a];
	jul = u;
}
void rs_11_03_07_2(char a, long b) {
	v2(~8, gi);
}
void rs_11_03_07_3(char a, long b) {
	unsigned long u = jul;
	v0();
	gul = u;
}
void rs_11_03_07_4(char a, long b) {
	gca[a] *= 5;
}
void rs_11_03_07_5(char a, long b) {
	if (r0()) { gi = ((int)gps->l - 255) >> 12; }
}
void rs_11_03_07_6(char a, long b) {
	gia[6] = gi = gs.a[a];
}
void rs_11_03_07_7(char a, long b) {
	int *t = jpi;
	v0();
	gpi = t;
}
int rs_11_03_07_8(char a, long b) {
	int *t = jpi;
	v0();
	return t[3];
}
void rs_11_03_08_0(void) {
	gs.u /= 10;
}
void rs_11_03_08_1(void) {
	gla[7] %= 7L;
}
void rs_11_03_08_2(void) {
	vs(gps);
}
void rs_11_03_08_3(void) {
	guc = (guca[0] / 4) - (guca[1] - guc);
}
void rs_11_03_08_4(void) {
	gul = gula[7];
}
unsigned long rs_11_03_08_5(void) {
	return ~gula[6] - (gul - gula[1]);
}
void rs_11_03_09_1(void) {
	gs.l += *gpl - gl2;
}
void rs_11_03_09_2(void) {
	int i = ji;
	i = 6; do { if (gl != 0) gl2 = gps->l % gl; gpi = gpi + i; } while (--i > 0);
}
void rs_11_03_09_3(void) {
	if ((gps->l = gl)) { if (gula[5] != 0) gul = gul % gula[5]; gul = gula[7] = 0x10000UL; }
}
void rs_11_03_09_4(void) {
	while (gi-- > 0) { if (*gpi == 8) break; gpi++; }
}
void rs_11_03_09_5(void) {
	int i = ji;
	for (i = 3; i > 0; i--) { gua[i] = 7 / 7; gla[i] *= 2L; gu = -((unsigned int)!31168UL); }
}
unsigned int rs_11_03_09_6(void) {
	return ru(gua[2]) + (gu & 255);
}
void rs_11_03_10_0(int a) {
	gul++;
}
void rs_11_03_10_1(int a) {
	while (a > 0) { gc2 += *gp++; a--; }
}
void rs_11_03_10_2(int a) {
	if (*gpi != 0) gia[a] = a % *gpi;
}
void rs_11_03_10_3(int a) {
	vs(gps);
}
unsigned int rs_11_03_10_4(int a) {
	return gua[7] | (1 & gua[6]);
}
void rs_11_03_11_0(int a, int b) {
	if (gc2) { if (gps->u != 0) gu2 = gu % gps->u; } else { if (gca[a] != 0) *gp = gps->c / gca[a]; }
}
void rs_11_03_11_1(int a, int b) {
	if (4UL <= gul || !a) { if (gpl[0] != 0) gpl[2] = (long)gps->u % gpl[0]; gi2 %= 3; } else { gda[2] = -gs.d * (gd / 2.5); if (b != 0) a = 255 % b; }
}
void rs_11_03_11_2(int a, int b) {
	gd = (gs.d + 100.0) - gs.d;
}
void rs_11_03_11_3(int a, int b) {
	a = (gi ^ 100) % 10;
}
int rs_11_03_11_4(int a, int b) {
	return (gpi[0] = b);
}
void rs_11_03_12_0(struct st *a) {
	double t = gd2 + gd;
	jd = t;
}
void rs_11_03_12_1(struct st *a) {
	int u = 256 - (int)gul;
	ji = u;
}
void rs_11_03_12_2(struct st *a) {
	gu2--;
}
void rs_11_03_12_3(struct st *a) {
	double t = jd;
	gd = t;
}
void rs_11_03_12_4(struct st *a) {
	int u = ji;
	if (gu <= ((unsigned int)gla[4]) && gpl[1] < 65536L) { gul = (unsigned long)((gps->u + ((unsigned int)gl2)) != (gu2 % 10)); }
}
char * rs_11_03_12_5(struct st *a) {
	return rp();
}
void rs_11_03_13_1(int *a) {
	if ((gula[1] = 5UL) && gu2 & 0x7) { gl &= gps->l >> 11; gl2 += (long)(gps->u < ((unsigned int)gc)); if (gl2 != 0) gl = gl2 % gl2; }
}
void rs_11_03_13_2(int *a) {
	int i = ji;
	for (i = 16; i > 0; i--) { gc = gca[i] / 7; }
}
void rs_11_03_13_3(int *a) {
	v2(gi2, gi3);
}
void rs_11_03_13_4(int *a) {
	--guc;
}
void rs_11_03_13_5(int *a) {
	--gc;
}
int * rs_11_03_13_6(int *a) {
	return gpi + 1;
}
void rs_11_03_14_1(void) {
	unsigned long t = (gu2 < 256 ? gula[6] : gula[2]);
	jul = t;
}
void rs_11_03_14_2(void) {
	double u = gd2;
	jd = u;
}
void rs_11_03_14_3(void) {
	double u = jd;
	gda[3] = u * u;
}
void rs_11_03_14_4(void) {
	int i = ji;
	for (i = 2; i > 0; i--) { v0(); gs.l = (gs.l ^ gps->l) * 5L; }
}
void rs_11_03_14_5(void) {
	unsigned long t = jul;
	v0();
	gul = t;
}
void rs_11_03_14_6(void) {
	double u = jd;
	v0();
	gps->l = (long)((u * gd2) >= (gl2 > 4L ? 10.0 : gd2));
}
int rs_11_03_14_7(void) {
	int i = ji;
	v0();
	if (gp[3] > gca[3] && gi2) return gs.a[1] ^ gps->i;
}
void rs_11_03_14_8(void) {
	int i = ji;
	double u = jd;
	v0();
	if (gps->u <= gu) { vp(gps->p + 1); gps->i = -307 % 2; }
}
int rs_11_03_14_9(void) {
	return 16;
}
void rs_11_03_15_1(long *a, unsigned int b) {
	int *t = gpi;
	jpi = t;
}
void rs_11_03_15_2(long *a, unsigned int b) {
	int i = ji;
	int *t = jpi;
	for (i = 0; i < 15; i++) { gs.a[i] = t[3] - gi2; ++gul; if (gl != 0) gl2 = 65536L / gl; }
}
long rs_11_03_15_3(long *a, unsigned int b) {
	if (((unsigned char)gc) >= guca[3]) return gla[b];
}
void rs_11_03_15_4(long *a, unsigned int b) {
	gc2 <<= 5;
}
void rs_11_03_15_5(long *a, unsigned int b) {
	if (b != 0) gu2 = gua[b] % b;
}
void rs_11_03_15_6(long *a, unsigned int b) {
	if (b != 0) b = gps->u / b;
}
long rs_11_03_15_7(long *a, unsigned int b) {
	return 65536L;
}
void rs_11_03_16_0(int a) {
	int *t = &gia[0];
	jpi = t;
}
char rs_11_03_16_1(int a) {
	if (-18591L != (long)a) return *gp % 100;
}
void rs_11_03_16_2(int a) {
	int *t = jpi;
	v1(*t);
}
void rs_11_03_16_3(int a) {
	--gp;
}
void rs_11_03_16_4(int a) {
	guc = ((unsigned char)!255) % 3;
}
void rs_11_03_16_5(int a) {
	guca[a] = 128;
}
void rs_11_03_16_6(int a) {
	gla[a] = -gl;
}
char rs_11_03_16_7(int a) {
	return (char)(~gula[a] < ((unsigned long)gl));
}
void rs_11_03_17_0(unsigned int a, long *b, int c) {
	unsigned long t = gul ^ 0UL;
	jul = t;
}
void rs_11_03_17_1(unsigned int a, long *b, int c) {
	char *u = gs.p;
	jp = u;
}
void rs_11_03_17_2(unsigned int a, long *b, int c) {
	vs(gps);
}
void rs_11_03_17_3(unsigned int a, long *b, int c) {
	char *u = jp;
	v0();
	gp = u;
}
void rs_11_03_17_4(unsigned int a, long *b, int c) {
	unsigned long t = jul;
	v0();
	gul = t;
}
void rs_11_03_17_5(unsigned int a, long *b, int c) {
	while (c-- > 0) { if (*b == 65536L) break; b++; }
}
void rs_11_03_17_6(unsigned int a, long *b, int c) {
	guc -= guc | 255;
}
void rs_11_03_17_7(unsigned int a, long *b, int c) {
	guc -= (unsigned char)gps->l;
}
void rs_11_03_17_8(unsigned int a, long *b, int c) {
	++a;
}
unsigned long rs_11_03_17_9(unsigned int a, long *b, int c) {
	return gula[a];
}
void rs_11_03_18_0(int a, unsigned char b, long *c) {
	unsigned char t = 128 & guca[a];
	juc = t;
}
void rs_11_03_18_1(int a, unsigned char b, long *c) {
	unsigned long u = 80774UL ^ gula[5];
	jul = u;
}
void rs_11_03_18_2(int a, unsigned char b, long *c) {
	unsigned char t = juc;
	guc = t;
}
void rs_11_03_18_3(int a, unsigned char b, long *c) {
	unsigned long u = jul;
	vl((long)u);
}
void rs_11_03_18_4(int a, unsigned char b, long *c) {
	gc2 -= ~gps->c;
}
void rs_11_03_18_5(int a, unsigned char b, long *c) {
	vu(gu2 - 32767);
}
int rs_11_03_18_6(int a, unsigned char b, long *c) {
	return gs.a[0];
}
void rs_11_03_19_0(unsigned int a) {
	gs.l = gla[a] & gs.l;
}
unsigned int rs_11_03_19_1(unsigned int a) {
	if (gi2) return gu2 & gua[a];
}
unsigned int rs_11_03_19_2(unsigned int a) {
	return (gu = 7441);
}
void rs_11_04_00_0(unsigned char a) {
	unsigned char t = (unsigned char)gl2;
	juc = t;
}
void rs_11_04_00_1(unsigned char a) {
	int *u = gpi;
	jpi = u;
}
void rs_11_04_00_2(unsigned char a) {
	*gpl *= 8L;
}
void rs_11_04_00_3(unsigned char a) {
	unsigned char t = juc;
	int *u = jpi;
	gu2 = gu = gps->u >> (t & 15);
}
void rs_11_04_00_4(unsigned char a) {
	if (gu2 & 2 || (*gpi = gi)) { gp = rp(); gc = ~(gia[7] ? gc : 9); gps->l = gpl[1] = -(!gi ? 65536L : gps->l); }
}
char * rs_11_04_00_5(unsigned char a) {
	return gp;
}
void rs_11_04_01_0(void) {
	long t = gl;
	jl = t;
}
void rs_11_04_01_1(void) {
	long t = jl;
	switch (t) { case 0L: gda[3] *= (double)gca[7]; break; case 1L: gs.a[2] += gi2; break; case 2L: gd2 = (double)gpl[1] * gs.d; break; case 3L: v0(); break; case 4L: vd(gd); break; case 5L: gu2 = gps->u; break; }
}
void rs_11_04_01_2(void) {
	if (gps->u & 1) { gd2 *= gd2; if (gl != 0) gl = 57947L % gl; } else { if (gps->a[3] != 0) gi2 = 2 % gps->a[3]; }
}
void rs_11_04_01_3(void) {
	vp(rp());
}
void rs_11_04_01_4(void) {
	gs.p = gp + 1;
}
void rs_11_04_02_1(void) {
	unsigned char u = juc;
	unsigned int t = gua[0] + gps->u;
	ju = t;
}
void rs_11_04_02_2(void) {
	unsigned char u = 128;
	juc = u;
}
void rs_11_04_02_3(void) {
	gpi[2] = 255 & gi;
}
void rs_11_04_02_4(void) {
	int i = ji;
	unsigned int t = ju;
	i = 0; while (i < 2) { *gp = gc2 = 'a'; t = (unsigned int)gla[i]; i++; }
}
void rs_11_04_02_5(void) {
	unsigned char u = juc;
	guc = u << 5;
}
void rs_11_04_02_6(void) {
	unsigned char u = juc;
	if (gul != 0) gula[u] = gul % gul;
}
void rs_11_04_02_7(void) {
	vd(gda[1]);
}
char * rs_11_04_02_8(void) {
	return gp;
}
void rs_11_04_03_0(unsigned int a, int b) {
	unsigned int t = gua[1] << 4;
	ju = t;
}
void rs_11_04_03_1(unsigned int a, int b) {
	gl++;
}
void rs_11_04_03_2(unsigned int a, int b) {
	guc >>= 7;
}
void rs_11_04_03_3(unsigned int a, int b) {
	unsigned int t = ju;
	if (!gps->a[t]) gpi = gpi + a;
}
void rs_11_04_03_4(unsigned int a, int b) {
	unsigned int t = ju;
	guc -= (gs.a[5] == 2 ? guca[t] : guc);
}
void rs_11_04_03_5(unsigned int a, int b) {
	unsigned int t = ju;
	gua[3] = t * 7;
}
int rs_11_04_03_6(unsigned int a, int b) {
	return (gi = gia[6]);
}
void rs_11_04_04_0(int a, char b, char *c) {
	unsigned long t = 0x10000UL;
	jul = t;
}
void rs_11_04_04_1(int a, char b, char *c) {
	while (a-- > 0) *c++ = 47;
}
void rs_11_04_04_2(int a, char b, char *c) {
	if (gl2 != 0) gl2 = (long)gc2 % gl2;
}
void rs_11_04_04_3(int a, char b, char *c) {
	unsigned long t = jul;
	vl((long)t);
}
char * rs_11_04_04_4(int a, char b, char *c) {
	return gs.p + a;
}
void rs_11_04_05_0(long a, struct st *b) {
	unsigned int t = -gua[4];
	ju = t;
}
void rs_11_04_05_1(long a, struct st *b) {
	unsigned int t = ju;
	if (gc == *gp && 65536L == 3L) { if (t != 0) gua[2] = t / t; } else { gca[t] = ~(char)guc; gps->l = gl = *gpl; gula[1] += gul - 0x10000UL; }
}
void rs_11_04_05_2(long a, struct st *b) {
	gula[4] = gul = rul(gula[1]);
}
void rs_11_04_05_3(long a, struct st *b) {
	gi <<= 11;
}
void rs_11_04_05_4(long a, struct st *b) {
	gp--;
}
void rs_11_04_05_5(long a, struct st *b) {
	guca[7] %= 3;
}
unsigned long rs_11_04_05_6(long a, struct st *b) {
	return (gula[3] = gula[5]);
}
void rs_11_04_06_0(double a, int b, int *c) {
	int t = ~b;
	ji = t;
}
void rs_11_04_06_1(double a, int b, int *c) {
	int u = r1(4);
	ji = u;
}
void rs_11_04_06_2(double a, int b, int *c) {
	int u = ji;
	v0();
	gi = u;
}
void rs_11_04_06_3(double a, int b, int *c) {
	gpi = &gia[2];
}
void rs_11_04_06_4(double a, int b, int *c) {
	int t = ji;
	v0();
	gi = t;
}
void rs_11_04_06_5(double a, int b, int *c) {
	vl(gpl[2] >> 30);
}
int rs_11_04_06_6(double a, int b, int *c) {
	return -(*gpi & 2);
}
void rs_11_04_07_0(int a, char b) {
	vu(gu);
}
void rs_11_04_07_1(int a, char b) {
	if (gc2 != gca[4]) { gps->u -= gu2 - 19207; } else { gula[b] = ~gula[4]; v2(-gs.a[6], gi); if (gu2 != 0) gu = gu % gu2; }
}
void rs_11_04_07_2(int a, char b) {
	gpi = rpi(-gi2);
}
char * rs_11_04_07_3(int a, char b) {
	return gp + b;
}
void rs_11_04_08_0(void) {
	long t = rl(*gpl);
	jl = t;
}
void rs_11_04_08_1(void) {
	int *u = rpi(gia[4]);
	v0();
	jpi = u;
}
void rs_11_04_08_2(void) {
	int *u = jpi;
	v0();
	v1(*u);
}
void rs_11_04_08_3(void) {
	gi3 = gi2;
}
void rs_11_04_08_4(void) {
	long t = jl;
	v0();
	gl = t;
}
void rs_11_04_08_5(void) {
	gs.l = gl = (long)(gul >> 3);
}
unsigned int rs_11_04_08_6(void) {
	return gu;
}
void rs_11_04_09_0(void) {
	vl(gl);
}
void rs_11_04_09_1(void) {
	if (*gpl) gul = ((unsigned long)*gpi) * 10UL;
}
void rs_11_04_09_2(void) {
	gi = ((gi2 = gi) >= 785 ? gia[7] : r1(*gpi));
}
void rs_11_04_09_3(void) {
	gd2 -= gd / 3.0;
}
void rs_11_04_09_4(void) {
	gca[6] = 2 / 7;
}
int rs_11_04_09_5(void) {
	return *gpi << 9;
}
void rs_11_04_10_0(void) {
	unsigned char t = guca[2] - guca[3];
	juc = t;
}
void rs_11_04_10_1(void) {
	unsigned char t = juc;
	if (!gl) { t = guc; } else { t += 0; }
}
void rs_11_04_10_2(void) {
	vp(gp);
}
void rs_11_04_10_3(void) {
	gp = gs.p;
}
int * rs_11_04_10_4(void) {
	return gpi;
}
void rs_11_04_11_0(long a, unsigned int b) {
	++gl2;
}
void rs_11_04_11_1(long a, unsigned int b) {
	gs.u = gps->u | gu2;
}
void rs_11_04_12_0(unsigned int a, int b, char c) {
	int *t = rpi(gi2);
	jpi = t;
}
void rs_11_04_12_1(unsigned int a, int b, char c) {
	gl = ((long)(gu2 <= ((unsigned int)gpl[3]))) ^ gps->l;
}
void rs_11_04_12_2(unsigned int a, int b, char c) {
	gca[1] /= 2;
}
void rs_11_04_12_3(unsigned int a, int b, char c) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_11_04_12_4(unsigned int a, int b, char c) {
	gl = rl(*gpl << 28);
}
long rs_11_04_12_5(unsigned int a, int b, char c) {
	return -(*gpl << 7);
}
void rs_11_04_13_0(int a, int *b, unsigned char c) {
	int t = 2 * 2;
	ji = t;
}
void rs_11_04_13_1(int a, int *b, unsigned char c) {
	if (r1(1)) { if (gc != 0) gc2 = gca[c] % gc; vc(gc2 / 100); b = gpi; } else { vp(gp + a); guca[a] >>= 2; gpi = b; }
}
void rs_11_04_13_2(int a, int *b, unsigned char c) {
	int t = ji;
	v0();
	gi = t;
}
void rs_11_04_13_3(int a, int *b, unsigned char c) {
	++gul;
}
int rs_11_04_13_4(int a, int *b, unsigned char c) {
	return (gu2 < 255) & (int)237;
}
void rs_11_04_14_0(double a, int *b) {
	char t = gc;
	jc = t;
}
void rs_11_04_14_1(double a, int *b) {
	vp(gps->p);
}
void rs_11_04_14_2(double a, int *b) {
	char t = jc;
	v0();
	gc = t;
}
void rs_11_04_14_3(double a, int *b) {
	vd((double)gpi[3] / 3.0);
}
void rs_11_04_14_4(double a, int *b) {
	vp(rp());
}
void rs_11_04_14_5(double a, int *b) {
	guca[1] = 255 + guc;
}
int rs_11_04_14_6(double a, int *b) {
	return !(gul * 32875UL);
}
void rs_11_04_15_0(unsigned char a) {
	char *t = rp();
	jp = t;
}
void rs_11_04_15_1(unsigned char a) {
	int u = 1 - gi3;
	v0();
	ji = u;
}
void rs_11_04_15_2(unsigned char a) {
	char *t = jp;
	int u = ji;
	v0();
	if (gu2 != 28264) { t[0] *= 3; gps->l = gla[a] = 65536L; if (gua[u] != 0) gua[u] = gu2 / gua[u]; }
}
void rs_11_04_15_3(unsigned char a) {
	char *t = jp;
	int u = ji;
	v0();
	if (u != gi3) { *t = 7 + gp[2]; gu &= gu + gps->u; } else { gc2 = gc2 / 2; if (u != 0) gs.a[u] = gi % u; --gul; }
}
void rs_11_04_15_4(unsigned char a) {
	int u = ji;
	v0();
	switch (gi2) { case 1: gul >>= 14; break; case 3: gu = gs.u; break; case 8: gu2 ^= gps->u; break; case 100: gc2 = gca[7]; break; }
}
void rs_11_04_15_5(unsigned char a) {
	gp = rp();
}
unsigned int rs_11_04_15_6(unsigned char a) {
	return -gu | (gu - gu2);
}
void rs_11_04_16_0(int *a) {
	if (gula[2] >= gula[0]) { gula[5] -= gul * 0UL; gl = *gpl = rl(65536L | (long)gu); }
}
void rs_11_04_16_1(int *a) {
	gps->u = gs.u;
}
char rs_11_04_16_2(int *a) {
	return gps->c;
}
void rs_11_04_17_0(unsigned char a, char b) {
	guc++;
}
void rs_11_04_17_1(unsigned char a, char b) {
	gpi = &gia[6];
}
void rs_11_04_17_2(unsigned char a, char b) {
	if (a != 128) gpi = gpi + a;
}
void rs_11_04_17_3(unsigned char a, char b) {
	gs.p = gp + a;
}
char rs_11_04_17_4(unsigned char a, char b) {
	return (gc2 >> (a & 7)) - (gca[a] ^ gc2);
}
void rs_11_04_18_1(char *a) {
	switch (gc2) { case 0: case 1: guc += 150; break; }
}
void rs_11_04_18_2(char *a) {
	guc++;
}
void rs_11_04_18_3(char *a) {
	int i = ji;
	for (i = 8; i > 0; i--) { a[0] = gc2 >> 4; gc = gc2 = rc(*gpi) + ~a[1]; }
}
void rs_11_04_18_4(char *a) {
	if (gul != 0) gul = gula[7] / gul;
}
unsigned int rs_11_04_18_5(char *a) {
	return (gps->u = 256);
}
void rs_11_04_19_1(long *a, unsigned int b) {
	char *t = gp + b;
	jp = t;
}
void rs_11_04_19_2(long *a, unsigned int b) {
	int u = r2(gi2, gi);
	ji = u;
}
void rs_11_04_19_3(long *a, unsigned int b) {
	if (gps->c < 3 && gs.l > 6L) { ++gu2; gd2 = (guca[b] & 0x8 ? gd2 : gd2) / 100.0; }
}
void rs_11_04_19_4(long *a, unsigned int b) {
	char *t = jp;
	v0();
	gp = t;
}
void rs_11_04_19_5(long *a, unsigned int b) {
	while (gi-- > 0) *a++ = 58554L;
}
void rs_11_04_19_6(long *a, unsigned int b) {
	int i = ji;
	int u = ji;
	v0();
	for (i = 3; i > 0; i--) { if (gpl[0] != 0) a[i] = *a % gpl[0]; v0(); if (gs.u != 0) gs.u = gu2 % gs.u; }
}
unsigned long rs_11_04_19_7(long *a, unsigned int b) {
	return gula[b];
}
void rs_11_05_00_0(double a, long b, int c) {
	unsigned long t = gula[c];
	jul = t;
}
void rs_11_05_00_1(double a, long b, int c) {
	char u = gs.c - gc;
	jc = u;
}
void rs_11_05_00_2(double a, long b, int c) {
	char u = jc;
	if (*gp != gca[u]) { if (b != 0) *gpl = gps->l % b; }
}
void rs_11_05_00_3(double a, long b, int c) {
	gca[3] = (9 * *gp) / 100;
}
void rs_11_05_00_4(double a, long b, int c) {
	char u = jc;
	gca[0] &= gps->c << (u & 7);
}
void rs_11_05_00_5(double a, long b, int c) {
	unsigned long t = jul;
	if (t == gula[0]) { gpi[3] = c; gc = gc2; if (gl != 0) gpl[3] = b / gl; }
}
void rs_11_05_00_6(double a, long b, int c) {
	unsigned long t = jul;
	if (gu & 0x80) { t = rul(t - 29254UL); gp--; if (t != 0) t = 18577UL / t; } else { gul = (unsigned long)!*gpl; }
}
int rs_11_05_00_7(double a, long b, int c) {
	char u = jc;
	v0();
	return (u == gs.c) ^ (gi * 11);
}
void rs_11_05_01_0(char a, double b, unsigned char c) {
	char t = ~'z';
	jc = t;
}
void rs_11_05_01_1(char a, double b, unsigned char c) {
	gu = gu2 = 19902;
}
void rs_11_05_01_2(char a, double b, unsigned char c) {
	vs(gps);
}
void rs_11_05_01_3(char a, double b, unsigned char c) {
	gla[c] &= -78526L * (long)gula[a];
}
void rs_11_05_01_4(char a, double b, unsigned char c) {
	char t = jc;
	v0();
	gc = t;
}
char * rs_11_05_01_5(char a, double b, unsigned char c) {
	char t = jc;
	v0();
	return gp + t;
}
void rs_11_05_02_0(unsigned long a, unsigned char b) {
	int t = r2(gps->a[b], gi);
	ji = t;
}
void rs_11_05_02_1(unsigned long a, unsigned char b) {
	char *u = gps->p;
	v0();
	jp = u;
}
void rs_11_05_02_2(unsigned long a, unsigned char b) {
	char *u = jp;
	v0();
	vp(u);
}
void rs_11_05_02_3(unsigned long a, unsigned char b) {
	if (!gul) { guc = b = -255; }
}
void rs_11_05_02_4(unsigned long a, unsigned char b) {
	int t = ji;
	v0();
	if (t != 1 && gua[b] != 1) { if (gs.i != 0) gps->a[t] = t / gs.i; a = gul; }
}
void rs_11_05_02_5(unsigned long a, unsigned char b) {
	int t = ji;
	v0();
	if (gia[1]) { gca[t] *= 12; gs.l %= 7L; if (gl2 != 0) gla[4] = gl2 % gl2; }
}
int rs_11_05_02_6(unsigned long a, unsigned char b) {
	int t = ji;
	v0();
	return (t = gs.a[4]);
}
void rs_11_05_03_0(void) {
	v0();
}
void rs_11_05_03_1(void) {
	gi2 = gia[0];
}
void rs_11_05_03_2(void) {
	guc = guca[2];
}
void rs_11_05_03_3(void) {
	while (gi-- > 0) { if (*gp == '0') break; gp++; }
}
void rs_11_05_03_4(void) {
	gi = gpi[0];
}
int * rs_11_05_03_5(void) {
	return gpi + 1;
}
void rs_11_05_04_1(int *a) {
	char *t = gp;
	jp = t;
}
void rs_11_05_04_2(int *a) {
	char *t = jp;
	char *u = t;
	jp = u;
}
void rs_11_05_04_3(int *a) {
	int i = ji;
	char *u = jp;
	if (*u != gps->c) gps->i = gpi[0] | 1;
}
void rs_11_05_04_4(int *a) {
	int i = ji;
	char *u = jp;
	for (i = 0; i < 9; i++) { if (gu2 != 0) gps->u = 1 / gu2; }
}
void rs_11_05_04_5(int *a) {
	int i = ji;
	i = 0; while (i < 8) { gula[i] |= gula[i] % 4UL; if (gul != 0) gul = ((unsigned long)gua[5]) / gul; i++; }
}
void rs_11_05_04_6(int *a) {
	char *t = jp;
	vp(t);
}
void rs_11_05_04_7(int *a) {
	char *u = jp;
	v0();
	gd2 *= (gps->u >= gua[6] ? (double)gl2 : gd);
}
unsigned long rs_11_05_04_8(int *a) {
	return gul;
}
void rs_11_05_05_1(unsigned int a) {
	long t = gl + (long)gua[1];
	jl = t;
}
void rs_11_05_05_2(unsigned int a) {
	long u = gps->l;
	jl = u;
}
void rs_11_05_05_3(unsigned int a) {
	long t = jl;
	vl(t);
}
void rs_11_05_05_4(unsigned int a) {
	int i = ji;
	v0();
	i = 0; while (i < 7) { v2(gi2, gps->a[i]); gp[3] |= *gp; i++; }
}
void rs_11_05_05_5(unsigned int a) {
	int i = ji;
	v0();
	for (i = 13; i > 0; i--) { if (gca[i] != 0) gc = *gp / gca[i]; }
}
void rs_11_05_05_6(unsigned int a) {
	int i = ji;
	v0();
	for (i = 0; i < 5; i++) { gu2 /= 16; }
}
void rs_11_05_05_7(unsigned int a) {
	int i = ji;
	v0();
	gi3 = -gi3 * (gps->i % 100);
}
void rs_11_05_05_8(unsigned int a) {
	vp(&gca[a]);
}
void rs_11_05_05_9(unsigned int a) {
	long u = jl;
	v0();
	vl(u);
}
char rs_11_05_05_10(unsigned int a) {
	return (gs.c = '0');
}
void rs_11_05_06_0(int *a, unsigned char b) {
	gpl[2] &= ~gps->l;
}
void rs_11_05_06_1(int *a, unsigned char b) {
	if (!gp[1]) { if (gs.u != 0) gua[b] = 255 / gs.u; gia[7] = r0(); gu--; } else { vs(gps); }
}
void rs_11_05_06_2(int *a, unsigned char b) {
	gc2 = 'z' ^ rc(gi);
}
void rs_11_05_06_3(int *a, unsigned char b) {
	gula[3] += gul ^ 23723UL;
}
int * rs_11_05_06_4(int *a, unsigned char b) {
	return &gia[0];
}
void rs_11_05_07_1(long a, struct st *b, int c) {
	int t = gi;
	ji = t;
}
void rs_11_05_07_2(long a, struct st *b, int c) {
	double u = (!gi2 ? gd : gda[0]);
	jd = u;
}
long rs_11_05_07_3(long a, struct st *b, int c) {
	int t = ji;
	if (gula[t] != 0x10000UL && gua[t]) return 65536L;
}
void rs_11_05_07_4(long a, struct st *b, int c) {
	int i = ji;
	int t = ji;
	for (i = 0; i < c; i++) { if (gca[t] != 0) gp[3] = gc % gca[t]; gpi = gpi + i; }
}
void rs_11_05_07_5(long a, struct st *b, int c) {
	double u = jd;
	vd(u);
}
void rs_11_05_07_6(long a, struct st *b, int c) {
	while (c-- > 0) *gpi++ = 1;
}
long rs_11_05_07_7(long a, struct st *b, int c) {
	int t = ji;
	v0();
	return (-37039L % 7L) << (t & 15);
}
void rs_11_05_08_1(void) {
	char t = *gp & gc;
	jc = t;
}
void rs_11_05_08_2(void) {
	char t = jc;
	char *u = gs.p + t;
	jp = u;
}
void rs_11_05_08_3(void) {
	char *u = jp;
	guca[3] += (unsigned char)gps->u;
}
void rs_11_05_08_4(void) {
	guc = (unsigned char)(int)-29056L;
}
void rs_11_05_08_5(void) {
	int i = ji;
	char t = jc;
	i = 7; do { if (gc2 != 0) t = *gp % gc2; gla[2] = gl & gla[2]; } while (--i > 0);
}
void rs_11_05_08_6(void) {
	char t = jc;
	gula[t] -= gul;
}
void rs_11_05_08_7(void) {
	char t = jc;
	gs.a[t] = (!((unsigned long)gu2)) + gia[t];
}
int rs_11_05_08_8(void) {
	return r0();
}
void rs_11_05_09_0(char a, int b, unsigned long c) {
	if ((' ') != gc2) { ++a; } else { gul *= 7UL; }
}
void rs_11_05_09_1(char a, int b, unsigned long c) {
	gps->c >>= 1;
}
void rs_11_05_09_2(char a, int b, unsigned long c) {
	switch (gs.c) { case 0: guc = (gu >= gua[a] ? 255 : guca[b]); case 1: guc = (gla[4] == 18044L ? guca[a] : guca[b]); break; case 2: gl2 = gl & *gpl; break; case 3: gs.a[a] -= gia[7]; break; case 4: gu *= 3; break; }
}
int rs_11_05_09_3(char a, int b, unsigned long c) {
	return (-gps->u == (gu2 + 1));
}
void rs_11_05_10_0(void) {
	if (!*gpl || ((unsigned long)gla[2]) > gul) { vc('a'); guca[3] = guc; if (gula[1] != 0) gul = gula[3] % gula[1]; }
}
void rs_11_05_10_1(void) {
	if (gl2 < gs.l) gps->a[7] = -gi;
}
void rs_11_05_10_2(void) {
	gpi[0] = 911 << 2;
}
void rs_11_05_10_3(void) {
	*gpi = (gs.u == ru(gu2));
}
void rs_11_05_10_4(void) {
	*gpi = gi3 + gi;
}
int rs_11_05_10_5(void) {
	return gi3;
}
void rs_11_05_11_0(struct st *a, unsigned int b) {
	char *t = gp;
	jp = t;
}
void rs_11_05_11_1(struct st *a, unsigned int b) {
	switch (gc) { case 1: gl2 *= 9L; case 10: gul = 0x10000UL; break; }
}
void rs_11_05_11_2(struct st *a, unsigned int b) {
	gs.d += 2.5 / 100.0;
}
void rs_11_05_11_3(struct st *a, unsigned int b) {
	gula[b] = gul % 2UL;
}
void rs_11_05_11_4(struct st *a, unsigned int b) {
	char *t = jp;
	gp = t;
}
void rs_11_05_11_5(struct st *a, unsigned int b) {
	++guc;
}
void rs_11_05_11_6(struct st *a, unsigned int b) {
	guc += guc | guca[b];
}
unsigned long rs_11_05_11_7(struct st *a, unsigned int b) {
	char *t = jp;
	return (unsigned long)((*t << 5) < ((char)(80156UL > gula[2])));
}
void rs_11_05_12_0(char a, struct st *b, long c) {
	double t = (gua[a] & 1 ? gs.d : (double)gi3);
	jd = t;
}
void rs_11_05_12_1(char a, struct st *b, long c) {
	unsigned char u = (gla[a] ? 128 : guca[0]);
	juc = u;
}
void rs_11_05_12_2(char a, struct st *b, long c) {
	gc2 %= 16;
}
void rs_11_05_12_3(char a, struct st *b, long c) {
	while (gi-- > 0) *gpi++ = 256;
}
void rs_11_05_12_4(char a, struct st *b, long c) {
	unsigned char u = juc;
	v1(u);
}
void rs_11_05_12_5(char a, struct st *b, long c) {
	gu2 = gu + (gu - 1);
}
void rs_11_05_12_6(char a, struct st *b, long c) {
	double t = jd;
	v0();
	gd = t;
}
char rs_11_05_12_7(char a, struct st *b, long c) {
	unsigned char u = juc;
	v0();
	return rc(6) >> (u & 7);
}
void rs_11_05_13_0(char a) {
	double t = gda[1];
	jd = t;
}
void rs_11_05_13_1(char a) {
	gd = gs.d;
}
void rs_11_05_13_2(char a) {
	if (r1(gi)) gula[a] = 0x10000UL + gula[a];
}
void rs_11_05_13_3(char a) {
	double t = jd;
	v0();
	vd(t);
}
int * rs_11_05_13_4(char a) {
	if (r2(gi2, gi)) return gpi;
}
int * rs_11_05_13_5(char a) {
	return gpi + a;
}
void rs_11_05_14_0(void) {
	if (gia[1]) if (gi2 != 0) gi2 = gia[5] % gi2;
}
void rs_11_05_14_1(void) {
	gps->i >>= 15;
}
void rs_11_05_14_2(void) {
	gps->l &= gl;
}
void rs_11_05_14_3(void) {
	++guc;
}
void rs_11_05_14_4(void) {
	if (gc2 != 0) gca[4] = -95 / gc2;
}
int rs_11_05_14_5(void) {
	return ((int)gla[4] - gi3) | (gps->c < 'A' ? gs.a[4] : gps->i);
}
void rs_11_05_15_0(char a, int b, char c) {
	gd2 += ((gula[c] = ((unsigned long)gu)) >= 9UL ? gs.d : gd2);
}
void rs_11_05_15_1(char a, int b, char c) {
	if (*gp) { b = ~(gi3 * *gpi); gda[1] -= gda[3] - gs.d; vd(gd + 3.0); } else { guca[b] = ~(193 + guc); if (gia[b] != 0) b = gi3 % gia[b]; gpl[3] = rl(gla[c]); }
}
void rs_11_05_15_2(char a, int b, char c) {
	if (gla[1] < gla[c] || gs.d < 0.25) gla[4] = *gpl;
}
void rs_11_05_15_3(char a, int b, char c) {
	gp = gps->p + a;
}
int rs_11_05_15_4(char a, int b, char c) {
	return !(*gpi & 0x8 ? gca[3] : 98);
}
void rs_11_05_16_0(long a, double b, double c) {
	gs.l |= *gpl / 4L;
}
void rs_11_05_16_1(long a, double b, double c) {
	if (((unsigned long)guc) >= 0UL || guca[2] > 255) if (gl2 != 0) a = a / gl2;
}
void rs_11_05_16_2(long a, double b, double c) {
	gc2 = (gc2 & *gp) & (char)gs.l;
}
void rs_11_05_16_3(long a, double b, double c) {
	gps->a[3] = (gps->i << 3) / 3;
}
void rs_11_05_16_4(long a, double b, double c) {
	gc %= 7;
}
int * rs_11_05_16_5(long a, double b, double c) {
	return rpi(gs.i >> 12);
}
void rs_11_05_17_0(unsigned int a, long b, double c) {
	gla[0] = (((unsigned int)gi) == 1 ? (65536L % 10L) : (65536L & gpl[0]));
}
void rs_11_05_17_1(unsigned int a, long b, double c) {
	vp(rp());
}
int rs_11_05_17_2(unsigned int a, long b, double c) {
	return (gi3 * 100) ^ gia[5];
}
void rs_11_05_18_0(void) {
	int *t = &gia[4];
	jpi = t;
}
void rs_11_05_18_1(void) {
	int *t = jpi;
	int *u = t;
	jpi = u;
}
void rs_11_05_18_2(void) {
	if (gul == 0x10000UL) ++guc;
}
void rs_11_05_18_3(void) {
	int *u = jpi;
	if (9 <= guc) { gl &= (long)!((unsigned char)gl); } else { if (gia[5] != 0) u[1] = 127 % gia[5]; if (gu != 0) gs.u = gu2 / gu; gc = rc(gi) % 10; }
}
void rs_11_05_18_4(void) {
	gul = gula[3] = (gula[4] >> 3) * 9UL;
}
void rs_11_05_18_5(void) {
	v0();
}
void rs_11_05_18_6(void) {
	int *u = jpi;
	v0();
	gu2 = (((unsigned int)gla[0]) ^ 32767) & gs.u;
}
void rs_11_05_18_7(void) {
	int *t = jpi;
	v0();
	v1(*t);
}
int rs_11_05_18_8(void) {
	return (!(' ')) + *gpi;
}
void rs_11_05_19_0(void) {
	int t = -100;
	ji = t;
}
void rs_11_05_19_1(void) {
	int t = ji;
	guca[5] = ~(guca[t] / 7);
}
void rs_11_05_19_2(void) {
	guc <<= 5;
}
void rs_11_05_19_3(void) {
	gps->l = (long)((unsigned long)gps->c);
}
void rs_11_05_19_4(void) {
	int t = ji;
	if (0 < guc && gu2) gca[t] = gs.c % 100;
}
char rs_11_05_19_5(void) {
	int t = ji;
	return (gs.c = gca[t]);
}
void rs_11_06_00_0(void) {
	int *t = gpi;
	jpi = t;
}
void rs_11_06_00_1(void) {
	switch (gl2) { case 0L: gda[0] += 1.0; break; case 1L: guca[4] = guc = (unsigned char)gs.l; case 2L: gul *= 8UL; break; }
}
void rs_11_06_00_2(void) {
	gua[1] %= 10;
}
void rs_11_06_00_3(void) {
	gua[5] &= gu / 100;
}
void rs_11_06_00_4(void) {
	gd = -(gd / 2.5);
}
void rs_11_06_00_5(void) {
	int *t = jpi;
	gpi = t;
}
void rs_11_06_01_0(unsigned int a, char b) {
	int t = gps->a[3] % 4;
	ji = t;
}
void rs_11_06_01_1(unsigned int a, char b) {
	unsigned char u = 255 - 2;
	juc = u;
}
void rs_11_06_01_2(unsigned int a, char b) {
	if (gp[3]) { gs.l += gl2 % 100L; if (gpl[0] != 0) gl2 = *gpl % gpl[0]; gpi = rpi(gi2); }
}
void rs_11_06_01_3(unsigned int a, char b) {
	int t = ji;
	v0();
	vc((char)gla[t]);
}
void rs_11_06_01_4(unsigned int a, char b) {
	while (gi-- > 0) { if (*gp == ' ') break; gp++; }
}
void rs_11_06_01_5(unsigned int a, char b) {
	unsigned char u = juc;
	v0();
	gl2 &= gla[u];
}
void rs_11_06_01_6(unsigned int a, char b) {
	unsigned char u = juc;
	v0();
	u = guca[6] = ((unsigned char)(0.25 < gd)) >> 2;
}
int rs_11_06_01_7(unsigned int a, char b) {
	unsigned char u = juc;
	v0();
	return ((guca[7] | u) != u);
}
void rs_11_06_02_0(long *a) {
	double t = gs.d - (double)gs.c;
	jd = t;
}
void rs_11_06_02_1(long *a) {
	if (2UL <= 0x10000UL) gps->u = ((unsigned int)gula[6]) - gs.u;
}
void rs_11_06_02_2(long *a) {
	guc /= 16;
}
void rs_11_06_02_3(long *a) {
	double t = jd;
	gd = t;
}
void rs_11_06_02_4(long *a) {
	gul++;
}
void rs_11_06_02_5(long *a) {
	gul = (gul | 0x10000UL) + ((unsigned long)gl);
}
void rs_11_06_02_6(long *a) {
	vd(1.0);
}
char * rs_11_06_02_7(long *a) {
	return rp();
}
void rs_11_06_03_0(void) {
	unsigned long t = (unsigned long)!gia[0];
	jul = t;
}
void rs_11_06_03_1(void) {
	guc = guca[6] = 128;
}
void rs_11_06_03_2(void) {
	gla[0] += *gpl;
}
void rs_11_06_03_3(void) {
	gd *= gd2;
}
void rs_11_06_03_4(void) {
	unsigned long t = jul;
	vl((long)t);
}
long rs_11_06_03_5(void) {
	return gpl[1];
}
char rs_11_06_04_0(void) {
	if (guca[1]) return (char)(gia[2] == gi2);
}
void rs_11_06_04_1(void) {
	--gu2;
}
void rs_11_06_04_2(void) {
	gda[2] = -gda[3];
}
char rs_11_06_04_3(void) {
	return 7;
}
void rs_11_06_05_1(struct st *a, char b) {
	int t = gia[4] & (int)gula[b];
	ji = t;
}
void rs_11_06_05_2(struct st *a, char b) {
	int t = ji;
	gula[t] = gul = (gul * gul) & ~gul;
}
void rs_11_06_05_3(struct st *a, char b) {
	a->c = (r2(256, gi) ? gc2 : gc);
}
void rs_11_06_05_4(struct st *a, char b) {
	if (gps->u != 0) gu = gua[4] % gps->u;
}
void rs_11_06_05_5(struct st *a, char b) {
	int i = ji;
	int t = ji;
	v0();
	for (i = 15; i > 0; i--) { if (*gpi != 0) t = gpi[3] / *gpi; gps->a[i] = t - gi2; }
}
long rs_11_06_05_6(struct st *a, char b) {
	return ~65536L;
}
void rs_11_06_06_0(char a) {
	int t = 100 / 10;
	ji = t;
}
void rs_11_06_06_1(char a) {
	gps->c -= gc2 - gp[2];
}
void rs_11_06_06_2(char a) {
	int t = ji;
	vp(gps->p + t);
}
void rs_11_06_06_3(char a) {
	if (a) if (gs.c != 0) gp[3] = gps->c / gs.c;
}
void rs_11_06_06_4(char a) {
	gi = gpi[1];
}
unsigned long rs_11_06_06_5(char a) {
	return ((unsigned long)gi) * (gul + gula[a]);
}
void rs_11_06_07_0(void) {
	long t = (gps->l < 65536L ? gla[6] : gps->l);
	jl = t;
}
void rs_11_06_07_1(void) {
	double u = 2.5;
	jd = u;
}
void rs_11_06_07_2(void) {
	long t = jl;
	gl = t;
}
void rs_11_06_07_3(void) {
	gl--;
}
void rs_11_06_07_4(void) {
	double u = jd;
	u *= u / 0.25;
}
void rs_11_06_08_1(int *a, unsigned int b, int c) {
	double t = -gd2;
	jd = t;
}
void rs_11_06_08_2(int *a, unsigned int b, int c) {
	int u = gia[1];
	ji = u;
}
void rs_11_06_08_3(int *a, unsigned int b, int c) {
	int i = ji;
	for (i = 3; i > 0; i--) { gl2 = (gl2 & gs.l) << 9; if (gu != 0) gu = ((unsigned int)gla[i]) % gu; }
}
void rs_11_06_08_4(int *a, unsigned int b, int c) {
	vu(ru(gu2));
}
void rs_11_06_08_5(int *a, unsigned int b, int c) {
	int i = ji;
	double t = jd;
	v0();
	for (i = 0; i < 3; i++) { t -= gd2; }
}
void rs_11_06_08_6(int *a, unsigned int b, int c) {
	*gpl = rl(gl2) - ((long)(a[b] > 1));
}
void rs_11_06_08_7(int *a, unsigned int b, int c) {
	int i = ji;
	int u = ji;
	v0();
	i = c; do { if (*gpi != 0) gi3 = u % *gpi; } while (--i > 0);
}
char * rs_11_06_08_8(int *a, unsigned int b, int c) {
	return &gca[3];
}
void rs_11_06_09_1(int a, int b, unsigned int c) {
	a = gi;
}
void rs_11_06_09_2(int a, int b, unsigned int c) {
	gu2 = gu;
}
void rs_11_06_09_3(int a, int b, unsigned int c) {
	int i = ji;
	i = 0; while (i < a) { if (gc != 0) gc2 = 1 % gc; gs.d = -(256 > gs.u ? gd2 : gd2); i++; }
}
void rs_11_06_09_4(int a, int b, unsigned int c) {
	guca[2] = guca[3];
}
int * rs_11_06_09_5(int a, int b, unsigned int c) {
	return gpi;
}
void rs_11_06_10_1(unsigned int a, char b, int *c) {
	gu--;
}
void rs_11_06_10_2(unsigned int a, char b, int *c) {
	if (256 < 1) gca[b] = gc = 'A';
}
void rs_11_06_10_3(unsigned int a, char b, int *c) {
	int i = ji;
	for (i = 0; i < 13; i++) { a--; vs(gps); if (gi2 != 0) *gpi = 8 % gi2; }
}
void rs_11_06_10_4(unsigned int a, char b, int *c) {
	if ((gc = b) != 4) vl(gps->l);
}
void rs_11_06_10_5(unsigned int a, char b, int *c) {
	if (a) { guca[1] = guc; gla[4] = *gpl - gla[7]; *gp = *gp - gc; } else { gd2 *= 0.25 + (double)gs.u; }
}
void rs_11_06_11_0(unsigned int a, unsigned long b, unsigned char c) {
	gs.u = a + 23687;
}
void rs_11_06_11_1(unsigned int a, unsigned long b, unsigned char c) {
	vp(gps->p + a);
}
void rs_11_06_11_2(unsigned int a, unsigned long b, unsigned char c) {
	while (gi > 0) { gc2 += *gp++; gi--; }
}
unsigned long rs_11_06_11_3(unsigned int a, unsigned long b, unsigned char c) {
	return 5UL;
}
void rs_11_06_12_0(long a) {
	gia[0] = (int)gps->c + gi;
}
void rs_11_06_12_1(long a) {
	gul = rul(gul % 10UL);
}
void rs_11_06_12_2(long a) {
	if (!gp[3]) if (gula[2] != 0) gul = gul / gula[2];
}
void rs_11_06_12_3(long a) {
	gu2 = gu & (gua[0] * 5);
}
void rs_11_06_12_4(long a) {
	if (gps->u != 0) gu = gua[6] % gps->u;
}
long rs_11_06_12_5(long a) {
	return (gla[6] >> 31) & a;
}
void rs_11_06_13_0(void) {
	char t = (char)*gpl << 3;
	jc = t;
}
void rs_11_06_13_1(void) {
	char t = jc;
	if (gula[t] < gul) { gula[t] = gul / 10UL; }
}
void rs_11_06_13_2(void) {
	char t = jc;
	switch (gc2) { case 0: gu <<= 4; break; case 1: *gpi -= gs.a[t]; break; case 2: vu(gs.u); break; case 3: gul = gula[4] = 66464UL; case 4: case 5: gu2 += (unsigned int)guc; break; }
}
int rs_11_06_13_3(void) {
	if (gc & 2) return (gul == 76898UL);
}
void rs_11_06_13_4(void) {
	gpi = rpi(gi);
}
void rs_11_06_13_5(void) {
	gul--;
}
int rs_11_06_13_6(void) {
	return 127;
}
void rs_11_06_14_0(struct st *a, unsigned char b) {
	char u = jc;
	unsigned int t = gs.u;
	ju = t;
}
void rs_11_06_14_1(struct st *a, unsigned char b) {
	char u = 22;
	jc = u;
}
void rs_11_06_14_2(struct st *a, unsigned char b) {
	char u = jc;
	if (gla[u] != 0) gla[b] = gl / gla[u];
}
void rs_11_06_14_3(struct st *a, unsigned char b) {
	unsigned int t = ju;
	char u = jc;
	gc2 = *gp = (u - 27) << (t & 7);
}
void rs_11_06_14_4(struct st *a, unsigned char b) {
	guca[0] = (unsigned char)gi3;
}
unsigned long rs_11_06_14_5(struct st *a, unsigned char b) {
	return (gula[b] = gula[1]);
}
void rs_11_06_15_0(void) {
	gi = (!gs.c ? gi2 : 2);
}
void rs_11_06_15_1(void) {
	gia[5] = (gps->a[3] ? gia[2] : gps->a[4]) + -255;
}
void rs_11_06_15_2(void) {
	vd(-gd2);
}
void rs_11_06_15_3(void) {
	gpi = rpi(gi * gs.a[0]);
}
void rs_11_06_15_4(void) {
	if (gia[5] != 0) gs.i = gia[7] / gia[5];
}
int * rs_11_06_15_5(void) {
	return gpi + 1;
}
void rs_11_06_16_0(void) {
	unsigned long t = 1389UL >> 6;
	jul = t;
}
void rs_11_06_16_1(void) {
	unsigned int u = (unsigned int)!gi;
	ju = u;
}
void rs_11_06_16_2(void) {
	v0();
}
void rs_11_06_16_3(void) {
	unsigned int u = ju;
	v0();
	if (gs.a[u]) gpi = gpi + u;
}
void rs_11_06_16_4(void) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
void rs_11_06_16_5(void) {
	gl += gl2;
}
unsigned int rs_11_06_16_6(void) {
	return ((unsigned int)(0 != gca[6])) % 10;
}
void rs_11_06_17_0(unsigned long a, long b, int *c) {
	char t = gc2;
	jc = t;
}
void rs_11_06_17_1(unsigned long a, long b, int *c) {
	guc--;
}
void rs_11_06_17_2(unsigned long a, long b, int *c) {
	char t = jc;
	gula[t] = gul;
}
int rs_11_06_17_3(unsigned long a, long b, int *c) {
	return r0();
}
void rs_11_06_18_0(int a, struct st *b) {
	gps->c = gc;
}
void rs_11_06_18_1(int a, struct st *b) {
	gu2 = gu = ru(8) ^ (gu2 / 10);
}
void rs_11_06_18_2(int a, struct st *b) {
	vc(gp[3] >> 3);
}
int rs_11_06_18_3(int a, struct st *b) {
	return (16 & 255) + gi3;
}
void rs_11_06_19_0(int a, double b, int c) {
	gla[2] = gpl[0] >> 3;
}
void rs_11_06_19_1(int a, double b, int c) {
	gpl[1] = gps->l;
}
void rs_11_06_19_2(int a, double b, int c) {
	gc2--;
}
char * rs_11_06_19_3(int a, double b, int c) {
	return &gca[c];
}
void rs_11_07_00_0(void) {
	long t = gl;
	jl = t;
}
void rs_11_07_00_1(void) {
	int *u = gpi;
	jpi = u;
}
void rs_11_07_00_2(void) {
	long t = jl;
	if (((unsigned long)gl2) <= 30906UL) { gs.l = t; } else { gc2 = gc = gca[4]; }
}
void rs_11_07_00_3(void) {
	int *u = jpi;
	switch (gi3) { case 0: vc('z'); break; case 1: u = &gia[2]; break; }
}
void rs_11_07_00_4(void) {
	int *u = jpi;
	v0();
	gs.u = gua[7] = gu2;
}
unsigned long rs_11_07_00_5(void) {
	long t = jl;
	int *u = jpi;
	v0();
	if (gps->l < t && ((unsigned int)gpl[2]) == gs.u) return (unsigned long)gps->c;
}
unsigned long rs_11_07_00_6(void) {
	return gul;
}
void rs_11_07_01_1(void) {
	char *t = rp();
	jp = t;
}
void rs_11_07_01_2(void) {
	int i = ji;
	unsigned long u = gula[2] & ((unsigned long)gps->i);
	v0();
	jul = u;
}
void rs_11_07_01_3(void) {
	int i = ji;
	v0();
	if (gi2 != 0) gps->i = 3 % gi2;
}
void rs_11_07_01_4(void) {
	int i = ji;
	v0();
	for (i = 0; i < 9; i++) { guc = ((unsigned char)gs.a[6]) << (i & 7); gps->l = 65536L; }
}
void rs_11_07_01_5(void) {
	gpl[1] = *gpl % 100L;
}
void rs_11_07_01_6(void) {
	unsigned long u = jul;
	v0();
	gca[1] = (char)u / 3;
}
void rs_11_07_01_7(void) {
	unsigned long u = jul;
	v0();
	gu2 = gps->u = ru(gua[0]) << 8;
}
void rs_11_07_01_8(void) {
	char *t = jp;
	v0();
	gp = t;
}
int rs_11_07_01_9(void) {
	int i = ji;
	v0();
	return (gs.i = gia[6]);
}
void rs_11_07_02_0(unsigned char a, long *b) {
	if (gs.u != 0) gu2 = gs.u % gs.u;
}
void rs_11_07_02_1(unsigned char a, long *b) {
	gpi = &gia[0];
}
char * rs_11_07_02_2(unsigned char a, long *b) {
	return gp + a;
}
void rs_11_07_03_0(int a, unsigned char b, struct st *c) {
	int *t = &gia[6];
	jpi = t;
}
void rs_11_07_03_1(int a, unsigned char b, struct st *c) {
	guc = (unsigned char)(gc2 + gca[b]);
}
void rs_11_07_03_2(int a, unsigned char b, struct st *c) {
	gl2 -= *gpl;
}
void rs_11_07_03_3(int a, unsigned char b, struct st *c) {
	gca[4] = (gs.c | '9') << 1;
}
void rs_11_07_03_4(int a, unsigned char b, struct st *c) {
	gu--;
}
void rs_11_07_03_5(int a, unsigned char b, struct st *c) {
	int *t = jpi;
	gpi = t;
}
unsigned long rs_11_07_03_6(int a, unsigned char b, struct st *c) {
	return gula[a];
}
void rs_11_07_04_0(unsigned int a, struct st *b, double c) {
	gi += gia[2] * gi3;
}
void rs_11_07_04_1(unsigned int a, struct st *b, double c) {
	if (guc & 2) { ++gul; } else { if (gca[3] != 0) *gp = '9' % gca[3]; if (gca[a] != 0) gca[a] = 'a' / gca[a]; }
}
void rs_11_07_04_2(unsigned int a, struct st *b, double c) {
	guc = guca[4] = ((unsigned char)(gd != 0.5)) / 3;
}
void rs_11_07_04_3(unsigned int a, struct st *b, double c) {
	if (gca[7] != 0) gs.c = gc % gca[7];
}
void rs_11_07_04_4(unsigned int a, struct st *b, double c) {
	if (r0()) { gla[a] = *gpl + 2L; if (gula[a] != 0) gul = 0x10000UL % gula[a]; }
}
unsigned int rs_11_07_04_5(unsigned int a, struct st *b, double c) {
	return ((unsigned int)(gd > gs.d)) * 3;
}
void rs_11_07_05_0(char *a) {
	long t = (long)!gpl[1];
	jl = t;
}
void rs_11_07_05_1(char *a) {
	unsigned long u = (gs.l < 27439L ? gul : gula[1]);
	jul = u;
}
int rs_11_07_05_2(char *a) {
	long t = jl;
	if (t < 65536L || -50285L >= gl) return gs.i;
}
void rs_11_07_05_3(char *a) {
	++gc2;
}
void rs_11_07_05_4(char *a) {
	while (gi-- > 0) { if (*a == 'z') break; a++; }
}
void rs_11_07_05_5(char *a) {
	unsigned long u = jul;
	gua[7] -= (unsigned int)(6UL >= u);
}
void rs_11_07_05_6(char *a) {
	long t = jl;
	guca[6] = (unsigned char)((gps->a[2] > gs.i ? (double)gu : gd) <= -(double)t);
}
int rs_11_07_05_7(char *a) {
	return !*a;
}
void rs_11_07_06_0(int a, struct st *b, long c) {
	double t = -0.25;
	jd = t;
}
void rs_11_07_06_1(int a, struct st *b, long c) {
	if (gl <= gs.l) { gu2 = ru(gu2); }
}
void rs_11_07_06_2(int a, struct st *b, long c) {
	++gi2;
}
void rs_11_07_06_3(int a, struct st *b, long c) {
	gp[0] = gps->c;
}
void rs_11_07_06_4(int a, struct st *b, long c) {
	++gul;
}
void rs_11_07_06_5(int a, struct st *b, long c) {
	double t = jd;
	v0();
	gd = t;
}
char rs_11_07_06_6(int a, struct st *b, long c) {
	return (!gla[a] ? (gs.c + gca[4]) : ((gu = gps->u) > 23650 ? 4 : 76));
}
void rs_11_07_07_0(void) {
	unsigned char t = guca[0];
	juc = t;
}
void rs_11_07_07_1(void) {
	unsigned long u = gula[6];
	jul = u;
}
void rs_11_07_07_2(void) {
	gi--;
}
void rs_11_07_07_3(void) {
	unsigned long u = jul;
	u = gul = 7UL;
}
unsigned int rs_11_07_07_4(void) {
	unsigned char t = juc;
	unsigned long u = jul;
	if (u & 0x80 || t & 1) return gu % 2;
}
unsigned int rs_11_07_07_5(void) {
	return (unsigned int)!(int)8;
}
void rs_11_07_08_1(void) {
	char t = rc(255);
	jc = t;
}
void rs_11_07_08_2(void) {
	gu2 -= gu >> 12;
}
void rs_11_07_08_3(void) {
	char t = jc;
	v0();
	vc(t);
}
void rs_11_07_08_4(void) {
	int i = ji;
	v0();
	i = 0; while (i < 8) { gd2 += gd; gpi[2] = gs.a[i]; if (gu != 0) gua[i] = gu2 / gu; i++; }
}
int rs_11_07_08_5(void) {
	return gi2;
}
void rs_11_07_09_0(void) {
	long t = gps->l * 12L;
	jl = t;
}
void rs_11_07_09_1(void) {
	long t = jl;
	gl = t;
}
void rs_11_07_09_2(void) {
	*gp = gs.c;
}
void rs_11_07_09_3(void) {
	gc2 = *gp >> 3;
}
char * rs_11_07_09_4(void) {
	return gs.p;
}
void rs_11_07_10_1(void) {
	int t = 256 >> 15;
	ji = t;
}
void rs_11_07_10_2(void) {
	double u = gd2 + gd2;
	jd = u;
}
char rs_11_07_10_3(void) {
	int t = ji;
	if (gua[t] > gu) return 2 % 7;
}
void rs_11_07_10_4(void) {
	int i = ji;
	i = 0; while (i < 8) { if (gul != 0) gul = 77756UL % gul; i++; }
}
void rs_11_07_10_5(void) {
	vd(gd2);
}
void rs_11_07_10_6(void) {
	int t = ji;
	double u = jd;
	v0();
	gua[t] |= gs.u / 4;
}
void rs_11_07_10_7(void) {
	gc |= *gp * gc2;
}
char rs_11_07_10_8(void) {
	return gs.c;
}
void rs_11_07_11_0(void) {
	unsigned long t = 2UL & gula[3];
	jul = t;
}
void rs_11_07_11_1(void) {
	gp = rp();
}
void rs_11_07_11_2(void) {
	guca[0] = ~guca[3];
}
void rs_11_07_11_3(void) {
	gl2 *= 6L;
}
void rs_11_07_11_4(void) {
	unsigned long t = jul;
	v0();
	gul = t;
}
int rs_11_07_11_5(void) {
	return gps->i;
}
void rs_11_07_12_0(void) {
	int *t = rpi(gi);
	jpi = t;
}
void rs_11_07_12_1(void) {
	double u = gd * gs.d;
	v0();
	jd = u;
}
long rs_11_07_12_2(void) {
	if (gi3) return *gpl;
}
void rs_11_07_12_3(void) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_11_07_12_4(void) {
	v0();
}
void rs_11_07_12_5(void) {
	gul = (unsigned long)!(long)!gc2;
}
void rs_11_07_12_6(void) {
	if (gul != 0) gula[0] = gula[6] % gul;
}
void rs_11_07_12_7(void) {
	gps->i = ~(int)gl2 / 2;
}
void rs_11_07_12_8(void) {
	double u = jd;
	v0();
	vd(u);
}
long rs_11_07_12_9(void) {
	return (guca[1] != guc ? 65536L : gs.l) / 10L;
}
void rs_11_07_13_1(char a, unsigned int b) {
	char *t = rp();
	jp = t;
}
void rs_11_07_13_2(char a, unsigned int b) {
	unsigned long u = -gul;
	v0();
	jul = u;
}
void rs_11_07_13_3(char a, unsigned int b) {
	int i = ji;
	v0();
	i = 0; while (i < 6) { gua[i] = gua[i] - 0; if (gps->c != 0) gc2 = (char)gua[i] % gps->c; a++; i++; }
}
void rs_11_07_13_4(char a, unsigned int b) {
	if (gu != 0) gu = 255 / gu;
}
void rs_11_07_13_5(char a, unsigned int b) {
	int i = ji;
	v0();
	if (gs.i != 0) gi = gps->a[a] % gs.i;
}
void rs_11_07_13_6(char a, unsigned int b) {
	if (gs.c != 0) gs.c = gs.c / gs.c;
}
void rs_11_07_13_7(char a, unsigned int b) {
	int i = ji;
	unsigned long u = jul;
	v0();
	switch (gps->u) { case 0: guca[b] = guca[2]; case 1: gs.i += gps->a[0]; break; }
}
void rs_11_07_13_8(char a, unsigned int b) {
	char *t = jp;
	v0();
	vp(t);
}
unsigned int rs_11_07_13_9(char a, unsigned int b) {
	return -(gu2 & gua[a]);
}
void rs_11_07_14_0(unsigned int a, long *b) {
	vp(gp);
}
void rs_11_07_14_1(unsigned int a, long *b) {
	if (*b != 0) gl2 = *b % *b;
}
int rs_11_07_14_2(unsigned int a, long *b) {
	return gs.i | (gi + gps->i);
}
void rs_11_07_15_0(void) {
	long t = gl + *gpl;
	jl = t;
}
void rs_11_07_15_1(void) {
	long t = jl;
	vl(t);
}
void rs_11_07_15_2(void) {
	guc = guca[6];
}
void rs_11_07_15_3(void) {
	gpi = &gia[7];
}
void rs_11_07_15_4(void) {
	vp(rp());
}
void rs_11_07_15_5(void) {
	long t = jl;
	v0();
	t = (63561L + t) >> 4;
}
int rs_11_07_15_6(void) {
	return (gs.a[0] << 8) | (gs.a[1] ^ 1);
}
void rs_11_07_16_1(long a, int b) {
	unsigned char t = 128 % 7;
	juc = t;
}
void rs_11_07_16_2(long a, int b) {
	int i = ji;
	i = 7; do { gp = gs.p; } while (--i > 0);
}
void rs_11_07_16_3(long a, int b) {
	unsigned char t = juc;
	t = -guc;
}
void rs_11_07_17_0(long a, double b) {
	vs(gps);
}
void rs_11_07_17_1(long a, double b) {
	vu(gua[6]);
}
int * rs_11_07_17_2(long a, double b) {
	return gpi;
}
void rs_11_07_18_0(unsigned char a, long *b) {
	gd -= gda[3];
}
void rs_11_07_18_1(unsigned char a, long *b) {
	gl--;
}
char rs_11_07_18_2(unsigned char a, long *b) {
	return (char)gu / 100;
}
void rs_11_07_19_0(double a) {
	gi2 <<= 9;
}
void rs_11_07_19_1(double a) {
	if (gul & 4) { gc2--; v1(gpi[0]); }
}
void rs_11_07_19_2(double a) {
	guc = (r0() ? ((unsigned char)gia[1]) : (guca[1] / 100));
}
void rs_11_07_19_3(double a) {
	switch (gi) { case 2: gl = (long)256; case 5: gul = (gla[0] > gla[7] ? gula[1] : gula[2]); case 10: v2(gi2, *gpi); break; default: guc = guca[2] = 255 >> 2; break; }
}
void rs_11_07_19_4(double a) {
	gu = gu2 = gu & (gu2 | 1);
}
void rs_11_08_00_0(void) {
	gp++;
}
void rs_11_08_00_1(void) {
	++gu;
}
void rs_11_08_00_2(void) {
	gul = 0x10000UL;
}
int rs_11_08_00_3(void) {
	return (gps->i >> 3) << 15;
}
void rs_11_08_01_0(char a, unsigned char b) {
	gul++;
}
void rs_11_08_01_1(char a, unsigned char b) {
	if (1 != gc) { gul = 9UL - ((unsigned long)(gl2 != *gpl)); } else { gpi = &gia[b]; }
}
void rs_11_08_01_2(char a, unsigned char b) {
	if (gla[2] != 0) *gpl = gl / gla[2];
}
void rs_11_08_01_3(char a, unsigned char b) {
	b = ((unsigned char)100) - (b << 3);
}
void rs_11_08_01_4(char a, unsigned char b) {
	gl2 = (gla[1] << (b & 15)) << 17;
}
int rs_11_08_01_5(char a, unsigned char b) {
	return -gi2 + (int)gul;
}
void rs_11_08_02_0(int a, long *b, struct st *c) {
	int *t = gpi;
	jpi = t;
}
void rs_11_08_02_1(int a, long *b, struct st *c) {
	char *u = gp;
	jp = u;
}
void rs_11_08_02_2(int a, long *b, struct st *c) {
	char *u = jp;
	vp(u);
}
void rs_11_08_02_3(int a, long *b, struct st *c) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_11_08_02_4(int a, long *b, struct st *c) {
	gula[6] = 3UL - gula[7];
}
void rs_11_08_02_5(int a, long *b, struct st *c) {
	gs.d = (gd2 / 0.25) + (!guc ? gda[3] : gd2);
}
int rs_11_08_02_6(int a, long *b, struct st *c) {
	return r2(gs.a[a] + gi3, gi);
}
void rs_11_08_03_0(double a, int b) {
	vu((unsigned int)*gpl);
}
void rs_11_08_03_1(double a, int b) {
	switch (gu) { case 0: vd(100.0); break; case 1: case 2: vl(gla[b]); break; default: vp(gp + b); break; }
}
void rs_11_08_03_2(double a, int b) {
	guc = ((unsigned char)gua[b]) + guca[1];
}
int rs_11_08_03_3(double a, int b) {
	if (guca[b] & 4) return !gu2;
}
int rs_11_08_03_4(double a, int b) {
	return b;
}
void rs_11_08_04_0(long a, char b) {
	gps->i = !*gpi;
}
void rs_11_08_04_1(long a, char b) {
	gul = (unsigned long)gia[0];
}
void rs_11_08_04_2(long a, char b) {
	vu(gs.u - 29224);
}
void rs_11_08_04_3(long a, char b) {
	while (gi-- > 0) *gpi++ = 226;
}
void rs_11_08_04_4(long a, char b) {
	guc = ((unsigned char)!gps->a[4]) - (guca[2] / 10);
}
int rs_11_08_04_5(long a, char b) {
	return r0();
}
void rs_11_08_05_0(unsigned int a, char b, char c) {
	gla[b] = gs.l;
}
void rs_11_08_05_1(unsigned int a, char b, char c) {
	gi3 *= 10;
}
void rs_11_08_05_2(unsigned int a, char b, char c) {
	if (*gpi >= 100) gc <<= 4;
}
void rs_11_08_05_3(unsigned int a, char b, char c) {
	guca[c] = guc + 24;
}
void rs_11_08_05_4(unsigned int a, char b, char c) {
	if (gpi[1] != 0) gi2 = gi % gpi[1];
}
int rs_11_08_05_5(unsigned int a, char b, char c) {
	return (256 + gia[b]) + (gi2 / 7);
}
void rs_11_08_06_1(void) {
	unsigned char t = guca[2] % 4;
	juc = t;
}
void rs_11_08_06_2(void) {
	switch (gc2) { case 1: gul /= 2UL; break; case 20: gl = -gpl[3]; break; }
}
void rs_11_08_06_3(void) {
	int i = ji;
	for (i = 0; i < 3; i++) { if (i != 0) gia[i] = i % i; gp = gps->p; }
}
void rs_11_08_06_4(void) {
	unsigned char t = juc;
	v1(t);
}
char rs_11_08_06_5(void) {
	return '0';
}
void rs_11_08_07_1(char *a) {
	gula[3] = rul(6UL / 2UL);
}
void rs_11_08_07_2(char *a) {
	int i = ji;
	v0();
	for (i = 4; i > 0; i--) { gc &= rc(1); *a = a[i] | gca[i]; guca[i] = ~255; }
}
int * rs_11_08_07_3(char *a) {
	return gpi + 1;
}
void rs_11_08_08_0(void) {
	int t = ((guc = 4) != 53 ? gia[2] : gia[3]);
	ji = t;
}
void rs_11_08_08_1(void) {
	double u = 3.0;
	jd = u;
}
void rs_11_08_08_2(void) {
	double u = jd;
	vd(u);
}
void rs_11_08_08_3(void) {
	int t = ji;
	v0();
	gu2 = ~ru(gua[t]);
}
void rs_11_08_08_4(void) {
	int t = ji;
	v0();
	gula[t] = gul + 8UL;
}
int * rs_11_08_08_5(void) {
	int t = ji;
	double u = jd;
	v0();
	return rpi((int)gs.u + t);
}
void rs_11_08_09_1(char *a) {
	unsigned char t = guca[7] << 2;
	juc = t;
}
void rs_11_08_09_2(char *a) {
	gul = 54604UL;
}
void rs_11_08_09_3(char *a) {
	unsigned char t = juc;
	gla[t] = -0L;
}
void rs_11_08_09_4(char *a) {
	vl(gl - gl2);
}
void rs_11_08_09_5(char *a) {
	int i = ji;
	v0();
	for (i = 0; i < 16; i++) { gla[i] = (long)gul * 10L; }
}
void rs_11_08_09_6(char *a) {
	gs.u |= gu2 ^ gua[0];
}
unsigned long rs_11_08_09_7(char *a) {
	return rul(gul ^ 6UL);
}
void rs_11_08_10_0(int a, int b) {
	int t = a + gi3;
	ji = t;
}
void rs_11_08_10_1(int a, int b) {
	vu(256 % 2);
}
void rs_11_08_10_2(int a, int b) {
	int t = ji;
	v0();
	switch (t) { case 3: case 8: gu2 = gs.u / 16; break; case 100: gps->u = (gs.u ? 18946 : gps->u); break; case 1000: guc = -guc; break; default: vs(gps); break; }
}
void rs_11_08_10_3(int a, int b) {
	gl = gpl[1] - (65536L + gl2);
}
void rs_11_08_10_4(int a, int b) {
	++gi;
}
void rs_11_08_11_0(void) {
	int t = (int)guca[2];
	ji = t;
}
void rs_11_08_11_1(void) {
	double u = gda[3] * gd2;
	jd = u;
}
void rs_11_08_11_2(void) {
	double u = jd;
	gd = u;
}
void rs_11_08_11_3(void) {
	int t = ji;
	v1(t);
}
void rs_11_08_11_4(void) {
	--gp;
}
void rs_11_08_11_5(void) {
	if (((unsigned long)gi3) <= gul) { guc *= 9; gul = ((unsigned long)*gpl) - (0x10000UL % 100UL); gd += gda[2] / 1.0; }
}
int rs_11_08_11_6(void) {
	return *gpi;
}
void rs_11_08_12_1(void) {
	char t = gc;
	jc = t;
}
void rs_11_08_12_2(void) {
	unsigned int u = gs.u + gu2;
	ju = u;
}
void rs_11_08_12_3(void) {
	v1(gi3 - 2);
}
void rs_11_08_12_4(void) {
	char t = jc;
	v0();
	vc(t);
}
void rs_11_08_12_5(void) {
	unsigned int u = ju;
	v0();
	vu(u);
}
void rs_11_08_12_6(void) {
	int i = ji;
	v0();
	i = 13; do { gla[i] = ~*gpl; gi >>= 11; gu2 = gua[i]; } while (--i > 0);
}
char rs_11_08_12_7(void) {
	char t = jc;
	v0();
	return (gca[7] + gc) | (t ^ -8);
}
void rs_11_08_13_1(void) {
	double t = 1.0;
	jd = t;
}
void rs_11_08_13_2(void) {
	vs(gps);
}
void rs_11_08_13_3(void) {
	vl(rl(gla[0]));
}
void rs_11_08_13_4(void) {
	double t = jd;
	v0();
	t = -(100.0 * gs.d);
}
void rs_11_08_13_5(void) {
	int i = ji;
	v0();
	i = 0; while (i < 10) { if (gi3 != 0) gs.a[i] = gi3 % gi3; ++guc; if (gul != 0) gul = ((unsigned long)gu) % gul; i++; }
}
void rs_11_08_13_6(void) {
	gpi = &gia[6];
}
char * rs_11_08_13_7(void) {
	return rp();
}
void rs_11_08_14_1(int a, unsigned int b) {
	v0();
}
void rs_11_08_14_2(int a, unsigned int b) {
	gpi = rpi(a & 127);
}
void rs_11_08_14_3(int a, unsigned int b) {
	gc2 = gs.c = (gs.c & gc2) + gc;
}
void rs_11_08_14_4(int a, unsigned int b) {
	gpi = &gia[a];
}
void rs_11_08_14_5(int a, unsigned int b) {
	int i = ji;
	v0();
	i = a; do { gc = 22 % 3; } while (--i > 0);
}
int rs_11_08_14_6(int a, unsigned int b) {
	return ((gula[6] - gula[a]) == (gul + gula[6]));
}
void rs_11_08_15_0(void) {
	unsigned char t = guc;
	juc = t;
}
void rs_11_08_15_1(void) {
	unsigned char t = juc;
	int *u = rpi((int)t);
	jpi = u;
}
void rs_11_08_15_2(void) {
	int *u = jpi;
	v0();
	gpi = u;
}
void rs_11_08_15_3(void) {
	unsigned char t = juc;
	v0();
	t >>= 1;
}
void rs_11_08_15_4(void) {
	unsigned char t = juc;
	v0();
	guca[5] = (unsigned char)(t != 255);
}
int rs_11_08_15_5(void) {
	int *u = jpi;
	v0();
	return *u | gi2;
}
void rs_11_08_16_0(void) {
	v2(gi2, r1(-467));
}
void rs_11_08_16_1(void) {
	gi = (gi2 / 100) & gi;
}
char rs_11_08_16_2(void) {
	return ~('A' + (char)gps->i);
}
void rs_11_08_17_0(unsigned long a, unsigned char b) {
	long t = gl2 ^ 65536L;
	jl = t;
}
void rs_11_08_17_1(unsigned long a, unsigned char b) {
	long t = jl;
	unsigned int u = (unsigned int)(t > 6L);
	ju = u;
}
void rs_11_08_17_2(unsigned long a, unsigned char b) {
	gc++;
}
void rs_11_08_17_3(unsigned long a, unsigned char b) {
	vs(gps);
}
void rs_11_08_17_4(unsigned long a, unsigned char b) {
	long t = jl;
	v0();
	t = (gl2 & gl) >> 19;
}
void rs_11_08_17_5(unsigned long a, unsigned char b) {
	unsigned int u = ju;
	v0();
	vu(u);
}
char * rs_11_08_17_6(unsigned long a, unsigned char b) {
	return rp();
}
void rs_11_08_18_1(double a) {
	int i = ji;
	for (i = 0; i < 14; i++) { ++gl2; }
}
void rs_11_08_18_2(double a) {
	gu2 = 4 / 100;
}
void rs_11_08_18_3(double a) {
	gl = gps->l;
}
int rs_11_08_18_4(double a) {
	return gi3 >> 3;
}
void rs_11_08_19_0(void) {
	long t = gl2;
	jl = t;
}
void rs_11_08_19_1(void) {
	unsigned long u = gul % 3UL;
	jul = u;
}
void rs_11_08_19_2(void) {
	gpi = &gia[5];
}
void rs_11_08_19_3(void) {
	vp(gps->p);
}
void rs_11_08_19_4(void) {
	long t = jl;
	v0();
	gl = t;
}
void rs_11_08_19_5(void) {
	gc = 9;
}
void rs_11_08_19_6(void) {
	unsigned long u = jul;
	v0();
	vl((long)u);
}
char rs_11_08_19_7(void) {
	return ~((char)(1 < gc));
}
void rs_11_09_00_0(void) {
	int t = gia[6] + 692;
	ji = t;
}
void rs_11_09_00_1(void) {
	int t = ji;
	v1(t);
}
void rs_11_09_00_2(void) {
	if (gc2 != 0) gs.c = 1 / gc2;
}
void rs_11_09_00_3(void) {
	vu(gu);
}
long rs_11_09_00_4(void) {
	return (gps->l & (long)*gp) << 15;
}
void rs_11_09_01_0(void) {
	unsigned char t = 128 / 10;
	juc = t;
}
void rs_11_09_01_1(void) {
	double u = gd2;
	jd = u;
}
void rs_11_09_01_2(void) {
	unsigned char t = juc;
	gula[4] = gula[t];
}
void rs_11_09_01_3(void) {
	unsigned char t = juc;
	double u = jd;
	if (gs.u > gua[2]) { vl(gla[5] - gl); } else { gl ^= 65536L - gla[3]; gla[t] = *gpl; }
}
void rs_11_09_01_4(void) {
	gu2 <<= 8;
}
void rs_11_09_01_5(void) {
	unsigned char t = juc;
	double u = jd;
	v0();
	gula[3] = ((unsigned long)gps->u) << (t & 15);
}
char * rs_11_09_01_6(void) {
	unsigned char t = juc;
	v0();
	return gs.p + t;
}
void rs_11_09_02_0(struct st *a, unsigned int b) {
	int t = (gc2 & 0x7 ? (int)gu2 : *gpi);
	ji = t;
}
void rs_11_09_02_1(struct st *a, unsigned int b) {
	int t = ji;
	if (17730UL > 9772UL) { gd2 += gda[3]; vl(gl2); if (gul != 0) gul = gula[1] % gul; } else { a->a[t] = gpi[3]; a->a[b] = gpi[0] + gi2; }
}
void rs_11_09_02_2(struct st *a, unsigned int b) {
	vs(a);
}
void rs_11_09_02_3(struct st *a, unsigned int b) {
	gia[0] = gi2 >> 8;
}
void rs_11_09_02_4(struct st *a, unsigned int b) {
	gs.d = gd;
}
void rs_11_09_02_5(struct st *a, unsigned int b) {
	gd2 += (guca[b] > 6 ? gd : gs.d);
}
int rs_11_09_02_6(struct st *a, unsigned int b) {
	return (gua[b] ? gi3 : gpi[0]) + (16 + 127);
}
void rs_11_09_03_0(int a) {
	double t = gs.d;
	jd = t;
}
void rs_11_09_03_1(int a) {
	double t = jd;
	t += (double)gs.c;
}
void rs_11_09_03_2(int a) {
	if (gul & 4 && gl > gs.l) { if (gs.i != 0) gs.i = 256 / gs.i; if (*gpl != 0) gl2 = gla[a] % *gpl; } else { if (gs.u == 255 || *gp != gc) gi = 256; }
}
void rs_11_09_03_3(int a) {
	gpi++;
}
int rs_11_09_03_4(int a) {
	return gpi[2] + 127;
}
void rs_11_09_04_0(long a) {
	switch (gc2) { case 1: guca[0] *= 9; break; case 2: gs.l /= 16L; break; case 3: v0(); case 8: gs.l = *gpl = (long)guc ^ gla[7]; case 20: gula[0] = (unsigned long)128; break; case 100: gua[5] = 2 >> 7; break; }
}
void rs_11_09_04_1(long a) {
	gc2 = 4;
}
void rs_11_09_04_2(long a) {
	gc2 = (gp[3] ^ gs.c) * (gc2 + gc);
}
void rs_11_09_04_3(long a) {
	gc = rc(gs.a[6]) << 2;
}
void rs_11_09_04_4(long a) {
	gd = gd2;
}
void rs_11_09_05_0(unsigned char a) {
	vl(65536L << 31);
}
void rs_11_09_05_1(unsigned char a) {
	v1(gs.i / 4);
}
unsigned int rs_11_09_05_2(unsigned char a) {
	return (1 * gu2) / 16;
}
void rs_11_09_06_0(int *a) {
	double t = -gda[1];
	jd = t;
}
void rs_11_09_06_1(int *a) {
	if ((guc = guca[5]) == 255) if (gul != 0) gul = gul / gul;
}
void rs_11_09_06_2(int *a) {
	double t = jd;
	vd(t);
}
void rs_11_09_06_3(int *a) {
	while (gi-- > 0) { if (*a == 778) break; a++; }
}
void rs_11_09_07_0(unsigned char a, int b, unsigned long c) {
	if (gc < 8) gula[7] &= gul;
}
void rs_11_09_07_1(unsigned char a, int b, unsigned long c) {
	guc = a;
}
void rs_11_09_07_2(unsigned char a, int b, unsigned long c) {
	gl2 += rl(gla[a]);
}
void rs_11_09_07_3(unsigned char a, int b, unsigned long c) {
	gi3--;
}
void rs_11_09_07_4(unsigned char a, int b, unsigned long c) {
	if (gul == c) { guc = (65536L > gs.l ? guca[1] : a) | 186; gs.p = &gca[b]; if (gi3 != 0) *gpi = gia[a] / gi3; } else { b = gps->i = (gi2 - gps->a[3]) | gps->i; guca[a] -= guc; }
}
unsigned long rs_11_09_07_5(unsigned char a, int b, unsigned long c) {
	return rul((unsigned long)!b);
}
void rs_11_09_08_1(void) {
	int t = gs.a[2];
	ji = t;
}
void rs_11_09_08_2(void) {
	int t = ji;
	guc = guca[7] = guca[t];
}
void rs_11_09_08_3(void) {
	++gpi;
}
void rs_11_09_08_4(void) {
	++gp;
}
void rs_11_09_08_5(void) {
	int i = ji;
	for (i = 0; i < 6; i++) { ++gp; }
}
unsigned long rs_11_09_08_6(void) {
	int t = ji;
	return (gula[t] & gul) * 5UL;
}
void rs_11_09_09_0(unsigned char a, long b, unsigned int c) {
	if (gul != 0) gul = gula[a] / gul;
}
void rs_11_09_09_1(unsigned char a, long b, unsigned int c) {
	gia[3] = gps->i;
}
void rs_11_09_09_2(unsigned char a, long b, unsigned int c) {
	gpi[0] |= (int)gu - gs.a[4];
}
int rs_11_09_09_3(unsigned char a, long b, unsigned int c) {
	return r1(gi3 - gi2);
}
void rs_11_09_10_0(long *a, char b, unsigned long c) {
	switch (gi3) { case 1: vp(&gca[b]); case 2: guc = (unsigned char)gps->l; break; case 5: b *= 12; break; case 8: gpi = gpi + b; break; case 1000: vu(gua[b]); break; }
}
void rs_11_09_10_1(long *a, char b, unsigned long c) {
	if ((gu2 = gs.u) == 32767) if (*gpi != 0) gps->a[6] = gi % *gpi;
}
unsigned long rs_11_09_10_2(long *a, char b, unsigned long c) {
	return c;
}
void rs_11_09_11_0(char a, unsigned long b, long c) {
	gul /= 10UL;
}
void rs_11_09_11_1(char a, unsigned long b, long c) {
	guca[3] = guc;
}
void rs_11_09_11_2(char a, unsigned long b, long c) {
	gc2 = (a << 7) << (a & 7);
}
void rs_11_09_11_3(char a, unsigned long b, long c) {
	gpi = &gia[0];
}
char * rs_11_09_11_4(char a, unsigned long b, long c) {
	return gp;
}
void rs_11_09_12_0(void) {
	int t = (int)gps->c;
	ji = t;
}
void rs_11_09_12_1(void) {
	++gc2;
}
void rs_11_09_12_2(void) {
	++gp;
}
void rs_11_09_12_3(void) {
	int t = ji;
	v1(t);
}
unsigned long rs_11_09_12_4(void) {
	return (unsigned long)(~gu2 == ((unsigned int)65536L));
}
void rs_11_09_13_0(struct st *a) {
	double t = gd + 1.0;
	jd = t;
}
void rs_11_09_13_1(struct st *a) {
	int u = gia[0];
	ji = u;
}
void rs_11_09_13_2(struct st *a) {
	int u = ji;
	if (gu2 & 2) gs.u = (gu + 4) >> (u & 15);
}
void rs_11_09_13_3(struct st *a) {
	double t = jd;
	gd = t;
}
void rs_11_09_13_4(struct st *a) {
	if (gu2 <= 255) { vc((char)!gul); }
}
char rs_11_09_13_5(struct st *a) {
	return gp[3] * (gp[2] - gp[0]);
}
void rs_11_09_14_0(void) {
	vd(gs.d + gs.d);
}
void rs_11_09_14_1(void) {
	gps->p = gp;
}
long rs_11_09_14_2(void) {
	return (long)(gc2 | *gp);
}
void rs_11_09_15_0(void) {
	unsigned int t = 27006 << 6;
	ju = t;
}
void rs_11_09_15_1(void) {
	gs.d = (gs.d * (double)gpi[1]) - (gs.d + gd);
}
unsigned int rs_11_09_15_2(void) {
	if (gia[5] < gi) return gu / 10;
}
void rs_11_09_15_3(void) {
	unsigned int t = ju;
	gs.a[t] = -255;
}
void rs_11_09_15_4(void) {
	if ((gia[1] = gia[4]) <= 127) { v1(r2(gi2, *gpi)); if (gps->a[7] != 0) gpi[3] = gi3 / gps->a[7]; }
}
unsigned int rs_11_09_15_5(void) {
	unsigned int t = ju;
	v0();
	return t & (((unsigned int)gc) << 2);
}
void rs_11_09_16_1(char a, long *b) {
	long t = (r0() ? gl : *gpl);
	jl = t;
}
void rs_11_09_16_2(char a, long *b) {
	double u = gda[0] - gda[2];
	v0();
	jd = u;
}
void rs_11_09_16_3(char a, long *b) {
	if (gi3) { gu2--; } else { gc2++; }
}
void rs_11_09_16_4(char a, long *b) {
	int i = ji;
	double u = jd;
	v0();
	i = 9; do { *b = (gc >= 0 ? b[i] : 46140L); gs.d = u; } while (--i > 0);
}
void rs_11_09_16_5(char a, long *b) {
	gc2 -= gp[2] + gc2;
}
void rs_11_09_16_6(char a, long *b) {
	long t = jl;
	v0();
	t = gla[7];
}
void rs_11_09_16_7(char a, long *b) {
	gi = gpi[1] = *gpi - (gi3 - 1);
}
int rs_11_09_16_8(char a, long *b) {
	int i = ji;
	v0();
	return (gu == 255 && gul == 5UL ? (gps->i << 14) : gi);
}
void rs_11_09_17_0(char *a) {
	char t = gc;
	jc = t;
}
void rs_11_09_17_1(char *a) {
	char u = gc2;
	jc = u;
}
void rs_11_09_17_2(char *a) {
	char u = jc;
	gc = u;
}
void rs_11_09_17_3(char *a) {
	if (255 == 127) { v0(); }
}
void rs_11_09_17_4(char *a) {
	char t = jc;
	v0();
	gc = t;
}
void rs_11_09_17_5(char *a) {
	gula[7] %= 7UL;
}
char rs_11_09_17_6(char *a) {
	return gc2;
}
void rs_11_09_18_0(void) {
	if (gula[1] < gula[2]) gps->p = &gca[7];
}
void rs_11_09_18_1(void) {
	gd = (gda[1] / 10.0) / 3.0;
}
void rs_11_09_18_2(void) {
	if (gps->u != 0) gu2 = gu % gps->u;
}
void rs_11_09_18_3(void) {
	gia[7] |= !gps->i;
}
char rs_11_09_18_4(void) {
	return (gs.c - gps->c) & ((char)gu >> 7);
}
void rs_11_09_19_0(struct st *a) {
	gul--;
}
void rs_11_09_19_1(struct st *a) {
	gpi = &gia[1];
}
unsigned int rs_11_09_19_2(struct st *a) {
	return -gs.u - (1 ^ gu);
}
