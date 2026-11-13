/* Every statement line of random3 alone in its own function (gen_rstmt.py corpus/random3 3): rs_<A>_<BB>_<CC>_<k> is line k of
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

void rs_3_00_00_0(void) {
	double t = gs.d;
	jd = t;
}
void rs_3_00_00_1(void) {
	unsigned char u = 11 - guca[1];
	juc = u;
}
void rs_3_00_00_2(void) {
	gu2--;
}
void rs_3_00_00_3(void) {
	double t = jd;
	vd(t);
}
void rs_3_00_00_4(void) {
	unsigned char u = juc;
	v0();
	if (r2(gi, gi)) gu = gs.u = ((unsigned int)gla[u]) - (255 & gu);
}
void rs_3_00_01_1(void) {
	unsigned char t = guc % 7;
	juc = t;
}
void rs_3_00_01_2(void) {
	unsigned char t = juc;
	t = (t * 255) % 3;
}
void rs_3_00_01_3(void) {
	int i = ji;
	unsigned char t = juc;
	i = 0; while (i < 10) { t = (0 - 128) + (t - 5); i++; }
}
void rs_3_00_01_4(void) {
	unsigned char t = juc;
	if (gi >= gpi[0]) { gpi = gpi + t; if (gs.u != 0) gu2 = gua[1] % gs.u; }
}
void rs_3_00_01_5(void) {
	unsigned char t = juc;
	if (r2(gi2, gps->a[t])) if (gs.a[t] != 0) gpi[1] = 2 % gs.a[t];
}
int rs_3_00_01_6(void) {
	return (gi3 ^ 1) * 4;
}
void rs_3_00_02_0(long a) {
	unsigned int t = (unsigned int)(gula[6] != gula[1]);
	ju = t;
}
void rs_3_00_02_1(long a) {
	vs(gps);
}
void rs_3_00_02_2(long a) {
	unsigned int t = ju;
	v0();
	gs.l = gla[t] = ~rl(65536L);
}
void rs_3_00_02_3(long a) {
	gps->a[7] = *gpi * 3;
}
int * rs_3_00_02_4(long a) {
	unsigned int t = ju;
	v0();
	return &gia[t];
}
void rs_3_00_03_0(unsigned char a, unsigned int b, double c) {
	gp[2] += gca[b] + -13;
}
void rs_3_00_03_1(unsigned char a, unsigned int b, double c) {
	if (gia[6] >= 100) { gia[a] = gi3 + !gi; if (gca[4] != 0) gca[b] = gs.c / gca[4]; if (gua[2] != 0) b = ((unsigned int)gi2) % gua[2]; } else { gula[0] = rul(gula[5]); }
}
void rs_3_00_03_2(unsigned char a, unsigned int b, double c) {
	vc((char)(-14610L >= gl2));
}
void rs_3_00_03_3(unsigned char a, unsigned int b, double c) {
	gu = -gu2 * 8;
}
void rs_3_00_03_4(unsigned char a, unsigned int b, double c) {
	gul &= gul * 12UL;
}
unsigned int rs_3_00_03_5(unsigned char a, unsigned int b, double c) {
	return (gps->u = ((unsigned int)gs.l));
}
void rs_3_00_04_1(void) {
	char *t = gp;
	jp = t;
}
void rs_3_00_04_2(void) {
	gd = -(-gd);
}
void rs_3_00_04_3(void) {
	int i = ji;
	for (i = 16; i > 0; i--) { ++gl; }
}
void rs_3_00_04_4(void) {
	gpl[1] = rl(2L);
}
void rs_3_00_04_5(void) {
	gula[3] = gul ^ ((unsigned long)*gpi);
}
void rs_3_00_04_6(void) {
	char *t = jp;
	v0();
	if (!gs.l) { v0(); if (gc != 0) gc2 = t[0] / gc; vp(t); } else { v0(); gula[0] = (unsigned long)guca[6]; gul++; }
}
unsigned int rs_3_00_04_7(void) {
	return ru(15223 - ((unsigned int)guc));
}
void rs_3_00_05_0(unsigned char a) {
	unsigned int t = gu2 | 7885;
	ju = t;
}
void rs_3_00_05_1(unsigned char a) {
	unsigned int t = ju;
	char *u = gs.p + t;
	jp = u;
}
void rs_3_00_05_2(unsigned char a) {
	++gpi;
}
void rs_3_00_05_3(unsigned char a) {
	char *u = jp;
	vp(u);
}
void rs_3_00_05_4(unsigned char a) {
	unsigned int t = ju;
	v0();
	gu = t;
}
void rs_3_00_05_5(unsigned char a) {
	gpi = &gia[0];
}
char * rs_3_00_05_6(unsigned char a) {
	return gp;
}
void rs_3_00_06_1(unsigned int a) {
	long t = gps->l;
	jl = t;
}
void rs_3_00_06_2(unsigned int a) {
	int u = (gi != 16 ? gia[6] : gi);
	ji = u;
}
void rs_3_00_06_3(unsigned int a) {
	int i = ji;
	long t = jl;
	for (i = 0; i < 13; i++) { v2(gia[i], gi); gda[1] = (guca[6] <= 62 ? (t <= gl2 ? gs.d : (double)gu) : (100.0 * 0.5)); if (gs.l != 0) gs.l = gl2 / gs.l; }
}
void rs_3_00_06_4(unsigned int a) {
	if (gul != 0) gul = gula[2] % gul;
}
void rs_3_00_06_5(unsigned int a) {
	int u = ji;
	v0();
	gi = u;
}
void rs_3_00_06_6(unsigned int a) {
	vp(gp);
}
int rs_3_00_06_7(unsigned int a) {
	return ((int)gl2 / 16) * 2;
}
void rs_3_00_07_0(void) {
	unsigned long t = gula[5] << 14;
	jul = t;
}
void rs_3_00_07_1(void) {
	*gpl = gla[3] = gs.l;
}
void rs_3_00_07_2(void) {
	gpl[2] += *gpl;
}
void rs_3_00_07_3(void) {
	unsigned long t = jul;
	vl((long)t);
}
int * rs_3_00_07_4(void) {
	return rpi((int)gul * 8);
}
void rs_3_00_08_0(int *a, unsigned char b, int c) {
	unsigned int t = (unsigned int)!b;
	ju = t;
}
void rs_3_00_08_1(int *a, unsigned char b, int c) {
	unsigned int u = gps->u;
	ju = u;
}
void rs_3_00_08_2(int *a, unsigned char b, int c) {
	unsigned int u = ju;
	gu = u;
}
void rs_3_00_08_3(int *a, unsigned char b, int c) {
	unsigned int t = ju;
	vu(t);
}
void rs_3_00_08_4(int *a, unsigned char b, int c) {
	guc = guca[c] = (guca[3] + b) % 16;
}
void rs_3_00_08_5(int *a, unsigned char b, int c) {
	gi2 *= 12;
}
char * rs_3_00_08_6(int *a, unsigned char b, int c) {
	return &gca[7];
}
void rs_3_00_09_0(long a, unsigned char b, unsigned int c) {
	unsigned char t = b << 4;
	juc = t;
}
void rs_3_00_09_1(long a, unsigned char b, unsigned int c) {
	int *u = gpi;
	jpi = u;
}
void rs_3_00_09_2(long a, unsigned char b, unsigned int c) {
	int *u = jpi;
	v1(*u);
}
void rs_3_00_09_3(long a, unsigned char b, unsigned int c) {
	gl = gla[3] + (65536L ^ *gpl);
}
void rs_3_00_09_4(long a, unsigned char b, unsigned int c) {
	unsigned char t = juc;
	v0();
	v1(t);
}
void rs_3_00_09_5(long a, unsigned char b, unsigned int c) {
	v0();
}
void rs_3_00_10_1(unsigned int a, unsigned long b, long c) {
	char *t = gp + a;
	jp = t;
}
void rs_3_00_10_2(unsigned int a, unsigned long b, long c) {
	unsigned long u = (unsigned long)'z';
	jul = u;
}
void rs_3_00_10_3(unsigned int a, unsigned long b, long c) {
	int i = ji;
	for (i = 0; i < 4; i++) { vs(gps); gc = (char)!gc2 + (char)gula[i]; }
}
void rs_3_00_10_4(unsigned int a, unsigned long b, long c) {
	unsigned long u = jul;
	v0();
	vl((long)u);
}
void rs_3_00_10_5(unsigned int a, unsigned long b, long c) {
	int i = ji;
	char *t = jp;
	v0();
	i = 15; do { vp(rp()); t = &gca[i]; gd2 = (gd2 - gd) - (0x10000UL > 3UL ? gs.d : 2.5); } while (--i > 0);
}
long rs_3_00_10_6(unsigned int a, unsigned long b, long c) {
	return (-9734L - gs.l) / 7L;
}
void rs_3_00_11_0(unsigned long a, struct st *b, char *c) {
	int t = ~gi3;
	ji = t;
}
char rs_3_00_11_1(unsigned long a, struct st *b, char *c) {
	if (gul <= 0x10000UL) return gc ^ 6;
}
void rs_3_00_11_2(unsigned long a, struct st *b, char *c) {
	int t = ji;
	v1(t);
}
void rs_3_00_11_3(unsigned long a, struct st *b, char *c) {
	v1(gi | gi3);
}
char rs_3_00_11_4(unsigned long a, struct st *b, char *c) {
	return (-78 + (char)gl) - '0';
}
void rs_3_00_12_1(void) {
	vc(gca[5]);
}
void rs_3_00_12_2(void) {
	guc = guca[6] = 9;
}
void rs_3_00_12_3(void) {
	gula[5] = gul + 7UL;
}
void rs_3_00_12_4(void) {
	int i = ji;
	v0();
	for (i = 4; i > 0; i--) { guc = guca[3]; gul = -gul; }
}
void rs_3_00_12_5(void) {
	gps->u -= gua[4];
}
unsigned int rs_3_00_12_6(void) {
	return gu2;
}
void rs_3_00_13_1(unsigned long a) {
	unsigned long t = a;
	jul = t;
}
void rs_3_00_13_2(unsigned long a) {
	v0();
}
void rs_3_00_13_3(unsigned long a) {
	gu2 = ru(gu2 - 1);
}
void rs_3_00_13_4(unsigned long a) {
	vl(rl(gpl[3]));
}
void rs_3_00_13_5(unsigned long a) {
	gda[1] *= (guc ? gd2 : gs.d);
}
void rs_3_00_13_6(unsigned long a) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
void rs_3_00_13_7(unsigned long a) {
	int i = ji;
	v0();
	i = 0; while (i < 9) { if (gs.l != 0) gs.l = gs.l % gs.l; if (gu != 0) gua[i] = gu2 % gu; gu2 = (unsigned int)gia[i]; i++; }
}
char * rs_3_00_13_8(unsigned long a) {
	return gp;
}
void rs_3_00_14_1(long a, long b, unsigned char c) {
	int *t = gpi;
	jpi = t;
}
void rs_3_00_14_2(long a, long b, unsigned char c) {
	char u = (gs.a[c] <= (int)gul ? gc2 : gca[c]);
	jc = u;
}
void rs_3_00_14_3(long a, long b, unsigned char c) {
	char u = jc;
	gu2 = gu = (gp[1] < '9' ? gua[c] : gps->u) - gu;
}
void rs_3_00_14_4(long a, long b, unsigned char c) {
	int i = ji;
	for (i = 0; i < 11; i++) { gd += gd - gs.d; }
}
void rs_3_00_14_5(long a, long b, unsigned char c) {
	char u = jc;
	gu2 = gs.u;
}
void rs_3_00_14_6(long a, long b, unsigned char c) {
	int *t = jpi;
	gpi = t;
}
void rs_3_00_14_7(long a, long b, unsigned char c) {
	++guc;
}
char rs_3_00_14_8(long a, long b, unsigned char c) {
	char u = jc;
	return (*gp * u) % 7;
}
void rs_3_00_15_1(int a, unsigned long b, int c) {
	vc((char)gps->u);
}
void rs_3_00_15_2(int a, unsigned long b, int c) {
	int i = ji;
	v0();
	i = 0; while (i < 15) { gl = gla[i]; i++; }
}
void rs_3_00_15_3(int a, unsigned long b, int c) {
	vd(gd2);
}
void rs_3_00_15_4(int a, unsigned long b, int c) {
	gs.p = &gca[0];
}
void rs_3_00_16_0(void) {
	char *t = rp();
	jp = t;
}
void rs_3_00_16_1(void) {
	if (gula[1] >= 0UL) { gi2 = ~(gi2 & gps->a[1]); } else { v0(); }
}
long rs_3_00_16_2(void) {
	char *t = jp;
	v0();
	if (t[2]) return (long)gia[6];
}
void rs_3_00_16_3(void) {
	gu = ~3;
}
long rs_3_00_16_4(void) {
	char *t = jp;
	v0();
	return ((long)(gc < t[1])) >> 6;
}
void rs_3_00_17_0(unsigned long a, unsigned int b, unsigned int c) {
	gda[0] *= gda[2] / 0.5;
}
void rs_3_00_17_1(unsigned long a, unsigned int b, unsigned int c) {
	gp++;
}
void rs_3_00_17_2(unsigned long a, unsigned int b, unsigned int c) {
	gula[7] = rul(gula[b]);
}
void rs_3_00_17_3(unsigned long a, unsigned int b, unsigned int c) {
	guca[3] = ((unsigned char)gula[2]) - (guca[3] & ((unsigned char)gi));
}
int rs_3_00_17_4(unsigned long a, unsigned int b, unsigned int c) {
	return (gpi[0] = (int)guc);
}
void rs_3_00_18_0(unsigned long a, unsigned char b, char *c) {
	unsigned int t = gps->u;
	ju = t;
}
void rs_3_00_18_1(unsigned long a, unsigned char b, char *c) {
	gu = ru(1) % 100;
}
void rs_3_00_18_2(unsigned long a, unsigned char b, char *c) {
	unsigned int t = ju;
	v0();
	gps->u = t | 27450;
}
void rs_3_00_18_3(unsigned long a, unsigned char b, char *c) {
	vd(gda[3]);
}
void rs_3_00_18_4(unsigned long a, unsigned char b, char *c) {
	a = gula[b];
}
void rs_3_00_18_5(unsigned long a, unsigned char b, char *c) {
	while (gi-- > 0) *c++ = 3;
}
int rs_3_00_18_6(unsigned long a, unsigned char b, char *c) {
	return r2(gs.a[b], gi) / 7;
}
void rs_3_00_19_0(void) {
	gi3 &= *gpi << 15;
}
void rs_3_00_19_1(void) {
	gp = gs.p;
}
void rs_3_00_19_2(void) {
	if (!gs.l) *gp = gp[3];
}
unsigned long rs_3_00_19_3(void) {
	if (guc > 1 || 65536L < 86430L) return gul + 3295UL;
}
void rs_3_00_19_4(void) {
	gs.i = gi & 276;
}
unsigned long rs_3_00_19_5(void) {
	return ((unsigned long)!gs.i) | (50391UL >> 3);
}
void rs_3_01_00_0(char a) {
	unsigned char t = guca[3];
	juc = t;
}
int * rs_3_01_00_1(char a) {
	unsigned char t = juc;
	if (r0()) return gpi + t;
}
void rs_3_01_00_2(char a) {
	unsigned char t = juc;
	v0();
	a = ~(a == gca[a] ? gca[t] : gc);
}
void rs_3_01_00_3(char a) {
	unsigned char t = juc;
	v0();
	gi = gs.a[t] = r2(gi2, gi2) ^ 1;
}
void rs_3_01_00_4(char a) {
	unsigned char t = juc;
	v0();
	switch (gl2) { case 0L: *gpl = gl & gla[t]; break; case 1L: gp[1] = gc2; case 2L: gi3 = gia[7] + gi; break; }
}
int * rs_3_01_00_5(char a) {
	return gpi + a;
}
void rs_3_01_01_1(unsigned char a) {
	int i = ji;
	i = 0; while (i < 16) { if (gia[3] != 0) gi2 = 256 % gia[3]; gc2 = 26; a /= 16; i++; }
}
void rs_3_01_01_2(unsigned char a) {
	guc = (guca[a] ^ 128) + (a - 255);
}
void rs_3_01_01_3(unsigned char a) {
	gpi = &gia[5];
}
void rs_3_01_01_4(unsigned char a) {
	int i = ji;
	if (!gs.i) { if (gul != 0) gula[2] = gula[0] / gul; if (gu2 != 0) gu2 = gu % gu2; if (gula[a] != 0) gula[1] = gula[a] / gula[a]; }
}
unsigned int rs_3_01_01_5(unsigned char a) {
	return (255 - gps->u) ^ ~gps->u;
}
void rs_3_01_02_0(char a) {
	gi++;
}
void rs_3_01_02_1(char a) {
	if (gps->a[5] <= gs.a[7]) { --gu; guc = (gca[a] > -62 || gca[a] != 'a' ? guca[a] : -guc); }
}
void rs_3_01_03_1(void) {
	unsigned long t = gula[7];
	jul = t;
}
void rs_3_01_03_2(void) {
	int *u = gpi + 1;
	jpi = u;
}
void rs_3_01_03_3(void) {
	unsigned long t = jul;
	gula[0] = t;
}
void rs_3_01_03_4(void) {
	while (gi-- > 0) *gpi++ = 255;
}
void rs_3_01_03_5(void) {
	guca[0] ^= guca[7] & guca[0];
}
void rs_3_01_03_6(void) {
	int i = ji;
	i = 4; do { guc += (unsigned char)!gs.l; gua[i] = (gua[i] * 4) + (gu2 * 7); } while (--i > 0);
}
void rs_3_01_03_7(void) {
	int *u = jpi;
	v1(*u);
}
void rs_3_01_03_8(void) {
	switch (gc2) { case 0: gc &= gp[3]; break; case 1: vu(gu); break; default: *gpl = 7L << 3; break; }
}
char rs_3_01_03_9(void) {
	return (char)!(long)gua[0];
}
void rs_3_01_04_0(void) {
	gl -= 5L << 26;
}
void rs_3_01_04_1(void) {
	guc = 255;
}
void rs_3_01_04_2(void) {
	*gpi %= 2;
}
void rs_3_01_04_3(void) {
	if (gl) { v0(); if (gca[1] != 0) gca[6] = 'a' % gca[1]; if (gc != 0) gp[3] = gca[5] % gc; } else { *gpi = gps->i = -(-gpi[1]); gula[7] = gul; }
}
void rs_3_01_04_4(void) {
	if ((gc2 = gc) > 'a') guca[6] = -guca[0];
}
void rs_3_01_05_1(void) {
	unsigned long t = gula[7] - gul;
	jul = t;
}
void rs_3_01_05_2(void) {
	gps->u = gua[1] = (32767 & gu) / 7;
}
void rs_3_01_05_3(void) {
	unsigned long t = jul;
	gul = t;
}
void rs_3_01_05_4(void) {
	int i = ji;
	i = 3; do { gula[i] *= 3UL; } while (--i > 0);
}
void rs_3_01_05_5(void) {
	gpl[3] ^= gpl[0] >> 3;
}
char rs_3_01_05_6(void) {
	return (gp[0] = 40);
}
void rs_3_01_06_0(char *a) {
	int t = gia[4];
	ji = t;
}
void rs_3_01_06_1(char *a) {
	int t = ji;
	unsigned char u = (gia[4] ? guca[t] : guc);
	juc = u;
}
void rs_3_01_06_2(char *a) {
	gda[1] *= -gd;
}
void rs_3_01_06_3(char *a) {
	vp(rp());
}
void rs_3_01_06_4(char *a) {
	int t = ji;
	v0();
	v1(t);
}
void rs_3_01_06_5(char *a) {
	unsigned char u = juc;
	v0();
	guc = u;
}
unsigned long rs_3_01_06_6(char *a) {
	unsigned char u = juc;
	v0();
	return (gula[u] % 2UL) + gul;
}
void rs_3_01_07_0(unsigned int a) {
	int *t = gpi + a;
	jpi = t;
}
void rs_3_01_07_1(unsigned int a) {
	gl2++;
}
void rs_3_01_07_2(unsigned int a) {
	a = gu2;
}
void rs_3_01_07_3(unsigned int a) {
	while (gi > 0) { gc2 += *gp++; gi--; }
}
void rs_3_01_07_4(unsigned int a) {
	int *t = jpi;
	gpi = t;
}
void rs_3_01_07_5(unsigned int a) {
	v2(gi2, (int)*gp % 2);
}
void rs_3_01_07_6(unsigned int a) {
	gla[1] %= 7L;
}
int rs_3_01_07_7(unsigned int a) {
	return (gi3 = 100);
}
void rs_3_01_08_0(double a, int *b, char c) {
	if ((double)gl2 == gd2 || !guca[6]) { ++gul; if (gpl[1] != 0) gl2 = gps->l % gpl[1]; gu2 %= 10; } else { gi3 = ~2 + !(-18802L); guc = guca[c]; }
}
void rs_3_01_08_1(double a, int *b, char c) {
	gs.l -= gpl[2];
}
void rs_3_01_08_2(double a, int *b, char c) {
	--gc;
}
unsigned int rs_3_01_08_3(double a, int *b, char c) {
	return gu2;
}
void rs_3_01_09_0(char a) {
	unsigned char t = guca[7];
	juc = t;
}
void rs_3_01_09_1(char a) {
	char *u = gps->p;
	jp = u;
}
void rs_3_01_09_2(char a) {
	unsigned char t = juc;
	++t;
}
void rs_3_01_09_3(char a) {
	char *u = jp;
	gp[0] = u[3];
}
int rs_3_01_09_4(char a) {
	return gps->i << 3;
}
void rs_3_01_10_0(long a, long *b) {
	gul = (gul % 3UL) % 2UL;
}
void rs_3_01_10_1(long a, long *b) {
	guc = ((unsigned char)!(-72039L)) - ((unsigned char)a);
}
char rs_3_01_10_2(long a, long *b) {
	return (gc2 % 2) % 4;
}
void rs_3_01_11_0(unsigned long a, int b) {
	int *t = &gia[1];
	jpi = t;
}
void rs_3_01_11_1(unsigned long a, int b) {
	if (gl2 != 0) gla[b] = gl2 % gl2;
}
void rs_3_01_11_2(unsigned long a, int b) {
	int *t = jpi;
	gpi = t;
}
void rs_3_01_11_3(unsigned long a, int b) {
	gla[5] = (long)!(r2(gi2, gi) ? gla[b] : gl2);
}
void rs_3_01_11_4(unsigned long a, int b) {
	gul = (unsigned long)!(*gp * 'a');
}
int rs_3_01_11_5(unsigned long a, int b) {
	return (int)(gula[b] - a);
}
void rs_3_01_12_0(int a, struct st *b) {
	int t = gi3 - *gpi;
	ji = t;
}
char * rs_3_01_12_1(int a, struct st *b) {
	if (gl != 7L) return b->p;
}
void rs_3_01_12_2(int a, struct st *b) {
	gu2 = ((unsigned int)!9UL) & b->u;
}
void rs_3_01_12_3(int a, struct st *b) {
	int t = ji;
	v1(t);
}
char * rs_3_01_12_4(int a, struct st *b) {
	return gp + a;
}
void rs_3_01_13_0(int *a) {
	unsigned int t = (unsigned int)!7UL;
	ju = t;
}
void rs_3_01_13_1(int *a) {
	gp--;
}
void rs_3_01_13_2(int *a) {
	gps->l -= 6L | gl;
}
void rs_3_01_13_3(int *a) {
	unsigned int t = ju;
	gu = t;
}
void rs_3_01_13_4(int *a) {
	while (gi-- > 0) *a++ = -646;
}
long rs_3_01_13_5(int *a) {
	return (gl2 = 65536L);
}
void rs_3_01_14_0(char a) {
	char t = (char)((char)guca[a] != '0');
	jc = t;
}
void rs_3_01_14_1(char a) {
	char t = jc;
	gia[t] = gps->a[7] + 256;
}
void rs_3_01_14_2(char a) {
	char t = jc;
	if (gua[a] != 0) gua[t] = ((unsigned int)gul) / gua[a];
}
void rs_3_01_14_3(char a) {
	gps->i = gi3 = -(189 + gia[a]);
}
void rs_3_01_14_4(char a) {
	guca[6] = guc + guca[5];
}
unsigned int rs_3_01_14_5(char a) {
	return ru((unsigned int)gc2);
}
void rs_3_01_15_1(int a) {
	char *t = gps->p + a;
	jp = t;
}
void rs_3_01_15_2(int a) {
	int u = 127;
	ji = u;
}
void rs_3_01_15_3(int a) {
	gc = (gc2 ? (gc + gs.c) : rc(gps->a[3]));
}
void rs_3_01_15_4(int a) {
	int i = ji;
	char *t = jp;
	int u = ji;
	v0();
	i = 0; while (i < a) { if (gi2 != 0) gi3 = u % gi2; vp(t); gl = gl2; i++; }
}
void rs_3_01_15_5(int a) {
	int u = ji;
	v0();
	if (255 < 0 && gc & 2) { if (gu != 0) gu = ((unsigned int)gl2) % gu; if (u != 0) gpi[3] = a % u; v2(gs.a[5] - gs.a[u], gi); }
}
int rs_3_01_15_6(int a) {
	return (int)guca[5] * 2;
}
void rs_3_01_16_0(int a, long *b) {
	char t = 'z';
	jc = t;
}
void rs_3_01_16_1(int a, long *b) {
	if (gla[a] != 0) gps->l = gla[2] % gla[a];
}
void rs_3_01_16_2(int a, long *b) {
	guca[a] = guc = -guc;
}
void rs_3_01_16_3(int a, long *b) {
	char t = jc;
	gc = t;
}
char * rs_3_01_16_4(int a, long *b) {
	return gps->p;
}
void rs_3_01_17_1(double a) {
	unsigned long t = ~5UL;
	jul = t;
}
void rs_3_01_17_2(double a) {
	if (gi != 0) gi3 = gi2 / gi;
}
void rs_3_01_17_3(double a) {
	gd2 = a + ((double)gu - 2.5);
}
void rs_3_01_17_4(double a) {
	int i = ji;
	unsigned long t = jul;
	i = 0; while (i < 10) { gul = (gula[0] & ((unsigned long)gu)) - (t + 0UL); i++; }
}
void rs_3_01_17_5(double a) {
	if (gu == gps->u) vp(gs.p);
}
void rs_3_01_17_6(double a) {
	if (gps->l != 0) gpl[1] = 65536L % gps->l;
}
char rs_3_01_17_7(double a) {
	return *gp;
}
void rs_3_01_18_0(unsigned char a) {
	int t = gs.i + 8;
	ji = t;
}
void rs_3_01_18_1(unsigned char a) {
	int *u = gpi;
	jpi = u;
}
void rs_3_01_18_2(unsigned char a) {
	int *u = jpi;
	gpi = u;
}
void rs_3_01_18_3(unsigned char a) {
	gs.d = gs.d * gs.d;
}
void rs_3_01_18_4(unsigned char a) {
	gd2 -= gd2;
}
void rs_3_01_18_5(unsigned char a) {
	*gp += '9' ^ gs.c;
}
void rs_3_01_18_6(unsigned char a) {
	vd(2.5);
}
void rs_3_01_18_7(unsigned char a) {
	int t = ji;
	v0();
	gi = t;
}
void rs_3_01_18_8(unsigned char a) {
	gd2 -= gda[3] + gd;
}
int rs_3_01_18_9(unsigned char a) {
	int t = ji;
	v0();
	return (r2(256, gi) ? t : 255) - (int)gs.l;
}
void rs_3_01_19_1(int a) {
	char t = ~gs.c;
	jc = t;
}
void rs_3_01_19_2(int a) {
	int i = ji;
	for (i = 16; i > 0; i--) { if (gu2 != 0) gu = gu / gu2; gula[i] = gul = 40191UL; }
}
void rs_3_01_19_3(int a) {
	char t = jc;
	vc(t);
}
void rs_3_01_19_4(int a) {
	while (a-- > 0) *gpi++ = 305;
}
char rs_3_01_19_5(int a) {
	return (char)(~gs.u != (gi3 ? gu : gua[a]));
}
void rs_3_02_00_1(void) {
	gl2 = *gpl;
}
void rs_3_02_00_2(void) {
	gi3 += r2(gi2, gi2);
}
void rs_3_02_00_3(void) {
	int i = ji;
	v0();
	for (i = 0; i < 2; i++) { if (gula[7] != 0) gul = gul % gula[7]; guc--; }
}
void rs_3_02_01_0(unsigned char a, char b) {
	long t = gla[a];
	jl = t;
}
void rs_3_02_01_1(unsigned char a, char b) {
	*gpl = gla[b] = (long)!gs.u;
}
void rs_3_02_01_2(unsigned char a, char b) {
	gl2 = ~65536L;
}
void rs_3_02_01_3(unsigned char a, char b) {
	long t = jl;
	gl = t;
}
void rs_3_02_01_4(unsigned char a, char b) {
	gc2 >>= 7;
}
void rs_3_02_01_5(unsigned char a, char b) {
	gs.a[3] *= 11;
}
void rs_3_02_01_6(unsigned char a, char b) {
	if (a) if (gl != 0) gl = gpl[2] % gl;
}
unsigned long rs_3_02_01_7(unsigned char a, char b) {
	return (gul % 7UL) << 13;
}
void rs_3_02_02_0(unsigned long a, unsigned char b) {
	gl2 = rl(72977L % 7L);
}
void rs_3_02_02_1(unsigned long a, unsigned char b) {
	v1(gi3 * gi3);
}
void rs_3_02_02_2(unsigned long a, unsigned char b) {
	guc *= 4;
}
int * rs_3_02_02_3(unsigned long a, unsigned char b) {
	return gpi;
}
void rs_3_02_03_0(unsigned char a, struct st *b, unsigned long c) {
	int t = (int)guc;
	ji = t;
}
void rs_3_02_03_1(unsigned char a, struct st *b, unsigned long c) {
	long u = rl(gl2);
	jl = u;
}
void rs_3_02_03_2(unsigned char a, struct st *b, unsigned long c) {
	int t = ji;
	long u = jl;
	v0();
	switch (t) { case 0: u ^= 65536L; break; case 1: u = u / 10L; break; case 2: vl(u); break; case 3: v1(b->i); default: vd(gd2); break; }
}
void rs_3_02_03_3(unsigned char a, struct st *b, unsigned long c) {
	int t = ji;
	v0();
	switch (gc) { case 5: gula[a] <<= (a & 15); break; case 20: gia[a] = t + 1; break; case 100: vl(41951L); break; }
}
void rs_3_02_03_4(unsigned char a, struct st *b, unsigned long c) {
	vu(gu2 << 12);
}
long rs_3_02_03_5(unsigned char a, struct st *b, unsigned long c) {
	return *gpl;
}
void rs_3_02_04_0(unsigned char a, unsigned int b, unsigned int c) {
	long t = 33371L % 7L;
	jl = t;
}
void rs_3_02_04_1(unsigned char a, unsigned int b, unsigned int c) {
	gu &= ru(32767);
}
void rs_3_02_04_2(unsigned char a, unsigned int b, unsigned int c) {
	long t = jl;
	v0();
	gl = t;
}
void rs_3_02_04_3(unsigned char a, unsigned int b, unsigned int c) {
	gps->p = gp;
}
void rs_3_02_04_4(unsigned char a, unsigned int b, unsigned int c) {
	v2(gi2, 16);
}
void rs_3_02_05_0(void) {
	char *t = gps->p;
	jp = t;
}
void rs_3_02_05_1(void) {
	gi3++;
}
void rs_3_02_05_2(void) {
	++gc;
}
void rs_3_02_05_3(void) {
	char *t = jp;
	gs.p = t;
}
void rs_3_02_05_4(void) {
	gda[3] = gda[3] + gda[1];
}
int rs_3_02_05_5(void) {
	return gs.a[5];
}
void rs_3_02_06_0(void) {
	gs.c = gca[2];
}
void rs_3_02_06_1(void) {
	vc(92 - gc);
}
void rs_3_02_06_2(void) {
	gda[3] = gd2;
}
void rs_3_02_06_3(void) {
	guca[0] = (guc % 7) / 10;
}
int * rs_3_02_06_4(void) {
	return gpi;
}
void rs_3_02_07_1(char *a, long *b, int c) {
	char t = (char)guca[6] & gs.c;
	jc = t;
}
void rs_3_02_07_2(char *a, long *b, int c) {
	double u = gd / 10.0;
	jd = u;
}
void rs_3_02_07_3(char *a, long *b, int c) {
	double u = jd;
	if (gua[5] > gs.u) { if (gi3 != 0) gi = gi / gi3; gl2 %= 3L; v2(1 | 255, gi); }
}
void rs_3_02_07_4(char *a, long *b, int c) {
	int i = ji;
	char t = jc;
	v0();
	for (i = 12; i > 0; i--) { guca[i] = guc; vc(a[t]); }
}
void rs_3_02_07_5(char *a, long *b, int c) {
	vs(gps);
}
char rs_3_02_07_6(char *a, long *b, int c) {
	return gca[c] / 100;
}
void rs_3_02_08_0(char a) {
	if (gc & 0x8 && gula[3] < ((unsigned long)gla[a])) { gca[a] = gps->c; v2(gpi[3], gi); gd2 += gd2; }
}
void rs_3_02_08_1(char a) {
	vp(gps->p);
}
int rs_3_02_08_2(char a) {
	return ((int)guc + gi2) << 3;
}
void rs_3_02_09_0(double a, unsigned char b, char c) {
	int t = gs.a[b];
	ji = t;
}
void rs_3_02_09_1(double a, unsigned char b, char c) {
	unsigned long u = 78906UL << 5;
	jul = u;
}
void rs_3_02_09_2(double a, unsigned char b, char c) {
	int t = ji;
	++t;
}
void rs_3_02_09_3(double a, unsigned char b, char c) {
	gpi = &gia[b];
}
void rs_3_02_09_4(double a, unsigned char b, char c) {
	unsigned long u = jul;
	gu2 = gps->u = ru(14840);
}
char * rs_3_02_09_5(double a, unsigned char b, char c) {
	return rp();
}
void rs_3_02_10_0(void) {
	gu2 ^= gua[3] >> 7;
}
void rs_3_02_10_1(void) {
	if (gul) { vl(gl2 & 4L); } else { if (32767 == gu) gia[7] = gi3 + gi2; }
}
void rs_3_02_10_2(void) {
	gs.d -= (double)*gpi;
}
char rs_3_02_10_3(void) {
	return (gc2 = gca[4]);
}
void rs_3_02_11_0(struct st *a) {
	int t = 256;
	ji = t;
}
void rs_3_02_11_1(struct st *a) {
	int u = ~255;
	ji = u;
}
void rs_3_02_11_2(struct st *a) {
	int t = ji;
	if (gu2 || gi2 == a->i) { gula[4] ^= ~gula[3]; t = 256 ^ (gs.c == -57 ? gpi[2] : 142); } else { gul--; gp = rp(); }
}
void rs_3_02_11_3(struct st *a) {
	int u = ji;
	v0();
	switch (gi) { case 0: case 1: v0(); case 2: gl2 *= 5L; break; case 3: v2(gi2, u); break; default: vs(gps); break; }
}
void rs_3_02_11_4(struct st *a) {
	int u = ji;
	v0();
	if (-43490L < gpl[0]) { vu(a->u); } else { gu2 -= ((unsigned int)gi2) + gu2; gd -= gd; }
}
void rs_3_02_11_5(struct st *a) {
	gps->c = gc;
}
void rs_3_02_11_6(struct st *a) {
	int t = ji;
	int u = ji;
	v0();
	u = (u - gi) >> (t & 15);
}
int * rs_3_02_11_7(struct st *a) {
	return gpi;
}
void rs_3_02_12_1(long *a, int b, long c) {
	char *t = gps->p + b;
	jp = t;
}
void rs_3_02_12_2(long *a, int b, long c) {
	gp[3] = -28;
}
void rs_3_02_12_3(long *a, int b, long c) {
	char *t = jp;
	switch (gi2) { case 0: vp(t); break; case 1: vc(gca[7]); break; case 2: gul = 1UL - gul; break; case 3: gp[0] ^= 55; break; case 4: *gpi -= gi; break; default: vs(gps); break; }
}
void rs_3_02_12_4(long *a, int b, long c) {
	gul = 0x10000UL;
}
void rs_3_02_12_5(long *a, int b, long c) {
	int i = ji;
	v0();
	for (i = 9; i > 0; i--) { if (c != 0) gl = (long)gc2 / c; guca[i] = guca[i] + guc; if (gs.l != 0) gpl[3] = gl % gs.l; }
}
void rs_3_02_12_6(long *a, int b, long c) {
	guc += 12;
}
int rs_3_02_12_7(long *a, int b, long c) {
	return r2(gi2, gi3) % 10;
}
void rs_3_02_13_0(long a, int b) {
	char t = 5;
	jc = t;
}
void rs_3_02_13_1(long a, int b) {
	char t = jc;
	char u = gps->c << (t & 7);
	jc = u;
}
void rs_3_02_13_2(long a, int b) {
	++gul;
}
void rs_3_02_13_3(long a, int b) {
	char t = jc;
	vc(t);
}
void rs_3_02_13_4(long a, int b) {
	gs.d = 0.5 + gda[3];
}
void rs_3_02_13_5(long a, int b) {
	char u = jc;
	v0();
	vc(u);
}
void rs_3_02_14_0(struct st *a) {
	unsigned char t = guc;
	juc = t;
}
void rs_3_02_14_1(struct st *a) {
	int u = gi3;
	ji = u;
}
void rs_3_02_14_2(struct st *a) {
	gc = gc2;
}
void rs_3_02_14_3(struct st *a) {
	gc++;
}
void rs_3_02_14_4(struct st *a) {
	int u = ji;
	gi = u;
}
void rs_3_02_14_5(struct st *a) {
	unsigned char t = juc;
	gla[7] = (gl >> (t & 15)) | (-17753L % 10L);
}
int * rs_3_02_14_6(struct st *a) {
	return gpi;
}
void rs_3_02_15_0(void) {
	int t = gs.i;
	ji = t;
}
void rs_3_02_15_1(void) {
	gl = gps->l;
}
void rs_3_02_15_2(void) {
	int t = ji;
	switch (gps->i) { case 0: gca[2] = 9; break; case 1: v0(); break; case 2: vc(gc); case 3: gu2 -= 1; case 4: case 5: vs(gps); default: vu(gua[t]); break; }
}
void rs_3_02_15_3(void) {
	if (gc != 0) gp[2] = gp[3] % gc;
}
void rs_3_02_15_4(void) {
	int t = ji;
	v0();
	gpi = gpi + t;
}
char rs_3_02_15_5(void) {
	int t = ji;
	v0();
	return rc(gia[t]);
}
void rs_3_02_16_1(unsigned char a) {
	gia[5] = gps->a[7] = !gia[a] - (gpi[3] - gi);
}
void rs_3_02_16_2(unsigned char a) {
	v0();
}
void rs_3_02_16_3(unsigned char a) {
	if (a >= guc) if (gpl[0] != 0) gla[6] = gs.l / gpl[0];
}
void rs_3_02_16_4(unsigned char a) {
	gs.d = (double)gu / 0.25;
}
void rs_3_02_16_5(unsigned char a) {
	int i = ji;
	v0();
	for (i = 6; i > 0; i--) { if (gp[3] != 0) gc = *gp / gp[3]; }
}
void rs_3_02_17_1(void) {
	unsigned char t = ((unsigned char)gula[0]) + guca[7];
	juc = t;
}
void rs_3_02_17_2(void) {
	unsigned char t = juc;
	gla[t] = gps->l ^ gs.l;
}
void rs_3_02_17_3(void) {
	unsigned char t = juc;
	if (gi == 256 || t & 0x8) { vs(gps); } else { gda[3] = -(gd * 10.0); }
}
void rs_3_02_17_4(void) {
	int i = ji;
	v0();
	i = 0; while (i < 2) { gpi = rpi(r0()); if (gl != 0) gs.l = gl2 % gl; gs.u = gu2; i++; }
}
void rs_3_02_17_5(void) {
	++gul;
}
char * rs_3_02_17_6(void) {
	return gp;
}
void rs_3_02_18_1(int a) {
	int *t = gpi + a;
	jpi = t;
}
void rs_3_02_18_2(int a) {
	int i = ji;
	for (i = 0; i < 4; i++) { if (gua[i] != 0) gu = gps->u / gua[i]; gl = gs.l = ((long)gu2 - gl2) * 6L; gc = (char)((i << 15) < (i | gps->i)); }
}
void rs_3_02_18_3(int a) {
	int *t = jpi;
	gpi = t;
}
void rs_3_02_18_4(int a) {
	guc += (unsigned char)gul;
}
long rs_3_02_18_5(int a) {
	return (long)!(gul / 4UL);
}
void rs_3_02_19_1(unsigned char a) {
	int i = ji;
	i = 0; while (i < 14) { guc = -(guca[i] + guc); gul = rul(gul) & ((unsigned long)gs.a[i]); if (gul != 0) gula[i] = ((unsigned long)gu2) / gul; i++; }
}
void rs_3_02_19_2(unsigned char a) {
	int i = ji;
	v0();
	if (gpi[0] != 0) gs.i = 267 / gpi[0];
}
int rs_3_02_19_3(unsigned char a) {
	return gi3;
}
void rs_3_03_00_1(unsigned long a, int b) {
	char *t = gps->p;
	jp = t;
}
void rs_3_03_00_2(unsigned long a, int b) {
	char *t = jp;
	v1(2 & (int)t[b]);
}
void rs_3_03_00_3(unsigned long a, int b) {
	a &= rul(gula[6]);
}
void rs_3_03_00_4(unsigned long a, int b) {
	int i = ji;
	v0();
	for (i = 0; i < b; i++) { if (gs.u != 0) gs.u = gua[1] % gs.u; }
}
unsigned long rs_3_03_00_5(unsigned long a, int b) {
	return gul;
}
void rs_3_03_01_0(void) {
	unsigned long t = gul - gula[7];
	jul = t;
}
void rs_3_03_01_1(void) {
	unsigned long t = jul;
	t /= 2UL;
}
void rs_3_03_01_2(void) {
	++gc;
}
void rs_3_03_01_3(void) {
	if (guc) *gpl = rl(gps->l);
}
void rs_3_03_01_4(void) {
	vp(gs.p);
}
void rs_3_03_01_5(void) {
	if (r2(gi2, gps->a[4])) if (*gpl != 0) gs.l = gl2 / *gpl;
}
int rs_3_03_01_6(void) {
	return (int)(guca[2] % 2);
}
void rs_3_03_02_0(void) {
	long t = 65536L & gl;
	jl = t;
}
void rs_3_03_02_1(void) {
	unsigned long u = gul / 16UL;
	jul = u;
}
void rs_3_03_02_2(void) {
	gs.d += gs.d / 0.5;
}
void rs_3_03_02_3(void) {
	long t = jl;
	t = (65536L % 16L) >> 31;
}
void rs_3_03_02_4(void) {
	unsigned long u = jul;
	if (gi2 < gs.i) { gs.u /= 10; guc = guca[6] >> 3; } else { if (gua[6] & 2) v0(); }
}
void rs_3_03_02_5(void) {
	long t = jl;
	v0();
	*gpl = (gps->l ^ gla[0]) - (gs.l - t);
}
void rs_3_03_02_6(void) {
	guca[5] *= 7;
}
void rs_3_03_03_0(struct st *a, char b, unsigned long c) {
	long t = gl2;
	jl = t;
}
void rs_3_03_03_1(struct st *a, char b, unsigned long c) {
	guc = (unsigned char)(int)128;
}
void rs_3_03_03_2(struct st *a, char b, unsigned long c) {
	long t = jl;
	gl = t;
}
void rs_3_03_03_3(struct st *a, char b, unsigned long c) {
	gs.d += -0.25;
}
void rs_3_03_03_4(struct st *a, char b, unsigned long c) {
	vc((char)!gu);
}
void rs_3_03_03_5(struct st *a, char b, unsigned long c) {
	gua[7] = (unsigned int)!(~b);
}
void rs_3_03_03_6(struct st *a, char b, unsigned long c) {
	gpi = &gia[b];
}
void rs_3_03_04_0(struct st *a, char *b) {
	char *t = &gca[0];
	jp = t;
}
void rs_3_03_04_1(struct st *a, char *b) {
	char *t = jp;
	switch (gl2) { case 2L: vu(gu2); break; case 8L: gu2 <<= 14; break; case 16L: case 20L: guc = guca[5]; break; case 100L: vs(gps); break; case 1000L: vp(t); break; }
}
void rs_3_03_04_2(struct st *a, char *b) {
	char *t = jp;
	v0();
	vc(gca[3] - t[0]);
}
void rs_3_03_04_3(struct st *a, char *b) {
	gs.d -= gs.d;
}
int * rs_3_03_04_4(struct st *a, char *b) {
	return gpi + 1;
}
void rs_3_03_05_1(int *a, int b) {
	long t = 8L - (long)gc;
	jl = t;
}
void rs_3_03_05_2(int *a, int b) {
	long t = jl;
	gl = t;
}
void rs_3_03_05_3(int *a, int b) {
	guca[b] += (unsigned char)gl2;
}
void rs_3_03_05_4(int *a, int b) {
	int i = ji;
	for (i = b; i > 0; i--) { vc(gps->c - gp[1]); }
}
void rs_3_03_05_5(int *a, int b) {
	vp(gp);
}
int rs_3_03_05_6(int *a, int b) {
	return 255;
}
void rs_3_03_06_0(int a) {
	long t = gl;
	jl = t;
}
void rs_3_03_06_1(int a) {
	int u = 2 % 10;
	ji = u;
}
long rs_3_03_06_2(int a) {
	long t = jl;
	if (gs.d >= gda[0]) return gl ^ t;
}
void rs_3_03_06_3(int a) {
	if (gula[1] != 0) gul = gula[1] % gula[1];
}
void rs_3_03_06_4(int a) {
	int u = ji;
	if (gua[a] != 0) gua[u] = gu2 / gua[a];
}
void rs_3_03_06_5(int a) {
	long t = jl;
	*gpl = t;
}
void rs_3_03_06_6(int a) {
	gla[0] = (long)gu2;
}
long rs_3_03_06_7(int a) {
	long t = jl;
	return rl(t + *gpl);
}
void rs_3_03_07_0(unsigned int a) {
	vs(gps);
}
void rs_3_03_07_1(unsigned int a) {
	vs(gps);
}
void rs_3_03_07_2(unsigned int a) {
	guca[5] = guc;
}
void rs_3_03_07_3(unsigned int a) {
	if (gps->u != 0) gu2 = 9 % gps->u;
}
void rs_3_03_07_4(unsigned int a) {
	gu2 ^= a;
}
long rs_3_03_07_5(unsigned int a) {
	return gps->l;
}
void rs_3_03_08_1(struct st *a, unsigned long b) {
	vc(gc2);
}
void rs_3_03_08_2(struct st *a, unsigned long b) {
	--gu2;
}
void rs_3_03_08_3(struct st *a, unsigned long b) {
	int i = ji;
	v0();
	for (i = 0; i < 10; i++) { guc += guca[i]; if (gs.c != 0) gc = gs.c / gs.c; }
}
void rs_3_03_08_4(struct st *a, unsigned long b) {
	gul &= (a->u == 32767 ? ((unsigned long)gpi[0]) : gul);
}
int rs_3_03_08_5(struct st *a, unsigned long b) {
	return (int)guc;
}
void rs_3_03_09_1(long a, long b, unsigned char c) {
	long t = rl(gps->l);
	jl = t;
}
void rs_3_03_09_2(long a, long b, unsigned char c) {
	int i = ji;
	v0();
	for (i = 0; i < 8; i++) { gu2 = gps->u; }
}
void rs_3_03_09_3(long a, long b, unsigned char c) {
	long t = jl;
	v0();
	gl = t;
}
void rs_3_03_09_4(long a, long b, unsigned char c) {
	int i = ji;
	v0();
	if (gca[c]) *gpi = gs.i & gpi[0];
}
void rs_3_03_09_5(long a, long b, unsigned char c) {
	vp(gs.p);
}
int rs_3_03_09_6(long a, long b, unsigned char c) {
	return 100 + (gi - 8);
}
void rs_3_03_10_0(void) {
	gi2 = (guca[5] > guc ? gps->i : (gi | gi3));
}
void rs_3_03_10_1(void) {
	gu = (unsigned int)(gla[3] << 24);
}
void rs_3_03_10_2(void) {
	++gl2;
}
void rs_3_03_10_3(void) {
	--gpi;
}
unsigned long rs_3_03_10_4(void) {
	return gula[3] % 2UL;
}
void rs_3_03_11_0(char a) {
	char *t = gp + a;
	jp = t;
}
void rs_3_03_11_1(char a) {
	if (gl != 0) gs.l = gl % gl;
}
void rs_3_03_11_2(char a) {
	char *t = jp;
	vp(t);
}
void rs_3_03_11_3(char a) {
	++gpi;
}
void rs_3_03_11_4(char a) {
	gda[0] = (r2(9, gi) ? 3.0 : gd);
}
void rs_3_03_11_5(char a) {
	--gpi;
}
int rs_3_03_11_6(char a) {
	return (gi + gps->i) << 6;
}
void rs_3_03_12_1(void) {
	int i = ji;
	for (i = 0; i < 4; i++) { gi3 = 16; v0(); gd = -gd2 / 0.25; }
}
void rs_3_03_12_2(void) {
	v2(!gpi[1], gi);
}
void rs_3_03_12_3(void) {
	gps->c /= 10;
}
void rs_3_03_12_4(void) {
	gul = (unsigned long)gps->u;
}
void rs_3_03_12_5(void) {
	gul -= (unsigned long)guca[4];
}
unsigned int rs_3_03_12_6(void) {
	return (unsigned int)!*gpi;
}
void rs_3_03_13_0(unsigned long a, unsigned char b) {
	char t = rc(gi);
	jc = t;
}
void rs_3_03_13_1(unsigned long a, unsigned char b) {
	char t = jc;
	char u = t;
	v0();
	jc = u;
}
void rs_3_03_13_2(unsigned long a, unsigned char b) {
	char t = jc;
	v0();
	t <<= 1;
}
void rs_3_03_13_3(unsigned long a, unsigned char b) {
	char u = jc;
	v0();
	gc = u;
}
void rs_3_03_13_4(unsigned long a, unsigned char b) {
	gul |= 3UL;
}
void rs_3_03_14_1(unsigned char a, unsigned int b) {
	int i = ji;
	for (i = 15; i > 0; i--) { gpi = gpi + b; }
}
void rs_3_03_14_2(unsigned char a, unsigned int b) {
	if (gs.c > gca[b] || gps->u == gu2) { gi2 -= !gia[b]; vl(73442L + (long)gula[7]); } else { if (gula[b] != 0) gul = gula[6] / gula[b]; gu2 = ((unsigned int)guc) - (gu2 | gs.u); vc(gc + gs.c); }
}
void rs_3_03_14_3(unsigned char a, unsigned int b) {
	gul++;
}
void rs_3_03_14_4(unsigned char a, unsigned int b) {
	int i = ji;
	v0();
	if (b <= gs.u || gps->i > 256) { v0(); } else { vs(gps); gpi = gpi + b; if (gul != 0) gula[0] = gul % gul; }
}
void rs_3_03_14_5(unsigned char a, unsigned int b) {
	gp = &gca[a];
}
unsigned long rs_3_03_14_6(unsigned char a, unsigned int b) {
	return gula[4];
}
void rs_3_03_15_1(unsigned long a) {
	int t = gi3 << 13;
	ji = t;
}
void rs_3_03_15_2(unsigned long a) {
	int u = 8 ^ *gpi;
	ji = u;
}
void rs_3_03_15_3(unsigned long a) {
	vd(gd2 / 1.0);
}
void rs_3_03_15_4(unsigned long a) {
	guc = guca[0];
}
void rs_3_03_15_5(unsigned long a) {
	int i = ji;
	v0();
	i = 0; while (i < 5) { if (gula[i] != 0) a = ((unsigned long)gl2) / gula[i]; i++; }
}
void rs_3_03_15_6(unsigned long a) {
	int u = ji;
	v0();
	gi = u;
}
void rs_3_03_15_7(unsigned long a) {
	int t = ji;
	v0();
	gl = rl((guca[t] ? gl : (long)t));
}
void rs_3_03_15_8(unsigned long a) {
	int i = ji;
	v0();
	for (i = 0; i < 15; i++) { gc++; gps->p = rp(); }
}
char rs_3_03_15_9(unsigned long a) {
	return gp[1] >> 5;
}
void rs_3_03_16_0(void) {
	double t = gs.d;
	jd = t;
}
void rs_3_03_16_1(void) {
	gc = (0 + gs.c) ^ (-4 / 4);
}
void rs_3_03_16_2(void) {
	guca[4] *= 5;
}
void rs_3_03_16_3(void) {
	double t = jd;
	vd(t);
}
void rs_3_03_16_4(void) {
	vs(gps);
}
int rs_3_03_16_5(void) {
	return -(int)gps->l ^ (gia[1] >> 2);
}
void rs_3_03_17_0(void) {
	vs(gps);
}
void rs_3_03_17_1(void) {
	guc = 128 ^ (guc >> 3);
}
int rs_3_03_17_2(void) {
	return gi;
}
void rs_3_03_18_0(char a) {
	unsigned char t = guca[a] ^ guca[4];
	juc = t;
}
void rs_3_03_18_1(char a) {
	gi2++;
}
void rs_3_03_18_2(char a) {
	unsigned char t = juc;
	guc = t;
}
void rs_3_03_18_3(char a) {
	gu2 = gu;
}
unsigned long rs_3_03_18_4(char a) {
	return (gula[a] = 18246UL);
}
void rs_3_03_19_1(unsigned long a, unsigned long b, unsigned int c) {
	int t = -gi;
	ji = t;
}
void rs_3_03_19_2(unsigned long a, unsigned long b, unsigned int c) {
	unsigned int u = gs.u;
	ju = u;
}
void rs_3_03_19_3(unsigned long a, unsigned long b, unsigned int c) {
	int t = ji;
	gula[t] <<= 15;
}
void rs_3_03_19_4(unsigned long a, unsigned long b, unsigned int c) {
	int i = ji;
	unsigned int u = ju;
	for (i = 0; i < 3; i++) { if (gul != 0) gul = gula[i] % gul; c = (gu2 + gu) ^ (-368 >= 256 ? u : gu2); gc = gc >> 2; }
}
void rs_3_03_19_5(unsigned long a, unsigned long b, unsigned int c) {
	if (!gula[3]) gi = gi3 << 10;
}
void rs_3_03_19_6(unsigned long a, unsigned long b, unsigned int c) {
	unsigned int u = ju;
	if (gla[c]) { u = (gua[2] + gu) << 14; gul = b = gul >> 14; }
}
void rs_3_03_19_7(unsigned long a, unsigned long b, unsigned int c) {
	gca[c] = gc2 << 1;
}
char * rs_3_03_19_8(unsigned long a, unsigned long b, unsigned int c) {
	return gs.p;
}
void rs_3_04_00_0(unsigned int a) {
	int *t = gpi;
	jpi = t;
}
void rs_3_04_00_1(unsigned int a) {
	unsigned char u = guc | 128;
	juc = u;
}
void rs_3_04_00_2(unsigned int a) {
	guc -= 255;
}
void rs_3_04_00_3(unsigned int a) {
	vc(rc(16));
}
void rs_3_04_00_4(unsigned int a) {
	unsigned char u = juc;
	v0();
	v1(u);
}
void rs_3_04_00_5(unsigned int a) {
	int *t = jpi;
	v0();
	gpi = t;
}
int * rs_3_04_00_6(unsigned int a) {
	int *t = jpi;
	v0();
	return t + a;
}
void rs_3_04_01_0(char a) {
	unsigned long t = 8UL;
	jul = t;
}
void rs_3_04_01_1(char a) {
	char *u = gs.p;
	jp = u;
}
void rs_3_04_01_2(char a) {
	v0();
}
void rs_3_04_01_3(char a) {
	char *u = jp;
	v0();
	gp = u;
}
void rs_3_04_01_4(char a) {
	if (r1(gi2)) { gpi++; }
}
void rs_3_04_01_5(char a) {
	unsigned long t = jul;
	v0();
	if (!gpl[2]) if (gula[2] != 0) t = gula[a] / gula[2];
}
int rs_3_04_01_6(char a) {
	return 100;
}
void rs_3_04_02_0(long a) {
	gu2 -= gu2 & gua[3];
}
void rs_3_04_02_1(long a) {
	gua[3] = (gu & 32767) - (gu & ((unsigned int)gps->l));
}
void rs_3_04_02_2(long a) {
	vl(gl2 << 21);
}
int rs_3_04_02_3(long a) {
	return (gs.i & 0x8 ? gia[2] : (gu ? gi3 : (int)gps->l));
}
void rs_3_04_03_0(void) {
	char *t = gp;
	jp = t;
}
void rs_3_04_03_1(void) {
	char u = '0';
	jc = u;
}
void rs_3_04_03_2(void) {
	char u = jc;
	gc = u;
}
void rs_3_04_03_3(void) {
	gd2 += gs.d;
}
void rs_3_04_03_4(void) {
	char *t = jp;
	vp(t);
}
void rs_3_04_03_5(void) {
	if (gula[0]) if (gul != 0) gul = gula[5] % gul;
}
void rs_3_04_03_6(void) {
	guc = (unsigned char)!256;
}
void rs_3_04_03_7(void) {
	gps->l = gla[6] = gl;
}
void rs_3_04_03_8(void) {
	gps->l = gl;
}
char * rs_3_04_03_9(void) {
	char *t = jp;
	char u = jc;
	v0();
	return t + u;
}
void rs_3_04_04_0(void) {
	int t = (gu & 0x80 ? 255 : 1);
	ji = t;
}
void rs_3_04_04_1(void) {
	int t = ji;
	gi = t;
}
void rs_3_04_04_2(void) {
	gul ^= gul + 0x10000UL;
}
void rs_3_04_04_3(void) {
	vd(1.0 - gd2);
}
void rs_3_04_04_4(void) {
	if ('9' == -97) gp[2] = rc(gia[5]);
}
void rs_3_04_04_5(void) {
	gs.d -= -gd2;
}
int rs_3_04_04_6(void) {
	return r0();
}
void rs_3_04_05_0(long a, int b, char c) {
	unsigned long t = gul / 7UL;
	jul = t;
}
void rs_3_04_05_1(long a, int b, char c) {
	gu2 = 256;
}
void rs_3_04_05_2(long a, int b, char c) {
	gua[0] = gps->u = ~((unsigned int)!15716UL);
}
void rs_3_04_05_3(long a, int b, char c) {
	unsigned long t = jul;
	gul = t;
}
void rs_3_04_05_4(long a, int b, char c) {
	++gpi;
}
void rs_3_04_06_0(char *a) {
	int t = 256 - gi3;
	ji = t;
}
void rs_3_04_06_1(char *a) {
	gda[0] = gd - 0.5;
}
void rs_3_04_06_2(char *a) {
	gula[6] = 54376UL;
}
void rs_3_04_06_3(char *a) {
	int t = ji;
	gi = t;
}
char * rs_3_04_06_4(char *a) {
	int t = ji;
	return &gca[t];
}
void rs_3_04_07_1(unsigned long a, long b, char *c) {
	char *t = gp;
	jp = t;
}
void rs_3_04_07_2(unsigned long a, long b, char *c) {
	double u = gda[3];
	jd = u;
}
void rs_3_04_07_3(unsigned long a, long b, char *c) {
	double u = jd;
	vd(u);
}
void rs_3_04_07_4(unsigned long a, long b, char *c) {
	char *t = jp;
	v0();
	vp(t);
}
void rs_3_04_07_5(unsigned long a, long b, char *c) {
	a += 63279UL * 2UL;
}
void rs_3_04_07_6(unsigned long a, long b, char *c) {
	int i = ji;
	char *t = jp;
	v0();
	i = 16; do { t[0] = gp[2] * gs.c; } while (--i > 0);
}
int rs_3_04_07_7(unsigned long a, long b, char *c) {
	return (gi2 - gi) / 7;
}
void rs_3_04_08_0(int a, char b) {
	unsigned char t = 255 * guc;
	juc = t;
}
void rs_3_04_08_1(int a, char b) {
	char *u = gs.p;
	jp = u;
}
void rs_3_04_08_2(int a, char b) {
	gla[3] = gps->l;
}
void rs_3_04_08_3(int a, char b) {
	gi3 += (gu > 6656 ? gi : gi2);
}
void rs_3_04_08_4(int a, char b) {
	unsigned char t = juc;
	guc = t;
}
void rs_3_04_08_5(int a, char b) {
	char *u = jp;
	gp = u;
}
char rs_3_04_08_6(int a, char b) {
	return (char)!(8 - gi3);
}
void rs_3_04_09_0(unsigned int a, unsigned char b, char *c) {
	++gi2;
}
void rs_3_04_09_1(unsigned int a, unsigned char b, char *c) {
	vs(gps);
}
void rs_3_04_09_2(unsigned int a, unsigned char b, char *c) {
	if (gula[b]) { gps->a[a] /= 7; } else { gl += gs.l ^ gl2; v0(); }
}
void rs_3_04_09_3(unsigned int a, unsigned char b, char *c) {
	guc = guc | b;
}
void rs_3_04_09_4(unsigned int a, unsigned char b, char *c) {
	v1(127);
}
int rs_3_04_09_5(unsigned int a, unsigned char b, char *c) {
	return (int)255;
}
void rs_3_04_10_0(char a) {
	int t = -556;
	ji = t;
}
void rs_3_04_10_1(char a) {
	double u = gda[3] / 2.5;
	jd = u;
}
void rs_3_04_10_2(char a) {
	int t = ji;
	gi = t;
}
void rs_3_04_10_3(char a) {
	++gi2;
}
void rs_3_04_10_4(char a) {
	gula[3] = -gul;
}
void rs_3_04_10_5(char a) {
	double u = jd;
	if ((char)gs.l != 57) { if (*gp != 0) gs.c = *gp / *gp; } else { if (gula[3] != 0) gul = 6UL % gula[3]; gula[4] = (unsigned long)(11465 >= gps->u); }
}
char * rs_3_04_10_6(char a) {
	return gp;
}
void rs_3_04_11_0(int *a, int *b) {
	int t = b[5];
	ji = t;
}
void rs_3_04_11_1(int *a, int *b) {
	unsigned int u = ((unsigned int)*gpl) + gu;
	ju = u;
}
void rs_3_04_11_2(int *a, int *b) {
	unsigned int u = ju;
	gc = gca[u];
}
void rs_3_04_11_3(int *a, int *b) {
	int t = ji;
	v1(t);
}
void rs_3_04_11_4(int *a, int *b) {
	while (gi-- > 0) *a++ = 256;
}
void rs_3_04_11_5(int *a, int *b) {
	gd = (gd2 / 1.0) - (gd / 100.0);
}
long rs_3_04_11_6(int *a, int *b) {
	return (gs.l | gla[5]) - rl(62576L);
}
void rs_3_04_12_1(char a, double b) {
	unsigned long t = 0x10000UL - gul;
	jul = t;
}
void rs_3_04_12_2(char a, double b) {
	int i = ji;
	for (i = 0; i < 14; i++) { gi3 *= 9; if (*gpl != 0) gl2 = gps->l / *gpl; }
}
void rs_3_04_12_3(char a, double b) {
	vp(rp());
}
void rs_3_04_12_4(char a, double b) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
int rs_3_04_12_5(char a, double b) {
	return (gi2 = 354);
}
void rs_3_04_13_0(long *a, struct st *b, char c) {
	long t = b->l / 4L;
	jl = t;
}
char rs_3_04_13_1(long *a, struct st *b, char c) {
	if (32767 > gua[c]) return gc2 / 10;
}
void rs_3_04_13_2(long *a, struct st *b, char c) {
	v1(gi2);
}
void rs_3_04_13_3(long *a, struct st *b, char c) {
	long t = jl;
	v0();
	gl = t;
}
char rs_3_04_13_4(long *a, struct st *b, char c) {
	return ' ';
}
void rs_3_04_14_0(void) {
	int *t = &gia[6];
	jpi = t;
}
void rs_3_04_14_1(void) {
	unsigned int u = gps->u - 1;
	ju = u;
}
void rs_3_04_14_2(void) {
	vs(gps);
}
void rs_3_04_14_3(void) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_3_04_14_4(void) {
	unsigned int u = ju;
	v0();
	if (gs.u) if (gula[u] != 0) gul = gul / gula[u];
}
char * rs_3_04_14_5(void) {
	return gps->p;
}
void rs_3_04_15_1(unsigned char a, unsigned long b, char c) {
	unsigned long t = 32233UL | gula[0];
	jul = t;
}
void rs_3_04_15_2(unsigned char a, unsigned long b, char c) {
	int *u = gpi;
	jpi = u;
}
void rs_3_04_15_3(unsigned char a, unsigned long b, char c) {
	int i = ji;
	int *u = jpi;
	for (i = 0; i < 7; i++) { gs.p = gs.p + i; if (*gpi != 0) gi3 = gi3 / *gpi; *u = gps->a[i]; }
}
void rs_3_04_15_4(unsigned char a, unsigned long b, char c) {
	unsigned long t = jul;
	gul = t;
}
void rs_3_04_15_5(unsigned char a, unsigned long b, char c) {
	while (gi-- > 0) { if (*gp == 0) break; gp++; }
}
void rs_3_04_15_6(unsigned char a, unsigned long b, char c) {
	gl &= 7L;
}
void rs_3_04_15_7(unsigned char a, unsigned long b, char c) {
	switch (gl2) { case 0L: gc -= 'a'; case 1L: a -= guca[a]; break; }
}
void rs_3_04_15_8(unsigned char a, unsigned long b, char c) {
	gi2 = gi3 = (gps->a[a] + 256) - (a >= 128);
}
char * rs_3_04_15_9(unsigned char a, unsigned long b, char c) {
	return rp();
}
void rs_3_04_16_0(void) {
	int t = 16 % 100;
	ji = t;
}
void rs_3_04_16_1(void) {
	v2(gi2, (int)gps->l);
}
void rs_3_04_16_2(void) {
	gda[1] *= 1.0 + gd2;
}
void rs_3_04_16_3(void) {
	int t = ji;
	v0();
	gc2 = (gps->c >> 4) & (gca[t] < gc2 ? gp[0] : gc);
}
int rs_3_04_16_4(void) {
	return gi3 / 3;
}
void rs_3_04_17_1(char *a, unsigned long b) {
	++gi2;
}
void rs_3_04_17_2(char *a, unsigned long b) {
	int i = ji;
	for (i = 0; i < 16; i++) { gc = -(gca[i] >> 1); if (gu != 0) gua[i] = 5 % gu; v2(gi2, gi2 + 16); }
}
int rs_3_04_17_3(char *a, unsigned long b) {
	return gi3;
}
void rs_3_04_18_0(long a, char *b) {
	gs.c += (!guca[5] ? 'A' : gca[0]);
}
void rs_3_04_18_1(long a, char *b) {
	gs.p = rp();
}
void rs_3_04_18_2(long a, char *b) {
	gp[0] = (char)!gl;
}
void rs_3_04_18_3(long a, char *b) {
	a = gps->l;
}
void rs_3_04_18_4(long a, char *b) {
	gpi = gpi + 1;
}
long rs_3_04_18_5(long a, char *b) {
	return (long)(guca[1] - guca[4]);
}
void rs_3_04_19_1(unsigned char a, char b) {
	int *t = rpi(gs.a[b]);
	jpi = t;
}
void rs_3_04_19_2(unsigned char a, char b) {
	double u = -(double)*gpl;
	v0();
	jd = u;
}
void rs_3_04_19_3(unsigned char a, char b) {
	double u = jd;
	v0();
	gd += gda[2] + u;
}
void rs_3_04_19_4(unsigned char a, char b) {
	*gp = b;
}
void rs_3_04_19_5(unsigned char a, char b) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_3_04_19_6(unsigned char a, char b) {
	gi2 = 2 % 7;
}
void rs_3_04_19_7(unsigned char a, char b) {
	int i = ji;
	v0();
	i = 0; while (i < 12) { v2(gi2, i); gia[i] = gpi[0] = *gpi; i++; }
}
char * rs_3_04_19_8(unsigned char a, char b) {
	return rp();
}
void rs_3_05_00_0(unsigned char a) {
	char *t = gp;
	jp = t;
}
void rs_3_05_00_1(unsigned char a) {
	if (gc & 0x7) guc = (guca[2] + a) >> 4;
}
void rs_3_05_00_2(unsigned char a) {
	char *t = jp;
	switch (gps->i) { case 0: case 1: vd(gda[0]); case 2: gps->p = t; break; case 3: gs.l <<= (a & 15); break; case 4: v2(gi3, gi); break; }
}
int rs_3_05_00_3(unsigned char a) {
	return -(int)gul;
}
void rs_3_05_01_0(double a, unsigned int b, unsigned char c) {
	unsigned long t = gul ^ 44010UL;
	jul = t;
}
void rs_3_05_01_1(double a, unsigned int b, unsigned char c) {
	switch (gi2) { case 1: gs.u ^= 1; break; case 5: v0(); break; default: c = c + 9; break; }
}
void rs_3_05_01_2(double a, unsigned int b, unsigned char c) {
	c |= 128;
}
void rs_3_05_01_3(double a, unsigned int b, unsigned char c) {
	unsigned long t = jul;
	v0();
	t += t ^ gula[c];
}
void rs_3_05_01_4(double a, unsigned int b, unsigned char c) {
	gd2 = (gs.d - gd) / 0.25;
}
void rs_3_05_01_5(double a, unsigned int b, unsigned char c) {
	*gp ^= 0;
}
unsigned long rs_3_05_01_6(double a, unsigned int b, unsigned char c) {
	unsigned long t = jul;
	v0();
	return (t << 14) % 7UL;
}
void rs_3_05_02_0(unsigned char a, long b, double c) {
	guca[a] = a = (a - guca[4]) / 100;
}
void rs_3_05_02_1(unsigned char a, long b, double c) {
	if (*gpl & 2) { vu(gua[a] << (a & 15)); }
}
int rs_3_05_02_2(unsigned char a, long b, double c) {
	return gi;
}
void rs_3_05_03_0(void) {
	v2(gps->a[5] + gi3, gi);
}
void rs_3_05_03_1(void) {
	gp = gps->p + 1;
}
unsigned long rs_3_05_03_2(void) {
	return (gul * gula[0]) >> 30;
}
void rs_3_05_04_1(int *a, int b, unsigned char c) {
	long t = -5247L * 10L;
	jl = t;
}
void rs_3_05_04_2(int *a, int b, unsigned char c) {
	int u = (gc == '9');
	ji = u;
}
void rs_3_05_04_3(int *a, int b, unsigned char c) {
	long t = jl;
	t = (t / 7L) - (long)guca[b];
}
void rs_3_05_04_4(int *a, int b, unsigned char c) {
	int i = ji;
	int u = ji;
	for (i = 6; i > 0; i--) { vu(gps->u); gd += gs.d; }
}
void rs_3_05_04_5(int *a, int b, unsigned char c) {
	int u = ji;
	v0();
	if (gs.c & 0x8) { gc = 17; if (gula[u] != 0) gul = gula[5] % gula[u]; }
}
void rs_3_05_04_6(int *a, int b, unsigned char c) {
	gi3 = !gs.l ^ (int)gula[b];
}
void rs_3_05_04_7(int *a, int b, unsigned char c) {
	gua[5] /= 16;
}
char * rs_3_05_04_8(int *a, int b, unsigned char c) {
	return gs.p;
}
void rs_3_05_05_0(double a, long b) {
	unsigned char t = guc;
	juc = t;
}
void rs_3_05_05_1(double a, long b) {
	unsigned char t = juc;
	int u = r2(gi2, (int)t);
	ji = u;
}
void rs_3_05_05_2(double a, long b) {
	int u = ji;
	v0();
	if (gul) { if (gc2 != 0) gs.c = (char)*gpi / gc2; if (gu != 0) gps->u = 255 / gu; }
}
void rs_3_05_05_3(double a, long b) {
	gl2 -= -48647L;
}
void rs_3_05_05_4(double a, long b) {
	unsigned char t = juc;
	v0();
	guc = t;
}
void rs_3_05_05_5(double a, long b) {
	int u = ji;
	v0();
	gpi = gpi + u;
}
int rs_3_05_05_6(double a, long b) {
	return r2(gi2, gps->i * gi3);
}
void rs_3_05_06_0(int a, long *b, long c) {
	char t = ~gps->c;
	jc = t;
}
void rs_3_05_06_1(int a, long *b, long c) {
	char u = 65;
	jc = u;
}
void rs_3_05_06_2(int a, long *b, long c) {
	if (gs.i == gi3) ++gc;
}
void rs_3_05_06_3(int a, long *b, long c) {
	char u = jc;
	vc(u);
}
void rs_3_05_06_4(int a, long *b, long c) {
	gda[0] += -(double)a;
}
void rs_3_05_06_5(int a, long *b, long c) {
	char t = jc;
	v0();
	vc(t);
}
char rs_3_05_06_6(int a, long *b, long c) {
	return (char)c;
}
void rs_3_05_07_0(void) {
	gc2 = (gca[5] ^ *gp) | (char)gla[1];
}
void rs_3_05_07_1(void) {
	vd(3.0 + 2.5);
}
void rs_3_05_07_2(void) {
	--gc2;
}
void rs_3_05_07_3(void) {
	if (gi == 127) if (gi != 0) gi = gi / gi;
}
void rs_3_05_07_4(void) {
	gca[6] = (char)gula[0] / 100;
}
int rs_3_05_07_5(void) {
	return (int)ru(gu2);
}
void rs_3_05_08_0(int *a, unsigned char b, long c) {
	unsigned char t = guca[7] << 6;
	juc = t;
}
void rs_3_05_08_1(int *a, unsigned char b, long c) {
	*gp = gs.c;
}
void rs_3_05_08_2(int *a, unsigned char b, long c) {
	unsigned char t = juc;
	gpi = a + t;
}
void rs_3_05_08_3(int *a, unsigned char b, long c) {
	gps->p = gs.p;
}
void rs_3_05_08_4(int *a, unsigned char b, long c) {
	vd(gd);
}
long rs_3_05_08_5(int *a, unsigned char b, long c) {
	return (18490L << 8) - (gps->l << 28);
}
void rs_3_05_09_0(char a, unsigned char b, int c) {
	int t = r0();
	ji = t;
}
void rs_3_05_09_1(char a, unsigned char b, int c) {
	int t = ji;
	v0();
	gu2 = (gpi[1] == gps->a[4] || r2(gs.a[a], gi) ? 32767 : ((unsigned int)gca[t]));
}
void rs_3_05_09_2(char a, unsigned char b, int c) {
	gd *= gd2;
}
void rs_3_05_09_3(char a, unsigned char b, int c) {
	b = 128;
}
void rs_3_05_09_4(char a, unsigned char b, int c) {
	vu((unsigned int)(gca[a] <= gca[3]));
}
char * rs_3_05_09_5(char a, unsigned char b, int c) {
	return &gca[4];
}
void rs_3_05_10_0(int a, unsigned char b) {
	gps->l = gps->l % 100L;
}
void rs_3_05_10_1(int a, unsigned char b) {
	gps->l = rl(gps->l);
}
void rs_3_05_10_2(int a, unsigned char b) {
	gi3 = (a | gps->i) + !255;
}
void rs_3_05_10_3(int a, unsigned char b) {
	if (b & 2 || guc) guca[3] = guca[3] + (guc << (a & 7));
}
void rs_3_05_10_4(int a, unsigned char b) {
	gps->l |= gpl[3] << 8;
}
char * rs_3_05_10_5(int a, unsigned char b) {
	return rp();
}
void rs_3_05_11_0(void) {
	unsigned long t = gul ^ gula[7];
	jul = t;
}
void rs_3_05_11_1(void) {
	gl = 65536L | gl;
}
void rs_3_05_11_2(void) {
	vu(gua[7] * 10);
}
void rs_3_05_11_3(void) {
	while (gi-- > 0) { if (*gp == 'a') break; gp++; }
}
void rs_3_05_11_4(void) {
	unsigned long t = jul;
	v0();
	gul = t;
}
void rs_3_05_11_5(void) {
	gua[5] >>= 7;
}
void rs_3_05_11_6(void) {
	vs(gps);
}
int rs_3_05_11_7(void) {
	return (911 + (int)gc) >> 12;
}
void rs_3_05_12_1(char a) {
	long t = gps->l;
	jl = t;
}
void rs_3_05_12_2(char a) {
	int i = ji;
	gs.a[5] = gps->i + -gi3;
}
void rs_3_05_12_3(char a) {
	int i = ji;
	if (gs.i != gi) if (gua[0] != 0) gu2 = gs.u / gua[0];
}
void rs_3_05_12_4(char a) {
	int i = ji;
	long t = jl;
	i = 5; do { if (gs.l != 0) gl = 62596L / gs.l; t = 65536L; if (gu2 != 0) gu = gua[i] / gu2; } while (--i > 0);
}
void rs_3_05_12_5(char a) {
	gpi = gpi + a;
}
void rs_3_05_12_6(char a) {
	guc += guc % 3;
}
int rs_3_05_12_7(char a) {
	return !guc | r1(gi2);
}
void rs_3_05_13_0(long a, int b) {
	guc = (guca[7] >> 4) * -guca[0];
}
void rs_3_05_13_1(long a, int b) {
	vl(1L - gla[b]);
}
void rs_3_05_13_2(long a, int b) {
	gul = (gul ^ 73961UL) ^ (gul / 7UL);
}
void rs_3_05_13_3(long a, int b) {
	guca[4] = guca[0];
}
void rs_3_05_13_4(long a, int b) {
	gs.d += gd;
}
unsigned long rs_3_05_13_5(long a, int b) {
	return ~gula[1] >> (b & 15);
}
void rs_3_05_14_0(char a) {
	gul = (gula[a] + gula[2]) + gul;
}
void rs_3_05_14_1(char a) {
	gpi[3] = gs.i & gi;
}
void rs_3_05_14_2(char a) {
	gula[a] = (r0() ? rul(gul) : (gula[2] * 11UL));
}
void rs_3_05_14_3(char a) {
	gi2 = (gia[6] << 3) >> 14;
}
int rs_3_05_14_4(char a) {
	return (gi | (int)gla[5]) & (gps->i | gi2);
}
void rs_3_05_15_1(unsigned char a) {
	unsigned int t = gu2;
	ju = t;
}
void rs_3_05_15_2(unsigned char a) {
	int i = ji;
	for (i = 0; i < 4; i++) { gla[1] = 3L + 54414L; gd = gd2 / 100.0; }
}
void rs_3_05_15_3(unsigned char a) {
	unsigned int t = ju;
	gu = gua[a] = t;
}
void rs_3_05_15_4(unsigned char a) {
	gul <<= 9;
}
void rs_3_05_15_5(unsigned char a) {
	unsigned int t = ju;
	switch (gs.l) { case 1L: case 5L: gs.c += gc2; break; case 1000L: gu2 = 8066 - t; break; default: gu2 = t; break; }
}
void rs_3_05_15_6(unsigned char a) {
	guca[a] -= guc + 214;
}
long rs_3_05_15_7(unsigned char a) {
	return (gpl[0] = gla[a]);
}
void rs_3_05_16_0(unsigned long a) {
	char *t = rp();
	jp = t;
}
void rs_3_05_16_1(unsigned long a) {
	guca[7] = guc >> 3;
}
void rs_3_05_16_2(unsigned long a) {
	gs.d = gd2 / 1.0;
}
void rs_3_05_16_3(unsigned long a) {
	char *t = jp;
	v0();
	vp(t);
}
void rs_3_05_16_4(unsigned long a) {
	gia[1] = ~gi;
}
void rs_3_05_16_5(unsigned long a) {
	vd((guca[1] ? 0.25 : gd));
}
void rs_3_05_16_6(unsigned long a) {
	if (255 < gi2) gla[3] ^= (gu2 & 0x10 ? -55263L : 57831L);
}
void rs_3_05_17_0(void) {
	int *t = &gia[6];
	jpi = t;
}
void rs_3_05_17_1(void) {
	char u = gps->c;
	jc = u;
}
void rs_3_05_17_2(void) {
	int *t = jpi;
	gpi = t;
}
void rs_3_05_17_3(void) {
	char u = jc;
	gi2 = gia[u] = gpi[3];
}
void rs_3_05_17_4(void) {
	v1(gps->a[3] / 4);
}
int * rs_3_05_17_5(void) {
	int *t = jpi;
	v0();
	return t;
}
void rs_3_05_18_0(int a, int b, char *c) {
	long t = 65536L << 1;
	jl = t;
}
void rs_3_05_18_1(int a, int b, char *c) {
	long u = gla[3];
	jl = u;
}
void rs_3_05_18_2(int a, int b, char *c) {
	long t = jl;
	gl = t;
}
void rs_3_05_18_3(int a, int b, char *c) {
	switch (gl) { case 2L: guc = (unsigned char)gul; break; case 5L: gul = 0x10000UL - gula[b]; break; case 10L: case 100L: a ^= 7; break; case 200L: vu(27362); break; default: gi3 = (int)gc2; break; }
}
void rs_3_05_18_4(int a, int b, char *c) {
	gula[a] = gula[b] / 7UL;
}
void rs_3_05_18_5(int a, int b, char *c) {
	long u = jl;
	v0();
	vl(u);
}
void rs_3_05_19_0(unsigned char a) {
	char *t = gs.p;
	jp = t;
}
void rs_3_05_19_1(unsigned char a) {
	int u = gia[2];
	ji = u;
}
void rs_3_05_19_2(unsigned char a) {
	--gu;
}
void rs_3_05_19_3(unsigned char a) {
	int u = ji;
	gi3 = gps->a[u];
}
void rs_3_05_19_4(unsigned char a) {
	char *t = jp;
	gps->c = (guca[7] == 255 ? gp[0] : t[1]);
}
void rs_3_05_19_5(unsigned char a) {
	vd(gs.d + 0.5);
}
int * rs_3_05_19_6(unsigned char a) {
	int u = ji;
	v0();
	return &gia[u];
}
void rs_3_06_00_0(unsigned long a, long b) {
	char t = (char)!gc;
	jc = t;
}
void rs_3_06_00_1(unsigned long a, long b) {
	char t = jc;
	if (gps->i > gi3) vu(gua[t] << 13);
}
void rs_3_06_00_2(unsigned long a, long b) {
	if (gpl[0] > 65536L) { gda[2] = -(gd / 100.0); gpl[3] += -*gpl; }
}
void rs_3_06_00_3(unsigned long a, long b) {
	vs(gps);
}
void rs_3_06_00_4(unsigned long a, long b) {
	while (gi-- > 0) *gpi++ = 127;
}
int rs_3_06_00_5(unsigned long a, long b) {
	char t = jc;
	v0();
	return (int)t / 2;
}
void rs_3_06_01_0(long *a, double b) {
	b = (gd2 - b) / 1.0;
}
void rs_3_06_01_1(long *a, double b) {
	gu--;
}
void rs_3_06_01_2(long *a, double b) {
	v2(-gs.i, gi);
}
long rs_3_06_01_3(long *a, double b) {
	return (long)!2;
}
int rs_3_06_02_0(void) {
	if (guc <= guca[7]) return gia[2] % 4;
}
void rs_3_06_02_1(void) {
	vd(gd2 * gda[2]);
}
int rs_3_06_02_2(void) {
	return (gi3 = gia[3]);
}
void rs_3_06_03_0(char *a) {
	int t = r2(gi2, (int)gul);
	ji = t;
}
void rs_3_06_03_1(char *a) {
	long u = (long)gc2;
	v0();
	jl = u;
}
void rs_3_06_03_2(char *a) {
	int t = ji;
	long u = jl;
	v0();
	if (a[2] > gps->c) { gu &= gua[t]; if (a[0] != 0) gca[6] = gc2 % a[0]; } else { if (gla[0] != 0) u = gl2 % gla[0]; }
}
void rs_3_06_03_3(char *a) {
	gi &= gpi[2];
}
unsigned long rs_3_06_03_4(char *a) {
	long u = jl;
	v0();
	return (gs.u > 255 ? ((unsigned long)guc) : gul) - -gul;
}
void rs_3_06_04_0(long a, int b, int *c) {
	int t = gs.i;
	ji = t;
}
void rs_3_06_04_1(long a, int b, int *c) {
	gula[b] ^= (unsigned long)gl;
}
void rs_3_06_04_2(long a, int b, int *c) {
	++guc;
}
void rs_3_06_04_3(long a, int b, int *c) {
	int t = ji;
	gua[t] /= 10;
}
void rs_3_06_05_0(char a, unsigned char b, double c) {
	unsigned long t = gul >> 22;
	jul = t;
}
void rs_3_06_05_1(char a, unsigned char b, double c) {
	unsigned char u = b;
	juc = u;
}
void rs_3_06_05_2(char a, unsigned char b, double c) {
	unsigned long t = jul;
	t *= 7UL;
}
void rs_3_06_05_3(char a, unsigned char b, double c) {
	a = rc(255 + *gpi);
}
void rs_3_06_05_4(char a, unsigned char b, double c) {
	unsigned char u = juc;
	v0();
	guc = u;
}
void rs_3_06_05_5(char a, unsigned char b, double c) {
	a = a | (gc2 | gc);
}
void rs_3_06_05_6(char a, unsigned char b, double c) {
	v1(~gi3);
}
int * rs_3_06_05_7(char a, unsigned char b, double c) {
	if (r2(gi2, gia[b])) return gpi;
}
int * rs_3_06_05_8(char a, unsigned char b, double c) {
	return &gia[a];
}
void rs_3_06_06_0(void) {
	unsigned char t = guca[6] + guc;
	juc = t;
}
void rs_3_06_06_1(void) {
	gpi++;
}
void rs_3_06_06_2(void) {
	unsigned char t = juc;
	gca[t] = (!gu ? gc2 : 33);
}
void rs_3_06_06_3(void) {
	unsigned char t = juc;
	t = 128;
}
int rs_3_06_06_4(void) {
	return ~(*gpi - (int)gl);
}
void rs_3_06_07_0(void) {
	char t = gp[1];
	jc = t;
}
void rs_3_06_07_1(void) {
	char t = jc;
	gc = t;
}
void rs_3_06_07_2(void) {
	vu((unsigned int)(gl2 < gla[1]));
}
void rs_3_06_07_3(void) {
	if (gu2 <= 32767) gia[3] = gi2 - gi;
}
void rs_3_06_07_4(void) {
	guc = -((unsigned char)gul);
}
void rs_3_06_07_5(void) {
	while (gi > 0) { gi3 += *gpi++; gi--; }
}
void rs_3_06_07_6(void) {
	gs.p = gp;
}
unsigned int rs_3_06_07_7(void) {
	char t = jc;
	v0();
	return (0 < guca[4] ? (t == gp[0] ? gu2 : gu) : ((unsigned int)(894 != gu2)));
}
void rs_3_06_08_1(long a, struct st *b) {
	long t = rl(a);
	jl = t;
}
void rs_3_06_08_2(long a, struct st *b) {
	unsigned char u = 128 + guc;
	v0();
	juc = u;
}
void rs_3_06_08_3(long a, struct st *b) {
	long t = jl;
	unsigned char u = juc;
	v0();
	if (!t && !gi) v2(gia[u], gi);
}
void rs_3_06_08_4(long a, struct st *b) {
	int i = ji;
	v0();
	for (i = 6; i > 0; i--) { guca[i] = guc = 128; }
}
int rs_3_06_08_5(long a, struct st *b) {
	unsigned char u = juc;
	v0();
	return (guca[0] < u) / 16;
}
void rs_3_06_09_1(void) {
	int t = gi3 % 2;
	ji = t;
}
void rs_3_06_09_2(void) {
	int t = ji;
	v1(gia[t] & gia[7]);
}
void rs_3_06_09_3(void) {
	*gpl = gla[4] = (long)((gl2 - gs.l) != *gpl);
}
void rs_3_06_09_4(void) {
	int i = ji;
	v0();
	i = 0; while (i < 12) { ++gc; i++; }
}
void rs_3_06_09_5(void) {
	if (guca[4] & 1) gps->u /= 3;
}
long rs_3_06_09_6(void) {
	return gl;
}
void rs_3_06_10_0(int a) {
	int t = 127 | gi;
	ji = t;
}
void rs_3_06_10_1(int a) {
	long u = rl(gl);
	jl = u;
}
void rs_3_06_10_2(int a) {
	long u = jl;
	v0();
	gs.u = gu + gua[a];
}
void rs_3_06_10_3(int a) {
	gula[a] /= 3UL;
}
void rs_3_06_10_4(int a) {
	gca[a] = gps->c;
}
void rs_3_06_10_5(int a) {
	long u = jl;
	v0();
	switch (gs.i) { case 0: gp = gs.p; case 1: case 2: gl2 <<= 23; break; case 3: gula[1] -= 0x10000UL; case 4: guc = guca[2]; break; case 5: v0(); break; default: vl(u); break; }
}
void rs_3_06_10_6(int a) {
	if (gl2 != 0) gla[7] = *gpl % gl2;
}
void rs_3_06_10_7(int a) {
	int t = ji;
	v0();
	gi = t;
}
int rs_3_06_10_8(int a) {
	int t = ji;
	v0();
	return (int)guca[t];
}
void rs_3_06_11_1(unsigned long a) {
	char *t = gp;
	jp = t;
}
void rs_3_06_11_2(unsigned long a) {
	unsigned int u = gu;
	ju = u;
}
void rs_3_06_11_3(unsigned long a) {
	gs.d -= gd2;
}
void rs_3_06_11_4(unsigned long a) {
	unsigned int u = ju;
	gs.u = 256 << 12;
}
void rs_3_06_11_5(unsigned long a) {
	int i = ji;
	char *t = jp;
	i = 0; while (i < 6) { if (gps->a[i] != 0) gia[i] = gpi[1] / gps->a[i]; if (gc != 0) *t = gc / gc; i++; }
}
void rs_3_06_11_6(unsigned long a) {
	vd(1.0 * gd2);
}
char rs_3_06_11_7(unsigned long a) {
	return gc2;
}
void rs_3_06_12_0(char a) {
	char *t = gp + a;
	jp = t;
}
void rs_3_06_12_1(char a) {
	char *u = &gca[a];
	jp = u;
}
void rs_3_06_12_2(char a) {
	char *u = jp;
	gp = u;
}
void rs_3_06_12_3(char a) {
	switch (gl) { case 2L: vu(gu); break; case 5L: gpi = &gia[a]; break; case 16L: case 100L: a = rc(gi3); }
}
void rs_3_06_12_4(char a) {
	gu = gua[a] = (unsigned int)!(~gs.i);
}
void rs_3_06_12_5(char a) {
	gc--;
}
void rs_3_06_12_6(char a) {
	char *t = jp;
	v0();
	gp = t;
}
void rs_3_06_12_7(char a) {
	gi3 &= gpi[2];
}
int * rs_3_06_12_8(char a) {
	return gpi + a;
}
void rs_3_06_13_0(int a, char b) {
	if (gs.u != gps->u) if (gl2 != 0) *gpl = *gpl % gl2;
}
void rs_3_06_13_1(int a, char b) {
	vl(rl(gs.l));
}
void rs_3_06_13_2(int a, char b) {
	while (a-- > 0) { if (*gpi == 100) break; gpi++; }
}
unsigned long rs_3_06_13_3(int a, char b) {
	return (gula[b] >> 22) | (gula[1] ^ gul);
}
void rs_3_06_14_0(void) {
	long t = 3L;
	jl = t;
}
void rs_3_06_14_1(void) {
	char *u = gs.p + 1;
	jp = u;
}
void rs_3_06_14_2(void) {
	long t = jl;
	if (guc) { if (gc2 != 0) gc = 8 % gc2; t = (gula[1] != gula[7] ? gps->l : (gla[2] & gpl[1])); }
}
void rs_3_06_14_3(void) {
	gua[0] = ~255;
}
void rs_3_06_14_4(void) {
	char *u = jp;
	switch (gi) { case 0: vd((double)u[2]); break; case 1: v0(); break; case 2: case 3: guc = guc ^ 255; break; case 4: gps->l /= 16L; break; }
}
void rs_3_06_14_5(void) {
	gula[0] = rul(gula[7]);
}
int * rs_3_06_14_6(void) {
	return rpi(gs.i - *gpi);
}
void rs_3_06_15_0(long a, unsigned char b, int c) {
	gp++;
}
void rs_3_06_15_1(long a, unsigned char b, int c) {
	*gpl %= 10L;
}
void rs_3_06_15_2(long a, unsigned char b, int c) {
	switch (c) { case 2: c = gs.i << 4; break; case 10: gps->l = (long)gi3; break; case 100: b *= 6; break; case 1000: vc(gc2); break; default: vc(gp[1]); break; }
}
int rs_3_06_15_3(long a, unsigned char b, int c) {
	return (gpi[1] = 1);
}
void rs_3_06_16_0(unsigned int a, int *b) {
	gp++;
}
void rs_3_06_16_1(unsigned int a, int *b) {
	if (gua[0] > 1) if (*b != 0) *gpi = gs.i % *b;
}
void rs_3_06_16_2(unsigned int a, int *b) {
	guc = guca[a] = guca[1];
}
unsigned int rs_3_06_16_3(unsigned int a, int *b) {
	return (27540 << 7) * 10;
}
char * rs_3_06_17_0(void) {
	if (gl) return gp + 1;
}
void rs_3_06_17_1(void) {
	gpi = &gia[4];
}
void rs_3_06_17_2(void) {
	gla[0] = gla[7];
}
char * rs_3_06_17_3(void) {
	return rp();
}
void rs_3_06_18_1(void) {
	int t = gi & 975;
	ji = t;
}
void rs_3_06_18_2(void) {
	unsigned char u = (unsigned char)gpl[0];
	juc = u;
}
void rs_3_06_18_3(void) {
	gs.a[0] = ~(127 ^ gpi[0]);
}
void rs_3_06_18_4(void) {
	int i = ji;
	int t = ji;
	for (i = 0; i < 9; i++) { if (gps->a[i] != 0) t = gpi[1] % gps->a[i]; }
}
void rs_3_06_18_5(void) {
	unsigned char u = juc;
	v1(u);
}
char * rs_3_06_18_6(void) {
	return gp;
}
long rs_3_06_19_0(char *a, unsigned int b, int *c) {
	if (b < gua[b]) return gla[b] << 27;
}
void rs_3_06_19_1(char *a, unsigned int b, int *c) {
	switch (gi2) { case 1: gs.d += 3.0; break; case 10: vl(gpl[1]); break; case 20: gpi = c; break; }
}
void rs_3_06_19_2(char *a, unsigned int b, int *c) {
	gd2 -= (double)gpi[1];
}
long rs_3_06_19_3(char *a, unsigned int b, int *c) {
	return (gs.l >> (b & 15)) & (gs.l - gps->l);
}
void rs_3_07_00_0(unsigned long a, long *b, int c) {
	v1(r1((int)gca[c]));
}
void rs_3_07_00_1(unsigned long a, long *b, int c) {
	guc -= guca[c];
}
char rs_3_07_00_2(unsigned long a, long *b, int c) {
	return gc2;
}
void rs_3_07_01_1(void) {
	unsigned char t = guca[0] / 16;
	juc = t;
}
void rs_3_07_01_2(void) {
	int u = r2(gi2, gi);
	ji = u;
}
void rs_3_07_01_3(void) {
	unsigned char t = juc;
	v0();
	guc = t;
}
void rs_3_07_01_4(void) {
	int u = ji;
	v0();
	v1(u);
}
void rs_3_07_01_5(void) {
	--gp;
}
void rs_3_07_01_6(void) {
	gps->c = *gp;
}
void rs_3_07_01_7(void) {
	int i = ji;
	v0();
	for (i = 12; i > 0; i--) { v0(); }
}
unsigned int rs_3_07_01_8(void) {
	return (unsigned int)gul;
}
void rs_3_07_02_0(long a) {
	vc(14 << 3);
}
void rs_3_07_02_1(long a) {
	if (gl2 > gpl[2]) { gl2++; } else { if ((gps->u = 32767)) gu = ru((unsigned int)(gu2 <= 9)); }
}
void rs_3_07_02_2(long a) {
	if (gu2 != 0) gps->u = gu / gu2;
}
int * rs_3_07_02_3(long a) {
	return gpi;
}
void rs_3_07_03_0(long a, unsigned long b) {
	if (gl2 & 0x10) { guc = (unsigned char)(gu < ((unsigned int)gla[0])); vl(gl2 >> 4); } else { if (gula[3] != 0x10000UL) gps->a[0] = gi3 = (gi * 8) + ~(int)guca[6]; }
}
void rs_3_07_03_1(long a, unsigned long b) {
	gula[6] = (gul >= ((unsigned long)gl) ? gula[4] : b) << 3;
}
long rs_3_07_03_2(long a, unsigned long b) {
	return (gla[0] << 31) - (long)!b;
}
void rs_3_07_04_1(void) {
	unsigned int t = (unsigned int)6L;
	ju = t;
}
void rs_3_07_04_2(void) {
	--gul;
}
void rs_3_07_04_3(void) {
	--gpi;
}
void rs_3_07_04_4(void) {
	unsigned int t = ju;
	t += 255;
}
void rs_3_07_04_5(void) {
	int i = ji;
	unsigned int t = ju;
	for (i = 3; i > 0; i--) { if (gi3 != 0) gi3 = gi % gi3; --guc; t = (gps->l < 93781L && !t ? (t << (t & 15)) : (gua[2] / 3)); }
}
int rs_3_07_04_6(void) {
	return (gs.d > (gd2 + gs.d));
}
void rs_3_07_05_1(unsigned int a, int *b, long c) {
	gs.d -= -gd2;
}
void rs_3_07_05_2(unsigned int a, int *b, long c) {
	gd2 -= -gda[2];
}
void rs_3_07_05_3(unsigned int a, int *b, long c) {
	int i = ji;
	for (i = 0; i < 10; i++) { gs.i = !(char)!gi2; }
}
void rs_3_07_05_4(unsigned int a, int *b, long c) {
	gula[a] -= -gul;
}
void rs_3_07_05_5(unsigned int a, int *b, long c) {
	gl = gl2 - rl(gl);
}
unsigned int rs_3_07_05_6(unsigned int a, int *b, long c) {
	return ru(-((unsigned int)gula[3]));
}
void rs_3_07_06_1(void) {
	char t = gc2 % 2;
	jc = t;
}
void rs_3_07_06_2(void) {
	int u = *gpi;
	ji = u;
}
void rs_3_07_06_3(void) {
	char t = jc;
	guca[2] <<= (t & 7);
}
void rs_3_07_06_4(void) {
	char t = jc;
	int u = ji;
	gua[t] = gps->u = (gps->u ^ 32767) % 100;
}
void rs_3_07_06_5(void) {
	int i = ji;
	int u = ji;
	for (i = 0; i < 16; i++) { if (*gpi != 0) u = 256 / *gpi; v2(gi2, gi2 + u); }
}
void rs_3_07_06_6(void) {
	vd((double)gu2 - gs.d);
}
int rs_3_07_06_7(void) {
	return (int)(1 / 3);
}
void rs_3_07_07_0(char *a, struct st *b, unsigned int c) {
	char *t = &gca[c];
	jp = t;
}
void rs_3_07_07_1(char *a, struct st *b, unsigned int c) {
	char *t = jp;
	gp = t;
}
void rs_3_07_07_2(char *a, struct st *b, unsigned int c) {
	gd2 = gd;
}
void rs_3_07_07_3(char *a, struct st *b, unsigned int c) {
	b->p = gps->p;
}
void rs_3_07_07_4(char *a, struct st *b, unsigned int c) {
	v0();
}
long rs_3_07_07_5(char *a, struct st *b, unsigned int c) {
	return (gua[c] ? gps->l : gla[c]) & gpl[2];
}
void rs_3_07_08_1(void) {
	unsigned long t = (unsigned long)(long)guc;
	jul = t;
}
void rs_3_07_08_2(void) {
	int i = ji;
	i = 12; do { gu = gua[i]; vl(*gpl); } while (--i > 0);
}
void rs_3_07_08_3(void) {
	int i = ji;
	v0();
	for (i = 16; i > 0; i--) { vc(gp[0]); ++gu; }
}
void rs_3_07_08_4(void) {
	int i = ji;
	v0();
	i = 0; while (i < 6) { gc = gc2 = (gca[i] % 3) * (gca[i] >> 7); gps->u = gps->u | ((unsigned int)gia[i]); i++; }
}
void rs_3_07_08_5(void) {
	gpi = &gia[5];
}
void rs_3_07_08_6(void) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
int rs_3_07_08_7(void) {
	return gia[3];
}
void rs_3_07_09_0(void) {
	gua[0] = gs.u = (unsigned int)!guc;
}
int rs_3_07_09_1(void) {
	if (gula[6]) return 2 & gi;
}
void rs_3_07_09_2(void) {
	if (gca[4]) { gi2 = gi2 - (gps->c < 1 ? gi2 : gps->a[0]); } else { gp = gp + 1; if (gu != 0) gu2 = gua[2] % gu; }
}
int rs_3_07_09_3(void) {
	return gi;
}
void rs_3_07_10_1(char a, double b) {
	char *t = gp + a;
	jp = t;
}
void rs_3_07_10_2(char a, double b) {
	unsigned long u = rul(0x10000UL);
	jul = u;
}
void rs_3_07_10_3(char a, double b) {
	*gpl = -gla[4];
}
void rs_3_07_10_4(char a, double b) {
	vp(gp);
}
void rs_3_07_10_5(char a, double b) {
	int i = ji;
	v0();
	if (1 == gua[6]) { vl(gpl[2] * gl2); gi = *gpi = gps->i; --gl2; } else { guca[1] ^= 128; gps->p = rp(); if (gpl[0] != 0) *gpl = *gpl / gpl[0]; }
}
void rs_3_07_10_6(char a, double b) {
	char *t = jp;
	v0();
	vp(t);
}
void rs_3_07_10_7(char a, double b) {
	int i = ji;
	unsigned long u = jul;
	v0();
	i = 8; do { gul = (gul * ((unsigned long)gps->u)) >> 16; gl = (long)gu2 / 10L; } while (--i > 0);
}
long rs_3_07_10_8(char a, double b) {
	unsigned long u = jul;
	v0();
	return (gpl[0] ^ (long)gu2) & (long)u;
}
void rs_3_07_11_0(double a, long b, struct st *c) {
	gul = gula[1] << 3;
}
void rs_3_07_11_1(double a, long b, struct st *c) {
	gps->p = gp;
}
char rs_3_07_11_2(double a, long b, struct st *c) {
	return (gs.c = 4);
}
void rs_3_07_12_0(char a, unsigned char b) {
	vs(gps);
}
void rs_3_07_12_1(char a, unsigned char b) {
	gu = gps->u >> 5;
}
void rs_3_07_12_2(char a, unsigned char b) {
	if (gd > gd2) gula[6] = rul(gula[a] % 2UL);
}
char rs_3_07_12_3(char a, unsigned char b) {
	if (guc == 255) return rc(100);
}
char rs_3_07_12_4(char a, unsigned char b) {
	return (gca[0] * 61) % 2;
}
void rs_3_07_13_1(struct st *a) {
	gu2 = ru(gu);
}
void rs_3_07_13_2(struct st *a) {
	vl(gla[5]);
}
void rs_3_07_13_3(struct st *a) {
	switch (gl) { case 0L: v2(*gpi, gi); break; case 1L: v2(gi2, a->a[3]); break; case 2L: *gpl |= -51439L; break; default: vc(gc2); break; }
}
void rs_3_07_13_4(struct st *a) {
	int i = ji;
	v0();
	for (i = 7; i > 0; i--) { if (gula[i] != 0) gula[i] = 6UL / gula[i]; guc = (7 + guc) ^ (guc & 162); gpl[0] = (long)!gul; }
}
char * rs_3_07_13_5(struct st *a) {
	return gps->p;
}
void rs_3_07_14_0(void) {
	int t = 16 >> 9;
	ji = t;
}
void rs_3_07_14_1(void) {
	int t = ji;
	t <<= 8;
}
void rs_3_07_14_2(void) {
	int t = ji;
	if (gl > *gpl) { gul -= gula[t] + gula[0]; }
}
void rs_3_07_14_3(void) {
	gp = gps->p;
}
unsigned int rs_3_07_14_4(void) {
	return 2079;
}
void rs_3_07_15_0(void) {
	--gc;
}
void rs_3_07_15_1(void) {
	gua[1] -= ~gs.u;
}
long rs_3_07_15_2(void) {
	return (gl2 = gs.l);
}
void rs_3_07_16_0(void) {
	int *t = gpi;
	jpi = t;
}
void rs_3_07_16_1(void) {
	char u = gps->c << 1;
	jc = u;
}
void rs_3_07_16_2(void) {
	int *t = jpi;
	v1(*t);
}
void rs_3_07_16_3(void) {
	*gp += gps->c | gc;
}
void rs_3_07_16_4(void) {
	char u = jc;
	v0();
	gc = u;
}
void rs_3_07_16_5(void) {
	++gi2;
}
int * rs_3_07_16_6(void) {
	int *t = jpi;
	char u = jc;
	v0();
	return t + u;
}
void rs_3_07_17_1(void) {
	unsigned char t = 9 / 2;
	juc = t;
}
void rs_3_07_17_2(void) {
	unsigned char t = juc;
	++t;
}
void rs_3_07_17_3(void) {
	unsigned char t = juc;
	gul = gula[t] | gul;
}
void rs_3_07_17_4(void) {
	int i = ji;
	for (i = 2; i > 0; i--) { gla[0] = gla[i]; gul -= (unsigned long)gps->u; gs.c = gca[i]; }
}
void rs_3_07_17_5(void) {
	unsigned char t = juc;
	gp[2] = '0' & gca[t];
}
void rs_3_07_17_6(void) {
	v0();
}
int * rs_3_07_17_7(void) {
	return gpi;
}
void rs_3_07_18_0(int a, unsigned int b, unsigned int c) {
	gs.c = gca[b] = 'z' >> 2;
}
void rs_3_07_18_1(int a, unsigned int b, unsigned int c) {
	gda[3] = (*gp & 4 ? gd2 : gd2);
}
void rs_3_07_18_2(int a, unsigned int b, unsigned int c) {
	gula[2] = rul(gula[c] << 12);
}
void rs_3_07_18_3(int a, unsigned int b, unsigned int c) {
	if (r2(gi2, gps->i)) if (gu != 0) c = gua[0] / gu;
}
void rs_3_07_18_4(int a, unsigned int b, unsigned int c) {
	*gpi = gi2;
}
char rs_3_07_18_5(int a, unsigned int b, unsigned int c) {
	return 'a' * (gc2 / 7);
}
void rs_3_07_19_0(unsigned long a) {
	unsigned int t = gua[6];
	ju = t;
}
void rs_3_07_19_1(unsigned long a) {
	unsigned int t = ju;
	if ((gp[1] = *gp) != 0) { a >>= 15; gc = (char)(gu2 % 4); gs.l = -39631L; } else { gs.c = 55; guc = (guc + 255) + (guc + guca[t]); }
}
void rs_3_07_19_2(unsigned long a) {
	if (gu2 || gl) gps->u %= 16;
}
char rs_3_07_19_3(unsigned long a) {
	return ((char)gi3 - gps->c) / 4;
}
void rs_3_08_00_0(struct st *a) {
	switch (gc2) { case 0: gpi = &gia[6]; break; case 1: gs.a[6] ^= gia[2]; break; case 2: gla[2] = gs.l; break; case 3: a->u = gu2 = a->u & gua[5]; break; case 4: gia[1] += gi; break; case 5: guc = guca[3] - guca[4]; break; default: gps->u = gu2 = gu - gua[3]; break; }
}
void rs_3_08_00_1(struct st *a) {
	a->l >>= 30;
}
void rs_3_08_00_2(struct st *a) {
	gpi[3] ^= gi + gs.i;
}
void rs_3_08_00_3(struct st *a) {
	*gp -= (' ') * gc2;
}
void rs_3_08_00_4(struct st *a) {
	if (2002 < gua[1]) gl++;
}
unsigned int rs_3_08_00_5(struct st *a) {
	return gps->u;
}
void rs_3_08_01_1(char *a) {
	double t = -(double)gu2;
	jd = t;
}
void rs_3_08_01_2(char *a) {
	gs.p = a;
}
void rs_3_08_01_3(char *a) {
	guc = ((unsigned char)(char)gla[6]) / 100;
}
void rs_3_08_01_4(char *a) {
	int i = ji;
	gl = (long)!(2 * gs.i);
}
void rs_3_08_01_5(char *a) {
	int i = ji;
	for (i = 0; i < 11; i++) { gula[i] = (a[3] ? gul : rul(0x10000UL)); }
}
void rs_3_08_01_6(char *a) {
	double t = jd;
	v0();
	vd(t);
}
void rs_3_08_01_7(char *a) {
	gc2 = (char)!108 + (*a % 7);
}
long rs_3_08_01_8(char *a) {
	return gl2;
}
void rs_3_08_02_1(char a, int b, unsigned int c) {
	unsigned long t = gul - 8UL;
	jul = t;
}
void rs_3_08_02_2(char a, int b, unsigned int c) {
	unsigned int u = gu2 - c;
	ju = u;
}
void rs_3_08_02_3(char a, int b, unsigned int c) {
	int i = ji;
	gps->i = gpi[1];
}
void rs_3_08_02_4(char a, int b, unsigned int c) {
	unsigned int u = ju;
	vu(u);
}
void rs_3_08_02_5(char a, int b, unsigned int c) {
	while (b-- > 0) *gpi++ = 255;
}
void rs_3_08_02_6(char a, int b, unsigned int c) {
	if (((unsigned int)a) == 8313 && *gpi & 0x7) { ++gi2; } else { if (gul & 0x8) guc <<= 6; }
}
void rs_3_08_02_7(char a, int b, unsigned int c) {
	int i = ji;
	unsigned long t = jul;
	v0();
	for (i = 13; i > 0; i--) { *gpl = gla[i] = gs.l; if (t != 0) t = t % t; }
}
void rs_3_08_02_8(char a, int b, unsigned int c) {
	gda[3] += gd / 0.25;
}
void rs_3_08_03_0(void) {
	gi2 = gia[0];
}
void rs_3_08_03_1(void) {
	gda[1] = gs.d / 3.0;
}
int rs_3_08_03_2(void) {
	return gi;
}
void rs_3_08_04_0(int *a, unsigned char b, unsigned long c) {
	char *t = gp + b;
	jp = t;
}
void rs_3_08_04_1(int *a, unsigned char b, unsigned long c) {
	guca[b] = guc - guca[1];
}
void rs_3_08_04_2(int *a, unsigned char b, unsigned long c) {
	if ((long)c != gs.l) if (gc != 0) gc2 = gc2 / gc;
}
void rs_3_08_04_3(int *a, unsigned char b, unsigned long c) {
	char *t = jp;
	gp = t;
}
void rs_3_08_04_4(int *a, unsigned char b, unsigned long c) {
	v2(gi2, (int)32767);
}
void rs_3_08_04_5(int *a, unsigned char b, unsigned long c) {
	gs.d = (guca[b] & 0x7 ? 3.0 : gs.d) - (gd + 0.5);
}
int rs_3_08_04_6(int *a, unsigned char b, unsigned long c) {
	return (int)gps->u & (gi | gia[b]);
}
void rs_3_08_05_1(long a, unsigned long b) {
	int t = (int)guca[7] + gi;
	ji = t;
}
void rs_3_08_05_2(long a, unsigned long b) {
	int t = ji;
	int *u = gpi + t;
	jpi = u;
}
void rs_3_08_05_3(long a, unsigned long b) {
	gu2 = ~gu << 2;
}
void rs_3_08_05_4(long a, unsigned long b) {
	int i = ji;
	int t = ji;
	i = 0; while (i < 8) { v2(gi2 & t, gi); gd = (gd + gd) - -gd2; gd += (double)*gp + gda[2]; i++; }
}
void rs_3_08_05_5(long a, unsigned long b) {
	if (gp[0] == *gp) guc = (unsigned char)~gu;
}
void rs_3_08_05_6(long a, unsigned long b) {
	gul /= 3UL;
}
void rs_3_08_05_7(long a, unsigned long b) {
	int *u = jpi;
	v0();
	v1(*u);
}
char * rs_3_08_05_8(long a, unsigned long b) {
	return rp();
}
void rs_3_08_06_0(unsigned char a) {
	gps->c >>= 3;
}
void rs_3_08_06_1(unsigned char a) {
	gu = gps->u;
}
void rs_3_08_06_2(unsigned char a) {
	gi2 = 16;
}
char rs_3_08_06_3(unsigned char a) {
	return gca[4];
}
void rs_3_08_07_0(int a, unsigned long b, char c) {
	unsigned char t = guca[3] - 128;
	juc = t;
}
void rs_3_08_07_1(int a, unsigned long b, char c) {
	gs.p = gps->p;
}
void rs_3_08_07_2(int a, unsigned long b, char c) {
	unsigned char t = juc;
	v1(t);
}
void rs_3_08_07_3(int a, unsigned long b, char c) {
	gpi--;
}
void rs_3_08_08_0(char *a, unsigned char b, unsigned int c) {
	unsigned int t = 7;
	ju = t;
}
void rs_3_08_08_1(char *a, unsigned char b, unsigned int c) {
	int u = (int)gul;
	ji = u;
}
void rs_3_08_08_2(char *a, unsigned char b, unsigned int c) {
	int u = ji;
	gi = u;
}
void rs_3_08_08_3(char *a, unsigned char b, unsigned int c) {
	unsigned int t = ju;
	vu(t);
}
void rs_3_08_08_4(char *a, unsigned char b, unsigned int c) {
	gc -= (char)!c;
}
void rs_3_08_08_5(char *a, unsigned char b, unsigned int c) {
	gc2 <<= 5;
}
void rs_3_08_08_6(char *a, unsigned char b, unsigned int c) {
	gps->a[c] = gia[3] >> 8;
}
void rs_3_08_08_7(char *a, unsigned char b, unsigned int c) {
	gl = gps->l;
}
unsigned long rs_3_08_08_8(char *a, unsigned char b, unsigned int c) {
	return 3UL;
}
void rs_3_08_09_1(void) {
	char t = gp[1] | 3;
	jc = t;
}
void rs_3_08_09_2(void) {
	char t = jc;
	if (!gs.l) { gi3 = (gs.a[3] << (t & 15)) * (gpi[2] ^ 256); gu = gua[2]; }
}
void rs_3_08_09_3(void) {
	gs.l += gl2;
}
void rs_3_08_09_4(void) {
	int i = ji;
	i = 14; do { gs.d = gda[1] / 2.5; gul--; gl--; } while (--i > 0);
}
void rs_3_08_09_5(void) {
	gula[4] = gul;
}
void rs_3_08_09_6(void) {
	int i = ji;
	for (i = 0; i < 10; i++) { vs(gps); }
}
int rs_3_08_09_7(void) {
	return 16;
}
void rs_3_08_10_1(unsigned int a) {
	int i = ji;
	i = 0; while (i < 14) { if (gpl[1] != 0) gps->l = gs.l / gpl[1]; gu >>= 3; vl((long)gc2 << 7); i++; }
}
void rs_3_08_10_2(unsigned int a) {
	gps->l += gl2;
}
void rs_3_08_10_3(unsigned int a) {
	gia[a] -= gia[6];
}
void rs_3_08_10_4(unsigned int a) {
	int i = ji;
	v0();
	i = 0; while (i < 16) { gua[6] = gps->u % 16; if (gpl[3] != 0) *gpl = gl % gpl[3]; i++; }
}
int rs_3_08_10_5(unsigned int a) {
	return (int)gps->c - gi3;
}
void rs_3_08_11_0(unsigned int a, long *b, int c) {
	unsigned long t = 54549UL + gul;
	jul = t;
}
void rs_3_08_11_1(unsigned int a, long *b, int c) {
	long u = gl;
	jl = u;
}
void rs_3_08_11_2(unsigned int a, long *b, int c) {
	gi2 = r2(gi2, gia[a] - gi2);
}
void rs_3_08_11_3(unsigned int a, long *b, int c) {
	unsigned long t = jul;
	v0();
	gul = t;
}
void rs_3_08_11_4(unsigned int a, long *b, int c) {
	long u = jl;
	v0();
	if (u) gia[1] = (guca[6] == 109);
}
void rs_3_08_11_5(unsigned int a, long *b, int c) {
	gpi = &gia[0];
}
int rs_3_08_11_6(unsigned int a, long *b, int c) {
	return !(gc - 5);
}
void rs_3_08_12_0(int a) {
	char *t = gps->p;
	jp = t;
}
void rs_3_08_12_1(int a) {
	int u = gs.a[3] + gps->a[a];
	ji = u;
}
void rs_3_08_12_2(int a) {
	int u = ji;
	gs.l = 1L << (u & 15);
}
void rs_3_08_12_3(int a) {
	gi3 = gi = r1(((int)guca[a] <= a));
}
void rs_3_08_12_4(int a) {
	vu(gu * 7);
}
void rs_3_08_12_5(int a) {
	char *t = jp;
	v0();
	gc = (char)!(int)gul * (*t - t[a]);
}
long rs_3_08_12_6(int a) {
	int u = ji;
	v0();
	return (gs.l >> (a & 15)) >> (u & 15);
}
void rs_3_08_13_1(struct st *a, unsigned char b, unsigned long c) {
	int i = ji;
	i = 0; while (i < 12) { gd *= gda[1]; i++; }
}
void rs_3_08_13_2(struct st *a, unsigned char b, unsigned long c) {
	switch (gi2) { case 1: v1(gi2); break; case 3: vl(gl2); break; default: v0(); break; }
}
void rs_3_08_13_3(struct st *a, unsigned char b, unsigned long c) {
	gd = 10.0 / 0.5;
}
void rs_3_08_13_4(struct st *a, unsigned char b, unsigned long c) {
	int i = ji;
	v0();
	gc2 = (r2(a->a[b], gi) ? -'0' : rc(gps->i));
}
unsigned int rs_3_08_13_5(struct st *a, unsigned char b, unsigned long c) {
	return -(8 | ((unsigned int)gl));
}
void rs_3_08_14_0(char a) {
	int *t = rpi(gi2);
	jpi = t;
}
void rs_3_08_14_1(char a) {
	int *t = jpi;
	v0();
	t = rpi(gi);
}
void rs_3_08_14_2(char a) {
	if (gu2 != 0) gs.u = gu / gu2;
}
void rs_3_08_15_0(long a) {
	double t = gda[3];
	jd = t;
}
void rs_3_08_15_1(long a) {
	int *u = &gia[7];
	jpi = u;
}
void rs_3_08_15_2(long a) {
	int *u = jpi;
	gi2 = gs.i = (gul & 0x80 ? (gula[2] > gula[1] ? u[0] : u[3]) : !*gp);
}
void rs_3_08_15_3(long a) {
	guc = guca[5] = guca[7];
}
void rs_3_08_15_4(long a) {
	switch (gi) { case 8: vp(&gca[7]); break; case 16: gla[2] /= 16L; break; case 20: guca[1] += guc; break; case 200: vc(gs.c); break; default: gul = gul & gula[5]; break; }
}
void rs_3_08_15_5(long a) {
	double t = jd;
	v0();
	if (gi2 <= gi3) { if (gi2 != 0) gi2 = gi3 % gi2; t *= ((int)gul != 127 ? gda[1] : gda[1]); gul *= 12UL; } else { gu--; }
}
void rs_3_08_15_6(long a) {
	v2(gi2, gia[1]);
}
int rs_3_08_15_7(long a) {
	return r2(gi2, 1) ^ gi3;
}
void rs_3_08_16_0(long a, unsigned int b) {
	int *t = gpi + b;
	jpi = t;
}
void rs_3_08_16_1(long a, unsigned int b) {
	unsigned char u = guc + 255;
	juc = u;
}
void rs_3_08_16_2(long a, unsigned int b) {
	v1(gi2 >> (b & 15));
}
void rs_3_08_16_3(long a, unsigned int b) {
	int *t = jpi;
	v0();
	t++;
}
void rs_3_08_16_4(long a, unsigned int b) {
	unsigned char u = juc;
	v0();
	if (r2(gia[u], gi)) gl = gs.l = rl((long)gc2) & (65536L >> 4);
}
int rs_3_08_16_5(long a, unsigned int b) {
	return 255 | gi;
}
void rs_3_08_17_0(void) {
	long t = gps->l;
	jl = t;
}
void rs_3_08_17_1(void) {
	double u = gda[0];
	jd = u;
}
void rs_3_08_17_2(void) {
	vp(gs.p);
}
void rs_3_08_17_3(void) {
	long t = jl;
	v0();
	t ^= 1L >> 24;
}
void rs_3_08_17_4(void) {
	long t = jl;
	v0();
	if (!gua[6]) { if (gs.c != 0) *gp = gc2 % gs.c; gi2--; } else { if (t != 0) gpl[3] = -71728L % t; gps->i = ((char)gs.a[1] != gca[6] ? 100 : gs.i); if (gc != 0) gp[2] = gc / gc; }
}
void rs_3_08_17_5(void) {
	double u = jd;
	v0();
	vd(u);
}
unsigned long rs_3_08_17_6(void) {
	return (guc & 0x10 ? gul : 90292UL) & gul;
}
void rs_3_08_18_0(unsigned int a) {
	int t = gps->a[2];
	ji = t;
}
void rs_3_08_18_1(unsigned int a) {
	int t = ji;
	t = (8 ^ t) / 16;
}
void rs_3_08_18_2(unsigned int a) {
	vu(gu2);
}
void rs_3_08_18_3(unsigned int a) {
	if (9 <= gps->c) guc |= 1;
}
char * rs_3_08_18_4(unsigned int a) {
	return gp;
}
void rs_3_08_19_0(int a, double b, unsigned char c) {
	int t = gs.a[5] << 12;
	ji = t;
}
void rs_3_08_19_1(int a, double b, unsigned char c) {
	if (r0()) vu(32767 % 7);
}
void rs_3_08_19_2(int a, double b, unsigned char c) {
	gs.c += gc2;
}
void rs_3_08_19_3(int a, double b, unsigned char c) {
	int t = ji;
	v0();
	gi = t;
}
int rs_3_08_19_4(int a, double b, unsigned char c) {
	int t = ji;
	v0();
	return ((int)*gp & gi) | (100 ^ t);
}
void rs_3_09_00_0(int a, int b, unsigned int c) {
	char *t = gs.p;
	jp = t;
}
void rs_3_09_00_1(int a, int b, unsigned int c) {
	int *u = gpi;
	jpi = u;
}
void rs_3_09_00_2(int a, int b, unsigned int c) {
	int *u = jpi;
	u--;
}
void rs_3_09_00_3(int a, int b, unsigned int c) {
	vd((*gpi <= a ? gd2 : gd2));
}
void rs_3_09_00_4(int a, int b, unsigned int c) {
	char *t = jp;
	v0();
	vp(t);
}
void rs_3_09_00_5(int a, int b, unsigned int c) {
	gp[0] *= 10;
}
void rs_3_09_00_6(int a, int b, unsigned int c) {
	if (gs.l != 0) gs.l = 2L % gs.l;
}
unsigned long rs_3_09_00_7(int a, int b, unsigned int c) {
	return gula[c] * 4UL;
}
void rs_3_09_01_0(double a, unsigned char b) {
	long t = (long)(gc < gc2);
	jl = t;
}
void rs_3_09_01_1(double a, unsigned char b) {
	double u = gd2;
	jd = u;
}
void rs_3_09_01_2(double a, unsigned char b) {
	gia[b] = gpi[2];
}
void rs_3_09_01_3(double a, unsigned char b) {
	double u = jd;
	gd = u;
}
void rs_3_09_01_4(double a, unsigned char b) {
	gpi = gpi + b;
}
void rs_3_09_01_5(double a, unsigned char b) {
	gpi = gpi + b;
}
void rs_3_09_01_6(double a, unsigned char b) {
	long t = jl;
	vl(t);
}
char * rs_3_09_01_7(double a, unsigned char b) {
	return gp;
}
void rs_3_09_02_0(void) {
	int *t = gpi;
	jpi = t;
}
void rs_3_09_02_1(void) {
	int *t = jpi;
	v1(*t);
}
void rs_3_09_02_2(void) {
	vl(((gul = 54902UL) >= 4UL ? gl : gps->l));
}
void rs_3_09_02_3(void) {
	gul = gula[4] = gula[6];
}
char * rs_3_09_02_4(void) {
	return gp;
}
void rs_3_09_03_1(struct st *a, unsigned char b) {
	gpi = rpi(gi);
}
void rs_3_09_03_2(struct st *a, unsigned char b) {
	gla[5] >>= (b & 15);
}
void rs_3_09_03_3(struct st *a, unsigned char b) {
	int i = ji;
	v0();
	for (i = 12; i > 0; i--) { gula[b] = rul(gula[i] % 7UL); }
}
void rs_3_09_03_4(struct st *a, unsigned char b) {
	gu = (unsigned int)(((unsigned long)gl2) * gula[3]);
}
void rs_3_09_03_5(struct st *a, unsigned char b) {
	gps->u = ~gu;
}
void rs_3_09_04_0(void) {
	int *t = gpi;
	jpi = t;
}
void rs_3_09_04_1(void) {
	v2(gia[1] & gs.a[7], gi);
}
void rs_3_09_04_2(void) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_3_09_04_3(void) {
	gs.c -= gc2;
}
void rs_3_09_04_4(void) {
	--gp;
}
int rs_3_09_04_5(void) {
	return *gpi;
}
void rs_3_09_05_0(int a) {
	long t = 17740L;
	jl = t;
}
void rs_3_09_05_1(int a) {
	a >>= 10;
}
void rs_3_09_05_2(int a) {
	long t = jl;
	if (t != 0) gla[a] = -55012L % t;
}
long rs_3_09_05_3(int a) {
	long t = jl;
	return t;
}
void rs_3_09_06_0(long a) {
	int t = gps->a[3];
	ji = t;
}
void rs_3_09_06_1(long a) {
	int u = gi3;
	ji = u;
}
void rs_3_09_06_2(long a) {
	int t = ji;
	v1(t);
}
void rs_3_09_06_3(long a) {
	int u = ji;
	v0();
	switch (gi2) { case 0: gua[0] %= 7; break; case 1: v2(u, gi); case 2: *gpi *= 10; break; case 3: gl2 >>= 16; break; case 4: case 5: vu(gu); break; default: vp(gp); break; }
}
void rs_3_09_06_4(long a) {
	gp--;
}
void rs_3_09_06_5(long a) {
	--gul;
}
void rs_3_09_06_6(long a) {
	gu++;
}
void rs_3_09_06_7(long a) {
	gps->p = &gca[3];
}
int rs_3_09_06_8(long a) {
	return gi3;
}
void rs_3_09_07_1(char a, struct st *b, long c) {
	int t = 255;
	ji = t;
}
void rs_3_09_07_2(char a, struct st *b, long c) {
	v1(r0());
}
void rs_3_09_07_3(char a, struct st *b, long c) {
	int i = ji;
	int t = ji;
	v0();
	for (i = 0; i < 6; i++) { gul++; gs.i = (gi2 + t) - t; }
}
void rs_3_09_07_4(char a, struct st *b, long c) {
	int i = ji;
	v0();
	for (i = 0; i < 2; i++) { vp(gs.p); gl *= 6L; vd(gd2 - gda[1]); }
}
void rs_3_09_07_5(char a, struct st *b, long c) {
	int i = ji;
	v0();
	gs.i = 2;
}
void rs_3_09_07_6(char a, struct st *b, long c) {
	c = c ^ ((long)!((unsigned long)gps->u));
}
unsigned int rs_3_09_07_7(char a, struct st *b, long c) {
	return gu >> 7;
}
void rs_3_09_08_0(unsigned long a, struct st *b) {
	gpi[3] = gi2 = gia[1];
}
void rs_3_09_08_1(unsigned long a, struct st *b) {
	if (gul != 0) gula[6] = 70762UL / gul;
}
void rs_3_09_08_2(unsigned long a, struct st *b) {
	gda[2] -= gd;
}
unsigned long rs_3_09_08_3(unsigned long a, struct st *b) {
	return rul((!gu2 ? gul : ((unsigned long)guca[0])));
}
void rs_3_09_09_0(long a) {
	unsigned int t = gua[2];
	ju = t;
}
void rs_3_09_09_1(long a) {
	guca[3] = guc;
}
void rs_3_09_09_2(long a) {
	unsigned int t = ju;
	t = ~gu2 ^ ru(t);
}
void rs_3_09_09_3(long a) {
	v2(gi2, gpi[0]);
}
void rs_3_09_09_4(long a) {
	unsigned int t = ju;
	v0();
	gul = gul ^ (gps->l > a ? gul : gula[t]);
}
int rs_3_09_09_5(long a) {
	return ((41 - gp[3]) < (8 & gc));
}
void rs_3_09_10_1(int a, long b) {
	unsigned char t = (gi <= gi3 ? guc : ((unsigned char)gla[a]));
	juc = t;
}
void rs_3_09_10_2(int a, long b) {
	int i = ji;
	unsigned char t = juc;
	switch (gu2) { case 0: v0(); break; case 1: vc(*gp); case 2: v1(gps->i); break; default: t = ~255; break; }
}
void rs_3_09_10_3(int a, long b) {
	int i = ji;
	v0();
	for (i = 0; i < a; i++) { gd = gda[1]; gi2 = 100; }
}
void rs_3_09_10_4(int a, long b) {
	gp--;
}
unsigned long rs_3_09_10_5(int a, long b) {
	return rul(gula[a]) % 10UL;
}
void rs_3_09_11_1(unsigned int a) {
	unsigned char t = guc;
	juc = t;
}
void rs_3_09_11_2(unsigned int a) {
	int *u = rpi(gs.a[a]);
	jpi = u;
}
void rs_3_09_11_3(unsigned int a) {
	unsigned char t = juc;
	v0();
	gs.d = gd2 + (double)gca[t];
}
void rs_3_09_11_4(unsigned int a) {
	unsigned char t = juc;
	v0();
	guc = t;
}
void rs_3_09_11_5(unsigned int a) {
	int i = ji;
	int *u = jpi;
	v0();
	i = 0; while (i < 3) { vp(gs.p); gs.u = 256 >> 3; i++; }
}
void rs_3_09_11_6(unsigned int a) {
	int *u = jpi;
	v0();
	gpi = u;
}
unsigned long rs_3_09_11_7(unsigned int a) {
	return rul(0x10000UL + gul);
}
void rs_3_09_12_0(void) {
	char t = gca[4] - 2;
	jc = t;
}
void rs_3_09_12_1(void) {
	char t = jc;
	gu -= ru(gua[t]);
}
void rs_3_09_12_2(void) {
	vl(gs.l << 3);
}
void rs_3_09_12_3(void) {
	gul <<= 26;
}
void rs_3_09_12_4(void) {
	v0();
}
void rs_3_09_12_5(void) {
	char t = jc;
	v0();
	if ('a' != t) { if (t != 0) gc2 = 8 % t; }
}
void rs_3_09_13_0(char *a) {
	long t = (long)gc2 ^ *gpl;
	jl = t;
}
void rs_3_09_13_1(char *a) {
	unsigned long u = (unsigned long)gl;
	jul = u;
}
void rs_3_09_13_2(char *a) {
	gs.c -= gc2 - 9;
}
void rs_3_09_13_3(char *a) {
	long t = jl;
	unsigned long u = jul;
	if ((t = *gpl) >= 3511L || gul >= 3UL) u = 1UL >> 29;
}
int rs_3_09_13_4(char *a) {
	return ((int)((unsigned char)gu)) >> 3;
}
void rs_3_09_14_0(void) {
	double t = gs.d;
	jd = t;
}
void rs_3_09_14_1(void) {
	unsigned char u = ((unsigned char)gl) % 3;
	juc = u;
}
void rs_3_09_14_2(void) {
	double t = jd;
	vd(t);
}
void rs_3_09_14_3(void) {
	gi3 = ~(gi ^ gps->a[6]);
}
void rs_3_09_14_4(void) {
	unsigned char u = juc;
	v0();
	gpi = gpi + u;
}
unsigned int rs_3_09_14_5(void) {
	return gu;
}
void rs_3_09_15_0(unsigned char a, char b, int c) {
	gu -= (unsigned int)!37194UL;
}
void rs_3_09_15_1(unsigned char a, char b, int c) {
	gu2 <<= 4;
}
void rs_3_09_15_2(unsigned char a, char b, int c) {
	gula[b] = gula[a] | 5UL;
}
int rs_3_09_15_3(unsigned char a, char b, int c) {
	return (gi2 + gs.i) * (8 - (int)gc2);
}
void rs_3_09_16_0(void) {
	if (gca[6] != 0) gs.c = 'a' % gca[6];
}
void rs_3_09_16_1(void) {
	switch (gps->c) { case 1: gula[7] = gula[0]; break; case 2: vs(gps); break; case 100: vc(gc2); break; default: vl((long)gul); break; }
}
void rs_3_09_16_2(void) {
	gula[6] = 6UL;
}
void rs_3_09_16_3(void) {
	vc(*gp + 7);
}
void rs_3_09_16_4(void) {
	if (!gps->i) { gda[1] = gs.d; vl(gs.l >> 3); } else { guca[6] = guc << 3; }
}
long rs_3_09_16_5(void) {
	return gla[5];
}
void rs_3_09_17_0(char *a, char b) {
	int t = 2 / 3;
	ji = t;
}
void rs_3_09_17_1(char *a, char b) {
	guc = (unsigned char)(gul / 3UL);
}
void rs_3_09_17_2(char *a, char b) {
	gu2 = gu;
}
void rs_3_09_17_3(char *a, char b) {
	guc = guc + ~guca[6];
}
void rs_3_09_17_4(char *a, char b) {
	int t = ji;
	gi = t;
}
void rs_3_09_18_0(void) {
	guc /= 3;
}
void rs_3_09_18_1(void) {
	if (gi2 < gia[6]) { gia[0] /= 16; }
}
void rs_3_09_19_0(void) {
	unsigned long t = (unsigned long)guca[4];
	jul = t;
}
void rs_3_09_19_1(void) {
	int u = gps->a[2] | gi3;
	ji = u;
}
void rs_3_09_19_2(void) {
	int u = ji;
	guca[u] = ~5;
}
void rs_3_09_19_3(void) {
	gs.d += 0.25 / 10.0;
}
void rs_3_09_19_4(void) {
	unsigned long t = jul;
	vl((long)t);
}
void rs_3_09_19_5(void) {
	int u = ji;
	v0();
	switch (gl) { case 0L: u = gia[5] / 7; break; case 1L: vp(gp); break; default: gd = gs.d; break; }
}
void rs_3_09_19_6(void) {
	gd2 += gda[1] - gd;
}
void rs_3_09_19_7(void) {
	int u = ji;
	v0();
	switch (gps->u) { case 0: guc = guc % 16; break; case 1: guc = guc - guca[0]; break; case 2: gi2 = gs.i; break; case 3: gps->l = *gpl; default: gpl[0] = gl = 65536L; break; }
}
int rs_3_09_19_8(void) {
	return (int)rl(gl);
}
