/* Unary operators, increments and casts at type char. */
extern char gc1, *gpc;
char neg_c(char a) { return -a; }
char not_c(char a) { return ~a; }
int lnot_c(char a) { return !a; }
void preinc_c(void) { ++gc1; }
void postdec_c(void) { gc1--; }
char preinc_val_c(void) { return ++gc1; }
char postinc_val_c(void) { return gc1++; }
char deref_inc_c(void) { return *gpc++; }
unsigned char cast_c_uc(char a) { return (unsigned char)a; }
int cast_c_i(char a) { return (int)a; }
unsigned int cast_c_ui(char a) { return (unsigned int)a; }
long cast_c_l(char a) { return (long)a; }
unsigned long cast_c_ul(char a) { return (unsigned long)a; }
