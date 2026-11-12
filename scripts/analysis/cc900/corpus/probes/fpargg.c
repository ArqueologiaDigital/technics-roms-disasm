/* The construct around one double temporary (gen_fpargg.py): ag_<C><P><V>.  C: I if, E if / else, Q ?:, A &&,
   H a shift by a variable, W while, F for, D do-while, S switch, G a block, N a nested if.  P: B before the
   double statement, A after it.  V: C vd(gd * gd2), O gd += gd2 / 3.0. */
extern double gd, gd2; extern int gi, gi2; extern unsigned int gu; extern long gl; extern void vd(double);

void ag_IBC(void) { if (gi) gu = 1; vd(gd * gd2); }
void ag_IBO(void) { if (gi) gu = 1; gd += gd2 / 3.0; }
void ag_IAC(void) { vd(gd * gd2); if (gi) gu = 1; }
void ag_IAO(void) { gd += gd2 / 3.0; if (gi) gu = 1; }
void ag_EBC(void) { if (gi) gu = 1; else gu = 2; vd(gd * gd2); }
void ag_EBO(void) { if (gi) gu = 1; else gu = 2; gd += gd2 / 3.0; }
void ag_EAC(void) { vd(gd * gd2); if (gi) gu = 1; else gu = 2; }
void ag_EAO(void) { gd += gd2 / 3.0; if (gi) gu = 1; else gu = 2; }
void ag_QBC(void) { gu = gi ? 5 : 7; vd(gd * gd2); }
void ag_QBO(void) { gu = gi ? 5 : 7; gd += gd2 / 3.0; }
void ag_QAC(void) { vd(gd * gd2); gu = gi ? 5 : 7; }
void ag_QAO(void) { gd += gd2 / 3.0; gu = gi ? 5 : 7; }
void ag_ABC(void) { gu = gi && gi2; vd(gd * gd2); }
void ag_ABO(void) { gu = gi && gi2; gd += gd2 / 3.0; }
void ag_AAC(void) { vd(gd * gd2); gu = gi && gi2; }
void ag_AAO(void) { gd += gd2 / 3.0; gu = gi && gi2; }
void ag_HBC(void) { gu = gu << gi; vd(gd * gd2); }
void ag_HBO(void) { gu = gu << gi; gd += gd2 / 3.0; }
void ag_HAC(void) { vd(gd * gd2); gu = gu << gi; }
void ag_HAO(void) { gd += gd2 / 3.0; gu = gu << gi; }
void ag_WBC(void) { while (gi > 0) gi--; vd(gd * gd2); }
void ag_WBO(void) { while (gi > 0) gi--; gd += gd2 / 3.0; }
void ag_WAC(void) { vd(gd * gd2); while (gi > 0) gi--; }
void ag_WAO(void) { gd += gd2 / 3.0; while (gi > 0) gi--; }
void ag_FBC(void) { for (gi = 0; gi < 4; gi++) gu += 9; vd(gd * gd2); }
void ag_FBO(void) { for (gi = 0; gi < 4; gi++) gu += 9; gd += gd2 / 3.0; }
void ag_FAC(void) { vd(gd * gd2); for (gi = 0; gi < 4; gi++) gu += 9; }
void ag_FAO(void) { gd += gd2 / 3.0; for (gi = 0; gi < 4; gi++) gu += 9; }
void ag_DBC(void) { do gi--; while (gi > 0); vd(gd * gd2); }
void ag_DBO(void) { do gi--; while (gi > 0); gd += gd2 / 3.0; }
void ag_DAC(void) { vd(gd * gd2); do gi--; while (gi > 0); }
void ag_DAO(void) { gd += gd2 / 3.0; do gi--; while (gi > 0); }
void ag_SBC(void) { switch (gu) { case 1: gl = 5; break; case 5: gl = 6; break; } vd(gd * gd2); }
void ag_SBO(void) { switch (gu) { case 1: gl = 5; break; case 5: gl = 6; break; } gd += gd2 / 3.0; }
void ag_SAC(void) { vd(gd * gd2); switch (gu) { case 1: gl = 5; break; case 5: gl = 6; break; } }
void ag_SAO(void) { gd += gd2 / 3.0; switch (gu) { case 1: gl = 5; break; case 5: gl = 6; break; } }
void ag_GBC(void) { { gu = 1; } vd(gd * gd2); }
void ag_GBO(void) { { gu = 1; } gd += gd2 / 3.0; }
void ag_GAC(void) { vd(gd * gd2); { gu = 1; } }
void ag_GAO(void) { gd += gd2 / 3.0; { gu = 1; } }
void ag_NBC(void) { if (gi) { if (gi2) gu = 1; } vd(gd * gd2); }
void ag_NBO(void) { if (gi) { if (gi2) gu = 1; } gd += gd2 / 3.0; }
void ag_NAC(void) { vd(gd * gd2); if (gi) { if (gi2) gu = 1; } }
void ag_NAO(void) { gd += gd2 / 3.0; if (gi) { if (gi2) gu = 1; } }
