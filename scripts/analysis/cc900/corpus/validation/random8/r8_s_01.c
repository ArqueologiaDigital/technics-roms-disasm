/* Random C89 program r8_s_01.c: gen_random.py --seed 8 --count 10 --funcs 20 --size small (file 1).
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

int r8_01_00(int a, unsigned long b) {
	int i;
	int t = -676 + gs.i;
	int u = 16 * gs.a[t];
	for (i = 15; i > 0; i--) { *gpl = gl ^ gla[i]; b |= gula[i] - 0x10000UL; --gc2; }
	guca[t] = (unsigned char)!(guca[7] - 5);
	v1(u);
	gp = gps->p;
	return (int)gu2;
}
char * r8_01_01(char *a, int b) {
	int *t = gpi;
	if (!gua[0]) return gs.p + b;
	gs.c = 5;
	v1(*t);
	gula[b] = ((guca[b] = guca[6]) < 0 ? gula[b] : gul);
	gul *= 6UL;
	vd(-(double)*gp);
	return gs.p;
}
unsigned long r8_01_02(void) {
	unsigned long t = gul - 0x10000UL;
	unsigned char u = ~236;
	switch (gu2) { case 0: vd(gd); break; case 1: case 2: gc += *gp; case 3: gl = gl << 2; break; default: t = -t; break; }
	guc = u;
	gl++;
	return t;
}
unsigned long r8_01_03(unsigned long a, int b) {
	++guc;
	while (b > 0) { gi2 += *gpi++; b--; }
	gl2++;
	if (r0()) gca[b] = ~gp[0];
	return (a & 1 ? gula[6] : gula[0]) - a;
}
void r8_01_04(unsigned long a, unsigned int b, int *c) {
	int i;
	int t = gps->a[0] | gs.i;
	unsigned long u = gul;
	gul ^= gula[t] * 0x10000UL;
	gua[b] |= gua[t] + b;
	for (i = 15; i > 0; i--) { gl2 = (long)((guc | 34) == (((unsigned char)*gpi) + guc)); if (gps->l != 0) gla[i] = gla[i] % gps->l; if (gu2 != 0) b = gs.u % gu2; }
	gua[t] %= 2;
}
int * r8_01_05(unsigned long a) {
	int i;
	if (gs.u > gu2 && r1(277)) vs(gps);
	for (i = 14; i > 0; i--) { gs.u = gps->u + gs.u; }
	return gpi;
}
unsigned long r8_01_06(void) {
	int i;
	i = 0; while (i < 6) { vl((long)guc << (i & 15)); gua[i] = gs.u; i++; }
	gps->p = rp();
	gi3++;
	if (guc > 2) return gula[3] + gul;
	gu2 /= 7;
	return (gula[4] = gul);
}
int r8_01_07(unsigned long a) {
	int t = gi;
	long u = gla[1] % 4L;
	--gc;
	vu(gua[6] / 4);
	u = (gs.l & u) << (t & 15);
	return (t << 11) - gps->a[t];
}
unsigned long r8_01_08(void) {
	unsigned int t = gua[0] / 10;
	int *u = rpi(gia[5]);
	gla[t] = gla[0] - gl;
	v2(8 | 2, gi);
	v1(*u);
	gul = ((unsigned long)guca[t]) % 2UL;
	if (gul != 82468UL) { if (gp[0] != 0) gca[1] = gca[t] / gp[0]; if (gi3 != 0) gps->a[t] = 100 % gi3; gpl[3] = gl; } else { guca[5] = guca[0] % 7; guc = ((unsigned char)gs.l) ^ (2 | guca[6]); }
	return gula[t] - (gula[t] & ((unsigned long)gl2));
}
long r8_01_09(unsigned int a, char *b, char c) {
	unsigned long t = gula[6] / 16UL;
	int *u = gpi + a;
	if (gs.i == 256 || ((unsigned long)gu2) > 83581UL) { t = gul & (gula[4] >> 19); guca[5] %= 2; } else { if (guca[3] < guc) guca[6] = guc + guca[7]; }
	if (!gs.l) return gs.l;
	if (gpl[1] >= gps->l && (gl = -1278L) != 65536L) { gl = gps->l = rl(gl ^ gpl[1]); } else { if (gu != 0) gu = gs.u % gu; v1((guca[1] <= 130)); gpi[3] = r2(gi2, *gpi); }
	return gpl[3] + gl2;
}
char r8_01_10(unsigned char a, long b, long *c) {
	vp(&gca[a]);
	guca[a] = 55 << 3;
	return ((char)gul * '9') & rc((int)gps->u);
}
long r8_01_11(int a) {
	int i;
	unsigned char t = ~guc;
	guc = t;
	i = 2; do { vu(ru(gps->u)); } while (--i > 0);
	gc--;
	return rl(gl2);
}
char r8_01_12(void) {
	int i;
	i = 15; do { gul *= 11UL; if (gs.l != 0) *gpl = gps->l % gs.l; if (gps->l != 0) gs.l = gpl[0] / gps->l; } while (--i > 0);
	if (!*gp) { gp = &gca[7]; if (gla[1] != 0) *gpl = *gpl % gla[1]; guca[7] = (5 + 128) - guca[6]; } else { if (gu2) gps->p = gp + 1; }
	v2(gps->i - gi, gi);
	if (gca[3] & 0x7) return (' ') - 'A';
	return (char)!(~gpl[0]);
}
void r8_01_13(char a, unsigned char b) {
	int i;
	*gpl = rl(gs.l);
	for (i = 0; i < 7; i++) { gc2 = rc(16); vs(gps); if (gua[i] != 0) gua[0] = 2853 / gua[i]; }
	v0();
}
unsigned int r8_01_14(struct st *a, char *b) {
	int i;
	unsigned int t = (unsigned int)(guc > 128);
	long u = a->l + gl2;
	for (i = 0; i < 15; i++) { if (gu2 != 0) a->u = t % gu2; if (gula[i] != 0) gul = gula[i] % gula[i]; }
	gul--;
	gula[t] = gula[7];
	return (6 == 4 ? (t % 10) : ((unsigned int)!guc));
}
unsigned int r8_01_15(unsigned char a, double b) {
	unsigned long t = gula[a];
	gps->l = (gla[a] | gs.l) & gl;
	if (gla[0] > gl2) { if (gu != 0) gu = gu2 / gu; vd(b); t = 2UL << 12; }
	v2(gi2, (guc < guca[a]));
	return (gia[2] >= gi3 ? gu2 : gs.u) + 256;
}
unsigned long r8_01_16(struct st *a, char b) {
	gu = ru(gua[b] >> 9);
	gia[b] = (int)guc;
	if (!gula[b]) { if (gpl[0] != 0) gs.l = gla[b] % gpl[0]; vu(gu ^ 255); } else { gl2 %= 3L; gl2 = ~gl; gu2 &= 255; }
	return (unsigned long)(guca[0] ^ guca[b]);
}
int * r8_01_17(struct st *a, int b, int *c) {
	unsigned long t = gula[2] | gul;
	while (b-- > 0) { if (*c == 2) break; c++; }
	vd(gd2);
	gs.d -= gd;
	vl((long)t);
	gs.d *= gda[1] + gd2;
	return &gia[b];
}
int r8_01_18(unsigned char a, unsigned char b, struct st *c) {
	int i;
	char t = gca[7] + gca[a];
	unsigned char u = a / 2;
	for (i = 0; i < 5; i++) { vl(65536L); u = ((unsigned char)(255 <= c->u)) & b; }
	gc = t;
	gl = gla[0];
	if ((gi = gs.i)) return gi2;
	return (gla[6] < gps->l) & (gia[u] - (int)t);
}
void r8_01_19(int a, char *b, struct st *c) {
	long t = rl((long)gul);
	unsigned int u = (unsigned int)(b[0] < '9');
	vs(gps);
	gd -= -gda[0];
	gu = u;
	vl(t);
}
