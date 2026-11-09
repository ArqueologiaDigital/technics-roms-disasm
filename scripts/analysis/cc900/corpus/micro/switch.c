/* Switch statements with statement bodies. */
extern void f0(void); extern void f1(int); extern int g1(int); extern int gi; extern long gl;
void sw_jt6(int x) { switch (x) { case 0: f1(10); break; case 1: f1(11); break; case 2: f1(12); break; case 3: f1(13); break; case 4: f1(14); break; case 5: f1(15); break; } }
void sw_jt6d(int x) { switch (x) { case 0: f1(10); break; case 1: f1(11); break; case 2: f1(12); break; case 3: f1(13); break; case 4: f1(14); break; case 5: f1(15); break; default: f0(); break; } }
void sw_jt3(int x) { switch (x) { case 0: f1(1); break; case 1: f1(2); break; case 2: f1(3); break; } }
void sw_jt4(int x) { switch (x) { case 0: f1(1); break; case 1: f1(2); break; case 2: f1(3); break; case 3: f1(4); break; } }
void sw_jt8(int x) { switch (x) { case 0: f0(); break; case 1: f1(1); break; case 2: f1(2); break; case 3: f1(3); break; case 4: f1(4); break; case 5: f1(5); break; case 6: f1(6); break; case 7: f1(7); break; } }
void sw_jtoff(int x) { switch (x) { case 10: f1(1); break; case 11: f1(2); break; case 12: f1(3); break; case 13: f1(4); break; case 14: f1(5); break; case 15: f1(6); break; } }
void sw_jthole(int x) { switch (x) { case 0: f1(1); break; case 1: f1(2); break; case 3: f1(3); break; case 4: f1(4); break; case 6: f1(5); break; case 7: f1(6); break; } }
void sw_jtu(unsigned int x) { switch (x) { case 0: f1(10); break; case 1: f1(11); break; case 2: f1(12); break; case 3: f1(13); break; case 4: f1(14); break; case 5: f1(15); break; } }
void sw_jtc(char x) { switch (x) { case 0: f1(10); break; case 1: f1(11); break; case 2: f1(12); break; case 3: f1(13); break; case 4: f1(14); break; case 5: f1(15); break; } }
void sw_jtuc(unsigned char x) { switch (x) { case 0: f1(10); break; case 1: f1(11); break; case 2: f1(12); break; case 3: f1(13); break; case 4: f1(14); break; case 5: f1(15); break; } }
void sw_jtl(long x) { switch (x) { case 0: f1(10); break; case 1: f1(11); break; case 2: f1(12); break; case 3: f1(13); break; case 4: f1(14); break; case 5: f1(15); break; } }
void sw_jtlu(unsigned long x) { switch (x) { case 0: f1(10); break; case 1: f1(11); break; case 2: f1(12); break; case 3: f1(13); break; case 4: f1(14); break; case 5: f1(15); break; } }
void sw_jtg(void) { switch (gi) { case 0: f1(10); break; case 1: f1(11); break; case 2: f1(12); break; case 3: f1(13); break; case 4: f1(14); break; case 5: f1(15); break; } }
void sw_jtgl(void) { switch (gl) { case 0: f1(10); break; case 1: f1(11); break; case 2: f1(12); break; case 3: f1(13); break; case 4: f1(14); break; case 5: f1(15); break; } }
void sw_fall(int x) { switch (x) { case 0: f0(); case 1: f1(1); break; case 2: case 3: f1(2); break; case 4: f1(4); case 5: f1(5); break; } }
int sw_ret(int x) { switch (x) { case 0: return g1(1); case 1: return g1(2); case 2: return g1(3); case 3: return g1(4); case 4: return g1(5); case 5: return g1(6); } return 0; }
int sw_local(int x) { int r = 0; switch (x) { case 0: r = 5; break; case 1: r = gi; break; case 2: r = g1(x); break; case 3: r = x + 1; break; case 4: r = -1; break; case 5: r = 7; break; } return r; }
void sw_sparse(int x) { switch (x) { case 1: f1(1); break; case 100: f1(2); break; case 1000: f1(3); break; case 30000: f1(4); break; } }
void sw_mixed(int x) { switch (x) { case 0: f1(0); break; case 1: f1(1); break; case 2: f1(2); break; case 3: f1(3); break; case 4: f1(4); break; case 100: f1(100); break; case 200: f1(200); break; } }
void sw_two(int x) { switch (x) { case 0: f1(1); break; case 1: f1(2); break; } }
void sw_one(int x) { switch (x) { case 7: f0(); break; } }
void sw_neg(int x) { switch (x) { case -2: f1(1); break; case -1: f1(2); break; case 0: f1(3); break; case 1: f1(4); break; case 2: f1(5); break; case 3: f1(6); break; } }
void sw_loop(int n) { int i; for (i = 0; i < n; i++) { switch (i) { case 0: f1(10); break; case 1: f1(11); break; case 2: f1(12); break; case 3: f1(13); break; case 4: f1(14); break; case 5: f1(15); break; } } }
int sw_ev(int obj, long ev, long par) { switch (ev) { case 0x1001: f1(obj); break; case 0x1002: f0(); break; case 0x2000: case 0x2001: case 0x2002: case 0x2003: case 0x2004: case 0x2005: f1((int)(ev - 0x2000)); break; default: return 0; } return 1; }
int sw_evtab(int obj, long ev, long par) { switch (ev) { case 0x2000: f1(obj); break; case 0x2001: f0(); break; case 0x2002: f1(2); break; case 0x2003: f1(3); break; case 0x2004: gi = obj; break; case 0x2005: gl = par; break; default: return g1(obj); } return 1; }
