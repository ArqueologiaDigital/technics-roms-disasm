/* Every statement line of random4 alone in its own function (gen_rstmt.py corpus/random4 4): rs_<A>_<BB>_<CC>_<k> is line k of
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

void rs_4_00_00_0(void) {
	char *t = &gca[5];
	jp = t;
}
void rs_4_00_00_1(void) {
	int *u = gpi;
	jpi = u;
}
void rs_4_00_00_2(void) {
	int *u = jpi;
	gs.u = ru(gu);
}
void rs_4_00_00_3(void) {
	gula[4] = gul | 0x10000UL;
}
void rs_4_00_00_4(void) {
	if (51 == gc2) { guc %= 10; }
}
int * rs_4_00_00_5(void) {
	if (guca[7] & 0x8) return &gia[6];
}
void rs_4_00_00_6(void) {
	char *t = jp;
	v0();
	vp(t);
}
int * rs_4_00_00_7(void) {
	return rpi(gpi[2] >> 14);
}
void rs_4_00_01_0(char a) {
	unsigned int t = -gua[a];
	ju = t;
}
void rs_4_00_01_1(char a) {
	if (a != gs.c) { --gpi; gula[a] <<= 26; if (gpi[0] != 0) gi2 = gps->a[7] / gpi[0]; } else { gl2 += gl2 | gl; gi3 = r2(gi2 & 16, gi); }
}
void rs_4_00_01_2(char a) {
	++guc;
}
void rs_4_00_01_3(char a) {
	unsigned int t = ju;
	v0();
	vu(t);
}
long rs_4_00_01_4(char a) {
	return gl2;
}
void rs_4_00_02_0(struct st *a, long *b, unsigned long c) {
	if (0x10000UL != 0x10000UL && gu2 != 256) ++gu2;
}
void rs_4_00_02_1(struct st *a, long *b, unsigned long c) {
	gul ^= 0x10000UL;
}
void rs_4_00_02_2(struct st *a, long *b, unsigned long c) {
	guca[4] = guc;
}
void rs_4_00_02_3(struct st *a, long *b, unsigned long c) {
	gc2 = gca[3] & (gc - *gp);
}
unsigned long rs_4_00_02_4(struct st *a, long *b, unsigned long c) {
	return (gul - 71157UL) + (gul - 0x10000UL);
}
void rs_4_00_03_0(int a) {
	gu = gua[a];
}
void rs_4_00_03_1(int a) {
	while (a-- > 0) { if (*gp == 'a') break; gp++; }
}
int * rs_4_00_03_2(int a) {
	return rpi(*gpi & gpi[2]);
}
void rs_4_00_04_1(long a, long b) {
	char t = (char)gu * gca[6];
	jc = t;
}
void rs_4_00_04_2(long a, long b) {
	char *u = rp();
	jp = u;
}
int rs_4_00_04_3(long a, long b) {
	if (gua[4]) return gi;
}
void rs_4_00_04_4(long a, long b) {
	char t = jc;
	v0();
	t += *gp;
}
void rs_4_00_04_5(long a, long b) {
	int i = ji;
	v0();
	i = 0; while (i < 3) { if (*gpl != 0) a = *gpl % *gpl; gd2 -= gda[2] - 10.0; i++; }
}
void rs_4_00_04_6(long a, long b) {
	char t = jc;
	v0();
	gpi = &gia[t];
}
void rs_4_00_04_7(long a, long b) {
	char *u = jp;
	v0();
	vp(u);
}
int rs_4_00_04_8(long a, long b) {
	char t = jc;
	v0();
	return (guca[2] > 2 ? (gi2 - gia[7]) : (100 << (t & 15)));
}
void rs_4_00_05_0(char *a) {
	unsigned int t = gu;
	ju = t;
}
void rs_4_00_05_1(char *a) {
	double u = gs.d / 1.0;
	jd = u;
}
void rs_4_00_05_2(char *a) {
	++gl;
}
char rs_4_00_05_3(char *a) {
	unsigned int t = ju;
	if (gca[t] > gc) return gca[t];
}
void rs_4_00_05_4(char *a) {
	double u = jd;
	gd = u;
}
void rs_4_00_05_5(char *a) {
	gi2 = (int)gul;
}
char rs_4_00_05_6(char *a) {
	return ~gs.c;
}
void rs_4_00_06_0(unsigned int a, unsigned int b) {
	char *t = gps->p;
	jp = t;
}
void rs_4_00_06_1(unsigned int a, unsigned int b) {
	int u = gps->a[b] % 10;
	ji = u;
}
void rs_4_00_06_2(unsigned int a, unsigned int b) {
	int u = ji;
	gi = u;
}
void rs_4_00_06_3(unsigned int a, unsigned int b) {
	char *t = jp;
	gca[5] = t[3];
}
void rs_4_00_06_4(unsigned int a, unsigned int b) {
	v2((int)234, gi);
}
void rs_4_00_06_5(unsigned int a, unsigned int b) {
	vl((long)gi2 / 4L);
}
void rs_4_00_07_1(struct st *a, char b) {
	char t = b;
	jc = t;
}
void rs_4_00_07_2(struct st *a, char b) {
	guc |= 128 / 10;
}
void rs_4_00_07_3(struct st *a, char b) {
	char t = jc;
	gc = t;
}
void rs_4_00_07_4(struct st *a, char b) {
	int i = ji;
	for (i = 0; i < 8; i++) { gs.a[i] %= 10; ++gi3; gpi = gpi + i; }
}
void rs_4_00_08_1(int a, unsigned long b) {
	int t = gi3;
	ji = t;
}
void rs_4_00_08_2(int a, unsigned long b) {
	int t = ji;
	v1(t);
}
void rs_4_00_08_3(int a, unsigned long b) {
	int i = ji;
	v0();
	for (i = 8; i > 0; i--) { gul = 0x10000UL + gula[i]; if (gua[i] != 0) gs.u = gu % gua[i]; }
}
void rs_4_00_08_4(int a, unsigned long b) {
	gia[1] = gi3 = (int)gl - r1(gia[6]);
}
unsigned int rs_4_00_08_5(int a, unsigned long b) {
	return gu2 ^ 255;
}
void rs_4_00_09_0(void) {
	unsigned char t = (unsigned char)gula[0];
	juc = t;
}
void rs_4_00_09_1(void) {
	gs.u = 1 + gu2;
}
void rs_4_00_09_2(void) {
	if (gs.l != 0) gs.l = gl % gs.l;
}
void rs_4_00_09_3(void) {
	unsigned char t = juc;
	v1(t);
}
void rs_4_00_09_4(void) {
	gi3--;
}
void rs_4_00_09_5(void) {
	gl2 = rl(rl(7L));
}
void rs_4_00_10_0(unsigned long a) {
	unsigned char t = ((unsigned char)gi) + guc;
	juc = t;
}
void rs_4_00_10_1(unsigned long a) {
	unsigned char u = 211;
	juc = u;
}
void rs_4_00_10_2(unsigned long a) {
	unsigned char t = juc;
	v1(t);
}
void rs_4_00_10_3(unsigned long a) {
	unsigned char u = juc;
	v0();
	v2(gi2, 256 * gs.a[u]);
}
void rs_4_00_10_4(unsigned long a) {
	unsigned char u = juc;
	v0();
	gc = (gc2 / 100) - (char)gia[u];
}
char * rs_4_00_10_5(unsigned long a) {
	return gp;
}
void rs_4_00_11_0(unsigned char a, double b) {
	long t = *gpl / 3L;
	jl = t;
}
void rs_4_00_11_1(unsigned char a, double b) {
	int u = 255;
	ji = u;
}
void rs_4_00_11_2(unsigned char a, double b) {
	vd(-gs.d);
}
void rs_4_00_11_3(unsigned char a, double b) {
	int u = ji;
	v0();
	switch (gi3) { case 1: gi %= 3; break; case 10: gs.c = (char)!guca[a]; break; default: gca[u] = gca[5] + (char)guc; break; }
}
void rs_4_00_11_4(unsigned char a, double b) {
	long t = jl;
	v0();
	vl(t);
}
void rs_4_00_11_5(unsigned char a, double b) {
	vc(gc);
}
void rs_4_00_11_6(unsigned char a, double b) {
	guc++;
}
long rs_4_00_11_7(unsigned char a, double b) {
	return (gps->l % 10L) ^ (gpl[0] | gl);
}
void rs_4_00_12_0(void) {
	char *t = gps->p;
	jp = t;
}
void rs_4_00_12_1(void) {
	gla[4] = 9L;
}
void rs_4_00_12_2(void) {
	char *t = jp;
	vp(t);
}
void rs_4_00_12_3(void) {
	while (gi > 0) { gc2 += *gp++; gi--; }
}
void rs_4_00_12_4(void) {
	gla[4] = (*gpl << 17) >> 10;
}
void rs_4_00_12_5(void) {
	gl = (long)-guca[2];
}
unsigned int rs_4_00_12_6(void) {
	return 22825;
}
void rs_4_00_13_0(void) {
	double t = -gd2;
	jd = t;
}
void rs_4_00_13_1(void) {
	gu = (unsigned int)gi2;
}
void rs_4_00_13_2(void) {
	double t = jd;
	vd(t);
}
void rs_4_00_13_3(void) {
	guc = ~(47 & guca[6]);
}
void rs_4_00_13_4(void) {
	if (*gpl & 4) *gpi = gps->i = ((*gp * gps->c) > (char)gs.u);
}
int rs_4_00_13_5(void) {
	return (8 ^ 16) << 11;
}
void rs_4_00_14_1(long a, int b) {
	double t = gd;
	jd = t;
}
void rs_4_00_14_2(long a, int b) {
	unsigned long u = (unsigned long)!gs.a[2];
	jul = u;
}
void rs_4_00_14_3(long a, int b) {
	int i = ji;
	for (i = 0; i < 4; i++) { if (gua[i] != 0) gua[i] = ((unsigned int)a) % gua[i]; }
}
void rs_4_00_14_4(long a, int b) {
	v1((r2((int)gca[b], gi) ? gi : b));
}
void rs_4_00_14_5(long a, int b) {
	gi -= gi3;
}
void rs_4_00_14_6(long a, int b) {
	unsigned long u = jul;
	v0();
	vl((long)u);
}
void rs_4_00_14_7(long a, int b) {
	gc--;
}
void rs_4_00_14_8(long a, int b) {
	double t = jd;
	v0();
	gd = t;
}
int * rs_4_00_14_9(long a, int b) {
	return rpi(-gpi[1]);
}
void rs_4_00_15_0(char *a, char *b, char *c) {
	gp[0] = ~gc - 1;
}
void rs_4_00_15_1(char *a, char *b, char *c) {
	gd = -(double)gc / 100.0;
}
void rs_4_00_15_2(char *a, char *b, char *c) {
	switch (gi2) { case 0: vc(gca[5]); break; case 1: gc2 = (char)gua[0]; break; case 2: guca[3] = guc; case 3: gpl[3] |= (long)gul; break; case 4: *b = gs.c & *b; break; }
}
char rs_4_00_15_3(char *a, char *b, char *c) {
	return -(char)guc;
}
void rs_4_00_16_0(unsigned long a, unsigned int b, char c) {
	unsigned char t = ~guca[c];
	juc = t;
}
void rs_4_00_16_1(unsigned long a, unsigned int b, char c) {
	unsigned int u = b + gu2;
	ju = u;
}
void rs_4_00_16_2(unsigned long a, unsigned int b, char c) {
	unsigned char t = juc;
	unsigned int u = ju;
	if (t) { gps->u = gu % 16; gpl[3] = (long)!t; if (gul != 0) gul = gul % gul; }
}
void rs_4_00_16_3(unsigned long a, unsigned int b, char c) {
	gua[0] = b;
}
void rs_4_00_16_4(unsigned long a, unsigned int b, char c) {
	gp = gps->p;
}
void rs_4_00_16_5(unsigned long a, unsigned int b, char c) {
	gps->p = &gca[c];
}
void rs_4_00_16_6(unsigned long a, unsigned int b, char c) {
	if (guc & 0x10 || gul != 0x10000UL) { gda[3] -= 3.0 + 3.0; if (gula[b] != 0) a = 0x10000UL / gula[b]; }
}
char * rs_4_00_16_7(unsigned long a, unsigned int b, char c) {
	return gp;
}
void rs_4_00_17_0(void) {
	unsigned char t = guca[6] << 2;
	juc = t;
}
void rs_4_00_17_1(void) {
	int u = gpi[2];
	ji = u;
}
void rs_4_00_17_2(void) {
	unsigned char t = juc;
	v1(t);
}
void rs_4_00_17_3(void) {
	int u = ji;
	v0();
	gi = u;
}
void rs_4_00_17_4(void) {
	vs(gps);
}
void rs_4_00_17_5(void) {
	if (234 >= guc) { gl -= gpl[0] / 7L; } else { vp(rp()); ++guc; }
}
void rs_4_00_18_1(int a, unsigned long b) {
	int i = ji;
	int t = (gc == gps->c ? 256 : gps->i);
	ji = t;
}
void rs_4_00_18_2(int a, unsigned long b) {
	vp(gs.p);
}
void rs_4_00_18_3(int a, unsigned long b) {
	gla[6] = (long)(*gpl != (gla[a] >> 16));
}
void rs_4_00_18_4(int a, unsigned long b) {
	int t = ji;
	v0();
	gp = &gca[t];
}
void rs_4_00_18_5(int a, unsigned long b) {
	int i = ji;
	v0();
	i = 0; while (i < 3) { if (gi != 0) gi3 = gps->i % gi; if (gl2 != 0) gl = gla[i] / gl2; i++; }
}
void rs_4_00_18_6(int a, unsigned long b) {
	++gul;
}
char rs_4_00_18_7(int a, unsigned long b) {
	int t = ji;
	v0();
	return (char)(gla[t] ^ (long)gula[t]);
}
void rs_4_00_19_0(unsigned char a, unsigned long b) {
	char t = gc;
	jc = t;
}
void rs_4_00_19_1(unsigned char a, unsigned long b) {
	long u = rl(gps->l);
	jl = u;
}
void rs_4_00_19_2(unsigned char a, unsigned long b) {
	vs(gps);
}
void rs_4_00_19_3(unsigned char a, unsigned long b) {
	v0();
}
void rs_4_00_19_4(unsigned char a, unsigned long b) {
	char t = jc;
	v0();
	vc(t);
}
void rs_4_00_19_5(unsigned char a, unsigned long b) {
	guc = a;
}
void rs_4_00_19_6(unsigned char a, unsigned long b) {
	gs.d = gda[2];
}
void rs_4_00_19_7(unsigned char a, unsigned long b) {
	long u = jl;
	v0();
	if (!u) if (gia[a] != 0) gi3 = 100 % gia[a];
}
char rs_4_00_19_8(unsigned char a, unsigned long b) {
	char t = jc;
	v0();
	return (char)((gul & 5UL) <= (9 <= t ? gul : ((unsigned long)gu2)));
}
void rs_4_01_00_0(char a, unsigned long b, int *c) {
	unsigned char t = (unsigned char)gl2;
	juc = t;
}
void rs_4_01_00_1(char a, unsigned long b, int *c) {
	int u = c[3] << 5;
	ji = u;
}
void rs_4_01_00_2(char a, unsigned long b, int *c) {
	gp = gps->p;
}
void rs_4_01_00_3(char a, unsigned long b, int *c) {
	unsigned char t = juc;
	v1(t);
}
void rs_4_01_00_4(char a, unsigned long b, int *c) {
	vs(gps);
}
void rs_4_01_00_5(char a, unsigned long b, int *c) {
	gps->l = *gpl = gl2;
}
void rs_4_01_00_6(char a, unsigned long b, int *c) {
	int u = ji;
	v0();
	v1(u);
}
long rs_4_01_00_7(char a, unsigned long b, int *c) {
	return rl((long)!247);
}
void rs_4_01_01_0(long a) {
	double t = (128 == 128 ? gs.d : gs.d);
	jd = t;
}
void rs_4_01_01_1(long a) {
	int *u = gpi;
	jpi = u;
}
void rs_4_01_01_2(long a) {
	double t = jd;
	vd(t);
}
void rs_4_01_01_3(long a) {
	if (r2(gi2, gi2) && gul) if (gula[2] != 0) gula[0] = gula[6] % gula[2];
}
void rs_4_01_01_4(long a) {
	int *u = jpi;
	v0();
	gu2 = gs.u;
}
int rs_4_01_01_5(long a) {
	return ((int)gu - (int)gula[7]) - (gca[5] <= gc);
}
void rs_4_01_02_0(unsigned long a, unsigned int b, unsigned long c) {
	while (gi-- > 0) *gpi++ = 8;
}
void rs_4_01_02_1(unsigned long a, unsigned int b, unsigned long c) {
	c = ('a' != gps->c ? gula[b] : a) | c;
}
void rs_4_01_02_2(unsigned long a, unsigned int b, unsigned long c) {
	gi++;
}
int * rs_4_01_02_3(unsigned long a, unsigned int b, unsigned long c) {
	return &gia[b];
}
void rs_4_01_03_0(struct st *a, long b) {
	int t = 16 ^ *gpi;
	ji = t;
}
void rs_4_01_03_1(struct st *a, long b) {
	gda[2] += (double)gps->u + gda[2];
}
void rs_4_01_03_2(struct st *a, long b) {
	int t = ji;
	if (4L != 2L) { t %= 10; gc2 = (gs.c - gc) + (gps->c % 2); guc = guca[5] = 113; }
}
void rs_4_01_03_3(struct st *a, long b) {
	int t = ji;
	b = gpl[1] = (gla[t] * (long)guca[t]) & (gps->l - 6L);
}
void rs_4_01_03_4(struct st *a, long b) {
	int t = ji;
	gca[t] = 3;
}
void rs_4_01_03_5(struct st *a, long b) {
	vd(gd - gd);
}
int rs_4_01_03_6(struct st *a, long b) {
	return gi2 % 3;
}
void rs_4_01_04_1(void) {
	unsigned int t = gu2 >> 3;
	ju = t;
}
void rs_4_01_04_2(void) {
	gd2 -= (double)gu2 - 2.5;
}
void rs_4_01_04_3(void) {
	int i = ji;
	i = 0; while (i < 4) { if (gc != 0) gps->c = gc % gc; if (gl2 != 0) gla[0] = gla[i] / gl2; i++; }
}
void rs_4_01_04_4(void) {
	gula[0] = gul / 3UL;
}
void rs_4_01_04_5(void) {
	unsigned int t = ju;
	t = ru(gs.u) / 2;
}
int rs_4_01_04_6(void) {
	return (gpi[2] = *gpi);
}
void rs_4_01_05_0(void) {
	unsigned char t = 2 >> 2;
	juc = t;
}
void rs_4_01_05_1(void) {
	unsigned char t = juc;
	int u = gi3 - gia[t];
	ji = u;
}
void rs_4_01_05_2(void) {
	unsigned char t = juc;
	v1(t);
}
void rs_4_01_05_3(void) {
	int u = ji;
	v0();
	v2(gi2, u);
}
void rs_4_01_05_4(void) {
	int u = ji;
	v0();
	switch (gps->c) { case 0: gpi = &gia[u]; break; case 1: case 2: gps->c = ~'a'; break; case 3: gu = 1; break; case 4: vl(gps->l); default: vu(gs.u); break; }
}
void rs_4_01_05_5(void) {
	vl((long)gua[3] & gla[2]);
}
int * rs_4_01_05_6(void) {
	return gpi;
}
void rs_4_01_06_1(int a, long *b) {
	if (r2(gi2, 1)) { if (gla[7] != 0) gl = *b / gla[7]; if (gps->u != 0) gu2 = gps->u % gps->u; --gi2; } else { a += 2; if (gul != 0) gul = gula[a] % gul; }
}
void rs_4_01_06_2(int a, long *b) {
	gp[0] -= gc;
}
void rs_4_01_06_3(int a, long *b) {
	int i = ji;
	v0();
	i = 4; do { gla[i] %= 16L; b[3] += 66003L + gla[i]; } while (--i > 0);
}
void rs_4_01_06_4(int a, long *b) {
	++gi2;
}
int rs_4_01_06_5(int a, long *b) {
	return gps->a[a] / 4;
}
void rs_4_01_07_0(unsigned long a, char *b) {
	char *t = &gca[4];
	jp = t;
}
void rs_4_01_07_1(unsigned long a, char *b) {
	guc -= ~guca[2];
}
void rs_4_01_07_2(unsigned long a, char *b) {
	vu(gu / 16);
}
void rs_4_01_07_3(unsigned long a, char *b) {
	v2(gi3, gi);
}
void rs_4_01_07_4(unsigned long a, char *b) {
	char *t = jp;
	v0();
	gp = t;
}
void rs_4_01_08_0(int a, unsigned int b) {
	switch (gc2) { case 0: gul = gul ^ 24517UL; break; case 1: vu(gua[1]); break; case 2: vs(gps); break; case 3: gula[6] = gul = gula[a] + gul; break; case 4: gul = gula[1] = ((unsigned long)gs.u) / 7UL; break; case 5: gl2 = *gpl + gpl[3]; break; default: v2(gpi[1], gi); break; }
}
void rs_4_01_08_1(int a, unsigned int b) {
	if (gps->a[b] <= gs.i) { vc(gc2 - 49); } else { guca[b] = 98; gi -= (int)guca[b]; }
}
int rs_4_01_08_2(int a, unsigned int b) {
	return (int)((unsigned char)(gps->c <= gp[1]));
}
void rs_4_01_09_0(long a, unsigned char b, char *c) {
	unsigned long t = ~gul;
	jul = t;
}
void rs_4_01_09_1(long a, unsigned char b, char *c) {
	long u = 6L << 26;
	jl = u;
}
void rs_4_01_09_2(long a, unsigned char b, char *c) {
	gs.c |= (char)!(int)b;
}
void rs_4_01_09_3(long a, unsigned char b, char *c) {
	long u = jl;
	vl(u);
}
void rs_4_01_09_4(long a, unsigned char b, char *c) {
	v2(gi2 % 4, gi);
}
void rs_4_01_09_5(long a, unsigned char b, char *c) {
	while (gi-- > 0) *c++ = 76;
}
void rs_4_01_09_6(long a, unsigned char b, char *c) {
	unsigned long t = jul;
	v0();
	gul = t;
}
void rs_4_01_09_7(long a, unsigned char b, char *c) {
	vd(gda[1] / 100.0);
}
void rs_4_01_09_8(long a, unsigned char b, char *c) {
	vc((char)(5UL < gula[b]));
}
char * rs_4_01_09_9(long a, unsigned char b, char *c) {
	return rp();
}
void rs_4_01_10_0(void) {
	while (gi-- > 0) *gp++ = '0';
}
void rs_4_01_10_1(void) {
	if (gi != 0) gia[5] = gpi[2] / gi;
}
void rs_4_01_10_2(void) {
	vd(-gda[0]);
}
void rs_4_01_10_3(void) {
	gu = ru(gs.u);
}
int rs_4_01_10_4(void) {
	return (*gpi | 16) + r0();
}
void rs_4_01_11_0(unsigned int a) {
	char *t = gs.p + a;
	jp = t;
}
void rs_4_01_11_1(unsigned int a) {
	char *t = jp;
	if (9L == gl && -66239L != 72776L) { if (gla[6] != 0) gla[a] = gl % gla[6]; } else { --gc; t = gs.p + a; gl2 = gl; }
}
void rs_4_01_11_2(unsigned int a) {
	gc2 ^= (' ') - *gp;
}
int rs_4_01_11_3(unsigned int a) {
	return (gia[a] - 2) >> 4;
}
void rs_4_01_12_1(void) {
	char t = rc(127);
	jc = t;
}
void rs_4_01_12_2(void) {
	char t = jc;
	unsigned int u = gua[t] & 13023;
	v0();
	ju = u;
}
void rs_4_01_12_3(void) {
	guc++;
}
void rs_4_01_12_4(void) {
	char t = jc;
	v0();
	vc(t);
}
void rs_4_01_12_5(void) {
	vu(((unsigned int)gc2) - gu);
}
void rs_4_01_12_6(void) {
	int i = ji;
	v0();
	gps->i = gi * gi3;
}
void rs_4_01_12_7(void) {
	int i = ji;
	v0();
	i = 7; do { if (gia[i] != 0) *gpi = 8 % gia[i]; gps->l = gl; } while (--i > 0);
}
void rs_4_01_12_8(void) {
	unsigned int u = ju;
	v0();
	u %= 7;
}
int rs_4_01_12_9(void) {
	unsigned int u = ju;
	v0();
	return (((unsigned char)u) >= guca[5]) << (u & 15);
}
void rs_4_01_13_0(void) {
	vl((long)gula[4]);
}
void rs_4_01_13_1(void) {
	if (gua[3] != 0) gu2 = gu2 / gua[3];
}
void rs_4_01_13_2(void) {
	if (!gs.a[5]) { gca[6] = (char)gps->i; if (gi != 0) gi3 = *gpi / gi; if (*gpi != 0) *gpi = gpi[1] / *gpi; }
}
void rs_4_01_14_0(unsigned long a) {
	unsigned long t = gula[4];
	jul = t;
}
void rs_4_01_14_1(unsigned long a) {
	unsigned char u = -guc;
	juc = u;
}
void rs_4_01_14_2(unsigned long a) {
	while (gi-- > 0) { if (*gpi == 255) break; gpi++; }
}
void rs_4_01_14_3(unsigned long a) {
	gl++;
}
void rs_4_01_14_4(unsigned long a) {
	gda[1] = -gd;
}
void rs_4_01_14_5(unsigned long a) {
	unsigned long t = jul;
	gul = t;
}
void rs_4_01_14_6(unsigned long a) {
	unsigned char u = juc;
	v1(u);
}
int rs_4_01_14_7(unsigned long a) {
	unsigned char u = juc;
	v0();
	return gi2 << (u & 15);
}
void rs_4_01_15_0(char a) {
	guc = (guc + guca[a]) * guca[a];
}
void rs_4_01_15_1(char a) {
	if (gc > 'a' && (gua[a] = gu2) < 255) { gu2 = gua[a] = (unsigned int)(255 + guca[a]); gu = ~gu2 / 3; } else { gpi[1] &= ~gps->i; }
}
void rs_4_01_15_2(char a) {
	*gp = gs.c % 10;
}
void rs_4_01_15_3(char a) {
	gp[0] -= gc2;
}
void rs_4_01_15_4(char a) {
	gl2 = gl2 - (gla[5] - gpl[3]);
}
unsigned int rs_4_01_15_5(char a) {
	return (gps->u & gu) - (((unsigned int)gc) | 5);
}
void rs_4_01_16_0(void) {
	int t = !gs.a[4];
	ji = t;
}
void rs_4_01_16_1(void) {
	int t = ji;
	long u = gps->l & gla[t];
	jl = u;
}
void rs_4_01_16_2(void) {
	if (gs.c == gc2) gps->l = gl2 * 7L;
}
void rs_4_01_16_3(void) {
	int t = ji;
	gpi = gpi + t;
}
void rs_4_01_16_4(void) {
	long u = jl;
	gl = u;
}
void rs_4_01_16_5(void) {
	int t = ji;
	gia[5] = t & -t;
}
void rs_4_01_16_6(void) {
	int t = ji;
	gul = rul(rul(gula[t]));
}
long rs_4_01_16_7(void) {
	return gl2;
}
void rs_4_01_17_0(long a) {
	*gpi = gia[4];
}
void rs_4_01_17_1(long a) {
	++gp;
}
void rs_4_01_17_2(long a) {
	vs(gps);
}
int * rs_4_01_17_3(long a) {
	return gpi;
}
void rs_4_01_18_0(int a, int *b) {
	int t = gi + 255;
	ji = t;
}
void rs_4_01_18_1(int a, int *b) {
	int t = ji;
	v1(t);
}
void rs_4_01_18_2(int a, int *b) {
	gc2 = gps->c;
}
void rs_4_01_18_3(int a, int *b) {
	gc2--;
}
char * rs_4_01_18_4(int a, int *b) {
	return gp;
}
void rs_4_01_19_0(long *a) {
	unsigned int t = (unsigned int)gps->a[7];
	ju = t;
}
void rs_4_01_19_1(long *a) {
	v0();
}
void rs_4_01_19_2(long *a) {
	gd *= (double)gps->c * 3.0;
}
void rs_4_01_19_3(long *a) {
	unsigned int t = ju;
	v0();
	gu = t;
}
void rs_4_01_19_4(long *a) {
	gd2 *= gd2 - gd;
}
int * rs_4_01_19_5(long *a) {
	return gpi;
}
void rs_4_02_00_0(double a, char b, long c) {
	unsigned int t = gs.u;
	ju = t;
}
void rs_4_02_00_1(double a, char b, long c) {
	unsigned int t = ju;
	vu(t);
}
void rs_4_02_00_2(double a, char b, long c) {
	gpi = &gia[3];
}
void rs_4_02_00_3(double a, char b, long c) {
	vl(gl ^ gl2);
}
void rs_4_02_00_4(double a, char b, long c) {
	c++;
}
void rs_4_02_00_5(double a, char b, long c) {
	if (b == gc) if (gca[b] != 0) gca[b] = gs.c / gca[b];
}
long rs_4_02_00_6(double a, char b, long c) {
	return rl(*gpl >> 24);
}
void rs_4_02_01_1(void) {
	char *t = gp;
	jp = t;
}
void rs_4_02_01_2(void) {
	unsigned long u = 0x10000UL;
	jul = u;
}
void rs_4_02_01_3(void) {
	int i = ji;
	i = 0; while (i < 12) { if (gps->i != 0) gps->a[i] = 1 % gps->i; gua[i] ^= gu2 & 0; gca[i] /= 10; i++; }
}
void rs_4_02_01_4(void) {
	vc(rc(gi));
}
void rs_4_02_01_5(void) {
	--gi;
}
void rs_4_02_01_6(void) {
	unsigned long u = jul;
	v0();
	vl((long)u);
}
void rs_4_02_01_7(void) {
	char *t = jp;
	v0();
	gp = t;
}
unsigned long rs_4_02_01_8(void) {
	unsigned long u = jul;
	v0();
	return rul(u % 2UL);
}
void rs_4_02_02_0(unsigned char a, struct st *b) {
	guc--;
}
void rs_4_02_02_1(unsigned char a, struct st *b) {
	switch (gl2) { case 0L: vp(gs.p); break; case 1L: gp[2] ^= *gp; break; }
}
void rs_4_02_02_2(unsigned char a, struct st *b) {
	guca[6] = guc = a + 255;
}
void rs_4_02_02_3(unsigned char a, struct st *b) {
	if (gula[a] != 0) gula[a] = 50271UL % gula[a];
}
void rs_4_02_02_4(unsigned char a, struct st *b) {
	gs.d = gd;
}
void rs_4_02_03_0(unsigned int a, unsigned char b) {
	double t = 3.0;
	jd = t;
}
void rs_4_02_03_1(unsigned int a, unsigned char b) {
	guca[7] = 255 & 128;
}
void rs_4_02_03_2(unsigned int a, unsigned char b) {
	--gul;
}
char * rs_4_02_03_3(unsigned int a, unsigned char b) {
	if (gul < 2UL || gul <= gula[7]) return gps->p;
}
void rs_4_02_03_4(unsigned int a, unsigned char b) {
	double t = jd;
	gd = t;
}
char * rs_4_02_03_5(unsigned int a, unsigned char b) {
	return gp;
}
void rs_4_02_04_0(unsigned int a, struct st *b) {
	int t = gi2;
	ji = t;
}
void rs_4_02_04_1(unsigned int a, struct st *b) {
	long u = 65536L;
	jl = u;
}
void rs_4_02_04_2(unsigned int a, struct st *b) {
	long u = jl;
	gs.u &= ~((unsigned int)u);
}
void rs_4_02_04_3(unsigned int a, struct st *b) {
	int t = ji;
	t %= 10;
}
int rs_4_02_04_4(unsigned int a, struct st *b) {
	return (gd != (gs.d * gs.d));
}
void rs_4_02_05_0(int *a, unsigned char b, unsigned char c) {
	char *t = gp;
	jp = t;
}
void rs_4_02_05_1(int *a, unsigned char b, unsigned char c) {
	char *t = jp;
	char u = t[0];
	jc = u;
}
void rs_4_02_05_2(int *a, unsigned char b, unsigned char c) {
	char u = jc;
	gc = u;
}
void rs_4_02_05_3(int *a, unsigned char b, unsigned char c) {
	gla[2] = (long)rul(gul);
}
void rs_4_02_05_4(int *a, unsigned char b, unsigned char c) {
	char *t = jp;
	v0();
	gp = t;
}
void rs_4_02_05_5(int *a, unsigned char b, unsigned char c) {
	gd2 = (gs.d + gs.d) * (gua[b] & 0x8 ? gd2 : gda[0]);
}
char * rs_4_02_05_6(int *a, unsigned char b, unsigned char c) {
	return &gca[c];
}
void rs_4_02_06_0(struct st *a, int b, struct st *c) {
	vu(gu2 >> (b & 15));
}
void rs_4_02_06_1(struct st *a, int b, struct st *c) {
	guc--;
}
void rs_4_02_06_2(struct st *a, int b, struct st *c) {
	if (guc < 144) { a->p = gp; } else { gul = (gula[b] - ((unsigned long)gua[b])) / 100UL; if (gps->u != 0) gps->u = 8 % gps->u; if (gs.u != 0) gu2 = gua[3] / gs.u; }
}
void rs_4_02_06_3(struct st *a, int b, struct st *c) {
	gpi++;
}
int * rs_4_02_06_4(struct st *a, int b, struct st *c) {
	return gpi;
}
void rs_4_02_07_1(char a) {
	*gp = *gp | gc2;
}
void rs_4_02_07_2(char a) {
	int i = ji;
	for (i = 4; i > 0; i--) { vu(gua[i] / 10); gla[i] = -(long)gia[4]; if (*gp != 0) *gp = gs.c % *gp; }
}
void rs_4_02_07_3(char a) {
	gs.u += gu2 - gua[7];
}
void rs_4_02_07_4(char a) {
	if (gps->l != 0) gla[a] = gl2 / gps->l;
}
int * rs_4_02_07_5(char a) {
	return &gia[a];
}
void rs_4_02_08_0(char *a) {
	char *t = gs.p;
	jp = t;
}
void rs_4_02_08_1(char *a) {
	guca[1] = guc % 100;
}
void rs_4_02_08_2(char *a) {
	if (gu2 > gua[5]) { gula[4] += rul(gul); v2(gi2, gi2); --gl2; }
}
void rs_4_02_08_3(char *a) {
	guca[4] = guca[5] + guc;
}
void rs_4_02_08_4(char *a) {
	char *t = jp;
	v0();
	if (r2(gi, gi)) { vp(t + 1); vu(gua[4] - 32767); }
}
void rs_4_02_08_5(char *a) {
	gula[6] = gul = ~gula[2];
}
long rs_4_02_08_6(char *a) {
	return (gpl[1] = gs.l);
}
void rs_4_02_09_0(int a) {
	long t = gla[3];
	jl = t;
}
void rs_4_02_09_1(int a) {
	unsigned char u = guc;
	juc = u;
}
void rs_4_02_09_2(int a) {
	long t = jl;
	gl = t;
}
void rs_4_02_09_3(int a) {
	unsigned char u = juc;
	if (gu2) if (gs.u != 0) gu2 = gu2 / gs.u;
}
void rs_4_02_09_4(int a) {
	unsigned char u = juc;
	gca[u] = rc(gi);
}
void rs_4_02_09_5(int a) {
	unsigned char u = juc;
	v0();
	if (r0() || gca[u] < gc2) gd2 = gs.d;
}
void rs_4_02_09_6(int a) {
	gps->c = gs.c << 3;
}
void rs_4_02_09_7(int a) {
	gi2 = a;
}
unsigned long rs_4_02_09_8(int a) {
	unsigned char u = juc;
	v0();
	return -(gula[3] + gula[u]);
}
void rs_4_02_10_0(char *a, double b, int c) {
	char t = rc(gi2);
	jc = t;
}
void rs_4_02_10_1(char *a, double b, int c) {
	unsigned int u = gu | gu2;
	v0();
	ju = u;
}
void rs_4_02_10_2(char *a, double b, int c) {
	v2(gi2, 255);
}
void rs_4_02_10_3(char *a, double b, int c) {
	char t = jc;
	v0();
	guca[t] /= 7;
}
void rs_4_02_10_4(char *a, double b, int c) {
	gc = (28 >> 7) | (guca[2] == guc ? (char)gua[1] : gc2);
}
void rs_4_02_10_5(char *a, double b, int c) {
	unsigned int u = ju;
	v0();
	vu(u);
}
void rs_4_02_10_6(char *a, double b, int c) {
	gps->p = rp();
}
int rs_4_02_10_7(char *a, double b, int c) {
	return ~(*gpi | c);
}
void rs_4_02_11_0(long a, int b, int c) {
	char t = gc2 - 2;
	jc = t;
}
void rs_4_02_11_1(long a, int b, int c) {
	gla[b] = (long)gula[c];
}
void rs_4_02_11_2(long a, int b, int c) {
	char t = jc;
	gc = t;
}
long rs_4_02_11_3(long a, int b, int c) {
	if (gi3 & 2) return a;
}
long rs_4_02_11_4(long a, int b, int c) {
	return (gla[2] = gla[7]);
}
void rs_4_02_12_1(char a, unsigned int b) {
	unsigned long t = rul(gul);
	jul = t;
}
void rs_4_02_12_2(char a, unsigned int b) {
	long u = *gpl;
	v0();
	jl = u;
}
void rs_4_02_12_3(char a, unsigned int b) {
	int i = ji;
	long u = jl;
	v0();
	for (i = 4; i > 0; i--) { gpi = rpi(5); gca[5] = (b <= gu && guca[i] > 1 ? (u == -57392L ? gc2 : gca[i]) : gc2); if (gs.a[i] != 0) gs.i = gi3 % gs.a[i]; }
}
void rs_4_02_12_4(char a, unsigned int b) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
void rs_4_02_12_5(char a, unsigned int b) {
	guc += guc | guca[4];
}
unsigned int rs_4_02_12_6(char a, unsigned int b) {
	return (unsigned int)((guc + 128) != -guca[3]);
}
void rs_4_02_13_1(int a, int b) {
	long t = (long)(gps->c == 'z');
	jl = t;
}
void rs_4_02_13_2(int a, int b) {
	char u = gc;
	jc = u;
}
void rs_4_02_13_3(int a, int b) {
	long t = jl;
	gl = t;
}
void rs_4_02_13_4(int a, int b) {
	gpi = rpi(a >> 14);
}
void rs_4_02_13_5(int a, int b) {
	int i = ji;
	char u = jc;
	v0();
	i = 0; while (i < a) { guc = ((unsigned char)u) ^ guca[i]; i++; }
}
unsigned long rs_4_02_13_6(int a, int b) {
	return 5UL;
}
void rs_4_02_14_1(void) {
	int i = ji;
	for (i = 0; i < 8; i++) { if (gula[i] != 0) gula[6] = 0x10000UL % gula[i]; if (gia[i] != 0) gia[i] = 8 / gia[i]; if (gc2 != 0) gps->c = gca[6] / gc2; }
}
void rs_4_02_14_2(void) {
	v2(gi2, gi3);
}
void rs_4_02_14_3(void) {
	gd2 = gs.d * gda[1];
}
int rs_4_02_14_4(void) {
	return r2(gi2, gs.a[6]) + (int)gu2;
}
void rs_4_02_15_0(long a, long b, double c) {
	char t = gc2 / 7;
	jc = t;
}
void rs_4_02_15_1(long a, long b, double c) {
	char t = jc;
	int u = gia[t];
	ji = u;
}
void rs_4_02_15_2(long a, long b, double c) {
	if (gula[7] != 0) gula[4] = 74983UL / gula[7];
}
void rs_4_02_15_3(long a, long b, double c) {
	char t = jc;
	if (gula[4] || gia[3] & 0x7) { vs(gps); guca[t] = (guc * guc) * ((unsigned char)(int)guca[t]); }
}
void rs_4_02_15_4(long a, long b, double c) {
	int u = ji;
	v0();
	gi = u;
}
void rs_4_02_15_5(long a, long b, double c) {
	gs.p = gp;
}
void rs_4_02_15_6(long a, long b, double c) {
	char t = jc;
	v0();
	++t;
}
int * rs_4_02_15_7(long a, long b, double c) {
	return gpi;
}
void rs_4_02_16_0(void) {
	unsigned long t = gula[7];
	jul = t;
}
void rs_4_02_16_1(void) {
	vc(gs.c / 3);
}
void rs_4_02_16_2(void) {
	switch (gi2) { case 1: case 20: vp(&gca[0]); break; case 200: v2(gi2, gps->a[7]); break; default: vc(gca[2]); break; }
}
void rs_4_02_16_3(void) {
	unsigned long t = jul;
	v0();
	gul = t;
}
unsigned int rs_4_02_16_4(void) {
	return (gs.u = gps->u);
}
void rs_4_02_17_0(int a) {
	int *t = gpi;
	jpi = t;
}
void rs_4_02_17_1(int a) {
	gs.d *= gd2 - 1.0;
}
void rs_4_02_17_2(int a) {
	--gul;
}
void rs_4_02_17_3(int a) {
	gla[a] *= 10L;
}
void rs_4_02_17_4(int a) {
	gu %= 3;
}
void rs_4_02_17_5(int a) {
	gla[3] -= rl(gla[a]);
}
void rs_4_02_17_6(int a) {
	int *t = jpi;
	v0();
	gpi = t;
}
int rs_4_02_17_7(int a) {
	return gia[a];
}
void rs_4_02_18_0(char a) {
	char *t = gps->p;
	jp = t;
}
void rs_4_02_18_1(char a) {
	double u = (double)gs.c / 2.5;
	jd = u;
}
void rs_4_02_18_2(char a) {
	gu = ((unsigned int)gula[4]) << (a & 15);
}
void rs_4_02_18_3(char a) {
	double u = jd;
	switch (gps->l) { case 0L: gula[1] >>= 23; break; case 1L: guc = (unsigned char)(8 > gps->a[a]); break; case 2L: gs.u = gu2 | 1; break; case 3L: guc &= guca[4]; break; }
}
void rs_4_02_18_4(char a) {
	gu--;
}
void rs_4_02_18_5(char a) {
	gula[a] = (unsigned long)((long)gul == gpl[3]);
}
char * rs_4_02_18_6(char a) {
	char *t = jp;
	if (guca[a] > ((unsigned char)gua[a])) return t;
}
char * rs_4_02_18_7(char a) {
	return rp();
}
void rs_4_02_19_1(unsigned char a, long b) {
	a = guc = -(55 + guc);
}
void rs_4_02_19_2(unsigned char a, long b) {
	int i = ji;
	for (i = 0; i < 6; i++) { if (gul != 0) gul = 0UL / gul; if (gc2 != 0) gs.c = gc2 / gc2; }
}
void rs_4_02_19_3(unsigned char a, long b) {
	guca[4] &= guc & a;
}
int rs_4_02_19_4(unsigned char a, long b) {
	return (gia[7] >> (a & 15)) + gs.a[4];
}
void rs_4_03_00_0(int a) {
	double t = gda[0] * gda[0];
	jd = t;
}
void rs_4_03_00_1(int a) {
	double t = jd;
	vd(t);
}
void rs_4_03_00_2(int a) {
	--guc;
}
void rs_4_03_00_3(int a) {
	if (gca[a]) if (gca[0] != 0) gc = gca[a] / gca[0];
}
void rs_4_03_00_4(int a) {
	gc2 = gca[4] ^ (gc & gc2);
}
int rs_4_03_00_5(int a) {
	return !8 & (gi3 * gi2);
}
void rs_4_03_01_0(double a, char *b, unsigned int c) {
	unsigned char t = -guca[c];
	juc = t;
}
void rs_4_03_01_1(double a, char *b, unsigned int c) {
	unsigned char t = juc;
	gia[t] <<= 4;
}
void rs_4_03_01_2(double a, char *b, unsigned int c) {
	unsigned char t = juc;
	t = (t | guca[t]) ^ (t | 128);
}
void rs_4_03_01_3(double a, char *b, unsigned int c) {
	unsigned char t = juc;
	if (gi2) { gps->c >>= 4; if (gla[t] != 0) gl2 = 65536L / gla[t]; } else { gi2 = gs.a[2] + (127 / 2); }
}
int rs_4_03_01_4(double a, char *b, unsigned int c) {
	return (gi = 256);
}
void rs_4_03_02_0(struct st *a, int b, struct st *c) {
	gd2 = gs.d * -gd;
}
void rs_4_03_02_1(struct st *a, int b, struct st *c) {
	while (b-- > 0) *gpi++ = 8;
}
int rs_4_03_02_2(struct st *a, int b, struct st *c) {
	return 8;
}
void rs_4_03_03_0(int *a, int *b, unsigned int c) {
	int t = (int)gs.c;
	ji = t;
}
void rs_4_03_03_1(int *a, int *b, unsigned int c) {
	char *u = gs.p;
	jp = u;
}
void rs_4_03_03_2(int *a, int *b, unsigned int c) {
	gl--;
}
void rs_4_03_03_3(int *a, int *b, unsigned int c) {
	char *u = jp;
	vp(u);
}
void rs_4_03_03_4(int *a, int *b, unsigned int c) {
	int t = ji;
	v0();
	v2(gi2, 255 & t);
}
void rs_4_03_03_5(int *a, int *b, unsigned int c) {
	if (gi2 & 0x80) { gpl[2] = (long)gs.a[2]; gula[0] = (unsigned long)!guca[6]; ++gc; }
}
int rs_4_03_03_6(int *a, int *b, unsigned int c) {
	int t = ji;
	v0();
	return (b[t] = t);
}
void rs_4_03_04_0(char a) {
	gpl[0] = gl;
}
void rs_4_03_04_1(char a) {
	++gi3;
}
void rs_4_03_04_2(char a) {
	gc = -gca[0] + (gc | 'A');
}
void rs_4_03_04_3(char a) {
	if (gul != 0) gul = gul / gul;
}
int * rs_4_03_04_4(char a) {
	return rpi(gps->i | gs.a[a]);
}
void rs_4_03_05_0(unsigned long a, unsigned long b) {
	unsigned int t = gu - gu2;
	ju = t;
}
void rs_4_03_05_1(unsigned long a, unsigned long b) {
	gl2 = (gl2 % 2L) - (gl | 65536L);
}
void rs_4_03_05_2(unsigned long a, unsigned long b) {
	unsigned int t = ju;
	if (guc == guca[t]) if (gc != 0) gs.c = gc2 / gc;
}
void rs_4_03_05_3(unsigned long a, unsigned long b) {
	unsigned int t = ju;
	guca[t] = 255 ^ guca[4];
}
void rs_4_03_05_4(unsigned long a, unsigned long b) {
	while (gi-- > 0) { if (*gp == 2) break; gp++; }
}
void rs_4_03_05_5(unsigned long a, unsigned long b) {
	unsigned int t = ju;
	gp = gp + t;
}
int rs_4_03_05_6(unsigned long a, unsigned long b) {
	return r1((gps->c < gc2));
}
void rs_4_03_06_1(unsigned long a) {
	int i = ji;
	int t = gs.i;
	ji = t;
}
void rs_4_03_06_2(unsigned long a) {
	int t = ji;
	v1(t);
}
void rs_4_03_06_3(unsigned long a) {
	int i = ji;
	v0();
	for (i = 13; i > 0; i--) { if (gs.c != 0) gc2 = 8 / gs.c; }
}
void rs_4_03_06_4(unsigned long a) {
	if (guca[6] & 0x10) { if (gc2 != 0) gc = gp[0] / gc2; gps->p = gp; }
}
long rs_4_03_06_5(unsigned long a) {
	return *gpl;
}
void rs_4_03_07_1(int a, int *b, unsigned char c) {
	char t = gc & 'z';
	jc = t;
}
void rs_4_03_07_2(int a, int *b, unsigned char c) {
	char t = jc;
	t = ~gc;
}
void rs_4_03_07_3(int a, int *b, unsigned char c) {
	char t = jc;
	gi3 = (int)(gula[5] | ((unsigned long)gia[t]));
}
void rs_4_03_07_4(int a, int *b, unsigned char c) {
	int i = ji;
	for (i = 0; i < 12; i++) { vd(gs.d); c <<= 4; v2(gi2, r2(gi3, gi)); }
}
unsigned int rs_4_03_07_5(int a, int *b, unsigned char c) {
	return gs.u % 3;
}
void rs_4_03_08_0(int a, unsigned int b, char c) {
	unsigned int t = ((unsigned int)guca[6]) >> (a & 15);
	ju = t;
}
void rs_4_03_08_1(int a, unsigned int b, char c) {
	int *u = gpi;
	jpi = u;
}
void rs_4_03_08_2(int a, unsigned int b, char c) {
	gc2 = (char)!419;
}
void rs_4_03_08_3(int a, unsigned int b, char c) {
	unsigned int t = ju;
	gu = t;
}
void rs_4_03_08_4(int a, unsigned int b, char c) {
	gl = (!gul ? 65536L : (long)gc2) >> 15;
}
void rs_4_03_08_5(int a, unsigned int b, char c) {
	int *u = jpi;
	switch (gu) { case 0: vs(gps); break; case 1: v0(); break; default: v2(u[2], gi); break; }
}
unsigned int rs_4_03_08_6(int a, unsigned int b, char c) {
	return (unsigned int)!(gc2 / 2);
}
void rs_4_03_09_0(void) {
	long t = ((gla[3] = -24129L) == -50472L ? 65536L : gs.l);
	jl = t;
}
void rs_4_03_09_1(void) {
	int *u = gpi;
	jpi = u;
}
void rs_4_03_09_2(void) {
	long t = jl;
	guc = (unsigned char)t;
}
void rs_4_03_09_3(void) {
	long t = jl;
	t = (gps->l | -73945L) & (guca[7] <= guc ? t : gl);
}
void rs_4_03_09_4(void) {
	gca[6] = gps->c | gca[6];
}
void rs_4_03_09_5(void) {
	int *u = jpi;
	gpi = u;
}
void rs_4_03_10_0(unsigned int a) {
	int t = !67119UL;
	ji = t;
}
void rs_4_03_10_1(unsigned int a) {
	int *u = gpi;
	jpi = u;
}
void rs_4_03_10_2(unsigned int a) {
	if (gul != 0) gul = ((unsigned long)gps->i) % gul;
}
void rs_4_03_10_3(unsigned int a) {
	int t = ji;
	if (1 > 'z') if (t != 0) gi3 = 255 % t;
}
void rs_4_03_10_4(unsigned int a) {
	gl = (*gpl + gl) % 10L;
}
void rs_4_03_10_5(unsigned int a) {
	int *u = jpi;
	v1(*u);
}
void rs_4_03_10_6(unsigned int a) {
	guca[a] = guc = guc & (guca[a] + 79);
}
long rs_4_03_10_7(unsigned int a) {
	return ~(long)!gula[a];
}
void rs_4_03_11_1(int *a, char b) {
	char *t = gp;
	jp = t;
}
void rs_4_03_11_2(int *a, char b) {
	vu(gu);
}
void rs_4_03_11_3(int *a, char b) {
	char *t = jp;
	v0();
	gp = t;
}
void rs_4_03_11_4(int *a, char b) {
	int i = ji;
	v0();
	i = 0; while (i < 9) { guca[i] -= 236 >> 6; if (gs.u != 0) gu = gu2 % gs.u; i++; }
}
void rs_4_03_12_1(int a, int b) {
	int *t = rpi(gi2);
	jpi = t;
}
void rs_4_03_12_2(int a, int b) {
	int i = ji;
	v0();
	for (i = 0; i < a; i++) { gu2 = gua[b] = gua[a]; if (gl2 != 0) gpl[1] = gla[i] % gl2; }
}
void rs_4_03_12_3(int a, int b) {
	gl2 = (long)!gla[b] * 12L;
}
void rs_4_03_12_4(int a, int b) {
	gp = gs.p;
}
void rs_4_03_12_5(int a, int b) {
	gd -= gs.d / 100.0;
}
void rs_4_03_12_6(int a, int b) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_4_03_12_7(int a, int b) {
	guc = (unsigned char)!ru(gua[a]);
}
void rs_4_03_13_0(unsigned int a, long b, char c) {
	double t = (double)gc2 - gd2;
	jd = t;
}
void rs_4_03_13_1(unsigned int a, long b, char c) {
	vu((unsigned int)!b);
}
void rs_4_03_13_2(unsigned int a, long b, char c) {
	double t = jd;
	v0();
	vd(t);
}
void rs_4_03_13_3(unsigned int a, long b, char c) {
	v2(gi2, gi2);
}
unsigned int rs_4_03_13_4(unsigned int a, long b, char c) {
	return (gu2 = 5);
}
void rs_4_03_14_1(int a, int b, double c) {
	gc = (gs.c / 10) & (gp[2] / 7);
}
void rs_4_03_14_2(int a, int b, double c) {
	gp = &gca[2];
}
void rs_4_03_14_3(int a, int b, double c) {
	int i = ji;
	for (i = 0; i < 9; i++) { if (gca[i] != 0) gs.c = gs.c % gca[i]; --gu; }
}
void rs_4_03_14_4(int a, int b, double c) {
	int i = ji;
	i = 0; while (i < a) { gu2++; vu(gu ^ 2058); i++; }
}
unsigned int rs_4_03_14_5(int a, int b, double c) {
	return (unsigned int)((9 + 255) > -gua[b]);
}
void rs_4_03_15_0(int a, unsigned long b) {
	vp(&gca[3]);
}
void rs_4_03_15_1(int a, unsigned long b) {
	vp(rp());
}
void rs_4_03_15_2(int a, unsigned long b) {
	gps->a[7] = gi2;
}
int rs_4_03_15_3(int a, unsigned long b) {
	return (gi2 = gps->i);
}
void rs_4_03_16_0(int a, long *b) {
	unsigned long t = gula[6] >> 20;
	jul = t;
}
void rs_4_03_16_1(int a, long *b) {
	if (((unsigned long)gua[7]) != 69769UL) gi = !((char)gpl[3] | (char)gua[a]);
}
void rs_4_03_16_2(int a, long *b) {
	gi3 |= 256 ^ (int)gula[4];
}
void rs_4_03_16_3(int a, long *b) {
	unsigned long t = jul;
	gul = t;
}
unsigned int rs_4_03_16_4(int a, long *b) {
	return 7822;
}
void rs_4_03_17_0(char *a, unsigned char b, int c) {
	int *t = gpi;
	jpi = t;
}
void rs_4_03_17_1(char *a, unsigned char b, int c) {
	int *t = jpi;
	v1(*t);
}
void rs_4_03_17_2(char *a, unsigned char b, int c) {
	guca[7] = 145;
}
void rs_4_03_17_3(char *a, unsigned char b, int c) {
	if (gu2 == gs.u) if (gul != 0) gul = gul % gul;
}
long rs_4_03_17_4(char *a, unsigned char b, int c) {
	if (r2(gi2, 16)) return gl2 * (long)gu;
}
void rs_4_03_17_5(char *a, unsigned char b, int c) {
	switch (gc2) { case 1: v0(); break; case 16: vc(gc2); break; default: gu2 = ru(gu2); break; }
}
void rs_4_03_17_6(char *a, unsigned char b, int c) {
	b *= 2;
}
long rs_4_03_17_7(char *a, unsigned char b, int c) {
	return gpl[3] >> (b & 15);
}
void rs_4_03_18_0(void) {
	int t = gia[0];
	ji = t;
}
void rs_4_03_18_1(void) {
	*gp = (char)((unsigned long)(gda[3] > gda[0]));
}
void rs_4_03_18_2(void) {
	int t = ji;
	gi = t;
}
void rs_4_03_18_3(void) {
	--gu2;
}
void rs_4_03_19_0(long a, long *b, double c) {
	if (gula[3] > gul) { vd(c * 0.25); gs.u += gu2 % 3; v0(); }
}
void rs_4_03_19_1(long a, long *b, double c) {
	switch (gl2) { case 0L: case 1L: gul = (unsigned long)(gs.c > gca[0]); break; case 2L: vs(gps); break; }
}
int * rs_4_03_19_2(long a, long *b, double c) {
	return gpi;
}
void rs_4_04_00_0(unsigned long a, char b, int c) {
	unsigned long t = a & 0x10000UL;
	jul = t;
}
void rs_4_04_00_1(unsigned long a, char b, int c) {
	unsigned long t = jul;
	guc = ((long)t < gps->l ? ((unsigned char)4) : ~guc);
}
void rs_4_04_00_2(unsigned long a, char b, int c) {
	while (c-- > 0) { if (*gp == -32) break; gp++; }
}
void rs_4_04_00_3(unsigned long a, char b, int c) {
	unsigned long t = jul;
	if (b & 1) { gul += t + 74825UL; }
}
char * rs_4_04_00_4(unsigned long a, char b, int c) {
	return gp;
}
void rs_4_04_01_1(void) {
	unsigned int t = gu2 - 19177;
	ju = t;
}
void rs_4_04_01_2(void) {
	char u = 6 >> 4;
	jc = u;
}
void rs_4_04_01_3(void) {
	gda[1] -= -gd2;
}
void rs_4_04_01_4(void) {
	guc++;
}
void rs_4_04_01_5(void) {
	switch (gs.c) { case 0: v2(gi3, gi); break; case 1: gi3 &= (int)gu2; break; case 2: vp(rp()); break; case 3: vp(gs.p); case 4: vl(*gpl); break; }
}
void rs_4_04_01_6(void) {
	char u = jc;
	v0();
	gc = u;
}
void rs_4_04_01_7(void) {
	unsigned int t = ju;
	v0();
	gu = t;
}
void rs_4_04_01_8(void) {
	gpl[1] = (long)(0.5 <= gs.d);
}
void rs_4_04_01_9(void) {
	int i = ji;
	v0();
	for (i = 11; i > 0; i--) { ++gp; }
}
char * rs_4_04_01_10(void) {
	return gps->p;
}
void rs_4_04_02_1(int a, unsigned long b) {
	int t = gia[5] + (int)gc;
	ji = t;
}
void rs_4_04_02_2(int a, unsigned long b) {
	long u = rl(gps->l);
	jl = u;
}
void rs_4_04_02_3(int a, unsigned long b) {
	int i = ji;
	int t = ji;
	long u = jl;
	v0();
	i = 12; do { if (gla[a] != 0) u = 9L % gla[a]; gla[t] -= gs.l; } while (--i > 0);
}
void rs_4_04_02_4(int a, unsigned long b) {
	int t = ji;
	v0();
	guc = ((guca[1] = guc) ? (guc / 10) : -guca[t]);
}
void rs_4_04_02_5(int a, unsigned long b) {
	gul |= (unsigned long)(gpi[2] > gi3);
}
void rs_4_04_03_0(char a) {
	int *t = gpi + a;
	jpi = t;
}
void rs_4_04_03_1(char a) {
	double u = gda[3] - gs.d;
	jd = u;
}
int rs_4_04_03_2(char a) {
	if (gc) return 127;
}
void rs_4_04_03_3(char a) {
	vs(gps);
}
void rs_4_04_03_4(char a) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_4_04_03_5(char a) {
	double u = jd;
	v0();
	vd(u);
}
void rs_4_04_03_6(char a) {
	guc -= guc & guca[1];
}
void rs_4_04_03_7(char a) {
	gu >>= (a & 15);
}
void rs_4_04_03_8(char a) {
	a = (char)gs.a[a];
}
int rs_4_04_03_9(char a) {
	return r0();
}
void rs_4_04_04_0(double a, struct st *b, long c) {
	double t = gda[1];
	jd = t;
}
void rs_4_04_04_1(double a, struct st *b, long c) {
	int u = *gpi >> 8;
	ji = u;
}
void rs_4_04_04_2(double a, struct st *b, long c) {
	int u = ji;
	gu2 = gua[u] = ru(gua[4]);
}
void rs_4_04_04_3(double a, struct st *b, long c) {
	*gpl = gl2 = c;
}
void rs_4_04_04_4(double a, struct st *b, long c) {
	double t = jd;
	v0();
	vd(a - t);
}
char * rs_4_04_04_5(double a, struct st *b, long c) {
	return gps->p;
}
void rs_4_04_05_1(int *a) {
	int t = ~(int)gc2;
	ji = t;
}
void rs_4_04_05_2(int *a) {
	double u = gd;
	jd = u;
}
void rs_4_04_05_3(int *a) {
	v0();
}
void rs_4_04_05_4(int *a) {
	double u = jd;
	v0();
	vd(u);
}
void rs_4_04_05_5(int *a) {
	if (gu) v0();
}
void rs_4_04_05_6(int *a) {
	vp(gps->p);
}
void rs_4_04_05_7(int *a) {
	int i = ji;
	int t = ji;
	v0();
	for (i = 6; i > 0; i--) { t = 2; }
}
void rs_4_04_05_8(int *a) {
	int i = ji;
	v0();
	for (i = 0; i < 3; i++) { gp = gps->p; }
}
unsigned long rs_4_04_05_9(int *a) {
	return gul << 24;
}
void rs_4_04_06_0(void) {
	guc += guc >> 3;
}
unsigned long rs_4_04_06_1(void) {
	if (gps->l & 4) return gul + 0x10000UL;
}
unsigned long rs_4_04_06_2(void) {
	return gul & rul(gul);
}
void rs_4_04_07_0(unsigned int a, int b, double c) {
	unsigned char t = (unsigned char)gp[3];
	juc = t;
}
void rs_4_04_07_1(unsigned int a, int b, double c) {
	unsigned char t = juc;
	unsigned char u = t;
	juc = u;
}
void rs_4_04_07_2(unsigned int a, int b, double c) {
	*gpl /= 7L;
}
void rs_4_04_07_3(unsigned int a, int b, double c) {
	gu = gua[2] = gu2;
}
void rs_4_04_07_4(unsigned int a, int b, double c) {
	unsigned char t = juc;
	v1(t);
}
void rs_4_04_07_5(unsigned int a, int b, double c) {
	unsigned char u = juc;
	v0();
	u = guca[6] = guc;
}
void rs_4_04_07_6(unsigned int a, int b, double c) {
	gda[2] = -gd;
}
void rs_4_04_07_7(unsigned int a, int b, double c) {
	unsigned char u = juc;
	v0();
	if (gps->u & 4) gia[u] = gi2;
}
void rs_4_04_08_0(void) {
	unsigned char t = -guc;
	juc = t;
}
void rs_4_04_08_1(void) {
	int *u = gpi;
	jpi = u;
}
void rs_4_04_08_2(void) {
	v0();
}
void rs_4_04_08_3(void) {
	while (gi > 0) { gi3 += *gpi++; gi--; }
}
void rs_4_04_08_4(void) {
	vl(gpl[2]);
}
void rs_4_04_08_5(void) {
	unsigned char t = juc;
	v0();
	v1(t);
}
void rs_4_04_08_6(void) {
	int *u = jpi;
	v0();
	if (gps->l) { if (gi2 != 0) *u = 1 / gi2; gc2 = 6; vp(gps->p); }
}
char rs_4_04_08_7(void) {
	return (gps->c * 35) + 26;
}
void rs_4_04_09_0(char a) {
	gula[a] = gula[a] % 3UL;
}
void rs_4_04_09_1(char a) {
	gi2 /= 16;
}
void rs_4_04_09_2(char a) {
	if (gl2) gu2++;
}
void rs_4_04_09_3(char a) {
	gul = (unsigned long)(gla[a] >= (gs.l << (a & 15)));
}
unsigned long rs_4_04_09_4(char a) {
	return rul(gula[a] << (a & 15));
}
void rs_4_04_10_1(char a, struct st *b) {
	double t = gs.d;
	jd = t;
}
void rs_4_04_10_2(char a, struct st *b) {
	if (gi <= (int)b->u) { gca[a] = ~(~'0'); vl(gla[3] / 100L); }
}
void rs_4_04_10_3(char a, struct st *b) {
	int i = ji;
	v0();
	i = 4; do { gula[3] ^= 64953UL; } while (--i > 0);
}
void rs_4_04_10_4(char a, struct st *b) {
	double t = jd;
	v0();
	vd(t);
}
void rs_4_04_10_5(char a, struct st *b) {
	vs(gps);
}
void rs_4_04_10_6(char a, struct st *b) {
	gp = b->p;
}
char rs_4_04_10_7(char a, struct st *b) {
	return gc * (char)!gua[7];
}
void rs_4_04_11_0(int a, unsigned long b, unsigned long c) {
	unsigned long t = c + gul;
	jul = t;
}
void rs_4_04_11_1(int a, unsigned long b, unsigned long c) {
	gda[1] = -100.0;
}
void rs_4_04_11_2(int a, unsigned long b, unsigned long c) {
	guca[6] += guca[0];
}
void rs_4_04_11_3(int a, unsigned long b, unsigned long c) {
	unsigned long t = jul;
	gul = t;
}
unsigned long rs_4_04_11_4(int a, unsigned long b, unsigned long c) {
	return (((unsigned char)gul) != 255 ? 41939UL : (gula[a] >> 2));
}
void rs_4_04_12_0(struct st *a) {
	unsigned long t = (gd != gda[0] ? gul : gula[6]);
	jul = t;
}
void rs_4_04_12_1(struct st *a) {
	*gpi %= 16;
}
void rs_4_04_12_2(struct st *a) {
	unsigned long t = jul;
	t = -t;
}
void rs_4_04_12_3(struct st *a) {
	gi2 = (int)255 & (gi + 16);
}
int rs_4_04_12_4(struct st *a) {
	return 2;
}
void rs_4_04_13_0(unsigned long a, long b, unsigned long c) {
	int t = gps->i;
	ji = t;
}
void rs_4_04_13_1(unsigned long a, long b, unsigned long c) {
	double u = gd;
	jd = u;
}
void rs_4_04_13_2(unsigned long a, long b, unsigned long c) {
	gc = gs.c;
}
void rs_4_04_13_3(unsigned long a, long b, unsigned long c) {
	gpi = rpi(gps->i);
}
void rs_4_04_13_4(unsigned long a, long b, unsigned long c) {
	double u = jd;
	v0();
	gd = u;
}
void rs_4_04_13_5(unsigned long a, long b, unsigned long c) {
	if (gps->l <= gpl[1]) if (gp[0] != 0) gs.c = gc2 / gp[0];
}
void rs_4_04_13_6(unsigned long a, long b, unsigned long c) {
	b = rl(gl2);
}
void rs_4_04_13_7(unsigned long a, long b, unsigned long c) {
	int t = ji;
	v0();
	gul -= c | gula[t];
}
void rs_4_04_14_1(char *a) {
	char t = (char)!gia[1];
	jc = t;
}
void rs_4_04_14_2(char *a) {
	int *u = gpi;
	jpi = u;
}
void rs_4_04_14_3(char *a) {
	int *u = jpi;
	gs.u = (gs.u << 10) % 10;
}
void rs_4_04_14_4(char *a) {
	int i = ji;
	char t = jc;
	for (i = 4; i > 0; i--) { --gi3; if (t != 0) t = t / t; gp = gps->p; }
}
void rs_4_04_14_5(char *a) {
	a++;
}
void rs_4_04_14_6(char *a) {
	char t = jc;
	gula[t] = gul;
}
int rs_4_04_14_7(char *a) {
	return (gi << 4) >> 6;
}
void rs_4_04_15_0(unsigned char a) {
	unsigned int t = gu << 7;
	ju = t;
}
void rs_4_04_15_1(unsigned char a) {
	gps->c = 0;
}
void rs_4_04_15_2(unsigned char a) {
	v1(gps->a[1]);
}
void rs_4_04_15_3(unsigned char a) {
	unsigned int t = ju;
	v0();
	gu = t;
}
void rs_4_04_15_4(unsigned char a) {
	if (gca[6] == 'A' || guca[3] & 0x7) vp(rp());
}
unsigned long rs_4_04_15_5(unsigned char a) {
	return gul;
}
void rs_4_04_16_1(int *a, int b) {
	int t = (r2(gi2, a[0]) ? 256 : gi3);
	ji = t;
}
void rs_4_04_16_2(int *a, int b) {
	int u = *a >> 11;
	v0();
	ji = u;
}
void rs_4_04_16_3(int *a, int b) {
	gps->l = rl(gl);
}
void rs_4_04_16_4(int *a, int b) {
	int u = ji;
	v0();
	gi = u;
}
void rs_4_04_16_5(int *a, int b) {
	int t = ji;
	v0();
	gi = t;
}
void rs_4_04_16_6(int *a, int b) {
	int i = ji;
	v0();
	i = 0; while (i < b) { guca[i] = (gs.i == 8 ? 255 : guca[i]); i++; }
}
char rs_4_04_16_7(int *a, int b) {
	int t = ji;
	int u = ji;
	v0();
	return gc & (gua[t] < 3 ? (char)gps->u : gp[0]);
}
void rs_4_04_17_0(unsigned int a, int b, unsigned char c) {
	unsigned char t = guca[0];
	juc = t;
}
void rs_4_04_17_1(unsigned int a, int b, unsigned char c) {
	vc(gs.c | gc2);
}
void rs_4_04_17_2(unsigned int a, int b, unsigned char c) {
	unsigned char t = juc;
	v0();
	guc = t;
}
void rs_4_04_17_3(unsigned int a, int b, unsigned char c) {
	gu2 += gu2 % 2;
}
unsigned long rs_4_04_17_4(unsigned int a, int b, unsigned char c) {
	return (unsigned long)!65536L;
}
void rs_4_04_18_0(long a) {
	long t = gla[5] - 49358L;
	jl = t;
}
void rs_4_04_18_1(long a) {
	++gpi;
}
void rs_4_04_18_2(long a) {
	gua[5] = gu2 = gps->u;
}
void rs_4_04_18_3(long a) {
	gl2 -= a;
}
void rs_4_04_18_4(long a) {
	++guc;
}
void rs_4_04_18_5(long a) {
	long t = jl;
	vl(t);
}
void rs_4_04_18_6(long a) {
	if (gc2 != 0) gc2 = (char)gula[6] % gc2;
}
int rs_4_04_18_7(long a) {
	return (int)gs.u;
}
void rs_4_04_19_0(double a, char b, char c) {
	int t = gs.i - gs.a[c];
	ji = t;
}
void rs_4_04_19_1(double a, char b, char c) {
	v0();
}
void rs_4_04_19_2(double a, char b, char c) {
	int t = ji;
	v0();
	v1(t);
}
void rs_4_04_19_3(double a, char b, char c) {
	gula[b] = gul + 55050UL;
}
void rs_4_04_19_4(double a, char b, char c) {
	gs.d *= (gs.l ? gd : gs.d);
}
int rs_4_04_19_5(double a, char b, char c) {
	return !(guca[0] - guc);
}
void rs_4_05_00_0(void) {
	gi2 |= gps->i;
}
void rs_4_05_00_1(void) {
	gla[7] = -59074L - gl;
}
char * rs_4_05_00_2(void) {
	return gps->p;
}
void rs_4_05_01_0(void) {
	int *t = gpi;
	jpi = t;
}
void rs_4_05_01_1(void) {
	unsigned int u = gu2 | gua[3];
	ju = u;
}
void rs_4_05_01_2(void) {
	gi3 = ~100 / 2;
}
void rs_4_05_01_3(void) {
	int *t = jpi;
	v1(*t);
}
void rs_4_05_01_4(void) {
	if (*gp != 0) gc = gca[5] % *gp;
}
void rs_4_05_01_5(void) {
	*gpl &= gla[2] + 65536L;
}
void rs_4_05_01_6(void) {
	unsigned int u = ju;
	v0();
	if (gca[1] && !gc2) gl2 &= gla[u] & (long)gi3;
}
char rs_4_05_01_7(void) {
	unsigned int u = ju;
	v0();
	return (char)!(gula[u] - gul);
}
void rs_4_05_02_0(unsigned long a, unsigned long b) {
	unsigned char t = guc;
	juc = t;
}
void rs_4_05_02_1(unsigned long a, unsigned long b) {
	unsigned char t = juc;
	if (a) { if (gu != 0) gu = gps->u / gu; if (gia[0] != 0) gs.a[t] = gs.i / gia[0]; } else { if (gul != 0) a = a % gul; if (gp[1] != 0) gca[t] = (char)t / gp[1]; }
}
void rs_4_05_02_2(unsigned long a, unsigned long b) {
	unsigned char t = juc;
	v2(gi2, gs.a[t]);
}
void rs_4_05_02_3(unsigned long a, unsigned long b) {
	switch (gps->u) { case 0: gp[1] += gc; break; case 1: case 2: case 3: vc(gs.c); break; default: vu(gu2); break; }
}
void rs_4_05_02_4(unsigned long a, unsigned long b) {
	gc -= rc(255);
}
void rs_4_05_02_5(unsigned long a, unsigned long b) {
	unsigned char t = juc;
	v0();
	t = guc & (guc - t);
}
int * rs_4_05_02_6(unsigned long a, unsigned long b) {
	return gpi;
}
void rs_4_05_03_0(char *a, int b, int c) {
	int t = gi3;
	ji = t;
}
void rs_4_05_03_1(char *a, int b, int c) {
	int t = ji;
	gca[t] = a[1] = rc(!3912L);
}
void rs_4_05_03_2(char *a, int b, int c) {
	guc = guca[0] = (guc / 16) << 7;
}
void rs_4_05_03_3(char *a, int b, int c) {
	*gpl = (gi3 & 2 ? (long)gc2 : gla[b]);
}
void rs_4_05_03_4(char *a, int b, int c) {
	int t = ji;
	v0();
	if (gul != 0) gula[t] = gula[b] % gul;
}
void rs_4_05_03_5(char *a, int b, int c) {
	gula[b] = 9UL;
}
void rs_4_05_04_0(long a, double b, char *c) {
	int t = gs.i << 10;
	ji = t;
}
void rs_4_05_04_1(long a, double b, char *c) {
	int t = ji;
	gc -= (char)(guc > guca[t]);
}
void rs_4_05_04_2(long a, double b, char *c) {
	while (gi-- > 0) *c++ = 2;
}
void rs_4_05_04_3(long a, double b, char *c) {
	int t = ji;
	if (!gs.a[t]) { v1((int)gula[0]); }
}
void rs_4_05_04_4(long a, double b, char *c) {
	int t = ji;
	v0();
	gca[t] = gc2 - (gca[t] / 10);
}
unsigned long rs_4_05_04_5(long a, double b, char *c) {
	return ~2UL ^ ~6UL;
}
void rs_4_05_05_0(long *a) {
	unsigned char t = ((unsigned char)gl) >> 3;
	juc = t;
}
void rs_4_05_05_1(long *a) {
	unsigned char t = juc;
	char *u = gs.p + t;
	jp = u;
}
void rs_4_05_05_2(long *a) {
	char *u = jp;
	gp[0] -= u[5] ^ *gp;
}
void rs_4_05_05_3(long *a) {
	v2(gs.a[1] / 100, gi);
}
void rs_4_05_05_4(long *a) {
	unsigned char t = juc;
	v0();
	if (gi < gpi[2]) { if (gu != 0) gu2 = gua[t] % gu; gua[2] = gu = gu2; }
}
void rs_4_05_05_5(long *a) {
	gul = rul(gul % 100UL);
}
char * rs_4_05_05_6(long *a) {
	return gs.p;
}
void rs_4_05_06_0(void) {
	char *t = &gca[6];
	jp = t;
}
void rs_4_05_06_1(void) {
	double u = gda[2] - gd2;
	jd = u;
}
long rs_4_05_06_2(void) {
	if (gda[2] > 3.0) return 65536L + gpl[2];
}
void rs_4_05_06_3(void) {
	char *t = jp;
	gp = t;
}
void rs_4_05_06_4(void) {
	double u = jd;
	gd = u;
}
void rs_4_05_06_5(void) {
	vp(gps->p);
}
long rs_4_05_06_6(void) {
	return gs.l;
}
void rs_4_05_07_1(double a) {
	vd((gula[4] < 75133UL ? 3.0 : gd2));
}
void rs_4_05_07_2(double a) {
	++gpi;
}
void rs_4_05_07_3(double a) {
	int i = ji;
	v0();
	for (i = 0; i < 13; i++) { gpi = gpi + i; }
}
void rs_4_05_07_4(double a) {
	gca[2] = gps->c;
}
unsigned long rs_4_05_07_5(double a) {
	return (unsigned long)!gi;
}
void rs_4_05_08_0(int a) {
	char *u = jp;
	unsigned int t = gps->u;
	ju = t;
}
void rs_4_05_08_1(int a) {
	char *u = rp();
	jp = u;
}
void rs_4_05_08_2(int a) {
	gi2 = ~gs.i << 14;
}
void rs_4_05_08_3(int a) {
	unsigned int t = ju;
	v0();
	gu2 = (unsigned int)(gs.i >= gps->a[t]);
}
void rs_4_05_08_4(int a) {
	char *u = jp;
	v0();
	gp[2] = -u[3] - (gca[a] % 2);
}
void rs_4_05_08_5(int a) {
	vp(gps->p + a);
}
void rs_4_05_08_6(int a) {
	unsigned int t = ju;
	v0();
	gula[t] = gul = 3UL;
}
unsigned int rs_4_05_08_7(int a) {
	unsigned int t = ju;
	v0();
	return -gu2 - ((unsigned int)!t);
}
void rs_4_05_09_0(unsigned char a, int b) {
	int t = b * 7;
	ji = t;
}
void rs_4_05_09_1(unsigned char a, int b) {
	int u = gs.i;
	ji = u;
}
void rs_4_05_09_2(unsigned char a, int b) {
	int t = ji;
	gi = t;
}
void rs_4_05_09_3(unsigned char a, int b) {
	gs.c = ~gp[2];
}
void rs_4_05_09_4(unsigned char a, int b) {
	int u = ji;
	if (gs.i != 0) u = u / gs.i;
}
void rs_4_05_09_5(unsigned char a, int b) {
	int u = ji;
	switch (u) { case 0: guc *= 6; break; case 1: gc /= 7; break; case 2: vd(2.5); break; default: *gpl = *gpl + gs.l; break; }
}
void rs_4_05_09_6(unsigned char a, int b) {
	vc(gc);
}
int rs_4_05_09_7(unsigned char a, int b) {
	return 100;
}
void rs_4_05_10_0(char a) {
	int *t = gpi;
	jpi = t;
}
void rs_4_05_10_1(char a) {
	vs(gps);
}
void rs_4_05_10_2(char a) {
	vl(gla[a]);
}
void rs_4_05_10_3(char a) {
	gd2 -= 0.5;
}
void rs_4_05_10_4(char a) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_4_05_10_5(char a) {
	vc(-gp[2]);
}
int rs_4_05_10_6(char a) {
	return (((unsigned int)!gua[a]) != (32767 + gua[4]));
}
void rs_4_05_11_0(int a, int b, unsigned int c) {
	char *t = gp + c;
	jp = t;
}
void rs_4_05_11_1(int a, int b, unsigned int c) {
	gc2 = *gp = (*gp & 3) << 4;
}
void rs_4_05_11_2(int a, int b, unsigned int c) {
	gi--;
}
void rs_4_05_11_3(int a, int b, unsigned int c) {
	char *t = jp;
	gp = t;
}
char * rs_4_05_11_4(int a, int b, unsigned int c) {
	return gps->p;
}
void rs_4_05_12_0(unsigned char a, char b) {
	gi &= (gc <= '0' ? gi2 : 3);
}
void rs_4_05_12_1(unsigned char a, char b) {
	a += guc;
}
void rs_4_05_12_2(unsigned char a, char b) {
	a = guc;
}
void rs_4_05_12_3(unsigned char a, char b) {
	v0();
}
void rs_4_05_12_4(unsigned char a, char b) {
	gla[1] = 65536L ^ *gpl;
}
int rs_4_05_12_5(unsigned char a, char b) {
	return *gpi;
}
void rs_4_05_13_1(int a, int *b) {
	int i = ji;
	i = 0; while (i < a) { if (gi != 0) gps->i = a / gi; guc = guca[i]; if (gu != 0) gu = 255 / gu; i++; }
}
void rs_4_05_13_2(int a, int *b) {
	gul += (unsigned long)gla[a];
}
void rs_4_05_13_3(int a, int *b) {
	gpl[0] = gl2;
}
int rs_4_05_13_4(int a, int *b) {
	int i = ji;
	return gps->i;
}
void rs_4_05_14_0(char *a, unsigned long b) {
	vc(a[0]);
}
void rs_4_05_14_1(char *a, unsigned long b) {
	gpi[2] = gs.i + *gpi;
}
void rs_4_05_14_2(char *a, unsigned long b) {
	gula[6] = gul + 82196UL;
}
void rs_4_05_14_3(char *a, unsigned long b) {
	gpi[3] = gs.i = gs.a[2];
}
int rs_4_05_14_4(char *a, unsigned long b) {
	return r1(gi);
}
void rs_4_05_15_0(unsigned char a, unsigned char b, char c) {
	long t = *gpl;
	jl = t;
}
void rs_4_05_15_1(unsigned char a, unsigned char b, char c) {
	int u = 256;
	ji = u;
}
void rs_4_05_15_2(unsigned char a, unsigned char b, char c) {
	long t = jl;
	t = rl(47679L | gla[6]);
}
void rs_4_05_15_3(unsigned char a, unsigned char b, char c) {
	v1(256 / 2);
}
void rs_4_05_15_4(unsigned char a, unsigned char b, char c) {
	int u = ji;
	v0();
	if ((u = gi3)) { vp(gps->p + c); gp = &gca[c]; }
}
int * rs_4_05_15_5(unsigned char a, unsigned char b, char c) {
	return &gia[b];
}
void rs_4_05_16_0(long a) {
	unsigned int t = gu * 4;
	ju = t;
}
void rs_4_05_16_1(long a) {
	long u = gl2;
	jl = u;
}
void rs_4_05_16_2(long a) {
	*gpi = gi3 - gps->i;
}
char * rs_4_05_16_3(long a) {
	unsigned int t = ju;
	if (guca[t] > 2) return gps->p;
}
void rs_4_05_16_4(long a) {
	long u = jl;
	gl = u;
}
char * rs_4_05_16_5(long a) {
	return gp;
}
void rs_4_05_17_0(unsigned int a, char b) {
	int t = 16;
	ji = t;
}
void rs_4_05_17_1(unsigned int a, char b) {
	gda[3] = (r2(gi2, 1) ? gs.d : gd);
}
void rs_4_05_17_2(unsigned int a, char b) {
	int t = ji;
	v0();
	v1(t);
}
void rs_4_05_17_3(unsigned int a, char b) {
	if (guca[4] != ((unsigned char)gula[b])) { gs.u = gua[4] + gua[2]; if (gps->u != 0) gu2 = gu % gps->u; }
}
char * rs_4_05_17_4(unsigned int a, char b) {
	return gp;
}
void rs_4_05_18_0(unsigned long a) {
	int t = gia[3] >> 1;
	ji = t;
}
void rs_4_05_18_1(unsigned long a) {
	char u = gca[1];
	jc = u;
}
void rs_4_05_18_2(unsigned long a) {
	vu(1);
}
void rs_4_05_18_3(unsigned long a) {
	char u = jc;
	v0();
	gps->u = 5762 * 6;
}
void rs_4_05_18_4(unsigned long a) {
	int t = ji;
	v0();
	gula[t] = gul;
}
unsigned long rs_4_05_18_5(unsigned long a) {
	return rul(gul);
}
void rs_4_05_19_1(int a, char *b) {
	v2(a ^ 2, gi);
}
void rs_4_05_19_2(int a, char *b) {
	if (gula[1] != 0) gula[a] = gul / gula[1];
}
void rs_4_05_19_3(int a, char *b) {
	gua[5] = -1;
}
void rs_4_05_19_4(int a, char *b) {
	--gpi;
}
void rs_4_05_19_5(int a, char *b) {
	int i = ji;
	v0();
	for (i = 0; i < 7; i++) { gu2 /= 16; if (gula[i] != 0) gul = gul % gula[i]; }
}
int rs_4_05_19_6(int a, char *b) {
	return *gpi;
}
void rs_4_06_00_0(double a, unsigned char b, struct st *c) {
	gua[b] >>= 7;
}
void rs_4_06_00_1(double a, unsigned char b, struct st *c) {
	if (gul != 0) gul = gula[b] % gul;
}
long rs_4_06_00_2(double a, unsigned char b, struct st *c) {
	return (*gpl % 100L) / 100L;
}
void rs_4_06_01_0(void) {
	gi3 -= r2(gi2, gia[4]);
}
void rs_4_06_01_1(void) {
	if (gula[2] != 0) gula[2] = 85201UL / gula[2];
}
void rs_4_06_01_2(void) {
	if (*gp != 0) *gp = gs.c % *gp;
}
void rs_4_06_02_0(void) {
	vl(65536L % 7L);
}
int * rs_4_06_02_1(void) {
	if (guca[2]) return gpi;
}
int * rs_4_06_02_2(void) {
	if (!gla[3] || 3 >= 1) return gpi;
}
int * rs_4_06_02_3(void) {
	return gpi;
}
void rs_4_06_03_0(int a, long b) {
	gua[0] = ((unsigned int)*gpi) | gua[a];
}
void rs_4_06_03_1(int a, long b) {
	if (gca[2]) gd -= -gd2;
}
void rs_4_06_03_2(int a, long b) {
	gi = !(-b);
}
int rs_4_06_03_3(int a, long b) {
	return (gpi[3] & gps->a[a]) - (256 >> (a & 15));
}
void rs_4_06_04_0(int a) {
	int t = gia[7] / 2;
	ji = t;
}
void rs_4_06_04_1(int a) {
	v2(gi2, 100 & gia[a]);
}
void rs_4_06_04_2(int a) {
	v2(gi2, gs.a[a] % 4);
}
void rs_4_06_04_3(int a) {
	int t = ji;
	v0();
	gi = t;
}
void rs_4_06_04_4(int a) {
	while (a-- > 0) *gpi++ = 100;
}
void rs_4_06_04_5(int a) {
	++gpi;
}
void rs_4_06_05_0(void) {
	if (!gs.c) gps->p = gp;
}
void rs_4_06_05_1(void) {
	*gpi ^= (int)26133UL;
}
void rs_4_06_05_2(void) {
	switch (gc2) { case 0: guca[1] = guc + 6; break; case 1: vl(gl); break; case 2: gi = gs.i = (int)guca[5] << 5; break; default: vu(gps->u); break; }
}
void rs_4_06_05_3(void) {
	gp = gs.p + 1;
}
void rs_4_06_06_0(void) {
	unsigned char t = guca[1];
	juc = t;
}
void rs_4_06_06_1(void) {
	unsigned char t = juc;
	guca[t] >>= 4;
}
void rs_4_06_06_2(void) {
	gi3 %= 3;
}
void rs_4_06_06_3(void) {
	gc++;
}
void rs_4_06_06_4(void) {
	gs.p = gp;
}
void rs_4_06_06_5(void) {
	gla[7] |= gla[4] + 61842L;
}
int rs_4_06_06_6(void) {
	unsigned char t = juc;
	return (gi3 <= gs.i) + (gps->a[t] & gi);
}
void rs_4_06_07_1(double a, unsigned long b) {
	gs.d -= gda[0] / 0.5;
}
void rs_4_06_07_2(double a, unsigned long b) {
	int i = ji;
	for (i = 0; i < 10; i++) { gi3++; gps->i += gi3 - gpi[0]; gs.c = -gca[i]; }
}
void rs_4_06_07_3(double a, unsigned long b) {
	v1(*gpi >> 15);
}
void rs_4_06_07_4(double a, unsigned long b) {
	vd(-gd);
}
void rs_4_06_07_5(double a, unsigned long b) {
	vs(gps);
}
unsigned int rs_4_06_07_6(double a, unsigned long b) {
	return ((unsigned int)!(int)guc) << 5;
}
void rs_4_06_08_1(struct st *a, char b) {
	unsigned char t = guca[b] & 128;
	juc = t;
}
void rs_4_06_08_2(struct st *a, char b) {
	if (gc != 0) gc2 = gp[1] % gc;
}
void rs_4_06_08_3(struct st *a, char b) {
	int i = ji;
	for (i = 4; i > 0; i--) { gp = gps->p; }
}
void rs_4_06_08_4(struct st *a, char b) {
	unsigned char t = juc;
	t = (a->c ? (-((unsigned char)gia[t])) : t);
}
unsigned long rs_4_06_08_5(struct st *a, char b) {
	return (((unsigned long)*gpi) + gul) - (gula[0] - gul);
}
void rs_4_06_09_0(int a) {
	unsigned char t = guca[a];
	juc = t;
}
void rs_4_06_09_1(int a) {
	gda[2] = -gda[2];
}
void rs_4_06_09_2(int a) {
	gl2 = 65536L % 4L;
}
void rs_4_06_09_3(int a) {
	unsigned char t = juc;
	t = ((unsigned char)(38 < t)) << 6;
}
void rs_4_06_09_4(int a) {
	gul = 2UL;
}
void rs_4_06_10_0(int a) {
	int t = (r2(a, gi) ? gia[4] : 127);
	ji = t;
}
void rs_4_06_10_1(int a) {
	char *u = gps->p;
	v0();
	jp = u;
}
void rs_4_06_10_2(int a) {
	int t = ji;
	v0();
	gd2 = (!t ? -gd2 : gd);
}
unsigned int rs_4_06_10_3(int a) {
	char *u = jp;
	v0();
	if (gps->u) return ru(gps->u);
}
void rs_4_06_10_4(int a) {
	char *u = jp;
	v0();
	if (a & 0x10) { if (gul != 0) gul = gul / gul; if (u[2] != 0) gc2 = gc / u[2]; gd2 = (gd2 / 3.0) / 0.25; }
}
unsigned int rs_4_06_10_5(int a) {
	return gu;
}
void rs_4_06_11_0(unsigned int a) {
	long t = ~gps->l;
	jl = t;
}
void rs_4_06_11_1(unsigned int a) {
	gua[a] = gu2 = a;
}
long rs_4_06_11_2(unsigned int a) {
	if (!gula[a]) return 65536L;
}
void rs_4_06_11_3(unsigned int a) {
	vu(gu - 255);
}
void rs_4_06_11_4(unsigned int a) {
	long t = jl;
	v0();
	gl = t;
}
void rs_4_06_11_5(unsigned int a) {
	gc2 *= 12;
}
long rs_4_06_11_6(unsigned int a) {
	long t = jl;
	v0();
	return (long)!t | rl(gla[3]);
}
void rs_4_06_12_0(unsigned char a) {
	int t = 2;
	ji = t;
}
void rs_4_06_12_1(unsigned char a) {
	char *u = gs.p;
	jp = u;
}
void rs_4_06_12_2(unsigned char a) {
	gda[1] += gd / 100.0;
}
void rs_4_06_12_3(unsigned char a) {
	char *u = jp;
	vp(u);
}
void rs_4_06_12_4(unsigned char a) {
	int t = ji;
	v0();
	gla[0] <<= (t & 15);
}
void rs_4_06_12_5(unsigned char a) {
	vl(gl - gps->l);
}
void rs_4_06_12_6(unsigned char a) {
	gd2 = 3.0;
}
char rs_4_06_12_7(unsigned char a) {
	return (char)!(gps->c >> 3);
}
void rs_4_06_13_1(int a, unsigned char b) {
	unsigned long t = gul + gula[b];
	jul = t;
}
void rs_4_06_13_2(int a, unsigned char b) {
	guca[4] = guca[1] + guca[b];
}
void rs_4_06_13_3(int a, unsigned char b) {
	unsigned long t = jul;
	if (!gul) { gl2 = (gpl[1] | 65536L) % 100L; } else { if (gula[a] != 0) t = 8UL / gula[a]; v0(); if (gla[6] != 0) gpl[3] = gl2 / gla[6]; }
}
void rs_4_06_13_4(int a, unsigned char b) {
	int i = ji;
	v0();
	for (i = 5; i > 0; i--) { if (gpl[2] != 0) gla[0] = 67292L / gpl[2]; }
}
void rs_4_06_13_5(int a, unsigned char b) {
	gca[a] <<= 1;
}
unsigned long rs_4_06_13_6(int a, unsigned char b) {
	unsigned long t = jul;
	v0();
	return (t = gula[b]);
}
void rs_4_06_14_0(unsigned long a) {
	int t = ~gps->a[6];
	ji = t;
}
void rs_4_06_14_1(unsigned long a) {
	double u = -gd2;
	jd = u;
}
void rs_4_06_14_2(unsigned long a) {
	gp = gps->p;
}
void rs_4_06_14_3(unsigned long a) {
	int t = ji;
	switch (gs.l) { case 0L: gc2 = gca[t] << (t & 7); break; case 1L: vs(gps); case 2L: gpi = gpi + t; break; case 3L: vs(gps); break; }
}
void rs_4_06_14_4(unsigned long a) {
	double u = jd;
	v0();
	vd(u);
}
void rs_4_06_14_5(unsigned long a) {
	int t = ji;
	v0();
	a = (gua[t] ? gul : gula[5]) + (gul / 10UL);
}
void rs_4_06_14_6(unsigned long a) {
	int t = ji;
	v0();
	if (gula[t] & 0x10) ++gpi;
}
char * rs_4_06_14_7(unsigned long a) {
	return gs.p;
}
void rs_4_06_15_1(unsigned char a) {
	double t = (gi3 & 0x80 ? gs.d : gd);
	jd = t;
}
void rs_4_06_15_2(unsigned char a) {
	unsigned int u = ~gu;
	ju = u;
}
void rs_4_06_15_3(unsigned char a) {
	int i = ji;
	unsigned int u = ju;
	i = 0; while (i < 2) { if (gi2 != 0) gi = gpi[2] % gi2; vu(ru(u)); v0(); i++; }
}
void rs_4_06_15_4(unsigned char a) {
	double t = jd;
	v0();
	vd(t);
}
void rs_4_06_15_5(unsigned char a) {
	gca[a] = gc;
}
void rs_4_06_15_6(unsigned char a) {
	a--;
}
void rs_4_06_15_7(unsigned char a) {
	int i = ji;
	unsigned int u = ju;
	v0();
	gul = gula[7] = (unsigned long)(((int)gla[u] - gi) == ((int)gla[3] - gs.i));
}
unsigned int rs_4_06_15_8(unsigned char a) {
	return (unsigned int)!(~gi);
}
void rs_4_06_16_1(int *a, int b, long c) {
	int *t = a;
	jpi = t;
}
void rs_4_06_16_2(int *a, int b, long c) {
	int *t = jpi;
	v1(*t);
}
void rs_4_06_16_3(int *a, int b, long c) {
	int i = ji;
	v0();
	i = 8; do { if (gul != 0) gula[i] = gula[i] / gul; if (*gpi != 0) b = gs.a[i] / *gpi; gula[i] = 0x10000UL; } while (--i > 0);
}
void rs_4_06_16_4(int *a, int b, long c) {
	gula[b] += rul(gula[4]);
}
char rs_4_06_16_5(int *a, int b, long c) {
	return 0;
}
void rs_4_06_17_0(void) {
	char t = '0' ^ 7;
	jc = t;
}
void rs_4_06_17_1(void) {
	int u = *gpi;
	ji = u;
}
void rs_4_06_17_2(void) {
	gu2 = gu;
}
void rs_4_06_17_3(void) {
	int u = ji;
	gc2 <<= (u & 7);
}
void rs_4_06_17_4(void) {
	char t = jc;
	gca[1] = t;
}
void rs_4_06_17_5(void) {
	int u = ji;
	if (32767 > 1 || gu2 < 12186) if (gla[u] != 0) gps->l = gpl[0] % gla[u];
}
void rs_4_06_17_6(void) {
	*gpl = (long)(gi2 + gs.a[4]);
}
int * rs_4_06_17_7(void) {
	return gpi;
}
void rs_4_06_18_0(void) {
	long t = gps->l >> 3;
	jl = t;
}
void rs_4_06_18_1(void) {
	long t = jl;
	long u = t;
	jl = u;
}
void rs_4_06_18_2(void) {
	vd(gd2 / 2.5);
}
void rs_4_06_18_3(void) {
	long u = jl;
	v0();
	u <<= 3;
}
void rs_4_06_18_4(void) {
	gpi++;
}
void rs_4_06_18_5(void) {
	long t = jl;
	v0();
	vl(t);
}
void rs_4_06_18_6(void) {
	gu = 256 << 5;
}
long rs_4_06_18_7(void) {
	long t = jl;
	long u = jl;
	v0();
	return (5451 != ((unsigned int)gul) ? (gua[6] <= gu2 ? u : u) : (65536L - t));
}
void rs_4_06_19_0(unsigned char a, int *b, long *c) {
	int t = gps->i + gi;
	ji = t;
}
void rs_4_06_19_1(unsigned char a, int *b, long *c) {
	if (65536L <= gl2) gpl[2] = (gla[7] - gs.l) % 10L;
}
void rs_4_06_19_2(unsigned char a, int *b, long *c) {
	int t = ji;
	if (gps->a[t]) { if (gs.l != 0) gl = gs.l / gs.l; }
}
void rs_4_06_19_3(unsigned char a, int *b, long *c) {
	gps->u = gu + gua[a];
}
void rs_4_06_19_4(unsigned char a, int *b, long *c) {
	int t = ji;
	guc = guca[t] = guc | (255 - guca[0]);
}
void rs_4_06_19_5(unsigned char a, int *b, long *c) {
	if (gua[a] > gu) { if (gu2 != 0) gua[7] = gs.u % gu2; vu(gu << 9); }
}
unsigned long rs_4_06_19_6(unsigned char a, int *b, long *c) {
	return gul;
}
void rs_4_07_00_1(long a, char b) {
	int i = ji;
	i = 0; while (i < 6) { vs(gps); gd2 *= gd * gs.d; i++; }
}
void rs_4_07_00_2(long a, char b) {
	guc <<= 5;
}
void rs_4_07_01_0(int a, unsigned int b) {
	double t = 3.0;
	jd = t;
}
void rs_4_07_01_1(int a, unsigned int b) {
	unsigned int u = gs.u + b;
	ju = u;
}
void rs_4_07_01_2(int a, unsigned int b) {
	gla[b] = gl ^ 7L;
}
void rs_4_07_01_3(int a, unsigned int b) {
	vl(gpl[0]);
}
void rs_4_07_01_4(int a, unsigned int b) {
	unsigned int u = ju;
	v0();
	vu(u);
}
void rs_4_07_01_5(int a, unsigned int b) {
	double t = jd;
	v0();
	vd(t);
}
long rs_4_07_01_6(int a, unsigned int b) {
	return rl(gl2) * (gpl[1] + 65536L);
}
void rs_4_07_02_1(unsigned char a, unsigned long b, char c) {
	unsigned long t = rul(0x10000UL);
	jul = t;
}
void rs_4_07_02_2(unsigned char a, unsigned long b, char c) {
	int *u = rpi((int)gps->l);
	v0();
	jpi = u;
}
void rs_4_07_02_3(unsigned char a, unsigned long b, char c) {
	int i = ji;
	v0();
	for (i = 2; i > 0; i--) { v2(gi2, gi3); }
}
void rs_4_07_02_4(unsigned char a, unsigned long b, char c) {
	if (gca[a] >= gs.c) { gca[a] = gps->c << 1; } else { if (gl >= gs.l) guc = (gca[c] == -30 ? guc : (a * guc)); }
}
void rs_4_07_02_5(unsigned char a, unsigned long b, char c) {
	unsigned long t = jul;
	v0();
	--t;
}
void rs_4_07_02_6(unsigned char a, unsigned long b, char c) {
	gla[1] = gl | -97327L;
}
void rs_4_07_02_7(unsigned char a, unsigned long b, char c) {
	int *u = jpi;
	v0();
	if (gu2 != 0) gs.u = gs.u / gu2;
}
void rs_4_07_03_0(int a, int *b, long c) {
	gul = ~((unsigned long)!guc);
}
void rs_4_07_03_1(int a, int *b, long c) {
	v0();
}
void rs_4_07_03_2(int a, int *b, long c) {
	if (gs.c) { gda[1] = gda[2]; } else { if (gua[6] != 0) gu2 = gu % gua[6]; guc--; }
}
unsigned long rs_4_07_03_3(int a, int *b, long c) {
	return gula[4];
}
void rs_4_07_04_0(void) {
	gua[5] = gu - 1;
}
void rs_4_07_04_1(void) {
	gca[6] = (char)gl2 & gc2;
}
void rs_4_07_04_2(void) {
	if (gl2 != 0) gl = gl2 % gl2;
}
void rs_4_07_04_3(void) {
	guca[6] = guc = (unsigned char)!(!(int)guc);
}
void rs_4_07_04_4(void) {
	if ((gc2 = gps->c) > -40) gl2 = (long)gua[7];
}
void rs_4_07_05_0(unsigned long a, char b, long *c) {
	int t = 100;
	ji = t;
}
void rs_4_07_05_1(unsigned long a, char b, long *c) {
	int t = ji;
	long u = gla[t] << (b & 15);
	jl = u;
}
void rs_4_07_05_2(unsigned long a, char b, long *c) {
	int t = ji;
	t = !2 - ((int)gua[t] % 10);
}
void rs_4_07_05_3(unsigned long a, char b, long *c) {
	gpi = &gia[7];
}
void rs_4_07_05_4(unsigned long a, char b, long *c) {
	gp = gs.p;
}
void rs_4_07_05_5(unsigned long a, char b, long *c) {
	long u = jl;
	gl = u;
}
void rs_4_07_05_6(unsigned long a, char b, long *c) {
	a = ((unsigned long)!128) & (a * gula[5]);
}
void rs_4_07_05_7(unsigned long a, char b, long *c) {
	v0();
}
int rs_4_07_05_8(unsigned long a, char b, long *c) {
	int t = ji;
	v0();
	return t + !8643;
}
void rs_4_07_06_0(char a, unsigned char b) {
	char *t = rp();
	jp = t;
}
void rs_4_07_06_1(char a, unsigned char b) {
	char u = gs.c;
	v0();
	jc = u;
}
void rs_4_07_06_2(char a, unsigned char b) {
	char u = jc;
	v0();
	gc = u;
}
void rs_4_07_06_3(char a, unsigned char b) {
	char *t = jp;
	v0();
	gua[5] = (unsigned int)!t[6];
}
void rs_4_07_06_4(char a, unsigned char b) {
	a = gc2;
}
int * rs_4_07_06_5(char a, unsigned char b) {
	return rpi(2 % 16);
}
void rs_4_07_07_0(void) {
	char t = gca[2] << 7;
	jc = t;
}
void rs_4_07_07_1(void) {
	char t = jc;
	char u = gca[t];
	jc = u;
}
void rs_4_07_07_2(void) {
	*gp *= 9;
}
void rs_4_07_07_3(void) {
	gul = (unsigned long)-255;
}
unsigned int rs_4_07_07_4(void) {
	char u = jc;
	if (gs.a[u] & 0x8) return 32767;
}
void rs_4_07_07_5(void) {
	char t = jc;
	gc = t;
}
void rs_4_07_07_6(void) {
	char u = jc;
	if (u == 7) if (gu2 != 0) gps->u = gps->u / gu2;
}
void rs_4_07_07_7(void) {
	gul = 0x10000UL;
}
unsigned int rs_4_07_07_8(void) {
	return ~gua[4];
}
void rs_4_07_08_1(double a, int b) {
	long t = *gpl / 3L;
	jl = t;
}
void rs_4_07_08_2(double a, int b) {
	char u = gp[2] / 2;
	jc = u;
}
void rs_4_07_08_3(double a, int b) {
	gs.d = 100.0;
}
void rs_4_07_08_4(double a, int b) {
	gpi = gpi + b;
}
void rs_4_07_08_5(double a, int b) {
	char u = jc;
	switch (gl2) { case 0L: vc(u); case 1L: gps->u = gu; break; case 2L: gul = (unsigned long)u; break; case 3L: vp(gps->p); break; default: gula[2] = gula[3] << 27; break; }
}
void rs_4_07_08_6(double a, int b) {
	int i = ji;
	v0();
	i = 3; do { gula[i] = gula[7] + gul; } while (--i > 0);
}
void rs_4_07_08_7(double a, int b) {
	long t = jl;
	v0();
	gl = t;
}
long rs_4_07_08_8(double a, int b) {
	return ~(gla[6] + 87477L);
}
void rs_4_07_09_0(int *a, unsigned long b, int c) {
	int t = r1(*gpi);
	ji = t;
}
void rs_4_07_09_1(int *a, unsigned long b, int c) {
	int t = ji;
	int u = t;
	v0();
	ji = u;
}
void rs_4_07_09_2(int *a, unsigned long b, int c) {
	gl2--;
}
void rs_4_07_09_3(int *a, unsigned long b, int c) {
	int u = ji;
	v0();
	gi = u;
}
void rs_4_07_09_4(int *a, unsigned long b, int c) {
	int t = ji;
	v0();
	v1(t);
}
void rs_4_07_09_5(int *a, unsigned long b, int c) {
	if (gu) gps->p = gp;
}
void rs_4_07_10_0(long a) {
	unsigned long t = 7971UL;
	jul = t;
}
void rs_4_07_10_1(long a) {
	unsigned int u = gu << 3;
	ju = u;
}
void rs_4_07_10_2(long a) {
	++gpi;
}
void rs_4_07_10_3(long a) {
	unsigned long t = jul;
	vl((long)t);
}
char * rs_4_07_10_4(long a) {
	unsigned int u = ju;
	v0();
	if (gc > gca[u]) return rp();
}
char * rs_4_07_10_5(long a) {
	unsigned int u = ju;
	v0();
	return gs.p + u;
}
void rs_4_07_11_1(void) {
	double t = gda[3] / 3.0;
	jd = t;
}
void rs_4_07_11_2(void) {
	unsigned long u = gula[4];
	jul = u;
}
void rs_4_07_11_3(void) {
	double t = jd;
	gda[2] *= t * gd2;
}
void rs_4_07_11_4(void) {
	guc++;
}
void rs_4_07_11_5(void) {
	unsigned long u = jul;
	vl((long)u);
}
void rs_4_07_11_6(void) {
	int i = ji;
	v0();
	for (i = 3; i > 0; i--) { if (i != 0) gpi[2] = 255 % i; gpl[3] = gla[i] << (i & 15); guc = (guca[i] + 178) + (guc >> 1); }
}
void rs_4_07_11_7(void) {
	*gpl = gl;
}
int * rs_4_07_11_8(void) {
	return rpi(gps->a[7] >> 1);
}
void rs_4_07_12_1(unsigned long a, long b) {
	int i = ji;
	int t = (b >= 65536L ? gps->i : gps->i);
	ji = t;
}
void rs_4_07_12_2(unsigned long a, long b) {
	unsigned long u = 5UL;
	jul = u;
}
void rs_4_07_12_3(unsigned long a, long b) {
	vd(gd2);
}
void rs_4_07_12_4(unsigned long a, long b) {
	unsigned long u = jul;
	v0();
	vl((long)u);
}
void rs_4_07_12_5(unsigned long a, long b) {
	int t = ji;
	v0();
	if (*gpl <= (long)gc) { gc %= 16; if (gua[t] != 0) gu = gua[t] / gua[t]; } else { guca[3] = guca[2]; }
}
void rs_4_07_12_6(unsigned long a, long b) {
	gu = 255;
}
void rs_4_07_12_7(unsigned long a, long b) {
	int i = ji;
	v0();
	for (i = 0; i < 10; i++) { if (gc2 != 0) gps->c = gc2 / gc2; }
}
char * rs_4_07_12_8(unsigned long a, long b) {
	return rp();
}
void rs_4_07_13_0(void) {
	vs(gps);
}
void rs_4_07_13_1(void) {
	gula[1] -= gul & 0x10000UL;
}
int * rs_4_07_13_2(void) {
	return gpi;
}
void rs_4_07_14_0(long a) {
	int *t = gpi;
	jpi = t;
}
void rs_4_07_14_1(long a) {
	char u = gca[5] % 4;
	jc = u;
}
void rs_4_07_14_2(long a) {
	int *t = jpi;
	gpi = t;
}
void rs_4_07_14_3(long a) {
	gc = (gp[3] & *gp) % 10;
}
void rs_4_07_14_4(long a) {
	char u = jc;
	gc = u;
}
void rs_4_07_14_5(long a) {
	v0();
}
unsigned long rs_4_07_14_6(long a) {
	return gul;
}
void rs_4_07_15_0(unsigned long a, long b) {
	unsigned long t = gula[4] & gul;
	jul = t;
}
void rs_4_07_15_1(unsigned long a, long b) {
	unsigned long t = jul;
	vl((long)t);
}
void rs_4_07_15_2(unsigned long a, long b) {
	if (!gla[4]) { --gpi; gps->u = gu << 15; } else { gua[1] = (gua[0] * 6) - gu; gca[3] += gca[1] << 5; }
}
void rs_4_07_15_3(unsigned long a, long b) {
	vl(*gpl);
}
void rs_4_07_15_4(unsigned long a, long b) {
	gps->i = gi / 4;
}
unsigned long rs_4_07_15_5(unsigned long a, long b) {
	return rul(gula[0] >> 4);
}
void rs_4_07_16_0(unsigned int a) {
	double t = gd / 0.25;
	jd = t;
}
void rs_4_07_16_1(unsigned int a) {
	gula[0] = rul(gula[a]);
}
void rs_4_07_16_2(unsigned int a) {
	gps->i &= gps->a[a] / 10;
}
void rs_4_07_16_3(unsigned int a) {
	--gpi;
}
void rs_4_07_16_4(unsigned int a) {
	double t = jd;
	v0();
	gd = t;
}
void rs_4_07_16_5(unsigned int a) {
	gc *= 2;
}
void rs_4_07_16_6(unsigned int a) {
	if (!gl) { a = gu2; if (gl2 != 0) gl = gla[a] / gl2; if (gia[2] != 0) gs.i = gia[5] % gia[2]; } else { vl(gps->l << 22); if (gps->c != 0) gp[3] = *gp / gps->c; }
}
int rs_4_07_16_7(unsigned int a) {
	return gs.a[0] - gpi[1];
}
void rs_4_07_17_1(struct st *a, long *b) {
	int *t = gpi;
	jpi = t;
}
void rs_4_07_17_2(struct st *a, long *b) {
	int i = ji;
	for (i = 8; i > 0; i--) { gca[i] = -92; gu = gua[1] = (unsigned int)gul; gps->p = gp; }
}
void rs_4_07_17_3(struct st *a, long *b) {
	int *t = jpi;
	t = t + 1;
}
void rs_4_07_17_4(struct st *a, long *b) {
	--gul;
}
void rs_4_07_17_5(struct st *a, long *b) {
	gul = gula[5] = gula[0];
}
void rs_4_07_17_6(struct st *a, long *b) {
	while (gi-- > 0) *b++ = 93213L;
}
int rs_4_07_17_7(struct st *a, long *b) {
	return -(gpi[1] % 10);
}
void rs_4_07_18_0(unsigned char a, unsigned long b) {
	gc--;
}
void rs_4_07_18_1(unsigned char a, unsigned long b) {
	b--;
}
unsigned int rs_4_07_18_2(unsigned char a, unsigned long b) {
	return gps->u;
}
void rs_4_07_19_0(void) {
	unsigned int t = gu ^ 255;
	ju = t;
}
void rs_4_07_19_1(void) {
	double u = 0.5 + 1.0;
	jd = u;
}
void rs_4_07_19_2(void) {
	unsigned int t = ju;
	gc2 >>= (t & 7);
}
void rs_4_07_19_3(void) {
	++gi2;
}
void rs_4_07_19_4(void) {
	gula[6] -= gul;
}
void rs_4_07_19_5(void) {
	unsigned int t = ju;
	vu(gu - t);
}
void rs_4_07_19_6(void) {
	unsigned int t = ju;
	double u = jd;
	v0();
	if (*gpl > gl && gp[3] == 0) { if (gula[t] != 0) gula[t] = gul % gula[t]; vu(ru(t)); gpl[2] = (long)gul; } else { gd = (u / 2.5) - -2.5; gd2 -= u; gi2 *= 11; }
}
char * rs_4_07_19_7(void) {
	return gp;
}
void rs_4_08_00_0(long a, int b, int c) {
	int t = ~gia[4];
	ji = t;
}
int rs_4_08_00_1(long a, int b, int c) {
	int t = ji;
	if (gul <= gula[t]) return 8;
}
void rs_4_08_00_2(long a, int b, int c) {
	v0();
}
void rs_4_08_00_3(long a, int b, int c) {
	switch (gc) { case 1: a <<= 9; break; case 3: gla[c] = gl << 1; break; case 16: v2(b, gi); break; default: vc((char)gu); break; }
}
int rs_4_08_00_4(long a, int b, int c) {
	int t = ji;
	v0();
	return (gpi[0] ^ t) & 331;
}
void rs_4_08_01_0(char *a, int b, unsigned char c) {
	int *t = gpi;
	jpi = t;
}
void rs_4_08_01_1(char *a, int b, unsigned char c) {
	a[2] = gc;
}
void rs_4_08_01_2(char *a, int b, unsigned char c) {
	int *t = jpi;
	gpi = t;
}
unsigned int rs_4_08_01_3(char *a, int b, unsigned char c) {
	if (r0()) return 11449;
}
void rs_4_08_01_4(char *a, int b, unsigned char c) {
	if (gu2 != 0) gu = gua[2] / gu2;
}
unsigned int rs_4_08_01_5(char *a, int b, unsigned char c) {
	return gu2;
}
unsigned int rs_4_08_02_0(long a, int *b, char c) {
	if ((int)guca[c] < gia[7]) return ((unsigned int)c) & gu2;
}
void rs_4_08_02_1(long a, int *b, char c) {
	gps->i <<= (c & 15);
}
void rs_4_08_02_2(long a, int *b, char c) {
	guc |= ~guca[c];
}
void rs_4_08_02_3(long a, int *b, char c) {
	vl(gps->l >> 5);
}
unsigned int rs_4_08_02_4(long a, int *b, char c) {
	return 255;
}
void rs_4_08_03_0(void) {
	char t = (char)!guc;
	jc = t;
}
void rs_4_08_03_1(void) {
	int u = r2(gpi[3], gi);
	ji = u;
}
void rs_4_08_03_2(void) {
	gp = gs.p;
}
void rs_4_08_03_3(void) {
	char t = jc;
	v0();
	vc(t);
}
void rs_4_08_03_4(void) {
	int u = ji;
	v0();
	if (gi2 == 2) gul = (unsigned long)(rul((unsigned long)guca[u]) > (gul - gula[u]));
}
void rs_4_08_03_5(void) {
	gu = (unsigned int)((unsigned char)gu);
}
void rs_4_08_03_6(void) {
	gs.l = gl;
}
void rs_4_08_03_7(void) {
	int u = ji;
	v0();
	u -= u | gpi[0];
}
int rs_4_08_03_8(void) {
	return *gpi;
}
void rs_4_08_04_0(char a, unsigned int b) {
	double t = gd * gs.d;
	jd = t;
}
void rs_4_08_04_1(char a, unsigned int b) {
	guc = guca[b] = 128 & guca[6];
}
void rs_4_08_04_2(char a, unsigned int b) {
	double t = jd;
	vd(t);
}
void rs_4_08_04_3(char a, unsigned int b) {
	guca[1] = guc - 128;
}
void rs_4_08_04_4(char a, unsigned int b) {
	gda[0] -= 10.0 * gs.d;
}
void rs_4_08_04_5(char a, unsigned int b) {
	gs.d = (a >= gc2 ? gd : gs.d);
}
void rs_4_08_05_0(int a, long b) {
	unsigned long t = (gda[2] >= gs.d ? gula[3] : gula[a]);
	jul = t;
}
void rs_4_08_05_1(int a, long b) {
	gu &= gu2 + gs.u;
}
void rs_4_08_05_2(int a, long b) {
	v2(gi2, gi >> 11);
}
void rs_4_08_05_3(int a, long b) {
	if (gu2 != 0) gu = gu2 / gu2;
}
void rs_4_08_05_4(int a, long b) {
	unsigned long t = jul;
	v0();
	gul = (((unsigned long)gua[0]) < gula[a] ? (gula[a] >> (a & 15)) : t);
}
int rs_4_08_05_5(int a, long b) {
	return gps->i << (a & 15);
}
void rs_4_08_06_0(int a, struct st *b, int c) {
	int t = b->a[5];
	ji = t;
}
void rs_4_08_06_1(int a, struct st *b, int c) {
	gi2 = (int)gul;
}
void rs_4_08_06_2(int a, struct st *b, int c) {
	int t = ji;
	if (gl2 < gpl[0]) { b->l -= *gpl >> (c & 15); if (gula[a] != 0) gula[0] = gul % gula[a]; a = (t >> 4) - 1; } else { gs.u &= (gula[3] & 0x80 ? gps->u : gu); }
}
void rs_4_08_06_3(int a, struct st *b, int c) {
	gla[6] |= gpl[2];
}
int rs_4_08_06_4(int a, struct st *b, int c) {
	return (int)gla[c];
}
void rs_4_08_07_0(unsigned char a) {
	gc = ~(gc / 16);
}
void rs_4_08_07_1(unsigned char a) {
	guca[a] = guc = 255;
}
void rs_4_08_07_2(unsigned char a) {
	vd(gs.d * gda[3]);
}
void rs_4_08_07_3(unsigned char a) {
	a = (unsigned char)((gps->l % 16L) != gl);
}
char rs_4_08_07_4(unsigned char a) {
	return -47;
}
void rs_4_08_08_0(char a, char b, unsigned char c) {
	int t = gia[0];
	ji = t;
}
void rs_4_08_08_1(char a, char b, unsigned char c) {
	int t = ji;
	v2(gi2, (gula[t] == gula[4]));
}
void rs_4_08_08_2(char a, char b, unsigned char c) {
	gi3 = gps->a[a];
}
void rs_4_08_08_3(char a, char b, unsigned char c) {
	gl2--;
}
void rs_4_08_08_4(char a, char b, unsigned char c) {
	int t = ji;
	v0();
	gca[t] = ((char)(b < gps->c)) & gs.c;
}
void rs_4_08_08_5(char a, char b, unsigned char c) {
	guc += ~c;
}
int rs_4_08_08_6(char a, char b, unsigned char c) {
	int t = ji;
	v0();
	return (gia[t] = gi);
}
void rs_4_08_09_0(void) {
	unsigned char t = ~guc;
	juc = t;
}
void rs_4_08_09_1(void) {
	unsigned char t = juc;
	gc2 = (char)!gu2 & (gca[t] | gca[3]);
}
void rs_4_08_09_2(void) {
	if ((gl = gpl[0])) { if (gul != 0) gul = gul / gul; if (gca[4] != 0) *gp = gca[2] / gca[4]; gi3 -= gia[6] % 7; }
}
void rs_4_08_09_3(void) {
	unsigned char t = juc;
	gula[t] = gula[t] + 0x10000UL;
}
void rs_4_08_09_4(void) {
	if (gi < -152) if (gi3 != 0) gs.a[1] = gi % gi3;
}
int rs_4_08_09_5(void) {
	unsigned char t = juc;
	return gia[t];
}
void rs_4_08_10_0(char a) {
	char *t = gps->p + a;
	jp = t;
}
void rs_4_08_10_1(char a) {
	char *u = gs.p;
	jp = u;
}
void rs_4_08_10_2(char a) {
	char *u = jp;
	gps->l = (long)u[a];
}
void rs_4_08_10_3(char a) {
	char *t = jp;
	gp = t;
}
void rs_4_08_10_4(char a) {
	gul--;
}
char rs_4_08_10_5(char a) {
	return (a + -91) % 4;
}
void rs_4_08_11_0(void) {
	char *t = rp();
	jp = t;
}
void rs_4_08_11_1(void) {
	char *t = jp;
	v0();
	vp(t);
}
void rs_4_08_11_2(void) {
	gpl[3] = gla[2] = (gu & 1 ? (gla[0] ^ gla[3]) : (long)!gs.c);
}
void rs_4_08_11_3(void) {
	gpi = &gia[7];
}
void rs_4_08_11_4(void) {
	guc ^= 255 + ((unsigned char)gl);
}
void rs_4_08_11_5(void) {
	vl(gpl[1] + gps->l);
}
void rs_4_08_11_6(void) {
	if (9 != guca[2]) { if (gs.u != 0) gs.u = gu2 % gs.u; } else { guc = -(68 << 3); gca[4] = gs.c; }
}
void rs_4_08_12_0(void) {
	unsigned char t = guc * guca[0];
	juc = t;
}
void rs_4_08_12_1(void) {
	unsigned char t = juc;
	gul = gula[t] = (gula[5] - gul) - (((unsigned long)gua[0]) * 3UL);
}
void rs_4_08_12_2(void) {
	++gul;
}
unsigned long rs_4_08_12_3(void) {
	return gul >> 20;
}
void rs_4_08_13_0(void) {
	guc = guca[4] ^ guc;
}
void rs_4_08_13_1(void) {
	gua[2] = (unsigned int)(((unsigned int)guc) > 32767);
}
void rs_4_08_13_2(void) {
	gl = (long)!(4L << 26);
}
int rs_4_08_13_3(void) {
	return !1;
}
void rs_4_08_14_1(void) {
	unsigned int t = gu >> 6;
	ju = t;
}
void rs_4_08_14_2(void) {
	char *u = &gca[2];
	jp = u;
}
void rs_4_08_14_3(void) {
	gd = -(gd - gs.d);
}
void rs_4_08_14_4(void) {
	int i = ji;
	i = 0; while (i < 7) { gl *= 3L; i++; }
}
void rs_4_08_14_5(void) {
	char *u = jp;
	vp(u);
}
void rs_4_08_14_6(void) {
	int i = ji;
	v0();
	for (i = 0; i < 16; i++) { gpi++; gl = gla[i]; gl2 = (gc2 > 1 ? gpl[0] : gps->l) * 6L; }
}
void rs_4_08_14_7(void) {
	unsigned int t = ju;
	v0();
	t += gu2;
}
void rs_4_08_14_8(void) {
	if (gl2 != 0) gla[7] = *gpl / gl2;
}
int rs_4_08_14_9(void) {
	unsigned int t = ju;
	v0();
	return gs.a[t] - gi3;
}
void rs_4_08_15_0(unsigned long a) {
	unsigned int t = gps->u & gu;
	ju = t;
}
void rs_4_08_15_1(unsigned long a) {
	gc2 <<= 3;
}
void rs_4_08_15_2(unsigned long a) {
	unsigned int t = ju;
	if (guca[t] || gpi[1] != gi) { a--; }
}
char rs_4_08_15_3(unsigned long a) {
	return (char)!gs.u;
}
void rs_4_08_16_0(unsigned char a, struct st *b, struct st *c) {
	int *t = gpi;
	jpi = t;
}
void rs_4_08_16_1(unsigned char a, struct st *b, struct st *c) {
	int *t = jpi;
	--t;
}
void rs_4_08_16_2(unsigned char a, struct st *b, struct st *c) {
	gi2--;
}
void rs_4_08_16_3(unsigned char a, struct st *b, struct st *c) {
	gs.u /= 16;
}
void rs_4_08_16_4(unsigned char a, struct st *b, struct st *c) {
	if (gps->i != 0) gi2 = 16 / gps->i;
}
void rs_4_08_16_5(unsigned char a, struct st *b, struct st *c) {
	a = ((unsigned char)!gula[1]) | (guca[4] + guc);
}
void rs_4_08_17_0(unsigned char a, unsigned long b) {
	int t = gi;
	ji = t;
}
void rs_4_08_17_1(unsigned char a, unsigned long b) {
	unsigned int u = gu;
	ju = u;
}
void rs_4_08_17_2(unsigned char a, unsigned long b) {
	gia[2] = r0();
}
void rs_4_08_17_3(unsigned char a, unsigned long b) {
	gul -= (unsigned long)gu;
}
void rs_4_08_17_4(unsigned char a, unsigned long b) {
	gc2 = -93 / 4;
}
void rs_4_08_17_5(unsigned char a, unsigned long b) {
	int t = ji;
	v0();
	gca[t] %= 16;
}
void rs_4_08_17_6(unsigned char a, unsigned long b) {
	vl(gl2);
}
void rs_4_08_17_7(unsigned char a, unsigned long b) {
	unsigned int u = ju;
	v0();
	gu = u;
}
int * rs_4_08_17_8(unsigned char a, unsigned long b) {
	return gpi;
}
void rs_4_08_18_0(void) {
	gia[4] = 654;
}
void rs_4_08_18_1(void) {
	gul = (gula[7] + 5UL) | (gul * gula[2]);
}
void rs_4_08_18_2(void) {
	gc2 = (guc == 128 && (gua[1] = gua[2]) >= 800 ? gca[5] : (gs.c - *gp));
}
int * rs_4_08_18_3(void) {
	return gpi;
}
void rs_4_08_19_0(void) {
	int t = gia[1] & *gpi;
	ji = t;
}
void rs_4_08_19_1(void) {
	int t = ji;
	char u = gca[t];
	jc = u;
}
void rs_4_08_19_2(void) {
	gp--;
}
void rs_4_08_19_3(void) {
	int t = ji;
	gi = t;
}
void rs_4_08_19_4(void) {
	char u = jc;
	guca[u] = ~guc;
}
void rs_4_08_19_5(void) {
	if (3.0 < gs.d) --gpi;
}
void rs_4_08_19_6(void) {
	vc(*gp | gca[3]);
}
unsigned int rs_4_08_19_7(void) {
	return (23 != -36 ? (((unsigned int)gul) / 10) : ((unsigned int)(gul >= gula[6])));
}
void rs_4_09_00_0(char *a, int b, long c) {
	while (b-- > 0) { if (*a == '9') break; a++; }
}
unsigned long rs_4_09_00_1(char *a, int b, long c) {
	if ((gc2 = *gp)) return (unsigned long)!gps->l;
}
void rs_4_09_00_2(char *a, int b, long c) {
	gpi--;
}
void rs_4_09_00_3(char *a, int b, long c) {
	if (gca[b] <= 5) { *a = gs.c = (char)!(gul / 16UL); gia[0] -= r0(); }
}
void rs_4_09_00_4(char *a, int b, long c) {
	gul++;
}
unsigned long rs_4_09_00_5(char *a, int b, long c) {
	return (gula[b] = gula[5]);
}
void rs_4_09_01_0(struct st *a, unsigned int b, unsigned char c) {
	unsigned long t = (unsigned long)!100;
	jul = t;
}
void rs_4_09_01_1(struct st *a, unsigned int b, unsigned char c) {
	if (gc2 != 0) gc2 = gc / gc2;
}
void rs_4_09_01_2(struct st *a, unsigned int b, unsigned char c) {
	gla[b] = gla[c] * 10L;
}
void rs_4_09_01_3(struct st *a, unsigned int b, unsigned char c) {
	gu2--;
}
void rs_4_09_01_4(struct st *a, unsigned int b, unsigned char c) {
	unsigned long t = jul;
	gul = t;
}
char * rs_4_09_01_5(struct st *a, unsigned int b, unsigned char c) {
	return rp();
}
void rs_4_09_02_0(char a, char b) {
	int t = gia[b];
	ji = t;
}
void rs_4_09_02_1(char a, char b) {
	int t = ji;
	if (gda[1] == gd) { gl2 = (gl - -10726L) + (gla[5] * (long)gula[t]); if (gua[7] != 0) gs.u = 32767 % gua[7]; gs.l |= 65536L; }
}
void rs_4_09_02_2(char a, char b) {
	++guc;
}
void rs_4_09_02_3(char a, char b) {
	int t = ji;
	gul -= gul >> (t & 15);
}
void rs_4_09_02_4(char a, char b) {
	guca[a] = guc = (255 ^ guca[b]) + (guc & 128);
}
unsigned int rs_4_09_02_5(char a, char b) {
	return ru(gps->u + 1);
}
void rs_4_09_03_0(int a) {
	vl(gl % 10L);
}
void rs_4_09_03_1(int a) {
	vs(gps);
}
void rs_4_09_03_2(int a) {
	vd(1.0);
}
int * rs_4_09_03_3(int a) {
	return rpi(gia[a]);
}
void rs_4_09_04_1(char a, long b) {
	long t = b;
	jl = t;
}
void rs_4_09_04_2(char a, long b) {
	gua[3] = gua[0] + gua[4];
}
void rs_4_09_04_3(char a, long b) {
	gu2 = (1 | gu2) << 1;
}
void rs_4_09_04_4(char a, long b) {
	long t = jl;
	vl(t);
}
void rs_4_09_04_5(char a, long b) {
	int i = ji;
	v0();
	i = 0; while (i < 16) { guc += guc >> 2; gul = gula[i]; vs(gps); i++; }
}
void rs_4_09_05_0(void) {
	long t = ~gl;
	jl = t;
}
void rs_4_09_05_1(void) {
	long u = 65536L ^ gl2;
	jl = u;
}
void rs_4_09_05_2(void) {
	long u = jl;
	vl(u);
}
void rs_4_09_05_3(void) {
	if ((long)gs.c == gl2) gu = gua[2];
}
void rs_4_09_05_4(void) {
	guc = (gi2 & 0x80 ? (128 << 4) : guc);
}
void rs_4_09_05_5(void) {
	long t = jl;
	v0();
	vl(t);
}
char rs_4_09_05_6(void) {
	return (char)guc;
}
void rs_4_09_06_0(void) {
	unsigned long t = (unsigned long)gps->l;
	jul = t;
}
void rs_4_09_06_1(void) {
	unsigned long t = jul;
	gul = t;
}
void rs_4_09_06_2(void) {
	vp(rp());
}
void rs_4_09_06_3(void) {
	gi2 = -(int)gca[0];
}
char * rs_4_09_06_4(void) {
	return gp;
}
void rs_4_09_07_0(unsigned long a, unsigned long b, struct st *c) {
	int *t = gpi;
	jpi = t;
}
void rs_4_09_07_1(unsigned long a, unsigned long b, struct st *c) {
	unsigned long u = ~gul;
	jul = u;
}
void rs_4_09_07_2(unsigned long a, unsigned long b, struct st *c) {
	unsigned long u = jul;
	gul = u;
}
void rs_4_09_07_3(unsigned long a, unsigned long b, struct st *c) {
	gu2 *= 6;
}
void rs_4_09_07_4(unsigned long a, unsigned long b, struct st *c) {
	int *t = jpi;
	gpi = t;
}
int rs_4_09_07_5(unsigned long a, unsigned long b, struct st *c) {
	if (!gul) return gs.a[3] / 100;
}
void rs_4_09_07_6(unsigned long a, unsigned long b, struct st *c) {
	vl((long)c->a[4] & 4L);
}
void rs_4_09_07_7(unsigned long a, unsigned long b, struct st *c) {
	gc = (*gp >> 3) | (gc2 % 2);
}
int rs_4_09_07_8(unsigned long a, unsigned long b, struct st *c) {
	return gi;
}
void rs_4_09_08_0(long a, int *b, int c) {
	unsigned long t = gula[c];
	jul = t;
}
void rs_4_09_08_1(long a, int *b, int c) {
	gc2 -= 78;
}
void rs_4_09_08_2(long a, int *b, int c) {
	unsigned long t = jul;
	gul = t;
}
void rs_4_09_08_3(long a, int *b, int c) {
	gp[0] = (char)(guc == (guca[c] | 128));
}
void rs_4_09_08_4(long a, int *b, int c) {
	gp[2] >>= (c & 7);
}
void rs_4_09_08_5(long a, int *b, int c) {
	v2(gi2, r1(256));
}
void rs_4_09_08_6(long a, int *b, int c) {
	switch (gc2) { case 2: vl(gl2); break; case 5: gpi = &gia[4]; break; case 8: guca[c] >>= 3; break; }
}
long rs_4_09_08_7(long a, int *b, int c) {
	unsigned long t = jul;
	v0();
	return ~(t ? gl2 : (long)gca[2]);
}
void rs_4_09_09_0(void) {
	gi2 = gi3;
}
void rs_4_09_09_1(void) {
	gs.u = ru(gu);
}
int * rs_4_09_09_2(void) {
	return &gia[5];
}
void rs_4_09_10_1(int *a, unsigned char b, double c) {
	int *t = &gia[3];
	jpi = t;
}
void rs_4_09_10_2(int *a, unsigned char b, double c) {
	char u = gs.c;
	jc = u;
}
void rs_4_09_10_3(int *a, unsigned char b, double c) {
	char u = jc;
	if (!gc) { v0(); } else { if (gu != 0) gua[5] = gu / gu; gps->p = &gca[2]; if (gp[0] != 0) u = u / gp[0]; }
}
void rs_4_09_10_4(int *a, unsigned char b, double c) {
	char u = jc;
	v0();
	if (b > 128 && u > '0') { if (gul != 0) gul = gul % gul; u = ('z' >> (b & 7)) + gps->c; }
}
void rs_4_09_10_5(int *a, unsigned char b, double c) {
	int i = ji;
	v0();
	for (i = 0; i < 13; i++) { if (gl != 0) *gpl = gla[i] % gl; gs.p = gp + b; guca[i] &= (unsigned char)!gu; }
}
void rs_4_09_10_6(int *a, unsigned char b, double c) {
	int *t = jpi;
	v0();
	--t;
}
int rs_4_09_10_7(int *a, unsigned char b, double c) {
	char u = jc;
	v0();
	return (gps->a[u] - gi3) << 11;
}
void rs_4_09_11_0(void) {
	vs(gps);
}
void rs_4_09_11_1(void) {
	gda[3] = gda[2] + gd;
}
void rs_4_09_11_2(void) {
	gps->p = rp();
}
void rs_4_09_11_3(void) {
	while (gi-- > 0) *gp++ = 100;
}
unsigned int rs_4_09_11_4(void) {
	return (gu2 << 3) - ru(gu2);
}
void rs_4_09_12_0(void) {
	gul += 1UL;
}
void rs_4_09_12_1(void) {
	if (gps->c < gc) { vs(gps); gua[6] -= (unsigned int)gula[1]; } else { *gpi = (int)65536L; }
}
void rs_4_09_12_2(void) {
	gc = (*gp | 88) * rc(gi3);
}
void rs_4_09_12_3(void) {
	gla[6] = rl(gl);
}
unsigned int rs_4_09_12_4(void) {
	return (unsigned int)(*gp ^ gc2);
}
void rs_4_09_13_0(void) {
	char t = gc2 - 5;
	jc = t;
}
void rs_4_09_13_1(void) {
	gda[1] -= -gda[0];
}
void rs_4_09_13_2(void) {
	while (gi-- > 0) *gp++ = 8;
}
void rs_4_09_13_3(void) {
	if (!gl) if (gu2 != 0) gu = gs.u % gu2;
}
void rs_4_09_13_4(void) {
	v0();
}
void rs_4_09_13_5(void) {
	char t = jc;
	v0();
	vc(t);
}
void rs_4_09_13_6(void) {
	gd -= 0.25 * 1.0;
}
unsigned int rs_4_09_13_7(void) {
	return (gps->u = ((unsigned int)gi2));
}
void rs_4_09_14_0(int a, char b, unsigned char c) {
	unsigned long t = 0x10000UL - gul;
	jul = t;
}
void rs_4_09_14_1(int a, char b, unsigned char c) {
	unsigned long t = jul;
	if (t != 0) t = 1UL % t;
}
void rs_4_09_14_2(int a, char b, unsigned char c) {
	vs(gps);
}
void rs_4_09_14_3(int a, char b, unsigned char c) {
	gl2 = gl = (gpl[0] ^ 65536L) % 4L;
}
void rs_4_09_14_4(int a, char b, unsigned char c) {
	gua[c] = ((unsigned int)gc2) - gu2;
}
char rs_4_09_14_5(int a, char b, unsigned char c) {
	return gc2;
}
void rs_4_09_15_0(unsigned char a, unsigned int b) {
	if (gul || gula[a]) { if (gc != 0) gca[4] = *gp / gc; gul--; gua[a] -= ((unsigned int)gc) - 255; }
}
void rs_4_09_15_1(unsigned char a, unsigned int b) {
	gul -= rul(gul);
}
unsigned int rs_4_09_15_2(unsigned char a, unsigned int b) {
	return 32767 * 5;
}
void rs_4_09_16_1(unsigned int a, long b) {
	int i = ji;
	i = 11; do { a = gu2; } while (--i > 0);
}
void rs_4_09_16_2(unsigned int a, long b) {
	if (gps->c == gc2) { if (gpl[1] != 0) gl2 = gla[a] % gpl[1]; vc(gca[a] % 2); }
}
void rs_4_09_16_3(unsigned int a, long b) {
	v0();
}
void rs_4_09_16_4(unsigned int a, long b) {
	gl = (long)guc;
}
unsigned long rs_4_09_16_5(unsigned int a, long b) {
	return 0x10000UL;
}
void rs_4_09_17_1(unsigned char a, int b, unsigned int c) {
	double t = gd2 + gd2;
	jd = t;
}
void rs_4_09_17_2(unsigned char a, int b, unsigned int c) {
	unsigned int u = 1;
	ju = u;
}
void rs_4_09_17_3(unsigned char a, int b, unsigned int c) {
	int i = ji;
	unsigned int u = ju;
	switch (gps->i) { case 1: vu(u); break; case 2: guc ^= a; break; case 5: case 16: v0(); break; case 20: vp(gp); break; case 200: gpi = rpi(gps->a[b]); break; default: guc = ~guc; break; }
}
void rs_4_09_17_4(unsigned char a, int b, unsigned int c) {
	double t = jd;
	v0();
	gd = t;
}
int rs_4_09_17_5(unsigned char a, int b, unsigned int c) {
	if (gi2) return gi2 >> 3;
}
void rs_4_09_17_6(unsigned char a, int b, unsigned int c) {
	gc2 = -(*gp - gs.c);
}
void rs_4_09_17_7(unsigned char a, int b, unsigned int c) {
	unsigned int u = ju;
	v0();
	gul >>= (u & 15);
}
void rs_4_09_17_8(unsigned char a, int b, unsigned int c) {
	int i = ji;
	v0();
	i = 10; do { gla[i] *= 10L; v2((int)gc, gi); } while (--i > 0);
}
int rs_4_09_17_9(unsigned char a, int b, unsigned int c) {
	return gia[1];
}
void rs_4_09_18_0(void) {
	double t = gd2 - gs.d;
	jd = t;
}
void rs_4_09_18_1(void) {
	unsigned long u = (unsigned long)gia[5];
	jul = u;
}
void rs_4_09_18_2(void) {
	vp(gp);
}
void rs_4_09_18_3(void) {
	double t = jd;
	v0();
	gd = t;
}
void rs_4_09_18_4(void) {
	v1(gia[7]);
}
void rs_4_09_18_5(void) {
	unsigned long u = jul;
	v0();
	vl((long)u);
}
char rs_4_09_18_6(void) {
	return gs.c + (gp[1] + gc2);
}
void rs_4_09_19_0(int a) {
	unsigned int t = ~gu2;
	ju = t;
}
void rs_4_09_19_1(int a) {
	vu(ru(1));
}
void rs_4_09_19_2(int a) {
	unsigned int t = ju;
	v0();
	if (t <= 256) gs.l = (gc2 ? gpl[2] : *gpl);
}
long rs_4_09_19_3(int a) {
	return gl2;
}
