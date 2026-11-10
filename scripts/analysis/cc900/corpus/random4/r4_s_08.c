/* Random C89 program r4_s_08.c: gen_random.py --seed 4 --count 10 --funcs 20 --size small (file 8).
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

int r4_08_00(long a, int b, int c) {
	int t = ~gia[4];
	if (gul <= gula[t]) return 8;
	v0();
	switch (gc) { case 1: a <<= 9; break; case 3: gla[c] = gl << 1; break; case 16: v2(b, gi); break; default: vc((char)gu); break; }
	return (gpi[0] ^ t) & 331;
}
unsigned int r4_08_01(char *a, int b, unsigned char c) {
	int *t = gpi;
	a[2] = gc;
	gpi = t;
	if (r0()) return 11449;
	if (gu2 != 0) gu = gua[2] / gu2;
	return gu2;
}
unsigned int r4_08_02(long a, int *b, char c) {
	if ((int)guca[c] < gia[7]) return ((unsigned int)c) & gu2;
	gps->i <<= (c & 15);
	guc |= ~guca[c];
	vl(gps->l >> 5);
	return 255;
}
int r4_08_03(void) {
	char t = (char)!guc;
	int u = r2(gpi[3], gi);
	gp = gs.p;
	vc(t);
	if (gi2 == 2) gul = (unsigned long)(rul((unsigned long)guca[u]) > (gul - gula[u]));
	gu = (unsigned int)((unsigned char)gu);
	gs.l = gl;
	u -= u | gpi[0];
	return *gpi;
}
void r4_08_04(char a, unsigned int b) {
	double t = gd * gs.d;
	guc = guca[b] = 128 & guca[6];
	vd(t);
	guca[1] = guc - 128;
	gda[0] -= 10.0 * gs.d;
	gs.d = (a >= gc2 ? gd : gs.d);
}
int r4_08_05(int a, long b) {
	unsigned long t = (gda[2] >= gs.d ? gula[3] : gula[a]);
	gu &= gu2 + gs.u;
	v2(gi2, gi >> 11);
	if (gu2 != 0) gu = gu2 / gu2;
	gul = (((unsigned long)gua[0]) < gula[a] ? (gula[a] >> (a & 15)) : t);
	return gps->i << (a & 15);
}
int r4_08_06(int a, struct st *b, int c) {
	int t = b->a[5];
	gi2 = (int)gul;
	if (gl2 < gpl[0]) { b->l -= *gpl >> (c & 15); if (gula[a] != 0) gula[0] = gul % gula[a]; a = (t >> 4) - 1; } else { gs.u &= (gula[3] & 0x80 ? gps->u : gu); }
	gla[6] |= gpl[2];
	return (int)gla[c];
}
char r4_08_07(unsigned char a) {
	gc = ~(gc / 16);
	guca[a] = guc = 255;
	vd(gs.d * gda[3]);
	a = (unsigned char)((gps->l % 16L) != gl);
	return -47;
}
int r4_08_08(char a, char b, unsigned char c) {
	int t = gia[0];
	v2(gi2, (gula[t] == gula[4]));
	gi3 = gps->a[a];
	gl2--;
	gca[t] = ((char)(b < gps->c)) & gs.c;
	guc += ~c;
	return (gia[t] = gi);
}
int r4_08_09(void) {
	unsigned char t = ~guc;
	gc2 = (char)!gu2 & (gca[t] | gca[3]);
	if ((gl = gpl[0])) { if (gul != 0) gul = gul / gul; if (gca[4] != 0) *gp = gca[2] / gca[4]; gi3 -= gia[6] % 7; }
	gula[t] = gula[t] + 0x10000UL;
	if (gi < -152) if (gi3 != 0) gs.a[1] = gi % gi3;
	return gia[t];
}
char r4_08_10(char a) {
	char *t = gps->p + a;
	char *u = gs.p;
	gps->l = (long)u[a];
	gp = t;
	gul--;
	return (a + -91) % 4;
}
void r4_08_11(void) {
	char *t = rp();
	vp(t);
	gpl[3] = gla[2] = (gu & 1 ? (gla[0] ^ gla[3]) : (long)!gs.c);
	gpi = &gia[7];
	guc ^= 255 + ((unsigned char)gl);
	vl(gpl[1] + gps->l);
	if (9 != guca[2]) { if (gs.u != 0) gs.u = gu2 % gs.u; } else { guc = -(68 << 3); gca[4] = gs.c; }
}
unsigned long r4_08_12(void) {
	unsigned char t = guc * guca[0];
	gul = gula[t] = (gula[5] - gul) - (((unsigned long)gua[0]) * 3UL);
	++gul;
	return gul >> 20;
}
int r4_08_13(void) {
	guc = guca[4] ^ guc;
	gua[2] = (unsigned int)(((unsigned int)guc) > 32767);
	gl = (long)!(4L << 26);
	return !1;
}
int r4_08_14(void) {
	int i;
	unsigned int t = gu >> 6;
	char *u = &gca[2];
	gd = -(gd - gs.d);
	i = 0; while (i < 7) { gl *= 3L; i++; }
	vp(u);
	for (i = 0; i < 16; i++) { gpi++; gl = gla[i]; gl2 = (gc2 > 1 ? gpl[0] : gps->l) * 6L; }
	t += gu2;
	if (gl2 != 0) gla[7] = *gpl / gl2;
	return gs.a[t] - gi3;
}
char r4_08_15(unsigned long a) {
	unsigned int t = gps->u & gu;
	gc2 <<= 3;
	if (guca[t] || gpi[1] != gi) { a--; }
	return (char)!gs.u;
}
void r4_08_16(unsigned char a, struct st *b, struct st *c) {
	int *t = gpi;
	--t;
	gi2--;
	gs.u /= 16;
	if (gps->i != 0) gi2 = 16 / gps->i;
	a = ((unsigned char)!gula[1]) | (guca[4] + guc);
}
int * r4_08_17(unsigned char a, unsigned long b) {
	int t = gi;
	unsigned int u = gu;
	gia[2] = r0();
	gul -= (unsigned long)gu;
	gc2 = -93 / 4;
	gca[t] %= 16;
	vl(gl2);
	gu = u;
	return gpi;
}
int * r4_08_18(void) {
	gia[4] = 654;
	gul = (gula[7] + 5UL) | (gul * gula[2]);
	gc2 = (guc == 128 && (gua[1] = gua[2]) >= 800 ? gca[5] : (gs.c - *gp));
	return gpi;
}
unsigned int r4_08_19(void) {
	int t = gia[1] & *gpi;
	char u = gca[t];
	gp--;
	gi = t;
	guca[u] = ~guc;
	if (3.0 < gs.d) --gpi;
	vc(*gp | gca[3]);
	return (23 != -36 ? (((unsigned int)gul) / 10) : ((unsigned int)(gul >= gula[6])));
}
