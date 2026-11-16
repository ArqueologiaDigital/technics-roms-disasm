/* lane_o3 probe: bit-fields; see gen_bitf.py for the name letters */
extern int gi3;
struct b1 { unsigned int a : 1; unsigned int b : 3; unsigned int c : 4; unsigned int d : 8; };
extern struct b1 gb1, *gpb1;
struct b2 { unsigned int a : 5; unsigned int b : 7; unsigned int c : 9; };
extern struct b2 gb2, *gpb2;
struct b3 { int s : 3; int t : 13; };
extern struct b3 gb3, *gpb3;
struct b4 { unsigned int w : 16; unsigned int x : 1; };
extern struct b4 gb4, *gpb4;
struct b5 { char c; unsigned int f : 4; unsigned int g : 12; };
extern struct b5 gb5, *gpb5;
struct b6 { unsigned int a : 4; unsigned int : 0; unsigned int b : 4; };
extern struct b6 gb6, *gpb6;
struct b7 { int m : 1; unsigned int n : 2; int o : 6; unsigned int q : 7; };
extern struct b7 gb7, *gpb7;
struct b8 { unsigned int h : 12; int i : 4; unsigned int j : 10; };
extern struct b8 gb8, *gpb8;
int bf_b1_size(void) { return sizeof(struct b1); }
unsigned int bf_b1_a_r(void) { return gb1.a; }
unsigned int bf_b1_a_p(void) { return gpb1->a; }
void bf_b1_a_k(void) { gb1.a = 1; }
void bf_b1_a_v(int v) { gb1.a = v; }
void bf_b1_a_w(int v) { gpb1->a = v; }
void bf_b1_a_a(void) { gb1.a += 1; }
void bf_b1_a_o(void) { gb1.a |= 1; }
void bf_b1_a_c(void) { if (gb1.a == 1) gi3 = 1; else gi3 = 2; }
unsigned int bf_b1_b_r(void) { return gb1.b; }
unsigned int bf_b1_b_p(void) { return gpb1->b; }
void bf_b1_b_k(void) { gb1.b = 3; }
void bf_b1_b_v(int v) { gb1.b = v; }
void bf_b1_b_w(int v) { gpb1->b = v; }
void bf_b1_b_a(void) { gb1.b += 1; }
void bf_b1_b_o(void) { gb1.b |= 1; }
void bf_b1_b_c(void) { if (gb1.b == 3) gi3 = 1; else gi3 = 2; }
unsigned int bf_b1_c_r(void) { return gb1.c; }
unsigned int bf_b1_c_p(void) { return gpb1->c; }
void bf_b1_c_k(void) { gb1.c = 7; }
void bf_b1_c_v(int v) { gb1.c = v; }
void bf_b1_c_w(int v) { gpb1->c = v; }
void bf_b1_c_a(void) { gb1.c += 1; }
void bf_b1_c_o(void) { gb1.c |= 1; }
void bf_b1_c_c(void) { if (gb1.c == 7) gi3 = 1; else gi3 = 2; }
unsigned int bf_b1_d_r(void) { return gb1.d; }
unsigned int bf_b1_d_p(void) { return gpb1->d; }
void bf_b1_d_k(void) { gb1.d = 127; }
void bf_b1_d_v(int v) { gb1.d = v; }
void bf_b1_d_w(int v) { gpb1->d = v; }
void bf_b1_d_a(void) { gb1.d += 1; }
void bf_b1_d_o(void) { gb1.d |= 1; }
void bf_b1_d_c(void) { if (gb1.d == 127) gi3 = 1; else gi3 = 2; }
int bf_b1_x(void) { return gb1.a + gb1.b; }
int bf_b2_size(void) { return sizeof(struct b2); }
unsigned int bf_b2_a_r(void) { return gb2.a; }
unsigned int bf_b2_a_p(void) { return gpb2->a; }
void bf_b2_a_k(void) { gb2.a = 15; }
void bf_b2_a_v(int v) { gb2.a = v; }
void bf_b2_a_w(int v) { gpb2->a = v; }
void bf_b2_a_a(void) { gb2.a += 1; }
void bf_b2_a_o(void) { gb2.a |= 1; }
void bf_b2_a_c(void) { if (gb2.a == 15) gi3 = 1; else gi3 = 2; }
unsigned int bf_b2_b_r(void) { return gb2.b; }
unsigned int bf_b2_b_p(void) { return gpb2->b; }
void bf_b2_b_k(void) { gb2.b = 63; }
void bf_b2_b_v(int v) { gb2.b = v; }
void bf_b2_b_w(int v) { gpb2->b = v; }
void bf_b2_b_a(void) { gb2.b += 1; }
void bf_b2_b_o(void) { gb2.b |= 1; }
void bf_b2_b_c(void) { if (gb2.b == 63) gi3 = 1; else gi3 = 2; }
unsigned int bf_b2_c_r(void) { return gb2.c; }
unsigned int bf_b2_c_p(void) { return gpb2->c; }
void bf_b2_c_k(void) { gb2.c = 255; }
void bf_b2_c_v(int v) { gb2.c = v; }
void bf_b2_c_w(int v) { gpb2->c = v; }
void bf_b2_c_a(void) { gb2.c += 1; }
void bf_b2_c_o(void) { gb2.c |= 1; }
void bf_b2_c_c(void) { if (gb2.c == 255) gi3 = 1; else gi3 = 2; }
int bf_b2_x(void) { return gb2.a + gb2.b; }
int bf_b3_size(void) { return sizeof(struct b3); }
int bf_b3_s_r(void) { return gb3.s; }
int bf_b3_s_p(void) { return gpb3->s; }
void bf_b3_s_k(void) { gb3.s = 1; }
void bf_b3_s_v(int v) { gb3.s = (v & 7) - 4; }
void bf_b3_s_w(int v) { gpb3->s = (v & 7) - 4; }
void bf_b3_s_a(void) { if (gb3.s < 3) gb3.s += 1; }
void bf_b3_s_o(void) { if (gb3.s > -4) gb3.s -= 1; }
void bf_b3_s_c(void) { if (gb3.s == 1) gi3 = 1; else gi3 = 2; }
int bf_b3_t_r(void) { return gb3.t; }
int bf_b3_t_p(void) { return gpb3->t; }
void bf_b3_t_k(void) { gb3.t = 2047; }
void bf_b3_t_v(int v) { gb3.t = (v & 8191) - 4096; }
void bf_b3_t_w(int v) { gpb3->t = (v & 8191) - 4096; }
void bf_b3_t_a(void) { if (gb3.t < 4095) gb3.t += 1; }
void bf_b3_t_o(void) { if (gb3.t > -4096) gb3.t -= 1; }
void bf_b3_t_c(void) { if (gb3.t == 2047) gi3 = 1; else gi3 = 2; }
int bf_b3_x(void) { return gb3.s + gb3.t; }
int bf_b4_size(void) { return sizeof(struct b4); }
unsigned int bf_b4_w_r(void) { return gb4.w; }
unsigned int bf_b4_w_p(void) { return gpb4->w; }
void bf_b4_w_k(void) { gb4.w = 32767; }
void bf_b4_w_v(int v) { gb4.w = v; }
void bf_b4_w_w(int v) { gpb4->w = v; }
void bf_b4_w_a(void) { gb4.w += 1; }
void bf_b4_w_o(void) { gb4.w |= 1; }
void bf_b4_w_c(void) { if (gb4.w == 32767) gi3 = 1; else gi3 = 2; }
unsigned int bf_b4_x_r(void) { return gb4.x; }
unsigned int bf_b4_x_p(void) { return gpb4->x; }
void bf_b4_x_k(void) { gb4.x = 1; }
void bf_b4_x_v(int v) { gb4.x = v; }
void bf_b4_x_w(int v) { gpb4->x = v; }
void bf_b4_x_a(void) { gb4.x += 1; }
void bf_b4_x_o(void) { gb4.x |= 1; }
void bf_b4_x_c(void) { if (gb4.x == 1) gi3 = 1; else gi3 = 2; }
int bf_b4_x(void) { return gb4.w + gb4.x; }
int bf_b5_size(void) { return sizeof(struct b5); }
unsigned int bf_b5_f_r(void) { return gb5.f; }
unsigned int bf_b5_f_p(void) { return gpb5->f; }
void bf_b5_f_k(void) { gb5.f = 7; }
void bf_b5_f_v(int v) { gb5.f = v; }
void bf_b5_f_w(int v) { gpb5->f = v; }
void bf_b5_f_a(void) { gb5.f += 1; }
void bf_b5_f_o(void) { gb5.f |= 1; }
void bf_b5_f_c(void) { if (gb5.f == 7) gi3 = 1; else gi3 = 2; }
unsigned int bf_b5_g_r(void) { return gb5.g; }
unsigned int bf_b5_g_p(void) { return gpb5->g; }
void bf_b5_g_k(void) { gb5.g = 2047; }
void bf_b5_g_v(int v) { gb5.g = v; }
void bf_b5_g_w(int v) { gpb5->g = v; }
void bf_b5_g_a(void) { gb5.g += 1; }
void bf_b5_g_o(void) { gb5.g |= 1; }
void bf_b5_g_c(void) { if (gb5.g == 2047) gi3 = 1; else gi3 = 2; }
int bf_b5_x(void) { return gb5.f + gb5.g; }
int bf_b6_size(void) { return sizeof(struct b6); }
unsigned int bf_b6_a_r(void) { return gb6.a; }
unsigned int bf_b6_a_p(void) { return gpb6->a; }
void bf_b6_a_k(void) { gb6.a = 7; }
void bf_b6_a_v(int v) { gb6.a = v; }
void bf_b6_a_w(int v) { gpb6->a = v; }
void bf_b6_a_a(void) { gb6.a += 1; }
void bf_b6_a_o(void) { gb6.a |= 1; }
void bf_b6_a_c(void) { if (gb6.a == 7) gi3 = 1; else gi3 = 2; }
unsigned int bf_b6_b_r(void) { return gb6.b; }
unsigned int bf_b6_b_p(void) { return gpb6->b; }
void bf_b6_b_k(void) { gb6.b = 7; }
void bf_b6_b_v(int v) { gb6.b = v; }
void bf_b6_b_w(int v) { gpb6->b = v; }
void bf_b6_b_a(void) { gb6.b += 1; }
void bf_b6_b_o(void) { gb6.b |= 1; }
void bf_b6_b_c(void) { if (gb6.b == 7) gi3 = 1; else gi3 = 2; }
int bf_b6_x(void) { return gb6.a + gb6.b; }
int bf_b7_size(void) { return sizeof(struct b7); }
int bf_b7_m_r(void) { return gb7.m; }
int bf_b7_m_p(void) { return gpb7->m; }
void bf_b7_m_k(void) { gb7.m = 0; }
void bf_b7_m_v(int v) { gb7.m = (v & 1) - 1; }
void bf_b7_m_w(int v) { gpb7->m = (v & 1) - 1; }
void bf_b7_m_a(void) { if (gb7.m < 0) gb7.m += 1; }
void bf_b7_m_o(void) { if (gb7.m > -1) gb7.m -= 1; }
void bf_b7_m_c(void) { if (gb7.m == 0) gi3 = 1; else gi3 = 2; }
unsigned int bf_b7_n_r(void) { return gb7.n; }
unsigned int bf_b7_n_p(void) { return gpb7->n; }
void bf_b7_n_k(void) { gb7.n = 1; }
void bf_b7_n_v(int v) { gb7.n = v; }
void bf_b7_n_w(int v) { gpb7->n = v; }
void bf_b7_n_a(void) { gb7.n += 1; }
void bf_b7_n_o(void) { gb7.n |= 1; }
void bf_b7_n_c(void) { if (gb7.n == 1) gi3 = 1; else gi3 = 2; }
int bf_b7_o_r(void) { return gb7.o; }
int bf_b7_o_p(void) { return gpb7->o; }
void bf_b7_o_k(void) { gb7.o = 15; }
void bf_b7_o_v(int v) { gb7.o = (v & 63) - 32; }
void bf_b7_o_w(int v) { gpb7->o = (v & 63) - 32; }
void bf_b7_o_a(void) { if (gb7.o < 31) gb7.o += 1; }
void bf_b7_o_o(void) { if (gb7.o > -32) gb7.o -= 1; }
void bf_b7_o_c(void) { if (gb7.o == 15) gi3 = 1; else gi3 = 2; }
unsigned int bf_b7_q_r(void) { return gb7.q; }
unsigned int bf_b7_q_p(void) { return gpb7->q; }
void bf_b7_q_k(void) { gb7.q = 63; }
void bf_b7_q_v(int v) { gb7.q = v; }
void bf_b7_q_w(int v) { gpb7->q = v; }
void bf_b7_q_a(void) { gb7.q += 1; }
void bf_b7_q_o(void) { gb7.q |= 1; }
void bf_b7_q_c(void) { if (gb7.q == 63) gi3 = 1; else gi3 = 2; }
int bf_b7_x(void) { return gb7.m + gb7.n; }
int bf_b8_size(void) { return sizeof(struct b8); }
unsigned int bf_b8_h_r(void) { return gb8.h; }
unsigned int bf_b8_h_p(void) { return gpb8->h; }
void bf_b8_h_k(void) { gb8.h = 2047; }
void bf_b8_h_v(int v) { gb8.h = v; }
void bf_b8_h_w(int v) { gpb8->h = v; }
void bf_b8_h_a(void) { gb8.h += 1; }
void bf_b8_h_o(void) { gb8.h |= 1; }
void bf_b8_h_c(void) { if (gb8.h == 2047) gi3 = 1; else gi3 = 2; }
int bf_b8_i_r(void) { return gb8.i; }
int bf_b8_i_p(void) { return gpb8->i; }
void bf_b8_i_k(void) { gb8.i = 3; }
void bf_b8_i_v(int v) { gb8.i = (v & 15) - 8; }
void bf_b8_i_w(int v) { gpb8->i = (v & 15) - 8; }
void bf_b8_i_a(void) { if (gb8.i < 7) gb8.i += 1; }
void bf_b8_i_o(void) { if (gb8.i > -8) gb8.i -= 1; }
void bf_b8_i_c(void) { if (gb8.i == 3) gi3 = 1; else gi3 = 2; }
unsigned int bf_b8_j_r(void) { return gb8.j; }
unsigned int bf_b8_j_p(void) { return gpb8->j; }
void bf_b8_j_k(void) { gb8.j = 511; }
void bf_b8_j_v(int v) { gb8.j = v; }
void bf_b8_j_w(int v) { gpb8->j = v; }
void bf_b8_j_a(void) { gb8.j += 1; }
void bf_b8_j_o(void) { gb8.j |= 1; }
void bf_b8_j_c(void) { if (gb8.j == 511) gi3 = 1; else gi3 = 2; }
int bf_b8_x(void) { return gb8.h + gb8.i; }
