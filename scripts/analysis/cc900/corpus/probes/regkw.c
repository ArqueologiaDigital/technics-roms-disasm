/* Does V4.23 honour the `register` keyword when it chooses which value lives in IZ / QIZ across calls?
   Each k_* function is a pair: the plain form (no keyword) and the same body with `register` on the value the
   plain form leaves in memory.  d_*: declaration order among several register locals (the 1997 library's
   __doprnt declares cnt, c, flag, width, precision all register and puts c, the second, in IZ). */
extern int g0(void);
extern void h1(int);
extern void h2(int, int);
extern int gi;

/* a is read 4 times, b twice: the plain rule homes a */
void k_plain(void) { int a, b; a = g0(); b = g0(); h1(a); h1(a); h1(b); h1(a); h1(b); h1(a); }
void k_reg_b(void) { int a; register int b; a = g0(); b = g0(); h1(a); h1(a); h1(b); h1(a); h1(b); h1(a); }
void k_reg_a(void) { register int a; int b; a = g0(); b = g0(); h1(a); h1(a); h1(b); h1(a); h1(b); h1(a); }
void k_reg_ab(void) { register int a, b; a = g0(); b = g0(); h1(a); h1(a); h1(b); h1(a); h1(b); h1(a); }
void k_reg_ba(void) { register int b, a; a = g0(); b = g0(); h1(a); h1(a); h1(b); h1(a); h1(b); h1(a); }

/* three values across calls: who gets IZ, who QIZ, who a slot */
void t_plain(void) { int a, b, c; a = g0(); b = g0(); c = g0(); h1(a); h1(b); h1(c); h1(c); h1(c); h1(b); }
void t_reg_a(void) { register int a; int b, c; a = g0(); b = g0(); c = g0(); h1(a); h1(b); h1(c); h1(c); h1(c); h1(b); }
void t_reg_all(void) { register int a, b, c; a = g0(); b = g0(); c = g0(); h1(a); h1(b); h1(c); h1(c); h1(c); h1(b); }

/* the __doprnt shape: an accumulator and a char value, all register, in a loop with calls */
int d_shape(const char *s, void (*f)(int))
{
	register int cnt; register int c; register int flag; register int width;
	cnt = 0; flag = 0; width = 0;
	while ((c = *s++) != '\0') {
		if (c == '-') { flag |= 2; continue; }
		if (c >= '0' && c <= '9') { width = width * 10 + (c - '0'); continue; }
		while (width-- > 0) { f(' '); cnt++; }
		f(c); cnt++;
		if (flag & 2) f('-');
	}
	return cnt;
}
int d_shape_plain(const char *s, void (*f)(int))
{
	int cnt; int c; int flag; int width;
	cnt = 0; flag = 0; width = 0;
	while ((c = *s++) != '\0') {
		if (c == '-') { flag |= 2; continue; }
		if (c >= '0' && c <= '9') { width = width * 10 + (c - '0'); continue; }
		while (width-- > 0) { f(' '); cnt++; }
		f(c); cnt++;
		if (flag & 2) f('-');
	}
	return cnt;
}

/* a register parameter */
void p_plain(int a, int b) { g0(); h1(b); h1(a); h1(a); h1(a); h1(b); }
void p_reg_b(int a, register int b) { g0(); h1(b); h1(a); h1(a); h1(a); h1(b); }
