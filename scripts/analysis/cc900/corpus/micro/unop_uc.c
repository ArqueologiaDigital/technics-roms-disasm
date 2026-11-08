/* Unary operators, increments and casts at type unsigned char. */
extern unsigned char guc1, *gpuc;
unsigned char neg_uc(unsigned char a) { return -a; }
unsigned char not_uc(unsigned char a) { return ~a; }
int lnot_uc(unsigned char a) { return !a; }
void preinc_uc(void) { ++guc1; }
void postdec_uc(void) { guc1--; }
unsigned char preinc_val_uc(void) { return ++guc1; }
unsigned char postinc_val_uc(void) { return guc1++; }
unsigned char deref_inc_uc(void) { return *gpuc++; }
char cast_uc_c(unsigned char a) { return (char)a; }
int cast_uc_i(unsigned char a) { return (int)a; }
unsigned int cast_uc_ui(unsigned char a) { return (unsigned int)a; }
long cast_uc_l(unsigned char a) { return (long)a; }
unsigned long cast_uc_ul(unsigned char a) { return (unsigned long)a; }
