/* Random C89 program r7_s_04.c: gen_random.py --seed 7 --count 10 --funcs 20 --size small (file 4).
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

int r7_04_00(void) {
	unsigned int t = gu >> 7;
	unsigned long u = gul;
	vu(t);
	vl((long)u);
	gc2 = gc = ('a' + -42) | ((char)(gl < 3L));
	guc = -(guca[1] & guc);
	gd2 += gs.d - gd;
	return (gi2 >= 2 ? gia[0] : -66) | (gc2 == 4 ? gs.i : gs.a[4]);
}
int r7_04_01(int a, char b, double c) {
	double t = (double)gl;
	++gu2;
	b = '0';
	++gl2;
	gda[2] = (gu2 & 0x8 ? t : t);
	gua[5] /= 2;
	return gia[a];
}
unsigned int r7_04_02(int a, int b, unsigned char c) {
	unsigned long t = gula[4] >> (b & 15);
	vl((long)t);
	if (gi2 & 2 || gi3 != b) gl2 = (long)!(gi + 256);
	vs(gps);
	gula[c] = 0x10000UL * 3UL;
	return (unsigned int)!(gs.u / 100);
}
unsigned long r7_04_03(int *a, struct st *b) {
	int t = gia[1];
	unsigned long u = -gula[6];
	vl((long)u);
	gi = t;
	guc = 246;
	gd -= gs.d;
	gl /= 2L;
	vs(b);
	return (unsigned long)(guca[t] & guc);
}
unsigned long r7_04_04(void) {
	unsigned int t = 1;
	char u = gps->c;
	gc = u;
	switch (t) { case 8: case 10: case 200: case 1000: guc |= 99; break; }
	gps->p = gs.p;
	gul = (unsigned long)!(guca[t] % 10);
	return (gul = 99116UL);
}
int r7_04_05(void) {
	long t = gla[0];
	gula[6] -= gul / 10UL;
	while (gi-- > 0) { if (*gp == '9') break; gp++; }
	vl(t);
	return (gs.i + 256) * r0();
}
int r7_04_06(char a) {
	int i;
	int t = 16;
	int u = ~gia[1];
	if (guca[u]) *gpl = (long)gi;
	gda[1] = gd - gs.d;
	for (i = 0; i < 8; i++) { vd(gd2); if (gca[i] != 0) gc = gca[t] % gca[i]; vp(gs.p + i); }
	return r2(gi2, r1(t));
}
long r7_04_07(char a, char b) {
	int t = !gi3;
	long u = gla[b] - gpl[3];
	if (gu2 != 0) gua[a] = gua[2] % gu2;
	while (gi > 0) { gc += *gp++; gi--; }
	if ((gc2 = b) == -46) v1(16 & t);
	if (gua[t] > gu) { gd2 = gd; *gpl = u = (long)gula[5]; }
	return u;
}
unsigned int r7_04_08(int *a, unsigned long b) {
	double t = -10.0;
	int u = (int)gps->u * gi2;
	gi = u;
	vd((!gc ? gd2 : gs.d));
	gca[3] = 'a' - gc;
	gca[6] = (char)(gi2 >= gps->a[6]);
	gd = t;
	gpi = &gia[0];
	guc--;
	return (gu2 % 3) >> 5;
}
void r7_04_09(void) {
	int i;
	int *t = gpi;
	double u = -gda[1];
	switch (gps->c) { case 0: guc = guca[6] + guca[1]; break; case 1: gul %= 3UL; break; case 2: gs.p = gp; break; case 3: vu(gu2); break; case 4: gd2 += gd2; break; case 5: gu2 %= 16; break; }
	gula[5] /= 10UL;
	for (i = 0; i < 11; i++) { gula[2] = ~9UL; }
	vd(u);
	v1(*t);
}
int r7_04_10(void) {
	char t = (char)!gca[3];
	gca[2] = gc = gca[t] / 100;
	if (gps->l != 0) gps->l = 65536L / gps->l;
	return -((int)gl2 >> (t & 15));
}
void r7_04_11(void) {
	gc2 = (char)!255;
	gl2 -= ~gl2;
	vs(gps);
}
char * r7_04_12(char a, unsigned char b) {
	double t = -(double)gi3;
	gd = t;
	vu(gu - 256);
	vl(*gpl ^ gps->l);
	a--;
	return gs.p;
}
int r7_04_13(unsigned long a, double b, int c) {
	int t = ~1;
	gpi[0] = gia[2];
	if (a) { guc -= ((char)gs.i == 86 ? guc : guca[t]); --a; v2(gi2, t); } else { gpi[3] /= 10; if (gla[6] != 0) gl2 = 65536L / gla[6]; }
	return r2(gia[1], gi) | !gs.i;
}
unsigned long r7_04_14(int a, int *b, long *c) {
	int i;
	double t = gs.d + gs.d;
	unsigned char u = guca[6];
	vd(t);
	for (i = 0; i < 2; i++) { if (gu2 != 0) gua[4] = gu2 % gu2; if (gul != 0) gul = gul % gul; }
	--u;
	return (unsigned long)gi;
}
int r7_04_15(unsigned int a, unsigned int b, int c) {
	unsigned char t = (unsigned char)(gla[a] == (long)gca[a]);
	unsigned char u = 128 << 3;
	t = u;
	if (r1(gi3)) return ~gs.i;
	return gs.a[6] + gi;
}
char r7_04_16(unsigned char a) {
	int i;
	int *t = rpi(gi3);
	int u = r1(gi);
	for (i = 13; i > 0; i--) { guc += (gpi[1] ? guc : 255); }
	gca[u] = (char)gu;
	switch (gl) { case 0L: gc2 += gc; break; case 1L: gda[2] += gs.d; break; case 2L: gps->u -= gua[u]; break; default: gl = (long)(u > gi3); break; }
	vs(gps);
	v1(*t);
	for (i = 0; i < 16; i++) { vc(-gc2); ++gu; }
	return (*gp + 0) & (gc ^ '0');
}
int r7_04_17(struct st *a, unsigned long b) {
	int i;
	i = 0; while (i < 15) { if (gs.l != 0) gla[7] = 39321L / gs.l; i++; }
	for (i = 0; i < 6; i++) { b++; gu = gua[i]; }
	guca[1] -= guca[2] + guc;
	gps->u = (unsigned int)(gda[3] >= gd2);
	return (int)guca[1];
}
unsigned long r7_04_18(unsigned int a, unsigned int b, unsigned char c) {
	b -= (unsigned int)(gs.d == 100.0);
	if (gc2 != 0) gps->c = gc / gc2;
	gs.l *= 7L;
	vd(gs.d * gs.d);
	gd2 *= gd * gs.d;
	return (gula[b] % 3UL) / 4UL;
}
unsigned int r7_04_19(void) {
	unsigned int t = gu + gu2;
	++t;
	switch (gc2) { case 0: vs(gps); break; case 1: gps->p = gp; break; case 2: guca[t] |= guc; break; case 3: vu(9); break; case 4: gd += gd; break; default: gp = gs.p + t; break; }
	gla[t] = gl = (gpl[1] * 4L) * 6L;
	gul = gula[t] = (gul / 2UL) - -4UL;
	return gua[1];
}
