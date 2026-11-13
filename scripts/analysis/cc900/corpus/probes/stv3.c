/* Layout and index variants of the pointer-member element store (gen_stv3.py). */
struct sa { int x; int arr[8]; unsigned long n[8]; };
struct sb { char pad; int x; int arr[8]; unsigned long n[8]; };
extern struct sa *ga; extern struct sb *gb;

void sv3_ac_i_d_E(int c) { ga->arr[c] = ga->arr[c] / c; }
void sv3_ac_i_d_P(int c) { ga->x = ga->arr[c] / c; }
void sv3_ac_i_m_E(int c) { ga->arr[c] = ga->arr[c] % c; }
void sv3_ac_i_m_P(int c) { ga->x = ga->arr[c] % c; }
void sv3_ac_n_d_E(int c) { ga->n[c] = ga->n[c] / c; }
void sv3_ac_n_d_P(int c) { ga->x = ga->n[c] / c; }
void sv3_ac_n_m_E(int c) { ga->n[c] = ga->n[c] % c; }
void sv3_ac_n_m_P(int c) { ga->x = ga->n[c] % c; }
void sv3_au_i_d_E(unsigned char c) { ga->arr[c] = ga->arr[c] / c; }
void sv3_au_i_d_P(unsigned char c) { ga->x = ga->arr[c] / c; }
void sv3_au_i_m_E(unsigned char c) { ga->arr[c] = ga->arr[c] % c; }
void sv3_au_i_m_P(unsigned char c) { ga->x = ga->arr[c] % c; }
void sv3_au_n_d_E(unsigned char c) { ga->n[c] = ga->n[c] / c; }
void sv3_au_n_d_P(unsigned char c) { ga->x = ga->n[c] / c; }
void sv3_au_n_m_E(unsigned char c) { ga->n[c] = ga->n[c] % c; }
void sv3_au_n_m_P(unsigned char c) { ga->x = ga->n[c] % c; }
void sv3_ak_i_d_E(int c) { int k = c; ga->arr[k] = ga->arr[k] / c; }
void sv3_ak_i_d_P(int c) { int k = c; ga->x = ga->arr[k] / c; }
void sv3_ak_i_m_E(int c) { int k = c; ga->arr[k] = ga->arr[k] % c; }
void sv3_ak_i_m_P(int c) { int k = c; ga->x = ga->arr[k] % c; }
void sv3_ak_n_d_E(int c) { int k = c; ga->n[k] = ga->n[k] / c; }
void sv3_ak_n_d_P(int c) { int k = c; ga->x = ga->n[k] / c; }
void sv3_ak_n_m_E(int c) { int k = c; ga->n[k] = ga->n[k] % c; }
void sv3_ak_n_m_P(int c) { int k = c; ga->x = ga->n[k] % c; }

void sv3_bc_i_d_E(int c) { gb->arr[c] = gb->arr[c] / c; }
void sv3_bc_i_d_P(int c) { gb->x = gb->arr[c] / c; }
void sv3_bc_i_m_E(int c) { gb->arr[c] = gb->arr[c] % c; }
void sv3_bc_i_m_P(int c) { gb->x = gb->arr[c] % c; }
void sv3_bc_n_d_E(int c) { gb->n[c] = gb->n[c] / c; }
void sv3_bc_n_d_P(int c) { gb->x = gb->n[c] / c; }
void sv3_bc_n_m_E(int c) { gb->n[c] = gb->n[c] % c; }
void sv3_bc_n_m_P(int c) { gb->x = gb->n[c] % c; }
void sv3_bu_i_d_E(unsigned char c) { gb->arr[c] = gb->arr[c] / c; }
void sv3_bu_i_d_P(unsigned char c) { gb->x = gb->arr[c] / c; }
void sv3_bu_i_m_E(unsigned char c) { gb->arr[c] = gb->arr[c] % c; }
void sv3_bu_i_m_P(unsigned char c) { gb->x = gb->arr[c] % c; }
void sv3_bu_n_d_E(unsigned char c) { gb->n[c] = gb->n[c] / c; }
void sv3_bu_n_d_P(unsigned char c) { gb->x = gb->n[c] / c; }
void sv3_bu_n_m_E(unsigned char c) { gb->n[c] = gb->n[c] % c; }
void sv3_bu_n_m_P(unsigned char c) { gb->x = gb->n[c] % c; }
void sv3_bk_i_d_E(int c) { int k = c; gb->arr[k] = gb->arr[k] / c; }
void sv3_bk_i_d_P(int c) { int k = c; gb->x = gb->arr[k] / c; }
void sv3_bk_i_m_E(int c) { int k = c; gb->arr[k] = gb->arr[k] % c; }
void sv3_bk_i_m_P(int c) { int k = c; gb->x = gb->arr[k] % c; }
void sv3_bk_n_d_E(int c) { int k = c; gb->n[k] = gb->n[k] / c; }
void sv3_bk_n_d_P(int c) { int k = c; gb->x = gb->n[k] / c; }
void sv3_bk_n_m_E(int c) { int k = c; gb->n[k] = gb->n[k] % c; }
void sv3_bk_n_m_P(int c) { int k = c; gb->x = gb->n[k] % c; }
