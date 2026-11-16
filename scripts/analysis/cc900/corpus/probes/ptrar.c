/* lane_nm wrong-code probe: pointer arithmetic, differences, comparisons, walks, pointers to pointers,
   arrays of pointers, function pointers; see gen_ptrar.py for the name letters */
struct s3 { char a[3]; };
struct s10 { int a[5]; };
struct pv { char *pc; int *pi; long *pl; struct s3 *px; struct s10 *ps; };
extern struct pv *gps;
extern int gi;
extern char gcu[], *gcp, *gcp2, **gcpp, *gcpa[4];
extern int giu[], *gip, *gip2, **gipp, *gipa[4];
extern long glu[], *glp, *glp2, **glpp, *glpa[4];
extern struct s3 gxu[], *gxp, *gxp2, **gxpp, *gxpa[4];
extern struct s10 gsu[], *gsp, *gsp2, **gspp, *gspa[4];
struct fs { int (*fi)(int); long (*fl)(long, long); void (*fv)(void); char (*fc)(char); };
extern struct fs gfs, *gpfs;
extern int (*gfa[4])(int);
extern long (*gfl[4])(long);
extern int (*gfp)(int);
extern int fi1(int);
char * pa_cgka(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp + 3; }
char * pa_cgks(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp - 3; }
char pa_cgkr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcp + 3); }
void pa_cgkw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gcp - 3) = 5; }
void pa_cgki(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = gcp + 3; }
char * pa_cgKa(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp + 0x8001u; }
char * pa_cgKs(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp - 0x8001u; }
char pa_cgKr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcp + 0x8001u); }
void pa_cgKw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gcp - 0x8001u) = 5; }
void pa_cgKi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = gcp + 0x8001u; }
char * pa_cgLa(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp + 0x12345L; }
char * pa_cgLs(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp - 0x12345L; }
char pa_cgLr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcp + 0x12345L); }
void pa_cgLw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gcp - 0x12345L) = 5; }
void pa_cgLi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = gcp + 0x12345L; }
char * pa_cgna(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp + -2; }
char * pa_cgns(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp - -2; }
char pa_cgnr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcp + -2); }
void pa_cgnw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gcp - -2) = 5; }
void pa_cgni(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = gcp + -2; }
char * pa_cgpa(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp + b; }
char * pa_cgps(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp - b; }
char pa_cgpr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcp + b); }
void pa_cgpw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gcp - b) = 5; }
void pa_cgpi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = gcp + b; }
char * pa_cgua(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp + ub; }
char * pa_cgus(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp - ub; }
char pa_cgur(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcp + ub); }
void pa_cguw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gcp - ub) = 5; }
void pa_cgui(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = gcp + ub; }
char * pa_cgca(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp + cb; }
char * pa_cgcs(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp - cb; }
char pa_cgcr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcp + cb); }
void pa_cgcw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gcp - cb) = 5; }
void pa_cgci(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = gcp + cb; }
char * pa_cgla(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp + lb; }
char * pa_cgls(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp - lb; }
char pa_cglr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcp + lb); }
void pa_cglw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gcp - lb) = 5; }
void pa_cgli(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = gcp + lb; }
char * pa_cgga(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp + gi; }
char * pa_cggs(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp - gi; }
char pa_cggr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcp + gi); }
void pa_cggw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gcp - gi) = 5; }
void pa_cggi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = gcp + gi; }
char * pa_cgea(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp + (b + 1); }
char * pa_cges(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp - (b + 1); }
char pa_cger(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcp + (b + 1)); }
void pa_cgew(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gcp - (b + 1)) = 5; }
void pa_cgei(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = gcp + (b + 1); }
char * pa_cqka(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q + 3; }
char * pa_cqks(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q - 3; }
char pa_cqkr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(q + 3); }
void pa_cqkw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(q - 3) = 5; }
void pa_cqki(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = q + 3; }
char * pa_cqKa(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q + 0x8001u; }
char * pa_cqKs(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q - 0x8001u; }
char pa_cqKr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(q + 0x8001u); }
void pa_cqKw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(q - 0x8001u) = 5; }
void pa_cqKi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = q + 0x8001u; }
char * pa_cqLa(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q + 0x12345L; }
char * pa_cqLs(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q - 0x12345L; }
char pa_cqLr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(q + 0x12345L); }
void pa_cqLw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(q - 0x12345L) = 5; }
void pa_cqLi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = q + 0x12345L; }
char * pa_cqna(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q + -2; }
char * pa_cqns(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q - -2; }
char pa_cqnr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(q + -2); }
void pa_cqnw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(q - -2) = 5; }
void pa_cqni(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = q + -2; }
char * pa_cqpa(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q + b; }
char * pa_cqps(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q - b; }
char pa_cqpr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(q + b); }
void pa_cqpw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(q - b) = 5; }
void pa_cqpi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = q + b; }
char * pa_cqua(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q + ub; }
char * pa_cqus(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q - ub; }
char pa_cqur(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(q + ub); }
void pa_cquw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(q - ub) = 5; }
void pa_cqui(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = q + ub; }
char * pa_cqca(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q + cb; }
char * pa_cqcs(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q - cb; }
char pa_cqcr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(q + cb); }
void pa_cqcw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(q - cb) = 5; }
void pa_cqci(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = q + cb; }
char * pa_cqla(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q + lb; }
char * pa_cqls(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q - lb; }
char pa_cqlr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(q + lb); }
void pa_cqlw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(q - lb) = 5; }
void pa_cqli(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = q + lb; }
char * pa_cqga(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q + gi; }
char * pa_cqgs(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q - gi; }
char pa_cqgr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(q + gi); }
void pa_cqgw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(q - gi) = 5; }
void pa_cqgi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = q + gi; }
char * pa_cqea(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q + (b + 1); }
char * pa_cqes(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q - (b + 1); }
char pa_cqer(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(q + (b + 1)); }
void pa_cqew(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(q - (b + 1)) = 5; }
void pa_cqei(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcp2 = q + (b + 1); }
char * pa_cuka(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcu + 3; }
char pa_cukr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcu + 3); }
char * pa_cuKa(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcu + 0x8001u; }
char pa_cuKr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcu + 0x8001u); }
char * pa_cuLa(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcu + 0x12345L; }
char pa_cuLr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcu + 0x12345L); }
char * pa_cuns(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcu - -2; }
void pa_cunw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gcu - -2) = 5; }
char * pa_cupa(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcu + b; }
char * pa_cups(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcu - b; }
char pa_cupr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcu + b); }
void pa_cupw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gcu - b) = 5; }
char * pa_cuua(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcu + ub; }
char * pa_cuus(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcu - ub; }
char pa_cuur(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcu + ub); }
void pa_cuuw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gcu - ub) = 5; }
char * pa_cuca(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcu + cb; }
char * pa_cucs(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcu - cb; }
char pa_cucr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcu + cb); }
void pa_cucw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gcu - cb) = 5; }
char * pa_cula(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcu + lb; }
char * pa_culs(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcu - lb; }
char pa_culr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcu + lb); }
void pa_culw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gcu - lb) = 5; }
char * pa_cuga(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcu + gi; }
char * pa_cugs(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcu - gi; }
char pa_cugr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcu + gi); }
void pa_cugw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gcu - gi) = 5; }
char * pa_cuea(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcu + (b + 1); }
char * pa_cues(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcu - (b + 1); }
char pa_cuer(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcu + (b + 1)); }
void pa_cuew(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gcu - (b + 1)) = 5; }
char * pa_caka(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[2] + 3; }
char pa_cakr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(&gcu[2] + 3); }
char * pa_caKa(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[2] + 0x8001u; }
char pa_caKr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(&gcu[2] + 0x8001u); }
char * pa_caLa(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[2] + 0x12345L; }
char pa_caLr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(&gcu[2] + 0x12345L); }
char * pa_cana(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[2] + -2; }
char * pa_cans(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[2] - -2; }
char pa_canr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(&gcu[2] + -2); }
void pa_canw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(&gcu[2] - -2) = 5; }
char * pa_capa(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[2] + b; }
char * pa_caps(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[2] - b; }
char pa_capr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(&gcu[2] + b); }
void pa_capw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(&gcu[2] - b) = 5; }
char * pa_caua(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[2] + ub; }
char * pa_caus(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[2] - ub; }
char pa_caur(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(&gcu[2] + ub); }
void pa_cauw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(&gcu[2] - ub) = 5; }
char * pa_caca(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[2] + cb; }
char * pa_cacs(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[2] - cb; }
char pa_cacr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(&gcu[2] + cb); }
void pa_cacw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(&gcu[2] - cb) = 5; }
char * pa_cala(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[2] + lb; }
char * pa_cals(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[2] - lb; }
char pa_calr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(&gcu[2] + lb); }
void pa_calw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(&gcu[2] - lb) = 5; }
char * pa_caga(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[2] + gi; }
char * pa_cags(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[2] - gi; }
char pa_cagr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(&gcu[2] + gi); }
void pa_cagw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(&gcu[2] - gi) = 5; }
char * pa_caea(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[2] + (b + 1); }
char * pa_caes(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[2] - (b + 1); }
char pa_caer(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(&gcu[2] + (b + 1)); }
void pa_caew(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(&gcu[2] - (b + 1)) = 5; }
char * pa_cmka(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc + 3; }
char * pa_cmks(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc - 3; }
char pa_cmkr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gps->pc + 3); }
void pa_cmkw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gps->pc - 3) = 5; }
char * pa_cmKa(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc + 0x8001u; }
char * pa_cmKs(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc - 0x8001u; }
char pa_cmKr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gps->pc + 0x8001u); }
void pa_cmKw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gps->pc - 0x8001u) = 5; }
char * pa_cmLa(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc + 0x12345L; }
char * pa_cmLs(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc - 0x12345L; }
char pa_cmLr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gps->pc + 0x12345L); }
void pa_cmLw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gps->pc - 0x12345L) = 5; }
char * pa_cmna(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc + -2; }
char * pa_cmns(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc - -2; }
char pa_cmnr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gps->pc + -2); }
void pa_cmnw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gps->pc - -2) = 5; }
char * pa_cmpa(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc + b; }
char * pa_cmps(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc - b; }
char pa_cmpr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gps->pc + b); }
void pa_cmpw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gps->pc - b) = 5; }
char * pa_cmua(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc + ub; }
char * pa_cmus(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc - ub; }
char pa_cmur(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gps->pc + ub); }
void pa_cmuw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gps->pc - ub) = 5; }
char * pa_cmca(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc + cb; }
char * pa_cmcs(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc - cb; }
char pa_cmcr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gps->pc + cb); }
void pa_cmcw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gps->pc - cb) = 5; }
char * pa_cmla(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc + lb; }
char * pa_cmls(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc - lb; }
char pa_cmlr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gps->pc + lb); }
void pa_cmlw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gps->pc - lb) = 5; }
char * pa_cmga(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc + gi; }
char * pa_cmgs(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc - gi; }
char pa_cmgr(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gps->pc + gi); }
void pa_cmgw(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gps->pc - gi) = 5; }
char * pa_cmea(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc + (b + 1); }
char * pa_cmes(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gps->pc - (b + 1); }
char pa_cmer(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gps->pc + (b + 1)); }
void pa_cmew(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *(gps->pc - (b + 1)) = 5; }
int * pa_igka(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip + 3; }
int * pa_igks(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip - 3; }
int pa_igkr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gip + 3); }
void pa_igkw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gip - 3) = 5; }
void pa_igki(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = gip + 3; }
int * pa_igKa(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip + 0x8001u; }
int * pa_igKs(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip - 0x8001u; }
int pa_igKr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gip + 0x8001u); }
void pa_igKw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gip - 0x8001u) = 5; }
void pa_igKi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = gip + 0x8001u; }
int * pa_igLa(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip + 0x12345L; }
int * pa_igLs(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip - 0x12345L; }
int pa_igLr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gip + 0x12345L); }
void pa_igLw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gip - 0x12345L) = 5; }
void pa_igLi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = gip + 0x12345L; }
int * pa_igna(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip + -2; }
int * pa_igns(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip - -2; }
int pa_ignr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gip + -2); }
void pa_ignw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gip - -2) = 5; }
void pa_igni(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = gip + -2; }
int * pa_igpa(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip + b; }
int * pa_igps(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip - b; }
int pa_igpr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gip + b); }
void pa_igpw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gip - b) = 5; }
void pa_igpi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = gip + b; }
int * pa_igua(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip + ub; }
int * pa_igus(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip - ub; }
int pa_igur(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gip + ub); }
void pa_iguw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gip - ub) = 5; }
void pa_igui(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = gip + ub; }
int * pa_igca(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip + cb; }
int * pa_igcs(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip - cb; }
int pa_igcr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gip + cb); }
void pa_igcw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gip - cb) = 5; }
void pa_igci(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = gip + cb; }
int * pa_igla(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip + lb; }
int * pa_igls(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip - lb; }
int pa_iglr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gip + lb); }
void pa_iglw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gip - lb) = 5; }
void pa_igli(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = gip + lb; }
int * pa_igga(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip + gi; }
int * pa_iggs(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip - gi; }
int pa_iggr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gip + gi); }
void pa_iggw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gip - gi) = 5; }
void pa_iggi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = gip + gi; }
int * pa_igea(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip + (b + 1); }
int * pa_iges(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip - (b + 1); }
int pa_iger(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gip + (b + 1)); }
void pa_igew(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gip - (b + 1)) = 5; }
void pa_igei(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = gip + (b + 1); }
int * pa_iqka(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q + 3; }
int * pa_iqks(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q - 3; }
int pa_iqkr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(q + 3); }
void pa_iqkw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(q - 3) = 5; }
void pa_iqki(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = q + 3; }
int * pa_iqKa(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q + 0x8001u; }
int * pa_iqKs(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q - 0x8001u; }
int pa_iqKr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(q + 0x8001u); }
void pa_iqKw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(q - 0x8001u) = 5; }
void pa_iqKi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = q + 0x8001u; }
int * pa_iqLa(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q + 0x12345L; }
int * pa_iqLs(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q - 0x12345L; }
int pa_iqLr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(q + 0x12345L); }
void pa_iqLw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(q - 0x12345L) = 5; }
void pa_iqLi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = q + 0x12345L; }
int * pa_iqna(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q + -2; }
int * pa_iqns(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q - -2; }
int pa_iqnr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(q + -2); }
void pa_iqnw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(q - -2) = 5; }
void pa_iqni(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = q + -2; }
int * pa_iqpa(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q + b; }
int * pa_iqps(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q - b; }
int pa_iqpr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(q + b); }
void pa_iqpw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(q - b) = 5; }
void pa_iqpi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = q + b; }
int * pa_iqua(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q + ub; }
int * pa_iqus(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q - ub; }
int pa_iqur(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(q + ub); }
void pa_iquw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(q - ub) = 5; }
void pa_iqui(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = q + ub; }
int * pa_iqca(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q + cb; }
int * pa_iqcs(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q - cb; }
int pa_iqcr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(q + cb); }
void pa_iqcw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(q - cb) = 5; }
void pa_iqci(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = q + cb; }
int * pa_iqla(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q + lb; }
int * pa_iqls(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q - lb; }
int pa_iqlr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(q + lb); }
void pa_iqlw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(q - lb) = 5; }
void pa_iqli(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = q + lb; }
int * pa_iqga(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q + gi; }
int * pa_iqgs(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q - gi; }
int pa_iqgr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(q + gi); }
void pa_iqgw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(q - gi) = 5; }
void pa_iqgi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = q + gi; }
int * pa_iqea(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q + (b + 1); }
int * pa_iqes(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q - (b + 1); }
int pa_iqer(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(q + (b + 1)); }
void pa_iqew(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(q - (b + 1)) = 5; }
void pa_iqei(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gip2 = q + (b + 1); }
int * pa_iuka(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return giu + 3; }
int pa_iukr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(giu + 3); }
int * pa_iuKa(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return giu + 0x8001u; }
int pa_iuKr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(giu + 0x8001u); }
int * pa_iuLa(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return giu + 0x12345L; }
int pa_iuLr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(giu + 0x12345L); }
int * pa_iuns(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return giu - -2; }
void pa_iunw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(giu - -2) = 5; }
int * pa_iupa(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return giu + b; }
int * pa_iups(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return giu - b; }
int pa_iupr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(giu + b); }
void pa_iupw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(giu - b) = 5; }
int * pa_iuua(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return giu + ub; }
int * pa_iuus(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return giu - ub; }
int pa_iuur(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(giu + ub); }
void pa_iuuw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(giu - ub) = 5; }
int * pa_iuca(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return giu + cb; }
int * pa_iucs(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return giu - cb; }
int pa_iucr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(giu + cb); }
void pa_iucw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(giu - cb) = 5; }
int * pa_iula(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return giu + lb; }
int * pa_iuls(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return giu - lb; }
int pa_iulr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(giu + lb); }
void pa_iulw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(giu - lb) = 5; }
int * pa_iuga(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return giu + gi; }
int * pa_iugs(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return giu - gi; }
int pa_iugr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(giu + gi); }
void pa_iugw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(giu - gi) = 5; }
int * pa_iuea(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return giu + (b + 1); }
int * pa_iues(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return giu - (b + 1); }
int pa_iuer(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(giu + (b + 1)); }
void pa_iuew(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(giu - (b + 1)) = 5; }
int * pa_iaka(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[2] + 3; }
int pa_iakr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(&giu[2] + 3); }
int * pa_iaKa(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[2] + 0x8001u; }
int pa_iaKr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(&giu[2] + 0x8001u); }
int * pa_iaLa(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[2] + 0x12345L; }
int pa_iaLr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(&giu[2] + 0x12345L); }
int * pa_iana(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[2] + -2; }
int * pa_ians(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[2] - -2; }
int pa_ianr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(&giu[2] + -2); }
void pa_ianw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(&giu[2] - -2) = 5; }
int * pa_iapa(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[2] + b; }
int * pa_iaps(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[2] - b; }
int pa_iapr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(&giu[2] + b); }
void pa_iapw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(&giu[2] - b) = 5; }
int * pa_iaua(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[2] + ub; }
int * pa_iaus(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[2] - ub; }
int pa_iaur(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(&giu[2] + ub); }
void pa_iauw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(&giu[2] - ub) = 5; }
int * pa_iaca(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[2] + cb; }
int * pa_iacs(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[2] - cb; }
int pa_iacr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(&giu[2] + cb); }
void pa_iacw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(&giu[2] - cb) = 5; }
int * pa_iala(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[2] + lb; }
int * pa_ials(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[2] - lb; }
int pa_ialr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(&giu[2] + lb); }
void pa_ialw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(&giu[2] - lb) = 5; }
int * pa_iaga(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[2] + gi; }
int * pa_iags(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[2] - gi; }
int pa_iagr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(&giu[2] + gi); }
void pa_iagw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(&giu[2] - gi) = 5; }
int * pa_iaea(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[2] + (b + 1); }
int * pa_iaes(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[2] - (b + 1); }
int pa_iaer(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(&giu[2] + (b + 1)); }
void pa_iaew(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(&giu[2] - (b + 1)) = 5; }
int * pa_imka(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi + 3; }
int * pa_imks(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi - 3; }
int pa_imkr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gps->pi + 3); }
void pa_imkw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gps->pi - 3) = 5; }
int * pa_imKa(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi + 0x8001u; }
int * pa_imKs(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi - 0x8001u; }
int pa_imKr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gps->pi + 0x8001u); }
void pa_imKw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gps->pi - 0x8001u) = 5; }
int * pa_imLa(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi + 0x12345L; }
int * pa_imLs(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi - 0x12345L; }
int pa_imLr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gps->pi + 0x12345L); }
void pa_imLw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gps->pi - 0x12345L) = 5; }
int * pa_imna(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi + -2; }
int * pa_imns(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi - -2; }
int pa_imnr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gps->pi + -2); }
void pa_imnw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gps->pi - -2) = 5; }
int * pa_impa(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi + b; }
int * pa_imps(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi - b; }
int pa_impr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gps->pi + b); }
void pa_impw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gps->pi - b) = 5; }
int * pa_imua(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi + ub; }
int * pa_imus(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi - ub; }
int pa_imur(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gps->pi + ub); }
void pa_imuw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gps->pi - ub) = 5; }
int * pa_imca(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi + cb; }
int * pa_imcs(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi - cb; }
int pa_imcr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gps->pi + cb); }
void pa_imcw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gps->pi - cb) = 5; }
int * pa_imla(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi + lb; }
int * pa_imls(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi - lb; }
int pa_imlr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gps->pi + lb); }
void pa_imlw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gps->pi - lb) = 5; }
int * pa_imga(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi + gi; }
int * pa_imgs(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi - gi; }
int pa_imgr(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gps->pi + gi); }
void pa_imgw(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gps->pi - gi) = 5; }
int * pa_imea(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi + (b + 1); }
int * pa_imes(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gps->pi - (b + 1); }
int pa_imer(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gps->pi + (b + 1)); }
void pa_imew(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *(gps->pi - (b + 1)) = 5; }
long * pa_lgka(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp + 3; }
long * pa_lgks(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp - 3; }
long pa_lgkr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glp + 3); }
void pa_lgkw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(glp - 3) = 5; }
void pa_lgki(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = glp + 3; }
long * pa_lgKa(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp + 0x8001u; }
long * pa_lgKs(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp - 0x8001u; }
long pa_lgKr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glp + 0x8001u); }
void pa_lgKw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(glp - 0x8001u) = 5; }
void pa_lgKi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = glp + 0x8001u; }
long * pa_lgLa(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp + 0x12345L; }
long * pa_lgLs(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp - 0x12345L; }
long pa_lgLr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glp + 0x12345L); }
void pa_lgLw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(glp - 0x12345L) = 5; }
void pa_lgLi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = glp + 0x12345L; }
long * pa_lgna(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp + -2; }
long * pa_lgns(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp - -2; }
long pa_lgnr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glp + -2); }
void pa_lgnw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(glp - -2) = 5; }
void pa_lgni(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = glp + -2; }
long * pa_lgpa(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp + b; }
long * pa_lgps(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp - b; }
long pa_lgpr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glp + b); }
void pa_lgpw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(glp - b) = 5; }
void pa_lgpi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = glp + b; }
long * pa_lgua(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp + ub; }
long * pa_lgus(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp - ub; }
long pa_lgur(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glp + ub); }
void pa_lguw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(glp - ub) = 5; }
void pa_lgui(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = glp + ub; }
long * pa_lgca(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp + cb; }
long * pa_lgcs(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp - cb; }
long pa_lgcr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glp + cb); }
void pa_lgcw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(glp - cb) = 5; }
void pa_lgci(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = glp + cb; }
long * pa_lgla(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp + lb; }
long * pa_lgls(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp - lb; }
long pa_lglr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glp + lb); }
void pa_lglw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(glp - lb) = 5; }
void pa_lgli(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = glp + lb; }
long * pa_lgga(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp + gi; }
long * pa_lggs(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp - gi; }
long pa_lggr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glp + gi); }
void pa_lggw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(glp - gi) = 5; }
void pa_lggi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = glp + gi; }
long * pa_lgea(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp + (b + 1); }
long * pa_lges(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp - (b + 1); }
long pa_lger(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glp + (b + 1)); }
void pa_lgew(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(glp - (b + 1)) = 5; }
void pa_lgei(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = glp + (b + 1); }
long * pa_lqka(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q + 3; }
long * pa_lqks(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q - 3; }
long pa_lqkr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(q + 3); }
void pa_lqkw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(q - 3) = 5; }
void pa_lqki(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = q + 3; }
long * pa_lqKa(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q + 0x8001u; }
long * pa_lqKs(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q - 0x8001u; }
long pa_lqKr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(q + 0x8001u); }
void pa_lqKw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(q - 0x8001u) = 5; }
void pa_lqKi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = q + 0x8001u; }
long * pa_lqLa(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q + 0x12345L; }
long * pa_lqLs(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q - 0x12345L; }
long pa_lqLr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(q + 0x12345L); }
void pa_lqLw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(q - 0x12345L) = 5; }
void pa_lqLi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = q + 0x12345L; }
long * pa_lqna(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q + -2; }
long * pa_lqns(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q - -2; }
long pa_lqnr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(q + -2); }
void pa_lqnw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(q - -2) = 5; }
void pa_lqni(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = q + -2; }
long * pa_lqpa(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q + b; }
long * pa_lqps(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q - b; }
long pa_lqpr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(q + b); }
void pa_lqpw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(q - b) = 5; }
void pa_lqpi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = q + b; }
long * pa_lqua(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q + ub; }
long * pa_lqus(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q - ub; }
long pa_lqur(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(q + ub); }
void pa_lquw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(q - ub) = 5; }
void pa_lqui(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = q + ub; }
long * pa_lqca(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q + cb; }
long * pa_lqcs(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q - cb; }
long pa_lqcr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(q + cb); }
void pa_lqcw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(q - cb) = 5; }
void pa_lqci(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = q + cb; }
long * pa_lqla(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q + lb; }
long * pa_lqls(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q - lb; }
long pa_lqlr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(q + lb); }
void pa_lqlw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(q - lb) = 5; }
void pa_lqli(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = q + lb; }
long * pa_lqga(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q + gi; }
long * pa_lqgs(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q - gi; }
long pa_lqgr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(q + gi); }
void pa_lqgw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(q - gi) = 5; }
void pa_lqgi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = q + gi; }
long * pa_lqea(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q + (b + 1); }
long * pa_lqes(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q - (b + 1); }
long pa_lqer(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(q + (b + 1)); }
void pa_lqew(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(q - (b + 1)) = 5; }
void pa_lqei(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glp2 = q + (b + 1); }
long * pa_luka(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glu + 3; }
long pa_lukr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glu + 3); }
long * pa_luKa(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glu + 0x8001u; }
long pa_luKr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glu + 0x8001u); }
long * pa_luLa(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glu + 0x12345L; }
long pa_luLr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glu + 0x12345L); }
long * pa_luns(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glu - -2; }
void pa_lunw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(glu - -2) = 5; }
long * pa_lupa(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glu + b; }
long * pa_lups(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glu - b; }
long pa_lupr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glu + b); }
void pa_lupw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(glu - b) = 5; }
long * pa_luua(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glu + ub; }
long * pa_luus(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glu - ub; }
long pa_luur(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glu + ub); }
void pa_luuw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(glu - ub) = 5; }
long * pa_luca(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glu + cb; }
long * pa_lucs(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glu - cb; }
long pa_lucr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glu + cb); }
void pa_lucw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(glu - cb) = 5; }
long * pa_lula(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glu + lb; }
long * pa_luls(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glu - lb; }
long pa_lulr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glu + lb); }
void pa_lulw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(glu - lb) = 5; }
long * pa_luga(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glu + gi; }
long * pa_lugs(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glu - gi; }
long pa_lugr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glu + gi); }
void pa_lugw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(glu - gi) = 5; }
long * pa_luea(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glu + (b + 1); }
long * pa_lues(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glu - (b + 1); }
long pa_luer(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glu + (b + 1)); }
void pa_luew(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(glu - (b + 1)) = 5; }
long * pa_laka(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[2] + 3; }
long pa_lakr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(&glu[2] + 3); }
long * pa_laKa(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[2] + 0x8001u; }
long pa_laKr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(&glu[2] + 0x8001u); }
long * pa_laLa(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[2] + 0x12345L; }
long pa_laLr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(&glu[2] + 0x12345L); }
long * pa_lana(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[2] + -2; }
long * pa_lans(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[2] - -2; }
long pa_lanr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(&glu[2] + -2); }
void pa_lanw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(&glu[2] - -2) = 5; }
long * pa_lapa(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[2] + b; }
long * pa_laps(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[2] - b; }
long pa_lapr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(&glu[2] + b); }
void pa_lapw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(&glu[2] - b) = 5; }
long * pa_laua(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[2] + ub; }
long * pa_laus(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[2] - ub; }
long pa_laur(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(&glu[2] + ub); }
void pa_lauw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(&glu[2] - ub) = 5; }
long * pa_laca(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[2] + cb; }
long * pa_lacs(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[2] - cb; }
long pa_lacr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(&glu[2] + cb); }
void pa_lacw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(&glu[2] - cb) = 5; }
long * pa_lala(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[2] + lb; }
long * pa_lals(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[2] - lb; }
long pa_lalr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(&glu[2] + lb); }
void pa_lalw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(&glu[2] - lb) = 5; }
long * pa_laga(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[2] + gi; }
long * pa_lags(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[2] - gi; }
long pa_lagr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(&glu[2] + gi); }
void pa_lagw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(&glu[2] - gi) = 5; }
long * pa_laea(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[2] + (b + 1); }
long * pa_laes(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[2] - (b + 1); }
long pa_laer(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(&glu[2] + (b + 1)); }
void pa_laew(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(&glu[2] - (b + 1)) = 5; }
long * pa_lmka(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl + 3; }
long * pa_lmks(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl - 3; }
long pa_lmkr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(gps->pl + 3); }
void pa_lmkw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(gps->pl - 3) = 5; }
long * pa_lmKa(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl + 0x8001u; }
long * pa_lmKs(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl - 0x8001u; }
long pa_lmKr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(gps->pl + 0x8001u); }
void pa_lmKw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(gps->pl - 0x8001u) = 5; }
long * pa_lmLa(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl + 0x12345L; }
long * pa_lmLs(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl - 0x12345L; }
long pa_lmLr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(gps->pl + 0x12345L); }
void pa_lmLw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(gps->pl - 0x12345L) = 5; }
long * pa_lmna(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl + -2; }
long * pa_lmns(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl - -2; }
long pa_lmnr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(gps->pl + -2); }
void pa_lmnw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(gps->pl - -2) = 5; }
long * pa_lmpa(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl + b; }
long * pa_lmps(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl - b; }
long pa_lmpr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(gps->pl + b); }
void pa_lmpw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(gps->pl - b) = 5; }
long * pa_lmua(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl + ub; }
long * pa_lmus(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl - ub; }
long pa_lmur(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(gps->pl + ub); }
void pa_lmuw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(gps->pl - ub) = 5; }
long * pa_lmca(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl + cb; }
long * pa_lmcs(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl - cb; }
long pa_lmcr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(gps->pl + cb); }
void pa_lmcw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(gps->pl - cb) = 5; }
long * pa_lmla(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl + lb; }
long * pa_lmls(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl - lb; }
long pa_lmlr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(gps->pl + lb); }
void pa_lmlw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(gps->pl - lb) = 5; }
long * pa_lmga(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl + gi; }
long * pa_lmgs(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl - gi; }
long pa_lmgr(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(gps->pl + gi); }
void pa_lmgw(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(gps->pl - gi) = 5; }
long * pa_lmea(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl + (b + 1); }
long * pa_lmes(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return gps->pl - (b + 1); }
long pa_lmer(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(gps->pl + (b + 1)); }
void pa_lmew(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *(gps->pl - (b + 1)) = 5; }
struct s3 * pa_xgka(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp + 3; }
struct s3 * pa_xgks(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp - 3; }
char pa_xgkr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp + 3)->a[1]; }
void pa_xgkw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxp - 3)->a[1] = 5; }
void pa_xgki(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = gxp + 3; }
struct s3 * pa_xgKa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp + 0x8001u; }
struct s3 * pa_xgKs(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp - 0x8001u; }
char pa_xgKr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp + 0x8001u)->a[1]; }
void pa_xgKw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxp - 0x8001u)->a[1] = 5; }
void pa_xgKi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = gxp + 0x8001u; }
struct s3 * pa_xgLa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp + 0x12345L; }
struct s3 * pa_xgLs(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp - 0x12345L; }
char pa_xgLr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp + 0x12345L)->a[1]; }
void pa_xgLw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxp - 0x12345L)->a[1] = 5; }
void pa_xgLi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = gxp + 0x12345L; }
struct s3 * pa_xgna(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp + -2; }
struct s3 * pa_xgns(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp - -2; }
char pa_xgnr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp + -2)->a[1]; }
void pa_xgnw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxp - -2)->a[1] = 5; }
void pa_xgni(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = gxp + -2; }
struct s3 * pa_xgpa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp + b; }
struct s3 * pa_xgps(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp - b; }
char pa_xgpr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp + b)->a[1]; }
void pa_xgpw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxp - b)->a[1] = 5; }
void pa_xgpi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = gxp + b; }
struct s3 * pa_xgua(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp + ub; }
struct s3 * pa_xgus(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp - ub; }
char pa_xgur(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp + ub)->a[1]; }
void pa_xguw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxp - ub)->a[1] = 5; }
void pa_xgui(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = gxp + ub; }
struct s3 * pa_xgca(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp + cb; }
struct s3 * pa_xgcs(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp - cb; }
char pa_xgcr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp + cb)->a[1]; }
void pa_xgcw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxp - cb)->a[1] = 5; }
void pa_xgci(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = gxp + cb; }
struct s3 * pa_xgla(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp + lb; }
struct s3 * pa_xgls(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp - lb; }
char pa_xglr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp + lb)->a[1]; }
void pa_xglw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxp - lb)->a[1] = 5; }
void pa_xgli(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = gxp + lb; }
struct s3 * pa_xgga(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp + gi; }
struct s3 * pa_xggs(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp - gi; }
char pa_xggr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp + gi)->a[1]; }
void pa_xggw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxp - gi)->a[1] = 5; }
void pa_xggi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = gxp + gi; }
struct s3 * pa_xgea(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp + (b + 1); }
struct s3 * pa_xges(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp - (b + 1); }
char pa_xger(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp + (b + 1))->a[1]; }
void pa_xgew(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxp - (b + 1))->a[1] = 5; }
void pa_xgei(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = gxp + (b + 1); }
struct s3 * pa_xqka(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q + 3; }
struct s3 * pa_xqks(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q - 3; }
char pa_xqkr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q + 3)->a[1]; }
void pa_xqkw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (q - 3)->a[1] = 5; }
void pa_xqki(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = q + 3; }
struct s3 * pa_xqKa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q + 0x8001u; }
struct s3 * pa_xqKs(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q - 0x8001u; }
char pa_xqKr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q + 0x8001u)->a[1]; }
void pa_xqKw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (q - 0x8001u)->a[1] = 5; }
void pa_xqKi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = q + 0x8001u; }
struct s3 * pa_xqLa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q + 0x12345L; }
struct s3 * pa_xqLs(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q - 0x12345L; }
char pa_xqLr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q + 0x12345L)->a[1]; }
void pa_xqLw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (q - 0x12345L)->a[1] = 5; }
void pa_xqLi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = q + 0x12345L; }
struct s3 * pa_xqna(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q + -2; }
struct s3 * pa_xqns(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q - -2; }
char pa_xqnr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q + -2)->a[1]; }
void pa_xqnw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (q - -2)->a[1] = 5; }
void pa_xqni(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = q + -2; }
struct s3 * pa_xqpa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q + b; }
struct s3 * pa_xqps(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q - b; }
char pa_xqpr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q + b)->a[1]; }
void pa_xqpw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (q - b)->a[1] = 5; }
void pa_xqpi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = q + b; }
struct s3 * pa_xqua(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q + ub; }
struct s3 * pa_xqus(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q - ub; }
char pa_xqur(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q + ub)->a[1]; }
void pa_xquw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (q - ub)->a[1] = 5; }
void pa_xqui(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = q + ub; }
struct s3 * pa_xqca(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q + cb; }
struct s3 * pa_xqcs(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q - cb; }
char pa_xqcr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q + cb)->a[1]; }
void pa_xqcw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (q - cb)->a[1] = 5; }
void pa_xqci(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = q + cb; }
struct s3 * pa_xqla(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q + lb; }
struct s3 * pa_xqls(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q - lb; }
char pa_xqlr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q + lb)->a[1]; }
void pa_xqlw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (q - lb)->a[1] = 5; }
void pa_xqli(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = q + lb; }
struct s3 * pa_xqga(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q + gi; }
struct s3 * pa_xqgs(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q - gi; }
char pa_xqgr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q + gi)->a[1]; }
void pa_xqgw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (q - gi)->a[1] = 5; }
void pa_xqgi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = q + gi; }
struct s3 * pa_xqea(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q + (b + 1); }
struct s3 * pa_xqes(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q - (b + 1); }
char pa_xqer(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q + (b + 1))->a[1]; }
void pa_xqew(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (q - (b + 1))->a[1] = 5; }
void pa_xqei(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxp2 = q + (b + 1); }
struct s3 * pa_xuka(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxu + 3; }
char pa_xukr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxu + 3)->a[1]; }
struct s3 * pa_xuKa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxu + 0x8001u; }
char pa_xuKr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxu + 0x8001u)->a[1]; }
struct s3 * pa_xuLa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxu + 0x12345L; }
char pa_xuLr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxu + 0x12345L)->a[1]; }
struct s3 * pa_xuns(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxu - -2; }
void pa_xunw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxu - -2)->a[1] = 5; }
struct s3 * pa_xupa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxu + b; }
struct s3 * pa_xups(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxu - b; }
char pa_xupr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxu + b)->a[1]; }
void pa_xupw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxu - b)->a[1] = 5; }
struct s3 * pa_xuua(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxu + ub; }
struct s3 * pa_xuus(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxu - ub; }
char pa_xuur(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxu + ub)->a[1]; }
void pa_xuuw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxu - ub)->a[1] = 5; }
struct s3 * pa_xuca(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxu + cb; }
struct s3 * pa_xucs(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxu - cb; }
char pa_xucr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxu + cb)->a[1]; }
void pa_xucw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxu - cb)->a[1] = 5; }
struct s3 * pa_xula(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxu + lb; }
struct s3 * pa_xuls(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxu - lb; }
char pa_xulr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxu + lb)->a[1]; }
void pa_xulw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxu - lb)->a[1] = 5; }
struct s3 * pa_xuga(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxu + gi; }
struct s3 * pa_xugs(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxu - gi; }
char pa_xugr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxu + gi)->a[1]; }
void pa_xugw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxu - gi)->a[1] = 5; }
struct s3 * pa_xuea(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxu + (b + 1); }
struct s3 * pa_xues(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxu - (b + 1); }
char pa_xuer(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxu + (b + 1))->a[1]; }
void pa_xuew(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxu - (b + 1))->a[1] = 5; }
struct s3 * pa_xaka(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[2] + 3; }
char pa_xakr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (&gxu[2] + 3)->a[1]; }
struct s3 * pa_xaKa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[2] + 0x8001u; }
char pa_xaKr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (&gxu[2] + 0x8001u)->a[1]; }
struct s3 * pa_xaLa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[2] + 0x12345L; }
char pa_xaLr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (&gxu[2] + 0x12345L)->a[1]; }
struct s3 * pa_xana(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[2] + -2; }
struct s3 * pa_xans(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[2] - -2; }
char pa_xanr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (&gxu[2] + -2)->a[1]; }
void pa_xanw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (&gxu[2] - -2)->a[1] = 5; }
struct s3 * pa_xapa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[2] + b; }
struct s3 * pa_xaps(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[2] - b; }
char pa_xapr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (&gxu[2] + b)->a[1]; }
void pa_xapw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (&gxu[2] - b)->a[1] = 5; }
struct s3 * pa_xaua(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[2] + ub; }
struct s3 * pa_xaus(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[2] - ub; }
char pa_xaur(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (&gxu[2] + ub)->a[1]; }
void pa_xauw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (&gxu[2] - ub)->a[1] = 5; }
struct s3 * pa_xaca(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[2] + cb; }
struct s3 * pa_xacs(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[2] - cb; }
char pa_xacr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (&gxu[2] + cb)->a[1]; }
void pa_xacw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (&gxu[2] - cb)->a[1] = 5; }
struct s3 * pa_xala(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[2] + lb; }
struct s3 * pa_xals(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[2] - lb; }
char pa_xalr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (&gxu[2] + lb)->a[1]; }
void pa_xalw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (&gxu[2] - lb)->a[1] = 5; }
struct s3 * pa_xaga(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[2] + gi; }
struct s3 * pa_xags(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[2] - gi; }
char pa_xagr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (&gxu[2] + gi)->a[1]; }
void pa_xagw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (&gxu[2] - gi)->a[1] = 5; }
struct s3 * pa_xaea(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[2] + (b + 1); }
struct s3 * pa_xaes(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[2] - (b + 1); }
char pa_xaer(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (&gxu[2] + (b + 1))->a[1]; }
void pa_xaew(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (&gxu[2] - (b + 1))->a[1] = 5; }
struct s3 * pa_xmka(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px + 3; }
struct s3 * pa_xmks(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px - 3; }
char pa_xmkr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gps->px + 3)->a[1]; }
void pa_xmkw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gps->px - 3)->a[1] = 5; }
struct s3 * pa_xmKa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px + 0x8001u; }
struct s3 * pa_xmKs(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px - 0x8001u; }
char pa_xmKr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gps->px + 0x8001u)->a[1]; }
void pa_xmKw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gps->px - 0x8001u)->a[1] = 5; }
struct s3 * pa_xmLa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px + 0x12345L; }
struct s3 * pa_xmLs(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px - 0x12345L; }
char pa_xmLr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gps->px + 0x12345L)->a[1]; }
void pa_xmLw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gps->px - 0x12345L)->a[1] = 5; }
struct s3 * pa_xmna(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px + -2; }
struct s3 * pa_xmns(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px - -2; }
char pa_xmnr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gps->px + -2)->a[1]; }
void pa_xmnw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gps->px - -2)->a[1] = 5; }
struct s3 * pa_xmpa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px + b; }
struct s3 * pa_xmps(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px - b; }
char pa_xmpr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gps->px + b)->a[1]; }
void pa_xmpw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gps->px - b)->a[1] = 5; }
struct s3 * pa_xmua(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px + ub; }
struct s3 * pa_xmus(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px - ub; }
char pa_xmur(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gps->px + ub)->a[1]; }
void pa_xmuw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gps->px - ub)->a[1] = 5; }
struct s3 * pa_xmca(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px + cb; }
struct s3 * pa_xmcs(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px - cb; }
char pa_xmcr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gps->px + cb)->a[1]; }
void pa_xmcw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gps->px - cb)->a[1] = 5; }
struct s3 * pa_xmla(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px + lb; }
struct s3 * pa_xmls(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px - lb; }
char pa_xmlr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gps->px + lb)->a[1]; }
void pa_xmlw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gps->px - lb)->a[1] = 5; }
struct s3 * pa_xmga(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px + gi; }
struct s3 * pa_xmgs(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px - gi; }
char pa_xmgr(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gps->px + gi)->a[1]; }
void pa_xmgw(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gps->px - gi)->a[1] = 5; }
struct s3 * pa_xmea(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px + (b + 1); }
struct s3 * pa_xmes(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gps->px - (b + 1); }
char pa_xmer(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gps->px + (b + 1))->a[1]; }
void pa_xmew(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gps->px - (b + 1))->a[1] = 5; }
struct s10 * pa_sgka(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp + 3; }
struct s10 * pa_sgks(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp - 3; }
int pa_sgkr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp + 3)->a[1]; }
void pa_sgkw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsp - 3)->a[1] = 5; }
void pa_sgki(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = gsp + 3; }
struct s10 * pa_sgKa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp + 0x8001u; }
struct s10 * pa_sgKs(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp - 0x8001u; }
int pa_sgKr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp + 0x8001u)->a[1]; }
void pa_sgKw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsp - 0x8001u)->a[1] = 5; }
void pa_sgKi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = gsp + 0x8001u; }
struct s10 * pa_sgLa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp + 0x12345L; }
struct s10 * pa_sgLs(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp - 0x12345L; }
int pa_sgLr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp + 0x12345L)->a[1]; }
void pa_sgLw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsp - 0x12345L)->a[1] = 5; }
void pa_sgLi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = gsp + 0x12345L; }
struct s10 * pa_sgna(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp + -2; }
struct s10 * pa_sgns(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp - -2; }
int pa_sgnr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp + -2)->a[1]; }
void pa_sgnw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsp - -2)->a[1] = 5; }
void pa_sgni(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = gsp + -2; }
struct s10 * pa_sgpa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp + b; }
struct s10 * pa_sgps(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp - b; }
int pa_sgpr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp + b)->a[1]; }
void pa_sgpw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsp - b)->a[1] = 5; }
void pa_sgpi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = gsp + b; }
struct s10 * pa_sgua(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp + ub; }
struct s10 * pa_sgus(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp - ub; }
int pa_sgur(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp + ub)->a[1]; }
void pa_sguw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsp - ub)->a[1] = 5; }
void pa_sgui(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = gsp + ub; }
struct s10 * pa_sgca(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp + cb; }
struct s10 * pa_sgcs(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp - cb; }
int pa_sgcr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp + cb)->a[1]; }
void pa_sgcw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsp - cb)->a[1] = 5; }
void pa_sgci(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = gsp + cb; }
struct s10 * pa_sgla(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp + lb; }
struct s10 * pa_sgls(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp - lb; }
int pa_sglr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp + lb)->a[1]; }
void pa_sglw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsp - lb)->a[1] = 5; }
void pa_sgli(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = gsp + lb; }
struct s10 * pa_sgga(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp + gi; }
struct s10 * pa_sggs(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp - gi; }
int pa_sggr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp + gi)->a[1]; }
void pa_sggw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsp - gi)->a[1] = 5; }
void pa_sggi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = gsp + gi; }
struct s10 * pa_sgea(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp + (b + 1); }
struct s10 * pa_sges(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp - (b + 1); }
int pa_sger(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp + (b + 1))->a[1]; }
void pa_sgew(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsp - (b + 1))->a[1] = 5; }
void pa_sgei(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = gsp + (b + 1); }
struct s10 * pa_sqka(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q + 3; }
struct s10 * pa_sqks(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q - 3; }
int pa_sqkr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q + 3)->a[1]; }
void pa_sqkw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (q - 3)->a[1] = 5; }
void pa_sqki(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = q + 3; }
struct s10 * pa_sqKa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q + 0x8001u; }
struct s10 * pa_sqKs(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q - 0x8001u; }
int pa_sqKr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q + 0x8001u)->a[1]; }
void pa_sqKw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (q - 0x8001u)->a[1] = 5; }
void pa_sqKi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = q + 0x8001u; }
struct s10 * pa_sqLa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q + 0x12345L; }
struct s10 * pa_sqLs(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q - 0x12345L; }
int pa_sqLr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q + 0x12345L)->a[1]; }
void pa_sqLw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (q - 0x12345L)->a[1] = 5; }
void pa_sqLi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = q + 0x12345L; }
struct s10 * pa_sqna(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q + -2; }
struct s10 * pa_sqns(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q - -2; }
int pa_sqnr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q + -2)->a[1]; }
void pa_sqnw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (q - -2)->a[1] = 5; }
void pa_sqni(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = q + -2; }
struct s10 * pa_sqpa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q + b; }
struct s10 * pa_sqps(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q - b; }
int pa_sqpr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q + b)->a[1]; }
void pa_sqpw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (q - b)->a[1] = 5; }
void pa_sqpi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = q + b; }
struct s10 * pa_squa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q + ub; }
struct s10 * pa_squs(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q - ub; }
int pa_squr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q + ub)->a[1]; }
void pa_squw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (q - ub)->a[1] = 5; }
void pa_squi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = q + ub; }
struct s10 * pa_sqca(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q + cb; }
struct s10 * pa_sqcs(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q - cb; }
int pa_sqcr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q + cb)->a[1]; }
void pa_sqcw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (q - cb)->a[1] = 5; }
void pa_sqci(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = q + cb; }
struct s10 * pa_sqla(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q + lb; }
struct s10 * pa_sqls(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q - lb; }
int pa_sqlr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q + lb)->a[1]; }
void pa_sqlw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (q - lb)->a[1] = 5; }
void pa_sqli(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = q + lb; }
struct s10 * pa_sqga(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q + gi; }
struct s10 * pa_sqgs(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q - gi; }
int pa_sqgr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q + gi)->a[1]; }
void pa_sqgw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (q - gi)->a[1] = 5; }
void pa_sqgi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = q + gi; }
struct s10 * pa_sqea(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q + (b + 1); }
struct s10 * pa_sqes(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q - (b + 1); }
int pa_sqer(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q + (b + 1))->a[1]; }
void pa_sqew(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (q - (b + 1))->a[1] = 5; }
void pa_sqei(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gsp2 = q + (b + 1); }
struct s10 * pa_suka(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsu + 3; }
int pa_sukr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsu + 3)->a[1]; }
struct s10 * pa_suKa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsu + 0x8001u; }
int pa_suKr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsu + 0x8001u)->a[1]; }
struct s10 * pa_suLa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsu + 0x12345L; }
int pa_suLr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsu + 0x12345L)->a[1]; }
struct s10 * pa_suns(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsu - -2; }
void pa_sunw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsu - -2)->a[1] = 5; }
struct s10 * pa_supa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsu + b; }
struct s10 * pa_sups(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsu - b; }
int pa_supr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsu + b)->a[1]; }
void pa_supw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsu - b)->a[1] = 5; }
struct s10 * pa_suua(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsu + ub; }
struct s10 * pa_suus(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsu - ub; }
int pa_suur(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsu + ub)->a[1]; }
void pa_suuw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsu - ub)->a[1] = 5; }
struct s10 * pa_suca(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsu + cb; }
struct s10 * pa_sucs(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsu - cb; }
int pa_sucr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsu + cb)->a[1]; }
void pa_sucw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsu - cb)->a[1] = 5; }
struct s10 * pa_sula(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsu + lb; }
struct s10 * pa_suls(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsu - lb; }
int pa_sulr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsu + lb)->a[1]; }
void pa_sulw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsu - lb)->a[1] = 5; }
struct s10 * pa_suga(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsu + gi; }
struct s10 * pa_sugs(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsu - gi; }
int pa_sugr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsu + gi)->a[1]; }
void pa_sugw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsu - gi)->a[1] = 5; }
struct s10 * pa_suea(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsu + (b + 1); }
struct s10 * pa_sues(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsu - (b + 1); }
int pa_suer(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsu + (b + 1))->a[1]; }
void pa_suew(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsu - (b + 1))->a[1] = 5; }
struct s10 * pa_saka(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[2] + 3; }
int pa_sakr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (&gsu[2] + 3)->a[1]; }
struct s10 * pa_saKa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[2] + 0x8001u; }
int pa_saKr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (&gsu[2] + 0x8001u)->a[1]; }
struct s10 * pa_saLa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[2] + 0x12345L; }
int pa_saLr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (&gsu[2] + 0x12345L)->a[1]; }
struct s10 * pa_sana(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[2] + -2; }
struct s10 * pa_sans(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[2] - -2; }
int pa_sanr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (&gsu[2] + -2)->a[1]; }
void pa_sanw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (&gsu[2] - -2)->a[1] = 5; }
struct s10 * pa_sapa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[2] + b; }
struct s10 * pa_saps(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[2] - b; }
int pa_sapr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (&gsu[2] + b)->a[1]; }
void pa_sapw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (&gsu[2] - b)->a[1] = 5; }
struct s10 * pa_saua(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[2] + ub; }
struct s10 * pa_saus(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[2] - ub; }
int pa_saur(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (&gsu[2] + ub)->a[1]; }
void pa_sauw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (&gsu[2] - ub)->a[1] = 5; }
struct s10 * pa_saca(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[2] + cb; }
struct s10 * pa_sacs(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[2] - cb; }
int pa_sacr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (&gsu[2] + cb)->a[1]; }
void pa_sacw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (&gsu[2] - cb)->a[1] = 5; }
struct s10 * pa_sala(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[2] + lb; }
struct s10 * pa_sals(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[2] - lb; }
int pa_salr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (&gsu[2] + lb)->a[1]; }
void pa_salw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (&gsu[2] - lb)->a[1] = 5; }
struct s10 * pa_saga(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[2] + gi; }
struct s10 * pa_sags(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[2] - gi; }
int pa_sagr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (&gsu[2] + gi)->a[1]; }
void pa_sagw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (&gsu[2] - gi)->a[1] = 5; }
struct s10 * pa_saea(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[2] + (b + 1); }
struct s10 * pa_saes(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[2] - (b + 1); }
int pa_saer(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (&gsu[2] + (b + 1))->a[1]; }
void pa_saew(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (&gsu[2] - (b + 1))->a[1] = 5; }
struct s10 * pa_smka(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps + 3; }
struct s10 * pa_smks(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps - 3; }
int pa_smkr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gps->ps + 3)->a[1]; }
void pa_smkw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gps->ps - 3)->a[1] = 5; }
struct s10 * pa_smKa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps + 0x8001u; }
struct s10 * pa_smKs(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps - 0x8001u; }
int pa_smKr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gps->ps + 0x8001u)->a[1]; }
void pa_smKw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gps->ps - 0x8001u)->a[1] = 5; }
struct s10 * pa_smLa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps + 0x12345L; }
struct s10 * pa_smLs(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps - 0x12345L; }
int pa_smLr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gps->ps + 0x12345L)->a[1]; }
void pa_smLw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gps->ps - 0x12345L)->a[1] = 5; }
struct s10 * pa_smna(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps + -2; }
struct s10 * pa_smns(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps - -2; }
int pa_smnr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gps->ps + -2)->a[1]; }
void pa_smnw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gps->ps - -2)->a[1] = 5; }
struct s10 * pa_smpa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps + b; }
struct s10 * pa_smps(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps - b; }
int pa_smpr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gps->ps + b)->a[1]; }
void pa_smpw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gps->ps - b)->a[1] = 5; }
struct s10 * pa_smua(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps + ub; }
struct s10 * pa_smus(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps - ub; }
int pa_smur(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gps->ps + ub)->a[1]; }
void pa_smuw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gps->ps - ub)->a[1] = 5; }
struct s10 * pa_smca(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps + cb; }
struct s10 * pa_smcs(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps - cb; }
int pa_smcr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gps->ps + cb)->a[1]; }
void pa_smcw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gps->ps - cb)->a[1] = 5; }
struct s10 * pa_smla(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps + lb; }
struct s10 * pa_smls(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps - lb; }
int pa_smlr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gps->ps + lb)->a[1]; }
void pa_smlw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gps->ps - lb)->a[1] = 5; }
struct s10 * pa_smga(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps + gi; }
struct s10 * pa_smgs(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps - gi; }
int pa_smgr(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gps->ps + gi)->a[1]; }
void pa_smgw(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gps->ps - gi)->a[1] = 5; }
struct s10 * pa_smea(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps + (b + 1); }
struct s10 * pa_smes(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gps->ps - (b + 1); }
int pa_smer(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gps->ps + (b + 1))->a[1]; }
void pa_smew(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gps->ps - (b + 1))->a[1] = 5; }
int pd_ca(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q - r; }
int pd_cb(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (gcu + b) - gcu; }
int pd_cc(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return &gcu[ub] - &gcu[b]; }
int pd_cd(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcp - gcp2; }
int pd_ce(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return q - gcp; }
long pd_cf(int b, unsigned int ub, char cb, long lb, char *q, char *r) { long d = r - q; return d; }
int pd_cg(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (q - r) > 0; }
int pd_ch(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (r - q) / 2; }
long pd_ci(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (gcu + lb) - gcu; }
int pd_ia(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q - r; }
int pd_ib(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (giu + b) - giu; }
int pd_ic(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return &giu[ub] - &giu[b]; }
int pd_id(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gip - gip2; }
int pd_ie(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return q - gip; }
long pd_if(int b, unsigned int ub, char cb, long lb, int *q, int *r) { long d = r - q; return d; }
int pd_ig(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (q - r) > 0; }
int pd_ih(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (r - q) / 2; }
long pd_ii(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (giu + lb) - giu; }
int pd_la(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q - r; }
int pd_lb(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (glu + b) - glu; }
int pd_lc(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return &glu[ub] - &glu[b]; }
int pd_ld(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glp - glp2; }
int pd_le(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return q - glp; }
long pd_lf(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long d = r - q; return d; }
int pd_lg(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (q - r) > 0; }
int pd_lh(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (r - q) / 2; }
long pd_li(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (glu + lb) - glu; }
int pd_xa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q - r; }
int pd_xb(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxu + b) - gxu; }
int pd_xc(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return &gxu[ub] - &gxu[b]; }
int pd_xd(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxp - gxp2; }
int pd_xe(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return q - gxp; }
long pd_xf(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { long d = r - q; return d; }
int pd_xg(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q - r) > 0; }
int pd_xh(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (r - q) / 2; }
long pd_xi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxu + lb) - gxu; }
int pd_sa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q - r; }
int pd_sb(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsu + b) - gsu; }
int pd_sc(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return &gsu[ub] - &gsu[b]; }
int pd_sd(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gsp - gsp2; }
int pd_se(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return q - gsp; }
long pd_sf(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { long d = r - q; return d; }
int pd_sg(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q - r) > 0; }
int pd_sh(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (r - q) / 2; }
long pd_si(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsu + lb) - gsu; }
int pc_cqlv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (q) < (r); }
void pc_cqli(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((q) < (r)) gi = 1; }
int pc_cqev(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (q) <= (r); }
void pc_cqei(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((q) <= (r)) gi = 1; }
int pc_cqgv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (q) > (r); }
void pc_cqgi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((q) > (r)) gi = 1; }
int pc_cqhv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (q) >= (r); }
void pc_cqhi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((q) >= (r)) gi = 1; }
int pc_cqqv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (q) == (r); }
void pc_cqqi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((q) == (r)) gi = 1; }
int pc_cqnv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (q) != (r); }
void pc_cqni(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((q) != (r)) gi = 1; }
int pc_cqzv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return !(q); }
void pc_cqzi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if (!(q)) gi = 1; }
int pc_cqyv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (q) == 0; }
void pc_cqyi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((q) == 0) gi = 1; }
int pc_cqbv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (q) && (r); }
void pc_cqbi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((q) && (r)) gi = 1; }
int pc_cglv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (gcp) < (gcp2); }
void pc_cgli(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((gcp) < (gcp2)) gi = 1; }
int pc_cgev(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (gcp) <= (gcp2); }
void pc_cgei(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((gcp) <= (gcp2)) gi = 1; }
int pc_cggv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (gcp) > (gcp2); }
void pc_cggi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((gcp) > (gcp2)) gi = 1; }
int pc_cghv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (gcp) >= (gcp2); }
void pc_cghi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((gcp) >= (gcp2)) gi = 1; }
int pc_cgqv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (gcp) == (gcp2); }
void pc_cgqi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((gcp) == (gcp2)) gi = 1; }
int pc_cgnv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (gcp) != (gcp2); }
void pc_cgni(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((gcp) != (gcp2)) gi = 1; }
int pc_cgzv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return !(gcp); }
void pc_cgzi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if (!(gcp)) gi = 1; }
int pc_cgyv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (gcp) == 0; }
void pc_cgyi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((gcp) == 0) gi = 1; }
int pc_cgbv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (gcp) && (gcp2); }
void pc_cgbi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((gcp) && (gcp2)) gi = 1; }
int pc_culv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (gcu + b) < (gcu + ub); }
void pc_culi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((gcu + b) < (gcu + ub)) gi = 1; }
int pc_cuev(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (gcu + b) <= (gcu + ub); }
void pc_cuei(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((gcu + b) <= (gcu + ub)) gi = 1; }
int pc_cugv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (gcu + b) > (gcu + ub); }
void pc_cugi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((gcu + b) > (gcu + ub)) gi = 1; }
int pc_cuhv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (gcu + b) >= (gcu + ub); }
void pc_cuhi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((gcu + b) >= (gcu + ub)) gi = 1; }
int pc_cuqv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (gcu + b) == (gcu + ub); }
void pc_cuqi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((gcu + b) == (gcu + ub)) gi = 1; }
int pc_cunv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (gcu + b) != (gcu + ub); }
void pc_cuni(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((gcu + b) != (gcu + ub)) gi = 1; }
int pc_cdlv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (*gcpp) < (q); }
void pc_cdli(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((*gcpp) < (q)) gi = 1; }
int pc_cdev(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (*gcpp) <= (q); }
void pc_cdei(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((*gcpp) <= (q)) gi = 1; }
int pc_cdgv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (*gcpp) > (q); }
void pc_cdgi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((*gcpp) > (q)) gi = 1; }
int pc_cdhv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (*gcpp) >= (q); }
void pc_cdhi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((*gcpp) >= (q)) gi = 1; }
int pc_cdqv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (*gcpp) == (q); }
void pc_cdqi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((*gcpp) == (q)) gi = 1; }
int pc_cdnv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (*gcpp) != (q); }
void pc_cdni(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((*gcpp) != (q)) gi = 1; }
int pc_cdzv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return !(*gcpp); }
void pc_cdzi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if (!(*gcpp)) gi = 1; }
int pc_cdyv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (*gcpp) == 0; }
void pc_cdyi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((*gcpp) == 0) gi = 1; }
int pc_cdbv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (*gcpp) && (q); }
void pc_cdbi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((*gcpp) && (q)) gi = 1; }
int pc_cklv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (q) < (q + b); }
void pc_ckli(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((q) < (q + b)) gi = 1; }
int pc_ckev(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (q) <= (q + b); }
void pc_ckei(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((q) <= (q + b)) gi = 1; }
int pc_ckgv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (q) > (q + b); }
void pc_ckgi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((q) > (q + b)) gi = 1; }
int pc_ckhv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (q) >= (q + b); }
void pc_ckhi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((q) >= (q + b)) gi = 1; }
int pc_ckqv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (q) == (q + b); }
void pc_ckqi(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((q) == (q + b)) gi = 1; }
int pc_cknv(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return (q) != (q + b); }
void pc_ckni(int b, unsigned int ub, char cb, long lb, char *q, char *r) { if ((q) != (q + b)) gi = 1; }
int pc_iqlv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (q) < (r); }
void pc_iqli(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((q) < (r)) gi = 1; }
int pc_iqev(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (q) <= (r); }
void pc_iqei(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((q) <= (r)) gi = 1; }
int pc_iqgv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (q) > (r); }
void pc_iqgi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((q) > (r)) gi = 1; }
int pc_iqhv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (q) >= (r); }
void pc_iqhi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((q) >= (r)) gi = 1; }
int pc_iqqv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (q) == (r); }
void pc_iqqi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((q) == (r)) gi = 1; }
int pc_iqnv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (q) != (r); }
void pc_iqni(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((q) != (r)) gi = 1; }
int pc_iqzv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return !(q); }
void pc_iqzi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if (!(q)) gi = 1; }
int pc_iqyv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (q) == 0; }
void pc_iqyi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((q) == 0) gi = 1; }
int pc_iqbv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (q) && (r); }
void pc_iqbi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((q) && (r)) gi = 1; }
int pc_iglv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (gip) < (gip2); }
void pc_igli(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((gip) < (gip2)) gi = 1; }
int pc_igev(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (gip) <= (gip2); }
void pc_igei(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((gip) <= (gip2)) gi = 1; }
int pc_iggv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (gip) > (gip2); }
void pc_iggi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((gip) > (gip2)) gi = 1; }
int pc_ighv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (gip) >= (gip2); }
void pc_ighi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((gip) >= (gip2)) gi = 1; }
int pc_igqv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (gip) == (gip2); }
void pc_igqi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((gip) == (gip2)) gi = 1; }
int pc_ignv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (gip) != (gip2); }
void pc_igni(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((gip) != (gip2)) gi = 1; }
int pc_igzv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return !(gip); }
void pc_igzi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if (!(gip)) gi = 1; }
int pc_igyv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (gip) == 0; }
void pc_igyi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((gip) == 0) gi = 1; }
int pc_igbv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (gip) && (gip2); }
void pc_igbi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((gip) && (gip2)) gi = 1; }
int pc_iulv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (giu + b) < (giu + ub); }
void pc_iuli(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((giu + b) < (giu + ub)) gi = 1; }
int pc_iuev(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (giu + b) <= (giu + ub); }
void pc_iuei(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((giu + b) <= (giu + ub)) gi = 1; }
int pc_iugv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (giu + b) > (giu + ub); }
void pc_iugi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((giu + b) > (giu + ub)) gi = 1; }
int pc_iuhv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (giu + b) >= (giu + ub); }
void pc_iuhi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((giu + b) >= (giu + ub)) gi = 1; }
int pc_iuqv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (giu + b) == (giu + ub); }
void pc_iuqi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((giu + b) == (giu + ub)) gi = 1; }
int pc_iunv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (giu + b) != (giu + ub); }
void pc_iuni(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((giu + b) != (giu + ub)) gi = 1; }
int pc_idlv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (*gipp) < (q); }
void pc_idli(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((*gipp) < (q)) gi = 1; }
int pc_idev(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (*gipp) <= (q); }
void pc_idei(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((*gipp) <= (q)) gi = 1; }
int pc_idgv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (*gipp) > (q); }
void pc_idgi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((*gipp) > (q)) gi = 1; }
int pc_idhv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (*gipp) >= (q); }
void pc_idhi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((*gipp) >= (q)) gi = 1; }
int pc_idqv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (*gipp) == (q); }
void pc_idqi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((*gipp) == (q)) gi = 1; }
int pc_idnv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (*gipp) != (q); }
void pc_idni(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((*gipp) != (q)) gi = 1; }
int pc_idzv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return !(*gipp); }
void pc_idzi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if (!(*gipp)) gi = 1; }
int pc_idyv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (*gipp) == 0; }
void pc_idyi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((*gipp) == 0) gi = 1; }
int pc_idbv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (*gipp) && (q); }
void pc_idbi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((*gipp) && (q)) gi = 1; }
int pc_iklv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (q) < (q + b); }
void pc_ikli(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((q) < (q + b)) gi = 1; }
int pc_ikev(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (q) <= (q + b); }
void pc_ikei(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((q) <= (q + b)) gi = 1; }
int pc_ikgv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (q) > (q + b); }
void pc_ikgi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((q) > (q + b)) gi = 1; }
int pc_ikhv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (q) >= (q + b); }
void pc_ikhi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((q) >= (q + b)) gi = 1; }
int pc_ikqv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (q) == (q + b); }
void pc_ikqi(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((q) == (q + b)) gi = 1; }
int pc_iknv(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return (q) != (q + b); }
void pc_ikni(int b, unsigned int ub, char cb, long lb, int *q, int *r) { if ((q) != (q + b)) gi = 1; }
int pc_lqlv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (q) < (r); }
void pc_lqli(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((q) < (r)) gi = 1; }
int pc_lqev(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (q) <= (r); }
void pc_lqei(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((q) <= (r)) gi = 1; }
int pc_lqgv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (q) > (r); }
void pc_lqgi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((q) > (r)) gi = 1; }
int pc_lqhv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (q) >= (r); }
void pc_lqhi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((q) >= (r)) gi = 1; }
int pc_lqqv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (q) == (r); }
void pc_lqqi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((q) == (r)) gi = 1; }
int pc_lqnv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (q) != (r); }
void pc_lqni(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((q) != (r)) gi = 1; }
int pc_lqzv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return !(q); }
void pc_lqzi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if (!(q)) gi = 1; }
int pc_lqyv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (q) == 0; }
void pc_lqyi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((q) == 0) gi = 1; }
int pc_lqbv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (q) && (r); }
void pc_lqbi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((q) && (r)) gi = 1; }
int pc_lglv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (glp) < (glp2); }
void pc_lgli(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((glp) < (glp2)) gi = 1; }
int pc_lgev(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (glp) <= (glp2); }
void pc_lgei(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((glp) <= (glp2)) gi = 1; }
int pc_lggv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (glp) > (glp2); }
void pc_lggi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((glp) > (glp2)) gi = 1; }
int pc_lghv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (glp) >= (glp2); }
void pc_lghi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((glp) >= (glp2)) gi = 1; }
int pc_lgqv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (glp) == (glp2); }
void pc_lgqi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((glp) == (glp2)) gi = 1; }
int pc_lgnv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (glp) != (glp2); }
void pc_lgni(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((glp) != (glp2)) gi = 1; }
int pc_lgzv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return !(glp); }
void pc_lgzi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if (!(glp)) gi = 1; }
int pc_lgyv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (glp) == 0; }
void pc_lgyi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((glp) == 0) gi = 1; }
int pc_lgbv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (glp) && (glp2); }
void pc_lgbi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((glp) && (glp2)) gi = 1; }
int pc_lulv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (glu + b) < (glu + ub); }
void pc_luli(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((glu + b) < (glu + ub)) gi = 1; }
int pc_luev(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (glu + b) <= (glu + ub); }
void pc_luei(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((glu + b) <= (glu + ub)) gi = 1; }
int pc_lugv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (glu + b) > (glu + ub); }
void pc_lugi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((glu + b) > (glu + ub)) gi = 1; }
int pc_luhv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (glu + b) >= (glu + ub); }
void pc_luhi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((glu + b) >= (glu + ub)) gi = 1; }
int pc_luqv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (glu + b) == (glu + ub); }
void pc_luqi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((glu + b) == (glu + ub)) gi = 1; }
int pc_lunv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (glu + b) != (glu + ub); }
void pc_luni(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((glu + b) != (glu + ub)) gi = 1; }
int pc_ldlv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (*glpp) < (q); }
void pc_ldli(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((*glpp) < (q)) gi = 1; }
int pc_ldev(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (*glpp) <= (q); }
void pc_ldei(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((*glpp) <= (q)) gi = 1; }
int pc_ldgv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (*glpp) > (q); }
void pc_ldgi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((*glpp) > (q)) gi = 1; }
int pc_ldhv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (*glpp) >= (q); }
void pc_ldhi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((*glpp) >= (q)) gi = 1; }
int pc_ldqv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (*glpp) == (q); }
void pc_ldqi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((*glpp) == (q)) gi = 1; }
int pc_ldnv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (*glpp) != (q); }
void pc_ldni(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((*glpp) != (q)) gi = 1; }
int pc_ldzv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return !(*glpp); }
void pc_ldzi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if (!(*glpp)) gi = 1; }
int pc_ldyv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (*glpp) == 0; }
void pc_ldyi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((*glpp) == 0) gi = 1; }
int pc_ldbv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (*glpp) && (q); }
void pc_ldbi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((*glpp) && (q)) gi = 1; }
int pc_lklv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (q) < (q + b); }
void pc_lkli(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((q) < (q + b)) gi = 1; }
int pc_lkev(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (q) <= (q + b); }
void pc_lkei(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((q) <= (q + b)) gi = 1; }
int pc_lkgv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (q) > (q + b); }
void pc_lkgi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((q) > (q + b)) gi = 1; }
int pc_lkhv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (q) >= (q + b); }
void pc_lkhi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((q) >= (q + b)) gi = 1; }
int pc_lkqv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (q) == (q + b); }
void pc_lkqi(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((q) == (q + b)) gi = 1; }
int pc_lknv(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return (q) != (q + b); }
void pc_lkni(int b, unsigned int ub, char cb, long lb, long *q, long *r) { if ((q) != (q + b)) gi = 1; }
int pc_xqlv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q) < (r); }
void pc_xqli(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((q) < (r)) gi = 1; }
int pc_xqev(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q) <= (r); }
void pc_xqei(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((q) <= (r)) gi = 1; }
int pc_xqgv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q) > (r); }
void pc_xqgi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((q) > (r)) gi = 1; }
int pc_xqhv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q) >= (r); }
void pc_xqhi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((q) >= (r)) gi = 1; }
int pc_xqqv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q) == (r); }
void pc_xqqi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((q) == (r)) gi = 1; }
int pc_xqnv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q) != (r); }
void pc_xqni(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((q) != (r)) gi = 1; }
int pc_xqzv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return !(q); }
void pc_xqzi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if (!(q)) gi = 1; }
int pc_xqyv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q) == 0; }
void pc_xqyi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((q) == 0) gi = 1; }
int pc_xqbv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q) && (r); }
void pc_xqbi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((q) && (r)) gi = 1; }
int pc_xglv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp) < (gxp2); }
void pc_xgli(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((gxp) < (gxp2)) gi = 1; }
int pc_xgev(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp) <= (gxp2); }
void pc_xgei(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((gxp) <= (gxp2)) gi = 1; }
int pc_xggv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp) > (gxp2); }
void pc_xggi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((gxp) > (gxp2)) gi = 1; }
int pc_xghv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp) >= (gxp2); }
void pc_xghi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((gxp) >= (gxp2)) gi = 1; }
int pc_xgqv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp) == (gxp2); }
void pc_xgqi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((gxp) == (gxp2)) gi = 1; }
int pc_xgnv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp) != (gxp2); }
void pc_xgni(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((gxp) != (gxp2)) gi = 1; }
int pc_xgzv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return !(gxp); }
void pc_xgzi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if (!(gxp)) gi = 1; }
int pc_xgyv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp) == 0; }
void pc_xgyi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((gxp) == 0) gi = 1; }
int pc_xgbv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxp) && (gxp2); }
void pc_xgbi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((gxp) && (gxp2)) gi = 1; }
int pc_xulv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxu + b) < (gxu + ub); }
void pc_xuli(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((gxu + b) < (gxu + ub)) gi = 1; }
int pc_xuev(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxu + b) <= (gxu + ub); }
void pc_xuei(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((gxu + b) <= (gxu + ub)) gi = 1; }
int pc_xugv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxu + b) > (gxu + ub); }
void pc_xugi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((gxu + b) > (gxu + ub)) gi = 1; }
int pc_xuhv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxu + b) >= (gxu + ub); }
void pc_xuhi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((gxu + b) >= (gxu + ub)) gi = 1; }
int pc_xuqv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxu + b) == (gxu + ub); }
void pc_xuqi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((gxu + b) == (gxu + ub)) gi = 1; }
int pc_xunv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxu + b) != (gxu + ub); }
void pc_xuni(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((gxu + b) != (gxu + ub)) gi = 1; }
int pc_xdlv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (*gxpp) < (q); }
void pc_xdli(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((*gxpp) < (q)) gi = 1; }
int pc_xdev(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (*gxpp) <= (q); }
void pc_xdei(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((*gxpp) <= (q)) gi = 1; }
int pc_xdgv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (*gxpp) > (q); }
void pc_xdgi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((*gxpp) > (q)) gi = 1; }
int pc_xdhv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (*gxpp) >= (q); }
void pc_xdhi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((*gxpp) >= (q)) gi = 1; }
int pc_xdqv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (*gxpp) == (q); }
void pc_xdqi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((*gxpp) == (q)) gi = 1; }
int pc_xdnv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (*gxpp) != (q); }
void pc_xdni(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((*gxpp) != (q)) gi = 1; }
int pc_xdzv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return !(*gxpp); }
void pc_xdzi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if (!(*gxpp)) gi = 1; }
int pc_xdyv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (*gxpp) == 0; }
void pc_xdyi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((*gxpp) == 0) gi = 1; }
int pc_xdbv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (*gxpp) && (q); }
void pc_xdbi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((*gxpp) && (q)) gi = 1; }
int pc_xklv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q) < (q + b); }
void pc_xkli(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((q) < (q + b)) gi = 1; }
int pc_xkev(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q) <= (q + b); }
void pc_xkei(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((q) <= (q + b)) gi = 1; }
int pc_xkgv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q) > (q + b); }
void pc_xkgi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((q) > (q + b)) gi = 1; }
int pc_xkhv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q) >= (q + b); }
void pc_xkhi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((q) >= (q + b)) gi = 1; }
int pc_xkqv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q) == (q + b); }
void pc_xkqi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((q) == (q + b)) gi = 1; }
int pc_xknv(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (q) != (q + b); }
void pc_xkni(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { if ((q) != (q + b)) gi = 1; }
int pc_sqlv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q) < (r); }
void pc_sqli(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((q) < (r)) gi = 1; }
int pc_sqev(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q) <= (r); }
void pc_sqei(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((q) <= (r)) gi = 1; }
int pc_sqgv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q) > (r); }
void pc_sqgi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((q) > (r)) gi = 1; }
int pc_sqhv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q) >= (r); }
void pc_sqhi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((q) >= (r)) gi = 1; }
int pc_sqqv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q) == (r); }
void pc_sqqi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((q) == (r)) gi = 1; }
int pc_sqnv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q) != (r); }
void pc_sqni(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((q) != (r)) gi = 1; }
int pc_sqzv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return !(q); }
void pc_sqzi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if (!(q)) gi = 1; }
int pc_sqyv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q) == 0; }
void pc_sqyi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((q) == 0) gi = 1; }
int pc_sqbv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q) && (r); }
void pc_sqbi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((q) && (r)) gi = 1; }
int pc_sglv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp) < (gsp2); }
void pc_sgli(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((gsp) < (gsp2)) gi = 1; }
int pc_sgev(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp) <= (gsp2); }
void pc_sgei(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((gsp) <= (gsp2)) gi = 1; }
int pc_sggv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp) > (gsp2); }
void pc_sggi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((gsp) > (gsp2)) gi = 1; }
int pc_sghv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp) >= (gsp2); }
void pc_sghi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((gsp) >= (gsp2)) gi = 1; }
int pc_sgqv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp) == (gsp2); }
void pc_sgqi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((gsp) == (gsp2)) gi = 1; }
int pc_sgnv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp) != (gsp2); }
void pc_sgni(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((gsp) != (gsp2)) gi = 1; }
int pc_sgzv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return !(gsp); }
void pc_sgzi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if (!(gsp)) gi = 1; }
int pc_sgyv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp) == 0; }
void pc_sgyi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((gsp) == 0) gi = 1; }
int pc_sgbv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsp) && (gsp2); }
void pc_sgbi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((gsp) && (gsp2)) gi = 1; }
int pc_sulv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsu + b) < (gsu + ub); }
void pc_suli(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((gsu + b) < (gsu + ub)) gi = 1; }
int pc_suev(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsu + b) <= (gsu + ub); }
void pc_suei(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((gsu + b) <= (gsu + ub)) gi = 1; }
int pc_sugv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsu + b) > (gsu + ub); }
void pc_sugi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((gsu + b) > (gsu + ub)) gi = 1; }
int pc_suhv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsu + b) >= (gsu + ub); }
void pc_suhi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((gsu + b) >= (gsu + ub)) gi = 1; }
int pc_suqv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsu + b) == (gsu + ub); }
void pc_suqi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((gsu + b) == (gsu + ub)) gi = 1; }
int pc_sunv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gsu + b) != (gsu + ub); }
void pc_suni(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((gsu + b) != (gsu + ub)) gi = 1; }
int pc_sdlv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (*gspp) < (q); }
void pc_sdli(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((*gspp) < (q)) gi = 1; }
int pc_sdev(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (*gspp) <= (q); }
void pc_sdei(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((*gspp) <= (q)) gi = 1; }
int pc_sdgv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (*gspp) > (q); }
void pc_sdgi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((*gspp) > (q)) gi = 1; }
int pc_sdhv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (*gspp) >= (q); }
void pc_sdhi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((*gspp) >= (q)) gi = 1; }
int pc_sdqv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (*gspp) == (q); }
void pc_sdqi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((*gspp) == (q)) gi = 1; }
int pc_sdnv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (*gspp) != (q); }
void pc_sdni(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((*gspp) != (q)) gi = 1; }
int pc_sdzv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return !(*gspp); }
void pc_sdzi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if (!(*gspp)) gi = 1; }
int pc_sdyv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (*gspp) == 0; }
void pc_sdyi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((*gspp) == 0) gi = 1; }
int pc_sdbv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (*gspp) && (q); }
void pc_sdbi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((*gspp) && (q)) gi = 1; }
int pc_sklv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q) < (q + b); }
void pc_skli(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((q) < (q + b)) gi = 1; }
int pc_skev(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q) <= (q + b); }
void pc_skei(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((q) <= (q + b)) gi = 1; }
int pc_skgv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q) > (q + b); }
void pc_skgi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((q) > (q + b)) gi = 1; }
int pc_skhv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q) >= (q + b); }
void pc_skhi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((q) >= (q + b)) gi = 1; }
int pc_skqv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q) == (q + b); }
void pc_skqi(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((q) == (q + b)) gi = 1; }
int pc_sknv(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (q) != (q + b); }
void pc_skni(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { if ((q) != (q + b)) gi = 1; }
char pw_cqa(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char y = *q++; return y; }
char pw_cqb(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char y = *--q; return y; }
char pw_cqc(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char y = *q--; return y; }
char pw_cqd(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char y = *++q; return y; }
void pw_cqe(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *q++ = b; }
void pw_cqf(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *--q = b; }
void pw_cqg(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *q++ += 1; }
char pw_cqh(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char y = *q++; y += *q++; return y; }
char pw_cga(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char y = *gcp++; return y; }
char pw_cgb(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char y = *--gcp; return y; }
char pw_cgc(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char y = *gcp--; return y; }
char pw_cgd(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char y = *++gcp; return y; }
void pw_cge(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *gcp++ = b; }
void pw_cgf(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *--gcp = b; }
void pw_cgg(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *gcp++ += 1; }
char pw_cgh(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char y = *gcp++; y += *gcp++; return y; }
char pw_cla(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char *p = q; char y = *p++; gi = (int)(p - q); return y; }
char pw_clb(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char *p = q; char y = *--p; gi = (int)(p - q); return y; }
char pw_clc(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char *p = q; char y = *p--; gi = (int)(p - q); return y; }
char pw_cld(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char *p = q; char y = *++p; gi = (int)(p - q); return y; }
void pw_cle(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char *p = q; *p++ = b; gi = (int)(p - q); }
void pw_clf(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char *p = q; *--p = b; gi = (int)(p - q); }
void pw_clg(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char *p = q; *p++ += 1; gi = (int)(p - q); }
char pw_clh(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char *p = q; char y = *p++; y += *p++; gi = (int)(p - q); return y; }
char pw_cma(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char y = *gps->pc++; return y; }
char pw_cmb(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char y = *--gps->pc; return y; }
char pw_cmc(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char y = *gps->pc--; return y; }
char pw_cmd(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char y = *++gps->pc; return y; }
void pw_cme(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *gps->pc++ = b; }
void pw_cmf(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *--gps->pc = b; }
void pw_cmg(int b, unsigned int ub, char cb, long lb, char *q, char *r) { *gps->pc++ += 1; }
char pw_cmh(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char y = *gps->pc++; y += *gps->pc++; return y; }
void pw_c_n(int b, unsigned int ub, char cb, long lb, char *q, char *r) { int n = b; while (n--) *q++ = 0; }
char pw_c_s(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char s = 0; int n = b; while (n-- > 0) s += *q++; return s; }
void pw_c_y(int b, unsigned int ub, char cb, long lb, char *q, char *r) { int n = b; while (n--) *q++ = *r++; }
int pw_c_z(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char *p = q; while (*p++) ; return p - q; }
char pw_c_r(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char s = 0; char *e = q + b; while (e > q) s += *--e; return s; }
int pw_iqa(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int y = *q++; return y; }
int pw_iqb(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int y = *--q; return y; }
int pw_iqc(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int y = *q--; return y; }
int pw_iqd(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int y = *++q; return y; }
void pw_iqe(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *q++ = b; }
void pw_iqf(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *--q = b; }
void pw_iqg(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *q++ += 1; }
int pw_iqh(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int y = *q++; y += *q++; return y; }
int pw_iga(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int y = *gip++; return y; }
int pw_igb(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int y = *--gip; return y; }
int pw_igc(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int y = *gip--; return y; }
int pw_igd(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int y = *++gip; return y; }
void pw_ige(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *gip++ = b; }
void pw_igf(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *--gip = b; }
void pw_igg(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *gip++ += 1; }
int pw_igh(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int y = *gip++; y += *gip++; return y; }
int pw_ila(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int *p = q; int y = *p++; gi = (int)(p - q); return y; }
int pw_ilb(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int *p = q; int y = *--p; gi = (int)(p - q); return y; }
int pw_ilc(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int *p = q; int y = *p--; gi = (int)(p - q); return y; }
int pw_ild(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int *p = q; int y = *++p; gi = (int)(p - q); return y; }
void pw_ile(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int *p = q; *p++ = b; gi = (int)(p - q); }
void pw_ilf(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int *p = q; *--p = b; gi = (int)(p - q); }
void pw_ilg(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int *p = q; *p++ += 1; gi = (int)(p - q); }
int pw_ilh(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int *p = q; int y = *p++; y += *p++; gi = (int)(p - q); return y; }
int pw_ima(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int y = *gps->pi++; return y; }
int pw_imb(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int y = *--gps->pi; return y; }
int pw_imc(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int y = *gps->pi--; return y; }
int pw_imd(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int y = *++gps->pi; return y; }
void pw_ime(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *gps->pi++ = b; }
void pw_imf(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *--gps->pi = b; }
void pw_img(int b, unsigned int ub, char cb, long lb, int *q, int *r) { *gps->pi++ += 1; }
int pw_imh(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int y = *gps->pi++; y += *gps->pi++; return y; }
void pw_i_n(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int n = b; while (n--) *q++ = 0; }
int pw_i_s(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int s = 0; int n = b; while (n-- > 0) s += *q++; return s; }
void pw_i_y(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int n = b; while (n--) *q++ = *r++; }
int pw_i_z(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int *p = q; while (*p++) ; return p - q; }
int pw_i_r(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int s = 0; int *e = q + b; while (e > q) s += *--e; return s; }
long pw_lqa(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long y = *q++; return y; }
long pw_lqb(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long y = *--q; return y; }
long pw_lqc(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long y = *q--; return y; }
long pw_lqd(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long y = *++q; return y; }
void pw_lqe(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *q++ = b; }
void pw_lqf(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *--q = b; }
void pw_lqg(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *q++ += 1; }
long pw_lqh(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long y = *q++; y += *q++; return y; }
long pw_lga(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long y = *glp++; return y; }
long pw_lgb(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long y = *--glp; return y; }
long pw_lgc(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long y = *glp--; return y; }
long pw_lgd(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long y = *++glp; return y; }
void pw_lge(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *glp++ = b; }
void pw_lgf(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *--glp = b; }
void pw_lgg(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *glp++ += 1; }
long pw_lgh(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long y = *glp++; y += *glp++; return y; }
long pw_lla(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long *p = q; long y = *p++; gi = (int)(p - q); return y; }
long pw_llb(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long *p = q; long y = *--p; gi = (int)(p - q); return y; }
long pw_llc(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long *p = q; long y = *p--; gi = (int)(p - q); return y; }
long pw_lld(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long *p = q; long y = *++p; gi = (int)(p - q); return y; }
void pw_lle(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long *p = q; *p++ = b; gi = (int)(p - q); }
void pw_llf(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long *p = q; *--p = b; gi = (int)(p - q); }
void pw_llg(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long *p = q; *p++ += 1; gi = (int)(p - q); }
long pw_llh(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long *p = q; long y = *p++; y += *p++; gi = (int)(p - q); return y; }
long pw_lma(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long y = *gps->pl++; return y; }
long pw_lmb(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long y = *--gps->pl; return y; }
long pw_lmc(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long y = *gps->pl--; return y; }
long pw_lmd(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long y = *++gps->pl; return y; }
void pw_lme(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *gps->pl++ = b; }
void pw_lmf(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *--gps->pl = b; }
void pw_lmg(int b, unsigned int ub, char cb, long lb, long *q, long *r) { *gps->pl++ += 1; }
long pw_lmh(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long y = *gps->pl++; y += *gps->pl++; return y; }
void pw_l_n(int b, unsigned int ub, char cb, long lb, long *q, long *r) { int n = b; while (n--) *q++ = 0; }
long pw_l_s(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long s = 0; int n = b; while (n-- > 0) s += *q++; return s; }
void pw_l_y(int b, unsigned int ub, char cb, long lb, long *q, long *r) { int n = b; while (n--) *q++ = *r++; }
int pw_l_z(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long *p = q; while (*p++) ; return p - q; }
long pw_l_r(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long s = 0; long *e = q + b; while (e > q) s += *--e; return s; }
char pw_xqa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { char y = (q++)->a[1]; return y; }
char pw_xqb(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { char y = (--q)->a[1]; return y; }
void pw_xqe(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (q++)->a[1] = b; }
void pw_xqf(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (--q)->a[1] = b; }
char pw_xga(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { char y = (gxp++)->a[1]; return y; }
char pw_xgb(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { char y = (--gxp)->a[1]; return y; }
void pw_xge(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gxp++)->a[1] = b; }
void pw_xgf(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (--gxp)->a[1] = b; }
char pw_xla(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { struct s3 *p = q; char y = (p++)->a[1]; gi = (int)(p - q); return y; }
char pw_xlb(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { struct s3 *p = q; char y = (--p)->a[1]; gi = (int)(p - q); return y; }
void pw_xle(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { struct s3 *p = q; (p++)->a[1] = b; gi = (int)(p - q); }
void pw_xlf(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { struct s3 *p = q; (--p)->a[1] = b; gi = (int)(p - q); }
char pw_xma(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { char y = (gps->px++)->a[1]; return y; }
char pw_xmb(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { char y = (--gps->px)->a[1]; return y; }
void pw_xme(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (gps->px++)->a[1] = b; }
void pw_xmf(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { (--gps->px)->a[1] = b; }
void pw_x_n(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { int n = b; while (n--) (q++)->a[1] = 0; }
void pw_x_y(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { int n = b; while (n--) *q++ = *r++; }
char pw_x_r(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { char s = 0; struct s3 *e = q + b; while (e > q) s += (--e)->a[1]; return s; }
int pw_sqa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { int y = (q++)->a[1]; return y; }
int pw_sqb(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { int y = (--q)->a[1]; return y; }
void pw_sqe(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (q++)->a[1] = b; }
void pw_sqf(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (--q)->a[1] = b; }
int pw_sga(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { int y = (gsp++)->a[1]; return y; }
int pw_sgb(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { int y = (--gsp)->a[1]; return y; }
void pw_sge(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gsp++)->a[1] = b; }
void pw_sgf(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (--gsp)->a[1] = b; }
int pw_sla(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { struct s10 *p = q; int y = (p++)->a[1]; gi = (int)(p - q); return y; }
int pw_slb(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { struct s10 *p = q; int y = (--p)->a[1]; gi = (int)(p - q); return y; }
void pw_sle(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { struct s10 *p = q; (p++)->a[1] = b; gi = (int)(p - q); }
void pw_slf(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { struct s10 *p = q; (--p)->a[1] = b; gi = (int)(p - q); }
int pw_sma(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { int y = (gps->ps++)->a[1]; return y; }
int pw_smb(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { int y = (--gps->ps)->a[1]; return y; }
void pw_sme(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (gps->ps++)->a[1] = b; }
void pw_smf(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { (--gps->ps)->a[1] = b; }
void pw_s_n(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { int n = b; while (n--) (q++)->a[1] = 0; }
void pw_s_y(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { int n = b; while (n--) *q++ = *r++; }
int pw_s_r(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { int s = 0; struct s10 *e = q + b; while (e > q) s += (--e)->a[1]; return s; }
char pp_cpa(int b, unsigned int ub, char *q, char **pp) { return *(*pp); }
char * pp_cpb(int b, unsigned int ub, char *q, char **pp) { return *pp + b; }
char pp_cpc(int b, unsigned int ub, char *q, char **pp) { return (*pp)[b]; }
void pp_cpd(int b, unsigned int ub, char *q, char **pp) { *pp = q; }
void pp_cpe(int b, unsigned int ub, char *q, char **pp) { (*pp)++; }
char pp_cpf(int b, unsigned int ub, char *q, char **pp) { return *((*pp)++); }
char pp_cpg(int b, unsigned int ub, char *q, char **pp) { return pp[b][2]; }
char pp_cph(int b, unsigned int ub, char *q, char **pp) { return *(pp[b]); }
void pp_cpi(int b, unsigned int ub, char *q, char **pp) { *(*pp) = 5; }
void pp_cpj(int b, unsigned int ub, char *q, char **pp) { *pp = &gcu[b]; }
int pp_cpk(int b, unsigned int ub, char *q, char **pp) { return pp[1] - pp[0]; }
char pp_cga(int b, unsigned int ub, char *q, char **pp) { return *(*gcpp); }
char * pp_cgb(int b, unsigned int ub, char *q, char **pp) { return *gcpp + b; }
char pp_cgc(int b, unsigned int ub, char *q, char **pp) { return (*gcpp)[b]; }
void pp_cgd(int b, unsigned int ub, char *q, char **pp) { *gcpp = q; }
void pp_cge(int b, unsigned int ub, char *q, char **pp) { (*gcpp)++; }
char pp_cgf(int b, unsigned int ub, char *q, char **pp) { return *((*gcpp)++); }
char pp_cgg(int b, unsigned int ub, char *q, char **pp) { return gcpp[b][2]; }
char pp_cgh(int b, unsigned int ub, char *q, char **pp) { return *(gcpp[b]); }
void pp_cgi(int b, unsigned int ub, char *q, char **pp) { *(*gcpp) = 5; }
void pp_cgj(int b, unsigned int ub, char *q, char **pp) { *gcpp = &gcu[b]; }
int pp_cgk(int b, unsigned int ub, char *q, char **pp) { return gcpp[1] - gcpp[0]; }
int pp_ipa(int b, unsigned int ub, int *q, int **pp) { return *(*pp); }
int * pp_ipb(int b, unsigned int ub, int *q, int **pp) { return *pp + b; }
int pp_ipc(int b, unsigned int ub, int *q, int **pp) { return (*pp)[b]; }
void pp_ipd(int b, unsigned int ub, int *q, int **pp) { *pp = q; }
void pp_ipe(int b, unsigned int ub, int *q, int **pp) { (*pp)++; }
int pp_ipf(int b, unsigned int ub, int *q, int **pp) { return *((*pp)++); }
int pp_ipg(int b, unsigned int ub, int *q, int **pp) { return pp[b][2]; }
int pp_iph(int b, unsigned int ub, int *q, int **pp) { return *(pp[b]); }
void pp_ipi(int b, unsigned int ub, int *q, int **pp) { *(*pp) = 5; }
void pp_ipj(int b, unsigned int ub, int *q, int **pp) { *pp = &giu[b]; }
int pp_ipk(int b, unsigned int ub, int *q, int **pp) { return pp[1] - pp[0]; }
int pp_iga(int b, unsigned int ub, int *q, int **pp) { return *(*gipp); }
int * pp_igb(int b, unsigned int ub, int *q, int **pp) { return *gipp + b; }
int pp_igc(int b, unsigned int ub, int *q, int **pp) { return (*gipp)[b]; }
void pp_igd(int b, unsigned int ub, int *q, int **pp) { *gipp = q; }
void pp_ige(int b, unsigned int ub, int *q, int **pp) { (*gipp)++; }
int pp_igf(int b, unsigned int ub, int *q, int **pp) { return *((*gipp)++); }
int pp_igg(int b, unsigned int ub, int *q, int **pp) { return gipp[b][2]; }
int pp_igh(int b, unsigned int ub, int *q, int **pp) { return *(gipp[b]); }
void pp_igi(int b, unsigned int ub, int *q, int **pp) { *(*gipp) = 5; }
void pp_igj(int b, unsigned int ub, int *q, int **pp) { *gipp = &giu[b]; }
int pp_igk(int b, unsigned int ub, int *q, int **pp) { return gipp[1] - gipp[0]; }
long pp_lpa(int b, unsigned int ub, long *q, long **pp) { return *(*pp); }
long * pp_lpb(int b, unsigned int ub, long *q, long **pp) { return *pp + b; }
long pp_lpc(int b, unsigned int ub, long *q, long **pp) { return (*pp)[b]; }
void pp_lpd(int b, unsigned int ub, long *q, long **pp) { *pp = q; }
void pp_lpe(int b, unsigned int ub, long *q, long **pp) { (*pp)++; }
long pp_lpf(int b, unsigned int ub, long *q, long **pp) { return *((*pp)++); }
long pp_lpg(int b, unsigned int ub, long *q, long **pp) { return pp[b][2]; }
long pp_lph(int b, unsigned int ub, long *q, long **pp) { return *(pp[b]); }
void pp_lpi(int b, unsigned int ub, long *q, long **pp) { *(*pp) = 5; }
void pp_lpj(int b, unsigned int ub, long *q, long **pp) { *pp = &glu[b]; }
int pp_lpk(int b, unsigned int ub, long *q, long **pp) { return pp[1] - pp[0]; }
long pp_lga(int b, unsigned int ub, long *q, long **pp) { return *(*glpp); }
long * pp_lgb(int b, unsigned int ub, long *q, long **pp) { return *glpp + b; }
long pp_lgc(int b, unsigned int ub, long *q, long **pp) { return (*glpp)[b]; }
void pp_lgd(int b, unsigned int ub, long *q, long **pp) { *glpp = q; }
void pp_lge(int b, unsigned int ub, long *q, long **pp) { (*glpp)++; }
long pp_lgf(int b, unsigned int ub, long *q, long **pp) { return *((*glpp)++); }
long pp_lgg(int b, unsigned int ub, long *q, long **pp) { return glpp[b][2]; }
long pp_lgh(int b, unsigned int ub, long *q, long **pp) { return *(glpp[b]); }
void pp_lgi(int b, unsigned int ub, long *q, long **pp) { *(*glpp) = 5; }
void pp_lgj(int b, unsigned int ub, long *q, long **pp) { *glpp = &glu[b]; }
int pp_lgk(int b, unsigned int ub, long *q, long **pp) { return glpp[1] - glpp[0]; }
char pp_xpa(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { return (*pp)->a[1]; }
struct s3 * pp_xpb(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { return *pp + b; }
char pp_xpc(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { return (*pp)[b].a[1]; }
void pp_xpd(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { *pp = q; }
void pp_xpe(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { (*pp)++; }
char pp_xpf(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { return ((*pp)++)->a[1]; }
char pp_xpg(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { return pp[b][2].a[1]; }
char pp_xph(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { return (pp[b])->a[1]; }
void pp_xpi(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { (*pp)->a[1] = 5; }
void pp_xpj(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { *pp = &gxu[b]; }
int pp_xpk(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { return pp[1] - pp[0]; }
char pp_xga(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { return (*gxpp)->a[1]; }
struct s3 * pp_xgb(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { return *gxpp + b; }
char pp_xgc(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { return (*gxpp)[b].a[1]; }
void pp_xgd(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { *gxpp = q; }
void pp_xge(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { (*gxpp)++; }
char pp_xgf(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { return ((*gxpp)++)->a[1]; }
char pp_xgg(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { return gxpp[b][2].a[1]; }
char pp_xgh(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { return (gxpp[b])->a[1]; }
void pp_xgi(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { (*gxpp)->a[1] = 5; }
void pp_xgj(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { *gxpp = &gxu[b]; }
int pp_xgk(int b, unsigned int ub, struct s3 *q, struct s3 **pp) { return gxpp[1] - gxpp[0]; }
int pp_spa(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { return (*pp)->a[1]; }
struct s10 * pp_spb(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { return *pp + b; }
int pp_spc(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { return (*pp)[b].a[1]; }
void pp_spd(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { *pp = q; }
void pp_spe(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { (*pp)++; }
int pp_spf(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { return ((*pp)++)->a[1]; }
int pp_spg(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { return pp[b][2].a[1]; }
int pp_sph(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { return (pp[b])->a[1]; }
void pp_spi(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { (*pp)->a[1] = 5; }
void pp_spj(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { *pp = &gsu[b]; }
int pp_spk(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { return pp[1] - pp[0]; }
int pp_sga(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { return (*gspp)->a[1]; }
struct s10 * pp_sgb(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { return *gspp + b; }
int pp_sgc(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { return (*gspp)[b].a[1]; }
void pp_sgd(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { *gspp = q; }
void pp_sge(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { (*gspp)++; }
int pp_sgf(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { return ((*gspp)++)->a[1]; }
int pp_sgg(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { return gspp[b][2].a[1]; }
int pp_sgh(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { return (gspp[b])->a[1]; }
void pp_sgi(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { (*gspp)->a[1] = 5; }
void pp_sgj(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { *gspp = &gsu[b]; }
int pp_sgk(int b, unsigned int ub, struct s10 *q, struct s10 **pp) { return gspp[1] - gspp[0]; }
char pr_ca(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcpa[b]); }
char pr_cb(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcpa[b][2]; }
char pr_cc(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcpa[2][b]; }
void pr_cd(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcpa[b] = q; }
void pr_ce(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcpa[b]++; }
char pr_cf(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return *(gcpa[2]++); }
void pr_cg(int b, unsigned int ub, char cb, long lb, char *q, char *r) { gcpa[b][ub] = 5; }
int pr_ch(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcpa[cb] - gcpa[0]; }
char pr_ci(int b, unsigned int ub, char cb, long lb, char *q, char *r) { char *la[2]; la[0] = q; la[1] = gcp; return *(la[b & 1]); }
int pr_cj(int b, unsigned int ub, char cb, long lb, char *q, char *r) { return gcpa[b] == q; }
int pr_ia(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gipa[b]); }
int pr_ib(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gipa[b][2]; }
int pr_ic(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gipa[2][b]; }
void pr_id(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gipa[b] = q; }
void pr_ie(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gipa[b]++; }
int pr_if(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return *(gipa[2]++); }
void pr_ig(int b, unsigned int ub, char cb, long lb, int *q, int *r) { gipa[b][ub] = 5; }
int pr_ih(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gipa[cb] - gipa[0]; }
int pr_ii(int b, unsigned int ub, char cb, long lb, int *q, int *r) { int *la[2]; la[0] = q; la[1] = gip; return *(la[b & 1]); }
int pr_ij(int b, unsigned int ub, char cb, long lb, int *q, int *r) { return gipa[b] == q; }
long pr_la(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glpa[b]); }
long pr_lb(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glpa[b][2]; }
long pr_lc(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glpa[2][b]; }
void pr_ld(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glpa[b] = q; }
void pr_le(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glpa[b]++; }
long pr_lf(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return *(glpa[2]++); }
void pr_lg(int b, unsigned int ub, char cb, long lb, long *q, long *r) { glpa[b][ub] = 5; }
int pr_lh(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glpa[cb] - glpa[0]; }
long pr_li(int b, unsigned int ub, char cb, long lb, long *q, long *r) { long *la[2]; la[0] = q; la[1] = glp; return *(la[b & 1]); }
int pr_lj(int b, unsigned int ub, char cb, long lb, long *q, long *r) { return glpa[b] == q; }
char pr_xa(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxpa[b])->a[1]; }
char pr_xb(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxpa[b][2].a[1]; }
char pr_xc(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxpa[2][b].a[1]; }
void pr_xd(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxpa[b] = q; }
void pr_xe(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxpa[b]++; }
char pr_xf(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return (gxpa[2]++)->a[1]; }
void pr_xg(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { gxpa[b][ub].a[1] = 5; }
int pr_xh(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxpa[cb] - gxpa[0]; }
char pr_xi(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { struct s3 *la[2]; la[0] = q; la[1] = gxp; return (la[b & 1])->a[1]; }
int pr_xj(int b, unsigned int ub, char cb, long lb, struct s3 *q, struct s3 *r) { return gxpa[b] == q; }
int pr_sa(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gspa[b])->a[1]; }
int pr_sb(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gspa[b][2].a[1]; }
int pr_sc(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gspa[2][b].a[1]; }
void pr_sd(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gspa[b] = q; }
void pr_se(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gspa[b]++; }
int pr_sf(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return (gspa[2]++)->a[1]; }
void pr_sg(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { gspa[b][ub].a[1] = 5; }
int pr_sh(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gspa[cb] - gspa[0]; }
int pr_si(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { struct s10 *la[2]; la[0] = q; la[1] = gsp; return (la[b & 1])->a[1]; }
int pr_sj(int b, unsigned int ub, char cb, long lb, struct s10 *q, struct s10 *r) { return gspa[b] == q; }
int pf_a(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return gfa[b](ub); }
int pf_b(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return gfa[2](b); }
int pf_c(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return (*gfa[cb])(3); }
int pf_d(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return gfs.fi(b); }
long pf_e(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return gpfs->fl(lb, 1); }
void pf_f(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { gpfs->fv(); }
int pf_g(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return q->fi(b); }
int pf_h(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return (*fp)(b); }
int pf_i(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return fp(b) + 1; }
int pf_j(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return fpa[b](ub); }
void pf_k(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { gfa[b] = gfp; }
void pf_m(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { gpfs->fi = fp; }
int pf_n(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return gfa[b] == gfp; }
int pf_o(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return gfa[b](1) + gfa[ub](2); }
int pf_p(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return gfa[b](gfa[0](cb)); }
char pf_q(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return gfs.fc(cb); }
long pf_r(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return gfl[b](lb) * 2; }
int pf_s(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return gfp(b); }
void pf_t(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { gfa[1] = fi1; }
int pf_u(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { int (*f)(int) = b ? gfa[0] : fp; return f(ub); }
void pf_v(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { q->fv(); gpfs->fv(); }
int pf_w(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return gfp != 0 ? gfp(b) : 0; }
long pf_x(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return q->fl(lb, b) + gpfs->fl(1, lb); }
int pf_y(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return (b ? gfa[1] : gfa[2])(cb); }
int pf_z(int b, unsigned int ub, char cb, long lb, int (*fp)(int), int (**fpa)(int), struct fs *q) { return fpa[2](b) - fpa[b](2); }
