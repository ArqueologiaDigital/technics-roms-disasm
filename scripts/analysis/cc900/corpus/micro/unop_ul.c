/* Unary operators, increments and casts at type unsigned long. */
extern unsigned long gul1, *gpul;
unsigned long neg_ul(unsigned long a) { return -a; }
unsigned long not_ul(unsigned long a) { return ~a; }
int lnot_ul(unsigned long a) { return !a; }
void preinc_ul(void) { ++gul1; }
void postdec_ul(void) { gul1--; }
unsigned long preinc_val_ul(void) { return ++gul1; }
unsigned long postinc_val_ul(void) { return gul1++; }
unsigned long deref_inc_ul(void) { return *gpul++; }
char cast_ul_c(unsigned long a) { return (char)a; }
unsigned char cast_ul_uc(unsigned long a) { return (unsigned char)a; }
int cast_ul_i(unsigned long a) { return (int)a; }
unsigned int cast_ul_ui(unsigned long a) { return (unsigned int)a; }
long cast_ul_l(unsigned long a) { return (long)a; }
