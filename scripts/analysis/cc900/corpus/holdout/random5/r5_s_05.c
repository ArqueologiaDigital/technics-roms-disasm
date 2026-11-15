/* Random C89 program r5_s_05.c: gen_random.py --seed 5 --count 10 --funcs 20 --size small (file 5).
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

int r5_05_00(struct st *a, long b) {
	int t = *gpi;
	char u = gc2 - (char)t;
	if (r0()) gu2 = (unsigned int)((255 / 100) >= (guca[t] & guca[3]));
	guc--;
	vc(u);
	return t;
}
int r5_05_01(unsigned int a, unsigned int b) {
	int i;
	unsigned long t = gul << (a & 15);
	for (i = 10; i > 0; i--) { guca[4] = guc = 20; gs.l = gpl[2] * 11L; guca[i] /= 16; }
	gi2 = (gi2 + gia[a]) % 3;
	gul = t;
	vp(gs.p + a);
	return gi % 100;
}
char * r5_05_02(unsigned int a, unsigned char b) {
	unsigned long t = gul;
	vp(gs.p + b);
	gul = t;
	vu(10090 % 7);
	gu2 >>= 6;
	gi2--;
	return gp;
}
unsigned int r5_05_03(double a, unsigned long b) {
	gpi--;
	gu2 %= 2;
	gca[4] = (char)!gul;
	gl2 *= 11L;
	v0();
	return (unsigned int)!(gua[5] | 15076);
}
char * r5_05_04(unsigned int a, struct st *b, int c) {
	int *t = gpi;
	gia[a] %= 7;
	v0();
	gl2 = gs.l;
	gp = &gca[1];
	gpi = t;
	if (!gc) { gs.d = 0.5; gc = 78; gua[a] ^= (unsigned int)!gla[1]; }
	return &gca[a];
}
char r5_05_05(void) {
	char t = gps->c - (char)guca[4];
	if (r2(*gpi, gi)) gpi = &gia[1];
	if (!gca[t] && gula[t] == 7503UL) guc = (unsigned char)!(gl2 - *gpl);
	gula[4] %= 3UL;
	return gc;
}
void r5_05_06(void) {
	long t = *gpl;
	char *u = rp();
	gul = (gula[4] + gul) & (gul & 0x10000UL);
	gp = u;
	vl(t);
	vc((gula[1] > gul ? gs.c : '9'));
}
void r5_05_07(int a) {
	double t = gs.d;
	gs.c = gp[1] / 100;
	gd = t;
	gpi = gpi + a;
	if ((long)gula[a] < 9L) { if (gc2 != 0) gc2 = gp[2] % gc2; } else { gula[6] = gul << 11; if (gu2 != 0) gs.u = 7 / gu2; }
}
long r5_05_08(unsigned long a) {
	int i;
	for (i = 0; i < 13; i++) { gps->c = *gp + gc2; gu2--; }
	if (gi2 == gps->a[7]) { gps->a[6] ^= (gl != gps->l ? gs.i : 100); }
	gps->c += ~gca[5];
	return (long)(gca[0] + gs.c);
}
unsigned long r5_05_09(void) {
	unsigned long t = gul + 11043UL;
	char *u = gp + 1;
	gc = (gc + -43) >> 6;
	if (gs.a[3] & 0x8) { t = gul = t << 26; gi2 += gi - gia[5]; *gpi += gps->i; } else { gl2 = (gs.c <= u[2] ? gl : (gl - -82807L)); }
	vu(~((unsigned int)gi2));
	u[3] = -*u;
	u = u + 1;
	return (t / 10UL) - (t / 4UL);
}
char r5_05_10(void) {
	double t = gd2;
	vd(t);
	if (guca[6] > guc && gps->l) if (gula[0] != 0) gula[3] = gul / gula[0];
	if (gu2 != 255) return gc % 7;
	return (gs.c % 2) & gca[5];
}
unsigned int r5_05_11(unsigned long a, unsigned int b) {
	char t = (char)a | gca[b];
	char *u = gps->p;
	vp(u);
	vc(rc(gi2));
	if (r2(gps->a[t], gi)) { guca[7] = guc + 255; }
	return (unsigned int)(int)a;
}
char * r5_05_12(long *a, unsigned int b, int c) {
	int i;
	gc2 = -gc2 + (char)gps->l;
	for (i = 8; i > 0; i--) { if (gpi[1] != 0) gps->a[i] = 255 / gpi[1]; b = (unsigned int)!b; guca[i] = guc = 128; }
	gca[b] = gp[1] = rc(gps->a[4]) / 2;
	vp(gs.p);
	return gs.p;
}
int * r5_05_13(unsigned int a, char b, unsigned char c) {
	char t = gca[4] ^ gc;
	int u = !gi;
	gl %= 10L;
	t = (b + gp[1]) & ('z' | gca[u]);
	gul++;
	vp(&gca[6]);
	return gpi;
}
int * r5_05_14(int *a, char b) {
	unsigned long t = gula[b] - gul;
	gla[b] = gla[5];
	vl((long)t);
	while (gi-- > 0) { if (*a == 100) break; a++; }
	return rpi((gs.d != gda[2]));
}
int * r5_05_15(void) {
	int t = gi2;
	gl = *gpl;
	gl -= gl + gs.l;
	if (gul < 63296UL) { t = !gps->i & gps->i; vp(gp); --gl2; } else { if (gs.l != 0) gpl[1] = 6L / gs.l; gp[1] *= 2; }
	gi2 <<= 1;
	gl2 = 2L;
	return &gia[6];
}
int r5_05_16(unsigned long a, int b, unsigned char c) {
	gs.i = 255 - gs.a[0];
	gs.d = gd;
	return gs.a[0];
}
int r5_05_17(void) {
	int i;
	int t = gia[7];
	int u = gia[t];
	v1(u);
	i = 11; do { gpi = &gia[i]; } while (--i > 0);
	guca[t] = (unsigned char)(gi > (int)gu2);
	return (255 ^ t) + ~gpi[1];
}
char * r5_05_18(char a) {
	long t = gpl[0] & gs.l;
	unsigned char u = 213 | 255;
	u = (guc ^ guca[1]) % 100;
	gl = t;
	gps->p = gs.p;
	return gps->p;
}
int r5_05_19(int a) {
	double t = 2.5 * (double)gla[1];
	unsigned char u = guca[a] / 100;
	gc2 = gp[2] = rc((int)gs.c + gi);
	vd(t);
	u += (gs.c & 2 ? u : u);
	gul = gula[3] = (gula[5] - gul) - ((unsigned long)!gul);
	if (gpi[0] != 0) gi3 = *gpi % gpi[0];
	return gi3;
}
