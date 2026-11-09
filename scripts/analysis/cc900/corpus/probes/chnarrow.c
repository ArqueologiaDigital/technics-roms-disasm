/* When does cc900 do int arithmetic on a char operand in the byte itself (sub A,0x30 / exts WA) instead of
   widening first?  Constants small and large, variables, the four operators, char and unsigned char, a return,
   a store to an int and to a char, and a conditional with char arms. */
extern int gi; extern char gc; extern unsigned char guc;
int cn_sub_k(char c) { return c - 48; }
int cn_add_k(char c) { return c + 5; }
int cn_add_big(char c) { return c + 200; }
int cn_sub_big(char c) { return c - 300; }
int cn_and_k(char c) { return c & 0x0f; }
int cn_or_k(char c) { return c | 0x20; }
int cn_mul_k(char c) { return c * 3; }
int cn_sub_v(char c, char d) { return c - d; }
int cn_sub_iv(char c, int d) { return c - d; }
int cn_uc_sub(unsigned char c) { return c - 48; }
int cn_uc_add(unsigned char c) { return c + 5; }
int cn_g_sub(void) { return gc - 48; }
void cn_st_int(char c) { gi = c - 48; }
void cn_st_char(char c) { gc = c - 48; }
int cn_loc(char c) { int n; n = c - 48; return n; }
int cn_loc2(char c) { int n; n = c - 48; return n * 2; }
int cn_tern(char c, int k) { return k ? c - 32 : c; }
int cn_tern_i(int c, int k) { return k ? c - 32 : c; }
int cn_tern_cc(char c, char d, int k) { return k ? c : d; }
int cn_cmp(char c) { return c - 48 < 10; }
