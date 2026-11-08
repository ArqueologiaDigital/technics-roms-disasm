/* Binary operators at type char: parameters, globals, a constant, a local. */
extern char gc1, gc2, gc3;
char add_c_pp(char a, char b) { return a + b; }
char add_c_pk(char a) { return a + 5; }
void add_c_gg(void) { gc1 = gc2 + gc3; }
void add_c_gk(void) { gc1 = gc2 + 5; }
char add_c_loc(char a, char b) { char x = a + b; return x + a; }
char sub_c_pp(char a, char b) { return a - b; }
char sub_c_pk(char a) { return a - 5; }
void sub_c_gg(void) { gc1 = gc2 - gc3; }
void sub_c_gk(void) { gc1 = gc2 - 5; }
char sub_c_loc(char a, char b) { char x = a - b; return x - a; }
char mul_c_pp(char a, char b) { return a * b; }
char mul_c_pk(char a) { return a * 10; }
void mul_c_gg(void) { gc1 = gc2 * gc3; }
void mul_c_gk(void) { gc1 = gc2 * 10; }
char mul_c_loc(char a, char b) { char x = a * b; return x * a; }
char div_c_pp(char a, char b) { return a / b; }
char div_c_pk(char a) { return a / 10; }
void div_c_gg(void) { gc1 = gc2 / gc3; }
void div_c_gk(void) { gc1 = gc2 / 10; }
char div_c_loc(char a, char b) { char x = a / b; return x / a; }
char mod_c_pp(char a, char b) { return a % b; }
char mod_c_pk(char a) { return a % 10; }
void mod_c_gg(void) { gc1 = gc2 % gc3; }
void mod_c_gk(void) { gc1 = gc2 % 10; }
char mod_c_loc(char a, char b) { char x = a % b; return x % a; }
char and_c_pp(char a, char b) { return a & b; }
char and_c_pk(char a) { return a & 5; }
void and_c_gg(void) { gc1 = gc2 & gc3; }
void and_c_gk(void) { gc1 = gc2 & 5; }
char and_c_loc(char a, char b) { char x = a & b; return x & a; }
char or_c_pp(char a, char b) { return a | b; }
char or_c_pk(char a) { return a | 5; }
void or_c_gg(void) { gc1 = gc2 | gc3; }
void or_c_gk(void) { gc1 = gc2 | 5; }
char or_c_loc(char a, char b) { char x = a | b; return x | a; }
char xor_c_pp(char a, char b) { return a ^ b; }
char xor_c_pk(char a) { return a ^ 5; }
void xor_c_gg(void) { gc1 = gc2 ^ gc3; }
void xor_c_gk(void) { gc1 = gc2 ^ 5; }
char xor_c_loc(char a, char b) { char x = a ^ b; return x ^ a; }
char shl_c_pp(char a, char b) { return a << b; }
char shl_c_pk(char a) { return a << 3; }
void shl_c_gg(void) { gc1 = gc2 << gc3; }
void shl_c_gk(void) { gc1 = gc2 << 3; }
char shl_c_loc(char a, char b) { char x = a << b; return x << a; }
char shr_c_pp(char a, char b) { return a >> b; }
char shr_c_pk(char a) { return a >> 3; }
void shr_c_gg(void) { gc1 = gc2 >> gc3; }
void shr_c_gk(void) { gc1 = gc2 >> 3; }
char shr_c_loc(char a, char b) { char x = a >> b; return x >> a; }
