/* lane_o3 shapes probe 2: see gen_shp2.py for the name letters */
struct sv { char mc; unsigned char mb; int mi; unsigned int mu; long ml; unsigned long mn; int ma[8]; };
extern struct sv gs, *gps;
extern char gc, gc2, gca[8], *gcp;
extern int gi, gi2, gia[8], *gip;
extern unsigned int gu, gu2, gua[8];
extern long gl, gl2, gla[8];
extern unsigned char guc;
void eo_iPaK(int b) { gia[b] += gu ^ 3; }
void eo_iPaM(int b) { gia[b] += gu * 3; }
void eo_iPaB(int b) { gia[b] += gu + gu2; }
void eo_iPaU(int b) { gia[b] += ~gu; }
void eo_iPaG(int b) { gia[b] += gu; }
void eo_iPsK(int b) { gia[b] -= gu ^ 3; }
void eo_iPsM(int b) { gia[b] -= gu * 3; }
void eo_iPsB(int b) { gia[b] -= gu + gu2; }
void eo_iPsU(int b) { gia[b] -= ~gu; }
void eo_iPsG(int b) { gia[b] -= gu; }
void eo_iPxK(int b) { gia[b] ^= gu ^ 3; }
void eo_iPxM(int b) { gia[b] ^= gu * 3; }
void eo_iPxB(int b) { gia[b] ^= gu + gu2; }
void eo_iPxU(int b) { gia[b] ^= ~gu; }
void eo_iPxG(int b) { gia[b] ^= gu; }
void eo_iPnK(int b) { gia[b] &= gu ^ 3; }
void eo_iPnM(int b) { gia[b] &= gu * 3; }
void eo_iPnB(int b) { gia[b] &= gu + gu2; }
void eo_iPnU(int b) { gia[b] &= ~gu; }
void eo_iPnG(int b) { gia[b] &= gu; }
void eo_iPoK(int b) { gia[b] |= gu ^ 3; }
void eo_iPoM(int b) { gia[b] |= gu * 3; }
void eo_iPoB(int b) { gia[b] |= gu + gu2; }
void eo_iPoU(int b) { gia[b] |= ~gu; }
void eo_iPoG(int b) { gia[b] |= gu; }
void eo_iLaK(void) { int b = gi2; gia[b] += gu ^ 3; }
void eo_iLaM(void) { int b = gi2; gia[b] += gu * 3; }
void eo_iLaB(void) { int b = gi2; gia[b] += gu + gu2; }
void eo_iLaU(void) { int b = gi2; gia[b] += ~gu; }
void eo_iLaG(void) { int b = gi2; gia[b] += gu; }
void eo_iLsK(void) { int b = gi2; gia[b] -= gu ^ 3; }
void eo_iLsM(void) { int b = gi2; gia[b] -= gu * 3; }
void eo_iLsB(void) { int b = gi2; gia[b] -= gu + gu2; }
void eo_iLsU(void) { int b = gi2; gia[b] -= ~gu; }
void eo_iLsG(void) { int b = gi2; gia[b] -= gu; }
void eo_iLxK(void) { int b = gi2; gia[b] ^= gu ^ 3; }
void eo_iLxM(void) { int b = gi2; gia[b] ^= gu * 3; }
void eo_iLxB(void) { int b = gi2; gia[b] ^= gu + gu2; }
void eo_iLxU(void) { int b = gi2; gia[b] ^= ~gu; }
void eo_iLxG(void) { int b = gi2; gia[b] ^= gu; }
void eo_iLnK(void) { int b = gi2; gia[b] &= gu ^ 3; }
void eo_iLnM(void) { int b = gi2; gia[b] &= gu * 3; }
void eo_iLnB(void) { int b = gi2; gia[b] &= gu + gu2; }
void eo_iLnU(void) { int b = gi2; gia[b] &= ~gu; }
void eo_iLnG(void) { int b = gi2; gia[b] &= gu; }
void eo_iLoK(void) { int b = gi2; gia[b] |= gu ^ 3; }
void eo_iLoM(void) { int b = gi2; gia[b] |= gu * 3; }
void eo_iLoB(void) { int b = gi2; gia[b] |= gu + gu2; }
void eo_iLoU(void) { int b = gi2; gia[b] |= ~gu; }
void eo_iLoG(void) { int b = gi2; gia[b] |= gu; }
void eo_lPaK(int b) { gla[b] += gl ^ 3; }
void eo_lPaM(int b) { gla[b] += gl * 3; }
void eo_lPaB(int b) { gla[b] += gl + gl2; }
void eo_lPaU(int b) { gla[b] += ~gl; }
void eo_lPaG(int b) { gla[b] += gl; }
void eo_lPsK(int b) { gla[b] -= gl ^ 3; }
void eo_lPsM(int b) { gla[b] -= gl * 3; }
void eo_lPsB(int b) { gla[b] -= gl + gl2; }
void eo_lPsU(int b) { gla[b] -= ~gl; }
void eo_lPsG(int b) { gla[b] -= gl; }
void eo_lPxK(int b) { gla[b] ^= gl ^ 3; }
void eo_lPxM(int b) { gla[b] ^= gl * 3; }
void eo_lPxB(int b) { gla[b] ^= gl + gl2; }
void eo_lPxU(int b) { gla[b] ^= ~gl; }
void eo_lPxG(int b) { gla[b] ^= gl; }
void eo_lPnK(int b) { gla[b] &= gl ^ 3; }
void eo_lPnM(int b) { gla[b] &= gl * 3; }
void eo_lPnB(int b) { gla[b] &= gl + gl2; }
void eo_lPnU(int b) { gla[b] &= ~gl; }
void eo_lPnG(int b) { gla[b] &= gl; }
void eo_lPoK(int b) { gla[b] |= gl ^ 3; }
void eo_lPoM(int b) { gla[b] |= gl * 3; }
void eo_lPoB(int b) { gla[b] |= gl + gl2; }
void eo_lPoU(int b) { gla[b] |= ~gl; }
void eo_lPoG(int b) { gla[b] |= gl; }
void eo_lLaK(void) { int b = gi2; gla[b] += gl ^ 3; }
void eo_lLaM(void) { int b = gi2; gla[b] += gl * 3; }
void eo_lLaB(void) { int b = gi2; gla[b] += gl + gl2; }
void eo_lLaU(void) { int b = gi2; gla[b] += ~gl; }
void eo_lLaG(void) { int b = gi2; gla[b] += gl; }
void eo_lLsK(void) { int b = gi2; gla[b] -= gl ^ 3; }
void eo_lLsM(void) { int b = gi2; gla[b] -= gl * 3; }
void eo_lLsB(void) { int b = gi2; gla[b] -= gl + gl2; }
void eo_lLsU(void) { int b = gi2; gla[b] -= ~gl; }
void eo_lLsG(void) { int b = gi2; gla[b] -= gl; }
void eo_lLxK(void) { int b = gi2; gla[b] ^= gl ^ 3; }
void eo_lLxM(void) { int b = gi2; gla[b] ^= gl * 3; }
void eo_lLxB(void) { int b = gi2; gla[b] ^= gl + gl2; }
void eo_lLxU(void) { int b = gi2; gla[b] ^= ~gl; }
void eo_lLxG(void) { int b = gi2; gla[b] ^= gl; }
void eo_lLnK(void) { int b = gi2; gla[b] &= gl ^ 3; }
void eo_lLnM(void) { int b = gi2; gla[b] &= gl * 3; }
void eo_lLnB(void) { int b = gi2; gla[b] &= gl + gl2; }
void eo_lLnU(void) { int b = gi2; gla[b] &= ~gl; }
void eo_lLnG(void) { int b = gi2; gla[b] &= gl; }
void eo_lLoK(void) { int b = gi2; gla[b] |= gl ^ 3; }
void eo_lLoM(void) { int b = gi2; gla[b] |= gl * 3; }
void eo_lLoB(void) { int b = gi2; gla[b] |= gl + gl2; }
void eo_lLoU(void) { int b = gi2; gla[b] |= ~gl; }
void eo_lLoG(void) { int b = gi2; gla[b] |= gl; }
void eo_cPaK(int b) { gca[b] += gc ^ 3; }
void eo_cPaM(int b) { gca[b] += gc * 3; }
void eo_cPaB(int b) { gca[b] += gc + gc2; }
void eo_cPaU(int b) { gca[b] += ~gc; }
void eo_cPaG(int b) { gca[b] += gc; }
void eo_cPsK(int b) { gca[b] -= gc ^ 3; }
void eo_cPsM(int b) { gca[b] -= gc * 3; }
void eo_cPsB(int b) { gca[b] -= gc + gc2; }
void eo_cPsU(int b) { gca[b] -= ~gc; }
void eo_cPsG(int b) { gca[b] -= gc; }
void eo_cPxK(int b) { gca[b] ^= gc ^ 3; }
void eo_cPxM(int b) { gca[b] ^= gc * 3; }
void eo_cPxB(int b) { gca[b] ^= gc + gc2; }
void eo_cPxU(int b) { gca[b] ^= ~gc; }
void eo_cPxG(int b) { gca[b] ^= gc; }
void eo_cPnK(int b) { gca[b] &= gc ^ 3; }
void eo_cPnM(int b) { gca[b] &= gc * 3; }
void eo_cPnB(int b) { gca[b] &= gc + gc2; }
void eo_cPnU(int b) { gca[b] &= ~gc; }
void eo_cPnG(int b) { gca[b] &= gc; }
void eo_cPoK(int b) { gca[b] |= gc ^ 3; }
void eo_cPoM(int b) { gca[b] |= gc * 3; }
void eo_cPoB(int b) { gca[b] |= gc + gc2; }
void eo_cPoU(int b) { gca[b] |= ~gc; }
void eo_cPoG(int b) { gca[b] |= gc; }
void eo_cLaK(void) { int b = gi2; gca[b] += gc ^ 3; }
void eo_cLaM(void) { int b = gi2; gca[b] += gc * 3; }
void eo_cLaB(void) { int b = gi2; gca[b] += gc + gc2; }
void eo_cLaU(void) { int b = gi2; gca[b] += ~gc; }
void eo_cLaG(void) { int b = gi2; gca[b] += gc; }
void eo_cLsK(void) { int b = gi2; gca[b] -= gc ^ 3; }
void eo_cLsM(void) { int b = gi2; gca[b] -= gc * 3; }
void eo_cLsB(void) { int b = gi2; gca[b] -= gc + gc2; }
void eo_cLsU(void) { int b = gi2; gca[b] -= ~gc; }
void eo_cLsG(void) { int b = gi2; gca[b] -= gc; }
void eo_cLxK(void) { int b = gi2; gca[b] ^= gc ^ 3; }
void eo_cLxM(void) { int b = gi2; gca[b] ^= gc * 3; }
void eo_cLxB(void) { int b = gi2; gca[b] ^= gc + gc2; }
void eo_cLxU(void) { int b = gi2; gca[b] ^= ~gc; }
void eo_cLxG(void) { int b = gi2; gca[b] ^= gc; }
void eo_cLnK(void) { int b = gi2; gca[b] &= gc ^ 3; }
void eo_cLnM(void) { int b = gi2; gca[b] &= gc * 3; }
void eo_cLnB(void) { int b = gi2; gca[b] &= gc + gc2; }
void eo_cLnU(void) { int b = gi2; gca[b] &= ~gc; }
void eo_cLnG(void) { int b = gi2; gca[b] &= gc; }
void eo_cLoK(void) { int b = gi2; gca[b] |= gc ^ 3; }
void eo_cLoM(void) { int b = gi2; gca[b] |= gc * 3; }
void eo_cLoB(void) { int b = gi2; gca[b] |= gc + gc2; }
void eo_cLoU(void) { int b = gi2; gca[b] |= ~gc; }
void eo_cLoG(void) { int b = gi2; gca[b] |= gc; }
int tv_MnNR(void) { return gps->ma[2] & (guc != 4); }
int tv_MnNr(void) { return (guc != 4) & gps->ma[2]; }
void tv_MnNS(void) { gi2 = gps->ma[2] & (guc != 4); }
int tv_MnLR(void) { return gps->ma[2] & (gi < gi2); }
int tv_MnLr(void) { return (gi < gi2) & gps->ma[2]; }
void tv_MnLS(void) { gi2 = gps->ma[2] & (gi < gi2); }
int tv_MnBR(void) { return gps->ma[2] & !gu; }
int tv_MnBr(void) { return !gu & gps->ma[2]; }
void tv_MnBS(void) { gi2 = gps->ma[2] & !gu; }
int tv_MoNR(void) { return gps->ma[2] | (guc != 4); }
int tv_MoNr(void) { return (guc != 4) | gps->ma[2]; }
void tv_MoNS(void) { gi2 = gps->ma[2] | (guc != 4); }
int tv_MoLR(void) { return gps->ma[2] | (gi < gi2); }
int tv_MoLr(void) { return (gi < gi2) | gps->ma[2]; }
void tv_MoLS(void) { gi2 = gps->ma[2] | (gi < gi2); }
int tv_MoBR(void) { return gps->ma[2] | !gu; }
int tv_MoBr(void) { return !gu | gps->ma[2]; }
void tv_MoBS(void) { gi2 = gps->ma[2] | !gu; }
int tv_MxNR(void) { return gps->ma[2] ^ (guc != 4); }
int tv_MxNr(void) { return (guc != 4) ^ gps->ma[2]; }
void tv_MxNS(void) { gi2 = gps->ma[2] ^ (guc != 4); }
int tv_MxLR(void) { return gps->ma[2] ^ (gi < gi2); }
int tv_MxLr(void) { return (gi < gi2) ^ gps->ma[2]; }
void tv_MxLS(void) { gi2 = gps->ma[2] ^ (gi < gi2); }
int tv_MxBR(void) { return gps->ma[2] ^ !gu; }
int tv_MxBr(void) { return !gu ^ gps->ma[2]; }
void tv_MxBS(void) { gi2 = gps->ma[2] ^ !gu; }
int tv_MaNR(void) { return gps->ma[2] + (guc != 4); }
int tv_MaNr(void) { return (guc != 4) + gps->ma[2]; }
void tv_MaNS(void) { gi2 = gps->ma[2] + (guc != 4); }
int tv_MaLR(void) { return gps->ma[2] + (gi < gi2); }
int tv_MaLr(void) { return (gi < gi2) + gps->ma[2]; }
void tv_MaLS(void) { gi2 = gps->ma[2] + (gi < gi2); }
int tv_MaBR(void) { return gps->ma[2] + !gu; }
int tv_MaBr(void) { return !gu + gps->ma[2]; }
void tv_MaBS(void) { gi2 = gps->ma[2] + !gu; }
int tv_AnNR(void) { return gia[2] & (guc != 4); }
int tv_AnNr(void) { return (guc != 4) & gia[2]; }
void tv_AnNS(void) { gi2 = gia[2] & (guc != 4); }
int tv_AnLR(void) { return gia[2] & (gi < gi2); }
int tv_AnLr(void) { return (gi < gi2) & gia[2]; }
void tv_AnLS(void) { gi2 = gia[2] & (gi < gi2); }
int tv_AnBR(void) { return gia[2] & !gu; }
int tv_AnBr(void) { return !gu & gia[2]; }
void tv_AnBS(void) { gi2 = gia[2] & !gu; }
int tv_AoNR(void) { return gia[2] | (guc != 4); }
int tv_AoNr(void) { return (guc != 4) | gia[2]; }
void tv_AoNS(void) { gi2 = gia[2] | (guc != 4); }
int tv_AoLR(void) { return gia[2] | (gi < gi2); }
int tv_AoLr(void) { return (gi < gi2) | gia[2]; }
void tv_AoLS(void) { gi2 = gia[2] | (gi < gi2); }
int tv_AoBR(void) { return gia[2] | !gu; }
int tv_AoBr(void) { return !gu | gia[2]; }
void tv_AoBS(void) { gi2 = gia[2] | !gu; }
int tv_AxNR(void) { return gia[2] ^ (guc != 4); }
int tv_AxNr(void) { return (guc != 4) ^ gia[2]; }
void tv_AxNS(void) { gi2 = gia[2] ^ (guc != 4); }
int tv_AxLR(void) { return gia[2] ^ (gi < gi2); }
int tv_AxLr(void) { return (gi < gi2) ^ gia[2]; }
void tv_AxLS(void) { gi2 = gia[2] ^ (gi < gi2); }
int tv_AxBR(void) { return gia[2] ^ !gu; }
int tv_AxBr(void) { return !gu ^ gia[2]; }
void tv_AxBS(void) { gi2 = gia[2] ^ !gu; }
int tv_AaNR(void) { return gia[2] + (guc != 4); }
int tv_AaNr(void) { return (guc != 4) + gia[2]; }
void tv_AaNS(void) { gi2 = gia[2] + (guc != 4); }
int tv_AaLR(void) { return gia[2] + (gi < gi2); }
int tv_AaLr(void) { return (gi < gi2) + gia[2]; }
void tv_AaLS(void) { gi2 = gia[2] + (gi < gi2); }
int tv_AaBR(void) { return gia[2] + !gu; }
int tv_AaBr(void) { return !gu + gia[2]; }
void tv_AaBS(void) { gi2 = gia[2] + !gu; }
int tv_GnNR(void) { return gi & (guc != 4); }
int tv_GnNr(void) { return (guc != 4) & gi; }
void tv_GnNS(void) { gi2 = gi & (guc != 4); }
int tv_GnLR(void) { return gi & (gi < gi2); }
int tv_GnLr(void) { return (gi < gi2) & gi; }
void tv_GnLS(void) { gi2 = gi & (gi < gi2); }
int tv_GnBR(void) { return gi & !gu; }
int tv_GnBr(void) { return !gu & gi; }
void tv_GnBS(void) { gi2 = gi & !gu; }
int tv_GoNR(void) { return gi | (guc != 4); }
int tv_GoNr(void) { return (guc != 4) | gi; }
void tv_GoNS(void) { gi2 = gi | (guc != 4); }
int tv_GoLR(void) { return gi | (gi < gi2); }
int tv_GoLr(void) { return (gi < gi2) | gi; }
void tv_GoLS(void) { gi2 = gi | (gi < gi2); }
int tv_GoBR(void) { return gi | !gu; }
int tv_GoBr(void) { return !gu | gi; }
void tv_GoBS(void) { gi2 = gi | !gu; }
int tv_GxNR(void) { return gi ^ (guc != 4); }
int tv_GxNr(void) { return (guc != 4) ^ gi; }
void tv_GxNS(void) { gi2 = gi ^ (guc != 4); }
int tv_GxLR(void) { return gi ^ (gi < gi2); }
int tv_GxLr(void) { return (gi < gi2) ^ gi; }
void tv_GxLS(void) { gi2 = gi ^ (gi < gi2); }
int tv_GxBR(void) { return gi ^ !gu; }
int tv_GxBr(void) { return !gu ^ gi; }
void tv_GxBS(void) { gi2 = gi ^ !gu; }
int tv_GaNR(void) { return gi + (guc != 4); }
int tv_GaNr(void) { return (guc != 4) + gi; }
void tv_GaNS(void) { gi2 = gi + (guc != 4); }
int tv_GaLR(void) { return gi + (gi < gi2); }
int tv_GaLr(void) { return (gi < gi2) + gi; }
void tv_GaLS(void) { gi2 = gi + (gi < gi2); }
int tv_GaBR(void) { return gi + !gu; }
int tv_GaBr(void) { return !gu + gi; }
void tv_GaBS(void) { gi2 = gi + !gu; }
int tv_DnNR(void) { return *gip & (guc != 4); }
int tv_DnNr(void) { return (guc != 4) & *gip; }
void tv_DnNS(void) { gi2 = *gip & (guc != 4); }
int tv_DnLR(void) { return *gip & (gi < gi2); }
int tv_DnLr(void) { return (gi < gi2) & *gip; }
void tv_DnLS(void) { gi2 = *gip & (gi < gi2); }
int tv_DnBR(void) { return *gip & !gu; }
int tv_DnBr(void) { return !gu & *gip; }
void tv_DnBS(void) { gi2 = *gip & !gu; }
int tv_DoNR(void) { return *gip | (guc != 4); }
int tv_DoNr(void) { return (guc != 4) | *gip; }
void tv_DoNS(void) { gi2 = *gip | (guc != 4); }
int tv_DoLR(void) { return *gip | (gi < gi2); }
int tv_DoLr(void) { return (gi < gi2) | *gip; }
void tv_DoLS(void) { gi2 = *gip | (gi < gi2); }
int tv_DoBR(void) { return *gip | !gu; }
int tv_DoBr(void) { return !gu | *gip; }
void tv_DoBS(void) { gi2 = *gip | !gu; }
int tv_DxNR(void) { return *gip ^ (guc != 4); }
int tv_DxNr(void) { return (guc != 4) ^ *gip; }
void tv_DxNS(void) { gi2 = *gip ^ (guc != 4); }
int tv_DxLR(void) { return *gip ^ (gi < gi2); }
int tv_DxLr(void) { return (gi < gi2) ^ *gip; }
void tv_DxLS(void) { gi2 = *gip ^ (gi < gi2); }
int tv_DxBR(void) { return *gip ^ !gu; }
int tv_DxBr(void) { return !gu ^ *gip; }
void tv_DxBS(void) { gi2 = *gip ^ !gu; }
int tv_DaNR(void) { return *gip + (guc != 4); }
int tv_DaNr(void) { return (guc != 4) + *gip; }
void tv_DaNS(void) { gi2 = *gip + (guc != 4); }
int tv_DaLR(void) { return *gip + (gi < gi2); }
int tv_DaLr(void) { return (gi < gi2) + *gip; }
void tv_DaLS(void) { gi2 = *gip + (gi < gi2); }
int tv_DaBR(void) { return *gip + !gu; }
int tv_DaBr(void) { return !gu + *gip; }
void tv_DaBS(void) { gi2 = *gip + !gu; }
void uc_Pol(char *a) { gc2 = a[6] | ~gc2; }
void uc_Por(char *a) { gc2 = ~gc2 | a[6]; }
void uc_Pnl(char *a) { gc2 = a[6] & ~gc2; }
void uc_Pnr(char *a) { gc2 = ~gc2 & a[6]; }
void uc_Pxl(char *a) { gc2 = a[6] ^ ~gc2; }
void uc_Pxr(char *a) { gc2 = ~gc2 ^ a[6]; }
void uc_Gol(char *a) { gc2 = gcp[6] | ~gc2; }
void uc_Gor(char *a) { gc2 = ~gc2 | gcp[6]; }
void uc_Gnl(char *a) { gc2 = gcp[6] & ~gc2; }
void uc_Gnr(char *a) { gc2 = ~gc2 & gcp[6]; }
void uc_Gxl(char *a) { gc2 = gcp[6] ^ ~gc2; }
void uc_Gxr(char *a) { gc2 = ~gc2 ^ gcp[6]; }
