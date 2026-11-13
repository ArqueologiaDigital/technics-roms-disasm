/* Constant folding with a negated constant on the left (random r2_08_12: return -40 - 255 gives 0xffd9, not 0xfed9).
   nk_<n>: one folded constant expression each, returned as an int unless noted. */
extern int gi; extern long gl; extern char gc;
int nk_a(void) { return -40 - 255; }
int nk_b(void) { return -40 - 200; }
int nk_c(void) { return -40 + 255; }
int nk_d(void) { return -1 - 255; }
int nk_e(void) { return 16 - 255; }
int nk_f(void) { return -300 - 255; }
int nk_g(void) { return -40 - 256; }
int nk_h(void) { return -40 - 127; }
int nk_i(void) { return -40 - 128; }
int nk_j(void) { return -128 - 255; }
int nk_k(void) { return -129 - 255; }
int nk_l(void) { return (-40) - 255; }
int nk_m(void) { return -40 * 255; }
int nk_n(void) { return -40 * 3; }
int nk_o(void) { return -40 * 4; }
int nk_p(void) { return 255 - -40; }
int nk_q(void) { return -40 - 1000; }
int nk_r(void) { return -40 & 255; }
int nk_s(void) { return -40 | 256; }
int nk_t(void) { return -40 ^ 255; }
int nk_u(void) { return ~40 - 255; }
int nk_v(void) { return -40 - 89; }
int nk_w(void) { return -40 - 88; }
int nk_x(void) { return -40 + -255; }
int nk_y(void) { return 40 - 255; }
int nk_z(void) { return -40 - 255 - 1; }
void nk_sa(void) { gi = -40 - 255; }
void nk_sb(void) { gl = -40 - 255; }
void nk_sc(void) { gc = -40 - 255; }
int nk_va(void) { return gi + (-40 - 255); }
long nk_la(void) { return -40L - 255; }
long nk_lb(void) { return -40 - 255L; }
unsigned nk_ua(void) { return -40 - 255U; }
int nk_ca(void) { return -'A' - 255; }
int nk_cb(void) { return 'A' - 255; }
int nk_h1(void) { return -0x28 - 0xff; }
int nk_h2(void) { return -40 - 0xff; }
int nk_h3(void) { return -40 - 0377; }
