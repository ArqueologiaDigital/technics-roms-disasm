/* An element at a local index (gen_idxloc.py): il_<t>_<H><S>(c) for int (i), long (l), char (c); H: L loop counter,
   T a local across a call, R a register temporary; S: 1 load, 2 store of a global, 3 store of a constant, 4 store of
   a call, 5 global minus the element, 6 element plus a global, 7 argument, 8 argument global minus element,
   9 compare, A element op= global, B address, C element minus another array's element. */
extern int gi, gi3, gx, hx; extern long gxl, hxl; extern char gxc, hxc;
extern int gia[8], hia[8]; extern long gla[8], hla[8]; extern char gca[8], hca[8];
extern int *gpx; extern long *gpl; extern char *gpc;
extern void v0(void); extern void v1(int); extern void vl(long); extern void vc(char);
extern int ri(void); extern long rl(void); extern char rc(void);

void il_i_L1(int c) { int i; for (i = 0; i < 4; i++) { gx = gia[i]; v0(); } }
void il_i_L2(int c) { int i; for (i = 0; i < 4; i++) { gia[i] = hx; v0(); } }
void il_i_L3(int c) { int i; for (i = 0; i < 4; i++) { gia[i] = 7; v0(); } }
void il_i_L4(int c) { int i; for (i = 0; i < 4; i++) { gia[i] = ri(); v0(); } }
void il_i_L5(int c) { int i; for (i = 0; i < 4; i++) { gx = hx - gia[i]; v0(); } }
void il_i_L6(int c) { int i; for (i = 0; i < 4; i++) { gx = gia[i] + hx; v0(); } }
void il_i_L7(int c) { int i; for (i = 0; i < 4; i++) { v1(gia[i]); v0(); } }
void il_i_L8(int c) { int i; for (i = 0; i < 4; i++) { v1(hx - gia[i]); v0(); } }
void il_i_L9(int c) { int i; for (i = 0; i < 4; i++) { if (gia[i] < hx) gi3 = 1; v0(); } }
void il_i_LA(int c) { int i; for (i = 0; i < 4; i++) { gia[i] += hx; v0(); } }
void il_i_LB(int c) { int i; for (i = 0; i < 4; i++) { gpx = &gia[i]; v0(); } }
void il_i_LC(int c) { int i; for (i = 0; i < 4; i++) { gx = gia[i] - hia[i]; v0(); } }
void il_i_T1(int c) { int t = gi; v0(); gx = gia[t]; v0(); }
void il_i_T2(int c) { int t = gi; v0(); gia[t] = hx; v0(); }
void il_i_T3(int c) { int t = gi; v0(); gia[t] = 7; v0(); }
void il_i_T4(int c) { int t = gi; v0(); gia[t] = ri(); v0(); }
void il_i_T5(int c) { int t = gi; v0(); gx = hx - gia[t]; v0(); }
void il_i_T6(int c) { int t = gi; v0(); gx = gia[t] + hx; v0(); }
void il_i_T7(int c) { int t = gi; v0(); v1(gia[t]); v0(); }
void il_i_T8(int c) { int t = gi; v0(); v1(hx - gia[t]); v0(); }
void il_i_T9(int c) { int t = gi; v0(); if (gia[t] < hx) gi3 = 1; v0(); }
void il_i_TA(int c) { int t = gi; v0(); gia[t] += hx; v0(); }
void il_i_TB(int c) { int t = gi; v0(); gpx = &gia[t]; v0(); }
void il_i_TC(int c) { int t = gi; v0(); gx = gia[t] - hia[t]; v0(); }
void il_i_R1(int c) { int t = gi; gx = gia[t]; }
void il_i_R2(int c) { int t = gi; gia[t] = hx; }
void il_i_R3(int c) { int t = gi; gia[t] = 7; }
void il_i_R4(int c) { int t = gi; gia[t] = ri(); }
void il_i_R5(int c) { int t = gi; gx = hx - gia[t]; }
void il_i_R6(int c) { int t = gi; gx = gia[t] + hx; }
void il_i_R7(int c) { int t = gi; v1(gia[t]); }
void il_i_R8(int c) { int t = gi; v1(hx - gia[t]); }
void il_i_R9(int c) { int t = gi; if (gia[t] < hx) gi3 = 1; }
void il_i_RA(int c) { int t = gi; gia[t] += hx; }
void il_i_RB(int c) { int t = gi; gpx = &gia[t]; }
void il_i_RC(int c) { int t = gi; gx = gia[t] - hia[t]; }

void il_l_L1(int c) { int i; for (i = 0; i < 4; i++) { gxl = gla[i]; v0(); } }
void il_l_L2(int c) { int i; for (i = 0; i < 4; i++) { gla[i] = hxl; v0(); } }
void il_l_L3(int c) { int i; for (i = 0; i < 4; i++) { gla[i] = 7; v0(); } }
void il_l_L4(int c) { int i; for (i = 0; i < 4; i++) { gla[i] = rl(); v0(); } }
void il_l_L5(int c) { int i; for (i = 0; i < 4; i++) { gxl = hxl - gla[i]; v0(); } }
void il_l_L6(int c) { int i; for (i = 0; i < 4; i++) { gxl = gla[i] + hxl; v0(); } }
void il_l_L7(int c) { int i; for (i = 0; i < 4; i++) { vl(gla[i]); v0(); } }
void il_l_L8(int c) { int i; for (i = 0; i < 4; i++) { vl(hxl - gla[i]); v0(); } }
void il_l_L9(int c) { int i; for (i = 0; i < 4; i++) { if (gla[i] < hxl) gi3 = 1; v0(); } }
void il_l_LA(int c) { int i; for (i = 0; i < 4; i++) { gla[i] += hxl; v0(); } }
void il_l_LB(int c) { int i; for (i = 0; i < 4; i++) { gpl = &gla[i]; v0(); } }
void il_l_LC(int c) { int i; for (i = 0; i < 4; i++) { gxl = gla[i] - hla[i]; v0(); } }
void il_l_T1(int c) { int t = gi; v0(); gxl = gla[t]; v0(); }
void il_l_T2(int c) { int t = gi; v0(); gla[t] = hxl; v0(); }
void il_l_T3(int c) { int t = gi; v0(); gla[t] = 7; v0(); }
void il_l_T4(int c) { int t = gi; v0(); gla[t] = rl(); v0(); }
void il_l_T5(int c) { int t = gi; v0(); gxl = hxl - gla[t]; v0(); }
void il_l_T6(int c) { int t = gi; v0(); gxl = gla[t] + hxl; v0(); }
void il_l_T7(int c) { int t = gi; v0(); vl(gla[t]); v0(); }
void il_l_T8(int c) { int t = gi; v0(); vl(hxl - gla[t]); v0(); }
void il_l_T9(int c) { int t = gi; v0(); if (gla[t] < hxl) gi3 = 1; v0(); }
void il_l_TA(int c) { int t = gi; v0(); gla[t] += hxl; v0(); }
void il_l_TB(int c) { int t = gi; v0(); gpl = &gla[t]; v0(); }
void il_l_TC(int c) { int t = gi; v0(); gxl = gla[t] - hla[t]; v0(); }
void il_l_R1(int c) { int t = gi; gxl = gla[t]; }
void il_l_R2(int c) { int t = gi; gla[t] = hxl; }
void il_l_R3(int c) { int t = gi; gla[t] = 7; }
void il_l_R4(int c) { int t = gi; gla[t] = rl(); }
void il_l_R5(int c) { int t = gi; gxl = hxl - gla[t]; }
void il_l_R6(int c) { int t = gi; gxl = gla[t] + hxl; }
void il_l_R7(int c) { int t = gi; vl(gla[t]); }
void il_l_R8(int c) { int t = gi; vl(hxl - gla[t]); }
void il_l_R9(int c) { int t = gi; if (gla[t] < hxl) gi3 = 1; }
void il_l_RA(int c) { int t = gi; gla[t] += hxl; }
void il_l_RB(int c) { int t = gi; gpl = &gla[t]; }
void il_l_RC(int c) { int t = gi; gxl = gla[t] - hla[t]; }

void il_c_L1(int c) { int i; for (i = 0; i < 4; i++) { gxc = gca[i]; v0(); } }
void il_c_L2(int c) { int i; for (i = 0; i < 4; i++) { gca[i] = hxc; v0(); } }
void il_c_L3(int c) { int i; for (i = 0; i < 4; i++) { gca[i] = 7; v0(); } }
void il_c_L4(int c) { int i; for (i = 0; i < 4; i++) { gca[i] = rc(); v0(); } }
void il_c_L5(int c) { int i; for (i = 0; i < 4; i++) { gxc = hxc - gca[i]; v0(); } }
void il_c_L6(int c) { int i; for (i = 0; i < 4; i++) { gxc = gca[i] + hxc; v0(); } }
void il_c_L7(int c) { int i; for (i = 0; i < 4; i++) { vc(gca[i]); v0(); } }
void il_c_L8(int c) { int i; for (i = 0; i < 4; i++) { vc(hxc - gca[i]); v0(); } }
void il_c_L9(int c) { int i; for (i = 0; i < 4; i++) { if (gca[i] < hxc) gi3 = 1; v0(); } }
void il_c_LA(int c) { int i; for (i = 0; i < 4; i++) { gca[i] += hxc; v0(); } }
void il_c_LB(int c) { int i; for (i = 0; i < 4; i++) { gpc = &gca[i]; v0(); } }
void il_c_LC(int c) { int i; for (i = 0; i < 4; i++) { gxc = gca[i] - hca[i]; v0(); } }
void il_c_T1(int c) { int t = gi; v0(); gxc = gca[t]; v0(); }
void il_c_T2(int c) { int t = gi; v0(); gca[t] = hxc; v0(); }
void il_c_T3(int c) { int t = gi; v0(); gca[t] = 7; v0(); }
void il_c_T4(int c) { int t = gi; v0(); gca[t] = rc(); v0(); }
void il_c_T5(int c) { int t = gi; v0(); gxc = hxc - gca[t]; v0(); }
void il_c_T6(int c) { int t = gi; v0(); gxc = gca[t] + hxc; v0(); }
void il_c_T7(int c) { int t = gi; v0(); vc(gca[t]); v0(); }
void il_c_T8(int c) { int t = gi; v0(); vc(hxc - gca[t]); v0(); }
void il_c_T9(int c) { int t = gi; v0(); if (gca[t] < hxc) gi3 = 1; v0(); }
void il_c_TA(int c) { int t = gi; v0(); gca[t] += hxc; v0(); }
void il_c_TB(int c) { int t = gi; v0(); gpc = &gca[t]; v0(); }
void il_c_TC(int c) { int t = gi; v0(); gxc = gca[t] - hca[t]; v0(); }
void il_c_R1(int c) { int t = gi; gxc = gca[t]; }
void il_c_R2(int c) { int t = gi; gca[t] = hxc; }
void il_c_R3(int c) { int t = gi; gca[t] = 7; }
void il_c_R4(int c) { int t = gi; gca[t] = rc(); }
void il_c_R5(int c) { int t = gi; gxc = hxc - gca[t]; }
void il_c_R6(int c) { int t = gi; gxc = gca[t] + hxc; }
void il_c_R7(int c) { int t = gi; vc(gca[t]); }
void il_c_R8(int c) { int t = gi; vc(hxc - gca[t]); }
void il_c_R9(int c) { int t = gi; if (gca[t] < hxc) gi3 = 1; }
void il_c_RA(int c) { int t = gi; gca[t] += hxc; }
void il_c_RB(int c) { int t = gi; gpc = &gca[t]; }
void il_c_RC(int c) { int t = gi; gxc = gca[t] - hca[t]; }

