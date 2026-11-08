/* Unary operators, increments and casts at type unsigned int. */
extern unsigned int gui1, *gpui;
unsigned int neg_ui(unsigned int a) { return -a; }
unsigned int not_ui(unsigned int a) { return ~a; }
int lnot_ui(unsigned int a) { return !a; }
void preinc_ui(void) { ++gui1; }
void postdec_ui(void) { gui1--; }
unsigned int preinc_val_ui(void) { return ++gui1; }
unsigned int postinc_val_ui(void) { return gui1++; }
unsigned int deref_inc_ui(void) { return *gpui++; }
char cast_ui_c(unsigned int a) { return (char)a; }
unsigned char cast_ui_uc(unsigned int a) { return (unsigned char)a; }
int cast_ui_i(unsigned int a) { return (int)a; }
long cast_ui_l(unsigned int a) { return (long)a; }
unsigned long cast_ui_ul(unsigned int a) { return (unsigned long)a; }
