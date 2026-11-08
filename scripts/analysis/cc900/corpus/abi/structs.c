/* How are structs passed by value, copied and assigned? */
struct pair { int a; int b; };
struct big { long a, b, c, d; };
extern struct pair gpair; extern struct big gbig;
extern void t_pair(struct pair); extern void t_big(struct big);
int s_pair(struct pair p) { return p.b; }
long s_big(struct big b) { return b.d; }
void s_pass_pair(void) { t_pair(gpair); }
void s_pass_big(void) { t_big(gbig); }
void s_copy(struct big *d, struct big *s) { *d = *s; }
