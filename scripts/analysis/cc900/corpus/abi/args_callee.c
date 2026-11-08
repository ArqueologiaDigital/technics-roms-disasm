/* Where does a callee find each argument, by type and position? */
char  a_c(char x) { return x; }
int   a_uc(unsigned char x) { return x; }
int   a_s(short x) { return x; }
int   a_i(int x) { return x; }
long  a_l(long x) { return x; }
char *a_p(char *x) { return x; }
float a_f(float x) { return x; }
double a_d(double x) { return x; }
long  a_mix(char c, int i, long l, char *p) { return c + i + l + (long)p; }
int   a_second(int a, int b) { return b; }
long  a_third(char a, char b, long c) { return c; }
int   a_many(int a, int b, int c, int d, int e, int f) { return a + f; }
