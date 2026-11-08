/* How are variadic arguments passed and read? */
#include <stdarg.h>
extern int v_print(const char *, ...);
extern char gc; extern int gi; extern long gl; extern double gd;
void v_call(void) { v_print("x", gc, gi, gl, gd); }
int v_sum(int n, ...) { va_list ap; int s = 0; va_start(ap, n); while (n--) s += va_arg(ap, int); va_end(ap); return s; }
long v_long(int n, ...) { va_list ap; long r; va_start(ap, n); r = va_arg(ap, long); va_end(ap); return r; }
