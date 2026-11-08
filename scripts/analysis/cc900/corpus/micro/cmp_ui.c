/* Comparisons at type unsigned int: as values and as branch conditions. */
extern unsigned int gui1;
extern void hit(void);
int eq_ui_val(unsigned int a, unsigned int b) { return a == b; }
void eq_ui_br(unsigned int a, unsigned int b) { if (a == b) hit(); }
void eq_ui_brk(unsigned int a) { if (a == 7) hit(); }
void eq_ui_br0(unsigned int a) { if (a == 0) hit(); }
void eq_ui_brg(void) { if (gui1 == 3) hit(); }
int ne_ui_val(unsigned int a, unsigned int b) { return a != b; }
void ne_ui_br(unsigned int a, unsigned int b) { if (a != b) hit(); }
void ne_ui_brk(unsigned int a) { if (a != 7) hit(); }
void ne_ui_br0(unsigned int a) { if (a != 0) hit(); }
void ne_ui_brg(void) { if (gui1 != 3) hit(); }
int lt_ui_val(unsigned int a, unsigned int b) { return a < b; }
void lt_ui_br(unsigned int a, unsigned int b) { if (a < b) hit(); }
void lt_ui_brk(unsigned int a) { if (a < 7) hit(); }
void lt_ui_br0(unsigned int a) { if (a < 0) hit(); }
void lt_ui_brg(void) { if (gui1 < 3) hit(); }
int le_ui_val(unsigned int a, unsigned int b) { return a <= b; }
void le_ui_br(unsigned int a, unsigned int b) { if (a <= b) hit(); }
void le_ui_brk(unsigned int a) { if (a <= 7) hit(); }
void le_ui_br0(unsigned int a) { if (a <= 0) hit(); }
void le_ui_brg(void) { if (gui1 <= 3) hit(); }
int gt_ui_val(unsigned int a, unsigned int b) { return a > b; }
void gt_ui_br(unsigned int a, unsigned int b) { if (a > b) hit(); }
void gt_ui_brk(unsigned int a) { if (a > 7) hit(); }
void gt_ui_br0(unsigned int a) { if (a > 0) hit(); }
void gt_ui_brg(void) { if (gui1 > 3) hit(); }
int ge_ui_val(unsigned int a, unsigned int b) { return a >= b; }
void ge_ui_br(unsigned int a, unsigned int b) { if (a >= b) hit(); }
void ge_ui_brk(unsigned int a) { if (a >= 7) hit(); }
void ge_ui_br0(unsigned int a) { if (a >= 0) hit(); }
void ge_ui_brg(void) { if (gui1 >= 3) hit(); }
