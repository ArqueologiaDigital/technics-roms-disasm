/* Random C89 program r7_s_02.c: gen_random.py --seed 7 --count 10 --funcs 20 --size small (file 2).
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

int * r7_02_00(int a, unsigned int b, int *c) {
	int i;
	unsigned int t = b << 3;
	gul = (gul / 3UL) >> (b & 15);
	for (i = 9; i > 0; i--) { if (gula[i] != 0) gul = gula[i] / gula[i]; }
	gu = t;
	return rpi(gpi[2] % 4);
}
char r7_02_01(int a, long *b) {
	guc = guc ^ 1;
	gp[3] = (char)(65536L > gs.l);
	v1(1 % 2);
	guc -= guca[a] + 128;
	return rc(gps->a[2]);
}
unsigned int r7_02_02(long a, int *b, double c) {
	char *t = gp;
	long u = a;
	vl(u);
	gp = t;
	if (c == 0.25 || gps->a[6]) return (unsigned int)gula[5];
	vu(gu);
	gula[6] = gul = (unsigned long)!gca[7];
	return (gu2 + gu) - gs.u;
}
int r7_02_03(int a) {
	int i;
	char *t = &gca[a];
	while (a > 0) { gc2 += *gp++; a--; }
	for (i = a; i > 0; i--) { t[3] = 4 ^ t[i]; if (gs.u != 0) gu2 = gua[i] / gs.u; *gp = (16439 == gu2 ? gps->c : (' ')); }
	gul = gula[a] = 11736UL;
	return -gi / 16;
}
long r7_02_04(int a) {
	v1(gi3 + gi2);
	gs.i = (int)gla[a];
	gs.a[1] = gia[5] - gi3;
	guc = 190;
	if (gua[5]) { gul = (r2(a, gi) ? gul : 23906UL) >> 29; gps->a[a] *= 6; if (gca[a] != 0) gca[5] = 'a' / gca[a]; } else { gpi = gpi + a; if (*gp != 0) gc2 = gs.c % *gp; if (gla[6] != 0) gs.l = *gpl % gla[6]; }
	return rl(-(-73264L));
}
int * r7_02_05(void) {
	while (gi-- > 0) *gp++ = 94;
	gp[2] -= rc(gi);
	if (guca[6] == guca[7]) return rpi(gpi[3]);
	if (49880UL >= gula[0]) { gs.p = &gca[0]; gps->a[1] = (int)gl2 % 4; gs.u *= 8; }
	return gpi + 1;
}
char r7_02_06(char a, unsigned int b) {
	v1(gs.a[6]);
	switch (gps->i) { case 0: case 1: gp = gps->p; break; default: v2(gi2, gi); break; }
	if (*gp > a) if (gps->l != 0) gl2 = gl2 / gps->l;
	gs.p = rp();
	if (b >= gu2) { if (gl != 0) gl = gl2 / gl; gps->u /= 2; } else { gs.u *= 7; }
	return gps->c;
}
char * r7_02_07(unsigned long a, char *b) {
	int i;
	gua[6] %= 7;
	for (i = 0; i < 6; i++) { if (gu != 0) gu2 = gu % gu; gul = gula[i] = gula[i] % 16UL; if (gc != 0) gps->c = 8 / gc; }
	vp(b + 1);
	if (0x10000UL > gul) return gp + 1;
	guc &= (unsigned char)(gul > 6UL);
	return rp();
}
void r7_02_08(char a, struct st *b) {
	gua[6] = gua[a];
	b->l = gl2 >> 13;
}
int r7_02_09(int a) {
	int *t = gpi + a;
	char u = (char)gua[1];
	gps->l = 5L * 8L;
	v0();
	vc(u);
	gpi = t;
	return r2(gi2, ~gi2);
}
long r7_02_10(void) {
	gp[1] = rc(r2(gi2, gi));
	gpi = &gia[1];
	gul = ~(73062UL >> 14);
	if (gi & 1) return (long)gula[5];
	guc--;
	return *gpl;
}
int r7_02_11(double a, double b) {
	int t = ~gs.a[2];
	b = a;
	gula[t] = gul = (gula[1] << 29) << (t & 15);
	guca[t] ^= 8 | 128;
	return t << 11;
}
unsigned int r7_02_12(void) {
	char *t = gp + 1;
	v2((gc2 ? 256 : gps->a[3]), gi);
	gp[3] = gp[3] << 2;
	if (guc < 152) *t /= 2;
	gl += rl((long)gc2);
	return gua[4];
}
unsigned long r7_02_13(unsigned long a, unsigned long b) {
	int i;
	int t = gi;
	int u = ~gpi[0];
	v1(t);
	guca[0] = guc = (guca[4] >> 4) * (0 * guca[6]);
	gi = u;
	i = 0; while (i < 14) { if (gc2 != 0) gp[3] = gc2 % gc2; if (gia[i] != 0) gia[i] = gps->i % gia[i]; guc++; i++; }
	*gpl = gpl[1];
	gs.c = -gc2;
	return 0x10000UL;
}
int r7_02_14(int *a) {
	int i;
	unsigned long t = 4UL >> 3;
	char *u = gs.p;
	gi2 /= 3;
	gu--;
	for (i = 0; i < 15; i++) { *gp = gc2 = gc - gca[i]; gi2 = (gi3 % 2) >> 3; }
	if (gl != 0) gs.l = gl % gl;
	for (i = 0; i < 8; i++) { ++gl2; *u = (char)gps->i; }
	gul = t;
	return gi2 | 127;
}
unsigned int r7_02_15(char a, struct st *b, unsigned int c) {
	int i;
	gps->i = 1 >> (c & 15);
	gul >>= 6;
	i = 0; while (i < 15) { v2(1 << 6, gi); i++; }
	if (r2(gi2, b->i)) { --gl2; guc--; }
	b->u = -gu2;
	return b->u;
}
void r7_02_16(long a, int *b, long c) {
	unsigned char t = guc;
	v1(r2((int)*gpl, gi));
	if (gl2 != 65536L && !gul) { b = gpi; gps->u <<= (t & 15); }
}
char * r7_02_17(double a, long b) {
	b -= (long)(gu2 == gua[4]);
	b--;
	vu(gps->u ^ 26657);
	gul = (gul % 10UL) ^ ((unsigned long)gi3);
	gca[6] = (' ') | '0';
	return gps->p + 1;
}
void r7_02_18(struct st *a, char b, long *c) {
	long t = *gpl * 2L;
	char u = gca[1];
	vd(gda[3] / 100.0);
	gula[0] = gul << (b & 15);
	vl(t);
	gp = rp();
	vc(u);
}
int * r7_02_19(double a) {
	int i;
	double t = -a;
	--gp;
	v2(255, gi);
	vd(t);
	if (*gpl > gl) { gl--; if (gul != 0) gul = gul / gul; } else { vu(gua[7] | gps->u); gu = ru(gu ^ gu2); }
	i = 13; do { gula[i] = 0x10000UL; gla[6] = 53013L << 21; gu2 = gua[i] = gu2 * 2; } while (--i > 0);
	if (!gu) v2(gi2, gpi[0] | gi2);
	return rpi(gia[4]);
}
