/* Division and remainder stored into an element at an int parameter index, through a pointer, or into a global
   (gen_stv.py).  sv_<t>_<op>_<D><V>(int c): t i int, u unsigned int, l long, n unsigned long; op d /, m %; D E element
   gXa[c], P through a pointer gp->x, G plain global; V G global hX, A element hXa[c], K constant 7, E element hXa[2]. */
struct sv { int x; unsigned int u; long l; unsigned long n; };
extern struct sv *gp; extern int gi, hi; extern unsigned int gu, hu; extern long gl, hl; extern unsigned long gn, hn;
extern int gia[8], hia[8]; extern unsigned int gua[8], hua[8]; extern long gla[8], hla[8]; extern unsigned long gna[8], hna[8];

void sv_i_d_EG(int c) { gia[c] = gia[c] / hi; }
void sv_i_d_EA(int c) { gia[c] = gia[c] / hia[c]; }
void sv_i_d_EK(int c) { gia[c] = gia[c] / 7; }
void sv_i_d_EE(int c) { gia[c] = gia[c] / hia[2]; }
void sv_i_d_PG(int c) { gp->x = gp->x / hi; }
void sv_i_d_PA(int c) { gp->x = gp->x / hia[c]; }
void sv_i_d_PK(int c) { gp->x = gp->x / 7; }
void sv_i_d_PE(int c) { gp->x = gp->x / hia[2]; }
void sv_i_d_GG(int c) { gi = hi / hi; }
void sv_i_d_GA(int c) { gi = hi / hia[c]; }
void sv_i_d_GK(int c) { gi = hi / 7; }
void sv_i_d_GE(int c) { gi = hi / hia[2]; }
void sv_i_m_EG(int c) { gia[c] = gia[c] % hi; }
void sv_i_m_EA(int c) { gia[c] = gia[c] % hia[c]; }
void sv_i_m_EK(int c) { gia[c] = gia[c] % 7; }
void sv_i_m_EE(int c) { gia[c] = gia[c] % hia[2]; }
void sv_i_m_PG(int c) { gp->x = gp->x % hi; }
void sv_i_m_PA(int c) { gp->x = gp->x % hia[c]; }
void sv_i_m_PK(int c) { gp->x = gp->x % 7; }
void sv_i_m_PE(int c) { gp->x = gp->x % hia[2]; }
void sv_i_m_GG(int c) { gi = hi % hi; }
void sv_i_m_GA(int c) { gi = hi % hia[c]; }
void sv_i_m_GK(int c) { gi = hi % 7; }
void sv_i_m_GE(int c) { gi = hi % hia[2]; }

void sv_u_d_EG(int c) { gua[c] = gua[c] / hu; }
void sv_u_d_EA(int c) { gua[c] = gua[c] / hua[c]; }
void sv_u_d_EK(int c) { gua[c] = gua[c] / 7; }
void sv_u_d_EE(int c) { gua[c] = gua[c] / hua[2]; }
void sv_u_d_PG(int c) { gp->u = gp->u / hu; }
void sv_u_d_PA(int c) { gp->u = gp->u / hua[c]; }
void sv_u_d_PK(int c) { gp->u = gp->u / 7; }
void sv_u_d_PE(int c) { gp->u = gp->u / hua[2]; }
void sv_u_d_GG(int c) { gu = hu / hu; }
void sv_u_d_GA(int c) { gu = hu / hua[c]; }
void sv_u_d_GK(int c) { gu = hu / 7; }
void sv_u_d_GE(int c) { gu = hu / hua[2]; }
void sv_u_m_EG(int c) { gua[c] = gua[c] % hu; }
void sv_u_m_EA(int c) { gua[c] = gua[c] % hua[c]; }
void sv_u_m_EK(int c) { gua[c] = gua[c] % 7; }
void sv_u_m_EE(int c) { gua[c] = gua[c] % hua[2]; }
void sv_u_m_PG(int c) { gp->u = gp->u % hu; }
void sv_u_m_PA(int c) { gp->u = gp->u % hua[c]; }
void sv_u_m_PK(int c) { gp->u = gp->u % 7; }
void sv_u_m_PE(int c) { gp->u = gp->u % hua[2]; }
void sv_u_m_GG(int c) { gu = hu % hu; }
void sv_u_m_GA(int c) { gu = hu % hua[c]; }
void sv_u_m_GK(int c) { gu = hu % 7; }
void sv_u_m_GE(int c) { gu = hu % hua[2]; }

void sv_l_d_EG(int c) { gla[c] = gla[c] / hl; }
void sv_l_d_EA(int c) { gla[c] = gla[c] / hla[c]; }
void sv_l_d_EK(int c) { gla[c] = gla[c] / 7; }
void sv_l_d_EE(int c) { gla[c] = gla[c] / hla[2]; }
void sv_l_d_PG(int c) { gp->l = gp->l / hl; }
void sv_l_d_PA(int c) { gp->l = gp->l / hla[c]; }
void sv_l_d_PK(int c) { gp->l = gp->l / 7; }
void sv_l_d_PE(int c) { gp->l = gp->l / hla[2]; }
void sv_l_d_GG(int c) { gl = hl / hl; }
void sv_l_d_GA(int c) { gl = hl / hla[c]; }
void sv_l_d_GK(int c) { gl = hl / 7; }
void sv_l_d_GE(int c) { gl = hl / hla[2]; }
void sv_l_m_EG(int c) { gla[c] = gla[c] % hl; }
void sv_l_m_EA(int c) { gla[c] = gla[c] % hla[c]; }
void sv_l_m_EK(int c) { gla[c] = gla[c] % 7; }
void sv_l_m_EE(int c) { gla[c] = gla[c] % hla[2]; }
void sv_l_m_PG(int c) { gp->l = gp->l % hl; }
void sv_l_m_PA(int c) { gp->l = gp->l % hla[c]; }
void sv_l_m_PK(int c) { gp->l = gp->l % 7; }
void sv_l_m_PE(int c) { gp->l = gp->l % hla[2]; }
void sv_l_m_GG(int c) { gl = hl % hl; }
void sv_l_m_GA(int c) { gl = hl % hla[c]; }
void sv_l_m_GK(int c) { gl = hl % 7; }
void sv_l_m_GE(int c) { gl = hl % hla[2]; }

void sv_n_d_EG(int c) { gna[c] = gna[c] / hn; }
void sv_n_d_EA(int c) { gna[c] = gna[c] / hna[c]; }
void sv_n_d_EK(int c) { gna[c] = gna[c] / 7; }
void sv_n_d_EE(int c) { gna[c] = gna[c] / hna[2]; }
void sv_n_d_PG(int c) { gp->n = gp->n / hn; }
void sv_n_d_PA(int c) { gp->n = gp->n / hna[c]; }
void sv_n_d_PK(int c) { gp->n = gp->n / 7; }
void sv_n_d_PE(int c) { gp->n = gp->n / hna[2]; }
void sv_n_d_GG(int c) { gn = hn / hn; }
void sv_n_d_GA(int c) { gn = hn / hna[c]; }
void sv_n_d_GK(int c) { gn = hn / 7; }
void sv_n_d_GE(int c) { gn = hn / hna[2]; }
void sv_n_m_EG(int c) { gna[c] = gna[c] % hn; }
void sv_n_m_EA(int c) { gna[c] = gna[c] % hna[c]; }
void sv_n_m_EK(int c) { gna[c] = gna[c] % 7; }
void sv_n_m_EE(int c) { gna[c] = gna[c] % hna[2]; }
void sv_n_m_PG(int c) { gp->n = gp->n % hn; }
void sv_n_m_PA(int c) { gp->n = gp->n % hna[c]; }
void sv_n_m_PK(int c) { gp->n = gp->n % 7; }
void sv_n_m_PE(int c) { gp->n = gp->n % hna[2]; }
void sv_n_m_GG(int c) { gn = hn % hn; }
void sv_n_m_GA(int c) { gn = hn % hna[c]; }
void sv_n_m_GK(int c) { gn = hn % 7; }
void sv_n_m_GE(int c) { gn = hn % hna[2]; }
