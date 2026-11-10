/* Random C89 program r1_s_04.c: gen_random.py --seed 1 --count 10 --funcs 20 --size small (file 4).
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

unsigned long r1_04_00(int a) {
	int i;
	gul %= 7UL;
	i = 0; while (i < 16) { gul--; gua[i] = 255; --gl; i++; }
	v2(!gs.l, gi);
	gul = gula[a];
	return gula[6] << 13;
}
unsigned long r1_04_01(char a) {
	gula[a] = ((unsigned long)gua[4]) ^ gul;
	--gc2;
	vu(~gua[a]);
	return gula[a] + rul(gul);
}
unsigned int r1_04_02(char a, long b) {
	int *t = gpi;
	v0();
	vp(gs.p + a);
	v1(*t);
	gul |= 0x10000UL | gula[4];
	return (unsigned int)gul;
}
unsigned long r1_04_03(struct st *a, int b, int c) {
	int t = c / 7;
	guc |= guca[t] ^ 229;
	guc = ((a->l = gps->l) ? 29 : guca[5]) ^ ((unsigned char)gua[6]);
	gula[c] = ((unsigned long)guc) % 3UL;
	gl--;
	return (gul + 0x10000UL) | rul(gula[t]);
}
char r1_04_04(char *a, char b) {
	unsigned int t = gua[0] << (b & 15);
	unsigned long u = gul;
	gi3 <<= (t & 15);
	vs(gps);
	switch (gc) { case 0: vp(gp + t); break; case 1: *gp = gc2 | gca[5]; break; case 2: case 3: t = gua[b] + 1; break; case 4: vp(gp); break; case 5: v2(gi2, (int)gula[2]); break; default: gi2 = gi = gs.a[5] - gpi[1]; break; }
	vl((long)u);
	return (char)!(t * gu);
}
unsigned int r1_04_05(int a, int *b, char c) {
	unsigned int t = gua[c] & 32767;
	v0();
	guc = (guca[a] | 128) % 2;
	gd2 = (3.0 / 0.25) / 0.25;
	vu(t);
	return (t = 255);
}
char r1_04_06(void) {
	int i;
	if ((gi2 = 256) > 255) { if (gul != 0) gul = gul % gul; vd(gd * gda[3]); } else { gul %= 10UL; }
	gul *= 4UL;
	i = 11; do { gl = gla[i]; } while (--i > 0);
	gpi = rpi(-2);
	return 7;
}
char * r1_04_07(int a, char b, int *c) {
	unsigned char t = (gul <= 0x10000UL ? guca[b] : 8);
	unsigned char u = guca[t] - t;
	vp(rp());
	if (gd <= gs.d) { gd2 += 0.25 - 10.0; } else { gpi[2] = *c = (a != gi3) >> (a & 15); }
	guc = t;
	gc /= 16;
	vc(-gc);
	gl2 = gps->l = (long)gia[u] | rl(gs.l);
	return gs.p;
}
unsigned int r1_04_08(char a, struct st *b, unsigned char c) {
	int i;
	unsigned char t = c;
	long u = rl(gla[a]);
	i = 0; while (i < 12) { if (gula[i] != 0) gul = gul / gula[i]; gi3 = r0(); if (gca[3] != 0) gp[1] = gps->c / gca[3]; i++; }
	gp = gps->p + c;
	switch (gps->u) { case 0: u = *gpl * 6L; break; case 1: *gp = (char)(t == c); break; case 2: case 3: case 4: gp = gps->p; break; default: vp(b->p); break; }
	vd(gd / 100.0);
	gd += gda[2] + gd2;
	return -(gua[a] - gu);
}
int * r1_04_09(void) {
	guc >>= 3;
	gl = (long)gul;
	gc = 'z';
	gi = (int)rc(2);
	v2(gi2, gi3 >> 2);
	return gpi;
}
long r1_04_10(char a) {
	unsigned char t = guca[7];
	unsigned int u = 255 | gua[a];
	if (r1(16)) { gps->u = (gu - ((unsigned int)gl2)) << 14; gps->c = ~gc; }
	++gp;
	++gpi;
	gs.d = gs.d - gd2;
	v1(gi - gs.a[u]);
	guc = t;
	return gpl[2];
}
char r1_04_11(int a) {
	int t = ~16;
	int u = a << 8;
	gula[t] *= 6UL;
	v1(u);
	gu2 <<= 14;
	return 'A';
}
int r1_04_12(long *a, long b, long *c) {
	unsigned long t = gula[5];
	gp = gs.p;
	guc++;
	guc -= 128;
	*gp = (char)(guc != 1);
	vl((long)t);
	return (gi | gi3) / 10;
}
int * r1_04_13(char a, int b, int c) {
	gd += gda[2] / 3.0;
	gl |= gps->l;
	gi3 %= 10;
	guca[b] = guc ^ guca[c];
	if (gula[c] != 0) gul = gul / gula[c];
	return rpi(gpi[1] / 3);
}
void r1_04_14(int a) {
	int t = *gpi % 3;
	v2(!gu2, gi);
	gpi = gpi + a;
	gps->l = gps->l + gla[1];
	if (gua[t] != 0) gu2 = 1 % gua[t];
}
int r1_04_15(struct st *a, long b, int c) {
	int *t = gpi + c;
	gula[c] <<= 23;
	gpi = t;
	if (gul != 0) gula[c] = gula[1] % gul;
	vp(gp + c);
	return ~(gi2 >> 9);
}
char r1_04_16(int a, double b, unsigned char c) {
	unsigned int t = ((unsigned int)gi) - gps->u;
	if (gua[c] >= gu) return gca[6] ^ *gp;
	gua[5] = gu2 = gu2 / 100;
	gc = rc(255 ^ gpi[2]);
	gu = t;
	return gs.c;
}
unsigned long r1_04_17(unsigned int a, char b, unsigned int c) {
	double t = gs.d / 100.0;
	gi2 |= 0 * 1;
	while (gi-- > 0) *gpi++ = 256;
	vd(t);
	gul = -gul;
	if (r0()) *gpl = gl2;
	if (gi != 0) gi2 = gs.i / gi;
	return ~gul;
}
char * r1_04_18(void) {
	int i;
	unsigned int t = ru(gu2);
	char *u = gp;
	gla[t] = (long)gi2;
	gl = -(long)gi3 - (long)!32767;
	u[0] /= 10;
	i = 11; do { v1(-100); if (gul != 0) gul = 88499UL / gul; guca[i] = (gu >= gua[7] ? guc : guc); } while (--i > 0);
	return gp;
}
char * r1_04_19(struct st *a, char b) {
	double t = gd;
	char *u = gp + b;
	gp++;
	vu(a->u);
	gula[b] = (unsigned long)gps->l;
	v0();
	gd = t;
	vs(a);
	return u;
}
