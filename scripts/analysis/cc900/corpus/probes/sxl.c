/* lane_o3 mini-probe: adecl stack layout of small structs; see gen_sxl.py */
struct s2 { int a; }; struct s4 { int a, b; }; struct s8 { long a; int b, c; };
extern char gi_C0;
extern double gi_D0;
extern double gi_D1;
extern double gi_D2;
extern double gi_D4;
extern int gi_I0;
extern int gi_I1;
extern int gi_I2;
extern int gi_I3;
extern long gi_L0;
extern long gi_L2;
extern long gi_L3;
extern struct s2 gi_s20;
extern struct s2 gi_s21;
extern struct s4 gi_s40;
extern struct s4 gi_s41;
extern struct s4 gi_s42;
extern struct s4 gi_s43;
extern struct s8 gi_s81;
extern char go_C0;
extern double go_D0;
extern double go_D1;
extern double go_D2;
extern double go_D4;
extern int go_I0;
extern int go_I1;
extern int go_I2;
extern int go_I3;
extern long go_L0;
extern long go_L2;
extern long go_L3;
extern struct s2 go_s20;
extern struct s2 go_s21;
extern struct s4 go_s40;
extern struct s4 go_s41;
extern struct s4 go_s42;
extern struct s4 go_s43;
extern struct s8 go_s81;
void sx_d_a(long p0, struct s4 p1, double p2) { go_L0 = p0; go_s41 = p1; go_D2 = p2; }
extern void x_a(long, struct s4, double);
void sx_c_a(void) { x_a(gi_L0, gi_s41, gi_D2); }
void sx_d_b(struct s4 p0, double p1) { go_s40 = p0; go_D1 = p1; }
extern void x_b(struct s4, double);
void sx_c_b(void) { x_b(gi_s40, gi_D1); }
void sx_d_c(double p0, struct s4 p1) { go_D0 = p0; go_s41 = p1; }
extern void x_c(double, struct s4);
void sx_c_c(void) { x_c(gi_D0, gi_s41); }
void sx_d_d(int p0, int p1, int p2, struct s4 p3, double p4) { go_I0 = p0; go_I1 = p1; go_I2 = p2; go_s43 = p3; go_D4 = p4; }
extern void x_d(int, int, int, struct s4, double);
void sx_c_d(void) { x_d(gi_I0, gi_I1, gi_I2, gi_s43, gi_D4); }
void sx_d_e(long p0, struct s4 p1, long p2, long p3) { go_L0 = p0; go_s41 = p1; go_L2 = p2; go_L3 = p3; }
extern void x_e(long, struct s4, long, long);
void sx_c_e(void) { x_e(gi_L0, gi_s41, gi_L2, gi_L3); }
void sx_d_f(long p0, struct s4 p1, struct s4 p2) { go_L0 = p0; go_s41 = p1; go_s42 = p2; }
extern void x_f(long, struct s4, struct s4);
void sx_c_f(void) { x_f(gi_L0, gi_s41, gi_s42); }
void sx_d_g(long p0, double p1, struct s4 p2) { go_L0 = p0; go_D1 = p1; go_s42 = p2; }
extern void x_g(long, double, struct s4);
void sx_c_g(void) { x_g(gi_L0, gi_D1, gi_s42); }
void sx_d_h(struct s4 p0, struct s8 p1) { go_s40 = p0; go_s81 = p1; }
extern void x_h(struct s4, struct s8);
void sx_c_h(void) { x_h(gi_s40, gi_s81); }
void sx_d_i(char p0, struct s4 p1, double p2, int p3) { go_C0 = p0; go_s41 = p1; go_D2 = p2; go_I3 = p3; }
extern void x_i(char, struct s4, double, int);
void sx_c_i(void) { x_i(gi_C0, gi_s41, gi_D2, gi_I3); }
void sx_d_j(long p0, struct s2 p1, double p2) { go_L0 = p0; go_s21 = p1; go_D2 = p2; }
extern void x_j(long, struct s2, double);
void sx_c_j(void) { x_j(gi_L0, gi_s21, gi_D2); }
void sx_d_k(struct s2 p0, double p1) { go_s20 = p0; go_D1 = p1; }
extern void x_k(struct s2, double);
void sx_c_k(void) { x_k(gi_s20, gi_D1); }
void sx_d_l(long p0, struct s8 p1, double p2) { go_L0 = p0; go_s81 = p1; go_D2 = p2; }
extern void x_l(long, struct s8, double);
void sx_c_l(void) { x_l(gi_L0, gi_s81, gi_D2); }
