/* Random C89 program r10_s_08.c: gen_random.py --seed 10 --count 10 --funcs 20 --size small (file 8).
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

char r10_08_00(unsigned int a, unsigned char b, long c) {
	int i;
	char *t = gp;
	gua[6] = a;
	for (i = 0; i < 8; i++) { gu = ru(255) | gu; gpi++; }
	vp(t);
	return gc2;
}
int r10_08_01(struct st *a) {
	gl += gla[4] / 16L;
	gc = rc(256 * 4);
	if (guca[4]) { vc(gca[2]); }
	vc(-24);
	gps->c = gc;
	return !guc & -gs.i;
}
char * r10_08_02(int a) {
	unsigned long t = ((unsigned long)*gp) >> 16;
	unsigned long u = (r1(100) ? 7UL : t);
	if (!gi) { if (gi2 != 0) a = a / gi2; gpi = rpi(gia[a] % 100); }
	vc(gca[a]);
	gc--;
	if ((guc = 255) < 3) { gps->u = gua[6] - gu2; if (gs.l != 0) gpl[1] = gla[a] % gs.l; if (gc2 != 0) gc = gca[a] % gc2; }
	gul = t;
	return gp;
}
void r10_08_03(char a, struct st *b, long *c) {
	int *t = &gia[a];
	unsigned int u = (unsigned int)!gul;
	gua[a] = b->u = gu;
	vu(~256);
	if (gps->c == ' ') { v0(); }
	u = u - (gu2 >> 2);
	a &= 99 ^ a;
	v1(*t);
}
unsigned long r10_08_04(void) {
	unsigned int t = gu - 1;
	unsigned int u = t ^ 256;
	gu = t;
	switch (gps->c) { case 0: v2(2, gi); break; case 1: case 2: case 3: guc += guca[4]; }
	gpl[1] = gl2 << 7;
	vu(u);
	gl2 /= 10L;
	if (gl2 != 0) gs.l = gl2 % gl2;
	return rul((unsigned long)gia[u]);
}
char r10_08_05(int *a) {
	double t = (!guca[6] ? gs.d : 3.0);
	long u = ~gl;
	vd(t);
	if (r2(*gpi, gi)) gpl[0] = (u - gl2) % 7L;
	gps->i = 996 ^ -156;
	--gc2;
	return gps->c;
}
int r10_08_06(int a, unsigned int b) {
	if (gia[b] & 0x10) return gi3 - gi2;
	gc2 += 8;
	gula[4] = (gula[a] - gula[1]) ^ (gula[b] / 16UL);
	b |= gu2 + gua[0];
	return 255;
}
char * r10_08_07(int a) {
	unsigned char t = (unsigned char)!gul;
	int u = (gu2 == gua[2]);
	while (a > 0) { gc2 += *gp++; a--; }
	if (gua[t]) { t /= 3; vu(gu2 & gua[t]); vp(&gca[t]); }
	v1(u);
	return gps->p;
}
int * r10_08_08(void) {
	char t = (char)(100.0 < gs.d);
	int u = 8;
	gd = 100.0 - gs.d;
	vc(t);
	vs(gps);
	gi = u;
	return gpi + t;
}
int * r10_08_09(unsigned char a) {
	if (guca[7] & 0x8) if (gla[7] != 0) gl2 = gl % gla[7];
	gla[5] = gpl[1] = (65536L / 2L) << 17;
	gia[a] >>= (a & 15);
	gs.l = gl2 = (gl2 & gla[1]) + (gpl[2] - 45439L);
	return rpi(100 << 14);
}
int r10_08_10(char *a, unsigned long b) {
	char t = gps->c;
	gu2 += ru(gu);
	vc(t);
	if (gps->l || r1(gi3)) return gpi[2];
	return gi2;
}
long r10_08_11(void) {
	unsigned int t = 255 - gu;
	gu = t;
	gl += 65536L;
	if (gc2) { v0(); if (gl != 0) gl2 = gl % gl; if (gula[5] != 0) gul = gul / gula[5]; }
	--gi;
	if (gc2) v0();
	return gl;
}
long r10_08_12(int a, long *b, long *c) {
	char *t = gp + a;
	int u = gi2 | gi3;
	gp = t;
	if (guc == 128) { if (gl2 != 0) *c = 65536L / gl2; guc = 128; gla[1] = gl = (r2(gi2, gs.i) ? (gla[4] & *gpl) : (gpl[0] - gps->l)); }
	vu((unsigned int)!gc2);
	vu((gps->a[0] ? 9958 : gps->u));
	return (long)((unsigned int)(*gp <= -23));
}
long r10_08_13(long *a, char b) {
	unsigned char t = (unsigned char)!49;
	unsigned char u = (gul == 2UL ? t : 128);
	if (gi2 != 0) gi = gs.a[7] / gi2;
	*a %= 2L;
	if (gc2 & 2 && ((unsigned long)t) == 80712UL) gula[1] &= gul;
	guc = (gula[t] & 4 ? u : u) * u;
	return (gl + 65536L) - (gl >> 16);
}
int r10_08_14(char a, int b, int c) {
	double t = gda[0] + gda[2];
	switch (gu2) { case 1: case 8: gp = &gca[a]; break; case 10: *gpi *= 4; break; case 20: v2(c, gi); break; case 100: gps->l &= 94169L; break; }
	gl = (long)!gul;
	gd = t;
	if (gi == 92) { vc(gc); if (gla[5] != 0) gl2 = 25424L % gla[5]; }
	gs.u ^= -255;
	--guc;
	return -(gi3 - gps->a[b]);
}
int r10_08_15(double a, unsigned long b) {
	int i;
	unsigned long t = (unsigned long)(gul == b);
	for (i = 0; i < 12; i++) { if (gla[i] != 0) gla[i] = gl / gla[i]; guca[i] = guc = -(guc | guca[i]); }
	t = (unsigned long)!rul(13526UL);
	vu(ru(gua[1]));
	guca[3] = guca[6] - guc;
	return (gps->a[2] = gps->i);
}
int r10_08_16(void) {
	int i;
	int t = gi2 >> 7;
	unsigned long u = (unsigned long)gua[t];
	gu2 /= 2;
	i = 7; do { t = gpi[2] = gi3 % 7; guc = (((unsigned int)t) == gua[i] ? guc : guc) / 2; if (gia[i] != 0) gps->a[i] = gps->a[i] % gia[i]; } while (--i > 0);
	gul = u;
	return (int)gca[7];
}
int r10_08_17(char a) {
	int t = -(int)gs.u;
	char *u = gs.p;
	vl((long)!*u);
	t = ~(~(int)gu);
	gi = gi3 = (*u ? (gi3 % 7) : !gia[7]);
	return t;
}
unsigned long r10_08_18(double a, char *b, char c) {
	unsigned int t = 1;
	char u = -gca[c];
	guc = ((unsigned char)'z') + guc;
	if ((gula[u] = gul) >= 0x10000UL) { v2((int)guca[4], gi); if (gia[6] != 0) gs.i = gi2 % gia[6]; vs(gps); }
	vc(gc + u);
	gu = t;
	return (((unsigned long)u) ^ 81444UL) ^ gul;
}
unsigned int r10_08_19(char a) {
	int t = (int)gl2;
	int *u = rpi(gia[7]);
	if (gl < 62318L) { gul++; gc2 %= 16; } else { if (gs.l != 0) gps->l = gl % gs.l; gd -= -gda[3]; }
	gd2 = gs.d;
	guca[6] &= (unsigned char)5;
	v1(t);
	if (r1(gi)) { vl(gl % 3L); }
	gpi = u;
	return (gu2 >> 1) >> (a & 15);
}
