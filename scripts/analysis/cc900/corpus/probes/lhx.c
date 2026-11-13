/* Long helpers, shapes the earlier probes leave out (gen_lhx.py).  t: l long, n unsigned long; op: d /, m %, x *.
   Group 1  lxi_<t>_<op>_<I><O><shape>(c): the element's INDEX has type I (c char, u unsigned char, w unsigned int)
     and origin O (P the parameter c, T a local initialised from a global of that type, L a for-loop counter 0..3 of
     that type).  shapes: G gv = vv op va[i]; X gv = va[i] op vv;
     E ga[i] = vv op wa[i]; Z ga[i] = ga[i] op vv.
   Group 2  lxo_<t>_<op>_<D><A><B>(c), c an int parameter: destination D: G plain global, P *p, D p->m, X element
     at c, R return, A call argument vv(...), Q condition if (A op B) gi = 1; operand A: P *p, D p->m, E vea[2]
     (constant element), X vea[c]; operand B: G plain global, P *p, D p->m, K 7, X wea[c].
   Group 3  lxm_<t>_<form>_<D>(c): two helpers or a nested operand in one expression; D G, X, P, R as above. */
struct sl { char c; long l; unsigned long n; };
extern struct sl gs, *gps;
extern char gcc; extern unsigned char guc; extern unsigned int guu; extern int gi;
extern long gl, vl, wl, gla[8], vla[8], wla[8], *gpl; extern void vvl(long); extern long rrl(long);
extern unsigned long gn, vn, wn, gna[8], vna[8], wna[8], *gpn; extern void vvn(unsigned long); extern unsigned long rrn(unsigned long);

void lxi_l_d_cPG(char c) { gl = vl / vla[c]; }
void lxi_l_d_cPX(char c) { gl = vla[c] / vl; }
void lxi_l_d_cPE(char c) { gla[c] = vl / wla[c]; }
void lxi_l_d_cPZ(char c) { gla[c] = gla[c] / vl; }
void lxi_l_d_cTG(int c) { char i = gcc; gl = vl / vla[i]; }
void lxi_l_d_cTX(int c) { char i = gcc; gl = vla[i] / vl; }
void lxi_l_d_cTE(int c) { char i = gcc; gla[i] = vl / wla[i]; }
void lxi_l_d_cTZ(int c) { char i = gcc; gla[i] = gla[i] / vl; }
void lxi_l_d_cLG(int c) { char i; for (i = 0; i < 4; i++) gl = vl / vla[i]; }
void lxi_l_d_cLX(int c) { char i; for (i = 0; i < 4; i++) gl = vla[i] / vl; }
void lxi_l_d_cLE(int c) { char i; for (i = 0; i < 4; i++) gla[i] = vl / wla[i]; }
void lxi_l_d_cLZ(int c) { char i; for (i = 0; i < 4; i++) gla[i] = gla[i] / vl; }
void lxi_l_d_uPG(unsigned char c) { gl = vl / vla[c]; }
void lxi_l_d_uPX(unsigned char c) { gl = vla[c] / vl; }
void lxi_l_d_uPE(unsigned char c) { gla[c] = vl / wla[c]; }
void lxi_l_d_uPZ(unsigned char c) { gla[c] = gla[c] / vl; }
void lxi_l_d_uTG(int c) { unsigned char i = guc; gl = vl / vla[i]; }
void lxi_l_d_uTX(int c) { unsigned char i = guc; gl = vla[i] / vl; }
void lxi_l_d_uTE(int c) { unsigned char i = guc; gla[i] = vl / wla[i]; }
void lxi_l_d_uTZ(int c) { unsigned char i = guc; gla[i] = gla[i] / vl; }
void lxi_l_d_uLG(int c) { unsigned char i; for (i = 0; i < 4; i++) gl = vl / vla[i]; }
void lxi_l_d_uLX(int c) { unsigned char i; for (i = 0; i < 4; i++) gl = vla[i] / vl; }
void lxi_l_d_uLE(int c) { unsigned char i; for (i = 0; i < 4; i++) gla[i] = vl / wla[i]; }
void lxi_l_d_uLZ(int c) { unsigned char i; for (i = 0; i < 4; i++) gla[i] = gla[i] / vl; }
void lxi_l_d_wPG(unsigned int c) { gl = vl / vla[c]; }
void lxi_l_d_wPX(unsigned int c) { gl = vla[c] / vl; }
void lxi_l_d_wPE(unsigned int c) { gla[c] = vl / wla[c]; }
void lxi_l_d_wPZ(unsigned int c) { gla[c] = gla[c] / vl; }
void lxi_l_d_wTG(int c) { unsigned int i = guu; gl = vl / vla[i]; }
void lxi_l_d_wTX(int c) { unsigned int i = guu; gl = vla[i] / vl; }
void lxi_l_d_wTE(int c) { unsigned int i = guu; gla[i] = vl / wla[i]; }
void lxi_l_d_wTZ(int c) { unsigned int i = guu; gla[i] = gla[i] / vl; }
void lxi_l_d_wLG(int c) { unsigned int i; for (i = 0; i < 4; i++) gl = vl / vla[i]; }
void lxi_l_d_wLX(int c) { unsigned int i; for (i = 0; i < 4; i++) gl = vla[i] / vl; }
void lxi_l_d_wLE(int c) { unsigned int i; for (i = 0; i < 4; i++) gla[i] = vl / wla[i]; }
void lxi_l_d_wLZ(int c) { unsigned int i; for (i = 0; i < 4; i++) gla[i] = gla[i] / vl; }

void lxi_l_m_cPG(char c) { gl = vl % vla[c]; }
void lxi_l_m_cPX(char c) { gl = vla[c] % vl; }
void lxi_l_m_cPE(char c) { gla[c] = vl % wla[c]; }
void lxi_l_m_cPZ(char c) { gla[c] = gla[c] % vl; }
void lxi_l_m_cTG(int c) { char i = gcc; gl = vl % vla[i]; }
void lxi_l_m_cTX(int c) { char i = gcc; gl = vla[i] % vl; }
void lxi_l_m_cTE(int c) { char i = gcc; gla[i] = vl % wla[i]; }
void lxi_l_m_cTZ(int c) { char i = gcc; gla[i] = gla[i] % vl; }
void lxi_l_m_cLG(int c) { char i; for (i = 0; i < 4; i++) gl = vl % vla[i]; }
void lxi_l_m_cLX(int c) { char i; for (i = 0; i < 4; i++) gl = vla[i] % vl; }
void lxi_l_m_cLE(int c) { char i; for (i = 0; i < 4; i++) gla[i] = vl % wla[i]; }
void lxi_l_m_cLZ(int c) { char i; for (i = 0; i < 4; i++) gla[i] = gla[i] % vl; }
void lxi_l_m_uPG(unsigned char c) { gl = vl % vla[c]; }
void lxi_l_m_uPX(unsigned char c) { gl = vla[c] % vl; }
void lxi_l_m_uPE(unsigned char c) { gla[c] = vl % wla[c]; }
void lxi_l_m_uPZ(unsigned char c) { gla[c] = gla[c] % vl; }
void lxi_l_m_uTG(int c) { unsigned char i = guc; gl = vl % vla[i]; }
void lxi_l_m_uTX(int c) { unsigned char i = guc; gl = vla[i] % vl; }
void lxi_l_m_uTE(int c) { unsigned char i = guc; gla[i] = vl % wla[i]; }
void lxi_l_m_uTZ(int c) { unsigned char i = guc; gla[i] = gla[i] % vl; }
void lxi_l_m_uLG(int c) { unsigned char i; for (i = 0; i < 4; i++) gl = vl % vla[i]; }
void lxi_l_m_uLX(int c) { unsigned char i; for (i = 0; i < 4; i++) gl = vla[i] % vl; }
void lxi_l_m_uLE(int c) { unsigned char i; for (i = 0; i < 4; i++) gla[i] = vl % wla[i]; }
void lxi_l_m_uLZ(int c) { unsigned char i; for (i = 0; i < 4; i++) gla[i] = gla[i] % vl; }
void lxi_l_m_wPG(unsigned int c) { gl = vl % vla[c]; }
void lxi_l_m_wPX(unsigned int c) { gl = vla[c] % vl; }
void lxi_l_m_wPE(unsigned int c) { gla[c] = vl % wla[c]; }
void lxi_l_m_wPZ(unsigned int c) { gla[c] = gla[c] % vl; }
void lxi_l_m_wTG(int c) { unsigned int i = guu; gl = vl % vla[i]; }
void lxi_l_m_wTX(int c) { unsigned int i = guu; gl = vla[i] % vl; }
void lxi_l_m_wTE(int c) { unsigned int i = guu; gla[i] = vl % wla[i]; }
void lxi_l_m_wTZ(int c) { unsigned int i = guu; gla[i] = gla[i] % vl; }
void lxi_l_m_wLG(int c) { unsigned int i; for (i = 0; i < 4; i++) gl = vl % vla[i]; }
void lxi_l_m_wLX(int c) { unsigned int i; for (i = 0; i < 4; i++) gl = vla[i] % vl; }
void lxi_l_m_wLE(int c) { unsigned int i; for (i = 0; i < 4; i++) gla[i] = vl % wla[i]; }
void lxi_l_m_wLZ(int c) { unsigned int i; for (i = 0; i < 4; i++) gla[i] = gla[i] % vl; }

void lxi_l_x_cPG(char c) { gl = vl * vla[c]; }
void lxi_l_x_cPX(char c) { gl = vla[c] * vl; }
void lxi_l_x_cPE(char c) { gla[c] = vl * wla[c]; }
void lxi_l_x_cPZ(char c) { gla[c] = gla[c] * vl; }
void lxi_l_x_cTG(int c) { char i = gcc; gl = vl * vla[i]; }
void lxi_l_x_cTX(int c) { char i = gcc; gl = vla[i] * vl; }
void lxi_l_x_cTE(int c) { char i = gcc; gla[i] = vl * wla[i]; }
void lxi_l_x_cTZ(int c) { char i = gcc; gla[i] = gla[i] * vl; }
void lxi_l_x_cLG(int c) { char i; for (i = 0; i < 4; i++) gl = vl * vla[i]; }
void lxi_l_x_cLX(int c) { char i; for (i = 0; i < 4; i++) gl = vla[i] * vl; }
void lxi_l_x_cLE(int c) { char i; for (i = 0; i < 4; i++) gla[i] = vl * wla[i]; }
void lxi_l_x_cLZ(int c) { char i; for (i = 0; i < 4; i++) gla[i] = gla[i] * vl; }
void lxi_l_x_uPG(unsigned char c) { gl = vl * vla[c]; }
void lxi_l_x_uPX(unsigned char c) { gl = vla[c] * vl; }
void lxi_l_x_uPE(unsigned char c) { gla[c] = vl * wla[c]; }
void lxi_l_x_uPZ(unsigned char c) { gla[c] = gla[c] * vl; }
void lxi_l_x_uTG(int c) { unsigned char i = guc; gl = vl * vla[i]; }
void lxi_l_x_uTX(int c) { unsigned char i = guc; gl = vla[i] * vl; }
void lxi_l_x_uTE(int c) { unsigned char i = guc; gla[i] = vl * wla[i]; }
void lxi_l_x_uTZ(int c) { unsigned char i = guc; gla[i] = gla[i] * vl; }
void lxi_l_x_uLG(int c) { unsigned char i; for (i = 0; i < 4; i++) gl = vl * vla[i]; }
void lxi_l_x_uLX(int c) { unsigned char i; for (i = 0; i < 4; i++) gl = vla[i] * vl; }
void lxi_l_x_uLE(int c) { unsigned char i; for (i = 0; i < 4; i++) gla[i] = vl * wla[i]; }
void lxi_l_x_uLZ(int c) { unsigned char i; for (i = 0; i < 4; i++) gla[i] = gla[i] * vl; }
void lxi_l_x_wPG(unsigned int c) { gl = vl * vla[c]; }
void lxi_l_x_wPX(unsigned int c) { gl = vla[c] * vl; }
void lxi_l_x_wPE(unsigned int c) { gla[c] = vl * wla[c]; }
void lxi_l_x_wPZ(unsigned int c) { gla[c] = gla[c] * vl; }
void lxi_l_x_wTG(int c) { unsigned int i = guu; gl = vl * vla[i]; }
void lxi_l_x_wTX(int c) { unsigned int i = guu; gl = vla[i] * vl; }
void lxi_l_x_wTE(int c) { unsigned int i = guu; gla[i] = vl * wla[i]; }
void lxi_l_x_wTZ(int c) { unsigned int i = guu; gla[i] = gla[i] * vl; }
void lxi_l_x_wLG(int c) { unsigned int i; for (i = 0; i < 4; i++) gl = vl * vla[i]; }
void lxi_l_x_wLX(int c) { unsigned int i; for (i = 0; i < 4; i++) gl = vla[i] * vl; }
void lxi_l_x_wLE(int c) { unsigned int i; for (i = 0; i < 4; i++) gla[i] = vl * wla[i]; }
void lxi_l_x_wLZ(int c) { unsigned int i; for (i = 0; i < 4; i++) gla[i] = gla[i] * vl; }

void lxi_n_d_cPG(char c) { gn = vn / vna[c]; }
void lxi_n_d_cPX(char c) { gn = vna[c] / vn; }
void lxi_n_d_cPE(char c) { gna[c] = vn / wna[c]; }
void lxi_n_d_cPZ(char c) { gna[c] = gna[c] / vn; }
void lxi_n_d_cTG(int c) { char i = gcc; gn = vn / vna[i]; }
void lxi_n_d_cTX(int c) { char i = gcc; gn = vna[i] / vn; }
void lxi_n_d_cTE(int c) { char i = gcc; gna[i] = vn / wna[i]; }
void lxi_n_d_cTZ(int c) { char i = gcc; gna[i] = gna[i] / vn; }
void lxi_n_d_cLG(int c) { char i; for (i = 0; i < 4; i++) gn = vn / vna[i]; }
void lxi_n_d_cLX(int c) { char i; for (i = 0; i < 4; i++) gn = vna[i] / vn; }
void lxi_n_d_cLE(int c) { char i; for (i = 0; i < 4; i++) gna[i] = vn / wna[i]; }
void lxi_n_d_cLZ(int c) { char i; for (i = 0; i < 4; i++) gna[i] = gna[i] / vn; }
void lxi_n_d_uPG(unsigned char c) { gn = vn / vna[c]; }
void lxi_n_d_uPX(unsigned char c) { gn = vna[c] / vn; }
void lxi_n_d_uPE(unsigned char c) { gna[c] = vn / wna[c]; }
void lxi_n_d_uPZ(unsigned char c) { gna[c] = gna[c] / vn; }
void lxi_n_d_uTG(int c) { unsigned char i = guc; gn = vn / vna[i]; }
void lxi_n_d_uTX(int c) { unsigned char i = guc; gn = vna[i] / vn; }
void lxi_n_d_uTE(int c) { unsigned char i = guc; gna[i] = vn / wna[i]; }
void lxi_n_d_uTZ(int c) { unsigned char i = guc; gna[i] = gna[i] / vn; }
void lxi_n_d_uLG(int c) { unsigned char i; for (i = 0; i < 4; i++) gn = vn / vna[i]; }
void lxi_n_d_uLX(int c) { unsigned char i; for (i = 0; i < 4; i++) gn = vna[i] / vn; }
void lxi_n_d_uLE(int c) { unsigned char i; for (i = 0; i < 4; i++) gna[i] = vn / wna[i]; }
void lxi_n_d_uLZ(int c) { unsigned char i; for (i = 0; i < 4; i++) gna[i] = gna[i] / vn; }
void lxi_n_d_wPG(unsigned int c) { gn = vn / vna[c]; }
void lxi_n_d_wPX(unsigned int c) { gn = vna[c] / vn; }
void lxi_n_d_wPE(unsigned int c) { gna[c] = vn / wna[c]; }
void lxi_n_d_wPZ(unsigned int c) { gna[c] = gna[c] / vn; }
void lxi_n_d_wTG(int c) { unsigned int i = guu; gn = vn / vna[i]; }
void lxi_n_d_wTX(int c) { unsigned int i = guu; gn = vna[i] / vn; }
void lxi_n_d_wTE(int c) { unsigned int i = guu; gna[i] = vn / wna[i]; }
void lxi_n_d_wTZ(int c) { unsigned int i = guu; gna[i] = gna[i] / vn; }
void lxi_n_d_wLG(int c) { unsigned int i; for (i = 0; i < 4; i++) gn = vn / vna[i]; }
void lxi_n_d_wLX(int c) { unsigned int i; for (i = 0; i < 4; i++) gn = vna[i] / vn; }
void lxi_n_d_wLE(int c) { unsigned int i; for (i = 0; i < 4; i++) gna[i] = vn / wna[i]; }
void lxi_n_d_wLZ(int c) { unsigned int i; for (i = 0; i < 4; i++) gna[i] = gna[i] / vn; }

void lxi_n_m_cPG(char c) { gn = vn % vna[c]; }
void lxi_n_m_cPX(char c) { gn = vna[c] % vn; }
void lxi_n_m_cPE(char c) { gna[c] = vn % wna[c]; }
void lxi_n_m_cPZ(char c) { gna[c] = gna[c] % vn; }
void lxi_n_m_cTG(int c) { char i = gcc; gn = vn % vna[i]; }
void lxi_n_m_cTX(int c) { char i = gcc; gn = vna[i] % vn; }
void lxi_n_m_cTE(int c) { char i = gcc; gna[i] = vn % wna[i]; }
void lxi_n_m_cTZ(int c) { char i = gcc; gna[i] = gna[i] % vn; }
void lxi_n_m_cLG(int c) { char i; for (i = 0; i < 4; i++) gn = vn % vna[i]; }
void lxi_n_m_cLX(int c) { char i; for (i = 0; i < 4; i++) gn = vna[i] % vn; }
void lxi_n_m_cLE(int c) { char i; for (i = 0; i < 4; i++) gna[i] = vn % wna[i]; }
void lxi_n_m_cLZ(int c) { char i; for (i = 0; i < 4; i++) gna[i] = gna[i] % vn; }
void lxi_n_m_uPG(unsigned char c) { gn = vn % vna[c]; }
void lxi_n_m_uPX(unsigned char c) { gn = vna[c] % vn; }
void lxi_n_m_uPE(unsigned char c) { gna[c] = vn % wna[c]; }
void lxi_n_m_uPZ(unsigned char c) { gna[c] = gna[c] % vn; }
void lxi_n_m_uTG(int c) { unsigned char i = guc; gn = vn % vna[i]; }
void lxi_n_m_uTX(int c) { unsigned char i = guc; gn = vna[i] % vn; }
void lxi_n_m_uTE(int c) { unsigned char i = guc; gna[i] = vn % wna[i]; }
void lxi_n_m_uTZ(int c) { unsigned char i = guc; gna[i] = gna[i] % vn; }
void lxi_n_m_uLG(int c) { unsigned char i; for (i = 0; i < 4; i++) gn = vn % vna[i]; }
void lxi_n_m_uLX(int c) { unsigned char i; for (i = 0; i < 4; i++) gn = vna[i] % vn; }
void lxi_n_m_uLE(int c) { unsigned char i; for (i = 0; i < 4; i++) gna[i] = vn % wna[i]; }
void lxi_n_m_uLZ(int c) { unsigned char i; for (i = 0; i < 4; i++) gna[i] = gna[i] % vn; }
void lxi_n_m_wPG(unsigned int c) { gn = vn % vna[c]; }
void lxi_n_m_wPX(unsigned int c) { gn = vna[c] % vn; }
void lxi_n_m_wPE(unsigned int c) { gna[c] = vn % wna[c]; }
void lxi_n_m_wPZ(unsigned int c) { gna[c] = gna[c] % vn; }
void lxi_n_m_wTG(int c) { unsigned int i = guu; gn = vn % vna[i]; }
void lxi_n_m_wTX(int c) { unsigned int i = guu; gn = vna[i] % vn; }
void lxi_n_m_wTE(int c) { unsigned int i = guu; gna[i] = vn % wna[i]; }
void lxi_n_m_wTZ(int c) { unsigned int i = guu; gna[i] = gna[i] % vn; }
void lxi_n_m_wLG(int c) { unsigned int i; for (i = 0; i < 4; i++) gn = vn % vna[i]; }
void lxi_n_m_wLX(int c) { unsigned int i; for (i = 0; i < 4; i++) gn = vna[i] % vn; }
void lxi_n_m_wLE(int c) { unsigned int i; for (i = 0; i < 4; i++) gna[i] = vn % wna[i]; }
void lxi_n_m_wLZ(int c) { unsigned int i; for (i = 0; i < 4; i++) gna[i] = gna[i] % vn; }

void lxi_n_x_cPG(char c) { gn = vn * vna[c]; }
void lxi_n_x_cPX(char c) { gn = vna[c] * vn; }
void lxi_n_x_cPE(char c) { gna[c] = vn * wna[c]; }
void lxi_n_x_cPZ(char c) { gna[c] = gna[c] * vn; }
void lxi_n_x_cTG(int c) { char i = gcc; gn = vn * vna[i]; }
void lxi_n_x_cTX(int c) { char i = gcc; gn = vna[i] * vn; }
void lxi_n_x_cTE(int c) { char i = gcc; gna[i] = vn * wna[i]; }
void lxi_n_x_cTZ(int c) { char i = gcc; gna[i] = gna[i] * vn; }
void lxi_n_x_cLG(int c) { char i; for (i = 0; i < 4; i++) gn = vn * vna[i]; }
void lxi_n_x_cLX(int c) { char i; for (i = 0; i < 4; i++) gn = vna[i] * vn; }
void lxi_n_x_cLE(int c) { char i; for (i = 0; i < 4; i++) gna[i] = vn * wna[i]; }
void lxi_n_x_cLZ(int c) { char i; for (i = 0; i < 4; i++) gna[i] = gna[i] * vn; }
void lxi_n_x_uPG(unsigned char c) { gn = vn * vna[c]; }
void lxi_n_x_uPX(unsigned char c) { gn = vna[c] * vn; }
void lxi_n_x_uPE(unsigned char c) { gna[c] = vn * wna[c]; }
void lxi_n_x_uPZ(unsigned char c) { gna[c] = gna[c] * vn; }
void lxi_n_x_uTG(int c) { unsigned char i = guc; gn = vn * vna[i]; }
void lxi_n_x_uTX(int c) { unsigned char i = guc; gn = vna[i] * vn; }
void lxi_n_x_uTE(int c) { unsigned char i = guc; gna[i] = vn * wna[i]; }
void lxi_n_x_uTZ(int c) { unsigned char i = guc; gna[i] = gna[i] * vn; }
void lxi_n_x_uLG(int c) { unsigned char i; for (i = 0; i < 4; i++) gn = vn * vna[i]; }
void lxi_n_x_uLX(int c) { unsigned char i; for (i = 0; i < 4; i++) gn = vna[i] * vn; }
void lxi_n_x_uLE(int c) { unsigned char i; for (i = 0; i < 4; i++) gna[i] = vn * wna[i]; }
void lxi_n_x_uLZ(int c) { unsigned char i; for (i = 0; i < 4; i++) gna[i] = gna[i] * vn; }
void lxi_n_x_wPG(unsigned int c) { gn = vn * vna[c]; }
void lxi_n_x_wPX(unsigned int c) { gn = vna[c] * vn; }
void lxi_n_x_wPE(unsigned int c) { gna[c] = vn * wna[c]; }
void lxi_n_x_wPZ(unsigned int c) { gna[c] = gna[c] * vn; }
void lxi_n_x_wTG(int c) { unsigned int i = guu; gn = vn * vna[i]; }
void lxi_n_x_wTX(int c) { unsigned int i = guu; gn = vna[i] * vn; }
void lxi_n_x_wTE(int c) { unsigned int i = guu; gna[i] = vn * wna[i]; }
void lxi_n_x_wTZ(int c) { unsigned int i = guu; gna[i] = gna[i] * vn; }
void lxi_n_x_wLG(int c) { unsigned int i; for (i = 0; i < 4; i++) gn = vn * vna[i]; }
void lxi_n_x_wLX(int c) { unsigned int i; for (i = 0; i < 4; i++) gn = vna[i] * vn; }
void lxi_n_x_wLE(int c) { unsigned int i; for (i = 0; i < 4; i++) gna[i] = vn * wna[i]; }
void lxi_n_x_wLZ(int c) { unsigned int i; for (i = 0; i < 4; i++) gna[i] = gna[i] * vn; }

void lxo_l_d_GPG(int c) { gl = *gpl / wl; }
void lxo_l_d_GPP(int c) { gl = *gpl / *gpl; }
void lxo_l_d_GPD(int c) { gl = *gpl / gps->l; }
void lxo_l_d_GPK(int c) { gl = *gpl / 7; }
void lxo_l_d_GPX(int c) { gl = *gpl / wla[c]; }
void lxo_l_d_GDG(int c) { gl = gps->l / wl; }
void lxo_l_d_GDP(int c) { gl = gps->l / *gpl; }
void lxo_l_d_GDD(int c) { gl = gps->l / gps->l; }
void lxo_l_d_GDK(int c) { gl = gps->l / 7; }
void lxo_l_d_GDX(int c) { gl = gps->l / wla[c]; }
void lxo_l_d_GEG(int c) { gl = vla[2] / wl; }
void lxo_l_d_GEP(int c) { gl = vla[2] / *gpl; }
void lxo_l_d_GED(int c) { gl = vla[2] / gps->l; }
void lxo_l_d_GEK(int c) { gl = vla[2] / 7; }
void lxo_l_d_GEX(int c) { gl = vla[2] / wla[c]; }
void lxo_l_d_GXG(int c) { gl = vla[c] / wl; }
void lxo_l_d_GXP(int c) { gl = vla[c] / *gpl; }
void lxo_l_d_GXD(int c) { gl = vla[c] / gps->l; }
void lxo_l_d_GXK(int c) { gl = vla[c] / 7; }
void lxo_l_d_GXX(int c) { gl = vla[c] / wla[c]; }
void lxo_l_d_PPG(int c) { *gpl = *gpl / wl; }
void lxo_l_d_PPP(int c) { *gpl = *gpl / *gpl; }
void lxo_l_d_PPD(int c) { *gpl = *gpl / gps->l; }
void lxo_l_d_PPK(int c) { *gpl = *gpl / 7; }
void lxo_l_d_PPX(int c) { *gpl = *gpl / wla[c]; }
void lxo_l_d_PDG(int c) { *gpl = gps->l / wl; }
void lxo_l_d_PDP(int c) { *gpl = gps->l / *gpl; }
void lxo_l_d_PDD(int c) { *gpl = gps->l / gps->l; }
void lxo_l_d_PDK(int c) { *gpl = gps->l / 7; }
void lxo_l_d_PDX(int c) { *gpl = gps->l / wla[c]; }
void lxo_l_d_PEG(int c) { *gpl = vla[2] / wl; }
void lxo_l_d_PEP(int c) { *gpl = vla[2] / *gpl; }
void lxo_l_d_PED(int c) { *gpl = vla[2] / gps->l; }
void lxo_l_d_PEK(int c) { *gpl = vla[2] / 7; }
void lxo_l_d_PEX(int c) { *gpl = vla[2] / wla[c]; }
void lxo_l_d_PXG(int c) { *gpl = vla[c] / wl; }
void lxo_l_d_PXP(int c) { *gpl = vla[c] / *gpl; }
void lxo_l_d_PXD(int c) { *gpl = vla[c] / gps->l; }
void lxo_l_d_PXK(int c) { *gpl = vla[c] / 7; }
void lxo_l_d_PXX(int c) { *gpl = vla[c] / wla[c]; }
void lxo_l_d_DPG(int c) { gps->l = *gpl / wl; }
void lxo_l_d_DPP(int c) { gps->l = *gpl / *gpl; }
void lxo_l_d_DPD(int c) { gps->l = *gpl / gps->l; }
void lxo_l_d_DPK(int c) { gps->l = *gpl / 7; }
void lxo_l_d_DPX(int c) { gps->l = *gpl / wla[c]; }
void lxo_l_d_DDG(int c) { gps->l = gps->l / wl; }
void lxo_l_d_DDP(int c) { gps->l = gps->l / *gpl; }
void lxo_l_d_DDD(int c) { gps->l = gps->l / gps->l; }
void lxo_l_d_DDK(int c) { gps->l = gps->l / 7; }
void lxo_l_d_DDX(int c) { gps->l = gps->l / wla[c]; }
void lxo_l_d_DEG(int c) { gps->l = vla[2] / wl; }
void lxo_l_d_DEP(int c) { gps->l = vla[2] / *gpl; }
void lxo_l_d_DED(int c) { gps->l = vla[2] / gps->l; }
void lxo_l_d_DEK(int c) { gps->l = vla[2] / 7; }
void lxo_l_d_DEX(int c) { gps->l = vla[2] / wla[c]; }
void lxo_l_d_DXG(int c) { gps->l = vla[c] / wl; }
void lxo_l_d_DXP(int c) { gps->l = vla[c] / *gpl; }
void lxo_l_d_DXD(int c) { gps->l = vla[c] / gps->l; }
void lxo_l_d_DXK(int c) { gps->l = vla[c] / 7; }
void lxo_l_d_DXX(int c) { gps->l = vla[c] / wla[c]; }
void lxo_l_d_XPG(int c) { gla[c] = *gpl / wl; }
void lxo_l_d_XPP(int c) { gla[c] = *gpl / *gpl; }
void lxo_l_d_XPD(int c) { gla[c] = *gpl / gps->l; }
void lxo_l_d_XPK(int c) { gla[c] = *gpl / 7; }
void lxo_l_d_XPX(int c) { gla[c] = *gpl / wla[c]; }
void lxo_l_d_XDG(int c) { gla[c] = gps->l / wl; }
void lxo_l_d_XDP(int c) { gla[c] = gps->l / *gpl; }
void lxo_l_d_XDD(int c) { gla[c] = gps->l / gps->l; }
void lxo_l_d_XDK(int c) { gla[c] = gps->l / 7; }
void lxo_l_d_XDX(int c) { gla[c] = gps->l / wla[c]; }
void lxo_l_d_XEG(int c) { gla[c] = vla[2] / wl; }
void lxo_l_d_XEP(int c) { gla[c] = vla[2] / *gpl; }
void lxo_l_d_XED(int c) { gla[c] = vla[2] / gps->l; }
void lxo_l_d_XEK(int c) { gla[c] = vla[2] / 7; }
void lxo_l_d_XEX(int c) { gla[c] = vla[2] / wla[c]; }
void lxo_l_d_XXG(int c) { gla[c] = vla[c] / wl; }
void lxo_l_d_XXP(int c) { gla[c] = vla[c] / *gpl; }
void lxo_l_d_XXD(int c) { gla[c] = vla[c] / gps->l; }
void lxo_l_d_XXK(int c) { gla[c] = vla[c] / 7; }
void lxo_l_d_XXX(int c) { gla[c] = vla[c] / wla[c]; }
long lxo_l_d_RPG(int c) { return *gpl / wl; }
long lxo_l_d_RPP(int c) { return *gpl / *gpl; }
long lxo_l_d_RPD(int c) { return *gpl / gps->l; }
long lxo_l_d_RPK(int c) { return *gpl / 7; }
long lxo_l_d_RPX(int c) { return *gpl / wla[c]; }
long lxo_l_d_RDG(int c) { return gps->l / wl; }
long lxo_l_d_RDP(int c) { return gps->l / *gpl; }
long lxo_l_d_RDD(int c) { return gps->l / gps->l; }
long lxo_l_d_RDK(int c) { return gps->l / 7; }
long lxo_l_d_RDX(int c) { return gps->l / wla[c]; }
long lxo_l_d_REG(int c) { return vla[2] / wl; }
long lxo_l_d_REP(int c) { return vla[2] / *gpl; }
long lxo_l_d_RED(int c) { return vla[2] / gps->l; }
long lxo_l_d_REK(int c) { return vla[2] / 7; }
long lxo_l_d_REX(int c) { return vla[2] / wla[c]; }
long lxo_l_d_RXG(int c) { return vla[c] / wl; }
long lxo_l_d_RXP(int c) { return vla[c] / *gpl; }
long lxo_l_d_RXD(int c) { return vla[c] / gps->l; }
long lxo_l_d_RXK(int c) { return vla[c] / 7; }
long lxo_l_d_RXX(int c) { return vla[c] / wla[c]; }
void lxo_l_d_APG(int c) { vvl(*gpl / wl); }
void lxo_l_d_APP(int c) { vvl(*gpl / *gpl); }
void lxo_l_d_APD(int c) { vvl(*gpl / gps->l); }
void lxo_l_d_APK(int c) { vvl(*gpl / 7); }
void lxo_l_d_APX(int c) { vvl(*gpl / wla[c]); }
void lxo_l_d_ADG(int c) { vvl(gps->l / wl); }
void lxo_l_d_ADP(int c) { vvl(gps->l / *gpl); }
void lxo_l_d_ADD(int c) { vvl(gps->l / gps->l); }
void lxo_l_d_ADK(int c) { vvl(gps->l / 7); }
void lxo_l_d_ADX(int c) { vvl(gps->l / wla[c]); }
void lxo_l_d_AEG(int c) { vvl(vla[2] / wl); }
void lxo_l_d_AEP(int c) { vvl(vla[2] / *gpl); }
void lxo_l_d_AED(int c) { vvl(vla[2] / gps->l); }
void lxo_l_d_AEK(int c) { vvl(vla[2] / 7); }
void lxo_l_d_AEX(int c) { vvl(vla[2] / wla[c]); }
void lxo_l_d_AXG(int c) { vvl(vla[c] / wl); }
void lxo_l_d_AXP(int c) { vvl(vla[c] / *gpl); }
void lxo_l_d_AXD(int c) { vvl(vla[c] / gps->l); }
void lxo_l_d_AXK(int c) { vvl(vla[c] / 7); }
void lxo_l_d_AXX(int c) { vvl(vla[c] / wla[c]); }
void lxo_l_d_QPG(int c) { if (*gpl / wl) gi = 1; }
void lxo_l_d_QPP(int c) { if (*gpl / *gpl) gi = 1; }
void lxo_l_d_QPD(int c) { if (*gpl / gps->l) gi = 1; }
void lxo_l_d_QPK(int c) { if (*gpl / 7) gi = 1; }
void lxo_l_d_QPX(int c) { if (*gpl / wla[c]) gi = 1; }
void lxo_l_d_QDG(int c) { if (gps->l / wl) gi = 1; }
void lxo_l_d_QDP(int c) { if (gps->l / *gpl) gi = 1; }
void lxo_l_d_QDD(int c) { if (gps->l / gps->l) gi = 1; }
void lxo_l_d_QDK(int c) { if (gps->l / 7) gi = 1; }
void lxo_l_d_QDX(int c) { if (gps->l / wla[c]) gi = 1; }
void lxo_l_d_QEG(int c) { if (vla[2] / wl) gi = 1; }
void lxo_l_d_QEP(int c) { if (vla[2] / *gpl) gi = 1; }
void lxo_l_d_QED(int c) { if (vla[2] / gps->l) gi = 1; }
void lxo_l_d_QEK(int c) { if (vla[2] / 7) gi = 1; }
void lxo_l_d_QEX(int c) { if (vla[2] / wla[c]) gi = 1; }
void lxo_l_d_QXG(int c) { if (vla[c] / wl) gi = 1; }
void lxo_l_d_QXP(int c) { if (vla[c] / *gpl) gi = 1; }
void lxo_l_d_QXD(int c) { if (vla[c] / gps->l) gi = 1; }
void lxo_l_d_QXK(int c) { if (vla[c] / 7) gi = 1; }
void lxo_l_d_QXX(int c) { if (vla[c] / wla[c]) gi = 1; }

void lxo_l_m_GPG(int c) { gl = *gpl % wl; }
void lxo_l_m_GPP(int c) { gl = *gpl % *gpl; }
void lxo_l_m_GPD(int c) { gl = *gpl % gps->l; }
void lxo_l_m_GPK(int c) { gl = *gpl % 7; }
void lxo_l_m_GPX(int c) { gl = *gpl % wla[c]; }
void lxo_l_m_GDG(int c) { gl = gps->l % wl; }
void lxo_l_m_GDP(int c) { gl = gps->l % *gpl; }
void lxo_l_m_GDD(int c) { gl = gps->l % gps->l; }
void lxo_l_m_GDK(int c) { gl = gps->l % 7; }
void lxo_l_m_GDX(int c) { gl = gps->l % wla[c]; }
void lxo_l_m_GEG(int c) { gl = vla[2] % wl; }
void lxo_l_m_GEP(int c) { gl = vla[2] % *gpl; }
void lxo_l_m_GED(int c) { gl = vla[2] % gps->l; }
void lxo_l_m_GEK(int c) { gl = vla[2] % 7; }
void lxo_l_m_GEX(int c) { gl = vla[2] % wla[c]; }
void lxo_l_m_GXG(int c) { gl = vla[c] % wl; }
void lxo_l_m_GXP(int c) { gl = vla[c] % *gpl; }
void lxo_l_m_GXD(int c) { gl = vla[c] % gps->l; }
void lxo_l_m_GXK(int c) { gl = vla[c] % 7; }
void lxo_l_m_GXX(int c) { gl = vla[c] % wla[c]; }
void lxo_l_m_PPG(int c) { *gpl = *gpl % wl; }
void lxo_l_m_PPP(int c) { *gpl = *gpl % *gpl; }
void lxo_l_m_PPD(int c) { *gpl = *gpl % gps->l; }
void lxo_l_m_PPK(int c) { *gpl = *gpl % 7; }
void lxo_l_m_PPX(int c) { *gpl = *gpl % wla[c]; }
void lxo_l_m_PDG(int c) { *gpl = gps->l % wl; }
void lxo_l_m_PDP(int c) { *gpl = gps->l % *gpl; }
void lxo_l_m_PDD(int c) { *gpl = gps->l % gps->l; }
void lxo_l_m_PDK(int c) { *gpl = gps->l % 7; }
void lxo_l_m_PDX(int c) { *gpl = gps->l % wla[c]; }
void lxo_l_m_PEG(int c) { *gpl = vla[2] % wl; }
void lxo_l_m_PEP(int c) { *gpl = vla[2] % *gpl; }
void lxo_l_m_PED(int c) { *gpl = vla[2] % gps->l; }
void lxo_l_m_PEK(int c) { *gpl = vla[2] % 7; }
void lxo_l_m_PEX(int c) { *gpl = vla[2] % wla[c]; }
void lxo_l_m_PXG(int c) { *gpl = vla[c] % wl; }
void lxo_l_m_PXP(int c) { *gpl = vla[c] % *gpl; }
void lxo_l_m_PXD(int c) { *gpl = vla[c] % gps->l; }
void lxo_l_m_PXK(int c) { *gpl = vla[c] % 7; }
void lxo_l_m_PXX(int c) { *gpl = vla[c] % wla[c]; }
void lxo_l_m_DPG(int c) { gps->l = *gpl % wl; }
void lxo_l_m_DPP(int c) { gps->l = *gpl % *gpl; }
void lxo_l_m_DPD(int c) { gps->l = *gpl % gps->l; }
void lxo_l_m_DPK(int c) { gps->l = *gpl % 7; }
void lxo_l_m_DPX(int c) { gps->l = *gpl % wla[c]; }
void lxo_l_m_DDG(int c) { gps->l = gps->l % wl; }
void lxo_l_m_DDP(int c) { gps->l = gps->l % *gpl; }
void lxo_l_m_DDD(int c) { gps->l = gps->l % gps->l; }
void lxo_l_m_DDK(int c) { gps->l = gps->l % 7; }
void lxo_l_m_DDX(int c) { gps->l = gps->l % wla[c]; }
void lxo_l_m_DEG(int c) { gps->l = vla[2] % wl; }
void lxo_l_m_DEP(int c) { gps->l = vla[2] % *gpl; }
void lxo_l_m_DED(int c) { gps->l = vla[2] % gps->l; }
void lxo_l_m_DEK(int c) { gps->l = vla[2] % 7; }
void lxo_l_m_DEX(int c) { gps->l = vla[2] % wla[c]; }
void lxo_l_m_DXG(int c) { gps->l = vla[c] % wl; }
void lxo_l_m_DXP(int c) { gps->l = vla[c] % *gpl; }
void lxo_l_m_DXD(int c) { gps->l = vla[c] % gps->l; }
void lxo_l_m_DXK(int c) { gps->l = vla[c] % 7; }
void lxo_l_m_DXX(int c) { gps->l = vla[c] % wla[c]; }
void lxo_l_m_XPG(int c) { gla[c] = *gpl % wl; }
void lxo_l_m_XPP(int c) { gla[c] = *gpl % *gpl; }
void lxo_l_m_XPD(int c) { gla[c] = *gpl % gps->l; }
void lxo_l_m_XPK(int c) { gla[c] = *gpl % 7; }
void lxo_l_m_XPX(int c) { gla[c] = *gpl % wla[c]; }
void lxo_l_m_XDG(int c) { gla[c] = gps->l % wl; }
void lxo_l_m_XDP(int c) { gla[c] = gps->l % *gpl; }
void lxo_l_m_XDD(int c) { gla[c] = gps->l % gps->l; }
void lxo_l_m_XDK(int c) { gla[c] = gps->l % 7; }
void lxo_l_m_XDX(int c) { gla[c] = gps->l % wla[c]; }
void lxo_l_m_XEG(int c) { gla[c] = vla[2] % wl; }
void lxo_l_m_XEP(int c) { gla[c] = vla[2] % *gpl; }
void lxo_l_m_XED(int c) { gla[c] = vla[2] % gps->l; }
void lxo_l_m_XEK(int c) { gla[c] = vla[2] % 7; }
void lxo_l_m_XEX(int c) { gla[c] = vla[2] % wla[c]; }
void lxo_l_m_XXG(int c) { gla[c] = vla[c] % wl; }
void lxo_l_m_XXP(int c) { gla[c] = vla[c] % *gpl; }
void lxo_l_m_XXD(int c) { gla[c] = vla[c] % gps->l; }
void lxo_l_m_XXK(int c) { gla[c] = vla[c] % 7; }
void lxo_l_m_XXX(int c) { gla[c] = vla[c] % wla[c]; }
long lxo_l_m_RPG(int c) { return *gpl % wl; }
long lxo_l_m_RPP(int c) { return *gpl % *gpl; }
long lxo_l_m_RPD(int c) { return *gpl % gps->l; }
long lxo_l_m_RPK(int c) { return *gpl % 7; }
long lxo_l_m_RPX(int c) { return *gpl % wla[c]; }
long lxo_l_m_RDG(int c) { return gps->l % wl; }
long lxo_l_m_RDP(int c) { return gps->l % *gpl; }
long lxo_l_m_RDD(int c) { return gps->l % gps->l; }
long lxo_l_m_RDK(int c) { return gps->l % 7; }
long lxo_l_m_RDX(int c) { return gps->l % wla[c]; }
long lxo_l_m_REG(int c) { return vla[2] % wl; }
long lxo_l_m_REP(int c) { return vla[2] % *gpl; }
long lxo_l_m_RED(int c) { return vla[2] % gps->l; }
long lxo_l_m_REK(int c) { return vla[2] % 7; }
long lxo_l_m_REX(int c) { return vla[2] % wla[c]; }
long lxo_l_m_RXG(int c) { return vla[c] % wl; }
long lxo_l_m_RXP(int c) { return vla[c] % *gpl; }
long lxo_l_m_RXD(int c) { return vla[c] % gps->l; }
long lxo_l_m_RXK(int c) { return vla[c] % 7; }
long lxo_l_m_RXX(int c) { return vla[c] % wla[c]; }
void lxo_l_m_APG(int c) { vvl(*gpl % wl); }
void lxo_l_m_APP(int c) { vvl(*gpl % *gpl); }
void lxo_l_m_APD(int c) { vvl(*gpl % gps->l); }
void lxo_l_m_APK(int c) { vvl(*gpl % 7); }
void lxo_l_m_APX(int c) { vvl(*gpl % wla[c]); }
void lxo_l_m_ADG(int c) { vvl(gps->l % wl); }
void lxo_l_m_ADP(int c) { vvl(gps->l % *gpl); }
void lxo_l_m_ADD(int c) { vvl(gps->l % gps->l); }
void lxo_l_m_ADK(int c) { vvl(gps->l % 7); }
void lxo_l_m_ADX(int c) { vvl(gps->l % wla[c]); }
void lxo_l_m_AEG(int c) { vvl(vla[2] % wl); }
void lxo_l_m_AEP(int c) { vvl(vla[2] % *gpl); }
void lxo_l_m_AED(int c) { vvl(vla[2] % gps->l); }
void lxo_l_m_AEK(int c) { vvl(vla[2] % 7); }
void lxo_l_m_AEX(int c) { vvl(vla[2] % wla[c]); }
void lxo_l_m_AXG(int c) { vvl(vla[c] % wl); }
void lxo_l_m_AXP(int c) { vvl(vla[c] % *gpl); }
void lxo_l_m_AXD(int c) { vvl(vla[c] % gps->l); }
void lxo_l_m_AXK(int c) { vvl(vla[c] % 7); }
void lxo_l_m_AXX(int c) { vvl(vla[c] % wla[c]); }
void lxo_l_m_QPG(int c) { if (*gpl % wl) gi = 1; }
void lxo_l_m_QPP(int c) { if (*gpl % *gpl) gi = 1; }
void lxo_l_m_QPD(int c) { if (*gpl % gps->l) gi = 1; }
void lxo_l_m_QPK(int c) { if (*gpl % 7) gi = 1; }
void lxo_l_m_QPX(int c) { if (*gpl % wla[c]) gi = 1; }
void lxo_l_m_QDG(int c) { if (gps->l % wl) gi = 1; }
void lxo_l_m_QDP(int c) { if (gps->l % *gpl) gi = 1; }
void lxo_l_m_QDD(int c) { if (gps->l % gps->l) gi = 1; }
void lxo_l_m_QDK(int c) { if (gps->l % 7) gi = 1; }
void lxo_l_m_QDX(int c) { if (gps->l % wla[c]) gi = 1; }
void lxo_l_m_QEG(int c) { if (vla[2] % wl) gi = 1; }
void lxo_l_m_QEP(int c) { if (vla[2] % *gpl) gi = 1; }
void lxo_l_m_QED(int c) { if (vla[2] % gps->l) gi = 1; }
void lxo_l_m_QEK(int c) { if (vla[2] % 7) gi = 1; }
void lxo_l_m_QEX(int c) { if (vla[2] % wla[c]) gi = 1; }
void lxo_l_m_QXG(int c) { if (vla[c] % wl) gi = 1; }
void lxo_l_m_QXP(int c) { if (vla[c] % *gpl) gi = 1; }
void lxo_l_m_QXD(int c) { if (vla[c] % gps->l) gi = 1; }
void lxo_l_m_QXK(int c) { if (vla[c] % 7) gi = 1; }
void lxo_l_m_QXX(int c) { if (vla[c] % wla[c]) gi = 1; }

void lxo_l_x_GPG(int c) { gl = *gpl * wl; }
void lxo_l_x_GPP(int c) { gl = *gpl * *gpl; }
void lxo_l_x_GPD(int c) { gl = *gpl * gps->l; }
void lxo_l_x_GPK(int c) { gl = *gpl * 7; }
void lxo_l_x_GPX(int c) { gl = *gpl * wla[c]; }
void lxo_l_x_GDG(int c) { gl = gps->l * wl; }
void lxo_l_x_GDP(int c) { gl = gps->l * *gpl; }
void lxo_l_x_GDD(int c) { gl = gps->l * gps->l; }
void lxo_l_x_GDK(int c) { gl = gps->l * 7; }
void lxo_l_x_GDX(int c) { gl = gps->l * wla[c]; }
void lxo_l_x_GEG(int c) { gl = vla[2] * wl; }
void lxo_l_x_GEP(int c) { gl = vla[2] * *gpl; }
void lxo_l_x_GED(int c) { gl = vla[2] * gps->l; }
void lxo_l_x_GEK(int c) { gl = vla[2] * 7; }
void lxo_l_x_GEX(int c) { gl = vla[2] * wla[c]; }
void lxo_l_x_GXG(int c) { gl = vla[c] * wl; }
void lxo_l_x_GXP(int c) { gl = vla[c] * *gpl; }
void lxo_l_x_GXD(int c) { gl = vla[c] * gps->l; }
void lxo_l_x_GXK(int c) { gl = vla[c] * 7; }
void lxo_l_x_GXX(int c) { gl = vla[c] * wla[c]; }
void lxo_l_x_PPG(int c) { *gpl = *gpl * wl; }
void lxo_l_x_PPP(int c) { *gpl = *gpl * *gpl; }
void lxo_l_x_PPD(int c) { *gpl = *gpl * gps->l; }
void lxo_l_x_PPK(int c) { *gpl = *gpl * 7; }
void lxo_l_x_PPX(int c) { *gpl = *gpl * wla[c]; }
void lxo_l_x_PDG(int c) { *gpl = gps->l * wl; }
void lxo_l_x_PDP(int c) { *gpl = gps->l * *gpl; }
void lxo_l_x_PDD(int c) { *gpl = gps->l * gps->l; }
void lxo_l_x_PDK(int c) { *gpl = gps->l * 7; }
void lxo_l_x_PDX(int c) { *gpl = gps->l * wla[c]; }
void lxo_l_x_PEG(int c) { *gpl = vla[2] * wl; }
void lxo_l_x_PEP(int c) { *gpl = vla[2] * *gpl; }
void lxo_l_x_PED(int c) { *gpl = vla[2] * gps->l; }
void lxo_l_x_PEK(int c) { *gpl = vla[2] * 7; }
void lxo_l_x_PEX(int c) { *gpl = vla[2] * wla[c]; }
void lxo_l_x_PXG(int c) { *gpl = vla[c] * wl; }
void lxo_l_x_PXP(int c) { *gpl = vla[c] * *gpl; }
void lxo_l_x_PXD(int c) { *gpl = vla[c] * gps->l; }
void lxo_l_x_PXK(int c) { *gpl = vla[c] * 7; }
void lxo_l_x_PXX(int c) { *gpl = vla[c] * wla[c]; }
void lxo_l_x_DPG(int c) { gps->l = *gpl * wl; }
void lxo_l_x_DPP(int c) { gps->l = *gpl * *gpl; }
void lxo_l_x_DPD(int c) { gps->l = *gpl * gps->l; }
void lxo_l_x_DPK(int c) { gps->l = *gpl * 7; }
void lxo_l_x_DPX(int c) { gps->l = *gpl * wla[c]; }
void lxo_l_x_DDG(int c) { gps->l = gps->l * wl; }
void lxo_l_x_DDP(int c) { gps->l = gps->l * *gpl; }
void lxo_l_x_DDD(int c) { gps->l = gps->l * gps->l; }
void lxo_l_x_DDK(int c) { gps->l = gps->l * 7; }
void lxo_l_x_DDX(int c) { gps->l = gps->l * wla[c]; }
void lxo_l_x_DEG(int c) { gps->l = vla[2] * wl; }
void lxo_l_x_DEP(int c) { gps->l = vla[2] * *gpl; }
void lxo_l_x_DED(int c) { gps->l = vla[2] * gps->l; }
void lxo_l_x_DEK(int c) { gps->l = vla[2] * 7; }
void lxo_l_x_DEX(int c) { gps->l = vla[2] * wla[c]; }
void lxo_l_x_DXG(int c) { gps->l = vla[c] * wl; }
void lxo_l_x_DXP(int c) { gps->l = vla[c] * *gpl; }
void lxo_l_x_DXD(int c) { gps->l = vla[c] * gps->l; }
void lxo_l_x_DXK(int c) { gps->l = vla[c] * 7; }
void lxo_l_x_DXX(int c) { gps->l = vla[c] * wla[c]; }
void lxo_l_x_XPG(int c) { gla[c] = *gpl * wl; }
void lxo_l_x_XPP(int c) { gla[c] = *gpl * *gpl; }
void lxo_l_x_XPD(int c) { gla[c] = *gpl * gps->l; }
void lxo_l_x_XPK(int c) { gla[c] = *gpl * 7; }
void lxo_l_x_XPX(int c) { gla[c] = *gpl * wla[c]; }
void lxo_l_x_XDG(int c) { gla[c] = gps->l * wl; }
void lxo_l_x_XDP(int c) { gla[c] = gps->l * *gpl; }
void lxo_l_x_XDD(int c) { gla[c] = gps->l * gps->l; }
void lxo_l_x_XDK(int c) { gla[c] = gps->l * 7; }
void lxo_l_x_XDX(int c) { gla[c] = gps->l * wla[c]; }
void lxo_l_x_XEG(int c) { gla[c] = vla[2] * wl; }
void lxo_l_x_XEP(int c) { gla[c] = vla[2] * *gpl; }
void lxo_l_x_XED(int c) { gla[c] = vla[2] * gps->l; }
void lxo_l_x_XEK(int c) { gla[c] = vla[2] * 7; }
void lxo_l_x_XEX(int c) { gla[c] = vla[2] * wla[c]; }
void lxo_l_x_XXG(int c) { gla[c] = vla[c] * wl; }
void lxo_l_x_XXP(int c) { gla[c] = vla[c] * *gpl; }
void lxo_l_x_XXD(int c) { gla[c] = vla[c] * gps->l; }
void lxo_l_x_XXK(int c) { gla[c] = vla[c] * 7; }
void lxo_l_x_XXX(int c) { gla[c] = vla[c] * wla[c]; }
long lxo_l_x_RPG(int c) { return *gpl * wl; }
long lxo_l_x_RPP(int c) { return *gpl * *gpl; }
long lxo_l_x_RPD(int c) { return *gpl * gps->l; }
long lxo_l_x_RPK(int c) { return *gpl * 7; }
long lxo_l_x_RPX(int c) { return *gpl * wla[c]; }
long lxo_l_x_RDG(int c) { return gps->l * wl; }
long lxo_l_x_RDP(int c) { return gps->l * *gpl; }
long lxo_l_x_RDD(int c) { return gps->l * gps->l; }
long lxo_l_x_RDK(int c) { return gps->l * 7; }
long lxo_l_x_RDX(int c) { return gps->l * wla[c]; }
long lxo_l_x_REG(int c) { return vla[2] * wl; }
long lxo_l_x_REP(int c) { return vla[2] * *gpl; }
long lxo_l_x_RED(int c) { return vla[2] * gps->l; }
long lxo_l_x_REK(int c) { return vla[2] * 7; }
long lxo_l_x_REX(int c) { return vla[2] * wla[c]; }
long lxo_l_x_RXG(int c) { return vla[c] * wl; }
long lxo_l_x_RXP(int c) { return vla[c] * *gpl; }
long lxo_l_x_RXD(int c) { return vla[c] * gps->l; }
long lxo_l_x_RXK(int c) { return vla[c] * 7; }
long lxo_l_x_RXX(int c) { return vla[c] * wla[c]; }
void lxo_l_x_APG(int c) { vvl(*gpl * wl); }
void lxo_l_x_APP(int c) { vvl(*gpl * *gpl); }
void lxo_l_x_APD(int c) { vvl(*gpl * gps->l); }
void lxo_l_x_APK(int c) { vvl(*gpl * 7); }
void lxo_l_x_APX(int c) { vvl(*gpl * wla[c]); }
void lxo_l_x_ADG(int c) { vvl(gps->l * wl); }
void lxo_l_x_ADP(int c) { vvl(gps->l * *gpl); }
void lxo_l_x_ADD(int c) { vvl(gps->l * gps->l); }
void lxo_l_x_ADK(int c) { vvl(gps->l * 7); }
void lxo_l_x_ADX(int c) { vvl(gps->l * wla[c]); }
void lxo_l_x_AEG(int c) { vvl(vla[2] * wl); }
void lxo_l_x_AEP(int c) { vvl(vla[2] * *gpl); }
void lxo_l_x_AED(int c) { vvl(vla[2] * gps->l); }
void lxo_l_x_AEK(int c) { vvl(vla[2] * 7); }
void lxo_l_x_AEX(int c) { vvl(vla[2] * wla[c]); }
void lxo_l_x_AXG(int c) { vvl(vla[c] * wl); }
void lxo_l_x_AXP(int c) { vvl(vla[c] * *gpl); }
void lxo_l_x_AXD(int c) { vvl(vla[c] * gps->l); }
void lxo_l_x_AXK(int c) { vvl(vla[c] * 7); }
void lxo_l_x_AXX(int c) { vvl(vla[c] * wla[c]); }
void lxo_l_x_QPG(int c) { if (*gpl * wl) gi = 1; }
void lxo_l_x_QPP(int c) { if (*gpl * *gpl) gi = 1; }
void lxo_l_x_QPD(int c) { if (*gpl * gps->l) gi = 1; }
void lxo_l_x_QPK(int c) { if (*gpl * 7) gi = 1; }
void lxo_l_x_QPX(int c) { if (*gpl * wla[c]) gi = 1; }
void lxo_l_x_QDG(int c) { if (gps->l * wl) gi = 1; }
void lxo_l_x_QDP(int c) { if (gps->l * *gpl) gi = 1; }
void lxo_l_x_QDD(int c) { if (gps->l * gps->l) gi = 1; }
void lxo_l_x_QDK(int c) { if (gps->l * 7) gi = 1; }
void lxo_l_x_QDX(int c) { if (gps->l * wla[c]) gi = 1; }
void lxo_l_x_QEG(int c) { if (vla[2] * wl) gi = 1; }
void lxo_l_x_QEP(int c) { if (vla[2] * *gpl) gi = 1; }
void lxo_l_x_QED(int c) { if (vla[2] * gps->l) gi = 1; }
void lxo_l_x_QEK(int c) { if (vla[2] * 7) gi = 1; }
void lxo_l_x_QEX(int c) { if (vla[2] * wla[c]) gi = 1; }
void lxo_l_x_QXG(int c) { if (vla[c] * wl) gi = 1; }
void lxo_l_x_QXP(int c) { if (vla[c] * *gpl) gi = 1; }
void lxo_l_x_QXD(int c) { if (vla[c] * gps->l) gi = 1; }
void lxo_l_x_QXK(int c) { if (vla[c] * 7) gi = 1; }
void lxo_l_x_QXX(int c) { if (vla[c] * wla[c]) gi = 1; }

void lxo_n_d_GPG(int c) { gn = *gpn / wn; }
void lxo_n_d_GPP(int c) { gn = *gpn / *gpn; }
void lxo_n_d_GPD(int c) { gn = *gpn / gps->n; }
void lxo_n_d_GPK(int c) { gn = *gpn / 7; }
void lxo_n_d_GPX(int c) { gn = *gpn / wna[c]; }
void lxo_n_d_GDG(int c) { gn = gps->n / wn; }
void lxo_n_d_GDP(int c) { gn = gps->n / *gpn; }
void lxo_n_d_GDD(int c) { gn = gps->n / gps->n; }
void lxo_n_d_GDK(int c) { gn = gps->n / 7; }
void lxo_n_d_GDX(int c) { gn = gps->n / wna[c]; }
void lxo_n_d_GEG(int c) { gn = vna[2] / wn; }
void lxo_n_d_GEP(int c) { gn = vna[2] / *gpn; }
void lxo_n_d_GED(int c) { gn = vna[2] / gps->n; }
void lxo_n_d_GEK(int c) { gn = vna[2] / 7; }
void lxo_n_d_GEX(int c) { gn = vna[2] / wna[c]; }
void lxo_n_d_GXG(int c) { gn = vna[c] / wn; }
void lxo_n_d_GXP(int c) { gn = vna[c] / *gpn; }
void lxo_n_d_GXD(int c) { gn = vna[c] / gps->n; }
void lxo_n_d_GXK(int c) { gn = vna[c] / 7; }
void lxo_n_d_GXX(int c) { gn = vna[c] / wna[c]; }
void lxo_n_d_PPG(int c) { *gpn = *gpn / wn; }
void lxo_n_d_PPP(int c) { *gpn = *gpn / *gpn; }
void lxo_n_d_PPD(int c) { *gpn = *gpn / gps->n; }
void lxo_n_d_PPK(int c) { *gpn = *gpn / 7; }
void lxo_n_d_PPX(int c) { *gpn = *gpn / wna[c]; }
void lxo_n_d_PDG(int c) { *gpn = gps->n / wn; }
void lxo_n_d_PDP(int c) { *gpn = gps->n / *gpn; }
void lxo_n_d_PDD(int c) { *gpn = gps->n / gps->n; }
void lxo_n_d_PDK(int c) { *gpn = gps->n / 7; }
void lxo_n_d_PDX(int c) { *gpn = gps->n / wna[c]; }
void lxo_n_d_PEG(int c) { *gpn = vna[2] / wn; }
void lxo_n_d_PEP(int c) { *gpn = vna[2] / *gpn; }
void lxo_n_d_PED(int c) { *gpn = vna[2] / gps->n; }
void lxo_n_d_PEK(int c) { *gpn = vna[2] / 7; }
void lxo_n_d_PEX(int c) { *gpn = vna[2] / wna[c]; }
void lxo_n_d_PXG(int c) { *gpn = vna[c] / wn; }
void lxo_n_d_PXP(int c) { *gpn = vna[c] / *gpn; }
void lxo_n_d_PXD(int c) { *gpn = vna[c] / gps->n; }
void lxo_n_d_PXK(int c) { *gpn = vna[c] / 7; }
void lxo_n_d_PXX(int c) { *gpn = vna[c] / wna[c]; }
void lxo_n_d_DPG(int c) { gps->n = *gpn / wn; }
void lxo_n_d_DPP(int c) { gps->n = *gpn / *gpn; }
void lxo_n_d_DPD(int c) { gps->n = *gpn / gps->n; }
void lxo_n_d_DPK(int c) { gps->n = *gpn / 7; }
void lxo_n_d_DPX(int c) { gps->n = *gpn / wna[c]; }
void lxo_n_d_DDG(int c) { gps->n = gps->n / wn; }
void lxo_n_d_DDP(int c) { gps->n = gps->n / *gpn; }
void lxo_n_d_DDD(int c) { gps->n = gps->n / gps->n; }
void lxo_n_d_DDK(int c) { gps->n = gps->n / 7; }
void lxo_n_d_DDX(int c) { gps->n = gps->n / wna[c]; }
void lxo_n_d_DEG(int c) { gps->n = vna[2] / wn; }
void lxo_n_d_DEP(int c) { gps->n = vna[2] / *gpn; }
void lxo_n_d_DED(int c) { gps->n = vna[2] / gps->n; }
void lxo_n_d_DEK(int c) { gps->n = vna[2] / 7; }
void lxo_n_d_DEX(int c) { gps->n = vna[2] / wna[c]; }
void lxo_n_d_DXG(int c) { gps->n = vna[c] / wn; }
void lxo_n_d_DXP(int c) { gps->n = vna[c] / *gpn; }
void lxo_n_d_DXD(int c) { gps->n = vna[c] / gps->n; }
void lxo_n_d_DXK(int c) { gps->n = vna[c] / 7; }
void lxo_n_d_DXX(int c) { gps->n = vna[c] / wna[c]; }
void lxo_n_d_XPG(int c) { gna[c] = *gpn / wn; }
void lxo_n_d_XPP(int c) { gna[c] = *gpn / *gpn; }
void lxo_n_d_XPD(int c) { gna[c] = *gpn / gps->n; }
void lxo_n_d_XPK(int c) { gna[c] = *gpn / 7; }
void lxo_n_d_XPX(int c) { gna[c] = *gpn / wna[c]; }
void lxo_n_d_XDG(int c) { gna[c] = gps->n / wn; }
void lxo_n_d_XDP(int c) { gna[c] = gps->n / *gpn; }
void lxo_n_d_XDD(int c) { gna[c] = gps->n / gps->n; }
void lxo_n_d_XDK(int c) { gna[c] = gps->n / 7; }
void lxo_n_d_XDX(int c) { gna[c] = gps->n / wna[c]; }
void lxo_n_d_XEG(int c) { gna[c] = vna[2] / wn; }
void lxo_n_d_XEP(int c) { gna[c] = vna[2] / *gpn; }
void lxo_n_d_XED(int c) { gna[c] = vna[2] / gps->n; }
void lxo_n_d_XEK(int c) { gna[c] = vna[2] / 7; }
void lxo_n_d_XEX(int c) { gna[c] = vna[2] / wna[c]; }
void lxo_n_d_XXG(int c) { gna[c] = vna[c] / wn; }
void lxo_n_d_XXP(int c) { gna[c] = vna[c] / *gpn; }
void lxo_n_d_XXD(int c) { gna[c] = vna[c] / gps->n; }
void lxo_n_d_XXK(int c) { gna[c] = vna[c] / 7; }
void lxo_n_d_XXX(int c) { gna[c] = vna[c] / wna[c]; }
unsigned long lxo_n_d_RPG(int c) { return *gpn / wn; }
unsigned long lxo_n_d_RPP(int c) { return *gpn / *gpn; }
unsigned long lxo_n_d_RPD(int c) { return *gpn / gps->n; }
unsigned long lxo_n_d_RPK(int c) { return *gpn / 7; }
unsigned long lxo_n_d_RPX(int c) { return *gpn / wna[c]; }
unsigned long lxo_n_d_RDG(int c) { return gps->n / wn; }
unsigned long lxo_n_d_RDP(int c) { return gps->n / *gpn; }
unsigned long lxo_n_d_RDD(int c) { return gps->n / gps->n; }
unsigned long lxo_n_d_RDK(int c) { return gps->n / 7; }
unsigned long lxo_n_d_RDX(int c) { return gps->n / wna[c]; }
unsigned long lxo_n_d_REG(int c) { return vna[2] / wn; }
unsigned long lxo_n_d_REP(int c) { return vna[2] / *gpn; }
unsigned long lxo_n_d_RED(int c) { return vna[2] / gps->n; }
unsigned long lxo_n_d_REK(int c) { return vna[2] / 7; }
unsigned long lxo_n_d_REX(int c) { return vna[2] / wna[c]; }
unsigned long lxo_n_d_RXG(int c) { return vna[c] / wn; }
unsigned long lxo_n_d_RXP(int c) { return vna[c] / *gpn; }
unsigned long lxo_n_d_RXD(int c) { return vna[c] / gps->n; }
unsigned long lxo_n_d_RXK(int c) { return vna[c] / 7; }
unsigned long lxo_n_d_RXX(int c) { return vna[c] / wna[c]; }
void lxo_n_d_APG(int c) { vvn(*gpn / wn); }
void lxo_n_d_APP(int c) { vvn(*gpn / *gpn); }
void lxo_n_d_APD(int c) { vvn(*gpn / gps->n); }
void lxo_n_d_APK(int c) { vvn(*gpn / 7); }
void lxo_n_d_APX(int c) { vvn(*gpn / wna[c]); }
void lxo_n_d_ADG(int c) { vvn(gps->n / wn); }
void lxo_n_d_ADP(int c) { vvn(gps->n / *gpn); }
void lxo_n_d_ADD(int c) { vvn(gps->n / gps->n); }
void lxo_n_d_ADK(int c) { vvn(gps->n / 7); }
void lxo_n_d_ADX(int c) { vvn(gps->n / wna[c]); }
void lxo_n_d_AEG(int c) { vvn(vna[2] / wn); }
void lxo_n_d_AEP(int c) { vvn(vna[2] / *gpn); }
void lxo_n_d_AED(int c) { vvn(vna[2] / gps->n); }
void lxo_n_d_AEK(int c) { vvn(vna[2] / 7); }
void lxo_n_d_AEX(int c) { vvn(vna[2] / wna[c]); }
void lxo_n_d_AXG(int c) { vvn(vna[c] / wn); }
void lxo_n_d_AXP(int c) { vvn(vna[c] / *gpn); }
void lxo_n_d_AXD(int c) { vvn(vna[c] / gps->n); }
void lxo_n_d_AXK(int c) { vvn(vna[c] / 7); }
void lxo_n_d_AXX(int c) { vvn(vna[c] / wna[c]); }
void lxo_n_d_QPG(int c) { if (*gpn / wn) gi = 1; }
void lxo_n_d_QPP(int c) { if (*gpn / *gpn) gi = 1; }
void lxo_n_d_QPD(int c) { if (*gpn / gps->n) gi = 1; }
void lxo_n_d_QPK(int c) { if (*gpn / 7) gi = 1; }
void lxo_n_d_QPX(int c) { if (*gpn / wna[c]) gi = 1; }
void lxo_n_d_QDG(int c) { if (gps->n / wn) gi = 1; }
void lxo_n_d_QDP(int c) { if (gps->n / *gpn) gi = 1; }
void lxo_n_d_QDD(int c) { if (gps->n / gps->n) gi = 1; }
void lxo_n_d_QDK(int c) { if (gps->n / 7) gi = 1; }
void lxo_n_d_QDX(int c) { if (gps->n / wna[c]) gi = 1; }
void lxo_n_d_QEG(int c) { if (vna[2] / wn) gi = 1; }
void lxo_n_d_QEP(int c) { if (vna[2] / *gpn) gi = 1; }
void lxo_n_d_QED(int c) { if (vna[2] / gps->n) gi = 1; }
void lxo_n_d_QEK(int c) { if (vna[2] / 7) gi = 1; }
void lxo_n_d_QEX(int c) { if (vna[2] / wna[c]) gi = 1; }
void lxo_n_d_QXG(int c) { if (vna[c] / wn) gi = 1; }
void lxo_n_d_QXP(int c) { if (vna[c] / *gpn) gi = 1; }
void lxo_n_d_QXD(int c) { if (vna[c] / gps->n) gi = 1; }
void lxo_n_d_QXK(int c) { if (vna[c] / 7) gi = 1; }
void lxo_n_d_QXX(int c) { if (vna[c] / wna[c]) gi = 1; }

void lxo_n_m_GPG(int c) { gn = *gpn % wn; }
void lxo_n_m_GPP(int c) { gn = *gpn % *gpn; }
void lxo_n_m_GPD(int c) { gn = *gpn % gps->n; }
void lxo_n_m_GPK(int c) { gn = *gpn % 7; }
void lxo_n_m_GPX(int c) { gn = *gpn % wna[c]; }
void lxo_n_m_GDG(int c) { gn = gps->n % wn; }
void lxo_n_m_GDP(int c) { gn = gps->n % *gpn; }
void lxo_n_m_GDD(int c) { gn = gps->n % gps->n; }
void lxo_n_m_GDK(int c) { gn = gps->n % 7; }
void lxo_n_m_GDX(int c) { gn = gps->n % wna[c]; }
void lxo_n_m_GEG(int c) { gn = vna[2] % wn; }
void lxo_n_m_GEP(int c) { gn = vna[2] % *gpn; }
void lxo_n_m_GED(int c) { gn = vna[2] % gps->n; }
void lxo_n_m_GEK(int c) { gn = vna[2] % 7; }
void lxo_n_m_GEX(int c) { gn = vna[2] % wna[c]; }
void lxo_n_m_GXG(int c) { gn = vna[c] % wn; }
void lxo_n_m_GXP(int c) { gn = vna[c] % *gpn; }
void lxo_n_m_GXD(int c) { gn = vna[c] % gps->n; }
void lxo_n_m_GXK(int c) { gn = vna[c] % 7; }
void lxo_n_m_GXX(int c) { gn = vna[c] % wna[c]; }
void lxo_n_m_PPG(int c) { *gpn = *gpn % wn; }
void lxo_n_m_PPP(int c) { *gpn = *gpn % *gpn; }
void lxo_n_m_PPD(int c) { *gpn = *gpn % gps->n; }
void lxo_n_m_PPK(int c) { *gpn = *gpn % 7; }
void lxo_n_m_PPX(int c) { *gpn = *gpn % wna[c]; }
void lxo_n_m_PDG(int c) { *gpn = gps->n % wn; }
void lxo_n_m_PDP(int c) { *gpn = gps->n % *gpn; }
void lxo_n_m_PDD(int c) { *gpn = gps->n % gps->n; }
void lxo_n_m_PDK(int c) { *gpn = gps->n % 7; }
void lxo_n_m_PDX(int c) { *gpn = gps->n % wna[c]; }
void lxo_n_m_PEG(int c) { *gpn = vna[2] % wn; }
void lxo_n_m_PEP(int c) { *gpn = vna[2] % *gpn; }
void lxo_n_m_PED(int c) { *gpn = vna[2] % gps->n; }
void lxo_n_m_PEK(int c) { *gpn = vna[2] % 7; }
void lxo_n_m_PEX(int c) { *gpn = vna[2] % wna[c]; }
void lxo_n_m_PXG(int c) { *gpn = vna[c] % wn; }
void lxo_n_m_PXP(int c) { *gpn = vna[c] % *gpn; }
void lxo_n_m_PXD(int c) { *gpn = vna[c] % gps->n; }
void lxo_n_m_PXK(int c) { *gpn = vna[c] % 7; }
void lxo_n_m_PXX(int c) { *gpn = vna[c] % wna[c]; }
void lxo_n_m_DPG(int c) { gps->n = *gpn % wn; }
void lxo_n_m_DPP(int c) { gps->n = *gpn % *gpn; }
void lxo_n_m_DPD(int c) { gps->n = *gpn % gps->n; }
void lxo_n_m_DPK(int c) { gps->n = *gpn % 7; }
void lxo_n_m_DPX(int c) { gps->n = *gpn % wna[c]; }
void lxo_n_m_DDG(int c) { gps->n = gps->n % wn; }
void lxo_n_m_DDP(int c) { gps->n = gps->n % *gpn; }
void lxo_n_m_DDD(int c) { gps->n = gps->n % gps->n; }
void lxo_n_m_DDK(int c) { gps->n = gps->n % 7; }
void lxo_n_m_DDX(int c) { gps->n = gps->n % wna[c]; }
void lxo_n_m_DEG(int c) { gps->n = vna[2] % wn; }
void lxo_n_m_DEP(int c) { gps->n = vna[2] % *gpn; }
void lxo_n_m_DED(int c) { gps->n = vna[2] % gps->n; }
void lxo_n_m_DEK(int c) { gps->n = vna[2] % 7; }
void lxo_n_m_DEX(int c) { gps->n = vna[2] % wna[c]; }
void lxo_n_m_DXG(int c) { gps->n = vna[c] % wn; }
void lxo_n_m_DXP(int c) { gps->n = vna[c] % *gpn; }
void lxo_n_m_DXD(int c) { gps->n = vna[c] % gps->n; }
void lxo_n_m_DXK(int c) { gps->n = vna[c] % 7; }
void lxo_n_m_DXX(int c) { gps->n = vna[c] % wna[c]; }
void lxo_n_m_XPG(int c) { gna[c] = *gpn % wn; }
void lxo_n_m_XPP(int c) { gna[c] = *gpn % *gpn; }
void lxo_n_m_XPD(int c) { gna[c] = *gpn % gps->n; }
void lxo_n_m_XPK(int c) { gna[c] = *gpn % 7; }
void lxo_n_m_XPX(int c) { gna[c] = *gpn % wna[c]; }
void lxo_n_m_XDG(int c) { gna[c] = gps->n % wn; }
void lxo_n_m_XDP(int c) { gna[c] = gps->n % *gpn; }
void lxo_n_m_XDD(int c) { gna[c] = gps->n % gps->n; }
void lxo_n_m_XDK(int c) { gna[c] = gps->n % 7; }
void lxo_n_m_XDX(int c) { gna[c] = gps->n % wna[c]; }
void lxo_n_m_XEG(int c) { gna[c] = vna[2] % wn; }
void lxo_n_m_XEP(int c) { gna[c] = vna[2] % *gpn; }
void lxo_n_m_XED(int c) { gna[c] = vna[2] % gps->n; }
void lxo_n_m_XEK(int c) { gna[c] = vna[2] % 7; }
void lxo_n_m_XEX(int c) { gna[c] = vna[2] % wna[c]; }
void lxo_n_m_XXG(int c) { gna[c] = vna[c] % wn; }
void lxo_n_m_XXP(int c) { gna[c] = vna[c] % *gpn; }
void lxo_n_m_XXD(int c) { gna[c] = vna[c] % gps->n; }
void lxo_n_m_XXK(int c) { gna[c] = vna[c] % 7; }
void lxo_n_m_XXX(int c) { gna[c] = vna[c] % wna[c]; }
unsigned long lxo_n_m_RPG(int c) { return *gpn % wn; }
unsigned long lxo_n_m_RPP(int c) { return *gpn % *gpn; }
unsigned long lxo_n_m_RPD(int c) { return *gpn % gps->n; }
unsigned long lxo_n_m_RPK(int c) { return *gpn % 7; }
unsigned long lxo_n_m_RPX(int c) { return *gpn % wna[c]; }
unsigned long lxo_n_m_RDG(int c) { return gps->n % wn; }
unsigned long lxo_n_m_RDP(int c) { return gps->n % *gpn; }
unsigned long lxo_n_m_RDD(int c) { return gps->n % gps->n; }
unsigned long lxo_n_m_RDK(int c) { return gps->n % 7; }
unsigned long lxo_n_m_RDX(int c) { return gps->n % wna[c]; }
unsigned long lxo_n_m_REG(int c) { return vna[2] % wn; }
unsigned long lxo_n_m_REP(int c) { return vna[2] % *gpn; }
unsigned long lxo_n_m_RED(int c) { return vna[2] % gps->n; }
unsigned long lxo_n_m_REK(int c) { return vna[2] % 7; }
unsigned long lxo_n_m_REX(int c) { return vna[2] % wna[c]; }
unsigned long lxo_n_m_RXG(int c) { return vna[c] % wn; }
unsigned long lxo_n_m_RXP(int c) { return vna[c] % *gpn; }
unsigned long lxo_n_m_RXD(int c) { return vna[c] % gps->n; }
unsigned long lxo_n_m_RXK(int c) { return vna[c] % 7; }
unsigned long lxo_n_m_RXX(int c) { return vna[c] % wna[c]; }
void lxo_n_m_APG(int c) { vvn(*gpn % wn); }
void lxo_n_m_APP(int c) { vvn(*gpn % *gpn); }
void lxo_n_m_APD(int c) { vvn(*gpn % gps->n); }
void lxo_n_m_APK(int c) { vvn(*gpn % 7); }
void lxo_n_m_APX(int c) { vvn(*gpn % wna[c]); }
void lxo_n_m_ADG(int c) { vvn(gps->n % wn); }
void lxo_n_m_ADP(int c) { vvn(gps->n % *gpn); }
void lxo_n_m_ADD(int c) { vvn(gps->n % gps->n); }
void lxo_n_m_ADK(int c) { vvn(gps->n % 7); }
void lxo_n_m_ADX(int c) { vvn(gps->n % wna[c]); }
void lxo_n_m_AEG(int c) { vvn(vna[2] % wn); }
void lxo_n_m_AEP(int c) { vvn(vna[2] % *gpn); }
void lxo_n_m_AED(int c) { vvn(vna[2] % gps->n); }
void lxo_n_m_AEK(int c) { vvn(vna[2] % 7); }
void lxo_n_m_AEX(int c) { vvn(vna[2] % wna[c]); }
void lxo_n_m_AXG(int c) { vvn(vna[c] % wn); }
void lxo_n_m_AXP(int c) { vvn(vna[c] % *gpn); }
void lxo_n_m_AXD(int c) { vvn(vna[c] % gps->n); }
void lxo_n_m_AXK(int c) { vvn(vna[c] % 7); }
void lxo_n_m_AXX(int c) { vvn(vna[c] % wna[c]); }
void lxo_n_m_QPG(int c) { if (*gpn % wn) gi = 1; }
void lxo_n_m_QPP(int c) { if (*gpn % *gpn) gi = 1; }
void lxo_n_m_QPD(int c) { if (*gpn % gps->n) gi = 1; }
void lxo_n_m_QPK(int c) { if (*gpn % 7) gi = 1; }
void lxo_n_m_QPX(int c) { if (*gpn % wna[c]) gi = 1; }
void lxo_n_m_QDG(int c) { if (gps->n % wn) gi = 1; }
void lxo_n_m_QDP(int c) { if (gps->n % *gpn) gi = 1; }
void lxo_n_m_QDD(int c) { if (gps->n % gps->n) gi = 1; }
void lxo_n_m_QDK(int c) { if (gps->n % 7) gi = 1; }
void lxo_n_m_QDX(int c) { if (gps->n % wna[c]) gi = 1; }
void lxo_n_m_QEG(int c) { if (vna[2] % wn) gi = 1; }
void lxo_n_m_QEP(int c) { if (vna[2] % *gpn) gi = 1; }
void lxo_n_m_QED(int c) { if (vna[2] % gps->n) gi = 1; }
void lxo_n_m_QEK(int c) { if (vna[2] % 7) gi = 1; }
void lxo_n_m_QEX(int c) { if (vna[2] % wna[c]) gi = 1; }
void lxo_n_m_QXG(int c) { if (vna[c] % wn) gi = 1; }
void lxo_n_m_QXP(int c) { if (vna[c] % *gpn) gi = 1; }
void lxo_n_m_QXD(int c) { if (vna[c] % gps->n) gi = 1; }
void lxo_n_m_QXK(int c) { if (vna[c] % 7) gi = 1; }
void lxo_n_m_QXX(int c) { if (vna[c] % wna[c]) gi = 1; }

void lxo_n_x_GPG(int c) { gn = *gpn * wn; }
void lxo_n_x_GPP(int c) { gn = *gpn * *gpn; }
void lxo_n_x_GPD(int c) { gn = *gpn * gps->n; }
void lxo_n_x_GPK(int c) { gn = *gpn * 7; }
void lxo_n_x_GPX(int c) { gn = *gpn * wna[c]; }
void lxo_n_x_GDG(int c) { gn = gps->n * wn; }
void lxo_n_x_GDP(int c) { gn = gps->n * *gpn; }
void lxo_n_x_GDD(int c) { gn = gps->n * gps->n; }
void lxo_n_x_GDK(int c) { gn = gps->n * 7; }
void lxo_n_x_GDX(int c) { gn = gps->n * wna[c]; }
void lxo_n_x_GEG(int c) { gn = vna[2] * wn; }
void lxo_n_x_GEP(int c) { gn = vna[2] * *gpn; }
void lxo_n_x_GED(int c) { gn = vna[2] * gps->n; }
void lxo_n_x_GEK(int c) { gn = vna[2] * 7; }
void lxo_n_x_GEX(int c) { gn = vna[2] * wna[c]; }
void lxo_n_x_GXG(int c) { gn = vna[c] * wn; }
void lxo_n_x_GXP(int c) { gn = vna[c] * *gpn; }
void lxo_n_x_GXD(int c) { gn = vna[c] * gps->n; }
void lxo_n_x_GXK(int c) { gn = vna[c] * 7; }
void lxo_n_x_GXX(int c) { gn = vna[c] * wna[c]; }
void lxo_n_x_PPG(int c) { *gpn = *gpn * wn; }
void lxo_n_x_PPP(int c) { *gpn = *gpn * *gpn; }
void lxo_n_x_PPD(int c) { *gpn = *gpn * gps->n; }
void lxo_n_x_PPK(int c) { *gpn = *gpn * 7; }
void lxo_n_x_PPX(int c) { *gpn = *gpn * wna[c]; }
void lxo_n_x_PDG(int c) { *gpn = gps->n * wn; }
void lxo_n_x_PDP(int c) { *gpn = gps->n * *gpn; }
void lxo_n_x_PDD(int c) { *gpn = gps->n * gps->n; }
void lxo_n_x_PDK(int c) { *gpn = gps->n * 7; }
void lxo_n_x_PDX(int c) { *gpn = gps->n * wna[c]; }
void lxo_n_x_PEG(int c) { *gpn = vna[2] * wn; }
void lxo_n_x_PEP(int c) { *gpn = vna[2] * *gpn; }
void lxo_n_x_PED(int c) { *gpn = vna[2] * gps->n; }
void lxo_n_x_PEK(int c) { *gpn = vna[2] * 7; }
void lxo_n_x_PEX(int c) { *gpn = vna[2] * wna[c]; }
void lxo_n_x_PXG(int c) { *gpn = vna[c] * wn; }
void lxo_n_x_PXP(int c) { *gpn = vna[c] * *gpn; }
void lxo_n_x_PXD(int c) { *gpn = vna[c] * gps->n; }
void lxo_n_x_PXK(int c) { *gpn = vna[c] * 7; }
void lxo_n_x_PXX(int c) { *gpn = vna[c] * wna[c]; }
void lxo_n_x_DPG(int c) { gps->n = *gpn * wn; }
void lxo_n_x_DPP(int c) { gps->n = *gpn * *gpn; }
void lxo_n_x_DPD(int c) { gps->n = *gpn * gps->n; }
void lxo_n_x_DPK(int c) { gps->n = *gpn * 7; }
void lxo_n_x_DPX(int c) { gps->n = *gpn * wna[c]; }
void lxo_n_x_DDG(int c) { gps->n = gps->n * wn; }
void lxo_n_x_DDP(int c) { gps->n = gps->n * *gpn; }
void lxo_n_x_DDD(int c) { gps->n = gps->n * gps->n; }
void lxo_n_x_DDK(int c) { gps->n = gps->n * 7; }
void lxo_n_x_DDX(int c) { gps->n = gps->n * wna[c]; }
void lxo_n_x_DEG(int c) { gps->n = vna[2] * wn; }
void lxo_n_x_DEP(int c) { gps->n = vna[2] * *gpn; }
void lxo_n_x_DED(int c) { gps->n = vna[2] * gps->n; }
void lxo_n_x_DEK(int c) { gps->n = vna[2] * 7; }
void lxo_n_x_DEX(int c) { gps->n = vna[2] * wna[c]; }
void lxo_n_x_DXG(int c) { gps->n = vna[c] * wn; }
void lxo_n_x_DXP(int c) { gps->n = vna[c] * *gpn; }
void lxo_n_x_DXD(int c) { gps->n = vna[c] * gps->n; }
void lxo_n_x_DXK(int c) { gps->n = vna[c] * 7; }
void lxo_n_x_DXX(int c) { gps->n = vna[c] * wna[c]; }
void lxo_n_x_XPG(int c) { gna[c] = *gpn * wn; }
void lxo_n_x_XPP(int c) { gna[c] = *gpn * *gpn; }
void lxo_n_x_XPD(int c) { gna[c] = *gpn * gps->n; }
void lxo_n_x_XPK(int c) { gna[c] = *gpn * 7; }
void lxo_n_x_XPX(int c) { gna[c] = *gpn * wna[c]; }
void lxo_n_x_XDG(int c) { gna[c] = gps->n * wn; }
void lxo_n_x_XDP(int c) { gna[c] = gps->n * *gpn; }
void lxo_n_x_XDD(int c) { gna[c] = gps->n * gps->n; }
void lxo_n_x_XDK(int c) { gna[c] = gps->n * 7; }
void lxo_n_x_XDX(int c) { gna[c] = gps->n * wna[c]; }
void lxo_n_x_XEG(int c) { gna[c] = vna[2] * wn; }
void lxo_n_x_XEP(int c) { gna[c] = vna[2] * *gpn; }
void lxo_n_x_XED(int c) { gna[c] = vna[2] * gps->n; }
void lxo_n_x_XEK(int c) { gna[c] = vna[2] * 7; }
void lxo_n_x_XEX(int c) { gna[c] = vna[2] * wna[c]; }
void lxo_n_x_XXG(int c) { gna[c] = vna[c] * wn; }
void lxo_n_x_XXP(int c) { gna[c] = vna[c] * *gpn; }
void lxo_n_x_XXD(int c) { gna[c] = vna[c] * gps->n; }
void lxo_n_x_XXK(int c) { gna[c] = vna[c] * 7; }
void lxo_n_x_XXX(int c) { gna[c] = vna[c] * wna[c]; }
unsigned long lxo_n_x_RPG(int c) { return *gpn * wn; }
unsigned long lxo_n_x_RPP(int c) { return *gpn * *gpn; }
unsigned long lxo_n_x_RPD(int c) { return *gpn * gps->n; }
unsigned long lxo_n_x_RPK(int c) { return *gpn * 7; }
unsigned long lxo_n_x_RPX(int c) { return *gpn * wna[c]; }
unsigned long lxo_n_x_RDG(int c) { return gps->n * wn; }
unsigned long lxo_n_x_RDP(int c) { return gps->n * *gpn; }
unsigned long lxo_n_x_RDD(int c) { return gps->n * gps->n; }
unsigned long lxo_n_x_RDK(int c) { return gps->n * 7; }
unsigned long lxo_n_x_RDX(int c) { return gps->n * wna[c]; }
unsigned long lxo_n_x_REG(int c) { return vna[2] * wn; }
unsigned long lxo_n_x_REP(int c) { return vna[2] * *gpn; }
unsigned long lxo_n_x_RED(int c) { return vna[2] * gps->n; }
unsigned long lxo_n_x_REK(int c) { return vna[2] * 7; }
unsigned long lxo_n_x_REX(int c) { return vna[2] * wna[c]; }
unsigned long lxo_n_x_RXG(int c) { return vna[c] * wn; }
unsigned long lxo_n_x_RXP(int c) { return vna[c] * *gpn; }
unsigned long lxo_n_x_RXD(int c) { return vna[c] * gps->n; }
unsigned long lxo_n_x_RXK(int c) { return vna[c] * 7; }
unsigned long lxo_n_x_RXX(int c) { return vna[c] * wna[c]; }
void lxo_n_x_APG(int c) { vvn(*gpn * wn); }
void lxo_n_x_APP(int c) { vvn(*gpn * *gpn); }
void lxo_n_x_APD(int c) { vvn(*gpn * gps->n); }
void lxo_n_x_APK(int c) { vvn(*gpn * 7); }
void lxo_n_x_APX(int c) { vvn(*gpn * wna[c]); }
void lxo_n_x_ADG(int c) { vvn(gps->n * wn); }
void lxo_n_x_ADP(int c) { vvn(gps->n * *gpn); }
void lxo_n_x_ADD(int c) { vvn(gps->n * gps->n); }
void lxo_n_x_ADK(int c) { vvn(gps->n * 7); }
void lxo_n_x_ADX(int c) { vvn(gps->n * wna[c]); }
void lxo_n_x_AEG(int c) { vvn(vna[2] * wn); }
void lxo_n_x_AEP(int c) { vvn(vna[2] * *gpn); }
void lxo_n_x_AED(int c) { vvn(vna[2] * gps->n); }
void lxo_n_x_AEK(int c) { vvn(vna[2] * 7); }
void lxo_n_x_AEX(int c) { vvn(vna[2] * wna[c]); }
void lxo_n_x_AXG(int c) { vvn(vna[c] * wn); }
void lxo_n_x_AXP(int c) { vvn(vna[c] * *gpn); }
void lxo_n_x_AXD(int c) { vvn(vna[c] * gps->n); }
void lxo_n_x_AXK(int c) { vvn(vna[c] * 7); }
void lxo_n_x_AXX(int c) { vvn(vna[c] * wna[c]); }
void lxo_n_x_QPG(int c) { if (*gpn * wn) gi = 1; }
void lxo_n_x_QPP(int c) { if (*gpn * *gpn) gi = 1; }
void lxo_n_x_QPD(int c) { if (*gpn * gps->n) gi = 1; }
void lxo_n_x_QPK(int c) { if (*gpn * 7) gi = 1; }
void lxo_n_x_QPX(int c) { if (*gpn * wna[c]) gi = 1; }
void lxo_n_x_QDG(int c) { if (gps->n * wn) gi = 1; }
void lxo_n_x_QDP(int c) { if (gps->n * *gpn) gi = 1; }
void lxo_n_x_QDD(int c) { if (gps->n * gps->n) gi = 1; }
void lxo_n_x_QDK(int c) { if (gps->n * 7) gi = 1; }
void lxo_n_x_QDX(int c) { if (gps->n * wna[c]) gi = 1; }
void lxo_n_x_QEG(int c) { if (vna[2] * wn) gi = 1; }
void lxo_n_x_QEP(int c) { if (vna[2] * *gpn) gi = 1; }
void lxo_n_x_QED(int c) { if (vna[2] * gps->n) gi = 1; }
void lxo_n_x_QEK(int c) { if (vna[2] * 7) gi = 1; }
void lxo_n_x_QEX(int c) { if (vna[2] * wna[c]) gi = 1; }
void lxo_n_x_QXG(int c) { if (vna[c] * wn) gi = 1; }
void lxo_n_x_QXP(int c) { if (vna[c] * *gpn) gi = 1; }
void lxo_n_x_QXD(int c) { if (vna[c] * gps->n) gi = 1; }
void lxo_n_x_QXK(int c) { if (vna[c] * 7) gi = 1; }
void lxo_n_x_QXX(int c) { if (vna[c] * wna[c]) gi = 1; }

void lxm_l_a_G(int c) { gl = gl % 3 % 2; }
void lxm_l_a_X(int c) { gla[c] = gl % 3 % 2; }
void lxm_l_a_P(int c) { *gpl = gl % 3 % 2; }
long lxm_l_a_R(int c) { return gl % 3 % 2; }
void lxm_l_b_G(int c) { gl = vl * (wl + gl); }
void lxm_l_b_X(int c) { gla[c] = vl * (wl + gl); }
void lxm_l_b_P(int c) { *gpl = vl * (wl + gl); }
long lxm_l_b_R(int c) { return vl * (wl + gl); }
void lxm_l_c_G(int c) { gl = (vl / wl) % 7; }
void lxm_l_c_X(int c) { gla[c] = (vl / wl) % 7; }
void lxm_l_c_P(int c) { *gpl = (vl / wl) % 7; }
long lxm_l_c_R(int c) { return (vl / wl) % 7; }
void lxm_l_d_G(int c) { gl = vl * wl * 5; }
void lxm_l_d_X(int c) { gla[c] = vl * wl * 5; }
void lxm_l_d_P(int c) { *gpl = vl * wl * 5; }
long lxm_l_d_R(int c) { return vl * wl * 5; }
void lxm_l_e_G(int c) { gl = vla[c] % 3 % 2; }
void lxm_l_e_X(int c) { gla[c] = vla[c] % 3 % 2; }
void lxm_l_e_P(int c) { *gpl = vla[c] % 3 % 2; }
long lxm_l_e_R(int c) { return vla[c] % 3 % 2; }
void lxm_l_f_G(int c) { gl = vl * (wla[c] + 1); }
void lxm_l_f_X(int c) { gla[c] = vl * (wla[c] + 1); }
void lxm_l_f_P(int c) { *gpl = vl * (wla[c] + 1); }
long lxm_l_f_R(int c) { return vl * (wla[c] + 1); }
void lxm_l_g_G(int c) { gl = (vl + wl) / vla[c]; }
void lxm_l_g_X(int c) { gla[c] = (vl + wl) / vla[c]; }
void lxm_l_g_P(int c) { *gpl = (vl + wl) / vla[c]; }
long lxm_l_g_R(int c) { return (vl + wl) / vla[c]; }
void lxm_l_h_G(int c) { gl = vl * wl + vl / wl; }
void lxm_l_h_X(int c) { gla[c] = vl * wl + vl / wl; }
void lxm_l_h_P(int c) { *gpl = vl * wl + vl / wl; }
long lxm_l_h_R(int c) { return vl * wl + vl / wl; }
void lxm_l_i_G(int c) { gl = rrl(vl) % 3; }
void lxm_l_i_X(int c) { gla[c] = rrl(vl) % 3; }
void lxm_l_i_P(int c) { *gpl = rrl(vl) % 3; }
long lxm_l_i_R(int c) { return rrl(vl) % 3; }
void lxm_l_j_G(int c) { gl = vl / 7 + wla[c] % 7; }
void lxm_l_j_X(int c) { gla[c] = vl / 7 + wla[c] % 7; }
void lxm_l_j_P(int c) { *gpl = vl / 7 + wla[c] % 7; }
long lxm_l_j_R(int c) { return vl / 7 + wla[c] % 7; }
void lxm_l_k_G(int c) { gl = *gpl * (gpl[1] + 65536); }
void lxm_l_k_X(int c) { gla[c] = *gpl * (gpl[1] + 65536); }
void lxm_l_k_P(int c) { *gpl = *gpl * (gpl[1] + 65536); }
long lxm_l_k_R(int c) { return *gpl * (gpl[1] + 65536); }
void lxm_l_l_G(int c) { gl = gps->l % 100 / 100; }
void lxm_l_l_X(int c) { gla[c] = gps->l % 100 / 100; }
void lxm_l_l_P(int c) { *gpl = gps->l % 100 / 100; }
long lxm_l_l_R(int c) { return gps->l % 100 / 100; }
void lxm_l_m_G(int c) { gl = gl / 10 / 10; }
void lxm_l_m_X(int c) { gla[c] = gl / 10 / 10; }
void lxm_l_m_P(int c) { *gpl = gl / 10 / 10; }
long lxm_l_m_R(int c) { return gl / 10 / 10; }
void lxm_l_n_G(int c) { gl = vla[c] * 3 * 5; }
void lxm_l_n_X(int c) { gla[c] = vla[c] * 3 * 5; }
void lxm_l_n_P(int c) { *gpl = vla[c] * 3 * 5; }
long lxm_l_n_R(int c) { return vla[c] * 3 * 5; }
void lxm_l_o_G(int c) { gl = (vla[c] % 10) * wl; }
void lxm_l_o_X(int c) { gla[c] = (vla[c] % 10) * wl; }
void lxm_l_o_P(int c) { *gpl = (vla[c] % 10) * wl; }
long lxm_l_o_R(int c) { return (vla[c] % 10) * wl; }
void lxm_l_p_G(int c) { gl = rrl(vl) * rrl(wl); }
void lxm_l_p_X(int c) { gla[c] = rrl(vl) * rrl(wl); }
void lxm_l_p_P(int c) { *gpl = rrl(vl) * rrl(wl); }
long lxm_l_p_R(int c) { return rrl(vl) * rrl(wl); }

void lxm_n_a_G(int c) { gn = gn % 3 % 2; }
void lxm_n_a_X(int c) { gna[c] = gn % 3 % 2; }
void lxm_n_a_P(int c) { *gpn = gn % 3 % 2; }
unsigned long lxm_n_a_R(int c) { return gn % 3 % 2; }
void lxm_n_b_G(int c) { gn = vn * (wn + gn); }
void lxm_n_b_X(int c) { gna[c] = vn * (wn + gn); }
void lxm_n_b_P(int c) { *gpn = vn * (wn + gn); }
unsigned long lxm_n_b_R(int c) { return vn * (wn + gn); }
void lxm_n_c_G(int c) { gn = (vn / wn) % 7; }
void lxm_n_c_X(int c) { gna[c] = (vn / wn) % 7; }
void lxm_n_c_P(int c) { *gpn = (vn / wn) % 7; }
unsigned long lxm_n_c_R(int c) { return (vn / wn) % 7; }
void lxm_n_d_G(int c) { gn = vn * wn * 5; }
void lxm_n_d_X(int c) { gna[c] = vn * wn * 5; }
void lxm_n_d_P(int c) { *gpn = vn * wn * 5; }
unsigned long lxm_n_d_R(int c) { return vn * wn * 5; }
void lxm_n_e_G(int c) { gn = vna[c] % 3 % 2; }
void lxm_n_e_X(int c) { gna[c] = vna[c] % 3 % 2; }
void lxm_n_e_P(int c) { *gpn = vna[c] % 3 % 2; }
unsigned long lxm_n_e_R(int c) { return vna[c] % 3 % 2; }
void lxm_n_f_G(int c) { gn = vn * (wna[c] + 1); }
void lxm_n_f_X(int c) { gna[c] = vn * (wna[c] + 1); }
void lxm_n_f_P(int c) { *gpn = vn * (wna[c] + 1); }
unsigned long lxm_n_f_R(int c) { return vn * (wna[c] + 1); }
void lxm_n_g_G(int c) { gn = (vn + wn) / vna[c]; }
void lxm_n_g_X(int c) { gna[c] = (vn + wn) / vna[c]; }
void lxm_n_g_P(int c) { *gpn = (vn + wn) / vna[c]; }
unsigned long lxm_n_g_R(int c) { return (vn + wn) / vna[c]; }
void lxm_n_h_G(int c) { gn = vn * wn + vn / wn; }
void lxm_n_h_X(int c) { gna[c] = vn * wn + vn / wn; }
void lxm_n_h_P(int c) { *gpn = vn * wn + vn / wn; }
unsigned long lxm_n_h_R(int c) { return vn * wn + vn / wn; }
void lxm_n_i_G(int c) { gn = rrn(vn) % 3; }
void lxm_n_i_X(int c) { gna[c] = rrn(vn) % 3; }
void lxm_n_i_P(int c) { *gpn = rrn(vn) % 3; }
unsigned long lxm_n_i_R(int c) { return rrn(vn) % 3; }
void lxm_n_j_G(int c) { gn = vn / 7 + wna[c] % 7; }
void lxm_n_j_X(int c) { gna[c] = vn / 7 + wna[c] % 7; }
void lxm_n_j_P(int c) { *gpn = vn / 7 + wna[c] % 7; }
unsigned long lxm_n_j_R(int c) { return vn / 7 + wna[c] % 7; }
void lxm_n_k_G(int c) { gn = *gpn * (gpn[1] + 65536); }
void lxm_n_k_X(int c) { gna[c] = *gpn * (gpn[1] + 65536); }
void lxm_n_k_P(int c) { *gpn = *gpn * (gpn[1] + 65536); }
unsigned long lxm_n_k_R(int c) { return *gpn * (gpn[1] + 65536); }
void lxm_n_l_G(int c) { gn = gps->n % 100 / 100; }
void lxm_n_l_X(int c) { gna[c] = gps->n % 100 / 100; }
void lxm_n_l_P(int c) { *gpn = gps->n % 100 / 100; }
unsigned long lxm_n_l_R(int c) { return gps->n % 100 / 100; }
void lxm_n_m_G(int c) { gn = gn / 10 / 10; }
void lxm_n_m_X(int c) { gna[c] = gn / 10 / 10; }
void lxm_n_m_P(int c) { *gpn = gn / 10 / 10; }
unsigned long lxm_n_m_R(int c) { return gn / 10 / 10; }
void lxm_n_n_G(int c) { gn = vna[c] * 3 * 5; }
void lxm_n_n_X(int c) { gna[c] = vna[c] * 3 * 5; }
void lxm_n_n_P(int c) { *gpn = vna[c] * 3 * 5; }
unsigned long lxm_n_n_R(int c) { return vna[c] * 3 * 5; }
void lxm_n_o_G(int c) { gn = (vna[c] % 10) * wn; }
void lxm_n_o_X(int c) { gna[c] = (vna[c] % 10) * wn; }
void lxm_n_o_P(int c) { *gpn = (vna[c] % 10) * wn; }
unsigned long lxm_n_o_R(int c) { return (vna[c] % 10) * wn; }
void lxm_n_p_G(int c) { gn = rrn(vn) * rrn(wn); }
void lxm_n_p_X(int c) { gna[c] = rrn(vn) * rrn(wn); }
void lxm_n_p_P(int c) { *gpn = rrn(vn) * rrn(wn); }
unsigned long lxm_n_p_R(int c) { return rrn(vn) * rrn(wn); }

