/* Random C89 program r3_s_07.c: gen_random.py --seed 3 --count 10 --funcs 20 --size small (file 7).
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

char r3_07_00(unsigned long a, long *b, int c) {
	v1(r1((int)gca[c]));
	guc -= guca[c];
	return gc2;
}
unsigned int r3_07_01(void) {
	int i;
	unsigned char t = guca[0] / 16;
	int u = r2(gi2, gi);
	guc = t;
	v1(u);
	--gp;
	gps->c = *gp;
	for (i = 12; i > 0; i--) { v0(); }
	return (unsigned int)gul;
}
int * r3_07_02(long a) {
	vc(14 << 3);
	if (gl2 > gpl[2]) { gl2++; } else { if ((gps->u = 32767)) gu = ru((unsigned int)(gu2 <= 9)); }
	if (gu2 != 0) gps->u = gu / gu2;
	return gpi;
}
long r3_07_03(long a, unsigned long b) {
	if (gl2 & 0x10) { guc = (unsigned char)(gu < ((unsigned int)gla[0])); vl(gl2 >> 4); } else { if (gula[3] != 0x10000UL) gps->a[0] = gi3 = (gi * 8) + ~(int)guca[6]; }
	gula[6] = (gul >= ((unsigned long)gl) ? gula[4] : b) << 3;
	return (gla[0] << 31) - (long)!b;
}
int r3_07_04(void) {
	int i;
	unsigned int t = (unsigned int)6L;
	--gul;
	--gpi;
	t += 255;
	for (i = 3; i > 0; i--) { if (gi3 != 0) gi3 = gi % gi3; --guc; t = (gps->l < 93781L && !t ? (t << (t & 15)) : (gua[2] / 3)); }
	return (gs.d > (gd2 + gs.d));
}
unsigned int r3_07_05(unsigned int a, int *b, long c) {
	int i;
	gs.d -= -gd2;
	gd2 -= -gda[2];
	for (i = 0; i < 10; i++) { gs.i = !(char)!gi2; }
	gula[a] -= -gul;
	gl = gl2 - rl(gl);
	return ru(-((unsigned int)gula[3]));
}
int r3_07_06(void) {
	int i;
	char t = gc2 % 2;
	int u = *gpi;
	guca[2] <<= (t & 7);
	gua[t] = gps->u = (gps->u ^ 32767) % 100;
	for (i = 0; i < 16; i++) { if (*gpi != 0) u = 256 / *gpi; v2(gi2, gi2 + u); }
	vd((double)gu2 - gs.d);
	return (int)(1 / 3);
}
long r3_07_07(char *a, struct st *b, unsigned int c) {
	char *t = &gca[c];
	gp = t;
	gd2 = gd;
	b->p = gps->p;
	v0();
	return (gua[c] ? gps->l : gla[c]) & gpl[2];
}
int r3_07_08(void) {
	int i;
	unsigned long t = (unsigned long)(long)guc;
	i = 12; do { gu = gua[i]; vl(*gpl); } while (--i > 0);
	for (i = 16; i > 0; i--) { vc(gp[0]); ++gu; }
	i = 0; while (i < 6) { gc = gc2 = (gca[i] % 3) * (gca[i] >> 7); gps->u = gps->u | ((unsigned int)gia[i]); i++; }
	gpi = &gia[5];
	vl((long)t);
	return gia[3];
}
int r3_07_09(void) {
	gua[0] = gs.u = (unsigned int)!guc;
	if (gula[6]) return 2 & gi;
	if (gca[4]) { gi2 = gi2 - (gps->c < 1 ? gi2 : gps->a[0]); } else { gp = gp + 1; if (gu != 0) gu2 = gua[2] % gu; }
	return gi;
}
long r3_07_10(char a, double b) {
	int i;
	char *t = gp + a;
	unsigned long u = rul(0x10000UL);
	*gpl = -gla[4];
	vp(gp);
	if (1 == gua[6]) { vl(gpl[2] * gl2); gi = *gpi = gps->i; --gl2; } else { guca[1] ^= 128; gps->p = rp(); if (gpl[0] != 0) *gpl = *gpl / gpl[0]; }
	vp(t);
	i = 8; do { gul = (gul * ((unsigned long)gps->u)) >> 16; gl = (long)gu2 / 10L; } while (--i > 0);
	return (gpl[0] ^ (long)gu2) & (long)u;
}
char r3_07_11(double a, long b, struct st *c) {
	gul = gula[1] << 3;
	gps->p = gp;
	return (gs.c = 4);
}
char r3_07_12(char a, unsigned char b) {
	vs(gps);
	gu = gps->u >> 5;
	if (gd > gd2) gula[6] = rul(gula[a] % 2UL);
	if (guc == 255) return rc(100);
	return (gca[0] * 61) % 2;
}
char * r3_07_13(struct st *a) {
	int i;
	gu2 = ru(gu);
	vl(gla[5]);
	switch (gl) { case 0L: v2(*gpi, gi); break; case 1L: v2(gi2, a->a[3]); break; case 2L: *gpl |= -51439L; break; default: vc(gc2); break; }
	for (i = 7; i > 0; i--) { if (gula[i] != 0) gula[i] = 6UL / gula[i]; guc = (7 + guc) ^ (guc & 162); gpl[0] = (long)!gul; }
	return gps->p;
}
unsigned int r3_07_14(void) {
	int t = 16 >> 9;
	t <<= 8;
	if (gl > *gpl) { gul -= gula[t] + gula[0]; }
	gp = gps->p;
	return 2079;
}
long r3_07_15(void) {
	--gc;
	gua[1] -= ~gs.u;
	return (gl2 = gs.l);
}
int * r3_07_16(void) {
	int *t = gpi;
	char u = gps->c << 1;
	v1(*t);
	*gp += gps->c | gc;
	gc = u;
	++gi2;
	return t + u;
}
int * r3_07_17(void) {
	int i;
	unsigned char t = 9 / 2;
	++t;
	gul = gula[t] | gul;
	for (i = 2; i > 0; i--) { gla[0] = gla[i]; gul -= (unsigned long)gps->u; gs.c = gca[i]; }
	gp[2] = '0' & gca[t];
	v0();
	return gpi;
}
char r3_07_18(int a, unsigned int b, unsigned int c) {
	gs.c = gca[b] = 'z' >> 2;
	gda[3] = (*gp & 4 ? gd2 : gd2);
	gula[2] = rul(gula[c] << 12);
	if (r2(gi2, gps->i)) if (gu != 0) c = gua[0] / gu;
	*gpi = gi2;
	return 'a' * (gc2 / 7);
}
char r3_07_19(unsigned long a) {
	unsigned int t = gua[6];
	if ((gp[1] = *gp) != 0) { a >>= 15; gc = (char)(gu2 % 4); gs.l = -39631L; } else { gs.c = 55; guc = (guc + 255) + (guc + guca[t]); }
	if (gu2 || gl) gps->u %= 16;
	return ((char)gi3 - gps->c) / 4;
}
