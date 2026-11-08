/* How does a caller pass each argument, and who removes them afterwards? */
extern void t_c(char), t_i(int), t_l(long), t_p(char *), t_f(float), t_d(double);
extern void t_mix(char, int, long, char *);
extern void t_six(int, int, int, int, int, int);
extern char gc; extern int gi; extern long gl; extern char *gp; extern float gf; extern double gd;
void c_c(void) { t_c(gc); }
void c_ci(void) { t_c(5); }
void c_i(void) { t_i(gi); }
void c_l(void) { t_l(gl); }
void c_lk(void) { t_l(0x12345678L); }
void c_p(void) { t_p(gp); }
void c_f(void) { t_f(gf); }
void c_d(void) { t_d(gd); }
void c_mix(void) { t_mix(gc, gi, gl, gp); }
void c_six(void) { t_six(1, 2, 3, 4, 5, 6); }
void c_two(void) { t_i(1); t_i(2); }
