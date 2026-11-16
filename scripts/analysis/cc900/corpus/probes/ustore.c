/* lane_nm probe: an unsigned int index on stores through a pointer; see gen_ustore.py for the name letters */
extern char gc, *gcp;
extern int gi, *gip;
extern long gl, *glp;
extern unsigned int ju;
extern void v0(void);
void us_cqls(unsigned int pu, char *q) { unsigned int u = ju; v0(); q[u] = 5; }
void us_cqlv(unsigned int pu, char *q) { unsigned int u = ju; v0(); q[u] = gc; }
char us_cqlr(unsigned int pu, char *q) { unsigned int u = ju; v0(); return q[u]; }
void us_cqla(unsigned int pu, char *q) { unsigned int u = ju; v0(); q[u] += 3; }
void us_cqgs(unsigned int pu, char *q) { q[ju] = 5; }
void us_cqgv(unsigned int pu, char *q) { q[ju] = gc; }
char us_cqgr(unsigned int pu, char *q) { return q[ju]; }
void us_cqga(unsigned int pu, char *q) { q[ju] += 3; }
void us_cqps(unsigned int pu, char *q) { q[pu] = 5; }
void us_cqpv(unsigned int pu, char *q) { q[pu] = gc; }
char us_cqpr(unsigned int pu, char *q) { return q[pu]; }
void us_cqpa(unsigned int pu, char *q) { q[pu] += 3; }
void us_cgls(unsigned int pu, char *q) { unsigned int u = ju; v0(); gcp[u] = 5; }
void us_cglv(unsigned int pu, char *q) { unsigned int u = ju; v0(); gcp[u] = gc; }
char us_cglr(unsigned int pu, char *q) { unsigned int u = ju; v0(); return gcp[u]; }
void us_cgla(unsigned int pu, char *q) { unsigned int u = ju; v0(); gcp[u] += 3; }
void us_cggs(unsigned int pu, char *q) { gcp[ju] = 5; }
void us_cggv(unsigned int pu, char *q) { gcp[ju] = gc; }
char us_cggr(unsigned int pu, char *q) { return gcp[ju]; }
void us_cgga(unsigned int pu, char *q) { gcp[ju] += 3; }
void us_cgps(unsigned int pu, char *q) { gcp[pu] = 5; }
void us_cgpv(unsigned int pu, char *q) { gcp[pu] = gc; }
char us_cgpr(unsigned int pu, char *q) { return gcp[pu]; }
void us_cgpa(unsigned int pu, char *q) { gcp[pu] += 3; }
void us_clls(unsigned int pu, char *q) { char *w = gcp; unsigned int u = ju; v0(); w[u] = 5; }
void us_cllv(unsigned int pu, char *q) { char *w = gcp; unsigned int u = ju; v0(); w[u] = gc; }
char us_cllr(unsigned int pu, char *q) { char *w = gcp; unsigned int u = ju; v0(); return w[u]; }
void us_clla(unsigned int pu, char *q) { char *w = gcp; unsigned int u = ju; v0(); w[u] += 3; }
void us_clgs(unsigned int pu, char *q) { char *w = gcp; v0(); w[ju] = 5; }
void us_clgv(unsigned int pu, char *q) { char *w = gcp; v0(); w[ju] = gc; }
char us_clgr(unsigned int pu, char *q) { char *w = gcp; v0(); return w[ju]; }
void us_clga(unsigned int pu, char *q) { char *w = gcp; v0(); w[ju] += 3; }
void us_clps(unsigned int pu, char *q) { char *w = gcp; v0(); w[pu] = 5; }
void us_clpv(unsigned int pu, char *q) { char *w = gcp; v0(); w[pu] = gc; }
char us_clpr(unsigned int pu, char *q) { char *w = gcp; v0(); return w[pu]; }
void us_clpa(unsigned int pu, char *q) { char *w = gcp; v0(); w[pu] += 3; }
void us_iqls(unsigned int pu, int *q) { unsigned int u = ju; v0(); q[u] = 5; }
void us_iqlv(unsigned int pu, int *q) { unsigned int u = ju; v0(); q[u] = gi; }
int us_iqlr(unsigned int pu, int *q) { unsigned int u = ju; v0(); return q[u]; }
void us_iqla(unsigned int pu, int *q) { unsigned int u = ju; v0(); q[u] += 3; }
void us_iqgs(unsigned int pu, int *q) { q[ju] = 5; }
void us_iqgv(unsigned int pu, int *q) { q[ju] = gi; }
int us_iqgr(unsigned int pu, int *q) { return q[ju]; }
void us_iqga(unsigned int pu, int *q) { q[ju] += 3; }
void us_iqps(unsigned int pu, int *q) { q[pu] = 5; }
void us_iqpv(unsigned int pu, int *q) { q[pu] = gi; }
int us_iqpr(unsigned int pu, int *q) { return q[pu]; }
void us_iqpa(unsigned int pu, int *q) { q[pu] += 3; }
void us_igls(unsigned int pu, int *q) { unsigned int u = ju; v0(); gip[u] = 5; }
void us_iglv(unsigned int pu, int *q) { unsigned int u = ju; v0(); gip[u] = gi; }
int us_iglr(unsigned int pu, int *q) { unsigned int u = ju; v0(); return gip[u]; }
void us_igla(unsigned int pu, int *q) { unsigned int u = ju; v0(); gip[u] += 3; }
void us_iggs(unsigned int pu, int *q) { gip[ju] = 5; }
void us_iggv(unsigned int pu, int *q) { gip[ju] = gi; }
int us_iggr(unsigned int pu, int *q) { return gip[ju]; }
void us_igga(unsigned int pu, int *q) { gip[ju] += 3; }
void us_igps(unsigned int pu, int *q) { gip[pu] = 5; }
void us_igpv(unsigned int pu, int *q) { gip[pu] = gi; }
int us_igpr(unsigned int pu, int *q) { return gip[pu]; }
void us_igpa(unsigned int pu, int *q) { gip[pu] += 3; }
void us_ills(unsigned int pu, int *q) { int *w = gip; unsigned int u = ju; v0(); w[u] = 5; }
void us_illv(unsigned int pu, int *q) { int *w = gip; unsigned int u = ju; v0(); w[u] = gi; }
int us_illr(unsigned int pu, int *q) { int *w = gip; unsigned int u = ju; v0(); return w[u]; }
void us_illa(unsigned int pu, int *q) { int *w = gip; unsigned int u = ju; v0(); w[u] += 3; }
void us_ilgs(unsigned int pu, int *q) { int *w = gip; v0(); w[ju] = 5; }
void us_ilgv(unsigned int pu, int *q) { int *w = gip; v0(); w[ju] = gi; }
int us_ilgr(unsigned int pu, int *q) { int *w = gip; v0(); return w[ju]; }
void us_ilga(unsigned int pu, int *q) { int *w = gip; v0(); w[ju] += 3; }
void us_ilps(unsigned int pu, int *q) { int *w = gip; v0(); w[pu] = 5; }
void us_ilpv(unsigned int pu, int *q) { int *w = gip; v0(); w[pu] = gi; }
int us_ilpr(unsigned int pu, int *q) { int *w = gip; v0(); return w[pu]; }
void us_ilpa(unsigned int pu, int *q) { int *w = gip; v0(); w[pu] += 3; }
void us_lqls(unsigned int pu, long *q) { unsigned int u = ju; v0(); q[u] = 5; }
void us_lqlv(unsigned int pu, long *q) { unsigned int u = ju; v0(); q[u] = gl; }
long us_lqlr(unsigned int pu, long *q) { unsigned int u = ju; v0(); return q[u]; }
void us_lqla(unsigned int pu, long *q) { unsigned int u = ju; v0(); q[u] += 3; }
void us_lqgs(unsigned int pu, long *q) { q[ju] = 5; }
void us_lqgv(unsigned int pu, long *q) { q[ju] = gl; }
long us_lqgr(unsigned int pu, long *q) { return q[ju]; }
void us_lqga(unsigned int pu, long *q) { q[ju] += 3; }
void us_lqps(unsigned int pu, long *q) { q[pu] = 5; }
void us_lqpv(unsigned int pu, long *q) { q[pu] = gl; }
long us_lqpr(unsigned int pu, long *q) { return q[pu]; }
void us_lqpa(unsigned int pu, long *q) { q[pu] += 3; }
void us_lgls(unsigned int pu, long *q) { unsigned int u = ju; v0(); glp[u] = 5; }
void us_lglv(unsigned int pu, long *q) { unsigned int u = ju; v0(); glp[u] = gl; }
long us_lglr(unsigned int pu, long *q) { unsigned int u = ju; v0(); return glp[u]; }
void us_lgla(unsigned int pu, long *q) { unsigned int u = ju; v0(); glp[u] += 3; }
void us_lggs(unsigned int pu, long *q) { glp[ju] = 5; }
void us_lggv(unsigned int pu, long *q) { glp[ju] = gl; }
long us_lggr(unsigned int pu, long *q) { return glp[ju]; }
void us_lgga(unsigned int pu, long *q) { glp[ju] += 3; }
void us_lgps(unsigned int pu, long *q) { glp[pu] = 5; }
void us_lgpv(unsigned int pu, long *q) { glp[pu] = gl; }
long us_lgpr(unsigned int pu, long *q) { return glp[pu]; }
void us_lgpa(unsigned int pu, long *q) { glp[pu] += 3; }
void us_llls(unsigned int pu, long *q) { long *w = glp; unsigned int u = ju; v0(); w[u] = 5; }
void us_lllv(unsigned int pu, long *q) { long *w = glp; unsigned int u = ju; v0(); w[u] = gl; }
long us_lllr(unsigned int pu, long *q) { long *w = glp; unsigned int u = ju; v0(); return w[u]; }
void us_llla(unsigned int pu, long *q) { long *w = glp; unsigned int u = ju; v0(); w[u] += 3; }
void us_llgs(unsigned int pu, long *q) { long *w = glp; v0(); w[ju] = 5; }
void us_llgv(unsigned int pu, long *q) { long *w = glp; v0(); w[ju] = gl; }
long us_llgr(unsigned int pu, long *q) { long *w = glp; v0(); return w[ju]; }
void us_llga(unsigned int pu, long *q) { long *w = glp; v0(); w[ju] += 3; }
void us_llps(unsigned int pu, long *q) { long *w = glp; v0(); w[pu] = 5; }
void us_llpv(unsigned int pu, long *q) { long *w = glp; v0(); w[pu] = gl; }
long us_llpr(unsigned int pu, long *q) { long *w = glp; v0(); return w[pu]; }
void us_llpa(unsigned int pu, long *q) { long *w = glp; v0(); w[pu] += 3; }
