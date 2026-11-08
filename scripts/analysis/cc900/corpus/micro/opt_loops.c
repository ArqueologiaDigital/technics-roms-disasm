/* -O3 loops: what is hoisted, which induction variables appear, where the bound lives. */
extern int ga[10], gb[10]; extern char gca[10]; extern long gla[10]; extern int gn; extern int *gp;
int ol_i_acc1(int k) { int i; int s0; s0 = 0; for (i = 0; i < k; i++) { s0 += ga[i]; } return s0; }
int ol_i_acc2(int k) { int i; int s0, s1; s0 = 0; s1 = 0; for (i = 0; i < k; i++) { s0 += ga[i]; s1 += ga[i]; } return s0 + s1; }
int ol_i_acc3(int k) { int i; int s0, s1, s2; s0 = 0; s1 = 0; s2 = 0; for (i = 0; i < k; i++) { s0 += ga[i]; s1 += ga[i]; s2 += ga[i]; } return s0 + s1 + s2; }
int ol_i_const(void) { int i; int s = 0; for (i = 0; i < 10; i++) s += ga[i]; return s; }
int ol_i_glob(void) { int i; int s = 0; for (i = 0; i < gn; i++) s += ga[i]; return s; }
void ol_i_clear(int k) { int i; for (i = 0; i < k; i++) ga[i] = 0; }
void ol_i_copy(int k) { int i; for (i = 0; i < k; i++) gb[i] = (int)ga[i]; }
long ol_l_acc1(int k) { int i; long s0; s0 = 0; for (i = 0; i < k; i++) { s0 += gla[i]; } return s0; }
long ol_l_acc2(int k) { int i; long s0, s1; s0 = 0; s1 = 0; for (i = 0; i < k; i++) { s0 += gla[i]; s1 += gla[i]; } return s0 + s1; }
long ol_l_acc3(int k) { int i; long s0, s1, s2; s0 = 0; s1 = 0; s2 = 0; for (i = 0; i < k; i++) { s0 += gla[i]; s1 += gla[i]; s2 += gla[i]; } return s0 + s1 + s2; }
long ol_l_const(void) { int i; long s = 0; for (i = 0; i < 10; i++) s += gla[i]; return s; }
long ol_l_glob(void) { int i; long s = 0; for (i = 0; i < gn; i++) s += gla[i]; return s; }
void ol_l_clear(int k) { int i; for (i = 0; i < k; i++) gla[i] = 0; }
void ol_l_copy(int k) { int i; for (i = 0; i < k; i++) gb[i] = (int)gla[i]; }
char ol_c_acc1(int k) { int i; char s0; s0 = 0; for (i = 0; i < k; i++) { s0 += gca[i]; } return s0; }
char ol_c_acc2(int k) { int i; char s0, s1; s0 = 0; s1 = 0; for (i = 0; i < k; i++) { s0 += gca[i]; s1 += gca[i]; } return s0 + s1; }
char ol_c_acc3(int k) { int i; char s0, s1, s2; s0 = 0; s1 = 0; s2 = 0; for (i = 0; i < k; i++) { s0 += gca[i]; s1 += gca[i]; s2 += gca[i]; } return s0 + s1 + s2; }
char ol_c_const(void) { int i; char s = 0; for (i = 0; i < 10; i++) s += gca[i]; return s; }
char ol_c_glob(void) { int i; char s = 0; for (i = 0; i < gn; i++) s += gca[i]; return s; }
void ol_c_clear(int k) { int i; for (i = 0; i < k; i++) gca[i] = 0; }
void ol_c_copy(int k) { int i; for (i = 0; i < k; i++) gb[i] = (int)gca[i]; }
int ol_idx_use(int k) { int i, s = 0; for (i = 0; i < k; i++) s += ga[i] * i; return s; }
int ol_two_arr(int k) { int i, s = 0; for (i = 0; i < k; i++) s += ga[i] + gb[i]; return s; }
int ol_ptr(int *p, int k) { int i, s = 0; for (i = 0; i < k; i++) s += p[i]; return s; }
int ol_ptr_walk(int *p, int k) { int s = 0; while (k--) s += *p++; return s; }
int ol_gptr(int k) { int i, s = 0; for (i = 0; i < k; i++) s += gp[i]; return s; }
void ol_down(int k) { int i; for (i = k; i > 0; i--) ga[i] = 0; }
void ol_while(int k) { int i = 0; while (i < k) { ga[i] = i; i++; } }
void ol_do(int k) { int i = 0; do { ga[i] = 0; i++; } while (i < k); }
int ol_nested(int k) { int i, j, s = 0; for (i = 0; i < k; i++) for (j = 0; j < k; j++) s += ga[j]; return s; }
int ol_inv(int k, int a, int b) { int i, s = 0; for (i = 0; i < k; i++) s += a * b; return s; }
void ol_strcpy(char *d, char *s) { while ((*d++ = *s++) != 0) ; }
int ol_strlen(char *s) { int n = 0; while (*s++) n++; return n; }
