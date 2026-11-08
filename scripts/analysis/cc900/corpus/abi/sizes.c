/* What are the sizes and alignments of the basic types, and how are struct members laid out? */
struct s_c  { char a; };
struct s_ci { char a; int b; };
struct s_cl { char a; long b; };
struct s_cp { char a; char *b; };
struct s_cf { char a; float b; };
struct s_cd { char a; double b; };
struct s_cs { char a; short b; };
struct s_cc { char a; char b; char c; };
struct s_lc { long a; char b; };
int sz_char = sizeof(char), sz_short = sizeof(short), sz_int = sizeof(int), sz_long = sizeof(long);
int sz_ptr = sizeof(char *), sz_fptr = sizeof(void (*)(void)), sz_float = sizeof(float), sz_double = sizeof(double);
int sz_ldouble = sizeof(long double);
int sz_s_c = sizeof(struct s_c), sz_s_ci = sizeof(struct s_ci), sz_s_cl = sizeof(struct s_cl);
int sz_s_cp = sizeof(struct s_cp), sz_s_cf = sizeof(struct s_cf), sz_s_cd = sizeof(struct s_cd);
int sz_s_cs = sizeof(struct s_cs), sz_s_cc = sizeof(struct s_cc), sz_s_lc = sizeof(struct s_lc);
int off_ci = (int)&((struct s_ci *)0)->b, off_cl = (int)&((struct s_cl *)0)->b, off_cd = (int)&((struct s_cd *)0)->b;
char g_c1 = 1; int g_i = 2; char g_c2 = 3; long g_l = 4; char g_c3 = 5; double g_d = 6.0;
char signed_char_test = (char)0x80 < 0;
