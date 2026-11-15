/* Random C89 program r5_s_06.c: gen_random.py --seed 5 --count 10 --funcs 20 --size small (file 6).
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

int r5_06_00(void) {
	int t = gi3;
	unsigned int u = (gs.u <= 256 ? gu2 : gs.u);
	gs.d -= -gda[2];
	if (gua[t] >= gu) { if (gula[3] != 0) gula[2] = gul / gula[3]; gs.l = (65536L & *gpl) >> 19; gs.u >>= (t & 15); } else { if (gpl[0] != gl2) gu2 = ((unsigned int)!8) + (gps->u | u); }
	gps->i = *gpi;
	v2(gps->a[t] << (u & 15), gi);
	return (gps->a[t] = gi);
}
void r5_06_01(char a) {
	int i;
	unsigned char t = guc;
	char u = (char)gps->i * gp[3];
	gps->l = gl;
	v1(gia[3] - gpi[3]);
	v0();
	for (i = 0; i < 6; i++) { t = (gl > gps->l ? ((unsigned char)a) : (255 << (a & 7))); }
	t = 0 % 4;
	vc(u);
}
int r5_06_02(void) {
	unsigned int t = gu ^ gu2;
	gps->l = 5L >> (t & 15);
	gl2 -= gl >> 7;
	gl = rl(gps->l);
	return 255;
}
int r5_06_03(int a) {
	int t = gs.i >> (a & 15);
	if (1 == gu || r2(100, gi)) { guca[a] = 252 >> 5; vs(gps); gca[a] = gs.c; } else { a = (8 << 1) - -gi; }
	if (guca[2] & 0x10) if (gla[7] != 0) gpl[0] = gla[6] / gla[7];
	switch (gl2) { case 0L: vl(gs.l); break; case 1L: v2(gi2, gi); break; case 2L: gula[t] <<= (a & 15); break; case 3L: gs.c = gc = gps->c % 16; break; }
	return (gia[a] >> 14) * 8;
}
char r5_06_04(char a) {
	int i;
	char t = gc;
	int *u = gpi;
	for (i = 6; i > 0; i--) { gul -= gul - gula[i]; guc--; }
	if ((gu2 = ((unsigned int)t)) >= 10431) gps->i = (gpi[1] ? gi : gi);
	if (gul != 0) gula[a] = gula[a] / gul;
	v0();
	v1(!7UL);
	gpi = u;
	return 8;
}
char r5_06_05(char *a, int b, int *c) {
	unsigned int t = gs.u * 2;
	char u = gp[2] >> 4;
	gul = rul(gula[4]);
	if ((gul = 0x10000UL)) { gps->l = gs.l; guc -= ((unsigned char)gia[7]) & 128; } else { gs.u = (gu ^ 32767) & ~gu; }
	gu = t;
	++gp;
	return (char)(guca[b] / 2);
}
long r5_06_06(double a, unsigned int b, unsigned int c) {
	gs.c = gca[c] = (gc >> 2) % 100;
	gp[1] = gca[c] = ~gp[0] - gca[c];
	return ~(-65536L);
}
unsigned int r5_06_07(int a, int *b) {
	int i;
	int t = (gua[7] & 2 ? b[a] : *b);
	for (i = 0; i < 2; i++) { --gi; }
	--gl2;
	gul += 96876UL;
	guca[a] /= 16;
	gi = t;
	while (a-- > 0) *b++ = 16;
	return (unsigned int)((unsigned long)(gul >= 1UL));
}
char * r5_06_08(char *a, int b) {
	char *t = gps->p;
	int *u = gpi;
	gp = t;
	vl((long)!guca[2]);
	u++;
	return a + b;
}
long r5_06_09(int a, int b) {
	unsigned int t = gs.u - gu2;
	gu = t;
	if (*gpl) vd(1.0 * gs.d);
	gl2 = (gl2 * 3L) + gpl[2];
	gca[3] = 44 + gc2;
	gps->p = gp;
	if (gul > 25741UL || (gp[2] = gc) < 4) v2((guca[3] != guca[5]), gi);
	return gpl[0];
}
long r5_06_10(void) {
	gi += 8 - gi3;
	gpi = rpi(gia[0] - 127);
	vp(gp + 1);
	switch (gps->i) { case 16: vd(gd); break; case 100: gula[1] = -gula[6]; break; }
	gca[2] |= gc2 + *gp;
	return gl2;
}
int r5_06_11(void) {
	int i;
	unsigned char t = guca[0] | guc;
	guca[t] = (!gs.l ? guca[0] : ((unsigned char)gu)) >> 6;
	gu = gua[t];
	gul = -gul / 16UL;
	i = 0; while (i < 7) { gc ^= rc(256); gu2 = (256 >> (i & 15)) - -gu; ++gi; i++; }
	return ((5 != t ? *gp : gps->c) < rc(127));
}
int r5_06_12(int *a, int b) {
	int i;
	int t = !gul;
	gs.l += (long)(guca[b] < 128);
	gp--;
	i = 8; do { if (gpl[2] != 0) gl2 = gs.l / gpl[2]; } while (--i > 0);
	gul--;
	v1(t);
	return (int)gul % 10;
}
char * r5_06_13(void) {
	int i;
	int *t = gpi;
	gps->i = !gs.u;
	for (i = 12; i > 0; i--) { gul = gula[i]; }
	v1(*t);
	gula[5] &= gula[7] << 26;
	return gp;
}
void r5_06_14(void) {
	vs(gps);
	gu = -(gua[3] ^ ((unsigned int)gl2));
	guc = (guc + guca[2]) % 4;
	gc2 %= 2;
}
char r5_06_15(double a) {
	int i;
	char *t = rp();
	switch (gps->c) { case 0: gd *= a; break; case 1: gl2 += 90104L; break; case 2: t = &gca[3]; break; }
	if (gi3 != 0) gs.a[7] = gi3 % gi3;
	for (i = 0; i < 12; i++) { vs(gps); vl(65536L); if (gu != 0) gua[i] = gs.u / gu; }
	if (r2(gi2, 100)) return gc - *gp;
	guca[2] = (guc >> 3) - (guca[6] ^ guca[5]);
	return -(~*t);
}
unsigned int r5_06_16(void) {
	int t = gia[2] >> 5;
	v2(gi2, gi);
	if (*gpi) { gs.d -= gs.d; }
	gs.a[t] = ~(t & gs.a[3]);
	gu >>= 3;
	if (gc2 < 5) ++gl2;
	return gu2;
}
void r5_06_17(void) {
	int i;
	i = 2; do { if (gua[i] != 0) gs.u = 256 / gua[i]; } while (--i > 0);
	vu(gua[2]);
	gc = ((char)gula[5] + gc2) * (1 * -96);
}
unsigned int r5_06_18(long a, unsigned int b, struct st *c) {
	int i;
	int t = gpi[2];
	unsigned char u = guca[1];
	if (gu != 0) gua[1] = b % gu;
	gs.u = ru(gs.u);
	gi = t;
	for (i = 0; i < 12; i++) { if (a != 0) gl2 = (long)u % a; if (gps->u != 0) gu = gps->u / gps->u; }
	vd(-gs.d);
	return ru(gua[t] * 255);
}
long r5_06_19(unsigned int a) {
	int t = 255 >> 5;
	char *u = gp;
	gp = u;
	vp(gp + t);
	vu(gua[a]);
	return rl(9L - 0L);
}
