/* Char arithmetic by operand kind and shift count (gen_chararith2.py): cb_<K><S>_<E>_<C>(a, pc, puc).
   K: g plain global, e constant element, x element at the int parameter a, p *pointer, m member through a pointer,
   r the char parameter itself; S: s signed, u unsigned.  E: ng -x, s1 / s2 / s5 / s7 x << k, mk x * 61, cp ~x, ak x + 3.
   C: si gi = E, ri returned as an int, sd E / 10, sr E >> 3, cm if (E > 5), sl gl = E. */
struct sv { char c; unsigned char uc; int i; };
extern char gc, gca[8], *gp; extern unsigned char guc, guca[8], *gup; extern struct sv *gps;
extern int gi; extern long gl; extern void v0(void);
void cb_gs_ng_si(int a, char pc, unsigned char puc) { gi = -gc; }
int cb_gs_ng_ri(int a, char pc, unsigned char puc) { return -gc; }
int cb_gs_ng_sd(int a, char pc, unsigned char puc) { return (-gc) / 10; }
int cb_gs_ng_sr(int a, char pc, unsigned char puc) { return (-gc) >> 3; }
void cb_gs_ng_cm(int a, char pc, unsigned char puc) { if ((-gc) > 5) v0(); }
void cb_gs_ng_sl(int a, char pc, unsigned char puc) { gl = -gc; }
void cb_gs_s1_si(int a, char pc, unsigned char puc) { gi = gc << 1; }
int cb_gs_s1_ri(int a, char pc, unsigned char puc) { return gc << 1; }
int cb_gs_s1_sd(int a, char pc, unsigned char puc) { return (gc << 1) / 10; }
int cb_gs_s1_sr(int a, char pc, unsigned char puc) { return (gc << 1) >> 3; }
void cb_gs_s1_cm(int a, char pc, unsigned char puc) { if ((gc << 1) > 5) v0(); }
void cb_gs_s1_sl(int a, char pc, unsigned char puc) { gl = gc << 1; }
void cb_gs_s2_si(int a, char pc, unsigned char puc) { gi = gc << 2; }
int cb_gs_s2_ri(int a, char pc, unsigned char puc) { return gc << 2; }
int cb_gs_s2_sd(int a, char pc, unsigned char puc) { return (gc << 2) / 10; }
int cb_gs_s2_sr(int a, char pc, unsigned char puc) { return (gc << 2) >> 3; }
void cb_gs_s2_cm(int a, char pc, unsigned char puc) { if ((gc << 2) > 5) v0(); }
void cb_gs_s2_sl(int a, char pc, unsigned char puc) { gl = gc << 2; }
void cb_gs_s5_si(int a, char pc, unsigned char puc) { gi = gc << 5; }
int cb_gs_s5_ri(int a, char pc, unsigned char puc) { return gc << 5; }
int cb_gs_s5_sd(int a, char pc, unsigned char puc) { return (gc << 5) / 10; }
int cb_gs_s5_sr(int a, char pc, unsigned char puc) { return (gc << 5) >> 3; }
void cb_gs_s5_cm(int a, char pc, unsigned char puc) { if ((gc << 5) > 5) v0(); }
void cb_gs_s5_sl(int a, char pc, unsigned char puc) { gl = gc << 5; }
void cb_gs_s7_si(int a, char pc, unsigned char puc) { gi = gc << 7; }
int cb_gs_s7_ri(int a, char pc, unsigned char puc) { return gc << 7; }
int cb_gs_s7_sd(int a, char pc, unsigned char puc) { return (gc << 7) / 10; }
int cb_gs_s7_sr(int a, char pc, unsigned char puc) { return (gc << 7) >> 3; }
void cb_gs_s7_cm(int a, char pc, unsigned char puc) { if ((gc << 7) > 5) v0(); }
void cb_gs_s7_sl(int a, char pc, unsigned char puc) { gl = gc << 7; }
void cb_gs_mk_si(int a, char pc, unsigned char puc) { gi = gc * 61; }
int cb_gs_mk_ri(int a, char pc, unsigned char puc) { return gc * 61; }
int cb_gs_mk_sd(int a, char pc, unsigned char puc) { return (gc * 61) / 10; }
int cb_gs_mk_sr(int a, char pc, unsigned char puc) { return (gc * 61) >> 3; }
void cb_gs_mk_cm(int a, char pc, unsigned char puc) { if ((gc * 61) > 5) v0(); }
void cb_gs_mk_sl(int a, char pc, unsigned char puc) { gl = gc * 61; }
void cb_gs_cp_si(int a, char pc, unsigned char puc) { gi = ~gc; }
int cb_gs_cp_ri(int a, char pc, unsigned char puc) { return ~gc; }
int cb_gs_cp_sd(int a, char pc, unsigned char puc) { return (~gc) / 10; }
int cb_gs_cp_sr(int a, char pc, unsigned char puc) { return (~gc) >> 3; }
void cb_gs_cp_cm(int a, char pc, unsigned char puc) { if ((~gc) > 5) v0(); }
void cb_gs_cp_sl(int a, char pc, unsigned char puc) { gl = ~gc; }
void cb_gs_ak_si(int a, char pc, unsigned char puc) { gi = gc + 3; }
int cb_gs_ak_ri(int a, char pc, unsigned char puc) { return gc + 3; }
int cb_gs_ak_sd(int a, char pc, unsigned char puc) { return (gc + 3) / 10; }
int cb_gs_ak_sr(int a, char pc, unsigned char puc) { return (gc + 3) >> 3; }
void cb_gs_ak_cm(int a, char pc, unsigned char puc) { if ((gc + 3) > 5) v0(); }
void cb_gs_ak_sl(int a, char pc, unsigned char puc) { gl = gc + 3; }
void cb_gu_ng_si(int a, char pc, unsigned char puc) { gi = -guc; }
int cb_gu_ng_ri(int a, char pc, unsigned char puc) { return -guc; }
int cb_gu_ng_sd(int a, char pc, unsigned char puc) { return (-guc) / 10; }
int cb_gu_ng_sr(int a, char pc, unsigned char puc) { return (-guc) >> 3; }
void cb_gu_ng_cm(int a, char pc, unsigned char puc) { if ((-guc) > 5) v0(); }
void cb_gu_ng_sl(int a, char pc, unsigned char puc) { gl = -guc; }
void cb_gu_s1_si(int a, char pc, unsigned char puc) { gi = guc << 1; }
int cb_gu_s1_ri(int a, char pc, unsigned char puc) { return guc << 1; }
int cb_gu_s1_sd(int a, char pc, unsigned char puc) { return (guc << 1) / 10; }
int cb_gu_s1_sr(int a, char pc, unsigned char puc) { return (guc << 1) >> 3; }
void cb_gu_s1_cm(int a, char pc, unsigned char puc) { if ((guc << 1) > 5) v0(); }
void cb_gu_s1_sl(int a, char pc, unsigned char puc) { gl = guc << 1; }
void cb_gu_s2_si(int a, char pc, unsigned char puc) { gi = guc << 2; }
int cb_gu_s2_ri(int a, char pc, unsigned char puc) { return guc << 2; }
int cb_gu_s2_sd(int a, char pc, unsigned char puc) { return (guc << 2) / 10; }
int cb_gu_s2_sr(int a, char pc, unsigned char puc) { return (guc << 2) >> 3; }
void cb_gu_s2_cm(int a, char pc, unsigned char puc) { if ((guc << 2) > 5) v0(); }
void cb_gu_s2_sl(int a, char pc, unsigned char puc) { gl = guc << 2; }
void cb_gu_s5_si(int a, char pc, unsigned char puc) { gi = guc << 5; }
int cb_gu_s5_ri(int a, char pc, unsigned char puc) { return guc << 5; }
int cb_gu_s5_sd(int a, char pc, unsigned char puc) { return (guc << 5) / 10; }
int cb_gu_s5_sr(int a, char pc, unsigned char puc) { return (guc << 5) >> 3; }
void cb_gu_s5_cm(int a, char pc, unsigned char puc) { if ((guc << 5) > 5) v0(); }
void cb_gu_s5_sl(int a, char pc, unsigned char puc) { gl = guc << 5; }
void cb_gu_s7_si(int a, char pc, unsigned char puc) { gi = guc << 7; }
int cb_gu_s7_ri(int a, char pc, unsigned char puc) { return guc << 7; }
int cb_gu_s7_sd(int a, char pc, unsigned char puc) { return (guc << 7) / 10; }
int cb_gu_s7_sr(int a, char pc, unsigned char puc) { return (guc << 7) >> 3; }
void cb_gu_s7_cm(int a, char pc, unsigned char puc) { if ((guc << 7) > 5) v0(); }
void cb_gu_s7_sl(int a, char pc, unsigned char puc) { gl = guc << 7; }
void cb_gu_mk_si(int a, char pc, unsigned char puc) { gi = guc * 61; }
int cb_gu_mk_ri(int a, char pc, unsigned char puc) { return guc * 61; }
int cb_gu_mk_sd(int a, char pc, unsigned char puc) { return (guc * 61) / 10; }
int cb_gu_mk_sr(int a, char pc, unsigned char puc) { return (guc * 61) >> 3; }
void cb_gu_mk_cm(int a, char pc, unsigned char puc) { if ((guc * 61) > 5) v0(); }
void cb_gu_mk_sl(int a, char pc, unsigned char puc) { gl = guc * 61; }
void cb_gu_cp_si(int a, char pc, unsigned char puc) { gi = ~guc; }
int cb_gu_cp_ri(int a, char pc, unsigned char puc) { return ~guc; }
int cb_gu_cp_sd(int a, char pc, unsigned char puc) { return (~guc) / 10; }
int cb_gu_cp_sr(int a, char pc, unsigned char puc) { return (~guc) >> 3; }
void cb_gu_cp_cm(int a, char pc, unsigned char puc) { if ((~guc) > 5) v0(); }
void cb_gu_cp_sl(int a, char pc, unsigned char puc) { gl = ~guc; }
void cb_gu_ak_si(int a, char pc, unsigned char puc) { gi = guc + 3; }
int cb_gu_ak_ri(int a, char pc, unsigned char puc) { return guc + 3; }
int cb_gu_ak_sd(int a, char pc, unsigned char puc) { return (guc + 3) / 10; }
int cb_gu_ak_sr(int a, char pc, unsigned char puc) { return (guc + 3) >> 3; }
void cb_gu_ak_cm(int a, char pc, unsigned char puc) { if ((guc + 3) > 5) v0(); }
void cb_gu_ak_sl(int a, char pc, unsigned char puc) { gl = guc + 3; }
void cb_es_ng_si(int a, char pc, unsigned char puc) { gi = -gca[2]; }
int cb_es_ng_ri(int a, char pc, unsigned char puc) { return -gca[2]; }
int cb_es_ng_sd(int a, char pc, unsigned char puc) { return (-gca[2]) / 10; }
int cb_es_ng_sr(int a, char pc, unsigned char puc) { return (-gca[2]) >> 3; }
void cb_es_ng_cm(int a, char pc, unsigned char puc) { if ((-gca[2]) > 5) v0(); }
void cb_es_ng_sl(int a, char pc, unsigned char puc) { gl = -gca[2]; }
void cb_es_s1_si(int a, char pc, unsigned char puc) { gi = gca[2] << 1; }
int cb_es_s1_ri(int a, char pc, unsigned char puc) { return gca[2] << 1; }
int cb_es_s1_sd(int a, char pc, unsigned char puc) { return (gca[2] << 1) / 10; }
int cb_es_s1_sr(int a, char pc, unsigned char puc) { return (gca[2] << 1) >> 3; }
void cb_es_s1_cm(int a, char pc, unsigned char puc) { if ((gca[2] << 1) > 5) v0(); }
void cb_es_s1_sl(int a, char pc, unsigned char puc) { gl = gca[2] << 1; }
void cb_es_s2_si(int a, char pc, unsigned char puc) { gi = gca[2] << 2; }
int cb_es_s2_ri(int a, char pc, unsigned char puc) { return gca[2] << 2; }
int cb_es_s2_sd(int a, char pc, unsigned char puc) { return (gca[2] << 2) / 10; }
int cb_es_s2_sr(int a, char pc, unsigned char puc) { return (gca[2] << 2) >> 3; }
void cb_es_s2_cm(int a, char pc, unsigned char puc) { if ((gca[2] << 2) > 5) v0(); }
void cb_es_s2_sl(int a, char pc, unsigned char puc) { gl = gca[2] << 2; }
void cb_es_s5_si(int a, char pc, unsigned char puc) { gi = gca[2] << 5; }
int cb_es_s5_ri(int a, char pc, unsigned char puc) { return gca[2] << 5; }
int cb_es_s5_sd(int a, char pc, unsigned char puc) { return (gca[2] << 5) / 10; }
int cb_es_s5_sr(int a, char pc, unsigned char puc) { return (gca[2] << 5) >> 3; }
void cb_es_s5_cm(int a, char pc, unsigned char puc) { if ((gca[2] << 5) > 5) v0(); }
void cb_es_s5_sl(int a, char pc, unsigned char puc) { gl = gca[2] << 5; }
void cb_es_s7_si(int a, char pc, unsigned char puc) { gi = gca[2] << 7; }
int cb_es_s7_ri(int a, char pc, unsigned char puc) { return gca[2] << 7; }
int cb_es_s7_sd(int a, char pc, unsigned char puc) { return (gca[2] << 7) / 10; }
int cb_es_s7_sr(int a, char pc, unsigned char puc) { return (gca[2] << 7) >> 3; }
void cb_es_s7_cm(int a, char pc, unsigned char puc) { if ((gca[2] << 7) > 5) v0(); }
void cb_es_s7_sl(int a, char pc, unsigned char puc) { gl = gca[2] << 7; }
void cb_es_mk_si(int a, char pc, unsigned char puc) { gi = gca[2] * 61; }
int cb_es_mk_ri(int a, char pc, unsigned char puc) { return gca[2] * 61; }
int cb_es_mk_sd(int a, char pc, unsigned char puc) { return (gca[2] * 61) / 10; }
int cb_es_mk_sr(int a, char pc, unsigned char puc) { return (gca[2] * 61) >> 3; }
void cb_es_mk_cm(int a, char pc, unsigned char puc) { if ((gca[2] * 61) > 5) v0(); }
void cb_es_mk_sl(int a, char pc, unsigned char puc) { gl = gca[2] * 61; }
void cb_es_cp_si(int a, char pc, unsigned char puc) { gi = ~gca[2]; }
int cb_es_cp_ri(int a, char pc, unsigned char puc) { return ~gca[2]; }
int cb_es_cp_sd(int a, char pc, unsigned char puc) { return (~gca[2]) / 10; }
int cb_es_cp_sr(int a, char pc, unsigned char puc) { return (~gca[2]) >> 3; }
void cb_es_cp_cm(int a, char pc, unsigned char puc) { if ((~gca[2]) > 5) v0(); }
void cb_es_cp_sl(int a, char pc, unsigned char puc) { gl = ~gca[2]; }
void cb_es_ak_si(int a, char pc, unsigned char puc) { gi = gca[2] + 3; }
int cb_es_ak_ri(int a, char pc, unsigned char puc) { return gca[2] + 3; }
int cb_es_ak_sd(int a, char pc, unsigned char puc) { return (gca[2] + 3) / 10; }
int cb_es_ak_sr(int a, char pc, unsigned char puc) { return (gca[2] + 3) >> 3; }
void cb_es_ak_cm(int a, char pc, unsigned char puc) { if ((gca[2] + 3) > 5) v0(); }
void cb_es_ak_sl(int a, char pc, unsigned char puc) { gl = gca[2] + 3; }
void cb_eu_ng_si(int a, char pc, unsigned char puc) { gi = -guca[2]; }
int cb_eu_ng_ri(int a, char pc, unsigned char puc) { return -guca[2]; }
int cb_eu_ng_sd(int a, char pc, unsigned char puc) { return (-guca[2]) / 10; }
int cb_eu_ng_sr(int a, char pc, unsigned char puc) { return (-guca[2]) >> 3; }
void cb_eu_ng_cm(int a, char pc, unsigned char puc) { if ((-guca[2]) > 5) v0(); }
void cb_eu_ng_sl(int a, char pc, unsigned char puc) { gl = -guca[2]; }
void cb_eu_s1_si(int a, char pc, unsigned char puc) { gi = guca[2] << 1; }
int cb_eu_s1_ri(int a, char pc, unsigned char puc) { return guca[2] << 1; }
int cb_eu_s1_sd(int a, char pc, unsigned char puc) { return (guca[2] << 1) / 10; }
int cb_eu_s1_sr(int a, char pc, unsigned char puc) { return (guca[2] << 1) >> 3; }
void cb_eu_s1_cm(int a, char pc, unsigned char puc) { if ((guca[2] << 1) > 5) v0(); }
void cb_eu_s1_sl(int a, char pc, unsigned char puc) { gl = guca[2] << 1; }
void cb_eu_s2_si(int a, char pc, unsigned char puc) { gi = guca[2] << 2; }
int cb_eu_s2_ri(int a, char pc, unsigned char puc) { return guca[2] << 2; }
int cb_eu_s2_sd(int a, char pc, unsigned char puc) { return (guca[2] << 2) / 10; }
int cb_eu_s2_sr(int a, char pc, unsigned char puc) { return (guca[2] << 2) >> 3; }
void cb_eu_s2_cm(int a, char pc, unsigned char puc) { if ((guca[2] << 2) > 5) v0(); }
void cb_eu_s2_sl(int a, char pc, unsigned char puc) { gl = guca[2] << 2; }
void cb_eu_s5_si(int a, char pc, unsigned char puc) { gi = guca[2] << 5; }
int cb_eu_s5_ri(int a, char pc, unsigned char puc) { return guca[2] << 5; }
int cb_eu_s5_sd(int a, char pc, unsigned char puc) { return (guca[2] << 5) / 10; }
int cb_eu_s5_sr(int a, char pc, unsigned char puc) { return (guca[2] << 5) >> 3; }
void cb_eu_s5_cm(int a, char pc, unsigned char puc) { if ((guca[2] << 5) > 5) v0(); }
void cb_eu_s5_sl(int a, char pc, unsigned char puc) { gl = guca[2] << 5; }
void cb_eu_s7_si(int a, char pc, unsigned char puc) { gi = guca[2] << 7; }
int cb_eu_s7_ri(int a, char pc, unsigned char puc) { return guca[2] << 7; }
int cb_eu_s7_sd(int a, char pc, unsigned char puc) { return (guca[2] << 7) / 10; }
int cb_eu_s7_sr(int a, char pc, unsigned char puc) { return (guca[2] << 7) >> 3; }
void cb_eu_s7_cm(int a, char pc, unsigned char puc) { if ((guca[2] << 7) > 5) v0(); }
void cb_eu_s7_sl(int a, char pc, unsigned char puc) { gl = guca[2] << 7; }
void cb_eu_mk_si(int a, char pc, unsigned char puc) { gi = guca[2] * 61; }
int cb_eu_mk_ri(int a, char pc, unsigned char puc) { return guca[2] * 61; }
int cb_eu_mk_sd(int a, char pc, unsigned char puc) { return (guca[2] * 61) / 10; }
int cb_eu_mk_sr(int a, char pc, unsigned char puc) { return (guca[2] * 61) >> 3; }
void cb_eu_mk_cm(int a, char pc, unsigned char puc) { if ((guca[2] * 61) > 5) v0(); }
void cb_eu_mk_sl(int a, char pc, unsigned char puc) { gl = guca[2] * 61; }
void cb_eu_cp_si(int a, char pc, unsigned char puc) { gi = ~guca[2]; }
int cb_eu_cp_ri(int a, char pc, unsigned char puc) { return ~guca[2]; }
int cb_eu_cp_sd(int a, char pc, unsigned char puc) { return (~guca[2]) / 10; }
int cb_eu_cp_sr(int a, char pc, unsigned char puc) { return (~guca[2]) >> 3; }
void cb_eu_cp_cm(int a, char pc, unsigned char puc) { if ((~guca[2]) > 5) v0(); }
void cb_eu_cp_sl(int a, char pc, unsigned char puc) { gl = ~guca[2]; }
void cb_eu_ak_si(int a, char pc, unsigned char puc) { gi = guca[2] + 3; }
int cb_eu_ak_ri(int a, char pc, unsigned char puc) { return guca[2] + 3; }
int cb_eu_ak_sd(int a, char pc, unsigned char puc) { return (guca[2] + 3) / 10; }
int cb_eu_ak_sr(int a, char pc, unsigned char puc) { return (guca[2] + 3) >> 3; }
void cb_eu_ak_cm(int a, char pc, unsigned char puc) { if ((guca[2] + 3) > 5) v0(); }
void cb_eu_ak_sl(int a, char pc, unsigned char puc) { gl = guca[2] + 3; }
void cb_xs_ng_si(int a, char pc, unsigned char puc) { gi = -gca[a]; }
int cb_xs_ng_ri(int a, char pc, unsigned char puc) { return -gca[a]; }
int cb_xs_ng_sd(int a, char pc, unsigned char puc) { return (-gca[a]) / 10; }
int cb_xs_ng_sr(int a, char pc, unsigned char puc) { return (-gca[a]) >> 3; }
void cb_xs_ng_cm(int a, char pc, unsigned char puc) { if ((-gca[a]) > 5) v0(); }
void cb_xs_ng_sl(int a, char pc, unsigned char puc) { gl = -gca[a]; }
void cb_xs_s1_si(int a, char pc, unsigned char puc) { gi = gca[a] << 1; }
int cb_xs_s1_ri(int a, char pc, unsigned char puc) { return gca[a] << 1; }
int cb_xs_s1_sd(int a, char pc, unsigned char puc) { return (gca[a] << 1) / 10; }
int cb_xs_s1_sr(int a, char pc, unsigned char puc) { return (gca[a] << 1) >> 3; }
void cb_xs_s1_cm(int a, char pc, unsigned char puc) { if ((gca[a] << 1) > 5) v0(); }
void cb_xs_s1_sl(int a, char pc, unsigned char puc) { gl = gca[a] << 1; }
void cb_xs_s2_si(int a, char pc, unsigned char puc) { gi = gca[a] << 2; }
int cb_xs_s2_ri(int a, char pc, unsigned char puc) { return gca[a] << 2; }
int cb_xs_s2_sd(int a, char pc, unsigned char puc) { return (gca[a] << 2) / 10; }
int cb_xs_s2_sr(int a, char pc, unsigned char puc) { return (gca[a] << 2) >> 3; }
void cb_xs_s2_cm(int a, char pc, unsigned char puc) { if ((gca[a] << 2) > 5) v0(); }
void cb_xs_s2_sl(int a, char pc, unsigned char puc) { gl = gca[a] << 2; }
void cb_xs_s5_si(int a, char pc, unsigned char puc) { gi = gca[a] << 5; }
int cb_xs_s5_ri(int a, char pc, unsigned char puc) { return gca[a] << 5; }
int cb_xs_s5_sd(int a, char pc, unsigned char puc) { return (gca[a] << 5) / 10; }
int cb_xs_s5_sr(int a, char pc, unsigned char puc) { return (gca[a] << 5) >> 3; }
void cb_xs_s5_cm(int a, char pc, unsigned char puc) { if ((gca[a] << 5) > 5) v0(); }
void cb_xs_s5_sl(int a, char pc, unsigned char puc) { gl = gca[a] << 5; }
void cb_xs_s7_si(int a, char pc, unsigned char puc) { gi = gca[a] << 7; }
int cb_xs_s7_ri(int a, char pc, unsigned char puc) { return gca[a] << 7; }
int cb_xs_s7_sd(int a, char pc, unsigned char puc) { return (gca[a] << 7) / 10; }
int cb_xs_s7_sr(int a, char pc, unsigned char puc) { return (gca[a] << 7) >> 3; }
void cb_xs_s7_cm(int a, char pc, unsigned char puc) { if ((gca[a] << 7) > 5) v0(); }
void cb_xs_s7_sl(int a, char pc, unsigned char puc) { gl = gca[a] << 7; }
void cb_xs_mk_si(int a, char pc, unsigned char puc) { gi = gca[a] * 61; }
int cb_xs_mk_ri(int a, char pc, unsigned char puc) { return gca[a] * 61; }
int cb_xs_mk_sd(int a, char pc, unsigned char puc) { return (gca[a] * 61) / 10; }
int cb_xs_mk_sr(int a, char pc, unsigned char puc) { return (gca[a] * 61) >> 3; }
void cb_xs_mk_cm(int a, char pc, unsigned char puc) { if ((gca[a] * 61) > 5) v0(); }
void cb_xs_mk_sl(int a, char pc, unsigned char puc) { gl = gca[a] * 61; }
void cb_xs_cp_si(int a, char pc, unsigned char puc) { gi = ~gca[a]; }
int cb_xs_cp_ri(int a, char pc, unsigned char puc) { return ~gca[a]; }
int cb_xs_cp_sd(int a, char pc, unsigned char puc) { return (~gca[a]) / 10; }
int cb_xs_cp_sr(int a, char pc, unsigned char puc) { return (~gca[a]) >> 3; }
void cb_xs_cp_cm(int a, char pc, unsigned char puc) { if ((~gca[a]) > 5) v0(); }
void cb_xs_cp_sl(int a, char pc, unsigned char puc) { gl = ~gca[a]; }
void cb_xs_ak_si(int a, char pc, unsigned char puc) { gi = gca[a] + 3; }
int cb_xs_ak_ri(int a, char pc, unsigned char puc) { return gca[a] + 3; }
int cb_xs_ak_sd(int a, char pc, unsigned char puc) { return (gca[a] + 3) / 10; }
int cb_xs_ak_sr(int a, char pc, unsigned char puc) { return (gca[a] + 3) >> 3; }
void cb_xs_ak_cm(int a, char pc, unsigned char puc) { if ((gca[a] + 3) > 5) v0(); }
void cb_xs_ak_sl(int a, char pc, unsigned char puc) { gl = gca[a] + 3; }
void cb_xu_ng_si(int a, char pc, unsigned char puc) { gi = -guca[a]; }
int cb_xu_ng_ri(int a, char pc, unsigned char puc) { return -guca[a]; }
int cb_xu_ng_sd(int a, char pc, unsigned char puc) { return (-guca[a]) / 10; }
int cb_xu_ng_sr(int a, char pc, unsigned char puc) { return (-guca[a]) >> 3; }
void cb_xu_ng_cm(int a, char pc, unsigned char puc) { if ((-guca[a]) > 5) v0(); }
void cb_xu_ng_sl(int a, char pc, unsigned char puc) { gl = -guca[a]; }
void cb_xu_s1_si(int a, char pc, unsigned char puc) { gi = guca[a] << 1; }
int cb_xu_s1_ri(int a, char pc, unsigned char puc) { return guca[a] << 1; }
int cb_xu_s1_sd(int a, char pc, unsigned char puc) { return (guca[a] << 1) / 10; }
int cb_xu_s1_sr(int a, char pc, unsigned char puc) { return (guca[a] << 1) >> 3; }
void cb_xu_s1_cm(int a, char pc, unsigned char puc) { if ((guca[a] << 1) > 5) v0(); }
void cb_xu_s1_sl(int a, char pc, unsigned char puc) { gl = guca[a] << 1; }
void cb_xu_s2_si(int a, char pc, unsigned char puc) { gi = guca[a] << 2; }
int cb_xu_s2_ri(int a, char pc, unsigned char puc) { return guca[a] << 2; }
int cb_xu_s2_sd(int a, char pc, unsigned char puc) { return (guca[a] << 2) / 10; }
int cb_xu_s2_sr(int a, char pc, unsigned char puc) { return (guca[a] << 2) >> 3; }
void cb_xu_s2_cm(int a, char pc, unsigned char puc) { if ((guca[a] << 2) > 5) v0(); }
void cb_xu_s2_sl(int a, char pc, unsigned char puc) { gl = guca[a] << 2; }
void cb_xu_s5_si(int a, char pc, unsigned char puc) { gi = guca[a] << 5; }
int cb_xu_s5_ri(int a, char pc, unsigned char puc) { return guca[a] << 5; }
int cb_xu_s5_sd(int a, char pc, unsigned char puc) { return (guca[a] << 5) / 10; }
int cb_xu_s5_sr(int a, char pc, unsigned char puc) { return (guca[a] << 5) >> 3; }
void cb_xu_s5_cm(int a, char pc, unsigned char puc) { if ((guca[a] << 5) > 5) v0(); }
void cb_xu_s5_sl(int a, char pc, unsigned char puc) { gl = guca[a] << 5; }
void cb_xu_s7_si(int a, char pc, unsigned char puc) { gi = guca[a] << 7; }
int cb_xu_s7_ri(int a, char pc, unsigned char puc) { return guca[a] << 7; }
int cb_xu_s7_sd(int a, char pc, unsigned char puc) { return (guca[a] << 7) / 10; }
int cb_xu_s7_sr(int a, char pc, unsigned char puc) { return (guca[a] << 7) >> 3; }
void cb_xu_s7_cm(int a, char pc, unsigned char puc) { if ((guca[a] << 7) > 5) v0(); }
void cb_xu_s7_sl(int a, char pc, unsigned char puc) { gl = guca[a] << 7; }
void cb_xu_mk_si(int a, char pc, unsigned char puc) { gi = guca[a] * 61; }
int cb_xu_mk_ri(int a, char pc, unsigned char puc) { return guca[a] * 61; }
int cb_xu_mk_sd(int a, char pc, unsigned char puc) { return (guca[a] * 61) / 10; }
int cb_xu_mk_sr(int a, char pc, unsigned char puc) { return (guca[a] * 61) >> 3; }
void cb_xu_mk_cm(int a, char pc, unsigned char puc) { if ((guca[a] * 61) > 5) v0(); }
void cb_xu_mk_sl(int a, char pc, unsigned char puc) { gl = guca[a] * 61; }
void cb_xu_cp_si(int a, char pc, unsigned char puc) { gi = ~guca[a]; }
int cb_xu_cp_ri(int a, char pc, unsigned char puc) { return ~guca[a]; }
int cb_xu_cp_sd(int a, char pc, unsigned char puc) { return (~guca[a]) / 10; }
int cb_xu_cp_sr(int a, char pc, unsigned char puc) { return (~guca[a]) >> 3; }
void cb_xu_cp_cm(int a, char pc, unsigned char puc) { if ((~guca[a]) > 5) v0(); }
void cb_xu_cp_sl(int a, char pc, unsigned char puc) { gl = ~guca[a]; }
void cb_xu_ak_si(int a, char pc, unsigned char puc) { gi = guca[a] + 3; }
int cb_xu_ak_ri(int a, char pc, unsigned char puc) { return guca[a] + 3; }
int cb_xu_ak_sd(int a, char pc, unsigned char puc) { return (guca[a] + 3) / 10; }
int cb_xu_ak_sr(int a, char pc, unsigned char puc) { return (guca[a] + 3) >> 3; }
void cb_xu_ak_cm(int a, char pc, unsigned char puc) { if ((guca[a] + 3) > 5) v0(); }
void cb_xu_ak_sl(int a, char pc, unsigned char puc) { gl = guca[a] + 3; }
void cb_ps_ng_si(int a, char pc, unsigned char puc) { gi = -*gp; }
int cb_ps_ng_ri(int a, char pc, unsigned char puc) { return -*gp; }
int cb_ps_ng_sd(int a, char pc, unsigned char puc) { return (-*gp) / 10; }
int cb_ps_ng_sr(int a, char pc, unsigned char puc) { return (-*gp) >> 3; }
void cb_ps_ng_cm(int a, char pc, unsigned char puc) { if ((-*gp) > 5) v0(); }
void cb_ps_ng_sl(int a, char pc, unsigned char puc) { gl = -*gp; }
void cb_ps_s1_si(int a, char pc, unsigned char puc) { gi = *gp << 1; }
int cb_ps_s1_ri(int a, char pc, unsigned char puc) { return *gp << 1; }
int cb_ps_s1_sd(int a, char pc, unsigned char puc) { return (*gp << 1) / 10; }
int cb_ps_s1_sr(int a, char pc, unsigned char puc) { return (*gp << 1) >> 3; }
void cb_ps_s1_cm(int a, char pc, unsigned char puc) { if ((*gp << 1) > 5) v0(); }
void cb_ps_s1_sl(int a, char pc, unsigned char puc) { gl = *gp << 1; }
void cb_ps_s2_si(int a, char pc, unsigned char puc) { gi = *gp << 2; }
int cb_ps_s2_ri(int a, char pc, unsigned char puc) { return *gp << 2; }
int cb_ps_s2_sd(int a, char pc, unsigned char puc) { return (*gp << 2) / 10; }
int cb_ps_s2_sr(int a, char pc, unsigned char puc) { return (*gp << 2) >> 3; }
void cb_ps_s2_cm(int a, char pc, unsigned char puc) { if ((*gp << 2) > 5) v0(); }
void cb_ps_s2_sl(int a, char pc, unsigned char puc) { gl = *gp << 2; }
void cb_ps_s5_si(int a, char pc, unsigned char puc) { gi = *gp << 5; }
int cb_ps_s5_ri(int a, char pc, unsigned char puc) { return *gp << 5; }
int cb_ps_s5_sd(int a, char pc, unsigned char puc) { return (*gp << 5) / 10; }
int cb_ps_s5_sr(int a, char pc, unsigned char puc) { return (*gp << 5) >> 3; }
void cb_ps_s5_cm(int a, char pc, unsigned char puc) { if ((*gp << 5) > 5) v0(); }
void cb_ps_s5_sl(int a, char pc, unsigned char puc) { gl = *gp << 5; }
void cb_ps_s7_si(int a, char pc, unsigned char puc) { gi = *gp << 7; }
int cb_ps_s7_ri(int a, char pc, unsigned char puc) { return *gp << 7; }
int cb_ps_s7_sd(int a, char pc, unsigned char puc) { return (*gp << 7) / 10; }
int cb_ps_s7_sr(int a, char pc, unsigned char puc) { return (*gp << 7) >> 3; }
void cb_ps_s7_cm(int a, char pc, unsigned char puc) { if ((*gp << 7) > 5) v0(); }
void cb_ps_s7_sl(int a, char pc, unsigned char puc) { gl = *gp << 7; }
void cb_ps_mk_si(int a, char pc, unsigned char puc) { gi = *gp * 61; }
int cb_ps_mk_ri(int a, char pc, unsigned char puc) { return *gp * 61; }
int cb_ps_mk_sd(int a, char pc, unsigned char puc) { return (*gp * 61) / 10; }
int cb_ps_mk_sr(int a, char pc, unsigned char puc) { return (*gp * 61) >> 3; }
void cb_ps_mk_cm(int a, char pc, unsigned char puc) { if ((*gp * 61) > 5) v0(); }
void cb_ps_mk_sl(int a, char pc, unsigned char puc) { gl = *gp * 61; }
void cb_ps_cp_si(int a, char pc, unsigned char puc) { gi = ~*gp; }
int cb_ps_cp_ri(int a, char pc, unsigned char puc) { return ~*gp; }
int cb_ps_cp_sd(int a, char pc, unsigned char puc) { return (~*gp) / 10; }
int cb_ps_cp_sr(int a, char pc, unsigned char puc) { return (~*gp) >> 3; }
void cb_ps_cp_cm(int a, char pc, unsigned char puc) { if ((~*gp) > 5) v0(); }
void cb_ps_cp_sl(int a, char pc, unsigned char puc) { gl = ~*gp; }
void cb_ps_ak_si(int a, char pc, unsigned char puc) { gi = *gp + 3; }
int cb_ps_ak_ri(int a, char pc, unsigned char puc) { return *gp + 3; }
int cb_ps_ak_sd(int a, char pc, unsigned char puc) { return (*gp + 3) / 10; }
int cb_ps_ak_sr(int a, char pc, unsigned char puc) { return (*gp + 3) >> 3; }
void cb_ps_ak_cm(int a, char pc, unsigned char puc) { if ((*gp + 3) > 5) v0(); }
void cb_ps_ak_sl(int a, char pc, unsigned char puc) { gl = *gp + 3; }
void cb_pu_ng_si(int a, char pc, unsigned char puc) { gi = -*gup; }
int cb_pu_ng_ri(int a, char pc, unsigned char puc) { return -*gup; }
int cb_pu_ng_sd(int a, char pc, unsigned char puc) { return (-*gup) / 10; }
int cb_pu_ng_sr(int a, char pc, unsigned char puc) { return (-*gup) >> 3; }
void cb_pu_ng_cm(int a, char pc, unsigned char puc) { if ((-*gup) > 5) v0(); }
void cb_pu_ng_sl(int a, char pc, unsigned char puc) { gl = -*gup; }
void cb_pu_s1_si(int a, char pc, unsigned char puc) { gi = *gup << 1; }
int cb_pu_s1_ri(int a, char pc, unsigned char puc) { return *gup << 1; }
int cb_pu_s1_sd(int a, char pc, unsigned char puc) { return (*gup << 1) / 10; }
int cb_pu_s1_sr(int a, char pc, unsigned char puc) { return (*gup << 1) >> 3; }
void cb_pu_s1_cm(int a, char pc, unsigned char puc) { if ((*gup << 1) > 5) v0(); }
void cb_pu_s1_sl(int a, char pc, unsigned char puc) { gl = *gup << 1; }
void cb_pu_s2_si(int a, char pc, unsigned char puc) { gi = *gup << 2; }
int cb_pu_s2_ri(int a, char pc, unsigned char puc) { return *gup << 2; }
int cb_pu_s2_sd(int a, char pc, unsigned char puc) { return (*gup << 2) / 10; }
int cb_pu_s2_sr(int a, char pc, unsigned char puc) { return (*gup << 2) >> 3; }
void cb_pu_s2_cm(int a, char pc, unsigned char puc) { if ((*gup << 2) > 5) v0(); }
void cb_pu_s2_sl(int a, char pc, unsigned char puc) { gl = *gup << 2; }
void cb_pu_s5_si(int a, char pc, unsigned char puc) { gi = *gup << 5; }
int cb_pu_s5_ri(int a, char pc, unsigned char puc) { return *gup << 5; }
int cb_pu_s5_sd(int a, char pc, unsigned char puc) { return (*gup << 5) / 10; }
int cb_pu_s5_sr(int a, char pc, unsigned char puc) { return (*gup << 5) >> 3; }
void cb_pu_s5_cm(int a, char pc, unsigned char puc) { if ((*gup << 5) > 5) v0(); }
void cb_pu_s5_sl(int a, char pc, unsigned char puc) { gl = *gup << 5; }
void cb_pu_s7_si(int a, char pc, unsigned char puc) { gi = *gup << 7; }
int cb_pu_s7_ri(int a, char pc, unsigned char puc) { return *gup << 7; }
int cb_pu_s7_sd(int a, char pc, unsigned char puc) { return (*gup << 7) / 10; }
int cb_pu_s7_sr(int a, char pc, unsigned char puc) { return (*gup << 7) >> 3; }
void cb_pu_s7_cm(int a, char pc, unsigned char puc) { if ((*gup << 7) > 5) v0(); }
void cb_pu_s7_sl(int a, char pc, unsigned char puc) { gl = *gup << 7; }
void cb_pu_mk_si(int a, char pc, unsigned char puc) { gi = *gup * 61; }
int cb_pu_mk_ri(int a, char pc, unsigned char puc) { return *gup * 61; }
int cb_pu_mk_sd(int a, char pc, unsigned char puc) { return (*gup * 61) / 10; }
int cb_pu_mk_sr(int a, char pc, unsigned char puc) { return (*gup * 61) >> 3; }
void cb_pu_mk_cm(int a, char pc, unsigned char puc) { if ((*gup * 61) > 5) v0(); }
void cb_pu_mk_sl(int a, char pc, unsigned char puc) { gl = *gup * 61; }
void cb_pu_cp_si(int a, char pc, unsigned char puc) { gi = ~*gup; }
int cb_pu_cp_ri(int a, char pc, unsigned char puc) { return ~*gup; }
int cb_pu_cp_sd(int a, char pc, unsigned char puc) { return (~*gup) / 10; }
int cb_pu_cp_sr(int a, char pc, unsigned char puc) { return (~*gup) >> 3; }
void cb_pu_cp_cm(int a, char pc, unsigned char puc) { if ((~*gup) > 5) v0(); }
void cb_pu_cp_sl(int a, char pc, unsigned char puc) { gl = ~*gup; }
void cb_pu_ak_si(int a, char pc, unsigned char puc) { gi = *gup + 3; }
int cb_pu_ak_ri(int a, char pc, unsigned char puc) { return *gup + 3; }
int cb_pu_ak_sd(int a, char pc, unsigned char puc) { return (*gup + 3) / 10; }
int cb_pu_ak_sr(int a, char pc, unsigned char puc) { return (*gup + 3) >> 3; }
void cb_pu_ak_cm(int a, char pc, unsigned char puc) { if ((*gup + 3) > 5) v0(); }
void cb_pu_ak_sl(int a, char pc, unsigned char puc) { gl = *gup + 3; }
void cb_ms_ng_si(int a, char pc, unsigned char puc) { gi = -gps->c; }
int cb_ms_ng_ri(int a, char pc, unsigned char puc) { return -gps->c; }
int cb_ms_ng_sd(int a, char pc, unsigned char puc) { return (-gps->c) / 10; }
int cb_ms_ng_sr(int a, char pc, unsigned char puc) { return (-gps->c) >> 3; }
void cb_ms_ng_cm(int a, char pc, unsigned char puc) { if ((-gps->c) > 5) v0(); }
void cb_ms_ng_sl(int a, char pc, unsigned char puc) { gl = -gps->c; }
void cb_ms_s1_si(int a, char pc, unsigned char puc) { gi = gps->c << 1; }
int cb_ms_s1_ri(int a, char pc, unsigned char puc) { return gps->c << 1; }
int cb_ms_s1_sd(int a, char pc, unsigned char puc) { return (gps->c << 1) / 10; }
int cb_ms_s1_sr(int a, char pc, unsigned char puc) { return (gps->c << 1) >> 3; }
void cb_ms_s1_cm(int a, char pc, unsigned char puc) { if ((gps->c << 1) > 5) v0(); }
void cb_ms_s1_sl(int a, char pc, unsigned char puc) { gl = gps->c << 1; }
void cb_ms_s2_si(int a, char pc, unsigned char puc) { gi = gps->c << 2; }
int cb_ms_s2_ri(int a, char pc, unsigned char puc) { return gps->c << 2; }
int cb_ms_s2_sd(int a, char pc, unsigned char puc) { return (gps->c << 2) / 10; }
int cb_ms_s2_sr(int a, char pc, unsigned char puc) { return (gps->c << 2) >> 3; }
void cb_ms_s2_cm(int a, char pc, unsigned char puc) { if ((gps->c << 2) > 5) v0(); }
void cb_ms_s2_sl(int a, char pc, unsigned char puc) { gl = gps->c << 2; }
void cb_ms_s5_si(int a, char pc, unsigned char puc) { gi = gps->c << 5; }
int cb_ms_s5_ri(int a, char pc, unsigned char puc) { return gps->c << 5; }
int cb_ms_s5_sd(int a, char pc, unsigned char puc) { return (gps->c << 5) / 10; }
int cb_ms_s5_sr(int a, char pc, unsigned char puc) { return (gps->c << 5) >> 3; }
void cb_ms_s5_cm(int a, char pc, unsigned char puc) { if ((gps->c << 5) > 5) v0(); }
void cb_ms_s5_sl(int a, char pc, unsigned char puc) { gl = gps->c << 5; }
void cb_ms_s7_si(int a, char pc, unsigned char puc) { gi = gps->c << 7; }
int cb_ms_s7_ri(int a, char pc, unsigned char puc) { return gps->c << 7; }
int cb_ms_s7_sd(int a, char pc, unsigned char puc) { return (gps->c << 7) / 10; }
int cb_ms_s7_sr(int a, char pc, unsigned char puc) { return (gps->c << 7) >> 3; }
void cb_ms_s7_cm(int a, char pc, unsigned char puc) { if ((gps->c << 7) > 5) v0(); }
void cb_ms_s7_sl(int a, char pc, unsigned char puc) { gl = gps->c << 7; }
void cb_ms_mk_si(int a, char pc, unsigned char puc) { gi = gps->c * 61; }
int cb_ms_mk_ri(int a, char pc, unsigned char puc) { return gps->c * 61; }
int cb_ms_mk_sd(int a, char pc, unsigned char puc) { return (gps->c * 61) / 10; }
int cb_ms_mk_sr(int a, char pc, unsigned char puc) { return (gps->c * 61) >> 3; }
void cb_ms_mk_cm(int a, char pc, unsigned char puc) { if ((gps->c * 61) > 5) v0(); }
void cb_ms_mk_sl(int a, char pc, unsigned char puc) { gl = gps->c * 61; }
void cb_ms_cp_si(int a, char pc, unsigned char puc) { gi = ~gps->c; }
int cb_ms_cp_ri(int a, char pc, unsigned char puc) { return ~gps->c; }
int cb_ms_cp_sd(int a, char pc, unsigned char puc) { return (~gps->c) / 10; }
int cb_ms_cp_sr(int a, char pc, unsigned char puc) { return (~gps->c) >> 3; }
void cb_ms_cp_cm(int a, char pc, unsigned char puc) { if ((~gps->c) > 5) v0(); }
void cb_ms_cp_sl(int a, char pc, unsigned char puc) { gl = ~gps->c; }
void cb_ms_ak_si(int a, char pc, unsigned char puc) { gi = gps->c + 3; }
int cb_ms_ak_ri(int a, char pc, unsigned char puc) { return gps->c + 3; }
int cb_ms_ak_sd(int a, char pc, unsigned char puc) { return (gps->c + 3) / 10; }
int cb_ms_ak_sr(int a, char pc, unsigned char puc) { return (gps->c + 3) >> 3; }
void cb_ms_ak_cm(int a, char pc, unsigned char puc) { if ((gps->c + 3) > 5) v0(); }
void cb_ms_ak_sl(int a, char pc, unsigned char puc) { gl = gps->c + 3; }
void cb_mu_ng_si(int a, char pc, unsigned char puc) { gi = -gps->uc; }
int cb_mu_ng_ri(int a, char pc, unsigned char puc) { return -gps->uc; }
int cb_mu_ng_sd(int a, char pc, unsigned char puc) { return (-gps->uc) / 10; }
int cb_mu_ng_sr(int a, char pc, unsigned char puc) { return (-gps->uc) >> 3; }
void cb_mu_ng_cm(int a, char pc, unsigned char puc) { if ((-gps->uc) > 5) v0(); }
void cb_mu_ng_sl(int a, char pc, unsigned char puc) { gl = -gps->uc; }
void cb_mu_s1_si(int a, char pc, unsigned char puc) { gi = gps->uc << 1; }
int cb_mu_s1_ri(int a, char pc, unsigned char puc) { return gps->uc << 1; }
int cb_mu_s1_sd(int a, char pc, unsigned char puc) { return (gps->uc << 1) / 10; }
int cb_mu_s1_sr(int a, char pc, unsigned char puc) { return (gps->uc << 1) >> 3; }
void cb_mu_s1_cm(int a, char pc, unsigned char puc) { if ((gps->uc << 1) > 5) v0(); }
void cb_mu_s1_sl(int a, char pc, unsigned char puc) { gl = gps->uc << 1; }
void cb_mu_s2_si(int a, char pc, unsigned char puc) { gi = gps->uc << 2; }
int cb_mu_s2_ri(int a, char pc, unsigned char puc) { return gps->uc << 2; }
int cb_mu_s2_sd(int a, char pc, unsigned char puc) { return (gps->uc << 2) / 10; }
int cb_mu_s2_sr(int a, char pc, unsigned char puc) { return (gps->uc << 2) >> 3; }
void cb_mu_s2_cm(int a, char pc, unsigned char puc) { if ((gps->uc << 2) > 5) v0(); }
void cb_mu_s2_sl(int a, char pc, unsigned char puc) { gl = gps->uc << 2; }
void cb_mu_s5_si(int a, char pc, unsigned char puc) { gi = gps->uc << 5; }
int cb_mu_s5_ri(int a, char pc, unsigned char puc) { return gps->uc << 5; }
int cb_mu_s5_sd(int a, char pc, unsigned char puc) { return (gps->uc << 5) / 10; }
int cb_mu_s5_sr(int a, char pc, unsigned char puc) { return (gps->uc << 5) >> 3; }
void cb_mu_s5_cm(int a, char pc, unsigned char puc) { if ((gps->uc << 5) > 5) v0(); }
void cb_mu_s5_sl(int a, char pc, unsigned char puc) { gl = gps->uc << 5; }
void cb_mu_s7_si(int a, char pc, unsigned char puc) { gi = gps->uc << 7; }
int cb_mu_s7_ri(int a, char pc, unsigned char puc) { return gps->uc << 7; }
int cb_mu_s7_sd(int a, char pc, unsigned char puc) { return (gps->uc << 7) / 10; }
int cb_mu_s7_sr(int a, char pc, unsigned char puc) { return (gps->uc << 7) >> 3; }
void cb_mu_s7_cm(int a, char pc, unsigned char puc) { if ((gps->uc << 7) > 5) v0(); }
void cb_mu_s7_sl(int a, char pc, unsigned char puc) { gl = gps->uc << 7; }
void cb_mu_mk_si(int a, char pc, unsigned char puc) { gi = gps->uc * 61; }
int cb_mu_mk_ri(int a, char pc, unsigned char puc) { return gps->uc * 61; }
int cb_mu_mk_sd(int a, char pc, unsigned char puc) { return (gps->uc * 61) / 10; }
int cb_mu_mk_sr(int a, char pc, unsigned char puc) { return (gps->uc * 61) >> 3; }
void cb_mu_mk_cm(int a, char pc, unsigned char puc) { if ((gps->uc * 61) > 5) v0(); }
void cb_mu_mk_sl(int a, char pc, unsigned char puc) { gl = gps->uc * 61; }
void cb_mu_cp_si(int a, char pc, unsigned char puc) { gi = ~gps->uc; }
int cb_mu_cp_ri(int a, char pc, unsigned char puc) { return ~gps->uc; }
int cb_mu_cp_sd(int a, char pc, unsigned char puc) { return (~gps->uc) / 10; }
int cb_mu_cp_sr(int a, char pc, unsigned char puc) { return (~gps->uc) >> 3; }
void cb_mu_cp_cm(int a, char pc, unsigned char puc) { if ((~gps->uc) > 5) v0(); }
void cb_mu_cp_sl(int a, char pc, unsigned char puc) { gl = ~gps->uc; }
void cb_mu_ak_si(int a, char pc, unsigned char puc) { gi = gps->uc + 3; }
int cb_mu_ak_ri(int a, char pc, unsigned char puc) { return gps->uc + 3; }
int cb_mu_ak_sd(int a, char pc, unsigned char puc) { return (gps->uc + 3) / 10; }
int cb_mu_ak_sr(int a, char pc, unsigned char puc) { return (gps->uc + 3) >> 3; }
void cb_mu_ak_cm(int a, char pc, unsigned char puc) { if ((gps->uc + 3) > 5) v0(); }
void cb_mu_ak_sl(int a, char pc, unsigned char puc) { gl = gps->uc + 3; }
void cb_rs_ng_si(int a, char pc, unsigned char puc) { gi = -pc; }
int cb_rs_ng_ri(int a, char pc, unsigned char puc) { return -pc; }
int cb_rs_ng_sd(int a, char pc, unsigned char puc) { return (-pc) / 10; }
int cb_rs_ng_sr(int a, char pc, unsigned char puc) { return (-pc) >> 3; }
void cb_rs_ng_cm(int a, char pc, unsigned char puc) { if ((-pc) > 5) v0(); }
void cb_rs_ng_sl(int a, char pc, unsigned char puc) { gl = -pc; }
void cb_rs_s1_si(int a, char pc, unsigned char puc) { gi = pc << 1; }
int cb_rs_s1_ri(int a, char pc, unsigned char puc) { return pc << 1; }
int cb_rs_s1_sd(int a, char pc, unsigned char puc) { return (pc << 1) / 10; }
int cb_rs_s1_sr(int a, char pc, unsigned char puc) { return (pc << 1) >> 3; }
void cb_rs_s1_cm(int a, char pc, unsigned char puc) { if ((pc << 1) > 5) v0(); }
void cb_rs_s1_sl(int a, char pc, unsigned char puc) { gl = pc << 1; }
void cb_rs_s2_si(int a, char pc, unsigned char puc) { gi = pc << 2; }
int cb_rs_s2_ri(int a, char pc, unsigned char puc) { return pc << 2; }
int cb_rs_s2_sd(int a, char pc, unsigned char puc) { return (pc << 2) / 10; }
int cb_rs_s2_sr(int a, char pc, unsigned char puc) { return (pc << 2) >> 3; }
void cb_rs_s2_cm(int a, char pc, unsigned char puc) { if ((pc << 2) > 5) v0(); }
void cb_rs_s2_sl(int a, char pc, unsigned char puc) { gl = pc << 2; }
void cb_rs_s5_si(int a, char pc, unsigned char puc) { gi = pc << 5; }
int cb_rs_s5_ri(int a, char pc, unsigned char puc) { return pc << 5; }
int cb_rs_s5_sd(int a, char pc, unsigned char puc) { return (pc << 5) / 10; }
int cb_rs_s5_sr(int a, char pc, unsigned char puc) { return (pc << 5) >> 3; }
void cb_rs_s5_cm(int a, char pc, unsigned char puc) { if ((pc << 5) > 5) v0(); }
void cb_rs_s5_sl(int a, char pc, unsigned char puc) { gl = pc << 5; }
void cb_rs_s7_si(int a, char pc, unsigned char puc) { gi = pc << 7; }
int cb_rs_s7_ri(int a, char pc, unsigned char puc) { return pc << 7; }
int cb_rs_s7_sd(int a, char pc, unsigned char puc) { return (pc << 7) / 10; }
int cb_rs_s7_sr(int a, char pc, unsigned char puc) { return (pc << 7) >> 3; }
void cb_rs_s7_cm(int a, char pc, unsigned char puc) { if ((pc << 7) > 5) v0(); }
void cb_rs_s7_sl(int a, char pc, unsigned char puc) { gl = pc << 7; }
void cb_rs_mk_si(int a, char pc, unsigned char puc) { gi = pc * 61; }
int cb_rs_mk_ri(int a, char pc, unsigned char puc) { return pc * 61; }
int cb_rs_mk_sd(int a, char pc, unsigned char puc) { return (pc * 61) / 10; }
int cb_rs_mk_sr(int a, char pc, unsigned char puc) { return (pc * 61) >> 3; }
void cb_rs_mk_cm(int a, char pc, unsigned char puc) { if ((pc * 61) > 5) v0(); }
void cb_rs_mk_sl(int a, char pc, unsigned char puc) { gl = pc * 61; }
void cb_rs_cp_si(int a, char pc, unsigned char puc) { gi = ~pc; }
int cb_rs_cp_ri(int a, char pc, unsigned char puc) { return ~pc; }
int cb_rs_cp_sd(int a, char pc, unsigned char puc) { return (~pc) / 10; }
int cb_rs_cp_sr(int a, char pc, unsigned char puc) { return (~pc) >> 3; }
void cb_rs_cp_cm(int a, char pc, unsigned char puc) { if ((~pc) > 5) v0(); }
void cb_rs_cp_sl(int a, char pc, unsigned char puc) { gl = ~pc; }
void cb_rs_ak_si(int a, char pc, unsigned char puc) { gi = pc + 3; }
int cb_rs_ak_ri(int a, char pc, unsigned char puc) { return pc + 3; }
int cb_rs_ak_sd(int a, char pc, unsigned char puc) { return (pc + 3) / 10; }
int cb_rs_ak_sr(int a, char pc, unsigned char puc) { return (pc + 3) >> 3; }
void cb_rs_ak_cm(int a, char pc, unsigned char puc) { if ((pc + 3) > 5) v0(); }
void cb_rs_ak_sl(int a, char pc, unsigned char puc) { gl = pc + 3; }
void cb_ru_ng_si(int a, char pc, unsigned char puc) { gi = -puc; }
int cb_ru_ng_ri(int a, char pc, unsigned char puc) { return -puc; }
int cb_ru_ng_sd(int a, char pc, unsigned char puc) { return (-puc) / 10; }
int cb_ru_ng_sr(int a, char pc, unsigned char puc) { return (-puc) >> 3; }
void cb_ru_ng_cm(int a, char pc, unsigned char puc) { if ((-puc) > 5) v0(); }
void cb_ru_ng_sl(int a, char pc, unsigned char puc) { gl = -puc; }
void cb_ru_s1_si(int a, char pc, unsigned char puc) { gi = puc << 1; }
int cb_ru_s1_ri(int a, char pc, unsigned char puc) { return puc << 1; }
int cb_ru_s1_sd(int a, char pc, unsigned char puc) { return (puc << 1) / 10; }
int cb_ru_s1_sr(int a, char pc, unsigned char puc) { return (puc << 1) >> 3; }
void cb_ru_s1_cm(int a, char pc, unsigned char puc) { if ((puc << 1) > 5) v0(); }
void cb_ru_s1_sl(int a, char pc, unsigned char puc) { gl = puc << 1; }
void cb_ru_s2_si(int a, char pc, unsigned char puc) { gi = puc << 2; }
int cb_ru_s2_ri(int a, char pc, unsigned char puc) { return puc << 2; }
int cb_ru_s2_sd(int a, char pc, unsigned char puc) { return (puc << 2) / 10; }
int cb_ru_s2_sr(int a, char pc, unsigned char puc) { return (puc << 2) >> 3; }
void cb_ru_s2_cm(int a, char pc, unsigned char puc) { if ((puc << 2) > 5) v0(); }
void cb_ru_s2_sl(int a, char pc, unsigned char puc) { gl = puc << 2; }
void cb_ru_s5_si(int a, char pc, unsigned char puc) { gi = puc << 5; }
int cb_ru_s5_ri(int a, char pc, unsigned char puc) { return puc << 5; }
int cb_ru_s5_sd(int a, char pc, unsigned char puc) { return (puc << 5) / 10; }
int cb_ru_s5_sr(int a, char pc, unsigned char puc) { return (puc << 5) >> 3; }
void cb_ru_s5_cm(int a, char pc, unsigned char puc) { if ((puc << 5) > 5) v0(); }
void cb_ru_s5_sl(int a, char pc, unsigned char puc) { gl = puc << 5; }
void cb_ru_s7_si(int a, char pc, unsigned char puc) { gi = puc << 7; }
int cb_ru_s7_ri(int a, char pc, unsigned char puc) { return puc << 7; }
int cb_ru_s7_sd(int a, char pc, unsigned char puc) { return (puc << 7) / 10; }
int cb_ru_s7_sr(int a, char pc, unsigned char puc) { return (puc << 7) >> 3; }
void cb_ru_s7_cm(int a, char pc, unsigned char puc) { if ((puc << 7) > 5) v0(); }
void cb_ru_s7_sl(int a, char pc, unsigned char puc) { gl = puc << 7; }
void cb_ru_mk_si(int a, char pc, unsigned char puc) { gi = puc * 61; }
int cb_ru_mk_ri(int a, char pc, unsigned char puc) { return puc * 61; }
int cb_ru_mk_sd(int a, char pc, unsigned char puc) { return (puc * 61) / 10; }
int cb_ru_mk_sr(int a, char pc, unsigned char puc) { return (puc * 61) >> 3; }
void cb_ru_mk_cm(int a, char pc, unsigned char puc) { if ((puc * 61) > 5) v0(); }
void cb_ru_mk_sl(int a, char pc, unsigned char puc) { gl = puc * 61; }
void cb_ru_cp_si(int a, char pc, unsigned char puc) { gi = ~puc; }
int cb_ru_cp_ri(int a, char pc, unsigned char puc) { return ~puc; }
int cb_ru_cp_sd(int a, char pc, unsigned char puc) { return (~puc) / 10; }
int cb_ru_cp_sr(int a, char pc, unsigned char puc) { return (~puc) >> 3; }
void cb_ru_cp_cm(int a, char pc, unsigned char puc) { if ((~puc) > 5) v0(); }
void cb_ru_cp_sl(int a, char pc, unsigned char puc) { gl = ~puc; }
void cb_ru_ak_si(int a, char pc, unsigned char puc) { gi = puc + 3; }
int cb_ru_ak_ri(int a, char pc, unsigned char puc) { return puc + 3; }
int cb_ru_ak_sd(int a, char pc, unsigned char puc) { return (puc + 3) / 10; }
int cb_ru_ak_sr(int a, char pc, unsigned char puc) { return (puc + 3) >> 3; }
void cb_ru_ak_cm(int a, char pc, unsigned char puc) { if ((puc + 3) > 5) v0(); }
void cb_ru_ak_sl(int a, char pc, unsigned char puc) { gl = puc + 3; }
