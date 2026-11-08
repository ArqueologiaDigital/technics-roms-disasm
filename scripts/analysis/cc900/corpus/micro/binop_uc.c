/* Binary operators at type unsigned char: parameters, globals, a constant, a local. */
extern unsigned char guc1, guc2, guc3;
unsigned char add_uc_pp(unsigned char a, unsigned char b) { return a + b; }
unsigned char add_uc_pk(unsigned char a) { return a + 5; }
void add_uc_gg(void) { guc1 = guc2 + guc3; }
void add_uc_gk(void) { guc1 = guc2 + 5; }
unsigned char add_uc_loc(unsigned char a, unsigned char b) { unsigned char x = a + b; return x + a; }
unsigned char sub_uc_pp(unsigned char a, unsigned char b) { return a - b; }
unsigned char sub_uc_pk(unsigned char a) { return a - 5; }
void sub_uc_gg(void) { guc1 = guc2 - guc3; }
void sub_uc_gk(void) { guc1 = guc2 - 5; }
unsigned char sub_uc_loc(unsigned char a, unsigned char b) { unsigned char x = a - b; return x - a; }
unsigned char mul_uc_pp(unsigned char a, unsigned char b) { return a * b; }
unsigned char mul_uc_pk(unsigned char a) { return a * 10; }
void mul_uc_gg(void) { guc1 = guc2 * guc3; }
void mul_uc_gk(void) { guc1 = guc2 * 10; }
unsigned char mul_uc_loc(unsigned char a, unsigned char b) { unsigned char x = a * b; return x * a; }
unsigned char div_uc_pp(unsigned char a, unsigned char b) { return a / b; }
unsigned char div_uc_pk(unsigned char a) { return a / 10; }
void div_uc_gg(void) { guc1 = guc2 / guc3; }
void div_uc_gk(void) { guc1 = guc2 / 10; }
unsigned char div_uc_loc(unsigned char a, unsigned char b) { unsigned char x = a / b; return x / a; }
unsigned char mod_uc_pp(unsigned char a, unsigned char b) { return a % b; }
unsigned char mod_uc_pk(unsigned char a) { return a % 10; }
void mod_uc_gg(void) { guc1 = guc2 % guc3; }
void mod_uc_gk(void) { guc1 = guc2 % 10; }
unsigned char mod_uc_loc(unsigned char a, unsigned char b) { unsigned char x = a % b; return x % a; }
unsigned char and_uc_pp(unsigned char a, unsigned char b) { return a & b; }
unsigned char and_uc_pk(unsigned char a) { return a & 5; }
void and_uc_gg(void) { guc1 = guc2 & guc3; }
void and_uc_gk(void) { guc1 = guc2 & 5; }
unsigned char and_uc_loc(unsigned char a, unsigned char b) { unsigned char x = a & b; return x & a; }
unsigned char or_uc_pp(unsigned char a, unsigned char b) { return a | b; }
unsigned char or_uc_pk(unsigned char a) { return a | 5; }
void or_uc_gg(void) { guc1 = guc2 | guc3; }
void or_uc_gk(void) { guc1 = guc2 | 5; }
unsigned char or_uc_loc(unsigned char a, unsigned char b) { unsigned char x = a | b; return x | a; }
unsigned char xor_uc_pp(unsigned char a, unsigned char b) { return a ^ b; }
unsigned char xor_uc_pk(unsigned char a) { return a ^ 5; }
void xor_uc_gg(void) { guc1 = guc2 ^ guc3; }
void xor_uc_gk(void) { guc1 = guc2 ^ 5; }
unsigned char xor_uc_loc(unsigned char a, unsigned char b) { unsigned char x = a ^ b; return x ^ a; }
unsigned char shl_uc_pp(unsigned char a, unsigned char b) { return a << b; }
unsigned char shl_uc_pk(unsigned char a) { return a << 3; }
void shl_uc_gg(void) { guc1 = guc2 << guc3; }
void shl_uc_gk(void) { guc1 = guc2 << 3; }
unsigned char shl_uc_loc(unsigned char a, unsigned char b) { unsigned char x = a << b; return x << a; }
unsigned char shr_uc_pp(unsigned char a, unsigned char b) { return a >> b; }
unsigned char shr_uc_pk(unsigned char a) { return a >> 3; }
void shr_uc_gg(void) { guc1 = guc2 >> guc3; }
void shr_uc_gk(void) { guc1 = guc2 >> 3; }
unsigned char shr_uc_loc(unsigned char a, unsigned char b) { unsigned char x = a >> b; return x >> a; }
