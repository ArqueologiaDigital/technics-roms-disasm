/* lane_o3 probe: a char shifted or divided, then compared; see gen_shcmp.py for the name letters */
extern int gi3;
extern unsigned char ga, gc;
extern signed char gsa, gsc;
extern int gi;
int sc_p_s1_ge_c_v(unsigned char a, unsigned char c) { return (a >> 1) >= c; }
void sc_p_s1_ge_c_b(unsigned char a, unsigned char c) { if ((a >> 1) >= c) gi3 = 1; else gi3 = 2; }
int sc_p_s1_ge_k_v(unsigned char a) { return (a >> 1) >= 5; }
void sc_p_s1_ge_k_b(unsigned char a) { if ((a >> 1) >= 5) gi3 = 1; else gi3 = 2; }
int sc_p_s1_ge_i_v(unsigned char a, int i) { return (a >> 1) >= i; }
void sc_p_s1_ge_i_b(unsigned char a, int i) { if ((a >> 1) >= i) gi3 = 1; else gi3 = 2; }
int sc_p_s1_ge_S_v(unsigned char a, signed char sc) { return (a >> 1) >= sc; }
void sc_p_s1_ge_S_b(unsigned char a, signed char sc) { if ((a >> 1) >= sc) gi3 = 1; else gi3 = 2; }
int sc_p_s1_lt_c_v(unsigned char a, unsigned char c) { return (a >> 1) < c; }
void sc_p_s1_lt_c_b(unsigned char a, unsigned char c) { if ((a >> 1) < c) gi3 = 1; else gi3 = 2; }
int sc_p_s1_lt_k_v(unsigned char a) { return (a >> 1) < 5; }
void sc_p_s1_lt_k_b(unsigned char a) { if ((a >> 1) < 5) gi3 = 1; else gi3 = 2; }
int sc_p_s1_lt_i_v(unsigned char a, int i) { return (a >> 1) < i; }
void sc_p_s1_lt_i_b(unsigned char a, int i) { if ((a >> 1) < i) gi3 = 1; else gi3 = 2; }
int sc_p_s1_lt_S_v(unsigned char a, signed char sc) { return (a >> 1) < sc; }
void sc_p_s1_lt_S_b(unsigned char a, signed char sc) { if ((a >> 1) < sc) gi3 = 1; else gi3 = 2; }
int sc_p_s1_eq_c_v(unsigned char a, unsigned char c) { return (a >> 1) == c; }
void sc_p_s1_eq_c_b(unsigned char a, unsigned char c) { if ((a >> 1) == c) gi3 = 1; else gi3 = 2; }
int sc_p_s1_eq_k_v(unsigned char a) { return (a >> 1) == 5; }
void sc_p_s1_eq_k_b(unsigned char a) { if ((a >> 1) == 5) gi3 = 1; else gi3 = 2; }
int sc_p_s1_eq_i_v(unsigned char a, int i) { return (a >> 1) == i; }
void sc_p_s1_eq_i_b(unsigned char a, int i) { if ((a >> 1) == i) gi3 = 1; else gi3 = 2; }
int sc_p_s1_eq_S_v(unsigned char a, signed char sc) { return (a >> 1) == sc; }
void sc_p_s1_eq_S_b(unsigned char a, signed char sc) { if ((a >> 1) == sc) gi3 = 1; else gi3 = 2; }
int sc_p_s3_ge_c_v(unsigned char a, unsigned char c) { return (a >> 3) >= c; }
void sc_p_s3_ge_c_b(unsigned char a, unsigned char c) { if ((a >> 3) >= c) gi3 = 1; else gi3 = 2; }
int sc_p_s3_ge_k_v(unsigned char a) { return (a >> 3) >= 5; }
void sc_p_s3_ge_k_b(unsigned char a) { if ((a >> 3) >= 5) gi3 = 1; else gi3 = 2; }
int sc_p_s3_ge_i_v(unsigned char a, int i) { return (a >> 3) >= i; }
void sc_p_s3_ge_i_b(unsigned char a, int i) { if ((a >> 3) >= i) gi3 = 1; else gi3 = 2; }
int sc_p_s3_lt_c_v(unsigned char a, unsigned char c) { return (a >> 3) < c; }
void sc_p_s3_lt_c_b(unsigned char a, unsigned char c) { if ((a >> 3) < c) gi3 = 1; else gi3 = 2; }
int sc_p_s3_lt_k_v(unsigned char a) { return (a >> 3) < 5; }
void sc_p_s3_lt_k_b(unsigned char a) { if ((a >> 3) < 5) gi3 = 1; else gi3 = 2; }
int sc_p_s3_lt_i_v(unsigned char a, int i) { return (a >> 3) < i; }
void sc_p_s3_lt_i_b(unsigned char a, int i) { if ((a >> 3) < i) gi3 = 1; else gi3 = 2; }
int sc_p_s3_eq_c_v(unsigned char a, unsigned char c) { return (a >> 3) == c; }
void sc_p_s3_eq_c_b(unsigned char a, unsigned char c) { if ((a >> 3) == c) gi3 = 1; else gi3 = 2; }
int sc_p_s3_eq_k_v(unsigned char a) { return (a >> 3) == 5; }
void sc_p_s3_eq_k_b(unsigned char a) { if ((a >> 3) == 5) gi3 = 1; else gi3 = 2; }
int sc_p_s3_eq_i_v(unsigned char a, int i) { return (a >> 3) == i; }
void sc_p_s3_eq_i_b(unsigned char a, int i) { if ((a >> 3) == i) gi3 = 1; else gi3 = 2; }
int sc_p_d2_ge_c_v(unsigned char a, unsigned char c) { return (a / 2) >= c; }
void sc_p_d2_ge_c_b(unsigned char a, unsigned char c) { if ((a / 2) >= c) gi3 = 1; else gi3 = 2; }
int sc_p_d2_ge_k_v(unsigned char a) { return (a / 2) >= 5; }
void sc_p_d2_ge_k_b(unsigned char a) { if ((a / 2) >= 5) gi3 = 1; else gi3 = 2; }
int sc_p_d2_ge_i_v(unsigned char a, int i) { return (a / 2) >= i; }
void sc_p_d2_ge_i_b(unsigned char a, int i) { if ((a / 2) >= i) gi3 = 1; else gi3 = 2; }
int sc_p_d2_ge_S_v(unsigned char a, signed char sc) { return (a / 2) >= sc; }
void sc_p_d2_ge_S_b(unsigned char a, signed char sc) { if ((a / 2) >= sc) gi3 = 1; else gi3 = 2; }
int sc_p_d2_lt_c_v(unsigned char a, unsigned char c) { return (a / 2) < c; }
void sc_p_d2_lt_c_b(unsigned char a, unsigned char c) { if ((a / 2) < c) gi3 = 1; else gi3 = 2; }
int sc_p_d2_lt_k_v(unsigned char a) { return (a / 2) < 5; }
void sc_p_d2_lt_k_b(unsigned char a) { if ((a / 2) < 5) gi3 = 1; else gi3 = 2; }
int sc_p_d2_lt_i_v(unsigned char a, int i) { return (a / 2) < i; }
void sc_p_d2_lt_i_b(unsigned char a, int i) { if ((a / 2) < i) gi3 = 1; else gi3 = 2; }
int sc_p_d2_lt_S_v(unsigned char a, signed char sc) { return (a / 2) < sc; }
void sc_p_d2_lt_S_b(unsigned char a, signed char sc) { if ((a / 2) < sc) gi3 = 1; else gi3 = 2; }
int sc_p_d2_eq_c_v(unsigned char a, unsigned char c) { return (a / 2) == c; }
void sc_p_d2_eq_c_b(unsigned char a, unsigned char c) { if ((a / 2) == c) gi3 = 1; else gi3 = 2; }
int sc_p_d2_eq_k_v(unsigned char a) { return (a / 2) == 5; }
void sc_p_d2_eq_k_b(unsigned char a) { if ((a / 2) == 5) gi3 = 1; else gi3 = 2; }
int sc_p_d2_eq_i_v(unsigned char a, int i) { return (a / 2) == i; }
void sc_p_d2_eq_i_b(unsigned char a, int i) { if ((a / 2) == i) gi3 = 1; else gi3 = 2; }
int sc_p_d2_eq_S_v(unsigned char a, signed char sc) { return (a / 2) == sc; }
void sc_p_d2_eq_S_b(unsigned char a, signed char sc) { if ((a / 2) == sc) gi3 = 1; else gi3 = 2; }
int sc_p_d4_ge_c_v(unsigned char a, unsigned char c) { return (a / 4) >= c; }
void sc_p_d4_ge_c_b(unsigned char a, unsigned char c) { if ((a / 4) >= c) gi3 = 1; else gi3 = 2; }
int sc_p_d4_ge_k_v(unsigned char a) { return (a / 4) >= 5; }
void sc_p_d4_ge_k_b(unsigned char a) { if ((a / 4) >= 5) gi3 = 1; else gi3 = 2; }
int sc_p_d4_ge_i_v(unsigned char a, int i) { return (a / 4) >= i; }
void sc_p_d4_ge_i_b(unsigned char a, int i) { if ((a / 4) >= i) gi3 = 1; else gi3 = 2; }
int sc_p_d4_lt_c_v(unsigned char a, unsigned char c) { return (a / 4) < c; }
void sc_p_d4_lt_c_b(unsigned char a, unsigned char c) { if ((a / 4) < c) gi3 = 1; else gi3 = 2; }
int sc_p_d4_lt_k_v(unsigned char a) { return (a / 4) < 5; }
void sc_p_d4_lt_k_b(unsigned char a) { if ((a / 4) < 5) gi3 = 1; else gi3 = 2; }
int sc_p_d4_lt_i_v(unsigned char a, int i) { return (a / 4) < i; }
void sc_p_d4_lt_i_b(unsigned char a, int i) { if ((a / 4) < i) gi3 = 1; else gi3 = 2; }
int sc_p_d4_eq_c_v(unsigned char a, unsigned char c) { return (a / 4) == c; }
void sc_p_d4_eq_c_b(unsigned char a, unsigned char c) { if ((a / 4) == c) gi3 = 1; else gi3 = 2; }
int sc_p_d4_eq_k_v(unsigned char a) { return (a / 4) == 5; }
void sc_p_d4_eq_k_b(unsigned char a) { if ((a / 4) == 5) gi3 = 1; else gi3 = 2; }
int sc_p_d4_eq_i_v(unsigned char a, int i) { return (a / 4) == i; }
void sc_p_d4_eq_i_b(unsigned char a, int i) { if ((a / 4) == i) gi3 = 1; else gi3 = 2; }
int sc_p_d3_ge_c_v(unsigned char a, unsigned char c) { return (a / 3) >= c; }
void sc_p_d3_ge_c_b(unsigned char a, unsigned char c) { if ((a / 3) >= c) gi3 = 1; else gi3 = 2; }
int sc_p_d3_ge_k_v(unsigned char a) { return (a / 3) >= 5; }
void sc_p_d3_ge_k_b(unsigned char a) { if ((a / 3) >= 5) gi3 = 1; else gi3 = 2; }
int sc_p_d3_ge_i_v(unsigned char a, int i) { return (a / 3) >= i; }
void sc_p_d3_ge_i_b(unsigned char a, int i) { if ((a / 3) >= i) gi3 = 1; else gi3 = 2; }
int sc_p_d3_lt_c_v(unsigned char a, unsigned char c) { return (a / 3) < c; }
void sc_p_d3_lt_c_b(unsigned char a, unsigned char c) { if ((a / 3) < c) gi3 = 1; else gi3 = 2; }
int sc_p_d3_lt_k_v(unsigned char a) { return (a / 3) < 5; }
void sc_p_d3_lt_k_b(unsigned char a) { if ((a / 3) < 5) gi3 = 1; else gi3 = 2; }
int sc_p_d3_lt_i_v(unsigned char a, int i) { return (a / 3) < i; }
void sc_p_d3_lt_i_b(unsigned char a, int i) { if ((a / 3) < i) gi3 = 1; else gi3 = 2; }
int sc_p_d3_eq_c_v(unsigned char a, unsigned char c) { return (a / 3) == c; }
void sc_p_d3_eq_c_b(unsigned char a, unsigned char c) { if ((a / 3) == c) gi3 = 1; else gi3 = 2; }
int sc_p_d3_eq_k_v(unsigned char a) { return (a / 3) == 5; }
void sc_p_d3_eq_k_b(unsigned char a) { if ((a / 3) == 5) gi3 = 1; else gi3 = 2; }
int sc_p_d3_eq_i_v(unsigned char a, int i) { return (a / 3) == i; }
void sc_p_d3_eq_i_b(unsigned char a, int i) { if ((a / 3) == i) gi3 = 1; else gi3 = 2; }
int sc_p_D2_ge_c_v(signed char sa, unsigned char c) { return (sa / 2) >= c; }
void sc_p_D2_ge_c_b(signed char sa, unsigned char c) { if ((sa / 2) >= c) gi3 = 1; else gi3 = 2; }
int sc_p_D2_ge_k_v(signed char sa) { return (sa / 2) >= 5; }
void sc_p_D2_ge_k_b(signed char sa) { if ((sa / 2) >= 5) gi3 = 1; else gi3 = 2; }
int sc_p_D2_ge_i_v(signed char sa, int i) { return (sa / 2) >= i; }
void sc_p_D2_ge_i_b(signed char sa, int i) { if ((sa / 2) >= i) gi3 = 1; else gi3 = 2; }
int sc_p_D2_ge_S_v(signed char sa, signed char sc) { return (sa / 2) >= sc; }
void sc_p_D2_ge_S_b(signed char sa, signed char sc) { if ((sa / 2) >= sc) gi3 = 1; else gi3 = 2; }
int sc_p_D2_lt_c_v(signed char sa, unsigned char c) { return (sa / 2) < c; }
void sc_p_D2_lt_c_b(signed char sa, unsigned char c) { if ((sa / 2) < c) gi3 = 1; else gi3 = 2; }
int sc_p_D2_lt_k_v(signed char sa) { return (sa / 2) < 5; }
void sc_p_D2_lt_k_b(signed char sa) { if ((sa / 2) < 5) gi3 = 1; else gi3 = 2; }
int sc_p_D2_lt_i_v(signed char sa, int i) { return (sa / 2) < i; }
void sc_p_D2_lt_i_b(signed char sa, int i) { if ((sa / 2) < i) gi3 = 1; else gi3 = 2; }
int sc_p_D2_lt_S_v(signed char sa, signed char sc) { return (sa / 2) < sc; }
void sc_p_D2_lt_S_b(signed char sa, signed char sc) { if ((sa / 2) < sc) gi3 = 1; else gi3 = 2; }
int sc_p_D2_eq_c_v(signed char sa, unsigned char c) { return (sa / 2) == c; }
void sc_p_D2_eq_c_b(signed char sa, unsigned char c) { if ((sa / 2) == c) gi3 = 1; else gi3 = 2; }
int sc_p_D2_eq_k_v(signed char sa) { return (sa / 2) == 5; }
void sc_p_D2_eq_k_b(signed char sa) { if ((sa / 2) == 5) gi3 = 1; else gi3 = 2; }
int sc_p_D2_eq_i_v(signed char sa, int i) { return (sa / 2) == i; }
void sc_p_D2_eq_i_b(signed char sa, int i) { if ((sa / 2) == i) gi3 = 1; else gi3 = 2; }
int sc_p_D2_eq_S_v(signed char sa, signed char sc) { return (sa / 2) == sc; }
void sc_p_D2_eq_S_b(signed char sa, signed char sc) { if ((sa / 2) == sc) gi3 = 1; else gi3 = 2; }
int sc_g_s1_ge_c_v(void) { return (ga >> 1) >= gc; }
void sc_g_s1_ge_c_b(void) { if ((ga >> 1) >= gc) gi3 = 1; else gi3 = 2; }
int sc_g_s1_ge_k_v(void) { return (ga >> 1) >= 5; }
void sc_g_s1_ge_k_b(void) { if ((ga >> 1) >= 5) gi3 = 1; else gi3 = 2; }
int sc_g_s1_ge_i_v(void) { return (ga >> 1) >= gi; }
void sc_g_s1_ge_i_b(void) { if ((ga >> 1) >= gi) gi3 = 1; else gi3 = 2; }
int sc_g_s1_ge_S_v(void) { return (ga >> 1) >= gsc; }
void sc_g_s1_ge_S_b(void) { if ((ga >> 1) >= gsc) gi3 = 1; else gi3 = 2; }
int sc_g_s1_lt_c_v(void) { return (ga >> 1) < gc; }
void sc_g_s1_lt_c_b(void) { if ((ga >> 1) < gc) gi3 = 1; else gi3 = 2; }
int sc_g_s1_lt_k_v(void) { return (ga >> 1) < 5; }
void sc_g_s1_lt_k_b(void) { if ((ga >> 1) < 5) gi3 = 1; else gi3 = 2; }
int sc_g_s1_lt_i_v(void) { return (ga >> 1) < gi; }
void sc_g_s1_lt_i_b(void) { if ((ga >> 1) < gi) gi3 = 1; else gi3 = 2; }
int sc_g_s1_lt_S_v(void) { return (ga >> 1) < gsc; }
void sc_g_s1_lt_S_b(void) { if ((ga >> 1) < gsc) gi3 = 1; else gi3 = 2; }
int sc_g_s1_eq_c_v(void) { return (ga >> 1) == gc; }
void sc_g_s1_eq_c_b(void) { if ((ga >> 1) == gc) gi3 = 1; else gi3 = 2; }
int sc_g_s1_eq_k_v(void) { return (ga >> 1) == 5; }
void sc_g_s1_eq_k_b(void) { if ((ga >> 1) == 5) gi3 = 1; else gi3 = 2; }
int sc_g_s1_eq_i_v(void) { return (ga >> 1) == gi; }
void sc_g_s1_eq_i_b(void) { if ((ga >> 1) == gi) gi3 = 1; else gi3 = 2; }
int sc_g_s1_eq_S_v(void) { return (ga >> 1) == gsc; }
void sc_g_s1_eq_S_b(void) { if ((ga >> 1) == gsc) gi3 = 1; else gi3 = 2; }
int sc_g_s3_ge_c_v(void) { return (ga >> 3) >= gc; }
void sc_g_s3_ge_c_b(void) { if ((ga >> 3) >= gc) gi3 = 1; else gi3 = 2; }
int sc_g_s3_ge_k_v(void) { return (ga >> 3) >= 5; }
void sc_g_s3_ge_k_b(void) { if ((ga >> 3) >= 5) gi3 = 1; else gi3 = 2; }
int sc_g_s3_ge_i_v(void) { return (ga >> 3) >= gi; }
void sc_g_s3_ge_i_b(void) { if ((ga >> 3) >= gi) gi3 = 1; else gi3 = 2; }
int sc_g_s3_lt_c_v(void) { return (ga >> 3) < gc; }
void sc_g_s3_lt_c_b(void) { if ((ga >> 3) < gc) gi3 = 1; else gi3 = 2; }
int sc_g_s3_lt_k_v(void) { return (ga >> 3) < 5; }
void sc_g_s3_lt_k_b(void) { if ((ga >> 3) < 5) gi3 = 1; else gi3 = 2; }
int sc_g_s3_lt_i_v(void) { return (ga >> 3) < gi; }
void sc_g_s3_lt_i_b(void) { if ((ga >> 3) < gi) gi3 = 1; else gi3 = 2; }
int sc_g_s3_eq_c_v(void) { return (ga >> 3) == gc; }
void sc_g_s3_eq_c_b(void) { if ((ga >> 3) == gc) gi3 = 1; else gi3 = 2; }
int sc_g_s3_eq_k_v(void) { return (ga >> 3) == 5; }
void sc_g_s3_eq_k_b(void) { if ((ga >> 3) == 5) gi3 = 1; else gi3 = 2; }
int sc_g_s3_eq_i_v(void) { return (ga >> 3) == gi; }
void sc_g_s3_eq_i_b(void) { if ((ga >> 3) == gi) gi3 = 1; else gi3 = 2; }
int sc_g_d2_ge_c_v(void) { return (ga / 2) >= gc; }
void sc_g_d2_ge_c_b(void) { if ((ga / 2) >= gc) gi3 = 1; else gi3 = 2; }
int sc_g_d2_ge_k_v(void) { return (ga / 2) >= 5; }
void sc_g_d2_ge_k_b(void) { if ((ga / 2) >= 5) gi3 = 1; else gi3 = 2; }
int sc_g_d2_ge_i_v(void) { return (ga / 2) >= gi; }
void sc_g_d2_ge_i_b(void) { if ((ga / 2) >= gi) gi3 = 1; else gi3 = 2; }
int sc_g_d2_ge_S_v(void) { return (ga / 2) >= gsc; }
void sc_g_d2_ge_S_b(void) { if ((ga / 2) >= gsc) gi3 = 1; else gi3 = 2; }
int sc_g_d2_lt_c_v(void) { return (ga / 2) < gc; }
void sc_g_d2_lt_c_b(void) { if ((ga / 2) < gc) gi3 = 1; else gi3 = 2; }
int sc_g_d2_lt_k_v(void) { return (ga / 2) < 5; }
void sc_g_d2_lt_k_b(void) { if ((ga / 2) < 5) gi3 = 1; else gi3 = 2; }
int sc_g_d2_lt_i_v(void) { return (ga / 2) < gi; }
void sc_g_d2_lt_i_b(void) { if ((ga / 2) < gi) gi3 = 1; else gi3 = 2; }
int sc_g_d2_lt_S_v(void) { return (ga / 2) < gsc; }
void sc_g_d2_lt_S_b(void) { if ((ga / 2) < gsc) gi3 = 1; else gi3 = 2; }
int sc_g_d2_eq_c_v(void) { return (ga / 2) == gc; }
void sc_g_d2_eq_c_b(void) { if ((ga / 2) == gc) gi3 = 1; else gi3 = 2; }
int sc_g_d2_eq_k_v(void) { return (ga / 2) == 5; }
void sc_g_d2_eq_k_b(void) { if ((ga / 2) == 5) gi3 = 1; else gi3 = 2; }
int sc_g_d2_eq_i_v(void) { return (ga / 2) == gi; }
void sc_g_d2_eq_i_b(void) { if ((ga / 2) == gi) gi3 = 1; else gi3 = 2; }
int sc_g_d2_eq_S_v(void) { return (ga / 2) == gsc; }
void sc_g_d2_eq_S_b(void) { if ((ga / 2) == gsc) gi3 = 1; else gi3 = 2; }
int sc_g_d4_ge_c_v(void) { return (ga / 4) >= gc; }
void sc_g_d4_ge_c_b(void) { if ((ga / 4) >= gc) gi3 = 1; else gi3 = 2; }
int sc_g_d4_ge_k_v(void) { return (ga / 4) >= 5; }
void sc_g_d4_ge_k_b(void) { if ((ga / 4) >= 5) gi3 = 1; else gi3 = 2; }
int sc_g_d4_ge_i_v(void) { return (ga / 4) >= gi; }
void sc_g_d4_ge_i_b(void) { if ((ga / 4) >= gi) gi3 = 1; else gi3 = 2; }
int sc_g_d4_lt_c_v(void) { return (ga / 4) < gc; }
void sc_g_d4_lt_c_b(void) { if ((ga / 4) < gc) gi3 = 1; else gi3 = 2; }
int sc_g_d4_lt_k_v(void) { return (ga / 4) < 5; }
void sc_g_d4_lt_k_b(void) { if ((ga / 4) < 5) gi3 = 1; else gi3 = 2; }
int sc_g_d4_lt_i_v(void) { return (ga / 4) < gi; }
void sc_g_d4_lt_i_b(void) { if ((ga / 4) < gi) gi3 = 1; else gi3 = 2; }
int sc_g_d4_eq_c_v(void) { return (ga / 4) == gc; }
void sc_g_d4_eq_c_b(void) { if ((ga / 4) == gc) gi3 = 1; else gi3 = 2; }
int sc_g_d4_eq_k_v(void) { return (ga / 4) == 5; }
void sc_g_d4_eq_k_b(void) { if ((ga / 4) == 5) gi3 = 1; else gi3 = 2; }
int sc_g_d4_eq_i_v(void) { return (ga / 4) == gi; }
void sc_g_d4_eq_i_b(void) { if ((ga / 4) == gi) gi3 = 1; else gi3 = 2; }
int sc_g_d3_ge_c_v(void) { return (ga / 3) >= gc; }
void sc_g_d3_ge_c_b(void) { if ((ga / 3) >= gc) gi3 = 1; else gi3 = 2; }
int sc_g_d3_ge_k_v(void) { return (ga / 3) >= 5; }
void sc_g_d3_ge_k_b(void) { if ((ga / 3) >= 5) gi3 = 1; else gi3 = 2; }
int sc_g_d3_ge_i_v(void) { return (ga / 3) >= gi; }
void sc_g_d3_ge_i_b(void) { if ((ga / 3) >= gi) gi3 = 1; else gi3 = 2; }
int sc_g_d3_lt_c_v(void) { return (ga / 3) < gc; }
void sc_g_d3_lt_c_b(void) { if ((ga / 3) < gc) gi3 = 1; else gi3 = 2; }
int sc_g_d3_lt_k_v(void) { return (ga / 3) < 5; }
void sc_g_d3_lt_k_b(void) { if ((ga / 3) < 5) gi3 = 1; else gi3 = 2; }
int sc_g_d3_lt_i_v(void) { return (ga / 3) < gi; }
void sc_g_d3_lt_i_b(void) { if ((ga / 3) < gi) gi3 = 1; else gi3 = 2; }
int sc_g_d3_eq_c_v(void) { return (ga / 3) == gc; }
void sc_g_d3_eq_c_b(void) { if ((ga / 3) == gc) gi3 = 1; else gi3 = 2; }
int sc_g_d3_eq_k_v(void) { return (ga / 3) == 5; }
void sc_g_d3_eq_k_b(void) { if ((ga / 3) == 5) gi3 = 1; else gi3 = 2; }
int sc_g_d3_eq_i_v(void) { return (ga / 3) == gi; }
void sc_g_d3_eq_i_b(void) { if ((ga / 3) == gi) gi3 = 1; else gi3 = 2; }
int sc_g_D2_ge_c_v(void) { return (gsa / 2) >= gc; }
void sc_g_D2_ge_c_b(void) { if ((gsa / 2) >= gc) gi3 = 1; else gi3 = 2; }
int sc_g_D2_ge_k_v(void) { return (gsa / 2) >= 5; }
void sc_g_D2_ge_k_b(void) { if ((gsa / 2) >= 5) gi3 = 1; else gi3 = 2; }
int sc_g_D2_ge_i_v(void) { return (gsa / 2) >= gi; }
void sc_g_D2_ge_i_b(void) { if ((gsa / 2) >= gi) gi3 = 1; else gi3 = 2; }
int sc_g_D2_ge_S_v(void) { return (gsa / 2) >= gsc; }
void sc_g_D2_ge_S_b(void) { if ((gsa / 2) >= gsc) gi3 = 1; else gi3 = 2; }
int sc_g_D2_lt_c_v(void) { return (gsa / 2) < gc; }
void sc_g_D2_lt_c_b(void) { if ((gsa / 2) < gc) gi3 = 1; else gi3 = 2; }
int sc_g_D2_lt_k_v(void) { return (gsa / 2) < 5; }
void sc_g_D2_lt_k_b(void) { if ((gsa / 2) < 5) gi3 = 1; else gi3 = 2; }
int sc_g_D2_lt_i_v(void) { return (gsa / 2) < gi; }
void sc_g_D2_lt_i_b(void) { if ((gsa / 2) < gi) gi3 = 1; else gi3 = 2; }
int sc_g_D2_lt_S_v(void) { return (gsa / 2) < gsc; }
void sc_g_D2_lt_S_b(void) { if ((gsa / 2) < gsc) gi3 = 1; else gi3 = 2; }
int sc_g_D2_eq_c_v(void) { return (gsa / 2) == gc; }
void sc_g_D2_eq_c_b(void) { if ((gsa / 2) == gc) gi3 = 1; else gi3 = 2; }
int sc_g_D2_eq_k_v(void) { return (gsa / 2) == 5; }
void sc_g_D2_eq_k_b(void) { if ((gsa / 2) == 5) gi3 = 1; else gi3 = 2; }
int sc_g_D2_eq_i_v(void) { return (gsa / 2) == gi; }
void sc_g_D2_eq_i_b(void) { if ((gsa / 2) == gi) gi3 = 1; else gi3 = 2; }
int sc_g_D2_eq_S_v(void) { return (gsa / 2) == gsc; }
void sc_g_D2_eq_S_b(void) { if ((gsa / 2) == gsc) gi3 = 1; else gi3 = 2; }
