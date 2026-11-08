/* Binary operators at type unsigned long: parameters, globals, a constant, a local. */
extern unsigned long gul1, gul2, gul3;
unsigned long add_ul_pp(unsigned long a, unsigned long b) { return a + b; }
unsigned long add_ul_pk(unsigned long a) { return a + 5; }
void add_ul_gg(void) { gul1 = gul2 + gul3; }
void add_ul_gk(void) { gul1 = gul2 + 5; }
unsigned long add_ul_loc(unsigned long a, unsigned long b) { unsigned long x = a + b; return x + a; }
unsigned long sub_ul_pp(unsigned long a, unsigned long b) { return a - b; }
unsigned long sub_ul_pk(unsigned long a) { return a - 5; }
void sub_ul_gg(void) { gul1 = gul2 - gul3; }
void sub_ul_gk(void) { gul1 = gul2 - 5; }
unsigned long sub_ul_loc(unsigned long a, unsigned long b) { unsigned long x = a - b; return x - a; }
unsigned long mul_ul_pp(unsigned long a, unsigned long b) { return a * b; }
unsigned long mul_ul_pk(unsigned long a) { return a * 10; }
void mul_ul_gg(void) { gul1 = gul2 * gul3; }
void mul_ul_gk(void) { gul1 = gul2 * 10; }
unsigned long mul_ul_loc(unsigned long a, unsigned long b) { unsigned long x = a * b; return x * a; }
unsigned long div_ul_pp(unsigned long a, unsigned long b) { return a / b; }
unsigned long div_ul_pk(unsigned long a) { return a / 10; }
void div_ul_gg(void) { gul1 = gul2 / gul3; }
void div_ul_gk(void) { gul1 = gul2 / 10; }
unsigned long div_ul_loc(unsigned long a, unsigned long b) { unsigned long x = a / b; return x / a; }
unsigned long mod_ul_pp(unsigned long a, unsigned long b) { return a % b; }
unsigned long mod_ul_pk(unsigned long a) { return a % 10; }
void mod_ul_gg(void) { gul1 = gul2 % gul3; }
void mod_ul_gk(void) { gul1 = gul2 % 10; }
unsigned long mod_ul_loc(unsigned long a, unsigned long b) { unsigned long x = a % b; return x % a; }
unsigned long and_ul_pp(unsigned long a, unsigned long b) { return a & b; }
unsigned long and_ul_pk(unsigned long a) { return a & 5; }
void and_ul_gg(void) { gul1 = gul2 & gul3; }
void and_ul_gk(void) { gul1 = gul2 & 5; }
unsigned long and_ul_loc(unsigned long a, unsigned long b) { unsigned long x = a & b; return x & a; }
unsigned long or_ul_pp(unsigned long a, unsigned long b) { return a | b; }
unsigned long or_ul_pk(unsigned long a) { return a | 5; }
void or_ul_gg(void) { gul1 = gul2 | gul3; }
void or_ul_gk(void) { gul1 = gul2 | 5; }
unsigned long or_ul_loc(unsigned long a, unsigned long b) { unsigned long x = a | b; return x | a; }
unsigned long xor_ul_pp(unsigned long a, unsigned long b) { return a ^ b; }
unsigned long xor_ul_pk(unsigned long a) { return a ^ 5; }
void xor_ul_gg(void) { gul1 = gul2 ^ gul3; }
void xor_ul_gk(void) { gul1 = gul2 ^ 5; }
unsigned long xor_ul_loc(unsigned long a, unsigned long b) { unsigned long x = a ^ b; return x ^ a; }
unsigned long shl_ul_pp(unsigned long a, unsigned long b) { return a << b; }
unsigned long shl_ul_pk(unsigned long a) { return a << 3; }
void shl_ul_gg(void) { gul1 = gul2 << gul3; }
void shl_ul_gk(void) { gul1 = gul2 << 3; }
unsigned long shl_ul_loc(unsigned long a, unsigned long b) { unsigned long x = a << b; return x << a; }
unsigned long shr_ul_pp(unsigned long a, unsigned long b) { return a >> b; }
unsigned long shr_ul_pk(unsigned long a) { return a >> 3; }
void shr_ul_gg(void) { gul1 = gul2 >> gul3; }
void shr_ul_gk(void) { gul1 = gul2 >> 3; }
unsigned long shr_ul_loc(unsigned long a, unsigned long b) { unsigned long x = a >> b; return x >> a; }
