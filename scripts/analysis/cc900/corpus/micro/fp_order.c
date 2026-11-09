/* Operand order of double expressions with conversions and table elements */
typedef union { unsigned char c[8]; double val; } DB;
extern DB gtab[]; extern double gd, gd2, gda[]; extern double fd(double); extern int gi;
double fo_log(int n, double s) { return gtab[3].val * n + 2 * s; }
double fo_log_rev(int n, double s) { return 2 * s + gtab[3].val * n; }
double fo_conv2(int n, double s) { return n * 2.0 + s * 3.0; }
double fo_conv2_rev(int n, double s) { return s * 3.0 + n * 2.0; }
double fo_mem_n(int n) { return gtab[3].val * n; }
double fo_n_mem(int n) { return n * gtab[3].val; }
double fo_glob_n(int n, double s) { return gd * n + 2 * s; }
double fo_arr_n(int n, double s) { return gda[3] * n + 2 * s; }
double fo_mem_call(double x) { return gtab[3].val * fd(x); }
double fo_mem_add(int n) { return gtab[3].val + n; }
double fo_mem_sub(int n) { return gtab[3].val - n; }
double fo_mem_div(int n) { return gtab[3].val / n; }
double fo_n_div(int n) { return n / gtab[3].val; }
double fo_gi(double s) { return gtab[3].val * gi + s; }
double fo_two_conv(int n, int m) { return (double)n * m; }
double fo_mem_mem(int n) { return gtab[3].val * gtab[2].val + n; }
void fo_store(int n, double s) { gd = gtab[3].val * n + 2 * s; }
double fo_loc(int n, double s) { double t; t = gtab[3].val * n; return t + 2 * s; }
