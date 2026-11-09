/* Counted loops: counter, bound, base and offset registers */
extern int gia[10]; extern char gca[10]; extern long gla[10]; extern int gi;
int oc_sum_pn(int *p, int n) { int s = 0; int i; for (i = 0; i < n; i++) s += p[i]; return s; }
int oc_sum_np(int n, int *p) { int s = 0; int i; for (i = 0; i < n; i++) s += p[i]; return s; }
void oc_cpy_abn(char *a, char *b, int n) { int i; for (i = 0; i < n; i++) a[i] = b[i]; }
void oc_cpy_anb(char *a, int n, char *b) { int i; for (i = 0; i < n; i++) a[i] = b[i]; }
void oc_cpy_ban(char *b, char *a, int n) { int i; for (i = 0; i < n; i++) a[i] = b[i]; }
void oc_cpy_bna(char *b, int n, char *a) { int i; for (i = 0; i < n; i++) a[i] = b[i]; }
void oc_cpy_nab(int n, char *a, char *b) { int i; for (i = 0; i < n; i++) a[i] = b[i]; }
void oc_cpy_nba(int n, char *b, char *a) { int i; for (i = 0; i < n; i++) a[i] = b[i]; }
int oc_find_pnk(int *p, int n, int k) { int i; for (i = 0; i < n; i++) if (p[i] == k) return i; return -1; }
int oc_find_pkn(int *p, int k, int n) { int i; for (i = 0; i < n; i++) if (p[i] == k) return i; return -1; }
int oc_find_npk(int n, int *p, int k) { int i; for (i = 0; i < n; i++) if (p[i] == k) return i; return -1; }
int oc_find_nkp(int n, int k, int *p) { int i; for (i = 0; i < n; i++) if (p[i] == k) return i; return -1; }
int oc_find_kpn(int k, int *p, int n) { int i; for (i = 0; i < n; i++) if (p[i] == k) return i; return -1; }
int oc_find_knp(int k, int n, int *p) { int i; for (i = 0; i < n; i++) if (p[i] == k) return i; return -1; }
void oc_clr_i(int *p, int n) { int i; for (i = 0; i < n; i++) p[i] = 0; }
void oc_clr_c(char *p, int n) { int i; for (i = 0; i < n; i++) p[i] = 0; }
void oc_clr_l(long *p, int n) { int i; for (i = 0; i < n; i++) p[i] = 0; }
long oc_sum_l(long *p, int n) { long s = 0; int i; for (i = 0; i < n; i++) s += p[i]; return s; }
int oc_sum_c(char *p, int n) { int s = 0; int i; for (i = 0; i < n; i++) s += p[i]; return s; }
int oc_sum2(int *p, int *q, int n) { int s = 0; int i; for (i = 0; i < n; i++) s += p[i] * q[i]; return s; }
void oc_add2(int *p, int *q, int n) { int i; for (i = 0; i < n; i++) p[i] += q[i]; }
int oc_sum_i_first(int *p, int n) { int i; int s = 0; for (i = 0; i < n; i++) s += p[i]; return s; }
int oc_sum_g(int n) { int s = 0; int i; for (i = 0; i < n; i++) s += gia[i]; return s; }
int oc_sum_gk(void) { int s = 0; int i; for (i = 0; i < 10; i++) s += gia[i]; return s; }
void oc_cpy_g(char *a) { int i; for (i = 0; i < 10; i++) a[i] = gca[i]; }
int oc_down(int *p, int n) { int s = 0; int i; for (i = n - 1; i >= 0; i--) s += p[i]; return s; }
int oc_down2(int *p, int n) { int s = 0; for (; n > 0; n--) s += p[n - 1]; return s; }
int oc_cnt_c(char *p, int n, char c) { int k = 0; int i; for (i = 0; i < n; i++) if (p[i] == c) k++; return k; }
int oc_max(int *p, int n) { int m = p[0]; int i; for (i = 1; i < n; i++) if (p[i] > m) m = p[i]; return m; }
void oc_fill_i(int *p, int n, int v) { int i; for (i = 0; i < n; i++) p[i] = v; }
void oc_idx(int *p, int n) { int i; for (i = 0; i < n; i++) p[i] = i; }
int oc_nested(int *p, int n, int m) { int s = 0; int i, j; for (i = 0; i < n; i++) for (j = 0; j < m; j++) s += p[j]; return s; }
