/* Binary operators at type long: parameters, globals, a constant, a local. */
extern long gl1, gl2, gl3;
long add_l_pp(long a, long b) { return a + b; }
long add_l_pk(long a) { return a + 5; }
void add_l_gg(void) { gl1 = gl2 + gl3; }
void add_l_gk(void) { gl1 = gl2 + 5; }
long add_l_loc(long a, long b) { long x = a + b; return x + a; }
long sub_l_pp(long a, long b) { return a - b; }
long sub_l_pk(long a) { return a - 5; }
void sub_l_gg(void) { gl1 = gl2 - gl3; }
void sub_l_gk(void) { gl1 = gl2 - 5; }
long sub_l_loc(long a, long b) { long x = a - b; return x - a; }
long mul_l_pp(long a, long b) { return a * b; }
long mul_l_pk(long a) { return a * 10; }
void mul_l_gg(void) { gl1 = gl2 * gl3; }
void mul_l_gk(void) { gl1 = gl2 * 10; }
long mul_l_loc(long a, long b) { long x = a * b; return x * a; }
long div_l_pp(long a, long b) { return a / b; }
long div_l_pk(long a) { return a / 10; }
void div_l_gg(void) { gl1 = gl2 / gl3; }
void div_l_gk(void) { gl1 = gl2 / 10; }
long div_l_loc(long a, long b) { long x = a / b; return x / a; }
long mod_l_pp(long a, long b) { return a % b; }
long mod_l_pk(long a) { return a % 10; }
void mod_l_gg(void) { gl1 = gl2 % gl3; }
void mod_l_gk(void) { gl1 = gl2 % 10; }
long mod_l_loc(long a, long b) { long x = a % b; return x % a; }
long and_l_pp(long a, long b) { return a & b; }
long and_l_pk(long a) { return a & 5; }
void and_l_gg(void) { gl1 = gl2 & gl3; }
void and_l_gk(void) { gl1 = gl2 & 5; }
long and_l_loc(long a, long b) { long x = a & b; return x & a; }
long or_l_pp(long a, long b) { return a | b; }
long or_l_pk(long a) { return a | 5; }
void or_l_gg(void) { gl1 = gl2 | gl3; }
void or_l_gk(void) { gl1 = gl2 | 5; }
long or_l_loc(long a, long b) { long x = a | b; return x | a; }
long xor_l_pp(long a, long b) { return a ^ b; }
long xor_l_pk(long a) { return a ^ 5; }
void xor_l_gg(void) { gl1 = gl2 ^ gl3; }
void xor_l_gk(void) { gl1 = gl2 ^ 5; }
long xor_l_loc(long a, long b) { long x = a ^ b; return x ^ a; }
long shl_l_pp(long a, long b) { return a << b; }
long shl_l_pk(long a) { return a << 3; }
void shl_l_gg(void) { gl1 = gl2 << gl3; }
void shl_l_gk(void) { gl1 = gl2 << 3; }
long shl_l_loc(long a, long b) { long x = a << b; return x << a; }
long shr_l_pp(long a, long b) { return a >> b; }
long shr_l_pk(long a) { return a >> 3; }
void shr_l_gg(void) { gl1 = gl2 >> gl3; }
void shr_l_gk(void) { gl1 = gl2 >> 3; }
long shr_l_loc(long a, long b) { long x = a >> b; return x >> a; }
