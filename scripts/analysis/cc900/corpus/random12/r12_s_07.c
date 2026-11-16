/* Random C89 program r12_s_07.c: gen_random.py --seed 12 --count 10 --funcs 20 --size small (file 7).
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

long r12_07_00(unsigned int a, long *b, char *c) {
	int t = gpi[0];
	v2((r2(gs.i, gi) ? t : gps->i), gi);
	gs.i = r1(gpi[3] | t);
	return (gs.l ^ b[t]) << 9;
}
char r12_07_01(unsigned char a) {
	int t = gpi[3];
	if (gda[3] < 10.0) { gi3 %= 7; gpi = rpi((gl2 != -22739L ? *gpi : gia[a])); gd2 -= gs.d / 10.0; } else { if (gula[a] != 0) gul = gula[a] / gula[a]; gla[t] = -0L; }
	if (gu2) { vc(gc + '0'); }
	return (gc2 - (char)gla[5]) / 3;
}
int r12_07_02(int a) {
	int i;
	long t = gps->l - gs.l;
	gula[0] = 7UL;
	guca[0] = (unsigned char)((int)guca[7] >= ~gi2);
	if (gda[1] == 100.0 || (char)gi > 46) { gc2 = (gi2 != a ? gc2 : (gu > 32767 ? '9' : gp[3])); v1(~a); }
	for (i = 0; i < a; i++) { vl(5L); if (gla[i] != 0) t = t % gla[i]; }
	return gi3;
}
char r12_07_03(int a, char b, struct st *c) {
	int i;
	int *t = gpi;
	v1(*t);
	gp = c->p + b;
	i = 0; while (i < a) { if (gua[i] != 0) gua[i] = ((unsigned int)guc) % gua[i]; gia[i] = gs.a[i]; c->i = ~gps->i; i++; }
	b = *gp;
	vc((char)!(char)c->l);
	return gc2;
}
int r12_07_04(char a, char b) {
	int t = (int)9500;
	switch (b) { case 1: v0(); case 3: case 20: gla[2] >>= 19; break; case 100: v1(t); break; default: vs(gps); break; }
	if (gua[a] != 0) gua[a] = 32767 % gua[a];
	if (gi2 != 0) gps->i = gi / gi2;
	return t;
}
char * r12_07_05(double a, unsigned char b) {
	int i;
	guca[b] = ((unsigned char)gc) | b;
	gi2 += 1;
	guca[b] ^= 255 & 255;
	gua[b] = gu2 | gps->u;
	for (i = 12; i > 0; i--) { gla[2] |= rl(gl); gi2 = (gi2 % 10) | (gca[i] >= gc2); guca[i] -= 128; }
	return gs.p;
}
unsigned long r12_07_06(int *a) {
	int i;
	double t = gd2 - gd;
	for (i = 2; i > 0; i--) { if (gu != 0) gu2 = gu % gu; gu++; }
	if (gpl[0]) { if (gps->u != 0) gu = gu2 / gps->u; }
	gul--;
	vd(t);
	if (gi2 & 1 || gl2 > gl) return (unsigned long)gi;
	return rul(~gul);
}
unsigned int r12_07_07(unsigned int a, unsigned char b, int c) {
	long t = -gs.l;
	if (gpi[1] & 0x7) vs(gps);
	gca[4] = (t ? gc : '9');
	return 8;
}
int * r12_07_08(int a, int b, long c) {
	unsigned int t = gu ^ gps->u;
	unsigned long u = gul;
	gul = u;
	vp(gp + t);
	guc = (unsigned char)(~7 <= (gca[b] / 2));
	return gpi;
}
void r12_07_09(unsigned long a) {
	if (gul != 0) gul = a % gul;
	switch (gc2) { case 2: guca[6] %= 3; break; case 3: gp[3] = gca[1] = gca[3]; break; case 16: gp = &gca[3]; break; case 100: vd((double)gc); break; default: guc = guc >> 2; break; }
	gula[3] = ~a;
	gu /= 10;
}
char * r12_07_10(int *a) {
	int i;
	unsigned long t = gul;
	guc = guc | (120 + guca[2]);
	for (i = 0; i < 4; i++) { if (gl != 0) gl2 = gl % gl; t = gul = ~gula[i]; if (gu != 0) gps->u = gu % gu; }
	for (i = 0; i < 13; i++) { if (gp[3] != 0) gca[i] = gp[3] % gp[3]; gc2 -= (gc == gca[i] ? gca[i] : 0); }
	gc = (char)((1 | gua[2]) <= ((unsigned int)(t == 8257UL)));
	return gps->p;
}
char r12_07_11(void) {
	char t = *gp + gca[1];
	unsigned long u = gul;
	gl = gla[t];
	if (gp[3]) return gp[2];
	gul = u;
	gi3 = r2(gi & 1, gi);
	return t ^ (gps->c & (' '));
}
unsigned int r12_07_12(void) {
	int i;
	int t = gs.a[2] << 3;
	char *u = &gca[t];
	for (i = 0; i < 16; i++) { gps->l = gl2 - gla[i]; }
	*gp = (char)guc >> (t & 7);
	gp = u;
	gi2 = gia[2];
	*gp >>= 1;
	gu = gu2 = 32767;
	return (gua[1] + 1) - gu2;
}
int r12_07_13(long a, long *b) {
	gps->a[6] = (int)b[2];
	vc(5);
	v0();
	return (gps->i & gi3) + (100 - gi3);
}
unsigned long r12_07_14(double a, unsigned int b) {
	double t = gd * gd;
	gca[5] |= (char)*gpl;
	vd(t);
	if ((gca[b] = '9')) { gu2 |= 256 | gua[b]; } else { v2(gi2, gi2); gps->l += gl2 / 16L; gs.u = gu + 10540; }
	*gpl %= 7L;
	gu2++;
	return (unsigned long)!b;
}
char r12_07_15(unsigned int a) {
	int i;
	unsigned int t = -a;
	unsigned long u = rul(gul);
	v2(gi3, gi);
	for (i = 0; i < 16; i++) { if (gua[i] != 0) t = 8 / gua[i]; guc++; }
	gul = u;
	switch (gc) { case 0: case 1: t ^= 1; break; default: gl = gpl[0] = gps->l; break; }
	return (gs.c = 29);
}
char * r12_07_16(void) {
	int i;
	double t = gs.d - gs.d;
	t += (double)gia[5];
	for (i = 10; i > 0; i--) { gl = 65536L; if (gi3 != 0) gi2 = gs.a[i] % gi3; t -= (gul <= 0x10000UL ? 3.0 : gd); }
	gl2++;
	gi2 = ~(*gpi - 256);
	return gps->p + 1;
}
int r12_07_17(struct st *a, long *b) {
	int *t = gpi + 1;
	v1(*t);
	vd(gd2 - gs.d);
	while (gi-- > 0) { if (*b == 65536L) break; b++; }
	guc--;
	return 2 / 7;
}
char * r12_07_18(unsigned char a) {
	int i;
	char t = rc(gi);
	vs(gps);
	gl = (gpl[2] + gl) >> 6;
	gl = gl2;
	if (!gc) return gs.p;
	for (i = 0; i < 16; i++) { if (gula[i] != 0) gul = gul % gula[i]; v2(gi2, gi2); gu = gs.u = -(gu2 ^ gs.u); }
	gc = t;
	return gp;
}
int r12_07_19(void) {
	gul = rul(gul) >> 3;
	gs.i = gi3 + gi;
	gl2 ^= 65536L + gpl[1];
	return 256 / 4;
}
