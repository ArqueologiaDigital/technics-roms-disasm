/* Random C89 program r4_s_09.c: gen_random.py --seed 4 --count 10 --funcs 20 --size small (file 9).
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

unsigned long r4_09_00(char *a, int b, long c) {
	while (b-- > 0) { if (*a == '9') break; a++; }
	if ((gc2 = *gp)) return (unsigned long)!gps->l;
	gpi--;
	if (gca[b] <= 5) { *a = gs.c = (char)!(gul / 16UL); gia[0] -= r0(); }
	gul++;
	return (gula[b] = gula[5]);
}
char * r4_09_01(struct st *a, unsigned int b, unsigned char c) {
	unsigned long t = (unsigned long)!100;
	if (gc2 != 0) gc2 = gc / gc2;
	gla[b] = gla[c] * 10L;
	gu2--;
	gul = t;
	return rp();
}
unsigned int r4_09_02(char a, char b) {
	int t = gia[b];
	if (gda[1] == gd) { gl2 = (gl - -10726L) + (gla[5] * (long)gula[t]); if (gua[7] != 0) gs.u = 32767 % gua[7]; gs.l |= 65536L; }
	++guc;
	gul -= gul >> (t & 15);
	guca[a] = guc = (255 ^ guca[b]) + (guc & 128);
	return ru(gps->u + 1);
}
int * r4_09_03(int a) {
	vl(gl % 10L);
	vs(gps);
	vd(1.0);
	return rpi(gia[a]);
}
void r4_09_04(char a, long b) {
	int i;
	long t = b;
	gua[3] = gua[0] + gua[4];
	gu2 = (1 | gu2) << 1;
	vl(t);
	i = 0; while (i < 16) { guc += guc >> 2; gul = gula[i]; vs(gps); i++; }
}
char r4_09_05(void) {
	long t = ~gl;
	long u = 65536L ^ gl2;
	vl(u);
	if ((long)gs.c == gl2) gu = gua[2];
	guc = (gi2 & 0x80 ? (128 << 4) : guc);
	vl(t);
	return (char)guc;
}
char * r4_09_06(void) {
	unsigned long t = (unsigned long)gps->l;
	gul = t;
	vp(rp());
	gi2 = -(int)gca[0];
	return gp;
}
int r4_09_07(unsigned long a, unsigned long b, struct st *c) {
	int *t = gpi;
	unsigned long u = ~gul;
	gul = u;
	gu2 *= 6;
	gpi = t;
	if (!gul) return gs.a[3] / 100;
	vl((long)c->a[4] & 4L);
	gc = (*gp >> 3) | (gc2 % 2);
	return gi;
}
long r4_09_08(long a, int *b, int c) {
	unsigned long t = gula[c];
	gc2 -= 78;
	gul = t;
	gp[0] = (char)(guc == (guca[c] | 128));
	gp[2] >>= (c & 7);
	v2(gi2, r1(256));
	switch (gc2) { case 2: vl(gl2); break; case 5: gpi = &gia[4]; break; case 8: guca[c] >>= 3; break; }
	return ~(t ? gl2 : (long)gca[2]);
}
int * r4_09_09(void) {
	gi2 = gi3;
	gs.u = ru(gu);
	return &gia[5];
}
int r4_09_10(int *a, unsigned char b, double c) {
	int i;
	int *t = &gia[3];
	char u = gs.c;
	if (!gc) { v0(); } else { if (gu != 0) gua[5] = gu / gu; gps->p = &gca[2]; if (gp[0] != 0) u = u / gp[0]; }
	if (b > 128 && u > '0') { if (gul != 0) gul = gul % gul; u = ('z' >> (b & 7)) + gps->c; }
	for (i = 0; i < 13; i++) { if (gl != 0) *gpl = gla[i] % gl; gs.p = gp + b; guca[i] &= (unsigned char)!gu; }
	--t;
	return (gps->a[u] - gi3) << 11;
}
unsigned int r4_09_11(void) {
	vs(gps);
	gda[3] = gda[2] + gd;
	gps->p = rp();
	while (gi-- > 0) *gp++ = 100;
	return (gu2 << 3) - ru(gu2);
}
unsigned int r4_09_12(void) {
	gul += 1UL;
	if (gps->c < gc) { vs(gps); gua[6] -= (unsigned int)gula[1]; } else { *gpi = (int)65536L; }
	gc = (*gp | 88) * rc(gi3);
	gla[6] = rl(gl);
	return (unsigned int)(*gp ^ gc2);
}
unsigned int r4_09_13(void) {
	char t = gc2 - 5;
	gda[1] -= -gda[0];
	while (gi-- > 0) *gp++ = 8;
	if (!gl) if (gu2 != 0) gu = gs.u % gu2;
	v0();
	vc(t);
	gd -= 0.25 * 1.0;
	return (gps->u = ((unsigned int)gi2));
}
char r4_09_14(int a, char b, unsigned char c) {
	unsigned long t = 0x10000UL - gul;
	if (t != 0) t = 1UL % t;
	vs(gps);
	gl2 = gl = (gpl[0] ^ 65536L) % 4L;
	gua[c] = ((unsigned int)gc2) - gu2;
	return gc2;
}
unsigned int r4_09_15(unsigned char a, unsigned int b) {
	if (gul || gula[a]) { if (gc != 0) gca[4] = *gp / gc; gul--; gua[a] -= ((unsigned int)gc) - 255; }
	gul -= rul(gul);
	return 32767 * 5;
}
unsigned long r4_09_16(unsigned int a, long b) {
	int i;
	i = 11; do { a = gu2; } while (--i > 0);
	if (gps->c == gc2) { if (gpl[1] != 0) gl2 = gla[a] % gpl[1]; vc(gca[a] % 2); }
	v0();
	gl = (long)guc;
	return 0x10000UL;
}
int r4_09_17(unsigned char a, int b, unsigned int c) {
	int i;
	double t = gd2 + gd2;
	unsigned int u = 1;
	switch (gps->i) { case 1: vu(u); break; case 2: guc ^= a; break; case 5: case 16: v0(); break; case 20: vp(gp); break; case 200: gpi = rpi(gps->a[b]); break; default: guc = ~guc; break; }
	gd = t;
	if (gi2) return gi2 >> 3;
	gc2 = -(*gp - gs.c);
	gul >>= (u & 15);
	i = 10; do { gla[i] *= 10L; v2((int)gc, gi); } while (--i > 0);
	return gia[1];
}
char r4_09_18(void) {
	double t = gd2 - gs.d;
	unsigned long u = (unsigned long)gia[5];
	vp(gp);
	gd = t;
	v1(gia[7]);
	vl((long)u);
	return gs.c + (gp[1] + gc2);
}
long r4_09_19(int a) {
	unsigned int t = ~gu2;
	vu(ru(1));
	if (t <= 256) gs.l = (gc2 ? gpl[2] : *gpl);
	return gl2;
}
