/* Random C89 program r5_s_03.c: gen_random.py --seed 5 --count 10 --funcs 20 --size small (file 3).
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

void r5_03_00(unsigned long a, int b) {
	int i;
	unsigned int t = ~gu;
	char *u = &gca[t];
	guc = guc & 128;
	guc %= 10;
	i = 16; do { if (t != 0) gps->u = ((unsigned int)gula[i]) / t; } while (--i > 0);
	for (i = 0; i < 8; i++) { gps->i <<= 4; }
	guca[t] = ((unsigned char)t) ^ guca[6];
}
int * r5_03_01(void) {
	int i;
	char *t = gp;
	unsigned long u = (unsigned long)gc;
	if (gu != 32767) return gpi;
	for (i = 0; i < 16; i++) { guc += (unsigned char)(255 >= guc); gd += (u == 0x10000UL ? gda[2] : gd2); }
	gp = t;
	return gpi + 1;
}
unsigned long r5_03_02(unsigned int a, int b) {
	long t = -77500L;
	unsigned long u = gul >> (b & 15);
	guc--;
	guca[b] += guca[4] >> 3;
	gc2--;
	if (gs.u & 1) { if (gl != 0) t = -10598L / gl; gl2 = t; v2(gi2, *gpi + 63); }
	gl ^= gla[b] * 8L;
	return (u >> 30) % 4UL;
}
unsigned long r5_03_03(unsigned long a) {
	int i;
	char t = gca[5] * gc2;
	a++;
	gc = t;
	while (gi-- > 0) *gpi++ = 16;
	i = 0; while (i < 4) { if (gc != 0) gca[i] = gps->c / gc; i++; }
	return (r1(gia[3]) ? (a + gul) : a);
}
int r5_03_04(int a) {
	int i;
	unsigned long t = gul;
	if (r2(gi2, gi)) { gs.c = gca[0] = gps->c; } else { if (gua[5] != 0) gua[a] = gu2 % gua[5]; }
	gul = t;
	gpi = &gia[7];
	for (i = a; i > 0; i--) { gu = gu2; --gu; }
	gu2--;
	gu2++;
	return (gi3 = 2);
}
unsigned int r5_03_05(unsigned long a) {
	int i;
	long t = gps->l * 2L;
	char u = gc2 & *gp;
	i = 0; while (i < 14) { if (t != 0) gl = t / t; u <<= (i & 7); if (gul != 0) a = ((unsigned long)gca[i]) % gul; i++; }
	vc(rc(*gpi));
	*gpi *= 6;
	guca[2] = (guc ^ 0) + (guc >> (u & 7));
	vs(gps);
	return ~gu2 - (gu2 - gua[0]);
}
int r5_03_06(long a, long *b) {
	gps->a[2] = -gia[4];
	vs(gps);
	if ((gu = ((unsigned int)gula[1])) != 256) { if (gla[0] != 0) gla[7] = b[0] % gla[0]; --gi; if (gps->c != 0) gca[0] = gps->c / gps->c; } else { vp(gp); }
	gda[3] += gda[2];
	return (gs.a[2] <= 100 || 6 > 'A' ? (gi2 | gia[6]) : ~gpi[0]);
}
char * r5_03_07(unsigned long a, unsigned char b) {
	gp = rp();
	gul = -a + gul;
	return rp();
}
unsigned int r5_03_08(int a, long *b) {
	int i;
	int t = gi2 ^ gi3;
	if (gl) { if (*gp != 0) gca[6] = gc / *gp; } else { gu = gs.u = (((unsigned int)t) & gua[a]) << (t & 15); }
	for (i = 0; i < a; i++) { guc -= (unsigned char)(gu > 256); if (gula[i] != 0) gula[i] = gul / gula[i]; }
	guca[5] = guc = (guca[a] >> 6) - guc;
	gula[a] = gul - gula[t];
	return -gua[3];
}
int r5_03_09(unsigned int a, int b, double c) {
	vp(rp());
	if (guc < guca[a]) { gula[1] = gula[7] >> 4; } else { vl(-(long)gs.u); }
	return (gia[a] = gps->a[7]);
}
long r5_03_10(unsigned char a, long b, long c) {
	int i;
	char t = gps->c;
	int u = gi;
	if ((gul = gula[3]) <= 0x10000UL) { gi2 *= 6; gpi--; ++gp; } else { if (gps->a[3] != 0) gia[6] = gia[3] % gps->a[3]; if (gi3 != 0) gps->i = 256 / gi3; if (gca[t] != 0) t = -80 / gca[t]; }
	gula[5] = gula[t];
	for (i = 9; i > 0; i--) { gula[i] >>= 18; gpi[0] = gia[u] = (2 % 10) & (gi2 + 266); gul |= gul + 2UL; }
	return ~gl2 - (gl << 21);
}
char r5_03_11(unsigned long a, long b, unsigned long c) {
	int i;
	int t = gi;
	guc--;
	i = 16; do { if (gps->c != 0) gc2 = gc2 % gps->c; } while (--i > 0);
	gi = t;
	for (i = 11; i > 0; i--) { a = rul((unsigned long)(9 > guc)); }
	return rc(gia[0]);
}
char * r5_03_12(long *a, char *b) {
	gs.c *= 9;
	if (gula[0] != 0) gula[4] = gul / gula[0];
	vu(ru(gua[4]));
	if (gs.l) guca[5] = guca[2];
	*gpl = gl;
	return gps->p + 1;
}
char * r5_03_13(unsigned char a, struct st *b, int c) {
	unsigned int t = ru(1);
	if (t) vu(t);
	vc(*gp);
	vc(rc((int)t));
	t--;
	vl(gl);
	return &gca[0];
}
char r5_03_14(unsigned long a, int b, unsigned char c) {
	unsigned int t = gua[2] % 3;
	long u = (t ? gla[b] : 65536L);
	if (gua[c] != 0) t = t % gua[c];
	gla[c] = u * 5L;
	return gp[1];
}
char r5_03_15(char a) {
	long t = 3L;
	unsigned char u = guc ^ 1;
	vl(t);
	if (gul >= 9UL) { if (gps->u != 0) gu2 = gu % gps->u; --gl2; }
	gla[u] = gla[6];
	gula[a] = gul | 2UL;
	return a;
}
void r5_03_16(int *a) {
	long t = gla[3] - gl;
	vp(gs.p);
	vl(t);
	if (gi3) if (gul != 0) gul = gul % gul;
}
int r5_03_17(long *a, int b) {
	int i;
	int *t = gpi;
	if (r0()) return gi;
	i = 0; while (i < 16) { vd(gda[0] / 3.0); gul = rul(gula[i]); gp = gps->p; i++; }
	i = 0; while (i < 5) { --gp; if (gu2 != 0) gu = 256 % gu2; i++; }
	vs(gps);
	v1(*t);
	return (~gs.l <= (long)gia[b]);
}
int r5_03_18(unsigned long a, int b, double c) {
	int i;
	int t = (int)128;
	for (i = 0; i < 2; i++) { if (*gp != 0) gps->c = 4 % *gp; gp++; if (a != 0) a = a % a; }
	v1(t);
	guc <<= 3;
	return (gi + gia[6]) * (int)guca[b];
}
long r5_03_19(int a, char b, struct st *c) {
	double t = (double)c->l - gs.d;
	unsigned char u = -guc;
	c->p = rp();
	gd = t;
	vl(rl(gla[2]));
	u = (guc + u) / 3;
	return (gs.l = *gpl);
}
