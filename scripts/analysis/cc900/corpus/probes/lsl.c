/* A local in a frame slot across a long helper or a call (gen_lsl.py): ls_<t>_<i>_<m>_<u>(void). */
extern int gi, gia[8], *gpi, *hpi; extern long gl, gl2, gla[8], *gpl; extern char gc, gca[8]; extern unsigned int gu2;
extern void v0(void);
void ls_i_g_h_a(void) { int t = gi; gu2--; if (gl != 0) *gpl = gla[7] % gl; gi = gi + t; }
int ls_i_g_h_r(void) { int t = gi; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_i_g_v_a(void) { int t = gi; gu2--; v0(); gi = gi + t; }
int ls_i_g_v_r(void) { int t = gi; gu2--; v0(); return t; }
void ls_i_g_n_a(void) { int t = gi; gu2--; gi = gi + t; }
int ls_i_g_n_r(void) { int t = gi; gu2--; return t; }
void ls_i_e_h_a(void) { int t = gia[3]; gu2--; if (gl != 0) *gpl = gla[7] % gl; gi = gi + t; }
int ls_i_e_h_r(void) { int t = gia[3]; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_i_e_v_a(void) { int t = gia[3]; gu2--; v0(); gi = gi + t; }
int ls_i_e_v_r(void) { int t = gia[3]; gu2--; v0(); return t; }
void ls_i_e_n_a(void) { int t = gia[3]; gu2--; gi = gi + t; }
int ls_i_e_n_r(void) { int t = gia[3]; gu2--; return t; }
void ls_i_c_h_a(void) { int t = (int)gca[3]; gu2--; if (gl != 0) *gpl = gla[7] % gl; gi = gi + t; }
int ls_i_c_h_r(void) { int t = (int)gca[3]; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_i_c_v_a(void) { int t = (int)gca[3]; gu2--; v0(); gi = gi + t; }
int ls_i_c_v_r(void) { int t = (int)gca[3]; gu2--; v0(); return t; }
void ls_i_c_n_a(void) { int t = (int)gca[3]; gu2--; gi = gi + t; }
int ls_i_c_n_r(void) { int t = (int)gca[3]; gu2--; return t; }
void ls_i_s_h_a(void) { int t = (int)gca[3] >> 3; gu2--; if (gl != 0) *gpl = gla[7] % gl; gi = gi + t; }
int ls_i_s_h_r(void) { int t = (int)gca[3] >> 3; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_i_s_v_a(void) { int t = (int)gca[3] >> 3; gu2--; v0(); gi = gi + t; }
int ls_i_s_v_r(void) { int t = (int)gca[3] >> 3; gu2--; v0(); return t; }
void ls_i_s_n_a(void) { int t = (int)gca[3] >> 3; gu2--; gi = gi + t; }
int ls_i_s_n_r(void) { int t = (int)gca[3] >> 3; gu2--; return t; }
void ls_i_a_h_a(void) { int t = gi + 5; gu2--; if (gl != 0) *gpl = gla[7] % gl; gi = gi + t; }
int ls_i_a_h_r(void) { int t = gi + 5; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_i_a_v_a(void) { int t = gi + 5; gu2--; v0(); gi = gi + t; }
int ls_i_a_v_r(void) { int t = gi + 5; gu2--; v0(); return t; }
void ls_i_a_n_a(void) { int t = gi + 5; gu2--; gi = gi + t; }
int ls_i_a_n_r(void) { int t = gi + 5; gu2--; return t; }
void ls_i_k_h_a(void) { int t = 9; gu2--; if (gl != 0) *gpl = gla[7] % gl; gi = gi + t; }
int ls_i_k_h_r(void) { int t = 9; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_i_k_v_a(void) { int t = 9; gu2--; v0(); gi = gi + t; }
int ls_i_k_v_r(void) { int t = 9; gu2--; v0(); return t; }
void ls_i_k_n_a(void) { int t = 9; gu2--; gi = gi + t; }
int ls_i_k_n_r(void) { int t = 9; gu2--; return t; }

void ls_l_g_h_a(void) { long t = gl2; gu2--; if (gl != 0) *gpl = gla[7] % gl; gl2 = gl2 + t; }
long ls_l_g_h_r(void) { long t = gl2; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_l_g_v_a(void) { long t = gl2; gu2--; v0(); gl2 = gl2 + t; }
long ls_l_g_v_r(void) { long t = gl2; gu2--; v0(); return t; }
void ls_l_g_n_a(void) { long t = gl2; gu2--; gl2 = gl2 + t; }
long ls_l_g_n_r(void) { long t = gl2; gu2--; return t; }
void ls_l_e_h_a(void) { long t = gla[3]; gu2--; if (gl != 0) *gpl = gla[7] % gl; gl2 = gl2 + t; }
long ls_l_e_h_r(void) { long t = gla[3]; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_l_e_v_a(void) { long t = gla[3]; gu2--; v0(); gl2 = gl2 + t; }
long ls_l_e_v_r(void) { long t = gla[3]; gu2--; v0(); return t; }
void ls_l_e_n_a(void) { long t = gla[3]; gu2--; gl2 = gl2 + t; }
long ls_l_e_n_r(void) { long t = gla[3]; gu2--; return t; }
void ls_l_c_h_a(void) { long t = (long)gca[3]; gu2--; if (gl != 0) *gpl = gla[7] % gl; gl2 = gl2 + t; }
long ls_l_c_h_r(void) { long t = (long)gca[3]; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_l_c_v_a(void) { long t = (long)gca[3]; gu2--; v0(); gl2 = gl2 + t; }
long ls_l_c_v_r(void) { long t = (long)gca[3]; gu2--; v0(); return t; }
void ls_l_c_n_a(void) { long t = (long)gca[3]; gu2--; gl2 = gl2 + t; }
long ls_l_c_n_r(void) { long t = (long)gca[3]; gu2--; return t; }
void ls_l_s_h_a(void) { long t = (long)gca[3] >> 3; gu2--; if (gl != 0) *gpl = gla[7] % gl; gl2 = gl2 + t; }
long ls_l_s_h_r(void) { long t = (long)gca[3] >> 3; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_l_s_v_a(void) { long t = (long)gca[3] >> 3; gu2--; v0(); gl2 = gl2 + t; }
long ls_l_s_v_r(void) { long t = (long)gca[3] >> 3; gu2--; v0(); return t; }
void ls_l_s_n_a(void) { long t = (long)gca[3] >> 3; gu2--; gl2 = gl2 + t; }
long ls_l_s_n_r(void) { long t = (long)gca[3] >> 3; gu2--; return t; }
void ls_l_a_h_a(void) { long t = gl2 + 5; gu2--; if (gl != 0) *gpl = gla[7] % gl; gl2 = gl2 + t; }
long ls_l_a_h_r(void) { long t = gl2 + 5; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_l_a_v_a(void) { long t = gl2 + 5; gu2--; v0(); gl2 = gl2 + t; }
long ls_l_a_v_r(void) { long t = gl2 + 5; gu2--; v0(); return t; }
void ls_l_a_n_a(void) { long t = gl2 + 5; gu2--; gl2 = gl2 + t; }
long ls_l_a_n_r(void) { long t = gl2 + 5; gu2--; return t; }
void ls_l_k_h_a(void) { long t = 9; gu2--; if (gl != 0) *gpl = gla[7] % gl; gl2 = gl2 + t; }
long ls_l_k_h_r(void) { long t = 9; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_l_k_v_a(void) { long t = 9; gu2--; v0(); gl2 = gl2 + t; }
long ls_l_k_v_r(void) { long t = 9; gu2--; v0(); return t; }
void ls_l_k_n_a(void) { long t = 9; gu2--; gl2 = gl2 + t; }
long ls_l_k_n_r(void) { long t = 9; gu2--; return t; }

void ls_c_g_h_a(void) { char t = gc; gu2--; if (gl != 0) *gpl = gla[7] % gl; gc = gc + t; }
char ls_c_g_h_r(void) { char t = gc; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_c_g_v_a(void) { char t = gc; gu2--; v0(); gc = gc + t; }
char ls_c_g_v_r(void) { char t = gc; gu2--; v0(); return t; }
void ls_c_g_n_a(void) { char t = gc; gu2--; gc = gc + t; }
char ls_c_g_n_r(void) { char t = gc; gu2--; return t; }
void ls_c_e_h_a(void) { char t = gca[3]; gu2--; if (gl != 0) *gpl = gla[7] % gl; gc = gc + t; }
char ls_c_e_h_r(void) { char t = gca[3]; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_c_e_v_a(void) { char t = gca[3]; gu2--; v0(); gc = gc + t; }
char ls_c_e_v_r(void) { char t = gca[3]; gu2--; v0(); return t; }
void ls_c_e_n_a(void) { char t = gca[3]; gu2--; gc = gc + t; }
char ls_c_e_n_r(void) { char t = gca[3]; gu2--; return t; }
void ls_c_c_h_a(void) { char t = (char)gca[3]; gu2--; if (gl != 0) *gpl = gla[7] % gl; gc = gc + t; }
char ls_c_c_h_r(void) { char t = (char)gca[3]; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_c_c_v_a(void) { char t = (char)gca[3]; gu2--; v0(); gc = gc + t; }
char ls_c_c_v_r(void) { char t = (char)gca[3]; gu2--; v0(); return t; }
void ls_c_c_n_a(void) { char t = (char)gca[3]; gu2--; gc = gc + t; }
char ls_c_c_n_r(void) { char t = (char)gca[3]; gu2--; return t; }
void ls_c_s_h_a(void) { char t = (char)gca[3] >> 3; gu2--; if (gl != 0) *gpl = gla[7] % gl; gc = gc + t; }
char ls_c_s_h_r(void) { char t = (char)gca[3] >> 3; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_c_s_v_a(void) { char t = (char)gca[3] >> 3; gu2--; v0(); gc = gc + t; }
char ls_c_s_v_r(void) { char t = (char)gca[3] >> 3; gu2--; v0(); return t; }
void ls_c_s_n_a(void) { char t = (char)gca[3] >> 3; gu2--; gc = gc + t; }
char ls_c_s_n_r(void) { char t = (char)gca[3] >> 3; gu2--; return t; }
void ls_c_a_h_a(void) { char t = gc + 5; gu2--; if (gl != 0) *gpl = gla[7] % gl; gc = gc + t; }
char ls_c_a_h_r(void) { char t = gc + 5; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_c_a_v_a(void) { char t = gc + 5; gu2--; v0(); gc = gc + t; }
char ls_c_a_v_r(void) { char t = gc + 5; gu2--; v0(); return t; }
void ls_c_a_n_a(void) { char t = gc + 5; gu2--; gc = gc + t; }
char ls_c_a_n_r(void) { char t = gc + 5; gu2--; return t; }
void ls_c_k_h_a(void) { char t = 9; gu2--; if (gl != 0) *gpl = gla[7] % gl; gc = gc + t; }
char ls_c_k_h_r(void) { char t = 9; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_c_k_v_a(void) { char t = 9; gu2--; v0(); gc = gc + t; }
char ls_c_k_v_r(void) { char t = 9; gu2--; v0(); return t; }
void ls_c_k_n_a(void) { char t = 9; gu2--; gc = gc + t; }
char ls_c_k_n_r(void) { char t = 9; gu2--; return t; }

void ls_p_g_h_a(void) { int * t = gpi; gu2--; if (gl != 0) *gpl = gla[7] % gl; gpi = t; }
int * ls_p_g_h_r(void) { int * t = gpi; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_p_g_v_a(void) { int * t = gpi; gu2--; v0(); gpi = t; }
int * ls_p_g_v_r(void) { int * t = gpi; gu2--; v0(); return t; }
void ls_p_g_n_a(void) { int * t = gpi; gu2--; gpi = t; }
int * ls_p_g_n_r(void) { int * t = gpi; gu2--; return t; }
void ls_p_e_h_a(void) { int * t = hpi; gu2--; if (gl != 0) *gpl = gla[7] % gl; gpi = t; }
int * ls_p_e_h_r(void) { int * t = hpi; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_p_e_v_a(void) { int * t = hpi; gu2--; v0(); gpi = t; }
int * ls_p_e_v_r(void) { int * t = hpi; gu2--; v0(); return t; }
void ls_p_e_n_a(void) { int * t = hpi; gu2--; gpi = t; }
int * ls_p_e_n_r(void) { int * t = hpi; gu2--; return t; }
void ls_p_a_h_a(void) { int * t = gpi + 5; gu2--; if (gl != 0) *gpl = gla[7] % gl; gpi = t; }
int * ls_p_a_h_r(void) { int * t = gpi + 5; gu2--; if (gl != 0) *gpl = gla[7] % gl; return t; }
void ls_p_a_v_a(void) { int * t = gpi + 5; gu2--; v0(); gpi = t; }
int * ls_p_a_v_r(void) { int * t = gpi + 5; gu2--; v0(); return t; }
void ls_p_a_n_a(void) { int * t = gpi + 5; gu2--; gpi = t; }
int * ls_p_a_n_r(void) { int * t = gpi + 5; gu2--; return t; }
