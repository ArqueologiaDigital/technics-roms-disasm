/* x & mask as a condition */
struct st { int flag; char c; long l; unsigned char b[4]; };
typedef union { double d; unsigned char c[8]; unsigned int n[4]; } DU;
extern char gc; extern unsigned char guc; extern int gi; extern unsigned int gui; extern long gl;
extern unsigned long gul; extern int gr; extern unsigned char gtab[]; extern struct st *gps;
extern int f(int);
int cb_c_p_1(char x) { if (x & 0x1) return 1; return 0; }
int cb_c_g_1(void) { if (gc & 0x1) return 1; return 0; }
int cb_c_p_80(char x) { if (x & 0x80) return 1; return 0; }
int cb_c_g_80(void) { if (gc & 0x80) return 1; return 0; }
int cb_c_p_10(char x) { if (x & 0x10) return 1; return 0; }
int cb_c_g_10(void) { if (gc & 0x10) return 1; return 0; }
int cb_c_p_f(char x) { if (x & 0xf) return 1; return 0; }
int cb_c_g_f(void) { if (gc & 0xf) return 1; return 0; }
int cb_c_not_80(char x) { if (!(x & 0x80)) return 1; return 0; }
int cb_c_eq0_80(char x) { if ((x & 0x80) == 0) return 1; return 0; }
int cb_c_ne0_80(char x) { if ((x & 0x80) != 0) return 1; return 0; }
int cb_c_ptr_80(char *p) { if (*p & 0x80) return 1; return 0; }
int cb_c_idx_80(char *p) { if (p[3] & 0x80) return 1; return 0; }
void cb_c_else_80(char x) { if (x & 0x80) gr = 1; else gr = 2; }
int cb_c_var(char x, char y) { if (x & y) return 1; return 0; }
int cb_uc_p_1(unsigned char x) { if (x & 0x1) return 1; return 0; }
int cb_uc_g_1(void) { if (guc & 0x1) return 1; return 0; }
int cb_uc_p_80(unsigned char x) { if (x & 0x80) return 1; return 0; }
int cb_uc_g_80(void) { if (guc & 0x80) return 1; return 0; }
int cb_uc_p_10(unsigned char x) { if (x & 0x10) return 1; return 0; }
int cb_uc_g_10(void) { if (guc & 0x10) return 1; return 0; }
int cb_uc_p_f0(unsigned char x) { if (x & 0xf0) return 1; return 0; }
int cb_uc_g_f0(void) { if (guc & 0xf0) return 1; return 0; }
int cb_uc_not_80(unsigned char x) { if (!(x & 0x80)) return 1; return 0; }
int cb_uc_eq0_80(unsigned char x) { if ((x & 0x80) == 0) return 1; return 0; }
int cb_uc_ne0_80(unsigned char x) { if ((x & 0x80) != 0) return 1; return 0; }
int cb_uc_ptr_80(unsigned char *p) { if (*p & 0x80) return 1; return 0; }
int cb_uc_idx_80(unsigned char *p) { if (p[3] & 0x80) return 1; return 0; }
void cb_uc_else_80(unsigned char x) { if (x & 0x80) gr = 1; else gr = 2; }
int cb_uc_var(unsigned char x, unsigned char y) { if (x & y) return 1; return 0; }
int cb_i_p_1(int x) { if (x & 0x1) return 1; return 0; }
int cb_i_g_1(void) { if (gi & 0x1) return 1; return 0; }
int cb_i_p_8000(int x) { if (x & 0x8000) return 1; return 0; }
int cb_i_g_8000(void) { if (gi & 0x8000) return 1; return 0; }
int cb_i_p_100(int x) { if (x & 0x100) return 1; return 0; }
int cb_i_g_100(void) { if (gi & 0x100) return 1; return 0; }
int cb_i_p_10(int x) { if (x & 0x10) return 1; return 0; }
int cb_i_g_10(void) { if (gi & 0x10) return 1; return 0; }
int cb_i_p_ff(int x) { if (x & 0xff) return 1; return 0; }
int cb_i_g_ff(void) { if (gi & 0xff) return 1; return 0; }
int cb_i_p_7ff0(int x) { if (x & 0x7ff0) return 1; return 0; }
int cb_i_g_7ff0(void) { if (gi & 0x7ff0) return 1; return 0; }
int cb_i_not_8000(int x) { if (!(x & 0x8000)) return 1; return 0; }
int cb_i_eq0_8000(int x) { if ((x & 0x8000) == 0) return 1; return 0; }
int cb_i_ne0_8000(int x) { if ((x & 0x8000) != 0) return 1; return 0; }
int cb_i_ptr_8000(int *p) { if (*p & 0x8000) return 1; return 0; }
int cb_i_idx_8000(int *p) { if (p[3] & 0x8000) return 1; return 0; }
void cb_i_else_8000(int x) { if (x & 0x8000) gr = 1; else gr = 2; }
int cb_i_var(int x, int y) { if (x & y) return 1; return 0; }
int cb_ui_p_1(unsigned int x) { if (x & 0x1) return 1; return 0; }
int cb_ui_g_1(void) { if (gui & 0x1) return 1; return 0; }
int cb_ui_p_8000(unsigned int x) { if (x & 0x8000) return 1; return 0; }
int cb_ui_g_8000(void) { if (gui & 0x8000) return 1; return 0; }
int cb_ui_p_100(unsigned int x) { if (x & 0x100) return 1; return 0; }
int cb_ui_g_100(void) { if (gui & 0x100) return 1; return 0; }
int cb_ui_p_f00(unsigned int x) { if (x & 0xf00) return 1; return 0; }
int cb_ui_g_f00(void) { if (gui & 0xf00) return 1; return 0; }
int cb_ui_not_8000(unsigned int x) { if (!(x & 0x8000)) return 1; return 0; }
int cb_ui_eq0_8000(unsigned int x) { if ((x & 0x8000) == 0) return 1; return 0; }
int cb_ui_ne0_8000(unsigned int x) { if ((x & 0x8000) != 0) return 1; return 0; }
int cb_ui_ptr_8000(unsigned int *p) { if (*p & 0x8000) return 1; return 0; }
int cb_ui_idx_8000(unsigned int *p) { if (p[3] & 0x8000) return 1; return 0; }
void cb_ui_else_8000(unsigned int x) { if (x & 0x8000) gr = 1; else gr = 2; }
int cb_ui_var(unsigned int x, unsigned int y) { if (x & y) return 1; return 0; }
int cb_l_p_1(long x) { if (x & 0x1) return 1; return 0; }
int cb_l_g_1(void) { if (gl & 0x1) return 1; return 0; }
int cb_l_p_80000000(long x) { if (x & 0x80000000) return 1; return 0; }
int cb_l_g_80000000(void) { if (gl & 0x80000000) return 1; return 0; }
int cb_l_p_10000(long x) { if (x & 0x10000) return 1; return 0; }
int cb_l_g_10000(void) { if (gl & 0x10000) return 1; return 0; }
int cb_l_p_ff00(long x) { if (x & 0xff00) return 1; return 0; }
int cb_l_g_ff00(void) { if (gl & 0xff00) return 1; return 0; }
int cb_l_not_80000000(long x) { if (!(x & 0x80000000)) return 1; return 0; }
int cb_l_eq0_80000000(long x) { if ((x & 0x80000000) == 0) return 1; return 0; }
int cb_l_ne0_80000000(long x) { if ((x & 0x80000000) != 0) return 1; return 0; }
int cb_l_ptr_80000000(long *p) { if (*p & 0x80000000) return 1; return 0; }
int cb_l_idx_80000000(long *p) { if (p[3] & 0x80000000) return 1; return 0; }
void cb_l_else_80000000(long x) { if (x & 0x80000000) gr = 1; else gr = 2; }
int cb_l_var(long x, long y) { if (x & y) return 1; return 0; }
int cb_ul_p_1(unsigned long x) { if (x & 0x1) return 1; return 0; }
int cb_ul_g_1(void) { if (gul & 0x1) return 1; return 0; }
int cb_ul_p_80000000(unsigned long x) { if (x & 0x80000000) return 1; return 0; }
int cb_ul_g_80000000(void) { if (gul & 0x80000000) return 1; return 0; }
int cb_ul_p_100(unsigned long x) { if (x & 0x100) return 1; return 0; }
int cb_ul_g_100(void) { if (gul & 0x100) return 1; return 0; }
int cb_ul_p_ffff0000(unsigned long x) { if (x & 0xffff0000) return 1; return 0; }
int cb_ul_g_ffff0000(void) { if (gul & 0xffff0000) return 1; return 0; }
int cb_ul_not_80000000(unsigned long x) { if (!(x & 0x80000000)) return 1; return 0; }
int cb_ul_eq0_80000000(unsigned long x) { if ((x & 0x80000000) == 0) return 1; return 0; }
int cb_ul_ne0_80000000(unsigned long x) { if ((x & 0x80000000) != 0) return 1; return 0; }
int cb_ul_ptr_80000000(unsigned long *p) { if (*p & 0x80000000) return 1; return 0; }
int cb_ul_idx_80000000(unsigned long *p) { if (p[3] & 0x80000000) return 1; return 0; }
void cb_ul_else_80000000(unsigned long x) { if (x & 0x80000000) gr = 1; else gr = 2; }
int cb_ul_var(unsigned long x, unsigned long y) { if (x & y) return 1; return 0; }
int cb_mem_flag(struct st *p) { if (p->flag & 0x4) return 1; return 0; }
int cb_mem_flag_g(void) { if (gps->flag & 0x4) return 1; return 0; }
int cb_mem_c(struct st *p) { if (p->c & 0x80) return 1; return 0; }
int cb_mem_l(struct st *p) { if (p->l & 0x100) return 1; return 0; }
int cb_mem_b(struct st *p) { if (p->b[3] & 0x80) return 1; return 0; }
int cb_union_c7(double x) { DU d; d.d = x; if (d.c[7] & 0x80) return 1; return 0; }
int cb_union_n0(double x) { DU d; d.d = x; if (!(d.n[0] & 0xf000)) return 1; return 0; }
int cb_loc(int a, int b) { int n; n = a + b; if (n & 1) return n; return 0; }
int cb_cast(long x) { if ((int)x & 1) return 1; return 0; }
int cb_call(int x) { if (f(x) & 0x8) return 1; return 0; }
int cb_shift(int x, int s) { if (x & (0x8000 >> s)) return 1; return 0; }
int cb_or_mask(int x) { if (x & (0x2 | 0x4)) return 1; return 0; }
int cb_and_and(int x, int y) { if ((x & 1) && y) return 1; return 0; }
int cb_and_and2(int x, int y) { if (y && (x & 0x80)) return 1; return 0; }
int cb_or_or(int x, int y) { if (y || (x & 0x6)) return 1; return 0; }
int cb_tern(int c) { return (gtab[(unsigned char)c] & 0x2) ? c - 32 : c; }
int cb_tern_char(char c) { return (gtab[(unsigned char)c] & 0x2) ? c + ('A' - 'a') : c; }
int cb_while(unsigned int x) { int n = 0; while (x & 1) { x >>= 1; n++; } return n; }
int cb_while_g(void) { int n = 0; while (gi & 0x80) { gi <<= 1; n++; } return n; }
int cb_for(int x) { int i, n = 0; for (i = 0; i < 8; i++) if (x & (1 << i)) n++; return n; }
int cb_lt_mask(unsigned int *p) { if (0x7ff0 <= (p[3] & 0x7ff0)) return 1; return 0; }
int cb_ret_val(int x) { return x & 0x80; }
int cb_ret_bool(int x) { return (x & 0x80) != 0; }
