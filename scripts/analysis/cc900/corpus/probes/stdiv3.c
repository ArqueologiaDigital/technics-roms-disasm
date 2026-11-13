/* A store of a division or a remainder with an element at a variable index (gen_stdiv3.py):
   sd3_<t>_<op>_<I>_<L><A><B>(c, d, e) { L = A op B; } for t = i int, u unsigned int, c char; op d (/) or m (%).
   I, the index: p the int parameter c, u the unsigned parameter e, q a char local kept across a call, r a char
   local with no call, l a for-loop counter.  L: G g<t>, D gps->m, E g<t>a[3], X g<t>a[I], P *g<t>p.
   A: G h<t>, K 100, E h<t>a[2], D hps->m, R the parameter d, X h<t>a[I].  B: X k<t>a[I], or G k<t> / K 7 when A is X. */
struct sv { char c; int i; unsigned int u; };
extern struct sv gs, hs, ks, *gps, *hps, *kps;
extern char jc; extern void f0(void);
extern int gi, hi, ki, gia[8], hia[8], kia[8], *gip;
extern unsigned int gu, hu, ku, gua[8], hua[8], kua[8], *gup;
extern char gc, hc, kc, gca[8], hca[8], kca[8], *gcp;

void sd3_i_d_p_GGX(int c, int d, unsigned int e) { gi = hi / kia[c]; }
void sd3_i_d_p_GKX(int c, int d, unsigned int e) { gi = 100 / kia[c]; }
void sd3_i_d_p_GEX(int c, int d, unsigned int e) { gi = hia[2] / kia[c]; }
void sd3_i_d_p_GDX(int c, int d, unsigned int e) { gi = hps->i / kia[c]; }
void sd3_i_d_p_GRX(int c, int d, unsigned int e) { gi = d / kia[c]; }
void sd3_i_d_p_GXX(int c, int d, unsigned int e) { gi = hia[c] / kia[c]; }
void sd3_i_d_p_GXG(int c, int d, unsigned int e) { gi = hia[c] / ki; }
void sd3_i_d_p_GXK(int c, int d, unsigned int e) { gi = hia[c] / 7; }
void sd3_i_d_p_DGX(int c, int d, unsigned int e) { gps->i = hi / kia[c]; }
void sd3_i_d_p_DKX(int c, int d, unsigned int e) { gps->i = 100 / kia[c]; }
void sd3_i_d_p_DEX(int c, int d, unsigned int e) { gps->i = hia[2] / kia[c]; }
void sd3_i_d_p_DDX(int c, int d, unsigned int e) { gps->i = hps->i / kia[c]; }
void sd3_i_d_p_DRX(int c, int d, unsigned int e) { gps->i = d / kia[c]; }
void sd3_i_d_p_DXX(int c, int d, unsigned int e) { gps->i = hia[c] / kia[c]; }
void sd3_i_d_p_DXG(int c, int d, unsigned int e) { gps->i = hia[c] / ki; }
void sd3_i_d_p_DXK(int c, int d, unsigned int e) { gps->i = hia[c] / 7; }
void sd3_i_d_p_EGX(int c, int d, unsigned int e) { gia[3] = hi / kia[c]; }
void sd3_i_d_p_EKX(int c, int d, unsigned int e) { gia[3] = 100 / kia[c]; }
void sd3_i_d_p_EEX(int c, int d, unsigned int e) { gia[3] = hia[2] / kia[c]; }
void sd3_i_d_p_EDX(int c, int d, unsigned int e) { gia[3] = hps->i / kia[c]; }
void sd3_i_d_p_ERX(int c, int d, unsigned int e) { gia[3] = d / kia[c]; }
void sd3_i_d_p_EXX(int c, int d, unsigned int e) { gia[3] = hia[c] / kia[c]; }
void sd3_i_d_p_EXG(int c, int d, unsigned int e) { gia[3] = hia[c] / ki; }
void sd3_i_d_p_EXK(int c, int d, unsigned int e) { gia[3] = hia[c] / 7; }
void sd3_i_d_p_XGX(int c, int d, unsigned int e) { gia[c] = hi / kia[c]; }
void sd3_i_d_p_XKX(int c, int d, unsigned int e) { gia[c] = 100 / kia[c]; }
void sd3_i_d_p_XEX(int c, int d, unsigned int e) { gia[c] = hia[2] / kia[c]; }
void sd3_i_d_p_XDX(int c, int d, unsigned int e) { gia[c] = hps->i / kia[c]; }
void sd3_i_d_p_XRX(int c, int d, unsigned int e) { gia[c] = d / kia[c]; }
void sd3_i_d_p_XXX(int c, int d, unsigned int e) { gia[c] = hia[c] / kia[c]; }
void sd3_i_d_p_XXG(int c, int d, unsigned int e) { gia[c] = hia[c] / ki; }
void sd3_i_d_p_XXK(int c, int d, unsigned int e) { gia[c] = hia[c] / 7; }
void sd3_i_d_p_PGX(int c, int d, unsigned int e) { *gip = hi / kia[c]; }
void sd3_i_d_p_PKX(int c, int d, unsigned int e) { *gip = 100 / kia[c]; }
void sd3_i_d_p_PEX(int c, int d, unsigned int e) { *gip = hia[2] / kia[c]; }
void sd3_i_d_p_PDX(int c, int d, unsigned int e) { *gip = hps->i / kia[c]; }
void sd3_i_d_p_PRX(int c, int d, unsigned int e) { *gip = d / kia[c]; }
void sd3_i_d_p_PXX(int c, int d, unsigned int e) { *gip = hia[c] / kia[c]; }
void sd3_i_d_p_PXG(int c, int d, unsigned int e) { *gip = hia[c] / ki; }
void sd3_i_d_p_PXK(int c, int d, unsigned int e) { *gip = hia[c] / 7; }
void sd3_i_d_u_GGX(int c, int d, unsigned int e) { gi = hi / kia[e]; }
void sd3_i_d_u_GKX(int c, int d, unsigned int e) { gi = 100 / kia[e]; }
void sd3_i_d_u_GEX(int c, int d, unsigned int e) { gi = hia[2] / kia[e]; }
void sd3_i_d_u_GDX(int c, int d, unsigned int e) { gi = hps->i / kia[e]; }
void sd3_i_d_u_GRX(int c, int d, unsigned int e) { gi = d / kia[e]; }
void sd3_i_d_u_GXX(int c, int d, unsigned int e) { gi = hia[e] / kia[e]; }
void sd3_i_d_u_GXG(int c, int d, unsigned int e) { gi = hia[e] / ki; }
void sd3_i_d_u_GXK(int c, int d, unsigned int e) { gi = hia[e] / 7; }
void sd3_i_d_u_DGX(int c, int d, unsigned int e) { gps->i = hi / kia[e]; }
void sd3_i_d_u_DKX(int c, int d, unsigned int e) { gps->i = 100 / kia[e]; }
void sd3_i_d_u_DEX(int c, int d, unsigned int e) { gps->i = hia[2] / kia[e]; }
void sd3_i_d_u_DDX(int c, int d, unsigned int e) { gps->i = hps->i / kia[e]; }
void sd3_i_d_u_DRX(int c, int d, unsigned int e) { gps->i = d / kia[e]; }
void sd3_i_d_u_DXX(int c, int d, unsigned int e) { gps->i = hia[e] / kia[e]; }
void sd3_i_d_u_DXG(int c, int d, unsigned int e) { gps->i = hia[e] / ki; }
void sd3_i_d_u_DXK(int c, int d, unsigned int e) { gps->i = hia[e] / 7; }
void sd3_i_d_u_EGX(int c, int d, unsigned int e) { gia[3] = hi / kia[e]; }
void sd3_i_d_u_EKX(int c, int d, unsigned int e) { gia[3] = 100 / kia[e]; }
void sd3_i_d_u_EEX(int c, int d, unsigned int e) { gia[3] = hia[2] / kia[e]; }
void sd3_i_d_u_EDX(int c, int d, unsigned int e) { gia[3] = hps->i / kia[e]; }
void sd3_i_d_u_ERX(int c, int d, unsigned int e) { gia[3] = d / kia[e]; }
void sd3_i_d_u_EXX(int c, int d, unsigned int e) { gia[3] = hia[e] / kia[e]; }
void sd3_i_d_u_EXG(int c, int d, unsigned int e) { gia[3] = hia[e] / ki; }
void sd3_i_d_u_EXK(int c, int d, unsigned int e) { gia[3] = hia[e] / 7; }
void sd3_i_d_u_XGX(int c, int d, unsigned int e) { gia[e] = hi / kia[e]; }
void sd3_i_d_u_XKX(int c, int d, unsigned int e) { gia[e] = 100 / kia[e]; }
void sd3_i_d_u_XEX(int c, int d, unsigned int e) { gia[e] = hia[2] / kia[e]; }
void sd3_i_d_u_XDX(int c, int d, unsigned int e) { gia[e] = hps->i / kia[e]; }
void sd3_i_d_u_XRX(int c, int d, unsigned int e) { gia[e] = d / kia[e]; }
void sd3_i_d_u_XXX(int c, int d, unsigned int e) { gia[e] = hia[e] / kia[e]; }
void sd3_i_d_u_XXG(int c, int d, unsigned int e) { gia[e] = hia[e] / ki; }
void sd3_i_d_u_XXK(int c, int d, unsigned int e) { gia[e] = hia[e] / 7; }
void sd3_i_d_u_PGX(int c, int d, unsigned int e) { *gip = hi / kia[e]; }
void sd3_i_d_u_PKX(int c, int d, unsigned int e) { *gip = 100 / kia[e]; }
void sd3_i_d_u_PEX(int c, int d, unsigned int e) { *gip = hia[2] / kia[e]; }
void sd3_i_d_u_PDX(int c, int d, unsigned int e) { *gip = hps->i / kia[e]; }
void sd3_i_d_u_PRX(int c, int d, unsigned int e) { *gip = d / kia[e]; }
void sd3_i_d_u_PXX(int c, int d, unsigned int e) { *gip = hia[e] / kia[e]; }
void sd3_i_d_u_PXG(int c, int d, unsigned int e) { *gip = hia[e] / ki; }
void sd3_i_d_u_PXK(int c, int d, unsigned int e) { *gip = hia[e] / 7; }
void sd3_i_d_q_GGX(int c, int d, unsigned int e) { char t = jc; f0(); gi = hi / kia[t]; }
void sd3_i_d_q_GKX(int c, int d, unsigned int e) { char t = jc; f0(); gi = 100 / kia[t]; }
void sd3_i_d_q_GEX(int c, int d, unsigned int e) { char t = jc; f0(); gi = hia[2] / kia[t]; }
void sd3_i_d_q_GDX(int c, int d, unsigned int e) { char t = jc; f0(); gi = hps->i / kia[t]; }
void sd3_i_d_q_GRX(int c, int d, unsigned int e) { char t = jc; f0(); gi = d / kia[t]; }
void sd3_i_d_q_GXX(int c, int d, unsigned int e) { char t = jc; f0(); gi = hia[t] / kia[t]; }
void sd3_i_d_q_GXG(int c, int d, unsigned int e) { char t = jc; f0(); gi = hia[t] / ki; }
void sd3_i_d_q_GXK(int c, int d, unsigned int e) { char t = jc; f0(); gi = hia[t] / 7; }
void sd3_i_d_q_DGX(int c, int d, unsigned int e) { char t = jc; f0(); gps->i = hi / kia[t]; }
void sd3_i_d_q_DKX(int c, int d, unsigned int e) { char t = jc; f0(); gps->i = 100 / kia[t]; }
void sd3_i_d_q_DEX(int c, int d, unsigned int e) { char t = jc; f0(); gps->i = hia[2] / kia[t]; }
void sd3_i_d_q_DDX(int c, int d, unsigned int e) { char t = jc; f0(); gps->i = hps->i / kia[t]; }
void sd3_i_d_q_DRX(int c, int d, unsigned int e) { char t = jc; f0(); gps->i = d / kia[t]; }
void sd3_i_d_q_DXX(int c, int d, unsigned int e) { char t = jc; f0(); gps->i = hia[t] / kia[t]; }
void sd3_i_d_q_DXG(int c, int d, unsigned int e) { char t = jc; f0(); gps->i = hia[t] / ki; }
void sd3_i_d_q_DXK(int c, int d, unsigned int e) { char t = jc; f0(); gps->i = hia[t] / 7; }
void sd3_i_d_q_EGX(int c, int d, unsigned int e) { char t = jc; f0(); gia[3] = hi / kia[t]; }
void sd3_i_d_q_EKX(int c, int d, unsigned int e) { char t = jc; f0(); gia[3] = 100 / kia[t]; }
void sd3_i_d_q_EEX(int c, int d, unsigned int e) { char t = jc; f0(); gia[3] = hia[2] / kia[t]; }
void sd3_i_d_q_EDX(int c, int d, unsigned int e) { char t = jc; f0(); gia[3] = hps->i / kia[t]; }
void sd3_i_d_q_ERX(int c, int d, unsigned int e) { char t = jc; f0(); gia[3] = d / kia[t]; }
void sd3_i_d_q_EXX(int c, int d, unsigned int e) { char t = jc; f0(); gia[3] = hia[t] / kia[t]; }
void sd3_i_d_q_EXG(int c, int d, unsigned int e) { char t = jc; f0(); gia[3] = hia[t] / ki; }
void sd3_i_d_q_EXK(int c, int d, unsigned int e) { char t = jc; f0(); gia[3] = hia[t] / 7; }
void sd3_i_d_q_XGX(int c, int d, unsigned int e) { char t = jc; f0(); gia[t] = hi / kia[t]; }
void sd3_i_d_q_XKX(int c, int d, unsigned int e) { char t = jc; f0(); gia[t] = 100 / kia[t]; }
void sd3_i_d_q_XEX(int c, int d, unsigned int e) { char t = jc; f0(); gia[t] = hia[2] / kia[t]; }
void sd3_i_d_q_XDX(int c, int d, unsigned int e) { char t = jc; f0(); gia[t] = hps->i / kia[t]; }
void sd3_i_d_q_XRX(int c, int d, unsigned int e) { char t = jc; f0(); gia[t] = d / kia[t]; }
void sd3_i_d_q_XXX(int c, int d, unsigned int e) { char t = jc; f0(); gia[t] = hia[t] / kia[t]; }
void sd3_i_d_q_XXG(int c, int d, unsigned int e) { char t = jc; f0(); gia[t] = hia[t] / ki; }
void sd3_i_d_q_XXK(int c, int d, unsigned int e) { char t = jc; f0(); gia[t] = hia[t] / 7; }
void sd3_i_d_q_PGX(int c, int d, unsigned int e) { char t = jc; f0(); *gip = hi / kia[t]; }
void sd3_i_d_q_PKX(int c, int d, unsigned int e) { char t = jc; f0(); *gip = 100 / kia[t]; }
void sd3_i_d_q_PEX(int c, int d, unsigned int e) { char t = jc; f0(); *gip = hia[2] / kia[t]; }
void sd3_i_d_q_PDX(int c, int d, unsigned int e) { char t = jc; f0(); *gip = hps->i / kia[t]; }
void sd3_i_d_q_PRX(int c, int d, unsigned int e) { char t = jc; f0(); *gip = d / kia[t]; }
void sd3_i_d_q_PXX(int c, int d, unsigned int e) { char t = jc; f0(); *gip = hia[t] / kia[t]; }
void sd3_i_d_q_PXG(int c, int d, unsigned int e) { char t = jc; f0(); *gip = hia[t] / ki; }
void sd3_i_d_q_PXK(int c, int d, unsigned int e) { char t = jc; f0(); *gip = hia[t] / 7; }
void sd3_i_d_r_GGX(int c, int d, unsigned int e) { char t = jc; gi = hi / kia[t]; }
void sd3_i_d_r_GKX(int c, int d, unsigned int e) { char t = jc; gi = 100 / kia[t]; }
void sd3_i_d_r_GEX(int c, int d, unsigned int e) { char t = jc; gi = hia[2] / kia[t]; }
void sd3_i_d_r_GDX(int c, int d, unsigned int e) { char t = jc; gi = hps->i / kia[t]; }
void sd3_i_d_r_GRX(int c, int d, unsigned int e) { char t = jc; gi = d / kia[t]; }
void sd3_i_d_r_GXX(int c, int d, unsigned int e) { char t = jc; gi = hia[t] / kia[t]; }
void sd3_i_d_r_GXG(int c, int d, unsigned int e) { char t = jc; gi = hia[t] / ki; }
void sd3_i_d_r_GXK(int c, int d, unsigned int e) { char t = jc; gi = hia[t] / 7; }
void sd3_i_d_r_DGX(int c, int d, unsigned int e) { char t = jc; gps->i = hi / kia[t]; }
void sd3_i_d_r_DKX(int c, int d, unsigned int e) { char t = jc; gps->i = 100 / kia[t]; }
void sd3_i_d_r_DEX(int c, int d, unsigned int e) { char t = jc; gps->i = hia[2] / kia[t]; }
void sd3_i_d_r_DDX(int c, int d, unsigned int e) { char t = jc; gps->i = hps->i / kia[t]; }
void sd3_i_d_r_DRX(int c, int d, unsigned int e) { char t = jc; gps->i = d / kia[t]; }
void sd3_i_d_r_DXX(int c, int d, unsigned int e) { char t = jc; gps->i = hia[t] / kia[t]; }
void sd3_i_d_r_DXG(int c, int d, unsigned int e) { char t = jc; gps->i = hia[t] / ki; }
void sd3_i_d_r_DXK(int c, int d, unsigned int e) { char t = jc; gps->i = hia[t] / 7; }
void sd3_i_d_r_EGX(int c, int d, unsigned int e) { char t = jc; gia[3] = hi / kia[t]; }
void sd3_i_d_r_EKX(int c, int d, unsigned int e) { char t = jc; gia[3] = 100 / kia[t]; }
void sd3_i_d_r_EEX(int c, int d, unsigned int e) { char t = jc; gia[3] = hia[2] / kia[t]; }
void sd3_i_d_r_EDX(int c, int d, unsigned int e) { char t = jc; gia[3] = hps->i / kia[t]; }
void sd3_i_d_r_ERX(int c, int d, unsigned int e) { char t = jc; gia[3] = d / kia[t]; }
void sd3_i_d_r_EXX(int c, int d, unsigned int e) { char t = jc; gia[3] = hia[t] / kia[t]; }
void sd3_i_d_r_EXG(int c, int d, unsigned int e) { char t = jc; gia[3] = hia[t] / ki; }
void sd3_i_d_r_EXK(int c, int d, unsigned int e) { char t = jc; gia[3] = hia[t] / 7; }
void sd3_i_d_r_XGX(int c, int d, unsigned int e) { char t = jc; gia[t] = hi / kia[t]; }
void sd3_i_d_r_XKX(int c, int d, unsigned int e) { char t = jc; gia[t] = 100 / kia[t]; }
void sd3_i_d_r_XEX(int c, int d, unsigned int e) { char t = jc; gia[t] = hia[2] / kia[t]; }
void sd3_i_d_r_XDX(int c, int d, unsigned int e) { char t = jc; gia[t] = hps->i / kia[t]; }
void sd3_i_d_r_XRX(int c, int d, unsigned int e) { char t = jc; gia[t] = d / kia[t]; }
void sd3_i_d_r_XXX(int c, int d, unsigned int e) { char t = jc; gia[t] = hia[t] / kia[t]; }
void sd3_i_d_r_XXG(int c, int d, unsigned int e) { char t = jc; gia[t] = hia[t] / ki; }
void sd3_i_d_r_XXK(int c, int d, unsigned int e) { char t = jc; gia[t] = hia[t] / 7; }
void sd3_i_d_r_PGX(int c, int d, unsigned int e) { char t = jc; *gip = hi / kia[t]; }
void sd3_i_d_r_PKX(int c, int d, unsigned int e) { char t = jc; *gip = 100 / kia[t]; }
void sd3_i_d_r_PEX(int c, int d, unsigned int e) { char t = jc; *gip = hia[2] / kia[t]; }
void sd3_i_d_r_PDX(int c, int d, unsigned int e) { char t = jc; *gip = hps->i / kia[t]; }
void sd3_i_d_r_PRX(int c, int d, unsigned int e) { char t = jc; *gip = d / kia[t]; }
void sd3_i_d_r_PXX(int c, int d, unsigned int e) { char t = jc; *gip = hia[t] / kia[t]; }
void sd3_i_d_r_PXG(int c, int d, unsigned int e) { char t = jc; *gip = hia[t] / ki; }
void sd3_i_d_r_PXK(int c, int d, unsigned int e) { char t = jc; *gip = hia[t] / 7; }
void sd3_i_d_l_GGX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gi = hi / kia[i]; }
void sd3_i_d_l_GKX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gi = 100 / kia[i]; }
void sd3_i_d_l_GEX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gi = hia[2] / kia[i]; }
void sd3_i_d_l_GDX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gi = hps->i / kia[i]; }
void sd3_i_d_l_GRX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gi = d / kia[i]; }
void sd3_i_d_l_GXX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gi = hia[i] / kia[i]; }
void sd3_i_d_l_GXG(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gi = hia[i] / ki; }
void sd3_i_d_l_GXK(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gi = hia[i] / 7; }
void sd3_i_d_l_DGX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->i = hi / kia[i]; }
void sd3_i_d_l_DKX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->i = 100 / kia[i]; }
void sd3_i_d_l_DEX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->i = hia[2] / kia[i]; }
void sd3_i_d_l_DDX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->i = hps->i / kia[i]; }
void sd3_i_d_l_DRX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->i = d / kia[i]; }
void sd3_i_d_l_DXX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->i = hia[i] / kia[i]; }
void sd3_i_d_l_DXG(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->i = hia[i] / ki; }
void sd3_i_d_l_DXK(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->i = hia[i] / 7; }
void sd3_i_d_l_EGX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[3] = hi / kia[i]; }
void sd3_i_d_l_EKX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[3] = 100 / kia[i]; }
void sd3_i_d_l_EEX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[3] = hia[2] / kia[i]; }
void sd3_i_d_l_EDX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[3] = hps->i / kia[i]; }
void sd3_i_d_l_ERX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[3] = d / kia[i]; }
void sd3_i_d_l_EXX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[3] = hia[i] / kia[i]; }
void sd3_i_d_l_EXG(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[3] = hia[i] / ki; }
void sd3_i_d_l_EXK(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[3] = hia[i] / 7; }
void sd3_i_d_l_XGX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[i] = hi / kia[i]; }
void sd3_i_d_l_XKX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[i] = 100 / kia[i]; }
void sd3_i_d_l_XEX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[i] = hia[2] / kia[i]; }
void sd3_i_d_l_XDX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[i] = hps->i / kia[i]; }
void sd3_i_d_l_XRX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[i] = d / kia[i]; }
void sd3_i_d_l_XXX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[i] = hia[i] / kia[i]; }
void sd3_i_d_l_XXG(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[i] = hia[i] / ki; }
void sd3_i_d_l_XXK(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[i] = hia[i] / 7; }
void sd3_i_d_l_PGX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gip = hi / kia[i]; }
void sd3_i_d_l_PKX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gip = 100 / kia[i]; }
void sd3_i_d_l_PEX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gip = hia[2] / kia[i]; }
void sd3_i_d_l_PDX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gip = hps->i / kia[i]; }
void sd3_i_d_l_PRX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gip = d / kia[i]; }
void sd3_i_d_l_PXX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gip = hia[i] / kia[i]; }
void sd3_i_d_l_PXG(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gip = hia[i] / ki; }
void sd3_i_d_l_PXK(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gip = hia[i] / 7; }
void sd3_i_m_p_GGX(int c, int d, unsigned int e) { gi = hi % kia[c]; }
void sd3_i_m_p_GKX(int c, int d, unsigned int e) { gi = 100 % kia[c]; }
void sd3_i_m_p_GEX(int c, int d, unsigned int e) { gi = hia[2] % kia[c]; }
void sd3_i_m_p_GDX(int c, int d, unsigned int e) { gi = hps->i % kia[c]; }
void sd3_i_m_p_GRX(int c, int d, unsigned int e) { gi = d % kia[c]; }
void sd3_i_m_p_GXX(int c, int d, unsigned int e) { gi = hia[c] % kia[c]; }
void sd3_i_m_p_GXG(int c, int d, unsigned int e) { gi = hia[c] % ki; }
void sd3_i_m_p_GXK(int c, int d, unsigned int e) { gi = hia[c] % 7; }
void sd3_i_m_p_DGX(int c, int d, unsigned int e) { gps->i = hi % kia[c]; }
void sd3_i_m_p_DKX(int c, int d, unsigned int e) { gps->i = 100 % kia[c]; }
void sd3_i_m_p_DEX(int c, int d, unsigned int e) { gps->i = hia[2] % kia[c]; }
void sd3_i_m_p_DDX(int c, int d, unsigned int e) { gps->i = hps->i % kia[c]; }
void sd3_i_m_p_DRX(int c, int d, unsigned int e) { gps->i = d % kia[c]; }
void sd3_i_m_p_DXX(int c, int d, unsigned int e) { gps->i = hia[c] % kia[c]; }
void sd3_i_m_p_DXG(int c, int d, unsigned int e) { gps->i = hia[c] % ki; }
void sd3_i_m_p_DXK(int c, int d, unsigned int e) { gps->i = hia[c] % 7; }
void sd3_i_m_p_EGX(int c, int d, unsigned int e) { gia[3] = hi % kia[c]; }
void sd3_i_m_p_EKX(int c, int d, unsigned int e) { gia[3] = 100 % kia[c]; }
void sd3_i_m_p_EEX(int c, int d, unsigned int e) { gia[3] = hia[2] % kia[c]; }
void sd3_i_m_p_EDX(int c, int d, unsigned int e) { gia[3] = hps->i % kia[c]; }
void sd3_i_m_p_ERX(int c, int d, unsigned int e) { gia[3] = d % kia[c]; }
void sd3_i_m_p_EXX(int c, int d, unsigned int e) { gia[3] = hia[c] % kia[c]; }
void sd3_i_m_p_EXG(int c, int d, unsigned int e) { gia[3] = hia[c] % ki; }
void sd3_i_m_p_EXK(int c, int d, unsigned int e) { gia[3] = hia[c] % 7; }
void sd3_i_m_p_XGX(int c, int d, unsigned int e) { gia[c] = hi % kia[c]; }
void sd3_i_m_p_XKX(int c, int d, unsigned int e) { gia[c] = 100 % kia[c]; }
void sd3_i_m_p_XEX(int c, int d, unsigned int e) { gia[c] = hia[2] % kia[c]; }
void sd3_i_m_p_XDX(int c, int d, unsigned int e) { gia[c] = hps->i % kia[c]; }
void sd3_i_m_p_XRX(int c, int d, unsigned int e) { gia[c] = d % kia[c]; }
void sd3_i_m_p_XXX(int c, int d, unsigned int e) { gia[c] = hia[c] % kia[c]; }
void sd3_i_m_p_XXG(int c, int d, unsigned int e) { gia[c] = hia[c] % ki; }
void sd3_i_m_p_XXK(int c, int d, unsigned int e) { gia[c] = hia[c] % 7; }
void sd3_i_m_p_PGX(int c, int d, unsigned int e) { *gip = hi % kia[c]; }
void sd3_i_m_p_PKX(int c, int d, unsigned int e) { *gip = 100 % kia[c]; }
void sd3_i_m_p_PEX(int c, int d, unsigned int e) { *gip = hia[2] % kia[c]; }
void sd3_i_m_p_PDX(int c, int d, unsigned int e) { *gip = hps->i % kia[c]; }
void sd3_i_m_p_PRX(int c, int d, unsigned int e) { *gip = d % kia[c]; }
void sd3_i_m_p_PXX(int c, int d, unsigned int e) { *gip = hia[c] % kia[c]; }
void sd3_i_m_p_PXG(int c, int d, unsigned int e) { *gip = hia[c] % ki; }
void sd3_i_m_p_PXK(int c, int d, unsigned int e) { *gip = hia[c] % 7; }
void sd3_i_m_u_GGX(int c, int d, unsigned int e) { gi = hi % kia[e]; }
void sd3_i_m_u_GKX(int c, int d, unsigned int e) { gi = 100 % kia[e]; }
void sd3_i_m_u_GEX(int c, int d, unsigned int e) { gi = hia[2] % kia[e]; }
void sd3_i_m_u_GDX(int c, int d, unsigned int e) { gi = hps->i % kia[e]; }
void sd3_i_m_u_GRX(int c, int d, unsigned int e) { gi = d % kia[e]; }
void sd3_i_m_u_GXX(int c, int d, unsigned int e) { gi = hia[e] % kia[e]; }
void sd3_i_m_u_GXG(int c, int d, unsigned int e) { gi = hia[e] % ki; }
void sd3_i_m_u_GXK(int c, int d, unsigned int e) { gi = hia[e] % 7; }
void sd3_i_m_u_DGX(int c, int d, unsigned int e) { gps->i = hi % kia[e]; }
void sd3_i_m_u_DKX(int c, int d, unsigned int e) { gps->i = 100 % kia[e]; }
void sd3_i_m_u_DEX(int c, int d, unsigned int e) { gps->i = hia[2] % kia[e]; }
void sd3_i_m_u_DDX(int c, int d, unsigned int e) { gps->i = hps->i % kia[e]; }
void sd3_i_m_u_DRX(int c, int d, unsigned int e) { gps->i = d % kia[e]; }
void sd3_i_m_u_DXX(int c, int d, unsigned int e) { gps->i = hia[e] % kia[e]; }
void sd3_i_m_u_DXG(int c, int d, unsigned int e) { gps->i = hia[e] % ki; }
void sd3_i_m_u_DXK(int c, int d, unsigned int e) { gps->i = hia[e] % 7; }
void sd3_i_m_u_EGX(int c, int d, unsigned int e) { gia[3] = hi % kia[e]; }
void sd3_i_m_u_EKX(int c, int d, unsigned int e) { gia[3] = 100 % kia[e]; }
void sd3_i_m_u_EEX(int c, int d, unsigned int e) { gia[3] = hia[2] % kia[e]; }
void sd3_i_m_u_EDX(int c, int d, unsigned int e) { gia[3] = hps->i % kia[e]; }
void sd3_i_m_u_ERX(int c, int d, unsigned int e) { gia[3] = d % kia[e]; }
void sd3_i_m_u_EXX(int c, int d, unsigned int e) { gia[3] = hia[e] % kia[e]; }
void sd3_i_m_u_EXG(int c, int d, unsigned int e) { gia[3] = hia[e] % ki; }
void sd3_i_m_u_EXK(int c, int d, unsigned int e) { gia[3] = hia[e] % 7; }
void sd3_i_m_u_XGX(int c, int d, unsigned int e) { gia[e] = hi % kia[e]; }
void sd3_i_m_u_XKX(int c, int d, unsigned int e) { gia[e] = 100 % kia[e]; }
void sd3_i_m_u_XEX(int c, int d, unsigned int e) { gia[e] = hia[2] % kia[e]; }
void sd3_i_m_u_XDX(int c, int d, unsigned int e) { gia[e] = hps->i % kia[e]; }
void sd3_i_m_u_XRX(int c, int d, unsigned int e) { gia[e] = d % kia[e]; }
void sd3_i_m_u_XXX(int c, int d, unsigned int e) { gia[e] = hia[e] % kia[e]; }
void sd3_i_m_u_XXG(int c, int d, unsigned int e) { gia[e] = hia[e] % ki; }
void sd3_i_m_u_XXK(int c, int d, unsigned int e) { gia[e] = hia[e] % 7; }
void sd3_i_m_u_PGX(int c, int d, unsigned int e) { *gip = hi % kia[e]; }
void sd3_i_m_u_PKX(int c, int d, unsigned int e) { *gip = 100 % kia[e]; }
void sd3_i_m_u_PEX(int c, int d, unsigned int e) { *gip = hia[2] % kia[e]; }
void sd3_i_m_u_PDX(int c, int d, unsigned int e) { *gip = hps->i % kia[e]; }
void sd3_i_m_u_PRX(int c, int d, unsigned int e) { *gip = d % kia[e]; }
void sd3_i_m_u_PXX(int c, int d, unsigned int e) { *gip = hia[e] % kia[e]; }
void sd3_i_m_u_PXG(int c, int d, unsigned int e) { *gip = hia[e] % ki; }
void sd3_i_m_u_PXK(int c, int d, unsigned int e) { *gip = hia[e] % 7; }
void sd3_i_m_q_GGX(int c, int d, unsigned int e) { char t = jc; f0(); gi = hi % kia[t]; }
void sd3_i_m_q_GKX(int c, int d, unsigned int e) { char t = jc; f0(); gi = 100 % kia[t]; }
void sd3_i_m_q_GEX(int c, int d, unsigned int e) { char t = jc; f0(); gi = hia[2] % kia[t]; }
void sd3_i_m_q_GDX(int c, int d, unsigned int e) { char t = jc; f0(); gi = hps->i % kia[t]; }
void sd3_i_m_q_GRX(int c, int d, unsigned int e) { char t = jc; f0(); gi = d % kia[t]; }
void sd3_i_m_q_GXX(int c, int d, unsigned int e) { char t = jc; f0(); gi = hia[t] % kia[t]; }
void sd3_i_m_q_GXG(int c, int d, unsigned int e) { char t = jc; f0(); gi = hia[t] % ki; }
void sd3_i_m_q_GXK(int c, int d, unsigned int e) { char t = jc; f0(); gi = hia[t] % 7; }
void sd3_i_m_q_DGX(int c, int d, unsigned int e) { char t = jc; f0(); gps->i = hi % kia[t]; }
void sd3_i_m_q_DKX(int c, int d, unsigned int e) { char t = jc; f0(); gps->i = 100 % kia[t]; }
void sd3_i_m_q_DEX(int c, int d, unsigned int e) { char t = jc; f0(); gps->i = hia[2] % kia[t]; }
void sd3_i_m_q_DDX(int c, int d, unsigned int e) { char t = jc; f0(); gps->i = hps->i % kia[t]; }
void sd3_i_m_q_DRX(int c, int d, unsigned int e) { char t = jc; f0(); gps->i = d % kia[t]; }
void sd3_i_m_q_DXX(int c, int d, unsigned int e) { char t = jc; f0(); gps->i = hia[t] % kia[t]; }
void sd3_i_m_q_DXG(int c, int d, unsigned int e) { char t = jc; f0(); gps->i = hia[t] % ki; }
void sd3_i_m_q_DXK(int c, int d, unsigned int e) { char t = jc; f0(); gps->i = hia[t] % 7; }
void sd3_i_m_q_EGX(int c, int d, unsigned int e) { char t = jc; f0(); gia[3] = hi % kia[t]; }
void sd3_i_m_q_EKX(int c, int d, unsigned int e) { char t = jc; f0(); gia[3] = 100 % kia[t]; }
void sd3_i_m_q_EEX(int c, int d, unsigned int e) { char t = jc; f0(); gia[3] = hia[2] % kia[t]; }
void sd3_i_m_q_EDX(int c, int d, unsigned int e) { char t = jc; f0(); gia[3] = hps->i % kia[t]; }
void sd3_i_m_q_ERX(int c, int d, unsigned int e) { char t = jc; f0(); gia[3] = d % kia[t]; }
void sd3_i_m_q_EXX(int c, int d, unsigned int e) { char t = jc; f0(); gia[3] = hia[t] % kia[t]; }
void sd3_i_m_q_EXG(int c, int d, unsigned int e) { char t = jc; f0(); gia[3] = hia[t] % ki; }
void sd3_i_m_q_EXK(int c, int d, unsigned int e) { char t = jc; f0(); gia[3] = hia[t] % 7; }
void sd3_i_m_q_XGX(int c, int d, unsigned int e) { char t = jc; f0(); gia[t] = hi % kia[t]; }
void sd3_i_m_q_XKX(int c, int d, unsigned int e) { char t = jc; f0(); gia[t] = 100 % kia[t]; }
void sd3_i_m_q_XEX(int c, int d, unsigned int e) { char t = jc; f0(); gia[t] = hia[2] % kia[t]; }
void sd3_i_m_q_XDX(int c, int d, unsigned int e) { char t = jc; f0(); gia[t] = hps->i % kia[t]; }
void sd3_i_m_q_XRX(int c, int d, unsigned int e) { char t = jc; f0(); gia[t] = d % kia[t]; }
void sd3_i_m_q_XXX(int c, int d, unsigned int e) { char t = jc; f0(); gia[t] = hia[t] % kia[t]; }
void sd3_i_m_q_XXG(int c, int d, unsigned int e) { char t = jc; f0(); gia[t] = hia[t] % ki; }
void sd3_i_m_q_XXK(int c, int d, unsigned int e) { char t = jc; f0(); gia[t] = hia[t] % 7; }
void sd3_i_m_q_PGX(int c, int d, unsigned int e) { char t = jc; f0(); *gip = hi % kia[t]; }
void sd3_i_m_q_PKX(int c, int d, unsigned int e) { char t = jc; f0(); *gip = 100 % kia[t]; }
void sd3_i_m_q_PEX(int c, int d, unsigned int e) { char t = jc; f0(); *gip = hia[2] % kia[t]; }
void sd3_i_m_q_PDX(int c, int d, unsigned int e) { char t = jc; f0(); *gip = hps->i % kia[t]; }
void sd3_i_m_q_PRX(int c, int d, unsigned int e) { char t = jc; f0(); *gip = d % kia[t]; }
void sd3_i_m_q_PXX(int c, int d, unsigned int e) { char t = jc; f0(); *gip = hia[t] % kia[t]; }
void sd3_i_m_q_PXG(int c, int d, unsigned int e) { char t = jc; f0(); *gip = hia[t] % ki; }
void sd3_i_m_q_PXK(int c, int d, unsigned int e) { char t = jc; f0(); *gip = hia[t] % 7; }
void sd3_i_m_r_GGX(int c, int d, unsigned int e) { char t = jc; gi = hi % kia[t]; }
void sd3_i_m_r_GKX(int c, int d, unsigned int e) { char t = jc; gi = 100 % kia[t]; }
void sd3_i_m_r_GEX(int c, int d, unsigned int e) { char t = jc; gi = hia[2] % kia[t]; }
void sd3_i_m_r_GDX(int c, int d, unsigned int e) { char t = jc; gi = hps->i % kia[t]; }
void sd3_i_m_r_GRX(int c, int d, unsigned int e) { char t = jc; gi = d % kia[t]; }
void sd3_i_m_r_GXX(int c, int d, unsigned int e) { char t = jc; gi = hia[t] % kia[t]; }
void sd3_i_m_r_GXG(int c, int d, unsigned int e) { char t = jc; gi = hia[t] % ki; }
void sd3_i_m_r_GXK(int c, int d, unsigned int e) { char t = jc; gi = hia[t] % 7; }
void sd3_i_m_r_DGX(int c, int d, unsigned int e) { char t = jc; gps->i = hi % kia[t]; }
void sd3_i_m_r_DKX(int c, int d, unsigned int e) { char t = jc; gps->i = 100 % kia[t]; }
void sd3_i_m_r_DEX(int c, int d, unsigned int e) { char t = jc; gps->i = hia[2] % kia[t]; }
void sd3_i_m_r_DDX(int c, int d, unsigned int e) { char t = jc; gps->i = hps->i % kia[t]; }
void sd3_i_m_r_DRX(int c, int d, unsigned int e) { char t = jc; gps->i = d % kia[t]; }
void sd3_i_m_r_DXX(int c, int d, unsigned int e) { char t = jc; gps->i = hia[t] % kia[t]; }
void sd3_i_m_r_DXG(int c, int d, unsigned int e) { char t = jc; gps->i = hia[t] % ki; }
void sd3_i_m_r_DXK(int c, int d, unsigned int e) { char t = jc; gps->i = hia[t] % 7; }
void sd3_i_m_r_EGX(int c, int d, unsigned int e) { char t = jc; gia[3] = hi % kia[t]; }
void sd3_i_m_r_EKX(int c, int d, unsigned int e) { char t = jc; gia[3] = 100 % kia[t]; }
void sd3_i_m_r_EEX(int c, int d, unsigned int e) { char t = jc; gia[3] = hia[2] % kia[t]; }
void sd3_i_m_r_EDX(int c, int d, unsigned int e) { char t = jc; gia[3] = hps->i % kia[t]; }
void sd3_i_m_r_ERX(int c, int d, unsigned int e) { char t = jc; gia[3] = d % kia[t]; }
void sd3_i_m_r_EXX(int c, int d, unsigned int e) { char t = jc; gia[3] = hia[t] % kia[t]; }
void sd3_i_m_r_EXG(int c, int d, unsigned int e) { char t = jc; gia[3] = hia[t] % ki; }
void sd3_i_m_r_EXK(int c, int d, unsigned int e) { char t = jc; gia[3] = hia[t] % 7; }
void sd3_i_m_r_XGX(int c, int d, unsigned int e) { char t = jc; gia[t] = hi % kia[t]; }
void sd3_i_m_r_XKX(int c, int d, unsigned int e) { char t = jc; gia[t] = 100 % kia[t]; }
void sd3_i_m_r_XEX(int c, int d, unsigned int e) { char t = jc; gia[t] = hia[2] % kia[t]; }
void sd3_i_m_r_XDX(int c, int d, unsigned int e) { char t = jc; gia[t] = hps->i % kia[t]; }
void sd3_i_m_r_XRX(int c, int d, unsigned int e) { char t = jc; gia[t] = d % kia[t]; }
void sd3_i_m_r_XXX(int c, int d, unsigned int e) { char t = jc; gia[t] = hia[t] % kia[t]; }
void sd3_i_m_r_XXG(int c, int d, unsigned int e) { char t = jc; gia[t] = hia[t] % ki; }
void sd3_i_m_r_XXK(int c, int d, unsigned int e) { char t = jc; gia[t] = hia[t] % 7; }
void sd3_i_m_r_PGX(int c, int d, unsigned int e) { char t = jc; *gip = hi % kia[t]; }
void sd3_i_m_r_PKX(int c, int d, unsigned int e) { char t = jc; *gip = 100 % kia[t]; }
void sd3_i_m_r_PEX(int c, int d, unsigned int e) { char t = jc; *gip = hia[2] % kia[t]; }
void sd3_i_m_r_PDX(int c, int d, unsigned int e) { char t = jc; *gip = hps->i % kia[t]; }
void sd3_i_m_r_PRX(int c, int d, unsigned int e) { char t = jc; *gip = d % kia[t]; }
void sd3_i_m_r_PXX(int c, int d, unsigned int e) { char t = jc; *gip = hia[t] % kia[t]; }
void sd3_i_m_r_PXG(int c, int d, unsigned int e) { char t = jc; *gip = hia[t] % ki; }
void sd3_i_m_r_PXK(int c, int d, unsigned int e) { char t = jc; *gip = hia[t] % 7; }
void sd3_i_m_l_GGX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gi = hi % kia[i]; }
void sd3_i_m_l_GKX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gi = 100 % kia[i]; }
void sd3_i_m_l_GEX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gi = hia[2] % kia[i]; }
void sd3_i_m_l_GDX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gi = hps->i % kia[i]; }
void sd3_i_m_l_GRX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gi = d % kia[i]; }
void sd3_i_m_l_GXX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gi = hia[i] % kia[i]; }
void sd3_i_m_l_GXG(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gi = hia[i] % ki; }
void sd3_i_m_l_GXK(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gi = hia[i] % 7; }
void sd3_i_m_l_DGX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->i = hi % kia[i]; }
void sd3_i_m_l_DKX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->i = 100 % kia[i]; }
void sd3_i_m_l_DEX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->i = hia[2] % kia[i]; }
void sd3_i_m_l_DDX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->i = hps->i % kia[i]; }
void sd3_i_m_l_DRX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->i = d % kia[i]; }
void sd3_i_m_l_DXX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->i = hia[i] % kia[i]; }
void sd3_i_m_l_DXG(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->i = hia[i] % ki; }
void sd3_i_m_l_DXK(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->i = hia[i] % 7; }
void sd3_i_m_l_EGX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[3] = hi % kia[i]; }
void sd3_i_m_l_EKX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[3] = 100 % kia[i]; }
void sd3_i_m_l_EEX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[3] = hia[2] % kia[i]; }
void sd3_i_m_l_EDX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[3] = hps->i % kia[i]; }
void sd3_i_m_l_ERX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[3] = d % kia[i]; }
void sd3_i_m_l_EXX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[3] = hia[i] % kia[i]; }
void sd3_i_m_l_EXG(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[3] = hia[i] % ki; }
void sd3_i_m_l_EXK(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[3] = hia[i] % 7; }
void sd3_i_m_l_XGX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[i] = hi % kia[i]; }
void sd3_i_m_l_XKX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[i] = 100 % kia[i]; }
void sd3_i_m_l_XEX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[i] = hia[2] % kia[i]; }
void sd3_i_m_l_XDX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[i] = hps->i % kia[i]; }
void sd3_i_m_l_XRX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[i] = d % kia[i]; }
void sd3_i_m_l_XXX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[i] = hia[i] % kia[i]; }
void sd3_i_m_l_XXG(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[i] = hia[i] % ki; }
void sd3_i_m_l_XXK(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gia[i] = hia[i] % 7; }
void sd3_i_m_l_PGX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gip = hi % kia[i]; }
void sd3_i_m_l_PKX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gip = 100 % kia[i]; }
void sd3_i_m_l_PEX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gip = hia[2] % kia[i]; }
void sd3_i_m_l_PDX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gip = hps->i % kia[i]; }
void sd3_i_m_l_PRX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gip = d % kia[i]; }
void sd3_i_m_l_PXX(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gip = hia[i] % kia[i]; }
void sd3_i_m_l_PXG(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gip = hia[i] % ki; }
void sd3_i_m_l_PXK(int c, int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gip = hia[i] % 7; }
void sd3_u_d_p_GGX(int c, unsigned int d, unsigned int e) { gu = hu / kua[c]; }
void sd3_u_d_p_GKX(int c, unsigned int d, unsigned int e) { gu = 100 / kua[c]; }
void sd3_u_d_p_GEX(int c, unsigned int d, unsigned int e) { gu = hua[2] / kua[c]; }
void sd3_u_d_p_GDX(int c, unsigned int d, unsigned int e) { gu = hps->u / kua[c]; }
void sd3_u_d_p_GRX(int c, unsigned int d, unsigned int e) { gu = d / kua[c]; }
void sd3_u_d_p_GXX(int c, unsigned int d, unsigned int e) { gu = hua[c] / kua[c]; }
void sd3_u_d_p_GXG(int c, unsigned int d, unsigned int e) { gu = hua[c] / ku; }
void sd3_u_d_p_GXK(int c, unsigned int d, unsigned int e) { gu = hua[c] / 7; }
void sd3_u_d_p_DGX(int c, unsigned int d, unsigned int e) { gps->u = hu / kua[c]; }
void sd3_u_d_p_DKX(int c, unsigned int d, unsigned int e) { gps->u = 100 / kua[c]; }
void sd3_u_d_p_DEX(int c, unsigned int d, unsigned int e) { gps->u = hua[2] / kua[c]; }
void sd3_u_d_p_DDX(int c, unsigned int d, unsigned int e) { gps->u = hps->u / kua[c]; }
void sd3_u_d_p_DRX(int c, unsigned int d, unsigned int e) { gps->u = d / kua[c]; }
void sd3_u_d_p_DXX(int c, unsigned int d, unsigned int e) { gps->u = hua[c] / kua[c]; }
void sd3_u_d_p_DXG(int c, unsigned int d, unsigned int e) { gps->u = hua[c] / ku; }
void sd3_u_d_p_DXK(int c, unsigned int d, unsigned int e) { gps->u = hua[c] / 7; }
void sd3_u_d_p_EGX(int c, unsigned int d, unsigned int e) { gua[3] = hu / kua[c]; }
void sd3_u_d_p_EKX(int c, unsigned int d, unsigned int e) { gua[3] = 100 / kua[c]; }
void sd3_u_d_p_EEX(int c, unsigned int d, unsigned int e) { gua[3] = hua[2] / kua[c]; }
void sd3_u_d_p_EDX(int c, unsigned int d, unsigned int e) { gua[3] = hps->u / kua[c]; }
void sd3_u_d_p_ERX(int c, unsigned int d, unsigned int e) { gua[3] = d / kua[c]; }
void sd3_u_d_p_EXX(int c, unsigned int d, unsigned int e) { gua[3] = hua[c] / kua[c]; }
void sd3_u_d_p_EXG(int c, unsigned int d, unsigned int e) { gua[3] = hua[c] / ku; }
void sd3_u_d_p_EXK(int c, unsigned int d, unsigned int e) { gua[3] = hua[c] / 7; }
void sd3_u_d_p_XGX(int c, unsigned int d, unsigned int e) { gua[c] = hu / kua[c]; }
void sd3_u_d_p_XKX(int c, unsigned int d, unsigned int e) { gua[c] = 100 / kua[c]; }
void sd3_u_d_p_XEX(int c, unsigned int d, unsigned int e) { gua[c] = hua[2] / kua[c]; }
void sd3_u_d_p_XDX(int c, unsigned int d, unsigned int e) { gua[c] = hps->u / kua[c]; }
void sd3_u_d_p_XRX(int c, unsigned int d, unsigned int e) { gua[c] = d / kua[c]; }
void sd3_u_d_p_XXX(int c, unsigned int d, unsigned int e) { gua[c] = hua[c] / kua[c]; }
void sd3_u_d_p_XXG(int c, unsigned int d, unsigned int e) { gua[c] = hua[c] / ku; }
void sd3_u_d_p_XXK(int c, unsigned int d, unsigned int e) { gua[c] = hua[c] / 7; }
void sd3_u_d_p_PGX(int c, unsigned int d, unsigned int e) { *gup = hu / kua[c]; }
void sd3_u_d_p_PKX(int c, unsigned int d, unsigned int e) { *gup = 100 / kua[c]; }
void sd3_u_d_p_PEX(int c, unsigned int d, unsigned int e) { *gup = hua[2] / kua[c]; }
void sd3_u_d_p_PDX(int c, unsigned int d, unsigned int e) { *gup = hps->u / kua[c]; }
void sd3_u_d_p_PRX(int c, unsigned int d, unsigned int e) { *gup = d / kua[c]; }
void sd3_u_d_p_PXX(int c, unsigned int d, unsigned int e) { *gup = hua[c] / kua[c]; }
void sd3_u_d_p_PXG(int c, unsigned int d, unsigned int e) { *gup = hua[c] / ku; }
void sd3_u_d_p_PXK(int c, unsigned int d, unsigned int e) { *gup = hua[c] / 7; }
void sd3_u_d_u_GGX(int c, unsigned int d, unsigned int e) { gu = hu / kua[e]; }
void sd3_u_d_u_GKX(int c, unsigned int d, unsigned int e) { gu = 100 / kua[e]; }
void sd3_u_d_u_GEX(int c, unsigned int d, unsigned int e) { gu = hua[2] / kua[e]; }
void sd3_u_d_u_GDX(int c, unsigned int d, unsigned int e) { gu = hps->u / kua[e]; }
void sd3_u_d_u_GRX(int c, unsigned int d, unsigned int e) { gu = d / kua[e]; }
void sd3_u_d_u_GXX(int c, unsigned int d, unsigned int e) { gu = hua[e] / kua[e]; }
void sd3_u_d_u_GXG(int c, unsigned int d, unsigned int e) { gu = hua[e] / ku; }
void sd3_u_d_u_GXK(int c, unsigned int d, unsigned int e) { gu = hua[e] / 7; }
void sd3_u_d_u_DGX(int c, unsigned int d, unsigned int e) { gps->u = hu / kua[e]; }
void sd3_u_d_u_DKX(int c, unsigned int d, unsigned int e) { gps->u = 100 / kua[e]; }
void sd3_u_d_u_DEX(int c, unsigned int d, unsigned int e) { gps->u = hua[2] / kua[e]; }
void sd3_u_d_u_DDX(int c, unsigned int d, unsigned int e) { gps->u = hps->u / kua[e]; }
void sd3_u_d_u_DRX(int c, unsigned int d, unsigned int e) { gps->u = d / kua[e]; }
void sd3_u_d_u_DXX(int c, unsigned int d, unsigned int e) { gps->u = hua[e] / kua[e]; }
void sd3_u_d_u_DXG(int c, unsigned int d, unsigned int e) { gps->u = hua[e] / ku; }
void sd3_u_d_u_DXK(int c, unsigned int d, unsigned int e) { gps->u = hua[e] / 7; }
void sd3_u_d_u_EGX(int c, unsigned int d, unsigned int e) { gua[3] = hu / kua[e]; }
void sd3_u_d_u_EKX(int c, unsigned int d, unsigned int e) { gua[3] = 100 / kua[e]; }
void sd3_u_d_u_EEX(int c, unsigned int d, unsigned int e) { gua[3] = hua[2] / kua[e]; }
void sd3_u_d_u_EDX(int c, unsigned int d, unsigned int e) { gua[3] = hps->u / kua[e]; }
void sd3_u_d_u_ERX(int c, unsigned int d, unsigned int e) { gua[3] = d / kua[e]; }
void sd3_u_d_u_EXX(int c, unsigned int d, unsigned int e) { gua[3] = hua[e] / kua[e]; }
void sd3_u_d_u_EXG(int c, unsigned int d, unsigned int e) { gua[3] = hua[e] / ku; }
void sd3_u_d_u_EXK(int c, unsigned int d, unsigned int e) { gua[3] = hua[e] / 7; }
void sd3_u_d_u_XGX(int c, unsigned int d, unsigned int e) { gua[e] = hu / kua[e]; }
void sd3_u_d_u_XKX(int c, unsigned int d, unsigned int e) { gua[e] = 100 / kua[e]; }
void sd3_u_d_u_XEX(int c, unsigned int d, unsigned int e) { gua[e] = hua[2] / kua[e]; }
void sd3_u_d_u_XDX(int c, unsigned int d, unsigned int e) { gua[e] = hps->u / kua[e]; }
void sd3_u_d_u_XRX(int c, unsigned int d, unsigned int e) { gua[e] = d / kua[e]; }
void sd3_u_d_u_XXX(int c, unsigned int d, unsigned int e) { gua[e] = hua[e] / kua[e]; }
void sd3_u_d_u_XXG(int c, unsigned int d, unsigned int e) { gua[e] = hua[e] / ku; }
void sd3_u_d_u_XXK(int c, unsigned int d, unsigned int e) { gua[e] = hua[e] / 7; }
void sd3_u_d_u_PGX(int c, unsigned int d, unsigned int e) { *gup = hu / kua[e]; }
void sd3_u_d_u_PKX(int c, unsigned int d, unsigned int e) { *gup = 100 / kua[e]; }
void sd3_u_d_u_PEX(int c, unsigned int d, unsigned int e) { *gup = hua[2] / kua[e]; }
void sd3_u_d_u_PDX(int c, unsigned int d, unsigned int e) { *gup = hps->u / kua[e]; }
void sd3_u_d_u_PRX(int c, unsigned int d, unsigned int e) { *gup = d / kua[e]; }
void sd3_u_d_u_PXX(int c, unsigned int d, unsigned int e) { *gup = hua[e] / kua[e]; }
void sd3_u_d_u_PXG(int c, unsigned int d, unsigned int e) { *gup = hua[e] / ku; }
void sd3_u_d_u_PXK(int c, unsigned int d, unsigned int e) { *gup = hua[e] / 7; }
void sd3_u_d_q_GGX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gu = hu / kua[t]; }
void sd3_u_d_q_GKX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gu = 100 / kua[t]; }
void sd3_u_d_q_GEX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gu = hua[2] / kua[t]; }
void sd3_u_d_q_GDX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gu = hps->u / kua[t]; }
void sd3_u_d_q_GRX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gu = d / kua[t]; }
void sd3_u_d_q_GXX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gu = hua[t] / kua[t]; }
void sd3_u_d_q_GXG(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gu = hua[t] / ku; }
void sd3_u_d_q_GXK(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gu = hua[t] / 7; }
void sd3_u_d_q_DGX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gps->u = hu / kua[t]; }
void sd3_u_d_q_DKX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gps->u = 100 / kua[t]; }
void sd3_u_d_q_DEX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gps->u = hua[2] / kua[t]; }
void sd3_u_d_q_DDX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gps->u = hps->u / kua[t]; }
void sd3_u_d_q_DRX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gps->u = d / kua[t]; }
void sd3_u_d_q_DXX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gps->u = hua[t] / kua[t]; }
void sd3_u_d_q_DXG(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gps->u = hua[t] / ku; }
void sd3_u_d_q_DXK(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gps->u = hua[t] / 7; }
void sd3_u_d_q_EGX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[3] = hu / kua[t]; }
void sd3_u_d_q_EKX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[3] = 100 / kua[t]; }
void sd3_u_d_q_EEX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[3] = hua[2] / kua[t]; }
void sd3_u_d_q_EDX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[3] = hps->u / kua[t]; }
void sd3_u_d_q_ERX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[3] = d / kua[t]; }
void sd3_u_d_q_EXX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[3] = hua[t] / kua[t]; }
void sd3_u_d_q_EXG(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[3] = hua[t] / ku; }
void sd3_u_d_q_EXK(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[3] = hua[t] / 7; }
void sd3_u_d_q_XGX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[t] = hu / kua[t]; }
void sd3_u_d_q_XKX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[t] = 100 / kua[t]; }
void sd3_u_d_q_XEX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[t] = hua[2] / kua[t]; }
void sd3_u_d_q_XDX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[t] = hps->u / kua[t]; }
void sd3_u_d_q_XRX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[t] = d / kua[t]; }
void sd3_u_d_q_XXX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[t] = hua[t] / kua[t]; }
void sd3_u_d_q_XXG(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[t] = hua[t] / ku; }
void sd3_u_d_q_XXK(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[t] = hua[t] / 7; }
void sd3_u_d_q_PGX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); *gup = hu / kua[t]; }
void sd3_u_d_q_PKX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); *gup = 100 / kua[t]; }
void sd3_u_d_q_PEX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); *gup = hua[2] / kua[t]; }
void sd3_u_d_q_PDX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); *gup = hps->u / kua[t]; }
void sd3_u_d_q_PRX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); *gup = d / kua[t]; }
void sd3_u_d_q_PXX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); *gup = hua[t] / kua[t]; }
void sd3_u_d_q_PXG(int c, unsigned int d, unsigned int e) { char t = jc; f0(); *gup = hua[t] / ku; }
void sd3_u_d_q_PXK(int c, unsigned int d, unsigned int e) { char t = jc; f0(); *gup = hua[t] / 7; }
void sd3_u_d_r_GGX(int c, unsigned int d, unsigned int e) { char t = jc; gu = hu / kua[t]; }
void sd3_u_d_r_GKX(int c, unsigned int d, unsigned int e) { char t = jc; gu = 100 / kua[t]; }
void sd3_u_d_r_GEX(int c, unsigned int d, unsigned int e) { char t = jc; gu = hua[2] / kua[t]; }
void sd3_u_d_r_GDX(int c, unsigned int d, unsigned int e) { char t = jc; gu = hps->u / kua[t]; }
void sd3_u_d_r_GRX(int c, unsigned int d, unsigned int e) { char t = jc; gu = d / kua[t]; }
void sd3_u_d_r_GXX(int c, unsigned int d, unsigned int e) { char t = jc; gu = hua[t] / kua[t]; }
void sd3_u_d_r_GXG(int c, unsigned int d, unsigned int e) { char t = jc; gu = hua[t] / ku; }
void sd3_u_d_r_GXK(int c, unsigned int d, unsigned int e) { char t = jc; gu = hua[t] / 7; }
void sd3_u_d_r_DGX(int c, unsigned int d, unsigned int e) { char t = jc; gps->u = hu / kua[t]; }
void sd3_u_d_r_DKX(int c, unsigned int d, unsigned int e) { char t = jc; gps->u = 100 / kua[t]; }
void sd3_u_d_r_DEX(int c, unsigned int d, unsigned int e) { char t = jc; gps->u = hua[2] / kua[t]; }
void sd3_u_d_r_DDX(int c, unsigned int d, unsigned int e) { char t = jc; gps->u = hps->u / kua[t]; }
void sd3_u_d_r_DRX(int c, unsigned int d, unsigned int e) { char t = jc; gps->u = d / kua[t]; }
void sd3_u_d_r_DXX(int c, unsigned int d, unsigned int e) { char t = jc; gps->u = hua[t] / kua[t]; }
void sd3_u_d_r_DXG(int c, unsigned int d, unsigned int e) { char t = jc; gps->u = hua[t] / ku; }
void sd3_u_d_r_DXK(int c, unsigned int d, unsigned int e) { char t = jc; gps->u = hua[t] / 7; }
void sd3_u_d_r_EGX(int c, unsigned int d, unsigned int e) { char t = jc; gua[3] = hu / kua[t]; }
void sd3_u_d_r_EKX(int c, unsigned int d, unsigned int e) { char t = jc; gua[3] = 100 / kua[t]; }
void sd3_u_d_r_EEX(int c, unsigned int d, unsigned int e) { char t = jc; gua[3] = hua[2] / kua[t]; }
void sd3_u_d_r_EDX(int c, unsigned int d, unsigned int e) { char t = jc; gua[3] = hps->u / kua[t]; }
void sd3_u_d_r_ERX(int c, unsigned int d, unsigned int e) { char t = jc; gua[3] = d / kua[t]; }
void sd3_u_d_r_EXX(int c, unsigned int d, unsigned int e) { char t = jc; gua[3] = hua[t] / kua[t]; }
void sd3_u_d_r_EXG(int c, unsigned int d, unsigned int e) { char t = jc; gua[3] = hua[t] / ku; }
void sd3_u_d_r_EXK(int c, unsigned int d, unsigned int e) { char t = jc; gua[3] = hua[t] / 7; }
void sd3_u_d_r_XGX(int c, unsigned int d, unsigned int e) { char t = jc; gua[t] = hu / kua[t]; }
void sd3_u_d_r_XKX(int c, unsigned int d, unsigned int e) { char t = jc; gua[t] = 100 / kua[t]; }
void sd3_u_d_r_XEX(int c, unsigned int d, unsigned int e) { char t = jc; gua[t] = hua[2] / kua[t]; }
void sd3_u_d_r_XDX(int c, unsigned int d, unsigned int e) { char t = jc; gua[t] = hps->u / kua[t]; }
void sd3_u_d_r_XRX(int c, unsigned int d, unsigned int e) { char t = jc; gua[t] = d / kua[t]; }
void sd3_u_d_r_XXX(int c, unsigned int d, unsigned int e) { char t = jc; gua[t] = hua[t] / kua[t]; }
void sd3_u_d_r_XXG(int c, unsigned int d, unsigned int e) { char t = jc; gua[t] = hua[t] / ku; }
void sd3_u_d_r_XXK(int c, unsigned int d, unsigned int e) { char t = jc; gua[t] = hua[t] / 7; }
void sd3_u_d_r_PGX(int c, unsigned int d, unsigned int e) { char t = jc; *gup = hu / kua[t]; }
void sd3_u_d_r_PKX(int c, unsigned int d, unsigned int e) { char t = jc; *gup = 100 / kua[t]; }
void sd3_u_d_r_PEX(int c, unsigned int d, unsigned int e) { char t = jc; *gup = hua[2] / kua[t]; }
void sd3_u_d_r_PDX(int c, unsigned int d, unsigned int e) { char t = jc; *gup = hps->u / kua[t]; }
void sd3_u_d_r_PRX(int c, unsigned int d, unsigned int e) { char t = jc; *gup = d / kua[t]; }
void sd3_u_d_r_PXX(int c, unsigned int d, unsigned int e) { char t = jc; *gup = hua[t] / kua[t]; }
void sd3_u_d_r_PXG(int c, unsigned int d, unsigned int e) { char t = jc; *gup = hua[t] / ku; }
void sd3_u_d_r_PXK(int c, unsigned int d, unsigned int e) { char t = jc; *gup = hua[t] / 7; }
void sd3_u_d_l_GGX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gu = hu / kua[i]; }
void sd3_u_d_l_GKX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gu = 100 / kua[i]; }
void sd3_u_d_l_GEX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gu = hua[2] / kua[i]; }
void sd3_u_d_l_GDX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gu = hps->u / kua[i]; }
void sd3_u_d_l_GRX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gu = d / kua[i]; }
void sd3_u_d_l_GXX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gu = hua[i] / kua[i]; }
void sd3_u_d_l_GXG(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gu = hua[i] / ku; }
void sd3_u_d_l_GXK(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gu = hua[i] / 7; }
void sd3_u_d_l_DGX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->u = hu / kua[i]; }
void sd3_u_d_l_DKX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->u = 100 / kua[i]; }
void sd3_u_d_l_DEX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->u = hua[2] / kua[i]; }
void sd3_u_d_l_DDX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->u = hps->u / kua[i]; }
void sd3_u_d_l_DRX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->u = d / kua[i]; }
void sd3_u_d_l_DXX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->u = hua[i] / kua[i]; }
void sd3_u_d_l_DXG(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->u = hua[i] / ku; }
void sd3_u_d_l_DXK(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->u = hua[i] / 7; }
void sd3_u_d_l_EGX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[3] = hu / kua[i]; }
void sd3_u_d_l_EKX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[3] = 100 / kua[i]; }
void sd3_u_d_l_EEX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[3] = hua[2] / kua[i]; }
void sd3_u_d_l_EDX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[3] = hps->u / kua[i]; }
void sd3_u_d_l_ERX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[3] = d / kua[i]; }
void sd3_u_d_l_EXX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[3] = hua[i] / kua[i]; }
void sd3_u_d_l_EXG(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[3] = hua[i] / ku; }
void sd3_u_d_l_EXK(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[3] = hua[i] / 7; }
void sd3_u_d_l_XGX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[i] = hu / kua[i]; }
void sd3_u_d_l_XKX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[i] = 100 / kua[i]; }
void sd3_u_d_l_XEX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[i] = hua[2] / kua[i]; }
void sd3_u_d_l_XDX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[i] = hps->u / kua[i]; }
void sd3_u_d_l_XRX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[i] = d / kua[i]; }
void sd3_u_d_l_XXX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[i] = hua[i] / kua[i]; }
void sd3_u_d_l_XXG(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[i] = hua[i] / ku; }
void sd3_u_d_l_XXK(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[i] = hua[i] / 7; }
void sd3_u_d_l_PGX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gup = hu / kua[i]; }
void sd3_u_d_l_PKX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gup = 100 / kua[i]; }
void sd3_u_d_l_PEX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gup = hua[2] / kua[i]; }
void sd3_u_d_l_PDX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gup = hps->u / kua[i]; }
void sd3_u_d_l_PRX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gup = d / kua[i]; }
void sd3_u_d_l_PXX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gup = hua[i] / kua[i]; }
void sd3_u_d_l_PXG(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gup = hua[i] / ku; }
void sd3_u_d_l_PXK(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gup = hua[i] / 7; }
void sd3_u_m_p_GGX(int c, unsigned int d, unsigned int e) { gu = hu % kua[c]; }
void sd3_u_m_p_GKX(int c, unsigned int d, unsigned int e) { gu = 100 % kua[c]; }
void sd3_u_m_p_GEX(int c, unsigned int d, unsigned int e) { gu = hua[2] % kua[c]; }
void sd3_u_m_p_GDX(int c, unsigned int d, unsigned int e) { gu = hps->u % kua[c]; }
void sd3_u_m_p_GRX(int c, unsigned int d, unsigned int e) { gu = d % kua[c]; }
void sd3_u_m_p_GXX(int c, unsigned int d, unsigned int e) { gu = hua[c] % kua[c]; }
void sd3_u_m_p_GXG(int c, unsigned int d, unsigned int e) { gu = hua[c] % ku; }
void sd3_u_m_p_GXK(int c, unsigned int d, unsigned int e) { gu = hua[c] % 7; }
void sd3_u_m_p_DGX(int c, unsigned int d, unsigned int e) { gps->u = hu % kua[c]; }
void sd3_u_m_p_DKX(int c, unsigned int d, unsigned int e) { gps->u = 100 % kua[c]; }
void sd3_u_m_p_DEX(int c, unsigned int d, unsigned int e) { gps->u = hua[2] % kua[c]; }
void sd3_u_m_p_DDX(int c, unsigned int d, unsigned int e) { gps->u = hps->u % kua[c]; }
void sd3_u_m_p_DRX(int c, unsigned int d, unsigned int e) { gps->u = d % kua[c]; }
void sd3_u_m_p_DXX(int c, unsigned int d, unsigned int e) { gps->u = hua[c] % kua[c]; }
void sd3_u_m_p_DXG(int c, unsigned int d, unsigned int e) { gps->u = hua[c] % ku; }
void sd3_u_m_p_DXK(int c, unsigned int d, unsigned int e) { gps->u = hua[c] % 7; }
void sd3_u_m_p_EGX(int c, unsigned int d, unsigned int e) { gua[3] = hu % kua[c]; }
void sd3_u_m_p_EKX(int c, unsigned int d, unsigned int e) { gua[3] = 100 % kua[c]; }
void sd3_u_m_p_EEX(int c, unsigned int d, unsigned int e) { gua[3] = hua[2] % kua[c]; }
void sd3_u_m_p_EDX(int c, unsigned int d, unsigned int e) { gua[3] = hps->u % kua[c]; }
void sd3_u_m_p_ERX(int c, unsigned int d, unsigned int e) { gua[3] = d % kua[c]; }
void sd3_u_m_p_EXX(int c, unsigned int d, unsigned int e) { gua[3] = hua[c] % kua[c]; }
void sd3_u_m_p_EXG(int c, unsigned int d, unsigned int e) { gua[3] = hua[c] % ku; }
void sd3_u_m_p_EXK(int c, unsigned int d, unsigned int e) { gua[3] = hua[c] % 7; }
void sd3_u_m_p_XGX(int c, unsigned int d, unsigned int e) { gua[c] = hu % kua[c]; }
void sd3_u_m_p_XKX(int c, unsigned int d, unsigned int e) { gua[c] = 100 % kua[c]; }
void sd3_u_m_p_XEX(int c, unsigned int d, unsigned int e) { gua[c] = hua[2] % kua[c]; }
void sd3_u_m_p_XDX(int c, unsigned int d, unsigned int e) { gua[c] = hps->u % kua[c]; }
void sd3_u_m_p_XRX(int c, unsigned int d, unsigned int e) { gua[c] = d % kua[c]; }
void sd3_u_m_p_XXX(int c, unsigned int d, unsigned int e) { gua[c] = hua[c] % kua[c]; }
void sd3_u_m_p_XXG(int c, unsigned int d, unsigned int e) { gua[c] = hua[c] % ku; }
void sd3_u_m_p_XXK(int c, unsigned int d, unsigned int e) { gua[c] = hua[c] % 7; }
void sd3_u_m_p_PGX(int c, unsigned int d, unsigned int e) { *gup = hu % kua[c]; }
void sd3_u_m_p_PKX(int c, unsigned int d, unsigned int e) { *gup = 100 % kua[c]; }
void sd3_u_m_p_PEX(int c, unsigned int d, unsigned int e) { *gup = hua[2] % kua[c]; }
void sd3_u_m_p_PDX(int c, unsigned int d, unsigned int e) { *gup = hps->u % kua[c]; }
void sd3_u_m_p_PRX(int c, unsigned int d, unsigned int e) { *gup = d % kua[c]; }
void sd3_u_m_p_PXX(int c, unsigned int d, unsigned int e) { *gup = hua[c] % kua[c]; }
void sd3_u_m_p_PXG(int c, unsigned int d, unsigned int e) { *gup = hua[c] % ku; }
void sd3_u_m_p_PXK(int c, unsigned int d, unsigned int e) { *gup = hua[c] % 7; }
void sd3_u_m_u_GGX(int c, unsigned int d, unsigned int e) { gu = hu % kua[e]; }
void sd3_u_m_u_GKX(int c, unsigned int d, unsigned int e) { gu = 100 % kua[e]; }
void sd3_u_m_u_GEX(int c, unsigned int d, unsigned int e) { gu = hua[2] % kua[e]; }
void sd3_u_m_u_GDX(int c, unsigned int d, unsigned int e) { gu = hps->u % kua[e]; }
void sd3_u_m_u_GRX(int c, unsigned int d, unsigned int e) { gu = d % kua[e]; }
void sd3_u_m_u_GXX(int c, unsigned int d, unsigned int e) { gu = hua[e] % kua[e]; }
void sd3_u_m_u_GXG(int c, unsigned int d, unsigned int e) { gu = hua[e] % ku; }
void sd3_u_m_u_GXK(int c, unsigned int d, unsigned int e) { gu = hua[e] % 7; }
void sd3_u_m_u_DGX(int c, unsigned int d, unsigned int e) { gps->u = hu % kua[e]; }
void sd3_u_m_u_DKX(int c, unsigned int d, unsigned int e) { gps->u = 100 % kua[e]; }
void sd3_u_m_u_DEX(int c, unsigned int d, unsigned int e) { gps->u = hua[2] % kua[e]; }
void sd3_u_m_u_DDX(int c, unsigned int d, unsigned int e) { gps->u = hps->u % kua[e]; }
void sd3_u_m_u_DRX(int c, unsigned int d, unsigned int e) { gps->u = d % kua[e]; }
void sd3_u_m_u_DXX(int c, unsigned int d, unsigned int e) { gps->u = hua[e] % kua[e]; }
void sd3_u_m_u_DXG(int c, unsigned int d, unsigned int e) { gps->u = hua[e] % ku; }
void sd3_u_m_u_DXK(int c, unsigned int d, unsigned int e) { gps->u = hua[e] % 7; }
void sd3_u_m_u_EGX(int c, unsigned int d, unsigned int e) { gua[3] = hu % kua[e]; }
void sd3_u_m_u_EKX(int c, unsigned int d, unsigned int e) { gua[3] = 100 % kua[e]; }
void sd3_u_m_u_EEX(int c, unsigned int d, unsigned int e) { gua[3] = hua[2] % kua[e]; }
void sd3_u_m_u_EDX(int c, unsigned int d, unsigned int e) { gua[3] = hps->u % kua[e]; }
void sd3_u_m_u_ERX(int c, unsigned int d, unsigned int e) { gua[3] = d % kua[e]; }
void sd3_u_m_u_EXX(int c, unsigned int d, unsigned int e) { gua[3] = hua[e] % kua[e]; }
void sd3_u_m_u_EXG(int c, unsigned int d, unsigned int e) { gua[3] = hua[e] % ku; }
void sd3_u_m_u_EXK(int c, unsigned int d, unsigned int e) { gua[3] = hua[e] % 7; }
void sd3_u_m_u_XGX(int c, unsigned int d, unsigned int e) { gua[e] = hu % kua[e]; }
void sd3_u_m_u_XKX(int c, unsigned int d, unsigned int e) { gua[e] = 100 % kua[e]; }
void sd3_u_m_u_XEX(int c, unsigned int d, unsigned int e) { gua[e] = hua[2] % kua[e]; }
void sd3_u_m_u_XDX(int c, unsigned int d, unsigned int e) { gua[e] = hps->u % kua[e]; }
void sd3_u_m_u_XRX(int c, unsigned int d, unsigned int e) { gua[e] = d % kua[e]; }
void sd3_u_m_u_XXX(int c, unsigned int d, unsigned int e) { gua[e] = hua[e] % kua[e]; }
void sd3_u_m_u_XXG(int c, unsigned int d, unsigned int e) { gua[e] = hua[e] % ku; }
void sd3_u_m_u_XXK(int c, unsigned int d, unsigned int e) { gua[e] = hua[e] % 7; }
void sd3_u_m_u_PGX(int c, unsigned int d, unsigned int e) { *gup = hu % kua[e]; }
void sd3_u_m_u_PKX(int c, unsigned int d, unsigned int e) { *gup = 100 % kua[e]; }
void sd3_u_m_u_PEX(int c, unsigned int d, unsigned int e) { *gup = hua[2] % kua[e]; }
void sd3_u_m_u_PDX(int c, unsigned int d, unsigned int e) { *gup = hps->u % kua[e]; }
void sd3_u_m_u_PRX(int c, unsigned int d, unsigned int e) { *gup = d % kua[e]; }
void sd3_u_m_u_PXX(int c, unsigned int d, unsigned int e) { *gup = hua[e] % kua[e]; }
void sd3_u_m_u_PXG(int c, unsigned int d, unsigned int e) { *gup = hua[e] % ku; }
void sd3_u_m_u_PXK(int c, unsigned int d, unsigned int e) { *gup = hua[e] % 7; }
void sd3_u_m_q_GGX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gu = hu % kua[t]; }
void sd3_u_m_q_GKX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gu = 100 % kua[t]; }
void sd3_u_m_q_GEX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gu = hua[2] % kua[t]; }
void sd3_u_m_q_GDX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gu = hps->u % kua[t]; }
void sd3_u_m_q_GRX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gu = d % kua[t]; }
void sd3_u_m_q_GXX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gu = hua[t] % kua[t]; }
void sd3_u_m_q_GXG(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gu = hua[t] % ku; }
void sd3_u_m_q_GXK(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gu = hua[t] % 7; }
void sd3_u_m_q_DGX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gps->u = hu % kua[t]; }
void sd3_u_m_q_DKX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gps->u = 100 % kua[t]; }
void sd3_u_m_q_DEX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gps->u = hua[2] % kua[t]; }
void sd3_u_m_q_DDX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gps->u = hps->u % kua[t]; }
void sd3_u_m_q_DRX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gps->u = d % kua[t]; }
void sd3_u_m_q_DXX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gps->u = hua[t] % kua[t]; }
void sd3_u_m_q_DXG(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gps->u = hua[t] % ku; }
void sd3_u_m_q_DXK(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gps->u = hua[t] % 7; }
void sd3_u_m_q_EGX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[3] = hu % kua[t]; }
void sd3_u_m_q_EKX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[3] = 100 % kua[t]; }
void sd3_u_m_q_EEX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[3] = hua[2] % kua[t]; }
void sd3_u_m_q_EDX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[3] = hps->u % kua[t]; }
void sd3_u_m_q_ERX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[3] = d % kua[t]; }
void sd3_u_m_q_EXX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[3] = hua[t] % kua[t]; }
void sd3_u_m_q_EXG(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[3] = hua[t] % ku; }
void sd3_u_m_q_EXK(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[3] = hua[t] % 7; }
void sd3_u_m_q_XGX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[t] = hu % kua[t]; }
void sd3_u_m_q_XKX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[t] = 100 % kua[t]; }
void sd3_u_m_q_XEX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[t] = hua[2] % kua[t]; }
void sd3_u_m_q_XDX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[t] = hps->u % kua[t]; }
void sd3_u_m_q_XRX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[t] = d % kua[t]; }
void sd3_u_m_q_XXX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[t] = hua[t] % kua[t]; }
void sd3_u_m_q_XXG(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[t] = hua[t] % ku; }
void sd3_u_m_q_XXK(int c, unsigned int d, unsigned int e) { char t = jc; f0(); gua[t] = hua[t] % 7; }
void sd3_u_m_q_PGX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); *gup = hu % kua[t]; }
void sd3_u_m_q_PKX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); *gup = 100 % kua[t]; }
void sd3_u_m_q_PEX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); *gup = hua[2] % kua[t]; }
void sd3_u_m_q_PDX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); *gup = hps->u % kua[t]; }
void sd3_u_m_q_PRX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); *gup = d % kua[t]; }
void sd3_u_m_q_PXX(int c, unsigned int d, unsigned int e) { char t = jc; f0(); *gup = hua[t] % kua[t]; }
void sd3_u_m_q_PXG(int c, unsigned int d, unsigned int e) { char t = jc; f0(); *gup = hua[t] % ku; }
void sd3_u_m_q_PXK(int c, unsigned int d, unsigned int e) { char t = jc; f0(); *gup = hua[t] % 7; }
void sd3_u_m_r_GGX(int c, unsigned int d, unsigned int e) { char t = jc; gu = hu % kua[t]; }
void sd3_u_m_r_GKX(int c, unsigned int d, unsigned int e) { char t = jc; gu = 100 % kua[t]; }
void sd3_u_m_r_GEX(int c, unsigned int d, unsigned int e) { char t = jc; gu = hua[2] % kua[t]; }
void sd3_u_m_r_GDX(int c, unsigned int d, unsigned int e) { char t = jc; gu = hps->u % kua[t]; }
void sd3_u_m_r_GRX(int c, unsigned int d, unsigned int e) { char t = jc; gu = d % kua[t]; }
void sd3_u_m_r_GXX(int c, unsigned int d, unsigned int e) { char t = jc; gu = hua[t] % kua[t]; }
void sd3_u_m_r_GXG(int c, unsigned int d, unsigned int e) { char t = jc; gu = hua[t] % ku; }
void sd3_u_m_r_GXK(int c, unsigned int d, unsigned int e) { char t = jc; gu = hua[t] % 7; }
void sd3_u_m_r_DGX(int c, unsigned int d, unsigned int e) { char t = jc; gps->u = hu % kua[t]; }
void sd3_u_m_r_DKX(int c, unsigned int d, unsigned int e) { char t = jc; gps->u = 100 % kua[t]; }
void sd3_u_m_r_DEX(int c, unsigned int d, unsigned int e) { char t = jc; gps->u = hua[2] % kua[t]; }
void sd3_u_m_r_DDX(int c, unsigned int d, unsigned int e) { char t = jc; gps->u = hps->u % kua[t]; }
void sd3_u_m_r_DRX(int c, unsigned int d, unsigned int e) { char t = jc; gps->u = d % kua[t]; }
void sd3_u_m_r_DXX(int c, unsigned int d, unsigned int e) { char t = jc; gps->u = hua[t] % kua[t]; }
void sd3_u_m_r_DXG(int c, unsigned int d, unsigned int e) { char t = jc; gps->u = hua[t] % ku; }
void sd3_u_m_r_DXK(int c, unsigned int d, unsigned int e) { char t = jc; gps->u = hua[t] % 7; }
void sd3_u_m_r_EGX(int c, unsigned int d, unsigned int e) { char t = jc; gua[3] = hu % kua[t]; }
void sd3_u_m_r_EKX(int c, unsigned int d, unsigned int e) { char t = jc; gua[3] = 100 % kua[t]; }
void sd3_u_m_r_EEX(int c, unsigned int d, unsigned int e) { char t = jc; gua[3] = hua[2] % kua[t]; }
void sd3_u_m_r_EDX(int c, unsigned int d, unsigned int e) { char t = jc; gua[3] = hps->u % kua[t]; }
void sd3_u_m_r_ERX(int c, unsigned int d, unsigned int e) { char t = jc; gua[3] = d % kua[t]; }
void sd3_u_m_r_EXX(int c, unsigned int d, unsigned int e) { char t = jc; gua[3] = hua[t] % kua[t]; }
void sd3_u_m_r_EXG(int c, unsigned int d, unsigned int e) { char t = jc; gua[3] = hua[t] % ku; }
void sd3_u_m_r_EXK(int c, unsigned int d, unsigned int e) { char t = jc; gua[3] = hua[t] % 7; }
void sd3_u_m_r_XGX(int c, unsigned int d, unsigned int e) { char t = jc; gua[t] = hu % kua[t]; }
void sd3_u_m_r_XKX(int c, unsigned int d, unsigned int e) { char t = jc; gua[t] = 100 % kua[t]; }
void sd3_u_m_r_XEX(int c, unsigned int d, unsigned int e) { char t = jc; gua[t] = hua[2] % kua[t]; }
void sd3_u_m_r_XDX(int c, unsigned int d, unsigned int e) { char t = jc; gua[t] = hps->u % kua[t]; }
void sd3_u_m_r_XRX(int c, unsigned int d, unsigned int e) { char t = jc; gua[t] = d % kua[t]; }
void sd3_u_m_r_XXX(int c, unsigned int d, unsigned int e) { char t = jc; gua[t] = hua[t] % kua[t]; }
void sd3_u_m_r_XXG(int c, unsigned int d, unsigned int e) { char t = jc; gua[t] = hua[t] % ku; }
void sd3_u_m_r_XXK(int c, unsigned int d, unsigned int e) { char t = jc; gua[t] = hua[t] % 7; }
void sd3_u_m_r_PGX(int c, unsigned int d, unsigned int e) { char t = jc; *gup = hu % kua[t]; }
void sd3_u_m_r_PKX(int c, unsigned int d, unsigned int e) { char t = jc; *gup = 100 % kua[t]; }
void sd3_u_m_r_PEX(int c, unsigned int d, unsigned int e) { char t = jc; *gup = hua[2] % kua[t]; }
void sd3_u_m_r_PDX(int c, unsigned int d, unsigned int e) { char t = jc; *gup = hps->u % kua[t]; }
void sd3_u_m_r_PRX(int c, unsigned int d, unsigned int e) { char t = jc; *gup = d % kua[t]; }
void sd3_u_m_r_PXX(int c, unsigned int d, unsigned int e) { char t = jc; *gup = hua[t] % kua[t]; }
void sd3_u_m_r_PXG(int c, unsigned int d, unsigned int e) { char t = jc; *gup = hua[t] % ku; }
void sd3_u_m_r_PXK(int c, unsigned int d, unsigned int e) { char t = jc; *gup = hua[t] % 7; }
void sd3_u_m_l_GGX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gu = hu % kua[i]; }
void sd3_u_m_l_GKX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gu = 100 % kua[i]; }
void sd3_u_m_l_GEX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gu = hua[2] % kua[i]; }
void sd3_u_m_l_GDX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gu = hps->u % kua[i]; }
void sd3_u_m_l_GRX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gu = d % kua[i]; }
void sd3_u_m_l_GXX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gu = hua[i] % kua[i]; }
void sd3_u_m_l_GXG(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gu = hua[i] % ku; }
void sd3_u_m_l_GXK(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gu = hua[i] % 7; }
void sd3_u_m_l_DGX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->u = hu % kua[i]; }
void sd3_u_m_l_DKX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->u = 100 % kua[i]; }
void sd3_u_m_l_DEX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->u = hua[2] % kua[i]; }
void sd3_u_m_l_DDX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->u = hps->u % kua[i]; }
void sd3_u_m_l_DRX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->u = d % kua[i]; }
void sd3_u_m_l_DXX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->u = hua[i] % kua[i]; }
void sd3_u_m_l_DXG(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->u = hua[i] % ku; }
void sd3_u_m_l_DXK(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->u = hua[i] % 7; }
void sd3_u_m_l_EGX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[3] = hu % kua[i]; }
void sd3_u_m_l_EKX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[3] = 100 % kua[i]; }
void sd3_u_m_l_EEX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[3] = hua[2] % kua[i]; }
void sd3_u_m_l_EDX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[3] = hps->u % kua[i]; }
void sd3_u_m_l_ERX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[3] = d % kua[i]; }
void sd3_u_m_l_EXX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[3] = hua[i] % kua[i]; }
void sd3_u_m_l_EXG(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[3] = hua[i] % ku; }
void sd3_u_m_l_EXK(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[3] = hua[i] % 7; }
void sd3_u_m_l_XGX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[i] = hu % kua[i]; }
void sd3_u_m_l_XKX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[i] = 100 % kua[i]; }
void sd3_u_m_l_XEX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[i] = hua[2] % kua[i]; }
void sd3_u_m_l_XDX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[i] = hps->u % kua[i]; }
void sd3_u_m_l_XRX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[i] = d % kua[i]; }
void sd3_u_m_l_XXX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[i] = hua[i] % kua[i]; }
void sd3_u_m_l_XXG(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[i] = hua[i] % ku; }
void sd3_u_m_l_XXK(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) gua[i] = hua[i] % 7; }
void sd3_u_m_l_PGX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gup = hu % kua[i]; }
void sd3_u_m_l_PKX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gup = 100 % kua[i]; }
void sd3_u_m_l_PEX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gup = hua[2] % kua[i]; }
void sd3_u_m_l_PDX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gup = hps->u % kua[i]; }
void sd3_u_m_l_PRX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gup = d % kua[i]; }
void sd3_u_m_l_PXX(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gup = hua[i] % kua[i]; }
void sd3_u_m_l_PXG(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gup = hua[i] % ku; }
void sd3_u_m_l_PXK(int c, unsigned int d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gup = hua[i] % 7; }
void sd3_c_d_p_GGX(int c, char d, unsigned int e) { gc = hc / kca[c]; }
void sd3_c_d_p_GKX(int c, char d, unsigned int e) { gc = 100 / kca[c]; }
void sd3_c_d_p_GEX(int c, char d, unsigned int e) { gc = hca[2] / kca[c]; }
void sd3_c_d_p_GDX(int c, char d, unsigned int e) { gc = hps->c / kca[c]; }
void sd3_c_d_p_GRX(int c, char d, unsigned int e) { gc = d / kca[c]; }
void sd3_c_d_p_GXX(int c, char d, unsigned int e) { gc = hca[c] / kca[c]; }
void sd3_c_d_p_GXG(int c, char d, unsigned int e) { gc = hca[c] / kc; }
void sd3_c_d_p_GXK(int c, char d, unsigned int e) { gc = hca[c] / 7; }
void sd3_c_d_p_DGX(int c, char d, unsigned int e) { gps->c = hc / kca[c]; }
void sd3_c_d_p_DKX(int c, char d, unsigned int e) { gps->c = 100 / kca[c]; }
void sd3_c_d_p_DEX(int c, char d, unsigned int e) { gps->c = hca[2] / kca[c]; }
void sd3_c_d_p_DDX(int c, char d, unsigned int e) { gps->c = hps->c / kca[c]; }
void sd3_c_d_p_DRX(int c, char d, unsigned int e) { gps->c = d / kca[c]; }
void sd3_c_d_p_DXX(int c, char d, unsigned int e) { gps->c = hca[c] / kca[c]; }
void sd3_c_d_p_DXG(int c, char d, unsigned int e) { gps->c = hca[c] / kc; }
void sd3_c_d_p_DXK(int c, char d, unsigned int e) { gps->c = hca[c] / 7; }
void sd3_c_d_p_EGX(int c, char d, unsigned int e) { gca[3] = hc / kca[c]; }
void sd3_c_d_p_EKX(int c, char d, unsigned int e) { gca[3] = 100 / kca[c]; }
void sd3_c_d_p_EEX(int c, char d, unsigned int e) { gca[3] = hca[2] / kca[c]; }
void sd3_c_d_p_EDX(int c, char d, unsigned int e) { gca[3] = hps->c / kca[c]; }
void sd3_c_d_p_ERX(int c, char d, unsigned int e) { gca[3] = d / kca[c]; }
void sd3_c_d_p_EXX(int c, char d, unsigned int e) { gca[3] = hca[c] / kca[c]; }
void sd3_c_d_p_EXG(int c, char d, unsigned int e) { gca[3] = hca[c] / kc; }
void sd3_c_d_p_EXK(int c, char d, unsigned int e) { gca[3] = hca[c] / 7; }
void sd3_c_d_p_XGX(int c, char d, unsigned int e) { gca[c] = hc / kca[c]; }
void sd3_c_d_p_XKX(int c, char d, unsigned int e) { gca[c] = 100 / kca[c]; }
void sd3_c_d_p_XEX(int c, char d, unsigned int e) { gca[c] = hca[2] / kca[c]; }
void sd3_c_d_p_XDX(int c, char d, unsigned int e) { gca[c] = hps->c / kca[c]; }
void sd3_c_d_p_XRX(int c, char d, unsigned int e) { gca[c] = d / kca[c]; }
void sd3_c_d_p_XXX(int c, char d, unsigned int e) { gca[c] = hca[c] / kca[c]; }
void sd3_c_d_p_XXG(int c, char d, unsigned int e) { gca[c] = hca[c] / kc; }
void sd3_c_d_p_XXK(int c, char d, unsigned int e) { gca[c] = hca[c] / 7; }
void sd3_c_d_p_PGX(int c, char d, unsigned int e) { *gcp = hc / kca[c]; }
void sd3_c_d_p_PKX(int c, char d, unsigned int e) { *gcp = 100 / kca[c]; }
void sd3_c_d_p_PEX(int c, char d, unsigned int e) { *gcp = hca[2] / kca[c]; }
void sd3_c_d_p_PDX(int c, char d, unsigned int e) { *gcp = hps->c / kca[c]; }
void sd3_c_d_p_PRX(int c, char d, unsigned int e) { *gcp = d / kca[c]; }
void sd3_c_d_p_PXX(int c, char d, unsigned int e) { *gcp = hca[c] / kca[c]; }
void sd3_c_d_p_PXG(int c, char d, unsigned int e) { *gcp = hca[c] / kc; }
void sd3_c_d_p_PXK(int c, char d, unsigned int e) { *gcp = hca[c] / 7; }
void sd3_c_d_u_GGX(int c, char d, unsigned int e) { gc = hc / kca[e]; }
void sd3_c_d_u_GKX(int c, char d, unsigned int e) { gc = 100 / kca[e]; }
void sd3_c_d_u_GEX(int c, char d, unsigned int e) { gc = hca[2] / kca[e]; }
void sd3_c_d_u_GDX(int c, char d, unsigned int e) { gc = hps->c / kca[e]; }
void sd3_c_d_u_GRX(int c, char d, unsigned int e) { gc = d / kca[e]; }
void sd3_c_d_u_GXX(int c, char d, unsigned int e) { gc = hca[e] / kca[e]; }
void sd3_c_d_u_GXG(int c, char d, unsigned int e) { gc = hca[e] / kc; }
void sd3_c_d_u_GXK(int c, char d, unsigned int e) { gc = hca[e] / 7; }
void sd3_c_d_u_DGX(int c, char d, unsigned int e) { gps->c = hc / kca[e]; }
void sd3_c_d_u_DKX(int c, char d, unsigned int e) { gps->c = 100 / kca[e]; }
void sd3_c_d_u_DEX(int c, char d, unsigned int e) { gps->c = hca[2] / kca[e]; }
void sd3_c_d_u_DDX(int c, char d, unsigned int e) { gps->c = hps->c / kca[e]; }
void sd3_c_d_u_DRX(int c, char d, unsigned int e) { gps->c = d / kca[e]; }
void sd3_c_d_u_DXX(int c, char d, unsigned int e) { gps->c = hca[e] / kca[e]; }
void sd3_c_d_u_DXG(int c, char d, unsigned int e) { gps->c = hca[e] / kc; }
void sd3_c_d_u_DXK(int c, char d, unsigned int e) { gps->c = hca[e] / 7; }
void sd3_c_d_u_EGX(int c, char d, unsigned int e) { gca[3] = hc / kca[e]; }
void sd3_c_d_u_EKX(int c, char d, unsigned int e) { gca[3] = 100 / kca[e]; }
void sd3_c_d_u_EEX(int c, char d, unsigned int e) { gca[3] = hca[2] / kca[e]; }
void sd3_c_d_u_EDX(int c, char d, unsigned int e) { gca[3] = hps->c / kca[e]; }
void sd3_c_d_u_ERX(int c, char d, unsigned int e) { gca[3] = d / kca[e]; }
void sd3_c_d_u_EXX(int c, char d, unsigned int e) { gca[3] = hca[e] / kca[e]; }
void sd3_c_d_u_EXG(int c, char d, unsigned int e) { gca[3] = hca[e] / kc; }
void sd3_c_d_u_EXK(int c, char d, unsigned int e) { gca[3] = hca[e] / 7; }
void sd3_c_d_u_XGX(int c, char d, unsigned int e) { gca[e] = hc / kca[e]; }
void sd3_c_d_u_XKX(int c, char d, unsigned int e) { gca[e] = 100 / kca[e]; }
void sd3_c_d_u_XEX(int c, char d, unsigned int e) { gca[e] = hca[2] / kca[e]; }
void sd3_c_d_u_XDX(int c, char d, unsigned int e) { gca[e] = hps->c / kca[e]; }
void sd3_c_d_u_XRX(int c, char d, unsigned int e) { gca[e] = d / kca[e]; }
void sd3_c_d_u_XXX(int c, char d, unsigned int e) { gca[e] = hca[e] / kca[e]; }
void sd3_c_d_u_XXG(int c, char d, unsigned int e) { gca[e] = hca[e] / kc; }
void sd3_c_d_u_XXK(int c, char d, unsigned int e) { gca[e] = hca[e] / 7; }
void sd3_c_d_u_PGX(int c, char d, unsigned int e) { *gcp = hc / kca[e]; }
void sd3_c_d_u_PKX(int c, char d, unsigned int e) { *gcp = 100 / kca[e]; }
void sd3_c_d_u_PEX(int c, char d, unsigned int e) { *gcp = hca[2] / kca[e]; }
void sd3_c_d_u_PDX(int c, char d, unsigned int e) { *gcp = hps->c / kca[e]; }
void sd3_c_d_u_PRX(int c, char d, unsigned int e) { *gcp = d / kca[e]; }
void sd3_c_d_u_PXX(int c, char d, unsigned int e) { *gcp = hca[e] / kca[e]; }
void sd3_c_d_u_PXG(int c, char d, unsigned int e) { *gcp = hca[e] / kc; }
void sd3_c_d_u_PXK(int c, char d, unsigned int e) { *gcp = hca[e] / 7; }
void sd3_c_d_q_GGX(int c, char d, unsigned int e) { char t = jc; f0(); gc = hc / kca[t]; }
void sd3_c_d_q_GKX(int c, char d, unsigned int e) { char t = jc; f0(); gc = 100 / kca[t]; }
void sd3_c_d_q_GEX(int c, char d, unsigned int e) { char t = jc; f0(); gc = hca[2] / kca[t]; }
void sd3_c_d_q_GDX(int c, char d, unsigned int e) { char t = jc; f0(); gc = hps->c / kca[t]; }
void sd3_c_d_q_GRX(int c, char d, unsigned int e) { char t = jc; f0(); gc = d / kca[t]; }
void sd3_c_d_q_GXX(int c, char d, unsigned int e) { char t = jc; f0(); gc = hca[t] / kca[t]; }
void sd3_c_d_q_GXG(int c, char d, unsigned int e) { char t = jc; f0(); gc = hca[t] / kc; }
void sd3_c_d_q_GXK(int c, char d, unsigned int e) { char t = jc; f0(); gc = hca[t] / 7; }
void sd3_c_d_q_DGX(int c, char d, unsigned int e) { char t = jc; f0(); gps->c = hc / kca[t]; }
void sd3_c_d_q_DKX(int c, char d, unsigned int e) { char t = jc; f0(); gps->c = 100 / kca[t]; }
void sd3_c_d_q_DEX(int c, char d, unsigned int e) { char t = jc; f0(); gps->c = hca[2] / kca[t]; }
void sd3_c_d_q_DDX(int c, char d, unsigned int e) { char t = jc; f0(); gps->c = hps->c / kca[t]; }
void sd3_c_d_q_DRX(int c, char d, unsigned int e) { char t = jc; f0(); gps->c = d / kca[t]; }
void sd3_c_d_q_DXX(int c, char d, unsigned int e) { char t = jc; f0(); gps->c = hca[t] / kca[t]; }
void sd3_c_d_q_DXG(int c, char d, unsigned int e) { char t = jc; f0(); gps->c = hca[t] / kc; }
void sd3_c_d_q_DXK(int c, char d, unsigned int e) { char t = jc; f0(); gps->c = hca[t] / 7; }
void sd3_c_d_q_EGX(int c, char d, unsigned int e) { char t = jc; f0(); gca[3] = hc / kca[t]; }
void sd3_c_d_q_EKX(int c, char d, unsigned int e) { char t = jc; f0(); gca[3] = 100 / kca[t]; }
void sd3_c_d_q_EEX(int c, char d, unsigned int e) { char t = jc; f0(); gca[3] = hca[2] / kca[t]; }
void sd3_c_d_q_EDX(int c, char d, unsigned int e) { char t = jc; f0(); gca[3] = hps->c / kca[t]; }
void sd3_c_d_q_ERX(int c, char d, unsigned int e) { char t = jc; f0(); gca[3] = d / kca[t]; }
void sd3_c_d_q_EXX(int c, char d, unsigned int e) { char t = jc; f0(); gca[3] = hca[t] / kca[t]; }
void sd3_c_d_q_EXG(int c, char d, unsigned int e) { char t = jc; f0(); gca[3] = hca[t] / kc; }
void sd3_c_d_q_EXK(int c, char d, unsigned int e) { char t = jc; f0(); gca[3] = hca[t] / 7; }
void sd3_c_d_q_XGX(int c, char d, unsigned int e) { char t = jc; f0(); gca[t] = hc / kca[t]; }
void sd3_c_d_q_XKX(int c, char d, unsigned int e) { char t = jc; f0(); gca[t] = 100 / kca[t]; }
void sd3_c_d_q_XEX(int c, char d, unsigned int e) { char t = jc; f0(); gca[t] = hca[2] / kca[t]; }
void sd3_c_d_q_XDX(int c, char d, unsigned int e) { char t = jc; f0(); gca[t] = hps->c / kca[t]; }
void sd3_c_d_q_XRX(int c, char d, unsigned int e) { char t = jc; f0(); gca[t] = d / kca[t]; }
void sd3_c_d_q_XXX(int c, char d, unsigned int e) { char t = jc; f0(); gca[t] = hca[t] / kca[t]; }
void sd3_c_d_q_XXG(int c, char d, unsigned int e) { char t = jc; f0(); gca[t] = hca[t] / kc; }
void sd3_c_d_q_XXK(int c, char d, unsigned int e) { char t = jc; f0(); gca[t] = hca[t] / 7; }
void sd3_c_d_q_PGX(int c, char d, unsigned int e) { char t = jc; f0(); *gcp = hc / kca[t]; }
void sd3_c_d_q_PKX(int c, char d, unsigned int e) { char t = jc; f0(); *gcp = 100 / kca[t]; }
void sd3_c_d_q_PEX(int c, char d, unsigned int e) { char t = jc; f0(); *gcp = hca[2] / kca[t]; }
void sd3_c_d_q_PDX(int c, char d, unsigned int e) { char t = jc; f0(); *gcp = hps->c / kca[t]; }
void sd3_c_d_q_PRX(int c, char d, unsigned int e) { char t = jc; f0(); *gcp = d / kca[t]; }
void sd3_c_d_q_PXX(int c, char d, unsigned int e) { char t = jc; f0(); *gcp = hca[t] / kca[t]; }
void sd3_c_d_q_PXG(int c, char d, unsigned int e) { char t = jc; f0(); *gcp = hca[t] / kc; }
void sd3_c_d_q_PXK(int c, char d, unsigned int e) { char t = jc; f0(); *gcp = hca[t] / 7; }
void sd3_c_d_r_GGX(int c, char d, unsigned int e) { char t = jc; gc = hc / kca[t]; }
void sd3_c_d_r_GKX(int c, char d, unsigned int e) { char t = jc; gc = 100 / kca[t]; }
void sd3_c_d_r_GEX(int c, char d, unsigned int e) { char t = jc; gc = hca[2] / kca[t]; }
void sd3_c_d_r_GDX(int c, char d, unsigned int e) { char t = jc; gc = hps->c / kca[t]; }
void sd3_c_d_r_GRX(int c, char d, unsigned int e) { char t = jc; gc = d / kca[t]; }
void sd3_c_d_r_GXX(int c, char d, unsigned int e) { char t = jc; gc = hca[t] / kca[t]; }
void sd3_c_d_r_GXG(int c, char d, unsigned int e) { char t = jc; gc = hca[t] / kc; }
void sd3_c_d_r_GXK(int c, char d, unsigned int e) { char t = jc; gc = hca[t] / 7; }
void sd3_c_d_r_DGX(int c, char d, unsigned int e) { char t = jc; gps->c = hc / kca[t]; }
void sd3_c_d_r_DKX(int c, char d, unsigned int e) { char t = jc; gps->c = 100 / kca[t]; }
void sd3_c_d_r_DEX(int c, char d, unsigned int e) { char t = jc; gps->c = hca[2] / kca[t]; }
void sd3_c_d_r_DDX(int c, char d, unsigned int e) { char t = jc; gps->c = hps->c / kca[t]; }
void sd3_c_d_r_DRX(int c, char d, unsigned int e) { char t = jc; gps->c = d / kca[t]; }
void sd3_c_d_r_DXX(int c, char d, unsigned int e) { char t = jc; gps->c = hca[t] / kca[t]; }
void sd3_c_d_r_DXG(int c, char d, unsigned int e) { char t = jc; gps->c = hca[t] / kc; }
void sd3_c_d_r_DXK(int c, char d, unsigned int e) { char t = jc; gps->c = hca[t] / 7; }
void sd3_c_d_r_EGX(int c, char d, unsigned int e) { char t = jc; gca[3] = hc / kca[t]; }
void sd3_c_d_r_EKX(int c, char d, unsigned int e) { char t = jc; gca[3] = 100 / kca[t]; }
void sd3_c_d_r_EEX(int c, char d, unsigned int e) { char t = jc; gca[3] = hca[2] / kca[t]; }
void sd3_c_d_r_EDX(int c, char d, unsigned int e) { char t = jc; gca[3] = hps->c / kca[t]; }
void sd3_c_d_r_ERX(int c, char d, unsigned int e) { char t = jc; gca[3] = d / kca[t]; }
void sd3_c_d_r_EXX(int c, char d, unsigned int e) { char t = jc; gca[3] = hca[t] / kca[t]; }
void sd3_c_d_r_EXG(int c, char d, unsigned int e) { char t = jc; gca[3] = hca[t] / kc; }
void sd3_c_d_r_EXK(int c, char d, unsigned int e) { char t = jc; gca[3] = hca[t] / 7; }
void sd3_c_d_r_XGX(int c, char d, unsigned int e) { char t = jc; gca[t] = hc / kca[t]; }
void sd3_c_d_r_XKX(int c, char d, unsigned int e) { char t = jc; gca[t] = 100 / kca[t]; }
void sd3_c_d_r_XEX(int c, char d, unsigned int e) { char t = jc; gca[t] = hca[2] / kca[t]; }
void sd3_c_d_r_XDX(int c, char d, unsigned int e) { char t = jc; gca[t] = hps->c / kca[t]; }
void sd3_c_d_r_XRX(int c, char d, unsigned int e) { char t = jc; gca[t] = d / kca[t]; }
void sd3_c_d_r_XXX(int c, char d, unsigned int e) { char t = jc; gca[t] = hca[t] / kca[t]; }
void sd3_c_d_r_XXG(int c, char d, unsigned int e) { char t = jc; gca[t] = hca[t] / kc; }
void sd3_c_d_r_XXK(int c, char d, unsigned int e) { char t = jc; gca[t] = hca[t] / 7; }
void sd3_c_d_r_PGX(int c, char d, unsigned int e) { char t = jc; *gcp = hc / kca[t]; }
void sd3_c_d_r_PKX(int c, char d, unsigned int e) { char t = jc; *gcp = 100 / kca[t]; }
void sd3_c_d_r_PEX(int c, char d, unsigned int e) { char t = jc; *gcp = hca[2] / kca[t]; }
void sd3_c_d_r_PDX(int c, char d, unsigned int e) { char t = jc; *gcp = hps->c / kca[t]; }
void sd3_c_d_r_PRX(int c, char d, unsigned int e) { char t = jc; *gcp = d / kca[t]; }
void sd3_c_d_r_PXX(int c, char d, unsigned int e) { char t = jc; *gcp = hca[t] / kca[t]; }
void sd3_c_d_r_PXG(int c, char d, unsigned int e) { char t = jc; *gcp = hca[t] / kc; }
void sd3_c_d_r_PXK(int c, char d, unsigned int e) { char t = jc; *gcp = hca[t] / 7; }
void sd3_c_d_l_GGX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gc = hc / kca[i]; }
void sd3_c_d_l_GKX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gc = 100 / kca[i]; }
void sd3_c_d_l_GEX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gc = hca[2] / kca[i]; }
void sd3_c_d_l_GDX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gc = hps->c / kca[i]; }
void sd3_c_d_l_GRX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gc = d / kca[i]; }
void sd3_c_d_l_GXX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gc = hca[i] / kca[i]; }
void sd3_c_d_l_GXG(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gc = hca[i] / kc; }
void sd3_c_d_l_GXK(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gc = hca[i] / 7; }
void sd3_c_d_l_DGX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->c = hc / kca[i]; }
void sd3_c_d_l_DKX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->c = 100 / kca[i]; }
void sd3_c_d_l_DEX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->c = hca[2] / kca[i]; }
void sd3_c_d_l_DDX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->c = hps->c / kca[i]; }
void sd3_c_d_l_DRX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->c = d / kca[i]; }
void sd3_c_d_l_DXX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->c = hca[i] / kca[i]; }
void sd3_c_d_l_DXG(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->c = hca[i] / kc; }
void sd3_c_d_l_DXK(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->c = hca[i] / 7; }
void sd3_c_d_l_EGX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[3] = hc / kca[i]; }
void sd3_c_d_l_EKX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[3] = 100 / kca[i]; }
void sd3_c_d_l_EEX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[3] = hca[2] / kca[i]; }
void sd3_c_d_l_EDX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[3] = hps->c / kca[i]; }
void sd3_c_d_l_ERX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[3] = d / kca[i]; }
void sd3_c_d_l_EXX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[3] = hca[i] / kca[i]; }
void sd3_c_d_l_EXG(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[3] = hca[i] / kc; }
void sd3_c_d_l_EXK(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[3] = hca[i] / 7; }
void sd3_c_d_l_XGX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[i] = hc / kca[i]; }
void sd3_c_d_l_XKX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[i] = 100 / kca[i]; }
void sd3_c_d_l_XEX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[i] = hca[2] / kca[i]; }
void sd3_c_d_l_XDX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[i] = hps->c / kca[i]; }
void sd3_c_d_l_XRX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[i] = d / kca[i]; }
void sd3_c_d_l_XXX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[i] = hca[i] / kca[i]; }
void sd3_c_d_l_XXG(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[i] = hca[i] / kc; }
void sd3_c_d_l_XXK(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[i] = hca[i] / 7; }
void sd3_c_d_l_PGX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gcp = hc / kca[i]; }
void sd3_c_d_l_PKX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gcp = 100 / kca[i]; }
void sd3_c_d_l_PEX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gcp = hca[2] / kca[i]; }
void sd3_c_d_l_PDX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gcp = hps->c / kca[i]; }
void sd3_c_d_l_PRX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gcp = d / kca[i]; }
void sd3_c_d_l_PXX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gcp = hca[i] / kca[i]; }
void sd3_c_d_l_PXG(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gcp = hca[i] / kc; }
void sd3_c_d_l_PXK(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gcp = hca[i] / 7; }
void sd3_c_m_p_GGX(int c, char d, unsigned int e) { gc = hc % kca[c]; }
void sd3_c_m_p_GKX(int c, char d, unsigned int e) { gc = 100 % kca[c]; }
void sd3_c_m_p_GEX(int c, char d, unsigned int e) { gc = hca[2] % kca[c]; }
void sd3_c_m_p_GDX(int c, char d, unsigned int e) { gc = hps->c % kca[c]; }
void sd3_c_m_p_GRX(int c, char d, unsigned int e) { gc = d % kca[c]; }
void sd3_c_m_p_GXX(int c, char d, unsigned int e) { gc = hca[c] % kca[c]; }
void sd3_c_m_p_GXG(int c, char d, unsigned int e) { gc = hca[c] % kc; }
void sd3_c_m_p_GXK(int c, char d, unsigned int e) { gc = hca[c] % 7; }
void sd3_c_m_p_DGX(int c, char d, unsigned int e) { gps->c = hc % kca[c]; }
void sd3_c_m_p_DKX(int c, char d, unsigned int e) { gps->c = 100 % kca[c]; }
void sd3_c_m_p_DEX(int c, char d, unsigned int e) { gps->c = hca[2] % kca[c]; }
void sd3_c_m_p_DDX(int c, char d, unsigned int e) { gps->c = hps->c % kca[c]; }
void sd3_c_m_p_DRX(int c, char d, unsigned int e) { gps->c = d % kca[c]; }
void sd3_c_m_p_DXX(int c, char d, unsigned int e) { gps->c = hca[c] % kca[c]; }
void sd3_c_m_p_DXG(int c, char d, unsigned int e) { gps->c = hca[c] % kc; }
void sd3_c_m_p_DXK(int c, char d, unsigned int e) { gps->c = hca[c] % 7; }
void sd3_c_m_p_EGX(int c, char d, unsigned int e) { gca[3] = hc % kca[c]; }
void sd3_c_m_p_EKX(int c, char d, unsigned int e) { gca[3] = 100 % kca[c]; }
void sd3_c_m_p_EEX(int c, char d, unsigned int e) { gca[3] = hca[2] % kca[c]; }
void sd3_c_m_p_EDX(int c, char d, unsigned int e) { gca[3] = hps->c % kca[c]; }
void sd3_c_m_p_ERX(int c, char d, unsigned int e) { gca[3] = d % kca[c]; }
void sd3_c_m_p_EXX(int c, char d, unsigned int e) { gca[3] = hca[c] % kca[c]; }
void sd3_c_m_p_EXG(int c, char d, unsigned int e) { gca[3] = hca[c] % kc; }
void sd3_c_m_p_EXK(int c, char d, unsigned int e) { gca[3] = hca[c] % 7; }
void sd3_c_m_p_XGX(int c, char d, unsigned int e) { gca[c] = hc % kca[c]; }
void sd3_c_m_p_XKX(int c, char d, unsigned int e) { gca[c] = 100 % kca[c]; }
void sd3_c_m_p_XEX(int c, char d, unsigned int e) { gca[c] = hca[2] % kca[c]; }
void sd3_c_m_p_XDX(int c, char d, unsigned int e) { gca[c] = hps->c % kca[c]; }
void sd3_c_m_p_XRX(int c, char d, unsigned int e) { gca[c] = d % kca[c]; }
void sd3_c_m_p_XXX(int c, char d, unsigned int e) { gca[c] = hca[c] % kca[c]; }
void sd3_c_m_p_XXG(int c, char d, unsigned int e) { gca[c] = hca[c] % kc; }
void sd3_c_m_p_XXK(int c, char d, unsigned int e) { gca[c] = hca[c] % 7; }
void sd3_c_m_p_PGX(int c, char d, unsigned int e) { *gcp = hc % kca[c]; }
void sd3_c_m_p_PKX(int c, char d, unsigned int e) { *gcp = 100 % kca[c]; }
void sd3_c_m_p_PEX(int c, char d, unsigned int e) { *gcp = hca[2] % kca[c]; }
void sd3_c_m_p_PDX(int c, char d, unsigned int e) { *gcp = hps->c % kca[c]; }
void sd3_c_m_p_PRX(int c, char d, unsigned int e) { *gcp = d % kca[c]; }
void sd3_c_m_p_PXX(int c, char d, unsigned int e) { *gcp = hca[c] % kca[c]; }
void sd3_c_m_p_PXG(int c, char d, unsigned int e) { *gcp = hca[c] % kc; }
void sd3_c_m_p_PXK(int c, char d, unsigned int e) { *gcp = hca[c] % 7; }
void sd3_c_m_u_GGX(int c, char d, unsigned int e) { gc = hc % kca[e]; }
void sd3_c_m_u_GKX(int c, char d, unsigned int e) { gc = 100 % kca[e]; }
void sd3_c_m_u_GEX(int c, char d, unsigned int e) { gc = hca[2] % kca[e]; }
void sd3_c_m_u_GDX(int c, char d, unsigned int e) { gc = hps->c % kca[e]; }
void sd3_c_m_u_GRX(int c, char d, unsigned int e) { gc = d % kca[e]; }
void sd3_c_m_u_GXX(int c, char d, unsigned int e) { gc = hca[e] % kca[e]; }
void sd3_c_m_u_GXG(int c, char d, unsigned int e) { gc = hca[e] % kc; }
void sd3_c_m_u_GXK(int c, char d, unsigned int e) { gc = hca[e] % 7; }
void sd3_c_m_u_DGX(int c, char d, unsigned int e) { gps->c = hc % kca[e]; }
void sd3_c_m_u_DKX(int c, char d, unsigned int e) { gps->c = 100 % kca[e]; }
void sd3_c_m_u_DEX(int c, char d, unsigned int e) { gps->c = hca[2] % kca[e]; }
void sd3_c_m_u_DDX(int c, char d, unsigned int e) { gps->c = hps->c % kca[e]; }
void sd3_c_m_u_DRX(int c, char d, unsigned int e) { gps->c = d % kca[e]; }
void sd3_c_m_u_DXX(int c, char d, unsigned int e) { gps->c = hca[e] % kca[e]; }
void sd3_c_m_u_DXG(int c, char d, unsigned int e) { gps->c = hca[e] % kc; }
void sd3_c_m_u_DXK(int c, char d, unsigned int e) { gps->c = hca[e] % 7; }
void sd3_c_m_u_EGX(int c, char d, unsigned int e) { gca[3] = hc % kca[e]; }
void sd3_c_m_u_EKX(int c, char d, unsigned int e) { gca[3] = 100 % kca[e]; }
void sd3_c_m_u_EEX(int c, char d, unsigned int e) { gca[3] = hca[2] % kca[e]; }
void sd3_c_m_u_EDX(int c, char d, unsigned int e) { gca[3] = hps->c % kca[e]; }
void sd3_c_m_u_ERX(int c, char d, unsigned int e) { gca[3] = d % kca[e]; }
void sd3_c_m_u_EXX(int c, char d, unsigned int e) { gca[3] = hca[e] % kca[e]; }
void sd3_c_m_u_EXG(int c, char d, unsigned int e) { gca[3] = hca[e] % kc; }
void sd3_c_m_u_EXK(int c, char d, unsigned int e) { gca[3] = hca[e] % 7; }
void sd3_c_m_u_XGX(int c, char d, unsigned int e) { gca[e] = hc % kca[e]; }
void sd3_c_m_u_XKX(int c, char d, unsigned int e) { gca[e] = 100 % kca[e]; }
void sd3_c_m_u_XEX(int c, char d, unsigned int e) { gca[e] = hca[2] % kca[e]; }
void sd3_c_m_u_XDX(int c, char d, unsigned int e) { gca[e] = hps->c % kca[e]; }
void sd3_c_m_u_XRX(int c, char d, unsigned int e) { gca[e] = d % kca[e]; }
void sd3_c_m_u_XXX(int c, char d, unsigned int e) { gca[e] = hca[e] % kca[e]; }
void sd3_c_m_u_XXG(int c, char d, unsigned int e) { gca[e] = hca[e] % kc; }
void sd3_c_m_u_XXK(int c, char d, unsigned int e) { gca[e] = hca[e] % 7; }
void sd3_c_m_u_PGX(int c, char d, unsigned int e) { *gcp = hc % kca[e]; }
void sd3_c_m_u_PKX(int c, char d, unsigned int e) { *gcp = 100 % kca[e]; }
void sd3_c_m_u_PEX(int c, char d, unsigned int e) { *gcp = hca[2] % kca[e]; }
void sd3_c_m_u_PDX(int c, char d, unsigned int e) { *gcp = hps->c % kca[e]; }
void sd3_c_m_u_PRX(int c, char d, unsigned int e) { *gcp = d % kca[e]; }
void sd3_c_m_u_PXX(int c, char d, unsigned int e) { *gcp = hca[e] % kca[e]; }
void sd3_c_m_u_PXG(int c, char d, unsigned int e) { *gcp = hca[e] % kc; }
void sd3_c_m_u_PXK(int c, char d, unsigned int e) { *gcp = hca[e] % 7; }
void sd3_c_m_q_GGX(int c, char d, unsigned int e) { char t = jc; f0(); gc = hc % kca[t]; }
void sd3_c_m_q_GKX(int c, char d, unsigned int e) { char t = jc; f0(); gc = 100 % kca[t]; }
void sd3_c_m_q_GEX(int c, char d, unsigned int e) { char t = jc; f0(); gc = hca[2] % kca[t]; }
void sd3_c_m_q_GDX(int c, char d, unsigned int e) { char t = jc; f0(); gc = hps->c % kca[t]; }
void sd3_c_m_q_GRX(int c, char d, unsigned int e) { char t = jc; f0(); gc = d % kca[t]; }
void sd3_c_m_q_GXX(int c, char d, unsigned int e) { char t = jc; f0(); gc = hca[t] % kca[t]; }
void sd3_c_m_q_GXG(int c, char d, unsigned int e) { char t = jc; f0(); gc = hca[t] % kc; }
void sd3_c_m_q_GXK(int c, char d, unsigned int e) { char t = jc; f0(); gc = hca[t] % 7; }
void sd3_c_m_q_DGX(int c, char d, unsigned int e) { char t = jc; f0(); gps->c = hc % kca[t]; }
void sd3_c_m_q_DKX(int c, char d, unsigned int e) { char t = jc; f0(); gps->c = 100 % kca[t]; }
void sd3_c_m_q_DEX(int c, char d, unsigned int e) { char t = jc; f0(); gps->c = hca[2] % kca[t]; }
void sd3_c_m_q_DDX(int c, char d, unsigned int e) { char t = jc; f0(); gps->c = hps->c % kca[t]; }
void sd3_c_m_q_DRX(int c, char d, unsigned int e) { char t = jc; f0(); gps->c = d % kca[t]; }
void sd3_c_m_q_DXX(int c, char d, unsigned int e) { char t = jc; f0(); gps->c = hca[t] % kca[t]; }
void sd3_c_m_q_DXG(int c, char d, unsigned int e) { char t = jc; f0(); gps->c = hca[t] % kc; }
void sd3_c_m_q_DXK(int c, char d, unsigned int e) { char t = jc; f0(); gps->c = hca[t] % 7; }
void sd3_c_m_q_EGX(int c, char d, unsigned int e) { char t = jc; f0(); gca[3] = hc % kca[t]; }
void sd3_c_m_q_EKX(int c, char d, unsigned int e) { char t = jc; f0(); gca[3] = 100 % kca[t]; }
void sd3_c_m_q_EEX(int c, char d, unsigned int e) { char t = jc; f0(); gca[3] = hca[2] % kca[t]; }
void sd3_c_m_q_EDX(int c, char d, unsigned int e) { char t = jc; f0(); gca[3] = hps->c % kca[t]; }
void sd3_c_m_q_ERX(int c, char d, unsigned int e) { char t = jc; f0(); gca[3] = d % kca[t]; }
void sd3_c_m_q_EXX(int c, char d, unsigned int e) { char t = jc; f0(); gca[3] = hca[t] % kca[t]; }
void sd3_c_m_q_EXG(int c, char d, unsigned int e) { char t = jc; f0(); gca[3] = hca[t] % kc; }
void sd3_c_m_q_EXK(int c, char d, unsigned int e) { char t = jc; f0(); gca[3] = hca[t] % 7; }
void sd3_c_m_q_XGX(int c, char d, unsigned int e) { char t = jc; f0(); gca[t] = hc % kca[t]; }
void sd3_c_m_q_XKX(int c, char d, unsigned int e) { char t = jc; f0(); gca[t] = 100 % kca[t]; }
void sd3_c_m_q_XEX(int c, char d, unsigned int e) { char t = jc; f0(); gca[t] = hca[2] % kca[t]; }
void sd3_c_m_q_XDX(int c, char d, unsigned int e) { char t = jc; f0(); gca[t] = hps->c % kca[t]; }
void sd3_c_m_q_XRX(int c, char d, unsigned int e) { char t = jc; f0(); gca[t] = d % kca[t]; }
void sd3_c_m_q_XXX(int c, char d, unsigned int e) { char t = jc; f0(); gca[t] = hca[t] % kca[t]; }
void sd3_c_m_q_XXG(int c, char d, unsigned int e) { char t = jc; f0(); gca[t] = hca[t] % kc; }
void sd3_c_m_q_XXK(int c, char d, unsigned int e) { char t = jc; f0(); gca[t] = hca[t] % 7; }
void sd3_c_m_q_PGX(int c, char d, unsigned int e) { char t = jc; f0(); *gcp = hc % kca[t]; }
void sd3_c_m_q_PKX(int c, char d, unsigned int e) { char t = jc; f0(); *gcp = 100 % kca[t]; }
void sd3_c_m_q_PEX(int c, char d, unsigned int e) { char t = jc; f0(); *gcp = hca[2] % kca[t]; }
void sd3_c_m_q_PDX(int c, char d, unsigned int e) { char t = jc; f0(); *gcp = hps->c % kca[t]; }
void sd3_c_m_q_PRX(int c, char d, unsigned int e) { char t = jc; f0(); *gcp = d % kca[t]; }
void sd3_c_m_q_PXX(int c, char d, unsigned int e) { char t = jc; f0(); *gcp = hca[t] % kca[t]; }
void sd3_c_m_q_PXG(int c, char d, unsigned int e) { char t = jc; f0(); *gcp = hca[t] % kc; }
void sd3_c_m_q_PXK(int c, char d, unsigned int e) { char t = jc; f0(); *gcp = hca[t] % 7; }
void sd3_c_m_r_GGX(int c, char d, unsigned int e) { char t = jc; gc = hc % kca[t]; }
void sd3_c_m_r_GKX(int c, char d, unsigned int e) { char t = jc; gc = 100 % kca[t]; }
void sd3_c_m_r_GEX(int c, char d, unsigned int e) { char t = jc; gc = hca[2] % kca[t]; }
void sd3_c_m_r_GDX(int c, char d, unsigned int e) { char t = jc; gc = hps->c % kca[t]; }
void sd3_c_m_r_GRX(int c, char d, unsigned int e) { char t = jc; gc = d % kca[t]; }
void sd3_c_m_r_GXX(int c, char d, unsigned int e) { char t = jc; gc = hca[t] % kca[t]; }
void sd3_c_m_r_GXG(int c, char d, unsigned int e) { char t = jc; gc = hca[t] % kc; }
void sd3_c_m_r_GXK(int c, char d, unsigned int e) { char t = jc; gc = hca[t] % 7; }
void sd3_c_m_r_DGX(int c, char d, unsigned int e) { char t = jc; gps->c = hc % kca[t]; }
void sd3_c_m_r_DKX(int c, char d, unsigned int e) { char t = jc; gps->c = 100 % kca[t]; }
void sd3_c_m_r_DEX(int c, char d, unsigned int e) { char t = jc; gps->c = hca[2] % kca[t]; }
void sd3_c_m_r_DDX(int c, char d, unsigned int e) { char t = jc; gps->c = hps->c % kca[t]; }
void sd3_c_m_r_DRX(int c, char d, unsigned int e) { char t = jc; gps->c = d % kca[t]; }
void sd3_c_m_r_DXX(int c, char d, unsigned int e) { char t = jc; gps->c = hca[t] % kca[t]; }
void sd3_c_m_r_DXG(int c, char d, unsigned int e) { char t = jc; gps->c = hca[t] % kc; }
void sd3_c_m_r_DXK(int c, char d, unsigned int e) { char t = jc; gps->c = hca[t] % 7; }
void sd3_c_m_r_EGX(int c, char d, unsigned int e) { char t = jc; gca[3] = hc % kca[t]; }
void sd3_c_m_r_EKX(int c, char d, unsigned int e) { char t = jc; gca[3] = 100 % kca[t]; }
void sd3_c_m_r_EEX(int c, char d, unsigned int e) { char t = jc; gca[3] = hca[2] % kca[t]; }
void sd3_c_m_r_EDX(int c, char d, unsigned int e) { char t = jc; gca[3] = hps->c % kca[t]; }
void sd3_c_m_r_ERX(int c, char d, unsigned int e) { char t = jc; gca[3] = d % kca[t]; }
void sd3_c_m_r_EXX(int c, char d, unsigned int e) { char t = jc; gca[3] = hca[t] % kca[t]; }
void sd3_c_m_r_EXG(int c, char d, unsigned int e) { char t = jc; gca[3] = hca[t] % kc; }
void sd3_c_m_r_EXK(int c, char d, unsigned int e) { char t = jc; gca[3] = hca[t] % 7; }
void sd3_c_m_r_XGX(int c, char d, unsigned int e) { char t = jc; gca[t] = hc % kca[t]; }
void sd3_c_m_r_XKX(int c, char d, unsigned int e) { char t = jc; gca[t] = 100 % kca[t]; }
void sd3_c_m_r_XEX(int c, char d, unsigned int e) { char t = jc; gca[t] = hca[2] % kca[t]; }
void sd3_c_m_r_XDX(int c, char d, unsigned int e) { char t = jc; gca[t] = hps->c % kca[t]; }
void sd3_c_m_r_XRX(int c, char d, unsigned int e) { char t = jc; gca[t] = d % kca[t]; }
void sd3_c_m_r_XXX(int c, char d, unsigned int e) { char t = jc; gca[t] = hca[t] % kca[t]; }
void sd3_c_m_r_XXG(int c, char d, unsigned int e) { char t = jc; gca[t] = hca[t] % kc; }
void sd3_c_m_r_XXK(int c, char d, unsigned int e) { char t = jc; gca[t] = hca[t] % 7; }
void sd3_c_m_r_PGX(int c, char d, unsigned int e) { char t = jc; *gcp = hc % kca[t]; }
void sd3_c_m_r_PKX(int c, char d, unsigned int e) { char t = jc; *gcp = 100 % kca[t]; }
void sd3_c_m_r_PEX(int c, char d, unsigned int e) { char t = jc; *gcp = hca[2] % kca[t]; }
void sd3_c_m_r_PDX(int c, char d, unsigned int e) { char t = jc; *gcp = hps->c % kca[t]; }
void sd3_c_m_r_PRX(int c, char d, unsigned int e) { char t = jc; *gcp = d % kca[t]; }
void sd3_c_m_r_PXX(int c, char d, unsigned int e) { char t = jc; *gcp = hca[t] % kca[t]; }
void sd3_c_m_r_PXG(int c, char d, unsigned int e) { char t = jc; *gcp = hca[t] % kc; }
void sd3_c_m_r_PXK(int c, char d, unsigned int e) { char t = jc; *gcp = hca[t] % 7; }
void sd3_c_m_l_GGX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gc = hc % kca[i]; }
void sd3_c_m_l_GKX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gc = 100 % kca[i]; }
void sd3_c_m_l_GEX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gc = hca[2] % kca[i]; }
void sd3_c_m_l_GDX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gc = hps->c % kca[i]; }
void sd3_c_m_l_GRX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gc = d % kca[i]; }
void sd3_c_m_l_GXX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gc = hca[i] % kca[i]; }
void sd3_c_m_l_GXG(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gc = hca[i] % kc; }
void sd3_c_m_l_GXK(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gc = hca[i] % 7; }
void sd3_c_m_l_DGX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->c = hc % kca[i]; }
void sd3_c_m_l_DKX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->c = 100 % kca[i]; }
void sd3_c_m_l_DEX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->c = hca[2] % kca[i]; }
void sd3_c_m_l_DDX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->c = hps->c % kca[i]; }
void sd3_c_m_l_DRX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->c = d % kca[i]; }
void sd3_c_m_l_DXX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->c = hca[i] % kca[i]; }
void sd3_c_m_l_DXG(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->c = hca[i] % kc; }
void sd3_c_m_l_DXK(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gps->c = hca[i] % 7; }
void sd3_c_m_l_EGX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[3] = hc % kca[i]; }
void sd3_c_m_l_EKX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[3] = 100 % kca[i]; }
void sd3_c_m_l_EEX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[3] = hca[2] % kca[i]; }
void sd3_c_m_l_EDX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[3] = hps->c % kca[i]; }
void sd3_c_m_l_ERX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[3] = d % kca[i]; }
void sd3_c_m_l_EXX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[3] = hca[i] % kca[i]; }
void sd3_c_m_l_EXG(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[3] = hca[i] % kc; }
void sd3_c_m_l_EXK(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[3] = hca[i] % 7; }
void sd3_c_m_l_XGX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[i] = hc % kca[i]; }
void sd3_c_m_l_XKX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[i] = 100 % kca[i]; }
void sd3_c_m_l_XEX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[i] = hca[2] % kca[i]; }
void sd3_c_m_l_XDX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[i] = hps->c % kca[i]; }
void sd3_c_m_l_XRX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[i] = d % kca[i]; }
void sd3_c_m_l_XXX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[i] = hca[i] % kca[i]; }
void sd3_c_m_l_XXG(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[i] = hca[i] % kc; }
void sd3_c_m_l_XXK(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) gca[i] = hca[i] % 7; }
void sd3_c_m_l_PGX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gcp = hc % kca[i]; }
void sd3_c_m_l_PKX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gcp = 100 % kca[i]; }
void sd3_c_m_l_PEX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gcp = hca[2] % kca[i]; }
void sd3_c_m_l_PDX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gcp = hps->c % kca[i]; }
void sd3_c_m_l_PRX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gcp = d % kca[i]; }
void sd3_c_m_l_PXX(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gcp = hca[i] % kca[i]; }
void sd3_c_m_l_PXG(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gcp = hca[i] % kc; }
void sd3_c_m_l_PXK(int c, char d, unsigned int e) { int i; for (i = 0; i < 4; i++) *gcp = hca[i] % 7; }
