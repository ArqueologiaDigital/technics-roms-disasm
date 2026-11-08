/* How are calls through pointers and to helpers (multiply, divide, shifts, floats) made? */
extern int (*gfp)(int); extern long gl, gl2; extern unsigned long gul; extern int gi, gi2; extern float gf, gf2; extern double gd, gd2;
int fp_call(int x) { return gfp(x); }
int fp_arg(int (*f)(int), int x) { return f(x); }
long h_lmul(void) { return gl * gl2; }
long h_ldiv(void) { return gl / gl2; }
long h_lmod(void) { return gl % gl2; }
unsigned long h_uldiv(void) { return gul / 10; }
int h_imul(void) { return gi * gi2; }
int h_idiv(void) { return gi / gi2; }
long h_lshl(int n) { return gl << n; }
long h_lshr(int n) { return gl >> n; }
float h_fadd(void) { return gf + gf2; }
double h_dmul(void) { return gd * gd2; }
int h_dcmp(void) { return gd < gd2; }
long h_d2l(void) { return (long)gd; }
double h_l2d(void) { return (double)gl; }
