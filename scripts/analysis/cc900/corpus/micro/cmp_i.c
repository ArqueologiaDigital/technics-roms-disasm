/* Comparisons at type int: as values and as branch conditions. */
extern int gi1;
extern void hit(void);
int eq_i_val(int a, int b) { return a == b; }
void eq_i_br(int a, int b) { if (a == b) hit(); }
void eq_i_brk(int a) { if (a == 7) hit(); }
void eq_i_br0(int a) { if (a == 0) hit(); }
void eq_i_brg(void) { if (gi1 == 3) hit(); }
int ne_i_val(int a, int b) { return a != b; }
void ne_i_br(int a, int b) { if (a != b) hit(); }
void ne_i_brk(int a) { if (a != 7) hit(); }
void ne_i_br0(int a) { if (a != 0) hit(); }
void ne_i_brg(void) { if (gi1 != 3) hit(); }
int lt_i_val(int a, int b) { return a < b; }
void lt_i_br(int a, int b) { if (a < b) hit(); }
void lt_i_brk(int a) { if (a < 7) hit(); }
void lt_i_br0(int a) { if (a < 0) hit(); }
void lt_i_brg(void) { if (gi1 < 3) hit(); }
int le_i_val(int a, int b) { return a <= b; }
void le_i_br(int a, int b) { if (a <= b) hit(); }
void le_i_brk(int a) { if (a <= 7) hit(); }
void le_i_br0(int a) { if (a <= 0) hit(); }
void le_i_brg(void) { if (gi1 <= 3) hit(); }
int gt_i_val(int a, int b) { return a > b; }
void gt_i_br(int a, int b) { if (a > b) hit(); }
void gt_i_brk(int a) { if (a > 7) hit(); }
void gt_i_br0(int a) { if (a > 0) hit(); }
void gt_i_brg(void) { if (gi1 > 3) hit(); }
int ge_i_val(int a, int b) { return a >= b; }
void ge_i_br(int a, int b) { if (a >= b) hit(); }
void ge_i_brk(int a) { if (a >= 7) hit(); }
void ge_i_br0(int a) { if (a >= 0) hit(); }
void ge_i_brg(void) { if (gi1 >= 3) hit(); }
