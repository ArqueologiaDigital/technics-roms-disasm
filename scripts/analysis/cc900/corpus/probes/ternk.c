/* ?: with one constant arm (lane_o3 rule 31); see gen_ternk.py for the name letters */
struct sv { char mc; unsigned char mb; int mi; unsigned int mu; long ml; unsigned long mn; };
extern struct sv gs, *gps;
extern char gc, hc, gca[8], jc;
extern int gi, gi2, gia[8], ji;
extern unsigned int gu;
extern long gl, gl2, gla[8], jl;
extern int gri(int);

void tk_c_BeGS(char a) { jc = (gu & 0x80 ? gc : 7); }
void tk_c_BeGT(char a) { char t = (gu & 0x80 ? gc : 7); jc = t; }
char tk_c_BeGR(char a) { return (gu & 0x80 ? gc : 7); }
void tk_c_BeGO(char a) { jc ^= (gu & 0x80 ? gc : 7); }
void tk_c_BeAS(char a) { jc = (gu & 0x80 ? gca[4] : 7); }
void tk_c_BeAT(char a) { char t = (gu & 0x80 ? gca[4] : 7); jc = t; }
char tk_c_BeAR(char a) { return (gu & 0x80 ? gca[4] : 7); }
void tk_c_BeAO(char a) { jc ^= (gu & 0x80 ? gca[4] : 7); }
void tk_c_BeMS(char a) { jc = (gu & 0x80 ? gps->mc : 7); }
void tk_c_BeMT(char a) { char t = (gu & 0x80 ? gps->mc : 7); jc = t; }
char tk_c_BeMR(char a) { return (gu & 0x80 ? gps->mc : 7); }
void tk_c_BeMO(char a) { jc ^= (gu & 0x80 ? gps->mc : 7); }
void tk_c_BePS(char a) { jc = (gu & 0x80 ? a : 7); }
void tk_c_BePT(char a) { char t = (gu & 0x80 ? a : 7); jc = t; }
char tk_c_BePR(char a) { return (gu & 0x80 ? a : 7); }
void tk_c_BePO(char a) { jc ^= (gu & 0x80 ? a : 7); }
void tk_c_BtGS(char a) { jc = (gu & 0x80 ? 7 : gc); }
void tk_c_BtGT(char a) { char t = (gu & 0x80 ? 7 : gc); jc = t; }
char tk_c_BtGR(char a) { return (gu & 0x80 ? 7 : gc); }
void tk_c_BtGO(char a) { jc ^= (gu & 0x80 ? 7 : gc); }
void tk_c_BtAS(char a) { jc = (gu & 0x80 ? 7 : gca[4]); }
void tk_c_BtAT(char a) { char t = (gu & 0x80 ? 7 : gca[4]); jc = t; }
char tk_c_BtAR(char a) { return (gu & 0x80 ? 7 : gca[4]); }
void tk_c_BtAO(char a) { jc ^= (gu & 0x80 ? 7 : gca[4]); }
void tk_c_BtMS(char a) { jc = (gu & 0x80 ? 7 : gps->mc); }
void tk_c_BtMT(char a) { char t = (gu & 0x80 ? 7 : gps->mc); jc = t; }
char tk_c_BtMR(char a) { return (gu & 0x80 ? 7 : gps->mc); }
void tk_c_BtMO(char a) { jc ^= (gu & 0x80 ? 7 : gps->mc); }
void tk_c_BtPS(char a) { jc = (gu & 0x80 ? 7 : a); }
void tk_c_BtPT(char a) { char t = (gu & 0x80 ? 7 : a); jc = t; }
char tk_c_BtPR(char a) { return (gu & 0x80 ? 7 : a); }
void tk_c_BtPO(char a) { jc ^= (gu & 0x80 ? 7 : a); }
void tk_c_LeGS(char a) { jc = (gl2 > -40543L ? gc : 7); }
void tk_c_LeGT(char a) { char t = (gl2 > -40543L ? gc : 7); jc = t; }
char tk_c_LeGR(char a) { return (gl2 > -40543L ? gc : 7); }
void tk_c_LeGO(char a) { jc ^= (gl2 > -40543L ? gc : 7); }
void tk_c_LeAS(char a) { jc = (gl2 > -40543L ? gca[4] : 7); }
void tk_c_LeAT(char a) { char t = (gl2 > -40543L ? gca[4] : 7); jc = t; }
char tk_c_LeAR(char a) { return (gl2 > -40543L ? gca[4] : 7); }
void tk_c_LeAO(char a) { jc ^= (gl2 > -40543L ? gca[4] : 7); }
void tk_c_LeMS(char a) { jc = (gl2 > -40543L ? gps->mc : 7); }
void tk_c_LeMT(char a) { char t = (gl2 > -40543L ? gps->mc : 7); jc = t; }
char tk_c_LeMR(char a) { return (gl2 > -40543L ? gps->mc : 7); }
void tk_c_LeMO(char a) { jc ^= (gl2 > -40543L ? gps->mc : 7); }
void tk_c_LePS(char a) { jc = (gl2 > -40543L ? a : 7); }
void tk_c_LePT(char a) { char t = (gl2 > -40543L ? a : 7); jc = t; }
char tk_c_LePR(char a) { return (gl2 > -40543L ? a : 7); }
void tk_c_LePO(char a) { jc ^= (gl2 > -40543L ? a : 7); }
void tk_c_LtGS(char a) { jc = (gl2 > -40543L ? 7 : gc); }
void tk_c_LtGT(char a) { char t = (gl2 > -40543L ? 7 : gc); jc = t; }
char tk_c_LtGR(char a) { return (gl2 > -40543L ? 7 : gc); }
void tk_c_LtGO(char a) { jc ^= (gl2 > -40543L ? 7 : gc); }
void tk_c_LtAS(char a) { jc = (gl2 > -40543L ? 7 : gca[4]); }
void tk_c_LtAT(char a) { char t = (gl2 > -40543L ? 7 : gca[4]); jc = t; }
char tk_c_LtAR(char a) { return (gl2 > -40543L ? 7 : gca[4]); }
void tk_c_LtAO(char a) { jc ^= (gl2 > -40543L ? 7 : gca[4]); }
void tk_c_LtMS(char a) { jc = (gl2 > -40543L ? 7 : gps->mc); }
void tk_c_LtMT(char a) { char t = (gl2 > -40543L ? 7 : gps->mc); jc = t; }
char tk_c_LtMR(char a) { return (gl2 > -40543L ? 7 : gps->mc); }
void tk_c_LtMO(char a) { jc ^= (gl2 > -40543L ? 7 : gps->mc); }
void tk_c_LtPS(char a) { jc = (gl2 > -40543L ? 7 : a); }
void tk_c_LtPT(char a) { char t = (gl2 > -40543L ? 7 : a); jc = t; }
char tk_c_LtPR(char a) { return (gl2 > -40543L ? 7 : a); }
void tk_c_LtPO(char a) { jc ^= (gl2 > -40543L ? 7 : a); }
void tk_c_MeGS(char a) { jc = (gps->mu < 9 ? gc : 7); }
void tk_c_MeGT(char a) { char t = (gps->mu < 9 ? gc : 7); jc = t; }
char tk_c_MeGR(char a) { return (gps->mu < 9 ? gc : 7); }
void tk_c_MeGO(char a) { jc ^= (gps->mu < 9 ? gc : 7); }
void tk_c_MeAS(char a) { jc = (gps->mu < 9 ? gca[4] : 7); }
void tk_c_MeAT(char a) { char t = (gps->mu < 9 ? gca[4] : 7); jc = t; }
char tk_c_MeAR(char a) { return (gps->mu < 9 ? gca[4] : 7); }
void tk_c_MeAO(char a) { jc ^= (gps->mu < 9 ? gca[4] : 7); }
void tk_c_MeMS(char a) { jc = (gps->mu < 9 ? gps->mc : 7); }
void tk_c_MeMT(char a) { char t = (gps->mu < 9 ? gps->mc : 7); jc = t; }
char tk_c_MeMR(char a) { return (gps->mu < 9 ? gps->mc : 7); }
void tk_c_MeMO(char a) { jc ^= (gps->mu < 9 ? gps->mc : 7); }
void tk_c_MePS(char a) { jc = (gps->mu < 9 ? a : 7); }
void tk_c_MePT(char a) { char t = (gps->mu < 9 ? a : 7); jc = t; }
char tk_c_MePR(char a) { return (gps->mu < 9 ? a : 7); }
void tk_c_MePO(char a) { jc ^= (gps->mu < 9 ? a : 7); }
void tk_c_MtGS(char a) { jc = (gps->mu < 9 ? 7 : gc); }
void tk_c_MtGT(char a) { char t = (gps->mu < 9 ? 7 : gc); jc = t; }
char tk_c_MtGR(char a) { return (gps->mu < 9 ? 7 : gc); }
void tk_c_MtGO(char a) { jc ^= (gps->mu < 9 ? 7 : gc); }
void tk_c_MtAS(char a) { jc = (gps->mu < 9 ? 7 : gca[4]); }
void tk_c_MtAT(char a) { char t = (gps->mu < 9 ? 7 : gca[4]); jc = t; }
char tk_c_MtAR(char a) { return (gps->mu < 9 ? 7 : gca[4]); }
void tk_c_MtAO(char a) { jc ^= (gps->mu < 9 ? 7 : gca[4]); }
void tk_c_MtMS(char a) { jc = (gps->mu < 9 ? 7 : gps->mc); }
void tk_c_MtMT(char a) { char t = (gps->mu < 9 ? 7 : gps->mc); jc = t; }
char tk_c_MtMR(char a) { return (gps->mu < 9 ? 7 : gps->mc); }
void tk_c_MtMO(char a) { jc ^= (gps->mu < 9 ? 7 : gps->mc); }
void tk_c_MtPS(char a) { jc = (gps->mu < 9 ? 7 : a); }
void tk_c_MtPT(char a) { char t = (gps->mu < 9 ? 7 : a); jc = t; }
char tk_c_MtPR(char a) { return (gps->mu < 9 ? 7 : a); }
void tk_c_MtPO(char a) { jc ^= (gps->mu < 9 ? 7 : a); }
void tk_c_PeGS(char a) { jc = (a > 3 ? gc : 7); }
void tk_c_PeGT(char a) { char t = (a > 3 ? gc : 7); jc = t; }
char tk_c_PeGR(char a) { return (a > 3 ? gc : 7); }
void tk_c_PeGO(char a) { jc ^= (a > 3 ? gc : 7); }
void tk_c_PeAS(char a) { jc = (a > 3 ? gca[4] : 7); }
void tk_c_PeAT(char a) { char t = (a > 3 ? gca[4] : 7); jc = t; }
char tk_c_PeAR(char a) { return (a > 3 ? gca[4] : 7); }
void tk_c_PeAO(char a) { jc ^= (a > 3 ? gca[4] : 7); }
void tk_c_PeMS(char a) { jc = (a > 3 ? gps->mc : 7); }
void tk_c_PeMT(char a) { char t = (a > 3 ? gps->mc : 7); jc = t; }
char tk_c_PeMR(char a) { return (a > 3 ? gps->mc : 7); }
void tk_c_PeMO(char a) { jc ^= (a > 3 ? gps->mc : 7); }
void tk_c_PePS(char a) { jc = (a > 3 ? a : 7); }
void tk_c_PePT(char a) { char t = (a > 3 ? a : 7); jc = t; }
char tk_c_PePR(char a) { return (a > 3 ? a : 7); }
void tk_c_PePO(char a) { jc ^= (a > 3 ? a : 7); }
void tk_c_PtGS(char a) { jc = (a > 3 ? 7 : gc); }
void tk_c_PtGT(char a) { char t = (a > 3 ? 7 : gc); jc = t; }
char tk_c_PtGR(char a) { return (a > 3 ? 7 : gc); }
void tk_c_PtGO(char a) { jc ^= (a > 3 ? 7 : gc); }
void tk_c_PtAS(char a) { jc = (a > 3 ? 7 : gca[4]); }
void tk_c_PtAT(char a) { char t = (a > 3 ? 7 : gca[4]); jc = t; }
char tk_c_PtAR(char a) { return (a > 3 ? 7 : gca[4]); }
void tk_c_PtAO(char a) { jc ^= (a > 3 ? 7 : gca[4]); }
void tk_c_PtMS(char a) { jc = (a > 3 ? 7 : gps->mc); }
void tk_c_PtMT(char a) { char t = (a > 3 ? 7 : gps->mc); jc = t; }
char tk_c_PtMR(char a) { return (a > 3 ? 7 : gps->mc); }
void tk_c_PtMO(char a) { jc ^= (a > 3 ? 7 : gps->mc); }
void tk_c_PtPS(char a) { jc = (a > 3 ? 7 : a); }
void tk_c_PtPT(char a) { char t = (a > 3 ? 7 : a); jc = t; }
char tk_c_PtPR(char a) { return (a > 3 ? 7 : a); }
void tk_c_PtPO(char a) { jc ^= (a > 3 ? 7 : a); }
void tk_c_EeGS(char a) { jc = (gia[a] != 0 ? gc : 7); }
void tk_c_EeGT(char a) { char t = (gia[a] != 0 ? gc : 7); jc = t; }
char tk_c_EeGR(char a) { return (gia[a] != 0 ? gc : 7); }
void tk_c_EeGO(char a) { jc ^= (gia[a] != 0 ? gc : 7); }
void tk_c_EeAS(char a) { jc = (gia[a] != 0 ? gca[4] : 7); }
void tk_c_EeAT(char a) { char t = (gia[a] != 0 ? gca[4] : 7); jc = t; }
char tk_c_EeAR(char a) { return (gia[a] != 0 ? gca[4] : 7); }
void tk_c_EeAO(char a) { jc ^= (gia[a] != 0 ? gca[4] : 7); }
void tk_c_EeMS(char a) { jc = (gia[a] != 0 ? gps->mc : 7); }
void tk_c_EeMT(char a) { char t = (gia[a] != 0 ? gps->mc : 7); jc = t; }
char tk_c_EeMR(char a) { return (gia[a] != 0 ? gps->mc : 7); }
void tk_c_EeMO(char a) { jc ^= (gia[a] != 0 ? gps->mc : 7); }
void tk_c_EePS(char a) { jc = (gia[a] != 0 ? a : 7); }
void tk_c_EePT(char a) { char t = (gia[a] != 0 ? a : 7); jc = t; }
char tk_c_EePR(char a) { return (gia[a] != 0 ? a : 7); }
void tk_c_EePO(char a) { jc ^= (gia[a] != 0 ? a : 7); }
void tk_c_EtGS(char a) { jc = (gia[a] != 0 ? 7 : gc); }
void tk_c_EtGT(char a) { char t = (gia[a] != 0 ? 7 : gc); jc = t; }
char tk_c_EtGR(char a) { return (gia[a] != 0 ? 7 : gc); }
void tk_c_EtGO(char a) { jc ^= (gia[a] != 0 ? 7 : gc); }
void tk_c_EtAS(char a) { jc = (gia[a] != 0 ? 7 : gca[4]); }
void tk_c_EtAT(char a) { char t = (gia[a] != 0 ? 7 : gca[4]); jc = t; }
char tk_c_EtAR(char a) { return (gia[a] != 0 ? 7 : gca[4]); }
void tk_c_EtAO(char a) { jc ^= (gia[a] != 0 ? 7 : gca[4]); }
void tk_c_EtMS(char a) { jc = (gia[a] != 0 ? 7 : gps->mc); }
void tk_c_EtMT(char a) { char t = (gia[a] != 0 ? 7 : gps->mc); jc = t; }
char tk_c_EtMR(char a) { return (gia[a] != 0 ? 7 : gps->mc); }
void tk_c_EtMO(char a) { jc ^= (gia[a] != 0 ? 7 : gps->mc); }
void tk_c_EtPS(char a) { jc = (gia[a] != 0 ? 7 : a); }
void tk_c_EtPT(char a) { char t = (gia[a] != 0 ? 7 : a); jc = t; }
char tk_c_EtPR(char a) { return (gia[a] != 0 ? 7 : a); }
void tk_c_EtPO(char a) { jc ^= (gia[a] != 0 ? 7 : a); }
void tk_c_QeGS(char a) { jc = (gc < hc ? gc : 7); }
void tk_c_QeGT(char a) { char t = (gc < hc ? gc : 7); jc = t; }
char tk_c_QeGR(char a) { return (gc < hc ? gc : 7); }
void tk_c_QeGO(char a) { jc ^= (gc < hc ? gc : 7); }
void tk_c_QeAS(char a) { jc = (gc < hc ? gca[4] : 7); }
void tk_c_QeAT(char a) { char t = (gc < hc ? gca[4] : 7); jc = t; }
char tk_c_QeAR(char a) { return (gc < hc ? gca[4] : 7); }
void tk_c_QeAO(char a) { jc ^= (gc < hc ? gca[4] : 7); }
void tk_c_QeMS(char a) { jc = (gc < hc ? gps->mc : 7); }
void tk_c_QeMT(char a) { char t = (gc < hc ? gps->mc : 7); jc = t; }
char tk_c_QeMR(char a) { return (gc < hc ? gps->mc : 7); }
void tk_c_QeMO(char a) { jc ^= (gc < hc ? gps->mc : 7); }
void tk_c_QePS(char a) { jc = (gc < hc ? a : 7); }
void tk_c_QePT(char a) { char t = (gc < hc ? a : 7); jc = t; }
char tk_c_QePR(char a) { return (gc < hc ? a : 7); }
void tk_c_QePO(char a) { jc ^= (gc < hc ? a : 7); }
void tk_c_QtGS(char a) { jc = (gc < hc ? 7 : gc); }
void tk_c_QtGT(char a) { char t = (gc < hc ? 7 : gc); jc = t; }
char tk_c_QtGR(char a) { return (gc < hc ? 7 : gc); }
void tk_c_QtGO(char a) { jc ^= (gc < hc ? 7 : gc); }
void tk_c_QtAS(char a) { jc = (gc < hc ? 7 : gca[4]); }
void tk_c_QtAT(char a) { char t = (gc < hc ? 7 : gca[4]); jc = t; }
char tk_c_QtAR(char a) { return (gc < hc ? 7 : gca[4]); }
void tk_c_QtAO(char a) { jc ^= (gc < hc ? 7 : gca[4]); }
void tk_c_QtMS(char a) { jc = (gc < hc ? 7 : gps->mc); }
void tk_c_QtMT(char a) { char t = (gc < hc ? 7 : gps->mc); jc = t; }
char tk_c_QtMR(char a) { return (gc < hc ? 7 : gps->mc); }
void tk_c_QtMO(char a) { jc ^= (gc < hc ? 7 : gps->mc); }
void tk_c_QtPS(char a) { jc = (gc < hc ? 7 : a); }
void tk_c_QtPT(char a) { char t = (gc < hc ? 7 : a); jc = t; }
char tk_c_QtPR(char a) { return (gc < hc ? 7 : a); }
void tk_c_QtPO(char a) { jc ^= (gc < hc ? 7 : a); }
void tk_c_CeGS(char a) { jc = (gri(gi) != 0 ? gc : 7); }
void tk_c_CeGT(char a) { char t = (gri(gi) != 0 ? gc : 7); jc = t; }
char tk_c_CeGR(char a) { return (gri(gi) != 0 ? gc : 7); }
void tk_c_CeGO(char a) { jc ^= (gri(gi) != 0 ? gc : 7); }
void tk_c_CeAS(char a) { jc = (gri(gi) != 0 ? gca[4] : 7); }
void tk_c_CeAT(char a) { char t = (gri(gi) != 0 ? gca[4] : 7); jc = t; }
char tk_c_CeAR(char a) { return (gri(gi) != 0 ? gca[4] : 7); }
void tk_c_CeAO(char a) { jc ^= (gri(gi) != 0 ? gca[4] : 7); }
void tk_c_CeMS(char a) { jc = (gri(gi) != 0 ? gps->mc : 7); }
void tk_c_CeMT(char a) { char t = (gri(gi) != 0 ? gps->mc : 7); jc = t; }
char tk_c_CeMR(char a) { return (gri(gi) != 0 ? gps->mc : 7); }
void tk_c_CeMO(char a) { jc ^= (gri(gi) != 0 ? gps->mc : 7); }
void tk_c_CePS(char a) { jc = (gri(gi) != 0 ? a : 7); }
void tk_c_CePT(char a) { char t = (gri(gi) != 0 ? a : 7); jc = t; }
char tk_c_CePR(char a) { return (gri(gi) != 0 ? a : 7); }
void tk_c_CePO(char a) { jc ^= (gri(gi) != 0 ? a : 7); }
void tk_c_CtGS(char a) { jc = (gri(gi) != 0 ? 7 : gc); }
void tk_c_CtGT(char a) { char t = (gri(gi) != 0 ? 7 : gc); jc = t; }
char tk_c_CtGR(char a) { return (gri(gi) != 0 ? 7 : gc); }
void tk_c_CtGO(char a) { jc ^= (gri(gi) != 0 ? 7 : gc); }
void tk_c_CtAS(char a) { jc = (gri(gi) != 0 ? 7 : gca[4]); }
void tk_c_CtAT(char a) { char t = (gri(gi) != 0 ? 7 : gca[4]); jc = t; }
char tk_c_CtAR(char a) { return (gri(gi) != 0 ? 7 : gca[4]); }
void tk_c_CtAO(char a) { jc ^= (gri(gi) != 0 ? 7 : gca[4]); }
void tk_c_CtMS(char a) { jc = (gri(gi) != 0 ? 7 : gps->mc); }
void tk_c_CtMT(char a) { char t = (gri(gi) != 0 ? 7 : gps->mc); jc = t; }
char tk_c_CtMR(char a) { return (gri(gi) != 0 ? 7 : gps->mc); }
void tk_c_CtMO(char a) { jc ^= (gri(gi) != 0 ? 7 : gps->mc); }
void tk_c_CtPS(char a) { jc = (gri(gi) != 0 ? 7 : a); }
void tk_c_CtPT(char a) { char t = (gri(gi) != 0 ? 7 : a); jc = t; }
char tk_c_CtPR(char a) { return (gri(gi) != 0 ? 7 : a); }
void tk_c_CtPO(char a) { jc ^= (gri(gi) != 0 ? 7 : a); }
void tk_i_BeGS(int a) { ji = (gu & 0x80 ? gi : 127); }
void tk_i_BeGT(int a) { int t = (gu & 0x80 ? gi : 127); ji = t; }
int tk_i_BeGR(int a) { return (gu & 0x80 ? gi : 127); }
void tk_i_BeGO(int a) { ji ^= (gu & 0x80 ? gi : 127); }
void tk_i_BeAS(int a) { ji = (gu & 0x80 ? gia[4] : 127); }
void tk_i_BeAT(int a) { int t = (gu & 0x80 ? gia[4] : 127); ji = t; }
int tk_i_BeAR(int a) { return (gu & 0x80 ? gia[4] : 127); }
void tk_i_BeAO(int a) { ji ^= (gu & 0x80 ? gia[4] : 127); }
void tk_i_BeMS(int a) { ji = (gu & 0x80 ? gps->mi : 127); }
void tk_i_BeMT(int a) { int t = (gu & 0x80 ? gps->mi : 127); ji = t; }
int tk_i_BeMR(int a) { return (gu & 0x80 ? gps->mi : 127); }
void tk_i_BeMO(int a) { ji ^= (gu & 0x80 ? gps->mi : 127); }
void tk_i_BePS(int a) { ji = (gu & 0x80 ? a : 127); }
void tk_i_BePT(int a) { int t = (gu & 0x80 ? a : 127); ji = t; }
int tk_i_BePR(int a) { return (gu & 0x80 ? a : 127); }
void tk_i_BePO(int a) { ji ^= (gu & 0x80 ? a : 127); }
void tk_i_BtGS(int a) { ji = (gu & 0x80 ? 127 : gi); }
void tk_i_BtGT(int a) { int t = (gu & 0x80 ? 127 : gi); ji = t; }
int tk_i_BtGR(int a) { return (gu & 0x80 ? 127 : gi); }
void tk_i_BtGO(int a) { ji ^= (gu & 0x80 ? 127 : gi); }
void tk_i_BtAS(int a) { ji = (gu & 0x80 ? 127 : gia[4]); }
void tk_i_BtAT(int a) { int t = (gu & 0x80 ? 127 : gia[4]); ji = t; }
int tk_i_BtAR(int a) { return (gu & 0x80 ? 127 : gia[4]); }
void tk_i_BtAO(int a) { ji ^= (gu & 0x80 ? 127 : gia[4]); }
void tk_i_BtMS(int a) { ji = (gu & 0x80 ? 127 : gps->mi); }
void tk_i_BtMT(int a) { int t = (gu & 0x80 ? 127 : gps->mi); ji = t; }
int tk_i_BtMR(int a) { return (gu & 0x80 ? 127 : gps->mi); }
void tk_i_BtMO(int a) { ji ^= (gu & 0x80 ? 127 : gps->mi); }
void tk_i_BtPS(int a) { ji = (gu & 0x80 ? 127 : a); }
void tk_i_BtPT(int a) { int t = (gu & 0x80 ? 127 : a); ji = t; }
int tk_i_BtPR(int a) { return (gu & 0x80 ? 127 : a); }
void tk_i_BtPO(int a) { ji ^= (gu & 0x80 ? 127 : a); }
void tk_i_LeGS(int a) { ji = (gl2 > -40543L ? gi : 127); }
void tk_i_LeGT(int a) { int t = (gl2 > -40543L ? gi : 127); ji = t; }
int tk_i_LeGR(int a) { return (gl2 > -40543L ? gi : 127); }
void tk_i_LeGO(int a) { ji ^= (gl2 > -40543L ? gi : 127); }
void tk_i_LeAS(int a) { ji = (gl2 > -40543L ? gia[4] : 127); }
void tk_i_LeAT(int a) { int t = (gl2 > -40543L ? gia[4] : 127); ji = t; }
int tk_i_LeAR(int a) { return (gl2 > -40543L ? gia[4] : 127); }
void tk_i_LeAO(int a) { ji ^= (gl2 > -40543L ? gia[4] : 127); }
void tk_i_LeMS(int a) { ji = (gl2 > -40543L ? gps->mi : 127); }
void tk_i_LeMT(int a) { int t = (gl2 > -40543L ? gps->mi : 127); ji = t; }
int tk_i_LeMR(int a) { return (gl2 > -40543L ? gps->mi : 127); }
void tk_i_LeMO(int a) { ji ^= (gl2 > -40543L ? gps->mi : 127); }
void tk_i_LePS(int a) { ji = (gl2 > -40543L ? a : 127); }
void tk_i_LePT(int a) { int t = (gl2 > -40543L ? a : 127); ji = t; }
int tk_i_LePR(int a) { return (gl2 > -40543L ? a : 127); }
void tk_i_LePO(int a) { ji ^= (gl2 > -40543L ? a : 127); }
void tk_i_LtGS(int a) { ji = (gl2 > -40543L ? 127 : gi); }
void tk_i_LtGT(int a) { int t = (gl2 > -40543L ? 127 : gi); ji = t; }
int tk_i_LtGR(int a) { return (gl2 > -40543L ? 127 : gi); }
void tk_i_LtGO(int a) { ji ^= (gl2 > -40543L ? 127 : gi); }
void tk_i_LtAS(int a) { ji = (gl2 > -40543L ? 127 : gia[4]); }
void tk_i_LtAT(int a) { int t = (gl2 > -40543L ? 127 : gia[4]); ji = t; }
int tk_i_LtAR(int a) { return (gl2 > -40543L ? 127 : gia[4]); }
void tk_i_LtAO(int a) { ji ^= (gl2 > -40543L ? 127 : gia[4]); }
void tk_i_LtMS(int a) { ji = (gl2 > -40543L ? 127 : gps->mi); }
void tk_i_LtMT(int a) { int t = (gl2 > -40543L ? 127 : gps->mi); ji = t; }
int tk_i_LtMR(int a) { return (gl2 > -40543L ? 127 : gps->mi); }
void tk_i_LtMO(int a) { ji ^= (gl2 > -40543L ? 127 : gps->mi); }
void tk_i_LtPS(int a) { ji = (gl2 > -40543L ? 127 : a); }
void tk_i_LtPT(int a) { int t = (gl2 > -40543L ? 127 : a); ji = t; }
int tk_i_LtPR(int a) { return (gl2 > -40543L ? 127 : a); }
void tk_i_LtPO(int a) { ji ^= (gl2 > -40543L ? 127 : a); }
void tk_i_MeGS(int a) { ji = (gps->mu < 9 ? gi : 127); }
void tk_i_MeGT(int a) { int t = (gps->mu < 9 ? gi : 127); ji = t; }
int tk_i_MeGR(int a) { return (gps->mu < 9 ? gi : 127); }
void tk_i_MeGO(int a) { ji ^= (gps->mu < 9 ? gi : 127); }
void tk_i_MeAS(int a) { ji = (gps->mu < 9 ? gia[4] : 127); }
void tk_i_MeAT(int a) { int t = (gps->mu < 9 ? gia[4] : 127); ji = t; }
int tk_i_MeAR(int a) { return (gps->mu < 9 ? gia[4] : 127); }
void tk_i_MeAO(int a) { ji ^= (gps->mu < 9 ? gia[4] : 127); }
void tk_i_MeMS(int a) { ji = (gps->mu < 9 ? gps->mi : 127); }
void tk_i_MeMT(int a) { int t = (gps->mu < 9 ? gps->mi : 127); ji = t; }
int tk_i_MeMR(int a) { return (gps->mu < 9 ? gps->mi : 127); }
void tk_i_MeMO(int a) { ji ^= (gps->mu < 9 ? gps->mi : 127); }
void tk_i_MePS(int a) { ji = (gps->mu < 9 ? a : 127); }
void tk_i_MePT(int a) { int t = (gps->mu < 9 ? a : 127); ji = t; }
int tk_i_MePR(int a) { return (gps->mu < 9 ? a : 127); }
void tk_i_MePO(int a) { ji ^= (gps->mu < 9 ? a : 127); }
void tk_i_MtGS(int a) { ji = (gps->mu < 9 ? 127 : gi); }
void tk_i_MtGT(int a) { int t = (gps->mu < 9 ? 127 : gi); ji = t; }
int tk_i_MtGR(int a) { return (gps->mu < 9 ? 127 : gi); }
void tk_i_MtGO(int a) { ji ^= (gps->mu < 9 ? 127 : gi); }
void tk_i_MtAS(int a) { ji = (gps->mu < 9 ? 127 : gia[4]); }
void tk_i_MtAT(int a) { int t = (gps->mu < 9 ? 127 : gia[4]); ji = t; }
int tk_i_MtAR(int a) { return (gps->mu < 9 ? 127 : gia[4]); }
void tk_i_MtAO(int a) { ji ^= (gps->mu < 9 ? 127 : gia[4]); }
void tk_i_MtMS(int a) { ji = (gps->mu < 9 ? 127 : gps->mi); }
void tk_i_MtMT(int a) { int t = (gps->mu < 9 ? 127 : gps->mi); ji = t; }
int tk_i_MtMR(int a) { return (gps->mu < 9 ? 127 : gps->mi); }
void tk_i_MtMO(int a) { ji ^= (gps->mu < 9 ? 127 : gps->mi); }
void tk_i_MtPS(int a) { ji = (gps->mu < 9 ? 127 : a); }
void tk_i_MtPT(int a) { int t = (gps->mu < 9 ? 127 : a); ji = t; }
int tk_i_MtPR(int a) { return (gps->mu < 9 ? 127 : a); }
void tk_i_MtPO(int a) { ji ^= (gps->mu < 9 ? 127 : a); }
void tk_i_PeGS(int a) { ji = (a > 3 ? gi : 127); }
void tk_i_PeGT(int a) { int t = (a > 3 ? gi : 127); ji = t; }
int tk_i_PeGR(int a) { return (a > 3 ? gi : 127); }
void tk_i_PeGO(int a) { ji ^= (a > 3 ? gi : 127); }
void tk_i_PeAS(int a) { ji = (a > 3 ? gia[4] : 127); }
void tk_i_PeAT(int a) { int t = (a > 3 ? gia[4] : 127); ji = t; }
int tk_i_PeAR(int a) { return (a > 3 ? gia[4] : 127); }
void tk_i_PeAO(int a) { ji ^= (a > 3 ? gia[4] : 127); }
void tk_i_PeMS(int a) { ji = (a > 3 ? gps->mi : 127); }
void tk_i_PeMT(int a) { int t = (a > 3 ? gps->mi : 127); ji = t; }
int tk_i_PeMR(int a) { return (a > 3 ? gps->mi : 127); }
void tk_i_PeMO(int a) { ji ^= (a > 3 ? gps->mi : 127); }
void tk_i_PePS(int a) { ji = (a > 3 ? a : 127); }
void tk_i_PePT(int a) { int t = (a > 3 ? a : 127); ji = t; }
int tk_i_PePR(int a) { return (a > 3 ? a : 127); }
void tk_i_PePO(int a) { ji ^= (a > 3 ? a : 127); }
void tk_i_PtGS(int a) { ji = (a > 3 ? 127 : gi); }
void tk_i_PtGT(int a) { int t = (a > 3 ? 127 : gi); ji = t; }
int tk_i_PtGR(int a) { return (a > 3 ? 127 : gi); }
void tk_i_PtGO(int a) { ji ^= (a > 3 ? 127 : gi); }
void tk_i_PtAS(int a) { ji = (a > 3 ? 127 : gia[4]); }
void tk_i_PtAT(int a) { int t = (a > 3 ? 127 : gia[4]); ji = t; }
int tk_i_PtAR(int a) { return (a > 3 ? 127 : gia[4]); }
void tk_i_PtAO(int a) { ji ^= (a > 3 ? 127 : gia[4]); }
void tk_i_PtMS(int a) { ji = (a > 3 ? 127 : gps->mi); }
void tk_i_PtMT(int a) { int t = (a > 3 ? 127 : gps->mi); ji = t; }
int tk_i_PtMR(int a) { return (a > 3 ? 127 : gps->mi); }
void tk_i_PtMO(int a) { ji ^= (a > 3 ? 127 : gps->mi); }
void tk_i_PtPS(int a) { ji = (a > 3 ? 127 : a); }
void tk_i_PtPT(int a) { int t = (a > 3 ? 127 : a); ji = t; }
int tk_i_PtPR(int a) { return (a > 3 ? 127 : a); }
void tk_i_PtPO(int a) { ji ^= (a > 3 ? 127 : a); }
void tk_i_EeGS(int a) { ji = (gia[a] != 0 ? gi : 127); }
void tk_i_EeGT(int a) { int t = (gia[a] != 0 ? gi : 127); ji = t; }
int tk_i_EeGR(int a) { return (gia[a] != 0 ? gi : 127); }
void tk_i_EeGO(int a) { ji ^= (gia[a] != 0 ? gi : 127); }
void tk_i_EeAS(int a) { ji = (gia[a] != 0 ? gia[4] : 127); }
void tk_i_EeAT(int a) { int t = (gia[a] != 0 ? gia[4] : 127); ji = t; }
int tk_i_EeAR(int a) { return (gia[a] != 0 ? gia[4] : 127); }
void tk_i_EeAO(int a) { ji ^= (gia[a] != 0 ? gia[4] : 127); }
void tk_i_EeMS(int a) { ji = (gia[a] != 0 ? gps->mi : 127); }
void tk_i_EeMT(int a) { int t = (gia[a] != 0 ? gps->mi : 127); ji = t; }
int tk_i_EeMR(int a) { return (gia[a] != 0 ? gps->mi : 127); }
void tk_i_EeMO(int a) { ji ^= (gia[a] != 0 ? gps->mi : 127); }
void tk_i_EePS(int a) { ji = (gia[a] != 0 ? a : 127); }
void tk_i_EePT(int a) { int t = (gia[a] != 0 ? a : 127); ji = t; }
int tk_i_EePR(int a) { return (gia[a] != 0 ? a : 127); }
void tk_i_EePO(int a) { ji ^= (gia[a] != 0 ? a : 127); }
void tk_i_EtGS(int a) { ji = (gia[a] != 0 ? 127 : gi); }
void tk_i_EtGT(int a) { int t = (gia[a] != 0 ? 127 : gi); ji = t; }
int tk_i_EtGR(int a) { return (gia[a] != 0 ? 127 : gi); }
void tk_i_EtGO(int a) { ji ^= (gia[a] != 0 ? 127 : gi); }
void tk_i_EtAS(int a) { ji = (gia[a] != 0 ? 127 : gia[4]); }
void tk_i_EtAT(int a) { int t = (gia[a] != 0 ? 127 : gia[4]); ji = t; }
int tk_i_EtAR(int a) { return (gia[a] != 0 ? 127 : gia[4]); }
void tk_i_EtAO(int a) { ji ^= (gia[a] != 0 ? 127 : gia[4]); }
void tk_i_EtMS(int a) { ji = (gia[a] != 0 ? 127 : gps->mi); }
void tk_i_EtMT(int a) { int t = (gia[a] != 0 ? 127 : gps->mi); ji = t; }
int tk_i_EtMR(int a) { return (gia[a] != 0 ? 127 : gps->mi); }
void tk_i_EtMO(int a) { ji ^= (gia[a] != 0 ? 127 : gps->mi); }
void tk_i_EtPS(int a) { ji = (gia[a] != 0 ? 127 : a); }
void tk_i_EtPT(int a) { int t = (gia[a] != 0 ? 127 : a); ji = t; }
int tk_i_EtPR(int a) { return (gia[a] != 0 ? 127 : a); }
void tk_i_EtPO(int a) { ji ^= (gia[a] != 0 ? 127 : a); }
void tk_i_QeGS(int a) { ji = (gc < hc ? gi : 127); }
void tk_i_QeGT(int a) { int t = (gc < hc ? gi : 127); ji = t; }
int tk_i_QeGR(int a) { return (gc < hc ? gi : 127); }
void tk_i_QeGO(int a) { ji ^= (gc < hc ? gi : 127); }
void tk_i_QeAS(int a) { ji = (gc < hc ? gia[4] : 127); }
void tk_i_QeAT(int a) { int t = (gc < hc ? gia[4] : 127); ji = t; }
int tk_i_QeAR(int a) { return (gc < hc ? gia[4] : 127); }
void tk_i_QeAO(int a) { ji ^= (gc < hc ? gia[4] : 127); }
void tk_i_QeMS(int a) { ji = (gc < hc ? gps->mi : 127); }
void tk_i_QeMT(int a) { int t = (gc < hc ? gps->mi : 127); ji = t; }
int tk_i_QeMR(int a) { return (gc < hc ? gps->mi : 127); }
void tk_i_QeMO(int a) { ji ^= (gc < hc ? gps->mi : 127); }
void tk_i_QePS(int a) { ji = (gc < hc ? a : 127); }
void tk_i_QePT(int a) { int t = (gc < hc ? a : 127); ji = t; }
int tk_i_QePR(int a) { return (gc < hc ? a : 127); }
void tk_i_QePO(int a) { ji ^= (gc < hc ? a : 127); }
void tk_i_QtGS(int a) { ji = (gc < hc ? 127 : gi); }
void tk_i_QtGT(int a) { int t = (gc < hc ? 127 : gi); ji = t; }
int tk_i_QtGR(int a) { return (gc < hc ? 127 : gi); }
void tk_i_QtGO(int a) { ji ^= (gc < hc ? 127 : gi); }
void tk_i_QtAS(int a) { ji = (gc < hc ? 127 : gia[4]); }
void tk_i_QtAT(int a) { int t = (gc < hc ? 127 : gia[4]); ji = t; }
int tk_i_QtAR(int a) { return (gc < hc ? 127 : gia[4]); }
void tk_i_QtAO(int a) { ji ^= (gc < hc ? 127 : gia[4]); }
void tk_i_QtMS(int a) { ji = (gc < hc ? 127 : gps->mi); }
void tk_i_QtMT(int a) { int t = (gc < hc ? 127 : gps->mi); ji = t; }
int tk_i_QtMR(int a) { return (gc < hc ? 127 : gps->mi); }
void tk_i_QtMO(int a) { ji ^= (gc < hc ? 127 : gps->mi); }
void tk_i_QtPS(int a) { ji = (gc < hc ? 127 : a); }
void tk_i_QtPT(int a) { int t = (gc < hc ? 127 : a); ji = t; }
int tk_i_QtPR(int a) { return (gc < hc ? 127 : a); }
void tk_i_QtPO(int a) { ji ^= (gc < hc ? 127 : a); }
void tk_i_CeGS(int a) { ji = (gri(gi) != 0 ? gi : 127); }
void tk_i_CeGT(int a) { int t = (gri(gi) != 0 ? gi : 127); ji = t; }
int tk_i_CeGR(int a) { return (gri(gi) != 0 ? gi : 127); }
void tk_i_CeGO(int a) { ji ^= (gri(gi) != 0 ? gi : 127); }
void tk_i_CeAS(int a) { ji = (gri(gi) != 0 ? gia[4] : 127); }
void tk_i_CeAT(int a) { int t = (gri(gi) != 0 ? gia[4] : 127); ji = t; }
int tk_i_CeAR(int a) { return (gri(gi) != 0 ? gia[4] : 127); }
void tk_i_CeAO(int a) { ji ^= (gri(gi) != 0 ? gia[4] : 127); }
void tk_i_CeMS(int a) { ji = (gri(gi) != 0 ? gps->mi : 127); }
void tk_i_CeMT(int a) { int t = (gri(gi) != 0 ? gps->mi : 127); ji = t; }
int tk_i_CeMR(int a) { return (gri(gi) != 0 ? gps->mi : 127); }
void tk_i_CeMO(int a) { ji ^= (gri(gi) != 0 ? gps->mi : 127); }
void tk_i_CePS(int a) { ji = (gri(gi) != 0 ? a : 127); }
void tk_i_CePT(int a) { int t = (gri(gi) != 0 ? a : 127); ji = t; }
int tk_i_CePR(int a) { return (gri(gi) != 0 ? a : 127); }
void tk_i_CePO(int a) { ji ^= (gri(gi) != 0 ? a : 127); }
void tk_i_CtGS(int a) { ji = (gri(gi) != 0 ? 127 : gi); }
void tk_i_CtGT(int a) { int t = (gri(gi) != 0 ? 127 : gi); ji = t; }
int tk_i_CtGR(int a) { return (gri(gi) != 0 ? 127 : gi); }
void tk_i_CtGO(int a) { ji ^= (gri(gi) != 0 ? 127 : gi); }
void tk_i_CtAS(int a) { ji = (gri(gi) != 0 ? 127 : gia[4]); }
void tk_i_CtAT(int a) { int t = (gri(gi) != 0 ? 127 : gia[4]); ji = t; }
int tk_i_CtAR(int a) { return (gri(gi) != 0 ? 127 : gia[4]); }
void tk_i_CtAO(int a) { ji ^= (gri(gi) != 0 ? 127 : gia[4]); }
void tk_i_CtMS(int a) { ji = (gri(gi) != 0 ? 127 : gps->mi); }
void tk_i_CtMT(int a) { int t = (gri(gi) != 0 ? 127 : gps->mi); ji = t; }
int tk_i_CtMR(int a) { return (gri(gi) != 0 ? 127 : gps->mi); }
void tk_i_CtMO(int a) { ji ^= (gri(gi) != 0 ? 127 : gps->mi); }
void tk_i_CtPS(int a) { ji = (gri(gi) != 0 ? 127 : a); }
void tk_i_CtPT(int a) { int t = (gri(gi) != 0 ? 127 : a); ji = t; }
int tk_i_CtPR(int a) { return (gri(gi) != 0 ? 127 : a); }
void tk_i_CtPO(int a) { ji ^= (gri(gi) != 0 ? 127 : a); }
void tk_l_BeGS(long a) { jl = (gu & 0x80 ? gl : 70000L); }
void tk_l_BeGT(long a) { long t = (gu & 0x80 ? gl : 70000L); jl = t; }
long tk_l_BeGR(long a) { return (gu & 0x80 ? gl : 70000L); }
void tk_l_BeGO(long a) { jl ^= (gu & 0x80 ? gl : 70000L); }
void tk_l_BeAS(long a) { jl = (gu & 0x80 ? gla[4] : 70000L); }
void tk_l_BeAT(long a) { long t = (gu & 0x80 ? gla[4] : 70000L); jl = t; }
long tk_l_BeAR(long a) { return (gu & 0x80 ? gla[4] : 70000L); }
void tk_l_BeAO(long a) { jl ^= (gu & 0x80 ? gla[4] : 70000L); }
void tk_l_BeMS(long a) { jl = (gu & 0x80 ? gps->ml : 70000L); }
void tk_l_BeMT(long a) { long t = (gu & 0x80 ? gps->ml : 70000L); jl = t; }
long tk_l_BeMR(long a) { return (gu & 0x80 ? gps->ml : 70000L); }
void tk_l_BeMO(long a) { jl ^= (gu & 0x80 ? gps->ml : 70000L); }
void tk_l_BePS(long a) { jl = (gu & 0x80 ? a : 70000L); }
void tk_l_BePT(long a) { long t = (gu & 0x80 ? a : 70000L); jl = t; }
long tk_l_BePR(long a) { return (gu & 0x80 ? a : 70000L); }
void tk_l_BePO(long a) { jl ^= (gu & 0x80 ? a : 70000L); }
void tk_l_BtGS(long a) { jl = (gu & 0x80 ? 70000L : gl); }
void tk_l_BtGT(long a) { long t = (gu & 0x80 ? 70000L : gl); jl = t; }
long tk_l_BtGR(long a) { return (gu & 0x80 ? 70000L : gl); }
void tk_l_BtGO(long a) { jl ^= (gu & 0x80 ? 70000L : gl); }
void tk_l_BtAS(long a) { jl = (gu & 0x80 ? 70000L : gla[4]); }
void tk_l_BtAT(long a) { long t = (gu & 0x80 ? 70000L : gla[4]); jl = t; }
long tk_l_BtAR(long a) { return (gu & 0x80 ? 70000L : gla[4]); }
void tk_l_BtAO(long a) { jl ^= (gu & 0x80 ? 70000L : gla[4]); }
void tk_l_BtMS(long a) { jl = (gu & 0x80 ? 70000L : gps->ml); }
void tk_l_BtMT(long a) { long t = (gu & 0x80 ? 70000L : gps->ml); jl = t; }
long tk_l_BtMR(long a) { return (gu & 0x80 ? 70000L : gps->ml); }
void tk_l_BtMO(long a) { jl ^= (gu & 0x80 ? 70000L : gps->ml); }
void tk_l_BtPS(long a) { jl = (gu & 0x80 ? 70000L : a); }
void tk_l_BtPT(long a) { long t = (gu & 0x80 ? 70000L : a); jl = t; }
long tk_l_BtPR(long a) { return (gu & 0x80 ? 70000L : a); }
void tk_l_BtPO(long a) { jl ^= (gu & 0x80 ? 70000L : a); }
void tk_l_LeGS(long a) { jl = (gl2 > -40543L ? gl : 70000L); }
void tk_l_LeGT(long a) { long t = (gl2 > -40543L ? gl : 70000L); jl = t; }
long tk_l_LeGR(long a) { return (gl2 > -40543L ? gl : 70000L); }
void tk_l_LeGO(long a) { jl ^= (gl2 > -40543L ? gl : 70000L); }
void tk_l_LeAS(long a) { jl = (gl2 > -40543L ? gla[4] : 70000L); }
void tk_l_LeAT(long a) { long t = (gl2 > -40543L ? gla[4] : 70000L); jl = t; }
long tk_l_LeAR(long a) { return (gl2 > -40543L ? gla[4] : 70000L); }
void tk_l_LeAO(long a) { jl ^= (gl2 > -40543L ? gla[4] : 70000L); }
void tk_l_LeMS(long a) { jl = (gl2 > -40543L ? gps->ml : 70000L); }
void tk_l_LeMT(long a) { long t = (gl2 > -40543L ? gps->ml : 70000L); jl = t; }
long tk_l_LeMR(long a) { return (gl2 > -40543L ? gps->ml : 70000L); }
void tk_l_LeMO(long a) { jl ^= (gl2 > -40543L ? gps->ml : 70000L); }
void tk_l_LePS(long a) { jl = (gl2 > -40543L ? a : 70000L); }
void tk_l_LePT(long a) { long t = (gl2 > -40543L ? a : 70000L); jl = t; }
long tk_l_LePR(long a) { return (gl2 > -40543L ? a : 70000L); }
void tk_l_LePO(long a) { jl ^= (gl2 > -40543L ? a : 70000L); }
void tk_l_LtGS(long a) { jl = (gl2 > -40543L ? 70000L : gl); }
void tk_l_LtGT(long a) { long t = (gl2 > -40543L ? 70000L : gl); jl = t; }
long tk_l_LtGR(long a) { return (gl2 > -40543L ? 70000L : gl); }
void tk_l_LtGO(long a) { jl ^= (gl2 > -40543L ? 70000L : gl); }
void tk_l_LtAS(long a) { jl = (gl2 > -40543L ? 70000L : gla[4]); }
void tk_l_LtAT(long a) { long t = (gl2 > -40543L ? 70000L : gla[4]); jl = t; }
long tk_l_LtAR(long a) { return (gl2 > -40543L ? 70000L : gla[4]); }
void tk_l_LtAO(long a) { jl ^= (gl2 > -40543L ? 70000L : gla[4]); }
void tk_l_LtMS(long a) { jl = (gl2 > -40543L ? 70000L : gps->ml); }
void tk_l_LtMT(long a) { long t = (gl2 > -40543L ? 70000L : gps->ml); jl = t; }
long tk_l_LtMR(long a) { return (gl2 > -40543L ? 70000L : gps->ml); }
void tk_l_LtMO(long a) { jl ^= (gl2 > -40543L ? 70000L : gps->ml); }
void tk_l_LtPS(long a) { jl = (gl2 > -40543L ? 70000L : a); }
void tk_l_LtPT(long a) { long t = (gl2 > -40543L ? 70000L : a); jl = t; }
long tk_l_LtPR(long a) { return (gl2 > -40543L ? 70000L : a); }
void tk_l_LtPO(long a) { jl ^= (gl2 > -40543L ? 70000L : a); }
void tk_l_MeGS(long a) { jl = (gps->mu < 9 ? gl : 70000L); }
void tk_l_MeGT(long a) { long t = (gps->mu < 9 ? gl : 70000L); jl = t; }
long tk_l_MeGR(long a) { return (gps->mu < 9 ? gl : 70000L); }
void tk_l_MeGO(long a) { jl ^= (gps->mu < 9 ? gl : 70000L); }
void tk_l_MeAS(long a) { jl = (gps->mu < 9 ? gla[4] : 70000L); }
void tk_l_MeAT(long a) { long t = (gps->mu < 9 ? gla[4] : 70000L); jl = t; }
long tk_l_MeAR(long a) { return (gps->mu < 9 ? gla[4] : 70000L); }
void tk_l_MeAO(long a) { jl ^= (gps->mu < 9 ? gla[4] : 70000L); }
void tk_l_MeMS(long a) { jl = (gps->mu < 9 ? gps->ml : 70000L); }
void tk_l_MeMT(long a) { long t = (gps->mu < 9 ? gps->ml : 70000L); jl = t; }
long tk_l_MeMR(long a) { return (gps->mu < 9 ? gps->ml : 70000L); }
void tk_l_MeMO(long a) { jl ^= (gps->mu < 9 ? gps->ml : 70000L); }
void tk_l_MePS(long a) { jl = (gps->mu < 9 ? a : 70000L); }
void tk_l_MePT(long a) { long t = (gps->mu < 9 ? a : 70000L); jl = t; }
long tk_l_MePR(long a) { return (gps->mu < 9 ? a : 70000L); }
void tk_l_MePO(long a) { jl ^= (gps->mu < 9 ? a : 70000L); }
void tk_l_MtGS(long a) { jl = (gps->mu < 9 ? 70000L : gl); }
void tk_l_MtGT(long a) { long t = (gps->mu < 9 ? 70000L : gl); jl = t; }
long tk_l_MtGR(long a) { return (gps->mu < 9 ? 70000L : gl); }
void tk_l_MtGO(long a) { jl ^= (gps->mu < 9 ? 70000L : gl); }
void tk_l_MtAS(long a) { jl = (gps->mu < 9 ? 70000L : gla[4]); }
void tk_l_MtAT(long a) { long t = (gps->mu < 9 ? 70000L : gla[4]); jl = t; }
long tk_l_MtAR(long a) { return (gps->mu < 9 ? 70000L : gla[4]); }
void tk_l_MtAO(long a) { jl ^= (gps->mu < 9 ? 70000L : gla[4]); }
void tk_l_MtMS(long a) { jl = (gps->mu < 9 ? 70000L : gps->ml); }
void tk_l_MtMT(long a) { long t = (gps->mu < 9 ? 70000L : gps->ml); jl = t; }
long tk_l_MtMR(long a) { return (gps->mu < 9 ? 70000L : gps->ml); }
void tk_l_MtMO(long a) { jl ^= (gps->mu < 9 ? 70000L : gps->ml); }
void tk_l_MtPS(long a) { jl = (gps->mu < 9 ? 70000L : a); }
void tk_l_MtPT(long a) { long t = (gps->mu < 9 ? 70000L : a); jl = t; }
long tk_l_MtPR(long a) { return (gps->mu < 9 ? 70000L : a); }
void tk_l_MtPO(long a) { jl ^= (gps->mu < 9 ? 70000L : a); }
void tk_l_PeGS(long a) { jl = (a > 3 ? gl : 70000L); }
void tk_l_PeGT(long a) { long t = (a > 3 ? gl : 70000L); jl = t; }
long tk_l_PeGR(long a) { return (a > 3 ? gl : 70000L); }
void tk_l_PeGO(long a) { jl ^= (a > 3 ? gl : 70000L); }
void tk_l_PeAS(long a) { jl = (a > 3 ? gla[4] : 70000L); }
void tk_l_PeAT(long a) { long t = (a > 3 ? gla[4] : 70000L); jl = t; }
long tk_l_PeAR(long a) { return (a > 3 ? gla[4] : 70000L); }
void tk_l_PeAO(long a) { jl ^= (a > 3 ? gla[4] : 70000L); }
void tk_l_PeMS(long a) { jl = (a > 3 ? gps->ml : 70000L); }
void tk_l_PeMT(long a) { long t = (a > 3 ? gps->ml : 70000L); jl = t; }
long tk_l_PeMR(long a) { return (a > 3 ? gps->ml : 70000L); }
void tk_l_PeMO(long a) { jl ^= (a > 3 ? gps->ml : 70000L); }
void tk_l_PePS(long a) { jl = (a > 3 ? a : 70000L); }
void tk_l_PePT(long a) { long t = (a > 3 ? a : 70000L); jl = t; }
long tk_l_PePR(long a) { return (a > 3 ? a : 70000L); }
void tk_l_PePO(long a) { jl ^= (a > 3 ? a : 70000L); }
void tk_l_PtGS(long a) { jl = (a > 3 ? 70000L : gl); }
void tk_l_PtGT(long a) { long t = (a > 3 ? 70000L : gl); jl = t; }
long tk_l_PtGR(long a) { return (a > 3 ? 70000L : gl); }
void tk_l_PtGO(long a) { jl ^= (a > 3 ? 70000L : gl); }
void tk_l_PtAS(long a) { jl = (a > 3 ? 70000L : gla[4]); }
void tk_l_PtAT(long a) { long t = (a > 3 ? 70000L : gla[4]); jl = t; }
long tk_l_PtAR(long a) { return (a > 3 ? 70000L : gla[4]); }
void tk_l_PtAO(long a) { jl ^= (a > 3 ? 70000L : gla[4]); }
void tk_l_PtMS(long a) { jl = (a > 3 ? 70000L : gps->ml); }
void tk_l_PtMT(long a) { long t = (a > 3 ? 70000L : gps->ml); jl = t; }
long tk_l_PtMR(long a) { return (a > 3 ? 70000L : gps->ml); }
void tk_l_PtMO(long a) { jl ^= (a > 3 ? 70000L : gps->ml); }
void tk_l_PtPS(long a) { jl = (a > 3 ? 70000L : a); }
void tk_l_PtPT(long a) { long t = (a > 3 ? 70000L : a); jl = t; }
long tk_l_PtPR(long a) { return (a > 3 ? 70000L : a); }
void tk_l_PtPO(long a) { jl ^= (a > 3 ? 70000L : a); }
void tk_l_EeGS(long a) { jl = (gia[a] != 0 ? gl : 70000L); }
void tk_l_EeGT(long a) { long t = (gia[a] != 0 ? gl : 70000L); jl = t; }
long tk_l_EeGR(long a) { return (gia[a] != 0 ? gl : 70000L); }
void tk_l_EeGO(long a) { jl ^= (gia[a] != 0 ? gl : 70000L); }
void tk_l_EeAS(long a) { jl = (gia[a] != 0 ? gla[4] : 70000L); }
void tk_l_EeAT(long a) { long t = (gia[a] != 0 ? gla[4] : 70000L); jl = t; }
long tk_l_EeAR(long a) { return (gia[a] != 0 ? gla[4] : 70000L); }
void tk_l_EeAO(long a) { jl ^= (gia[a] != 0 ? gla[4] : 70000L); }
void tk_l_EeMS(long a) { jl = (gia[a] != 0 ? gps->ml : 70000L); }
void tk_l_EeMT(long a) { long t = (gia[a] != 0 ? gps->ml : 70000L); jl = t; }
long tk_l_EeMR(long a) { return (gia[a] != 0 ? gps->ml : 70000L); }
void tk_l_EeMO(long a) { jl ^= (gia[a] != 0 ? gps->ml : 70000L); }
void tk_l_EePS(long a) { jl = (gia[a] != 0 ? a : 70000L); }
void tk_l_EePT(long a) { long t = (gia[a] != 0 ? a : 70000L); jl = t; }
long tk_l_EePR(long a) { return (gia[a] != 0 ? a : 70000L); }
void tk_l_EePO(long a) { jl ^= (gia[a] != 0 ? a : 70000L); }
void tk_l_EtGS(long a) { jl = (gia[a] != 0 ? 70000L : gl); }
void tk_l_EtGT(long a) { long t = (gia[a] != 0 ? 70000L : gl); jl = t; }
long tk_l_EtGR(long a) { return (gia[a] != 0 ? 70000L : gl); }
void tk_l_EtGO(long a) { jl ^= (gia[a] != 0 ? 70000L : gl); }
void tk_l_EtAS(long a) { jl = (gia[a] != 0 ? 70000L : gla[4]); }
void tk_l_EtAT(long a) { long t = (gia[a] != 0 ? 70000L : gla[4]); jl = t; }
long tk_l_EtAR(long a) { return (gia[a] != 0 ? 70000L : gla[4]); }
void tk_l_EtAO(long a) { jl ^= (gia[a] != 0 ? 70000L : gla[4]); }
void tk_l_EtMS(long a) { jl = (gia[a] != 0 ? 70000L : gps->ml); }
void tk_l_EtMT(long a) { long t = (gia[a] != 0 ? 70000L : gps->ml); jl = t; }
long tk_l_EtMR(long a) { return (gia[a] != 0 ? 70000L : gps->ml); }
void tk_l_EtMO(long a) { jl ^= (gia[a] != 0 ? 70000L : gps->ml); }
void tk_l_EtPS(long a) { jl = (gia[a] != 0 ? 70000L : a); }
void tk_l_EtPT(long a) { long t = (gia[a] != 0 ? 70000L : a); jl = t; }
long tk_l_EtPR(long a) { return (gia[a] != 0 ? 70000L : a); }
void tk_l_EtPO(long a) { jl ^= (gia[a] != 0 ? 70000L : a); }
void tk_l_QeGS(long a) { jl = (gc < hc ? gl : 70000L); }
void tk_l_QeGT(long a) { long t = (gc < hc ? gl : 70000L); jl = t; }
long tk_l_QeGR(long a) { return (gc < hc ? gl : 70000L); }
void tk_l_QeGO(long a) { jl ^= (gc < hc ? gl : 70000L); }
void tk_l_QeAS(long a) { jl = (gc < hc ? gla[4] : 70000L); }
void tk_l_QeAT(long a) { long t = (gc < hc ? gla[4] : 70000L); jl = t; }
long tk_l_QeAR(long a) { return (gc < hc ? gla[4] : 70000L); }
void tk_l_QeAO(long a) { jl ^= (gc < hc ? gla[4] : 70000L); }
void tk_l_QeMS(long a) { jl = (gc < hc ? gps->ml : 70000L); }
void tk_l_QeMT(long a) { long t = (gc < hc ? gps->ml : 70000L); jl = t; }
long tk_l_QeMR(long a) { return (gc < hc ? gps->ml : 70000L); }
void tk_l_QeMO(long a) { jl ^= (gc < hc ? gps->ml : 70000L); }
void tk_l_QePS(long a) { jl = (gc < hc ? a : 70000L); }
void tk_l_QePT(long a) { long t = (gc < hc ? a : 70000L); jl = t; }
long tk_l_QePR(long a) { return (gc < hc ? a : 70000L); }
void tk_l_QePO(long a) { jl ^= (gc < hc ? a : 70000L); }
void tk_l_QtGS(long a) { jl = (gc < hc ? 70000L : gl); }
void tk_l_QtGT(long a) { long t = (gc < hc ? 70000L : gl); jl = t; }
long tk_l_QtGR(long a) { return (gc < hc ? 70000L : gl); }
void tk_l_QtGO(long a) { jl ^= (gc < hc ? 70000L : gl); }
void tk_l_QtAS(long a) { jl = (gc < hc ? 70000L : gla[4]); }
void tk_l_QtAT(long a) { long t = (gc < hc ? 70000L : gla[4]); jl = t; }
long tk_l_QtAR(long a) { return (gc < hc ? 70000L : gla[4]); }
void tk_l_QtAO(long a) { jl ^= (gc < hc ? 70000L : gla[4]); }
void tk_l_QtMS(long a) { jl = (gc < hc ? 70000L : gps->ml); }
void tk_l_QtMT(long a) { long t = (gc < hc ? 70000L : gps->ml); jl = t; }
long tk_l_QtMR(long a) { return (gc < hc ? 70000L : gps->ml); }
void tk_l_QtMO(long a) { jl ^= (gc < hc ? 70000L : gps->ml); }
void tk_l_QtPS(long a) { jl = (gc < hc ? 70000L : a); }
void tk_l_QtPT(long a) { long t = (gc < hc ? 70000L : a); jl = t; }
long tk_l_QtPR(long a) { return (gc < hc ? 70000L : a); }
void tk_l_QtPO(long a) { jl ^= (gc < hc ? 70000L : a); }
void tk_l_CeGS(long a) { jl = (gri(gi) != 0 ? gl : 70000L); }
void tk_l_CeGT(long a) { long t = (gri(gi) != 0 ? gl : 70000L); jl = t; }
long tk_l_CeGR(long a) { return (gri(gi) != 0 ? gl : 70000L); }
void tk_l_CeGO(long a) { jl ^= (gri(gi) != 0 ? gl : 70000L); }
void tk_l_CeAS(long a) { jl = (gri(gi) != 0 ? gla[4] : 70000L); }
void tk_l_CeAT(long a) { long t = (gri(gi) != 0 ? gla[4] : 70000L); jl = t; }
long tk_l_CeAR(long a) { return (gri(gi) != 0 ? gla[4] : 70000L); }
void tk_l_CeAO(long a) { jl ^= (gri(gi) != 0 ? gla[4] : 70000L); }
void tk_l_CeMS(long a) { jl = (gri(gi) != 0 ? gps->ml : 70000L); }
void tk_l_CeMT(long a) { long t = (gri(gi) != 0 ? gps->ml : 70000L); jl = t; }
long tk_l_CeMR(long a) { return (gri(gi) != 0 ? gps->ml : 70000L); }
void tk_l_CeMO(long a) { jl ^= (gri(gi) != 0 ? gps->ml : 70000L); }
void tk_l_CePS(long a) { jl = (gri(gi) != 0 ? a : 70000L); }
void tk_l_CePT(long a) { long t = (gri(gi) != 0 ? a : 70000L); jl = t; }
long tk_l_CePR(long a) { return (gri(gi) != 0 ? a : 70000L); }
void tk_l_CePO(long a) { jl ^= (gri(gi) != 0 ? a : 70000L); }
void tk_l_CtGS(long a) { jl = (gri(gi) != 0 ? 70000L : gl); }
void tk_l_CtGT(long a) { long t = (gri(gi) != 0 ? 70000L : gl); jl = t; }
long tk_l_CtGR(long a) { return (gri(gi) != 0 ? 70000L : gl); }
void tk_l_CtGO(long a) { jl ^= (gri(gi) != 0 ? 70000L : gl); }
void tk_l_CtAS(long a) { jl = (gri(gi) != 0 ? 70000L : gla[4]); }
void tk_l_CtAT(long a) { long t = (gri(gi) != 0 ? 70000L : gla[4]); jl = t; }
long tk_l_CtAR(long a) { return (gri(gi) != 0 ? 70000L : gla[4]); }
void tk_l_CtAO(long a) { jl ^= (gri(gi) != 0 ? 70000L : gla[4]); }
void tk_l_CtMS(long a) { jl = (gri(gi) != 0 ? 70000L : gps->ml); }
void tk_l_CtMT(long a) { long t = (gri(gi) != 0 ? 70000L : gps->ml); jl = t; }
long tk_l_CtMR(long a) { return (gri(gi) != 0 ? 70000L : gps->ml); }
void tk_l_CtMO(long a) { jl ^= (gri(gi) != 0 ? 70000L : gps->ml); }
void tk_l_CtPS(long a) { jl = (gri(gi) != 0 ? 70000L : a); }
void tk_l_CtPT(long a) { long t = (gri(gi) != 0 ? 70000L : a); jl = t; }
long tk_l_CtPR(long a) { return (gri(gi) != 0 ? 70000L : a); }
void tk_l_CtPO(long a) { jl ^= (gri(gi) != 0 ? 70000L : a); }
