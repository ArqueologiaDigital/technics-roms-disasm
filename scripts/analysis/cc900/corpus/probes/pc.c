/* Cached cdecl parameter (gen_pc.py).  pc_<t>_<form>(t c): t i int, u unsigned int, c char; forms a..p vary the number
   of reads of c (1..4) and their roles (value, array index, divisor, compared); no calls. */
extern int gi, gia[8], gib[8]; extern unsigned int gu, gua[8], gub[8]; extern char gc, gca[8], gcb[8];
void pc_i_a(int c) { gi = c; }
void pc_i_b(int c) { gi = gia[c]; }
void pc_i_c(int c) { gi = c + c; }
void pc_i_d(int c) { gi = gia[c] + c; }
void pc_i_e(int c) { gi = gia[c] / c; }
void pc_i_f(int c) { gia[c] = gib[c]; }
void pc_i_g(int c) { gia[c] = c; }
void pc_i_h(int c) { gi = c * c + c; }
void pc_i_i(int c) { gia[c] = gib[c] + c; }
void pc_i_j(int c) { gi = gia[c] + gib[c] + c; }
void pc_i_k(int c) { gi = (c != 0) ? gia[c] : c; }
void pc_i_l(int c) { if (c != 0) gi = gia[c] / c; }
void pc_i_m(int c) { gia[c] = gib[c] / c; }
void pc_i_n(int c) { gi = gia[c] + gib[c] + gia[c] + c; }
void pc_i_o(int c) { if (c != 0) gia[c] = gib[c] % c; }
void pc_i_p(int c) { gi = c + c + c + c; }

void pc_u_a(unsigned int c) { gu = c; }
void pc_u_b(unsigned int c) { gu = gua[c]; }
void pc_u_c(unsigned int c) { gu = c + c; }
void pc_u_d(unsigned int c) { gu = gua[c] + c; }
void pc_u_e(unsigned int c) { gu = gua[c] / c; }
void pc_u_f(unsigned int c) { gua[c] = gub[c]; }
void pc_u_g(unsigned int c) { gua[c] = c; }
void pc_u_h(unsigned int c) { gu = c * c + c; }
void pc_u_i(unsigned int c) { gua[c] = gub[c] + c; }
void pc_u_j(unsigned int c) { gu = gua[c] + gub[c] + c; }
void pc_u_k(unsigned int c) { gu = (c != 0) ? gua[c] : c; }
void pc_u_l(unsigned int c) { if (c != 0) gu = gua[c] / c; }
void pc_u_m(unsigned int c) { gua[c] = gub[c] / c; }
void pc_u_n(unsigned int c) { gu = gua[c] + gub[c] + gua[c] + c; }
void pc_u_o(unsigned int c) { if (c != 0) gua[c] = gub[c] % c; }
void pc_u_p(unsigned int c) { gu = c + c + c + c; }

void pc_c_a(char c) { gc = c; }
void pc_c_b(char c) { gc = gca[c]; }
void pc_c_c(char c) { gc = c + c; }
void pc_c_d(char c) { gc = gca[c] + c; }
void pc_c_e(char c) { gc = gca[c] / c; }
void pc_c_f(char c) { gca[c] = gcb[c]; }
void pc_c_g(char c) { gca[c] = c; }
void pc_c_h(char c) { gc = c * c + c; }
void pc_c_i(char c) { gca[c] = gcb[c] + c; }
void pc_c_j(char c) { gc = gca[c] + gcb[c] + c; }
void pc_c_k(char c) { gc = (c != 0) ? gca[c] : c; }
void pc_c_l(char c) { if (c != 0) gc = gca[c] / c; }
void pc_c_m(char c) { gca[c] = gcb[c] / c; }
void pc_c_n(char c) { gc = gca[c] + gcb[c] + gca[c] + c; }
void pc_c_o(char c) { if (c != 0) gca[c] = gcb[c] % c; }
void pc_c_p(char c) { gc = c + c + c + c; }
