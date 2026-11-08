/* Binary operators at type int: parameters, globals, a constant, a local. */
extern int gi1, gi2, gi3;
int add_i_pp(int a, int b) { return a + b; }
int add_i_pk(int a) { return a + 5; }
void add_i_gg(void) { gi1 = gi2 + gi3; }
void add_i_gk(void) { gi1 = gi2 + 5; }
int add_i_loc(int a, int b) { int x = a + b; return x + a; }
int sub_i_pp(int a, int b) { return a - b; }
int sub_i_pk(int a) { return a - 5; }
void sub_i_gg(void) { gi1 = gi2 - gi3; }
void sub_i_gk(void) { gi1 = gi2 - 5; }
int sub_i_loc(int a, int b) { int x = a - b; return x - a; }
int mul_i_pp(int a, int b) { return a * b; }
int mul_i_pk(int a) { return a * 10; }
void mul_i_gg(void) { gi1 = gi2 * gi3; }
void mul_i_gk(void) { gi1 = gi2 * 10; }
int mul_i_loc(int a, int b) { int x = a * b; return x * a; }
int div_i_pp(int a, int b) { return a / b; }
int div_i_pk(int a) { return a / 10; }
void div_i_gg(void) { gi1 = gi2 / gi3; }
void div_i_gk(void) { gi1 = gi2 / 10; }
int div_i_loc(int a, int b) { int x = a / b; return x / a; }
int mod_i_pp(int a, int b) { return a % b; }
int mod_i_pk(int a) { return a % 10; }
void mod_i_gg(void) { gi1 = gi2 % gi3; }
void mod_i_gk(void) { gi1 = gi2 % 10; }
int mod_i_loc(int a, int b) { int x = a % b; return x % a; }
int and_i_pp(int a, int b) { return a & b; }
int and_i_pk(int a) { return a & 5; }
void and_i_gg(void) { gi1 = gi2 & gi3; }
void and_i_gk(void) { gi1 = gi2 & 5; }
int and_i_loc(int a, int b) { int x = a & b; return x & a; }
int or_i_pp(int a, int b) { return a | b; }
int or_i_pk(int a) { return a | 5; }
void or_i_gg(void) { gi1 = gi2 | gi3; }
void or_i_gk(void) { gi1 = gi2 | 5; }
int or_i_loc(int a, int b) { int x = a | b; return x | a; }
int xor_i_pp(int a, int b) { return a ^ b; }
int xor_i_pk(int a) { return a ^ 5; }
void xor_i_gg(void) { gi1 = gi2 ^ gi3; }
void xor_i_gk(void) { gi1 = gi2 ^ 5; }
int xor_i_loc(int a, int b) { int x = a ^ b; return x ^ a; }
int shl_i_pp(int a, int b) { return a << b; }
int shl_i_pk(int a) { return a << 3; }
void shl_i_gg(void) { gi1 = gi2 << gi3; }
void shl_i_gk(void) { gi1 = gi2 << 3; }
int shl_i_loc(int a, int b) { int x = a << b; return x << a; }
int shr_i_pp(int a, int b) { return a >> b; }
int shr_i_pk(int a) { return a >> 3; }
void shr_i_gg(void) { gi1 = gi2 >> gi3; }
void shr_i_gk(void) { gi1 = gi2 >> 3; }
int shr_i_loc(int a, int b) { int x = a >> b; return x >> a; }
