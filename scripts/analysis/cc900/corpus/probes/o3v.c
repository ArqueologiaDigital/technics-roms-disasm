/* lane_o3 verification probe (rules 19, 21, 22, 26): see gen_o3v.py for the name letters */
struct sv { char mc; unsigned char mb; int mi; unsigned int mu; long ml; unsigned long mn; int ma[4];
            char mc2; int mi2; unsigned int mu2; long ml2; };
extern struct sv gs, *gps, *hps;
extern char gc, hc, jc, *gcp; extern int gi, hi, ji, gi3, *gip; extern unsigned int gu, hu, ju, *gup;
extern long gl, hl, jl, *glp;
extern void fc(char); extern void fi(int); extern void fu(unsigned int); extern void fl(long);
extern char rc(char); extern int ri(int); extern unsigned int ru(unsigned int); extern long rl(long);
extern void fc2(char, int); extern void fi2(int, int); extern void fu2(unsigned int, int); extern void fl2(long, int);
extern void gc2(int, char); extern void gi2f(int, int); extern void gu2f(int, unsigned int); extern void gl2f(int, long);
extern void v0(void);
void gd_cGGD(char a) { if (hc != 0) gps->mc2 = gc / hc; }
void gd_cGGZ(char a) { if (hc != 0) gps->mc = gc / hc; }
void gd_cGGS(char a) { if (hc != 0) jc = gc / hc; }
void gd_cGGR(char a) { if (hc != 0) gps->mc2 = gc % hc; }
void gd_cGKD(char a) { if (hc != 0) gps->mc2 = 100 / hc; }
void gd_cGKZ(char a) { if (hc != 0) gps->mc = 100 / hc; }
void gd_cGKS(char a) { if (hc != 0) jc = 100 / hc; }
void gd_cGKR(char a) { if (hc != 0) gps->mc2 = 100 % hc; }
void gd_cGPD(char a) { if (hc != 0) gps->mc2 = a / hc; }
void gd_cGPZ(char a) { if (hc != 0) gps->mc = a / hc; }
void gd_cGPS(char a) { if (hc != 0) jc = a / hc; }
void gd_cGPR(char a) { if (hc != 0) gps->mc2 = a % hc; }
void gd_cMGD(char a) { if (hps->mc != 0) gps->mc2 = gc / hps->mc; }
void gd_cMGZ(char a) { if (hps->mc != 0) gps->mc = gc / hps->mc; }
void gd_cMGS(char a) { if (hps->mc != 0) jc = gc / hps->mc; }
void gd_cMGR(char a) { if (hps->mc != 0) gps->mc2 = gc % hps->mc; }
void gd_cMKD(char a) { if (hps->mc != 0) gps->mc2 = 100 / hps->mc; }
void gd_cMKZ(char a) { if (hps->mc != 0) gps->mc = 100 / hps->mc; }
void gd_cMKS(char a) { if (hps->mc != 0) jc = 100 / hps->mc; }
void gd_cMKR(char a) { if (hps->mc != 0) gps->mc2 = 100 % hps->mc; }
void gd_cMPD(char a) { if (hps->mc != 0) gps->mc2 = a / hps->mc; }
void gd_cMPZ(char a) { if (hps->mc != 0) gps->mc = a / hps->mc; }
void gd_cMPS(char a) { if (hps->mc != 0) jc = a / hps->mc; }
void gd_cMPR(char a) { if (hps->mc != 0) gps->mc2 = a % hps->mc; }
void gd_iGGD(int a) { if (hi != 0) gps->mi2 = gi / hi; }
void gd_iGGZ(int a) { if (hi != 0) *gip = gi / hi; }
void gd_iGGS(int a) { if (hi != 0) ji = gi / hi; }
void gd_iGGR(int a) { if (hi != 0) gps->mi2 = gi % hi; }
void gd_iGKD(int a) { if (hi != 0) gps->mi2 = 100 / hi; }
void gd_iGKZ(int a) { if (hi != 0) *gip = 100 / hi; }
void gd_iGKS(int a) { if (hi != 0) ji = 100 / hi; }
void gd_iGKR(int a) { if (hi != 0) gps->mi2 = 100 % hi; }
void gd_iGPD(int a) { if (hi != 0) gps->mi2 = a / hi; }
void gd_iGPZ(int a) { if (hi != 0) *gip = a / hi; }
void gd_iGPS(int a) { if (hi != 0) ji = a / hi; }
void gd_iGPR(int a) { if (hi != 0) gps->mi2 = a % hi; }
void gd_iMGD(int a) { if (hps->mi != 0) gps->mi2 = gi / hps->mi; }
void gd_iMGZ(int a) { if (hps->mi != 0) *gip = gi / hps->mi; }
void gd_iMGS(int a) { if (hps->mi != 0) ji = gi / hps->mi; }
void gd_iMGR(int a) { if (hps->mi != 0) gps->mi2 = gi % hps->mi; }
void gd_iMKD(int a) { if (hps->mi != 0) gps->mi2 = 100 / hps->mi; }
void gd_iMKZ(int a) { if (hps->mi != 0) *gip = 100 / hps->mi; }
void gd_iMKS(int a) { if (hps->mi != 0) ji = 100 / hps->mi; }
void gd_iMKR(int a) { if (hps->mi != 0) gps->mi2 = 100 % hps->mi; }
void gd_iMPD(int a) { if (hps->mi != 0) gps->mi2 = a / hps->mi; }
void gd_iMPZ(int a) { if (hps->mi != 0) *gip = a / hps->mi; }
void gd_iMPS(int a) { if (hps->mi != 0) ji = a / hps->mi; }
void gd_iMPR(int a) { if (hps->mi != 0) gps->mi2 = a % hps->mi; }
void gd_uGGD(unsigned int a) { if (hu != 0) gps->mu2 = gu / hu; }
void gd_uGGZ(unsigned int a) { if (hu != 0) *gup = gu / hu; }
void gd_uGGS(unsigned int a) { if (hu != 0) ju = gu / hu; }
void gd_uGGR(unsigned int a) { if (hu != 0) gps->mu2 = gu % hu; }
void gd_uGKD(unsigned int a) { if (hu != 0) gps->mu2 = 100 / hu; }
void gd_uGKZ(unsigned int a) { if (hu != 0) *gup = 100 / hu; }
void gd_uGKS(unsigned int a) { if (hu != 0) ju = 100 / hu; }
void gd_uGKR(unsigned int a) { if (hu != 0) gps->mu2 = 100 % hu; }
void gd_uGPD(unsigned int a) { if (hu != 0) gps->mu2 = a / hu; }
void gd_uGPZ(unsigned int a) { if (hu != 0) *gup = a / hu; }
void gd_uGPS(unsigned int a) { if (hu != 0) ju = a / hu; }
void gd_uGPR(unsigned int a) { if (hu != 0) gps->mu2 = a % hu; }
void gd_uMGD(unsigned int a) { if (hps->mu != 0) gps->mu2 = gu / hps->mu; }
void gd_uMGZ(unsigned int a) { if (hps->mu != 0) *gup = gu / hps->mu; }
void gd_uMGS(unsigned int a) { if (hps->mu != 0) ju = gu / hps->mu; }
void gd_uMGR(unsigned int a) { if (hps->mu != 0) gps->mu2 = gu % hps->mu; }
void gd_uMKD(unsigned int a) { if (hps->mu != 0) gps->mu2 = 100 / hps->mu; }
void gd_uMKZ(unsigned int a) { if (hps->mu != 0) *gup = 100 / hps->mu; }
void gd_uMKS(unsigned int a) { if (hps->mu != 0) ju = 100 / hps->mu; }
void gd_uMKR(unsigned int a) { if (hps->mu != 0) gps->mu2 = 100 % hps->mu; }
void gd_uMPD(unsigned int a) { if (hps->mu != 0) gps->mu2 = a / hps->mu; }
void gd_uMPZ(unsigned int a) { if (hps->mu != 0) *gup = a / hps->mu; }
void gd_uMPS(unsigned int a) { if (hps->mu != 0) ju = a / hps->mu; }
void gd_uMPR(unsigned int a) { if (hps->mu != 0) gps->mu2 = a % hps->mu; }
void ua_inG1(int a) { fi(-gi); }
int ua_inGT(int a) { return ri(-gi); }
void ua_inG2(int a) { fi2(-gi, gi); }
void ua_inG3(int a) { gi2f(gi, -gi); }
void ua_inP1(int a) { fi(-a); }
int ua_inPT(int a) { return ri(-a); }
void ua_inP2(int a) { fi2(-a, gi); }
void ua_inP3(int a) { gi2f(gi, -a); }
void ua_inI1(int a) { int t = gi; v0(); fi(-t); }
int ua_inIT(int a) { int t = gi; v0(); return ri(-t); }
void ua_inI2(int a) { int t = gi; v0(); fi2(-t, gi); }
void ua_inI3(int a) { int t = gi; v0(); gi2f(gi, -t); }
void ua_inM1(int a) { fi(-gps->mi); }
int ua_inMT(int a) { return ri(-gps->mi); }
void ua_inM2(int a) { fi2(-gps->mi, gi); }
void ua_inM3(int a) { gi2f(gi, -gps->mi); }
void ua_icG1(int a) { fi(~gi); }
int ua_icGT(int a) { return ri(~gi); }
void ua_icG2(int a) { fi2(~gi, gi); }
void ua_icG3(int a) { gi2f(gi, ~gi); }
void ua_icP1(int a) { fi(~a); }
int ua_icPT(int a) { return ri(~a); }
void ua_icP2(int a) { fi2(~a, gi); }
void ua_icP3(int a) { gi2f(gi, ~a); }
void ua_icI1(int a) { int t = gi; v0(); fi(~t); }
int ua_icIT(int a) { int t = gi; v0(); return ri(~t); }
void ua_icI2(int a) { int t = gi; v0(); fi2(~t, gi); }
void ua_icI3(int a) { int t = gi; v0(); gi2f(gi, ~t); }
void ua_icM1(int a) { fi(~gps->mi); }
int ua_icMT(int a) { return ri(~gps->mi); }
void ua_icM2(int a) { fi2(~gps->mi, gi); }
void ua_icM3(int a) { gi2f(gi, ~gps->mi); }
void ua_unG1(unsigned int a) { fu(-gu); }
unsigned int ua_unGT(unsigned int a) { return ru(-gu); }
void ua_unG2(unsigned int a) { fu2(-gu, gi); }
void ua_unG3(unsigned int a) { gu2f(gi, -gu); }
void ua_unP1(unsigned int a) { fu(-a); }
unsigned int ua_unPT(unsigned int a) { return ru(-a); }
void ua_unP2(unsigned int a) { fu2(-a, gi); }
void ua_unP3(unsigned int a) { gu2f(gi, -a); }
void ua_unI1(unsigned int a) { unsigned int t = gu; v0(); fu(-t); }
unsigned int ua_unIT(unsigned int a) { unsigned int t = gu; v0(); return ru(-t); }
void ua_unI2(unsigned int a) { unsigned int t = gu; v0(); fu2(-t, gi); }
void ua_unI3(unsigned int a) { unsigned int t = gu; v0(); gu2f(gi, -t); }
void ua_unM1(unsigned int a) { fu(-gps->mu); }
unsigned int ua_unMT(unsigned int a) { return ru(-gps->mu); }
void ua_unM2(unsigned int a) { fu2(-gps->mu, gi); }
void ua_unM3(unsigned int a) { gu2f(gi, -gps->mu); }
void ua_ucG1(unsigned int a) { fu(~gu); }
unsigned int ua_ucGT(unsigned int a) { return ru(~gu); }
void ua_ucG2(unsigned int a) { fu2(~gu, gi); }
void ua_ucG3(unsigned int a) { gu2f(gi, ~gu); }
void ua_ucP1(unsigned int a) { fu(~a); }
unsigned int ua_ucPT(unsigned int a) { return ru(~a); }
void ua_ucP2(unsigned int a) { fu2(~a, gi); }
void ua_ucP3(unsigned int a) { gu2f(gi, ~a); }
void ua_ucI1(unsigned int a) { unsigned int t = gu; v0(); fu(~t); }
unsigned int ua_ucIT(unsigned int a) { unsigned int t = gu; v0(); return ru(~t); }
void ua_ucI2(unsigned int a) { unsigned int t = gu; v0(); fu2(~t, gi); }
void ua_ucI3(unsigned int a) { unsigned int t = gu; v0(); gu2f(gi, ~t); }
void ua_ucM1(unsigned int a) { fu(~gps->mu); }
unsigned int ua_ucMT(unsigned int a) { return ru(~gps->mu); }
void ua_ucM2(unsigned int a) { fu2(~gps->mu, gi); }
void ua_ucM3(unsigned int a) { gu2f(gi, ~gps->mu); }
void ua_lnG1(long a) { fl(-gl); }
long ua_lnGT(long a) { return rl(-gl); }
void ua_lnG2(long a) { fl2(-gl, gi); }
void ua_lnG3(long a) { gl2f(gi, -gl); }
void ua_lnP1(long a) { fl(-a); }
long ua_lnPT(long a) { return rl(-a); }
void ua_lnP2(long a) { fl2(-a, gi); }
void ua_lnP3(long a) { gl2f(gi, -a); }
void ua_lnI1(long a) { long t = gl; v0(); fl(-t); }
long ua_lnIT(long a) { long t = gl; v0(); return rl(-t); }
void ua_lnI2(long a) { long t = gl; v0(); fl2(-t, gi); }
void ua_lnI3(long a) { long t = gl; v0(); gl2f(gi, -t); }
void ua_lnM1(long a) { fl(-gps->ml); }
long ua_lnMT(long a) { return rl(-gps->ml); }
void ua_lnM2(long a) { fl2(-gps->ml, gi); }
void ua_lnM3(long a) { gl2f(gi, -gps->ml); }
void ua_lcG1(long a) { fl(~gl); }
long ua_lcGT(long a) { return rl(~gl); }
void ua_lcG2(long a) { fl2(~gl, gi); }
void ua_lcG3(long a) { gl2f(gi, ~gl); }
void ua_lcP1(long a) { fl(~a); }
long ua_lcPT(long a) { return rl(~a); }
void ua_lcP2(long a) { fl2(~a, gi); }
void ua_lcP3(long a) { gl2f(gi, ~a); }
void ua_lcI1(long a) { long t = gl; v0(); fl(~t); }
long ua_lcIT(long a) { long t = gl; v0(); return rl(~t); }
void ua_lcI2(long a) { long t = gl; v0(); fl2(~t, gi); }
void ua_lcI3(long a) { long t = gl; v0(); gl2f(gi, ~t); }
void ua_lcM1(long a) { fl(~gps->ml); }
long ua_lcMT(long a) { return rl(~gps->ml); }
void ua_lcM2(long a) { fl2(~gps->ml, gi); }
void ua_lcM3(long a) { gl2f(gi, ~gps->ml); }
void sr_cGDl(int n) { *gcp <<= 3; }
void sr_cGDr(int n) { *gcp >>= 3; }
void sr_cGDv(int n) { *gcp >>= n; }
void sr_cGMl(int n) { gps->mc2 <<= 3; }
void sr_cGMr(int n) { gps->mc2 >>= 3; }
void sr_cGMv(int n) { gps->mc2 >>= n; }
void sr_cGAl(int n) { gcp[2] <<= 3; }
void sr_cGAr(int n) { gcp[2] >>= 3; }
void sr_cGAv(int n) { gcp[2] >>= n; }
void sr_cSDl(int n, long z, char *p) { *p <<= 3; }
void sr_cSDr(int n, long z, char *p) { *p >>= 3; }
void sr_cSDv(int n, long z, char *p) { *p >>= n; }
void sr_cSMl(int n, long z, struct sv *p) { p->mc2 <<= 3; }
void sr_cSMr(int n, long z, struct sv *p) { p->mc2 >>= 3; }
void sr_cSMv(int n, long z, struct sv *p) { p->mc2 >>= n; }
void sr_cSAl(int n, long z, char *p) { p[2] <<= 3; }
void sr_cSAr(int n, long z, char *p) { p[2] >>= 3; }
void sr_cSAv(int n, long z, char *p) { p[2] >>= n; }
void sr_cRDl(char *p, int n) { *p <<= 3; }
void sr_cRDr(char *p, int n) { *p >>= 3; }
void sr_cRDv(char *p, int n) { *p >>= n; }
void sr_cRMl(struct sv *p, int n) { p->mc2 <<= 3; }
void sr_cRMr(struct sv *p, int n) { p->mc2 >>= 3; }
void sr_cRMv(struct sv *p, int n) { p->mc2 >>= n; }
void sr_cRAl(char *p, int n) { p[2] <<= 3; }
void sr_cRAr(char *p, int n) { p[2] >>= 3; }
void sr_cRAv(char *p, int n) { p[2] >>= n; }
void sr_iGDl(int n) { *gip <<= 3; }
void sr_iGDr(int n) { *gip >>= 3; }
void sr_iGDv(int n) { *gip >>= n; }
void sr_iGMl(int n) { gps->mi2 <<= 3; }
void sr_iGMr(int n) { gps->mi2 >>= 3; }
void sr_iGMv(int n) { gps->mi2 >>= n; }
void sr_iGAl(int n) { gip[2] <<= 3; }
void sr_iGAr(int n) { gip[2] >>= 3; }
void sr_iGAv(int n) { gip[2] >>= n; }
void sr_iSDl(int n, long z, int *p) { *p <<= 3; }
void sr_iSDr(int n, long z, int *p) { *p >>= 3; }
void sr_iSDv(int n, long z, int *p) { *p >>= n; }
void sr_iSMl(int n, long z, struct sv *p) { p->mi2 <<= 3; }
void sr_iSMr(int n, long z, struct sv *p) { p->mi2 >>= 3; }
void sr_iSMv(int n, long z, struct sv *p) { p->mi2 >>= n; }
void sr_iSAl(int n, long z, int *p) { p[2] <<= 3; }
void sr_iSAr(int n, long z, int *p) { p[2] >>= 3; }
void sr_iSAv(int n, long z, int *p) { p[2] >>= n; }
void sr_iRDl(int *p, int n) { *p <<= 3; }
void sr_iRDr(int *p, int n) { *p >>= 3; }
void sr_iRDv(int *p, int n) { *p >>= n; }
void sr_iRMl(struct sv *p, int n) { p->mi2 <<= 3; }
void sr_iRMr(struct sv *p, int n) { p->mi2 >>= 3; }
void sr_iRMv(struct sv *p, int n) { p->mi2 >>= n; }
void sr_iRAl(int *p, int n) { p[2] <<= 3; }
void sr_iRAr(int *p, int n) { p[2] >>= 3; }
void sr_iRAv(int *p, int n) { p[2] >>= n; }
void sr_uGDl(int n) { *gup <<= 3; }
void sr_uGDr(int n) { *gup >>= 3; }
void sr_uGDv(int n) { *gup >>= n; }
void sr_uGMl(int n) { gps->mu2 <<= 3; }
void sr_uGMr(int n) { gps->mu2 >>= 3; }
void sr_uGMv(int n) { gps->mu2 >>= n; }
void sr_uGAl(int n) { gup[2] <<= 3; }
void sr_uGAr(int n) { gup[2] >>= 3; }
void sr_uGAv(int n) { gup[2] >>= n; }
void sr_uSDl(int n, long z, unsigned int *p) { *p <<= 3; }
void sr_uSDr(int n, long z, unsigned int *p) { *p >>= 3; }
void sr_uSDv(int n, long z, unsigned int *p) { *p >>= n; }
void sr_uSMl(int n, long z, struct sv *p) { p->mu2 <<= 3; }
void sr_uSMr(int n, long z, struct sv *p) { p->mu2 >>= 3; }
void sr_uSMv(int n, long z, struct sv *p) { p->mu2 >>= n; }
void sr_uSAl(int n, long z, unsigned int *p) { p[2] <<= 3; }
void sr_uSAr(int n, long z, unsigned int *p) { p[2] >>= 3; }
void sr_uSAv(int n, long z, unsigned int *p) { p[2] >>= n; }
void sr_uRDl(unsigned int *p, int n) { *p <<= 3; }
void sr_uRDr(unsigned int *p, int n) { *p >>= 3; }
void sr_uRDv(unsigned int *p, int n) { *p >>= n; }
void sr_uRMl(struct sv *p, int n) { p->mu2 <<= 3; }
void sr_uRMr(struct sv *p, int n) { p->mu2 >>= 3; }
void sr_uRMv(struct sv *p, int n) { p->mu2 >>= n; }
void sr_uRAl(unsigned int *p, int n) { p[2] <<= 3; }
void sr_uRAr(unsigned int *p, int n) { p[2] >>= 3; }
void sr_uRAv(unsigned int *p, int n) { p[2] >>= n; }
void sr_lGDl(int n) { *glp <<= 3; }
void sr_lGDr(int n) { *glp >>= 3; }
void sr_lGDv(int n) { *glp >>= n; }
void sr_lGMl(int n) { gps->ml2 <<= 3; }
void sr_lGMr(int n) { gps->ml2 >>= 3; }
void sr_lGMv(int n) { gps->ml2 >>= n; }
void sr_lGAl(int n) { glp[2] <<= 3; }
void sr_lGAr(int n) { glp[2] >>= 3; }
void sr_lGAv(int n) { glp[2] >>= n; }
void sr_lSDl(int n, long z, long *p) { *p <<= 3; }
void sr_lSDr(int n, long z, long *p) { *p >>= 3; }
void sr_lSDv(int n, long z, long *p) { *p >>= n; }
void sr_lSMl(int n, long z, struct sv *p) { p->ml2 <<= 3; }
void sr_lSMr(int n, long z, struct sv *p) { p->ml2 >>= 3; }
void sr_lSMv(int n, long z, struct sv *p) { p->ml2 >>= n; }
void sr_lSAl(int n, long z, long *p) { p[2] <<= 3; }
void sr_lSAr(int n, long z, long *p) { p[2] >>= 3; }
void sr_lSAv(int n, long z, long *p) { p[2] >>= n; }
void sr_lRDl(long *p, int n) { *p <<= 3; }
void sr_lRDr(long *p, int n) { *p >>= 3; }
void sr_lRDv(long *p, int n) { *p >>= n; }
void sr_lRMl(struct sv *p, int n) { p->ml2 <<= 3; }
void sr_lRMr(struct sv *p, int n) { p->ml2 >>= 3; }
void sr_lRMv(struct sv *p, int n) { p->ml2 >>= n; }
void sr_lRAl(long *p, int n) { p[2] <<= 3; }
void sr_lRAr(long *p, int n) { p[2] >>= 3; }
void sr_lRAv(long *p, int n) { p[2] >>= n; }
void pt_cSD(long z, char *p) { if (*p != 0) { gi3 = gs.mi / *p; } }
void pt_cSA(long z, char *p) { if (*p != 0) { gi3 = gi + *p; } }
void pt_cSW(long z, char *p) { if (*p != 0) { *p = gc; } }
void pt_cSN(long z, char *p) { if (*p != 0) { gi3 = gi; } }
void pt_cSI(long z, char *p) { if (*p != 0) { p++; gi3 = gi + *p; } }
void pt_cGD(void) { if (*gcp != 0) { gi3 = gs.mi / *gcp; } }
void pt_cGA(void) { if (*gcp != 0) { gi3 = gi + *gcp; } }
void pt_cGW(void) { if (*gcp != 0) { *gcp = gc; } }
void pt_cGN(void) { if (*gcp != 0) { gi3 = gi; } }
void pt_cGI(void) { if (*gcp != 0) { gcp++; gi3 = gi + *gcp; } }
void pt_iSD(long z, int *p) { if (*p != 0) { gi3 = gs.mi / *p; } }
void pt_iSA(long z, int *p) { if (*p != 0) { gi3 = gi + *p; } }
void pt_iSW(long z, int *p) { if (*p != 0) { *p = gi; } }
void pt_iSN(long z, int *p) { if (*p != 0) { gi3 = gi; } }
void pt_iSI(long z, int *p) { if (*p != 0) { p++; gi3 = gi + *p; } }
void pt_iGD(void) { if (*gip != 0) { gi3 = gs.mi / *gip; } }
void pt_iGA(void) { if (*gip != 0) { gi3 = gi + *gip; } }
void pt_iGW(void) { if (*gip != 0) { *gip = gi; } }
void pt_iGN(void) { if (*gip != 0) { gi3 = gi; } }
void pt_iGI(void) { if (*gip != 0) { gip++; gi3 = gi + *gip; } }
