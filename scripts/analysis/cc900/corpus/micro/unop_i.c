/* Unary operators, increments and casts at type int. */
extern int gi1, *gpi;
int neg_i(int a) { return -a; }
int not_i(int a) { return ~a; }
int lnot_i(int a) { return !a; }
void preinc_i(void) { ++gi1; }
void postdec_i(void) { gi1--; }
int preinc_val_i(void) { return ++gi1; }
int postinc_val_i(void) { return gi1++; }
int deref_inc_i(void) { return *gpi++; }
char cast_i_c(int a) { return (char)a; }
unsigned char cast_i_uc(int a) { return (unsigned char)a; }
unsigned int cast_i_ui(int a) { return (unsigned int)a; }
long cast_i_l(int a) { return (long)a; }
unsigned long cast_i_ul(int a) { return (unsigned long)a; }
