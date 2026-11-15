/* Random C89 program r7_s_05.c: gen_random.py --seed 7 --count 10 --funcs 20 --size small (file 5).
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

long r7_05_00(double a, char b, int *c) {
	unsigned int t = gua[0] << (b & 15);
	long u = gla[t] + 65536L;
	if (guc > guca[5]) { *gp = gc2; if (*gpl != 0) gpl[0] = u % *gpl; }
	guca[6] >>= 1;
	gu = t;
	guca[0] %= 2;
	return (u = 4L);
}
int r7_05_01(int a) {
	gpi = rpi(r0());
	gps->p = gp + a;
	gps->u = -((unsigned int)gpl[2]);
	gula[6] |= gula[a] / 10UL;
	gl2--;
	return (gs.a[a] == (-164 % 4));
}
int * r7_05_02(int a, struct st *b, int c) {
	if ((gula[c] = gul) && gula[c] >= gula[4]) return rpi(gia[c]);
	guc--;
	return rpi(b->a[a] * 10);
}
void r7_05_03(unsigned long a, long b, long *c) {
	int t = 100;
	v0();
	switch (t) { case 2: vp(gp + t); break; case 5: gu2 *= 7; break; case 8: *gpi = (0x10000UL != 0x10000UL ? gi2 : 16); break; case 200: gca[7] += gp[1]; break; }
	t = r2(t >> 1, gi);
}
void r7_05_04(char a) {
	int t = gi;
	int u = 255 * 11;
	gd2 = -gd;
	gl2 = (*gpl - 5038L) + (*gpl ^ gla[t]);
	gi3 = (u + 127) << 1;
	gula[0] = (gula[t] % 10UL) << 17;
}
unsigned long r7_05_05(unsigned long a, int *b, unsigned long c) {
	guc = guca[3] % 100;
	switch (gps->l) { case 3L: vp(gp + 1); break; case 5L: guc -= 9; break; case 10L: guca[5] += 111; break; case 16L: vu(gu2); break; default: v2(gi2, *gpi); break; }
	return (c = 0x10000UL);
}
void r7_05_06(void) {
	gl2 = (gpl[1] % 7L) >> 18;
	gps->p = gps->p + 1;
	gca[0] = gp[3] % 7;
}
char * r7_05_07(unsigned int a) {
	while (gi-- > 0) { if (*gpi == -626) break; gpi++; }
	gpl[2] = gpl[2] >> 9;
	switch (gu) { case 3: vd((double)gu); break; case 10: case 16: case 200: gl |= 65536L; break; case 1000: gu &= gps->u; default: vl(gpl[3]); break; }
	gul = gula[0] = 36751UL;
	return &gca[4];
}
int r7_05_08(long *a) {
	char *t = rp();
	vs(gps);
	v1(gi);
	gp = t;
	gu2 = gua[4] = 256 % 100;
	v0();
	return (gpi[2] = gs.a[0]);
}
int * r7_05_09(long a, unsigned long b) {
	int i;
	char *t = gp + 1;
	gp = t;
	for (i = 0; i < 3; i++) { if (gul != 0) gul = ((unsigned long)guc) % gul; vc(4 - gc); }
	++gul;
	i = 0; while (i < 6) { gl /= 7L; i++; }
	return rpi(gps->a[1]);
}
char r7_05_10(int a, long b) {
	char t = -(-26);
	gula[a] -= -gul;
	gul--;
	gua[a] = gua[0] % 16;
	if (r2(gi2, gi2)) { if (gl != 0) gl2 = 7L % gl; gu2 = -gua[t] / 16; }
	return (*gpi == gps->i ? rc((int)t) : t);
}
char r7_05_11(struct st *a, unsigned int b, int c) {
	int i;
	for (i = 0; i < c; i++) { if (gps->u != 0) b = gps->u % gps->u; gu2 = gua[4] ^ (255 >> 8); if (gl != 0) gps->l = gs.l / gl; }
	gu2 = (((unsigned int)gula[7]) - gua[4]) | ru(gu);
	return 17;
}
int * r7_05_12(unsigned long a) {
	gps->u += 32767;
	if (gca[5] >= gca[0]) if (gi3 != 0) gia[4] = 256 % gi3;
	if (gu != 0) gu2 = 9 % gu;
	return &gia[0];
}
int r7_05_13(void) {
	int t = gpi[0];
	t = gia[t];
	gia[1] += gps->a[0];
	if (gl2) { if (gl != 0) gs.l = gl2 % gl; }
	guca[3] = (unsigned char)!((unsigned char)t);
	return t;
}
char * r7_05_14(char *a, int *b) {
	gl = (gla[7] & gl2) / 10L;
	--gp;
	*a = (char)(gl2 > -81893L);
	gu2--;
	b = gpi;
	return a;
}
long r7_05_15(char a, int b) {
	int i;
	unsigned char t = (unsigned char)(guca[a] == ((unsigned char)gps->l));
	for (i = 0; i < 14; i++) { gula[0] = (unsigned long)gl; ++gp; gi = (b >> 9) << (b & 15); }
	v1(t);
	switch (gi) { case 0: vu(gs.u); break; case 1: vd(1.0); break; case 2: gul -= 3UL; case 3: v0(); break; case 4: case 5: gc = a * 20; break; default: vl(gl); break; }
	while (b-- > 0) *gpi++ = 100;
	gula[3] = -6UL;
	return rl(65536L << 26);
}
char r7_05_16(int *a, long b, double c) {
	char t = (char)((char)gu2 <= gc2);
	double u = gda[1] * gs.d;
	gi = r0();
	vl((10.0 <= (double)t ? gla[1] : 65536L));
	gd = u;
	guc = -((unsigned char)(t != gp[1]));
	if (b == 65536L) { gl = (long)t << 6; }
	return gc2;
}
char r7_05_17(int a, long b) {
	char t = rc(a);
	gu = (unsigned int)gula[a];
	guc <<= 4;
	switch (gl2) { case 0L: gi *= 2; break; case 1L: gua[3] = gu2 << (a & 15); break; case 2L: gua[1] = gu2; case 3L: vc(t); break; case 4L: t /= 16; break; }
	if (gpl[2] & 2 || gi3 < *gpi) gpi = rpi(gpi[2] * gi3);
	return gp[0];
}
int r7_05_18(unsigned int a, long *b, unsigned int c) {
	int i;
	char t = gp[0] - *gp;
	for (i = 7; i > 0; i--) { gia[i] = gps->a[i] ^ gi; gca[i] = *gp = t; }
	gpi[1] = -gps->a[4];
	if (gs.a[5] != 0) gi2 = 2 % gs.a[5];
	return r1((gc == t));
}
int * r7_05_19(void) {
	gul = (gula[7] | ((unsigned long)gc2)) * -gula[7];
	if (r1(gia[0]) && gps->l < 65536L) { gul = gula[2] = 4UL; }
	if (0L != gl2) { vd(1.0 / 2.5); if (gul != 0) gul = gul % gul; } else { vu(gu2 ^ gua[1]); }
	return gpi;
}
