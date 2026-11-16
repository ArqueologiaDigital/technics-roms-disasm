/* lane_nm probe: char pointer + int, the extz and the lda forms; see gen_psum.py for the name letters */
extern char *gp, *gp2;
extern int gi;
extern void vp(char *);
extern void v0(void);
void ps_qba(int b, unsigned int ub, char cb, long lb, char *q) { vp(q + b); }
char * ps_qbr(int b, unsigned int ub, char cb, long lb, char *q) { return q + b; }
void ps_qbs(int b, unsigned int ub, char cb, long lb, char *q) { gp2 = q + b; }
void ps_qbi(int b, unsigned int ub, char cb, long lb, char *q) { { char *w = q + b; vp(w); } }
void ps_qbd(int b, unsigned int ub, char cb, long lb, char *q) { *(q + b) = 5; }
void ps_qua(int b, unsigned int ub, char cb, long lb, char *q) { vp(q + ub); }
char * ps_qur(int b, unsigned int ub, char cb, long lb, char *q) { return q + ub; }
void ps_qus(int b, unsigned int ub, char cb, long lb, char *q) { gp2 = q + ub; }
void ps_qui(int b, unsigned int ub, char cb, long lb, char *q) { { char *w = q + ub; vp(w); } }
void ps_qud(int b, unsigned int ub, char cb, long lb, char *q) { *(q + ub) = 5; }
void ps_qga(int b, unsigned int ub, char cb, long lb, char *q) { vp(q + gi); }
char * ps_qgr(int b, unsigned int ub, char cb, long lb, char *q) { return q + gi; }
void ps_qgs(int b, unsigned int ub, char cb, long lb, char *q) { gp2 = q + gi; }
void ps_qgi(int b, unsigned int ub, char cb, long lb, char *q) { { char *w = q + gi; vp(w); } }
void ps_qgd(int b, unsigned int ub, char cb, long lb, char *q) { *(q + gi) = 5; }
void ps_qla(int b, unsigned int ub, char cb, long lb, char *q) { int t = gi; v0(); vp(q + t); }
char * ps_qlr(int b, unsigned int ub, char cb, long lb, char *q) { int t = gi; v0(); return q + t; }
void ps_qls(int b, unsigned int ub, char cb, long lb, char *q) { int t = gi; v0(); gp2 = q + t; }
void ps_qli(int b, unsigned int ub, char cb, long lb, char *q) { int t = gi; v0(); { char *w = q + t; vp(w); } }
void ps_qld(int b, unsigned int ub, char cb, long lb, char *q) { int t = gi; v0(); *(q + t) = 5; }
void ps_qka(int b, unsigned int ub, char cb, long lb, char *q) { int t = b + 1; v0(); vp(q + t); }
char * ps_qkr(int b, unsigned int ub, char cb, long lb, char *q) { int t = b + 1; v0(); return q + t; }
void ps_qks(int b, unsigned int ub, char cb, long lb, char *q) { int t = b + 1; v0(); gp2 = q + t; }
void ps_qki(int b, unsigned int ub, char cb, long lb, char *q) { int t = b + 1; v0(); { char *w = q + t; vp(w); } }
void ps_qkd(int b, unsigned int ub, char cb, long lb, char *q) { int t = b + 1; v0(); *(q + t) = 5; }
void ps_qca(int b, unsigned int ub, char cb, long lb, char *q) { vp(q + cb); }
char * ps_qcr(int b, unsigned int ub, char cb, long lb, char *q) { return q + cb; }
void ps_qcs(int b, unsigned int ub, char cb, long lb, char *q) { gp2 = q + cb; }
void ps_qci(int b, unsigned int ub, char cb, long lb, char *q) { { char *w = q + cb; vp(w); } }
void ps_qcd(int b, unsigned int ub, char cb, long lb, char *q) { *(q + cb) = 5; }
void ps_qxa(int b, unsigned int ub, char cb, long lb, char *q) { vp(q + lb); }
char * ps_qxr(int b, unsigned int ub, char cb, long lb, char *q) { return q + lb; }
void ps_qxs(int b, unsigned int ub, char cb, long lb, char *q) { gp2 = q + lb; }
void ps_qxi(int b, unsigned int ub, char cb, long lb, char *q) { { char *w = q + lb; vp(w); } }
void ps_qxd(int b, unsigned int ub, char cb, long lb, char *q) { *(q + lb) = 5; }
void ps_gba(int b, unsigned int ub, char cb, long lb, char *q) { vp(gp + b); }
char * ps_gbr(int b, unsigned int ub, char cb, long lb, char *q) { return gp + b; }
void ps_gbs(int b, unsigned int ub, char cb, long lb, char *q) { gp2 = gp + b; }
void ps_gbi(int b, unsigned int ub, char cb, long lb, char *q) { { char *w = gp + b; vp(w); } }
void ps_gbd(int b, unsigned int ub, char cb, long lb, char *q) { *(gp + b) = 5; }
void ps_gua(int b, unsigned int ub, char cb, long lb, char *q) { vp(gp + ub); }
char * ps_gur(int b, unsigned int ub, char cb, long lb, char *q) { return gp + ub; }
void ps_gus(int b, unsigned int ub, char cb, long lb, char *q) { gp2 = gp + ub; }
void ps_gui(int b, unsigned int ub, char cb, long lb, char *q) { { char *w = gp + ub; vp(w); } }
void ps_gud(int b, unsigned int ub, char cb, long lb, char *q) { *(gp + ub) = 5; }
void ps_gga(int b, unsigned int ub, char cb, long lb, char *q) { vp(gp + gi); }
char * ps_ggr(int b, unsigned int ub, char cb, long lb, char *q) { return gp + gi; }
void ps_ggs(int b, unsigned int ub, char cb, long lb, char *q) { gp2 = gp + gi; }
void ps_ggi(int b, unsigned int ub, char cb, long lb, char *q) { { char *w = gp + gi; vp(w); } }
void ps_ggd(int b, unsigned int ub, char cb, long lb, char *q) { *(gp + gi) = 5; }
void ps_gla(int b, unsigned int ub, char cb, long lb, char *q) { int t = gi; v0(); vp(gp + t); }
char * ps_glr(int b, unsigned int ub, char cb, long lb, char *q) { int t = gi; v0(); return gp + t; }
void ps_gls(int b, unsigned int ub, char cb, long lb, char *q) { int t = gi; v0(); gp2 = gp + t; }
void ps_gli(int b, unsigned int ub, char cb, long lb, char *q) { int t = gi; v0(); { char *w = gp + t; vp(w); } }
void ps_gld(int b, unsigned int ub, char cb, long lb, char *q) { int t = gi; v0(); *(gp + t) = 5; }
void ps_gka(int b, unsigned int ub, char cb, long lb, char *q) { int t = b + 1; v0(); vp(gp + t); }
char * ps_gkr(int b, unsigned int ub, char cb, long lb, char *q) { int t = b + 1; v0(); return gp + t; }
void ps_gks(int b, unsigned int ub, char cb, long lb, char *q) { int t = b + 1; v0(); gp2 = gp + t; }
void ps_gki(int b, unsigned int ub, char cb, long lb, char *q) { int t = b + 1; v0(); { char *w = gp + t; vp(w); } }
void ps_gkd(int b, unsigned int ub, char cb, long lb, char *q) { int t = b + 1; v0(); *(gp + t) = 5; }
void ps_gca(int b, unsigned int ub, char cb, long lb, char *q) { vp(gp + cb); }
char * ps_gcr(int b, unsigned int ub, char cb, long lb, char *q) { return gp + cb; }
void ps_gcs(int b, unsigned int ub, char cb, long lb, char *q) { gp2 = gp + cb; }
void ps_gci(int b, unsigned int ub, char cb, long lb, char *q) { { char *w = gp + cb; vp(w); } }
void ps_gcd(int b, unsigned int ub, char cb, long lb, char *q) { *(gp + cb) = 5; }
void ps_gxa(int b, unsigned int ub, char cb, long lb, char *q) { vp(gp + lb); }
char * ps_gxr(int b, unsigned int ub, char cb, long lb, char *q) { return gp + lb; }
void ps_gxs(int b, unsigned int ub, char cb, long lb, char *q) { gp2 = gp + lb; }
void ps_gxi(int b, unsigned int ub, char cb, long lb, char *q) { { char *w = gp + lb; vp(w); } }
void ps_gxd(int b, unsigned int ub, char cb, long lb, char *q) { *(gp + lb) = 5; }
void ps_lba(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); vp(u + b); }
char * ps_lbr(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); return u + b; }
void ps_lbs(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); gp2 = u + b; }
void ps_lbi(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); { char *w = u + b; vp(w); } }
void ps_lbd(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); *(u + b) = 5; }
void ps_lua(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); vp(u + ub); }
char * ps_lur(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); return u + ub; }
void ps_lus(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); gp2 = u + ub; }
void ps_lui(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); { char *w = u + ub; vp(w); } }
void ps_lud(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); *(u + ub) = 5; }
void ps_lga(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); vp(u + gi); }
char * ps_lgr(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); return u + gi; }
void ps_lgs(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); gp2 = u + gi; }
void ps_lgi(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); { char *w = u + gi; vp(w); } }
void ps_lgd(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); *(u + gi) = 5; }
void ps_lla(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; int t = gi; v0(); vp(u + t); }
char * ps_llr(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; int t = gi; v0(); return u + t; }
void ps_lls(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; int t = gi; v0(); gp2 = u + t; }
void ps_lli(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; int t = gi; v0(); { char *w = u + t; vp(w); } }
void ps_lld(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; int t = gi; v0(); *(u + t) = 5; }
void ps_lka(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; int t = b + 1; v0(); vp(u + t); }
char * ps_lkr(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; int t = b + 1; v0(); return u + t; }
void ps_lks(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; int t = b + 1; v0(); gp2 = u + t; }
void ps_lki(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; int t = b + 1; v0(); { char *w = u + t; vp(w); } }
void ps_lkd(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; int t = b + 1; v0(); *(u + t) = 5; }
void ps_lca(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); vp(u + cb); }
char * ps_lcr(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); return u + cb; }
void ps_lcs(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); gp2 = u + cb; }
void ps_lci(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); { char *w = u + cb; vp(w); } }
void ps_lcd(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); *(u + cb) = 5; }
void ps_lxa(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); vp(u + lb); }
char * ps_lxr(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); return u + lb; }
void ps_lxs(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); gp2 = u + lb; }
void ps_lxi(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); { char *w = u + lb; vp(w); } }
void ps_lxd(int b, unsigned int ub, char cb, long lb, char *q) { char *u = gp; v0(); *(u + lb) = 5; }
void ps_mba(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); vp(u + b); }
char * ps_mbr(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); return u + b; }
void ps_mbs(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); gp2 = u + b; }
void ps_mbi(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); { char *w = u + b; vp(w); } }
void ps_mbd(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); *(u + b) = 5; }
void ps_mua(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); vp(u + ub); }
char * ps_mur(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); return u + ub; }
void ps_mus(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); gp2 = u + ub; }
void ps_mui(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); { char *w = u + ub; vp(w); } }
void ps_mud(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); *(u + ub) = 5; }
void ps_mga(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); vp(u + gi); }
char * ps_mgr(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); return u + gi; }
void ps_mgs(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); gp2 = u + gi; }
void ps_mgi(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); { char *w = u + gi; vp(w); } }
void ps_mgd(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); *(u + gi) = 5; }
void ps_mla(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; int t = gi; v0(); vp(u + t); }
char * ps_mlr(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; int t = gi; v0(); return u + t; }
void ps_mls(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; int t = gi; v0(); gp2 = u + t; }
void ps_mli(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; int t = gi; v0(); { char *w = u + t; vp(w); } }
void ps_mld(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; int t = gi; v0(); *(u + t) = 5; }
void ps_mka(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; int t = b + 1; v0(); vp(u + t); }
char * ps_mkr(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; int t = b + 1; v0(); return u + t; }
void ps_mks(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; int t = b + 1; v0(); gp2 = u + t; }
void ps_mki(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; int t = b + 1; v0(); { char *w = u + t; vp(w); } }
void ps_mkd(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; int t = b + 1; v0(); *(u + t) = 5; }
void ps_mca(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); vp(u + cb); }
char * ps_mcr(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); return u + cb; }
void ps_mcs(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); gp2 = u + cb; }
void ps_mci(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); { char *w = u + cb; vp(w); } }
void ps_mcd(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); *(u + cb) = 5; }
void ps_mxa(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); vp(u + lb); }
char * ps_mxr(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); return u + lb; }
void ps_mxs(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); gp2 = u + lb; }
void ps_mxi(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); { char *w = u + lb; vp(w); } }
void ps_mxd(int b, unsigned int ub, char cb, long lb, char *q) { char *u = q; v0(); *(u + lb) = 5; }
