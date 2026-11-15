/* Random C89 program r8_s_00.c: gen_random.py --seed 8 --count 10 --funcs 20 --size small (file 0).
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

unsigned int r8_00_00(unsigned int a, unsigned long b) {
	vu(gua[7] - a);
	vd(gda[2]);
	return 2432;
}
int r8_00_01(void) {
	int t = 16;
	long u = (gps->c ? *gpl : gps->l);
	gl = u;
	gia[t] |= gi3 >> 3;
	gu = ((unsigned int)(guc < 255)) | gu2;
	return ((int)guca[t] - gpi[0]) % 100;
}
int * r8_00_02(int a, int b) {
	int *t = gpi;
	unsigned int u = gua[4] << 8;
	gu = u;
	while (b > 0) { gi += *gpi++; b--; }
	vd(gda[2] + 3.0);
	gpi = t;
	return gpi + u;
}
unsigned long r8_00_03(void) {
	int i;
	for (i = 0; i < 4; i++) { gul = gula[i] = 9UL; guc++; gi = gi3; }
	gps->c ^= rc(gi2);
	gp++;
	gla[2] = gl = *gpl;
	return (gul * gula[7]) & (gula[4] >> 23);
}
unsigned long r8_00_04(unsigned int a) {
	int *t = rpi(gpi[2]);
	char *u = rp();
	--gi3;
	gpi = t;
	if (guc >= 128) if (gpl[0] != 0) *gpl = gpl[1] / gpl[0];
	vp(u);
	return (gs.a[a] >= gi3 ? (gul + gula[a]) : (gul - 0x10000UL));
}
int * r8_00_05(int a, unsigned long b, int *c) {
	int i;
	char *t = gps->p;
	vp(t);
	i = 0; while (i < 6) { gs.c -= rc(gi3); gua[i] += gs.u * gu2; gs.u *= 12; i++; }
	guca[0] = guc / 3;
	v1(gia[a]);
	return gpi;
}
unsigned long r8_00_06(int a) {
	int *t = rpi(1);
	unsigned long u = gul + gula[a];
	u = (u - gula[0]) >> 5;
	gpi = t;
	if (gs.l == gl || u == gula[a]) { if (gla[a] != 0) gpl[1] = gl / gla[a]; } else { u--; gp++; }
	return gul;
}
char r8_00_07(unsigned int a) {
	char *t = gp;
	switch (gc2) { case 0: gpi = gpi + a; case 1: v2(gi2, gpi[2]); break; default: gi2 = gi3; break; }
	vu(gps->u * 4);
	gul = -9601UL * gul;
	gpl[2] = (65536L / 100L) | (-46746L + gl2);
	vp(t);
	return -(~(char)gula[a]);
}
unsigned long r8_00_08(char a, char b, long *c) {
	unsigned char t = guc;
	if (gc2 != 0) gc = (char)gu % gc2;
	guc = t;
	vs(gps);
	return 0x10000UL;
}
int r8_00_09(int a, char b) {
	unsigned char t = 255 + guc;
	if (gu & 4) gia[3] -= gi3 - 8;
	t = ((unsigned char)(gp[1] > gps->c)) / 16;
	if (r0() && *gpl) return *gpi & gps->i;
	return -(*gpi >> 15);
}
void r8_00_10(char a, unsigned long b) {
	unsigned char t = (0 == '9' ? guc : guc);
	unsigned char u = guca[5];
	gula[u] /= 2UL;
	gua[a] = -gs.u;
	if (r1(gi2)) if (gps->l != 0) gpl[3] = 65536L / gps->l;
	v1(t);
	++gpi;
}
void r8_00_11(unsigned int a, int *b) {
	int *t = b + a;
	v1(*t);
	gps->u = (gua[7] >> 2) * 4;
	gl2++;
}
char r8_00_12(int a) {
	int i;
	guca[a] &= 6 / 100;
	for (i = 0; i < 6; i++) { if (gl2 != 0) gla[i] = gl / gl2; gs.d -= gd2 / 100.0; }
	gla[a] = gl2;
	vs(gps);
	gla[a] = gpl[2];
	return *gp;
}
void r8_00_13(unsigned long a, int b, int c) {
	if (gs.u != 0) gu2 = ((unsigned int)a) / gs.u;
	gi = (int)(gla[3] % 16L);
}
int r8_00_14(int a, int b) {
	long t = gl / 4L;
	int u = (int)guc;
	v1(u);
	gl = t;
	if (gps->l) gs.p = &gca[6];
	--gl;
	guc--;
	return ((gca[b] % 100) > ('9' - gs.c));
}
int r8_00_15(char a, unsigned char b, unsigned int c) {
	int i;
	char *t = &gca[5];
	guca[1] += guca[b] - guca[7];
	if (!t[1]) return gi2 % 2;
	for (i = 0; i < 16; i++) { if (gua[i] != 0) gps->u = gu2 / gua[i]; }
	return !gl ^ gi;
}
char r8_00_16(char a, int b) {
	int i;
	unsigned long t = 6UL << 6;
	double u = gs.d;
	gd = u;
	switch (gc2) { case 3: gi2 = gps->a[a] = b << 3; break; case 16: gla[2] += gla[b]; break; case 100: *gp = gs.c; break; }
	if (gi3 != 255) if (gul != 0) gula[0] = ((unsigned long)guc) / gul;
	for (i = 6; i > 0; i--) { vl(0L); if (gul != 0) t = t % gul; if (gu != 0) gua[i] = gu % gu; }
	return gps->c;
}
int r8_00_17(unsigned char a, int b, unsigned int c) {
	int *t = gpi;
	char *u = gp;
	gula[a] = (gula[b] + 7UL) | gul;
	--a;
	vp(u);
	gpi = t;
	return b & (gs.i & b);
}
int r8_00_18(unsigned int a, char b, char c) {
	unsigned char t = guca[7] * ((unsigned char)gu2);
	char u = 8 >> 5;
	gps->a[t] >>= 8;
	a += gs.u;
	vp(gp);
	gpi++;
	return (guc ? 256 : (gi2 << 6));
}
char r8_00_19(char a) {
	vl(gla[2]);
	if (r1(gi3)) { gula[a] ^= gula[7] & 0x10000UL; if (gula[a] != 0) gula[6] = gula[a] % gula[a]; }
	if (2 > gi) { gc2 = gs.c & gps->c; v0(); } else { gd2 *= (gu2 & 4 ? gda[1] : gd2); a = gc2 = gp[1]; if (gi != 0) gps->a[a] = gps->i / gi; }
	gi = ~(gl2 > *gpl ? (int)gs.u : (int)guc);
	return (char)(ru(gu2) <= -gu);
}
