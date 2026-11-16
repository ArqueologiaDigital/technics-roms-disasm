/* Random C89 program r9_s_06.c: gen_random.py --seed 9 --count 10 --funcs 20 --size small (file 6).
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

void r9_06_00(unsigned long a, struct st *b) {
	int t = gi2 * 10;
	double u = gs.d / 10.0;
	b->p = &gca[0];
	if (gula[t] & 4) gp = gs.p;
	gd = u;
	b->i = gi3 = (t << 14) & ((int)guca[4] | *gpi);
	while (gi-- > 0) { if (*gp == 'a') break; gp++; }
}
unsigned long r9_06_01(void) {
	char *t = gp;
	t = gps->p + 1;
	gl |= ~gps->l;
	v0();
	return (52228UL ^ gula[5]) % 3UL;
}
unsigned long r9_06_02(void) {
	int *t = gpi;
	unsigned long u = gula[3];
	vl((long)u);
	v1(*t);
	gda[0] = (gs.a[2] > gpi[0] ? gd : gs.d);
	gps->l = gpl[0];
	return ((unsigned long)gc2) >> 17;
}
long r9_06_03(struct st *a, char b, unsigned char c) {
	int t = gs.i;
	vd((double)gi);
	guc &= ~guc;
	gca[c] = (char)gla[t];
	return (gla[3] % 7L) * 65536L;
}
int * r9_06_04(void) {
	long t = rl(gps->l);
	int *u = gpi + 1;
	gi2 &= gi3 - gi2;
	++t;
	gps->u = gu2;
	gps->c = gc2 % 3;
	return u + 1;
}
int r9_06_05(unsigned char a, int b, long *c) {
	int i;
	i = 0; while (i < b) { gl /= 10L; i++; }
	gs.c = '0';
	gs.c = gca[a] - gs.c;
	gc2 = ((char)(gd != (double)gs.u)) + (15 << 4);
	gu2 = gua[5] / 7;
	return r0();
}
unsigned int r9_06_06(void) {
	double t = gd2;
	gla[2] = ~gla[2];
	gp = rp();
	vd(t);
	gul = gula[1];
	gu = (gua[4] / 2) % 10;
	gl2 ^= gla[0];
	return (unsigned int)gula[7];
}
int r9_06_07(unsigned int a, int b, unsigned long c) {
	int t = 8;
	v2(gi2, ~gps->a[5]);
	v0();
	vl(-50635L + gl);
	v1(t);
	if (guc != 128) gi3 = b;
	return t + !gpi[2];
}
char * r9_06_08(long a, unsigned long b) {
	char *t = gp;
	guca[7] += guca[5];
	if (!guca[6]) { if (gu2 != 0) gps->u = gs.u % gu2; if (gua[3] != 0) gu2 = gs.u % gua[3]; } else { guc = (guc / 10) / 10; }
	gl2 = (long)-gul;
	vp(t);
	return gp + 1;
}
long r9_06_09(unsigned char a, unsigned long b, int c) {
	double t = (guca[4] ? gd : (double)gi2);
	gpi = &gia[1];
	gu = gs.u = (unsigned int)!gia[a];
	vl((guca[2] < 128 ? gl2 : gla[5]));
	guca[a] = guc = (255 >> (a & 7)) ^ (a - guc);
	t *= (guca[4] < 128 ? (double)gs.a[0] : t);
	return (gla[c] + gl) * 2L;
}
long r9_06_10(unsigned int a, long *b) {
	double t = -gda[3];
	gs.p = gps->p + a;
	a--;
	++gl2;
	gp = gp + a;
	gd = t;
	vs(gps);
	return gps->l + (long)gula[7];
}
int r9_06_11(void) {
	gc2--;
	if (r0()) { guca[0] /= 16; }
	return r1(gi >> 3);
}
char * r9_06_12(void) {
	long t = gs.l;
	vs(gps);
	guc = (8 - 128) * (guc + 255);
	v2(gia[3] % 4, gi);
	vl(t);
	guc ^= (unsigned char)gps->u;
	return gp;
}
int r9_06_13(void) {
	int t = gi2 ^ gia[4];
	gpl[0] = rl((long)guc - gl2);
	gs.l -= gl;
	*gpl -= gla[6];
	switch (gps->i) { case 0: gda[1] = gd + 0.25; break; case 1: gd2 += 2.5; break; case 2: vs(gps); break; case 3: gla[2] = gpl[2] = (long)!gla[t]; break; case 4: v2((int)gla[t], gi); break; default: gp = gs.p; break; }
	return !218 ^ (gc2 < -43 ? gi : gi3);
}
int r9_06_14(void) {
	char *t = rp();
	int u = gi2 - gi3;
	gla[u] = gl + (long)*gpi;
	vp(t);
	gd = (1.0 + gs.d) / 2.5;
	guca[u] = 128;
	while (gi > 0) { gc += *gp++; gi--; }
	return 1;
}
unsigned long r9_06_15(void) {
	gu = (unsigned int)(gul >= (9UL * 2UL));
	vd(gs.d + (double)gpi[3]);
	vc(6);
	return (unsigned long)(gc < (gc2 * *gp));
}
unsigned long r9_06_16(unsigned char a, long b) {
	char t = (char)!gu2;
	long u = gs.l;
	vl(u);
	a = guc = (128 * guca[3]) + (((unsigned char)gla[1]) << 2);
	if (*gp == '0') return ((unsigned long)guc) | gula[4];
	gc *= 7;
	a = 51;
	if (gc > 8) { b = (*gpl >> 4) ^ (4L + 65536L); }
	vc(t);
	return (unsigned long)gu2;
}
char r9_06_17(unsigned char a, unsigned int b, unsigned char c) {
	int i;
	for (i = 0; i < 3; i++) { vc(gp[0] * gps->c); }
	if (gua[a] & 0x10) if (gl2 != 0) *gpl = 3387L / gl2;
	return rc(gps->a[4]);
}
char r9_06_18(int a, char *b) {
	int i;
	char *t = gps->p;
	guc += guca[4] - guc;
	if (gda[3] > gda[1]) t = t + a;
	gd = -gs.d;
	i = a; do { gpi = &gia[i]; if (gs.l != 0) gl2 = gla[i] / gs.l; } while (--i > 0);
	for (i = 0; i < 16; i++) { gia[i] *= 9; if (gl != 0) gs.l = 7L / gl; }
	return -69;
}
int * r9_06_19(unsigned long a, unsigned long b, unsigned char c) {
	unsigned char t = ~guca[c];
	if (gp[3] & 0x10) { a = gul; gua[4] = gua[4] + gps->u; t = (guca[c] / 7) & (t % 10); }
	gc2 = (-41 | *gp) % 10;
	return gpi;
}
