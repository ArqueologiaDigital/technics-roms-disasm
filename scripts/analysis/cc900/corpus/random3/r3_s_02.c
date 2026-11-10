/* Random C89 program r3_s_02.c: gen_random.py --seed 3 --count 10 --funcs 20 --size small (file 2).
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

void r3_02_00(void) {
	int i;
	gl2 = *gpl;
	gi3 += r2(gi2, gi2);
	for (i = 0; i < 2; i++) { if (gula[7] != 0) gul = gul % gula[7]; guc--; }
}
unsigned long r3_02_01(unsigned char a, char b) {
	long t = gla[a];
	*gpl = gla[b] = (long)!gs.u;
	gl2 = ~65536L;
	gl = t;
	gc2 >>= 7;
	gs.a[3] *= 11;
	if (a) if (gl != 0) gl = gpl[2] % gl;
	return (gul % 7UL) << 13;
}
int * r3_02_02(unsigned long a, unsigned char b) {
	gl2 = rl(72977L % 7L);
	v1(gi3 * gi3);
	guc *= 4;
	return gpi;
}
long r3_02_03(unsigned char a, struct st *b, unsigned long c) {
	int t = (int)guc;
	long u = rl(gl2);
	switch (t) { case 0: u ^= 65536L; break; case 1: u = u / 10L; break; case 2: vl(u); break; case 3: v1(b->i); default: vd(gd2); break; }
	switch (gc) { case 5: gula[a] <<= (a & 15); break; case 20: gia[a] = t + 1; break; case 100: vl(41951L); break; }
	vu(gu2 << 12);
	return *gpl;
}
void r3_02_04(unsigned char a, unsigned int b, unsigned int c) {
	long t = 33371L % 7L;
	gu &= ru(32767);
	gl = t;
	gps->p = gp;
	v2(gi2, 16);
}
int r3_02_05(void) {
	char *t = gps->p;
	gi3++;
	++gc;
	gs.p = t;
	gda[3] = gda[3] + gda[1];
	return gs.a[5];
}
int * r3_02_06(void) {
	gs.c = gca[2];
	vc(92 - gc);
	gda[3] = gd2;
	guca[0] = (guc % 7) / 10;
	return gpi;
}
char r3_02_07(char *a, long *b, int c) {
	int i;
	char t = (char)guca[6] & gs.c;
	double u = gd / 10.0;
	if (gua[5] > gs.u) { if (gi3 != 0) gi = gi / gi3; gl2 %= 3L; v2(1 | 255, gi); }
	for (i = 12; i > 0; i--) { guca[i] = guc; vc(a[t]); }
	vs(gps);
	return gca[c] / 100;
}
int r3_02_08(char a) {
	if (gc & 0x8 && gula[3] < ((unsigned long)gla[a])) { gca[a] = gps->c; v2(gpi[3], gi); gd2 += gd2; }
	vp(gps->p);
	return ((int)guc + gi2) << 3;
}
char * r3_02_09(double a, unsigned char b, char c) {
	int t = gs.a[b];
	unsigned long u = 78906UL << 5;
	++t;
	gpi = &gia[b];
	gu2 = gps->u = ru(14840);
	return rp();
}
char r3_02_10(void) {
	gu2 ^= gua[3] >> 7;
	if (gul) { vl(gl2 & 4L); } else { if (32767 == gu) gia[7] = gi3 + gi2; }
	gs.d -= (double)*gpi;
	return (gc2 = gca[4]);
}
int * r3_02_11(struct st *a) {
	int t = 256;
	int u = ~255;
	if (gu2 || gi2 == a->i) { gula[4] ^= ~gula[3]; t = 256 ^ (gs.c == -57 ? gpi[2] : 142); } else { gul--; gp = rp(); }
	switch (gi) { case 0: case 1: v0(); case 2: gl2 *= 5L; break; case 3: v2(gi2, u); break; default: vs(gps); break; }
	if (-43490L < gpl[0]) { vu(a->u); } else { gu2 -= ((unsigned int)gi2) + gu2; gd -= gd; }
	gps->c = gc;
	u = (u - gi) >> (t & 15);
	return gpi;
}
int r3_02_12(long *a, int b, long c) {
	int i;
	char *t = gps->p + b;
	gp[3] = -28;
	switch (gi2) { case 0: vp(t); break; case 1: vc(gca[7]); break; case 2: gul = 1UL - gul; break; case 3: gp[0] ^= 55; break; case 4: *gpi -= gi; break; default: vs(gps); break; }
	gul = 0x10000UL;
	for (i = 9; i > 0; i--) { if (c != 0) gl = (long)gc2 / c; guca[i] = guca[i] + guc; if (gs.l != 0) gpl[3] = gl % gs.l; }
	guc += 12;
	return r2(gi2, gi3) % 10;
}
void r3_02_13(long a, int b) {
	char t = 5;
	char u = gps->c << (t & 7);
	++gul;
	vc(t);
	gs.d = 0.5 + gda[3];
	vc(u);
}
int * r3_02_14(struct st *a) {
	unsigned char t = guc;
	int u = gi3;
	gc = gc2;
	gc++;
	gi = u;
	gla[7] = (gl >> (t & 15)) | (-17753L % 10L);
	return gpi;
}
char r3_02_15(void) {
	int t = gs.i;
	gl = gps->l;
	switch (gps->i) { case 0: gca[2] = 9; break; case 1: v0(); break; case 2: vc(gc); case 3: gu2 -= 1; case 4: case 5: vs(gps); default: vu(gua[t]); break; }
	if (gc != 0) gp[2] = gp[3] % gc;
	gpi = gpi + t;
	return rc(gia[t]);
}
void r3_02_16(unsigned char a) {
	int i;
	gia[5] = gps->a[7] = !gia[a] - (gpi[3] - gi);
	v0();
	if (a >= guc) if (gpl[0] != 0) gla[6] = gs.l / gpl[0];
	gs.d = (double)gu / 0.25;
	for (i = 6; i > 0; i--) { if (gp[3] != 0) gc = *gp / gp[3]; }
}
char * r3_02_17(void) {
	int i;
	unsigned char t = ((unsigned char)gula[0]) + guca[7];
	gla[t] = gps->l ^ gs.l;
	if (gi == 256 || t & 0x8) { vs(gps); } else { gda[3] = -(gd * 10.0); }
	i = 0; while (i < 2) { gpi = rpi(r0()); if (gl != 0) gs.l = gl2 % gl; gs.u = gu2; i++; }
	++gul;
	return gp;
}
long r3_02_18(int a) {
	int i;
	int *t = gpi + a;
	for (i = 0; i < 4; i++) { if (gua[i] != 0) gu = gps->u / gua[i]; gl = gs.l = ((long)gu2 - gl2) * 6L; gc = (char)((i << 15) < (i | gps->i)); }
	gpi = t;
	guc += (unsigned char)gul;
	return (long)!(gul / 4UL);
}
int r3_02_19(unsigned char a) {
	int i;
	i = 0; while (i < 14) { guc = -(guca[i] + guc); gul = rul(gul) & ((unsigned long)gs.a[i]); if (gul != 0) gula[i] = ((unsigned long)gu2) / gul; i++; }
	if (gpi[0] != 0) gs.i = 267 / gpi[0];
	return gi3;
}
