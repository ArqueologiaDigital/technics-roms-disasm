/* Every statement line of random9 alone in its own function (gen_rstmt.py corpus/random9 9): rs_<A>_<BB>_<CC>_<k> is line k of
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

void rs_9_00_00_0(unsigned int a, double b) {
	int t = -(-31);
	ji = t;
}
void rs_9_00_00_1(unsigned int a, double b) {
	int t = ji;
	v1(t);
}
void rs_9_00_00_2(unsigned int a, double b) {
	v0();
}
void rs_9_00_00_3(unsigned int a, double b) {
	gua[a] = gu - gu2;
}
void rs_9_00_00_4(unsigned int a, double b) {
	gps->l /= 7L;
}
unsigned long rs_9_00_00_5(unsigned int a, double b) {
	return gul | gula[a];
}
void rs_9_00_01_1(char a) {
	if (r2(gi2, gi)) if (gp[2] != 0) a = a / gp[2];
}
void rs_9_00_01_2(char a) {
	int i = ji;
	v0();
	for (i = 0; i < 12; i++) { if (gula[i] != 0) gul = gul / gula[i]; }
}
void rs_9_00_01_3(char a) {
	int i = ji;
	v0();
	for (i = 0; i < 10; i++) { if (gula[7] != 0) gula[i] = gula[a] / gula[7]; if (gi2 != 0) *gpi = 289 / gi2; }
}
char * rs_9_00_01_4(char a) {
	return gp;
}
void rs_9_00_02_0(void) {
	int t = (guca[2] <= guca[4]);
	ji = t;
}
void rs_9_00_02_1(void) {
	gl = -gl2 % 7L;
}
void rs_9_00_02_2(void) {
	int t = ji;
	gul = gula[t] = gul - 0x10000UL;
}
unsigned int rs_9_00_02_3(void) {
	return (((unsigned int)guc) / 100) + ((unsigned int)guca[3]);
}
void rs_9_00_03_0(long *a, long b) {
	int *t = gpi;
	jpi = t;
}
void rs_9_00_03_1(long *a, long b) {
	int *t = jpi;
	v1(*t);
}
void rs_9_00_03_2(long *a, long b) {
	if (253 < 26 && gc2 != gc) { *gpl = b = gl2; gc |= 9; }
}
void rs_9_00_03_3(long *a, long b) {
	guca[7] = guc = (unsigned char)gs.u;
}
int rs_9_00_03_4(long *a, long b) {
	return gi3 ^ gpi[3];
}
void rs_9_00_04_0(char *a) {
	vu(-gu2);
}
void rs_9_00_04_1(char *a) {
	gula[5] <<= 31;
}
void rs_9_00_04_2(char *a) {
	guca[4] = 8;
}
void rs_9_00_05_0(struct st *a, struct st *b) {
	long t = -gs.l;
	jl = t;
}
void rs_9_00_05_1(struct st *a, struct st *b) {
	if (gca[1] != 0) gca[7] = gs.c % gca[1];
}
void rs_9_00_05_2(struct st *a, struct st *b) {
	long t = jl;
	gl = t;
}
void rs_9_00_05_3(struct st *a, struct st *b) {
	gula[1] = gul = rul(gula[3]) - (0x10000UL << 18);
}
void rs_9_00_05_4(struct st *a, struct st *b) {
	gi3 = ((gs.a[6] - gi) >= (gi2 * 11));
}
int * rs_9_00_05_5(struct st *a, struct st *b) {
	return &gia[6];
}
void rs_9_00_06_1(struct st *a, struct st *b, int c) {
	unsigned char t = guca[3] << (c & 7);
	juc = t;
}
void rs_9_00_06_2(struct st *a, struct st *b, int c) {
	unsigned char t = juc;
	guc = t;
}
void rs_9_00_06_3(struct st *a, struct st *b, int c) {
	int i = ji;
	i = 11; do { if (gi2 != 0) c = 256 / gi2; gp = b->p; gpi = &gia[i]; } while (--i > 0);
}
void rs_9_00_06_4(struct st *a, struct st *b, int c) {
	gpl[2] = gps->l;
}
int rs_9_00_06_5(struct st *a, struct st *b, int c) {
	return 8 >> 3;
}
void rs_9_00_07_0(long a, unsigned long b) {
	int t = gi;
	ji = t;
}
void rs_9_00_07_1(long a, unsigned long b) {
	int u = (gda[0] == (double)*gp);
	ji = u;
}
unsigned long rs_9_00_07_2(long a, unsigned long b) {
	int t = ji;
	int u = ji;
	if (u >= t) return b;
}
void rs_9_00_07_3(long a, unsigned long b) {
	int t = ji;
	v2(t * 2, gi);
}
void rs_9_00_07_4(long a, unsigned long b) {
	switch (gs.i) { case 0: a /= 7L; break; case 1: *gp = gca[5] % 16; break; }
}
void rs_9_00_07_5(long a, unsigned long b) {
	guc = 255;
}
void rs_9_00_07_6(long a, unsigned long b) {
	int u = ji;
	v0();
	gua[u] = (unsigned int)a;
}
unsigned long rs_9_00_07_7(long a, unsigned long b) {
	return b;
}
void rs_9_00_08_1(int a, unsigned long b) {
	double t = gd * 1.0;
	jd = t;
}
void rs_9_00_08_2(int a, unsigned long b) {
	int *u = gpi;
	jpi = u;
}
void rs_9_00_08_3(int a, unsigned long b) {
	gi2 %= 10;
}
void rs_9_00_08_4(int a, unsigned long b) {
	int i = ji;
	int *u = jpi;
	for (i = 3; i > 0; i--) { if (u[3] != 0) *gpi = gi2 % u[3]; guc = guca[i]; }
}
void rs_9_00_08_5(int a, unsigned long b) {
	double t = jd;
	vd(t);
}
void rs_9_00_08_6(int a, unsigned long b) {
	if (gc2 & 0x7) vu(gu ^ gua[a]);
}
void rs_9_00_08_7(int a, unsigned long b) {
	gpl[2] *= 4L;
}
char * rs_9_00_08_8(int a, unsigned long b) {
	return &gca[4];
}
void rs_9_00_09_0(int a) {
	while (a-- > 0) *gpi++ = 1;
}
void rs_9_00_09_1(int a) {
	vl((long)!gps->u);
}
void rs_9_00_09_2(int a) {
	if (gpi[3] >= gs.a[a] && *gpi & 0x8) { if (gul != 0) gul = 26686UL / gul; guc = (175 << (a & 7)) << (a & 7); v0(); } else { gl2 = *gpl ^ (gs.l % 4L); vp(rp()); gula[a] = gula[a] - gul; }
}
int * rs_9_00_09_3(int a) {
	return gpi + a;
}
void rs_9_00_10_0(void) {
	int t = gi2;
	ji = t;
}
void rs_9_00_10_1(void) {
	vl(gpl[2] + -3356L);
}
void rs_9_00_10_2(void) {
	guc *= 3;
}
void rs_9_00_10_3(void) {
	int t = ji;
	v0();
	gia[2] = -t;
}
void rs_9_00_10_4(void) {
	gi3 = 256;
}
void rs_9_00_10_5(void) {
	guc = (guca[4] & guca[3]) ^ (guca[6] % 4);
}
int rs_9_00_10_6(void) {
	int t = ji;
	v0();
	return 143 >> (t & 15);
}
void rs_9_00_11_0(long a, unsigned long b) {
	unsigned int t = gs.u * 11;
	ju = t;
}
void rs_9_00_11_1(long a, unsigned long b) {
	unsigned int t = ju;
	gc = gca[t] = rc(gi3);
}
void rs_9_00_11_2(long a, unsigned long b) {
	vu(1);
}
void rs_9_00_11_3(long a, unsigned long b) {
	--gp;
}
void rs_9_00_11_4(long a, unsigned long b) {
	unsigned int t = ju;
	v0();
	gp = gs.p + t;
}
unsigned int rs_9_00_11_5(long a, unsigned long b) {
	return (gu = 255);
}
void rs_9_00_12_0(void) {
	switch (gi3) { case 20: gi |= gia[0]; break; case 100: gu2 = -gua[5]; break; default: gul = gula[2] = ~gul; break; }
}
void rs_9_00_12_1(void) {
	gu2 = (-((unsigned int)gl)) ^ gu;
}
void rs_9_00_12_2(void) {
	if ((gu2 = 256)) { gul -= rul(0x10000UL); gs.d -= gd; gs.d -= gda[2]; } else { if (gu != 0) gua[4] = gu % gu; }
}
void rs_9_00_12_3(void) {
	guca[5] = ((unsigned char)gps->a[6]) ^ 255;
}
void rs_9_00_12_4(void) {
	if (!gs.l) { gs.p = &gca[5]; } else { if (gu) if (gu != 0) gs.u = gu2 / gu; }
}
int rs_9_00_12_5(void) {
	return (16 - gi) + *gpi;
}
void rs_9_00_13_0(int a, long b) {
	int *t = gpi + a;
	jpi = t;
}
void rs_9_00_13_1(int a, long b) {
	int *t = jpi;
	gpi = t;
}
void rs_9_00_13_2(int a, long b) {
	gu2--;
}
void rs_9_00_13_3(int a, long b) {
	if (b != 0) gl2 = 15763L % b;
}
void rs_9_00_13_4(int a, long b) {
	gu = gs.u = gu2;
}
int * rs_9_00_13_5(int a, long b) {
	return rpi(100 - *gpi);
}
void rs_9_00_14_0(long *a, struct st *b, unsigned char c) {
	int t = ~gps->a[c];
	ji = t;
}
void rs_9_00_14_1(long *a, struct st *b, unsigned char c) {
	c = (c >> 3) & ((unsigned char)(b->u <= gua[6]));
}
void rs_9_00_14_2(long *a, struct st *b, unsigned char c) {
	v2(gi, gi);
}
void rs_9_00_14_3(long *a, struct st *b, unsigned char c) {
	int t = ji;
	v0();
	if (gula[t] != 0) gul = gul / gula[t];
}
void rs_9_00_14_4(long *a, struct st *b, unsigned char c) {
	int t = ji;
	v0();
	*gp -= rc(t);
}
int rs_9_00_14_5(long *a, struct st *b, unsigned char c) {
	return gps->i;
}
void rs_9_00_15_0(int a, unsigned int b, unsigned char c) {
	switch (gi) { case 0: case 1: gca[c] = gp[2] ^ *gp; case 2: case 3: vl(*gpl); case 4: guc = -guc; break; default: gs.c = gca[c]; break; }
}
void rs_9_00_15_1(int a, unsigned int b, unsigned char c) {
	guc = c = 255;
}
int rs_9_00_15_2(int a, unsigned int b, unsigned char c) {
	return (gps->i = gi);
}
void rs_9_00_16_0(void) {
	int t = gia[6] - gs.i;
	ji = t;
}
void rs_9_00_16_1(void) {
	double u = (5 < 128 ? gd : 3.0);
	jd = u;
}
void rs_9_00_16_2(void) {
	double u = jd;
	gd = u;
}
void rs_9_00_16_3(void) {
	int t = ji;
	v1(t);
}
void rs_9_00_16_4(void) {
	vs(gps);
}
void rs_9_00_16_5(void) {
	gs.i = 255;
}
void rs_9_00_16_6(void) {
	if (guc & 1) vc(rc(256));
}
char rs_9_00_16_7(void) {
	int t = ji;
	v0();
	return (!guca[t] ? gc : gc2) - gca[5];
}
void rs_9_00_17_0(struct st *a, long b, int c) {
	int t = -gi2;
	ji = t;
}
void rs_9_00_17_1(struct st *a, long b, int c) {
	gl2 = (long)((gs.d / 10.0) >= gd);
}
void rs_9_00_17_2(struct st *a, long b, int c) {
	guc = -(~guca[5]);
}
void rs_9_00_17_3(struct st *a, long b, int c) {
	--gc;
}
void rs_9_00_17_4(struct st *a, long b, int c) {
	int t = ji;
	if (gla[0] != 0) gla[t] = 65536L / gla[0];
}
void rs_9_00_17_5(struct st *a, long b, int c) {
	guca[c] <<= (c & 7);
}
void rs_9_00_18_1(long a, unsigned long b) {
	guca[0] *= 7;
}
void rs_9_00_18_2(long a, unsigned long b) {
	guc -= 30;
}
void rs_9_00_18_3(long a, unsigned long b) {
	int i = ji;
	for (i = 14; i > 0; i--) { gc = (guca[i] >= guc ? gc : gca[i]) | (gca[i] % 4); gps->p = rp(); }
}
void rs_9_00_18_4(long a, unsigned long b) {
	int i = ji;
	v0();
	if (r2(gi2, gps->i)) guc &= guc % 7;
}
void rs_9_00_18_5(long a, unsigned long b) {
	if (gs.u <= ((unsigned int)gi2)) v2(gi2, (guc == guca[1]));
}
char rs_9_00_18_6(long a, unsigned long b) {
	return gps->c;
}
void rs_9_00_19_0(double a, long b) {
	unsigned long t = rul(gul);
	jul = t;
}
void rs_9_00_19_1(double a, long b) {
	char *u = gp;
	v0();
	jp = u;
}
void rs_9_00_19_2(double a, long b) {
	gc2 = gc2 / 4;
}
void rs_9_00_19_3(double a, long b) {
	char *u = jp;
	v0();
	gps->u -= ~gu2;
}
void rs_9_00_19_4(double a, long b) {
	unsigned long t = jul;
	v0();
	guc = guca[1] - (((unsigned char)t) >> 7);
}
void rs_9_00_19_5(double a, long b) {
	gu = (unsigned int)(gl <= (long)!guca[6]);
}
long rs_9_00_19_6(double a, long b) {
	return (long)!rc(gps->i);
}
void rs_9_01_00_0(unsigned long a) {
	int *t = gpi + 1;
	jpi = t;
}
void rs_9_01_00_1(unsigned long a) {
	gca[6] = 'a' + gc;
}
void rs_9_01_00_2(unsigned long a) {
	int *t = jpi;
	t = gpi;
}
void rs_9_01_00_3(unsigned long a) {
	v0();
}
char * rs_9_01_00_4(unsigned long a) {
	return gp;
}
void rs_9_01_01_0(void) {
	unsigned char t = 128;
	juc = t;
}
void rs_9_01_01_1(void) {
	char *u = rp();
	jp = u;
}
void rs_9_01_01_2(void) {
	*gpl = gl = (long)gu + (long)!gla[3];
}
void rs_9_01_01_3(void) {
	unsigned char t = juc;
	v0();
	v1((r0() ? (int)guca[t] : *gpi));
}
void rs_9_01_01_4(void) {
	gi <<= 15;
}
void rs_9_01_01_5(void) {
	char *u = jp;
	v0();
	gu = (gs.u | 399) ^ ((unsigned int)gl2);
}
int * rs_9_01_01_6(void) {
	return gpi;
}
void rs_9_01_02_0(void) {
	char t = ~gp[2];
	jc = t;
}
void rs_9_01_02_1(void) {
	char *u = &gca[2];
	jp = u;
}
void rs_9_01_02_2(void) {
	char t = jc;
	if (guc > 5) { vp(gps->p); if (gc != 0) t = gc % gc; } else { gps->c = gc2 + t; gc += 3 & gps->c; if (t != 0) gc = gs.c / t; }
}
void rs_9_01_02_3(void) {
	char *u = jp;
	v0();
	vp(u);
}
void rs_9_01_02_4(void) {
	gi3 &= gi - gi3;
}
void rs_9_01_02_5(void) {
	guc -= guc >> 7;
}
char * rs_9_01_02_6(void) {
	return gs.p;
}
void rs_9_01_03_0(void) {
	int t = (int)guca[0];
	ji = t;
}
void rs_9_01_03_1(void) {
	guc &= 233;
}
void rs_9_01_03_2(void) {
	gs.l = gl / 16L;
}
void rs_9_01_03_3(void) {
	int t = ji;
	gula[t] = gula[5] / 2UL;
}
char * rs_9_01_03_4(void) {
	return gps->p;
}
void rs_9_01_04_0(long a, char b, long c) {
	guca[2] = guc;
}
void rs_9_01_04_1(long a, char b, long c) {
	if (gula[6] != 0) gul = gul % gula[6];
}
void rs_9_01_04_2(long a, char b, long c) {
	vl(gla[7] | a);
}
void rs_9_01_04_3(long a, char b, long c) {
	vp(gps->p);
}
unsigned int rs_9_01_04_4(long a, char b, long c) {
	return ((unsigned int)(38 != 9)) * 7;
}
void rs_9_01_05_1(void) {
	gs.l = ((long)(gu2 >= gs.u)) + gl;
}
void rs_9_01_05_2(void) {
	int i = ji;
	for (i = 3; i > 0; i--) { --gul; }
}
int rs_9_01_05_3(void) {
	return (gpi[0] << 7) - (gia[6] + gi);
}
void rs_9_01_06_0(void) {
	unsigned char t = guc;
	juc = t;
}
void rs_9_01_06_1(void) {
	unsigned char t = juc;
	gp = gp + t;
}
void rs_9_01_06_2(void) {
	gda[0] *= gd - gda[1];
}
int rs_9_01_06_3(void) {
	return !gs.c;
}
void rs_9_01_07_0(int a, unsigned char b, char c) {
	int t = 256;
	ji = t;
}
void rs_9_01_07_1(int a, unsigned char b, char c) {
	unsigned long u = -gul;
	jul = u;
}
void rs_9_01_07_2(int a, unsigned char b, char c) {
	int t = ji;
	gi = t;
}
void rs_9_01_07_3(int a, unsigned char b, char c) {
	gul = (((unsigned long)gs.l) / 100UL) - gul;
}
void rs_9_01_07_4(int a, unsigned char b, char c) {
	gc = 5;
}
void rs_9_01_07_5(int a, unsigned char b, char c) {
	unsigned long u = jul;
	vl((long)u);
}
void rs_9_01_07_6(int a, unsigned char b, char c) {
	gi2 = 16;
}
void rs_9_01_07_7(int a, unsigned char b, char c) {
	vd(-gda[0]);
}
void rs_9_01_07_8(int a, unsigned char b, char c) {
	gda[2] += gd2 / 0.5;
}
long rs_9_01_07_9(int a, unsigned char b, char c) {
	return 47944L * 4L;
}
void rs_9_01_08_0(unsigned char a, int b, unsigned long c) {
	int *t = rpi(256);
	jpi = t;
}
void rs_9_01_08_1(unsigned char a, int b, unsigned long c) {
	double u = gda[2] * gda[2];
	v0();
	jd = u;
}
void rs_9_01_08_2(unsigned char a, int b, unsigned long c) {
	a += 255 | guca[2];
}
void rs_9_01_08_3(unsigned char a, int b, unsigned long c) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_9_01_08_4(unsigned char a, int b, unsigned long c) {
	b += gia[b];
}
void rs_9_01_08_5(unsigned char a, int b, unsigned long c) {
	double u = jd;
	v0();
	gd = u;
}
int rs_9_01_08_6(unsigned char a, int b, unsigned long c) {
	return -gps->a[b] + (guc >= a);
}
void rs_9_01_09_0(int a, unsigned char b, unsigned char c) {
	int t = (gul > 3UL);
	ji = t;
}
void rs_9_01_09_1(int a, unsigned char b, unsigned char c) {
	int t = ji;
	if (guca[a] & 0x10) if (gula[c] != 0) gula[t] = ((unsigned long)gps->u) / gula[c];
}
void rs_9_01_09_2(int a, unsigned char b, unsigned char c) {
	gps->l >>= 31;
}
void rs_9_01_09_3(int a, unsigned char b, unsigned char c) {
	vd(gd);
}
void rs_9_01_09_4(int a, unsigned char b, unsigned char c) {
	int t = ji;
	v0();
	switch (gl) { case 0L: vp(gp); break; case 1L: gl2 += gl; break; case 2L: gpi[3] = ~t; break; case 3L: gi2 = 100 / 100; break; case 4L: vu(gs.u); break; }
}
unsigned long rs_9_01_09_5(int a, unsigned char b, unsigned char c) {
	return ~gul;
}
void rs_9_01_10_0(long *a) {
	while (gi > 0) { gl2 += *a++; gi--; }
}
void rs_9_01_10_1(long *a) {
	v2(gi2 - gi, gi);
}
unsigned long rs_9_01_10_2(long *a) {
	if (r2(gi2, 310)) return rul(gula[6]);
}
unsigned long rs_9_01_10_3(long *a) {
	if (gpl[1] & 0x10 || gp[3] < 'A') return gul + 0x10000UL;
}
void rs_9_01_10_4(long *a) {
	switch (gs.i) { case 3: v2(gi2, gps->a[4]); break; case 10: vs(gps); case 1000: gc = gca[2]; break; }
}
unsigned long rs_9_01_10_5(long *a) {
	return gul;
}
void rs_9_01_11_0(void) {
	unsigned int t = gu2 << 11;
	ju = t;
}
void rs_9_01_11_1(void) {
	char *u = gp;
	jp = u;
}
void rs_9_01_11_2(void) {
	char *u = jp;
	vp(u);
}
int rs_9_01_11_3(void) {
	unsigned int t = ju;
	v0();
	if (gs.a[7] <= gi) return gia[t];
}
int rs_9_01_11_4(void) {
	unsigned int t = ju;
	v0();
	if (guca[6] >= guc) return gia[t] * 12;
}
void rs_9_01_11_5(void) {
	gc2 ^= gc >> 1;
}
int rs_9_01_11_6(void) {
	unsigned int t = ju;
	v0();
	return (gps->a[t] - gs.i) | (gi2 >> 2);
}
void rs_9_01_12_0(double a) {
	unsigned char t = guc;
	juc = t;
}
void rs_9_01_12_1(double a) {
	int *u = gpi;
	jpi = u;
}
void rs_9_01_12_2(double a) {
	--gu2;
}
void rs_9_01_12_3(double a) {
	unsigned char t = juc;
	gpl[3] = gla[t];
}
void rs_9_01_12_4(double a) {
	int *u = jpi;
	gpi = u;
}
void rs_9_01_12_5(double a) {
	v1(gi2);
}
void rs_9_01_12_6(double a) {
	--gi3;
}
int rs_9_01_12_7(double a) {
	return (int)gl % 2;
}
void rs_9_01_13_1(char a, long b, double c) {
	int *t = &gia[4];
	jpi = t;
}
void rs_9_01_13_2(char a, long b, double c) {
	gd2 = -gda[2];
}
void rs_9_01_13_3(char a, long b, double c) {
	switch (gu2) { case 3: v2(gi2, gs.a[a]); case 8: guca[a] /= 16; break; case 20: vs(gps); break; }
}
void rs_9_01_13_4(char a, long b, double c) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_9_01_13_5(char a, long b, double c) {
	int i = ji;
	v0();
	for (i = 4; i > 0; i--) { --b; if (b != 0) b = gla[i] % b; }
}
void rs_9_01_13_6(char a, long b, double c) {
	gu2 -= ~gu2;
}
long rs_9_01_13_7(char a, long b, double c) {
	return (*gpl = 6L);
}
void rs_9_01_14_0(void) {
	v1(256);
}
void rs_9_01_14_1(void) {
	gpi = &gia[2];
}
void rs_9_01_14_2(void) {
	vu(gu2);
}
void rs_9_01_14_3(void) {
	*gpl = gl;
}
long rs_9_01_14_4(void) {
	return (32041L & 65536L) % 7L;
}
void rs_9_01_15_1(unsigned long a, long b, int c) {
	guca[c] = (unsigned char)!gpi[2];
}
void rs_9_01_15_2(unsigned long a, long b, int c) {
	int i = ji;
	for (i = 0; i < c; i++) { ++gi3; }
}
void rs_9_01_15_3(unsigned long a, long b, int c) {
	gla[c] = gpl[0];
}
void rs_9_01_15_4(unsigned long a, long b, int c) {
	gs.u = gu2 << 14;
}
unsigned int rs_9_01_15_5(unsigned long a, long b, int c) {
	return (255 % 7) / 2;
}
void rs_9_01_16_1(unsigned char a, unsigned long b, unsigned char c) {
	int *t = gpi;
	jpi = t;
}
void rs_9_01_16_2(unsigned char a, unsigned long b, unsigned char c) {
	int i = ji;
	for (i = 15; i > 0; i--) { *gp = (char)i; if (gc != 0) *gp = gca[i] / gc; gc2 = gp[0] = (!guca[i] ? (gs.c << (a & 7)) : (gca[i] ^ gs.c)); }
}
void rs_9_01_16_3(unsigned char a, unsigned long b, unsigned char c) {
	int *t = jpi;
	gpi = t;
}
void rs_9_01_16_4(unsigned char a, unsigned long b, unsigned char c) {
	gc--;
}
void rs_9_01_16_5(unsigned char a, unsigned long b, unsigned char c) {
	gia[4] = -gpi[2];
}
int rs_9_01_16_6(unsigned char a, unsigned long b, unsigned char c) {
	return (gia[5] = 2);
}
void rs_9_01_17_0(unsigned int a) {
	gd = ((gps->l = gl2) == -81358L ? gd2 : gd) * gs.d;
}
void rs_9_01_17_1(unsigned int a) {
	vc((char)gpl[1]);
}
void rs_9_01_17_2(unsigned int a) {
	guca[a] = guc + guca[6];
}
void rs_9_01_17_3(unsigned int a) {
	guca[a] = guca[1] - guc;
}
char rs_9_01_17_4(unsigned int a) {
	return (gca[2] << (a & 7)) & gps->c;
}
void rs_9_01_18_1(void) {
	gl = (gl % 4L) - (65536L - gla[2]);
}
void rs_9_01_18_2(void) {
	int i = ji;
	for (i = 0; i < 15; i++) { v0(); gpi = gpi + i; }
}
unsigned int rs_9_01_18_3(void) {
	return gu2;
}
void rs_9_01_19_0(int a) {
	int *t = gpi + a;
	jpi = t;
}
void rs_9_01_19_1(int a) {
	char *u = gps->p;
	jp = u;
}
void rs_9_01_19_2(int a) {
	gp[1] ^= (char)gu + (char)gi2;
}
char * rs_9_01_19_3(int a) {
	if ((' ') <= gc2) return &gca[a];
}
void rs_9_01_19_4(int a) {
	gula[1] = ((unsigned long)gps->l) - gul;
}
void rs_9_01_19_5(int a) {
	int *t = jpi;
	char *u = jp;
	gps->a[4] = *t = (gul != 1UL || gca[6] != gca[3] ? ((int)u[3] - gps->a[3]) : (gpi[1] - 255));
}
void rs_9_01_19_6(int a) {
	guca[1] = guc;
}
char * rs_9_01_19_7(int a) {
	return gps->p + a;
}
void rs_9_02_00_0(char *a) {
	unsigned int t = gps->u;
	ju = t;
}
void rs_9_02_00_1(char *a) {
	gda[2] *= -gd2;
}
void rs_9_02_00_2(char *a) {
	v0();
}
void rs_9_02_00_3(char *a) {
	unsigned int t = ju;
	v0();
	gpi = gpi + t;
}
int rs_9_02_00_4(char *a) {
	return (gi2 * gs.a[6]) | gi3;
}
void rs_9_02_01_0(unsigned int a) {
	char t = gc2 ^ gps->c;
	jc = t;
}
void rs_9_02_01_1(unsigned int a) {
	int u = 127;
	ji = u;
}
void rs_9_02_01_2(unsigned int a) {
	char t = jc;
	*gp = t << 2;
}
void rs_9_02_01_3(unsigned int a) {
	guca[6] = (unsigned char)((gd * gd2) == (gs.d / 1.0));
}
void rs_9_02_01_4(unsigned int a) {
	guca[0] &= guc + 86;
}
void rs_9_02_01_5(unsigned int a) {
	gda[1] = (double)*gpl + gd2;
}
void rs_9_02_01_6(unsigned int a) {
	int u = ji;
	gi = u;
}
long rs_9_02_01_7(unsigned int a) {
	return 65536L;
}
void rs_9_02_02_1(void) {
	int *t = gpi;
	jpi = t;
}
void rs_9_02_02_2(void) {
	int *t = jpi;
	int u = t[7];
	ji = u;
}
void rs_9_02_02_3(void) {
	int *t = jpi;
	gpi = t;
}
void rs_9_02_02_4(void) {
	int i = ji;
	int u = ji;
	for (i = 10; i > 0; i--) { gi = u; gs.u = gu2 = ru(gps->u) / 3; }
}
void rs_9_02_02_5(void) {
	guca[6] -= guc;
}
void rs_9_02_02_6(void) {
	int u = ji;
	v0();
	gul = ((unsigned long)(gula[u] <= gula[7])) / 10UL;
}
void rs_9_02_02_7(void) {
	if (gula[5] != 0) gul = gul % gula[5];
}
void rs_9_02_02_8(void) {
	vs(gps);
}
char rs_9_02_02_9(void) {
	return gc << 4;
}
void rs_9_02_03_0(long a) {
	if (gc != 0) gca[1] = gc / gc;
}
void rs_9_02_03_1(long a) {
	if (gca[3] < gca[5]) { *gp = gc >> 4; if (gu2 != 0) gua[6] = gua[4] % gu2; gc = (gca[2] + gca[3]) / 2; }
}
void rs_9_02_03_2(long a) {
	if (gua[5] != 0) gu = gu % gua[5];
}
void rs_9_02_03_3(long a) {
	switch (gi2) { case 0: gi2 %= 7; break; case 1: vp(rp()); break; case 2: vc(-93); break; case 3: vs(gps); break; case 4: gl += gs.l; break; case 5: guc += guca[1]; break; default: guca[5] = 255 ^ guc; break; }
}
void rs_9_02_03_4(long a) {
	--a;
}
void rs_9_02_04_0(char *a, int b) {
	unsigned char t = (unsigned char)!gla[2];
	juc = t;
}
void rs_9_02_04_1(char *a, int b) {
	unsigned char t = juc;
	t++;
}
void rs_9_02_04_2(char *a, int b) {
	vu(gu2);
}
void rs_9_02_04_3(char *a, int b) {
	gl2++;
}
int rs_9_02_04_4(char *a, int b) {
	return gps->a[7] | !gs.u;
}
void rs_9_02_05_1(void) {
	int t = (gca[5] <= gps->c);
	ji = t;
}
void rs_9_02_05_2(void) {
	int i = ji;
	i = 0; while (i < 6) { vd(((gl2 = 5L) <= 9L ? gda[0] : gda[0])); gi2 = r0(); if (gpl[2] != 0) gla[i] = (long)guca[i] / gpl[2]; i++; }
}
void rs_9_02_05_3(void) {
	int t = ji;
	v0();
	gpi = &gia[t];
}
void rs_9_02_05_4(void) {
	int t = ji;
	v0();
	guca[t] = guc;
}
void rs_9_02_05_5(void) {
	int t = ji;
	v0();
	guc = guca[t] * (guc / 3);
}
char * rs_9_02_05_6(void) {
	return gps->p;
}
void rs_9_02_06_0(unsigned int a, char b) {
	int t = 1;
	ji = t;
}
void rs_9_02_06_1(unsigned int a, char b) {
	gp--;
}
void rs_9_02_06_2(unsigned int a, char b) {
	v1(gi2 + gs.i);
}
void rs_9_02_06_3(unsigned int a, char b) {
	int t = ji;
	v0();
	v1(t);
}
void rs_9_02_06_4(unsigned int a, char b) {
	++gpi;
}
void rs_9_02_06_5(unsigned int a, char b) {
	vc(*gp ^ gca[2]);
}
unsigned long rs_9_02_06_6(unsigned int a, char b) {
	int t = ji;
	v0();
	return gula[t];
}
void rs_9_02_07_0(unsigned int a) {
	char t = 79 * 'A';
	jc = t;
}
void rs_9_02_07_1(unsigned int a) {
	int u = -318 + gi2;
	ji = u;
}
void rs_9_02_07_2(unsigned int a) {
	gi3--;
}
void rs_9_02_07_3(unsigned int a) {
	v2(gpi[0] % 10, gi);
}
void rs_9_02_07_4(unsigned int a) {
	while (gi > 0) { gc2 += *gp++; gi--; }
}
void rs_9_02_07_5(unsigned int a) {
	gda[3] = gda[2];
}
void rs_9_02_07_6(unsigned int a) {
	char t = jc;
	v0();
	vc(t);
}
void rs_9_02_07_7(unsigned int a) {
	int u = ji;
	v0();
	gi = u;
}
int rs_9_02_07_8(unsigned int a) {
	return gpi[3];
}
void rs_9_02_08_0(double a) {
	if (gu <= gua[2] || gla[4] > 1L) gi2--;
}
void rs_9_02_08_1(double a) {
	++gp;
}
void rs_9_02_08_2(double a) {
	*gpl = gl = gs.l;
}
void rs_9_02_08_3(double a) {
	gua[2] = gu2 + gu;
}
void rs_9_02_08_4(double a) {
	gul++;
}
char rs_9_02_08_5(double a) {
	return (gua[4] <= gu ? *gp : (char)guca[4]);
}
void rs_9_02_09_1(char a, long *b) {
	int t = !gc2;
	ji = t;
}
void rs_9_02_09_2(char a, long *b) {
	int i = ji;
	for (i = 5; i > 0; i--) { vl(gl * 12L); if (gc2 != 0) gc = '9' % gc2; b[i] -= -46061L; }
}
void rs_9_02_09_3(char a, long *b) {
	int t = ji;
	v0();
	gi = t;
}
void rs_9_02_09_4(char a, long *b) {
	vd((double)gua[2]);
}
char rs_9_02_09_5(char a, long *b) {
	return gs.c;
}
void rs_9_02_10_0(int *a) {
	int t = *gpi & 16;
	ji = t;
}
void rs_9_02_10_1(int *a) {
	int t = ji;
	gi = t;
}
void rs_9_02_10_2(int *a) {
	guc--;
}
void rs_9_02_10_3(int *a) {
	gp--;
}
unsigned int rs_9_02_10_4(int *a) {
	return (r2(gi3, gi) ? (gua[3] | gs.u) : (gps->u * 11));
}
void rs_9_02_11_0(unsigned long a, unsigned long b, unsigned long c) {
	int t = ~(int)gs.l;
	ji = t;
}
void rs_9_02_11_1(unsigned long a, unsigned long b, unsigned long c) {
	gu2 >>= 14;
}
void rs_9_02_11_2(unsigned long a, unsigned long b, unsigned long c) {
	int t = ji;
	if (gl2 < 65536L) { if (gi3 != 0) gi3 = gi % gi3; vc((char)gl2); gu = gu2 = (gu2 | gs.u) ^ (256 * gua[t]); } else { if (*gpi != 0) t = gs.i % *gpi; guc = ((unsigned char)gu) - guca[t]; guca[7] += 128 & guc; }
}
void rs_9_02_11_3(unsigned long a, unsigned long b, unsigned long c) {
	gi2 = gi - (gs.i + gia[0]);
}
int rs_9_02_11_4(unsigned long a, unsigned long b, unsigned long c) {
	return gi;
}
void rs_9_02_12_0(unsigned long a, int b, struct st *c) {
	if (r0()) { vu(18831 / 7); } else { vc(gca[7] - gps->c); }
}
void rs_9_02_12_1(unsigned long a, int b, struct st *c) {
	gps->l = (255 > gps->u ? gps->l : 65536L);
}
void rs_9_02_12_2(unsigned long a, int b, struct st *c) {
	gs.d -= gs.d + gd2;
}
unsigned int rs_9_02_12_3(unsigned long a, int b, struct st *c) {
	return (gua[b] + 1915) - gu2;
}
void rs_9_02_13_0(unsigned int a) {
	unsigned long t = (unsigned long)(1.0 >= gda[1]);
	jul = t;
}
void rs_9_02_13_1(unsigned int a) {
	gp = rp();
}
void rs_9_02_13_2(unsigned int a) {
	if (*gpi >= 16) gpi = rpi(gi - 506);
}
void rs_9_02_13_3(unsigned int a) {
	unsigned long t = jul;
	v0();
	gul = t;
}
void rs_9_02_13_4(unsigned int a) {
	gl2 = ~((long)(guc > 3));
}
int * rs_9_02_13_5(unsigned int a) {
	return gpi;
}
void rs_9_02_14_0(void) {
	unsigned int t = gu2;
	ju = t;
}
void rs_9_02_14_1(void) {
	gps->l = gla[4];
}
void rs_9_02_14_2(void) {
	unsigned int t = ju;
	vu(gu & gua[t]);
}
void rs_9_02_14_3(void) {
	gul++;
}
char rs_9_02_14_4(void) {
	return 7;
}
void rs_9_02_15_0(int *a, struct st *b, unsigned int c) {
	if (gul != 0) gula[c] = gula[c] / gul;
}
void rs_9_02_15_1(int *a, struct st *b, unsigned int c) {
	while (gi-- > 0) { if (*a == 2) break; a++; }
}
char rs_9_02_15_2(int *a, struct st *b, unsigned int c) {
	return (3 + gca[1]) - (gp[1] - (char)gula[c]);
}
void rs_9_02_16_0(double a, int *b) {
	unsigned int t = gu - gu2;
	ju = t;
}
void rs_9_02_16_1(double a, int *b) {
	unsigned int t = ju;
	gula[t] = ((unsigned long)gu2) - gula[t];
}
void rs_9_02_16_2(double a, int *b) {
	gl = ~(gl - gl2);
}
unsigned int rs_9_02_16_3(double a, int *b) {
	return -(~gps->u);
}
void rs_9_02_17_0(void) {
	if (0UL <= gula[4]) gu2 = 32767;
}
void rs_9_02_17_1(void) {
	gpi[0] = gps->i;
}
void rs_9_02_17_2(void) {
	gul <<= 3;
}
void rs_9_02_17_3(void) {
	if (guca[4]) { gla[0] = (long)guca[6]; } else { gc2 = (char)gula[5]; }
}
int rs_9_02_17_4(void) {
	if (r2(gi2, 2)) return gpi[3] - *gpi;
}
int rs_9_02_17_5(void) {
	return (gi2 % 100) >> 3;
}
void rs_9_02_18_0(long a, long b) {
	switch (gps->i) { case 2: vs(gps); break; case 1000: gs.d = 100.0; break; }
}
void rs_9_02_18_1(long a, long b) {
	gpi = rpi(gia[7] * 2);
}
void rs_9_02_19_0(int a, unsigned char b, char *c) {
	while (a-- > 0) *c++ = 6;
}
void rs_9_02_19_1(int a, unsigned char b, char *c) {
	++gi2;
}
void rs_9_02_19_2(int a, unsigned char b, char *c) {
	vs(gps);
}
char * rs_9_02_19_3(int a, unsigned char b, char *c) {
	return gs.p;
}
void rs_9_03_00_0(struct st *a, unsigned long b, long *c) {
	int t = gi3 | gia[4];
	ji = t;
}
void rs_9_03_00_1(struct st *a, unsigned long b, long *c) {
	int t = ji;
	unsigned long u = gula[t] / 2UL;
	jul = u;
}
void rs_9_03_00_2(struct st *a, unsigned long b, long *c) {
	vp(gs.p);
}
void rs_9_03_00_3(struct st *a, unsigned long b, long *c) {
	int t = ji;
	v0();
	gi = t;
}
void rs_9_03_00_4(struct st *a, unsigned long b, long *c) {
	unsigned long u = jul;
	v0();
	vl((long)u);
}
void rs_9_03_00_5(struct st *a, unsigned long b, long *c) {
	b -= gula[7] / 4UL;
}
int * rs_9_03_00_6(struct st *a, unsigned long b, long *c) {
	int t = ji;
	v0();
	return gpi + t;
}
void rs_9_03_01_0(void) {
	if (r2(gi2, gi2)) { if (gul != 0) gul = gul % gul; v2(gi2, gps->a[3] >> 13); if (gps->i != 0) gi = (int)gs.u % gps->i; } else { if (gi != 0) gi = gi / gi; gc = gc2 + gca[3]; v2(gi2, 1); }
}
void rs_9_03_01_1(void) {
	gpi++;
}
char rs_9_03_01_2(void) {
	return (gc2 - gs.c) - (-83 | (char)gu);
}
void rs_9_03_02_0(int a, struct st *b) {
	int t = gpi[0] << 2;
	ji = t;
}
void rs_9_03_02_1(int a, struct st *b) {
	int t = ji;
	gia[t] = a % 7;
}
void rs_9_03_02_2(int a, struct st *b) {
	b->p = gp;
}
unsigned int rs_9_03_02_3(int a, struct st *b) {
	return gu;
}
void rs_9_03_03_1(int a, unsigned long b) {
	char *t = gps->p + a;
	jp = t;
}
void rs_9_03_03_2(int a, unsigned long b) {
	unsigned int u = gu;
	ju = u;
}
void rs_9_03_03_3(int a, unsigned long b) {
	char *t = jp;
	gp = t;
}
void rs_9_03_03_4(int a, unsigned long b) {
	int i = ji;
	unsigned int u = ju;
	for (i = 0; i < 2; i++) { --gul; u /= 2; }
}
void rs_9_03_03_5(int a, unsigned long b) {
	gda[3] -= gd2 + 1.0;
}
void rs_9_03_03_6(int a, unsigned long b) {
	unsigned int u = ju;
	if (*gpl != 0) *gpl = gla[u] / *gpl;
}
void rs_9_03_03_7(int a, unsigned long b) {
	unsigned int u = ju;
	if (guc == guca[u]) { if (gula[a] != 0) b = gula[7] % gula[a]; gpl[0] &= gl; guca[6] = guc = (guca[7] * guca[0]) - guca[a]; }
}
int * rs_9_03_03_8(int a, unsigned long b) {
	return gpi + a;
}
void rs_9_03_04_0(unsigned char a, double b, long c) {
	int *t = gpi + a;
	jpi = t;
}
void rs_9_03_04_1(unsigned char a, double b, long c) {
	unsigned int u = ru(gps->u);
	ju = u;
}
void rs_9_03_04_2(unsigned char a, double b, long c) {
	int *t = jpi;
	v0();
	t = rpi(*gpi);
}
void rs_9_03_04_3(unsigned char a, double b, long c) {
	v0();
}
void rs_9_03_04_4(unsigned char a, double b, long c) {
	unsigned int u = ju;
	v0();
	gc >>= (u & 7);
}
int rs_9_03_04_5(unsigned char a, double b, long c) {
	return (gc2 == gc);
}
void rs_9_03_05_0(void) {
	gs.i *= 11;
}
void rs_9_03_05_1(void) {
	if (((unsigned char)gua[5]) >= 170) { gd = gs.d + (*gp ? 2.5 : 100.0); gula[6] += gul; vl(gpl[2]); } else { gula[1] = gul = 0x10000UL; }
}
void rs_9_03_05_2(void) {
	vl((long)3);
}
char * rs_9_03_05_3(void) {
	return gp;
}
void rs_9_03_06_1(void) {
	long t = gl + gla[0];
	jl = t;
}
void rs_9_03_06_2(void) {
	unsigned int u = gua[4] % 3;
	ju = u;
}
void rs_9_03_06_3(void) {
	long t = jl;
	gl = t;
}
void rs_9_03_06_4(void) {
	unsigned int u = ju;
	u += (unsigned int)(255 == guc);
}
void rs_9_03_06_5(void) {
	int i = ji;
	for (i = 0; i < 15; i++) { guc++; }
}
unsigned long rs_9_03_06_6(void) {
	unsigned int u = ju;
	return gula[u];
}
void rs_9_03_07_0(unsigned int a, double b) {
	unsigned char t = (unsigned char)*gp;
	juc = t;
}
void rs_9_03_07_1(unsigned int a, double b) {
	int *u = gpi;
	jpi = u;
}
void rs_9_03_07_2(unsigned int a, double b) {
	gl += gl << 20;
}
void rs_9_03_07_3(unsigned int a, double b) {
	int *u = jpi;
	v1(*u);
}
void rs_9_03_07_4(unsigned int a, double b) {
	gs.c /= 2;
}
void rs_9_03_07_5(unsigned int a, double b) {
	unsigned char t = juc;
	v0();
	guc = t;
}
void rs_9_03_08_0(long a, unsigned char b) {
	long t = a;
	jl = t;
}
void rs_9_03_08_1(long a, unsigned char b) {
	long t = jl;
	gl = t;
}
void rs_9_03_08_2(long a, unsigned char b) {
	gpi = &gia[b];
}
void rs_9_03_08_3(long a, unsigned char b) {
	vl(gpl[2]);
}
void rs_9_03_08_4(long a, unsigned char b) {
	gps->i = gi ^ gi3;
}
void rs_9_03_08_5(long a, unsigned char b) {
	guc = b = guca[4] - (b & 128);
}
int rs_9_03_08_6(long a, unsigned char b) {
	return (int)gu2 / 7;
}
void rs_9_03_09_0(unsigned char a, double b) {
	unsigned long u = jul;
	unsigned long t = (unsigned long)gps->u;
	jul = t;
}
void rs_9_03_09_1(unsigned char a, double b) {
	unsigned long t = jul;
	unsigned long u = t | 37714UL;
	jul = u;
}
void rs_9_03_09_2(unsigned char a, double b) {
	--gc2;
}
int rs_9_03_09_3(unsigned char a, double b) {
	if (guc == 247) return ~*gpi;
}
void rs_9_03_09_4(unsigned char a, double b) {
	unsigned long u = jul;
	vl((long)u);
}
void rs_9_03_09_5(unsigned char a, double b) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
int rs_9_03_09_6(unsigned char a, double b) {
	return ((gca[a] + 'a') >= gp[3]);
}
void rs_9_03_10_0(void) {
	int t = (gc2 != (char)gul);
	ji = t;
}
void rs_9_03_10_1(void) {
	guca[5] = guc;
}
void rs_9_03_10_2(void) {
	int t = ji;
	gca[t] ^= gc << 3;
}
void rs_9_03_10_3(void) {
	int t = ji;
	switch (gs.c) { case 0: case 1: gps->p = gs.p; break; case 2: vd(gs.d); break; case 3: gs.l -= gps->l; break; case 4: v2(gi2, gi); break; default: gul = gula[t] / 7UL; break; }
}
void rs_9_03_10_4(void) {
	v1(8);
}
void rs_9_03_10_5(void) {
	vs(gps);
}
unsigned long rs_9_03_10_6(void) {
	int t = ji;
	v0();
	return gula[t] + gul;
}
void rs_9_03_11_0(struct st *a) {
	unsigned long t = gul;
	jul = t;
}
void rs_9_03_11_1(struct st *a) {
	int u = r2(gi2, gi);
	ji = u;
}
void rs_9_03_11_2(struct st *a) {
	gs.l = 23114L - *gpl;
}
void rs_9_03_11_3(struct st *a) {
	int u = ji;
	v0();
	guca[u] /= 3;
}
void rs_9_03_11_4(struct st *a) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
void rs_9_03_11_5(struct st *a) {
	++guc;
}
void rs_9_03_11_6(struct st *a) {
	v0();
}
void rs_9_03_11_7(struct st *a) {
	guc += (gs.l ? ((unsigned char)gla[0]) : guca[6]);
}
int rs_9_03_11_8(struct st *a) {
	int u = ji;
	v0();
	return u;
}
void rs_9_03_12_0(char *a, int b) {
	char t = gp[0] >> (b & 7);
	jc = t;
}
void rs_9_03_12_1(char *a, int b) {
	switch (gu2) { case 0: v2(gi2, gi3); case 1: gd *= gs.d; break; }
}
void rs_9_03_12_2(char *a, int b) {
	char t = jc;
	v0();
	gul = (0x10000UL - gul) << (t & 15);
}
void rs_9_03_12_3(char *a, int b) {
	gul = rul(gul) | (gula[3] ^ gula[5]);
}
char * rs_9_03_12_4(char *a, int b) {
	return gs.p + b;
}
void rs_9_03_13_0(double a, unsigned int b, unsigned char c) {
	gd -= (guc & 0x8 ? 3.0 : a);
}
void rs_9_03_13_1(double a, unsigned int b, unsigned char c) {
	gpi = rpi(gi2);
}
long rs_9_03_13_2(double a, unsigned int b, unsigned char c) {
	return (gla[b] + (long)gia[0]) ^ (gl ^ gps->l);
}
void rs_9_03_14_1(int *a) {
	vc(gc);
}
void rs_9_03_14_2(int *a) {
	gd2 += gd * gd2;
}
void rs_9_03_14_3(int *a) {
	int i = ji;
	v0();
	i = 3; do { gla[i] = gl * 0L; if (gua[i] != 0) gu = gu2 % gua[i]; } while (--i > 0);
}
long rs_9_03_14_4(int *a) {
	return rl(gla[4] - 5L);
}
void rs_9_03_15_0(void) {
	int *t = &gia[1];
	jpi = t;
}
void rs_9_03_15_1(void) {
	v2(gi3, gi);
}
void rs_9_03_15_2(void) {
	gp = gs.p;
}
void rs_9_03_15_3(void) {
	gps->p = rp();
}
void rs_9_03_15_4(void) {
	if (gu2 != 0) gu2 = 5 % gu2;
}
void rs_9_03_15_5(void) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_9_03_15_6(void) {
	gua[2] = 9;
}
int rs_9_03_15_7(void) {
	return (gps->a[2] >> 11) * (2 << 3);
}
void rs_9_03_16_1(int a, char b, unsigned int c) {
	vp(gps->p + a);
}
void rs_9_03_16_2(int a, char b, unsigned int c) {
	int i = ji;
	v0();
	for (i = 0; i < a; i++) { if (gu != 0) gps->u = gua[i] % gu; guca[i] %= 3; gp = rp(); }
}
void rs_9_03_16_3(int a, char b, unsigned int c) {
	if (65536L == 74176L && 61 > 7) gp++;
}
int rs_9_03_16_4(int a, char b, unsigned int c) {
	int i = ji;
	v0();
	return ~gi2 - gps->i;
}
void rs_9_03_17_0(unsigned int a, int b) {
	char *t = gps->p + a;
	jp = t;
}
void rs_9_03_17_1(unsigned int a, int b) {
	char *t = jp;
	gp = t;
}
void rs_9_03_17_2(unsigned int a, int b) {
	gl2 = ((long)(b == gia[b])) >> (b & 15);
}
void rs_9_03_17_3(unsigned int a, int b) {
	guca[a] = guc = (unsigned char)!(5 + gps->c);
}
unsigned long rs_9_03_17_4(unsigned int a, int b) {
	return (gul ^ ((unsigned long)guca[a])) - (gula[a] % 10UL);
}
void rs_9_03_18_0(void) {
	gula[1] = rul(gul);
}
void rs_9_03_18_1(void) {
	switch (gi2) { case 0: gda[1] -= 0.5; break; case 1: gd -= gd2; break; default: gula[2] = gula[2] - 0x10000UL; break; }
}
void rs_9_03_18_2(void) {
	gl2 = (long)!2 + (gl / 10L);
}
void rs_9_03_18_3(void) {
	gu = -((unsigned int)(4 == gca[0]));
}
void rs_9_03_18_4(void) {
	if (32767 == 17439 && 2 != gpi[2]) gu = ru(gu2 - gua[2]);
}
long rs_9_03_18_5(void) {
	return gl + (gla[3] * 12L);
}
void rs_9_03_19_0(void) {
	unsigned char t = guca[3];
	juc = t;
}
void rs_9_03_19_1(void) {
	gl2 %= 16L;
}
void rs_9_03_19_2(void) {
	gp[0] = rc(gi2);
}
void rs_9_03_19_3(void) {
	unsigned char t = juc;
	v0();
	v1(t);
}
void rs_9_03_19_4(void) {
	v0();
}
void rs_9_03_19_5(void) {
	gc2 = '9';
}
void rs_9_03_19_6(void) {
	gca[3] += -'z';
}
int * rs_9_03_19_7(void) {
	unsigned char t = juc;
	v0();
	return rpi(gia[t]);
}
void rs_9_04_00_0(long *a, int b) {
	int u = ji;
	unsigned int t = gps->u / 7;
	ju = t;
}
void rs_9_04_00_1(long *a, int b) {
	int u = gpi[1];
	ji = u;
}
void rs_9_04_00_2(long *a, int b) {
	gi2 += !0L;
}
void rs_9_04_00_3(long *a, int b) {
	gl &= (long)(gs.a[4] != gs.i);
}
unsigned int rs_9_04_00_4(long *a, int b) {
	int u = ji;
	if (guc >= guca[u] && -11574L <= gl) return gu;
}
void rs_9_04_00_5(long *a, int b) {
	int u = ji;
	if (gc != 0) gps->c = gca[u] % gc;
}
void rs_9_04_00_6(long *a, int b) {
	unsigned int t = ju;
	vu(t);
}
void rs_9_04_00_7(long *a, int b) {
	b = r2(b - 255, gi);
}
unsigned int rs_9_04_00_8(long *a, int b) {
	unsigned int t = ju;
	v0();
	return ~gu2 + (r1(*gpi) ? t : gu2);
}
void rs_9_04_01_0(char *a, long b) {
	unsigned long t = 0UL & gula[2];
	jul = t;
}
void rs_9_04_01_1(char *a, long b) {
	double u = (gua[3] & 2 ? gd2 : gd2);
	jd = u;
}
void rs_9_04_01_2(char *a, long b) {
	gd *= (double)gc / 0.25;
}
void rs_9_04_01_3(char *a, long b) {
	gs.l = gs.l + *gpl;
}
void rs_9_04_01_4(char *a, long b) {
	gs.a[3] = (int)((unsigned char)gl2);
}
void rs_9_04_01_5(char *a, long b) {
	double u = jd;
	gd = u;
}
void rs_9_04_01_6(char *a, long b) {
	unsigned long t = jul;
	if (gps->a[7]) if (gula[7] != 0) t = gula[1] / gula[7];
}
int * rs_9_04_01_7(char *a, long b) {
	return gpi;
}
void rs_9_04_02_0(long *a) {
	long t = gs.l + gl2;
	jl = t;
}
void rs_9_04_02_1(long *a) {
	long t = jl;
	vl(t);
}
void rs_9_04_02_2(long *a) {
	switch (gc2) { case 0: v0(); case 1: gps->c = gc = (gua[2] < 1 ? gs.c : '0'); break; case 2: vu(gua[0]); break; case 3: vl(0L); break; default: vd(0.5); break; }
}
void rs_9_04_02_3(long *a) {
	vc(*gp);
}
void rs_9_04_02_4(long *a) {
	gp = gp + 1;
}
int rs_9_04_02_5(long *a) {
	return (gi & gps->a[0]) & (int)gps->l;
}
void rs_9_04_03_1(int *a) {
	char *t = gps->p;
	jp = t;
}
void rs_9_04_03_2(int *a) {
	int i = ji;
	int u = gs.i % 7;
	ji = u;
}
void rs_9_04_03_3(int *a) {
	--gpi;
}
void rs_9_04_03_4(int *a) {
	char *t = jp;
	vp(t);
}
void rs_9_04_03_5(int *a) {
	int i = ji;
	int u = ji;
	v0();
	for (i = 0; i < 3; i++) { gs.d += gs.d * gd2; if (gua[i] != 0) gs.u = gu / gua[i]; }
}
void rs_9_04_03_6(int *a) {
	if (gu != 0) gu = gu2 % gu;
}
void rs_9_04_03_7(int *a) {
	gs.l &= gpl[3] - gps->l;
}
unsigned int rs_9_04_03_8(int *a) {
	return (unsigned int)!(char)!gpl[2];
}
void rs_9_04_04_0(unsigned long a) {
	switch (gu) { case 0: gl = gl2; break; case 1: vs(gps); break; }
}
void rs_9_04_04_1(unsigned long a) {
	gp[0] = -gps->c;
}
unsigned int rs_9_04_04_2(unsigned long a) {
	return (unsigned int)(a - gula[0]);
}
void rs_9_04_05_1(void) {
	int i = ji;
	i = 0; while (i < 7) { ++gc2; v2(r0(), gi); i++; }
}
char rs_9_04_05_2(void) {
	if (gua[5] < 2 || guca[2] != ((unsigned char)gl2)) return gp[2];
}
char rs_9_04_05_3(void) {
	return rc(gia[7] | gs.a[4]);
}
void rs_9_04_06_0(int a) {
	guc -= ~guc;
}
void rs_9_04_06_1(int a) {
	gs.l = gl2 = (long)gul / 4L;
}
void rs_9_04_06_2(int a) {
	if (gul > 7UL) { if (gs.l != 0) gla[3] = gpl[0] % gs.l; if (gl2 != 0) gla[0] = gl % gl2; if (gl2 != 0) gpl[0] = gla[a] % gl2; }
}
void rs_9_04_06_3(int a) {
	guc = guca[7] = (unsigned char)(ru(gs.u) <= (((unsigned int)gl) + gu2));
}
void rs_9_04_06_4(int a) {
	gd = (gd / 2.5) / 2.5;
}
char rs_9_04_06_5(int a) {
	return (guca[a] < guca[0] ? 13 : gc2) & 4;
}
void rs_9_04_07_0(unsigned char a) {
	while (gi-- > 0) { if (*gp == -44) break; gp++; }
}
void rs_9_04_07_1(unsigned char a) {
	gi2++;
}
void rs_9_04_07_2(unsigned char a) {
	++gc2;
}
void rs_9_04_07_3(unsigned char a) {
	gc = gs.c = 22;
}
void rs_9_04_07_4(unsigned char a) {
	gs.u = gu;
}
int * rs_9_04_07_5(unsigned char a) {
	return gpi + a;
}
void rs_9_04_08_0(unsigned char a) {
	vp(gs.p + a);
}
void rs_9_04_08_1(unsigned char a) {
	gp = &gca[4];
}
void rs_9_04_08_2(unsigned char a) {
	a = -a % 16;
}
char rs_9_04_08_3(unsigned char a) {
	return gs.c;
}
void rs_9_04_09_0(int a, int b) {
	int *t = rpi(b);
	jpi = t;
}
void rs_9_04_09_1(int a, int b) {
	unsigned int u = gu;
	v0();
	ju = u;
}
void rs_9_04_09_2(int a, int b) {
	gca[b] = (char)!guca[6];
}
void rs_9_04_09_3(int a, int b) {
	unsigned int u = ju;
	v0();
	vu(u);
}
void rs_9_04_09_4(int a, int b) {
	gs.p = gps->p + b;
}
void rs_9_04_09_5(int a, int b) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_9_04_09_6(int a, int b) {
	v0();
}
long rs_9_04_09_7(int a, int b) {
	return gps->l;
}
void rs_9_04_10_0(void) {
	guca[4] = (unsigned char)(gpl[2] == gps->l);
}
void rs_9_04_10_1(void) {
	while (gi > 0) { gi3 += *gpi++; gi--; }
}
void rs_9_04_10_2(void) {
	--gc2;
}
unsigned int rs_9_04_10_3(void) {
	return (gps->u = 8);
}
void rs_9_04_11_0(void) {
	gi3 %= 7;
}
void rs_9_04_11_1(void) {
	vl(gl + gs.l);
}
void rs_9_04_11_2(void) {
	*gpi = (127 > gs.i);
}
void rs_9_04_11_3(void) {
	gda[1] = gda[1] - 10.0;
}
long rs_9_04_11_4(void) {
	return (gps->l = gs.l);
}
void rs_9_04_12_1(void) {
	int *t = rpi(100);
	jpi = t;
}
void rs_9_04_12_2(void) {
	unsigned long u = gula[6] >> 27;
	v0();
	jul = u;
}
void rs_9_04_12_3(void) {
	int i = ji;
	unsigned long u = jul;
	v0();
	for (i = 0; i < 13; i++) { u = 32474UL; }
}
void rs_9_04_12_4(void) {
	gd -= 0.25;
}
void rs_9_04_12_5(void) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_9_04_12_6(void) {
	unsigned long u = jul;
	v0();
	u = rul(gul);
}
int rs_9_04_12_7(void) {
	return gi2 >> 15;
}
void rs_9_04_13_0(void) {
	double t = gd / 0.25;
	jd = t;
}
void rs_9_04_13_1(void) {
	char *u = rp();
	jp = u;
}
void rs_9_04_13_2(void) {
	double t = jd;
	v0();
	gd = t;
}
void rs_9_04_13_3(void) {
	guca[6] = guc - (guca[4] + guca[7]);
}
void rs_9_04_13_4(void) {
	char *u = jp;
	v0();
	gs.u = ~((unsigned int)gula[5]);
}
void rs_9_04_13_5(void) {
	gul = 6UL;
}
void rs_9_04_13_6(void) {
	gi = (gi2 / 16) - (gi - gi3);
}
int rs_9_04_13_7(void) {
	return gi;
}
long rs_9_04_14_0(void) {
	if (0L < -33398L) return 65536L;
}
void rs_9_04_14_1(void) {
	gul--;
}
long rs_9_04_14_2(void) {
	return gl2 | 1L;
}
void rs_9_04_15_0(int a, unsigned int b, double c) {
	long t = 65536L >> 13;
	jl = t;
}
void rs_9_04_15_1(int a, unsigned int b, double c) {
	long t = jl;
	t = ~t;
}
void rs_9_04_15_2(int a, unsigned int b, double c) {
	gda[0] = -(c * gd2);
}
long rs_9_04_15_3(int a, unsigned int b, double c) {
	return (gpl[0] = 41471L);
}
void rs_9_04_16_0(long *a) {
	double t = gd2 - gd;
	jd = t;
}
void rs_9_04_16_1(long *a) {
	char *u = gps->p + 1;
	jp = u;
}
void rs_9_04_16_2(long *a) {
	gc2 = (char)(gps->a[6] / 16);
}
void rs_9_04_16_3(long *a) {
	double t = jd;
	gd = t;
}
void rs_9_04_16_4(long *a) {
	char *u = jp;
	vp(u);
}
void rs_9_04_16_5(long *a) {
	gl2 = rl(gl - 7L);
}
int * rs_9_04_16_6(long *a) {
	return gpi;
}
void rs_9_04_17_0(void) {
	int t = gi2 | gps->a[6];
	ji = t;
}
void rs_9_04_17_1(void) {
	int t = ji;
	gula[t] ^= ((unsigned long)gs.a[t]) + gul;
}
void rs_9_04_17_2(void) {
	int t = ji;
	guca[t] |= guca[1] - guc;
}
void rs_9_04_17_3(void) {
	if (gu2 != 0) gua[1] = 2 % gu2;
}
int rs_9_04_17_4(void) {
	return (int)*gp;
}
void rs_9_04_18_0(long *a) {
	int *t = rpi(gi2);
	jpi = t;
}
void rs_9_04_18_1(long *a) {
	gs.a[1] = gpi[2] - gia[7];
}
void rs_9_04_18_2(long *a) {
	int *t = jpi;
	v0();
	*t = gia[4] + gia[7];
}
void rs_9_04_18_3(long *a) {
	gpi = rpi(gs.i);
}
void rs_9_04_18_4(long *a) {
	if (gi2 & 1) { gps->u = gu; vl((long)gul); guc = ((unsigned char)!gi) - ~guca[7]; } else { *gpl = (long)((4L / 100L) < (gl2 + gla[2])); gd -= (double)gl2; }
}
void rs_9_04_18_5(long *a) {
	gu = gua[4] - (gu2 | gu);
}
long rs_9_04_18_6(long *a) {
	return (73496L << 22) - gl2;
}
void rs_9_04_19_1(void) {
	unsigned long t = ((unsigned long)guc) + gul;
	jul = t;
}
void rs_9_04_19_2(void) {
	gp = rp();
}
void rs_9_04_19_3(void) {
	gc = gca[3];
}
void rs_9_04_19_4(void) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
void rs_9_04_19_5(void) {
	int i = ji;
	v0();
	i = 7; do { gia[i] = (8 >> (i & 15)) / 100; vl(65536L | gla[i]); --gpi; } while (--i > 0);
}
void rs_9_04_19_6(void) {
	gps->u = 1 - gu2;
}
void rs_9_04_19_7(void) {
	if (gu == 1) { ++gul; } else { gula[7] = rul(gula[3]) / 4UL; gpi = gpi + 1; }
}
unsigned int rs_9_04_19_8(void) {
	return gua[7];
}
void rs_9_05_00_0(struct st *a, unsigned char b) {
	char *t = a->p + b;
	jp = t;
}
void rs_9_05_00_1(struct st *a, unsigned char b) {
	switch (gi) { case 0: gula[7] -= gul; break; case 1: gu2 += gps->u; break; default: gi3 = gi; break; }
}
void rs_9_05_00_2(struct st *a, unsigned char b) {
	char *t = jp;
	gp = t;
}
void rs_9_05_00_3(struct st *a, unsigned char b) {
	if (gu != 0) gs.u = ((unsigned int)gia[b]) / gu;
}
void rs_9_05_00_4(struct st *a, unsigned char b) {
	vl(*gpl | gl);
}
void rs_9_05_00_5(struct st *a, unsigned char b) {
	gi2 ^= 14;
}
void rs_9_05_00_6(struct st *a, unsigned char b) {
	v2(gps->i, gi);
}
void rs_9_05_01_1(void) {
	double t = gd;
	jd = t;
}
void rs_9_05_01_2(void) {
	long u = *gpl;
	jl = u;
}
void rs_9_05_01_3(void) {
	int i = ji;
	long u = jl;
	for (i = 9; i > 0; i--) { gla[i] = rl(u * 8L); }
}
void rs_9_05_01_4(void) {
	long u = jl;
	v0();
	gs.u = (gs.c < ' ' ? gu2 : gua[2]);
}
void rs_9_05_01_5(void) {
	double t = jd;
	v0();
	vd(t);
}
void rs_9_05_01_6(void) {
	if (gul < gula[2] || guca[3]) guca[4] = guc;
}
unsigned int rs_9_05_01_7(void) {
	return 255;
}
void rs_9_05_02_0(char *a) {
	gula[7] -= (unsigned long)(gs.u >= gu);
}
void rs_9_05_02_1(char *a) {
	++gc;
}
void rs_9_05_02_2(char *a) {
	if (gpi[3] > 0) gps->l += (long)guca[5];
}
void rs_9_05_02_3(char *a) {
	gi++;
}
unsigned long rs_9_05_02_4(char *a) {
	return (gul + 4UL) / 2UL;
}
void rs_9_05_03_1(unsigned int a, int *b, unsigned char c) {
	double t = 0.25 * gd2;
	jd = t;
}
void rs_9_05_03_2(unsigned int a, int *b, unsigned char c) {
	int u = ~gi3;
	ji = u;
}
void rs_9_05_03_3(unsigned int a, int *b, unsigned char c) {
	double t = jd;
	vd(3.0 + t);
}
void rs_9_05_03_4(unsigned int a, int *b, unsigned char c) {
	int u = ji;
	v0();
	if (u) if (u != 0) u = b[1] % u;
}
void rs_9_05_03_5(unsigned int a, int *b, unsigned char c) {
	int i = ji;
	v0();
	for (i = 0; i < 2; i++) { gula[i] = ~gula[7]; if (gua[6] != 0) gu2 = gua[i] % gua[6]; }
}
int rs_9_05_03_6(unsigned int a, int *b, unsigned char c) {
	int i = ji;
	int u = ji;
	v0();
	return ((gs.i / 2) == (int)gps->u);
}
void rs_9_05_04_1(char a, long *b) {
	unsigned char t = guc & guca[7];
	juc = t;
}
void rs_9_05_04_2(char a, long *b) {
	int u = gps->a[a];
	ji = u;
}
void rs_9_05_04_3(char a, long *b) {
	int i = ji;
	i = 0; while (i < 14) { if (gul != 0) gula[i] = gul % gul; i++; }
}
void rs_9_05_04_4(char a, long *b) {
	unsigned char t = juc;
	v1(t);
}
void rs_9_05_04_5(char a, long *b) {
	if (gps->l) { gps->c = gc / 3; }
}
void rs_9_05_04_6(char a, long *b) {
	++gpi;
}
void rs_9_05_04_7(char a, long *b) {
	int u = ji;
	v0();
	v1(u);
}
int rs_9_05_04_8(char a, long *b) {
	return gia[a];
}
void rs_9_05_05_0(unsigned long a, unsigned long b, char c) {
	int *t = gpi;
	jpi = t;
}
void rs_9_05_05_1(unsigned long a, unsigned long b, char c) {
	gia[4] ^= (guca[7] < guc ? gia[c] : gia[c]);
}
void rs_9_05_05_2(unsigned long a, unsigned long b, char c) {
	if (gu2 != 32767) { if (gi2 != 0) gi3 = gi2 / gi2; if (gu != 0) gua[2] = 32767 % gu; if (b != 0) a = gula[5] / b; }
}
void rs_9_05_05_3(unsigned long a, unsigned long b, char c) {
	int *t = jpi;
	v1(*t);
}
void rs_9_05_05_4(unsigned long a, unsigned long b, char c) {
	gi3 = gps->i >> 7;
}
void rs_9_05_05_5(unsigned long a, unsigned long b, char c) {
	while (gi-- > 0) { if (*gpi == 255) break; gpi++; }
}
void rs_9_05_05_6(unsigned long a, unsigned long b, char c) {
	if (gi3 & 2) gula[c] = (unsigned long)!rul(a);
}
void rs_9_05_06_0(long *a) {
	int *t = &gia[5];
	jpi = t;
}
void rs_9_05_06_1(long *a) {
	unsigned long u = 8932UL << 5;
	jul = u;
}
void rs_9_05_06_2(long *a) {
	unsigned long u = jul;
	gps->u = ru(gps->u);
}
void rs_9_05_06_3(long *a) {
	v2(~gi, gi);
}
void rs_9_05_06_4(long *a) {
	gda[0] += -gd2;
}
void rs_9_05_06_5(long *a) {
	int *t = jpi;
	v0();
	v1(*t);
}
int rs_9_05_06_6(long *a) {
	return !guca[7];
}
void rs_9_05_07_0(unsigned long a) {
	gi2 = (gi3 & gs.a[6]) - ((int)guca[3] + gia[6]);
}
void rs_9_05_07_1(unsigned long a) {
	gl = (gs.l % 100L) / 7L;
}
void rs_9_05_07_2(unsigned long a) {
	gu2 += gua[1];
}
void rs_9_05_07_3(unsigned long a) {
	if (gpl[1] > gla[3]) { gua[7] = (unsigned int)gula[4]; gps->u = gu = (unsigned int)gul; if (gua[5] != 0) gps->u = gu / gua[5]; }
}
long rs_9_05_07_4(unsigned long a) {
	return (65536L >> 3) - rl(87158L);
}
void rs_9_05_08_0(void) {
	char *u = jp;
	double t = (!gps->u ? 2.5 : gd);
	jd = t;
}
void rs_9_05_08_1(void) {
	char *u = gs.p;
	jp = u;
}
void rs_9_05_08_2(void) {
	gps->l = (gl2 + gs.l) + (gla[6] % 10L);
}
void rs_9_05_08_3(void) {
	char *u = jp;
	switch (gi2) { case 1: v0(); break; case 2: gl2 -= gs.l; break; case 3: case 5: u = gp; break; case 100: vs(gps); break; case 200: vc(gp[1]); default: guca[2] = guc = guca[1] << 7; break; }
}
void rs_9_05_08_4(void) {
	gps->a[4] += r2(gi, gi);
}
void rs_9_05_08_5(void) {
	vc((char)!gi);
}
void rs_9_05_08_6(void) {
	double t = jd;
	v0();
	gd = t;
}
int rs_9_05_08_7(void) {
	return gi;
}
void rs_9_05_09_0(char a, int b, long c) {
	double t = gs.d / 3.0;
	jd = t;
}
void rs_9_05_09_1(char a, int b, long c) {
	int u = gi;
	ji = u;
}
void rs_9_05_09_2(char a, int b, long c) {
	switch (gu2) { case 0: v0(); break; case 1: gul = gula[a] - gul; break; case 2: case 3: v2((int)gu, gi); break; }
}
void rs_9_05_09_3(char a, int b, long c) {
	int u = ji;
	v0();
	vu(gs.u % 4);
}
void rs_9_05_09_4(char a, int b, long c) {
	double t = jd;
	v0();
	gd = t;
}
int rs_9_05_09_5(char a, int b, long c) {
	int u = ji;
	v0();
	return gia[u] + !gul;
}
void rs_9_05_10_0(unsigned int a, struct st *b, int c) {
	gi -= gi2 % 3;
}
void rs_9_05_10_1(unsigned int a, struct st *b, int c) {
	gpi = gpi + c;
}
int rs_9_05_10_2(unsigned int a, struct st *b, int c) {
	return (gia[c] << 2) + ((int)gul >> 3);
}
void rs_9_05_11_1(struct st *a, int b, long *c) {
	unsigned char t = guca[b] * guc;
	juc = t;
}
void rs_9_05_11_2(struct st *a, int b, long *c) {
	double u = gd / 3.0;
	jd = u;
}
void rs_9_05_11_3(struct st *a, int b, long *c) {
	int i = ji;
	double u = jd;
	i = b; do { vc(rc(b)); if (gu2 != 0) gu2 = gs.u / gu2; gc2 -= 3 / 4; } while (--i > 0);
}
void rs_9_05_11_4(struct st *a, int b, long *c) {
	gc2 = gp[3];
}
void rs_9_05_11_5(struct st *a, int b, long *c) {
	gula[1] = (gula[5] % 16UL) + gula[5];
}
void rs_9_05_11_6(struct st *a, int b, long *c) {
	if (gula[b] != 0) gul = gul / gula[b];
}
void rs_9_05_11_7(struct st *a, int b, long *c) {
	unsigned char t = juc;
	v0();
	gca[t] = ~(gs.c / 7);
}
int * rs_9_05_11_8(struct st *a, int b, long *c) {
	return gpi + b;
}
void rs_9_05_12_1(long *a, unsigned long b, unsigned char c) {
	char *t = rp();
	jp = t;
}
void rs_9_05_12_2(long *a, unsigned long b, unsigned char c) {
	unsigned char u = guca[c] >> 4;
	v0();
	juc = u;
}
void rs_9_05_12_3(long *a, unsigned long b, unsigned char c) {
	char *t = jp;
	v0();
	gp = t;
}
long rs_9_05_12_4(long *a, unsigned long b, unsigned char c) {
	if (gu2 & 0x7) return (long)((unsigned int)guca[0]);
}
void rs_9_05_12_5(long *a, unsigned long b, unsigned char c) {
	int i = ji;
	v0();
	for (i = 0; i < 5; i++) { if (gps->a[i] != 0) gps->a[6] = gia[0] % gps->a[i]; *gpi <<= (i & 15); }
}
void rs_9_05_12_6(long *a, unsigned long b, unsigned char c) {
	int i = ji;
	v0();
	i = 12; do { *gp %= 16; } while (--i > 0);
}
void rs_9_05_12_7(long *a, unsigned long b, unsigned char c) {
	unsigned char u = juc;
	v0();
	gps->a[u] = gia[3] << 6;
}
void rs_9_05_12_8(long *a, unsigned long b, unsigned char c) {
	gc2 = (gp[2] >> 1) % 7;
}
long rs_9_05_12_9(long *a, unsigned long b, unsigned char c) {
	return (long)(ru((unsigned int)a[1]) >= 681);
}
void rs_9_05_13_0(void) {
	char t = gca[4];
	jc = t;
}
void rs_9_05_13_1(void) {
	int *u = &gia[1];
	jpi = u;
}
void rs_9_05_13_2(void) {
	gula[5] = gul / 100UL;
}
void rs_9_05_13_3(void) {
	gi3 = -r0();
}
void rs_9_05_13_4(void) {
	int *u = jpi;
	v0();
	*u &= gi2 & gpi[1];
}
void rs_9_05_13_5(void) {
	char t = jc;
	v0();
	vc(t);
}
char rs_9_05_13_6(void) {
	return (gc % 100) << 3;
}
void rs_9_05_14_0(char a, int *b) {
	int *t = rpi(gi2);
	jpi = t;
}
void rs_9_05_14_1(char a, int *b) {
	unsigned long u = ~gula[a];
	v0();
	jul = u;
}
void rs_9_05_14_2(char a, int *b) {
	gd *= gd * gd2;
}
void rs_9_05_14_3(char a, int *b) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_9_05_14_4(char a, int *b) {
	unsigned long u = jul;
	v0();
	gul = u;
}
void rs_9_05_14_5(char a, int *b) {
	gu2 = ru(255) + 255;
}
void rs_9_05_15_0(int a) {
	if (gs.l > -60159L) { guca[0] = guca[a]; gul += gula[3] / 3UL; vd(gd2); }
}
void rs_9_05_15_1(int a) {
	gi2 *= 4;
}
void rs_9_05_15_2(int a) {
	gu = gs.u = (unsigned int)!rl(gl2);
}
void rs_9_05_15_3(int a) {
	gul = gula[a];
}
int rs_9_05_15_4(int a) {
	return (gps->i = 8);
}
void rs_9_05_16_0(char a, long *b) {
	unsigned long t = gula[5] * ((unsigned long)gi3);
	jul = t;
}
void rs_9_05_16_1(char a, long *b) {
	long u = 8L / 2L;
	jl = u;
}
void rs_9_05_16_2(char a, long *b) {
	long u = jl;
	gl = u;
}
void rs_9_05_16_3(char a, long *b) {
	unsigned long t = jul;
	t = (gula[1] % 100UL) * 11UL;
}
void rs_9_05_16_4(char a, long *b) {
	gs.a[6] = gi2 >> 6;
}
void rs_9_05_17_0(int a, unsigned int b) {
	long t = gl - gl2;
	jl = t;
}
void rs_9_05_17_1(int a, unsigned int b) {
	int u = gia[a] + gs.i;
	ji = u;
}
void rs_9_05_17_2(int a, unsigned int b) {
	long t = jl;
	vl(t);
}
void rs_9_05_17_3(int a, unsigned int b) {
	int u = ji;
	v0();
	if (gu2) { if (u != 0) gia[4] = 256 % u; } else { gp = gs.p + u; }
}
void rs_9_05_17_4(int a, unsigned int b) {
	int u = ji;
	v0();
	u = 2 >> 1;
}
void rs_9_05_17_5(int a, unsigned int b) {
	int u = ji;
	v0();
	u--;
}
void rs_9_05_17_6(int a, unsigned int b) {
	int u = ji;
	v0();
	gpl[0] = gla[u] & *gpl;
}
int rs_9_05_17_7(int a, unsigned int b) {
	if (156 >= guca[2]) return gs.i;
}
int rs_9_05_17_8(int a, unsigned int b) {
	return -gi2 | ((int)gula[a] + gi3);
}
void rs_9_05_18_0(int a, char b) {
	int t = gps->a[a];
	ji = t;
}
void rs_9_05_18_1(int a, char b) {
	gd *= gd - gda[3];
}
void rs_9_05_18_2(int a, char b) {
	int t = ji;
	gi = t;
}
void rs_9_05_18_3(int a, char b) {
	guca[0] = (gu < gu2 ? guca[b] : guca[a]);
}
int rs_9_05_18_4(int a, char b) {
	return gs.i;
}
void rs_9_05_19_0(void) {
	double t = 2.5;
	jd = t;
}
void rs_9_05_19_1(void) {
	unsigned char u = guc;
	juc = u;
}
void rs_9_05_19_2(void) {
	unsigned char u = juc;
	switch (gps->u) { case 2: gl2 <<= 4; case 3: gula[u] -= 7UL; break; case 10: gps->u = gu >> 9; break; case 200: vc(gca[3]); case 1000: vd((double)gua[6]); break; default: vp(gs.p); break; }
}
void rs_9_05_19_3(void) {
	double t = jd;
	v0();
	gd = t;
}
void rs_9_05_19_4(void) {
	unsigned char u = juc;
	v0();
	gula[2] = (unsigned long)(gca[u] != gs.c);
}
long rs_9_05_19_5(void) {
	return 4L;
}
void rs_9_06_00_0(unsigned long a, struct st *b) {
	int t = gi2 * 10;
	ji = t;
}
void rs_9_06_00_1(unsigned long a, struct st *b) {
	double u = gs.d / 10.0;
	jd = u;
}
void rs_9_06_00_2(unsigned long a, struct st *b) {
	b->p = &gca[0];
}
void rs_9_06_00_3(unsigned long a, struct st *b) {
	int t = ji;
	if (gula[t] & 4) gp = gs.p;
}
void rs_9_06_00_4(unsigned long a, struct st *b) {
	double u = jd;
	gd = u;
}
void rs_9_06_00_5(unsigned long a, struct st *b) {
	int t = ji;
	b->i = gi3 = (t << 14) & ((int)guca[4] | *gpi);
}
void rs_9_06_00_6(unsigned long a, struct st *b) {
	while (gi-- > 0) { if (*gp == 'a') break; gp++; }
}
void rs_9_06_01_0(void) {
	char *t = gp;
	jp = t;
}
void rs_9_06_01_1(void) {
	char *t = jp;
	t = gps->p + 1;
}
void rs_9_06_01_2(void) {
	gl |= ~gps->l;
}
void rs_9_06_01_3(void) {
	v0();
}
unsigned long rs_9_06_01_4(void) {
	return (52228UL ^ gula[5]) % 3UL;
}
void rs_9_06_02_0(void) {
	int *t = gpi;
	jpi = t;
}
void rs_9_06_02_1(void) {
	unsigned long u = gula[3];
	jul = u;
}
void rs_9_06_02_2(void) {
	unsigned long u = jul;
	vl((long)u);
}
void rs_9_06_02_3(void) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_9_06_02_4(void) {
	gda[0] = (gs.a[2] > gpi[0] ? gd : gs.d);
}
void rs_9_06_02_5(void) {
	gps->l = gpl[0];
}
unsigned long rs_9_06_02_6(void) {
	return ((unsigned long)gc2) >> 17;
}
void rs_9_06_03_0(struct st *a, char b, unsigned char c) {
	int t = gs.i;
	ji = t;
}
void rs_9_06_03_1(struct st *a, char b, unsigned char c) {
	vd((double)gi);
}
void rs_9_06_03_2(struct st *a, char b, unsigned char c) {
	guc &= ~guc;
}
void rs_9_06_03_3(struct st *a, char b, unsigned char c) {
	int t = ji;
	v0();
	gca[c] = (char)gla[t];
}
long rs_9_06_03_4(struct st *a, char b, unsigned char c) {
	return (gla[3] % 7L) * 65536L;
}
void rs_9_06_04_0(void) {
	long t = rl(gps->l);
	jl = t;
}
void rs_9_06_04_1(void) {
	int *u = gpi + 1;
	v0();
	jpi = u;
}
void rs_9_06_04_2(void) {
	gi2 &= gi3 - gi2;
}
void rs_9_06_04_3(void) {
	long t = jl;
	v0();
	++t;
}
void rs_9_06_04_4(void) {
	int *u = jpi;
	v0();
	gps->u = gu2;
}
void rs_9_06_04_5(void) {
	gps->c = gc2 % 3;
}
int * rs_9_06_04_6(void) {
	int *u = jpi;
	v0();
	return u + 1;
}
void rs_9_06_05_1(unsigned char a, int b, long *c) {
	int i = ji;
	i = 0; while (i < b) { gl /= 10L; i++; }
}
void rs_9_06_05_2(unsigned char a, int b, long *c) {
	gs.c = '0';
}
void rs_9_06_05_3(unsigned char a, int b, long *c) {
	gs.c = gca[a] - gs.c;
}
void rs_9_06_05_4(unsigned char a, int b, long *c) {
	gc2 = ((char)(gd != (double)gs.u)) + (15 << 4);
}
void rs_9_06_05_5(unsigned char a, int b, long *c) {
	gu2 = gua[5] / 7;
}
int rs_9_06_05_6(unsigned char a, int b, long *c) {
	return r0();
}
void rs_9_06_06_0(void) {
	double t = gd2;
	jd = t;
}
void rs_9_06_06_1(void) {
	gla[2] = ~gla[2];
}
void rs_9_06_06_2(void) {
	gp = rp();
}
void rs_9_06_06_3(void) {
	double t = jd;
	v0();
	vd(t);
}
void rs_9_06_06_4(void) {
	gul = gula[1];
}
void rs_9_06_06_5(void) {
	gu = (gua[4] / 2) % 10;
}
void rs_9_06_06_6(void) {
	gl2 ^= gla[0];
}
unsigned int rs_9_06_06_7(void) {
	return (unsigned int)gula[7];
}
void rs_9_06_07_0(unsigned int a, int b, unsigned long c) {
	int t = 8;
	ji = t;
}
void rs_9_06_07_1(unsigned int a, int b, unsigned long c) {
	v2(gi2, ~gps->a[5]);
}
void rs_9_06_07_2(unsigned int a, int b, unsigned long c) {
	v0();
}
void rs_9_06_07_3(unsigned int a, int b, unsigned long c) {
	vl(-50635L + gl);
}
void rs_9_06_07_4(unsigned int a, int b, unsigned long c) {
	int t = ji;
	v0();
	v1(t);
}
void rs_9_06_07_5(unsigned int a, int b, unsigned long c) {
	if (guc != 128) gi3 = b;
}
int rs_9_06_07_6(unsigned int a, int b, unsigned long c) {
	int t = ji;
	v0();
	return t + !gpi[2];
}
void rs_9_06_08_0(long a, unsigned long b) {
	char *t = gp;
	jp = t;
}
void rs_9_06_08_1(long a, unsigned long b) {
	guca[7] += guca[5];
}
void rs_9_06_08_2(long a, unsigned long b) {
	if (!guca[6]) { if (gu2 != 0) gps->u = gs.u % gu2; if (gua[3] != 0) gu2 = gs.u % gua[3]; } else { guc = (guc / 10) / 10; }
}
void rs_9_06_08_3(long a, unsigned long b) {
	gl2 = (long)-gul;
}
void rs_9_06_08_4(long a, unsigned long b) {
	char *t = jp;
	vp(t);
}
char * rs_9_06_08_5(long a, unsigned long b) {
	return gp + 1;
}
void rs_9_06_09_0(unsigned char a, unsigned long b, int c) {
	double t = (guca[4] ? gd : (double)gi2);
	jd = t;
}
void rs_9_06_09_1(unsigned char a, unsigned long b, int c) {
	gpi = &gia[1];
}
void rs_9_06_09_2(unsigned char a, unsigned long b, int c) {
	gu = gs.u = (unsigned int)!gia[a];
}
void rs_9_06_09_3(unsigned char a, unsigned long b, int c) {
	vl((guca[2] < 128 ? gl2 : gla[5]));
}
void rs_9_06_09_4(unsigned char a, unsigned long b, int c) {
	guca[a] = guc = (255 >> (a & 7)) ^ (a - guc);
}
void rs_9_06_09_5(unsigned char a, unsigned long b, int c) {
	double t = jd;
	v0();
	t *= (guca[4] < 128 ? (double)gs.a[0] : t);
}
long rs_9_06_09_6(unsigned char a, unsigned long b, int c) {
	return (gla[c] + gl) * 2L;
}
void rs_9_06_10_0(unsigned int a, long *b) {
	double t = -gda[3];
	jd = t;
}
void rs_9_06_10_1(unsigned int a, long *b) {
	gs.p = gps->p + a;
}
void rs_9_06_10_2(unsigned int a, long *b) {
	a--;
}
void rs_9_06_10_3(unsigned int a, long *b) {
	++gl2;
}
void rs_9_06_10_4(unsigned int a, long *b) {
	gp = gp + a;
}
void rs_9_06_10_5(unsigned int a, long *b) {
	double t = jd;
	gd = t;
}
void rs_9_06_10_6(unsigned int a, long *b) {
	vs(gps);
}
long rs_9_06_10_7(unsigned int a, long *b) {
	return gps->l + (long)gula[7];
}
void rs_9_06_11_0(void) {
	gc2--;
}
void rs_9_06_11_1(void) {
	if (r0()) { guca[0] /= 16; }
}
int rs_9_06_11_2(void) {
	return r1(gi >> 3);
}
void rs_9_06_12_0(void) {
	long t = gs.l;
	jl = t;
}
void rs_9_06_12_1(void) {
	vs(gps);
}
void rs_9_06_12_2(void) {
	guc = (8 - 128) * (guc + 255);
}
void rs_9_06_12_3(void) {
	v2(gia[3] % 4, gi);
}
void rs_9_06_12_4(void) {
	long t = jl;
	v0();
	vl(t);
}
void rs_9_06_12_5(void) {
	guc ^= (unsigned char)gps->u;
}
char * rs_9_06_12_6(void) {
	return gp;
}
void rs_9_06_13_0(void) {
	int t = gi2 ^ gia[4];
	ji = t;
}
void rs_9_06_13_1(void) {
	gpl[0] = rl((long)guc - gl2);
}
void rs_9_06_13_2(void) {
	gs.l -= gl;
}
void rs_9_06_13_3(void) {
	*gpl -= gla[6];
}
void rs_9_06_13_4(void) {
	int t = ji;
	v0();
	switch (gps->i) { case 0: gda[1] = gd + 0.25; break; case 1: gd2 += 2.5; break; case 2: vs(gps); break; case 3: gla[2] = gpl[2] = (long)!gla[t]; break; case 4: v2((int)gla[t], gi); break; default: gp = gs.p; break; }
}
int rs_9_06_13_5(void) {
	return !218 ^ (gc2 < -43 ? gi : gi3);
}
void rs_9_06_14_0(void) {
	char *t = rp();
	jp = t;
}
void rs_9_06_14_1(void) {
	int u = gi2 - gi3;
	v0();
	ji = u;
}
void rs_9_06_14_2(void) {
	int u = ji;
	v0();
	gla[u] = gl + (long)*gpi;
}
void rs_9_06_14_3(void) {
	char *t = jp;
	v0();
	vp(t);
}
void rs_9_06_14_4(void) {
	gd = (1.0 + gs.d) / 2.5;
}
void rs_9_06_14_5(void) {
	int u = ji;
	v0();
	guca[u] = 128;
}
void rs_9_06_14_6(void) {
	while (gi > 0) { gc += *gp++; gi--; }
}
int rs_9_06_14_7(void) {
	return 1;
}
void rs_9_06_15_0(void) {
	gu = (unsigned int)(gul >= (9UL * 2UL));
}
void rs_9_06_15_1(void) {
	vd(gs.d + (double)gpi[3]);
}
void rs_9_06_15_2(void) {
	vc(6);
}
unsigned long rs_9_06_15_3(void) {
	return (unsigned long)(gc < (gc2 * *gp));
}
void rs_9_06_16_0(unsigned char a, long b) {
	char t = (char)!gu2;
	jc = t;
}
void rs_9_06_16_1(unsigned char a, long b) {
	long u = gs.l;
	jl = u;
}
void rs_9_06_16_2(unsigned char a, long b) {
	long u = jl;
	vl(u);
}
void rs_9_06_16_3(unsigned char a, long b) {
	a = guc = (128 * guca[3]) + (((unsigned char)gla[1]) << 2);
}
unsigned long rs_9_06_16_4(unsigned char a, long b) {
	if (*gp == '0') return ((unsigned long)guc) | gula[4];
}
void rs_9_06_16_5(unsigned char a, long b) {
	gc *= 7;
}
void rs_9_06_16_6(unsigned char a, long b) {
	a = 51;
}
void rs_9_06_16_7(unsigned char a, long b) {
	if (gc > 8) { b = (*gpl >> 4) ^ (4L + 65536L); }
}
void rs_9_06_16_8(unsigned char a, long b) {
	char t = jc;
	v0();
	vc(t);
}
unsigned long rs_9_06_16_9(unsigned char a, long b) {
	return (unsigned long)gu2;
}
void rs_9_06_17_1(unsigned char a, unsigned int b, unsigned char c) {
	int i = ji;
	for (i = 0; i < 3; i++) { vc(gp[0] * gps->c); }
}
void rs_9_06_17_2(unsigned char a, unsigned int b, unsigned char c) {
	if (gua[a] & 0x10) if (gl2 != 0) *gpl = 3387L / gl2;
}
char rs_9_06_17_3(unsigned char a, unsigned int b, unsigned char c) {
	return rc(gps->a[4]);
}
void rs_9_06_18_1(int a, char *b) {
	char *t = gps->p;
	jp = t;
}
void rs_9_06_18_2(int a, char *b) {
	guc += guca[4] - guc;
}
void rs_9_06_18_3(int a, char *b) {
	char *t = jp;
	if (gda[3] > gda[1]) t = t + a;
}
void rs_9_06_18_4(int a, char *b) {
	gd = -gs.d;
}
void rs_9_06_18_5(int a, char *b) {
	int i = ji;
	i = a; do { gpi = &gia[i]; if (gs.l != 0) gl2 = gla[i] / gs.l; } while (--i > 0);
}
void rs_9_06_18_6(int a, char *b) {
	int i = ji;
	for (i = 0; i < 16; i++) { gia[i] *= 9; if (gl != 0) gs.l = 7L / gl; }
}
char rs_9_06_18_7(int a, char *b) {
	return -69;
}
void rs_9_06_19_0(unsigned long a, unsigned long b, unsigned char c) {
	unsigned char t = ~guca[c];
	juc = t;
}
void rs_9_06_19_1(unsigned long a, unsigned long b, unsigned char c) {
	unsigned char t = juc;
	if (gp[3] & 0x10) { a = gul; gua[4] = gua[4] + gps->u; t = (guca[c] / 7) & (t % 10); }
}
void rs_9_06_19_2(unsigned long a, unsigned long b, unsigned char c) {
	gc2 = (-41 | *gp) % 10;
}
int * rs_9_06_19_3(unsigned long a, unsigned long b, unsigned char c) {
	return gpi;
}
void rs_9_07_00_0(char *a, int b, int c) {
	vd(gd);
}
void rs_9_07_00_1(char *a, int b, int c) {
	--gl;
}
int rs_9_07_00_2(char *a, int b, int c) {
	return gi3;
}
void rs_9_07_01_0(long *a, unsigned char b, int c) {
	int t = *gpi;
	ji = t;
}
void rs_9_07_01_1(long *a, unsigned char b, int c) {
	int u = gi << 9;
	ji = u;
}
void rs_9_07_01_2(long *a, unsigned char b, int c) {
	int u = ji;
	if (c) { a[3] >>= (c & 15); c ^= u << 15; --gu2; }
}
void rs_9_07_01_3(long *a, unsigned char b, int c) {
	vu(gu ^ 1);
}
void rs_9_07_01_4(long *a, unsigned char b, int c) {
	int t = ji;
	v0();
	gi = t;
}
int rs_9_07_01_5(long *a, unsigned char b, int c) {
	return *gpi / 4;
}
void rs_9_07_02_0(char a, int *b, int c) {
	vp(&gca[a]);
}
void rs_9_07_02_1(char a, int *b, int c) {
	gps->u = (gu % 4) - gua[a];
}
void rs_9_07_02_2(char a, int *b, int c) {
	gla[1] += gl;
}
void rs_9_07_02_3(char a, int *b, int c) {
	++gl;
}
void rs_9_07_03_1(struct st *a, int *b) {
	vs(a);
}
void rs_9_07_03_2(struct st *a, int *b) {
	guca[7] += guca[3];
}
void rs_9_07_03_3(struct st *a, int *b) {
	int i = ji;
	v0();
	i = 0; while (i < 15) { gd2 += (gs.i < gps->a[i] ? gd2 : 100.0); i++; }
}
void rs_9_07_03_4(struct st *a, int *b) {
	gd2 = gda[0] * gd2;
}
void rs_9_07_03_5(struct st *a, int *b) {
	int i = ji;
	v0();
	i = 0; while (i < 15) { vs(gps); gpi = rpi(i); if (gia[i] != 0) gpi[1] = i / gia[i]; i++; }
}
int rs_9_07_03_6(struct st *a, int *b) {
	return -(-611);
}
void rs_9_07_04_0(char a, long *b) {
	unsigned long t = gula[4];
	jul = t;
}
void rs_9_07_04_1(char a, long *b) {
	unsigned int u = gua[1];
	ju = u;
}
void rs_9_07_04_2(char a, long *b) {
	unsigned long t = jul;
	gps->a[7] = (gula[2] < t ? gi3 : gi3);
}
void rs_9_07_04_3(char a, long *b) {
	unsigned int u = ju;
	switch (gs.l) { case 0L: vd(gda[2]); break; case 1L: gl2 = gl; break; case 2L: case 3L: gi3 >>= (u & 15); break; case 4L: v1(gi3); break; }
}
void rs_9_07_04_4(char a, long *b) {
	unsigned long t = jul;
	unsigned int u = ju;
	v0();
	if (t && (gi3 = gia[7])) { gps->p = gp + u; gda[3] -= gda[2]; gla[1] = gl / 4L; } else { if (t != 0) gul = gula[a] % t; }
}
void rs_9_07_04_5(char a, long *b) {
	unsigned int u = ju;
	v0();
	u = gu;
}
unsigned int rs_9_07_04_6(char a, long *b) {
	return 32767;
}
void rs_9_07_05_1(char *a, unsigned long b, unsigned int c) {
	int i = ji;
	for (i = 4; i > 0; i--) { gda[0] = gd2 / 0.25; gia[i] = (int)b; }
}
void rs_9_07_05_2(char *a, unsigned long b, unsigned int c) {
	while (gi > 0) { gc2 += *a++; gi--; }
}
void rs_9_07_05_3(char *a, unsigned long b, unsigned int c) {
	guc = guca[2];
}
void rs_9_07_05_4(char *a, unsigned long b, unsigned int c) {
	gu += ru(255);
}
void rs_9_07_05_5(char *a, unsigned long b, unsigned int c) {
	gc = (char)(rul(gul) <= (((unsigned long)guc) - gul));
}
char rs_9_07_05_6(char *a, unsigned long b, unsigned int c) {
	return -(gca[4] * (char)*gpl);
}
void rs_9_07_06_0(long *a) {
	unsigned char t = guc;
	juc = t;
}
void rs_9_07_06_1(long *a) {
	double u = gs.d - (double)gi2;
	jd = u;
}
void rs_9_07_06_2(long *a) {
	unsigned char t = juc;
	if (gula[t] != 0) gul = gul % gula[t];
}
void rs_9_07_06_3(long *a) {
	double u = jd;
	vd(u);
}
void rs_9_07_06_4(long *a) {
	--gpi;
}
int rs_9_07_06_5(long *a) {
	return gps->a[4] % 2;
}
void rs_9_07_07_1(long a, char *b) {
	int i = ji;
	for (i = 0; i < 7; i++) { if (*gpl != 0) a = 79838L / *gpl; if (gl2 != 0) gl = gpl[1] / gl2; if (i != 0) gi = 8 / i; }
}
void rs_9_07_07_2(long a, char *b) {
	int i = ji;
	if (gi != 0) gs.i = 7 % gi;
}
int rs_9_07_07_3(long a, char *b) {
	return gps->a[3];
}
void rs_9_07_08_1(char a) {
	int t = gi3 + 100;
	ji = t;
}
void rs_9_07_08_2(char a) {
	unsigned char u = guc >> 5;
	juc = u;
}
void rs_9_07_08_3(char a) {
	gu2--;
}
void rs_9_07_08_4(char a) {
	gua[6] *= 12;
}
void rs_9_07_08_5(char a) {
	int t = ji;
	if (gul & 0x8) if (t != 0) gi3 = 6 % t;
}
void rs_9_07_08_6(char a) {
	int i = ji;
	i = 4; do { gul -= 0x10000UL; gps->c = gca[i] / 16; } while (--i > 0);
}
void rs_9_07_08_7(char a) {
	int t = ji;
	unsigned char u = juc;
	guca[t] = 128 ^ u;
}
char rs_9_07_08_8(char a) {
	return gp[3];
}
void rs_9_07_09_1(long *a) {
	unsigned char t = 9;
	juc = t;
}
void rs_9_07_09_2(long *a) {
	unsigned char t = juc;
	gla[t] = (long)(rc(gs.a[t]) == ('A' >> 6));
}
void rs_9_07_09_3(long *a) {
	unsigned char t = juc;
	v0();
	if (gi3 & 2) { gps->a[t] = gi2 = -(~1); vc('a'); }
}
void rs_9_07_09_4(long *a) {
	unsigned char t = juc;
	v0();
	guc = ~(t * guca[5]);
}
void rs_9_07_09_5(long *a) {
	int i = ji;
	v0();
	i = 4; do { gp[3] = gps->c * gps->c; } while (--i > 0);
}
void rs_9_07_09_6(long *a) {
	v2(100 + *gpi, gi);
}
unsigned long rs_9_07_09_7(long *a) {
	return (gul / 10UL) ^ (3UL ^ gul);
}
void rs_9_07_10_0(long *a) {
	long t = gla[3] << 27;
	jl = t;
}
void rs_9_07_10_1(long *a) {
	int u = *gpi - gi2;
	ji = u;
}
void rs_9_07_10_2(long *a) {
	guc = (guc | ((unsigned char)gi)) << 6;
}
void rs_9_07_10_3(long *a) {
	gs.c = gc2;
}
void rs_9_07_10_4(long *a) {
	gs.c <<= 6;
}
void rs_9_07_10_5(long *a) {
	*gpi = gi - 4;
}
void rs_9_07_10_6(long *a) {
	long t = jl;
	gl = t;
}
void rs_9_07_10_7(long *a) {
	int u = ji;
	v1(u);
}
int * rs_9_07_10_8(long *a) {
	int u = ji;
	v0();
	return gpi + u;
}
void rs_9_07_11_0(void) {
	switch (gi) { case 0: case 1: gua[4] |= 255; break; }
}
void rs_9_07_11_1(void) {
	gla[4] += gl2 - 68560L;
}
void rs_9_07_11_2(void) {
	gpi = gpi + 1;
}
void rs_9_07_11_3(void) {
	gua[2] = gua[1] + gu;
}
void rs_9_07_11_4(void) {
	gs.i = gi;
}
unsigned int rs_9_07_11_5(void) {
	return -((unsigned int)gs.c);
}
void rs_9_07_12_0(char a, int *b, char c) {
	unsigned char t = guc;
	juc = t;
}
void rs_9_07_12_1(char a, int *b, char c) {
	double u = gda[3];
	jd = u;
}
void rs_9_07_12_2(char a, int *b, char c) {
	unsigned char t = juc;
	if (gul & 0x80) { gpl[2] = gla[c]; t = (gps->l < gpl[0] ? t : 169); if (gpl[0] != 0) gl = gl2 % gpl[0]; } else { gia[6] >>= 8; if (gs.c != 0) c = gs.c / gs.c; t = ~128 ^ ((unsigned char)(gpl[3] == gla[1])); }
}
void rs_9_07_12_3(char a, int *b, char c) {
	unsigned char t = juc;
	gula[t] = (((unsigned long)gi3) + gula[a]) - (gula[0] - gul);
}
void rs_9_07_12_4(char a, int *b, char c) {
	gps->a[2] = ((long)gca[6] > -28075L ? gi2 : gi);
}
void rs_9_07_12_5(char a, int *b, char c) {
	double u = jd;
	gd = u;
}
void rs_9_07_12_6(char a, int *b, char c) {
	gula[a] = gul = 0UL;
}
char rs_9_07_12_7(char a, int *b, char c) {
	return (0 % 2) + (-64 * gc2);
}
void rs_9_07_13_0(unsigned char a, int b) {
	char t = *gp;
	jc = t;
}
void rs_9_07_13_1(unsigned char a, int b) {
	char t = jc;
	double u = (t <= 1 ? gd2 : gs.d);
	jd = u;
}
void rs_9_07_13_2(unsigned char a, int b) {
	char t = jc;
	double u = jd;
	u -= (t & 0x10 ? u : gd);
}
void rs_9_07_13_3(unsigned char a, int b) {
	if (4 < 213) { gla[a] = 0L - gl; gps->a[7] = (gl <= 65536L); if (gul != 0) gula[b] = gula[2] % gul; } else { gs.l -= gl; vc(-gs.c); }
}
void rs_9_07_13_4(unsigned char a, int b) {
	vu(256 ^ gua[2]);
}
unsigned long rs_9_07_13_5(unsigned char a, int b) {
	return (gula[2] = 0x10000UL);
}
void rs_9_07_14_1(double a, double b, int c) {
	int t = r2(gps->a[c], gi);
	ji = t;
}
void rs_9_07_14_2(double a, double b, int c) {
	int i = ji;
	v0();
	if (gps->i) gp = rp();
}
void rs_9_07_14_3(double a, double b, int c) {
	int i = ji;
	int t = ji;
	v0();
	for (i = 0; i < c; i++) { gs.d = (t ? b : gd); gula[i] = (128 <= guc ? gul : gul); gu -= gs.u; }
}
void rs_9_07_14_4(double a, double b, int c) {
	gi2 *= 2;
}
void rs_9_07_14_5(double a, double b, int c) {
	v2(gi2, (gps->l == gl));
}
void rs_9_07_15_0(int a, int b, unsigned char c) {
	int t = r2(gi2, gps->a[5]);
	ji = t;
}
void rs_9_07_15_1(int a, int b, unsigned char c) {
	unsigned long u = gul;
	v0();
	jul = u;
}
void rs_9_07_15_2(int a, int b, unsigned char c) {
	int t = ji;
	v0();
	gi = (gi2 - t) - gia[1];
}
void rs_9_07_15_3(int a, int b, unsigned char c) {
	gl2 += rl(gl);
}
void rs_9_07_15_4(int a, int b, unsigned char c) {
	c = guc = (guc + c) * (c * guca[2]);
}
void rs_9_07_15_5(int a, int b, unsigned char c) {
	unsigned long u = jul;
	v0();
	vl((long)u);
}
unsigned int rs_9_07_15_6(int a, int b, unsigned char c) {
	unsigned long u = jul;
	v0();
	return -gs.u;
}
void rs_9_07_16_0(int a) {
	char *t = gp;
	jp = t;
}
void rs_9_07_16_1(int a) {
	double u = 0.5;
	jd = u;
}
void rs_9_07_16_2(int a) {
	if (gps->i != 0) gi = (int)gua[a] / gps->i;
}
void rs_9_07_16_3(int a) {
	gla[4] = gl2 + gl;
}
void rs_9_07_16_4(int a) {
	double u = jd;
	gd = u;
}
void rs_9_07_16_5(int a) {
	char *t = jp;
	vp(t);
}
void rs_9_07_16_6(int a) {
	gi += a;
}
long rs_9_07_16_7(int a) {
	return (long)!gp[2] & gl;
}
void rs_9_07_17_1(unsigned char a, char b, int c) {
	int *t = gpi;
	jpi = t;
}
void rs_9_07_17_2(unsigned char a, char b, int c) {
	int *u = rpi(gpi[0]);
	jpi = u;
}
void rs_9_07_17_3(unsigned char a, char b, int c) {
	a--;
}
void rs_9_07_17_4(unsigned char a, char b, int c) {
	int i = ji;
	v0();
	i = 8; do { if (gp[0] != 0) b = gc / gp[0]; if (gul != 0) gula[i] = gula[i] % gul; gul = ~(gula[i] & 3224UL); } while (--i > 0);
}
void rs_9_07_17_5(unsigned char a, char b, int c) {
	int *u = jpi;
	v0();
	gpi = u;
}
void rs_9_07_17_6(unsigned char a, char b, int c) {
	gla[3] = gl = (long)(gu2 * 3);
}
void rs_9_07_17_7(unsigned char a, char b, int c) {
	gula[5] %= 16UL;
}
void rs_9_07_17_8(unsigned char a, char b, int c) {
	int *t = jpi;
	v0();
	gpi = t;
}
int * rs_9_07_17_9(unsigned char a, char b, int c) {
	return &gia[2];
}
void rs_9_07_18_0(long *a, char *b, long c) {
	double t = gda[0] + 2.5;
	jd = t;
}
void rs_9_07_18_1(long *a, char *b, long c) {
	unsigned int u = gua[6];
	ju = u;
}
void rs_9_07_18_2(long *a, char *b, long c) {
	double t = jd;
	vd(t);
}
void rs_9_07_18_3(long *a, char *b, long c) {
	guc = ~guc;
}
void rs_9_07_18_4(long *a, char *b, long c) {
	unsigned int u = ju;
	v0();
	vc((char)guca[u]);
}
void rs_9_07_19_0(unsigned long a, unsigned int b, char c) {
	switch (gl2) { case 5L: gd2 = gs.d / 3.0; break; case 10L: case 16L: gi2 = gs.i; break; case 20L: *gpl = gla[c]; break; case 1000L: vs(gps); break; }
}
void rs_9_07_19_1(unsigned long a, unsigned int b, char c) {
	gpi = gpi + b;
}
int rs_9_07_19_2(unsigned long a, unsigned int b, char c) {
	return gia[0];
}
void rs_9_08_00_0(long a, double b) {
	int *t = gpi;
	jpi = t;
}
void rs_9_08_00_1(long a, double b) {
	gs.i ^= (int)gs.u - gia[2];
}
void rs_9_08_00_2(long a, double b) {
	int *t = jpi;
	gpi = t;
}
void rs_9_08_00_3(long a, double b) {
	gia[2] = gi2;
}
void rs_9_08_00_4(long a, double b) {
	gu++;
}
void rs_9_08_00_5(long a, double b) {
	gul >>= 11;
}
char rs_9_08_00_6(long a, double b) {
	return ((char)gs.u ^ gp[2]) / 16;
}
void rs_9_08_01_0(unsigned char a) {
	double t = gd2;
	jd = t;
}
void rs_9_08_01_1(unsigned char a) {
	double u = -gda[0];
	jd = u;
}
void rs_9_08_01_2(unsigned char a) {
	if (gul != 0) gula[a] = gula[3] % gul;
}
void rs_9_08_01_3(unsigned char a) {
	double t = jd;
	double u = jd;
	gda[0] = (gps->i > 8 ? (255 < 1 ? gd2 : t) : (gu ? gd2 : u));
}
void rs_9_08_02_0(unsigned char a, char *b, unsigned char c) {
	int *t = gpi;
	jpi = t;
}
void rs_9_08_02_1(unsigned char a, char *b, unsigned char c) {
	char u = (gi > 1 ? (' ') : gs.c);
	jc = u;
}
void rs_9_08_02_2(unsigned char a, char *b, unsigned char c) {
	int *t = jpi;
	char u = jc;
	t = t + u;
}
void rs_9_08_02_3(unsigned char a, char *b, unsigned char c) {
	gc = (char)!gs.c % 100;
}
void rs_9_08_02_4(unsigned char a, char *b, unsigned char c) {
	gl -= gl | gpl[2];
}
int rs_9_08_02_5(unsigned char a, char *b, unsigned char c) {
	return (gi2 = gps->i);
}
void rs_9_08_03_0(void) {
	long t = gpl[2] ^ 65536L;
	jl = t;
}
void rs_9_08_03_1(void) {
	--gi;
}
void rs_9_08_03_2(void) {
	--gul;
}
void rs_9_08_03_3(void) {
	long t = jl;
	vl(t);
}
void rs_9_08_03_4(void) {
	vl(rl((long)gs.i));
}
void rs_9_08_03_5(void) {
	gula[2] = gul + gula[1];
}
void rs_9_08_03_6(void) {
	if ((gu2 = gps->u)) { if (gi2 != 0) *gpi = gi3 % gi2; if (*gpl != 0) gpl[1] = -67665L / *gpl; } else { gul = gula[1]; if (gps->c != 0) gca[2] = gps->c / gps->c; }
}
int rs_9_08_03_7(void) {
	return gi3 * (*gpi == gi);
}
void rs_9_08_04_1(void) {
	unsigned int t = (unsigned int)(3.0 < gd);
	ju = t;
}
void rs_9_08_04_2(void) {
	char *u = &gca[5];
	jp = u;
}
void rs_9_08_04_3(void) {
	int i = ji;
	char *u = jp;
	i = 0; while (i < 12) { vp(u + i); if (gul != 0) gul = gula[i] / gul; gl = (long)!(184 >> 6); i++; }
}
void rs_9_08_04_4(void) {
	unsigned int t = ju;
	char *u = jp;
	v0();
	gi3 = ((u[0] << (t & 7)) < gs.c);
}
void rs_9_08_04_5(void) {
	vs(gps);
}
int rs_9_08_04_6(void) {
	return -*gpi;
}
void rs_9_08_05_0(void) {
	int t = (int)gula[7];
	ji = t;
}
void rs_9_08_05_1(void) {
	int t = ji;
	long u = (long)(gua[t] != ((unsigned int)gula[7]));
	jl = u;
}
void rs_9_08_05_2(void) {
	long u = jl;
	vu(gps->u - ((unsigned int)gul));
}
void rs_9_08_05_3(void) {
	gul = ~gul;
}
void rs_9_08_05_4(void) {
	int t = ji;
	v0();
	switch (gs.c) { case 0: gi3 <<= 12; break; case 1: vd(gda[3]); break; case 2: gua[t] -= 255; break; case 3: guca[3] += 255; break; }
}
void rs_9_08_05_5(void) {
	--guc;
}
int rs_9_08_05_6(void) {
	int t = ji;
	v0();
	return (t = 5);
}
void rs_9_08_06_0(char a, struct st *b) {
	unsigned long t = gula[a] >> 15;
	jul = t;
}
void rs_9_08_06_1(char a, struct st *b) {
	if (gc) if (gs.i != 0) gps->a[0] = 100 % gs.i;
}
void rs_9_08_06_2(char a, struct st *b) {
	unsigned long t = jul;
	vl((long)t);
}
void rs_9_08_06_3(char a, struct st *b) {
	gu = gu2 = (gu2 ^ 256) ^ ~gua[a];
}
int rs_9_08_06_4(char a, struct st *b) {
	return gi3;
}
unsigned int rs_9_08_07_0(unsigned char a) {
	if (gs.c) return (unsigned int)!gpi[3];
}
void rs_9_08_07_1(unsigned char a) {
	guc = a = (unsigned char)!((char)gps->i - '0');
}
void rs_9_08_07_2(unsigned char a) {
	gu2 = (unsigned int)((gla[7] * 4L) >= 9L);
}
unsigned int rs_9_08_07_3(unsigned char a) {
	return gua[a];
}
void rs_9_08_08_0(unsigned long a) {
	char *t = gp;
	jp = t;
}
void rs_9_08_08_1(unsigned long a) {
	long u = gla[4];
	jl = u;
}
void rs_9_08_08_2(unsigned long a) {
	long u = jl;
	vl(u);
}
void rs_9_08_08_3(unsigned long a) {
	gc ^= -85 + gps->c;
}
void rs_9_08_08_4(unsigned long a) {
	char *t = jp;
	v0();
	vp(t);
}
void rs_9_08_08_5(unsigned long a) {
	gi2 = gi3;
}
void rs_9_08_08_6(unsigned long a) {
	gul = -((unsigned long)(255 <= gps->i));
}
void rs_9_08_08_7(unsigned long a) {
	gd -= gs.d + gd;
}
char rs_9_08_08_8(unsigned long a) {
	return gps->c;
}
void rs_9_08_09_0(double a) {
	unsigned int t = (unsigned int)gps->c;
	ju = t;
}
void rs_9_08_09_1(double a) {
	unsigned int t = ju;
	char *u = &gca[t];
	jp = u;
}
void rs_9_08_09_2(double a) {
	gda[2] = 0.5 * a;
}
void rs_9_08_09_3(double a) {
	unsigned int t = ju;
	gu = t;
}
void rs_9_08_09_4(double a) {
	char *u = jp;
	gp = u;
}
void rs_9_08_09_5(double a) {
	vs(gps);
}
char rs_9_08_09_6(double a) {
	return rc(gi2) | gs.c;
}
void rs_9_08_10_0(unsigned int a, char *b) {
	int t = 8 + gi3;
	ji = t;
}
void rs_9_08_10_1(unsigned int a, char *b) {
	unsigned long u = gula[6] | 9UL;
	jul = u;
}
void rs_9_08_10_2(unsigned int a, char *b) {
	int t = ji;
	switch (t) { case 0: case 1: gca[a] = gc = -53 - 9; break; }
}
void rs_9_08_10_3(unsigned int a, char *b) {
	int t = ji;
	b[1] <<= (t & 7);
}
void rs_9_08_10_4(unsigned int a, char *b) {
	gs.l += 2L;
}
void rs_9_08_10_5(unsigned int a, char *b) {
	int t = ji;
	switch (gs.i) { case 2: vd(gd); break; case 16: case 20: t = t + 4; break; case 200: vl(gl2); break; case 1000: guc /= 10; break; default: v1(t); break; }
}
void rs_9_08_10_6(unsigned int a, char *b) {
	int t = ji;
	unsigned long u = jul;
	v0();
	if (!b[2]) { gul = u; if (t != 0) t = t / t; --gp; }
}
int rs_9_08_10_7(unsigned int a, char *b) {
	return !(~guc);
}
void rs_9_08_11_0(void) {
	int t = gi + gpi[3];
	ji = t;
}
void rs_9_08_11_1(void) {
	int *u = gpi;
	jpi = u;
}
void rs_9_08_11_2(void) {
	int t = ji;
	if (*gp <= gp[0]) gula[t] += gul / 10UL;
}
void rs_9_08_11_3(void) {
	--gl2;
}
void rs_9_08_11_4(void) {
	int t = ji;
	int *u = jpi;
	if (r2(gi2, gpi[3])) { gca[t] -= gc2 ^ (char)gs.u; gpi = u + t; }
}
void rs_9_08_11_5(void) {
	gula[5] = (unsigned long)gs.c;
}
unsigned int rs_9_08_11_6(void) {
	int t = ji;
	int *u = jpi;
	v0();
	return (gu2 + gua[7]) - (gs.u + gua[t]);
}
void rs_9_08_12_0(int a, unsigned char b, unsigned long c) {
	double t = gd2 + (double)gps->l;
	jd = t;
}
void rs_9_08_12_1(int a, unsigned char b, unsigned long c) {
	unsigned long u = gula[a] + gula[1];
	jul = u;
}
void rs_9_08_12_2(int a, unsigned char b, unsigned long c) {
	if ((gps->a[b] = gps->a[5])) gs.a[b] <<= (a & 15);
}
void rs_9_08_12_3(int a, unsigned char b, unsigned long c) {
	gl2 = *gpl << 13;
}
void rs_9_08_12_4(int a, unsigned char b, unsigned long c) {
	unsigned long u = jul;
	vl((long)u);
}
void rs_9_08_12_5(int a, unsigned char b, unsigned long c) {
	double t = jd;
	v0();
	gd = t;
}
int * rs_9_08_12_6(int a, unsigned char b, unsigned long c) {
	return gpi;
}
void rs_9_08_13_0(unsigned char a, long *b, double c) {
	unsigned char t = a;
	juc = t;
}
void rs_9_08_13_1(unsigned char a, long *b, double c) {
	unsigned char t = juc;
	char *u = gp + t;
	jp = u;
}
void rs_9_08_13_2(unsigned char a, long *b, double c) {
	gs.i &= 8 % 4;
}
void rs_9_08_13_3(unsigned char a, long *b, double c) {
	--gp;
}
void rs_9_08_13_4(unsigned char a, long *b, double c) {
	unsigned char t = juc;
	v1(t);
}
void rs_9_08_13_5(unsigned char a, long *b, double c) {
	char *u = jp;
	v0();
	vp(u);
}
unsigned int rs_9_08_13_6(unsigned char a, long *b, double c) {
	char *u = jp;
	v0();
	return (gps->u / 2) + ((unsigned int)(gula[7] > 0x10000UL));
}
void rs_9_08_14_0(char a, int b) {
	if (gula[b] != 0) gula[b] = gul % gula[b];
}
void rs_9_08_14_1(char a, int b) {
	vu(gu2);
}
int rs_9_08_14_2(char a, int b) {
	return b;
}
void rs_9_08_15_0(char a) {
	char t = 77;
	jc = t;
}
void rs_9_08_15_1(char a) {
	double u = -gda[3];
	jd = u;
}
void rs_9_08_15_2(char a) {
	double u = jd;
	gd = u;
}
void rs_9_08_15_3(char a) {
	gpi = gpi + a;
}
void rs_9_08_15_4(char a) {
	gl <<= (a & 15);
}
void rs_9_08_15_5(char a) {
	char t = jc;
	vc(t);
}
char * rs_9_08_15_6(char a) {
	return rp();
}
void rs_9_08_16_0(void) {
	char t = gca[0];
	jc = t;
}
void rs_9_08_16_1(void) {
	char t = jc;
	int u = gs.a[t];
	ji = u;
}
void rs_9_08_16_2(void) {
	int u = ji;
	v1(u);
}
void rs_9_08_16_3(void) {
	char t = jc;
	v0();
	t /= 16;
}
void rs_9_08_16_4(void) {
	gula[2] = (gul ^ 49764UL) ^ ~gul;
}
void rs_9_08_16_5(void) {
	gl2 &= -16445L;
}
void rs_9_08_16_6(void) {
	char t = jc;
	v0();
	vc((gi ? t : gc2));
}
void rs_9_08_16_7(void) {
	++gpi;
}
char * rs_9_08_16_8(void) {
	char t = jc;
	v0();
	return gps->p + t;
}
void rs_9_08_17_0(char a, int b) {
	gps->l -= (long)(0x10000UL >= gul);
}
void rs_9_08_17_1(char a, int b) {
	gs.a[3] *= 5;
}
unsigned int rs_9_08_17_2(char a, int b) {
	if (guca[3] > 3 || gul != gula[b]) return gua[b] >> 9;
}
void rs_9_08_17_3(char a, int b) {
	gs.c = '0';
}
unsigned int rs_9_08_17_4(char a, int b) {
	return ~gu2 - ((unsigned int)!gula[7]);
}
void rs_9_08_18_0(unsigned char a, long b, unsigned char c) {
	gl -= b;
}
void rs_9_08_18_1(unsigned char a, long b, unsigned char c) {
	--gpi;
}
void rs_9_08_18_2(unsigned char a, long b, unsigned char c) {
	guc = (guca[7] % 3) | guca[2];
}
int rs_9_08_18_3(unsigned char a, long b, unsigned char c) {
	return 127;
}
void rs_9_08_19_1(int a, long b, int c) {
	long t = -gla[c];
	jl = t;
}
void rs_9_08_19_2(int a, long b, int c) {
	unsigned long u = gula[c] - gula[a];
	jul = u;
}
void rs_9_08_19_3(int a, long b, int c) {
	unsigned long u = jul;
	gul = u;
}
void rs_9_08_19_4(int a, long b, int c) {
	int i = ji;
	long t = jl;
	for (i = 0; i < 12; i++) { if (gpl[2] != 0) *gpl = 65536L / gpl[2]; gl = gla[i] = t / 10L; }
}
void rs_9_08_19_5(int a, long b, int c) {
	if (gca[c]) guca[3] |= (unsigned char)(5UL != 0x10000UL);
}
void rs_9_08_19_6(int a, long b, int c) {
	v2(-gs.a[a], gi);
}
long rs_9_08_19_7(int a, long b, int c) {
	return 0L;
}
void rs_9_09_00_0(unsigned char a, double b, unsigned int c) {
	*gp = -44;
}
void rs_9_09_00_1(unsigned char a, double b, unsigned int c) {
	if (255 < 4) a = guca[a];
}
unsigned int rs_9_09_00_2(unsigned char a, double b, unsigned int c) {
	return c;
}
void rs_9_09_01_0(int *a) {
	++gul;
}
void rs_9_09_01_1(int *a) {
	a = gpi;
}
void rs_9_09_01_2(int *a) {
	++gc2;
}
void rs_9_09_01_3(int *a) {
	switch (gl2) { case 1L: guc &= guca[5]; break; case 10L: v1(gia[5]); break; case 100L: gc2 >>= 3; case 200L: vd(gd2); }
}
void rs_9_09_01_4(int *a) {
	--gul;
}
unsigned int rs_9_09_01_5(int *a) {
	return gu;
}
void rs_9_09_02_1(int a, int b) {
	gua[6] += 255 + gs.u;
}
void rs_9_09_02_2(int a, int b) {
	int i = ji;
	for (i = 0; i < a; i++) { if (gula[1] != 0) gul = gula[i] % gula[1]; }
}
char rs_9_09_02_3(int a, int b) {
	return (gp[2] % 4) + (gc + 8);
}
void rs_9_09_03_0(unsigned long a, unsigned long b, long c) {
	unsigned int t = gua[5];
	ju = t;
}
void rs_9_09_03_1(unsigned long a, unsigned long b, long c) {
	gpl[0] /= 10L;
}
void rs_9_09_03_2(unsigned long a, unsigned long b, long c) {
	gi2--;
}
void rs_9_09_03_3(unsigned long a, unsigned long b, long c) {
	unsigned int t = ju;
	if (guc == 128) v1(!guca[t]);
}
void rs_9_09_03_4(unsigned long a, unsigned long b, long c) {
	gp[0] = gc = gca[1] + gs.c;
}
int rs_9_09_03_5(unsigned long a, unsigned long b, long c) {
	return r2(gi2, gi3);
}
void rs_9_09_04_1(void) {
	gps->l = gs.l + gla[4];
}
void rs_9_09_04_2(void) {
	int i = ji;
	for (i = 13; i > 0; i--) { gd2 = gs.d; gs.a[i] = gia[i] / 2; gd = ((' ') != *gp ? (gd * gs.d) : (gd / 0.5)); }
}
void rs_9_09_04_3(void) {
	v2(~gi, gi);
}
long rs_9_09_04_4(void) {
	return 28237L;
}
void rs_9_09_05_0(unsigned long a) {
	char *t = gs.p;
	jp = t;
}
void rs_9_09_05_1(unsigned long a) {
	gul = gula[3];
}
void rs_9_09_05_2(unsigned long a) {
	gla[0] = rl(gpl[1]);
}
void rs_9_09_05_3(unsigned long a) {
	char *t = jp;
	v0();
	gp = t;
}
long rs_9_09_05_4(unsigned long a) {
	return (long)(18806 <= (((unsigned int)gp[1]) - gu));
}
void rs_9_09_06_0(double a, unsigned int b, double c) {
	v2(gi2, gi2 | gps->i);
}
void rs_9_09_06_1(double a, unsigned int b, double c) {
	gpi++;
}
void rs_9_09_06_2(double a, unsigned int b, double c) {
	switch (gi) { case 3: gl += *gpl; break; case 5: guca[b] <<= 2; break; case 10: case 20: v1((int)gps->u); case 100: gpi = rpi((int)gul); break; }
}
void rs_9_09_06_3(double a, unsigned int b, double c) {
	gpl[3] += 65536L / 4L;
}
void rs_9_09_06_4(double a, unsigned int b, double c) {
	gla[b] -= (long)gul + gl;
}
int rs_9_09_06_5(double a, unsigned int b, double c) {
	return (int)*gpl | gi;
}
void rs_9_09_07_0(char *a, long b) {
	char t = rc(gi3);
	jc = t;
}
void rs_9_09_07_1(char *a, long b) {
	unsigned int u = gu2;
	v0();
	ju = u;
}
void rs_9_09_07_2(char *a, long b) {
	++gp;
}
void rs_9_09_07_3(char *a, long b) {
	unsigned int u = ju;
	v0();
	if (guc < 128) gla[u] = gl + gla[u];
}
void rs_9_09_07_4(char *a, long b) {
	gula[5] = rul(gul | 75625UL);
}
void rs_9_09_07_5(char *a, long b) {
	char t = jc;
	v0();
	if (t != 0) a[6] = gc / t;
}
void rs_9_09_08_1(struct st *a, int b) {
	gpi = &gia[b];
}
void rs_9_09_08_2(struct st *a, int b) {
	int i = ji;
	for (i = 0; i < 16; i++) { if (gps->l != 0) gl = gl2 % gps->l; }
}
int rs_9_09_08_3(struct st *a, int b) {
	int i = ji;
	return (guc ? (gul > 11960UL) : ~a->i);
}
void rs_9_09_09_1(unsigned long a, unsigned int b) {
	double t = gd2 / 0.25;
	jd = t;
}
void rs_9_09_09_2(unsigned long a, unsigned int b) {
	unsigned int u = 615;
	ju = u;
}
void rs_9_09_09_3(unsigned long a, unsigned int b) {
	int i = ji;
	unsigned int u = ju;
	if (256 == 1 && 0x10000UL != ((unsigned long)u)) { gps->a[6] = (gua[2] ? (gps->a[5] + gps->i) : r2(gi2, *gpi)); }
}
void rs_9_09_09_4(unsigned long a, unsigned int b) {
	double t = jd;
	v0();
	vd(t);
}
void rs_9_09_09_5(unsigned long a, unsigned int b) {
	gp = &gca[7];
}
void rs_9_09_09_6(unsigned long a, unsigned int b) {
	v1(gi2);
}
void rs_9_09_09_7(unsigned long a, unsigned int b) {
	int i = ji;
	unsigned int u = ju;
	v0();
	i = 16; do { u = (gua[i] << 13) ^ 32767; gc2 = rc(255 << 14); } while (--i > 0);
}
long rs_9_09_09_8(unsigned long a, unsigned int b) {
	return -(long)!b;
}
void rs_9_09_10_0(double a, long b) {
	unsigned long t = gula[7] ^ gula[5];
	jul = t;
}
void rs_9_09_10_1(double a, long b) {
	if (gu2 != gu && gps->a[2] == (int)*gp) { gl = -66097L; gc2 /= 2; gl = gl2; } else { vu(ru(gu2)); if (b != 0) gpl[1] = gla[0] % b; gs.u ^= (unsigned int)guca[2]; }
}
void rs_9_09_10_2(double a, long b) {
	gpi = rpi((8UL != gul ? gi3 : gi3));
}
void rs_9_09_10_3(double a, long b) {
	unsigned long t = jul;
	v0();
	if (gps->u > 3 || gu2 <= gps->u) t = (t | gul) >> 3;
}
void rs_9_09_10_4(double a, long b) {
	gu -= 15565;
}
void rs_9_09_10_5(double a, long b) {
	unsigned long t = jul;
	v0();
	if (!guca[4]) { gi2 += ~gps->i; guc = guca[4]; t = (((unsigned long)*gp) - gula[7]) / 7UL; } else { gi2 = gps->i; }
}
long rs_9_09_10_6(double a, long b) {
	return 32099L - gs.l;
}
void rs_9_09_11_1(long *a, struct st *b) {
	int i = ji;
	i = 8; do { if (gula[i] != 0) gul = gula[i] / gula[i]; v2(127 * (int)gua[i], gi); if (gi3 != 0) gi3 = b->a[i] % gi3; } while (--i > 0);
}
void rs_9_09_11_2(long *a, struct st *b) {
	if (gu2 >= gu) { if (gc != 0) *gp = 1 % gc; gi3 = r0() - (gi3 + 950); } else { if (gl != 0) *a = 83938L % gl; gc2 = *gp = -(*gp + '0'); if (gl != 0) gl2 = *gpl % gl; }
}
void rs_9_09_11_3(long *a, struct st *b) {
	guc = guca[0];
}
void rs_9_09_11_4(long *a, struct st *b) {
	int i = ji;
	v0();
	for (i = 14; i > 0; i--) { if (gul != 0) gula[i] = gul / gul; if (gu != 0) gu2 = gua[6] / gu; gd *= (i ? 0.25 : gd2); }
}
int rs_9_09_11_5(long *a, struct st *b) {
	return b->a[2] / 4;
}
void rs_9_09_12_0(void) {
	guca[3] += guca[2] % 7;
}
void rs_9_09_12_1(void) {
	v0();
}
int rs_9_09_12_2(void) {
	return gi3 % 100;
}
void rs_9_09_13_0(void) {
	int t = 8;
	ji = t;
}
void rs_9_09_13_1(void) {
	int t = ji;
	if (gia[t]) { ++gul; vs(gps); v0(); } else { vu((unsigned int)!gu); if (gi3 != 0) gi = *gpi / gi3; gps->l += -45986L & (long)guca[t]; }
}
void rs_9_09_13_2(void) {
	vl(gps->l - gl);
}
int rs_9_09_13_3(void) {
	return (int)(1 + gu);
}
void rs_9_09_14_0(void) {
	int *t = gpi + 1;
	jpi = t;
}
void rs_9_09_14_1(void) {
	int u = r0();
	ji = u;
}
void rs_9_09_14_2(void) {
	while (gi > 0) { gc2 += *gp++; gi--; }
}
void rs_9_09_14_3(void) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_9_09_14_4(void) {
	if (gs.c != 0) gc2 = 3 / gs.c;
}
void rs_9_09_14_5(void) {
	int u = ji;
	v0();
	v1(u);
}
int * rs_9_09_14_6(void) {
	int *t = jpi;
	v0();
	return t;
}
void rs_9_09_15_0(unsigned int a, char b, long c) {
	double t = gda[3];
	jd = t;
}
void rs_9_09_15_1(unsigned int a, char b, long c) {
	char u = gc;
	jc = u;
}
void rs_9_09_15_2(unsigned int a, char b, long c) {
	gi = (gs.i - gi) % 100;
}
void rs_9_09_15_3(unsigned int a, char b, long c) {
	double t = jd;
	vd(t);
}
void rs_9_09_15_4(unsigned int a, char b, long c) {
	char u = jc;
	v0();
	vc(u);
}
void rs_9_09_15_5(unsigned int a, char b, long c) {
	gps->p = &gca[0];
}
long rs_9_09_15_6(unsigned int a, char b, long c) {
	return gpl[2];
}
void rs_9_09_16_1(char a) {
	unsigned int t = gu2;
	ju = t;
}
void rs_9_09_16_2(char a) {
	char u = rc(100);
	jc = u;
}
void rs_9_09_16_3(char a) {
	if (gpl[0] != 0) gps->l = gla[7] % gpl[0];
}
void rs_9_09_16_4(char a) {
	int i = ji;
	v0();
	for (i = 0; i < 7; i++) { gd = (gca[i] != 6 ? -10.0 : (gs.a[i] & 0x7 ? gd : gd2)); }
}
void rs_9_09_16_5(char a) {
	unsigned int t = ju;
	v0();
	if ((a = 8)) *gpi = (int)t - gi;
}
void rs_9_09_16_6(char a) {
	char u = jc;
	v0();
	gc = u;
}
void rs_9_09_16_7(char a) {
	int i = ji;
	unsigned int t = ju;
	v0();
	if (gi3 < gps->i) guc = guca[t] * ~guc;
}
void rs_9_09_17_0(long a, char *b) {
	if (!gu) { guca[3] = (unsigned char)!gla[2]; gl--; guc = 255; }
}
void rs_9_09_17_1(long a, char *b) {
	if (gu != 0) gps->u = gua[4] % gu;
}
unsigned int rs_9_09_17_2(long a, char *b) {
	return gua[5];
}
void rs_9_09_18_0(long a, char b) {
	int *t = gpi;
	jpi = t;
}
void rs_9_09_18_1(long a, char b) {
	v2(gi2, 16);
}
void rs_9_09_18_2(long a, char b) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_9_09_18_3(long a, char b) {
	guc -= 60 - 145;
}
int rs_9_09_18_4(long a, char b) {
	return (*gpi = 127);
}
void rs_9_09_19_0(void) {
	char *t = gp + 1;
	jp = t;
}
void rs_9_09_19_1(void) {
	unsigned char u = guc;
	juc = u;
}
void rs_9_09_19_2(void) {
	unsigned char u = juc;
	guca[4] = u * (u * u);
}
void rs_9_09_19_3(void) {
	gi2 |= gi2 - 1;
}
void rs_9_09_19_4(void) {
	char *t = jp;
	vp(t);
}
char * rs_9_09_19_5(void) {
	return gp;
}
