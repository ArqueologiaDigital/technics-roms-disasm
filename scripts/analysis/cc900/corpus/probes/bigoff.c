/* lane_nm probe: constant element offsets past 16 bits; see gen_bigoff.py for the name letters */
struct s10 { int a[5]; };
extern char gcb[0x20010];
extern int gib[0x10008];
extern long glb[0x8004];
extern struct s10 gsb[0x3340];
char bo_car(char *q) { return gcb[32766]; }
void bo_caw(char *q) { gcb[32766] = 5; }
char * bo_caa(char *q) { return &gcb[32766]; }
char bo_cap(char *q) { return q[32766]; }
char bo_cal(char *q) { int t = 32766; return gcb[t]; }
char bo_cau(char *q) { return gcb[32766u]; }
char bo_cam(char *q) { return q[-32766]; }
char bo_cbr(char *q) { return gcb[32768]; }
void bo_cbw(char *q) { gcb[32768] = 5; }
char * bo_cba(char *q) { return &gcb[32768]; }
char bo_cbp(char *q) { return q[32768]; }
char bo_cbu(char *q) { return gcb[32768u]; }
char bo_cbm(char *q) { return q[-32768]; }
char bo_ccr(char *q) { return gcb[32770]; }
void bo_ccw(char *q) { gcb[32770] = 5; }
char * bo_cca(char *q) { return &gcb[32770]; }
char bo_ccp(char *q) { return q[32770]; }
char bo_ccu(char *q) { return gcb[32770u]; }
char bo_ccm(char *q) { return q[-32770]; }
char bo_cdr(char *q) { return gcb[40960]; }
void bo_cdw(char *q) { gcb[40960] = 5; }
char * bo_cda(char *q) { return &gcb[40960]; }
char bo_cdp(char *q) { return q[40960]; }
char bo_cdu(char *q) { return gcb[40960u]; }
char bo_cdm(char *q) { return q[-40960]; }
char bo_cer(char *q) { return gcb[65534]; }
void bo_cew(char *q) { gcb[65534] = 5; }
char * bo_cea(char *q) { return &gcb[65534]; }
char bo_cep(char *q) { return q[65534]; }
char bo_ceu(char *q) { return gcb[65534u]; }
char bo_cem(char *q) { return q[-65534]; }
char bo_cfr(char *q) { return gcb[65536]; }
void bo_cfw(char *q) { gcb[65536] = 5; }
char * bo_cfa(char *q) { return &gcb[65536]; }
char bo_cfp(char *q) { return q[65536]; }
char bo_cfu(char *q) { return gcb[65536u]; }
char bo_cfm(char *q) { return q[-65536]; }
char bo_cgr(char *q) { return gcb[74560]; }
void bo_cgw(char *q) { gcb[74560] = 5; }
char * bo_cga(char *q) { return &gcb[74560]; }
char bo_cgp(char *q) { return q[74560]; }
char bo_cgu(char *q) { return gcb[74560u]; }
char bo_chr(char *q) { return gcb[131068]; }
void bo_chw(char *q) { gcb[131068] = 5; }
char * bo_cha(char *q) { return &gcb[131068]; }
char bo_chp(char *q) { return q[131068]; }
char bo_chu(char *q) { return gcb[131068u]; }
int bo_iar(int *q) { return gib[16383]; }
void bo_iaw(int *q) { gib[16383] = 5; }
int * bo_iaa(int *q) { return &gib[16383]; }
int bo_iap(int *q) { return q[16383]; }
int bo_ial(int *q) { int t = 16383; return gib[t]; }
int bo_iau(int *q) { return gib[16383u]; }
int bo_iam(int *q) { return q[-16383]; }
int bo_ibr(int *q) { return gib[16384]; }
void bo_ibw(int *q) { gib[16384] = 5; }
int * bo_iba(int *q) { return &gib[16384]; }
int bo_ibp(int *q) { return q[16384]; }
int bo_ibl(int *q) { int t = 16384; return gib[t]; }
int bo_ibu(int *q) { return gib[16384u]; }
int bo_ibm(int *q) { return q[-16384]; }
int bo_icr(int *q) { return gib[16385]; }
void bo_icw(int *q) { gib[16385] = 5; }
int * bo_ica(int *q) { return &gib[16385]; }
int bo_icp(int *q) { return q[16385]; }
int bo_icl(int *q) { int t = 16385; return gib[t]; }
int bo_icu(int *q) { return gib[16385u]; }
int bo_icm(int *q) { return q[-16385]; }
int bo_idr(int *q) { return gib[20480]; }
void bo_idw(int *q) { gib[20480] = 5; }
int * bo_ida(int *q) { return &gib[20480]; }
int bo_idp(int *q) { return q[20480]; }
int bo_idl(int *q) { int t = 20480; return gib[t]; }
int bo_idu(int *q) { return gib[20480u]; }
int bo_idm(int *q) { return q[-20480]; }
int bo_ier(int *q) { return gib[32767]; }
void bo_iew(int *q) { gib[32767] = 5; }
int * bo_iea(int *q) { return &gib[32767]; }
int bo_iep(int *q) { return q[32767]; }
int bo_iel(int *q) { int t = 32767; return gib[t]; }
int bo_ieu(int *q) { return gib[32767u]; }
int bo_iem(int *q) { return q[-32767]; }
int bo_ifr(int *q) { return gib[32768]; }
void bo_ifw(int *q) { gib[32768] = 5; }
int * bo_ifa(int *q) { return &gib[32768]; }
int bo_ifp(int *q) { return q[32768]; }
int bo_ifu(int *q) { return gib[32768u]; }
int bo_ifm(int *q) { return q[-32768]; }
int bo_igr(int *q) { return gib[37280]; }
void bo_igw(int *q) { gib[37280] = 5; }
int * bo_iga(int *q) { return &gib[37280]; }
int bo_igp(int *q) { return q[37280]; }
int bo_igu(int *q) { return gib[37280u]; }
int bo_ihr(int *q) { return gib[65534]; }
void bo_ihw(int *q) { gib[65534] = 5; }
int * bo_iha(int *q) { return &gib[65534]; }
int bo_ihp(int *q) { return q[65534]; }
int bo_ihu(int *q) { return gib[65534u]; }
long bo_lar(long *q) { return glb[8191]; }
void bo_law(long *q) { glb[8191] = 5; }
long * bo_laa(long *q) { return &glb[8191]; }
long bo_lap(long *q) { return q[8191]; }
long bo_lal(long *q) { int t = 8191; return glb[t]; }
long bo_lau(long *q) { return glb[8191u]; }
long bo_lam(long *q) { return q[-8191]; }
long bo_lbr(long *q) { return glb[8192]; }
void bo_lbw(long *q) { glb[8192] = 5; }
long * bo_lba(long *q) { return &glb[8192]; }
long bo_lbp(long *q) { return q[8192]; }
long bo_lbl(long *q) { int t = 8192; return glb[t]; }
long bo_lbu(long *q) { return glb[8192u]; }
long bo_lbm(long *q) { return q[-8192]; }
long bo_lcr(long *q) { return glb[8192]; }
void bo_lcw(long *q) { glb[8192] = 5; }
long * bo_lca(long *q) { return &glb[8192]; }
long bo_lcp(long *q) { return q[8192]; }
long bo_lcl(long *q) { int t = 8192; return glb[t]; }
long bo_lcu(long *q) { return glb[8192u]; }
long bo_lcm(long *q) { return q[-8192]; }
long bo_ldr(long *q) { return glb[10240]; }
void bo_ldw(long *q) { glb[10240] = 5; }
long * bo_lda(long *q) { return &glb[10240]; }
long bo_ldp(long *q) { return q[10240]; }
long bo_ldl(long *q) { int t = 10240; return glb[t]; }
long bo_ldu(long *q) { return glb[10240u]; }
long bo_ldm(long *q) { return q[-10240]; }
long bo_ler(long *q) { return glb[16383]; }
void bo_lew(long *q) { glb[16383] = 5; }
long * bo_lea(long *q) { return &glb[16383]; }
long bo_lep(long *q) { return q[16383]; }
long bo_lel(long *q) { int t = 16383; return glb[t]; }
long bo_leu(long *q) { return glb[16383u]; }
long bo_lem(long *q) { return q[-16383]; }
long bo_lfr(long *q) { return glb[16384]; }
void bo_lfw(long *q) { glb[16384] = 5; }
long * bo_lfa(long *q) { return &glb[16384]; }
long bo_lfp(long *q) { return q[16384]; }
long bo_lfl(long *q) { int t = 16384; return glb[t]; }
long bo_lfu(long *q) { return glb[16384u]; }
long bo_lfm(long *q) { return q[-16384]; }
long bo_lgr(long *q) { return glb[18640]; }
void bo_lgw(long *q) { glb[18640] = 5; }
long * bo_lga(long *q) { return &glb[18640]; }
long bo_lgp(long *q) { return q[18640]; }
long bo_lgl(long *q) { int t = 18640; return glb[t]; }
long bo_lgu(long *q) { return glb[18640u]; }
long bo_lhr(long *q) { return glb[32767]; }
void bo_lhw(long *q) { glb[32767] = 5; }
long * bo_lha(long *q) { return &glb[32767]; }
long bo_lhp(long *q) { return q[32767]; }
long bo_lhl(long *q) { int t = 32767; return glb[t]; }
long bo_lhu(long *q) { return glb[32767u]; }
int bo_sar(struct s10 *q) { return gsb[3276].a[1]; }
void bo_saw(struct s10 *q) { gsb[3276].a[1] = 5; }
struct s10 * bo_saa(struct s10 *q) { return &gsb[3276]; }
int bo_sap(struct s10 *q) { return q[3276].a[1]; }
int bo_sal(struct s10 *q) { int t = 3276; return gsb[t].a[1]; }
int bo_sau(struct s10 *q) { return gsb[3276u].a[1]; }
int bo_sam(struct s10 *q) { return q[-3276].a[1]; }
int bo_sbr(struct s10 *q) { return gsb[3276].a[1]; }
void bo_sbw(struct s10 *q) { gsb[3276].a[1] = 5; }
struct s10 * bo_sba(struct s10 *q) { return &gsb[3276]; }
int bo_sbp(struct s10 *q) { return q[3276].a[1]; }
int bo_sbl(struct s10 *q) { int t = 3276; return gsb[t].a[1]; }
int bo_sbu(struct s10 *q) { return gsb[3276u].a[1]; }
int bo_sbm(struct s10 *q) { return q[-3276].a[1]; }
int bo_scr(struct s10 *q) { return gsb[3277].a[1]; }
void bo_scw(struct s10 *q) { gsb[3277].a[1] = 5; }
struct s10 * bo_sca(struct s10 *q) { return &gsb[3277]; }
int bo_scp(struct s10 *q) { return q[3277].a[1]; }
int bo_scl(struct s10 *q) { int t = 3277; return gsb[t].a[1]; }
int bo_scu(struct s10 *q) { return gsb[3277u].a[1]; }
int bo_scm(struct s10 *q) { return q[-3277].a[1]; }
int bo_sdr(struct s10 *q) { return gsb[4096].a[1]; }
void bo_sdw(struct s10 *q) { gsb[4096].a[1] = 5; }
struct s10 * bo_sda(struct s10 *q) { return &gsb[4096]; }
int bo_sdp(struct s10 *q) { return q[4096].a[1]; }
int bo_sdl(struct s10 *q) { int t = 4096; return gsb[t].a[1]; }
int bo_sdu(struct s10 *q) { return gsb[4096u].a[1]; }
int bo_sdm(struct s10 *q) { return q[-4096].a[1]; }
int bo_ser(struct s10 *q) { return gsb[6553].a[1]; }
void bo_sew(struct s10 *q) { gsb[6553].a[1] = 5; }
struct s10 * bo_sea(struct s10 *q) { return &gsb[6553]; }
int bo_sep(struct s10 *q) { return q[6553].a[1]; }
int bo_sel(struct s10 *q) { int t = 6553; return gsb[t].a[1]; }
int bo_seu(struct s10 *q) { return gsb[6553u].a[1]; }
int bo_sem(struct s10 *q) { return q[-6553].a[1]; }
int bo_sfr(struct s10 *q) { return gsb[6553].a[1]; }
void bo_sfw(struct s10 *q) { gsb[6553].a[1] = 5; }
struct s10 * bo_sfa(struct s10 *q) { return &gsb[6553]; }
int bo_sfp(struct s10 *q) { return q[6553].a[1]; }
int bo_sfl(struct s10 *q) { int t = 6553; return gsb[t].a[1]; }
int bo_sfu(struct s10 *q) { return gsb[6553u].a[1]; }
int bo_sfm(struct s10 *q) { return q[-6553].a[1]; }
int bo_sgr(struct s10 *q) { return gsb[7456].a[1]; }
void bo_sgw(struct s10 *q) { gsb[7456].a[1] = 5; }
struct s10 * bo_sga(struct s10 *q) { return &gsb[7456]; }
int bo_sgp(struct s10 *q) { return q[7456].a[1]; }
int bo_sgl(struct s10 *q) { int t = 7456; return gsb[t].a[1]; }
int bo_sgu(struct s10 *q) { return gsb[7456u].a[1]; }
int bo_shr(struct s10 *q) { return gsb[13106].a[1]; }
void bo_shw(struct s10 *q) { gsb[13106].a[1] = 5; }
struct s10 * bo_sha(struct s10 *q) { return &gsb[13106]; }
int bo_shp(struct s10 *q) { return q[13106].a[1]; }
int bo_shl(struct s10 *q) { int t = 13106; return gsb[t].a[1]; }
int bo_shu(struct s10 *q) { return gsb[13106u].a[1]; }
long bo_lx_cast(long *q) { int t = (int)36768UL; return q[t]; }
