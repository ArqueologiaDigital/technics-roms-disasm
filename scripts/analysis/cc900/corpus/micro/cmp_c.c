/* Comparisons at type char: as values and as branch conditions. */
extern char gc1;
extern void hit(void);
int eq_c_val(char a, char b) { return a == b; }
void eq_c_br(char a, char b) { if (a == b) hit(); }
void eq_c_brk(char a) { if (a == 7) hit(); }
void eq_c_br0(char a) { if (a == 0) hit(); }
void eq_c_brg(void) { if (gc1 == 3) hit(); }
int ne_c_val(char a, char b) { return a != b; }
void ne_c_br(char a, char b) { if (a != b) hit(); }
void ne_c_brk(char a) { if (a != 7) hit(); }
void ne_c_br0(char a) { if (a != 0) hit(); }
void ne_c_brg(void) { if (gc1 != 3) hit(); }
int lt_c_val(char a, char b) { return a < b; }
void lt_c_br(char a, char b) { if (a < b) hit(); }
void lt_c_brk(char a) { if (a < 7) hit(); }
void lt_c_br0(char a) { if (a < 0) hit(); }
void lt_c_brg(void) { if (gc1 < 3) hit(); }
int le_c_val(char a, char b) { return a <= b; }
void le_c_br(char a, char b) { if (a <= b) hit(); }
void le_c_brk(char a) { if (a <= 7) hit(); }
void le_c_br0(char a) { if (a <= 0) hit(); }
void le_c_brg(void) { if (gc1 <= 3) hit(); }
int gt_c_val(char a, char b) { return a > b; }
void gt_c_br(char a, char b) { if (a > b) hit(); }
void gt_c_brk(char a) { if (a > 7) hit(); }
void gt_c_br0(char a) { if (a > 0) hit(); }
void gt_c_brg(void) { if (gc1 > 3) hit(); }
int ge_c_val(char a, char b) { return a >= b; }
void ge_c_br(char a, char b) { if (a >= b) hit(); }
void ge_c_brk(char a) { if (a >= 7) hit(); }
void ge_c_br0(char a) { if (a >= 0) hit(); }
void ge_c_brg(void) { if (gc1 >= 3) hit(); }
