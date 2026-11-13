/* Second context of the store shapes (gen_stv2.py): dividend gp->arr[c] (Q); divisor the parameter c (R) or
   gp->arr[c] (S); destination gp->arr[c] (E) or gp->x (P).  sv2_<t>_<op>_<D><V>(int c), t i int, u unsigned int,
   l long, n unsigned long; op d /, m %. */
struct sv2 { int x; int arr[8]; unsigned int u[8]; long l[8]; unsigned long n[8]; };
extern struct sv2 *gp;

void sv2_i_d_ER(int c) { gp->arr[c] = gp->arr[c] / c; }
void sv2_i_d_ES(int c) { gp->arr[c] = gp->arr[c] / gp->arr[c]; }
void sv2_i_d_PR(int c) { gp->x = gp->arr[c] / c; }
void sv2_i_d_PS(int c) { gp->x = gp->arr[c] / gp->arr[c]; }
void sv2_i_m_ER(int c) { gp->arr[c] = gp->arr[c] % c; }
void sv2_i_m_ES(int c) { gp->arr[c] = gp->arr[c] % gp->arr[c]; }
void sv2_i_m_PR(int c) { gp->x = gp->arr[c] % c; }
void sv2_i_m_PS(int c) { gp->x = gp->arr[c] % gp->arr[c]; }

void sv2_u_d_ER(int c) { gp->u[c] = gp->u[c] / c; }
void sv2_u_d_ES(int c) { gp->u[c] = gp->u[c] / gp->u[c]; }
void sv2_u_d_PR(int c) { gp->x = gp->u[c] / c; }
void sv2_u_d_PS(int c) { gp->x = gp->u[c] / gp->u[c]; }
void sv2_u_m_ER(int c) { gp->u[c] = gp->u[c] % c; }
void sv2_u_m_ES(int c) { gp->u[c] = gp->u[c] % gp->u[c]; }
void sv2_u_m_PR(int c) { gp->x = gp->u[c] % c; }
void sv2_u_m_PS(int c) { gp->x = gp->u[c] % gp->u[c]; }

void sv2_l_d_ER(int c) { gp->l[c] = gp->l[c] / c; }
void sv2_l_d_ES(int c) { gp->l[c] = gp->l[c] / gp->l[c]; }
void sv2_l_d_PR(int c) { gp->x = gp->l[c] / c; }
void sv2_l_d_PS(int c) { gp->x = gp->l[c] / gp->l[c]; }
void sv2_l_m_ER(int c) { gp->l[c] = gp->l[c] % c; }
void sv2_l_m_ES(int c) { gp->l[c] = gp->l[c] % gp->l[c]; }
void sv2_l_m_PR(int c) { gp->x = gp->l[c] % c; }
void sv2_l_m_PS(int c) { gp->x = gp->l[c] % gp->l[c]; }

void sv2_n_d_ER(int c) { gp->n[c] = gp->n[c] / c; }
void sv2_n_d_ES(int c) { gp->n[c] = gp->n[c] / gp->n[c]; }
void sv2_n_d_PR(int c) { gp->x = gp->n[c] / c; }
void sv2_n_d_PS(int c) { gp->x = gp->n[c] / gp->n[c]; }
void sv2_n_m_ER(int c) { gp->n[c] = gp->n[c] % c; }
void sv2_n_m_ES(int c) { gp->n[c] = gp->n[c] % gp->n[c]; }
void sv2_n_m_PR(int c) { gp->x = gp->n[c] % c; }
void sv2_n_m_PS(int c) { gp->x = gp->n[c] % gp->n[c]; }
