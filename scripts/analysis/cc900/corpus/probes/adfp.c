/* Where do float and double parameters go under the adecl convention (-Xr), and does one use up a register
   position?  Callee side (the parameter's place) and caller side (the argument's place). */
extern int gi; extern double gd; extern float gf;
extern void t_di(double, int), t_id(int, double), t_idi(int, double, int), t_iid(int, int, double);
extern void t_fi(float, int), t_if(int, float), t_ifi(int, float, int), t_iiif(int, int, int, float);
int ad_d(double x) { return x > 0.0; }
int ad_di(double x, int a) { return a + (x > 0.0); }
int ad_id(int a, double x) { return a + (x > 0.0); }
int ad_idi(int a, double x, int b) { return a + b + (x > 0.0); }
int ad_iid(int a, int b, double x) { return a + b + (x > 0.0); }
int ad_fi(float x, int a) { return a + (x > 0.0f); }
int ad_ifi(int a, float x, int b) { return a + b + (x > 0.0f); }
void ac_di(void) { t_di(gd, gi); }
void ac_id(void) { t_id(gi, gd); }
void ac_idi(void) { t_idi(gi, gd, 3); }
void ac_iid(void) { t_iid(gi, 2, gd); }
void ac_fi(void) { t_fi(gf, gi); }
void ac_if(void) { t_if(gi, gf); }
void ac_ifi(void) { t_ifi(gi, gf, 3); }
void ac_iiif(void) { t_iiif(1, 2, 3, gf); }
