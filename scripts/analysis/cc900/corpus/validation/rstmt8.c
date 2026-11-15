/* Every statement line of random8 alone in its own function (gen_rstmt.py corpus/validation/random8 8): rs_<A>_<BB>_<CC>_<k> is line k of
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

void rs_8_00_00_0(unsigned int a, unsigned long b) {
	vu(gua[7] - a);
}
void rs_8_00_00_1(unsigned int a, unsigned long b) {
	vd(gda[2]);
}
unsigned int rs_8_00_00_2(unsigned int a, unsigned long b) {
	return 2432;
}
void rs_8_00_01_0(void) {
	int t = 16;
	ji = t;
}
void rs_8_00_01_1(void) {
	long u = (gps->c ? *gpl : gps->l);
	jl = u;
}
void rs_8_00_01_2(void) {
	long u = jl;
	gl = u;
}
void rs_8_00_01_3(void) {
	int t = ji;
	gia[t] |= gi3 >> 3;
}
void rs_8_00_01_4(void) {
	gu = ((unsigned int)(guc < 255)) | gu2;
}
int rs_8_00_01_5(void) {
	int t = ji;
	return ((int)guca[t] - gpi[0]) % 100;
}
void rs_8_00_02_0(int a, int b) {
	int *t = gpi;
	jpi = t;
}
void rs_8_00_02_1(int a, int b) {
	unsigned int u = gua[4] << 8;
	ju = u;
}
void rs_8_00_02_2(int a, int b) {
	unsigned int u = ju;
	gu = u;
}
void rs_8_00_02_3(int a, int b) {
	while (b > 0) { gi += *gpi++; b--; }
}
void rs_8_00_02_4(int a, int b) {
	vd(gda[2] + 3.0);
}
void rs_8_00_02_5(int a, int b) {
	int *t = jpi;
	v0();
	gpi = t;
}
int * rs_8_00_02_6(int a, int b) {
	unsigned int u = ju;
	v0();
	return gpi + u;
}
void rs_8_00_03_1(void) {
	int i = ji;
	for (i = 0; i < 4; i++) { gul = gula[i] = 9UL; guc++; gi = gi3; }
}
void rs_8_00_03_2(void) {
	gps->c ^= rc(gi2);
}
void rs_8_00_03_3(void) {
	gp++;
}
void rs_8_00_03_4(void) {
	gla[2] = gl = *gpl;
}
unsigned long rs_8_00_03_5(void) {
	return (gul * gula[7]) & (gula[4] >> 23);
}
void rs_8_00_04_0(unsigned int a) {
	int *t = rpi(gpi[2]);
	jpi = t;
}
void rs_8_00_04_1(unsigned int a) {
	char *u = rp();
	v0();
	jp = u;
}
void rs_8_00_04_2(unsigned int a) {
	--gi3;
}
void rs_8_00_04_3(unsigned int a) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_8_00_04_4(unsigned int a) {
	if (guc >= 128) if (gpl[0] != 0) *gpl = gpl[1] / gpl[0];
}
void rs_8_00_04_5(unsigned int a) {
	char *u = jp;
	v0();
	vp(u);
}
unsigned long rs_8_00_04_6(unsigned int a) {
	return (gs.a[a] >= gi3 ? (gul + gula[a]) : (gul - 0x10000UL));
}
void rs_8_00_05_1(int a, unsigned long b, int *c) {
	char *t = gps->p;
	jp = t;
}
void rs_8_00_05_2(int a, unsigned long b, int *c) {
	char *t = jp;
	vp(t);
}
void rs_8_00_05_3(int a, unsigned long b, int *c) {
	int i = ji;
	v0();
	i = 0; while (i < 6) { gs.c -= rc(gi3); gua[i] += gs.u * gu2; gs.u *= 12; i++; }
}
void rs_8_00_05_4(int a, unsigned long b, int *c) {
	guca[0] = guc / 3;
}
void rs_8_00_05_5(int a, unsigned long b, int *c) {
	v1(gia[a]);
}
int * rs_8_00_05_6(int a, unsigned long b, int *c) {
	return gpi;
}
void rs_8_00_06_0(int a) {
	int *t = rpi(1);
	jpi = t;
}
void rs_8_00_06_1(int a) {
	unsigned long u = gul + gula[a];
	v0();
	jul = u;
}
void rs_8_00_06_2(int a) {
	unsigned long u = jul;
	v0();
	u = (u - gula[0]) >> 5;
}
void rs_8_00_06_3(int a) {
	int *t = jpi;
	v0();
	gpi = t;
}
void rs_8_00_06_4(int a) {
	unsigned long u = jul;
	v0();
	if (gs.l == gl || u == gula[a]) { if (gla[a] != 0) gpl[1] = gl / gla[a]; } else { u--; gp++; }
}
unsigned long rs_8_00_06_5(int a) {
	return gul;
}
void rs_8_00_07_0(unsigned int a) {
	char *t = gp;
	jp = t;
}
void rs_8_00_07_1(unsigned int a) {
	switch (gc2) { case 0: gpi = gpi + a; case 1: v2(gi2, gpi[2]); break; default: gi2 = gi3; break; }
}
void rs_8_00_07_2(unsigned int a) {
	vu(gps->u * 4);
}
void rs_8_00_07_3(unsigned int a) {
	gul = -9601UL * gul;
}
void rs_8_00_07_4(unsigned int a) {
	gpl[2] = (65536L / 100L) | (-46746L + gl2);
}
void rs_8_00_07_5(unsigned int a) {
	char *t = jp;
	v0();
	vp(t);
}
char rs_8_00_07_6(unsigned int a) {
	return -(~(char)gula[a]);
}
void rs_8_00_08_0(char a, char b, long *c) {
	unsigned char t = guc;
	juc = t;
}
void rs_8_00_08_1(char a, char b, long *c) {
	if (gc2 != 0) gc = (char)gu % gc2;
}
void rs_8_00_08_2(char a, char b, long *c) {
	unsigned char t = juc;
	guc = t;
}
void rs_8_00_08_3(char a, char b, long *c) {
	vs(gps);
}
unsigned long rs_8_00_08_4(char a, char b, long *c) {
	return 0x10000UL;
}
void rs_8_00_09_0(int a, char b) {
	unsigned char t = 255 + guc;
	juc = t;
}
void rs_8_00_09_1(int a, char b) {
	if (gu & 4) gia[3] -= gi3 - 8;
}
void rs_8_00_09_2(int a, char b) {
	unsigned char t = juc;
	t = ((unsigned char)(gp[1] > gps->c)) / 16;
}
int rs_8_00_09_3(int a, char b) {
	if (r0() && *gpl) return *gpi & gps->i;
}
int rs_8_00_09_4(int a, char b) {
	return -(*gpi >> 15);
}
void rs_8_00_10_0(char a, unsigned long b) {
	unsigned char t = (0 == '9' ? guc : guc);
	juc = t;
}
void rs_8_00_10_1(char a, unsigned long b) {
	unsigned char u = guca[5];
	juc = u;
}
void rs_8_00_10_2(char a, unsigned long b) {
	unsigned char u = juc;
	gula[u] /= 2UL;
}
void rs_8_00_10_3(char a, unsigned long b) {
	unsigned char u = juc;
	gua[a] = -gs.u;
}
void rs_8_00_10_4(char a, unsigned long b) {
	if (r1(gi2)) if (gps->l != 0) gpl[3] = 65536L / gps->l;
}
void rs_8_00_10_5(char a, unsigned long b) {
	unsigned char t = juc;
	v0();
	v1(t);
}
void rs_8_00_10_6(char a, unsigned long b) {
	++gpi;
}
void rs_8_00_11_0(unsigned int a, int *b) {
	int *t = b + a;
	jpi = t;
}
void rs_8_00_11_1(unsigned int a, int *b) {
	int *t = jpi;
	v1(*t);
}
void rs_8_00_11_2(unsigned int a, int *b) {
	gps->u = (gua[7] >> 2) * 4;
}
void rs_8_00_11_3(unsigned int a, int *b) {
	gl2++;
}
void rs_8_00_12_1(int a) {
	guca[a] &= 6 / 100;
}
void rs_8_00_12_2(int a) {
	int i = ji;
	for (i = 0; i < 6; i++) { if (gl2 != 0) gla[i] = gl / gl2; gs.d -= gd2 / 100.0; }
}
void rs_8_00_12_3(int a) {
	gla[a] = gl2;
}
void rs_8_00_12_4(int a) {
	vs(gps);
}
void rs_8_00_12_5(int a) {
	gla[a] = gpl[2];
}
char rs_8_00_12_6(int a) {
	return *gp;
}
void rs_8_00_13_0(unsigned long a, int b, int c) {
	if (gs.u != 0) gu2 = ((unsigned int)a) / gs.u;
}
void rs_8_00_13_1(unsigned long a, int b, int c) {
	gi = (int)(gla[3] % 16L);
}
void rs_8_00_14_0(int a, int b) {
	long t = gl / 4L;
	jl = t;
}
void rs_8_00_14_1(int a, int b) {
	int u = (int)guc;
	ji = u;
}
void rs_8_00_14_2(int a, int b) {
	int u = ji;
	v1(u);
}
void rs_8_00_14_3(int a, int b) {
	long t = jl;
	v0();
	gl = t;
}
void rs_8_00_14_4(int a, int b) {
	if (gps->l) gs.p = &gca[6];
}
void rs_8_00_14_5(int a, int b) {
	--gl;
}
void rs_8_00_14_6(int a, int b) {
	guc--;
}
int rs_8_00_14_7(int a, int b) {
	return ((gca[b] % 100) > ('9' - gs.c));
}
void rs_8_00_15_1(char a, unsigned char b, unsigned int c) {
	char *t = &gca[5];
	jp = t;
}
void rs_8_00_15_2(char a, unsigned char b, unsigned int c) {
	guca[1] += guca[b] - guca[7];
}
int rs_8_00_15_3(char a, unsigned char b, unsigned int c) {
	char *t = jp;
	if (!t[1]) return gi2 % 2;
}
void rs_8_00_15_4(char a, unsigned char b, unsigned int c) {
	int i = ji;
	for (i = 0; i < 16; i++) { if (gua[i] != 0) gps->u = gu2 / gua[i]; }
}
int rs_8_00_15_5(char a, unsigned char b, unsigned int c) {
	return !gl ^ gi;
}
void rs_8_00_16_1(char a, int b) {
	unsigned long t = 6UL << 6;
	jul = t;
}
void rs_8_00_16_2(char a, int b) {
	double u = gs.d;
	jd = u;
}
void rs_8_00_16_3(char a, int b) {
	double u = jd;
	gd = u;
}
void rs_8_00_16_4(char a, int b) {
	switch (gc2) { case 3: gi2 = gps->a[a] = b << 3; break; case 16: gla[2] += gla[b]; break; case 100: *gp = gs.c; break; }
}
void rs_8_00_16_5(char a, int b) {
	if (gi3 != 255) if (gul != 0) gula[0] = ((unsigned long)guc) / gul;
}
void rs_8_00_16_6(char a, int b) {
	int i = ji;
	unsigned long t = jul;
	for (i = 6; i > 0; i--) { vl(0L); if (gul != 0) t = t % gul; if (gu != 0) gua[i] = gu % gu; }
}
char rs_8_00_16_7(char a, int b) {
	return gps->c;
}
void rs_8_00_17_0(unsigned char a, int b, unsigned int c) {
	int *t = gpi;
	jpi = t;
}
void rs_8_00_17_1(unsigned char a, int b, unsigned int c) {
	char *u = gp;
	jp = u;
}
void rs_8_00_17_2(unsigned char a, int b, unsigned int c) {
	gula[a] = (gula[b] + 7UL) | gul;
}
void rs_8_00_17_3(unsigned char a, int b, unsigned int c) {
	--a;
}
void rs_8_00_17_4(unsigned char a, int b, unsigned int c) {
	char *u = jp;
	vp(u);
}
void rs_8_00_17_5(unsigned char a, int b, unsigned int c) {
	int *t = jpi;
	v0();
	gpi = t;
}
int rs_8_00_17_6(unsigned char a, int b, unsigned int c) {
	return b & (gs.i & b);
}
void rs_8_00_18_0(unsigned int a, char b, char c) {
	unsigned char t = guca[7] * ((unsigned char)gu2);
	juc = t;
}
void rs_8_00_18_1(unsigned int a, char b, char c) {
	char u = 8 >> 5;
	jc = u;
}
void rs_8_00_18_2(unsigned int a, char b, char c) {
	unsigned char t = juc;
	gps->a[t] >>= 8;
}
void rs_8_00_18_3(unsigned int a, char b, char c) {
	char u = jc;
	a += gs.u;
}
void rs_8_00_18_4(unsigned int a, char b, char c) {
	vp(gp);
}
void rs_8_00_18_5(unsigned int a, char b, char c) {
	gpi++;
}
int rs_8_00_18_6(unsigned int a, char b, char c) {
	return (guc ? 256 : (gi2 << 6));
}
void rs_8_00_19_0(char a) {
	vl(gla[2]);
}
void rs_8_00_19_1(char a) {
	if (r1(gi3)) { gula[a] ^= gula[7] & 0x10000UL; if (gula[a] != 0) gula[6] = gula[a] % gula[a]; }
}
void rs_8_00_19_2(char a) {
	if (2 > gi) { gc2 = gs.c & gps->c; v0(); } else { gd2 *= (gu2 & 4 ? gda[1] : gd2); a = gc2 = gp[1]; if (gi != 0) gps->a[a] = gps->i / gi; }
}
void rs_8_00_19_3(char a) {
	gi = ~(gl2 > *gpl ? (int)gs.u : (int)guc);
}
char rs_8_00_19_4(char a) {
	return (char)(ru(gu2) <= -gu);
}
void rs_8_01_00_1(int a, unsigned long b) {
	int i = ji;
	int t = -676 + gs.i;
	ji = t;
}
void rs_8_01_00_2(int a, unsigned long b) {
	int t = ji;
	int u = 16 * gs.a[t];
	ji = u;
}
void rs_8_01_00_3(int a, unsigned long b) {
	int i = ji;
	for (i = 15; i > 0; i--) { *gpl = gl ^ gla[i]; b |= gula[i] - 0x10000UL; --gc2; }
}
void rs_8_01_00_4(int a, unsigned long b) {
	int t = ji;
	guca[t] = (unsigned char)!(guca[7] - 5);
}
void rs_8_01_00_5(int a, unsigned long b) {
	int u = ji;
	v1(u);
}
void rs_8_01_00_6(int a, unsigned long b) {
	gp = gps->p;
}
int rs_8_01_00_7(int a, unsigned long b) {
	return (int)gu2;
}
void rs_8_01_01_0(char *a, int b) {
	int *t = gpi;
	jpi = t;
}
char * rs_8_01_01_1(char *a, int b) {
	if (!gua[0]) return gs.p + b;
}
void rs_8_01_01_2(char *a, int b) {
	gs.c = 5;
}
void rs_8_01_01_3(char *a, int b) {
	int *t = jpi;
	v1(*t);
}
void rs_8_01_01_4(char *a, int b) {
	gula[b] = ((guca[b] = guca[6]) < 0 ? gula[b] : gul);
}
void rs_8_01_01_5(char *a, int b) {
	gul *= 6UL;
}
void rs_8_01_01_6(char *a, int b) {
	vd(-(double)*gp);
}
char * rs_8_01_01_7(char *a, int b) {
	return gs.p;
}
void rs_8_01_02_0(void) {
	unsigned long t = gul - 0x10000UL;
	jul = t;
}
void rs_8_01_02_1(void) {
	unsigned char u = ~236;
	juc = u;
}
void rs_8_01_02_2(void) {
	unsigned long t = jul;
	switch (gu2) { case 0: vd(gd); break; case 1: case 2: gc += *gp; case 3: gl = gl << 2; break; default: t = -t; break; }
}
void rs_8_01_02_3(void) {
	unsigned char u = juc;
	v0();
	guc = u;
}
void rs_8_01_02_4(void) {
	gl++;
}
unsigned long rs_8_01_02_5(void) {
	unsigned long t = jul;
	v0();
	return t;
}
void rs_8_01_03_0(unsigned long a, int b) {
	++guc;
}
void rs_8_01_03_1(unsigned long a, int b) {
	while (b > 0) { gi2 += *gpi++; b--; }
}
void rs_8_01_03_2(unsigned long a, int b) {
	gl2++;
}
void rs_8_01_03_3(unsigned long a, int b) {
	if (r0()) gca[b] = ~gp[0];
}
unsigned long rs_8_01_03_4(unsigned long a, int b) {
	return (a & 1 ? gula[6] : gula[0]) - a;
}
void rs_8_01_04_1(unsigned long a, unsigned int b, int *c) {
	int i = ji;
	int t = gps->a[0] | gs.i;
	ji = t;
}
void rs_8_01_04_2(unsigned long a, unsigned int b, int *c) {
	unsigned long u = gul;
	jul = u;
}
void rs_8_01_04_3(unsigned long a, unsigned int b, int *c) {
	int t = ji;
	gul ^= gula[t] * 0x10000UL;
}
void rs_8_01_04_4(unsigned long a, unsigned int b, int *c) {
	int t = ji;
	gua[b] |= gua[t] + b;
}
void rs_8_01_04_5(unsigned long a, unsigned int b, int *c) {
	int i = ji;
	unsigned long u = jul;
	for (i = 15; i > 0; i--) { gl2 = (long)((guc | 34) == (((unsigned char)*gpi) + guc)); if (gps->l != 0) gla[i] = gla[i] % gps->l; if (gu2 != 0) b = gs.u % gu2; }
}
void rs_8_01_04_6(unsigned long a, unsigned int b, int *c) {
	int t = ji;
	gua[t] %= 2;
}
void rs_8_01_05_1(unsigned long a) {
	if (gs.u > gu2 && r1(277)) vs(gps);
}
void rs_8_01_05_2(unsigned long a) {
	int i = ji;
	v0();
	for (i = 14; i > 0; i--) { gs.u = gps->u + gs.u; }
}
int * rs_8_01_05_3(unsigned long a) {
	return gpi;
}
void rs_8_01_06_1(void) {
	int i = ji;
	i = 0; while (i < 6) { vl((long)guc << (i & 15)); gua[i] = gs.u; i++; }
}
void rs_8_01_06_2(void) {
	gps->p = rp();
}
void rs_8_01_06_3(void) {
	gi3++;
}
unsigned long rs_8_01_06_4(void) {
	if (guc > 2) return gula[3] + gul;
}
void rs_8_01_06_5(void) {
	gu2 /= 7;
}
unsigned long rs_8_01_06_6(void) {
	return (gula[4] = gul);
}
void rs_8_01_07_0(unsigned long a) {
	int t = gi;
	ji = t;
}
void rs_8_01_07_1(unsigned long a) {
	long u = gla[1] % 4L;
	jl = u;
}
void rs_8_01_07_2(unsigned long a) {
	--gc;
}
void rs_8_01_07_3(unsigned long a) {
	vu(gua[6] / 4);
}
void rs_8_01_07_4(unsigned long a) {
	int t = ji;
	long u = jl;
	v0();
	u = (gs.l & u) << (t & 15);
}
int rs_8_01_07_5(unsigned long a) {
	int t = ji;
	v0();
	return (t << 11) - gps->a[t];
}
void rs_8_01_08_0(void) {
	unsigned int t = gua[0] / 10;
	ju = t;
}
void rs_8_01_08_1(void) {
	int *u = rpi(gia[5]);
	jpi = u;
}
void rs_8_01_08_2(void) {
	unsigned int t = ju;
	v0();
	gla[t] = gla[0] - gl;
}
void rs_8_01_08_3(void) {
	v2(8 | 2, gi);
}
void rs_8_01_08_4(void) {
	int *u = jpi;
	v0();
	v1(*u);
}
void rs_8_01_08_5(void) {
	unsigned int t = ju;
	v0();
	gul = ((unsigned long)guca[t]) % 2UL;
}
void rs_8_01_08_6(void) {
	unsigned int t = ju;
	v0();
	if (gul != 82468UL) { if (gp[0] != 0) gca[1] = gca[t] / gp[0]; if (gi3 != 0) gps->a[t] = 100 % gi3; gpl[3] = gl; } else { guca[5] = guca[0] % 7; guc = ((unsigned char)gs.l) ^ (2 | guca[6]); }
}
unsigned long rs_8_01_08_7(void) {
	unsigned int t = ju;
	v0();
	return gula[t] - (gula[t] & ((unsigned long)gl2));
}
void rs_8_01_09_0(unsigned int a, char *b, char c) {
	unsigned long t = gula[6] / 16UL;
	jul = t;
}
void rs_8_01_09_1(unsigned int a, char *b, char c) {
	int *u = gpi + a;
	jpi = u;
}
void rs_8_01_09_2(unsigned int a, char *b, char c) {
	unsigned long t = jul;
	if (gs.i == 256 || ((unsigned long)gu2) > 83581UL) { t = gul & (gula[4] >> 19); guca[5] %= 2; } else { if (guca[3] < guc) guca[6] = guc + guca[7]; }
}
long rs_8_01_09_3(unsigned int a, char *b, char c) {
	if (!gs.l) return gs.l;
}
void rs_8_01_09_4(unsigned int a, char *b, char c) {
	int *u = jpi;
	if (gpl[1] >= gps->l && (gl = -1278L) != 65536L) { gl = gps->l = rl(gl ^ gpl[1]); } else { if (gu != 0) gu = gs.u % gu; v1((guca[1] <= 130)); gpi[3] = r2(gi2, *gpi); }
}
long rs_8_01_09_5(unsigned int a, char *b, char c) {
	return gpl[3] + gl2;
}
void rs_8_01_10_0(unsigned char a, long b, long *c) {
	vp(&gca[a]);
}
void rs_8_01_10_1(unsigned char a, long b, long *c) {
	guca[a] = 55 << 3;
}
char rs_8_01_10_2(unsigned char a, long b, long *c) {
	return ((char)gul * '9') & rc((int)gps->u);
}
void rs_8_01_11_1(int a) {
	unsigned char t = ~guc;
	juc = t;
}
void rs_8_01_11_2(int a) {
	unsigned char t = juc;
	guc = t;
}
void rs_8_01_11_3(int a) {
	int i = ji;
	i = 2; do { vu(ru(gps->u)); } while (--i > 0);
}
void rs_8_01_11_4(int a) {
	gc--;
}
long rs_8_01_11_5(int a) {
	return rl(gl2);
}
void rs_8_01_12_1(void) {
	int i = ji;
	i = 15; do { gul *= 11UL; if (gs.l != 0) *gpl = gps->l % gs.l; if (gps->l != 0) gs.l = gpl[0] / gps->l; } while (--i > 0);
}
void rs_8_01_12_2(void) {
	if (!*gp) { gp = &gca[7]; if (gla[1] != 0) *gpl = *gpl % gla[1]; guca[7] = (5 + 128) - guca[6]; } else { if (gu2) gps->p = gp + 1; }
}
void rs_8_01_12_3(void) {
	int i = ji;
	v2(gps->i - gi, gi);
}
char rs_8_01_12_4(void) {
	if (gca[3] & 0x7) return (' ') - 'A';
}
char rs_8_01_12_5(void) {
	return (char)!(~gpl[0]);
}
void rs_8_01_13_1(char a, unsigned char b) {
	*gpl = rl(gs.l);
}
void rs_8_01_13_2(char a, unsigned char b) {
	int i = ji;
	v0();
	for (i = 0; i < 7; i++) { gc2 = rc(16); vs(gps); if (gua[i] != 0) gua[0] = 2853 / gua[i]; }
}
void rs_8_01_13_3(char a, unsigned char b) {
	v0();
}
void rs_8_01_14_1(struct st *a, char *b) {
	unsigned int t = (unsigned int)(guc > 128);
	ju = t;
}
void rs_8_01_14_2(struct st *a, char *b) {
	long u = a->l + gl2;
	jl = u;
}
void rs_8_01_14_3(struct st *a, char *b) {
	int i = ji;
	unsigned int t = ju;
	long u = jl;
	for (i = 0; i < 15; i++) { if (gu2 != 0) a->u = t % gu2; if (gula[i] != 0) gul = gula[i] % gula[i]; }
}
void rs_8_01_14_4(struct st *a, char *b) {
	gul--;
}
void rs_8_01_14_5(struct st *a, char *b) {
	unsigned int t = ju;
	gula[t] = gula[7];
}
unsigned int rs_8_01_14_6(struct st *a, char *b) {
	unsigned int t = ju;
	return (6 == 4 ? (t % 10) : ((unsigned int)!guc));
}
void rs_8_01_15_0(unsigned char a, double b) {
	unsigned long t = gula[a];
	jul = t;
}
void rs_8_01_15_1(unsigned char a, double b) {
	gps->l = (gla[a] | gs.l) & gl;
}
void rs_8_01_15_2(unsigned char a, double b) {
	unsigned long t = jul;
	if (gla[0] > gl2) { if (gu != 0) gu = gu2 / gu; vd(b); t = 2UL << 12; }
}
void rs_8_01_15_3(unsigned char a, double b) {
	v2(gi2, (guc < guca[a]));
}
unsigned int rs_8_01_15_4(unsigned char a, double b) {
	return (gia[2] >= gi3 ? gu2 : gs.u) + 256;
}
void rs_8_01_16_0(struct st *a, char b) {
	gu = ru(gua[b] >> 9);
}
void rs_8_01_16_1(struct st *a, char b) {
	gia[b] = (int)guc;
}
void rs_8_01_16_2(struct st *a, char b) {
	if (!gula[b]) { if (gpl[0] != 0) gs.l = gla[b] % gpl[0]; vu(gu ^ 255); } else { gl2 %= 3L; gl2 = ~gl; gu2 &= 255; }
}
unsigned long rs_8_01_16_3(struct st *a, char b) {
	return (unsigned long)(guca[0] ^ guca[b]);
}
void rs_8_01_17_0(struct st *a, int b, int *c) {
	unsigned long t = gula[2] | gul;
	jul = t;
}
void rs_8_01_17_1(struct st *a, int b, int *c) {
	while (b-- > 0) { if (*c == 2) break; c++; }
}
void rs_8_01_17_2(struct st *a, int b, int *c) {
	vd(gd2);
}
void rs_8_01_17_3(struct st *a, int b, int *c) {
	gs.d -= gd;
}
void rs_8_01_17_4(struct st *a, int b, int *c) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
void rs_8_01_17_5(struct st *a, int b, int *c) {
	gs.d *= gda[1] + gd2;
}
int * rs_8_01_17_6(struct st *a, int b, int *c) {
	return &gia[b];
}
void rs_8_01_18_1(unsigned char a, unsigned char b, struct st *c) {
	char t = gca[7] + gca[a];
	jc = t;
}
void rs_8_01_18_2(unsigned char a, unsigned char b, struct st *c) {
	unsigned char u = a / 2;
	juc = u;
}
void rs_8_01_18_3(unsigned char a, unsigned char b, struct st *c) {
	int i = ji;
	unsigned char u = juc;
	for (i = 0; i < 5; i++) { vl(65536L); u = ((unsigned char)(255 <= c->u)) & b; }
}
void rs_8_01_18_4(unsigned char a, unsigned char b, struct st *c) {
	char t = jc;
	v0();
	gc = t;
}
void rs_8_01_18_5(unsigned char a, unsigned char b, struct st *c) {
	gl = gla[0];
}
int rs_8_01_18_6(unsigned char a, unsigned char b, struct st *c) {
	int i = ji;
	v0();
	if ((gi = gs.i)) return gi2;
}
int rs_8_01_18_7(unsigned char a, unsigned char b, struct st *c) {
	char t = jc;
	unsigned char u = juc;
	v0();
	return (gla[6] < gps->l) & (gia[u] - (int)t);
}
void rs_8_01_19_0(int a, char *b, struct st *c) {
	long t = rl((long)gul);
	jl = t;
}
void rs_8_01_19_1(int a, char *b, struct st *c) {
	unsigned int u = (unsigned int)(b[0] < '9');
	v0();
	ju = u;
}
void rs_8_01_19_2(int a, char *b, struct st *c) {
	vs(gps);
}
void rs_8_01_19_3(int a, char *b, struct st *c) {
	gd -= -gda[0];
}
void rs_8_01_19_4(int a, char *b, struct st *c) {
	unsigned int u = ju;
	v0();
	gu = u;
}
void rs_8_01_19_5(int a, char *b, struct st *c) {
	long t = jl;
	v0();
	vl(t);
}
void rs_8_02_00_0(int *a) {
	unsigned char t = guca[7];
	juc = t;
}
void rs_8_02_00_1(int *a) {
	int u = (int)62;
	ji = u;
}
void rs_8_02_00_2(int *a) {
	int u = ji;
	gl2 = gs.l | (a[3] ? (long)u : 65536L);
}
void rs_8_02_00_3(int *a) {
	int u = ji;
	if (*gpi != 0) u = gia[1] % *gpi;
}
void rs_8_02_00_4(int *a) {
	unsigned char t = juc;
	gu2 &= gua[t] * 11;
}
unsigned int rs_8_02_00_5(int *a) {
	if (*gp & 0x7) return gu2 & 32767;
}
void rs_8_02_00_6(int *a) {
	gpl[1] = gl2 = (long)gs.a[4] << 26;
}
unsigned int rs_8_02_00_7(int *a) {
	unsigned char t = juc;
	return gua[t];
}
void rs_8_02_01_1(int a) {
	int t = gpi[1] - gia[2];
	ji = t;
}
void rs_8_02_01_2(int a) {
	gps->u = ru(gps->u);
}
void rs_8_02_01_3(int a) {
	--gi;
}
void rs_8_02_01_4(int a) {
	int i = ji;
	v0();
	i = 10; do { gd = (gd2 + gd2) / 3.0; } while (--i > 0);
}
void rs_8_02_01_5(int a) {
	int t = ji;
	v0();
	gs.a[0] = t + gs.a[t];
}
void rs_8_02_01_6(int a) {
	int t = ji;
	v0();
	gpi = gpi + t;
}
char * rs_8_02_01_7(int a) {
	return &gca[7];
}
void rs_8_02_02_0(void) {
	unsigned long t = gula[1] >> 27;
	jul = t;
}
void rs_8_02_02_1(void) {
	unsigned long t = jul;
	unsigned long u = (unsigned long)(t != 55246UL);
	jul = u;
}
void rs_8_02_02_2(void) {
	v2(gi2, 255 - gs.i);
}
void rs_8_02_02_3(void) {
	unsigned long t = jul;
	unsigned long u = jul;
	v0();
	t = -u;
}
void rs_8_02_02_4(void) {
	v2(gi2, r2(gi2, gi));
}
void rs_8_02_02_5(void) {
	unsigned long t = jul;
	unsigned long u = jul;
	v0();
	if (gc2 & 2 && t) { gu = ru(gua[2] * 6); if (gp[1] != 0) gc = gca[6] / gp[1]; if (gi != 0) gi2 = gi / gi; } else { v1((gda[3] != gd2)); if (t != 0) t = u % t; guca[1] = (unsigned char)gc; }
}
void rs_8_02_02_6(void) {
	unsigned long u = jul;
	v0();
	if (gu & 1) { if (gl != 0) gl2 = gps->l / gl; gpi = &gia[4]; u = gula[4] = ~(((unsigned char)gc) != 128 ? u : u); } else { if (gua[1] != 0) gs.u = gps->u % gua[1]; gc += *gp; }
}
unsigned long rs_8_02_02_7(void) {
	return 0x10000UL / 100UL;
}
void rs_8_02_03_1(unsigned int a, int b, int c) {
	unsigned long t = 92813UL - 0UL;
	jul = t;
}
void rs_8_02_03_2(unsigned int a, int b, int c) {
	unsigned char u = 255;
	juc = u;
}
void rs_8_02_03_3(unsigned int a, int b, int c) {
	gp = gs.p;
}
void rs_8_02_03_4(unsigned int a, int b, int c) {
	int i = ji;
	if (*gpl != gps->l) { gi2 = r2(gi2, gi); if (gs.a[5] != 0) gi2 = gs.i / gs.a[5]; gda[3] *= gd2 * 10.0; }
}
void rs_8_02_03_5(unsigned int a, int b, int c) {
	unsigned long t = jul;
	v0();
	gul = t;
}
void rs_8_02_03_6(unsigned int a, int b, int c) {
	unsigned char u = juc;
	v0();
	v1(u);
}
void rs_8_02_03_7(unsigned int a, int b, int c) {
	int i = ji;
	v0();
	i = 0; while (i < b) { --gp; i++; }
}
unsigned long rs_8_02_03_8(unsigned int a, int b, int c) {
	unsigned long t = jul;
	v0();
	return (gula[b] | t) >> 12;
}
void rs_8_02_04_0(unsigned char a) {
	long u = jl;
	unsigned int t = gs.u * 256;
	ju = t;
}
void rs_8_02_04_1(unsigned char a) {
	long u = -(long)gula[2];
	jl = u;
}
void rs_8_02_04_2(unsigned char a) {
	unsigned int t = ju;
	if (gps->c < gc) { gi >>= (a & 15); } else { ++t; }
}
void rs_8_02_04_3(unsigned char a) {
	--gi2;
}
void rs_8_02_04_4(unsigned char a) {
	++gp;
}
void rs_8_02_04_5(unsigned char a) {
	gi3 = gs.a[0];
}
void rs_8_02_04_6(unsigned char a) {
	long u = jl;
	vl(u);
}
void rs_8_02_04_7(unsigned char a) {
	guc <<= 6;
}
int * rs_8_02_04_8(unsigned char a) {
	unsigned int t = ju;
	v0();
	return gpi + t;
}
void rs_8_02_05_0(void) {
	gps->c = rc(gs.a[6]);
}
void rs_8_02_05_1(void) {
	gps->l >>= 14;
}
void rs_8_02_05_2(void) {
	*gpi = (gul > gula[6]);
}
void rs_8_02_05_3(void) {
	*gp = gps->c = ~(gca[5] + gc);
}
void rs_8_02_05_4(void) {
	gca[5] = (r2(gia[7], gi) ? gp[2] : gps->c);
}
int * rs_8_02_05_5(void) {
	return gpi + 1;
}
void rs_8_02_06_0(unsigned long a, double b, int c) {
	gda[0] = 0.5;
}
void rs_8_02_06_1(unsigned long a, double b, int c) {
	gu++;
}
void rs_8_02_06_2(unsigned long a, double b, int c) {
	b = -gd;
}
long rs_8_02_06_3(unsigned long a, double b, int c) {
	return (gul > 28394UL ? (gpl[3] ^ gl) : (long)gca[7]);
}
void rs_8_02_07_1(unsigned int a, unsigned char b) {
	int i = ji;
	i = 0; while (i < 10) { if (gpl[2] != 0) gla[6] = gl2 / gpl[2]; gca[i] = gc - (char)gps->i; i++; }
}
void rs_8_02_07_2(unsigned int a, unsigned char b) {
	gps->c = -87;
}
int rs_8_02_07_3(unsigned int a, unsigned char b) {
	return r0();
}
void rs_8_02_08_0(void) {
	unsigned long t = gul;
	jul = t;
}
void rs_8_02_08_1(void) {
	vp(rp());
}
void rs_8_02_08_2(void) {
	unsigned long t = jul;
	v0();
	gul -= t;
}
unsigned long rs_8_02_08_3(void) {
	unsigned long t = jul;
	v0();
	return t;
}
void rs_8_02_09_0(int a) {
	char *t = gp;
	jp = t;
}
void rs_8_02_09_1(int a) {
	int u = gs.i - 1;
	ji = u;
}
void rs_8_02_09_2(int a) {
	char *t = jp;
	gp = t;
}
void rs_8_02_09_3(int a) {
	int u = ji;
	if (u != 0) gia[u] = 8 % u;
}
void rs_8_02_09_4(int a) {
	gl = *gpl;
}
void rs_8_02_09_5(int a) {
	while (a > 0) { gc2 += *gp++; a--; }
}
int rs_8_02_09_6(int a) {
	int u = ji;
	if (gc2 >= gca[7]) return ~u;
}
int rs_8_02_09_7(int a) {
	int u = ji;
	return (u - gi) % 100;
}
void rs_8_02_10_1(char a, int b, long c) {
	char *t = rp();
	jp = t;
}
void rs_8_02_10_2(char a, int b, long c) {
	int i = ji;
	v0();
	i = 0; while (i < 12) { gps->l <<= 3; gi2 = gi = (256 == 255 ? gia[i] : gi3) >> 1; gl2 = ~65536L + (gps->l >> 16); i++; }
}
void rs_8_02_10_3(char a, int b, long c) {
	char *t = jp;
	v0();
	vp(t);
}
void rs_8_02_10_4(char a, int b, long c) {
	switch (gi3) { case 2: vs(gps); break; case 10: vp(gs.p); break; default: gps->l = c % 10L; break; }
}
unsigned int rs_8_02_10_5(char a, int b, long c) {
	return gps->u;
}
void rs_8_02_11_0(void) {
	unsigned char t = guca[6] + guca[3];
	juc = t;
}
void rs_8_02_11_1(void) {
	unsigned char t = juc;
	switch (gu) { case 0: vd(gda[1]); break; case 1: v2(gi, gi); break; default: gua[1] = gua[t]; break; }
}
void rs_8_02_11_2(void) {
	gul = (unsigned long)(8 == (0 - guca[2]));
}
int * rs_8_02_11_3(void) {
	return gpi;
}
void rs_8_02_12_1(unsigned char a, int b, long c) {
	char t = gs.c / 7;
	jc = t;
}
void rs_8_02_12_2(unsigned char a, int b, long c) {
	int *u = gpi;
	jpi = u;
}
void rs_8_02_12_3(unsigned char a, int b, long c) {
	--gc2;
}
void rs_8_02_12_4(unsigned char a, int b, long c) {
	int i = ji;
	char t = jc;
	for (i = 0; i < b; i++) { if (gps->l != 0) c = (long)gula[i] / gps->l; c = (long)t; if (gps->l != 0) gla[6] = gla[i] / gps->l; }
}
void rs_8_02_12_5(unsigned char a, int b, long c) {
	int *u = jpi;
	gpi = u;
}
void rs_8_02_12_6(unsigned char a, int b, long c) {
	int i = ji;
	if (guc) if (gps->i != 0) gpi[2] = 1 / gps->i;
}
long rs_8_02_12_7(unsigned char a, int b, long c) {
	return (gl = c);
}
void rs_8_02_13_0(void) {
	gs.i = r2(gi2, gia[1]) ^ (gs.i * gia[3]);
}
void rs_8_02_13_1(void) {
	--gc2;
}
void rs_8_02_13_2(void) {
	++gu;
}
void rs_8_02_13_3(void) {
	if (gps->c & 2) { if (gca[1] != 0) gc = 'z' % gca[1]; } else { *gpi = gi3; vu(~gps->u); if (gi2 != 0) *gpi = gpi[0] % gi2; }
}
void rs_8_02_13_4(void) {
	if ((long)gc2 == gs.l) { gs.i = gi3 << 6; if (gps->c != 0) gp[1] = (char)guc % gps->c; vu(gps->u); } else { gs.c = gc2 & gp[3]; *gpl ^= (long)gc; }
}
void rs_8_02_14_0(void) {
	gca[1] = gc2 | (gs.c + gp[0]);
}
void rs_8_02_14_1(void) {
	if ((gia[0] = 1) != 100 && gp[2]) { gps->a[3] = r2(gi2, gia[7]); if (gul != 0) gul = gula[4] / gul; }
}
void rs_8_02_14_2(void) {
	*gp *= 3;
}
char * rs_8_02_14_3(void) {
	return gp;
}
void rs_8_02_15_0(unsigned char a, int b, char *c) {
	int t = 255;
	ji = t;
}
void rs_8_02_15_1(unsigned char a, int b, char *c) {
	double u = 2.5 - gs.d;
	jd = u;
}
void rs_8_02_15_2(unsigned char a, int b, char *c) {
	int t = ji;
	if (!gul && !*gpl) if (t != 0) b = gps->a[3] / t;
}
void rs_8_02_15_3(unsigned char a, int b, char *c) {
	int t = ji;
	if (b == 16) if (gs.a[3] != 0) t = gi2 / gs.a[3];
}
void rs_8_02_15_4(unsigned char a, int b, char *c) {
	gd = gd2;
}
void rs_8_02_15_5(unsigned char a, int b, char *c) {
	double u = jd;
	gd = u;
}
int rs_8_02_15_6(unsigned char a, int b, char *c) {
	return (*gpi & gps->a[a]) << 2;
}
void rs_8_02_16_1(void) {
	int i = ji;
	i = 0; while (i < 5) { gps->l = (long)gula[i]; gul |= (unsigned long)(gps->u <= gu2); i++; }
}
void rs_8_02_16_2(void) {
	gps->p = rp();
}
void rs_8_02_16_3(void) {
	if (gc2 != 0) gca[1] = gp[3] % gc2;
}
void rs_8_02_16_4(void) {
	int i = ji;
	v0();
	if (r2(gi2, 16) || gi2 >= gps->i) { vs(gps); gc = gc2 = -(-gc); if (gul != 0) gul = gula[5] / gul; }
}
int rs_8_02_16_5(void) {
	return gi;
}
void rs_8_02_17_0(struct st *a, long *b, unsigned long c) {
	int t = !gula[5];
	ji = t;
}
void rs_8_02_17_1(struct st *a, long *b, unsigned long c) {
	gd2 = -(r2(gi2, 127) ? (double)gu2 : 0.25);
}
void rs_8_02_17_2(struct st *a, long *b, unsigned long c) {
	gl--;
}
void rs_8_02_17_3(struct st *a, long *b, unsigned long c) {
	int t = ji;
	v0();
	t = gi;
}
int rs_8_02_17_4(struct st *a, long *b, unsigned long c) {
	return -(8 ^ gia[6]);
}
void rs_8_02_18_0(void) {
	int t = gpi[0] ^ gi3;
	ji = t;
}
void rs_8_02_18_1(void) {
	if (gul != 0) gul = gul % gul;
}
void rs_8_02_18_2(void) {
	int t = ji;
	gi3 = t;
}
void rs_8_02_18_3(void) {
	gula[0] = gul = (gula[6] * 92485UL) + gula[4];
}
int rs_8_02_18_4(void) {
	return r2(gi3, gi);
}
void rs_8_02_19_0(int a) {
	int t = (int)gpl[1];
	ji = t;
}
void rs_8_02_19_1(int a) {
	*gp = gc2 = gc;
}
void rs_8_02_19_2(int a) {
	int t = ji;
	gula[t] = gula[a] >> 10;
}
unsigned int rs_8_02_19_3(int a) {
	return (gps->u + 32767) >> 5;
}
void rs_8_03_00_1(double a, struct st *b, struct st *c) {
	unsigned int t = gu;
	ju = t;
}
void rs_8_03_00_2(double a, struct st *b, struct st *c) {
	guca[4] = guca[7];
}
void rs_8_03_00_3(double a, struct st *b, struct st *c) {
	gc++;
}
void rs_8_03_00_4(double a, struct st *b, struct st *c) {
	int i = ji;
	unsigned int t = ju;
	for (i = 8; i > 0; i--) { gpi = gpi + t; if (gps->c != 0) gc2 = gc / gps->c; }
}
void rs_8_03_00_5(double a, struct st *b, struct st *c) {
	unsigned int t = ju;
	gul = (gula[t] + gula[5]) % 4UL;
}
char * rs_8_03_00_6(double a, struct st *b, struct st *c) {
	unsigned int t = ju;
	if (!gu2) return gs.p + t;
}
char * rs_8_03_00_7(double a, struct st *b, struct st *c) {
	return b->p;
}
void rs_8_03_01_0(long *a, char *b, struct st *c) {
	unsigned int t = ru(gu);
	ju = t;
}
void rs_8_03_01_1(long *a, char *b, struct st *c) {
	unsigned int t = ju;
	v0();
	if (b[2] != 0) gca[1] = b[t] % b[2];
}
char rs_8_03_01_2(long *a, char *b, struct st *c) {
	if (guc) return (gul & 4 ? c->c : gca[2]);
}
char rs_8_03_01_3(long *a, char *b, struct st *c) {
	return gca[1];
}
void rs_8_03_02_0(void) {
	vc(*gp | -2);
}
void rs_8_03_02_1(void) {
	if (gd2 > 3.0) { if (gul != 0) gula[3] = gul / gul; }
}
void rs_8_03_02_2(void) {
	gi2 = -(gs.i - gi);
}
void rs_8_03_02_3(void) {
	gpl[2] = gps->l;
}
unsigned long rs_8_03_02_4(void) {
	return -(0x10000UL * 8UL);
}
void rs_8_03_03_0(int *a) {
	long t = gps->l * 2L;
	jl = t;
}
void rs_8_03_03_1(int *a) {
	long t = jl;
	vl(t);
}
void rs_8_03_03_2(int *a) {
	*a = r0() + r2(*a, gi);
}
int rs_8_03_03_3(int *a) {
	if (gu2 != gua[2]) return gpi[2];
}
void rs_8_03_03_4(int *a) {
	long t = jl;
	v0();
	if (gu) { if (gps->u != 0) gps->u = gu % gps->u; gda[3] = 2.5 * gs.d; } else { gla[5] = t = 17111L; if (*gp != 0) gs.c = 9 / *gp; }
}
int rs_8_03_03_5(int *a) {
	return ~(gi ^ gia[3]);
}
void rs_8_03_04_0(void) {
	gi3 = ((gps->u >= 5 ? gd2 : gda[2]) >= (gd * gd));
}
void rs_8_03_04_1(void) {
	gu2 -= (gs.d != gd2 ? 7 : gu2);
}
void rs_8_03_04_2(void) {
	if (gl2 < 65536L) { gula[0] = gul = (((unsigned long)guc) > gul ? gul : (1UL / 16UL)); gpi[3] &= 0 - gia[1]; } else { if (gu2 != 0) gs.u = 32767 % gu2; }
}
unsigned long rs_8_03_04_3(void) {
	return gul;
}
void rs_8_03_05_1(int a, double b, unsigned long c) {
	v2(gi2, gi2 + (int)gla[2]);
}
void rs_8_03_05_2(int a, double b, unsigned long c) {
	int i = ji;
	v0();
	i = 0; while (i < 3) { vd(-gs.d); i++; }
}
void rs_8_03_05_3(int a, double b, unsigned long c) {
	guca[a] = guc & ((unsigned char)c);
}
int rs_8_03_05_4(int a, double b, unsigned long c) {
	return (gia[5] = gps->a[0]);
}
void rs_8_03_06_0(char a, int b) {
	gula[1] <<= 28;
}
void rs_8_03_06_1(char a, int b) {
	gpi = gpi + a;
}
void rs_8_03_06_2(char a, int b) {
	guca[b] = (unsigned char)!gs.l;
}
void rs_8_03_06_3(char a, int b) {
	a--;
}
int * rs_8_03_06_4(char a, int b) {
	return gpi;
}
void rs_8_03_07_0(long a, char *b, char c) {
	gula[7] = (unsigned long)!gps->u;
}
void rs_8_03_07_1(long a, char *b, char c) {
	++gu2;
}
void rs_8_03_07_2(long a, char *b, char c) {
	while (gi > 0) { gc += *b++; gi--; }
}
void rs_8_03_07_3(long a, char *b, char c) {
	gl2 = gl = (a | gl2) << 11;
}
int rs_8_03_07_4(long a, char *b, char c) {
	return gps->i % 16;
}
void rs_8_03_08_0(void) {
	int t = r1(gia[7]);
	ji = t;
}
void rs_8_03_08_1(void) {
	gpi = rpi(gi3 & 8);
}
void rs_8_03_08_2(void) {
	int t = ji;
	v0();
	gi3 = t = (t >> 14) & (255 / 10);
}
int rs_8_03_08_3(void) {
	return gi2;
}
void rs_8_03_09_1(unsigned char a, long b, int c) {
	unsigned char t = guc;
	juc = t;
}
void rs_8_03_09_2(unsigned char a, long b, int c) {
	unsigned char t = juc;
	guc = t;
}
void rs_8_03_09_3(unsigned char a, long b, int c) {
	b = rl(3L);
}
void rs_8_03_09_4(unsigned char a, long b, int c) {
	gca[7] = gc;
}
void rs_8_03_09_5(unsigned char a, long b, int c) {
	int i = ji;
	v0();
	for (i = 0; i < 12; i++) { if (gua[i] != 0) gu2 = gs.u / gua[i]; }
}
void rs_8_03_10_0(unsigned long a, unsigned char b) {
	char *t = gs.p;
	jp = t;
}
void rs_8_03_10_1(unsigned long a, unsigned char b) {
	gc2 = 'A';
}
void rs_8_03_10_2(unsigned long a, unsigned char b) {
	if (!guca[b] || !gc) guc *= 8;
}
void rs_8_03_10_3(unsigned long a, unsigned char b) {
	char *t = jp;
	if (gps->c > *t) { gc = 87; vc(gc2 + *t); guc++; }
}
void rs_8_03_10_4(unsigned long a, unsigned char b) {
	gi3 -= gi2;
}
int rs_8_03_10_5(unsigned long a, unsigned char b) {
	return (gi2 << 2) * 10;
}
void rs_8_03_11_1(double a) {
	double t = 3.0 / 10.0;
	jd = t;
}
void rs_8_03_11_2(double a) {
	char *u = gp;
	jp = u;
}
void rs_8_03_11_3(double a) {
	gs.l = gla[0] = ~(*gpl ^ gl);
}
void rs_8_03_11_4(double a) {
	int i = ji;
	for (i = 0; i < 10; i++) { gi3 = gi2 | (gi / 16); }
}
void rs_8_03_11_5(double a) {
	int i = ji;
	char *u = jp;
	for (i = 0; i < 14; i++) { u[i] /= 7; if (gi2 != 0) gi2 = gs.i % gi2; if (gu != 0) gua[i] = gu2 / gu; }
}
void rs_8_03_11_6(double a) {
	int i = ji;
	char *u = jp;
	i = 8; do { u[i] <<= 3; guca[i] = 255; } while (--i > 0);
}
void rs_8_03_11_7(double a) {
	double t = jd;
	vd(t);
}
void rs_8_03_11_8(double a) {
	char *u = jp;
	v0();
	vu(gps->u);
}
unsigned long rs_8_03_11_9(double a) {
	return 0x10000UL >> 31;
}
int rs_8_03_12_0(void) {
	if (gu2 > gua[3]) return gs.a[1] - (int)guc;
}
void rs_8_03_12_1(void) {
	switch (gps->u) { case 0: gca[5] = gca[2] + gps->c; case 1: v0(); break; default: v2(gps->a[2], gi); break; }
}
void rs_8_03_12_2(void) {
	while (gi > 0) { gi3 += *gpi++; gi--; }
}
void rs_8_03_12_3(void) {
	--gul;
}
int rs_8_03_12_4(void) {
	return (gps->a[3] = gps->i);
}
void rs_8_03_13_0(unsigned int a) {
	int *t = gpi;
	jpi = t;
}
void rs_8_03_13_1(unsigned int a) {
	unsigned long u = rul(0x10000UL);
	jul = u;
}
void rs_8_03_13_2(unsigned int a) {
	unsigned long u = jul;
	v0();
	vl((long)u);
}
void rs_8_03_13_3(unsigned int a) {
	int *t = jpi;
	v0();
	if (gps->c == gca[2] && *gp & 0x7) t = gpi;
}
int * rs_8_03_13_4(unsigned int a) {
	int *t = jpi;
	v0();
	if (6 > gpi[0]) return t;
}
void rs_8_03_13_5(unsigned int a) {
	gia[3] = gs.a[a];
}
void rs_8_03_13_6(unsigned int a) {
	gps->i = 256;
}
int * rs_8_03_13_7(unsigned int a) {
	return gpi;
}
void rs_8_03_14_0(void) {
	unsigned long t = (unsigned long)(gua[4] >= 255);
	jul = t;
}
void rs_8_03_14_1(void) {
	gpi = &gia[7];
}
void rs_8_03_14_2(void) {
	if (gs.u != 0) gs.u = 25162 / gs.u;
}
void rs_8_03_14_3(void) {
	unsigned long t = jul;
	t = t % 16UL;
}
unsigned long rs_8_03_14_4(void) {
	unsigned long t = jul;
	return t;
}
void rs_8_03_15_0(void) {
	if ((char)gpi[2] == gca[7]) { gua[6] = gps->u >> 1; gp = gp + 1; guca[5] = ((unsigned char)gi2) % 7; } else { gula[0] -= (unsigned long)(gul > gula[6]); }
}
void rs_8_03_15_1(void) {
	gc2 += 'A';
}
void rs_8_03_15_2(void) {
	if (gu != 0) gps->u = gs.u % gu;
}
int * rs_8_03_15_3(void) {
	return rpi(~100);
}
void rs_8_03_16_0(unsigned long a, unsigned long b) {
	long t = -37215L % 4L;
	jl = t;
}
void rs_8_03_16_1(unsigned long a, unsigned long b) {
	int u = gi3 ^ 256;
	ji = u;
}
void rs_8_03_16_2(unsigned long a, unsigned long b) {
	long t = jl;
	gl = t;
}
void rs_8_03_16_3(unsigned long a, unsigned long b) {
	vu(gu / 7);
}
void rs_8_03_16_4(unsigned long a, unsigned long b) {
	int u = ji;
	v0();
	u--;
}
void rs_8_03_16_5(unsigned long a, unsigned long b) {
	vs(gps);
}
void rs_8_03_17_0(int a, unsigned char b, char c) {
	long t = -gl;
	jl = t;
}
void rs_8_03_17_1(int a, unsigned char b, char c) {
	c %= 10;
}
void rs_8_03_17_2(int a, unsigned char b, char c) {
	if (gps->c != 0) c = 1 / gps->c;
}
void rs_8_03_17_3(int a, unsigned char b, char c) {
	gul += gula[b];
}
void rs_8_03_17_4(int a, unsigned char b, char c) {
	long t = jl;
	gl = t;
}
void rs_8_03_17_5(int a, unsigned char b, char c) {
	v2(-gi2, gi);
}
int rs_8_03_17_6(int a, unsigned char b, char c) {
	return !(gi < a ? gla[a] : 65536L);
}
void rs_8_03_18_0(int a) {
	guc = ((unsigned char)!255) * (guc | 128);
}
void rs_8_03_18_1(int a) {
	if (gula[a] >= gul) { vd(gd2 - gda[0]); }
}
void rs_8_03_18_2(int a) {
	if (!gc2) { if (gula[2] != 0) gula[a] = 4UL % gula[2]; vu((unsigned int)gc); v2(gi3 / 3, gi); }
}
void rs_8_03_18_3(int a) {
	gc2++;
}
void rs_8_03_18_4(int a) {
	gp = gps->p + a;
}
int rs_8_03_18_5(int a) {
	return 127 % 100;
}
void rs_8_03_19_0(int a) {
	int t = ~gi;
	ji = t;
}
void rs_8_03_19_1(int a) {
	long u = (long)!gul;
	jl = u;
}
void rs_8_03_19_2(int a) {
	gua[3] = gu2 % 7;
}
void rs_8_03_19_3(int a) {
	int t = ji;
	v1(t);
}
void rs_8_03_19_4(int a) {
	long u = jl;
	v0();
	vl(u);
}
void rs_8_03_19_5(int a) {
	gs.p = gp;
}
void rs_8_04_00_0(unsigned long a, int b, double c) {
	unsigned long t = ~a;
	jul = t;
}
void rs_8_04_00_1(unsigned long a, int b, double c) {
	long u = gl;
	jl = u;
}
void rs_8_04_00_2(unsigned long a, int b, double c) {
	unsigned long t = jul;
	gul = t;
}
void rs_8_04_00_3(unsigned long a, int b, double c) {
	guc = guca[b];
}
void rs_8_04_00_4(unsigned long a, int b, double c) {
	long u = jl;
	vl(u);
}
void rs_8_04_00_5(unsigned long a, int b, double c) {
	v1(b - gi2);
}
char * rs_8_04_00_6(unsigned long a, int b, double c) {
	return gp + b;
}
void rs_8_04_01_0(unsigned char a) {
	gp = gs.p;
}
void rs_8_04_01_1(unsigned char a) {
	gu <<= 13;
}
void rs_8_04_01_2(unsigned char a) {
	gps->i = gs.i % 10;
}
void rs_8_04_01_3(unsigned char a) {
	if (gu != 0) gs.u = gs.u / gu;
}
void rs_8_04_01_4(unsigned char a) {
	gula[0] += gula[5] % 4UL;
}
int * rs_8_04_01_5(unsigned char a) {
	return rpi(127);
}
void rs_8_04_02_0(int a, int b, unsigned long c) {
	gc -= gc + (char)gpl[1];
}
void rs_8_04_02_1(int a, int b, unsigned long c) {
	gs.d = gda[0];
}
void rs_8_04_02_2(int a, int b, unsigned long c) {
	switch (gc2) { case 0: case 1: case 2: gd2 = 0.5 * 3.0; break; case 3: v1(gia[b]); break; case 4: gpi = gpi + b; break; case 5: v2(a, gi); break; default: v2(8, gi); break; }
}
void rs_8_04_02_3(int a, int b, unsigned long c) {
	vu(gu / 10);
}
long rs_8_04_02_4(int a, int b, unsigned long c) {
	return (gps->l + (long)gua[b]) + -(long)gula[6];
}
void rs_8_04_03_0(int *a) {
	unsigned int t = gps->u;
	ju = t;
}
void rs_8_04_03_1(int *a) {
	gua[1] = ru((unsigned int)gl);
}
void rs_8_04_03_2(int *a) {
	gua[5] <<= 11;
}
void rs_8_04_03_3(int *a) {
	unsigned int t = ju;
	v0();
	gpi[0] = gi + gia[t];
}
void rs_8_04_03_4(int *a) {
	gi2++;
}
void rs_8_04_03_5(int *a) {
	unsigned int t = ju;
	v0();
	if (gula[t] != 0) gul = gula[t] / gula[t];
}
int * rs_8_04_03_6(int *a) {
	return a;
}
void rs_8_04_04_0(long *a) {
	int t = gpi[3] + gps->i;
	ji = t;
}
void rs_8_04_04_1(long *a) {
	int t = ji;
	unsigned char u = guca[t] + guc;
	juc = u;
}
void rs_8_04_04_2(long *a) {
	unsigned char u = juc;
	gua[u] = gps->u;
}
void rs_8_04_04_3(long *a) {
	gpi++;
}
void rs_8_04_04_4(long *a) {
	gu &= (unsigned int)gi2;
}
void rs_8_04_04_5(long *a) {
	unsigned char u = juc;
	vp(gps->p + u);
}
void rs_8_04_04_6(long *a) {
	int t = ji;
	v0();
	gi = t;
}
int rs_8_04_04_7(long *a) {
	return (gs.i - gpi[2]) / 2;
}
void rs_8_04_05_0(long a, char b, int c) {
	char *t = gp;
	jp = t;
}
void rs_8_04_05_1(long a, char b, int c) {
	unsigned int u = gps->u;
	ju = u;
}
void rs_8_04_05_2(long a, char b, int c) {
	if (gs.d < 1.0) guc = (((unsigned char)gul) << 5) ^ -guc;
}
void rs_8_04_05_3(long a, char b, int c) {
	unsigned int u = ju;
	if ((gca[c] = gc) >= 5) if (gula[u] != 0) gula[7] = gula[u] % gula[u];
}
void rs_8_04_05_4(long a, char b, int c) {
	gp--;
}
char * rs_8_04_05_5(long a, char b, int c) {
	char *t = jp;
	if (!guca[0]) return t;
}
void rs_8_04_05_6(long a, char b, int c) {
	unsigned int u = ju;
	gs.u = gu;
}
char * rs_8_04_05_7(long a, char b, int c) {
	unsigned int u = ju;
	return &gca[u];
}
void rs_8_04_06_0(int a, unsigned char b, char *c) {
	double t = 1.0;
	jd = t;
}
void rs_8_04_06_1(int a, unsigned char b, char *c) {
	unsigned long u = rul(gul);
	jul = u;
}
void rs_8_04_06_2(int a, unsigned char b, char *c) {
	double t = jd;
	v0();
	gd = t;
}
void rs_8_04_06_3(int a, unsigned char b, char *c) {
	vp(rp());
}
void rs_8_04_06_4(int a, unsigned char b, char *c) {
	unsigned long u = jul;
	v0();
	switch (gc2) { case 1: v2(gi2, gs.i); break; case 2: vu(gu2); break; case 3: vd(3.0); case 10: gc2 += gs.c; break; case 20: gula[b] = u * ((unsigned long)gc); default: c[2] = *gp = (char)!gla[b]; break; }
}
void rs_8_04_06_5(int a, unsigned char b, char *c) {
	gu >>= 2;
}
void rs_8_04_06_6(int a, unsigned char b, char *c) {
	unsigned long u = jul;
	v0();
	if (gps->u) u = ((unsigned long)(*gpi >= gia[6])) + (guca[5] ? u : gul);
}
void rs_8_04_06_7(int a, unsigned char b, char *c) {
	unsigned long u = jul;
	v0();
	u = 0x10000UL;
}
char * rs_8_04_06_8(int a, unsigned char b, char *c) {
	return gp;
}
void rs_8_04_07_0(void) {
	gd2 = (10.0 - gda[0]) * (gd - gd2);
}
void rs_8_04_07_1(void) {
	if (gi != gi2) if (*gpi != 0) gi = gi % *gpi;
}
void rs_8_04_07_2(void) {
	*gpi = gps->i = !(~gps->l);
}
void rs_8_04_07_3(void) {
	if (gla[3] == 65536L) { guca[3] = guc; if (gu2 != 0) gs.u = gs.u % gu2; } else { gp--; }
}
char * rs_8_04_07_4(void) {
	return gp;
}
void rs_8_04_08_1(long a, char b) {
	gu = (unsigned int)(gul >= rul(gul));
}
void rs_8_04_08_2(long a, char b) {
	gula[5] = gul = 71981UL;
}
void rs_8_04_08_3(long a, char b) {
	int i = ji;
	v0();
	i = 9; do { guc = (unsigned char)!gs.c; guc >>= 4; } while (--i > 0);
}
void rs_8_04_08_4(long a, char b) {
	gpi--;
}
void rs_8_04_08_5(long a, char b) {
	guc = guca[b] / 10;
}
unsigned long rs_8_04_08_6(long a, char b) {
	return rul(gula[b] | 0x10000UL);
}
void rs_8_04_09_1(char a, char b) {
	unsigned int t = gu2;
	ju = t;
}
void rs_8_04_09_2(char a, char b) {
	unsigned int u = gua[0] / 3;
	ju = u;
}
void rs_8_04_09_3(char a, char b) {
	int i = ji;
	for (i = 7; i > 0; i--) { vd(gd2); }
}
void rs_8_04_09_4(char a, char b) {
	vd(-gd2);
}
void rs_8_04_09_5(char a, char b) {
	unsigned int t = ju;
	v0();
	vu(t);
}
void rs_8_04_09_6(char a, char b) {
	if (gula[6] < ((unsigned long)guca[5])) gs.d = gs.d - 0.5;
}
void rs_8_04_09_7(char a, char b) {
	int i = ji;
	v0();
	gs.i >>= 7;
}
void rs_8_04_09_8(char a, char b) {
	unsigned int u = ju;
	v0();
	gu = u + gu;
}
char * rs_8_04_09_9(char a, char b) {
	return gs.p;
}
void rs_8_04_10_1(double a) {
	double t = gd2 / 0.25;
	jd = t;
}
void rs_8_04_10_2(double a) {
	double u = gda[2] + 3.0;
	jd = u;
}
void rs_8_04_10_3(double a) {
	if (gula[1] != 0) gul = gul / gula[1];
}
void rs_8_04_10_4(double a) {
	double t = jd;
	vd(t);
}
void rs_8_04_10_5(double a) {
	switch (gi2) { case 0: case 1: vl(gl); break; case 2: vc(gca[6]); break; default: gla[3] = (long)gca[3] & gla[5]; break; }
}
void rs_8_04_10_6(double a) {
	int i = ji;
	v0();
	for (i = 0; i < 6; i++) { vp(gps->p); }
}
void rs_8_04_10_7(double a) {
	if (r0()) vs(gps);
}
void rs_8_04_10_8(double a) {
	double u = jd;
	v0();
	vd(u);
}
void rs_8_04_10_9(double a) {
	--gl;
}
int * rs_8_04_10_10(double a) {
	return &gia[1];
}
void rs_8_04_11_0(char a, int *b, char c) {
	unsigned long t = (unsigned long)gl2;
	jul = t;
}
void rs_8_04_11_1(char a, int *b, char c) {
	int u = gi3;
	ji = u;
}
void rs_8_04_11_2(char a, int *b, char c) {
	guca[7] *= 5;
}
void rs_8_04_11_3(char a, int *b, char c) {
	guc += guca[4] / 100;
}
void rs_8_04_11_4(char a, int *b, char c) {
	int u = ji;
	gi = u;
}
void rs_8_04_11_5(char a, int *b, char c) {
	unsigned long t = jul;
	gul = t;
}
long rs_8_04_11_6(char a, int *b, char c) {
	return gla[c] - -36530L;
}
void rs_8_04_12_1(void) {
	if (gs.d > gd2) { gu2 = 1 >> 3; gu *= 7; } else { if (gu2 >= gua[4]) guc = guca[3] = (((unsigned char)gu2) * guca[7]) + guca[2]; }
}
void rs_8_04_12_2(void) {
	vl(gl ^ gpl[1]);
}
void rs_8_04_12_3(void) {
	vp(gps->p);
}
void rs_8_04_12_4(void) {
	int i = ji;
	v0();
	for (i = 0; i < 9; i++) { gda[0] = gs.d + gda[1]; if (gu2 != 0) gua[i] = ((unsigned int)gps->a[1]) % gu2; if (*gpl != 0) gl2 = gl % *gpl; }
}
int rs_8_04_12_5(void) {
	if (!guca[7] || (gps->u = gs.u)) return r2(gi2, 256);
}
int rs_8_04_12_6(void) {
	return (int)gu2;
}
void rs_8_04_13_1(unsigned long a) {
	if (gc2) gda[1] = (a != 0x10000UL ? gd : gd2);
}
void rs_8_04_13_2(unsigned long a) {
	if (guc && gl & 0x10) if (gc != 0) gc2 = gc2 / gc;
}
void rs_8_04_13_3(unsigned long a) {
	int i = ji;
	for (i = 0; i < 15; i++) { gda[0] += gs.d; }
}
char rs_8_04_13_4(unsigned long a) {
	return (char)a;
}
void rs_8_04_14_0(void) {
	double t = gd2 - gd;
	jd = t;
}
void rs_8_04_14_1(void) {
	char *u = gps->p + 1;
	jp = u;
}
void rs_8_04_14_2(void) {
	double t = jd;
	if (gu2 & 0x7) { --gc2; if (gul != 0) gul = gul / gul; gs.d = (t * t) * (gda[1] - gd); } else { gpi[1] = gia[0] << 3; *gpl = gps->l = gpl[1]; }
}
void rs_8_04_14_3(void) {
	gi2++;
}
void rs_8_04_14_4(void) {
	char *u = jp;
	gp = u;
}
void rs_8_04_14_5(void) {
	++gpi;
}
char * rs_8_04_14_6(void) {
	return gp + 1;
}
void rs_8_04_15_0(struct st *a, int b) {
	char t = gc % 3;
	jc = t;
}
void rs_8_04_15_1(struct st *a, int b) {
	char u = (char)(guc == 255);
	jc = u;
}
void rs_8_04_15_2(struct st *a, int b) {
	char t = jc;
	gula[t] = gul % 16UL;
}
void rs_8_04_15_3(struct st *a, int b) {
	char u = jc;
	if (gca[6] != 0) u = *gp % gca[6];
}
unsigned long rs_8_04_15_4(struct st *a, int b) {
	return (unsigned long)!gu2;
}
void rs_8_04_16_0(char a) {
	--gpi;
}
void rs_8_04_16_1(char a) {
	gd += gd;
}
void rs_8_04_16_2(char a) {
	gula[1] = gul = ~((unsigned long)gua[a]);
}
void rs_8_04_16_3(char a) {
	vl((long)gul);
}
unsigned int rs_8_04_16_4(char a) {
	return ((unsigned int)guca[4]) | (32767 % 100);
}
void rs_8_04_17_0(void) {
	char *t = rp();
	jp = t;
}
void rs_8_04_17_1(void) {
	gc2 <<= 1;
}
void rs_8_04_17_2(void) {
	char *t = jp;
	v0();
	switch (gu2) { case 20: t = &gca[2]; break; case 100: gc <<= 4; break; }
}
void rs_8_04_17_3(void) {
	*gp = gc;
}
void rs_8_04_17_4(void) {
	if (gl2 >= gl || (*gp = gca[4]) <= 20) { guca[6] /= 10; vd(gd2 + 100.0); }
}
void rs_8_04_17_5(void) {
	guc++;
}
int * rs_8_04_17_6(void) {
	return gpi + 1;
}
void rs_8_04_18_0(void) {
	long t = ~65536L;
	jl = t;
}
void rs_8_04_18_1(void) {
	int *u = gpi;
	jpi = u;
}
void rs_8_04_18_2(void) {
	guc = 255;
}
void rs_8_04_18_3(void) {
	long t = jl;
	switch (t) { case 0L: gu -= (unsigned int)gi2; break; case 1L: v1(gi2); break; default: gpi = rpi(gps->i); break; }
}
void rs_8_04_18_4(void) {
	long t = jl;
	v0();
	switch (gc2) { case 0: gul &= 5UL; break; case 1: vp(gp); case 2: t = gs.l; break; case 3: vs(gps); break; }
}
void rs_8_04_18_5(void) {
	int *u = jpi;
	v0();
	v1(*u);
}
void rs_8_04_18_6(void) {
	gla[5] = 1L;
}
unsigned long rs_8_04_18_7(void) {
	return rul(gula[4]);
}
void rs_8_04_19_0(unsigned long a) {
	double t = gs.d - gd;
	jd = t;
}
void rs_8_04_19_1(unsigned long a) {
	int u = gi2 % 2;
	ji = u;
}
void rs_8_04_19_2(unsigned long a) {
	gc2 = (gca[0] * gps->c) ^ (gc % 100);
}
void rs_8_04_19_3(unsigned long a) {
	double t = jd;
	vd(t);
}
void rs_8_04_19_4(unsigned long a) {
	while (gi > 0) { gi3 += *gpi++; gi--; }
}
void rs_8_04_19_5(unsigned long a) {
	int u = ji;
	v0();
	v1(u);
}
void rs_8_04_19_6(unsigned long a) {
	gula[5] = a = 0x10000UL;
}
void rs_8_04_19_7(unsigned long a) {
	vd(-gs.d);
}
int rs_8_04_19_8(unsigned long a) {
	int u = ji;
	v0();
	return (91244UL == 40206UL ? (2 - 1) : u);
}
void rs_8_05_00_0(unsigned char a) {
	unsigned char t = 255;
	juc = t;
}
void rs_8_05_00_1(unsigned char a) {
	unsigned char t = juc;
	v1(t);
}
void rs_8_05_00_2(unsigned char a) {
	if (gs.i != 0) gi3 = gpi[1] / gs.i;
}
void rs_8_05_00_3(unsigned char a) {
	gia[a] = r2(gs.a[5] | gi3, gi);
}
int rs_8_05_00_4(unsigned char a) {
	return gia[a];
}
void rs_8_05_01_0(int *a) {
	long t = gl2;
	jl = t;
}
void rs_8_05_01_1(int *a) {
	if (!gla[7]) { gl |= (long)guc - 3L; vd(100.0 - gda[0]); }
}
void rs_8_05_01_2(int *a) {
	vu(gua[4] - gs.u);
}
void rs_8_05_01_3(int *a) {
	guc = (guca[3] & 153) << 6;
}
void rs_8_05_01_4(int *a) {
	guc = (guc / 16) >> 1;
}
void rs_8_05_01_5(int *a) {
	long t = jl;
	v0();
	vl(t);
}
char * rs_8_05_01_6(int *a) {
	return gps->p + 1;
}
void rs_8_05_02_0(unsigned char a, int b) {
	char t = gca[0] - gps->c;
	jc = t;
}
void rs_8_05_02_1(unsigned char a, int b) {
	char t = jc;
	if (b) gla[b] = gla[t];
}
void rs_8_05_02_2(unsigned char a, int b) {
	v2(gi2, gi);
}
int rs_8_05_02_3(unsigned char a, int b) {
	return !(guca[1] - 255);
}
void rs_8_05_03_0(void) {
	long t = gl2 >> 18;
	jl = t;
}
void rs_8_05_03_1(void) {
	int u = (int)guca[5];
	ji = u;
}
void rs_8_05_03_2(void) {
	long t = jl;
	vl(t);
}
void rs_8_05_03_3(void) {
	int u = ji;
	v0();
	if (((unsigned char)gula[u]) >= guc) { if (*gpi != 0) u = (int)gu % *gpi; gp = gps->p + u; if (gca[u] != 0) gp[1] = -15 / gca[u]; } else { --guc; }
}
void rs_8_05_03_4(void) {
	int u = ji;
	v0();
	if (gps->a[5] & 4) { v0(); if (gua[1] != 0) gu = gua[7] / gua[1]; } else { vs(gps); if (gs.u != 0) gu = gu / gs.u; }
}
long rs_8_05_03_5(void) {
	int u = ji;
	v0();
	return -(r2(gi2, gs.i) ? (long)gula[u] : 1L);
}
void rs_8_05_04_0(unsigned char a, unsigned int b, int c) {
	b = gu;
}
void rs_8_05_04_1(unsigned char a, unsigned int b, int c) {
	if (gc2 != 0) gca[a] = gc / gc2;
}
void rs_8_05_04_2(unsigned char a, unsigned int b, int c) {
	a >>= 3;
}
void rs_8_05_04_3(unsigned char a, unsigned int b, int c) {
	if (!gca[5]) if (gs.l != 0) gl2 = *gpl % gs.l;
}
void rs_8_05_04_4(unsigned char a, unsigned int b, int c) {
	gu2 = ~(gu2 - b);
}
char * rs_8_05_04_5(unsigned char a, unsigned int b, int c) {
	return gs.p + a;
}
void rs_8_05_05_0(int a) {
	vc((char)gu);
}
void rs_8_05_05_1(int a) {
	guca[6] = guc = guc >> 5;
}
void rs_8_05_05_2(int a) {
	if (gps->c > *gp) { if (*gp != 0) gc = -60 / *gp; if (gia[a] != 0) gia[a] = gi2 % gia[a]; } else { if (gl2 != 0) gla[4] = gl % gl2; gc--; }
}
void rs_8_05_05_3(int a) {
	gs.c = '0' % 100;
}
int rs_8_05_05_4(int a) {
	return (guca[a] & 0x8 ? (gi2 * 10) : (gia[a] / 2));
}
void rs_8_05_06_0(int a, int b, char c) {
	gd += gda[0];
}
void rs_8_05_06_1(int a, int b, char c) {
	gd += (r2(gi2, b) ? gs.d : gda[3]);
}
int rs_8_05_06_2(int a, int b, char c) {
	return a;
}
void rs_8_05_07_1(char a, unsigned int b, unsigned char c) {
	unsigned char t = (gula[2] < 94403UL ? guca[7] : 128);
	juc = t;
}
void rs_8_05_07_2(char a, unsigned int b, unsigned char c) {
	int i = ji;
	for (i = 0; i < 4; i++) { if (gul != 0) gul = gula[i] / gul; gl2 *= 6L; }
}
void rs_8_05_07_3(char a, unsigned int b, unsigned char c) {
	if (gpi[2]) { vl(gpl[2] & gps->l); vp(rp()); }
}
void rs_8_05_07_4(char a, unsigned int b, unsigned char c) {
	gla[a] = rl(65536L);
}
void rs_8_05_07_5(char a, unsigned int b, unsigned char c) {
	unsigned char t = juc;
	v0();
	v1(t);
}
void rs_8_05_07_6(char a, unsigned int b, unsigned char c) {
	gi3 = ~(gi3 % 16);
}
char * rs_8_05_07_7(char a, unsigned int b, unsigned char c) {
	return gp;
}
void rs_8_05_08_0(void) {
	char u = jc;
	unsigned int t = ru(gs.u);
	ju = t;
}
void rs_8_05_08_1(void) {
	char u = *gp;
	v0();
	jc = u;
}
void rs_8_05_08_2(void) {
	char u = jc;
	v0();
	gs.u = gu2 = ((unsigned int)!guc) / 100;
}
void rs_8_05_08_3(void) {
	unsigned int t = ju;
	v0();
	gu2 = t = 2;
}
void rs_8_05_09_0(void) {
	gu = gps->u = gs.u;
}
void rs_8_05_09_1(void) {
	++gp;
}
int rs_8_05_09_2(void) {
	if (0x10000UL != gula[5]) return gi + 792;
}
void rs_8_05_09_3(void) {
	if (1 > gu2 || gi3 < gps->i) { ++gul; gd = gs.d; gps->i = gi; }
}
void rs_8_05_09_4(void) {
	gi3 = (int)gul >> 6;
}
int rs_8_05_09_5(void) {
	return gps->a[1];
}
void rs_8_05_10_1(unsigned long a) {
	int t = r2(gi2, gps->a[4]);
	ji = t;
}
void rs_8_05_10_2(unsigned long a) {
	a--;
}
void rs_8_05_10_3(unsigned long a) {
	int i = ji;
	int t = ji;
	v0();
	for (i = 5; i > 0; i--) { gpi[0] = t ^ 16; gc %= 16; }
}
void rs_8_05_10_4(unsigned long a) {
	int t = ji;
	v0();
	gc -= gca[t];
}
void rs_8_05_10_5(unsigned long a) {
	gl2 = gps->l;
}
int * rs_8_05_10_6(unsigned long a) {
	return gpi;
}
void rs_8_05_11_1(unsigned long a, char *b, unsigned int c) {
	long t = rl(65536L);
	jl = t;
}
void rs_8_05_11_2(unsigned long a, char *b, unsigned int c) {
	char u = *gp - gca[c];
	v0();
	jc = u;
}
void rs_8_05_11_3(unsigned long a, char *b, unsigned int c) {
	long t = jl;
	v0();
	gl = t;
}
void rs_8_05_11_4(unsigned long a, char *b, unsigned int c) {
	int i = ji;
	v0();
	i = 10; do { if (gua[i] != 0) gua[i] = c / gua[i]; gi3 <<= 9; a = a >> 7; } while (--i > 0);
}
void rs_8_05_11_5(unsigned long a, char *b, unsigned int c) {
	char u = jc;
	v0();
	*gp = u;
}
void rs_8_05_11_6(unsigned long a, char *b, unsigned int c) {
	while (gi > 0) { gc += *b++; gi--; }
}
long rs_8_05_11_7(unsigned long a, char *b, unsigned int c) {
	return (long)!255;
}
void rs_8_05_12_0(long *a, long *b, int *c) {
	char *t = gp;
	jp = t;
}
void rs_8_05_12_1(long *a, long *b, int *c) {
	gd += 10.0;
}
void rs_8_05_12_2(long *a, long *b, int *c) {
	char *t = jp;
	if ((long)gi2 > 65536L && r2(*gpi, gi)) { vp(t + 1); if (gua[3] != 0) gu2 = 256 / gua[3]; gu = gps->u = ~ru(gua[6]); }
}
void rs_8_05_12_3(long *a, long *b, int *c) {
	gps->u = gu2 + gua[0];
}
void rs_8_05_12_4(long *a, long *b, int *c) {
	vc('a');
}
int rs_8_05_12_5(long *a, long *b, int *c) {
	return 5;
}
void rs_8_05_13_1(char a, double b) {
	long t = gl2 - gl;
	jl = t;
}
void rs_8_05_13_2(char a, double b) {
	int *u = rpi(gi3);
	jpi = u;
}
void rs_8_05_13_3(char a, double b) {
	int i = ji;
	v0();
	i = 0; while (i < 13) { gl2 = ~(15163L & 65536L); i++; }
}
void rs_8_05_13_4(char a, double b) {
	long t = jl;
	v0();
	vl(t);
}
void rs_8_05_13_5(char a, double b) {
	int i = ji;
	int *u = jpi;
	v0();
	switch (gs.i) { case 0: gul ^= gula[a]; break; case 1: guc %= 7; break; case 2: a = (char)gs.u; break; case 3: vu(gu); break; case 4: v2(gi2, gia[a]); break; }
}
int rs_8_05_13_6(char a, double b) {
	return gs.a[7] & (2 - gia[1]);
}
void rs_8_05_14_0(unsigned int a) {
	unsigned char t = guc;
	juc = t;
}
void rs_8_05_14_1(unsigned int a) {
	*gpi = gpi[3];
}
void rs_8_05_14_2(unsigned int a) {
	unsigned char t = juc;
	gula[t] = ((unsigned long)gla[0]) / 10UL;
}
long rs_8_05_14_3(unsigned int a) {
	return ~((long)(gi2 <= *gpi));
}
void rs_8_05_15_0(void) {
	if (gs.d == 10.0) if (*gpi != 0) gi = gi3 % *gpi;
}
void rs_8_05_15_1(void) {
	if (gpi[1] != 0) gi2 = (int)gua[7] / gpi[1];
}
void rs_8_05_15_2(void) {
	v2(8 + gi3, gi);
}
void rs_8_05_15_3(void) {
	if (256 > gu) { guca[6] = 9; gpi = gpi + 1; gs.l = gl2; } else { gc2 = gs.c * ((char)(gl2 == gl)); gua[2] = gu2 - gua[7]; }
}
void rs_8_05_15_4(void) {
	switch (gs.l) { case 0L: gs.d -= gs.d; break; case 1L: guc -= guca[7]; case 2L: gda[0] -= gd; break; case 3L: v2(gi2, (int)gu); break; default: gul = gula[3] = gula[7] >> 27; break; }
}
long rs_8_05_15_5(void) {
	return (-6915L - 65536L) + -*gpl;
}
void rs_8_05_16_0(void) {
	int t = gi3 * 10;
	ji = t;
}
void rs_8_05_16_1(void) {
	double u = gd2;
	jd = u;
}
void rs_8_05_16_2(void) {
	double u = jd;
	gd = u;
}
void rs_8_05_16_3(void) {
	gps->c = gca[2] = gc;
}
void rs_8_05_16_4(void) {
	int t = ji;
	switch (gc2) { case 1: vs(gps); break; case 2: vu(gu); break; case 8: t >>= 13; break; default: vu(gu); break; }
}
char * rs_8_05_16_5(void) {
	return gp;
}
void rs_8_05_17_0(void) {
	unsigned char t = guca[1] + guc;
	juc = t;
}
void rs_8_05_17_1(void) {
	vl(rl(gpl[2]));
}
void rs_8_05_17_2(void) {
	unsigned char t = juc;
	v0();
	switch (gi) { case 5: gpi = &gia[7]; break; case 8: v1(gi); break; case 100: gd2 += gd2; break; case 1000: gua[t] = gu2 = gua[t] / 7; break; default: vl(gl2); break; }
}
void rs_8_05_17_3(void) {
	++guc;
}
unsigned long rs_8_05_17_4(void) {
	unsigned char t = juc;
	v0();
	return (gula[t] = gul);
}
void rs_8_05_18_0(void) {
	char t = (char)!gula[2];
	jc = t;
}
void rs_8_05_18_1(void) {
	int u = gpi[0] % 16;
	ji = u;
}
void rs_8_05_18_2(void) {
	vc(gc + gp[2]);
}
void rs_8_05_18_3(void) {
	vu(((unsigned int)gul) & gu2);
}
void rs_8_05_18_4(void) {
	int u = ji;
	v0();
	gi = u;
}
unsigned long rs_8_05_18_5(void) {
	if (gps->a[4] < *gpi) return (unsigned long)!gu2;
}
void rs_8_05_18_6(void) {
	char t = jc;
	v0();
	vc(t);
}
unsigned long rs_8_05_18_7(void) {
	int u = ji;
	v0();
	return gula[u] ^ rul(0x10000UL);
}
void rs_8_05_19_0(void) {
	gua[0] -= gu2 * gua[5];
}
void rs_8_05_19_1(void) {
	gpi[3] = !gula[2];
}
void rs_8_05_19_2(void) {
	v0();
}
void rs_8_05_19_3(void) {
	if (gul != 0) gul = gula[5] / gul;
}
void rs_8_05_19_4(void) {
	++gp;
}
unsigned long rs_8_05_19_5(void) {
	return -(gula[7] / 16UL);
}
void rs_8_06_00_0(char *a, unsigned int b) {
	int t = 2;
	ji = t;
}
void rs_8_06_00_1(char *a, unsigned int b) {
	int t = ji;
	gps->u = gua[t] = (gu2 | b) + gu;
}
void rs_8_06_00_2(char *a, unsigned int b) {
	vd(gda[2] - gs.d);
}
void rs_8_06_00_3(char *a, unsigned int b) {
	gs.d += -(double)b;
}
int rs_8_06_00_4(char *a, unsigned int b) {
	return (gi - 2) >> 11;
}
void rs_8_06_01_0(unsigned char a, char b, long *c) {
	b = (gs.c << 3) + (gps->c - gp[2]);
}
void rs_8_06_01_1(unsigned char a, char b, long *c) {
	gd *= 3.0;
}
long rs_8_06_01_2(unsigned char a, char b, long *c) {
	return gpl[2];
}
void rs_8_06_02_1(unsigned int a, char b) {
	unsigned long t = 5UL >> (a & 15);
	jul = t;
}
void rs_8_06_02_2(unsigned int a, char b) {
	int *u = rpi(gi2);
	jpi = u;
}
void rs_8_06_02_3(unsigned int a, char b) {
	unsigned long t = jul;
	v0();
	vl((long)t);
}
void rs_8_06_02_4(unsigned int a, char b) {
	vd(-100.0);
}
void rs_8_06_02_5(unsigned int a, char b) {
	gs.l = (long)!((unsigned char)a);
}
void rs_8_06_02_6(unsigned int a, char b) {
	int i = ji;
	v0();
	for (i = 0; i < 13; i++) { gps->l %= 3L; v0(); }
}
void rs_8_06_02_7(unsigned int a, char b) {
	int *u = jpi;
	v0();
	gpi = u;
}
void rs_8_06_02_8(unsigned int a, char b) {
	vp(gp);
}
void rs_8_06_02_9(unsigned int a, char b) {
	gi = gps->a[b] = 255;
}
char * rs_8_06_02_10(unsigned int a, char b) {
	return gs.p;
}
void rs_8_06_03_0(int a, char b) {
	long t = 9L * 10L;
	jl = t;
}
void rs_8_06_03_1(int a, char b) {
	vu((unsigned int)(gda[1] == 10.0));
}
void rs_8_06_03_2(int a, char b) {
	gp--;
}
void rs_8_06_03_3(int a, char b) {
	gp[3] = gc = gc2 ^ b;
}
void rs_8_06_03_4(int a, char b) {
	long t = jl;
	v0();
	gl = t;
}
void rs_8_06_04_0(unsigned char a, int b, unsigned char c) {
	guc = ((unsigned char)-879) + ((unsigned char)(gula[b] == gul));
}
void rs_8_06_04_1(unsigned char a, int b, unsigned char c) {
	gp = rp();
}
int rs_8_06_04_2(unsigned char a, int b, unsigned char c) {
	return (guc == (gula[b] & 4 ? a : c));
}
void rs_8_06_05_0(void) {
	if (gul & 0x80) *gp = (gc2 / 7) % 10;
}
void rs_8_06_05_1(void) {
	++gpi;
}
void rs_8_06_05_2(void) {
	gi2 = gs.a[1] = gia[4];
}
void rs_8_06_05_3(void) {
	switch (gu) { case 0: case 1: gs.u = ((unsigned int)gpi[3]) - gua[0]; break; default: guc = guca[5] & 204; break; }
}
long rs_8_06_05_4(void) {
	return (gl % 3L) % 3L;
}
void rs_8_06_06_0(void) {
	gla[7] += (gu != 0 ? gl : gl2);
}
void rs_8_06_06_1(void) {
	*gp = rc(gps->i);
}
void rs_8_06_06_2(void) {
	switch (gi3) { case 8: case 20: gua[2] = gps->u = gu2 ^ 28592; break; }
}
void rs_8_06_06_3(void) {
	if (gul < ((unsigned long)gl2)) if (gu != 0) gua[7] = gu % gu;
}
unsigned long rs_8_06_06_4(void) {
	return rul(~gul);
}
void rs_8_06_07_1(unsigned long a) {
	unsigned char t = guc;
	juc = t;
}
void rs_8_06_07_2(unsigned long a) {
	unsigned char u = 255;
	juc = u;
}
void rs_8_06_07_3(unsigned long a) {
	gu &= 1;
}
void rs_8_06_07_4(unsigned long a) {
	int i = ji;
	for (i = 5; i > 0; i--) { if (gua[i] != 0) gu2 = gu % gua[i]; gi = (gps->l == gpl[2] ? 1 : (int)gca[i]); }
}
void rs_8_06_07_5(unsigned long a) {
	unsigned char t = juc;
	v1(t);
}
void rs_8_06_07_6(unsigned long a) {
	int i = ji;
	v0();
	for (i = 11; i > 0; i--) { gs.l *= 10L; }
}
void rs_8_06_07_7(unsigned long a) {
	gul *= 8UL;
}
void rs_8_06_07_8(unsigned long a) {
	unsigned char u = juc;
	v0();
	v1(u);
}
char * rs_8_06_07_9(unsigned long a) {
	return gs.p;
}
void rs_8_06_08_1(long a, unsigned char b, int *c) {
	double t = (gua[b] ? gda[3] : gd);
	jd = t;
}
void rs_8_06_08_2(long a, unsigned char b, int *c) {
	unsigned char u = guc ^ 2;
	juc = u;
}
void rs_8_06_08_3(long a, unsigned char b, int *c) {
	int i = ji;
	unsigned char u = juc;
	for (i = 15; i > 0; i--) { vc(rc(1)); u = (u | guc) * (u ? ((unsigned char)gi3) : u); if (gi2 != 0) gpi[1] = gps->a[4] % gi2; }
}
void rs_8_06_08_4(long a, unsigned char b, int *c) {
	vp(gp);
}
void rs_8_06_08_5(long a, unsigned char b, int *c) {
	v2(gi, gi);
}
void rs_8_06_08_6(long a, unsigned char b, int *c) {
	double t = jd;
	v0();
	vd(t);
}
void rs_8_06_08_7(long a, unsigned char b, int *c) {
	unsigned char u = juc;
	v0();
	switch (gs.u) { case 0: gs.u &= 15019; case 1: gl = gl2 / 16L; break; case 2: gul ^= 66849UL; break; default: vp(&gca[u]); break; }
}
void rs_8_06_08_8(long a, unsigned char b, int *c) {
	gs.d -= -gs.d;
}
unsigned long rs_8_06_08_9(long a, unsigned char b, int *c) {
	return (2UL + gul) - rul(gula[0]);
}
void rs_8_06_09_0(int *a, int *b) {
	int t = (int)guca[3] - 0;
	ji = t;
}
void rs_8_06_09_1(int *a, int *b) {
	int t = ji;
	int u = t;
	ji = u;
}
void rs_8_06_09_2(int *a, int *b) {
	int u = ji;
	gi = u;
}
void rs_8_06_09_3(int *a, int *b) {
	int t = ji;
	gi = t;
}
void rs_8_06_09_4(int *a, int *b) {
	if (gc != 0) gps->c = gc / gc;
}
void rs_8_06_09_5(int *a, int *b) {
	switch (gps->i) { case 5: case 16: gs.i = ~(int)gl2; break; }
}
void rs_8_06_09_6(int *a, int *b) {
	vu((unsigned int)(gc2 >= (char)gul));
}
int rs_8_06_09_7(int *a, int *b) {
	int u = ji;
	v0();
	return ~u & gi3;
}
void rs_8_06_10_1(void) {
	char *t = gps->p + 1;
	jp = t;
}
void rs_8_06_10_2(void) {
	v0();
}
void rs_8_06_10_3(void) {
	if (gs.l & 2) { if (gp[3] != 0) gc2 = gc2 % gp[3]; guca[5] -= 117; vs(gps); }
}
void rs_8_06_10_4(void) {
	if (!gc) { *gpl = gpl[3]; }
}
void rs_8_06_10_5(void) {
	int i = ji;
	char *t = jp;
	v0();
	for (i = 0; i < 9; i++) { if (gc2 != 0) *t = -11 % gc2; }
}
int rs_8_06_10_6(void) {
	return gia[7];
}
void rs_8_06_11_1(void) {
	int t = 127;
	ji = t;
}
void rs_8_06_11_2(void) {
	double u = gda[2] / 0.25;
	jd = u;
}
void rs_8_06_11_3(void) {
	--gp;
}
void rs_8_06_11_4(void) {
	double u = jd;
	vd(u);
}
void rs_8_06_11_5(void) {
	int t = ji;
	v0();
	if (gla[2] != 0) gla[t] = gps->l % gla[2];
}
void rs_8_06_11_6(void) {
	int t = ji;
	v0();
	v2(*gpi & gs.a[t], gi);
}
void rs_8_06_11_7(void) {
	int i = ji;
	v0();
	for (i = 0; i < 10; i++) { gps->c >>= 7; gc = gp[1] = ((char)((long)gp[3] == gpl[2])) - gp[1]; }
}
void rs_8_06_11_8(void) {
	if (gps->c != 0) gp[0] = gps->c % gps->c;
}
void rs_8_06_12_1(unsigned char a, char b, unsigned char c) {
	double t = gs.d - gd;
	jd = t;
}
void rs_8_06_12_2(unsigned char a, char b, unsigned char c) {
	char *u = &gca[a];
	jp = u;
}
void rs_8_06_12_3(unsigned char a, char b, unsigned char c) {
	int i = ji;
	i = 0; while (i < 3) { if (gul != 0) gul = gula[0] % gul; vc((char)gps->l | gc); gps->a[i] += gi; i++; }
}
void rs_8_06_12_4(unsigned char a, char b, unsigned char c) {
	if (r2(gi, gi)) { gu2 >>= 15; gia[7] = gpi[0] = gs.a[4]; gula[b] = gul % 10UL; }
}
void rs_8_06_12_5(unsigned char a, char b, unsigned char c) {
	char *u = jp;
	v0();
	vp(u);
}
void rs_8_06_12_6(unsigned char a, char b, unsigned char c) {
	double t = jd;
	v0();
	vd(t);
}
char * rs_8_06_12_7(unsigned char a, char b, unsigned char c) {
	if (gula[5] & 0x80) return gp;
}
char * rs_8_06_12_8(unsigned char a, char b, unsigned char c) {
	return rp();
}
void rs_8_06_13_0(long *a, int b) {
	b = !ru(gua[3]);
}
void rs_8_06_13_1(long *a, int b) {
	gpi = gpi + b;
}
void rs_8_06_13_2(long *a, int b) {
	gul = (unsigned long)guca[b];
}
void rs_8_06_13_3(long *a, int b) {
	guc ^= 5 & guc;
}
void rs_8_06_13_4(long *a, int b) {
	++gc;
}
char rs_8_06_13_5(long *a, int b) {
	return rc(gps->i | gs.i);
}
void rs_8_06_14_0(void) {
	gula[1] = gul / 7UL;
}
void rs_8_06_14_1(void) {
	gc *= 6;
}
long rs_8_06_14_2(void) {
	return (long)!(-256);
}
void rs_8_06_15_1(void) {
	long u = jl;
	unsigned int t = gs.u;
	ju = t;
}
void rs_8_06_15_2(void) {
	long u = gl2 * 8L;
	jl = u;
}
void rs_8_06_15_3(void) {
	gc >>= 4;
}
void rs_8_06_15_4(void) {
	long u = jl;
	vl(u);
}
void rs_8_06_15_5(void) {
	int i = ji;
	unsigned int t = ju;
	v0();
	for (i = 0; i < 2; i++) { if (t != 0) t = t % t; }
}
unsigned long rs_8_06_15_6(void) {
	return gul;
}
void rs_8_06_16_1(long a) {
	gpi--;
}
void rs_8_06_16_2(long a) {
	int i = ji;
	for (i = 9; i > 0; i--) { gula[i] = (gca[i] > *gp ? gul : gula[i]); gps->a[i] = (gs.a[i] > gia[i]); }
}
void rs_8_06_16_3(long a) {
	gla[0] <<= 3;
}
void rs_8_06_16_4(long a) {
	guc = guca[7];
}
void rs_8_06_16_5(long a) {
	if (gula[6] != gula[1]) if (gul != 0) gula[0] = gula[6] / gul;
}
unsigned int rs_8_06_16_6(long a) {
	return gu / 100;
}
void rs_8_06_17_0(void) {
	vs(gps);
}
void rs_8_06_17_1(void) {
	gul = ((unsigned long)!gs.u) | gula[6];
}
void rs_8_06_17_2(void) {
	gua[5] %= 7;
}
void rs_8_06_17_3(void) {
	gp = gps->p + 1;
}
void rs_8_06_17_4(void) {
	gla[7] = (long)!gua[0] + (long)!8;
}
long rs_8_06_17_5(void) {
	return gl;
}
void rs_8_06_18_0(void) {
	long t = (long)guca[1];
	jl = t;
}
void rs_8_06_18_1(void) {
	char *u = &gca[1];
	jp = u;
}
void rs_8_06_18_2(void) {
	gu >>= 13;
}
void rs_8_06_18_3(void) {
	gu = gua[2];
}
void rs_8_06_18_4(void) {
	++gc2;
}
void rs_8_06_18_5(void) {
	char *u = jp;
	vp(u);
}
void rs_8_06_18_6(void) {
	long t = jl;
	v0();
	gl = t;
}
int * rs_8_06_18_7(void) {
	return gpi;
}
void rs_8_06_19_0(struct st *a) {
	double t = (double)gl * (double)a->c;
	jd = t;
}
void rs_8_06_19_1(struct st *a) {
	double t = jd;
	gd = t;
}
void rs_8_06_19_2(struct st *a) {
	*gpl = ~(gla[2] ^ a->l);
}
void rs_8_06_19_3(struct st *a) {
	vl(gps->l);
}
void rs_8_06_19_4(struct st *a) {
	guc--;
}
unsigned long rs_8_06_19_5(struct st *a) {
	return ~gula[1] ^ (3UL - gula[3]);
}
void rs_8_07_00_0(void) {
	char *t = rp();
	jp = t;
}
void rs_8_07_00_1(void) {
	int *u = &gia[6];
	v0();
	jpi = u;
}
void rs_8_07_00_2(void) {
	gul &= 5UL;
}
void rs_8_07_00_3(void) {
	int *u = jpi;
	v0();
	v1(*u);
}
void rs_8_07_00_4(void) {
	v2(~gs.i, gi);
}
void rs_8_07_00_5(void) {
	gs.l = rl(*gpl) - (gl | 6L);
}
void rs_8_07_00_6(void) {
	char *t = jp;
	v0();
	t = gps->p;
}
void rs_8_07_00_7(void) {
	char *t = jp;
	v0();
	t[5] = (54 >> 1) + (t[2] * gs.c);
}
long rs_8_07_00_8(void) {
	return (long)!(gula[7] / 10UL);
}
void rs_8_07_01_0(char a) {
	char *t = gs.p;
	jp = t;
}
void rs_8_07_01_1(char a) {
	unsigned long u = gula[a];
	jul = u;
}
void rs_8_07_01_2(char a) {
	char *t = jp;
	gs.p = t;
}
void rs_8_07_01_3(char a) {
	gl = -(~65536L);
}
void rs_8_07_01_4(char a) {
	char *t = jp;
	vc(*t & gc);
}
void rs_8_07_01_5(char a) {
	char *t = jp;
	v0();
	t = gps->p + a;
}
void rs_8_07_01_6(char a) {
	unsigned long u = jul;
	v0();
	if (u != 0) u = gula[6] / u;
}
int * rs_8_07_01_7(char a) {
	return gpi;
}
void rs_8_07_02_0(int a) {
	unsigned int t = gu2;
	ju = t;
}
void rs_8_07_02_1(int a) {
	unsigned int t = ju;
	vp(gps->p + t);
}
void rs_8_07_02_2(int a) {
	gula[a] = 0x10000UL;
}
void rs_8_07_03_0(unsigned int a, unsigned long b, char c) {
	int t = gi3;
	ji = t;
}
void rs_8_07_03_1(unsigned int a, unsigned long b, char c) {
	b %= 3UL;
}
void rs_8_07_03_2(unsigned int a, unsigned long b, char c) {
	int t = ji;
	gi = t;
}
void rs_8_07_03_3(unsigned int a, unsigned long b, char c) {
	vs(gps);
}
void rs_8_07_03_4(unsigned int a, unsigned long b, char c) {
	v1(gi & gps->i);
}
unsigned int rs_8_07_03_5(unsigned int a, unsigned long b, char c) {
	return ru((unsigned int)gpl[2]) % 4;
}
void rs_8_07_04_0(unsigned long a, int b) {
	unsigned long t = (unsigned long)gs.i;
	jul = t;
}
void rs_8_07_04_1(unsigned long a, int b) {
	unsigned char u = guca[3];
	juc = u;
}
void rs_8_07_04_2(unsigned long a, int b) {
	gl = *gpl - (long)!0x10000UL;
}
void rs_8_07_04_3(unsigned long a, int b) {
	unsigned long t = jul;
	gul = t;
}
void rs_8_07_04_4(unsigned long a, int b) {
	unsigned char u = juc;
	gl2 = (gla[4] * gla[u]) - (gl - gs.l);
}
void rs_8_07_05_0(void) {
	if (4L > 65536L) { if (gla[5] != 0) gpl[2] = gl2 / gla[5]; gul >>= 25; if (gps->u != 0) gps->u = gu % gps->u; } else { if (gs.c != 0) gps->c = gp[1] % gs.c; guca[3] = guc % 10; gu = gua[0] | (gu2 >> 5); }
}
void rs_8_07_05_1(void) {
	gi = (((unsigned char)gla[1]) == guca[5] ? gps->a[6] : (gi3 >> 7));
}
void rs_8_07_05_2(void) {
	switch (gc) { case 1: vd(gda[2]); break; case 2: vc(gc); break; case 8: gs.d = gd2 - (double)*gp; break; case 10: v1(gia[3]); break; case 20: gia[4] |= 127; break; case 100: vu(gua[4]); break; default: vp(rp()); break; }
}
void rs_8_07_05_3(void) {
	gula[0] = 0x10000UL;
}
void rs_8_07_05_4(void) {
	vs(gps);
}
long rs_8_07_05_5(void) {
	return 5L;
}
void rs_8_07_06_0(struct st *a, double b, char c) {
	int t = *gpi * *gpi;
	ji = t;
}
void rs_8_07_06_1(struct st *a, double b, char c) {
	int *u = rpi(gi);
	jpi = u;
}
void rs_8_07_06_2(struct st *a, double b, char c) {
	int *u = jpi;
	v0();
	gpi = u;
}
void rs_8_07_06_3(struct st *a, double b, char c) {
	switch (gi3) { case 2: gla[c] <<= (c & 15); break; case 8: gs.d *= gs.d; break; case 20: case 1000: b -= 0.5; break; }
}
void rs_8_07_06_4(struct st *a, double b, char c) {
	gl++;
}
void rs_8_07_06_5(struct st *a, double b, char c) {
	int t = ji;
	v0();
	v1(t);
}
void rs_8_07_06_6(struct st *a, double b, char c) {
	v0();
}
int rs_8_07_06_7(struct st *a, double b, char c) {
	int t = ji;
	v0();
	return -t;
}
void rs_8_07_07_0(unsigned long a) {
	int t = gi2;
	ji = t;
}
void rs_8_07_07_1(unsigned long a) {
	gs.d = gd2;
}
void rs_8_07_07_2(unsigned long a) {
	if (gu == 1) gd2 -= gd2 * gda[0];
}
void rs_8_07_07_3(unsigned long a) {
	int t = ji;
	gi = t;
}
int rs_8_07_07_4(unsigned long a) {
	return !gpl[1];
}
void rs_8_07_08_0(void) {
	gu = gua[0];
}
void rs_8_07_08_1(void) {
	gpl[2] = gpl[3];
}
void rs_8_07_08_2(void) {
	vd(gd);
}
void rs_8_07_08_3(void) {
	gc -= 11;
}
char * rs_8_07_08_4(void) {
	return gp;
}
void rs_8_07_09_0(void) {
	char *t = gs.p;
	jp = t;
}
void rs_8_07_09_1(void) {
	vs(gps);
}
void rs_8_07_09_2(void) {
	*gp = gca[0] = rc((int)(' '));
}
void rs_8_07_09_3(void) {
	if (!guca[6]) { gca[0] = -(-98); } else { gia[6] = gpi[2] / 2; gul = ~(gul - gula[7]); }
}
void rs_8_07_09_4(void) {
	char *t = jp;
	v0();
	++t;
}
int rs_8_07_09_5(void) {
	return *gpi;
}
void rs_8_07_10_0(unsigned int a) {
	if (gc2 < 4) { gs.l = gla[7] = gl; if (gpl[0] != 0) gps->l = gpl[0] / gpl[0]; }
}
void rs_8_07_10_1(unsigned int a) {
	if (r1(256)) { ++gc; --gl; gps->c = gc; } else { guc = guca[a] = -(guc >> 6); guca[a] = guc = (guc | guca[a]) >> 4; if (gca[a] != 0) gs.c = (char)gps->i % gca[a]; }
}
unsigned int rs_8_07_10_2(unsigned int a) {
	return gu2 >> (a & 15);
}
void rs_8_07_11_0(int a) {
	double t = gd;
	jd = t;
}
void rs_8_07_11_1(int a) {
	if (*gpi != 0) a = gs.i / *gpi;
}
void rs_8_07_11_2(int a) {
	double t = jd;
	vd(t);
}
void rs_8_07_11_3(int a) {
	if (gul & 1 || 2 > gi2) *gpi = gi3;
}
void rs_8_07_11_4(int a) {
	while (a-- > 0) *gp++ = 5;
}
char * rs_8_07_11_5(int a) {
	return gs.p;
}
void rs_8_07_12_0(unsigned int a, int b) {
	unsigned int t = gua[a];
	ju = t;
}
void rs_8_07_12_1(unsigned int a, int b) {
	unsigned char u = (unsigned char)!guc;
	juc = u;
}
void rs_8_07_12_2(unsigned int a, int b) {
	unsigned int t = ju;
	if (gc || a) gps->a[a] ^= !t;
}
void rs_8_07_12_3(unsigned int a, int b) {
	unsigned int t = ju;
	unsigned char u = juc;
	if (u != ((unsigned char)gul)) { gca[u] = gc - 3; } else { if (t != 0) gs.u = t % t; gpi--; vu(gu); }
}
void rs_8_07_12_4(unsigned int a, int b) {
	unsigned char u = juc;
	v0();
	gd = (u ? (gd2 / 0.5) : (guca[b] > 255 ? 100.0 : 10.0));
}
void rs_8_07_12_5(unsigned int a, int b) {
	unsigned int t = ju;
	v0();
	t++;
}
void rs_8_07_12_6(unsigned int a, int b) {
	gs.i = 1 - b;
}
unsigned long rs_8_07_12_7(unsigned int a, int b) {
	return ~(gul - ((unsigned long)gu2));
}
void rs_8_07_13_0(char a) {
	long t = gps->l + gpl[3];
	jl = t;
}
void rs_8_07_13_1(char a) {
	*gpl = (long)gul;
}
void rs_8_07_13_2(char a) {
	long t = jl;
	gl = t;
}
void rs_8_07_13_3(char a) {
	vd(gda[1] / 100.0);
}
unsigned int rs_8_07_13_4(char a) {
	return (gl2 ? (((unsigned int)gia[a]) + ((unsigned int)guca[a])) : (1480 ^ gu));
}
void rs_8_07_14_1(long a) {
	unsigned int t = (unsigned int)gps->l;
	ju = t;
}
void rs_8_07_14_2(long a) {
	unsigned int t = ju;
	++t;
}
void rs_8_07_14_3(long a) {
	++guc;
}
char * rs_8_07_14_4(long a) {
	if (gua[0] & 0x7 || r0()) return gps->p;
}
void rs_8_07_14_5(long a) {
	unsigned int t = ju;
	v0();
	guca[t] = guc;
}
void rs_8_07_14_6(long a) {
	int i = ji;
	v0();
	for (i = 0; i < 14; i++) { if (gu2 != 0) gu = 1 / gu2; if (gula[i] != 0) gul = gula[2] % gula[i]; }
}
char * rs_8_07_14_7(long a) {
	unsigned int t = ju;
	v0();
	return gs.p + t;
}
void rs_8_07_15_0(int a, char *b, char *c) {
	if (gi3 >= a) gua[5] = gu2;
}
void rs_8_07_15_1(int a, char *b, char *c) {
	gs.l >>= 23;
}
void rs_8_07_15_2(int a, char *b, char *c) {
	gu2 = (*b & 4 ? gps->u : (gua[a] / 10));
}
void rs_8_07_16_0(unsigned long a) {
	unsigned char t = 128;
	juc = t;
}
void rs_8_07_16_1(unsigned long a) {
	char u = gca[3];
	jc = u;
}
void rs_8_07_16_2(unsigned long a) {
	char u = jc;
	vc(u);
}
void rs_8_07_16_3(unsigned long a) {
	++a;
}
void rs_8_07_16_4(unsigned long a) {
	unsigned char t = juc;
	v0();
	v1(t);
}
void rs_8_07_16_5(unsigned long a) {
	vu(gu2);
}
int * rs_8_07_16_6(unsigned long a) {
	unsigned char t = juc;
	v0();
	return gpi + t;
}
void rs_8_07_17_0(void) {
	long t = gla[4];
	jl = t;
}
void rs_8_07_17_1(void) {
	vs(gps);
}
void rs_8_07_17_2(void) {
	long t = jl;
	v0();
	vl(t);
}
void rs_8_07_17_3(void) {
	++gul;
}
char * rs_8_07_17_4(void) {
	return gs.p + 1;
}
void rs_8_07_18_1(unsigned int a, struct st *b) {
	unsigned long t = gul / 16UL;
	jul = t;
}
void rs_8_07_18_2(unsigned int a, struct st *b) {
	unsigned int u = gu2 / 3;
	ju = u;
}
void rs_8_07_18_3(unsigned int a, struct st *b) {
	int i = ji;
	unsigned long t = jul;
	for (i = 4; i > 0; i--) { gs.i = ~127 >> 5; if (t != 0) t = 0x10000UL / t; gc++; }
}
void rs_8_07_18_4(unsigned int a, struct st *b) {
	int i = ji;
	i = 0; while (i < 11) { gda[2] *= -10.0; ++gpi; i++; }
}
void rs_8_07_18_5(unsigned int a, struct st *b) {
	vl(rl(gla[1]));
}
void rs_8_07_18_6(unsigned int a, struct st *b) {
	unsigned int u = ju;
	v0();
	a = gua[6] = ru(u) + (32767 | u);
}
unsigned long rs_8_07_18_7(unsigned int a, struct st *b) {
	if (guc > 6) return -0x10000UL;
}
unsigned long rs_8_07_18_8(unsigned int a, struct st *b) {
	unsigned int u = ju;
	v0();
	return -gula[u] + (0UL / 3UL);
}
void rs_8_07_19_0(int a) {
	unsigned char t = guc;
	juc = t;
}
void rs_8_07_19_1(int a) {
	gc2++;
}
void rs_8_07_19_2(int a) {
	vd(gda[3]);
}
int rs_8_07_19_3(int a) {
	unsigned char t = juc;
	v0();
	if (t & 2) return (gua[2] < gs.u);
}
void rs_8_07_19_4(int a) {
	gd = -gs.d;
}
void rs_8_07_19_5(int a) {
	--gi3;
}
int rs_8_07_19_6(int a) {
	return (a & gs.i) / 2;
}
void rs_8_08_00_0(void) {
	long t = *gpl;
	jl = t;
}
void rs_8_08_00_1(void) {
	double u = gd2 - gd2;
	jd = u;
}
void rs_8_08_00_2(void) {
	if (6 <= gu2 || gs.l != 65536L) { if (gua[6] != 0) gu2 = gua[1] % gua[6]; }
}
void rs_8_08_00_3(void) {
	long t = jl;
	gl = t;
}
void rs_8_08_00_4(void) {
	double u = jd;
	vd(u);
}
void rs_8_08_00_5(void) {
	gula[1] = gula[4];
}
unsigned int rs_8_08_00_6(void) {
	return gu2;
}
void rs_8_08_01_1(void) {
	int i = ji;
	i = 0; while (i < 11) { gul = -(gula[i] / 7UL); *gpi ^= (int)guc + (int)gc2; guc = (unsigned char)!r0(); i++; }
}
void rs_8_08_01_2(void) {
	vc(gca[2] >> 6);
}
void rs_8_08_01_3(void) {
	gu2 = (unsigned int)gul;
}
void rs_8_08_01_4(void) {
	gd2 = gs.d * -gs.d;
}
void rs_8_08_01_5(void) {
	guca[7] -= guc ^ guca[7];
}
unsigned int rs_8_08_01_6(void) {
	return gps->u;
}
void rs_8_08_02_1(void) {
	long t = (long)(gul <= gula[2]);
	jl = t;
}
void rs_8_08_02_2(void) {
	long u = 1L + 85264L;
	jl = u;
}
void rs_8_08_02_3(void) {
	int i = ji;
	long u = jl;
	i = 4; do { if (gu2 != 0) gu = gs.u / gu2; } while (--i > 0);
}
void rs_8_08_02_4(void) {
	int i = ji;
	if (gs.a[6] & 0x10) { gc2 = (gca[7] | gc2) << 6; } else { if (gula[5] != 0) gula[0] = 0x10000UL % gula[5]; gs.i = gps->a[5] ^ gi2; }
}
void rs_8_08_02_5(void) {
	long u = jl;
	u &= ~gl2;
}
void rs_8_08_02_6(void) {
	gpi = &gia[1];
}
void rs_8_08_02_7(void) {
	long t = jl;
	vl(t);
}
int rs_8_08_02_8(void) {
	return (gpi[0] = 615);
}
void rs_8_08_03_1(int a) {
	unsigned char t = (gla[6] ? 6 : guca[a]);
	juc = t;
}
void rs_8_08_03_2(int a) {
	unsigned char u = 255 << (a & 7);
	juc = u;
}
void rs_8_08_03_3(int a) {
	unsigned char t = juc;
	gpi = gpi + t;
}
void rs_8_08_03_4(int a) {
	--gul;
}
void rs_8_08_03_5(int a) {
	unsigned char u = juc;
	if (gua[0] > gu) { if (gc != 0) gs.c = 'a' % gc; u = guca[a] - (guc - 255); } else { vs(gps); gl = gla[7] = (long)(gul << 18); }
}
void rs_8_08_03_6(int a) {
	int i = ji;
	v0();
	i = 0; while (i < 10) { gua[i] = (unsigned int)!gul; if (gula[i] != 0) gul = gul / gula[i]; i++; }
}
void rs_8_08_03_7(int a) {
	gca[7] %= 2;
}
int rs_8_08_03_8(int a) {
	return (gi2 + 2) ^ gi2;
}
void rs_8_08_04_1(unsigned char a, double b) {
	guca[a] += guca[2];
}
void rs_8_08_04_2(unsigned char a, double b) {
	gu2 <<= (a & 15);
}
void rs_8_08_04_3(unsigned char a, double b) {
	gs.d += gd2;
}
void rs_8_08_04_4(unsigned char a, double b) {
	int i = ji;
	for (i = 5; i > 0; i--) { vs(gps); }
}
void rs_8_08_05_1(unsigned long a, double b) {
	if (gl <= gl2) if (gs.c != 0) gps->c = gc / gs.c;
}
void rs_8_08_05_2(unsigned long a, double b) {
	int i = ji;
	for (i = 0; i < 8; i++) { if (gla[1] != 0) gl2 = gl / gla[1]; }
}
void rs_8_08_05_3(unsigned long a, double b) {
	gl = gla[3] = *gpl;
}
int * rs_8_08_05_4(unsigned long a, double b) {
	return gpi;
}
void rs_8_08_06_0(void) {
	gs.d += gd2;
}
void rs_8_08_06_1(void) {
	gu2 = (255 | gua[0]) + (gps->u << 15);
}
void rs_8_08_06_2(void) {
	gs.c = rc(16) >> 4;
}
void rs_8_08_06_3(void) {
	gul = rul(gula[6] >> 3);
}
void rs_8_08_06_4(void) {
	if (!gps->i || gps->i <= 9) gps->u = gu2 * (gps->u >> 3);
}
void rs_8_08_07_0(unsigned char a, long *b, int c) {
	unsigned char t = guca[6] + 139;
	juc = t;
}
void rs_8_08_07_1(unsigned char a, long *b, int c) {
	gul = gula[0] % 4UL;
}
void rs_8_08_07_2(unsigned char a, long *b, int c) {
	gula[2] = gul | gula[c];
}
void rs_8_08_07_3(unsigned char a, long *b, int c) {
	unsigned char t = juc;
	switch (gc) { case 0: gc |= 9; break; case 1: case 2: gs.a[t] &= gi2; default: gpi = &gia[c]; break; }
}
void rs_8_08_07_4(unsigned char a, long *b, int c) {
	vp(gps->p);
}
void rs_8_08_08_0(double a, int b, long *c) {
	char t = gps->c;
	jc = t;
}
void rs_8_08_08_1(double a, int b, long *c) {
	char t = jc;
	long u = gpl[0] << (t & 15);
	jl = u;
}
void rs_8_08_08_2(double a, int b, long *c) {
	gu2 <<= 6;
}
void rs_8_08_08_3(double a, int b, long *c) {
	char t = jc;
	vu((unsigned int)t);
}
void rs_8_08_08_4(double a, int b, long *c) {
	long u = jl;
	v0();
	gl = u;
}
void rs_8_08_08_5(double a, int b, long *c) {
	vp(gs.p);
}
int * rs_8_08_08_6(double a, int b, long *c) {
	return rpi(gia[4] * 12);
}
void rs_8_08_09_0(int a, char *b) {
	double t = gs.d - gda[3];
	jd = t;
}
void rs_8_08_09_1(int a, char *b) {
	char u = gp[0];
	jc = u;
}
void rs_8_08_09_2(int a, char *b) {
	gu++;
}
void rs_8_08_09_3(int a, char *b) {
	double t = jd;
	gd = t;
}
void rs_8_08_09_4(int a, char *b) {
	while (a-- > 0) *b++ = '9';
}
void rs_8_08_09_5(int a, char *b) {
	gla[1] *= 11L;
}
void rs_8_08_09_6(int a, char *b) {
	guc = ~5 + 35;
}
void rs_8_08_09_7(int a, char *b) {
	char u = jc;
	vc(u);
}
int rs_8_08_09_8(int a, char *b) {
	return (int)-19 / 7;
}
void rs_8_08_10_0(int a) {
	char t = ~gca[a];
	jc = t;
}
void rs_8_08_10_1(int a) {
	unsigned char u = guca[a];
	juc = u;
}
void rs_8_08_10_2(int a) {
	gula[a] = gul | gula[a];
}
void rs_8_08_10_3(int a) {
	unsigned char u = juc;
	if (gc & 4 && !gl) { gu = gs.u = 0; u = (guc ^ u) + (u << 1); gi3++; }
}
void rs_8_08_10_4(int a) {
	char t = jc;
	gc = t;
}
int rs_8_08_10_5(int a) {
	return r0() ^ (int)gl;
}
void rs_8_08_11_0(int a, unsigned long b, char c) {
	gda[2] = gda[3] - 10.0;
}
void rs_8_08_11_1(int a, unsigned long b, char c) {
	vc(gc | c);
}
void rs_8_08_11_2(int a, unsigned long b, char c) {
	guc = guca[c] = 255;
}
void rs_8_08_11_3(int a, unsigned long b, char c) {
	vs(gps);
}
int * rs_8_08_11_4(int a, unsigned long b, char c) {
	return gpi;
}
void rs_8_08_12_0(void) {
	char *t = gp;
	jp = t;
}
void rs_8_08_12_1(void) {
	char u = 1 << 3;
	jc = u;
}
void rs_8_08_12_2(void) {
	gl *= 5L;
}
void rs_8_08_12_3(void) {
	char u = jc;
	gl = -gla[u] + gl2;
}
void rs_8_08_12_4(void) {
	char *t = jp;
	vp(t);
}
char rs_8_08_12_5(void) {
	char u = jc;
	v0();
	return ((char)(*gp >= u)) | ~u;
}
void rs_8_08_13_0(unsigned char a, long b) {
	char *t = gp;
	jp = t;
}
void rs_8_08_13_1(unsigned char a, long b) {
	char *u = gp;
	jp = u;
}
void rs_8_08_13_2(unsigned char a, long b) {
	char *t = jp;
	if (r2(gi2, gs.i)) { gda[1] -= gs.d; if (gula[a] != 0) gul = 6UL / gula[a]; gca[1] = *t; }
}
void rs_8_08_13_3(unsigned char a, long b) {
	char *u = jp;
	v0();
	gp = u;
}
void rs_8_08_13_4(unsigned char a, long b) {
	v0();
}
void rs_8_08_13_5(unsigned char a, long b) {
	gd = gd2;
}
void rs_8_08_13_6(unsigned char a, long b) {
	gs.a[a] &= gi3 & gia[a];
}
void rs_8_08_14_0(long *a, char *b) {
	int t = ~gia[0];
	ji = t;
}
void rs_8_08_14_1(long *a, char *b) {
	unsigned char u = guca[5];
	juc = u;
}
void rs_8_08_14_2(long *a, char *b) {
	int t = ji;
	v1(t);
}
void rs_8_08_14_3(long *a, char *b) {
	vu(gu / 16);
}
void rs_8_08_14_4(long *a, char *b) {
	vs(gps);
}
void rs_8_08_14_5(long *a, char *b) {
	unsigned char u = juc;
	v0();
	guc = u;
}
int rs_8_08_14_6(long *a, char *b) {
	return r1(gi3) + (673 & 100);
}
void rs_8_08_15_0(int a) {
	unsigned char t = -guca[a];
	juc = t;
}
void rs_8_08_15_1(int a) {
	unsigned char t = juc;
	unsigned long u = 0x10000UL ^ gula[t];
	jul = u;
}
void rs_8_08_15_2(int a) {
	gp = gp + a;
}
void rs_8_08_15_3(int a) {
	unsigned char t = juc;
	gp = gps->p + t;
}
void rs_8_08_15_4(int a) {
	unsigned char t = juc;
	vc(gca[t] * gp[2]);
}
void rs_8_08_15_5(int a) {
	vs(gps);
}
void rs_8_08_15_6(int a) {
	unsigned long u = jul;
	v0();
	gul = u;
}
char * rs_8_08_15_7(int a) {
	unsigned char t = juc;
	v0();
	return gs.p + t;
}
void rs_8_08_16_0(void) {
	unsigned char t = 179 / 100;
	juc = t;
}
void rs_8_08_16_1(void) {
	vc(5);
}
void rs_8_08_16_2(void) {
	gp = &gca[0];
}
void rs_8_08_16_3(void) {
	unsigned char t = juc;
	v0();
	if (*gp != 'z' || gu2) if (gi3 != 0) gia[7] = gia[t] / gi3;
}
void rs_8_08_16_4(void) {
	unsigned char t = juc;
	v0();
	gia[t] ^= gs.i;
}
void rs_8_08_16_5(void) {
	if (gl2 < 65536L) { if (gs.l != 0) *gpl = (long)gs.a[0] % gs.l; --gul; }
}
unsigned long rs_8_08_16_6(void) {
	return 87362UL - (gul + 30704UL);
}
void rs_8_08_17_0(long a) {
	unsigned char t = 255;
	juc = t;
}
void rs_8_08_17_1(long a) {
	unsigned char t = juc;
	gca[t] = gc ^ gca[1];
}
void rs_8_08_17_2(long a) {
	gi3 >>= 12;
}
void rs_8_08_17_3(long a) {
	if (gps->i != 0) gi3 = gi2 / gps->i;
}
void rs_8_08_17_4(long a) {
	gda[2] += 0.5 + gd2;
}
int rs_8_08_17_5(long a) {
	return r1((r2(gi2, gi) ? gs.i : gi3));
}
void rs_8_08_18_0(void) {
	int *t = gpi + 1;
	jpi = t;
}
void rs_8_08_18_1(void) {
	unsigned char u = guca[1] | guc;
	juc = u;
}
int rs_8_08_18_2(void) {
	unsigned char u = juc;
	if (gl >= gla[u] || !*gpi) return gps->a[0] % 100;
}
void rs_8_08_18_3(void) {
	unsigned char u = juc;
	gca[u] = gps->c - 'a';
}
void rs_8_08_18_4(void) {
	int *t = jpi;
	gpi = t;
}
int rs_8_08_18_5(void) {
	return (339 | 2) + (int)7;
}
void rs_8_08_19_0(int a, unsigned long b, unsigned int c) {
	gula[a] = gula[c];
}
void rs_8_08_19_1(int a, unsigned long b, unsigned int c) {
	if (gc) { gi = ~246; if (gc2 != 0) gca[2] = gca[6] / gc2; gda[2] = gs.d - gd; }
}
void rs_8_08_19_2(int a, unsigned long b, unsigned int c) {
	vs(gps);
}
void rs_8_08_19_3(int a, unsigned long b, unsigned int c) {
	vs(gps);
}
void rs_8_08_19_4(int a, unsigned long b, unsigned int c) {
	gd -= -gd;
}
int rs_8_08_19_5(int a, unsigned long b, unsigned int c) {
	return r2(gi3 << 14, gi);
}
void rs_8_09_00_0(long *a, int b) {
	vl(6L);
}
void rs_8_09_00_1(long *a, int b) {
	++gul;
}
void rs_8_09_00_2(long *a, int b) {
	b += gi3 % 3;
}
void rs_8_09_00_3(long *a, int b) {
	--gl;
}
void rs_8_09_00_4(long *a, int b) {
	vd((gc != 1 ? 10.0 : gd2));
}
int rs_8_09_00_5(long *a, int b) {
	return gi3 - (gs.a[1] - gi3);
}
void rs_8_09_01_0(unsigned char a, char b, long c) {
	unsigned char t = 255 ^ a;
	juc = t;
}
void rs_8_09_01_1(unsigned char a, char b, long c) {
	--gi3;
}
void rs_8_09_01_2(unsigned char a, char b, long c) {
	gs.d = gda[2] / 1.0;
}
void rs_8_09_01_3(unsigned char a, char b, long c) {
	gi3++;
}
void rs_8_09_01_4(unsigned char a, char b, long c) {
	unsigned char t = juc;
	v1(t);
}
char rs_8_09_01_5(unsigned char a, char b, long c) {
	return (b = *gp);
}
void rs_8_09_02_0(void) {
	int *t = rpi(8);
	jpi = t;
}
void rs_8_09_02_1(void) {
	long u = 65536L << 25;
	v0();
	jl = u;
}
void rs_8_09_02_2(void) {
	guc = (unsigned char)((gda[2] * gd2) <= (double)gi2);
}
void rs_8_09_02_3(void) {
	gi2 = ((gi2 > 256 ? gd : gd2) != (gs.d + gd));
}
void rs_8_09_02_4(void) {
	int *t = jpi;
	v0();
	v1(*t);
}
void rs_8_09_02_5(void) {
	long u = jl;
	v0();
	vl(u);
}
int * rs_8_09_02_6(void) {
	int *t = jpi;
	v0();
	return t + 1;
}
void rs_8_09_03_0(int *a, int b, int c) {
	int t = gia[b];
	ji = t;
}
void rs_8_09_03_1(int *a, int b, int c) {
	++gu;
}
void rs_8_09_03_2(int *a, int b, int c) {
	gps->u = 256;
}
void rs_8_09_03_3(int *a, int b, int c) {
	int t = ji;
	gi -= r2(t, gi);
}
void rs_8_09_03_4(int *a, int b, int c) {
	int t = ji;
	v0();
	gp = gp + t;
}
int * rs_8_09_03_5(int *a, int b, int c) {
	return gpi + c;
}
void rs_8_09_04_0(void) {
	int t = gps->a[4] | gpi[3];
	ji = t;
}
void rs_8_09_04_1(void) {
	int t = ji;
	double u = (gca[t] != 1 ? gs.d : gs.d);
	jd = u;
}
void rs_8_09_04_2(void) {
	vl(gl2);
}
void rs_8_09_04_3(void) {
	gca[0] = gca[5];
}
void rs_8_09_04_4(void) {
	int t = ji;
	v0();
	v1(t);
}
void rs_8_09_04_5(void) {
	double u = jd;
	v0();
	vd(u);
}
unsigned int rs_8_09_04_6(void) {
	return ((unsigned int)gps->c) / 2;
}
void rs_8_09_05_0(unsigned int a, unsigned char b, long c) {
	gu2 = gps->u;
}
void rs_8_09_05_1(unsigned int a, unsigned char b, long c) {
	guc ^= guca[0];
}
void rs_8_09_05_2(unsigned int a, unsigned char b, long c) {
	gps->a[b] = r2(gs.i, gi) - (gia[3] - gi);
}
unsigned long rs_8_09_05_3(unsigned int a, unsigned char b, long c) {
	return (gula[b] = gula[3]);
}
void rs_8_09_06_0(void) {
	long t = (long)!gla[3];
	jl = t;
}
void rs_8_09_06_1(void) {
	v1(gps->a[3] + gs.i);
}
void rs_8_09_06_2(void) {
	long t = jl;
	v0();
	gl = t;
}
void rs_8_09_06_3(void) {
	v1(gi3 & gps->i);
}
int * rs_8_09_06_4(void) {
	return gpi;
}
void rs_8_09_07_1(double a) {
	unsigned int t = -((unsigned int)guca[0]);
	ju = t;
}
void rs_8_09_07_2(double a) {
	unsigned int t = ju;
	t = (255 * t) - (gps->c > 22 ? gu : gs.u);
}
void rs_8_09_07_3(double a) {
	int i = ji;
	unsigned int t = ju;
	for (i = 0; i < 6; i++) { t = (256 << 9) ^ (gu | t); *gp = gs.c; if (t != 0) gua[1] = gs.u / t; }
}
void rs_8_09_07_4(double a) {
	*gpl = rl(gs.l);
}
void rs_8_09_08_1(long a, char b) {
	int t = (gua[b] ? gpi[0] : gps->a[b]);
	ji = t;
}
void rs_8_09_08_2(long a, char b) {
	gps->u = gu2;
}
void rs_8_09_08_3(long a, char b) {
	int t = ji;
	v1(t * 2);
}
void rs_8_09_08_4(long a, char b) {
	gu2 = (unsigned int)((long)(gia[3] == gi));
}
void rs_8_09_08_5(long a, char b) {
	int i = ji;
	v0();
	for (i = 2; i > 0; i--) { vp(gs.p); }
}
long rs_8_09_08_6(long a, char b) {
	return ~(~65536L);
}
void rs_8_09_09_0(void) {
	char t = *gp % 16;
	jc = t;
}
void rs_8_09_09_1(void) {
	char t = jc;
	int u = gps->a[t] << (t & 15);
	ji = u;
}
void rs_8_09_09_2(void) {
	vs(gps);
}
void rs_8_09_09_3(void) {
	char t = jc;
	v0();
	gc = t;
}
void rs_8_09_09_4(void) {
	gua[6] = gu = (unsigned int)gi2;
}
void rs_8_09_09_5(void) {
	int u = ji;
	v0();
	if (gula[u] != 0) gul = gul / gula[u];
}
void rs_8_09_10_1(unsigned int a, int b) {
	int i = ji;
	i = 11; do { *gpl += (long)(gps->c >= 3); a = gu; } while (--i > 0);
}
void rs_8_09_10_2(unsigned int a, int b) {
	gps->a[b] = r1(gi);
}
void rs_8_09_10_3(unsigned int a, int b) {
	*gp = gc = -(~gc);
}
char * rs_8_09_10_4(unsigned int a, int b) {
	return gp;
}
void rs_8_09_11_0(long *a, struct st *b, unsigned char c) {
	char *t = gps->p;
	jp = t;
}
void rs_8_09_11_1(long *a, struct st *b, unsigned char c) {
	unsigned char u = (unsigned char)*gpl;
	juc = u;
}
void rs_8_09_11_2(long *a, struct st *b, unsigned char c) {
	gpi = rpi(gi / 4);
}
void rs_8_09_11_3(long *a, struct st *b, unsigned char c) {
	gi3 = r1(gi3 - gs.i);
}
void rs_8_09_11_4(long *a, struct st *b, unsigned char c) {
	*gpl = gl = (a[3] * 7L) << 11;
}
void rs_8_09_11_5(long *a, struct st *b, unsigned char c) {
	unsigned char u = juc;
	v0();
	if (gula[1] <= gula[u]) { guc /= 16; if (gi3 != 0) gs.i = gi / gi3; } else { gula[u] = ~gul; gu = gua[c] = (gu2 & 256) * (gua[c] + 7); ++gpi; }
}
void rs_8_09_11_6(long *a, struct st *b, unsigned char c) {
	char *t = jp;
	v0();
	gp = t;
}
unsigned int rs_8_09_11_7(long *a, struct st *b, unsigned char c) {
	unsigned char u = juc;
	v0();
	return (gu = gs.u);
}
void rs_8_09_12_1(int *a, int b, unsigned long c) {
	gd2 -= 0.25;
}
void rs_8_09_12_2(int *a, int b, unsigned long c) {
	gp[1] = gc / 3;
}
void rs_8_09_12_3(int *a, int b, unsigned long c) {
	guca[b] = guc = ~7 >> (b & 7);
}
void rs_8_09_12_4(int *a, int b, unsigned long c) {
	if (*gp != 0) gca[2] = *gp / *gp;
}
void rs_8_09_12_5(int *a, int b, unsigned long c) {
	int i = ji;
	for (i = 0; i < 8; i++) { guc = guca[i] >> (i & 7); }
}
void rs_8_09_13_0(unsigned long a, unsigned long b) {
	char t = gc;
	jc = t;
}
void rs_8_09_13_1(unsigned long a, unsigned long b) {
	unsigned long u = gul;
	jul = u;
}
void rs_8_09_13_2(unsigned long a, unsigned long b) {
	switch (gi2) { case 0: gpi = rpi(2); break; case 1: gi3 >>= 6; default: gs.i = gia[3] = (-47 <= '9'); break; }
}
void rs_8_09_13_3(unsigned long a, unsigned long b) {
	unsigned long u = jul;
	v0();
	vl((long)u);
}
long rs_8_09_13_4(unsigned long a, unsigned long b) {
	if (guc != guca[1]) return gl + gpl[2];
}
void rs_8_09_13_5(unsigned long a, unsigned long b) {
	gs.d *= 2.5 * gd;
}
void rs_8_09_13_6(unsigned long a, unsigned long b) {
	char t = jc;
	v0();
	gua[t] = gu - gua[t];
}
void rs_8_09_13_7(unsigned long a, unsigned long b) {
	gda[1] = gd + gs.d;
}
long rs_8_09_13_8(unsigned long a, unsigned long b) {
	char t = jc;
	v0();
	return (long)!(gs.i & gia[t]);
}
void rs_8_09_14_0(int a, int *b) {
	gc2 = gca[2] ^ 9;
}
void rs_8_09_14_1(int a, int *b) {
	gs.u = ((unsigned int)gc2) - gps->u;
}
void rs_8_09_14_2(int a, int *b) {
	if (gc != 0) gs.c = gca[a] / gc;
}
int rs_8_09_14_3(int a, int *b) {
	return (int)gul;
}
void rs_8_09_15_0(double a, double b) {
	gca[5] /= 2;
}
void rs_8_09_15_1(double a, double b) {
	gc2 = rc(*gpi) - ~gp[2];
}
void rs_8_09_15_2(double a, double b) {
	gca[2] = (gc >> 4) & rc(gi2);
}
int rs_8_09_15_3(double a, double b) {
	return gs.i >> 5;
}
void rs_8_09_16_0(unsigned int a, int b, int *c) {
	char t = 93 + gca[b];
	jc = t;
}
void rs_8_09_16_1(unsigned int a, int b, int *c) {
	char t = jc;
	vc(t);
}
void rs_8_09_16_2(unsigned int a, int b, int *c) {
	gi3 = !guc % 2;
}
void rs_8_09_16_3(unsigned int a, int b, int *c) {
	gl = 65536L;
}
char rs_8_09_16_4(unsigned int a, int b, int *c) {
	return (a < 23682 ? ~gs.c : (gca[a] - gca[3]));
}
void rs_8_09_17_0(unsigned int a, unsigned int b, unsigned char c) {
	double t = gd / 0.25;
	jd = t;
}
void rs_8_09_17_1(unsigned int a, unsigned int b, unsigned char c) {
	int u = r2(gps->i, gi);
	ji = u;
}
void rs_8_09_17_2(unsigned int a, unsigned int b, unsigned char c) {
	a--;
}
void rs_8_09_17_3(unsigned int a, unsigned int b, unsigned char c) {
	int u = ji;
	v0();
	gi = u;
}
void rs_8_09_17_4(unsigned int a, unsigned int b, unsigned char c) {
	double t = jd;
	v0();
	gd = t;
}
void rs_8_09_17_5(unsigned int a, unsigned int b, unsigned char c) {
	vd(gd);
}
char * rs_8_09_17_6(unsigned int a, unsigned int b, unsigned char c) {
	return &gca[b];
}
void rs_8_09_18_0(unsigned long a, unsigned char b, char c) {
	char *t = gp;
	jp = t;
}
void rs_8_09_18_1(unsigned long a, unsigned char b, char c) {
	char *u = rp();
	jp = u;
}
void rs_8_09_18_2(unsigned long a, unsigned char b, char c) {
	gl = -(-65536L);
}
void rs_8_09_18_3(unsigned long a, unsigned char b, char c) {
	gl2 = rl(*gpl - gl);
}
void rs_8_09_18_4(unsigned long a, unsigned char b, char c) {
	char *u = jp;
	v0();
	vl(gla[0] - (long)u[2]);
}
void rs_8_09_18_5(unsigned long a, unsigned char b, char c) {
	char *t = jp;
	v0();
	gp = t;
}
void rs_8_09_18_6(unsigned long a, unsigned char b, char c) {
	gl ^= (long)gc2;
}
void rs_8_09_18_7(unsigned long a, unsigned char b, char c) {
	gul %= 2UL;
}
int * rs_8_09_18_8(unsigned long a, unsigned char b, char c) {
	return gpi;
}
void rs_8_09_19_0(long a) {
	unsigned long t = gula[3];
	jul = t;
}
void rs_8_09_19_1(long a) {
	int u = gi3 << 2;
	ji = u;
}
void rs_8_09_19_2(long a) {
	gc <<= 4;
}
void rs_8_09_19_3(long a) {
	while (gi-- > 0) *gp++ = 7;
}
void rs_8_09_19_4(long a) {
	int u = ji;
	v1(u);
}
void rs_8_09_19_5(long a) {
	unsigned long t = jul;
	v0();
	t = gul;
}
long rs_8_09_19_6(long a) {
	return gs.l ^ (*gpl + 65536L);
}
