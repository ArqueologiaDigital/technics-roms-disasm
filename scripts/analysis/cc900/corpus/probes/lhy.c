/* Long helpers with an element at an int or char index (gen_lhy.py).  t: l long, n unsigned long; op: d /, m %,
   x *.  lyi_<t>_<op>_<I><O><g><shape>: the index has type I (i int, c char) and origin O (P the parameter c, T a
   local initialised from a global); g: n plain, g under if (divisor != 0), as the random corpora guard a division.
   shapes: G gv = vv op va[i]; X gv = va[i] op vv; E ga[i] = vv op wa[i]; Z ga[i] = ga[i] op vv;
   Y ga[i] = vv op ga[i]; K gv = va[i] op 7; J gv = 7 op va[i]; S ga[i] = ga[i] op 7; C ga[2] = va[i] op vv;
   D ga[2] = vv op va[i]; R return va[i] op vv.  lhx.c already asks c with G X E Z, plain: left out here. */
extern char gcc; extern int gi;
extern long gl, vl, wl, gla[8], vla[8], wla[8];
extern unsigned long gn, vn, wn, gna[8], vna[8], wna[8];

void lyi_l_d_iPnG(int c) { gl = vl / vla[c]; }
void lyi_l_d_iPnX(int c) { gl = vla[c] / vl; }
void lyi_l_d_iPnE(int c) { gla[c] = vl / wla[c]; }
void lyi_l_d_iPnZ(int c) { gla[c] = gla[c] / vl; }
void lyi_l_d_iPnY(int c) { gla[c] = vl / gla[c]; }
void lyi_l_d_iPnK(int c) { gl = vla[c] / 7; }
void lyi_l_d_iPnJ(int c) { gl = 7 / vla[c]; }
void lyi_l_d_iPnS(int c) { gla[c] = gla[c] / 7; }
void lyi_l_d_iPnC(int c) { gla[2] = vla[c] / vl; }
void lyi_l_d_iPnD(int c) { gla[2] = vl / vla[c]; }
long lyi_l_d_iPnR(int c) { return vla[c] / vl; }
void lyi_l_d_iPgG(int c) { if (vla[c] != 0) gl = vl / vla[c]; }
void lyi_l_d_iPgX(int c) { if (vl != 0) gl = vla[c] / vl; }
void lyi_l_d_iPgE(int c) { if (wla[c] != 0) gla[c] = vl / wla[c]; }
void lyi_l_d_iPgZ(int c) { if (vl != 0) gla[c] = gla[c] / vl; }
void lyi_l_d_iPgY(int c) { if (gla[c] != 0) gla[c] = vl / gla[c]; }
void lyi_l_d_iPgJ(int c) { if (vla[c] != 0) gl = 7 / vla[c]; }
void lyi_l_d_iPgC(int c) { if (vl != 0) gla[2] = vla[c] / vl; }
void lyi_l_d_iPgD(int c) { if (vla[c] != 0) gla[2] = vl / vla[c]; }
long lyi_l_d_iPgR(int c) { if (vl != 0) return vla[c] / vl; }
void lyi_l_d_iTnG(int c) { int i = gi; gl = vl / vla[i]; }
void lyi_l_d_iTnX(int c) { int i = gi; gl = vla[i] / vl; }
void lyi_l_d_iTnE(int c) { int i = gi; gla[i] = vl / wla[i]; }
void lyi_l_d_iTnZ(int c) { int i = gi; gla[i] = gla[i] / vl; }
void lyi_l_d_iTnY(int c) { int i = gi; gla[i] = vl / gla[i]; }
void lyi_l_d_iTnK(int c) { int i = gi; gl = vla[i] / 7; }
void lyi_l_d_iTnJ(int c) { int i = gi; gl = 7 / vla[i]; }
void lyi_l_d_iTnS(int c) { int i = gi; gla[i] = gla[i] / 7; }
void lyi_l_d_iTnC(int c) { int i = gi; gla[2] = vla[i] / vl; }
void lyi_l_d_iTnD(int c) { int i = gi; gla[2] = vl / vla[i]; }
long lyi_l_d_iTnR(int c) { int i = gi; return vla[i] / vl; }
void lyi_l_d_iTgG(int c) { int i = gi; if (vla[i] != 0) gl = vl / vla[i]; }
void lyi_l_d_iTgX(int c) { int i = gi; if (vl != 0) gl = vla[i] / vl; }
void lyi_l_d_iTgE(int c) { int i = gi; if (wla[i] != 0) gla[i] = vl / wla[i]; }
void lyi_l_d_iTgZ(int c) { int i = gi; if (vl != 0) gla[i] = gla[i] / vl; }
void lyi_l_d_iTgY(int c) { int i = gi; if (gla[i] != 0) gla[i] = vl / gla[i]; }
void lyi_l_d_iTgJ(int c) { int i = gi; if (vla[i] != 0) gl = 7 / vla[i]; }
void lyi_l_d_iTgC(int c) { int i = gi; if (vl != 0) gla[2] = vla[i] / vl; }
void lyi_l_d_iTgD(int c) { int i = gi; if (vla[i] != 0) gla[2] = vl / vla[i]; }
long lyi_l_d_iTgR(int c) { int i = gi; if (vl != 0) return vla[i] / vl; }
void lyi_l_d_cPnY(char c) { gla[c] = vl / gla[c]; }
void lyi_l_d_cPnK(char c) { gl = vla[c] / 7; }
void lyi_l_d_cPnJ(char c) { gl = 7 / vla[c]; }
void lyi_l_d_cPnS(char c) { gla[c] = gla[c] / 7; }
void lyi_l_d_cPnC(char c) { gla[2] = vla[c] / vl; }
void lyi_l_d_cPnD(char c) { gla[2] = vl / vla[c]; }
long lyi_l_d_cPnR(char c) { return vla[c] / vl; }
void lyi_l_d_cPgG(char c) { if (vla[c] != 0) gl = vl / vla[c]; }
void lyi_l_d_cPgX(char c) { if (vl != 0) gl = vla[c] / vl; }
void lyi_l_d_cPgE(char c) { if (wla[c] != 0) gla[c] = vl / wla[c]; }
void lyi_l_d_cPgZ(char c) { if (vl != 0) gla[c] = gla[c] / vl; }
void lyi_l_d_cPgY(char c) { if (gla[c] != 0) gla[c] = vl / gla[c]; }
void lyi_l_d_cPgJ(char c) { if (vla[c] != 0) gl = 7 / vla[c]; }
void lyi_l_d_cPgC(char c) { if (vl != 0) gla[2] = vla[c] / vl; }
void lyi_l_d_cPgD(char c) { if (vla[c] != 0) gla[2] = vl / vla[c]; }
long lyi_l_d_cPgR(char c) { if (vl != 0) return vla[c] / vl; }
void lyi_l_d_cTnY(int c) { char i = gcc; gla[i] = vl / gla[i]; }
void lyi_l_d_cTnK(int c) { char i = gcc; gl = vla[i] / 7; }
void lyi_l_d_cTnJ(int c) { char i = gcc; gl = 7 / vla[i]; }
void lyi_l_d_cTnS(int c) { char i = gcc; gla[i] = gla[i] / 7; }
void lyi_l_d_cTnC(int c) { char i = gcc; gla[2] = vla[i] / vl; }
void lyi_l_d_cTnD(int c) { char i = gcc; gla[2] = vl / vla[i]; }
long lyi_l_d_cTnR(int c) { char i = gcc; return vla[i] / vl; }
void lyi_l_d_cTgG(int c) { char i = gcc; if (vla[i] != 0) gl = vl / vla[i]; }
void lyi_l_d_cTgX(int c) { char i = gcc; if (vl != 0) gl = vla[i] / vl; }
void lyi_l_d_cTgE(int c) { char i = gcc; if (wla[i] != 0) gla[i] = vl / wla[i]; }
void lyi_l_d_cTgZ(int c) { char i = gcc; if (vl != 0) gla[i] = gla[i] / vl; }
void lyi_l_d_cTgY(int c) { char i = gcc; if (gla[i] != 0) gla[i] = vl / gla[i]; }
void lyi_l_d_cTgJ(int c) { char i = gcc; if (vla[i] != 0) gl = 7 / vla[i]; }
void lyi_l_d_cTgC(int c) { char i = gcc; if (vl != 0) gla[2] = vla[i] / vl; }
void lyi_l_d_cTgD(int c) { char i = gcc; if (vla[i] != 0) gla[2] = vl / vla[i]; }
long lyi_l_d_cTgR(int c) { char i = gcc; if (vl != 0) return vla[i] / vl; }

void lyi_l_m_iPnG(int c) { gl = vl % vla[c]; }
void lyi_l_m_iPnX(int c) { gl = vla[c] % vl; }
void lyi_l_m_iPnE(int c) { gla[c] = vl % wla[c]; }
void lyi_l_m_iPnZ(int c) { gla[c] = gla[c] % vl; }
void lyi_l_m_iPnY(int c) { gla[c] = vl % gla[c]; }
void lyi_l_m_iPnK(int c) { gl = vla[c] % 7; }
void lyi_l_m_iPnJ(int c) { gl = 7 % vla[c]; }
void lyi_l_m_iPnS(int c) { gla[c] = gla[c] % 7; }
void lyi_l_m_iPnC(int c) { gla[2] = vla[c] % vl; }
void lyi_l_m_iPnD(int c) { gla[2] = vl % vla[c]; }
long lyi_l_m_iPnR(int c) { return vla[c] % vl; }
void lyi_l_m_iPgG(int c) { if (vla[c] != 0) gl = vl % vla[c]; }
void lyi_l_m_iPgX(int c) { if (vl != 0) gl = vla[c] % vl; }
void lyi_l_m_iPgE(int c) { if (wla[c] != 0) gla[c] = vl % wla[c]; }
void lyi_l_m_iPgZ(int c) { if (vl != 0) gla[c] = gla[c] % vl; }
void lyi_l_m_iPgY(int c) { if (gla[c] != 0) gla[c] = vl % gla[c]; }
void lyi_l_m_iPgJ(int c) { if (vla[c] != 0) gl = 7 % vla[c]; }
void lyi_l_m_iPgC(int c) { if (vl != 0) gla[2] = vla[c] % vl; }
void lyi_l_m_iPgD(int c) { if (vla[c] != 0) gla[2] = vl % vla[c]; }
long lyi_l_m_iPgR(int c) { if (vl != 0) return vla[c] % vl; }
void lyi_l_m_iTnG(int c) { int i = gi; gl = vl % vla[i]; }
void lyi_l_m_iTnX(int c) { int i = gi; gl = vla[i] % vl; }
void lyi_l_m_iTnE(int c) { int i = gi; gla[i] = vl % wla[i]; }
void lyi_l_m_iTnZ(int c) { int i = gi; gla[i] = gla[i] % vl; }
void lyi_l_m_iTnY(int c) { int i = gi; gla[i] = vl % gla[i]; }
void lyi_l_m_iTnK(int c) { int i = gi; gl = vla[i] % 7; }
void lyi_l_m_iTnJ(int c) { int i = gi; gl = 7 % vla[i]; }
void lyi_l_m_iTnS(int c) { int i = gi; gla[i] = gla[i] % 7; }
void lyi_l_m_iTnC(int c) { int i = gi; gla[2] = vla[i] % vl; }
void lyi_l_m_iTnD(int c) { int i = gi; gla[2] = vl % vla[i]; }
long lyi_l_m_iTnR(int c) { int i = gi; return vla[i] % vl; }
void lyi_l_m_iTgG(int c) { int i = gi; if (vla[i] != 0) gl = vl % vla[i]; }
void lyi_l_m_iTgX(int c) { int i = gi; if (vl != 0) gl = vla[i] % vl; }
void lyi_l_m_iTgE(int c) { int i = gi; if (wla[i] != 0) gla[i] = vl % wla[i]; }
void lyi_l_m_iTgZ(int c) { int i = gi; if (vl != 0) gla[i] = gla[i] % vl; }
void lyi_l_m_iTgY(int c) { int i = gi; if (gla[i] != 0) gla[i] = vl % gla[i]; }
void lyi_l_m_iTgJ(int c) { int i = gi; if (vla[i] != 0) gl = 7 % vla[i]; }
void lyi_l_m_iTgC(int c) { int i = gi; if (vl != 0) gla[2] = vla[i] % vl; }
void lyi_l_m_iTgD(int c) { int i = gi; if (vla[i] != 0) gla[2] = vl % vla[i]; }
long lyi_l_m_iTgR(int c) { int i = gi; if (vl != 0) return vla[i] % vl; }
void lyi_l_m_cPnY(char c) { gla[c] = vl % gla[c]; }
void lyi_l_m_cPnK(char c) { gl = vla[c] % 7; }
void lyi_l_m_cPnJ(char c) { gl = 7 % vla[c]; }
void lyi_l_m_cPnS(char c) { gla[c] = gla[c] % 7; }
void lyi_l_m_cPnC(char c) { gla[2] = vla[c] % vl; }
void lyi_l_m_cPnD(char c) { gla[2] = vl % vla[c]; }
long lyi_l_m_cPnR(char c) { return vla[c] % vl; }
void lyi_l_m_cPgG(char c) { if (vla[c] != 0) gl = vl % vla[c]; }
void lyi_l_m_cPgX(char c) { if (vl != 0) gl = vla[c] % vl; }
void lyi_l_m_cPgE(char c) { if (wla[c] != 0) gla[c] = vl % wla[c]; }
void lyi_l_m_cPgZ(char c) { if (vl != 0) gla[c] = gla[c] % vl; }
void lyi_l_m_cPgY(char c) { if (gla[c] != 0) gla[c] = vl % gla[c]; }
void lyi_l_m_cPgJ(char c) { if (vla[c] != 0) gl = 7 % vla[c]; }
void lyi_l_m_cPgC(char c) { if (vl != 0) gla[2] = vla[c] % vl; }
void lyi_l_m_cPgD(char c) { if (vla[c] != 0) gla[2] = vl % vla[c]; }
long lyi_l_m_cPgR(char c) { if (vl != 0) return vla[c] % vl; }
void lyi_l_m_cTnY(int c) { char i = gcc; gla[i] = vl % gla[i]; }
void lyi_l_m_cTnK(int c) { char i = gcc; gl = vla[i] % 7; }
void lyi_l_m_cTnJ(int c) { char i = gcc; gl = 7 % vla[i]; }
void lyi_l_m_cTnS(int c) { char i = gcc; gla[i] = gla[i] % 7; }
void lyi_l_m_cTnC(int c) { char i = gcc; gla[2] = vla[i] % vl; }
void lyi_l_m_cTnD(int c) { char i = gcc; gla[2] = vl % vla[i]; }
long lyi_l_m_cTnR(int c) { char i = gcc; return vla[i] % vl; }
void lyi_l_m_cTgG(int c) { char i = gcc; if (vla[i] != 0) gl = vl % vla[i]; }
void lyi_l_m_cTgX(int c) { char i = gcc; if (vl != 0) gl = vla[i] % vl; }
void lyi_l_m_cTgE(int c) { char i = gcc; if (wla[i] != 0) gla[i] = vl % wla[i]; }
void lyi_l_m_cTgZ(int c) { char i = gcc; if (vl != 0) gla[i] = gla[i] % vl; }
void lyi_l_m_cTgY(int c) { char i = gcc; if (gla[i] != 0) gla[i] = vl % gla[i]; }
void lyi_l_m_cTgJ(int c) { char i = gcc; if (vla[i] != 0) gl = 7 % vla[i]; }
void lyi_l_m_cTgC(int c) { char i = gcc; if (vl != 0) gla[2] = vla[i] % vl; }
void lyi_l_m_cTgD(int c) { char i = gcc; if (vla[i] != 0) gla[2] = vl % vla[i]; }
long lyi_l_m_cTgR(int c) { char i = gcc; if (vl != 0) return vla[i] % vl; }

void lyi_l_x_iPnG(int c) { gl = vl * vla[c]; }
void lyi_l_x_iPnX(int c) { gl = vla[c] * vl; }
void lyi_l_x_iPnE(int c) { gla[c] = vl * wla[c]; }
void lyi_l_x_iPnZ(int c) { gla[c] = gla[c] * vl; }
void lyi_l_x_iPnY(int c) { gla[c] = vl * gla[c]; }
void lyi_l_x_iPnK(int c) { gl = vla[c] * 7; }
void lyi_l_x_iPnJ(int c) { gl = 7 * vla[c]; }
void lyi_l_x_iPnS(int c) { gla[c] = gla[c] * 7; }
void lyi_l_x_iPnC(int c) { gla[2] = vla[c] * vl; }
void lyi_l_x_iPnD(int c) { gla[2] = vl * vla[c]; }
long lyi_l_x_iPnR(int c) { return vla[c] * vl; }
void lyi_l_x_iTnG(int c) { int i = gi; gl = vl * vla[i]; }
void lyi_l_x_iTnX(int c) { int i = gi; gl = vla[i] * vl; }
void lyi_l_x_iTnE(int c) { int i = gi; gla[i] = vl * wla[i]; }
void lyi_l_x_iTnZ(int c) { int i = gi; gla[i] = gla[i] * vl; }
void lyi_l_x_iTnY(int c) { int i = gi; gla[i] = vl * gla[i]; }
void lyi_l_x_iTnK(int c) { int i = gi; gl = vla[i] * 7; }
void lyi_l_x_iTnJ(int c) { int i = gi; gl = 7 * vla[i]; }
void lyi_l_x_iTnS(int c) { int i = gi; gla[i] = gla[i] * 7; }
void lyi_l_x_iTnC(int c) { int i = gi; gla[2] = vla[i] * vl; }
void lyi_l_x_iTnD(int c) { int i = gi; gla[2] = vl * vla[i]; }
long lyi_l_x_iTnR(int c) { int i = gi; return vla[i] * vl; }
void lyi_l_x_cPnY(char c) { gla[c] = vl * gla[c]; }
void lyi_l_x_cPnK(char c) { gl = vla[c] * 7; }
void lyi_l_x_cPnJ(char c) { gl = 7 * vla[c]; }
void lyi_l_x_cPnS(char c) { gla[c] = gla[c] * 7; }
void lyi_l_x_cPnC(char c) { gla[2] = vla[c] * vl; }
void lyi_l_x_cPnD(char c) { gla[2] = vl * vla[c]; }
long lyi_l_x_cPnR(char c) { return vla[c] * vl; }
void lyi_l_x_cTnY(int c) { char i = gcc; gla[i] = vl * gla[i]; }
void lyi_l_x_cTnK(int c) { char i = gcc; gl = vla[i] * 7; }
void lyi_l_x_cTnJ(int c) { char i = gcc; gl = 7 * vla[i]; }
void lyi_l_x_cTnS(int c) { char i = gcc; gla[i] = gla[i] * 7; }
void lyi_l_x_cTnC(int c) { char i = gcc; gla[2] = vla[i] * vl; }
void lyi_l_x_cTnD(int c) { char i = gcc; gla[2] = vl * vla[i]; }
long lyi_l_x_cTnR(int c) { char i = gcc; return vla[i] * vl; }

void lyi_n_d_iPnG(int c) { gn = vn / vna[c]; }
void lyi_n_d_iPnX(int c) { gn = vna[c] / vn; }
void lyi_n_d_iPnE(int c) { gna[c] = vn / wna[c]; }
void lyi_n_d_iPnZ(int c) { gna[c] = gna[c] / vn; }
void lyi_n_d_iPnY(int c) { gna[c] = vn / gna[c]; }
void lyi_n_d_iPnK(int c) { gn = vna[c] / 7; }
void lyi_n_d_iPnJ(int c) { gn = 7 / vna[c]; }
void lyi_n_d_iPnS(int c) { gna[c] = gna[c] / 7; }
void lyi_n_d_iPnC(int c) { gna[2] = vna[c] / vn; }
void lyi_n_d_iPnD(int c) { gna[2] = vn / vna[c]; }
unsigned long lyi_n_d_iPnR(int c) { return vna[c] / vn; }
void lyi_n_d_iPgG(int c) { if (vna[c] != 0) gn = vn / vna[c]; }
void lyi_n_d_iPgX(int c) { if (vn != 0) gn = vna[c] / vn; }
void lyi_n_d_iPgE(int c) { if (wna[c] != 0) gna[c] = vn / wna[c]; }
void lyi_n_d_iPgZ(int c) { if (vn != 0) gna[c] = gna[c] / vn; }
void lyi_n_d_iPgY(int c) { if (gna[c] != 0) gna[c] = vn / gna[c]; }
void lyi_n_d_iPgJ(int c) { if (vna[c] != 0) gn = 7 / vna[c]; }
void lyi_n_d_iPgC(int c) { if (vn != 0) gna[2] = vna[c] / vn; }
void lyi_n_d_iPgD(int c) { if (vna[c] != 0) gna[2] = vn / vna[c]; }
unsigned long lyi_n_d_iPgR(int c) { if (vn != 0) return vna[c] / vn; }
void lyi_n_d_iTnG(int c) { int i = gi; gn = vn / vna[i]; }
void lyi_n_d_iTnX(int c) { int i = gi; gn = vna[i] / vn; }
void lyi_n_d_iTnE(int c) { int i = gi; gna[i] = vn / wna[i]; }
void lyi_n_d_iTnZ(int c) { int i = gi; gna[i] = gna[i] / vn; }
void lyi_n_d_iTnY(int c) { int i = gi; gna[i] = vn / gna[i]; }
void lyi_n_d_iTnK(int c) { int i = gi; gn = vna[i] / 7; }
void lyi_n_d_iTnJ(int c) { int i = gi; gn = 7 / vna[i]; }
void lyi_n_d_iTnS(int c) { int i = gi; gna[i] = gna[i] / 7; }
void lyi_n_d_iTnC(int c) { int i = gi; gna[2] = vna[i] / vn; }
void lyi_n_d_iTnD(int c) { int i = gi; gna[2] = vn / vna[i]; }
unsigned long lyi_n_d_iTnR(int c) { int i = gi; return vna[i] / vn; }
void lyi_n_d_iTgG(int c) { int i = gi; if (vna[i] != 0) gn = vn / vna[i]; }
void lyi_n_d_iTgX(int c) { int i = gi; if (vn != 0) gn = vna[i] / vn; }
void lyi_n_d_iTgE(int c) { int i = gi; if (wna[i] != 0) gna[i] = vn / wna[i]; }
void lyi_n_d_iTgZ(int c) { int i = gi; if (vn != 0) gna[i] = gna[i] / vn; }
void lyi_n_d_iTgY(int c) { int i = gi; if (gna[i] != 0) gna[i] = vn / gna[i]; }
void lyi_n_d_iTgJ(int c) { int i = gi; if (vna[i] != 0) gn = 7 / vna[i]; }
void lyi_n_d_iTgC(int c) { int i = gi; if (vn != 0) gna[2] = vna[i] / vn; }
void lyi_n_d_iTgD(int c) { int i = gi; if (vna[i] != 0) gna[2] = vn / vna[i]; }
unsigned long lyi_n_d_iTgR(int c) { int i = gi; if (vn != 0) return vna[i] / vn; }
void lyi_n_d_cPnY(char c) { gna[c] = vn / gna[c]; }
void lyi_n_d_cPnK(char c) { gn = vna[c] / 7; }
void lyi_n_d_cPnJ(char c) { gn = 7 / vna[c]; }
void lyi_n_d_cPnS(char c) { gna[c] = gna[c] / 7; }
void lyi_n_d_cPnC(char c) { gna[2] = vna[c] / vn; }
void lyi_n_d_cPnD(char c) { gna[2] = vn / vna[c]; }
unsigned long lyi_n_d_cPnR(char c) { return vna[c] / vn; }
void lyi_n_d_cPgG(char c) { if (vna[c] != 0) gn = vn / vna[c]; }
void lyi_n_d_cPgX(char c) { if (vn != 0) gn = vna[c] / vn; }
void lyi_n_d_cPgE(char c) { if (wna[c] != 0) gna[c] = vn / wna[c]; }
void lyi_n_d_cPgZ(char c) { if (vn != 0) gna[c] = gna[c] / vn; }
void lyi_n_d_cPgY(char c) { if (gna[c] != 0) gna[c] = vn / gna[c]; }
void lyi_n_d_cPgJ(char c) { if (vna[c] != 0) gn = 7 / vna[c]; }
void lyi_n_d_cPgC(char c) { if (vn != 0) gna[2] = vna[c] / vn; }
void lyi_n_d_cPgD(char c) { if (vna[c] != 0) gna[2] = vn / vna[c]; }
unsigned long lyi_n_d_cPgR(char c) { if (vn != 0) return vna[c] / vn; }
void lyi_n_d_cTnY(int c) { char i = gcc; gna[i] = vn / gna[i]; }
void lyi_n_d_cTnK(int c) { char i = gcc; gn = vna[i] / 7; }
void lyi_n_d_cTnJ(int c) { char i = gcc; gn = 7 / vna[i]; }
void lyi_n_d_cTnS(int c) { char i = gcc; gna[i] = gna[i] / 7; }
void lyi_n_d_cTnC(int c) { char i = gcc; gna[2] = vna[i] / vn; }
void lyi_n_d_cTnD(int c) { char i = gcc; gna[2] = vn / vna[i]; }
unsigned long lyi_n_d_cTnR(int c) { char i = gcc; return vna[i] / vn; }
void lyi_n_d_cTgG(int c) { char i = gcc; if (vna[i] != 0) gn = vn / vna[i]; }
void lyi_n_d_cTgX(int c) { char i = gcc; if (vn != 0) gn = vna[i] / vn; }
void lyi_n_d_cTgE(int c) { char i = gcc; if (wna[i] != 0) gna[i] = vn / wna[i]; }
void lyi_n_d_cTgZ(int c) { char i = gcc; if (vn != 0) gna[i] = gna[i] / vn; }
void lyi_n_d_cTgY(int c) { char i = gcc; if (gna[i] != 0) gna[i] = vn / gna[i]; }
void lyi_n_d_cTgJ(int c) { char i = gcc; if (vna[i] != 0) gn = 7 / vna[i]; }
void lyi_n_d_cTgC(int c) { char i = gcc; if (vn != 0) gna[2] = vna[i] / vn; }
void lyi_n_d_cTgD(int c) { char i = gcc; if (vna[i] != 0) gna[2] = vn / vna[i]; }
unsigned long lyi_n_d_cTgR(int c) { char i = gcc; if (vn != 0) return vna[i] / vn; }

void lyi_n_m_iPnG(int c) { gn = vn % vna[c]; }
void lyi_n_m_iPnX(int c) { gn = vna[c] % vn; }
void lyi_n_m_iPnE(int c) { gna[c] = vn % wna[c]; }
void lyi_n_m_iPnZ(int c) { gna[c] = gna[c] % vn; }
void lyi_n_m_iPnY(int c) { gna[c] = vn % gna[c]; }
void lyi_n_m_iPnK(int c) { gn = vna[c] % 7; }
void lyi_n_m_iPnJ(int c) { gn = 7 % vna[c]; }
void lyi_n_m_iPnS(int c) { gna[c] = gna[c] % 7; }
void lyi_n_m_iPnC(int c) { gna[2] = vna[c] % vn; }
void lyi_n_m_iPnD(int c) { gna[2] = vn % vna[c]; }
unsigned long lyi_n_m_iPnR(int c) { return vna[c] % vn; }
void lyi_n_m_iPgG(int c) { if (vna[c] != 0) gn = vn % vna[c]; }
void lyi_n_m_iPgX(int c) { if (vn != 0) gn = vna[c] % vn; }
void lyi_n_m_iPgE(int c) { if (wna[c] != 0) gna[c] = vn % wna[c]; }
void lyi_n_m_iPgZ(int c) { if (vn != 0) gna[c] = gna[c] % vn; }
void lyi_n_m_iPgY(int c) { if (gna[c] != 0) gna[c] = vn % gna[c]; }
void lyi_n_m_iPgJ(int c) { if (vna[c] != 0) gn = 7 % vna[c]; }
void lyi_n_m_iPgC(int c) { if (vn != 0) gna[2] = vna[c] % vn; }
void lyi_n_m_iPgD(int c) { if (vna[c] != 0) gna[2] = vn % vna[c]; }
unsigned long lyi_n_m_iPgR(int c) { if (vn != 0) return vna[c] % vn; }
void lyi_n_m_iTnG(int c) { int i = gi; gn = vn % vna[i]; }
void lyi_n_m_iTnX(int c) { int i = gi; gn = vna[i] % vn; }
void lyi_n_m_iTnE(int c) { int i = gi; gna[i] = vn % wna[i]; }
void lyi_n_m_iTnZ(int c) { int i = gi; gna[i] = gna[i] % vn; }
void lyi_n_m_iTnY(int c) { int i = gi; gna[i] = vn % gna[i]; }
void lyi_n_m_iTnK(int c) { int i = gi; gn = vna[i] % 7; }
void lyi_n_m_iTnJ(int c) { int i = gi; gn = 7 % vna[i]; }
void lyi_n_m_iTnS(int c) { int i = gi; gna[i] = gna[i] % 7; }
void lyi_n_m_iTnC(int c) { int i = gi; gna[2] = vna[i] % vn; }
void lyi_n_m_iTnD(int c) { int i = gi; gna[2] = vn % vna[i]; }
unsigned long lyi_n_m_iTnR(int c) { int i = gi; return vna[i] % vn; }
void lyi_n_m_iTgG(int c) { int i = gi; if (vna[i] != 0) gn = vn % vna[i]; }
void lyi_n_m_iTgX(int c) { int i = gi; if (vn != 0) gn = vna[i] % vn; }
void lyi_n_m_iTgE(int c) { int i = gi; if (wna[i] != 0) gna[i] = vn % wna[i]; }
void lyi_n_m_iTgZ(int c) { int i = gi; if (vn != 0) gna[i] = gna[i] % vn; }
void lyi_n_m_iTgY(int c) { int i = gi; if (gna[i] != 0) gna[i] = vn % gna[i]; }
void lyi_n_m_iTgJ(int c) { int i = gi; if (vna[i] != 0) gn = 7 % vna[i]; }
void lyi_n_m_iTgC(int c) { int i = gi; if (vn != 0) gna[2] = vna[i] % vn; }
void lyi_n_m_iTgD(int c) { int i = gi; if (vna[i] != 0) gna[2] = vn % vna[i]; }
unsigned long lyi_n_m_iTgR(int c) { int i = gi; if (vn != 0) return vna[i] % vn; }
void lyi_n_m_cPnY(char c) { gna[c] = vn % gna[c]; }
void lyi_n_m_cPnK(char c) { gn = vna[c] % 7; }
void lyi_n_m_cPnJ(char c) { gn = 7 % vna[c]; }
void lyi_n_m_cPnS(char c) { gna[c] = gna[c] % 7; }
void lyi_n_m_cPnC(char c) { gna[2] = vna[c] % vn; }
void lyi_n_m_cPnD(char c) { gna[2] = vn % vna[c]; }
unsigned long lyi_n_m_cPnR(char c) { return vna[c] % vn; }
void lyi_n_m_cPgG(char c) { if (vna[c] != 0) gn = vn % vna[c]; }
void lyi_n_m_cPgX(char c) { if (vn != 0) gn = vna[c] % vn; }
void lyi_n_m_cPgE(char c) { if (wna[c] != 0) gna[c] = vn % wna[c]; }
void lyi_n_m_cPgZ(char c) { if (vn != 0) gna[c] = gna[c] % vn; }
void lyi_n_m_cPgY(char c) { if (gna[c] != 0) gna[c] = vn % gna[c]; }
void lyi_n_m_cPgJ(char c) { if (vna[c] != 0) gn = 7 % vna[c]; }
void lyi_n_m_cPgC(char c) { if (vn != 0) gna[2] = vna[c] % vn; }
void lyi_n_m_cPgD(char c) { if (vna[c] != 0) gna[2] = vn % vna[c]; }
unsigned long lyi_n_m_cPgR(char c) { if (vn != 0) return vna[c] % vn; }
void lyi_n_m_cTnY(int c) { char i = gcc; gna[i] = vn % gna[i]; }
void lyi_n_m_cTnK(int c) { char i = gcc; gn = vna[i] % 7; }
void lyi_n_m_cTnJ(int c) { char i = gcc; gn = 7 % vna[i]; }
void lyi_n_m_cTnS(int c) { char i = gcc; gna[i] = gna[i] % 7; }
void lyi_n_m_cTnC(int c) { char i = gcc; gna[2] = vna[i] % vn; }
void lyi_n_m_cTnD(int c) { char i = gcc; gna[2] = vn % vna[i]; }
unsigned long lyi_n_m_cTnR(int c) { char i = gcc; return vna[i] % vn; }
void lyi_n_m_cTgG(int c) { char i = gcc; if (vna[i] != 0) gn = vn % vna[i]; }
void lyi_n_m_cTgX(int c) { char i = gcc; if (vn != 0) gn = vna[i] % vn; }
void lyi_n_m_cTgE(int c) { char i = gcc; if (wna[i] != 0) gna[i] = vn % wna[i]; }
void lyi_n_m_cTgZ(int c) { char i = gcc; if (vn != 0) gna[i] = gna[i] % vn; }
void lyi_n_m_cTgY(int c) { char i = gcc; if (gna[i] != 0) gna[i] = vn % gna[i]; }
void lyi_n_m_cTgJ(int c) { char i = gcc; if (vna[i] != 0) gn = 7 % vna[i]; }
void lyi_n_m_cTgC(int c) { char i = gcc; if (vn != 0) gna[2] = vna[i] % vn; }
void lyi_n_m_cTgD(int c) { char i = gcc; if (vna[i] != 0) gna[2] = vn % vna[i]; }
unsigned long lyi_n_m_cTgR(int c) { char i = gcc; if (vn != 0) return vna[i] % vn; }

void lyi_n_x_iPnG(int c) { gn = vn * vna[c]; }
void lyi_n_x_iPnX(int c) { gn = vna[c] * vn; }
void lyi_n_x_iPnE(int c) { gna[c] = vn * wna[c]; }
void lyi_n_x_iPnZ(int c) { gna[c] = gna[c] * vn; }
void lyi_n_x_iPnY(int c) { gna[c] = vn * gna[c]; }
void lyi_n_x_iPnK(int c) { gn = vna[c] * 7; }
void lyi_n_x_iPnJ(int c) { gn = 7 * vna[c]; }
void lyi_n_x_iPnS(int c) { gna[c] = gna[c] * 7; }
void lyi_n_x_iPnC(int c) { gna[2] = vna[c] * vn; }
void lyi_n_x_iPnD(int c) { gna[2] = vn * vna[c]; }
unsigned long lyi_n_x_iPnR(int c) { return vna[c] * vn; }
void lyi_n_x_iTnG(int c) { int i = gi; gn = vn * vna[i]; }
void lyi_n_x_iTnX(int c) { int i = gi; gn = vna[i] * vn; }
void lyi_n_x_iTnE(int c) { int i = gi; gna[i] = vn * wna[i]; }
void lyi_n_x_iTnZ(int c) { int i = gi; gna[i] = gna[i] * vn; }
void lyi_n_x_iTnY(int c) { int i = gi; gna[i] = vn * gna[i]; }
void lyi_n_x_iTnK(int c) { int i = gi; gn = vna[i] * 7; }
void lyi_n_x_iTnJ(int c) { int i = gi; gn = 7 * vna[i]; }
void lyi_n_x_iTnS(int c) { int i = gi; gna[i] = gna[i] * 7; }
void lyi_n_x_iTnC(int c) { int i = gi; gna[2] = vna[i] * vn; }
void lyi_n_x_iTnD(int c) { int i = gi; gna[2] = vn * vna[i]; }
unsigned long lyi_n_x_iTnR(int c) { int i = gi; return vna[i] * vn; }
void lyi_n_x_cPnY(char c) { gna[c] = vn * gna[c]; }
void lyi_n_x_cPnK(char c) { gn = vna[c] * 7; }
void lyi_n_x_cPnJ(char c) { gn = 7 * vna[c]; }
void lyi_n_x_cPnS(char c) { gna[c] = gna[c] * 7; }
void lyi_n_x_cPnC(char c) { gna[2] = vna[c] * vn; }
void lyi_n_x_cPnD(char c) { gna[2] = vn * vna[c]; }
unsigned long lyi_n_x_cPnR(char c) { return vna[c] * vn; }
void lyi_n_x_cTnY(int c) { char i = gcc; gna[i] = vn * gna[i]; }
void lyi_n_x_cTnK(int c) { char i = gcc; gn = vna[i] * 7; }
void lyi_n_x_cTnJ(int c) { char i = gcc; gn = 7 * vna[i]; }
void lyi_n_x_cTnS(int c) { char i = gcc; gna[i] = gna[i] * 7; }
void lyi_n_x_cTnC(int c) { char i = gcc; gna[2] = vna[i] * vn; }
void lyi_n_x_cTnD(int c) { char i = gcc; gna[2] = vn * vna[i]; }
unsigned long lyi_n_x_cTnR(int c) { char i = gcc; return vna[i] * vn; }
