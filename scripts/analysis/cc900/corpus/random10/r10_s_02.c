/* Random C89 program r10_s_02.c: gen_random.py --seed 10 --count 10 --funcs 20 --size small (file 2).
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

long r10_02_00(unsigned int a, unsigned int b, unsigned char c) {
	unsigned char t = -guca[7];
	char u = -10 * gca[c];
	vp(gp);
	v1(t);
	gpi = &gia[a];
	while (gi-- > 0) *gp++ = -96;
	switch (gs.c) { case 0: u |= 'a'; break; case 1: gs.d -= gd; break; case 2: v2(gi2, gi); break; }
	return (gs.l = (long)b);
}
char * r10_02_01(long a, unsigned int b, char *c) {
	int i;
	int t = (6UL > gula[1]);
	gi3--;
	i = 15; do { gc2 = gps->c; if (gps->c != 0) gc = gp[2] % gps->c; } while (--i > 0);
	if (t != 0) gi2 = 256 % t;
	return c;
}
void r10_02_02(char a, struct st *b, unsigned char c) {
	char *t = gp;
	if (gua[c] != 0) gua[a] = b->u / gua[c];
	gps->i = r2(gi2, gi2);
	vd(gda[0]);
	gi3 = gs.i = (gps->a[c] - 111) + !t[0];
	gla[7] = (long)!gl2;
}
unsigned int r10_02_03(unsigned long a) {
	if (gu2 != 0) gua[1] = ((unsigned int)gula[3]) % gu2;
	if (gp[1] != 0) gc = gca[7] / gp[1];
	gul = rul(gula[3] | gul);
	return gu2;
}
unsigned int r10_02_04(unsigned int a, unsigned char b, unsigned long c) {
	int *t = rpi(gi2);
	vp(gp + b);
	if (gs.d != gd) return gps->u / 2;
	gd = -gd2;
	b = (6 & guca[a]) ^ (guc | 169);
	gpi = t;
	return gua[7];
}
char * r10_02_05(double a, int *b) {
	switch (gc2) { case 0: guc -= guca[1]; case 1: v1(-39); break; default: gp[1] = gca[2] ^ gc; break; }
	gl %= 16L;
	if (!gula[2]) { if (gula[3] != 0) gula[4] = ((unsigned long)*gpi) % gula[3]; } else { vl(rl(gl)); }
	return rp();
}
long r10_02_06(unsigned int a) {
	int i;
	double t = gs.d;
	for (i = 0; i < 12; i++) { gca[i] = gc - gca[i]; if (gl != 0) gl = 29990L / gl; ++gp; }
	vd(t + gda[2]);
	gia[4] = -gps->i;
	return (gps->l = gla[a]);
}
int r10_02_07(long *a, int b) {
	if (gi != 0) gi = gi3 % gi;
	gul -= 50787UL / 2UL;
	guc %= 3;
	gpi = gpi + b;
	return gs.i;
}
int r10_02_08(char a, unsigned long b, int *c) {
	int i;
	unsigned char t = 128;
	char *u = rp();
	i = 0; while (i < 12) { u = &gca[0]; v2(gi2, (int)b); i++; }
	gda[3] *= (guc <= guca[t] ? gd : gs.d);
	++gi3;
	u = gs.p;
	return c[7];
}
char * r10_02_09(unsigned int a, unsigned long b) {
	gps->i = 1 % 100;
	if (guc & 0x7) return &gca[a];
	gl2 = rl(65536L + gs.l);
	gc = rc((gs.i & 1 ? gps->a[0] : gi));
	switch (gs.c) { case 0: gc <<= (a & 7); break; case 1: v2(gps->a[a], gi); break; case 2: *gpi = 2 << 3; break; case 3: vc(gc2); break; case 4: guc = ~guca[2]; break; default: gca[a] = *gp = gc * 26; break; }
	return &gca[a];
}
int r10_02_10(void) {
	int t = gi2;
	gul++;
	if (gl2 != 0) gl = (long)guc / gl2;
	gi -= gi3;
	gca[t] = 72 >> 1;
	gula[7] |= (gul < 0x10000UL ? 0x10000UL : 0x10000UL);
	return (409 * 8) - (gps->i + gi3);
}
char r10_02_11(char *a, long *b) {
	char t = *gp + 96;
	char *u = gp + t;
	if (r2(16, gi)) if (*gpl != 0) b[6] = gla[7] % *gpl;
	if (gs.l != gl2) gia[2] <<= 11;
	gp = gp + t;
	vp(u);
	return t - 'A';
}
char r10_02_12(int a, int b, double c) {
	unsigned long t = ~((unsigned long)guca[a]);
	int u = gi2 << 10;
	v2(gi2, !gps->c);
	gi = u;
	vl((long)t);
	gps->c *= 9;
	return (gc2 ^ ' ') - (42 + 1);
}
int r10_02_13(int a, long b, unsigned int c) {
	int i;
	int *t = gpi + a;
	char *u = gs.p + a;
	gpi = t;
	for (i = a; i > 0; i--) { gul %= 10UL; gda[0] = (gul == ((unsigned long)*gp) ? (gs.d + gda[1]) : gs.d); gul /= 10UL; }
	gc -= *u >> (a & 7);
	return ~(int)gl2 - (gia[c] | 815);
}
char r10_02_14(unsigned int a) {
	int i;
	char t = *gp >> 2;
	i = 16; do { gi = r2(r2((int)guc, gi), gi); } while (--i > 0);
	gu = a % 4;
	gs.d = gd * gd;
	guc = guca[t];
	if (gula[5] != 0) gul = gul % gula[5];
	return ~82;
}
int r10_02_15(double a, int b, unsigned int c) {
	gula[4] = gul = ((unsigned long)!gi2) % 16UL;
	++gp;
	if (gps->c < gs.c && guca[c]) { gc = -(9 % 10); } else { if (gul != 0) gula[4] = gul / gul; if (gul != 0) gula[c] = gula[c] % gul; gl2 >>= 10; }
	return (gc2 < 'a' ? b : (*gpi << 13));
}
int r10_02_16(unsigned int a) {
	int i;
	unsigned long t = 0x10000UL / 7UL;
	unsigned char u = (unsigned char)gc;
	if ((gua[u] = a) != 16155) { if (gpi[2] != 0) gi3 = 6 % gpi[2]; gi3 = gps->a[0] >> (a & 15); }
	i = 15; do { if (a != 0) a = 3 / a; --gp; gi++; } while (--i > 0);
	++gp;
	gu2 = (t != 0x10000UL ? gu2 : ((unsigned int)gca[u])) - a;
	gs.a[a] = gpi[0] - gs.i;
	return r2(2, gi);
}
int * r10_02_17(void) {
	int *t = gpi;
	gs.d = (!gu ? gd : gd2);
	t = &gia[2];
	return t;
}
unsigned long r10_02_18(unsigned long a, char b, unsigned long c) {
	char *t = gps->p;
	int u = (gps->l & 2 ? gps->i : (int)gpl[1]);
	u = (gi ^ gs.i) >> 5;
	guc = guca[2] = -(guc >> (b & 7));
	gp = t;
	gu = gu2 - (((unsigned int)guca[6]) ^ gu2);
	return (c = gul);
}
char r10_02_19(void) {
	--gul;
	gpi = gpi + 1;
	gps->u = gua[7];
	return (gc = gc2);
}
