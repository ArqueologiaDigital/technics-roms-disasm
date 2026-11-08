/* Unary operators, increments and casts at type long. */
extern long gl1, *gpl;
long neg_l(long a) { return -a; }
long not_l(long a) { return ~a; }
int lnot_l(long a) { return !a; }
void preinc_l(void) { ++gl1; }
void postdec_l(void) { gl1--; }
long preinc_val_l(void) { return ++gl1; }
long postinc_val_l(void) { return gl1++; }
long deref_inc_l(void) { return *gpl++; }
char cast_l_c(long a) { return (char)a; }
unsigned char cast_l_uc(long a) { return (unsigned char)a; }
int cast_l_i(long a) { return (int)a; }
unsigned int cast_l_ui(long a) { return (unsigned int)a; }
unsigned long cast_l_ul(long a) { return (unsigned long)a; }
