/* Random C89 program r3_s_01.c: gen_random.py --seed 3 --count 10 --funcs 20 --size small (file 1).
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

int * r3_01_00(char a) {
	unsigned char t = guca[3];
	if (r0()) return gpi + t;
	a = ~(a == gca[a] ? gca[t] : gc);
	gi = gs.a[t] = r2(gi2, gi2) ^ 1;
	switch (gl2) { case 0L: *gpl = gl & gla[t]; break; case 1L: gp[1] = gc2; case 2L: gi3 = gia[7] + gi; break; }
	return gpi + a;
}
unsigned int r3_01_01(unsigned char a) {
	int i;
	i = 0; while (i < 16) { if (gia[3] != 0) gi2 = 256 % gia[3]; gc2 = 26; a /= 16; i++; }
	guc = (guca[a] ^ 128) + (a - 255);
	gpi = &gia[5];
	if (!gs.i) { if (gul != 0) gula[2] = gula[0] / gul; if (gu2 != 0) gu2 = gu % gu2; if (gula[a] != 0) gula[1] = gula[a] / gula[a]; }
	return (255 - gps->u) ^ ~gps->u;
}
void r3_01_02(char a) {
	gi++;
	if (gps->a[5] <= gs.a[7]) { --gu; guc = (gca[a] > -62 || gca[a] != 'a' ? guca[a] : -guc); }
}
char r3_01_03(void) {
	int i;
	unsigned long t = gula[7];
	int *u = gpi + 1;
	gula[0] = t;
	while (gi-- > 0) *gpi++ = 255;
	guca[0] ^= guca[7] & guca[0];
	i = 4; do { guc += (unsigned char)!gs.l; gua[i] = (gua[i] * 4) + (gu2 * 7); } while (--i > 0);
	v1(*u);
	switch (gc2) { case 0: gc &= gp[3]; break; case 1: vu(gu); break; default: *gpl = 7L << 3; break; }
	return (char)!(long)gua[0];
}
void r3_01_04(void) {
	gl -= 5L << 26;
	guc = 255;
	*gpi %= 2;
	if (gl) { v0(); if (gca[1] != 0) gca[6] = 'a' % gca[1]; if (gc != 0) gp[3] = gca[5] % gc; } else { *gpi = gps->i = -(-gpi[1]); gula[7] = gul; }
	if ((gc2 = gc) > 'a') guca[6] = -guca[0];
}
char r3_01_05(void) {
	int i;
	unsigned long t = gula[7] - gul;
	gps->u = gua[1] = (32767 & gu) / 7;
	gul = t;
	i = 3; do { gula[i] *= 3UL; } while (--i > 0);
	gpl[3] ^= gpl[0] >> 3;
	return (gp[0] = 40);
}
unsigned long r3_01_06(char *a) {
	int t = gia[4];
	unsigned char u = (gia[4] ? guca[t] : guc);
	gda[1] *= -gd;
	vp(rp());
	v1(t);
	guc = u;
	return (gula[u] % 2UL) + gul;
}
int r3_01_07(unsigned int a) {
	int *t = gpi + a;
	gl2++;
	a = gu2;
	while (gi > 0) { gc2 += *gp++; gi--; }
	gpi = t;
	v2(gi2, (int)*gp % 2);
	gla[1] %= 7L;
	return (gi3 = 100);
}
unsigned int r3_01_08(double a, int *b, char c) {
	if ((double)gl2 == gd2 || !guca[6]) { ++gul; if (gpl[1] != 0) gl2 = gps->l % gpl[1]; gu2 %= 10; } else { gi3 = ~2 + !(-18802L); guc = guca[c]; }
	gs.l -= gpl[2];
	--gc;
	return gu2;
}
int r3_01_09(char a) {
	unsigned char t = guca[7];
	char *u = gps->p;
	++t;
	gp[0] = u[3];
	return gps->i << 3;
}
char r3_01_10(long a, long *b) {
	gul = (gul % 3UL) % 2UL;
	guc = ((unsigned char)!(-72039L)) - ((unsigned char)a);
	return (gc2 % 2) % 4;
}
int r3_01_11(unsigned long a, int b) {
	int *t = &gia[1];
	if (gl2 != 0) gla[b] = gl2 % gl2;
	gpi = t;
	gla[5] = (long)!(r2(gi2, gi) ? gla[b] : gl2);
	gul = (unsigned long)!(*gp * 'a');
	return (int)(gula[b] - a);
}
char * r3_01_12(int a, struct st *b) {
	int t = gi3 - *gpi;
	if (gl != 7L) return b->p;
	gu2 = ((unsigned int)!9UL) & b->u;
	v1(t);
	return gp + a;
}
long r3_01_13(int *a) {
	unsigned int t = (unsigned int)!7UL;
	gp--;
	gps->l -= 6L | gl;
	gu = t;
	while (gi-- > 0) *a++ = -646;
	return (gl2 = 65536L);
}
unsigned int r3_01_14(char a) {
	char t = (char)((char)guca[a] != '0');
	gia[t] = gps->a[7] + 256;
	if (gua[a] != 0) gua[t] = ((unsigned int)gul) / gua[a];
	gps->i = gi3 = -(189 + gia[a]);
	guca[6] = guc + guca[5];
	return ru((unsigned int)gc2);
}
int r3_01_15(int a) {
	int i;
	char *t = gps->p + a;
	int u = 127;
	gc = (gc2 ? (gc + gs.c) : rc(gps->a[3]));
	i = 0; while (i < a) { if (gi2 != 0) gi3 = u % gi2; vp(t); gl = gl2; i++; }
	if (255 < 0 && gc & 2) { if (gu != 0) gu = ((unsigned int)gl2) % gu; if (u != 0) gpi[3] = a % u; v2(gs.a[5] - gs.a[u], gi); }
	return (int)guca[5] * 2;
}
char * r3_01_16(int a, long *b) {
	char t = 'z';
	if (gla[a] != 0) gps->l = gla[2] % gla[a];
	guca[a] = guc = -guc;
	gc = t;
	return gps->p;
}
char r3_01_17(double a) {
	int i;
	unsigned long t = ~5UL;
	if (gi != 0) gi3 = gi2 / gi;
	gd2 = a + ((double)gu - 2.5);
	i = 0; while (i < 10) { gul = (gula[0] & ((unsigned long)gu)) - (t + 0UL); i++; }
	if (gu == gps->u) vp(gs.p);
	if (gps->l != 0) gpl[1] = 65536L % gps->l;
	return *gp;
}
int r3_01_18(unsigned char a) {
	int t = gs.i + 8;
	int *u = gpi;
	gpi = u;
	gs.d = gs.d * gs.d;
	gd2 -= gd2;
	*gp += '9' ^ gs.c;
	vd(2.5);
	gi = t;
	gd2 -= gda[3] + gd;
	return (r2(256, gi) ? t : 255) - (int)gs.l;
}
char r3_01_19(int a) {
	int i;
	char t = ~gs.c;
	for (i = 16; i > 0; i--) { if (gu2 != 0) gu = gu / gu2; gula[i] = gul = 40191UL; }
	vc(t);
	while (a-- > 0) *gpi++ = 305;
	return (char)(~gs.u != (gi3 ? gu : gua[a]));
}
