/* Long helpers with an element at a loop counter or a local index (gen_lhidx.py): lx_<t>_<op>_<S><shape>.
   t: l long, n unsigned long; op: d /, m %, x *; S: L a for loop over i, T int t = gi, C the parameter c.
   shapes: GX gv = vv op va[i]; XG gv = va[i] op vv; XK gv = va[i] op 7; KX gv = 100 op va[i]; MX gv = vs.v op
   va[i]; YX gv = va[c] op wa[i]; SX ga[3] = vv op va[i]; DX gps->v = vv op va[i]; EX ga[i] = vv op wa[i]. */
struct sl { char c; long l; unsigned long n; };
extern long gl, vl, gla[8], vla[8], wla[8]; extern unsigned long gn, vn, gna[8], vna[8], wna[8];
extern struct sl vs, *gps; extern int gi;

void lx_l_d_LGX(int c) { int i; for (i = 0; i < 4; i++) gl = vl / vla[i]; }
void lx_l_d_LXG(int c) { int i; for (i = 0; i < 4; i++) gl = vla[i] / vl; }
void lx_l_d_LXK(int c) { int i; for (i = 0; i < 4; i++) gl = vla[i] / 7; }
void lx_l_d_LKX(int c) { int i; for (i = 0; i < 4; i++) gl = 100 / vla[i]; }
void lx_l_d_LMX(int c) { int i; for (i = 0; i < 4; i++) gl = vs.l / vla[i]; }
void lx_l_d_LYX(int c) { int i; for (i = 0; i < 4; i++) gl = vla[c] / wla[i]; }
void lx_l_d_LSX(int c) { int i; for (i = 0; i < 4; i++) gla[3] = vl / vla[i]; }
void lx_l_d_LDX(int c) { int i; for (i = 0; i < 4; i++) gps->l = vl / vla[i]; }
void lx_l_d_LEX(int c) { int i; for (i = 0; i < 4; i++) gla[i] = vl / wla[i]; }
void lx_l_d_TGX(int c) { int t = gi; gl = vl / vla[t]; }
void lx_l_d_TXG(int c) { int t = gi; gl = vla[t] / vl; }
void lx_l_d_TXK(int c) { int t = gi; gl = vla[t] / 7; }
void lx_l_d_TKX(int c) { int t = gi; gl = 100 / vla[t]; }
void lx_l_d_TMX(int c) { int t = gi; gl = vs.l / vla[t]; }
void lx_l_d_TYX(int c) { int t = gi; gl = vla[c] / wla[t]; }
void lx_l_d_TSX(int c) { int t = gi; gla[3] = vl / vla[t]; }
void lx_l_d_TDX(int c) { int t = gi; gps->l = vl / vla[t]; }
void lx_l_d_TEX(int c) { int t = gi; gla[t] = vl / wla[t]; }
void lx_l_d_CGX(int c) { gl = vl / vla[c]; }
void lx_l_d_CXG(int c) { gl = vla[c] / vl; }
void lx_l_d_CXK(int c) { gl = vla[c] / 7; }
void lx_l_d_CKX(int c) { gl = 100 / vla[c]; }
void lx_l_d_CMX(int c) { gl = vs.l / vla[c]; }
void lx_l_d_CYX(int c) { gl = vla[c] / wla[c]; }
void lx_l_d_CSX(int c) { gla[3] = vl / vla[c]; }
void lx_l_d_CDX(int c) { gps->l = vl / vla[c]; }
void lx_l_d_CEX(int c) { gla[c] = vl / wla[c]; }

void lx_l_m_LGX(int c) { int i; for (i = 0; i < 4; i++) gl = vl % vla[i]; }
void lx_l_m_LXG(int c) { int i; for (i = 0; i < 4; i++) gl = vla[i] % vl; }
void lx_l_m_LXK(int c) { int i; for (i = 0; i < 4; i++) gl = vla[i] % 7; }
void lx_l_m_LKX(int c) { int i; for (i = 0; i < 4; i++) gl = 100 % vla[i]; }
void lx_l_m_LMX(int c) { int i; for (i = 0; i < 4; i++) gl = vs.l % vla[i]; }
void lx_l_m_LYX(int c) { int i; for (i = 0; i < 4; i++) gl = vla[c] % wla[i]; }
void lx_l_m_LSX(int c) { int i; for (i = 0; i < 4; i++) gla[3] = vl % vla[i]; }
void lx_l_m_LDX(int c) { int i; for (i = 0; i < 4; i++) gps->l = vl % vla[i]; }
void lx_l_m_LEX(int c) { int i; for (i = 0; i < 4; i++) gla[i] = vl % wla[i]; }
void lx_l_m_TGX(int c) { int t = gi; gl = vl % vla[t]; }
void lx_l_m_TXG(int c) { int t = gi; gl = vla[t] % vl; }
void lx_l_m_TXK(int c) { int t = gi; gl = vla[t] % 7; }
void lx_l_m_TKX(int c) { int t = gi; gl = 100 % vla[t]; }
void lx_l_m_TMX(int c) { int t = gi; gl = vs.l % vla[t]; }
void lx_l_m_TYX(int c) { int t = gi; gl = vla[c] % wla[t]; }
void lx_l_m_TSX(int c) { int t = gi; gla[3] = vl % vla[t]; }
void lx_l_m_TDX(int c) { int t = gi; gps->l = vl % vla[t]; }
void lx_l_m_TEX(int c) { int t = gi; gla[t] = vl % wla[t]; }
void lx_l_m_CGX(int c) { gl = vl % vla[c]; }
void lx_l_m_CXG(int c) { gl = vla[c] % vl; }
void lx_l_m_CXK(int c) { gl = vla[c] % 7; }
void lx_l_m_CKX(int c) { gl = 100 % vla[c]; }
void lx_l_m_CMX(int c) { gl = vs.l % vla[c]; }
void lx_l_m_CYX(int c) { gl = vla[c] % wla[c]; }
void lx_l_m_CSX(int c) { gla[3] = vl % vla[c]; }
void lx_l_m_CDX(int c) { gps->l = vl % vla[c]; }
void lx_l_m_CEX(int c) { gla[c] = vl % wla[c]; }

void lx_l_x_LGX(int c) { int i; for (i = 0; i < 4; i++) gl = vl * vla[i]; }
void lx_l_x_LXG(int c) { int i; for (i = 0; i < 4; i++) gl = vla[i] * vl; }
void lx_l_x_LMX(int c) { int i; for (i = 0; i < 4; i++) gl = vs.l * vla[i]; }
void lx_l_x_LYX(int c) { int i; for (i = 0; i < 4; i++) gl = vla[c] * wla[i]; }
void lx_l_x_LSX(int c) { int i; for (i = 0; i < 4; i++) gla[3] = vl * vla[i]; }
void lx_l_x_LDX(int c) { int i; for (i = 0; i < 4; i++) gps->l = vl * vla[i]; }
void lx_l_x_LEX(int c) { int i; for (i = 0; i < 4; i++) gla[i] = vl * wla[i]; }
void lx_l_x_TGX(int c) { int t = gi; gl = vl * vla[t]; }
void lx_l_x_TXG(int c) { int t = gi; gl = vla[t] * vl; }
void lx_l_x_TMX(int c) { int t = gi; gl = vs.l * vla[t]; }
void lx_l_x_TYX(int c) { int t = gi; gl = vla[c] * wla[t]; }
void lx_l_x_TSX(int c) { int t = gi; gla[3] = vl * vla[t]; }
void lx_l_x_TDX(int c) { int t = gi; gps->l = vl * vla[t]; }
void lx_l_x_TEX(int c) { int t = gi; gla[t] = vl * wla[t]; }
void lx_l_x_CGX(int c) { gl = vl * vla[c]; }
void lx_l_x_CXG(int c) { gl = vla[c] * vl; }
void lx_l_x_CMX(int c) { gl = vs.l * vla[c]; }
void lx_l_x_CYX(int c) { gl = vla[c] * wla[c]; }
void lx_l_x_CSX(int c) { gla[3] = vl * vla[c]; }
void lx_l_x_CDX(int c) { gps->l = vl * vla[c]; }
void lx_l_x_CEX(int c) { gla[c] = vl * wla[c]; }

void lx_n_d_LGX(int c) { int i; for (i = 0; i < 4; i++) gn = vn / vna[i]; }
void lx_n_d_LXG(int c) { int i; for (i = 0; i < 4; i++) gn = vna[i] / vn; }
void lx_n_d_LXK(int c) { int i; for (i = 0; i < 4; i++) gn = vna[i] / 7; }
void lx_n_d_LKX(int c) { int i; for (i = 0; i < 4; i++) gn = 100 / vna[i]; }
void lx_n_d_LMX(int c) { int i; for (i = 0; i < 4; i++) gn = vs.n / vna[i]; }
void lx_n_d_LYX(int c) { int i; for (i = 0; i < 4; i++) gn = vna[c] / wna[i]; }
void lx_n_d_LSX(int c) { int i; for (i = 0; i < 4; i++) gna[3] = vn / vna[i]; }
void lx_n_d_LDX(int c) { int i; for (i = 0; i < 4; i++) gps->n = vn / vna[i]; }
void lx_n_d_LEX(int c) { int i; for (i = 0; i < 4; i++) gna[i] = vn / wna[i]; }
void lx_n_d_TGX(int c) { int t = gi; gn = vn / vna[t]; }
void lx_n_d_TXG(int c) { int t = gi; gn = vna[t] / vn; }
void lx_n_d_TXK(int c) { int t = gi; gn = vna[t] / 7; }
void lx_n_d_TKX(int c) { int t = gi; gn = 100 / vna[t]; }
void lx_n_d_TMX(int c) { int t = gi; gn = vs.n / vna[t]; }
void lx_n_d_TYX(int c) { int t = gi; gn = vna[c] / wna[t]; }
void lx_n_d_TSX(int c) { int t = gi; gna[3] = vn / vna[t]; }
void lx_n_d_TDX(int c) { int t = gi; gps->n = vn / vna[t]; }
void lx_n_d_TEX(int c) { int t = gi; gna[t] = vn / wna[t]; }
void lx_n_d_CGX(int c) { gn = vn / vna[c]; }
void lx_n_d_CXG(int c) { gn = vna[c] / vn; }
void lx_n_d_CXK(int c) { gn = vna[c] / 7; }
void lx_n_d_CKX(int c) { gn = 100 / vna[c]; }
void lx_n_d_CMX(int c) { gn = vs.n / vna[c]; }
void lx_n_d_CYX(int c) { gn = vna[c] / wna[c]; }
void lx_n_d_CSX(int c) { gna[3] = vn / vna[c]; }
void lx_n_d_CDX(int c) { gps->n = vn / vna[c]; }
void lx_n_d_CEX(int c) { gna[c] = vn / wna[c]; }

void lx_n_m_LGX(int c) { int i; for (i = 0; i < 4; i++) gn = vn % vna[i]; }
void lx_n_m_LXG(int c) { int i; for (i = 0; i < 4; i++) gn = vna[i] % vn; }
void lx_n_m_LXK(int c) { int i; for (i = 0; i < 4; i++) gn = vna[i] % 7; }
void lx_n_m_LKX(int c) { int i; for (i = 0; i < 4; i++) gn = 100 % vna[i]; }
void lx_n_m_LMX(int c) { int i; for (i = 0; i < 4; i++) gn = vs.n % vna[i]; }
void lx_n_m_LYX(int c) { int i; for (i = 0; i < 4; i++) gn = vna[c] % wna[i]; }
void lx_n_m_LSX(int c) { int i; for (i = 0; i < 4; i++) gna[3] = vn % vna[i]; }
void lx_n_m_LDX(int c) { int i; for (i = 0; i < 4; i++) gps->n = vn % vna[i]; }
void lx_n_m_LEX(int c) { int i; for (i = 0; i < 4; i++) gna[i] = vn % wna[i]; }
void lx_n_m_TGX(int c) { int t = gi; gn = vn % vna[t]; }
void lx_n_m_TXG(int c) { int t = gi; gn = vna[t] % vn; }
void lx_n_m_TXK(int c) { int t = gi; gn = vna[t] % 7; }
void lx_n_m_TKX(int c) { int t = gi; gn = 100 % vna[t]; }
void lx_n_m_TMX(int c) { int t = gi; gn = vs.n % vna[t]; }
void lx_n_m_TYX(int c) { int t = gi; gn = vna[c] % wna[t]; }
void lx_n_m_TSX(int c) { int t = gi; gna[3] = vn % vna[t]; }
void lx_n_m_TDX(int c) { int t = gi; gps->n = vn % vna[t]; }
void lx_n_m_TEX(int c) { int t = gi; gna[t] = vn % wna[t]; }
void lx_n_m_CGX(int c) { gn = vn % vna[c]; }
void lx_n_m_CXG(int c) { gn = vna[c] % vn; }
void lx_n_m_CXK(int c) { gn = vna[c] % 7; }
void lx_n_m_CKX(int c) { gn = 100 % vna[c]; }
void lx_n_m_CMX(int c) { gn = vs.n % vna[c]; }
void lx_n_m_CYX(int c) { gn = vna[c] % wna[c]; }
void lx_n_m_CSX(int c) { gna[3] = vn % vna[c]; }
void lx_n_m_CDX(int c) { gps->n = vn % vna[c]; }
void lx_n_m_CEX(int c) { gna[c] = vn % wna[c]; }

void lx_n_x_LGX(int c) { int i; for (i = 0; i < 4; i++) gn = vn * vna[i]; }
void lx_n_x_LXG(int c) { int i; for (i = 0; i < 4; i++) gn = vna[i] * vn; }
void lx_n_x_LMX(int c) { int i; for (i = 0; i < 4; i++) gn = vs.n * vna[i]; }
void lx_n_x_LYX(int c) { int i; for (i = 0; i < 4; i++) gn = vna[c] * wna[i]; }
void lx_n_x_LSX(int c) { int i; for (i = 0; i < 4; i++) gna[3] = vn * vna[i]; }
void lx_n_x_LDX(int c) { int i; for (i = 0; i < 4; i++) gps->n = vn * vna[i]; }
void lx_n_x_LEX(int c) { int i; for (i = 0; i < 4; i++) gna[i] = vn * wna[i]; }
void lx_n_x_TGX(int c) { int t = gi; gn = vn * vna[t]; }
void lx_n_x_TXG(int c) { int t = gi; gn = vna[t] * vn; }
void lx_n_x_TMX(int c) { int t = gi; gn = vs.n * vna[t]; }
void lx_n_x_TYX(int c) { int t = gi; gn = vna[c] * wna[t]; }
void lx_n_x_TSX(int c) { int t = gi; gna[3] = vn * vna[t]; }
void lx_n_x_TDX(int c) { int t = gi; gps->n = vn * vna[t]; }
void lx_n_x_TEX(int c) { int t = gi; gna[t] = vn * wna[t]; }
void lx_n_x_CGX(int c) { gn = vn * vna[c]; }
void lx_n_x_CXG(int c) { gn = vna[c] * vn; }
void lx_n_x_CMX(int c) { gn = vs.n * vna[c]; }
void lx_n_x_CYX(int c) { gn = vna[c] * wna[c]; }
void lx_n_x_CSX(int c) { gna[3] = vn * vna[c]; }
void lx_n_x_CDX(int c) { gps->n = vn * vna[c]; }
void lx_n_x_CEX(int c) { gna[c] = vn * wna[c]; }

