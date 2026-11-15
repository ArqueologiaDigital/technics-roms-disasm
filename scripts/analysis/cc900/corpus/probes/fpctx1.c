/* fpctx1.c (lane_fpframe, 2026-11-15): minimal pairs for the frame / context rules 01-10 of lane_fpframe RULES.md.
   Each group: the form a rule claims and its competitors.  Run at none, O3XS, Xr, O3XSXr. */
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
extern char jc; extern unsigned char juc; extern int ji; extern unsigned int ju; extern long jl; extern unsigned long jul;
extern double jd; extern char *jp; extern int *jpi; extern long *jpl; extern struct st *jps;


/* rule 01 RESET_INC4_INNER: a 4-byte ++ / -- of a memory object inside an expression statement (region D) */
void x01a(void) { gd2 = gs.d * -gd; *gp++ = 8; }
void x01b(void) { gd2 = gs.d * -gd; *gp = 8; }
void x01c(void) { gd2 = gs.d * -gd; gp++; }
void x01d(void) { gd2 = gs.d * -gd; *gpi++ = 8; }
void x01e(char *c) { gd2 = gs.d * -gd; *c++ = 8; }
void x01f(void) { gd2 = gs.d * -gd; gia[2] = gl++; }
void x01g(void) { *gp++ = 8; gd2 = gs.d * -gd; }
void x01h(void) { gd2 = gs.d * -gd; gi = gi2++; }
void x01i(void) { vd(-gda[0]); *gpl++ = 9L; }

/* rule 02 / 04: m = m % m2 resets, m = m / m2 does not (and the 2-byte forms) */
void x02a(void) { gd2 = gs.d * -gd; gul = gul % gula[1]; }
void x02b(void) { gd2 = gs.d * -gd; gul = gul / gula[1]; }
void x02c(void) { gd2 = gs.d * -gd; gu = gu % gu2; }
void x02d(void) { gd2 = gs.d * -gd; gu = gu / gu2; }
void x02e(void) { gd2 = gs.d * -gd; gul = gul % gul; }
void x02f(void) { gd2 = gs.d * -gd; gi = gi * gi2; }
void x02g(void) { if ((gi2 = 256) > 255) vd(gd * gda[3]); }

/* rule 03 RESET_BIT_CAST: a bit test of 1 or 2 bytes resets, a 4-byte one does not */
void x03a(void) { gd2 = gs.d * -gd; if (gu & 0x80) gi = 1; }
void x03b(void) { gd2 = gs.d * -gd; if (gul & 0x80) gi = 1; }
void x03c(void) { gd2 = gs.d * -gd; if (gi & 0x80) gi2 = 1; }
void x03d(void) { gd2 = gs.d * -gd; if (guc & 0x80) gi = 1; }
void x03e(void) { gd2 = gs.d * -gd; gi = (gu & 0x80 ? 3 : 4); }
void x03f(void) { gd2 = gs.d * -gd; gi = (gul & 0x80 ? 3 : 4); }
void x03g(void) { gd2 = (gu2 & 0x8 ? gd : gda[1]) * gs.d; }
void x03h(void) { gd2 = (gul & 0x8 ? gd : gda[1]) * gs.d; }

/* rule 05 RESET_OPA_LOST: a local a double op= keeps out of XIZ sits below the region, the region D */
char x05a(void) { char *u = gs.p; gda[1] += gd / 100.0; vp(u); return 1; }
char x05b(void) { char *u = gs.p; gd += gd2 / 100.0; vp(u); return 1; }
char x05c(void) { int u = gi2; gda[1] *= gd / 3.0; v1(u); return 1; }
char x05d(void) { long u = gl2; gda[2] -= gd * 2.5; vl(u); return 1; }

/* rule 06 DL_DEREF_PTR: (double) of a long read through a pointer */
void x06a(void) { gd = (double)*gpl; }
void x06b(void) { gd = gd2 * (double)*gpl; }
void x06c(void) { gd = gd2 * (double)gpl[1]; }
void x06d(void) { gd = gd2 * (double)gps->l; }
void x06e(long *p) { gd = gd2 * (double)*p; }
void x06f(void) { gd = gd2 * (double)*jpl; }
void x06g(void) { vd((double)*gpl); }

/* rule 07 WINDOW_LONG_ONE: one long slot, temporaries made by one statement */
void x07a(void) { gd2 -= (double)gu2 - 2.5; }
void x07b(void) { gd2 -= (double)gi2 * 2.5; }
void x07c(void) { gi = 1; gd2 -= (double)gi2 * 2.5; gi3 = 2; gi2 = 4; }
void x07d(void) { gd2 = gd + ((double)gu - 2.5); }
void x07e(int n) { gd = gd * n + 2.0 * gd2; }
void x07f(void) { gd = (gi ? (0.5 + (double)*gp) : gd2); }

/* rule 08 FP_NEG_FOLD: -(-x) and a - -b of doubles; an op= is not folded */
void x08a(void) { gd = -(-gd2); }
void x08b(void) { gd = gd2 - -gs.d; }
void x08c(void) { gd = gd2 + -gs.d; }
void x08d(void) { gd -= -gd2; }
void x08e(void) { gd = -(-gd2) * gs.d; }
void x08f(void) { gd = (gd2 / 10.0) - -gda[3]; }
void x08g(void) { vd(-(-gd2)); }

/* rule 09 OPA_XIZ_POPS_FIRST: a call's pending pops before a double op='s XIZ, unless a later call takes them */
void x09a(void) { vc(gc); gda[3] *= gd2; }
void x09b(void) { vc(gc); gda[3] *= gd2; vc(gc2); }
void x09c(void) { vc(gc); gda[3] *= gd2; gi = 2; }
void x09d(void) { vl(gl); gs.d += gd2; }

/* rule 10 FOLDABLE_OVER_STORE: a local not folded over a pointer store gets a home */
int x10a(void) { unsigned long t = gula[4]; gda[1] = -gd; gul = t; return 1; }
int x10b(void) { long t = *gpl; *gpl = 5L; gd = gd2 * gs.d; gl = t; return 1; }
int x10c(void) { unsigned long t = gula[4]; gula[4] = 3UL; gul = t; return 1; }
int x10d(void) { int t = gia[2]; gia[2] = 7; gd = -gd2; gi = t; return 1; }
