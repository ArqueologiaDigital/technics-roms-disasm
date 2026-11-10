/* Random C89 program r4_s_02.c: gen_random.py --seed 4 --count 10 --funcs 20 --size small (file 2).
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

long r4_02_00(double a, char b, long c) {
	unsigned int t = gs.u;
	vu(t);
	gpi = &gia[3];
	vl(gl ^ gl2);
	c++;
	if (b == gc) if (gca[b] != 0) gca[b] = gs.c / gca[b];
	return rl(*gpl >> 24);
}
unsigned long r4_02_01(void) {
	int i;
	char *t = gp;
	unsigned long u = 0x10000UL;
	i = 0; while (i < 12) { if (gps->i != 0) gps->a[i] = 1 % gps->i; gua[i] ^= gu2 & 0; gca[i] /= 10; i++; }
	vc(rc(gi));
	--gi;
	vl((long)u);
	gp = t;
	return rul(u % 2UL);
}
void r4_02_02(unsigned char a, struct st *b) {
	guc--;
	switch (gl2) { case 0L: vp(gs.p); break; case 1L: gp[2] ^= *gp; break; }
	guca[6] = guc = a + 255;
	if (gula[a] != 0) gula[a] = 50271UL % gula[a];
	gs.d = gd;
}
char * r4_02_03(unsigned int a, unsigned char b) {
	double t = 3.0;
	guca[7] = 255 & 128;
	--gul;
	if (gul < 2UL || gul <= gula[7]) return gps->p;
	gd = t;
	return gp;
}
int r4_02_04(unsigned int a, struct st *b) {
	int t = gi2;
	long u = 65536L;
	gs.u &= ~((unsigned int)u);
	t %= 10;
	return (gd != (gs.d * gs.d));
}
char * r4_02_05(int *a, unsigned char b, unsigned char c) {
	char *t = gp;
	char u = t[0];
	gc = u;
	gla[2] = (long)rul(gul);
	gp = t;
	gd2 = (gs.d + gs.d) * (gua[b] & 0x8 ? gd2 : gda[0]);
	return &gca[c];
}
int * r4_02_06(struct st *a, int b, struct st *c) {
	vu(gu2 >> (b & 15));
	guc--;
	if (guc < 144) { a->p = gp; } else { gul = (gula[b] - ((unsigned long)gua[b])) / 100UL; if (gps->u != 0) gps->u = 8 % gps->u; if (gs.u != 0) gu2 = gua[3] / gs.u; }
	gpi++;
	return gpi;
}
int * r4_02_07(char a) {
	int i;
	*gp = *gp | gc2;
	for (i = 4; i > 0; i--) { vu(gua[i] / 10); gla[i] = -(long)gia[4]; if (*gp != 0) *gp = gs.c % *gp; }
	gs.u += gu2 - gua[7];
	if (gps->l != 0) gla[a] = gl2 / gps->l;
	return &gia[a];
}
long r4_02_08(char *a) {
	char *t = gs.p;
	guca[1] = guc % 100;
	if (gu2 > gua[5]) { gula[4] += rul(gul); v2(gi2, gi2); --gl2; }
	guca[4] = guca[5] + guc;
	if (r2(gi, gi)) { vp(t + 1); vu(gua[4] - 32767); }
	gula[6] = gul = ~gula[2];
	return (gpl[1] = gs.l);
}
unsigned long r4_02_09(int a) {
	long t = gla[3];
	unsigned char u = guc;
	gl = t;
	if (gu2) if (gs.u != 0) gu2 = gu2 / gs.u;
	gca[u] = rc(gi);
	if (r0() || gca[u] < gc2) gd2 = gs.d;
	gps->c = gs.c << 3;
	gi2 = a;
	return -(gula[3] + gula[u]);
}
int r4_02_10(char *a, double b, int c) {
	char t = rc(gi2);
	unsigned int u = gu | gu2;
	v2(gi2, 255);
	guca[t] /= 7;
	gc = (28 >> 7) | (guca[2] == guc ? (char)gua[1] : gc2);
	vu(u);
	gps->p = rp();
	return ~(*gpi | c);
}
long r4_02_11(long a, int b, int c) {
	char t = gc2 - 2;
	gla[b] = (long)gula[c];
	gc = t;
	if (gi3 & 2) return a;
	return (gla[2] = gla[7]);
}
unsigned int r4_02_12(char a, unsigned int b) {
	int i;
	unsigned long t = rul(gul);
	long u = *gpl;
	for (i = 4; i > 0; i--) { gpi = rpi(5); gca[5] = (b <= gu && guca[i] > 1 ? (u == -57392L ? gc2 : gca[i]) : gc2); if (gs.a[i] != 0) gs.i = gi3 % gs.a[i]; }
	vl((long)t);
	guc += guc | guca[4];
	return (unsigned int)((guc + 128) != -guca[3]);
}
unsigned long r4_02_13(int a, int b) {
	int i;
	long t = (long)(gps->c == 'z');
	char u = gc;
	gl = t;
	gpi = rpi(a >> 14);
	i = 0; while (i < a) { guc = ((unsigned char)u) ^ guca[i]; i++; }
	return 5UL;
}
int r4_02_14(void) {
	int i;
	for (i = 0; i < 8; i++) { if (gula[i] != 0) gula[6] = 0x10000UL % gula[i]; if (gia[i] != 0) gia[i] = 8 / gia[i]; if (gc2 != 0) gps->c = gca[6] / gc2; }
	v2(gi2, gi3);
	gd2 = gs.d * gda[1];
	return r2(gi2, gs.a[6]) + (int)gu2;
}
int * r4_02_15(long a, long b, double c) {
	char t = gc2 / 7;
	int u = gia[t];
	if (gula[7] != 0) gula[4] = 74983UL / gula[7];
	if (gula[4] || gia[3] & 0x7) { vs(gps); guca[t] = (guc * guc) * ((unsigned char)(int)guca[t]); }
	gi = u;
	gs.p = gp;
	++t;
	return gpi;
}
unsigned int r4_02_16(void) {
	unsigned long t = gula[7];
	vc(gs.c / 3);
	switch (gi2) { case 1: case 20: vp(&gca[0]); break; case 200: v2(gi2, gps->a[7]); break; default: vc(gca[2]); break; }
	gul = t;
	return (gs.u = gps->u);
}
int r4_02_17(int a) {
	int *t = gpi;
	gs.d *= gd2 - 1.0;
	--gul;
	gla[a] *= 10L;
	gu %= 3;
	gla[3] -= rl(gla[a]);
	gpi = t;
	return gia[a];
}
char * r4_02_18(char a) {
	char *t = gps->p;
	double u = (double)gs.c / 2.5;
	gu = ((unsigned int)gula[4]) << (a & 15);
	switch (gps->l) { case 0L: gula[1] >>= 23; break; case 1L: guc = (unsigned char)(8 > gps->a[a]); break; case 2L: gs.u = gu2 | 1; break; case 3L: guc &= guca[4]; break; }
	gu--;
	gula[a] = (unsigned long)((long)gul == gpl[3]);
	if (guca[a] > ((unsigned char)gua[a])) return t;
	return rp();
}
int r4_02_19(unsigned char a, long b) {
	int i;
	a = guc = -(55 + guc);
	for (i = 0; i < 6; i++) { if (gul != 0) gul = 0UL / gul; if (gc2 != 0) gs.c = gc2 / gc2; }
	guca[4] &= guc & a;
	return (gia[7] >> (a & 15)) + gs.a[4];
}
