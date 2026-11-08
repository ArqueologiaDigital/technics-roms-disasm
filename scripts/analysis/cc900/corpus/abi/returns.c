/* Which register (or memory) carries a function result, by type? */
struct pair { int a; int b; };
struct big { long a, b, c, d; };
extern char gc; extern int gi; extern long gl; extern char *gp; extern float gf; extern double gd;
extern struct pair gpair; extern struct big gbig;
char   r_c(void) { return gc; }
int    r_i(void) { return gi; }
long   r_l(void) { return gl; }
char  *r_p(void) { return gp; }
float  r_f(void) { return gf; }
double r_d(void) { return gd; }
struct pair r_pair(void) { return gpair; }
struct big  r_big(void) { return gbig; }
extern char x_c(void); extern int x_i(void); extern long x_l(void); extern double x_d(void);
extern struct pair x_pair(void);
void use_c(void) { gc = x_c(); }
void use_i(void) { gi = x_i(); }
void use_l(void) { gl = x_l(); }
void use_d(void) { gd = x_d(); }
void use_pair(void) { gpair = x_pair(); }
