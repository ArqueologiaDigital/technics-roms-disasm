/* Parameters kept in registers by -O: in which order are they loaded? */
extern int gi;
void op_cpy_ab(char *a, char *b, int n) { while (n--) *a++ = *b++; }
void op_cpy_ba(char *a, char *b, int n) { while (n--) *b++ = *a++; }
void op_cpy_nab(int n, char *a, char *b) { while (n--) *a++ = *b++; }
void op_cpy_anb(char *a, int n, char *b) { while (n--) *a++ = *b++; }
int op_cmp_ab(char *a, char *b, int n) { while (n && *a == *b) { a++; b++; n--; } return n; }
int op_cmp_ba(char *a, char *b, int n) { while (n && *b == *a) { b++; a++; n--; } return n; }
int op_sum2(int *p, int *q, int n) { int s = 0; while (n--) s += *p++ + *q++; return s; }
int op_sum2q(int *p, int *q, int n) { int s = 0; while (n--) s += *q++ + *p++; return s; }
void op_fill(char *a, int n, char c) { while (n--) *a++ = c; }
void op_fill2(char c, int n, char *a) { while (n--) *a++ = c; }
int op_two(char *a, char *b) { while (*a == *b && *a) { a++; b++; } return *a - *b; }
int op_two_ba(char *a, char *b) { while (*b == *a && *b) { b++; a++; } return *b - *a; }
void op_cat(char *a, char *b, int n) { while (*a) a++; while (n--) *a++ = *b++; }
void op_cat2(char *a, int n, char *b) { while (*a) a++; while (n--) *a++ = *b++; }
void op_cat3(char *a, char *b, int n) { while (*a) a++; while (n-- && *b) *a++ = *b++; }
void op_cat4(char *a, char *b, int n) { while (*a) a++; while (*b && n--) *a++ = *b++; }
void op_cat_b(char *a, char *b, int n) { while (*b) b++; while (n--) *b++ = *a++; }
void op_two_loops(char *a, char *b) { while (*a) a++; while (*b) b++; *a = *b; }
void op_three(char *d, char *s, char *t, int n) { while (n--) *d++ = *s++ + *t++; }
void op_three2(char *s, char *t, char *d, int n) { while (n--) *d++ = *s++ + *t++; }
int op_heavy_a(char *a, char *b, int n) { int s = 0; while (n--) { s += *a; s += a[1]; a++; b++; } return s; }
int op_heavy_b(char *a, char *b, int n) { int s = 0; while (n--) { s += *b; s += b[1]; a++; b++; } return s; }
char *op_ret_a(char *a, char *b, int n) { char *r = a; while (n--) *a++ = *b++; return r; }
char *op_ret_b(char *a, char *b, int n) { char *r = b; while (n--) *a++ = *b++; return r; }
