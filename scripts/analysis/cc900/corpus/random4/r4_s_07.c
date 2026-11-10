/* Random C89 program r4_s_07.c: gen_random.py --seed 4 --count 10 --funcs 20 --size small (file 7).
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

void r4_07_00(long a, char b) {
	int i;
	i = 0; while (i < 6) { vs(gps); gd2 *= gd * gs.d; i++; }
	guc <<= 5;
}
long r4_07_01(int a, unsigned int b) {
	double t = 3.0;
	unsigned int u = gs.u + b;
	gla[b] = gl ^ 7L;
	vl(gpl[0]);
	vu(u);
	vd(t);
	return rl(gl2) * (gpl[1] + 65536L);
}
void r4_07_02(unsigned char a, unsigned long b, char c) {
	int i;
	unsigned long t = rul(0x10000UL);
	int *u = rpi((int)gps->l);
	for (i = 2; i > 0; i--) { v2(gi2, gi3); }
	if (gca[a] >= gs.c) { gca[a] = gps->c << 1; } else { if (gl >= gs.l) guc = (gca[c] == -30 ? guc : (a * guc)); }
	--t;
	gla[1] = gl | -97327L;
	if (gu2 != 0) gs.u = gs.u / gu2;
}
unsigned long r4_07_03(int a, int *b, long c) {
	gul = ~((unsigned long)!guc);
	v0();
	if (gs.c) { gda[1] = gda[2]; } else { if (gua[6] != 0) gu2 = gu % gua[6]; guc--; }
	return gula[4];
}
void r4_07_04(void) {
	gua[5] = gu - 1;
	gca[6] = (char)gl2 & gc2;
	if (gl2 != 0) gl = gl2 % gl2;
	guca[6] = guc = (unsigned char)!(!(int)guc);
	if ((gc2 = gps->c) > -40) gl2 = (long)gua[7];
}
int r4_07_05(unsigned long a, char b, long *c) {
	int t = 100;
	long u = gla[t] << (b & 15);
	t = !2 - ((int)gua[t] % 10);
	gpi = &gia[7];
	gp = gs.p;
	gl = u;
	a = ((unsigned long)!128) & (a * gula[5]);
	v0();
	return t + !8643;
}
int * r4_07_06(char a, unsigned char b) {
	char *t = rp();
	char u = gs.c;
	gc = u;
	gua[5] = (unsigned int)!t[6];
	a = gc2;
	return rpi(2 % 16);
}
unsigned int r4_07_07(void) {
	char t = gca[2] << 7;
	char u = gca[t];
	*gp *= 9;
	gul = (unsigned long)-255;
	if (gs.a[u] & 0x8) return 32767;
	gc = t;
	if (u == 7) if (gu2 != 0) gps->u = gps->u / gu2;
	gul = 0x10000UL;
	return ~gua[4];
}
long r4_07_08(double a, int b) {
	int i;
	long t = *gpl / 3L;
	char u = gp[2] / 2;
	gs.d = 100.0;
	gpi = gpi + b;
	switch (gl2) { case 0L: vc(u); case 1L: gps->u = gu; break; case 2L: gul = (unsigned long)u; break; case 3L: vp(gps->p); break; default: gula[2] = gula[3] << 27; break; }
	i = 3; do { gula[i] = gula[7] + gul; } while (--i > 0);
	gl = t;
	return ~(gla[6] + 87477L);
}
void r4_07_09(int *a, unsigned long b, int c) {
	int t = r1(*gpi);
	int u = t;
	gl2--;
	gi = u;
	v1(t);
	if (gu) gps->p = gp;
}
char * r4_07_10(long a) {
	unsigned long t = 7971UL;
	unsigned int u = gu << 3;
	++gpi;
	vl((long)t);
	if (gc > gca[u]) return rp();
	return gs.p + u;
}
int * r4_07_11(void) {
	int i;
	double t = gda[3] / 3.0;
	unsigned long u = gula[4];
	gda[2] *= t * gd2;
	guc++;
	vl((long)u);
	for (i = 3; i > 0; i--) { if (i != 0) gpi[2] = 255 % i; gpl[3] = gla[i] << (i & 15); guc = (guca[i] + 178) + (guc >> 1); }
	*gpl = gl;
	return rpi(gps->a[7] >> 1);
}
char * r4_07_12(unsigned long a, long b) {
	int i;
	int t = (b >= 65536L ? gps->i : gps->i);
	unsigned long u = 5UL;
	vd(gd2);
	vl((long)u);
	if (*gpl <= (long)gc) { gc %= 16; if (gua[t] != 0) gu = gua[t] / gua[t]; } else { guca[3] = guca[2]; }
	gu = 255;
	for (i = 0; i < 10; i++) { if (gc2 != 0) gps->c = gc2 / gc2; }
	return rp();
}
int * r4_07_13(void) {
	vs(gps);
	gula[1] -= gul & 0x10000UL;
	return gpi;
}
unsigned long r4_07_14(long a) {
	int *t = gpi;
	char u = gca[5] % 4;
	gpi = t;
	gc = (gp[3] & *gp) % 10;
	gc = u;
	v0();
	return gul;
}
unsigned long r4_07_15(unsigned long a, long b) {
	unsigned long t = gula[4] & gul;
	vl((long)t);
	if (!gla[4]) { --gpi; gps->u = gu << 15; } else { gua[1] = (gua[0] * 6) - gu; gca[3] += gca[1] << 5; }
	vl(*gpl);
	gps->i = gi / 4;
	return rul(gula[0] >> 4);
}
int r4_07_16(unsigned int a) {
	double t = gd / 0.25;
	gula[0] = rul(gula[a]);
	gps->i &= gps->a[a] / 10;
	--gpi;
	gd = t;
	gc *= 2;
	if (!gl) { a = gu2; if (gl2 != 0) gl = gla[a] / gl2; if (gia[2] != 0) gs.i = gia[5] % gia[2]; } else { vl(gps->l << 22); if (gps->c != 0) gp[3] = *gp / gps->c; }
	return gs.a[0] - gpi[1];
}
int r4_07_17(struct st *a, long *b) {
	int i;
	int *t = gpi;
	for (i = 8; i > 0; i--) { gca[i] = -92; gu = gua[1] = (unsigned int)gul; gps->p = gp; }
	t = t + 1;
	--gul;
	gul = gula[5] = gula[0];
	while (gi-- > 0) *b++ = 93213L;
	return -(gpi[1] % 10);
}
unsigned int r4_07_18(unsigned char a, unsigned long b) {
	gc--;
	b--;
	return gps->u;
}
char * r4_07_19(void) {
	unsigned int t = gu ^ 255;
	double u = 0.5 + 1.0;
	gc2 >>= (t & 7);
	++gi2;
	gula[6] -= gul;
	vu(gu - t);
	if (*gpl > gl && gp[3] == 0) { if (gula[t] != 0) gula[t] = gul % gula[t]; vu(ru(t)); gpl[2] = (long)gul; } else { gd = (u / 2.5) - -2.5; gd2 -= u; gi2 *= 11; }
	return gp;
}
