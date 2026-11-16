/* lane_o3 probe: a compare against an array element at a variable index; see gen_cmpel.py */
extern int gi3, ji;
extern unsigned int ju;
extern unsigned char gc, kca[8], aca[8], uca[], *gpc, *qc;
struct sc { int pad; unsigned char m; };
extern struct sc gsc;
extern int gi, kia[8], aia[8], uia[], *gpi, *qi;
struct si { int pad; int m; };
extern struct si gsi;
extern long gl, kla[8], ala[8], ula[], *gpl, *ql;
struct sl { int pad; long m; };
extern struct sl gsl;
void ce_c_g_a_P_eq(int i) { if (gc == aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_a_P_ne(int i) { if (gc != aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_a_P_lt(int i) { if (gc < aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_a_P_ge(int i) { if (gc >= aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_a_L_eq(void) { int i = ji; if (gc == aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_a_L_ne(void) { int i = ji; if (gc != aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_a_L_lt(void) { int i = ji; if (gc < aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_a_L_ge(void) { int i = ji; if (gc >= aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_a_U_eq(void) { unsigned int i = ju; if (gc == aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_a_U_ne(void) { unsigned int i = ju; if (gc != aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_a_U_lt(void) { unsigned int i = ju; if (gc < aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_a_U_ge(void) { unsigned int i = ju; if (gc >= aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_u_P_eq(int i) { if (gc == uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_u_P_ne(int i) { if (gc != uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_u_P_lt(int i) { if (gc < uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_u_P_ge(int i) { if (gc >= uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_u_L_eq(void) { int i = ji; if (gc == uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_u_L_ne(void) { int i = ji; if (gc != uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_u_L_lt(void) { int i = ji; if (gc < uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_u_L_ge(void) { int i = ji; if (gc >= uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_u_U_eq(void) { unsigned int i = ju; if (gc == uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_u_U_ne(void) { unsigned int i = ju; if (gc != uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_u_U_lt(void) { unsigned int i = ju; if (gc < uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_u_U_ge(void) { unsigned int i = ju; if (gc >= uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_p_P_eq(unsigned char *p, int i) { if (gc == p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_p_P_ne(unsigned char *p, int i) { if (gc != p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_p_P_lt(unsigned char *p, int i) { if (gc < p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_p_P_ge(unsigned char *p, int i) { if (gc >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_p_L_eq(unsigned char *p) { int i = ji; if (gc == p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_p_L_ne(unsigned char *p) { int i = ji; if (gc != p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_p_L_lt(unsigned char *p) { int i = ji; if (gc < p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_p_L_ge(unsigned char *p) { int i = ji; if (gc >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_p_U_eq(unsigned char *p) { unsigned int i = ju; if (gc == p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_p_U_ne(unsigned char *p) { unsigned int i = ju; if (gc != p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_p_U_lt(unsigned char *p) { unsigned int i = ju; if (gc < p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_p_U_ge(unsigned char *p) { unsigned int i = ju; if (gc >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_q_P_eq(int i) { if (gc == qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_q_P_ne(int i) { if (gc != qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_q_P_lt(int i) { if (gc < qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_q_P_ge(int i) { if (gc >= qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_q_L_eq(void) { int i = ji; if (gc == qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_q_L_ne(void) { int i = ji; if (gc != qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_q_L_lt(void) { int i = ji; if (gc < qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_q_L_ge(void) { int i = ji; if (gc >= qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_q_U_eq(void) { unsigned int i = ju; if (gc == qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_q_U_ne(void) { unsigned int i = ju; if (gc != qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_q_U_lt(void) { unsigned int i = ju; if (gc < qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_g_q_U_ge(void) { unsigned int i = ju; if (gc >= qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_a_P_eq(int i) { if (kca[3] == aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_a_P_ne(int i) { if (kca[3] != aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_a_P_lt(int i) { if (kca[3] < aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_a_P_ge(int i) { if (kca[3] >= aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_a_L_eq(void) { int i = ji; if (kca[3] == aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_a_L_ne(void) { int i = ji; if (kca[3] != aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_a_L_lt(void) { int i = ji; if (kca[3] < aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_a_L_ge(void) { int i = ji; if (kca[3] >= aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_a_U_eq(void) { unsigned int i = ju; if (kca[3] == aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_a_U_ne(void) { unsigned int i = ju; if (kca[3] != aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_a_U_lt(void) { unsigned int i = ju; if (kca[3] < aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_a_U_ge(void) { unsigned int i = ju; if (kca[3] >= aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_u_P_eq(int i) { if (kca[3] == uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_u_P_ne(int i) { if (kca[3] != uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_u_P_lt(int i) { if (kca[3] < uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_u_P_ge(int i) { if (kca[3] >= uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_u_L_eq(void) { int i = ji; if (kca[3] == uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_u_L_ne(void) { int i = ji; if (kca[3] != uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_u_L_lt(void) { int i = ji; if (kca[3] < uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_u_L_ge(void) { int i = ji; if (kca[3] >= uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_u_U_eq(void) { unsigned int i = ju; if (kca[3] == uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_u_U_ne(void) { unsigned int i = ju; if (kca[3] != uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_u_U_lt(void) { unsigned int i = ju; if (kca[3] < uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_u_U_ge(void) { unsigned int i = ju; if (kca[3] >= uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_p_P_eq(unsigned char *p, int i) { if (kca[3] == p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_p_P_ne(unsigned char *p, int i) { if (kca[3] != p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_p_P_lt(unsigned char *p, int i) { if (kca[3] < p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_p_P_ge(unsigned char *p, int i) { if (kca[3] >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_p_L_eq(unsigned char *p) { int i = ji; if (kca[3] == p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_p_L_ne(unsigned char *p) { int i = ji; if (kca[3] != p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_p_L_lt(unsigned char *p) { int i = ji; if (kca[3] < p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_p_L_ge(unsigned char *p) { int i = ji; if (kca[3] >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_p_U_eq(unsigned char *p) { unsigned int i = ju; if (kca[3] == p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_p_U_ne(unsigned char *p) { unsigned int i = ju; if (kca[3] != p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_p_U_lt(unsigned char *p) { unsigned int i = ju; if (kca[3] < p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_p_U_ge(unsigned char *p) { unsigned int i = ju; if (kca[3] >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_q_P_eq(int i) { if (kca[3] == qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_q_P_ne(int i) { if (kca[3] != qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_q_P_lt(int i) { if (kca[3] < qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_q_P_ge(int i) { if (kca[3] >= qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_q_L_eq(void) { int i = ji; if (kca[3] == qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_q_L_ne(void) { int i = ji; if (kca[3] != qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_q_L_lt(void) { int i = ji; if (kca[3] < qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_q_L_ge(void) { int i = ji; if (kca[3] >= qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_q_U_eq(void) { unsigned int i = ju; if (kca[3] == qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_q_U_ne(void) { unsigned int i = ju; if (kca[3] != qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_q_U_lt(void) { unsigned int i = ju; if (kca[3] < qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_k_q_U_ge(void) { unsigned int i = ju; if (kca[3] >= qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_a_P_eq(int i) { if (*gpc == aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_a_P_ne(int i) { if (*gpc != aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_a_P_lt(int i) { if (*gpc < aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_a_P_ge(int i) { if (*gpc >= aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_a_L_eq(void) { int i = ji; if (*gpc == aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_a_L_ne(void) { int i = ji; if (*gpc != aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_a_L_lt(void) { int i = ji; if (*gpc < aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_a_L_ge(void) { int i = ji; if (*gpc >= aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_a_U_eq(void) { unsigned int i = ju; if (*gpc == aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_a_U_ne(void) { unsigned int i = ju; if (*gpc != aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_a_U_lt(void) { unsigned int i = ju; if (*gpc < aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_a_U_ge(void) { unsigned int i = ju; if (*gpc >= aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_u_P_eq(int i) { if (*gpc == uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_u_P_ne(int i) { if (*gpc != uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_u_P_lt(int i) { if (*gpc < uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_u_P_ge(int i) { if (*gpc >= uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_u_L_eq(void) { int i = ji; if (*gpc == uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_u_L_ne(void) { int i = ji; if (*gpc != uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_u_L_lt(void) { int i = ji; if (*gpc < uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_u_L_ge(void) { int i = ji; if (*gpc >= uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_u_U_eq(void) { unsigned int i = ju; if (*gpc == uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_u_U_ne(void) { unsigned int i = ju; if (*gpc != uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_u_U_lt(void) { unsigned int i = ju; if (*gpc < uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_u_U_ge(void) { unsigned int i = ju; if (*gpc >= uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_p_P_eq(unsigned char *p, int i) { if (*gpc == p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_p_P_ne(unsigned char *p, int i) { if (*gpc != p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_p_P_lt(unsigned char *p, int i) { if (*gpc < p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_p_P_ge(unsigned char *p, int i) { if (*gpc >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_p_L_eq(unsigned char *p) { int i = ji; if (*gpc == p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_p_L_ne(unsigned char *p) { int i = ji; if (*gpc != p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_p_L_lt(unsigned char *p) { int i = ji; if (*gpc < p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_p_L_ge(unsigned char *p) { int i = ji; if (*gpc >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_p_U_eq(unsigned char *p) { unsigned int i = ju; if (*gpc == p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_p_U_ne(unsigned char *p) { unsigned int i = ju; if (*gpc != p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_p_U_lt(unsigned char *p) { unsigned int i = ju; if (*gpc < p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_p_U_ge(unsigned char *p) { unsigned int i = ju; if (*gpc >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_q_P_eq(int i) { if (*gpc == qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_q_P_ne(int i) { if (*gpc != qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_q_P_lt(int i) { if (*gpc < qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_q_P_ge(int i) { if (*gpc >= qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_q_L_eq(void) { int i = ji; if (*gpc == qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_q_L_ne(void) { int i = ji; if (*gpc != qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_q_L_lt(void) { int i = ji; if (*gpc < qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_q_L_ge(void) { int i = ji; if (*gpc >= qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_q_U_eq(void) { unsigned int i = ju; if (*gpc == qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_q_U_ne(void) { unsigned int i = ju; if (*gpc != qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_q_U_lt(void) { unsigned int i = ju; if (*gpc < qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_d_q_U_ge(void) { unsigned int i = ju; if (*gpc >= qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_a_P_eq(int i) { if (gsc.m == aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_a_P_ne(int i) { if (gsc.m != aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_a_P_lt(int i) { if (gsc.m < aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_a_P_ge(int i) { if (gsc.m >= aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_a_L_eq(void) { int i = ji; if (gsc.m == aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_a_L_ne(void) { int i = ji; if (gsc.m != aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_a_L_lt(void) { int i = ji; if (gsc.m < aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_a_L_ge(void) { int i = ji; if (gsc.m >= aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_a_U_eq(void) { unsigned int i = ju; if (gsc.m == aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_a_U_ne(void) { unsigned int i = ju; if (gsc.m != aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_a_U_lt(void) { unsigned int i = ju; if (gsc.m < aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_a_U_ge(void) { unsigned int i = ju; if (gsc.m >= aca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_u_P_eq(int i) { if (gsc.m == uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_u_P_ne(int i) { if (gsc.m != uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_u_P_lt(int i) { if (gsc.m < uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_u_P_ge(int i) { if (gsc.m >= uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_u_L_eq(void) { int i = ji; if (gsc.m == uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_u_L_ne(void) { int i = ji; if (gsc.m != uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_u_L_lt(void) { int i = ji; if (gsc.m < uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_u_L_ge(void) { int i = ji; if (gsc.m >= uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_u_U_eq(void) { unsigned int i = ju; if (gsc.m == uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_u_U_ne(void) { unsigned int i = ju; if (gsc.m != uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_u_U_lt(void) { unsigned int i = ju; if (gsc.m < uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_u_U_ge(void) { unsigned int i = ju; if (gsc.m >= uca[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_p_P_eq(unsigned char *p, int i) { if (gsc.m == p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_p_P_ne(unsigned char *p, int i) { if (gsc.m != p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_p_P_lt(unsigned char *p, int i) { if (gsc.m < p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_p_P_ge(unsigned char *p, int i) { if (gsc.m >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_p_L_eq(unsigned char *p) { int i = ji; if (gsc.m == p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_p_L_ne(unsigned char *p) { int i = ji; if (gsc.m != p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_p_L_lt(unsigned char *p) { int i = ji; if (gsc.m < p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_p_L_ge(unsigned char *p) { int i = ji; if (gsc.m >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_p_U_eq(unsigned char *p) { unsigned int i = ju; if (gsc.m == p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_p_U_ne(unsigned char *p) { unsigned int i = ju; if (gsc.m != p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_p_U_lt(unsigned char *p) { unsigned int i = ju; if (gsc.m < p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_p_U_ge(unsigned char *p) { unsigned int i = ju; if (gsc.m >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_q_P_eq(int i) { if (gsc.m == qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_q_P_ne(int i) { if (gsc.m != qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_q_P_lt(int i) { if (gsc.m < qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_q_P_ge(int i) { if (gsc.m >= qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_q_L_eq(void) { int i = ji; if (gsc.m == qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_q_L_ne(void) { int i = ji; if (gsc.m != qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_q_L_lt(void) { int i = ji; if (gsc.m < qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_q_L_ge(void) { int i = ji; if (gsc.m >= qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_q_U_eq(void) { unsigned int i = ju; if (gsc.m == qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_q_U_ne(void) { unsigned int i = ju; if (gsc.m != qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_q_U_lt(void) { unsigned int i = ju; if (gsc.m < qc[i]) gi3 = 1; else gi3 = 2; }
void ce_c_m_q_U_ge(void) { unsigned int i = ju; if (gsc.m >= qc[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_a_P_eq(int i) { if (gi == aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_a_P_ne(int i) { if (gi != aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_a_P_lt(int i) { if (gi < aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_a_P_ge(int i) { if (gi >= aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_a_L_eq(void) { int i = ji; if (gi == aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_a_L_ne(void) { int i = ji; if (gi != aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_a_L_lt(void) { int i = ji; if (gi < aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_a_L_ge(void) { int i = ji; if (gi >= aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_a_U_eq(void) { unsigned int i = ju; if (gi == aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_a_U_ne(void) { unsigned int i = ju; if (gi != aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_a_U_lt(void) { unsigned int i = ju; if (gi < aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_a_U_ge(void) { unsigned int i = ju; if (gi >= aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_u_P_eq(int i) { if (gi == uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_u_P_ne(int i) { if (gi != uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_u_P_lt(int i) { if (gi < uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_u_P_ge(int i) { if (gi >= uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_u_L_eq(void) { int i = ji; if (gi == uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_u_L_ne(void) { int i = ji; if (gi != uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_u_L_lt(void) { int i = ji; if (gi < uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_u_L_ge(void) { int i = ji; if (gi >= uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_u_U_eq(void) { unsigned int i = ju; if (gi == uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_u_U_ne(void) { unsigned int i = ju; if (gi != uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_u_U_lt(void) { unsigned int i = ju; if (gi < uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_u_U_ge(void) { unsigned int i = ju; if (gi >= uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_p_P_eq(int *p, int i) { if (gi == p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_p_P_ne(int *p, int i) { if (gi != p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_p_P_lt(int *p, int i) { if (gi < p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_p_P_ge(int *p, int i) { if (gi >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_p_L_eq(int *p) { int i = ji; if (gi == p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_p_L_ne(int *p) { int i = ji; if (gi != p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_p_L_lt(int *p) { int i = ji; if (gi < p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_p_L_ge(int *p) { int i = ji; if (gi >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_p_U_eq(int *p) { unsigned int i = ju; if (gi == p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_p_U_ne(int *p) { unsigned int i = ju; if (gi != p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_p_U_lt(int *p) { unsigned int i = ju; if (gi < p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_p_U_ge(int *p) { unsigned int i = ju; if (gi >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_q_P_eq(int i) { if (gi == qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_q_P_ne(int i) { if (gi != qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_q_P_lt(int i) { if (gi < qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_q_P_ge(int i) { if (gi >= qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_q_L_eq(void) { int i = ji; if (gi == qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_q_L_ne(void) { int i = ji; if (gi != qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_q_L_lt(void) { int i = ji; if (gi < qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_q_L_ge(void) { int i = ji; if (gi >= qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_q_U_eq(void) { unsigned int i = ju; if (gi == qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_q_U_ne(void) { unsigned int i = ju; if (gi != qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_q_U_lt(void) { unsigned int i = ju; if (gi < qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_g_q_U_ge(void) { unsigned int i = ju; if (gi >= qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_a_P_eq(int i) { if (kia[3] == aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_a_P_ne(int i) { if (kia[3] != aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_a_P_lt(int i) { if (kia[3] < aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_a_P_ge(int i) { if (kia[3] >= aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_a_L_eq(void) { int i = ji; if (kia[3] == aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_a_L_ne(void) { int i = ji; if (kia[3] != aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_a_L_lt(void) { int i = ji; if (kia[3] < aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_a_L_ge(void) { int i = ji; if (kia[3] >= aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_a_U_eq(void) { unsigned int i = ju; if (kia[3] == aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_a_U_ne(void) { unsigned int i = ju; if (kia[3] != aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_a_U_lt(void) { unsigned int i = ju; if (kia[3] < aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_a_U_ge(void) { unsigned int i = ju; if (kia[3] >= aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_u_P_eq(int i) { if (kia[3] == uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_u_P_ne(int i) { if (kia[3] != uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_u_P_lt(int i) { if (kia[3] < uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_u_P_ge(int i) { if (kia[3] >= uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_u_L_eq(void) { int i = ji; if (kia[3] == uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_u_L_ne(void) { int i = ji; if (kia[3] != uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_u_L_lt(void) { int i = ji; if (kia[3] < uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_u_L_ge(void) { int i = ji; if (kia[3] >= uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_u_U_eq(void) { unsigned int i = ju; if (kia[3] == uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_u_U_ne(void) { unsigned int i = ju; if (kia[3] != uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_u_U_lt(void) { unsigned int i = ju; if (kia[3] < uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_u_U_ge(void) { unsigned int i = ju; if (kia[3] >= uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_p_P_eq(int *p, int i) { if (kia[3] == p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_p_P_ne(int *p, int i) { if (kia[3] != p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_p_P_lt(int *p, int i) { if (kia[3] < p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_p_P_ge(int *p, int i) { if (kia[3] >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_p_L_eq(int *p) { int i = ji; if (kia[3] == p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_p_L_ne(int *p) { int i = ji; if (kia[3] != p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_p_L_lt(int *p) { int i = ji; if (kia[3] < p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_p_L_ge(int *p) { int i = ji; if (kia[3] >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_p_U_eq(int *p) { unsigned int i = ju; if (kia[3] == p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_p_U_ne(int *p) { unsigned int i = ju; if (kia[3] != p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_p_U_lt(int *p) { unsigned int i = ju; if (kia[3] < p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_p_U_ge(int *p) { unsigned int i = ju; if (kia[3] >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_q_P_eq(int i) { if (kia[3] == qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_q_P_ne(int i) { if (kia[3] != qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_q_P_lt(int i) { if (kia[3] < qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_q_P_ge(int i) { if (kia[3] >= qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_q_L_eq(void) { int i = ji; if (kia[3] == qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_q_L_ne(void) { int i = ji; if (kia[3] != qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_q_L_lt(void) { int i = ji; if (kia[3] < qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_q_L_ge(void) { int i = ji; if (kia[3] >= qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_q_U_eq(void) { unsigned int i = ju; if (kia[3] == qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_q_U_ne(void) { unsigned int i = ju; if (kia[3] != qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_q_U_lt(void) { unsigned int i = ju; if (kia[3] < qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_k_q_U_ge(void) { unsigned int i = ju; if (kia[3] >= qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_a_P_eq(int i) { if (*gpi == aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_a_P_ne(int i) { if (*gpi != aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_a_P_lt(int i) { if (*gpi < aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_a_P_ge(int i) { if (*gpi >= aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_a_L_eq(void) { int i = ji; if (*gpi == aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_a_L_ne(void) { int i = ji; if (*gpi != aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_a_L_lt(void) { int i = ji; if (*gpi < aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_a_L_ge(void) { int i = ji; if (*gpi >= aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_a_U_eq(void) { unsigned int i = ju; if (*gpi == aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_a_U_ne(void) { unsigned int i = ju; if (*gpi != aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_a_U_lt(void) { unsigned int i = ju; if (*gpi < aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_a_U_ge(void) { unsigned int i = ju; if (*gpi >= aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_u_P_eq(int i) { if (*gpi == uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_u_P_ne(int i) { if (*gpi != uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_u_P_lt(int i) { if (*gpi < uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_u_P_ge(int i) { if (*gpi >= uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_u_L_eq(void) { int i = ji; if (*gpi == uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_u_L_ne(void) { int i = ji; if (*gpi != uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_u_L_lt(void) { int i = ji; if (*gpi < uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_u_L_ge(void) { int i = ji; if (*gpi >= uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_u_U_eq(void) { unsigned int i = ju; if (*gpi == uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_u_U_ne(void) { unsigned int i = ju; if (*gpi != uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_u_U_lt(void) { unsigned int i = ju; if (*gpi < uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_u_U_ge(void) { unsigned int i = ju; if (*gpi >= uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_p_P_eq(int *p, int i) { if (*gpi == p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_p_P_ne(int *p, int i) { if (*gpi != p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_p_P_lt(int *p, int i) { if (*gpi < p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_p_P_ge(int *p, int i) { if (*gpi >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_p_L_eq(int *p) { int i = ji; if (*gpi == p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_p_L_ne(int *p) { int i = ji; if (*gpi != p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_p_L_lt(int *p) { int i = ji; if (*gpi < p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_p_L_ge(int *p) { int i = ji; if (*gpi >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_p_U_eq(int *p) { unsigned int i = ju; if (*gpi == p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_p_U_ne(int *p) { unsigned int i = ju; if (*gpi != p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_p_U_lt(int *p) { unsigned int i = ju; if (*gpi < p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_p_U_ge(int *p) { unsigned int i = ju; if (*gpi >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_q_P_eq(int i) { if (*gpi == qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_q_P_ne(int i) { if (*gpi != qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_q_P_lt(int i) { if (*gpi < qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_q_P_ge(int i) { if (*gpi >= qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_q_L_eq(void) { int i = ji; if (*gpi == qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_q_L_ne(void) { int i = ji; if (*gpi != qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_q_L_lt(void) { int i = ji; if (*gpi < qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_q_L_ge(void) { int i = ji; if (*gpi >= qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_q_U_eq(void) { unsigned int i = ju; if (*gpi == qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_q_U_ne(void) { unsigned int i = ju; if (*gpi != qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_q_U_lt(void) { unsigned int i = ju; if (*gpi < qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_d_q_U_ge(void) { unsigned int i = ju; if (*gpi >= qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_a_P_eq(int i) { if (gsi.m == aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_a_P_ne(int i) { if (gsi.m != aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_a_P_lt(int i) { if (gsi.m < aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_a_P_ge(int i) { if (gsi.m >= aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_a_L_eq(void) { int i = ji; if (gsi.m == aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_a_L_ne(void) { int i = ji; if (gsi.m != aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_a_L_lt(void) { int i = ji; if (gsi.m < aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_a_L_ge(void) { int i = ji; if (gsi.m >= aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_a_U_eq(void) { unsigned int i = ju; if (gsi.m == aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_a_U_ne(void) { unsigned int i = ju; if (gsi.m != aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_a_U_lt(void) { unsigned int i = ju; if (gsi.m < aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_a_U_ge(void) { unsigned int i = ju; if (gsi.m >= aia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_u_P_eq(int i) { if (gsi.m == uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_u_P_ne(int i) { if (gsi.m != uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_u_P_lt(int i) { if (gsi.m < uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_u_P_ge(int i) { if (gsi.m >= uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_u_L_eq(void) { int i = ji; if (gsi.m == uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_u_L_ne(void) { int i = ji; if (gsi.m != uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_u_L_lt(void) { int i = ji; if (gsi.m < uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_u_L_ge(void) { int i = ji; if (gsi.m >= uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_u_U_eq(void) { unsigned int i = ju; if (gsi.m == uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_u_U_ne(void) { unsigned int i = ju; if (gsi.m != uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_u_U_lt(void) { unsigned int i = ju; if (gsi.m < uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_u_U_ge(void) { unsigned int i = ju; if (gsi.m >= uia[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_p_P_eq(int *p, int i) { if (gsi.m == p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_p_P_ne(int *p, int i) { if (gsi.m != p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_p_P_lt(int *p, int i) { if (gsi.m < p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_p_P_ge(int *p, int i) { if (gsi.m >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_p_L_eq(int *p) { int i = ji; if (gsi.m == p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_p_L_ne(int *p) { int i = ji; if (gsi.m != p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_p_L_lt(int *p) { int i = ji; if (gsi.m < p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_p_L_ge(int *p) { int i = ji; if (gsi.m >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_p_U_eq(int *p) { unsigned int i = ju; if (gsi.m == p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_p_U_ne(int *p) { unsigned int i = ju; if (gsi.m != p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_p_U_lt(int *p) { unsigned int i = ju; if (gsi.m < p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_p_U_ge(int *p) { unsigned int i = ju; if (gsi.m >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_q_P_eq(int i) { if (gsi.m == qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_q_P_ne(int i) { if (gsi.m != qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_q_P_lt(int i) { if (gsi.m < qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_q_P_ge(int i) { if (gsi.m >= qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_q_L_eq(void) { int i = ji; if (gsi.m == qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_q_L_ne(void) { int i = ji; if (gsi.m != qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_q_L_lt(void) { int i = ji; if (gsi.m < qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_q_L_ge(void) { int i = ji; if (gsi.m >= qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_q_U_eq(void) { unsigned int i = ju; if (gsi.m == qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_q_U_ne(void) { unsigned int i = ju; if (gsi.m != qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_q_U_lt(void) { unsigned int i = ju; if (gsi.m < qi[i]) gi3 = 1; else gi3 = 2; }
void ce_i_m_q_U_ge(void) { unsigned int i = ju; if (gsi.m >= qi[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_a_P_eq(int i) { if (gl == ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_a_P_ne(int i) { if (gl != ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_a_P_lt(int i) { if (gl < ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_a_P_ge(int i) { if (gl >= ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_a_L_eq(void) { int i = ji; if (gl == ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_a_L_ne(void) { int i = ji; if (gl != ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_a_L_lt(void) { int i = ji; if (gl < ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_a_L_ge(void) { int i = ji; if (gl >= ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_a_U_eq(void) { unsigned int i = ju; if (gl == ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_a_U_ne(void) { unsigned int i = ju; if (gl != ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_a_U_lt(void) { unsigned int i = ju; if (gl < ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_a_U_ge(void) { unsigned int i = ju; if (gl >= ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_u_P_eq(int i) { if (gl == ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_u_P_ne(int i) { if (gl != ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_u_P_lt(int i) { if (gl < ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_u_P_ge(int i) { if (gl >= ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_u_L_eq(void) { int i = ji; if (gl == ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_u_L_ne(void) { int i = ji; if (gl != ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_u_L_lt(void) { int i = ji; if (gl < ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_u_L_ge(void) { int i = ji; if (gl >= ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_u_U_eq(void) { unsigned int i = ju; if (gl == ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_u_U_ne(void) { unsigned int i = ju; if (gl != ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_u_U_lt(void) { unsigned int i = ju; if (gl < ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_u_U_ge(void) { unsigned int i = ju; if (gl >= ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_p_P_eq(long *p, int i) { if (gl == p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_p_P_ne(long *p, int i) { if (gl != p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_p_P_lt(long *p, int i) { if (gl < p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_p_P_ge(long *p, int i) { if (gl >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_p_L_eq(long *p) { int i = ji; if (gl == p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_p_L_ne(long *p) { int i = ji; if (gl != p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_p_L_lt(long *p) { int i = ji; if (gl < p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_p_L_ge(long *p) { int i = ji; if (gl >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_p_U_eq(long *p) { unsigned int i = ju; if (gl == p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_p_U_ne(long *p) { unsigned int i = ju; if (gl != p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_p_U_lt(long *p) { unsigned int i = ju; if (gl < p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_p_U_ge(long *p) { unsigned int i = ju; if (gl >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_q_P_eq(int i) { if (gl == ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_q_P_ne(int i) { if (gl != ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_q_P_lt(int i) { if (gl < ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_q_P_ge(int i) { if (gl >= ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_q_L_eq(void) { int i = ji; if (gl == ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_q_L_ne(void) { int i = ji; if (gl != ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_q_L_lt(void) { int i = ji; if (gl < ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_q_L_ge(void) { int i = ji; if (gl >= ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_q_U_eq(void) { unsigned int i = ju; if (gl == ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_q_U_ne(void) { unsigned int i = ju; if (gl != ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_q_U_lt(void) { unsigned int i = ju; if (gl < ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_g_q_U_ge(void) { unsigned int i = ju; if (gl >= ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_a_P_eq(int i) { if (kla[3] == ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_a_P_ne(int i) { if (kla[3] != ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_a_P_lt(int i) { if (kla[3] < ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_a_P_ge(int i) { if (kla[3] >= ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_a_L_eq(void) { int i = ji; if (kla[3] == ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_a_L_ne(void) { int i = ji; if (kla[3] != ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_a_L_lt(void) { int i = ji; if (kla[3] < ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_a_L_ge(void) { int i = ji; if (kla[3] >= ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_a_U_eq(void) { unsigned int i = ju; if (kla[3] == ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_a_U_ne(void) { unsigned int i = ju; if (kla[3] != ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_a_U_lt(void) { unsigned int i = ju; if (kla[3] < ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_a_U_ge(void) { unsigned int i = ju; if (kla[3] >= ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_u_P_eq(int i) { if (kla[3] == ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_u_P_ne(int i) { if (kla[3] != ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_u_P_lt(int i) { if (kla[3] < ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_u_P_ge(int i) { if (kla[3] >= ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_u_L_eq(void) { int i = ji; if (kla[3] == ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_u_L_ne(void) { int i = ji; if (kla[3] != ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_u_L_lt(void) { int i = ji; if (kla[3] < ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_u_L_ge(void) { int i = ji; if (kla[3] >= ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_u_U_eq(void) { unsigned int i = ju; if (kla[3] == ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_u_U_ne(void) { unsigned int i = ju; if (kla[3] != ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_u_U_lt(void) { unsigned int i = ju; if (kla[3] < ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_u_U_ge(void) { unsigned int i = ju; if (kla[3] >= ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_p_P_eq(long *p, int i) { if (kla[3] == p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_p_P_ne(long *p, int i) { if (kla[3] != p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_p_P_lt(long *p, int i) { if (kla[3] < p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_p_P_ge(long *p, int i) { if (kla[3] >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_p_L_eq(long *p) { int i = ji; if (kla[3] == p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_p_L_ne(long *p) { int i = ji; if (kla[3] != p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_p_L_lt(long *p) { int i = ji; if (kla[3] < p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_p_L_ge(long *p) { int i = ji; if (kla[3] >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_p_U_eq(long *p) { unsigned int i = ju; if (kla[3] == p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_p_U_ne(long *p) { unsigned int i = ju; if (kla[3] != p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_p_U_lt(long *p) { unsigned int i = ju; if (kla[3] < p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_p_U_ge(long *p) { unsigned int i = ju; if (kla[3] >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_q_P_eq(int i) { if (kla[3] == ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_q_P_ne(int i) { if (kla[3] != ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_q_P_lt(int i) { if (kla[3] < ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_q_P_ge(int i) { if (kla[3] >= ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_q_L_eq(void) { int i = ji; if (kla[3] == ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_q_L_ne(void) { int i = ji; if (kla[3] != ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_q_L_lt(void) { int i = ji; if (kla[3] < ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_q_L_ge(void) { int i = ji; if (kla[3] >= ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_q_U_eq(void) { unsigned int i = ju; if (kla[3] == ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_q_U_ne(void) { unsigned int i = ju; if (kla[3] != ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_q_U_lt(void) { unsigned int i = ju; if (kla[3] < ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_k_q_U_ge(void) { unsigned int i = ju; if (kla[3] >= ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_a_P_eq(int i) { if (*gpl == ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_a_P_ne(int i) { if (*gpl != ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_a_P_lt(int i) { if (*gpl < ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_a_P_ge(int i) { if (*gpl >= ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_a_L_eq(void) { int i = ji; if (*gpl == ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_a_L_ne(void) { int i = ji; if (*gpl != ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_a_L_lt(void) { int i = ji; if (*gpl < ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_a_L_ge(void) { int i = ji; if (*gpl >= ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_a_U_eq(void) { unsigned int i = ju; if (*gpl == ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_a_U_ne(void) { unsigned int i = ju; if (*gpl != ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_a_U_lt(void) { unsigned int i = ju; if (*gpl < ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_a_U_ge(void) { unsigned int i = ju; if (*gpl >= ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_u_P_eq(int i) { if (*gpl == ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_u_P_ne(int i) { if (*gpl != ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_u_P_lt(int i) { if (*gpl < ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_u_P_ge(int i) { if (*gpl >= ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_u_L_eq(void) { int i = ji; if (*gpl == ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_u_L_ne(void) { int i = ji; if (*gpl != ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_u_L_lt(void) { int i = ji; if (*gpl < ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_u_L_ge(void) { int i = ji; if (*gpl >= ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_u_U_eq(void) { unsigned int i = ju; if (*gpl == ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_u_U_ne(void) { unsigned int i = ju; if (*gpl != ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_u_U_lt(void) { unsigned int i = ju; if (*gpl < ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_u_U_ge(void) { unsigned int i = ju; if (*gpl >= ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_p_P_eq(long *p, int i) { if (*gpl == p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_p_P_ne(long *p, int i) { if (*gpl != p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_p_P_lt(long *p, int i) { if (*gpl < p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_p_P_ge(long *p, int i) { if (*gpl >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_p_L_eq(long *p) { int i = ji; if (*gpl == p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_p_L_ne(long *p) { int i = ji; if (*gpl != p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_p_L_lt(long *p) { int i = ji; if (*gpl < p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_p_L_ge(long *p) { int i = ji; if (*gpl >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_p_U_eq(long *p) { unsigned int i = ju; if (*gpl == p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_p_U_ne(long *p) { unsigned int i = ju; if (*gpl != p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_p_U_lt(long *p) { unsigned int i = ju; if (*gpl < p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_p_U_ge(long *p) { unsigned int i = ju; if (*gpl >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_q_P_eq(int i) { if (*gpl == ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_q_P_ne(int i) { if (*gpl != ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_q_P_lt(int i) { if (*gpl < ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_q_P_ge(int i) { if (*gpl >= ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_q_L_eq(void) { int i = ji; if (*gpl == ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_q_L_ne(void) { int i = ji; if (*gpl != ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_q_L_lt(void) { int i = ji; if (*gpl < ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_q_L_ge(void) { int i = ji; if (*gpl >= ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_q_U_eq(void) { unsigned int i = ju; if (*gpl == ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_q_U_ne(void) { unsigned int i = ju; if (*gpl != ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_q_U_lt(void) { unsigned int i = ju; if (*gpl < ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_d_q_U_ge(void) { unsigned int i = ju; if (*gpl >= ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_a_P_eq(int i) { if (gsl.m == ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_a_P_ne(int i) { if (gsl.m != ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_a_P_lt(int i) { if (gsl.m < ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_a_P_ge(int i) { if (gsl.m >= ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_a_L_eq(void) { int i = ji; if (gsl.m == ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_a_L_ne(void) { int i = ji; if (gsl.m != ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_a_L_lt(void) { int i = ji; if (gsl.m < ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_a_L_ge(void) { int i = ji; if (gsl.m >= ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_a_U_eq(void) { unsigned int i = ju; if (gsl.m == ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_a_U_ne(void) { unsigned int i = ju; if (gsl.m != ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_a_U_lt(void) { unsigned int i = ju; if (gsl.m < ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_a_U_ge(void) { unsigned int i = ju; if (gsl.m >= ala[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_u_P_eq(int i) { if (gsl.m == ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_u_P_ne(int i) { if (gsl.m != ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_u_P_lt(int i) { if (gsl.m < ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_u_P_ge(int i) { if (gsl.m >= ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_u_L_eq(void) { int i = ji; if (gsl.m == ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_u_L_ne(void) { int i = ji; if (gsl.m != ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_u_L_lt(void) { int i = ji; if (gsl.m < ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_u_L_ge(void) { int i = ji; if (gsl.m >= ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_u_U_eq(void) { unsigned int i = ju; if (gsl.m == ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_u_U_ne(void) { unsigned int i = ju; if (gsl.m != ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_u_U_lt(void) { unsigned int i = ju; if (gsl.m < ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_u_U_ge(void) { unsigned int i = ju; if (gsl.m >= ula[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_p_P_eq(long *p, int i) { if (gsl.m == p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_p_P_ne(long *p, int i) { if (gsl.m != p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_p_P_lt(long *p, int i) { if (gsl.m < p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_p_P_ge(long *p, int i) { if (gsl.m >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_p_L_eq(long *p) { int i = ji; if (gsl.m == p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_p_L_ne(long *p) { int i = ji; if (gsl.m != p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_p_L_lt(long *p) { int i = ji; if (gsl.m < p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_p_L_ge(long *p) { int i = ji; if (gsl.m >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_p_U_eq(long *p) { unsigned int i = ju; if (gsl.m == p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_p_U_ne(long *p) { unsigned int i = ju; if (gsl.m != p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_p_U_lt(long *p) { unsigned int i = ju; if (gsl.m < p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_p_U_ge(long *p) { unsigned int i = ju; if (gsl.m >= p[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_q_P_eq(int i) { if (gsl.m == ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_q_P_ne(int i) { if (gsl.m != ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_q_P_lt(int i) { if (gsl.m < ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_q_P_ge(int i) { if (gsl.m >= ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_q_L_eq(void) { int i = ji; if (gsl.m == ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_q_L_ne(void) { int i = ji; if (gsl.m != ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_q_L_lt(void) { int i = ji; if (gsl.m < ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_q_L_ge(void) { int i = ji; if (gsl.m >= ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_q_U_eq(void) { unsigned int i = ju; if (gsl.m == ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_q_U_ne(void) { unsigned int i = ju; if (gsl.m != ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_q_U_lt(void) { unsigned int i = ju; if (gsl.m < ql[i]) gi3 = 1; else gi3 = 2; }
void ce_l_m_q_U_ge(void) { unsigned int i = ju; if (gsl.m >= ql[i]) gi3 = 1; else gi3 = 2; }
