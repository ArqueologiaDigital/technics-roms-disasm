/* Char indexes: how V4.23 computes an element address or a pointer sum whose index is a char (signed and
   unsigned), for every element size and base kind.  The random corpus showed three different forms (byte
   arithmetic with an 8-bit index register, 16-bit scaling zero-extended, the low byte of a 16-bit offset);
   this probe separates them.  c = signed char, u = unsigned char; element sizes 1 / 2 / 4; bases: a sized global
   array, an unsized global array, a global pointer, a pointer parameter, a pointer member, a member array. */
struct st { int a[6]; char b[8]; long l[3]; int *q; };
extern char gca[10]; extern int gia[10]; extern long gla[10];
extern char xca[]; extern int xia[];
extern char *gp; extern int *gpi; extern long *gpl;
extern struct st gs, *gps;
extern int gi; extern char gc; extern long gl;

/* reads */
int rc1(char c) { return gca[c]; }
int rc2(char c) { return gia[c]; }
long rc4(char c) { return gla[c]; }
int ru1(unsigned char u) { return gca[u]; }
int ru2(unsigned char u) { return gia[u]; }
long ru4(unsigned char u) { return gla[u]; }
int xc1(char c) { return xca[c]; }
int xc2(char c) { return xia[c]; }
int xu2(unsigned char u) { return xia[u]; }
int pc1(char c) { return gp[c]; }
int pc2(char c) { return gpi[c]; }
long pc4(char c) { return gpl[c]; }
int pu2(unsigned char u) { return gpi[u]; }
int qc1(char *p, char c) { return p[c]; }
int qc2(int *p, char c) { return p[c]; }
long qc4(long *p, char c) { return p[c]; }
int qu2(int *p, unsigned char u) { return p[u]; }
int mc2(char c) { return gs.a[c]; }
int mc1(char c) { return gs.b[c]; }
int mu2(unsigned char u) { return gs.a[u]; }
int nc2(char c) { return gps->a[c]; }
int nu2(unsigned char u) { return gps->a[u]; }
int oc2(struct st *s, char c) { return s->a[c]; }
int ou2(struct st *s, unsigned char u) { return s->a[u]; }
long oc4(struct st *s, char c) { return s->l[c]; }
/* stores */
void sc1(char c) { gca[c] = 1; }
void sc2(char c) { gia[c] = 1; }
void su2(unsigned char u) { gia[u] = 1; }
void sc4(char c) { gla[c] = 1; }
void tc2(int *p, char c) { p[c] = 1; }
void tu2(int *p, unsigned char u) { p[u] = 1; }
void vc2(char c) { gia[c] = gi; }
/* pointer sums and differences */
int *ac2(char c) { return gpi + c; }
char *ac1(char c) { return gp + c; }
long *ac4(char c) { return gpl + c; }
int *au2(unsigned char u) { return gpi + u; }
int *bc2(int *p, char c) { return p + c; }
int *bu2(int *p, unsigned char u) { return p + u; }
int *dc2(char c) { return gpi - c; }
char *ec1(char c) { return &gca[c]; }
int *ec2(char c) { return &gia[c]; }
int *eu2(unsigned char u) { return &gia[u]; }
/* the index as an expression of a char */
int fc2(char c) { return gia[c + 1]; }
int fu2(unsigned char u) { return gia[u * 2]; }
int gc2(char c, char d) { return gia[c + d]; }
int hc2(char c) { return gia[(unsigned char)c]; }
int hi2(int i) { return gia[(char)i]; }
/* compound assignment through a char index */
void kc2(char c) { gia[c] += 3; }
void ku2(unsigned char u) { gia[u] ^= gi; }
void lc1(char c) { gca[c]++; }
