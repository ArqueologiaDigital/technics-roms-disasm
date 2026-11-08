/* Comparisons at type unsigned char: as values and as branch conditions. */
extern unsigned char guc1;
extern void hit(void);
int eq_uc_val(unsigned char a, unsigned char b) { return a == b; }
void eq_uc_br(unsigned char a, unsigned char b) { if (a == b) hit(); }
void eq_uc_brk(unsigned char a) { if (a == 7) hit(); }
void eq_uc_br0(unsigned char a) { if (a == 0) hit(); }
void eq_uc_brg(void) { if (guc1 == 3) hit(); }
int ne_uc_val(unsigned char a, unsigned char b) { return a != b; }
void ne_uc_br(unsigned char a, unsigned char b) { if (a != b) hit(); }
void ne_uc_brk(unsigned char a) { if (a != 7) hit(); }
void ne_uc_br0(unsigned char a) { if (a != 0) hit(); }
void ne_uc_brg(void) { if (guc1 != 3) hit(); }
int lt_uc_val(unsigned char a, unsigned char b) { return a < b; }
void lt_uc_br(unsigned char a, unsigned char b) { if (a < b) hit(); }
void lt_uc_brk(unsigned char a) { if (a < 7) hit(); }
void lt_uc_br0(unsigned char a) { if (a < 0) hit(); }
void lt_uc_brg(void) { if (guc1 < 3) hit(); }
int le_uc_val(unsigned char a, unsigned char b) { return a <= b; }
void le_uc_br(unsigned char a, unsigned char b) { if (a <= b) hit(); }
void le_uc_brk(unsigned char a) { if (a <= 7) hit(); }
void le_uc_br0(unsigned char a) { if (a <= 0) hit(); }
void le_uc_brg(void) { if (guc1 <= 3) hit(); }
int gt_uc_val(unsigned char a, unsigned char b) { return a > b; }
void gt_uc_br(unsigned char a, unsigned char b) { if (a > b) hit(); }
void gt_uc_brk(unsigned char a) { if (a > 7) hit(); }
void gt_uc_br0(unsigned char a) { if (a > 0) hit(); }
void gt_uc_brg(void) { if (guc1 > 3) hit(); }
int ge_uc_val(unsigned char a, unsigned char b) { return a >= b; }
void ge_uc_br(unsigned char a, unsigned char b) { if (a >= b) hit(); }
void ge_uc_brk(unsigned char a) { if (a >= 7) hit(); }
void ge_uc_br0(unsigned char a) { if (a >= 0) hit(); }
void ge_uc_brg(void) { if (guc1 >= 3) hit(); }
