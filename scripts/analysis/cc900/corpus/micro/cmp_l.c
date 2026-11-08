/* Comparisons at type long: as values and as branch conditions. */
extern long gl1;
extern void hit(void);
int eq_l_val(long a, long b) { return a == b; }
void eq_l_br(long a, long b) { if (a == b) hit(); }
void eq_l_brk(long a) { if (a == 7) hit(); }
void eq_l_br0(long a) { if (a == 0) hit(); }
void eq_l_brg(void) { if (gl1 == 3) hit(); }
int ne_l_val(long a, long b) { return a != b; }
void ne_l_br(long a, long b) { if (a != b) hit(); }
void ne_l_brk(long a) { if (a != 7) hit(); }
void ne_l_br0(long a) { if (a != 0) hit(); }
void ne_l_brg(void) { if (gl1 != 3) hit(); }
int lt_l_val(long a, long b) { return a < b; }
void lt_l_br(long a, long b) { if (a < b) hit(); }
void lt_l_brk(long a) { if (a < 7) hit(); }
void lt_l_br0(long a) { if (a < 0) hit(); }
void lt_l_brg(void) { if (gl1 < 3) hit(); }
int le_l_val(long a, long b) { return a <= b; }
void le_l_br(long a, long b) { if (a <= b) hit(); }
void le_l_brk(long a) { if (a <= 7) hit(); }
void le_l_br0(long a) { if (a <= 0) hit(); }
void le_l_brg(void) { if (gl1 <= 3) hit(); }
int gt_l_val(long a, long b) { return a > b; }
void gt_l_br(long a, long b) { if (a > b) hit(); }
void gt_l_brk(long a) { if (a > 7) hit(); }
void gt_l_br0(long a) { if (a > 0) hit(); }
void gt_l_brg(void) { if (gl1 > 3) hit(); }
int ge_l_val(long a, long b) { return a >= b; }
void ge_l_br(long a, long b) { if (a >= b) hit(); }
void ge_l_brk(long a) { if (a >= 7) hit(); }
void ge_l_br0(long a) { if (a >= 0) hit(); }
void ge_l_brg(void) { if (gl1 >= 3) hit(); }
