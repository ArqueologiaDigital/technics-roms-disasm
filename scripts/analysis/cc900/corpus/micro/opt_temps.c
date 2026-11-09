/* -O3 -XS -Xr leaf loops: the register family of the temporaries */
extern int gi; extern char gc;
void ot_cpy_abn(char *a, char *b, int n) { while (n--) *a++ = *b++; }
void ot_cpy_anb(char *a, int n, char *b) { while (n--) *a++ = *b++; }
void ot_cpy_ban(char *b, char *a, int n) { while (n--) *a++ = *b++; }
void ot_cpy_bna(char *b, int n, char *a) { while (n--) *a++ = *b++; }
void ot_cpy_nab(int n, char *a, char *b) { while (n--) *a++ = *b++; }
void ot_cpy_nba(int n, char *b, char *a) { while (n--) *a++ = *b++; }
int ot_cmp_abn(char *a, char *b, int n) { while (n && *a == *b) { a++; b++; n--; } return n; }
int ot_cmp_anb(char *a, int n, char *b) { while (n && *a == *b) { a++; b++; n--; } return n; }
int ot_cmp_ban(char *b, char *a, int n) { while (n && *a == *b) { a++; b++; n--; } return n; }
int ot_cmp_bna(char *b, int n, char *a) { while (n && *a == *b) { a++; b++; n--; } return n; }
int ot_cmp_nab(int n, char *a, char *b) { while (n && *a == *b) { a++; b++; n--; } return n; }
int ot_cmp_nba(int n, char *b, char *a) { while (n && *a == *b) { a++; b++; n--; } return n; }
void ot_add_abn(char *a, char *b, int n) { while (n--) *a++ += *b++; }
void ot_add_anb(char *a, int n, char *b) { while (n--) *a++ += *b++; }
void ot_add_ban(char *b, char *a, int n) { while (n--) *a++ += *b++; }
void ot_add_bna(char *b, int n, char *a) { while (n--) *a++ += *b++; }
void ot_add_nab(int n, char *a, char *b) { while (n--) *a++ += *b++; }
void ot_add_nba(int n, char *b, char *a) { while (n--) *a++ += *b++; }
int ot_sum_abn(char *a, char *b, int n) { int s = 0; while (n--) s += *a++ - *b++; return s; }
int ot_sum_anb(char *a, int n, char *b) { int s = 0; while (n--) s += *a++ - *b++; return s; }
int ot_sum_ban(char *b, char *a, int n) { int s = 0; while (n--) s += *a++ - *b++; return s; }
int ot_sum_bna(char *b, int n, char *a) { int s = 0; while (n--) s += *a++ - *b++; return s; }
int ot_sum_nab(int n, char *a, char *b) { int s = 0; while (n--) s += *a++ - *b++; return s; }
int ot_sum_nba(int n, char *b, char *a) { int s = 0; while (n--) s += *a++ - *b++; return s; }
void ot_cnt_abn(char *a, char *b, int n) { while (n--) { a++; b++; } gc = *a + *b; }
void ot_cnt_anb(char *a, int n, char *b) { while (n--) { a++; b++; } gc = *a + *b; }
void ot_cnt_ban(char *b, char *a, int n) { while (n--) { a++; b++; } gc = *a + *b; }
void ot_cnt_bna(char *b, int n, char *a) { while (n--) { a++; b++; } gc = *a + *b; }
void ot_cnt_nab(int n, char *a, char *b) { while (n--) { a++; b++; } gc = *a + *b; }
void ot_cnt_nba(int n, char *b, char *a) { while (n--) { a++; b++; } gc = *a + *b; }
void ot_fill_acn(char *a, char c, int n) { while (n--) *a++ = c; }
void ot_fill_anc(char *a, int n, char c) { while (n--) *a++ = c; }
void ot_fill_can(char c, char *a, int n) { while (n--) *a++ = c; }
void ot_fill_nac(int n, char *a, char c) { while (n--) *a++ = c; }
void ot_one_an(char *a, int n) { while (n--) *a++ = 0; }
void ot_one_na(int n, char *a) { while (n--) *a++ = 0; }
int ot_len(char *a) { int n = 0; while (*a++) n++; return n; }
int ot_len2(char *a, char *b) { int n = 0; while (*a++ == *b++) n++; return n; }
