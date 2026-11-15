/* Every statement line of random6 alone in its own function (gen_rstmt.py corpus/validation/random6 6): rs_<A>_<BB>_<CC>_<k> is line k of
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

void rs_6_00_00_1(char a, unsigned char b) {
	long t = gla[6];
	jl = t;
}
void rs_6_00_00_2(char a, unsigned char b) {
	int i = ji;
	i = 0; while (i < 2) { ++gl; gps->i = gs.a[i] + (int)*gp; if (gul != 0) gula[7] = gula[i] / gul; i++; }
}
void rs_6_00_00_3(char a, unsigned char b) {
	long t = jl;
	vl(t);
}
void rs_6_00_00_4(char a, unsigned char b) {
	gul = rul(0x10000UL) ^ ((unsigned long)3);
}
long rs_6_00_00_5(char a, unsigned char b) {
	long t = jl;
	v0();
	return t;
}
void rs_6_00_01_0(long a) {
	unsigned long t = gula[3];
	jul = t;
}
void rs_6_00_01_1(long a) {
	gps->l >>= 15;
}
void rs_6_00_01_2(long a) {
	guca[7] /= 3;
}
void rs_6_00_01_3(long a) {
	gla[2] ^= 2L + 65536L;
}
void rs_6_00_01_4(long a) {
	vc(gc2 - gps->c);
}
void rs_6_00_01_5(long a) {
	v0();
}
void rs_6_00_01_6(long a) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
int rs_6_00_01_7(long a) {
	return r2(gi2, gs.i * 10);
}
void rs_6_00_02_0(int a, char b) {
	unsigned int t = ru(gu);
	ju = t;
}
void rs_6_00_02_1(int a, char b) {
	unsigned int t = ju;
	v0();
	switch (gc2) { case 5: case 8: gl %= 7L; break; case 10: gda[2] = gda[3] * gs.d; break; case 20: gc2 = gca[b] = gs.c << (t & 7); break; case 100: guc >>= 1; break; }
}
unsigned long rs_6_00_02_2(int a, char b) {
	unsigned int t = ju;
	v0();
	if (100 < 1 && gla[a]) return gul >> (t & 15);
}
void rs_6_00_02_3(int a, char b) {
	vl(gpl[2] << (a & 15));
}
void rs_6_00_02_4(int a, char b) {
	switch (gs.c) { case 1: v0(); break; case 3: v2(gi2, gi); break; case 10: v2(gpi[2], gi); break; default: guc = guca[6] = (unsigned char)!63340L; break; }
}
void rs_6_00_02_5(int a, char b) {
	unsigned int t = ju;
	v0();
	gu2 = t;
}
unsigned long rs_6_00_02_6(int a, char b) {
	return (gula[a] - ((unsigned long)gla[2])) / 7UL;
}
void rs_6_00_03_0(void) {
	char *t = gps->p + 1;
	jp = t;
}
void rs_6_00_03_1(void) {
	gu = ru((!guca[0] ? gu2 : 1));
}
void rs_6_00_03_2(void) {
	if ((long)gps->u <= gps->l) { vp(&gca[5]); gi += !(int)gua[2]; }
}
void rs_6_00_03_3(void) {
	char *t = jp;
	v0();
	gp = t;
}
int * rs_6_00_03_4(void) {
	return gpi + 1;
}
void rs_6_00_04_1(long *a) {
	int t = gi3;
	ji = t;
}
void rs_6_00_04_2(long *a) {
	if (gula[4]) { if (gl2 != 0) gl2 = gl2 / gl2; }
}
void rs_6_00_04_3(long *a) {
	int t = ji;
	t = (int)gla[4] * (gs.d <= 10.0);
}
void rs_6_00_04_4(long *a) {
	gs.p = rp();
}
void rs_6_00_04_5(long *a) {
	int i = ji;
	v0();
	for (i = 0; i < 11; i++) { gua[3] -= (gul < 0x10000UL ? gua[i] : gu); }
}
int rs_6_00_04_6(long *a) {
	int t = ji;
	v0();
	return (t * 6) - r0();
}
void rs_6_00_05_0(char a) {
	if (((unsigned long)gpi[1]) != gula[7]) { v2(gi2, gps->i); gl = 7L; gps->a[0] += r0(); } else { gp = gps->p + a; }
}
void rs_6_00_05_1(char a) {
	while (gi-- > 0) { if (*gp == '9') break; gp++; }
}
int * rs_6_00_05_2(char a) {
	return rpi(gs.i * gi);
}
void rs_6_00_06_0(int a, int b, int c) {
	v2(gi2 | c, gi);
}
void rs_6_00_06_1(int a, int b, int c) {
	if (gula[a] != 0) gul = gula[4] / gula[a];
}
long rs_6_00_06_2(int a, int b, int c) {
	return (gps->l ^ gpl[3]) - *gpl;
}
void rs_6_00_07_1(unsigned long a, double b, unsigned int c) {
	--c;
}
void rs_6_00_07_2(unsigned long a, double b, unsigned int c) {
	int i = ji;
	for (i = 0; i < 13; i++) { a = rul((unsigned long)guc) - (gul - a); }
}
void rs_6_00_08_0(char a, unsigned char b) {
	int *t = gpi;
	jpi = t;
}
void rs_6_00_08_1(char a, unsigned char b) {
	gd -= gd / 3.0;
}
void rs_6_00_08_2(char a, unsigned char b) {
	if (gc < 34) { b *= 4; }
}
void rs_6_00_08_3(char a, unsigned char b) {
	int *t = jpi;
	v1(*t);
}
void rs_6_00_08_4(char a, unsigned char b) {
	gda[1] = gda[1] * gd;
}
unsigned long rs_6_00_08_5(char a, unsigned char b) {
	return (((unsigned long)gua[4]) % 3UL) + gula[a];
}
void rs_6_00_09_0(int a) {
	long t = (long)(gula[4] > gul);
	jl = t;
}
void rs_6_00_09_1(int a) {
	unsigned long u = gula[a];
	jul = u;
}
void rs_6_00_09_2(int a) {
	long t = jl;
	unsigned long u = jul;
	if (gs.u > 13811) { gc2 %= 7; if (gps->l != 0) t = 65536L / gps->l; }
}
int rs_6_00_09_3(int a) {
	if (!gl2) return 16;
}
void rs_6_00_09_4(int a) {
	vc((char)(255 > 29));
}
void rs_6_00_09_5(int a) {
	vu(ru(32767));
}
void rs_6_00_09_6(int a) {
	long t = jl;
	v0();
	guc = ((unsigned char)t) * (guca[a] + 7);
}
int rs_6_00_09_7(int a) {
	return r2(gi2, (int)gu2 | gs.a[a]);
}
void rs_6_00_10_0(struct st *a, unsigned int b, char c) {
	c--;
}
void rs_6_00_10_1(struct st *a, unsigned int b, char c) {
	gps->l = -5801L / 3L;
}
int rs_6_00_10_2(struct st *a, unsigned int b, char c) {
	return (int)(guca[3] - guc);
}
void rs_6_00_11_0(int a, char b) {
	unsigned char t = guc % 3;
	juc = t;
}
void rs_6_00_11_1(int a, char b) {
	int u = (2L >= gl);
	ji = u;
}
void rs_6_00_11_2(int a, char b) {
	gl2++;
}
void rs_6_00_11_3(int a, char b) {
	unsigned char t = juc;
	guc = t;
}
void rs_6_00_11_4(int a, char b) {
	*gp = -(char)gia[4];
}
void rs_6_00_11_5(int a, char b) {
	if (gua[0] != 0) gua[a] = gua[0] % gua[0];
}
void rs_6_00_11_6(int a, char b) {
	gc2 = gc;
}
void rs_6_00_11_7(int a, char b) {
	int u = ji;
	if (gpi[1] != 0) gi = u % gpi[1];
}
void rs_6_00_12_0(void) {
	if (gul < 5512UL) gu2 = ((unsigned int)(gps->l == gl2)) % 16;
}
void rs_6_00_12_1(void) {
	v2(1, gi);
}
void rs_6_00_13_0(unsigned int a, unsigned int b) {
	double t = gd * (double)a;
	jd = t;
}
void rs_6_00_13_1(unsigned int a, unsigned int b) {
	char *u = gs.p;
	jp = u;
}
void rs_6_00_13_2(unsigned int a, unsigned int b) {
	double t = jd;
	vd(t);
}
void rs_6_00_13_3(unsigned int a, unsigned int b) {
	switch (gu) { case 16: gula[b] = gul; case 20: gula[a] -= gula[0]; break; case 200: gc2 -= *gp; break; default: v0(); break; }
}
void rs_6_00_13_4(unsigned int a, unsigned int b) {
	--gc;
}
void rs_6_00_13_5(unsigned int a, unsigned int b) {
	gi3 = (gi2 * gi) / 10;
}
void rs_6_00_13_6(unsigned int a, unsigned int b) {
	char *u = jp;
	v0();
	gp = u;
}
void rs_6_00_13_7(unsigned int a, unsigned int b) {
	vd(gd2);
}
char * rs_6_00_13_8(unsigned int a, unsigned int b) {
	char *u = jp;
	v0();
	return u;
}
void rs_6_00_14_0(unsigned long a, int b, unsigned long c) {
	int *t = rpi(gi);
	jpi = t;
}
void rs_6_00_14_1(unsigned long a, int b, unsigned long c) {
	char u = rc((int)a);
	v0();
	jc = u;
}
void rs_6_00_14_2(unsigned long a, int b, unsigned long c) {
	char u = jc;
	v0();
	gula[u] = (unsigned long)(255 > (guca[u] + 1));
}
void rs_6_00_14_3(unsigned long a, int b, unsigned long c) {
	char u = jc;
	v0();
	vu((u >= 'z' ? 255 : gua[2]));
}
void rs_6_00_14_4(unsigned long a, int b, unsigned long c) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_6_00_14_5(unsigned long a, int b, unsigned long c) {
	char u = jc;
	v0();
	gps->a[2] = gs.a[u] ^ 255;
}
unsigned long rs_6_00_14_6(unsigned long a, int b, unsigned long c) {
	return gula[b];
}
void rs_6_00_15_0(void) {
	unsigned char t = 117 & 129;
	juc = t;
}
void rs_6_00_15_1(void) {
	int u = gi << 3;
	ji = u;
}
void rs_6_00_15_2(void) {
	unsigned char t = juc;
	if (gula[t] > gul) if (gi != 0) gi = gi / gi;
}
void rs_6_00_15_3(void) {
	gs.c = gca[3] - gs.c;
}
void rs_6_00_15_4(void) {
	gl--;
}
void rs_6_00_15_5(void) {
	unsigned char t = juc;
	gla[t] = gps->l = rl(gl | gl2);
}
void rs_6_00_15_6(void) {
	unsigned char t = juc;
	int u = ji;
	v0();
	if (0x10000UL < gula[u]) { gps->l = (gla[t] ^ gpl[0]) >> 22; if (gi2 != 0) u = gs.a[3] / gi2; }
}
char * rs_6_00_15_7(void) {
	unsigned char t = juc;
	v0();
	return gs.p + t;
}
void rs_6_00_16_0(int a, struct st *b) {
	int t = a;
	ji = t;
}
void rs_6_00_16_1(int a, struct st *b) {
	int t = ji;
	gl2 >>= (t & 15);
}
void rs_6_00_16_2(int a, struct st *b) {
	if (gca[2] != gc && (gp[3] = b->c)) { guca[2] = guca[7]; } else { guca[5] = 128; vd(gs.d * gs.d); gs.i += gi3 - 6; }
}
int * rs_6_00_16_3(int a, struct st *b) {
	return rpi((gul ? gps->a[6] : gi2));
}
void rs_6_00_17_0(void) {
	char *t = rp();
	jp = t;
}
void rs_6_00_17_1(void) {
	vu(gu / 4);
}
void rs_6_00_17_2(void) {
	++gul;
}
void rs_6_00_17_3(void) {
	guca[4] /= 2;
}
void rs_6_00_17_4(void) {
	char *t = jp;
	v0();
	vp(t);
}
void rs_6_00_17_5(void) {
	vu(32767 & gua[7]);
}
void rs_6_00_17_6(void) {
	if (gula[1] != 0) gula[5] = gula[2] % gula[1];
}
long rs_6_00_17_7(void) {
	return 1L + gpl[2];
}
void rs_6_00_18_1(unsigned char a, unsigned int b) {
	int *t = &gia[b];
	jpi = t;
}
void rs_6_00_18_2(unsigned char a, unsigned int b) {
	if (91676UL < ((unsigned long)b)) { if (gula[6] != 0) gul = 0x10000UL % gula[6]; if (gp[0] != 0) *gp = gc2 % gp[0]; } else { vu(gu - 256); gl2 = (long)(((unsigned char)gc) > guca[a]); }
}
void rs_6_00_18_3(unsigned char a, unsigned int b) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_6_00_18_4(unsigned char a, unsigned int b) {
	int i = ji;
	v0();
	for (i = 4; i > 0; i--) { gi3 += *gpi << 6; }
}
void rs_6_00_18_5(unsigned char a, unsigned int b) {
	b -= (unsigned int)(-14 >= *gp);
}
long rs_6_00_18_6(unsigned char a, unsigned int b) {
	return gs.l;
}
void rs_6_00_19_1(int a, char *b) {
	gla[a] = gps->l << 9;
}
void rs_6_00_19_2(int a, char *b) {
	if ((guca[4] = guc) >= 255) { guca[a] = (unsigned char)a; if (gi2 != 0) gpi[1] = (int)gl / gi2; if (gul != 0) gula[7] = gul % gul; } else { guca[6] = guca[5] << (a & 7); if (gp[2] != 0) gc = gc2 % gp[2]; if (gca[0] != 0) gca[a] = b[0] % gca[0]; }
}
void rs_6_00_19_3(int a, char *b) {
	gu++;
}
void rs_6_00_19_4(int a, char *b) {
	gpi[1] = gia[a] << 7;
}
void rs_6_00_19_5(int a, char *b) {
	int i = ji;
	i = 0; while (i < 5) { if (gua[i] != 0) gua[i] = 32767 % gua[i]; i++; }
}
long rs_6_00_19_6(int a, char *b) {
	return (gl - 65536L) << 6;
}
void rs_6_01_00_0(void) {
	long t = gpl[0] & gl;
	jl = t;
}
void rs_6_01_00_1(void) {
	char *u = &gca[7];
	jp = u;
}
void rs_6_01_00_2(void) {
	guc = -2 - (guca[5] % 16);
}
void rs_6_01_00_3(void) {
	guc = guca[2] = (guca[2] * guca[4]) - guc;
}
void rs_6_01_00_4(void) {
	gul -= 0x10000UL + gula[5];
}
void rs_6_01_00_5(void) {
	long t = jl;
	if (gs.c < gca[7]) if (gl != 0) t = gla[0] % gl;
}
void rs_6_01_00_6(void) {
	gps->i = gi3 + 256;
}
void rs_6_01_00_7(void) {
	char *u = jp;
	vp(u);
}
long rs_6_01_00_8(void) {
	long t = jl;
	v0();
	return (t - 1L) + *gpl;
}
void rs_6_01_01_0(long *a) {
	if (r1(gia[5])) if (gp[0] != 0) gc = *gp % gp[0];
}
void rs_6_01_01_1(long *a) {
	if (r2(gi, gi) && guc > 128) { if (*gp != 0) gca[4] = (' ') / *gp; if (gps->u != 0) gs.u = gu / gps->u; } else { if (gula[5] != 0) gul = 6UL / gula[5]; vu((unsigned int)(65536L > gla[2])); }
}
void rs_6_01_01_2(long *a) {
	gula[0] = gula[0] << 3;
}
void rs_6_01_01_3(long *a) {
	gula[0] = ~gula[0];
}
char * rs_6_01_01_4(long *a) {
	return gps->p;
}
void rs_6_01_02_0(unsigned char a) {
	char *t = gps->p;
	jp = t;
}
void rs_6_01_02_1(unsigned char a) {
	double u = gda[3] + gd2;
	jd = u;
}
void rs_6_01_02_2(unsigned char a) {
	a = (unsigned char)(gs.l * gl);
}
void rs_6_01_02_3(unsigned char a) {
	if (gi2 != 0) gi2 = gps->a[a] / gi2;
}
void rs_6_01_02_4(unsigned char a) {
	double u = jd;
	if (gu2 != 0) gu = gs.u % gu2;
}
void rs_6_01_02_5(unsigned char a) {
	char *t = jp;
	switch (gs.l) { case 0L: *gpi ^= gpi[1]; break; case 1L: vp(t); break; case 2L: gc2 = *gp >> 3; break; }
}
long rs_6_01_02_6(unsigned char a) {
	return (gps->l ^ gs.l) & (-70776L / 7L);
}
void rs_6_01_03_0(unsigned char a, int *b) {
	int t = gi3 >> (a & 15);
	ji = t;
}
void rs_6_01_03_1(unsigned char a, int *b) {
	int u = gi2 << 3;
	ji = u;
}
long rs_6_01_03_2(unsigned char a, int *b) {
	if (88 >= gp[2]) return gpl[1] / 10L;
}
void rs_6_01_03_3(unsigned char a, int *b) {
	gu = 9;
}
void rs_6_01_03_4(unsigned char a, int *b) {
	int u = ji;
	gs.u &= gua[a] / 16;
}
void rs_6_01_03_5(unsigned char a, int *b) {
	int t = ji;
	v2(16 ^ t, gi);
}
long rs_6_01_03_6(unsigned char a, int *b) {
	return (gl2 = gs.l);
}
void rs_6_01_04_0(int *a, int b) {
	gul++;
}
void rs_6_01_04_1(int *a, int b) {
	switch (gps->u) { case 0: a[3] *= 9; break; case 1: gca[b] = rc(gi); break; case 2: v0(); case 3: *a = gpi[2] * 11; break; case 4: gc |= (char)gia[b]; case 5: vd(gd); break; default: vc(gc); break; }
}
int rs_6_01_04_2(int *a, int b) {
	return gi2;
}
void rs_6_01_05_0(long a, int b, unsigned long c) {
	*gpl = gl2;
}
void rs_6_01_05_1(long a, int b, unsigned long c) {
	gs.d = 2.5 / 100.0;
}
void rs_6_01_05_2(long a, int b, unsigned long c) {
	gps->a[b] = gi ^ b;
}
char rs_6_01_05_3(long a, int b, unsigned long c) {
	return (gc2 = *gp);
}
void rs_6_01_06_1(void) {
	v2(gi2, gia[1] | gps->a[6]);
}
void rs_6_01_06_2(void) {
	int i = ji;
	v0();
	for (i = 0; i < 12; i++) { gpi = gpi + i; }
}
void rs_6_01_06_3(void) {
	gul = (unsigned long)(((unsigned char)!9) <= 255);
}
void rs_6_01_06_4(void) {
	vl((long)guca[4]);
}
void rs_6_01_06_5(void) {
	gps->u = 12274;
}
int rs_6_01_06_6(void) {
	int i = ji;
	v0();
	return r2(gi2, gs.i) << 4;
}
void rs_6_01_07_1(unsigned int a) {
	vs(gps);
}
void rs_6_01_07_2(unsigned int a) {
	switch (gi3) { case 0: gl *= 2L; break; case 1: vd(gd2); break; case 2: vu(gu2); case 3: case 4: guc &= guca[0]; }
}
void rs_6_01_07_3(unsigned int a) {
	int i = ji;
	v0();
	i = 6; do { *gpi = gs.i & gia[i]; gul = gula[6] = 0x10000UL >> (i & 15); } while (--i > 0);
}
void rs_6_01_07_4(unsigned int a) {
	gps->p = gp;
}
int rs_6_01_07_5(unsigned int a) {
	int i = ji;
	v0();
	return gs.i;
}
void rs_6_01_08_0(char *a) {
	int t = gia[5] - gpi[1];
	ji = t;
}
void rs_6_01_08_1(char *a) {
	gl2++;
}
void rs_6_01_08_2(char *a) {
	gps->l = gl - 65536L;
}
void rs_6_01_08_3(char *a) {
	int t = ji;
	switch (gl) { case 8L: v1(gia[t]); break; case 10L: case 16L: gl2 = (long)t >> 28; break; }
}
void rs_6_01_08_4(char *a) {
	gc2--;
}
char * rs_6_01_08_5(char *a) {
	return rp();
}
void rs_6_01_09_1(unsigned int a, unsigned char b) {
	int *t = gpi + b;
	jpi = t;
}
void rs_6_01_09_2(unsigned int a, unsigned char b) {
	int *t = jpi;
	v1(*t);
}
void rs_6_01_09_3(unsigned int a, unsigned char b) {
	--a;
}
void rs_6_01_09_4(unsigned int a, unsigned char b) {
	gp[3] += 'z' ^ 1;
}
void rs_6_01_09_5(unsigned int a, unsigned char b) {
	if (gl > *gpl) gul = (2UL - gul) << 30;
}
void rs_6_01_09_6(unsigned int a, unsigned char b) {
	int i = ji;
	v0();
	for (i = 10; i > 0; i--) { gps->l += ~*gpl; if (gl2 != 0) gla[i] = gla[i] % gl2; }
}
void rs_6_01_09_7(unsigned int a, unsigned char b) {
	if (r0()) if (gps->a[a] != 0) *gpi = 127 / gps->a[a];
}
int * rs_6_01_09_8(unsigned int a, unsigned char b) {
	return rpi((guca[1] != 5 ? gi3 : gi3));
}
void rs_6_01_10_1(unsigned long a, double b) {
	int t = r2(gi2, gi2);
	ji = t;
}
void rs_6_01_10_2(unsigned long a, double b) {
	int u = gi % 3;
	v0();
	ji = u;
}
void rs_6_01_10_3(unsigned long a, double b) {
	gda[1] -= gda[0] + 10.0;
}
void rs_6_01_10_4(unsigned long a, double b) {
	int t = ji;
	v0();
	if (gul != 0) gula[t] = a / gul;
}
void rs_6_01_10_5(unsigned long a, double b) {
	gl2 |= gs.l + gps->l;
}
void rs_6_01_10_6(unsigned long a, double b) {
	int i = ji;
	int t = ji;
	int u = ji;
	v0();
	for (i = 11; i > 0; i--) { t = r2(u, gi); if (gp[0] != 0) gc2 = *gp / gp[0]; if (gca[5] != 0) gca[i] = *gp % gca[5]; }
}
char rs_6_01_10_7(unsigned long a, double b) {
	return gs.c;
}
void rs_6_01_11_0(char a, int b, int c) {
	char t = gca[6] - gc;
	jc = t;
}
void rs_6_01_11_1(char a, int b, int c) {
	int u = (int)gul | gia[3];
	ji = u;
}
void rs_6_01_11_2(char a, int b, int c) {
	int u = ji;
	--u;
}
void rs_6_01_11_3(char a, int b, int c) {
	gs.p = gp;
}
void rs_6_01_11_4(char a, int b, int c) {
	char t = jc;
	vc(t);
}
void rs_6_01_11_5(char a, int b, int c) {
	gc /= 10;
}
unsigned long rs_6_01_11_6(char a, int b, int c) {
	return rul(gula[4] % 2UL);
}
void rs_6_01_12_1(int a, char *b, unsigned int c) {
	int *t = rpi(a);
	jpi = t;
}
void rs_6_01_12_2(int a, char *b, unsigned int c) {
	int i = ji;
	int *t = jpi;
	int u = (t[a] > gi ? gs.i : gi3);
	v0();
	ji = u;
}
void rs_6_01_12_3(int a, char *b, unsigned int c) {
	int i = ji;
	int u = ji;
	v0();
	i = 14; do { gd2 = (r2(u, gi) || gul > 0x10000UL ? gda[2] : (double)gca[a]); } while (--i > 0);
}
void rs_6_01_12_4(int a, char *b, unsigned int c) {
	int u = ji;
	v0();
	switch (gi) { case 0: guc = guca[7] + guc; case 1: gia[u] = a; break; case 2: vp(&gca[a]); break; case 3: gc2 |= 4; break; case 4: case 5: gps->l = gl & gpl[3]; break; }
}
void rs_6_01_12_5(int a, char *b, unsigned int c) {
	gl2++;
}
void rs_6_01_12_6(int a, char *b, unsigned int c) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_6_01_12_7(int a, char *b, unsigned int c) {
	if (c != 0) c = gua[4] / c;
}
char * rs_6_01_12_8(int a, char *b, unsigned int c) {
	return gp;
}
void rs_6_01_13_0(unsigned long a) {
	unsigned long t = gul + a;
	jul = t;
}
void rs_6_01_13_1(unsigned long a) {
	unsigned char u = 255;
	juc = u;
}
void rs_6_01_13_2(unsigned long a) {
	unsigned char u = juc;
	if (gc2 != 0) gc2 = gca[u] / gc2;
}
void rs_6_01_13_3(unsigned long a) {
	unsigned long t = jul;
	vl((long)t);
}
void rs_6_01_13_4(unsigned long a) {
	gua[6] <<= 13;
}
void rs_6_01_13_5(unsigned long a) {
	gs.i = gps->i;
}
char rs_6_01_13_6(unsigned long a) {
	unsigned char u = juc;
	v0();
	return gp[1] >> (u & 7);
}
void rs_6_01_14_0(unsigned long a, unsigned long b) {
	int *t = gpi;
	jpi = t;
}
void rs_6_01_14_1(unsigned long a, unsigned long b) {
	int *u = &gia[6];
	jpi = u;
}
void rs_6_01_14_2(unsigned long a, unsigned long b) {
	int *u = jpi;
	v1(*u);
}
void rs_6_01_14_3(unsigned long a, unsigned long b) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_6_01_14_4(unsigned long a, unsigned long b) {
	*gpl ^= gpl[1] + -60049L;
}
void rs_6_01_14_5(unsigned long a, unsigned long b) {
	gul = gula[1] = (b / 3UL) - 7UL;
}
void rs_6_01_14_6(unsigned long a, unsigned long b) {
	gi3 *= 5;
}
long rs_6_01_14_7(unsigned long a, unsigned long b) {
	return (gu ? ((long)guca[3] + gl) : (gps->l - (long)gu));
}
void rs_6_01_15_1(int a, unsigned long b, char *c) {
	int *t = &gia[4];
	jpi = t;
}
void rs_6_01_15_2(int a, unsigned long b, char *c) {
	int i = ji;
	for (i = 2; i > 0; i--) { gc2 <<= 3; gs.p = c; }
}
void rs_6_01_15_3(int a, unsigned long b, char *c) {
	if (gs.u != 0) gps->u = gua[a] % gs.u;
}
void rs_6_01_15_4(int a, unsigned long b, char *c) {
	if ((gu2 = 17986)) { v0(); }
}
void rs_6_01_15_5(int a, unsigned long b, char *c) {
	int i = ji;
	v0();
	for (i = 6; i > 0; i--) { b = gula[i] = (unsigned long)(((char)gs.u == 46 ? gul : gul) != (0x10000UL * 5UL)); }
}
void rs_6_01_15_6(int a, unsigned long b, char *c) {
	int *t = jpi;
	v0();
	gpi = t;
}
unsigned int rs_6_01_15_7(int a, unsigned long b, char *c) {
	return ru(gs.u | gu2);
}
void rs_6_01_16_0(unsigned int a, unsigned int b) {
	double t = gd2 / 3.0;
	jd = t;
}
void rs_6_01_16_1(unsigned int a, unsigned int b) {
	gul /= 3UL;
}
void rs_6_01_16_2(unsigned int a, unsigned int b) {
	double t = jd;
	vd(t);
}
void rs_6_01_16_3(unsigned int a, unsigned int b) {
	if (gu2 != 0) gps->u = 256 % gu2;
}
unsigned long rs_6_01_16_4(unsigned int a, unsigned int b) {
	return 3UL;
}
void rs_6_01_17_0(unsigned char a, double b, double c) {
	gs.l += gl << 11;
}
void rs_6_01_17_1(unsigned char a, double b, double c) {
	if (gi3 < 4) { if (gia[0] != 0) gs.i = 16 % gia[0]; gul = 0x10000UL ^ rul(gula[a]); } else { if (gula[3] != 0) gula[7] = gul % gula[3]; gi2 = ~gi2 * 3; gp++; }
}
void rs_6_01_17_2(unsigned char a, double b, double c) {
	gps->u ^= gu << 9;
}
void rs_6_01_17_3(unsigned char a, double b, double c) {
	vl(gl2 & 3L);
}
void rs_6_01_17_4(unsigned char a, double b, double c) {
	if (guc) gc2 = ((char)!((unsigned char)gl2)) | (gc - gca[4]);
}
int rs_6_01_17_5(unsigned char a, double b, double c) {
	return r1(!((unsigned long)gl));
}
void rs_6_01_18_1(int a, int b, unsigned int c) {
	vl(gl - gl2);
}
void rs_6_01_18_2(int a, int b, unsigned int c) {
	if (gu != 0) c = gua[5] % gu;
}
void rs_6_01_18_3(int a, int b, unsigned int c) {
	int i = ji;
	v0();
	i = 2; do { gpi++; vu(((unsigned int)a) | c); } while (--i > 0);
}
void rs_6_01_18_4(int a, int b, unsigned int c) {
	gul &= gula[a] << 27;
}
long rs_6_01_18_5(int a, int b, unsigned int c) {
	return (long)!(-20) / 16L;
}
void rs_6_01_19_0(void) {
	unsigned long t = (unsigned long)!gi3;
	jul = t;
}
void rs_6_01_19_1(void) {
	int *u = rpi(256);
	jpi = u;
}
void rs_6_01_19_2(void) {
	while (gi-- > 0) { if (*gpi == 127) break; gpi++; }
}
void rs_6_01_19_3(void) {
	unsigned long t = jul;
	int *u = jpi;
	v0();
	switch (gs.c) { case 1: t = gul + 0UL; break; case 3: gc /= 7; break; case 5: case 16: u = rpi(gi2); break; case 20: gs.u = gps->u; break; default: vs(gps); break; }
}
void rs_6_01_19_4(void) {
	gs.a[1] = 1 - gi;
}
int * rs_6_01_19_5(void) {
	int *u = jpi;
	v0();
	return u;
}
void rs_6_02_00_0(long a, char b, int *c) {
	int t = gi2 - gia[5];
	ji = t;
}
void rs_6_02_00_1(long a, char b, int *c) {
	gc <<= 1;
}
void rs_6_02_00_2(long a, char b, int *c) {
	int t = ji;
	if (!guca[t]) { gu2 = ru((unsigned int)guca[t]); --gpi; }
}
void rs_6_02_00_3(long a, char b, int *c) {
	vp(gp);
}
void rs_6_02_00_4(long a, char b, int *c) {
	gl2 -= gla[0] << 23;
}
unsigned long rs_6_02_00_5(long a, char b, int *c) {
	return (gula[5] = gul);
}
void rs_6_02_01_1(void) {
	int i = ji;
	i = 15; do { gs.c = gc2 = (gp[3] & gc) | -86; if (gs.u != 0) gu = gs.u % gs.u; } while (--i > 0);
}
void rs_6_02_01_2(void) {
	gda[2] = gda[0] + gd;
}
void rs_6_02_01_3(void) {
	if (2 >= gpi[1]) guca[3] = guca[7] ^ guca[5];
}
void rs_6_02_01_4(void) {
	switch (gi3) { case 0: case 1: gd = gda[1] + 1.0; }
}
char rs_6_02_01_5(void) {
	return ((char)(gs.a[6] < gps->a[2])) + (gc >> 3);
}
void rs_6_02_02_0(char *a, int b, int c) {
	char t = gps->c;
	jc = t;
}
void rs_6_02_02_1(char *a, int b, int c) {
	unsigned char u = guc;
	juc = u;
}
void rs_6_02_02_2(char *a, int b, int c) {
	unsigned char u = juc;
	if (gu2 != 0) gu2 = gua[u] % gu2;
}
void rs_6_02_02_3(char *a, int b, int c) {
	b |= gi3;
}
void rs_6_02_02_4(char *a, int b, int c) {
	++gl;
}
void rs_6_02_02_5(char *a, int b, int c) {
	gl2 = 0L;
}
void rs_6_02_02_6(char *a, int b, int c) {
	char t = jc;
	vc(t);
}
void rs_6_02_02_7(char *a, int b, int c) {
	gi2 = gi3 = r2(gps->i, gi) * 9;
}
unsigned long rs_6_02_02_8(char *a, int b, int c) {
	return -0x10000UL | gul;
}
void rs_6_02_03_1(unsigned long a, char *b) {
	char *t = gps->p;
	jp = t;
}
void rs_6_02_03_2(unsigned long a, char *b) {
	char *u = gp + 1;
	jp = u;
}
void rs_6_02_03_3(unsigned long a, char *b) {
	++gl;
}
void rs_6_02_03_4(unsigned long a, char *b) {
	char *u = jp;
	gp = u;
}
void rs_6_02_03_5(unsigned long a, char *b) {
	int i = ji;
	char *t = jp;
	i = 15; do { gua[2] -= gu; t = rp(); } while (--i > 0);
}
void rs_6_02_03_6(unsigned long a, char *b) {
	guc = 0 ^ guc;
}
void rs_6_02_03_7(unsigned long a, char *b) {
	gs.d = (gla[2] == 65536L ? gd : (double)b[0]);
}
void rs_6_02_04_0(unsigned char a) {
	char t = (char)!gc2;
	jc = t;
}
void rs_6_02_04_1(unsigned char a) {
	char t = jc;
	gc = t;
}
void rs_6_02_04_2(unsigned char a) {
	gl = (*gpl + gl) % 2L;
}
void rs_6_02_04_3(unsigned char a) {
	gpi++;
}
unsigned long rs_6_02_04_4(unsigned char a) {
	return ~gul;
}
void rs_6_02_05_0(int a, unsigned char b, int c) {
	char t = gc2;
	jc = t;
}
void rs_6_02_05_1(int a, unsigned char b, int c) {
	guc = guca[b] = b;
}
void rs_6_02_05_2(int a, unsigned char b, int c) {
	gps->l -= 2L - 65536L;
}
void rs_6_02_05_3(int a, unsigned char b, int c) {
	gu2++;
}
void rs_6_02_05_4(int a, unsigned char b, int c) {
	char t = jc;
	t = (char)gla[t];
}
void rs_6_02_05_5(int a, unsigned char b, int c) {
	if (gul != 0) gula[1] = 35782UL % gul;
}
void rs_6_02_06_1(void) {
	unsigned char t = 130 | guca[0];
	juc = t;
}
void rs_6_02_06_2(void) {
	double u = -gda[3];
	jd = u;
}
void rs_6_02_06_3(void) {
	gu2 = -gu2;
}
void rs_6_02_06_4(void) {
	gula[6] &= gul;
}
void rs_6_02_06_5(void) {
	if (gps->c) vc(gc2);
}
void rs_6_02_06_6(void) {
	unsigned char t = juc;
	v0();
	guc = t;
}
void rs_6_02_06_7(void) {
	double u = jd;
	v0();
	vd(u);
}
void rs_6_02_06_8(void) {
	int i = ji;
	v0();
	for (i = 0; i < 3; i++) { gi3 |= 100; }
}
unsigned int rs_6_02_06_9(void) {
	return (gu = gu2);
}
void rs_6_02_07_0(void) {
	vl(gl ^ gs.l);
}
void rs_6_02_07_1(void) {
	v2(gi2, gia[5] * 10);
}
void rs_6_02_07_2(void) {
	gs.i = -gia[2];
}
void rs_6_02_07_3(void) {
	gps->c = gc;
}
unsigned long rs_6_02_07_4(void) {
	return (gula[3] * 6UL) - (gul - gula[0]);
}
void rs_6_02_08_0(int *a) {
	gula[4] = (unsigned long)(gu2 <= gu);
}
void rs_6_02_08_1(int *a) {
	gul |= rul(gul);
}
void rs_6_02_08_2(int *a) {
	if (gd != 10.0) { if (gc != 0) gca[7] = (char)gs.i % gc; a = rpi(-125); gi2--; } else { *gpi = (gul != 0x10000UL); vs(gps); }
}
void rs_6_02_08_3(int *a) {
	gpi = a;
}
char rs_6_02_08_4(int *a) {
	return (gps->c + 0) >> 4;
}
void rs_6_02_09_0(int a, double b) {
	int *t = gpi;
	jpi = t;
}
void rs_6_02_09_1(int a, double b) {
	unsigned char u = guc ^ 1;
	juc = u;
}
void rs_6_02_09_2(int a, double b) {
	gc2 = (gul & 0x8 ? rc(3) : (gps->c | *gp));
}
void rs_6_02_09_3(int a, double b) {
	if (gps->l != 0) gla[a] = (long)a % gps->l;
}
void rs_6_02_09_4(int a, double b) {
	int *t = jpi;
	v0();
	a = (gs.i & t[1]) + gps->a[0];
}
void rs_6_02_09_5(int a, double b) {
	unsigned char u = juc;
	v0();
	guc = u;
}
int rs_6_02_09_6(int a, double b) {
	return (gi = (int)gs.c);
}
void rs_6_02_10_1(unsigned long a) {
	guc--;
}
void rs_6_02_10_2(unsigned long a) {
	int i = ji;
	i = 0; while (i < 8) { gi3 -= gps->i << 3; v1(gps->i); if (gca[i] != 0) gs.c = gca[i] % gca[i]; i++; }
}
void rs_6_02_10_3(unsigned long a) {
	int i = ji;
	v0();
	if (gs.i > (int)gs.c) { if (gua[4] != 0) gu = gu2 / gua[4]; } else { gul = a; gs.p = gps->p; vu(gs.u * 4); }
}
void rs_6_02_10_4(unsigned long a) {
	v2(gi2 >> 1, gi);
}
void rs_6_02_10_5(unsigned long a) {
	if (gua[7] >= gu2) gu += (gl2 & 2 ? gps->u : gu);
}
long rs_6_02_10_6(unsigned long a) {
	return (gps->l | gla[3]) | (gla[1] / 10L);
}
void rs_6_02_11_0(char a, struct st *b) {
	double t = gs.d - gda[0];
	jd = t;
}
void rs_6_02_11_1(char a, struct st *b) {
	char u = rc(100);
	jc = u;
}
void rs_6_02_11_2(char a, struct st *b) {
	gul += gul % 7UL;
}
void rs_6_02_11_3(char a, struct st *b) {
	double t = jd;
	v0();
	gd = t;
}
void rs_6_02_11_4(char a, struct st *b) {
	char u = jc;
	v0();
	guca[u] -= guca[5];
}
void rs_6_02_11_5(char a, struct st *b) {
	char u = jc;
	v0();
	if (gl) u += u / 16;
}
void rs_6_02_11_6(char a, struct st *b) {
	guca[a] = guc;
}
void rs_6_02_11_7(char a, struct st *b) {
	vc(5 >> 3);
}
long rs_6_02_11_8(char a, struct st *b) {
	return (r0() || gc > 7 ? (long)!(-75034L) : (gs.l - 65536L));
}
void rs_6_02_12_0(void) {
	int *t = gpi + 1;
	jpi = t;
}
void rs_6_02_12_1(void) {
	int *t = jpi;
	v1(*t);
}
void rs_6_02_12_2(void) {
	vs(gps);
}
void rs_6_02_12_3(void) {
	gp = &gca[0];
}
void rs_6_02_13_0(double a) {
	int t = ~1;
	ji = t;
}
void rs_6_02_13_1(double a) {
	unsigned long u = gul;
	jul = u;
}
void rs_6_02_13_2(double a) {
	int t = ji;
	*gpl = gla[7] << (t & 15);
}
void rs_6_02_13_3(double a) {
	int t = ji;
	t = (t << 9) - ~t;
}
void rs_6_02_13_4(double a) {
	v0();
}
void rs_6_02_13_5(double a) {
	int t = ji;
	unsigned long u = jul;
	v0();
	if (gl2 != 49945L) gula[t] += u - 0x10000UL;
}
void rs_6_02_13_6(double a) {
	int t = ji;
	v0();
	guca[t] = guc = (unsigned char)(guc < (guca[3] ^ guca[t]));
}
long rs_6_02_13_7(double a) {
	return (gla[6] = *gpl);
}
void rs_6_02_14_0(unsigned char a, int *b, unsigned char c) {
	char t = '0';
	jc = t;
}
void rs_6_02_14_1(unsigned char a, int *b, unsigned char c) {
	char t = jc;
	gula[c] = (a & 4 ? (0x10000UL >> 7) : rul(gula[t]));
}
void rs_6_02_14_2(unsigned char a, int *b, unsigned char c) {
	vl((long)(int)gl);
}
char rs_6_02_14_3(unsigned char a, int *b, unsigned char c) {
	return -gc2;
}
void rs_6_02_15_0(char a) {
	long t = gl2 >> 28;
	jl = t;
}
void rs_6_02_15_1(char a) {
	int u = gps->a[1] >> (a & 15);
	ji = u;
}
void rs_6_02_15_2(char a) {
	long t = jl;
	gl = t;
}
void rs_6_02_15_3(char a) {
	int u = ji;
	if (r2(gia[2], gi)) { v1((int)gps->u); guc = ~((unsigned char)!gi3); }
}
void rs_6_02_15_4(char a) {
	gs.i = gi / 16;
}
void rs_6_02_15_5(char a) {
	++guc;
}
void rs_6_02_15_6(char a) {
	int u = ji;
	v0();
	gu = -(gua[0] & gps->u);
}
int rs_6_02_15_7(char a) {
	return (128 == (guca[0] ^ guca[a]));
}
void rs_6_02_16_0(unsigned long a) {
	unsigned long t = ~gula[4];
	jul = t;
}
void rs_6_02_16_1(unsigned long a) {
	unsigned long u = rul(gula[4]);
	jul = u;
}
void rs_6_02_16_2(unsigned long a) {
	gca[4] = gps->c;
}
void rs_6_02_16_3(unsigned long a) {
	if (gla[5] != 0) gla[7] = gpl[0] % gla[5];
}
void rs_6_02_16_4(unsigned long a) {
	unsigned long u = jul;
	v0();
	if (gu != 0) gs.u = gu2 / gu;
}
void rs_6_02_16_5(unsigned long a) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
void rs_6_02_16_6(unsigned long a) {
	gd *= (double)gua[4];
}
void rs_6_02_16_7(unsigned long a) {
	--gpi;
}
void rs_6_02_17_0(unsigned int a) {
	switch (gc) { case 0: gl2 = (long)!a; break; case 1: vc(gc2); break; default: vc(gp[3]); break; }
}
void rs_6_02_17_1(unsigned int a) {
	if (gl != 0) *gpl = gpl[3] / gl;
}
void rs_6_02_17_2(unsigned int a) {
	gula[0] <<= 2;
}
char * rs_6_02_17_3(unsigned int a) {
	return rp();
}
void rs_6_02_18_0(void) {
	int t = gi;
	ji = t;
}
void rs_6_02_18_1(void) {
	v0();
}
void rs_6_02_18_2(void) {
	int t = ji;
	v0();
	gc2 = rc((guca[3] < 128 ? t : t));
}
void rs_6_02_18_3(void) {
	guca[0] = 128;
}
int rs_6_02_18_4(void) {
	return ~gi;
}
void rs_6_02_19_0(long a, long b, int c) {
	unsigned int t = ru((unsigned int)guca[c]);
	ju = t;
}
void rs_6_02_19_1(long a, long b, int c) {
	int u = gi3 - 255;
	v0();
	ji = u;
}
void rs_6_02_19_2(long a, long b, int c) {
	int u = ji;
	v0();
	gp = gps->p + u;
}
void rs_6_02_19_3(long a, long b, int c) {
	gc2++;
}
void rs_6_02_19_4(long a, long b, int c) {
	unsigned int t = ju;
	v0();
	vu(t);
}
void rs_6_02_19_5(long a, long b, int c) {
	++gi;
}
long rs_6_02_19_6(long a, long b, int c) {
	return 65536L;
}
void rs_6_03_00_0(char *a) {
	int *t = gpi;
	jpi = t;
}
void rs_6_03_00_1(char *a) {
	int u = 256;
	ji = u;
}
void rs_6_03_00_2(char *a) {
	int *t = jpi;
	v1(*t);
}
void rs_6_03_00_3(char *a) {
	gul = 68026UL;
}
void rs_6_03_00_4(char *a) {
	int u = ji;
	v0();
	gul = rul(gula[u]) - (gps->u != 1 ? gula[5] : gul);
}
void rs_6_03_00_5(char *a) {
	switch (gs.i) { case 0: guc += 128; case 1: v1(gi2); default: gs.d = gd; break; }
}
int rs_6_03_00_6(char *a) {
	return -(int)gu & (2 >> 4);
}
void rs_6_03_01_1(int a, unsigned int b, char *c) {
	int t = gi3;
	ji = t;
}
void rs_6_03_01_2(int a, unsigned int b, char *c) {
	char u = 62 << 2;
	jc = u;
}
void rs_6_03_01_3(int a, unsigned int b, char *c) {
	int i = ji;
	int t = ji;
	char u = jc;
	for (i = 0; i < 9; i++) { v1(t | (int)u); guca[i] *= 10; }
}
void rs_6_03_01_4(int a, unsigned int b, char *c) {
	gpi++;
}
void rs_6_03_01_5(int a, unsigned int b, char *c) {
	vu(gu + b);
}
int rs_6_03_01_6(int a, unsigned int b, char *c) {
	int i = ji;
	v0();
	return gps->a[b] - (gs.i / 10);
}
void rs_6_03_02_0(char a) {
	guc = ((unsigned char)!(char)gu2) << 5;
}
int rs_6_03_02_1(char a) {
	if (a) return gps->a[a] - gps->i;
}
void rs_6_03_02_2(char a) {
	gpl[3] = gps->l;
}
void rs_6_03_02_3(char a) {
	gu2 += 32767 + gu2;
}
void rs_6_03_02_4(char a) {
	gd *= gd2;
}
int rs_6_03_02_5(char a) {
	return (*gpi % 100) * 9;
}
void rs_6_03_03_0(int a, int b, long c) {
	char t = gc ^ gca[7];
	jc = t;
}
void rs_6_03_03_1(int a, int b, long c) {
	gul = 5UL;
}
void rs_6_03_03_2(int a, int b, long c) {
	vd(gda[0]);
}
void rs_6_03_03_3(int a, int b, long c) {
	++gu2;
}
void rs_6_03_03_4(int a, int b, long c) {
	switch (c) { case 0L: v2(gi, gi); break; case 1L: v0(); break; case 2L: gu2 -= 4; case 3L: case 4L: v1(gi2); break; case 5L: vd(gs.d); break; }
}
void rs_6_03_03_5(int a, int b, long c) {
	char t = jc;
	v0();
	gc = t;
}
char * rs_6_03_03_6(int a, int b, long c) {
	return rp();
}
void rs_6_03_04_0(unsigned char a) {
	long t = (long)(21213UL > gula[6]);
	jl = t;
}
void rs_6_03_04_1(unsigned char a) {
	unsigned char u = guc ^ guca[5];
	juc = u;
}
void rs_6_03_04_2(unsigned char a) {
	gi2 = gi3 = -(gia[0] / 2);
}
void rs_6_03_04_3(unsigned char a) {
	long t = jl;
	unsigned char u = juc;
	if (!gca[6]) { u = 255 + -128; v0(); if (t != 0) gl = *gpl / t; } else { gs.c = '9'; vd((!gc ? 0.25 : gd2)); if (gla[u] != 0) t = gl / gla[u]; }
}
void rs_6_03_04_4(unsigned char a) {
	gpi = rpi(-gi3);
}
void rs_6_03_04_5(unsigned char a) {
	v0();
}
void rs_6_03_04_6(unsigned char a) {
	vc(*gp % 2);
}
long rs_6_03_04_7(unsigned char a) {
	return (65536L ^ gla[3]) + (gl & gl2);
}
void rs_6_03_05_0(char a, long b, unsigned long c) {
	unsigned long t = gul ^ 4401UL;
	jul = t;
}
void rs_6_03_05_1(char a, long b, unsigned long c) {
	c = gul = 60774UL;
}
void rs_6_03_05_2(char a, long b, unsigned long c) {
	unsigned long t = jul;
	if (gla[a] > (long)t) { --guc; if (gps->u != 0) gu2 = gu2 / gps->u; } else { if (gl == -45295L) if (gs.l != 0) gl2 = 65536L % gs.l; }
}
void rs_6_03_05_3(char a, long b, unsigned long c) {
	guca[4] = guc;
}
void rs_6_03_05_4(char a, long b, unsigned long c) {
	if (guca[6]) { if (gps->u != 0) gu = gs.u / gps->u; }
}
void rs_6_03_05_5(char a, long b, unsigned long c) {
	unsigned long t = jul;
	if (r1(gps->i)) { if (gpi[1] != 0) gs.a[a] = gs.i % gpi[1]; ++t; }
}
long rs_6_03_05_6(char a, long b, unsigned long c) {
	return (long)guca[2] << (a & 15);
}
void rs_6_03_06_0(long *a, int b) {
	vu(1 & gu2);
}
void rs_6_03_06_1(long *a, int b) {
	if (gul != gula[b]) gua[b] >>= (b & 15);
}
void rs_6_03_06_2(long *a, int b) {
	gl = 0L;
}
unsigned int rs_6_03_06_3(long *a, int b) {
	return gu2;
}
void rs_6_03_07_1(unsigned char a, long b) {
	if (!gula[a] && gps->c) v0();
}
int rs_6_03_07_2(unsigned char a, long b) {
	if (r2(*gpi, gi)) return (int)gu;
}
void rs_6_03_07_3(unsigned char a, long b) {
	int i = ji;
	v0();
	i = 4; do { if (gul != 0) gula[5] = 0x10000UL / gul; } while (--i > 0);
}
int rs_6_03_07_4(unsigned char a, long b) {
	return (int)gc2;
}
void rs_6_03_08_0(unsigned int a, int b, int c) {
	if (16 <= 8) { gp = &gca[b]; ++gul; }
}
void rs_6_03_08_1(unsigned int a, int b, int c) {
	while (c > 0) { gi += *gpi++; c--; }
}
void rs_6_03_08_2(unsigned int a, int b, int c) {
	++guc;
}
void rs_6_03_08_3(unsigned int a, int b, int c) {
	gps->c = (gc + gca[0]) | 3;
}
unsigned long rs_6_03_08_4(unsigned int a, int b, int c) {
	return (gi2 == *gpi && 3 == -16 ? (62256UL + 29416UL) : (((unsigned long)gs.c) << 12));
}
void rs_6_03_09_0(unsigned int a, unsigned int b) {
	guc = ~255 - ~guca[4];
}
void rs_6_03_09_1(unsigned int a, unsigned int b) {
	gd = (gd - gd) * (0.5 / 100.0);
}
void rs_6_03_09_2(unsigned int a, unsigned int b) {
	gpl[3] = gl2 * 12L;
}
void rs_6_03_09_3(unsigned int a, unsigned int b) {
	if (gps->u == b) gla[a] = 2L;
}
void rs_6_03_09_4(unsigned int a, unsigned int b) {
	guca[1] = guca[b];
}
void rs_6_03_10_0(unsigned int a) {
	int t = gi - *gpi;
	ji = t;
}
void rs_6_03_10_1(unsigned int a) {
	char *u = rp();
	jp = u;
}
void rs_6_03_10_2(unsigned int a) {
	int t = ji;
	v0();
	if (t > gi3) vs(gps);
}
void rs_6_03_10_3(unsigned int a) {
	int t = ji;
	v0();
	gpi = gpi + t;
}
void rs_6_03_10_4(unsigned int a) {
	if (guca[2] < 3 || gul == 0x10000UL) gs.i = gs.a[4] - 256;
}
void rs_6_03_10_5(unsigned int a) {
	char *u = jp;
	v0();
	gp = u;
}
void rs_6_03_10_6(unsigned int a) {
	gd -= 10.0;
}
int rs_6_03_10_7(unsigned int a) {
	int t = ji;
	v0();
	return (t - 1) + !guca[t];
}
void rs_6_03_11_1(unsigned char a, char b, struct st *c) {
	switch (gi2) { case 1: gul = gul * 2UL; break; case 2: a ^= guc; break; case 16: vs(gps); break; case 200: gi3 -= 6; break; default: v1(gpi[1]); break; }
}
void rs_6_03_11_2(unsigned char a, char b, struct st *c) {
	gl2++;
}
void rs_6_03_11_3(unsigned char a, char b, struct st *c) {
	vd((double)gia[0]);
}
void rs_6_03_11_4(unsigned char a, char b, struct st *c) {
	int i = ji;
	v0();
	for (i = 0; i < 4; i++) { guca[i] = guc << 4; vc(gca[6] - b); guca[i] += (unsigned char)(((unsigned char)c->l) == a); }
}
void rs_6_03_11_5(unsigned char a, char b, struct st *c) {
	gs.d += gs.d / 0.5;
}
int rs_6_03_11_6(unsigned char a, char b, struct st *c) {
	return *gpi;
}
void rs_6_03_12_0(char *a) {
	gs.u = gua[6] % 10;
}
void rs_6_03_12_1(char *a) {
	gpi = rpi(r1(gpi[0]));
}
void rs_6_03_12_2(char *a) {
	guca[5] = (unsigned char)(gula[6] <= gul);
}
void rs_6_03_12_3(char *a) {
	if (gul) { if (gl != 0) gla[4] = (long)gul % gl; vc((char)gi3 >> 3); } else { if (!gul) if (gc != 0) gc2 = 99 / gc; }
}
char rs_6_03_12_4(char *a) {
	return gca[7] + (gc / 16);
}
void rs_6_03_13_0(void) {
	unsigned long t = ~gul;
	jul = t;
}
void rs_6_03_13_1(void) {
	int u = gia[1];
	ji = u;
}
void rs_6_03_13_2(void) {
	unsigned long t = jul;
	vl((long)t);
}
void rs_6_03_13_3(void) {
	v2(gi2, gi - *gpi);
}
char rs_6_03_13_4(void) {
	if (guca[5]) return gps->c - (' ');
}
void rs_6_03_13_5(void) {
	int u = ji;
	v0();
	v1(u);
}
char rs_6_03_13_6(void) {
	unsigned long t = jul;
	int u = ji;
	v0();
	return ((char)(t != gul)) - rc(u);
}
void rs_6_03_14_0(unsigned int a, char b) {
	if (guca[2] < 189) { a = (unsigned int)((gps->u + gu) == (a ^ gps->u)); gps->i <<= 7; } else { if (gpl[0]) gpi++; }
}
void rs_6_03_14_1(unsigned int a, char b) {
	if (r2(gs.i, gi)) { gps->u = (gps->u % 4) % 100; } else { gd2 *= ((gps->l = gl2) >= 8L ? gd : gd); if (a != 0) gu = gu2 / a; if (b != 0) gp[0] = b % b; }
}
void rs_6_03_14_2(unsigned int a, char b) {
	gul = gula[4];
}
void rs_6_03_14_3(unsigned int a, char b) {
	a <<= 9;
}
void rs_6_03_15_0(char a) {
	gd2 = -(double)gc * (gd * gd2);
}
void rs_6_03_15_1(char a) {
	gd = gs.d;
}
unsigned long rs_6_03_15_2(char a) {
	if ((gps->c = gc2)) return -0x10000UL;
}
unsigned long rs_6_03_15_3(char a) {
	return rul(gula[1]) + (gul + gula[5]);
}
void rs_6_03_16_0(char a, unsigned int b) {
	unsigned long t = (gps->l != 39780L ? gul : gul);
	jul = t;
}
void rs_6_03_16_1(char a, unsigned int b) {
	unsigned long t = jul;
	gul = t;
}
void rs_6_03_16_2(char a, unsigned int b) {
	gd2 *= 2.5 * gd;
}
void rs_6_03_16_3(char a, unsigned int b) {
	gps->l += *gpl - gs.l;
}
void rs_6_03_16_4(char a, unsigned int b) {
	if (gca[3] != 0) *gp = gca[b] / gca[3];
}
void rs_6_03_16_5(char a, unsigned int b) {
	if (gps->a[a]) { gps->i = gia[b]; }
}
char rs_6_03_16_6(char a, unsigned int b) {
	return (char)((unsigned long)(guc > 3));
}
void rs_6_03_17_0(char *a) {
	unsigned int t = gu2 - gua[3];
	ju = t;
}
void rs_6_03_17_1(char *a) {
	unsigned int t = ju;
	int u = gia[4] | gps->a[t];
	ji = u;
}
void rs_6_03_17_2(char *a) {
	unsigned int t = ju;
	int u = ji;
	gula[u] = gula[t] / 2UL;
}
void rs_6_03_17_3(char *a) {
	unsigned int t = ju;
	guca[3] = -((unsigned char)(gp[2] != gca[t]));
}
unsigned long rs_6_03_17_4(char *a) {
	int u = ji;
	return (unsigned long)gs.u;
}
void rs_6_03_18_0(long a, unsigned int b) {
	char u = jc;
	unsigned long t = (unsigned long)gs.u;
	jul = t;
}
void rs_6_03_18_1(long a, unsigned int b) {
	char u = *gp & gp[3];
	jc = u;
}
void rs_6_03_18_2(long a, unsigned int b) {
	char u = jc;
	if (guca[b] != guc) gp[3] = (char)(gps->u << 5);
}
void rs_6_03_18_3(long a, unsigned int b) {
	++gi2;
}
void rs_6_03_18_4(long a, unsigned int b) {
	gd *= gd2;
}
void rs_6_03_18_5(long a, unsigned int b) {
	unsigned long t = jul;
	gul = t;
}
char rs_6_03_18_6(long a, unsigned int b) {
	return (r2(gi2, gi) ? (gs.c << 5) : (char)guc);
}
void rs_6_03_19_0(void) {
	int t = -gi2;
	ji = t;
}
void rs_6_03_19_1(void) {
	int t = ji;
	switch (gs.l) { case 0L: gula[5] = gula[t] % 10UL; break; case 1L: vu(gu); break; case 2L: gula[6] >>= 29; break; case 3L: t -= *gpi; break; case 4L: *gp = (0x10000UL > gula[7] ? gca[t] : 'z'); default: v0(); break; }
}
void rs_6_03_19_2(void) {
	gul ^= rul(0UL);
}
void rs_6_03_19_3(void) {
	int t = ji;
	v0();
	guca[t] = guca[t] * guca[3];
}
int rs_6_03_19_4(void) {
	int t = ji;
	v0();
	return -(255 | gps->a[t]);
}
void rs_6_04_00_1(void) {
	int t = ~255;
	ji = t;
}
void rs_6_04_00_2(void) {
	int *u = gpi;
	jpi = u;
}
void rs_6_04_00_3(void) {
	int *u = jpi;
	gpi = u;
}
void rs_6_04_00_4(void) {
	int t = ji;
	if (gua[t] != 0) gu2 = gua[3] % gua[t];
}
void rs_6_04_00_5(void) {
	int i = ji;
	i = 0; while (i < 12) { gs.c = ~gca[i]; if (gul != 0) gul = gula[i] % gul; gua[i] = (unsigned int)!guca[i]; i++; }
}
unsigned long rs_6_04_00_6(void) {
	int t = ji;
	return (gul + ((unsigned long)gps->a[0])) | gula[t];
}
void rs_6_04_01_1(unsigned long a) {
	int i = ji;
	i = 14; do { gu2 = (unsigned int)!(gula[i] + 99603UL); if (gs.l != 0) *gpl = gs.l % gs.l; gi += gpi[3]; } while (--i > 0);
}
void rs_6_04_01_2(unsigned long a) {
	v0();
}
unsigned long rs_6_04_01_3(unsigned long a) {
	return (((unsigned long)gps->u) >> 21) + (gula[5] & a);
}
void rs_6_04_02_0(unsigned long a, char b) {
	gs.p = gp;
}
void rs_6_04_02_1(unsigned long a, char b) {
	gul = (unsigned long)!(gi3 - 2);
}
void rs_6_04_02_2(unsigned long a, char b) {
	gi2++;
}
int rs_6_04_02_3(unsigned long a, char b) {
	return r2(gi2, r2(gi2, *gpi));
}
void rs_6_04_03_0(void) {
	double t = gd2 - (double)gps->i;
	jd = t;
}
void rs_6_04_03_1(void) {
	double t = jd;
	vd(t);
}
void rs_6_04_03_2(void) {
	gula[0] -= gula[6];
}
void rs_6_04_03_3(void) {
	vp(rp());
}
void rs_6_04_03_4(void) {
	if (gu2 >= gu && gca[0] & 4) gul = (79881UL % 4UL) - ((unsigned long)!((unsigned char)gca[6]));
}
void rs_6_04_03_5(void) {
	if (gu2 < gua[0]) { gul += gul | 9UL; }
}
int rs_6_04_03_6(void) {
	if (1 >= 26105) return *gpi;
}
int rs_6_04_03_7(void) {
	return -gi % 7;
}
void rs_6_04_04_0(void) {
	gu = (unsigned int)(((unsigned char)gca[4]) << 1);
}
void rs_6_04_04_1(void) {
	gul = gul << 8;
}
void rs_6_04_04_2(void) {
	if (gi3) { vc(gc2 * gs.c); gl2--; }
}
void rs_6_04_04_3(void) {
	--gu;
}
void rs_6_04_04_4(void) {
	switch (gi) { case 0: gps->u = (unsigned int)!7366L; break; case 1: gula[0] |= gula[4]; break; case 2: gu = 19352 ^ 3; break; case 3: vp(rp()); break; case 4: gu2 = (gi2 != 707 ? gu2 : gua[3]); break; }
}
long rs_6_04_04_5(void) {
	return gla[7];
}
void rs_6_04_05_0(unsigned long a, char *b) {
	vu(255);
}
void rs_6_04_05_1(unsigned long a, char *b) {
	switch (gu2) { case 1: gs.u |= gu2; break; case 3: gs.p = b + 1; case 200: a -= gula[1]; break; }
}
void rs_6_04_05_2(unsigned long a, char *b) {
	gs.i = (gs.c >= gca[7]);
}
void rs_6_04_05_3(unsigned long a, char *b) {
	vc((char)((unsigned int)gs.a[6]));
}
void rs_6_04_05_4(unsigned long a, char *b) {
	v1(gi2 - gps->a[3]);
}
int rs_6_04_05_5(unsigned long a, char *b) {
	return ~gps->a[4];
}
void rs_6_04_06_1(void) {
	int t = gi3 % 7;
	ji = t;
}
void rs_6_04_06_2(void) {
	int t = ji;
	gpi = gpi + t;
}
void rs_6_04_06_3(void) {
	int i = ji;
	for (i = 0; i < 9; i++) { gi = -122; if (gul != 0) gul = gula[i] / gul; }
}
void rs_6_04_06_4(void) {
	++guc;
}
void rs_6_04_06_5(void) {
	if (6 > -68 || (gua[7] = 1)) vp(&gca[5]);
}
long rs_6_04_06_6(void) {
	return (gl2 & 6360L) + (gl << 13);
}
void rs_6_04_07_0(double a, char b) {
	int t = gi >> 11;
	ji = t;
}
void rs_6_04_07_1(double a, char b) {
	char u = gc;
	jc = u;
}
int rs_6_04_07_2(double a, char b) {
	int t = ji;
	if (gd2 <= 100.0) return t;
}
void rs_6_04_07_3(double a, char b) {
	char u = jc;
	gs.u <<= 6;
}
int rs_6_04_07_4(double a, char b) {
	int t = ji;
	return (gi2 * t) >> 13;
}
void rs_6_04_08_1(unsigned long a, int b) {
	int i = ji;
	switch (gs.i) { case 0: gs.d = gs.d + gd; break; case 1: v2(gi2, *gpi); case 2: v1(gi2); break; case 3: v2(gia[0], gi); break; default: gca[4] = (char)65536L; break; }
}
void rs_6_04_08_2(unsigned long a, int b) {
	int i = ji;
	v0();
	i = 0; while (i < 11) { if (gp[2] != 0) gca[i] = gc % gp[2]; i++; }
}
void rs_6_04_08_3(unsigned long a, int b) {
	gpi++;
}
void rs_6_04_08_4(unsigned long a, int b) {
	--guc;
}
void rs_6_04_08_5(unsigned long a, int b) {
	gu2++;
}
int rs_6_04_08_6(unsigned long a, int b) {
	return gia[3];
}
void rs_6_04_09_1(int *a, unsigned int b) {
	if (!guca[3]) if (gi2 != 0) *a = gia[3] / gi2;
}
void rs_6_04_09_2(int *a, unsigned int b) {
	gs.d *= gs.d / 1.0;
}
void rs_6_04_09_3(int *a, unsigned int b) {
	int i = ji;
	for (i = 9; i > 0; i--) { gula[i] = (unsigned long)gps->a[i]; ++gc2; a--; }
}
char * rs_6_04_09_4(int *a, unsigned int b) {
	return gs.p;
}
void rs_6_04_10_0(unsigned long a, int *b) {
	unsigned char t = ~((unsigned char)gca[2]);
	juc = t;
}
void rs_6_04_10_1(unsigned long a, int *b) {
	while (gi-- > 0) *b++ = -912;
}
void rs_6_04_10_2(unsigned long a, int *b) {
	gda[2] = -gda[1];
}
void rs_6_04_10_3(unsigned long a, int *b) {
	unsigned char t = juc;
	if (gul < 0x10000UL) { gua[t] ^= gps->u; }
}
void rs_6_04_10_4(unsigned long a, int *b) {
	gs.u = gu = 25775;
}
int * rs_6_04_10_5(unsigned long a, int *b) {
	return b;
}
void rs_6_04_11_0(int a, unsigned char b, int c) {
	if (gul <= gula[0]) gps->l = 65536L;
}
void rs_6_04_11_1(int a, unsigned char b, int c) {
	if (*gpi > 16) gla[a] += ~6L;
}
void rs_6_04_11_2(int a, unsigned char b, int c) {
	gl--;
}
void rs_6_04_11_3(int a, unsigned char b, int c) {
	guc &= b ^ 255;
}
char rs_6_04_11_4(int a, unsigned char b, int c) {
	return ~(gpl[2] <= 65536L ? gca[a] : gps->c);
}
void rs_6_04_12_0(struct st *a, unsigned char b) {
	unsigned char t = -guca[5];
	juc = t;
}
void rs_6_04_12_1(struct st *a, unsigned char b) {
	int *u = rpi(gi3);
	jpi = u;
}
void rs_6_04_12_2(struct st *a, unsigned char b) {
	gd2 *= (double)gs.l - gd;
}
void rs_6_04_12_3(struct st *a, unsigned char b) {
	gps->i = (*gpi > gi);
}
void rs_6_04_12_4(struct st *a, unsigned char b) {
	unsigned char t = juc;
	v0();
	guc = t = (41 % 4) % 100;
}
void rs_6_04_12_5(struct st *a, unsigned char b) {
	gp++;
}
void rs_6_04_12_6(struct st *a, unsigned char b) {
	int *u = jpi;
	v0();
	v1(*u);
}
int rs_6_04_12_7(struct st *a, unsigned char b) {
	return *gpi;
}
void rs_6_04_13_0(long a) {
	char *t = gs.p;
	jp = t;
}
void rs_6_04_13_1(long a) {
	vp(gp);
}
void rs_6_04_13_2(long a) {
	gca[2] = rc(gi2);
}
void rs_6_04_13_3(long a) {
	char *t = jp;
	v0();
	gp = t;
}
void rs_6_04_13_4(long a) {
	if (gla[1] != 0) a = gl / gla[1];
}
char * rs_6_04_13_5(long a) {
	char *t = jp;
	v0();
	return t + 1;
}
void rs_6_04_14_0(char a, struct st *b, int c) {
	vp(gp);
}
void rs_6_04_14_1(char a, struct st *b, int c) {
	gula[2] = gul = (0x10000UL * gul) & (gula[0] & gul);
}
long rs_6_04_14_2(char a, struct st *b, int c) {
	return gs.l;
}
void rs_6_04_15_0(void) {
	double t = gd2 / 2.5;
	jd = t;
}
void rs_6_04_15_1(void) {
	char u = (char)gps->a[1] << 3;
	jc = u;
}
void rs_6_04_15_2(void) {
	double t = jd;
	gd = t;
}
void rs_6_04_15_3(void) {
	vu(gu);
}
void rs_6_04_15_4(void) {
	guca[1] = (guca[3] - guc) * guca[0];
}
void rs_6_04_15_5(void) {
	gc2 = gc2 + rc(255);
}
void rs_6_04_15_6(void) {
	guc &= guc & 111;
}
void rs_6_04_15_7(void) {
	char u = jc;
	v0();
	gc = u;
}
long rs_6_04_15_8(void) {
	return 950L;
}
void rs_6_04_16_0(double a, long *b, int c) {
	long t = gl2 % 4L;
	jl = t;
}
void rs_6_04_16_1(double a, long *b, int c) {
	gula[c] >>= (c & 15);
}
void rs_6_04_16_2(double a, long *b, int c) {
	long t = jl;
	gl = t;
}
void rs_6_04_16_3(double a, long *b, int c) {
	--gul;
}
void rs_6_04_16_4(double a, long *b, int c) {
	if (gu != 0) gs.u = 255 / gu;
}
int rs_6_04_16_5(double a, long *b, int c) {
	return gia[1];
}
void rs_6_04_17_0(char a) {
	char t = (' ') + gc;
	jc = t;
}
void rs_6_04_17_1(char a) {
	char t = jc;
	unsigned long u = gula[t] + 0x10000UL;
	jul = u;
}
void rs_6_04_17_2(char a) {
	switch (gi2) { case 0: gl2 = gl; break; case 1: vu(gu2); break; case 2: v2(gi2, gi); break; }
}
void rs_6_04_17_3(char a) {
	char t = jc;
	unsigned long u = jul;
	v0();
	if ((guc = ((unsigned char)gps->u))) { gl2++; vl((long)!guc); if (gs.c != 0) a = gp[2] / gs.c; } else { gula[a] = u + 55391UL; gda[1] = (t == 7 ? gda[2] : gd2); }
}
void rs_6_04_17_4(char a) {
	char t = jc;
	v0();
	if ((gl2 = gla[1])) gca[4] = t | 2;
}
int rs_6_04_17_5(char a) {
	char t = jc;
	unsigned long u = jul;
	v0();
	return ((gla[0] * 11L) < (u > ((unsigned long)gi) ? gla[t] : (long)gu));
}
void rs_6_04_18_0(int a, unsigned long b, char c) {
	unsigned int t = ~gs.u;
	ju = t;
}
void rs_6_04_18_1(int a, unsigned long b, char c) {
	b = -gula[1] / 100UL;
}
void rs_6_04_18_2(int a, unsigned long b, char c) {
	unsigned int t = ju;
	gu2 = t;
}
void rs_6_04_18_3(int a, unsigned long b, char c) {
	guc = (gs.i ? (guca[0] << 1) : ((unsigned char)!gs.l));
}
void rs_6_04_18_4(int a, unsigned long b, char c) {
	gda[0] = gd;
}
void rs_6_04_18_5(int a, unsigned long b, char c) {
	gpl[3] |= gps->l % 100L;
}
unsigned int rs_6_04_18_6(int a, unsigned long b, char c) {
	unsigned int t = ju;
	return t;
}
void rs_6_04_19_0(void) {
	char t = gc2;
	jc = t;
}
void rs_6_04_19_1(void) {
	char t = jc;
	vc(t);
}
void rs_6_04_19_2(void) {
	v2(gi2, gi2 + gpi[1]);
}
void rs_6_04_19_3(void) {
	gu <<= 15;
}
char * rs_6_04_19_4(void) {
	return gps->p;
}
void rs_6_05_00_1(unsigned long a) {
	guca[5] = guc / 4;
}
void rs_6_05_00_2(unsigned long a) {
	v0();
}
void rs_6_05_00_3(unsigned long a) {
	int i = ji;
	v0();
	i = 2; do { gl = ~(gla[i] ^ gl); if (gu2 != 0) gu2 = gu / gu2; } while (--i > 0);
}
void rs_6_05_00_4(unsigned long a) {
	int i = ji;
	v0();
	for (i = 0; i < 8; i++) { gu2 = ru(-gu2); }
}
void rs_6_05_00_5(unsigned long a) {
	gs.u = 7933;
}
char * rs_6_05_00_6(unsigned long a) {
	return gs.p;
}
void rs_6_05_01_0(unsigned long a, unsigned long b) {
	long t = 3L / 7L;
	jl = t;
}
void rs_6_05_01_1(unsigned long a, unsigned long b) {
	char *u = gps->p + 1;
	jp = u;
}
void rs_6_05_01_2(unsigned long a, unsigned long b) {
	guca[2] ^= 128 - guca[4];
}
void rs_6_05_01_3(unsigned long a, unsigned long b) {
	char *u = jp;
	gp = u;
}
void rs_6_05_01_4(unsigned long a, unsigned long b) {
	v2(gi2, 4);
}
void rs_6_05_01_5(unsigned long a, unsigned long b) {
	long t = jl;
	v0();
	vl(t);
}
int rs_6_05_01_6(unsigned long a, unsigned long b) {
	return (gps->a[5] = gia[7]);
}
void rs_6_05_02_1(char a, int b, unsigned long c) {
	long t = ~65536L;
	jl = t;
}
void rs_6_05_02_2(char a, int b, unsigned long c) {
	int i = ji;
	for (i = 6; i > 0; i--) { gul = (unsigned long)(gua[i] != 256); if (gl != 0) gl = gps->l / gl; }
}
void rs_6_05_02_3(char a, int b, unsigned long c) {
	gul = rul((unsigned long)gs.u) - (9UL << (b & 15));
}
void rs_6_05_02_4(char a, int b, unsigned long c) {
	gi3 = gia[a] + gi2;
}
void rs_6_05_02_5(char a, int b, unsigned long c) {
	long t = jl;
	v0();
	gl = t;
}
void rs_6_05_02_6(char a, int b, unsigned long c) {
	gp++;
}
unsigned int rs_6_05_02_7(char a, int b, unsigned long c) {
	return (unsigned int)((gda[2] * gs.d) < (gc <= gps->c ? gd : gda[2]));
}
void rs_6_05_03_1(int *a) {
	double t = (double)*a * gda[3];
	jd = t;
}
void rs_6_05_03_2(int *a) {
	double t = jd;
	gd = t;
}
void rs_6_05_03_3(int *a) {
	int i = ji;
	for (i = 0; i < 8; i++) { gul &= gul + 12523UL; gua[i] = gs.u; }
}
void rs_6_05_03_4(int *a) {
	if (gu2 < 6) if (gu2 != 0) gu = 4 / gu2;
}
unsigned int rs_6_05_03_5(int *a) {
	return gu2 - (gu2 | gua[1]);
}
void rs_6_05_04_0(unsigned long a, char b) {
	gul /= 2UL;
}
void rs_6_05_04_1(unsigned long a, char b) {
	gl2 *= 2L;
}
void rs_6_05_04_2(unsigned long a, char b) {
	guca[b] = guc / 2;
}
int * rs_6_05_04_3(unsigned long a, char b) {
	return gpi;
}
void rs_6_05_05_1(int a, unsigned long b, unsigned long c) {
	unsigned char t = (unsigned char)b;
	juc = t;
}
void rs_6_05_05_2(int a, unsigned long b, unsigned long c) {
	unsigned char t = juc;
	gu -= gua[t] - gps->u;
}
void rs_6_05_05_3(int a, unsigned long b, unsigned long c) {
	int i = ji;
	unsigned char t = juc;
	i = a; do { if (gpl[2] != 0) gl = 65536L / gpl[2]; gc = (t <= ((unsigned char)c) ? (*gp % 3) : gs.c); gps->a[i] |= (int)gu; } while (--i > 0);
}
void rs_6_05_05_4(int a, unsigned long b, unsigned long c) {
	gc2 += (char)(gula[7] <= b);
}
void rs_6_05_05_5(int a, unsigned long b, unsigned long c) {
	int i = ji;
	for (i = 5; i > 0; i--) { gla[7] -= ~gl; vd(1.0); }
}
int rs_6_05_05_6(int a, unsigned long b, unsigned long c) {
	unsigned char t = juc;
	v0();
	return (int)t;
}
void rs_6_05_06_0(void) {
	v0();
}
void rs_6_05_06_1(void) {
	gl2 *= 7L;
}
int * rs_6_05_06_2(void) {
	return gpi + 1;
}
void rs_6_05_07_0(void) {
	long t = gpl[2];
	jl = t;
}
void rs_6_05_07_1(void) {
	char u = (*gpi ? '9' : *gp);
	jc = u;
}
void rs_6_05_07_2(void) {
	long t = jl;
	char u = jc;
	if (!gc2) { guc += (unsigned char)(gi2 == gs.i); t = ~(gla[u] * gla[1]); gua[3] = 255; }
}
void rs_6_05_07_3(void) {
	vs(gps);
}
void rs_6_05_07_4(void) {
	++gi3;
}
void rs_6_05_07_5(void) {
	long t = jl;
	v0();
	if (t != 0) t = t % t;
}
int * rs_6_05_07_6(void) {
	return gpi;
}
void rs_6_05_08_0(struct st *a, struct st *b, char *c) {
	gps->i *= 2;
}
void rs_6_05_08_1(struct st *a, struct st *b, char *c) {
	vl(gps->l);
}
void rs_6_05_08_2(struct st *a, struct st *b, char *c) {
	if (gd2 >= 2.5) { gi2 = r2(gi2, b->i) << 3; }
}
void rs_6_05_08_3(struct st *a, struct st *b, char *c) {
	gd *= gs.d;
}
char * rs_6_05_08_4(struct st *a, struct st *b, char *c) {
	return gs.p;
}
void rs_6_05_09_0(void) {
	unsigned char t = (unsigned char)gu2;
	juc = t;
}
void rs_6_05_09_1(void) {
	unsigned long u = gul;
	jul = u;
}
void rs_6_05_09_2(void) {
	if (*gp < gc2) if (gl2 != 0) gps->l = (long)gc / gl2;
}
void rs_6_05_09_3(void) {
	unsigned char t = juc;
	v1(t);
}
void rs_6_05_09_4(void) {
	gd -= 0.5;
}
void rs_6_05_09_5(void) {
	unsigned long u = jul;
	v0();
	gul = u;
}
void rs_6_05_09_6(void) {
	vu(11104);
}
void rs_6_05_09_7(void) {
	gs.l = (long)6;
}
char * rs_6_05_09_8(void) {
	unsigned char t = juc;
	v0();
	return gp + t;
}
void rs_6_05_10_0(char a) {
	unsigned int t = (unsigned int)gula[7];
	ju = t;
}
void rs_6_05_10_1(char a) {
	unsigned char u = 94 << 4;
	juc = u;
}
void rs_6_05_10_2(char a) {
	vs(gps);
}
void rs_6_05_10_3(char a) {
	vu(ru(gua[5]));
}
void rs_6_05_10_4(char a) {
	unsigned int t = ju;
	v0();
	vu(t);
}
void rs_6_05_10_5(char a) {
	gda[2] -= -gd2;
}
void rs_6_05_10_6(char a) {
	unsigned char u = juc;
	v0();
	guc = u;
}
void rs_6_05_10_7(char a) {
	gul = rul(81103UL * gula[7]);
}
void rs_6_05_10_8(char a) {
	*gpl = gl2;
}
int * rs_6_05_10_9(char a) {
	return gpi;
}
void rs_6_05_11_0(void) {
	unsigned int t = 32767 % 100;
	ju = t;
}
void rs_6_05_11_1(void) {
	int u = (int)gl2 - gps->a[0];
	ji = u;
}
void rs_6_05_11_2(void) {
	int u = ji;
	u ^= (guc > guca[6]);
}
void rs_6_05_11_3(void) {
	gc++;
}
void rs_6_05_11_4(void) {
	unsigned int t = ju;
	vu(t);
}
void rs_6_05_11_5(void) {
	gs.i >>= 1;
}
void rs_6_05_12_0(unsigned int a, int b, int c) {
	unsigned int t = gu2 / 7;
	ju = t;
}
void rs_6_05_12_1(unsigned int a, int b, int c) {
	gl2 = gs.l;
}
void rs_6_05_12_2(unsigned int a, int b, int c) {
	gp = rp();
}
void rs_6_05_12_3(unsigned int a, int b, int c) {
	--gpi;
}
void rs_6_05_12_4(unsigned int a, int b, int c) {
	if (*gpl) { gul <<= 8; gula[4] = gula[c]; } else { if (gla[b] != 0) gl = gs.l / gla[b]; }
}
void rs_6_05_12_5(unsigned int a, int b, int c) {
	gs.p = gp;
}
void rs_6_05_12_6(unsigned int a, int b, int c) {
	unsigned int t = ju;
	v0();
	gu = t;
}
char * rs_6_05_12_7(unsigned int a, int b, int c) {
	return gps->p;
}
void rs_6_05_13_0(struct st *a, int b, char *c) {
	--gul;
}
void rs_6_05_13_1(struct st *a, int b, char *c) {
	gs.d = gda[1] / 0.25;
}
void rs_6_05_13_2(struct st *a, int b, char *c) {
	gs.d *= (3UL == 9UL ? (double)gla[b] : gda[3]);
}
int rs_6_05_13_3(struct st *a, int b, char *c) {
	return *gpi - (gi3 - 2);
}
void rs_6_05_14_1(char *a, struct st *b, long *c) {
	double t = gs.d * gd2;
	jd = t;
}
void rs_6_05_14_2(char *a, struct st *b, long *c) {
	int i = ji;
	double t = jd;
	for (i = 0; i < 3; i++) { if (gua[0] != 0) gua[0] = gua[i] / gua[0]; t = gd / 1.0; gpi = &gia[i]; }
}
void rs_6_05_14_3(char *a, struct st *b, long *c) {
	vu(ru(1));
}
void rs_6_05_14_4(char *a, struct st *b, long *c) {
	gpl[2] = -gl2;
}
void rs_6_05_14_5(char *a, struct st *b, long *c) {
	int i = ji;
	v0();
	gi2 = gia[3] - gps->i;
}
long rs_6_05_14_6(char *a, struct st *b, long *c) {
	return (long)(guc < (guc - 128));
}
void rs_6_05_15_0(void) {
	int t = gps->a[6] / 3;
	ji = t;
}
void rs_6_05_15_1(void) {
	double u = gd2;
	jd = u;
}
void rs_6_05_15_2(void) {
	double u = jd;
	gs.u = gua[2];
}
void rs_6_05_15_3(void) {
	--guc;
}
void rs_6_05_15_4(void) {
	int t = ji;
	gp[2] <<= (t & 7);
}
void rs_6_05_15_5(void) {
	vp(rp());
}
long rs_6_05_15_6(void) {
	if (guca[6] & 0x8) return gl2;
}
long rs_6_05_15_7(void) {
	return gl2;
}
void rs_6_05_16_0(char a) {
	double t = gs.d / 100.0;
	jd = t;
}
void rs_6_05_16_1(char a) {
	double u = -gs.d;
	jd = u;
}
void rs_6_05_16_2(char a) {
	guc = (guc + 255) + guc;
}
void rs_6_05_16_3(char a) {
	guca[3] = guca[a] << (a & 7);
}
void rs_6_05_16_4(char a) {
	double u = jd;
	u -= u;
}
void rs_6_05_16_5(char a) {
	while (gi-- > 0) *gp++ = 98;
}
void rs_6_05_16_6(char a) {
	double t = jd;
	gd = t;
}
void rs_6_05_16_7(char a) {
	double u = jd;
	if (*gpi) { gi = (gul > 0x10000UL) | r1(gi3); gl *= 2L; guc = ~((unsigned char)!gs.i); } else { gps->i = (int)gps->u; }
}
unsigned long rs_6_05_16_8(char a) {
	return (!guc ? (r0() ? gul : gul) : (gula[a] % 4UL));
}
void rs_6_05_17_1(char a, int b) {
	double t = gs.d * (double)gua[a];
	jd = t;
}
void rs_6_05_17_2(char a, int b) {
	int *u = gpi + b;
	jpi = u;
}
long rs_6_05_17_3(char a, int b) {
	if (r0()) return gps->l + *gpl;
}
void rs_6_05_17_4(char a, int b) {
	while (b > 0) { gi2 += *gpi++; b--; }
}
void rs_6_05_17_5(char a, int b) {
	double t = jd;
	v0();
	vd(t);
}
void rs_6_05_17_6(char a, int b) {
	int *u = jpi;
	v0();
	v1(*u);
}
void rs_6_05_17_7(char a, int b) {
	int i = ji;
	v0();
	i = b; do { gs.l = (long)!gs.c >> 26; v2(gi2, r1(b)); gul = 0x10000UL >> 22; } while (--i > 0);
}
void rs_6_05_17_8(char a, int b) {
	*gpi = gi2 / 10;
}
long rs_6_05_17_9(char a, int b) {
	return (gla[7] + 68917L) * 7L;
}
void rs_6_05_18_1(void) {
	double t = gs.d - gd2;
	jd = t;
}
void rs_6_05_18_2(void) {
	int i = ji;
	for (i = 0; i < 5; i++) { gl = rl((long)gula[i]) ^ (long)gul; }
}
void rs_6_05_18_3(void) {
	guc--;
}
void rs_6_05_18_4(void) {
	if (gi3 < *gpi) { if (gul != 0) gul = gula[5] % gul; }
}
void rs_6_05_18_5(void) {
	double t = jd;
	v0();
	vd(t);
}
void rs_6_05_19_0(void) {
	unsigned long t = gula[1] - gula[5];
	jul = t;
}
void rs_6_05_19_1(void) {
	unsigned int u = ~gua[3];
	ju = u;
}
void rs_6_05_19_2(void) {
	*gpi ^= -(-708);
}
void rs_6_05_19_3(void) {
	unsigned long t = jul;
	if (t != 0) gul = gula[6] / t;
}
void rs_6_05_19_4(void) {
	unsigned int u = ju;
	gu = u;
}
void rs_6_06_00_0(double a, int *b, char c) {
	char t = gca[6];
	jc = t;
}
void rs_6_06_00_1(double a, int *b, char c) {
	if (gua[c] <= gps->u) b = gpi;
}
void rs_6_06_00_2(double a, int *b, char c) {
	vl(-56478L + gla[4]);
}
void rs_6_06_00_3(double a, int *b, char c) {
	char t = jc;
	v0();
	switch (gs.u) { case 0: gs.u >>= 9; case 1: guca[t] += guca[2]; break; case 2: gi2 = b[t]; break; case 3: gps->p = rp(); break; }
}
unsigned long rs_6_06_00_4(double a, int *b, char c) {
	return gul;
}
void rs_6_06_01_0(unsigned int a, char *b, int c) {
	double t = gda[0] + gd2;
	jd = t;
}
void rs_6_06_01_1(unsigned int a, char *b, int c) {
	int u = c / 4;
	ji = u;
}
void rs_6_06_01_2(unsigned int a, char *b, int c) {
	c = gia[3];
}
void rs_6_06_01_3(unsigned int a, char *b, int c) {
	int u = ji;
	switch (gi) { case 0: vu(5); break; case 1: gps->p = &gca[4]; break; case 2: gua[a] += gps->u; break; case 3: case 4: gpi = rpi(u); break; case 5: gps->u |= gu2; default: gl2 = -10013L; break; }
}
void rs_6_06_01_4(unsigned int a, char *b, int c) {
	gu = ru(a) - ~a;
}
void rs_6_06_01_5(unsigned int a, char *b, int c) {
	double t = jd;
	v0();
	vd(t);
}
void rs_6_06_01_6(unsigned int a, char *b, int c) {
	guc = (guca[2] % 4) + (guca[6] ^ guca[4]);
}
void rs_6_06_01_7(unsigned int a, char *b, int c) {
	*gpi |= 100;
}
char * rs_6_06_01_8(unsigned int a, char *b, int c) {
	return gp + c;
}
void rs_6_06_02_0(char a, unsigned long b) {
	unsigned char t = guc * 1;
	juc = t;
}
void rs_6_06_02_1(char a, unsigned long b) {
	if (((unsigned char)gul) < ((unsigned char)a)) { a -= rc(gpi[3]); v0(); gi2 = gi3; } else { gc2 = (char)!gu; gula[5] = -b; }
}
void rs_6_06_02_2(char a, unsigned long b) {
	unsigned char t = juc;
	v0();
	gua[t] += (unsigned int)gp[2];
}
void rs_6_06_02_3(char a, unsigned long b) {
	unsigned char t = juc;
	v0();
	guc = (b > gula[4] || gua[5] ? ((unsigned char)gps->a[t]) : (t - guca[7]));
}
void rs_6_06_02_4(char a, unsigned long b) {
	gl = gps->l = gla[5];
}
void rs_6_06_02_5(char a, unsigned long b) {
	v0();
}
char * rs_6_06_02_6(char a, unsigned long b) {
	return gps->p;
}
void rs_6_06_03_0(void) {
	gl2 = (gla[1] / 4L) - gl2;
}
void rs_6_06_03_1(void) {
	v0();
}
long rs_6_06_03_2(void) {
	return (!gi2 ? gla[0] : gs.l) ^ (gla[3] << 3);
}
void rs_6_06_04_1(void) {
	int t = gi3 / 3;
	ji = t;
}
void rs_6_06_04_2(void) {
	int *u = gpi;
	jpi = u;
}
void rs_6_06_04_3(void) {
	int i = ji;
	i = 11; do { vs(gps); vs(gps); } while (--i > 0);
}
void rs_6_06_04_4(void) {
	int i = ji;
	v0();
	for (i = 0; i < 13; i++) { guc *= 9; ++gp; }
}
void rs_6_06_04_5(void) {
	int t = ji;
	v0();
	v1(t);
}
void rs_6_06_04_6(void) {
	int *u = jpi;
	v0();
	v1(*u);
}
void rs_6_06_04_7(void) {
	v0();
}
unsigned long rs_6_06_04_8(void) {
	int t = ji;
	v0();
	return (gula[t] = gul);
}
void rs_6_06_05_0(long a, int *b, char c) {
	int t = 8;
	ji = t;
}
void rs_6_06_05_1(long a, int *b, char c) {
	int t = ji;
	gul = gula[t] = rul(gula[c]);
}
void rs_6_06_05_2(long a, int *b, char c) {
	vc(-29);
}
void rs_6_06_05_3(long a, int *b, char c) {
	gs.u = -gps->u;
}
int rs_6_06_05_4(long a, int *b, char c) {
	return *gpi;
}
void rs_6_06_06_0(unsigned char a) {
	double t = 0.25 - gs.d;
	jd = t;
}
void rs_6_06_06_1(unsigned char a) {
	if (gul) gc = 'a';
}
void rs_6_06_06_2(unsigned char a) {
	gi3 = (gi3 % 16) ^ gps->a[a];
}
void rs_6_06_06_3(unsigned char a) {
	gul &= ((unsigned long)*gpi) - 0x10000UL;
}
void rs_6_06_06_4(unsigned char a) {
	v2(~gi2, gi);
}
void rs_6_06_06_5(unsigned char a) {
	double t = jd;
	v0();
	gd = t;
}
void rs_6_06_06_6(unsigned char a) {
	while (gi-- > 0) { if (*gp == 'z') break; gp++; }
}
void rs_6_06_07_1(void) {
	unsigned int t = 256;
	ju = t;
}
void rs_6_06_07_2(void) {
	int *u = gpi;
	jpi = u;
}
void rs_6_06_07_3(void) {
	gda[0] = gda[3] * gd;
}
void rs_6_06_07_4(void) {
	unsigned int t = ju;
	t = 667 << (t & 15);
}
void rs_6_06_07_5(void) {
	int i = ji;
	for (i = 0; i < 15; i++) { gula[i] = gula[i] + gul; guc = (unsigned char)!(gi2 / 10); }
}
void rs_6_06_07_6(void) {
	gula[4] = gula[1];
}
void rs_6_06_07_7(void) {
	int *u = jpi;
	gpi = u;
}
int rs_6_06_07_8(void) {
	unsigned int t = ju;
	return gia[t];
}
void rs_6_06_08_1(int a, unsigned char b, int c) {
	int *t = gpi + b;
	jpi = t;
}
void rs_6_06_08_2(int a, unsigned char b, int c) {
	int u = gia[5] + gia[a];
	ji = u;
}
void rs_6_06_08_3(int a, unsigned char b, int c) {
	gu2 = gu2 - ~gu2;
}
void rs_6_06_08_4(int a, unsigned char b, int c) {
	int i = ji;
	int u = ji;
	for (i = 12; i > 0; i--) { if (c != 0) u = (int)gu2 % c; }
}
void rs_6_06_08_5(int a, unsigned char b, int c) {
	int i = ji;
	i = 11; do { gl2 = (guca[i] > guc ? (gl2 + 7L) : (3L - gl2)); vl(-(-30202L)); gla[i] = (gl2 - gpl[0]) + (gla[i] / 3L); } while (--i > 0);
}
void rs_6_06_08_6(int a, unsigned char b, int c) {
	int *t = jpi;
	v0();
	v1(*t);
}
unsigned int rs_6_06_08_7(int a, unsigned char b, int c) {
	return (gu2 * 7) - (255 - 23547);
}
void rs_6_06_09_1(unsigned long a, int *b) {
	if (gps->l & 0x80) { gca[6] = (gp[2] + 2) + (gc2 * 'A'); gia[2] = 127 % 4; }
}
void rs_6_06_09_2(unsigned long a, int *b) {
	guca[5] += 255;
}
void rs_6_06_09_3(unsigned long a, int *b) {
	gs.a[5] += -435;
}
void rs_6_06_09_4(unsigned long a, int *b) {
	if (gi2 != 0) *gpi = gia[0] / gi2;
}
void rs_6_06_09_5(unsigned long a, int *b) {
	int i = ji;
	for (i = 0; i < 7; i++) { *b = gi3 << 4; guca[i] /= 10; }
}
long rs_6_06_09_6(unsigned long a, int *b) {
	return 65536L;
}
void rs_6_06_10_0(unsigned long a, double b, int c) {
	gs.p = gps->p;
}
void rs_6_06_10_1(unsigned long a, double b, int c) {
	gl2 = (guc ? gs.l : (long)gua[0]) + gl;
}
void rs_6_06_10_2(unsigned long a, double b, int c) {
	if (gul <= 7UL) vl(gs.l << 27);
}
void rs_6_06_10_3(unsigned long a, double b, int c) {
	gu += gs.u % 100;
}
void rs_6_06_10_4(unsigned long a, double b, int c) {
	vs(gps);
}
void rs_6_06_11_0(long a, int b, unsigned int c) {
	if (gia[c] != 0) gi = gs.i / gia[c];
}
void rs_6_06_11_1(long a, int b, unsigned int c) {
	guca[2] <<= (c & 7);
}
void rs_6_06_11_2(long a, int b, unsigned int c) {
	gul <<= (c & 15);
}
int rs_6_06_11_3(long a, int b, unsigned int c) {
	if (gua[1] & 0x80) return gpi[2] - gps->a[5];
}
int rs_6_06_11_4(long a, int b, unsigned int c) {
	return (b = gs.i);
}
void rs_6_06_12_0(long a, int b) {
	unsigned char t = guc + 255;
	juc = t;
}
void rs_6_06_12_1(long a, int b) {
	if (5UL <= gula[2]) vc(gp[1] >> 3);
}
void rs_6_06_12_2(long a, int b) {
	if (!*gp) gpi = gpi + b;
}
void rs_6_06_12_3(long a, int b) {
	gl = (long)gul;
}
void rs_6_06_12_4(long a, int b) {
	gs.d = gs.d + (double)gpi[2];
}
void rs_6_06_12_5(long a, int b) {
	unsigned char t = juc;
	v0();
	v1(t);
}
unsigned long rs_6_06_12_6(long a, int b) {
	return ((unsigned long)!gia[0]) - gul;
}
void rs_6_06_13_0(void) {
	int t = gi2 ^ gia[4];
	ji = t;
}
void rs_6_06_13_1(void) {
	long u = 65536L & gla[1];
	jl = u;
}
void rs_6_06_13_2(void) {
	gl = ((long)(gua[6] >= gu)) | gl;
}
void rs_6_06_13_3(void) {
	int t = ji;
	long u = jl;
	if (guca[t] == 66 && (gul = gula[6]) < 4UL) { guc = guca[t]; gla[6] = u = (long)gul ^ (u + 29245L); if (gc2 != 0) *gp = *gp / gc2; } else { v2(gi2, gia[t]); }
}
void rs_6_06_14_1(double a, int b) {
	long t = (long)(1.0 != gs.d);
	jl = t;
}
void rs_6_06_14_2(double a, int b) {
	double u = gs.d - gs.d;
	jd = u;
}
void rs_6_06_14_3(double a, int b) {
	gp[0] = gc = ~(-54) ^ (char)!gul;
}
void rs_6_06_14_4(double a, int b) {
	long t = jl;
	t--;
}
void rs_6_06_14_5(double a, int b) {
	int i = ji;
	long t = jl;
	i = 0; while (i < 16) { gla[b] = t; gla[i] = 34601L; if (*gp != 0) gs.c = gc2 / *gp; i++; }
}
void rs_6_06_14_6(double a, int b) {
	gua[3] = gu + gua[7];
}
void rs_6_06_14_7(double a, int b) {
	double u = jd;
	gd = u;
}
unsigned long rs_6_06_14_8(double a, int b) {
	return (gula[5] ^ gula[7]) & -42117UL;
}
void rs_6_06_15_1(unsigned int a, unsigned int b) {
	unsigned long t = gul >> (a & 15);
	jul = t;
}
void rs_6_06_15_2(unsigned int a, unsigned int b) {
	char *u = gps->p + b;
	jp = u;
}
void rs_6_06_15_3(unsigned int a, unsigned int b) {
	int i = ji;
	for (i = 0; i < 5; i++) { vs(gps); }
}
void rs_6_06_15_4(unsigned int a, unsigned int b) {
	gp = &gca[b];
}
void rs_6_06_15_5(unsigned int a, unsigned int b) {
	if (gla[2] & 2) guca[2] = guca[a];
}
void rs_6_06_15_6(unsigned int a, unsigned int b) {
	char *u = jp;
	v0();
	vp(u);
}
void rs_6_06_15_7(unsigned int a, unsigned int b) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
unsigned int rs_6_06_15_8(unsigned int a, unsigned int b) {
	return (gla[b] ? (gu - 1) : ((unsigned int)(255 <= 0)));
}
void rs_6_06_16_0(double a) {
	char t = rc(gi2);
	jc = t;
}
unsigned long rs_6_06_16_1(double a) {
	char t = jc;
	v0();
	if (gula[t] == 93399UL || gu2 != 1) return (unsigned long)!1;
}
void rs_6_06_16_2(double a) {
	--gi3;
}
void rs_6_06_16_3(double a) {
	if (!gi3) if (gula[3] != 0) gul = gul % gula[3];
}
unsigned long rs_6_06_16_4(double a) {
	return gul;
}
void rs_6_06_17_0(long *a, long b, int c) {
	b--;
}
void rs_6_06_17_1(long *a, long b, int c) {
	gua[c] = gu2;
}
void rs_6_06_17_2(long *a, long b, int c) {
	gula[c] -= gula[7];
}
long rs_6_06_17_3(long *a, long b, int c) {
	return rl((long)gs.u + a[3]);
}
void rs_6_06_18_0(unsigned long a, long b) {
	long t = gl;
	jl = t;
}
void rs_6_06_18_1(unsigned long a, long b) {
	++gc;
}
void rs_6_06_18_2(unsigned long a, long b) {
	gps->c /= 3;
}
void rs_6_06_18_3(unsigned long a, long b) {
	long t = jl;
	vl(t);
}
int * rs_6_06_18_4(unsigned long a, long b) {
	return gpi;
}
void rs_6_06_19_0(char a, unsigned int b, char c) {
	gul++;
}
void rs_6_06_19_1(char a, unsigned int b, char c) {
	vp(gps->p);
}
unsigned int rs_6_06_19_2(char a, unsigned int b, char c) {
	return gs.u;
}
void rs_6_07_00_0(char *a, char b) {
	long t = (255 >= guca[b] ? gla[b] : 65536L);
	jl = t;
}
void rs_6_07_00_1(char *a, char b) {
	char *u = a;
	jp = u;
}
void rs_6_07_00_2(char *a, char b) {
	long t = jl;
	vl(t);
}
void rs_6_07_00_3(char *a, char b) {
	char *u = jp;
	v0();
	vp(u);
}
void rs_6_07_00_4(char *a, char b) {
	vc((gps->a[b] & 0x80 ? *gp : gc2));
}
void rs_6_07_00_5(char *a, char b) {
	gpi = gpi + b;
}
int rs_6_07_00_6(char *a, char b) {
	return gi << 10;
}
void rs_6_07_01_1(void) {
	int i = ji;
	i = 2; do { gps->l = gpl[3] = -((long)(gu2 != gs.u)); gua[4] = gu2; } while (--i > 0);
}
void rs_6_07_01_2(void) {
	gu2 = ((unsigned int)gs.c) >> 4;
}
void rs_6_07_01_3(void) {
	if (guc) { gu = gps->u; gps->p = gp + 1; gd += gs.d * gd; } else { gi2++; }
}
void rs_6_07_01_4(void) {
	if (gl2 && gu) guca[3] = (unsigned char)((gul * 6UL) == (guca[6] ? gula[7] : gula[5]));
}
void rs_6_07_02_0(long *a, struct st *b, char *c) {
	gul = gula[0] - (gula[6] % 7UL);
}
void rs_6_07_02_1(long *a, struct st *b, char *c) {
	gs.u = gu = b->u;
}
int rs_6_07_02_2(long *a, struct st *b, char *c) {
	return (gi2 = (int)gl2);
}
void rs_6_07_03_0(int a, char b) {
	char *t = gp;
	jp = t;
}
void rs_6_07_03_1(int a, char b) {
	int *u = &gia[b];
	jpi = u;
}
void rs_6_07_03_2(int a, char b) {
	int *u = jpi;
	u = u + a;
}
void rs_6_07_03_3(int a, char b) {
	--guc;
}
void rs_6_07_03_4(int a, char b) {
	int *u = jpi;
	if (gul < 7UL) gi3 = a = *u;
}
void rs_6_07_03_5(int a, char b) {
	int *u = jpi;
	v1(u[3]);
}
void rs_6_07_03_6(int a, char b) {
	char *t = jp;
	v0();
	vp(t);
}
int rs_6_07_03_7(int a, char b) {
	return (gs.i = gia[2]);
}
void rs_6_07_04_0(void) {
	unsigned long t = rul(gul);
	jul = t;
}
void rs_6_07_04_1(void) {
	unsigned long u = (unsigned long)gc;
	v0();
	jul = u;
}
void rs_6_07_04_2(void) {
	if (gl != 0) gl = *gpl / gl;
}
void rs_6_07_04_3(void) {
	vp(&gca[2]);
}
void rs_6_07_04_4(void) {
	unsigned long u = jul;
	v0();
	gul = u;
}
void rs_6_07_04_5(void) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
char rs_6_07_04_6(void) {
	return gs.c;
}
void rs_6_07_05_0(unsigned char a, unsigned char b) {
	gu++;
}
void rs_6_07_05_1(unsigned char a, unsigned char b) {
	gpi[2] = ((long)gula[a] != gs.l);
}
void rs_6_07_05_2(unsigned char a, unsigned char b) {
	gi3 = gs.i;
}
unsigned int rs_6_07_05_3(unsigned char a, unsigned char b) {
	return gua[b];
}
void rs_6_07_06_0(unsigned char a, int b, unsigned char c) {
	gc2 = gp[0] = rc(~gi2);
}
void rs_6_07_06_1(unsigned char a, int b, unsigned char c) {
	gl2 = (long)gps->i;
}
void rs_6_07_06_2(unsigned char a, int b, unsigned char c) {
	gul = ~(gul ^ ((unsigned long)gu));
}
void rs_6_07_06_3(unsigned char a, int b, unsigned char c) {
	if (gu <= 256) { *gp = gs.c ^ 'A'; }
}
unsigned long rs_6_07_06_4(unsigned char a, int b, unsigned char c) {
	return ((unsigned long)8) * 99196UL;
}
void rs_6_07_07_0(unsigned int a, unsigned int b) {
	long t = gl & *gpl;
	jl = t;
}
void rs_6_07_07_1(unsigned int a, unsigned int b) {
	long t = jl;
	if (t < 30787L) { gl = *gpl; gu2 = (gu2 ^ gua[a]) >> 10; } else { if (gs.c != 0) *gp = gc2 % gs.c; gps->c = gc = 9 << 2; if (gc != 0) gca[b] = gp[1] % gc; }
}
void rs_6_07_07_2(unsigned int a, unsigned int b) {
	gul--;
}
void rs_6_07_07_3(unsigned int a, unsigned int b) {
	switch (gps->c) { case 0: gua[3] = ru(gu2); break; case 1: gp = gs.p + a; break; case 2: vl(gla[b]); break; case 3: case 4: guca[4] -= (unsigned char)gl; break; }
}
void rs_6_07_07_4(unsigned int a, unsigned int b) {
	gpi = gpi + b;
}
int rs_6_07_07_5(unsigned int a, unsigned int b) {
	return (gi3 = 286);
}
void rs_6_07_08_1(int *a, unsigned int b, int c) {
	int t = *gpi + gi3;
	ji = t;
}
void rs_6_07_08_2(int *a, unsigned int b, int c) {
	gla[6] = (long)gc2;
}
void rs_6_07_08_3(int *a, unsigned int b, int c) {
	gs.l = gla[c] - (gla[c] <= gl2 ? *gpl : gla[7]);
}
void rs_6_07_08_4(int *a, unsigned int b, int c) {
	int i = ji;
	int t = ji;
	for (i = 0; i < c; i++) { if (t != 0) gi2 = gia[i] / t; if (gul != 0) gula[i] = gul / gul; v1(gia[i] & gi3); }
}
void rs_6_07_08_5(int *a, unsigned int b, int c) {
	gca[4] = gca[6];
}
int * rs_6_07_08_6(int *a, unsigned int b, int c) {
	return gpi + b;
}
void rs_6_07_09_1(double a) {
	int i = ji;
	i = 0; while (i < 14) { --guc; i++; }
}
void rs_6_07_09_2(double a) {
	gula[2] += 6UL & 9UL;
}
void rs_6_07_09_3(double a) {
	if (gs.l && gps->a[7] < 100) vu(gu);
}
void rs_6_07_09_4(double a) {
	v2(gi2, (!gi2 ? (int)gps->u : gia[7]));
}
void rs_6_07_09_5(double a) {
	gp[1] ^= rc(gs.a[6]);
}
char * rs_6_07_09_6(double a) {
	return gp;
}
void rs_6_07_10_0(int a, unsigned long b, unsigned int c) {
	unsigned int t = ru(gu);
	ju = t;
}
void rs_6_07_10_1(int a, unsigned long b, unsigned int c) {
	int u = r2(gps->a[2], gi);
	v0();
	ji = u;
}
void rs_6_07_10_2(int a, unsigned long b, unsigned int c) {
	b <<= 9;
}
void rs_6_07_10_3(int a, unsigned long b, unsigned int c) {
	unsigned int t = ju;
	v0();
	gu = t;
}
void rs_6_07_10_4(int a, unsigned long b, unsigned int c) {
	gi <<= 4;
}
void rs_6_07_10_5(int a, unsigned long b, unsigned int c) {
	int u = ji;
	v0();
	v1(u);
}
int rs_6_07_10_6(int a, unsigned long b, unsigned int c) {
	return gi;
}
void rs_6_07_11_1(void) {
	int t = gi2;
	ji = t;
}
void rs_6_07_11_2(void) {
	gu2 ^= 256;
}
void rs_6_07_11_3(void) {
	gl >>= 21;
}
void rs_6_07_11_4(void) {
	int t = ji;
	guc = guca[t] = guc ^ 128;
}
void rs_6_07_11_5(void) {
	int i = ji;
	int t = ji;
	i = 0; while (i < 9) { gi2 = ((int)gc2 != t) * 7; if (gula[t] != 0) gula[2] = 4UL / gula[t]; i++; }
}
void rs_6_07_11_6(void) {
	switch (gs.u) { case 0: case 1: gula[2] -= 98716UL; break; case 2: v2(gi2, gi3); case 3: vl(*gpl); break; case 4: *gp ^= gc; break; case 5: v0(); }
}
unsigned int rs_6_07_11_7(void) {
	return (gu2 - gua[3]) / 100;
}
void rs_6_07_12_0(long a) {
	gl2++;
}
void rs_6_07_12_1(long a) {
	vs(gps);
}
void rs_6_07_12_2(long a) {
	gu2 = gu = ru(gps->u);
}
void rs_6_07_12_3(long a) {
	gul = gula[3] * 12UL;
}
void rs_6_07_12_4(long a) {
	gps->p = gp + 1;
}
char rs_6_07_12_5(long a) {
	return rc(-gi3);
}
void rs_6_07_13_1(struct st *a) {
	long t = ~65536L;
	jl = t;
}
void rs_6_07_13_2(struct st *a) {
	guc /= 2;
}
void rs_6_07_13_3(struct st *a) {
	int i = ji;
	i = 11; do { gda[0] = (guc < guca[i] ? gd2 : (double)gu2); } while (--i > 0);
}
void rs_6_07_13_4(struct st *a) {
	int i = ji;
	i = 14; do { vp(gp); } while (--i > 0);
}
void rs_6_07_13_5(struct st *a) {
	++gp;
}
void rs_6_07_13_6(struct st *a) {
	gula[3] = gul = gul + (gula[6] - gul);
}
void rs_6_07_13_7(struct st *a) {
	long t = jl;
	v0();
	gl = t;
}
int rs_6_07_13_8(struct st *a) {
	return (int)gca[2] % 2;
}
void rs_6_07_14_0(int *a, long *b) {
	int *t = a;
	jpi = t;
}
void rs_6_07_14_1(int *a, long *b) {
	if (gc2 == 'A') { if (gps->a[5] != 0) *a = gps->a[4] / gps->a[5]; }
}
void rs_6_07_14_2(int *a, long *b) {
	gs.d = gd;
}
void rs_6_07_14_3(int *a, long *b) {
	int *t = jpi;
	++t;
}
void rs_6_07_14_4(int *a, long *b) {
	gu >>= 3;
}
void rs_6_07_14_5(int *a, long *b) {
	guca[2] += guca[6];
}
int rs_6_07_14_6(int *a, long *b) {
	int *t = jpi;
	return *t;
}
void rs_6_07_15_0(long *a, char b, unsigned char c) {
	gul += 0x10000UL;
}
void rs_6_07_15_1(long *a, char b, unsigned char c) {
	gd += gd;
}
void rs_6_07_15_2(long *a, char b, unsigned char c) {
	vl(gl);
}
void rs_6_07_15_3(long *a, char b, unsigned char c) {
	gs.p = gps->p;
}
int rs_6_07_15_4(long *a, char b, unsigned char c) {
	return gia[5] % 10;
}
void rs_6_07_16_1(long *a, long b) {
	if (gu2 != 0) gu2 = gua[5] % gu2;
}
void rs_6_07_16_2(long *a, long b) {
	int i = ji;
	i = 0; while (i < 12) { gua[i] = gu2; i++; }
}
unsigned long rs_6_07_16_3(long *a, long b) {
	return ~(gul - gula[6]);
}
void rs_6_07_17_0(char a, unsigned int b, char c) {
	char t = gps->c * gc;
	jc = t;
}
void rs_6_07_17_1(char a, unsigned int b, char c) {
	gl2 >>= 30;
}
void rs_6_07_17_2(char a, unsigned int b, char c) {
	guca[7] += guc;
}
void rs_6_07_17_3(char a, unsigned int b, char c) {
	char t = jc;
	if (gl2 < 73608L) if (t != 0) gc2 = gp[0] % t;
}
char * rs_6_07_17_4(char a, unsigned int b, char c) {
	return gs.p + a;
}
void rs_6_07_18_0(long a, unsigned long b) {
	gl = (65536L ^ gl) + 80665L;
}
void rs_6_07_18_1(long a, unsigned long b) {
	gula[5] = b;
}
void rs_6_07_18_2(long a, unsigned long b) {
	gua[6] = gu;
}
void rs_6_07_18_3(long a, unsigned long b) {
	guc = (55 << 5) % 16;
}
void rs_6_07_18_4(long a, unsigned long b) {
	gpi = rpi(gi2 | gs.a[3]);
}
void rs_6_07_19_1(int a, long b) {
	long t = 65536L % 10L;
	jl = t;
}
void rs_6_07_19_2(int a, long b) {
	char *u = gs.p + a;
	jp = u;
}
void rs_6_07_19_3(int a, long b) {
	*gpi /= 3;
}
void rs_6_07_19_4(int a, long b) {
	vu((unsigned int)!gpi[0]);
}
void rs_6_07_19_5(int a, long b) {
	gul = rul(gula[2]);
}
void rs_6_07_19_6(int a, long b) {
	char *u = jp;
	v0();
	switch (gi2) { case 1: guc = guca[4] % 3; break; case 2: vl(9L); break; default: gps->u = -gu2; break; }
}
void rs_6_07_19_7(int a, long b) {
	int i = ji;
	v0();
	for (i = 0; i < 12; i++) { ++gu2; vd(2.5 / 1.0); gua[i] = ((unsigned int)guc) - (gu2 | gua[a]); }
}
void rs_6_07_19_8(int a, long b) {
	long t = jl;
	v0();
	vl(t);
}
char * rs_6_07_19_9(int a, long b) {
	return gps->p + a;
}
void rs_6_08_00_0(void) {
	int t = *gpi;
	ji = t;
}
void rs_6_08_00_1(void) {
	long u = 65536L;
	jl = u;
}
void rs_6_08_00_2(void) {
	int t = ji;
	t = gi;
}
void rs_6_08_00_3(void) {
	int t = ji;
	if ((long)guc == gl || gca[t] < 5) if (gs.c != 0) gc = gc % gs.c;
}
void rs_6_08_00_4(void) {
	long u = jl;
	vl(u);
}
char rs_6_08_00_5(void) {
	return (5 * 51) >> 2;
}
void rs_6_08_01_0(void) {
	unsigned long t = (unsigned long)(guca[4] >= guc);
	jul = t;
}
void rs_6_08_01_1(void) {
	gps->i = gpi[0] = (gpi[0] / 16) - (1 * 10);
}
void rs_6_08_01_2(void) {
	gp++;
}
void rs_6_08_01_3(void) {
	unsigned long t = jul;
	vl((long)t);
}
void rs_6_08_01_4(void) {
	vp(gp);
}
int rs_6_08_01_5(void) {
	return gs.a[3] + (2 | gs.a[5]);
}
void rs_6_08_02_0(void) {
	gu = ((unsigned int)(gula[5] == gula[7])) + (gps->u + gua[3]);
}
void rs_6_08_02_1(void) {
	--guc;
}
void rs_6_08_02_2(void) {
	guca[2] /= 16;
}
void rs_6_08_02_3(void) {
	gd = gd2;
}
void rs_6_08_03_0(int *a, long b, int *c) {
	switch (gl2) { case 0L: gps->l %= 3L; break; case 1L: vp(gp); break; case 2L: v0(); case 3L: gd2 += 100.0; break; }
}
void rs_6_08_03_1(int *a, long b, int *c) {
	if (gua[4] != 0) gu2 = gu2 % gua[4];
}
void rs_6_08_03_2(int *a, long b, int *c) {
	switch (gi) { case 0: gua[7] = gu2; break; case 1: vp(&gca[3]); break; }
}
int rs_6_08_03_3(int *a, long b, int *c) {
	return *a;
}
void rs_6_08_04_0(unsigned int a, struct st *b) {
	unsigned char t = ~144;
	juc = t;
}
void rs_6_08_04_1(unsigned int a, struct st *b) {
	unsigned char t = juc;
	unsigned char u = guc * t;
	juc = u;
}
void rs_6_08_04_2(unsigned int a, struct st *b) {
	gd = (gda[0] - (double)gs.l) / 100.0;
}
void rs_6_08_04_3(unsigned int a, struct st *b) {
	unsigned char u = juc;
	v1(u);
}
void rs_6_08_04_4(unsigned int a, struct st *b) {
	unsigned char t = juc;
	v0();
	v1(t);
}
void rs_6_08_04_5(unsigned int a, struct st *b) {
	vl((long)32767);
}
void rs_6_08_05_0(int a, int b, char *c) {
	long t = gl;
	jl = t;
}
void rs_6_08_05_1(int a, int b, char *c) {
	int u = *gpi >> (a & 15);
	ji = u;
}
void rs_6_08_05_2(int a, int b, char *c) {
	gpi = &gia[7];
}
void rs_6_08_05_3(int a, int b, char *c) {
	long t = jl;
	vl(t);
}
void rs_6_08_05_4(int a, int b, char *c) {
	guc = ((unsigned char)gula[6]) << 3;
}
void rs_6_08_05_5(int a, int b, char *c) {
	gula[b] = 8UL;
}
void rs_6_08_05_6(int a, int b, char *c) {
	int u = ji;
	v0();
	if (r0() && 0x10000UL >= 41119UL) { gul = ~15624UL; vd(1.0 + 1.0); gs.c = gca[u] ^ -70; }
}
unsigned int rs_6_08_05_7(int a, int b, char *c) {
	long t = jl;
	v0();
	return (255 + gu2) | ((unsigned int)(gps->l == t));
}
void rs_6_08_06_1(unsigned long a, double b) {
	double t = gs.d;
	jd = t;
}
void rs_6_08_06_2(unsigned long a, double b) {
	int i = ji;
	for (i = 0; i < 9; i++) { gu |= ru(gu2); gp = &gca[2]; }
}
void rs_6_08_06_3(unsigned long a, double b) {
	double t = jd;
	v0();
	gd = t;
}
void rs_6_08_06_4(unsigned long a, double b) {
	if (gd2 == b) gs.u = -gps->u;
}
void rs_6_08_06_5(unsigned long a, double b) {
	if (gi2 & 2) { if (gi3 != 0) gi = gia[7] % gi3; if (gps->u != 0) gu = gs.u % gps->u; } else { if (gu) if (a != 0) gula[3] = gula[6] / a; }
}
long rs_6_08_06_6(unsigned long a, double b) {
	return (gla[1] / 16L) & gl2;
}
void rs_6_08_07_0(unsigned long a) {
	int t = gi % 16;
	ji = t;
}
void rs_6_08_07_1(unsigned long a) {
	double u = gda[0];
	jd = u;
}
void rs_6_08_07_2(unsigned long a) {
	int t = ji;
	if ((int)gul < 255 && gula[t] <= gul) { gpi = &gia[3]; if (gca[t] != 0) gc2 = (char)gu / gca[t]; }
}
void rs_6_08_07_3(unsigned long a) {
	double u = jd;
	vd(u);
}
int rs_6_08_07_4(unsigned long a) {
	if (r2(gi2, gps->i)) return gi2;
}
void rs_6_08_07_5(unsigned long a) {
	int t = ji;
	v0();
	gc2 = *gp = rc((int)gps->c) & (gca[t] - 2);
}
int rs_6_08_07_6(unsigned long a) {
	return gpi[3] - (100 ^ *gpi);
}
void rs_6_08_08_0(struct st *a, long *b, unsigned long c) {
	int t = gs.a[3] << 3;
	ji = t;
}
void rs_6_08_08_1(struct st *a, long *b, unsigned long c) {
	gula[3] -= gul;
}
void rs_6_08_08_2(struct st *a, long *b, unsigned long c) {
	gu = gua[6] / 100;
}
void rs_6_08_08_3(struct st *a, long *b, unsigned long c) {
	int t = ji;
	v2(gi2, -t);
}
void rs_6_08_08_4(struct st *a, long *b, unsigned long c) {
	int t = ji;
	v0();
	t = (a->a[2] % 4) + (t % 7);
}
int * rs_6_08_08_5(struct st *a, long *b, unsigned long c) {
	return gpi;
}
void rs_6_08_09_0(int a, unsigned int b) {
	unsigned long t = 69901UL + gula[0];
	jul = t;
}
void rs_6_08_09_1(int a, unsigned int b) {
	guca[b] = 255;
}
void rs_6_08_09_2(int a, unsigned int b) {
	unsigned long t = jul;
	t = rul(t);
}
void rs_6_08_09_3(int a, unsigned int b) {
	gia[0] = gi2 * 12;
}
void rs_6_08_09_4(int a, unsigned int b) {
	gs.l = gla[a] | 65536L;
}
int * rs_6_08_09_5(int a, unsigned int b) {
	return gpi + b;
}
void rs_6_08_10_0(unsigned long a, int b, unsigned int c) {
	gp = gs.p;
}
void rs_6_08_10_1(unsigned long a, int b, unsigned int c) {
	gda[2] += gs.d + (double)gs.c;
}
int rs_6_08_10_2(unsigned long a, int b, unsigned int c) {
	return (gpi[3] = gia[b]);
}
void rs_6_08_11_0(long a, unsigned int b) {
	unsigned int t = b - 256;
	ju = t;
}
void rs_6_08_11_1(long a, unsigned int b) {
	char *u = gp;
	jp = u;
}
void rs_6_08_11_2(long a, unsigned int b) {
	gl2 = (a - 65536L) + rl(a);
}
void rs_6_08_11_3(long a, unsigned int b) {
	unsigned int t = ju;
	v0();
	guca[t] = guc % 100;
}
void rs_6_08_11_4(long a, unsigned int b) {
	if ((gula[6] = gul)) { gul--; --a; } else { gps->a[1] = 100 * 12; if (gul != 0) gula[1] = gul / gul; }
}
void rs_6_08_11_5(long a, unsigned int b) {
	char *u = jp;
	v0();
	vp(u);
}
long rs_6_08_11_6(long a, unsigned int b) {
	return a;
}
void rs_6_08_12_1(long a, unsigned int b, unsigned long c) {
	int t = *gpi;
	ji = t;
}
void rs_6_08_12_2(long a, unsigned int b, unsigned long c) {
	int t = ji;
	int u = t;
	ji = u;
}
void rs_6_08_12_3(long a, unsigned int b, unsigned long c) {
	int u = ji;
	gi = u;
}
void rs_6_08_12_4(long a, unsigned int b, unsigned long c) {
	int i = ji;
	i = 9; do { guc ^= guca[i]; gi3 = gs.a[i]; } while (--i > 0);
}
void rs_6_08_12_5(long a, unsigned int b, unsigned long c) {
	gc2 = (gca[2] >> 3) % 7;
}
void rs_6_08_12_6(long a, unsigned int b, unsigned long c) {
	int t = ji;
	v1(t);
}
void rs_6_08_12_7(long a, unsigned int b, unsigned long c) {
	int i = ji;
	v0();
	vu(((unsigned int)gs.i) + gu);
}
void rs_6_08_12_8(long a, unsigned int b, unsigned long c) {
	gua[3] = gua[6];
}
void rs_6_08_13_0(unsigned long a) {
	unsigned long t = gula[4] >> 3;
	jul = t;
}
void rs_6_08_13_1(unsigned long a) {
	gs.c = rc(gi3);
}
void rs_6_08_13_2(unsigned long a) {
	while (gi-- > 0) { if (*gp == '9') break; gp++; }
}
void rs_6_08_13_3(unsigned long a) {
	guca[4] += 128;
}
void rs_6_08_13_4(unsigned long a) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
int * rs_6_08_13_5(unsigned long a) {
	return &gia[0];
}
void rs_6_08_14_0(void) {
	gs.c = gs.c - gp[3];
}
void rs_6_08_14_1(void) {
	gu = (unsigned int)255;
}
unsigned long rs_6_08_14_2(void) {
	return gul;
}
void rs_6_08_15_1(void) {
	char *t = rp();
	jp = t;
}
void rs_6_08_15_2(void) {
	int *u = &gia[6];
	v0();
	jpi = u;
}
void rs_6_08_15_3(void) {
	int *u = jpi;
	v0();
	u--;
}
void rs_6_08_15_4(void) {
	int i = ji;
	v0();
	i = 4; do { guc = 7 & (guc - 241); vl(rl(6L)); } while (--i > 0);
}
void rs_6_08_15_5(void) {
	char *t = jp;
	v0();
	gp = t;
}
char * rs_6_08_15_6(void) {
	char *t = jp;
	v0();
	return t;
}
void rs_6_08_16_0(long *a) {
	char *t = &gca[3];
	jp = t;
}
void rs_6_08_16_1(long *a) {
	int u = gps->a[1] + gi;
	ji = u;
}
void rs_6_08_16_2(long *a) {
	if (!gp[3]) guc = guca[1] = (guca[2] * guc) << 7;
}
int rs_6_08_16_3(long *a) {
	int u = ji;
	if (r1(u) || gula[u] > gul) return gs.i;
}
void rs_6_08_16_4(long *a) {
	gl = (gs.l & -16693L) / 16L;
}
void rs_6_08_16_5(long *a) {
	char *t = jp;
	v0();
	gp = t;
}
int rs_6_08_16_6(long *a) {
	int u = ji;
	v0();
	return (gi2 = u);
}
void rs_6_08_17_0(void) {
	char t = *gp % 2;
	jc = t;
}
void rs_6_08_17_1(void) {
	int *u = &gia[6];
	jpi = u;
}
void rs_6_08_17_2(void) {
	gc2 -= gca[7] * gc;
}
char * rs_6_08_17_3(void) {
	if (gl && gi3 <= (int)gl) return gp;
}
void rs_6_08_17_4(void) {
	char t = jc;
	gc = t;
}
void rs_6_08_17_5(void) {
	int *u = jpi;
	gpi = u;
}
char * rs_6_08_17_6(void) {
	return gp;
}
void rs_6_08_18_0(int a) {
	int t = 1;
	ji = t;
}
void rs_6_08_18_1(int a) {
	int t = ji;
	unsigned char u = (unsigned char)!t;
	juc = u;
}
void rs_6_08_18_2(int a) {
	int t = ji;
	v1(t);
}
void rs_6_08_18_3(int a) {
	unsigned char u = juc;
	v0();
	switch (gi3) { case 0: gps->a[u] *= 10; break; case 1: vc(gp[0]); break; case 2: guc = guc | ((unsigned char)gc2); break; case 3: u &= 7; default: vc(gps->c); break; }
}
void rs_6_08_18_4(int a) {
	gs.d *= 0.25;
}
int rs_6_08_18_5(int a) {
	return (int)gula[4];
}
void rs_6_08_19_0(struct st *a) {
	unsigned long t = ((unsigned long)gca[2]) | gula[2];
	jul = t;
}
void rs_6_08_19_1(struct st *a) {
	unsigned long t = jul;
	vl((long)t);
}
void rs_6_08_19_2(struct st *a) {
	vu(gps->u);
}
void rs_6_08_19_3(struct st *a) {
	guc &= (guca[4] <= guc ? guca[5] : guca[7]);
}
void rs_6_08_19_4(struct st *a) {
	gi3 = a->i;
}
long rs_6_08_19_5(struct st *a) {
	return 1L;
}
void rs_6_09_00_0(unsigned long a, char b, unsigned int c) {
	double t = (double)gl2 * gd2;
	jd = t;
}
void rs_6_09_00_1(unsigned long a, char b, unsigned int c) {
	char u = b;
	jc = u;
}
void rs_6_09_00_2(unsigned long a, char b, unsigned int c) {
	double t = jd;
	gd = t;
}
void rs_6_09_00_3(unsigned long a, char b, unsigned int c) {
	gpl[2] %= 7L;
}
void rs_6_09_00_4(unsigned long a, char b, unsigned int c) {
	char u = jc;
	vc(u);
}
void rs_6_09_00_5(unsigned long a, char b, unsigned int c) {
	vp(gs.p);
}
char rs_6_09_00_6(unsigned long a, char b, unsigned int c) {
	char u = jc;
	v0();
	return (*gp << 7) | u;
}
void rs_6_09_01_0(void) {
	char *t = gp;
	jp = t;
}
void rs_6_09_01_1(void) {
	gps->u *= 12;
}
void rs_6_09_01_2(void) {
	char *t = jp;
	gp = t;
}
void rs_6_09_01_3(void) {
	gu2 = (((unsigned int)gla[6]) - gs.u) * 3;
}
char rs_6_09_01_4(void) {
	return (char)guca[6];
}
void rs_6_09_02_1(int a, int b, double c) {
	gps->c = gca[a] + gca[2];
}
void rs_6_09_02_2(int a, int b, double c) {
	if (gula[3] != 0) gula[4] = gul % gula[3];
}
void rs_6_09_02_3(int a, int b, double c) {
	if (guc <= guca[b]) { gu2 = ~(255 + 9); v2(gi2, a / 2); }
}
void rs_6_09_02_4(int a, int b, double c) {
	int i = ji;
	v0();
	i = 0; while (i < a) { gi++; i++; }
}
void rs_6_09_02_5(int a, int b, double c) {
	guca[1] = guca[a];
}
int rs_6_09_02_6(int a, int b, double c) {
	return gi;
}
void rs_6_09_03_0(char *a, int *b) {
	gps->u += gu;
}
void rs_6_09_03_1(char *a, int *b) {
	*gpl *= 3L;
}
void rs_6_09_03_2(char *a, int *b) {
	guca[7] = -guc;
}
void rs_6_09_03_3(char *a, int *b) {
	a[0] = gca[3] + gc2;
}
void rs_6_09_04_0(unsigned char a, int *b) {
	long t = gps->l << 28;
	jl = t;
}
void rs_6_09_04_1(unsigned char a, int *b) {
	a--;
}
void rs_6_09_04_2(unsigned char a, int *b) {
	long t = jl;
	vl(t);
}
void rs_6_09_04_3(unsigned char a, int *b) {
	gul = (unsigned long)(*gp <= ('a' != -71 ? (char)a : gps->c));
}
void rs_6_09_04_4(unsigned char a, int *b) {
	if ((gu2 = gs.u)) gia[0] -= 1 % 10;
}
int * rs_6_09_04_5(unsigned char a, int *b) {
	return b;
}
void rs_6_09_05_0(unsigned char a, unsigned char b, struct st *c) {
	unsigned char t = guc / 7;
	juc = t;
}
void rs_6_09_05_1(unsigned char a, unsigned char b, struct st *c) {
	unsigned char t = juc;
	if (gu < c->u) { guca[t] = -6; gula[4] = gula[a] & gul; }
}
void rs_6_09_05_2(unsigned char a, unsigned char b, struct st *c) {
	gda[1] = (gu2 ? 3.0 : gda[3]);
}
void rs_6_09_05_3(unsigned char a, unsigned char b, struct st *c) {
	gc = gc2 = (char)!*gpi;
}
unsigned int rs_6_09_05_4(unsigned char a, unsigned char b, struct st *c) {
	return (gua[6] % 7) + ((unsigned int)gps->i);
}
void rs_6_09_06_0(int a) {
	char t = gc2 + gca[a];
	jc = t;
}
void rs_6_09_06_1(int a) {
	int *u = &gia[a];
	jpi = u;
}
void rs_6_09_06_2(int a) {
	int *u = jpi;
	gps->u = gua[3];
}
void rs_6_09_06_3(int a) {
	char t = jc;
	int *u = jpi;
	if (gps->u <= gu2) { gula[t] = (unsigned long)(long)gua[1]; vl(rl(gl)); }
}
int * rs_6_09_06_4(int a) {
	int *u = jpi;
	v0();
	return u;
}
void rs_6_09_07_1(struct st *a) {
	if (gc2 <= *gp && !*gp) { ++gpi; }
}
void rs_6_09_07_2(struct st *a) {
	if (!guca[5]) { if (gul != 0) gula[5] = gula[4] % gul; gpi[1] -= (int)gc2; --guc; } else { gu2 = gps->u; guca[1] = (unsigned char)65536L; vc(~89); }
}
int rs_6_09_07_3(struct st *a) {
	if ((guca[6] = 7) <= 255) return gpi[2] % 4;
}
void rs_6_09_07_4(struct st *a) {
	int i = ji;
	v0();
	i = 0; while (i < 3) { gi2 = -(~127); i++; }
}
void rs_6_09_07_5(struct st *a) {
	if (gul) { gs.l = gla[6]; if (gla[1] != 0) gps->l = gl / gla[1]; if (gl != 0) gla[2] = gla[4] % gl; } else { if (*gpl != 0) gs.l = gl % *gpl; }
}
int rs_6_09_07_6(struct st *a) {
	return (*gpi * gi2) >> 14;
}
void rs_6_09_08_0(long a, long b, unsigned long c) {
	char *t = gp;
	jp = t;
}
void rs_6_09_08_1(long a, long b, unsigned long c) {
	vu(gu2);
}
void rs_6_09_08_2(long a, long b, unsigned long c) {
	vs(gps);
}
void rs_6_09_08_3(long a, long b, unsigned long c) {
	gc2 &= gps->c + gc;
}
void rs_6_09_08_4(long a, long b, unsigned long c) {
	char *t = jp;
	v0();
	vp(t);
}
void rs_6_09_08_5(long a, long b, unsigned long c) {
	vl(gs.l ^ gl);
}
void rs_6_09_08_6(long a, long b, unsigned long c) {
	if (gc2 != 0) gc = 5 % gc2;
}
long rs_6_09_08_7(long a, long b, unsigned long c) {
	return (long)(-8 | gs.c);
}
void rs_6_09_09_0(int a, char *b, long *c) {
	guc ^= guca[a] + guc;
}
void rs_6_09_09_1(int a, char *b, long *c) {
	if (gc2) if (gu2 != 0) gps->u = 8 / gu2;
}
void rs_6_09_09_2(int a, char *b, long *c) {
	v0();
}
void rs_6_09_09_3(int a, char *b, long *c) {
	b[1] = ~*gp;
}
char rs_6_09_09_4(int a, char *b, long *c) {
	return ~(char)0x10000UL;
}
void rs_6_09_10_1(unsigned long a, struct st *b, unsigned char c) {
	if (gpl[1] != 0) gps->l = gla[4] / gpl[1];
}
void rs_6_09_10_2(unsigned long a, struct st *b, unsigned char c) {
	int i = ji;
	for (i = 2; i > 0; i--) { c = c ^ ((unsigned char)(a > 80069UL)); }
}
int rs_6_09_10_3(unsigned long a, struct st *b, unsigned char c) {
	return gi - (2 + gia[1]);
}
void rs_6_09_11_0(char *a) {
	long t = 1L << 31;
	jl = t;
}
void rs_6_09_11_1(char *a) {
	int u = gia[3] >> 3;
	ji = u;
}
void rs_6_09_11_2(char *a) {
	gp = rp();
}
void rs_6_09_11_3(char *a) {
	gpi[3] = gi = (*gpi >> 11) << 15;
}
void rs_6_09_11_4(char *a) {
	int u = ji;
	v0();
	gps->u = gps->u * 3;
}
void rs_6_09_11_5(char *a) {
	long t = jl;
	v0();
	vl(t);
}
int rs_6_09_11_6(char *a) {
	return r0();
}
void rs_6_09_12_0(struct st *a, int b, struct st *c) {
	int *t = gpi;
	jpi = t;
}
void rs_6_09_12_1(struct st *a, int b, struct st *c) {
	unsigned long u = gula[6] + gul;
	jul = u;
}
void rs_6_09_12_2(struct st *a, int b, struct st *c) {
	unsigned long u = jul;
	if (gps->l) { gps->i <<= 7; --gu; if (gula[b] != 0) u = ((unsigned long)guc) % gula[b]; }
}
void rs_6_09_12_3(struct st *a, int b, struct st *c) {
	int *t = jpi;
	if (guc && c->i >= *t) { gca[b] = (char)1; gca[b] = gp[1]; } else { vp(gps->p); if (gc2 != 0) gs.c = gca[b] / gc2; }
}
int * rs_6_09_12_4(struct st *a, int b, struct st *c) {
	int *t = jpi;
	v0();
	return t;
}
void rs_6_09_13_0(void) {
	int t = *gpi << 5;
	ji = t;
}
void rs_6_09_13_1(void) {
	int t = ji;
	if (r1(16)) { gul = ((unsigned long)!5) >> (t & 15); gl2--; } else { if (gps->i <= gi2) gla[5] = (long)gca[6] | gl2; }
}
void rs_6_09_13_2(void) {
	gs.l = gl2 = gps->l;
}
void rs_6_09_13_3(void) {
	int t = ji;
	v0();
	if (guca[t] & 4) if (gul != 0) gula[7] = gul / gul;
}
void rs_6_09_14_1(long a, unsigned char b, char *c) {
	int t = ~gi3;
	ji = t;
}
void rs_6_09_14_2(long a, unsigned char b, char *c) {
	int i = ji;
	for (i = 0; i < 14; i++) { *c = ~*gp * (char)gs.a[i]; --gul; v1(gs.i); }
}
void rs_6_09_14_3(long a, unsigned char b, char *c) {
	b = (b + 128) | b;
}
void rs_6_09_14_4(long a, unsigned char b, char *c) {
	int t = ji;
	v0();
	if (gca[t]) { if (gs.u != 0) gu2 = gua[b] / gs.u; if (*gp != 0) gc = gca[1] / *gp; if (gu != 0) gu = 8 % gu; } else { if (guc) vc(gca[2] / 3); }
}
void rs_6_09_14_5(long a, unsigned char b, char *c) {
	int i = ji;
	v0();
	for (i = 2; i > 0; i--) { gpi = rpi(16 + gia[b]); gu2 = gua[i] = ~13020 - (gu2 - 255); }
}
void rs_6_09_14_6(long a, unsigned char b, char *c) {
	gl2 = (long)(gula[4] - ((unsigned long)gc));
}
int rs_6_09_14_7(long a, unsigned char b, char *c) {
	int t = ji;
	v0();
	return ~(16 * t);
}
void rs_6_09_15_0(char *a, int b, int c) {
	long t = (long)!b;
	jl = t;
}
void rs_6_09_15_1(char *a, int b, int c) {
	vd(gda[0]);
}
void rs_6_09_15_2(char *a, int b, int c) {
	vd((gul < 67004UL ? gd : 10.0));
}
void rs_6_09_15_3(char *a, int b, int c) {
	if ((gi2 = gi3)) vu(gu ^ 1);
}
void rs_6_09_15_4(char *a, int b, int c) {
	long t = jl;
	v0();
	vl(t);
}
int rs_6_09_15_5(char *a, int b, int c) {
	return (b = 1);
}
void rs_6_09_16_1(char *a, long *b, int c) {
	double t = gda[0] - gs.d;
	jd = t;
}
void rs_6_09_16_2(char *a, long *b, int c) {
	double u = 0.25;
	jd = u;
}
void rs_6_09_16_3(char *a, long *b, int c) {
	gla[3] = gpl[2] - gl2;
}
void rs_6_09_16_4(char *a, long *b, int c) {
	switch (gu) { case 1: gpi = gpi + c; break; case 2: v1(gi2); break; case 3: vp(&gca[c]); break; case 8: gc ^= -24; break; case 10: gps->a[2] = gia[5] + c; break; case 1000: vs(gps); break; }
}
void rs_6_09_16_5(char *a, long *b, int c) {
	if (gl == 65536L && gla[c]) { gua[0] = (unsigned int)((long)gps->c < gps->l); }
}
void rs_6_09_16_6(char *a, long *b, int c) {
	double t = jd;
	v0();
	gd = t;
}
void rs_6_09_16_7(char *a, long *b, int c) {
	int i = ji;
	double u = jd;
	v0();
	for (i = 0; i < 12; i++) { vu(-gu2); gs.u = gua[i]; }
}
void rs_6_09_16_8(char *a, long *b, int c) {
	vd(gda[3]);
}
unsigned long rs_6_09_16_9(char *a, long *b, int c) {
	return (gul = 0x10000UL);
}
char * rs_6_09_17_1(struct st *a) {
	if (guca[1] >= 255) return gs.p;
}
void rs_6_09_17_2(struct st *a) {
	int i = ji;
	switch (a->c) { case 0: gul = gula[1]; break; case 1: vl(gl); break; case 2: guca[3] = guc ^ 255; break; case 3: gd *= (double)gl2; break; case 4: v2(gs.i, gi); break; case 5: vd(gs.d); break; default: gula[7] = gul; break; }
}
void rs_6_09_17_3(struct st *a) {
	int i = ji;
	v0();
	i = 14; do { a->p = gs.p; gc = gc2 = rc((gs.a[i] == a->a[i])); if (gpi[1] != 0) gi2 = (int)gula[i] % gpi[1]; } while (--i > 0);
}
char * rs_6_09_17_4(struct st *a) {
	return gp;
}
void rs_6_09_18_0(long a, char b, unsigned char c) {
	gi2++;
}
void rs_6_09_18_1(long a, char b, unsigned char c) {
	gu2 = ((unsigned int)gs.a[6]) & (((unsigned int)a) << 3);
}
void rs_6_09_18_2(long a, char b, unsigned char c) {
	--b;
}
void rs_6_09_18_3(long a, char b, unsigned char c) {
	gpi = gpi + b;
}
void rs_6_09_18_4(long a, char b, unsigned char c) {
	v1((int)guc);
}
void rs_6_09_19_0(struct st *a, int *b) {
	int t = r1(gi);
	ji = t;
}
void rs_6_09_19_1(struct st *a, int *b) {
	int t = ji;
	int *u = b + t;
	v0();
	jpi = u;
}
void rs_6_09_19_2(struct st *a, int *b) {
	int *u = jpi;
	v0();
	gpi = u;
}
void rs_6_09_19_3(struct st *a, int *b) {
	int t = ji;
	v0();
	if (gs.d > gd2) { a->p = gps->p; gp--; } else { gua[2] <<= 8; if (gul != 0) gula[t] = gul / gul; }
}
void rs_6_09_19_4(struct st *a, int *b) {
	v2(gia[6] | gia[0], gi);
}
int rs_6_09_19_5(struct st *a, int *b) {
	int t = ji;
	v0();
	return b[t];
}
