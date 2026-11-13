/* Char arithmetic in an int context (gen_chararith.py): ca_<E>_<C>.  E: mss gc * hc, mks gc * 61, muu guc * huc,
   mku guc * 61, msu gc * guc, ngs -gc, ngu -guc, cps ~gc, cpu ~guc, ads gc + hc, adu guc + huc, sbs gc - hc,
   sbu guc - huc, aku guc + 200, shs gc << 2, shu guc << 2, dvs gc / hc.  C: ri returned as an int, si gi = E,
   sc gc2 = E, sl gl = E, sr E >> 3, sd E / 10, sm E % 7, pa E + gi, cm if (E > 5), ar v1(E), ng -(E), xi E ^ gi,
   su gu = E, ml E * gi. */
extern char gc, hc, gc2; extern unsigned char guc, huc; extern int gi; extern unsigned int gu; extern long gl;
extern void v0(void); extern void v1(int);
int ca_mss_ri(void) { return gc * hc; }
void ca_mss_si(void) { gi = gc * hc; }
void ca_mss_sc(void) { gc2 = gc * hc; }
void ca_mss_sl(void) { gl = gc * hc; }
int ca_mss_sr(void) { return (gc * hc) >> 3; }
int ca_mss_sd(void) { return (gc * hc) / 10; }
int ca_mss_sm(void) { return (gc * hc) % 7; }
int ca_mss_pa(void) { return (gc * hc) + gi; }
void ca_mss_cm(void) { if ((gc * hc) > 5) v0(); }
void ca_mss_ar(void) { v1(gc * hc); }
int ca_mss_ng(void) { return -(gc * hc); }
int ca_mss_xi(void) { return (gc * hc) ^ gi; }
void ca_mss_su(void) { gu = gc * hc; }
int ca_mss_ml(void) { return (gc * hc) * gi; }
int ca_mks_ri(void) { return gc * 61; }
void ca_mks_si(void) { gi = gc * 61; }
void ca_mks_sc(void) { gc2 = gc * 61; }
void ca_mks_sl(void) { gl = gc * 61; }
int ca_mks_sr(void) { return (gc * 61) >> 3; }
int ca_mks_sd(void) { return (gc * 61) / 10; }
int ca_mks_sm(void) { return (gc * 61) % 7; }
int ca_mks_pa(void) { return (gc * 61) + gi; }
void ca_mks_cm(void) { if ((gc * 61) > 5) v0(); }
void ca_mks_ar(void) { v1(gc * 61); }
int ca_mks_ng(void) { return -(gc * 61); }
int ca_mks_xi(void) { return (gc * 61) ^ gi; }
void ca_mks_su(void) { gu = gc * 61; }
int ca_mks_ml(void) { return (gc * 61) * gi; }
int ca_muu_ri(void) { return guc * huc; }
void ca_muu_si(void) { gi = guc * huc; }
void ca_muu_sc(void) { gc2 = guc * huc; }
void ca_muu_sl(void) { gl = guc * huc; }
int ca_muu_sr(void) { return (guc * huc) >> 3; }
int ca_muu_sd(void) { return (guc * huc) / 10; }
int ca_muu_sm(void) { return (guc * huc) % 7; }
int ca_muu_pa(void) { return (guc * huc) + gi; }
void ca_muu_cm(void) { if ((guc * huc) > 5) v0(); }
void ca_muu_ar(void) { v1(guc * huc); }
int ca_muu_ng(void) { return -(guc * huc); }
int ca_muu_xi(void) { return (guc * huc) ^ gi; }
void ca_muu_su(void) { gu = guc * huc; }
int ca_muu_ml(void) { return (guc * huc) * gi; }
int ca_mku_ri(void) { return guc * 61; }
void ca_mku_si(void) { gi = guc * 61; }
void ca_mku_sc(void) { gc2 = guc * 61; }
void ca_mku_sl(void) { gl = guc * 61; }
int ca_mku_sr(void) { return (guc * 61) >> 3; }
int ca_mku_sd(void) { return (guc * 61) / 10; }
int ca_mku_sm(void) { return (guc * 61) % 7; }
int ca_mku_pa(void) { return (guc * 61) + gi; }
void ca_mku_cm(void) { if ((guc * 61) > 5) v0(); }
void ca_mku_ar(void) { v1(guc * 61); }
int ca_mku_ng(void) { return -(guc * 61); }
int ca_mku_xi(void) { return (guc * 61) ^ gi; }
void ca_mku_su(void) { gu = guc * 61; }
int ca_mku_ml(void) { return (guc * 61) * gi; }
int ca_msu_ri(void) { return gc * guc; }
void ca_msu_si(void) { gi = gc * guc; }
void ca_msu_sc(void) { gc2 = gc * guc; }
void ca_msu_sl(void) { gl = gc * guc; }
int ca_msu_sr(void) { return (gc * guc) >> 3; }
int ca_msu_sd(void) { return (gc * guc) / 10; }
int ca_msu_sm(void) { return (gc * guc) % 7; }
int ca_msu_pa(void) { return (gc * guc) + gi; }
void ca_msu_cm(void) { if ((gc * guc) > 5) v0(); }
void ca_msu_ar(void) { v1(gc * guc); }
int ca_msu_ng(void) { return -(gc * guc); }
int ca_msu_xi(void) { return (gc * guc) ^ gi; }
void ca_msu_su(void) { gu = gc * guc; }
int ca_msu_ml(void) { return (gc * guc) * gi; }
int ca_ngs_ri(void) { return -gc; }
void ca_ngs_si(void) { gi = -gc; }
void ca_ngs_sc(void) { gc2 = -gc; }
void ca_ngs_sl(void) { gl = -gc; }
int ca_ngs_sr(void) { return (-gc) >> 3; }
int ca_ngs_sd(void) { return (-gc) / 10; }
int ca_ngs_sm(void) { return (-gc) % 7; }
int ca_ngs_pa(void) { return (-gc) + gi; }
void ca_ngs_cm(void) { if ((-gc) > 5) v0(); }
void ca_ngs_ar(void) { v1(-gc); }
int ca_ngs_ng(void) { return -(-gc); }
int ca_ngs_xi(void) { return (-gc) ^ gi; }
void ca_ngs_su(void) { gu = -gc; }
int ca_ngs_ml(void) { return (-gc) * gi; }
int ca_ngu_ri(void) { return -guc; }
void ca_ngu_si(void) { gi = -guc; }
void ca_ngu_sc(void) { gc2 = -guc; }
void ca_ngu_sl(void) { gl = -guc; }
int ca_ngu_sr(void) { return (-guc) >> 3; }
int ca_ngu_sd(void) { return (-guc) / 10; }
int ca_ngu_sm(void) { return (-guc) % 7; }
int ca_ngu_pa(void) { return (-guc) + gi; }
void ca_ngu_cm(void) { if ((-guc) > 5) v0(); }
void ca_ngu_ar(void) { v1(-guc); }
int ca_ngu_ng(void) { return -(-guc); }
int ca_ngu_xi(void) { return (-guc) ^ gi; }
void ca_ngu_su(void) { gu = -guc; }
int ca_ngu_ml(void) { return (-guc) * gi; }
int ca_cps_ri(void) { return ~gc; }
void ca_cps_si(void) { gi = ~gc; }
void ca_cps_sc(void) { gc2 = ~gc; }
void ca_cps_sl(void) { gl = ~gc; }
int ca_cps_sr(void) { return (~gc) >> 3; }
int ca_cps_sd(void) { return (~gc) / 10; }
int ca_cps_sm(void) { return (~gc) % 7; }
int ca_cps_pa(void) { return (~gc) + gi; }
void ca_cps_cm(void) { if ((~gc) > 5) v0(); }
void ca_cps_ar(void) { v1(~gc); }
int ca_cps_ng(void) { return -(~gc); }
int ca_cps_xi(void) { return (~gc) ^ gi; }
void ca_cps_su(void) { gu = ~gc; }
int ca_cps_ml(void) { return (~gc) * gi; }
int ca_cpu_ri(void) { return ~guc; }
void ca_cpu_si(void) { gi = ~guc; }
void ca_cpu_sc(void) { gc2 = ~guc; }
void ca_cpu_sl(void) { gl = ~guc; }
int ca_cpu_sr(void) { return (~guc) >> 3; }
int ca_cpu_sd(void) { return (~guc) / 10; }
int ca_cpu_sm(void) { return (~guc) % 7; }
int ca_cpu_pa(void) { return (~guc) + gi; }
void ca_cpu_cm(void) { if ((~guc) > 5) v0(); }
void ca_cpu_ar(void) { v1(~guc); }
int ca_cpu_ng(void) { return -(~guc); }
int ca_cpu_xi(void) { return (~guc) ^ gi; }
void ca_cpu_su(void) { gu = ~guc; }
int ca_cpu_ml(void) { return (~guc) * gi; }
int ca_ads_ri(void) { return gc + hc; }
void ca_ads_si(void) { gi = gc + hc; }
void ca_ads_sc(void) { gc2 = gc + hc; }
void ca_ads_sl(void) { gl = gc + hc; }
int ca_ads_sr(void) { return (gc + hc) >> 3; }
int ca_ads_sd(void) { return (gc + hc) / 10; }
int ca_ads_sm(void) { return (gc + hc) % 7; }
int ca_ads_pa(void) { return (gc + hc) + gi; }
void ca_ads_cm(void) { if ((gc + hc) > 5) v0(); }
void ca_ads_ar(void) { v1(gc + hc); }
int ca_ads_ng(void) { return -(gc + hc); }
int ca_ads_xi(void) { return (gc + hc) ^ gi; }
void ca_ads_su(void) { gu = gc + hc; }
int ca_ads_ml(void) { return (gc + hc) * gi; }
int ca_adu_ri(void) { return guc + huc; }
void ca_adu_si(void) { gi = guc + huc; }
void ca_adu_sc(void) { gc2 = guc + huc; }
void ca_adu_sl(void) { gl = guc + huc; }
int ca_adu_sr(void) { return (guc + huc) >> 3; }
int ca_adu_sd(void) { return (guc + huc) / 10; }
int ca_adu_sm(void) { return (guc + huc) % 7; }
int ca_adu_pa(void) { return (guc + huc) + gi; }
void ca_adu_cm(void) { if ((guc + huc) > 5) v0(); }
void ca_adu_ar(void) { v1(guc + huc); }
int ca_adu_ng(void) { return -(guc + huc); }
int ca_adu_xi(void) { return (guc + huc) ^ gi; }
void ca_adu_su(void) { gu = guc + huc; }
int ca_adu_ml(void) { return (guc + huc) * gi; }
int ca_sbs_ri(void) { return gc - hc; }
void ca_sbs_si(void) { gi = gc - hc; }
void ca_sbs_sc(void) { gc2 = gc - hc; }
void ca_sbs_sl(void) { gl = gc - hc; }
int ca_sbs_sr(void) { return (gc - hc) >> 3; }
int ca_sbs_sd(void) { return (gc - hc) / 10; }
int ca_sbs_sm(void) { return (gc - hc) % 7; }
int ca_sbs_pa(void) { return (gc - hc) + gi; }
void ca_sbs_cm(void) { if ((gc - hc) > 5) v0(); }
void ca_sbs_ar(void) { v1(gc - hc); }
int ca_sbs_ng(void) { return -(gc - hc); }
int ca_sbs_xi(void) { return (gc - hc) ^ gi; }
void ca_sbs_su(void) { gu = gc - hc; }
int ca_sbs_ml(void) { return (gc - hc) * gi; }
int ca_sbu_ri(void) { return guc - huc; }
void ca_sbu_si(void) { gi = guc - huc; }
void ca_sbu_sc(void) { gc2 = guc - huc; }
void ca_sbu_sl(void) { gl = guc - huc; }
int ca_sbu_sr(void) { return (guc - huc) >> 3; }
int ca_sbu_sd(void) { return (guc - huc) / 10; }
int ca_sbu_sm(void) { return (guc - huc) % 7; }
int ca_sbu_pa(void) { return (guc - huc) + gi; }
void ca_sbu_cm(void) { if ((guc - huc) > 5) v0(); }
void ca_sbu_ar(void) { v1(guc - huc); }
int ca_sbu_ng(void) { return -(guc - huc); }
int ca_sbu_xi(void) { return (guc - huc) ^ gi; }
void ca_sbu_su(void) { gu = guc - huc; }
int ca_sbu_ml(void) { return (guc - huc) * gi; }
int ca_aku_ri(void) { return guc + 200; }
void ca_aku_si(void) { gi = guc + 200; }
void ca_aku_sc(void) { gc2 = guc + 200; }
void ca_aku_sl(void) { gl = guc + 200; }
int ca_aku_sr(void) { return (guc + 200) >> 3; }
int ca_aku_sd(void) { return (guc + 200) / 10; }
int ca_aku_sm(void) { return (guc + 200) % 7; }
int ca_aku_pa(void) { return (guc + 200) + gi; }
void ca_aku_cm(void) { if ((guc + 200) > 5) v0(); }
void ca_aku_ar(void) { v1(guc + 200); }
int ca_aku_ng(void) { return -(guc + 200); }
int ca_aku_xi(void) { return (guc + 200) ^ gi; }
void ca_aku_su(void) { gu = guc + 200; }
int ca_aku_ml(void) { return (guc + 200) * gi; }
int ca_shs_ri(void) { return gc << 2; }
void ca_shs_si(void) { gi = gc << 2; }
void ca_shs_sc(void) { gc2 = gc << 2; }
void ca_shs_sl(void) { gl = gc << 2; }
int ca_shs_sr(void) { return (gc << 2) >> 3; }
int ca_shs_sd(void) { return (gc << 2) / 10; }
int ca_shs_sm(void) { return (gc << 2) % 7; }
int ca_shs_pa(void) { return (gc << 2) + gi; }
void ca_shs_cm(void) { if ((gc << 2) > 5) v0(); }
void ca_shs_ar(void) { v1(gc << 2); }
int ca_shs_ng(void) { return -(gc << 2); }
int ca_shs_xi(void) { return (gc << 2) ^ gi; }
void ca_shs_su(void) { gu = gc << 2; }
int ca_shs_ml(void) { return (gc << 2) * gi; }
int ca_shu_ri(void) { return guc << 2; }
void ca_shu_si(void) { gi = guc << 2; }
void ca_shu_sc(void) { gc2 = guc << 2; }
void ca_shu_sl(void) { gl = guc << 2; }
int ca_shu_sr(void) { return (guc << 2) >> 3; }
int ca_shu_sd(void) { return (guc << 2) / 10; }
int ca_shu_sm(void) { return (guc << 2) % 7; }
int ca_shu_pa(void) { return (guc << 2) + gi; }
void ca_shu_cm(void) { if ((guc << 2) > 5) v0(); }
void ca_shu_ar(void) { v1(guc << 2); }
int ca_shu_ng(void) { return -(guc << 2); }
int ca_shu_xi(void) { return (guc << 2) ^ gi; }
void ca_shu_su(void) { gu = guc << 2; }
int ca_shu_ml(void) { return (guc << 2) * gi; }
int ca_dvs_ri(void) { return gc / hc; }
void ca_dvs_si(void) { gi = gc / hc; }
void ca_dvs_sc(void) { gc2 = gc / hc; }
void ca_dvs_sl(void) { gl = gc / hc; }
int ca_dvs_sr(void) { return (gc / hc) >> 3; }
int ca_dvs_sd(void) { return (gc / hc) / 10; }
int ca_dvs_sm(void) { return (gc / hc) % 7; }
int ca_dvs_pa(void) { return (gc / hc) + gi; }
void ca_dvs_cm(void) { if ((gc / hc) > 5) v0(); }
void ca_dvs_ar(void) { v1(gc / hc); }
int ca_dvs_ng(void) { return -(gc / hc); }
int ca_dvs_xi(void) { return (gc / hc) ^ gi; }
void ca_dvs_su(void) { gu = gc / hc; }
int ca_dvs_ml(void) { return (gc / hc) * gi; }
