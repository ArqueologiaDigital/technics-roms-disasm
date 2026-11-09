/* Operand chains: built in WA and moved, or built in the target? */
extern void g0(void); extern int g1(int); extern int gi, gj, gk, gm, gn;
int ch_g2(void) { return gi + gj; }
int ch_g3(void) { return gi + gj + gk; }
int ch_g4(void) { return gi + gj + gk + gm; }
int ch_g5(void) { return gi + gj + gk + gm + gn; }
int ch_g3_sub(void) { return gi - gj - gk; }
int ch_g3_mix(void) { return gi + gj - gk; }
int ch_g3_and(void) { return gi & gj & gk; }
int ch_g3_xor(void) { return gi ^ gj | gk; }
int ch_g3_rep(void) { return gi + gi + gj; }
int ch_g3_rep2(void) { return gi + gj + gj; }
int ch_g3_k(void) { return gi + gj + 100; }
int ch_g3_k1(void) { return gi + 100 + gj; }
int ch_p3(int a, int b, int c) { return a + b + c; }
int ch_p4(int a, int b, int c) { return a + b + c + a; }
int ch_pg2(int a) { return a + gi + gj; }
int ch_gp2(int a) { return gi + a + gj; }
int ch_ggp(int a) { return gi + gj + a; }
int ch_p2g(int a, int b) { return a + b + gi; }
int ch_c_pg2(int a) { g0(); return a + gi + gj; }
int ch_c_gp2(int a) { g0(); return gi + a + gj; }
int ch_c_ggp(int a) { g0(); return gi + gj + a; }
int ch_c_g3(void) { g0(); return gi + gj + gk; }
int ch_c_g4p(int a) { g0(); return gi + gj + gk + a; }
int ch_c_pg3(int a) { g0(); return a + gi + gj + gk; }
int ch_c_xyz(int a, int b, int c) { int x = a + b, y = b + c, z = a + c; g0(); return x + y + z; }
int ch_c_zyx(int a, int b, int c) { int x = a + b, y = b + c, z = a + c; g0(); return z + y + x; }
int ch_c_yxz(int a, int b, int c) { int x = a + b, y = b + c, z = a + c; g0(); return y + x + z; }
int ch_c_xzy(int a, int b, int c) { int x = a + b, y = b + c, z = a + c; g0(); return x + z + y; }
int ch_c_xyg(int a, int b, int c) { int x = a + b, y = b + c, z = a + c; g0(); return x + y + gi + z; }
void ch_st3(void) { gi = gj + gk + gm; }
void ch_st4(void) { gi = gj + gk + gm + gn; }
void ch_arg3(void) { g1(gj + gk + gm); }
int ch_loc3(void) { int x = gj + gk + gm; g0(); return x; }
