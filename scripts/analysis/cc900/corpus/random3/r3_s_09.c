/* Random C89 program r3_s_09.c: gen_random.py --seed 3 --count 10 --funcs 20 --size small (file 9).
   Ours, deterministic; the docstring of gen_random.py says what it may contain and what it avoids. */
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

unsigned long r3_09_00(int a, int b, unsigned int c) {
	char *t = gs.p;
	int *u = gpi;
	u--;
	vd((*gpi <= a ? gd2 : gd2));
	vp(t);
	gp[0] *= 10;
	if (gs.l != 0) gs.l = 2L % gs.l;
	return gula[c] * 4UL;
}
char * r3_09_01(double a, unsigned char b) {
	long t = (long)(gc < gc2);
	double u = gd2;
	gia[b] = gpi[2];
	gd = u;
	gpi = gpi + b;
	gpi = gpi + b;
	vl(t);
	return gp;
}
char * r3_09_02(void) {
	int *t = gpi;
	v1(*t);
	vl(((gul = 54902UL) >= 4UL ? gl : gps->l));
	gul = gula[4] = gula[6];
	return gp;
}
void r3_09_03(struct st *a, unsigned char b) {
	int i;
	gpi = rpi(gi);
	gla[5] >>= (b & 15);
	for (i = 12; i > 0; i--) { gula[b] = rul(gula[i] % 7UL); }
	gu = (unsigned int)(((unsigned long)gl2) * gula[3]);
	gps->u = ~gu;
}
int r3_09_04(void) {
	int *t = gpi;
	v2(gia[1] & gs.a[7], gi);
	v1(*t);
	gs.c -= gc2;
	--gp;
	return *gpi;
}
long r3_09_05(int a) {
	long t = 17740L;
	a >>= 10;
	if (t != 0) gla[a] = -55012L % t;
	return t;
}
int r3_09_06(long a) {
	int t = gps->a[3];
	int u = gi3;
	v1(t);
	switch (gi2) { case 0: gua[0] %= 7; break; case 1: v2(u, gi); case 2: *gpi *= 10; break; case 3: gl2 >>= 16; break; case 4: case 5: vu(gu); break; default: vp(gp); break; }
	gp--;
	--gul;
	gu++;
	gps->p = &gca[3];
	return gi3;
}
unsigned int r3_09_07(char a, struct st *b, long c) {
	int i;
	int t = 255;
	v1(r0());
	for (i = 0; i < 6; i++) { gul++; gs.i = (gi2 + t) - t; }
	for (i = 0; i < 2; i++) { vp(gs.p); gl *= 6L; vd(gd2 - gda[1]); }
	gs.i = 2;
	c = c ^ ((long)!((unsigned long)gps->u));
	return gu >> 7;
}
unsigned long r3_09_08(unsigned long a, struct st *b) {
	gpi[3] = gi2 = gia[1];
	if (gul != 0) gula[6] = 70762UL / gul;
	gda[2] -= gd;
	return rul((!gu2 ? gul : ((unsigned long)guca[0])));
}
int r3_09_09(long a) {
	unsigned int t = gua[2];
	guca[3] = guc;
	t = ~gu2 ^ ru(t);
	v2(gi2, gpi[0]);
	gul = gul ^ (gps->l > a ? gul : gula[t]);
	return ((41 - gp[3]) < (8 & gc));
}
unsigned long r3_09_10(int a, long b) {
	int i;
	unsigned char t = (gi <= gi3 ? guc : ((unsigned char)gla[a]));
	switch (gu2) { case 0: v0(); break; case 1: vc(*gp); case 2: v1(gps->i); break; default: t = ~255; break; }
	for (i = 0; i < a; i++) { gd = gda[1]; gi2 = 100; }
	gp--;
	return rul(gula[a]) % 10UL;
}
unsigned long r3_09_11(unsigned int a) {
	int i;
	unsigned char t = guc;
	int *u = rpi(gs.a[a]);
	gs.d = gd2 + (double)gca[t];
	guc = t;
	i = 0; while (i < 3) { vp(gs.p); gs.u = 256 >> 3; i++; }
	gpi = u;
	return rul(0x10000UL + gul);
}
void r3_09_12(void) {
	char t = gca[4] - 2;
	gu -= ru(gua[t]);
	vl(gs.l << 3);
	gul <<= 26;
	v0();
	if ('a' != t) { if (t != 0) gc2 = 8 % t; }
}
int r3_09_13(char *a) {
	long t = (long)gc2 ^ *gpl;
	unsigned long u = (unsigned long)gl;
	gs.c -= gc2 - 9;
	if ((t = *gpl) >= 3511L || gul >= 3UL) u = 1UL >> 29;
	return ((int)((unsigned char)gu)) >> 3;
}
unsigned int r3_09_14(void) {
	double t = gs.d;
	unsigned char u = ((unsigned char)gl) % 3;
	vd(t);
	gi3 = ~(gi ^ gps->a[6]);
	gpi = gpi + u;
	return gu;
}
int r3_09_15(unsigned char a, char b, int c) {
	gu -= (unsigned int)!37194UL;
	gu2 <<= 4;
	gula[b] = gula[a] | 5UL;
	return (gi2 + gs.i) * (8 - (int)gc2);
}
long r3_09_16(void) {
	if (gca[6] != 0) gs.c = 'a' % gca[6];
	switch (gps->c) { case 1: gula[7] = gula[0]; break; case 2: vs(gps); break; case 100: vc(gc2); break; default: vl((long)gul); break; }
	gula[6] = 6UL;
	vc(*gp + 7);
	if (!gps->i) { gda[1] = gs.d; vl(gs.l >> 3); } else { guca[6] = guc << 3; }
	return gla[5];
}
void r3_09_17(char *a, char b) {
	int t = 2 / 3;
	guc = (unsigned char)(gul / 3UL);
	gu2 = gu;
	guc = guc + ~guca[6];
	gi = t;
}
void r3_09_18(void) {
	guc /= 3;
	if (gi2 < gia[6]) { gia[0] /= 16; }
}
int r3_09_19(void) {
	unsigned long t = (unsigned long)guca[4];
	int u = gps->a[2] | gi3;
	guca[u] = ~5;
	gs.d += 0.25 / 10.0;
	vl((long)t);
	switch (gl) { case 0L: u = gia[5] / 7; break; case 1L: vp(gp); break; default: gd = gs.d; break; }
	gd2 += gda[1] - gd;
	switch (gps->u) { case 0: guc = guc % 16; break; case 1: guc = guc - guca[0]; break; case 2: gi2 = gs.i; break; case 3: gps->l = *gpl; default: gpl[0] = gl = 65536L; break; }
	return (int)rl(gl);
}
