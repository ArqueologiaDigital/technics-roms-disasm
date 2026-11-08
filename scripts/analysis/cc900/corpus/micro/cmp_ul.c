/* Comparisons at type unsigned long: as values and as branch conditions. */
extern unsigned long gul1;
extern void hit(void);
int eq_ul_val(unsigned long a, unsigned long b) { return a == b; }
void eq_ul_br(unsigned long a, unsigned long b) { if (a == b) hit(); }
void eq_ul_brk(unsigned long a) { if (a == 7) hit(); }
void eq_ul_br0(unsigned long a) { if (a == 0) hit(); }
void eq_ul_brg(void) { if (gul1 == 3) hit(); }
int ne_ul_val(unsigned long a, unsigned long b) { return a != b; }
void ne_ul_br(unsigned long a, unsigned long b) { if (a != b) hit(); }
void ne_ul_brk(unsigned long a) { if (a != 7) hit(); }
void ne_ul_br0(unsigned long a) { if (a != 0) hit(); }
void ne_ul_brg(void) { if (gul1 != 3) hit(); }
int lt_ul_val(unsigned long a, unsigned long b) { return a < b; }
void lt_ul_br(unsigned long a, unsigned long b) { if (a < b) hit(); }
void lt_ul_brk(unsigned long a) { if (a < 7) hit(); }
void lt_ul_br0(unsigned long a) { if (a < 0) hit(); }
void lt_ul_brg(void) { if (gul1 < 3) hit(); }
int le_ul_val(unsigned long a, unsigned long b) { return a <= b; }
void le_ul_br(unsigned long a, unsigned long b) { if (a <= b) hit(); }
void le_ul_brk(unsigned long a) { if (a <= 7) hit(); }
void le_ul_br0(unsigned long a) { if (a <= 0) hit(); }
void le_ul_brg(void) { if (gul1 <= 3) hit(); }
int gt_ul_val(unsigned long a, unsigned long b) { return a > b; }
void gt_ul_br(unsigned long a, unsigned long b) { if (a > b) hit(); }
void gt_ul_brk(unsigned long a) { if (a > 7) hit(); }
void gt_ul_br0(unsigned long a) { if (a > 0) hit(); }
void gt_ul_brg(void) { if (gul1 > 3) hit(); }
int ge_ul_val(unsigned long a, unsigned long b) { return a >= b; }
void ge_ul_br(unsigned long a, unsigned long b) { if (a >= b) hit(); }
void ge_ul_brk(unsigned long a) { if (a >= 7) hit(); }
void ge_ul_br0(unsigned long a) { if (a >= 0) hit(); }
void ge_ul_brg(void) { if (gul1 >= 3) hit(); }
