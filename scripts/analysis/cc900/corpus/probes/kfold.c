/* Constant folding of small constants (rstmt rs_4_00_13_5: return (8 ^ 16) << 11 gives 0, not 0xc000).
   kf_<n>: one folded constant expression each, returned as an int unless noted. */
extern int gi; extern long gl; extern char gc; extern unsigned int gu;
extern void v2(int, int);
int kf_a(void) { return (8 ^ 16) << 11; }
int kf_b(void) { return 8 << 11; }
int kf_c(void) { return 24 << 11; }
int kf_d(void) { return (8 | 16) << 11; }
int kf_e(void) { return (8 + 16) << 11; }
int kf_f(void) { return (8 ^ 16) << 7; }
int kf_g(void) { return (8 ^ 16) << 8; }
int kf_h(void) { return (8 ^ 16) << 4; }
int kf_i(void) { return (8 ^ 16) * 1000; }
int kf_j(void) { return (8 ^ 16) * 100; }
int kf_k(void) { return (8 ^ 16) + 1000; }
int kf_l(void) { return 100 + 100; }
int kf_m(void) { return (100 + 100) << 1; }
int kf_n(void) { return 100 * 3; }
int kf_o(void) { return (100 * 3) + 1; }
int kf_p(void) { return 100 << 2; }
int kf_q(void) { return (100 << 2) + 1; }
int kf_r(void) { return (100 + 27) + 1; }
int kf_s(void) { return (100 + 28) + 1; }
int kf_t(void) { return (200 ^ 1) << 2; }
int kf_u(void) { return 200 << 2; }
int kf_v(void) { return (200 + 100) << 2; }
int kf_w(void) { return (8 ^ 16) << (2 + 9); }
int kf_x(void) { return (8 & 24) << 11; }
int kf_y(void) { return (8 ^ 256) << 4; }
int kf_z(void) { return (300 ^ 16) << 4; }
int kf_aa(void) { return ~255; }
int kf_ab(void) { return ~255 + 1; }
int kf_ac(void) { return 256 >> 1; }
int kf_ad(void) { return (8 ^ 16) >> 1; }
int kf_ae(void) { return (8 ^ 16) - 100; }
int kf_af(void) { return (8 ^ 16) - 200; }
int kf_ag(void) { return 16 * 16; }
int kf_ah(void) { return (16 * 16) + 1; }
int kf_ai(void) { return 127 + 1; }
int kf_aj(void) { return (127 + 1) + 1; }
int kf_ak(void) { return (8 ^ 16) << 11 | 1; }
int kf_al(void) { return gi + ((8 ^ 16) << 11); }
void kf_sa(void) { gi = (8 ^ 16) << 11; }
void kf_sb(void) { gl = (8 ^ 16) << 11; }
void kf_sc(void) { gu = (8 ^ 16) << 11; }
void kf_va(void) { v2(~255, gi); }
void kf_vb(void) { v2((8 ^ 16) << 11, gi); }
long kf_la(void) { return (8L ^ 16) << 11; }
int kf_ua(void) { return (8U ^ 16) << 11; }
int kf_ca(void) { return ('A' ^ 'B') << 11; }
int kf_cb(void) { return 'A' << 9; }
