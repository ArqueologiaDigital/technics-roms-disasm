/* Array elements with computed indexes */
extern char gca[]; extern unsigned short gsa[]; extern int gia[]; extern long gla[]; extern int gr;
extern unsigned char gtab[];
char ai_c_g_p1(int i) { return gca[i + 1]; }
char ai_c_g_m1(int i) { return gca[i - 1]; }
char ai_c_g_ij(int i, int j) { return gca[i + j]; }
void ai_c_g_st_p1(int i, char x) { gca[i + 1] = x; }
void ai_c_g_add(int i, char x) { gca[i] += x; }
void ai_c_g_and(int i) { gca[i] &= 0xff; }
void ai_c_g_mul(int i) { gca[i] *= 10; }
void ai_c_g_div(int i) { gca[i] /= 10; }
void ai_c_g_sh(int i) { gca[i - 1] += gca[i] >> 8; }
char ai_c_p_p1(char *p, int i) { return p[i + 1]; }
void ai_c_p_st_m1(char *p, int i, char x) { p[i - 1] = x; }
void ai_c_p_add(char *p, int i, char x) { p[i] += x; }
void ai_c_p_div(char *p, int i) { p[i] /= 10; }
void ai_c_p_carry(char *p, int i) { p[i + 1] += p[i] % 10 * 256; }
unsigned short ai_us_g_p1(int i) { return gsa[i + 1]; }
unsigned short ai_us_g_m1(int i) { return gsa[i - 1]; }
unsigned short ai_us_g_ij(int i, int j) { return gsa[i + j]; }
void ai_us_g_st_p1(int i, unsigned short x) { gsa[i + 1] = x; }
void ai_us_g_add(int i, unsigned short x) { gsa[i] += x; }
void ai_us_g_and(int i) { gsa[i] &= 0xff; }
void ai_us_g_mul(int i) { gsa[i] *= 10; }
void ai_us_g_div(int i) { gsa[i] /= 10; }
void ai_us_g_sh(int i) { gsa[i - 1] += gsa[i] >> 8; }
unsigned short ai_us_p_p1(unsigned short *p, int i) { return p[i + 1]; }
void ai_us_p_st_m1(unsigned short *p, int i, unsigned short x) { p[i - 1] = x; }
void ai_us_p_add(unsigned short *p, int i, unsigned short x) { p[i] += x; }
void ai_us_p_div(unsigned short *p, int i) { p[i] /= 10; }
void ai_us_p_carry(unsigned short *p, int i) { p[i + 1] += p[i] % 10 * 256; }
int ai_i_g_p1(int i) { return gia[i + 1]; }
int ai_i_g_m1(int i) { return gia[i - 1]; }
int ai_i_g_ij(int i, int j) { return gia[i + j]; }
void ai_i_g_st_p1(int i, int x) { gia[i + 1] = x; }
void ai_i_g_add(int i, int x) { gia[i] += x; }
void ai_i_g_and(int i) { gia[i] &= 0xff; }
void ai_i_g_mul(int i) { gia[i] *= 10; }
void ai_i_g_div(int i) { gia[i] /= 10; }
void ai_i_g_sh(int i) { gia[i - 1] += gia[i] >> 8; }
int ai_i_p_p1(int *p, int i) { return p[i + 1]; }
void ai_i_p_st_m1(int *p, int i, int x) { p[i - 1] = x; }
void ai_i_p_add(int *p, int i, int x) { p[i] += x; }
void ai_i_p_div(int *p, int i) { p[i] /= 10; }
void ai_i_p_carry(int *p, int i) { p[i + 1] += p[i] % 10 * 256; }
long ai_l_g_p1(int i) { return gla[i + 1]; }
long ai_l_g_m1(int i) { return gla[i - 1]; }
long ai_l_g_ij(int i, int j) { return gla[i + j]; }
void ai_l_g_st_p1(int i, long x) { gla[i + 1] = x; }
void ai_l_g_add(int i, long x) { gla[i] += x; }
void ai_l_g_and(int i) { gla[i] &= 0xff; }
void ai_l_g_mul(int i) { gla[i] *= 10; }
void ai_l_g_div(int i) { gla[i] /= 10; }
void ai_l_g_sh(int i) { gla[i - 1] += gla[i] >> 8; }
long ai_l_p_p1(long *p, int i) { return p[i + 1]; }
void ai_l_p_st_m1(long *p, int i, long x) { p[i - 1] = x; }
void ai_l_p_add(long *p, int i, long x) { p[i] += x; }
void ai_l_p_div(long *p, int i) { p[i] /= 10; }
void ai_l_p_carry(long *p, int i) { p[i + 1] += p[i] % 10 * 256; }
void ai_div10(unsigned short *t) { int i; for (i = 0; i < 9; i++) { t[i + 1] += t[i] % 10 * 256; t[i] /= 10; } }
void ai_mul10(void) { int i; for (i = 0; i < 10; i++) { if (gsa[i] == 0) continue; gsa[i] *= 10; } }
void ai_carry(void) { int i; for (i = 9; i > 0; i--) { if (gsa[i] >= 256) { gsa[i - 1] += gsa[i] >> 8; gsa[i] &= 0xff; } } }
void ai_clear(int *a, int n) { int i; for (i = 0; i < n; i++) a[i] = 0; }
void ai_shift(unsigned short *a, int n) { int i; for (i = n - 1; i > 0; i--) a[i] = a[i - 1]; a[0] = 0; }
int ai_xdig(char ch) { if (gtab[(unsigned char)ch] & 0x44) return 1; return 2; }
int ai_xdig_i(int ch) { if (gtab[(unsigned char)ch] & 0x44) return 1; return 2; }
int ai_dig_val(char ch) { int n; if (gtab[(unsigned char)ch] & 0x4) n = ch - 48; else return -1; return n; }
int ai_up(char ch) { return (gtab[(unsigned char)ch] & 0x2) ? ch - 32 : ch; }
int ai_up_sub(char ch) { return ((gtab[(unsigned char)ch] & 0x2) ? ch - 32 : ch) - 55; }
