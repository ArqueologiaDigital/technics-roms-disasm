/* Binary operators at type unsigned int: parameters, globals, a constant, a local. */
extern unsigned int gui1, gui2, gui3;
unsigned int add_ui_pp(unsigned int a, unsigned int b) { return a + b; }
unsigned int add_ui_pk(unsigned int a) { return a + 5; }
void add_ui_gg(void) { gui1 = gui2 + gui3; }
void add_ui_gk(void) { gui1 = gui2 + 5; }
unsigned int add_ui_loc(unsigned int a, unsigned int b) { unsigned int x = a + b; return x + a; }
unsigned int sub_ui_pp(unsigned int a, unsigned int b) { return a - b; }
unsigned int sub_ui_pk(unsigned int a) { return a - 5; }
void sub_ui_gg(void) { gui1 = gui2 - gui3; }
void sub_ui_gk(void) { gui1 = gui2 - 5; }
unsigned int sub_ui_loc(unsigned int a, unsigned int b) { unsigned int x = a - b; return x - a; }
unsigned int mul_ui_pp(unsigned int a, unsigned int b) { return a * b; }
unsigned int mul_ui_pk(unsigned int a) { return a * 10; }
void mul_ui_gg(void) { gui1 = gui2 * gui3; }
void mul_ui_gk(void) { gui1 = gui2 * 10; }
unsigned int mul_ui_loc(unsigned int a, unsigned int b) { unsigned int x = a * b; return x * a; }
unsigned int div_ui_pp(unsigned int a, unsigned int b) { return a / b; }
unsigned int div_ui_pk(unsigned int a) { return a / 10; }
void div_ui_gg(void) { gui1 = gui2 / gui3; }
void div_ui_gk(void) { gui1 = gui2 / 10; }
unsigned int div_ui_loc(unsigned int a, unsigned int b) { unsigned int x = a / b; return x / a; }
unsigned int mod_ui_pp(unsigned int a, unsigned int b) { return a % b; }
unsigned int mod_ui_pk(unsigned int a) { return a % 10; }
void mod_ui_gg(void) { gui1 = gui2 % gui3; }
void mod_ui_gk(void) { gui1 = gui2 % 10; }
unsigned int mod_ui_loc(unsigned int a, unsigned int b) { unsigned int x = a % b; return x % a; }
unsigned int and_ui_pp(unsigned int a, unsigned int b) { return a & b; }
unsigned int and_ui_pk(unsigned int a) { return a & 5; }
void and_ui_gg(void) { gui1 = gui2 & gui3; }
void and_ui_gk(void) { gui1 = gui2 & 5; }
unsigned int and_ui_loc(unsigned int a, unsigned int b) { unsigned int x = a & b; return x & a; }
unsigned int or_ui_pp(unsigned int a, unsigned int b) { return a | b; }
unsigned int or_ui_pk(unsigned int a) { return a | 5; }
void or_ui_gg(void) { gui1 = gui2 | gui3; }
void or_ui_gk(void) { gui1 = gui2 | 5; }
unsigned int or_ui_loc(unsigned int a, unsigned int b) { unsigned int x = a | b; return x | a; }
unsigned int xor_ui_pp(unsigned int a, unsigned int b) { return a ^ b; }
unsigned int xor_ui_pk(unsigned int a) { return a ^ 5; }
void xor_ui_gg(void) { gui1 = gui2 ^ gui3; }
void xor_ui_gk(void) { gui1 = gui2 ^ 5; }
unsigned int xor_ui_loc(unsigned int a, unsigned int b) { unsigned int x = a ^ b; return x ^ a; }
unsigned int shl_ui_pp(unsigned int a, unsigned int b) { return a << b; }
unsigned int shl_ui_pk(unsigned int a) { return a << 3; }
void shl_ui_gg(void) { gui1 = gui2 << gui3; }
void shl_ui_gk(void) { gui1 = gui2 << 3; }
unsigned int shl_ui_loc(unsigned int a, unsigned int b) { unsigned int x = a << b; return x << a; }
unsigned int shr_ui_pp(unsigned int a, unsigned int b) { return a >> b; }
unsigned int shr_ui_pk(unsigned int a) { return a >> 3; }
void shr_ui_gg(void) { gui1 = gui2 >> gui3; }
void shr_ui_gk(void) { gui1 = gui2 >> 3; }
unsigned int shr_ui_loc(unsigned int a, unsigned int b) { unsigned int x = a >> b; return x >> a; }
