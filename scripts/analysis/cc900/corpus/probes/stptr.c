/* lane_nm wrong-code probe: element and pointer stores and chains; see gen_stptr.py for the name letters */
struct sv { char mc; int mi; long ml; char mca[8]; int mia[8]; long mla[8]; };
extern struct sv *gps;
extern char gc, gc2, gc3, gca[8], gcb[8], gcu[], *gcp;
extern int gi, gi2, gi3, gia[8], gib[8], giu[], *gip;
extern long gl, gl2, gl3, gla[8], glb[8], glu[], *glp;
extern unsigned int gu;
extern char rc(void);
extern int ri(void);
extern long rl(void);
void sp_cAka(int b, unsigned int ub, char cb, char *q) { gca[3] = 5; }
void sp_cAkb(int b, unsigned int ub, char cb, char *q) { gca[3] = gc; }
void sp_cAkc(int b, unsigned int ub, char cb, char *q) { gca[3] = gc + gc2; }
void sp_cAkd(int b, unsigned int ub, char cb, char *q) { gca[3] = gc * gc2; }
void sp_cAke(int b, unsigned int ub, char cb, char *q) { gca[3] = rc(); }
void sp_cAkf(int b, unsigned int ub, char cb, char *q) { gca[3] = gc >> cb; }
void sp_cAkg(int b, unsigned int ub, char cb, char *q) { gca[3] = (gu ? gc : gc2); }
void sp_cAkh(int b, unsigned int ub, char cb, char *q) { gca[3] = -gcb[2]; }
void sp_cAki(int b, unsigned int ub, char cb, char *q) { gca[3] = gc3 = gc + gc2; }
void sp_cAkj(int b, unsigned int ub, char cb, char *q) { gca[3] = gc3 = 7; }
void sp_cAkk(int b, unsigned int ub, char cb, char *q) { gca[3] += gc; }
void sp_cAkm(int b, unsigned int ub, char cb, char *q) { gca[3] ^= gc + gc2; }
void sp_cAkn(int b, unsigned int ub, char cb, char *q) { gca[3] -= 9; }
void sp_cAko(int b, unsigned int ub, char cb, char *q) { gca[3] <<= 1; }
void sp_cAkp(int b, unsigned int ub, char cb, char *q) { gca[3]++; }
void sp_cAkq(int b, unsigned int ub, char cb, char *q) { --gca[3]; }
void sp_cAkr(int b, unsigned int ub, char cb, char *q) { gc3 = gca[3]++; }
void sp_cAks(int b, unsigned int ub, char cb, char *q) { gc3 = ++gca[3]; }
void sp_cAkt(int b, unsigned int ub, char cb, char *q) { gc3 = gca[3]--; }
void sp_cAKa(int b, unsigned int ub, char cb, char *q) { gca[0x8001u] = 5; }
void sp_cAKb(int b, unsigned int ub, char cb, char *q) { gca[0x8001u] = gc; }
void sp_cAKc(int b, unsigned int ub, char cb, char *q) { gca[0x8001u] = gc + gc2; }
void sp_cAKd(int b, unsigned int ub, char cb, char *q) { gca[0x8001u] = gc * gc2; }
void sp_cAKe(int b, unsigned int ub, char cb, char *q) { gca[0x8001u] = rc(); }
void sp_cAKf(int b, unsigned int ub, char cb, char *q) { gca[0x8001u] = gc >> cb; }
void sp_cAKg(int b, unsigned int ub, char cb, char *q) { gca[0x8001u] = (gu ? gc : gc2); }
void sp_cAKh(int b, unsigned int ub, char cb, char *q) { gca[0x8001u] = -gcb[2]; }
void sp_cAKi(int b, unsigned int ub, char cb, char *q) { gca[0x8001u] = gc3 = gc + gc2; }
void sp_cAKj(int b, unsigned int ub, char cb, char *q) { gca[0x8001u] = gc3 = 7; }
void sp_cAKk(int b, unsigned int ub, char cb, char *q) { gca[0x8001u] += gc; }
void sp_cAKm(int b, unsigned int ub, char cb, char *q) { gca[0x8001u] ^= gc + gc2; }
void sp_cAKn(int b, unsigned int ub, char cb, char *q) { gca[0x8001u] -= 9; }
void sp_cAKo(int b, unsigned int ub, char cb, char *q) { gca[0x8001u] <<= 1; }
void sp_cAKp(int b, unsigned int ub, char cb, char *q) { gca[0x8001u]++; }
void sp_cAKq(int b, unsigned int ub, char cb, char *q) { --gca[0x8001u]; }
void sp_cAKr(int b, unsigned int ub, char cb, char *q) { gc3 = gca[0x8001u]++; }
void sp_cAKs(int b, unsigned int ub, char cb, char *q) { gc3 = ++gca[0x8001u]; }
void sp_cAKt(int b, unsigned int ub, char cb, char *q) { gc3 = gca[0x8001u]--; }
void sp_cApa(int b, unsigned int ub, char cb, char *q) { gca[b] = 5; }
void sp_cApb(int b, unsigned int ub, char cb, char *q) { gca[b] = gc; }
void sp_cApc(int b, unsigned int ub, char cb, char *q) { gca[b] = gc + gc2; }
void sp_cApd(int b, unsigned int ub, char cb, char *q) { gca[b] = gc * gc2; }
void sp_cApe(int b, unsigned int ub, char cb, char *q) { gca[b] = rc(); }
void sp_cApf(int b, unsigned int ub, char cb, char *q) { gca[b] = gc >> cb; }
void sp_cApg(int b, unsigned int ub, char cb, char *q) { gca[b] = (gu ? gc : gc2); }
void sp_cAph(int b, unsigned int ub, char cb, char *q) { gca[b] = -gcb[2]; }
void sp_cApi(int b, unsigned int ub, char cb, char *q) { gca[b] = gc3 = gc + gc2; }
void sp_cApj(int b, unsigned int ub, char cb, char *q) { gca[b] = gc3 = 7; }
void sp_cApk(int b, unsigned int ub, char cb, char *q) { gca[b] += gc; }
void sp_cApm(int b, unsigned int ub, char cb, char *q) { gca[b] ^= gc + gc2; }
void sp_cApn(int b, unsigned int ub, char cb, char *q) { gca[b] -= 9; }
void sp_cApo(int b, unsigned int ub, char cb, char *q) { gca[b] <<= 1; }
void sp_cApp(int b, unsigned int ub, char cb, char *q) { gca[b]++; }
void sp_cApq(int b, unsigned int ub, char cb, char *q) { --gca[b]; }
void sp_cApr(int b, unsigned int ub, char cb, char *q) { gc3 = gca[b]++; }
void sp_cAps(int b, unsigned int ub, char cb, char *q) { gc3 = ++gca[b]; }
void sp_cApt(int b, unsigned int ub, char cb, char *q) { gc3 = gca[b]--; }
void sp_cAua(int b, unsigned int ub, char cb, char *q) { gca[ub] = 5; }
void sp_cAuc(int b, unsigned int ub, char cb, char *q) { gca[ub] = gc + gc2; }
void sp_cAud(int b, unsigned int ub, char cb, char *q) { gca[ub] = gc * gc2; }
void sp_cAue(int b, unsigned int ub, char cb, char *q) { gca[ub] = rc(); }
void sp_cAui(int b, unsigned int ub, char cb, char *q) { gca[ub] = gc3 = gc + gc2; }
void sp_cAuj(int b, unsigned int ub, char cb, char *q) { gca[ub] = gc3 = 7; }
void sp_cAuk(int b, unsigned int ub, char cb, char *q) { gca[ub] += gc; }
void sp_cAum(int b, unsigned int ub, char cb, char *q) { gca[ub] ^= gc + gc2; }
void sp_cAup(int b, unsigned int ub, char cb, char *q) { gca[ub]++; }
void sp_cAur(int b, unsigned int ub, char cb, char *q) { gc3 = gca[ub]++; }
void sp_cAca(int b, unsigned int ub, char cb, char *q) { gca[cb] = 5; }
void sp_cAcc(int b, unsigned int ub, char cb, char *q) { gca[cb] = gc + gc2; }
void sp_cAcd(int b, unsigned int ub, char cb, char *q) { gca[cb] = gc * gc2; }
void sp_cAce(int b, unsigned int ub, char cb, char *q) { gca[cb] = rc(); }
void sp_cAci(int b, unsigned int ub, char cb, char *q) { gca[cb] = gc3 = gc + gc2; }
void sp_cAcj(int b, unsigned int ub, char cb, char *q) { gca[cb] = gc3 = 7; }
void sp_cAck(int b, unsigned int ub, char cb, char *q) { gca[cb] += gc; }
void sp_cAcm(int b, unsigned int ub, char cb, char *q) { gca[cb] ^= gc + gc2; }
void sp_cAcp(int b, unsigned int ub, char cb, char *q) { gca[cb]++; }
void sp_cAcr(int b, unsigned int ub, char cb, char *q) { gc3 = gca[cb]++; }
void sp_cAla(int b, unsigned int ub, char cb, char *q) { int t = gi3; gca[t] = 5; }
void sp_cAlb(int b, unsigned int ub, char cb, char *q) { int t = gi3; gca[t] = gc; }
void sp_cAlc(int b, unsigned int ub, char cb, char *q) { int t = gi3; gca[t] = gc + gc2; }
void sp_cAld(int b, unsigned int ub, char cb, char *q) { int t = gi3; gca[t] = gc * gc2; }
void sp_cAle(int b, unsigned int ub, char cb, char *q) { int t = gi3; gca[t] = rc(); }
void sp_cAlf(int b, unsigned int ub, char cb, char *q) { int t = gi3; gca[t] = gc >> cb; }
void sp_cAlg(int b, unsigned int ub, char cb, char *q) { int t = gi3; gca[t] = (gu ? gc : gc2); }
void sp_cAlh(int b, unsigned int ub, char cb, char *q) { int t = gi3; gca[t] = -gcb[2]; }
void sp_cAli(int b, unsigned int ub, char cb, char *q) { int t = gi3; gca[t] = gc3 = gc + gc2; }
void sp_cAlj(int b, unsigned int ub, char cb, char *q) { int t = gi3; gca[t] = gc3 = 7; }
void sp_cAlk(int b, unsigned int ub, char cb, char *q) { int t = gi3; gca[t] += gc; }
void sp_cAlm(int b, unsigned int ub, char cb, char *q) { int t = gi3; gca[t] ^= gc + gc2; }
void sp_cAln(int b, unsigned int ub, char cb, char *q) { int t = gi3; gca[t] -= 9; }
void sp_cAlo(int b, unsigned int ub, char cb, char *q) { int t = gi3; gca[t] <<= 1; }
void sp_cAlp(int b, unsigned int ub, char cb, char *q) { int t = gi3; gca[t]++; }
void sp_cAlq(int b, unsigned int ub, char cb, char *q) { int t = gi3; --gca[t]; }
void sp_cAlr(int b, unsigned int ub, char cb, char *q) { int t = gi3; gc3 = gca[t]++; }
void sp_cAls(int b, unsigned int ub, char cb, char *q) { int t = gi3; gc3 = ++gca[t]; }
void sp_cAlt(int b, unsigned int ub, char cb, char *q) { int t = gi3; gc3 = gca[t]--; }
void sp_cAga(int b, unsigned int ub, char cb, char *q) { gca[gi2] = 5; }
void sp_cAgc(int b, unsigned int ub, char cb, char *q) { gca[gi2] = gc + gc2; }
void sp_cAgd(int b, unsigned int ub, char cb, char *q) { gca[gi2] = gc * gc2; }
void sp_cAge(int b, unsigned int ub, char cb, char *q) { gca[gi2] = rc(); }
void sp_cAgi(int b, unsigned int ub, char cb, char *q) { gca[gi2] = gc3 = gc + gc2; }
void sp_cAgj(int b, unsigned int ub, char cb, char *q) { gca[gi2] = gc3 = 7; }
void sp_cAgk(int b, unsigned int ub, char cb, char *q) { gca[gi2] += gc; }
void sp_cAgm(int b, unsigned int ub, char cb, char *q) { gca[gi2] ^= gc + gc2; }
void sp_cAgp(int b, unsigned int ub, char cb, char *q) { gca[gi2]++; }
void sp_cAgr(int b, unsigned int ub, char cb, char *q) { gc3 = gca[gi2]++; }
void sp_cUka(int b, unsigned int ub, char cb, char *q) { gcu[3] = 5; }
void sp_cUkb(int b, unsigned int ub, char cb, char *q) { gcu[3] = gc; }
void sp_cUkc(int b, unsigned int ub, char cb, char *q) { gcu[3] = gc + gc2; }
void sp_cUkd(int b, unsigned int ub, char cb, char *q) { gcu[3] = gc * gc2; }
void sp_cUke(int b, unsigned int ub, char cb, char *q) { gcu[3] = rc(); }
void sp_cUkf(int b, unsigned int ub, char cb, char *q) { gcu[3] = gc >> cb; }
void sp_cUkg(int b, unsigned int ub, char cb, char *q) { gcu[3] = (gu ? gc : gc2); }
void sp_cUkh(int b, unsigned int ub, char cb, char *q) { gcu[3] = -gcb[2]; }
void sp_cUki(int b, unsigned int ub, char cb, char *q) { gcu[3] = gc3 = gc + gc2; }
void sp_cUkj(int b, unsigned int ub, char cb, char *q) { gcu[3] = gc3 = 7; }
void sp_cUkk(int b, unsigned int ub, char cb, char *q) { gcu[3] += gc; }
void sp_cUkm(int b, unsigned int ub, char cb, char *q) { gcu[3] ^= gc + gc2; }
void sp_cUkn(int b, unsigned int ub, char cb, char *q) { gcu[3] -= 9; }
void sp_cUko(int b, unsigned int ub, char cb, char *q) { gcu[3] <<= 1; }
void sp_cUkp(int b, unsigned int ub, char cb, char *q) { gcu[3]++; }
void sp_cUkq(int b, unsigned int ub, char cb, char *q) { --gcu[3]; }
void sp_cUkr(int b, unsigned int ub, char cb, char *q) { gc3 = gcu[3]++; }
void sp_cUks(int b, unsigned int ub, char cb, char *q) { gc3 = ++gcu[3]; }
void sp_cUkt(int b, unsigned int ub, char cb, char *q) { gc3 = gcu[3]--; }
void sp_cUKa(int b, unsigned int ub, char cb, char *q) { gcu[0x8001u] = 5; }
void sp_cUKb(int b, unsigned int ub, char cb, char *q) { gcu[0x8001u] = gc; }
void sp_cUKc(int b, unsigned int ub, char cb, char *q) { gcu[0x8001u] = gc + gc2; }
void sp_cUKd(int b, unsigned int ub, char cb, char *q) { gcu[0x8001u] = gc * gc2; }
void sp_cUKe(int b, unsigned int ub, char cb, char *q) { gcu[0x8001u] = rc(); }
void sp_cUKf(int b, unsigned int ub, char cb, char *q) { gcu[0x8001u] = gc >> cb; }
void sp_cUKg(int b, unsigned int ub, char cb, char *q) { gcu[0x8001u] = (gu ? gc : gc2); }
void sp_cUKh(int b, unsigned int ub, char cb, char *q) { gcu[0x8001u] = -gcb[2]; }
void sp_cUKi(int b, unsigned int ub, char cb, char *q) { gcu[0x8001u] = gc3 = gc + gc2; }
void sp_cUKj(int b, unsigned int ub, char cb, char *q) { gcu[0x8001u] = gc3 = 7; }
void sp_cUKk(int b, unsigned int ub, char cb, char *q) { gcu[0x8001u] += gc; }
void sp_cUKm(int b, unsigned int ub, char cb, char *q) { gcu[0x8001u] ^= gc + gc2; }
void sp_cUKn(int b, unsigned int ub, char cb, char *q) { gcu[0x8001u] -= 9; }
void sp_cUKo(int b, unsigned int ub, char cb, char *q) { gcu[0x8001u] <<= 1; }
void sp_cUKp(int b, unsigned int ub, char cb, char *q) { gcu[0x8001u]++; }
void sp_cUKq(int b, unsigned int ub, char cb, char *q) { --gcu[0x8001u]; }
void sp_cUKr(int b, unsigned int ub, char cb, char *q) { gc3 = gcu[0x8001u]++; }
void sp_cUKs(int b, unsigned int ub, char cb, char *q) { gc3 = ++gcu[0x8001u]; }
void sp_cUKt(int b, unsigned int ub, char cb, char *q) { gc3 = gcu[0x8001u]--; }
void sp_cUpa(int b, unsigned int ub, char cb, char *q) { gcu[b] = 5; }
void sp_cUpb(int b, unsigned int ub, char cb, char *q) { gcu[b] = gc; }
void sp_cUpc(int b, unsigned int ub, char cb, char *q) { gcu[b] = gc + gc2; }
void sp_cUpd(int b, unsigned int ub, char cb, char *q) { gcu[b] = gc * gc2; }
void sp_cUpe(int b, unsigned int ub, char cb, char *q) { gcu[b] = rc(); }
void sp_cUpf(int b, unsigned int ub, char cb, char *q) { gcu[b] = gc >> cb; }
void sp_cUpg(int b, unsigned int ub, char cb, char *q) { gcu[b] = (gu ? gc : gc2); }
void sp_cUph(int b, unsigned int ub, char cb, char *q) { gcu[b] = -gcb[2]; }
void sp_cUpi(int b, unsigned int ub, char cb, char *q) { gcu[b] = gc3 = gc + gc2; }
void sp_cUpj(int b, unsigned int ub, char cb, char *q) { gcu[b] = gc3 = 7; }
void sp_cUpk(int b, unsigned int ub, char cb, char *q) { gcu[b] += gc; }
void sp_cUpm(int b, unsigned int ub, char cb, char *q) { gcu[b] ^= gc + gc2; }
void sp_cUpn(int b, unsigned int ub, char cb, char *q) { gcu[b] -= 9; }
void sp_cUpo(int b, unsigned int ub, char cb, char *q) { gcu[b] <<= 1; }
void sp_cUpp(int b, unsigned int ub, char cb, char *q) { gcu[b]++; }
void sp_cUpq(int b, unsigned int ub, char cb, char *q) { --gcu[b]; }
void sp_cUpr(int b, unsigned int ub, char cb, char *q) { gc3 = gcu[b]++; }
void sp_cUps(int b, unsigned int ub, char cb, char *q) { gc3 = ++gcu[b]; }
void sp_cUpt(int b, unsigned int ub, char cb, char *q) { gc3 = gcu[b]--; }
void sp_cUca(int b, unsigned int ub, char cb, char *q) { gcu[cb] = 5; }
void sp_cUcc(int b, unsigned int ub, char cb, char *q) { gcu[cb] = gc + gc2; }
void sp_cUcd(int b, unsigned int ub, char cb, char *q) { gcu[cb] = gc * gc2; }
void sp_cUce(int b, unsigned int ub, char cb, char *q) { gcu[cb] = rc(); }
void sp_cUci(int b, unsigned int ub, char cb, char *q) { gcu[cb] = gc3 = gc + gc2; }
void sp_cUcj(int b, unsigned int ub, char cb, char *q) { gcu[cb] = gc3 = 7; }
void sp_cUck(int b, unsigned int ub, char cb, char *q) { gcu[cb] += gc; }
void sp_cUcm(int b, unsigned int ub, char cb, char *q) { gcu[cb] ^= gc + gc2; }
void sp_cUcp(int b, unsigned int ub, char cb, char *q) { gcu[cb]++; }
void sp_cUcr(int b, unsigned int ub, char cb, char *q) { gc3 = gcu[cb]++; }
void sp_cPka(int b, unsigned int ub, char cb, char *q) { gcp[3] = 5; }
void sp_cPkb(int b, unsigned int ub, char cb, char *q) { gcp[3] = gc; }
void sp_cPkc(int b, unsigned int ub, char cb, char *q) { gcp[3] = gc + gc2; }
void sp_cPkd(int b, unsigned int ub, char cb, char *q) { gcp[3] = gc * gc2; }
void sp_cPke(int b, unsigned int ub, char cb, char *q) { gcp[3] = rc(); }
void sp_cPkf(int b, unsigned int ub, char cb, char *q) { gcp[3] = gc >> cb; }
void sp_cPkg(int b, unsigned int ub, char cb, char *q) { gcp[3] = (gu ? gc : gc2); }
void sp_cPkh(int b, unsigned int ub, char cb, char *q) { gcp[3] = -gcb[2]; }
void sp_cPki(int b, unsigned int ub, char cb, char *q) { gcp[3] = gc3 = gc + gc2; }
void sp_cPkj(int b, unsigned int ub, char cb, char *q) { gcp[3] = gc3 = 7; }
void sp_cPkk(int b, unsigned int ub, char cb, char *q) { gcp[3] += gc; }
void sp_cPkm(int b, unsigned int ub, char cb, char *q) { gcp[3] ^= gc + gc2; }
void sp_cPkn(int b, unsigned int ub, char cb, char *q) { gcp[3] -= 9; }
void sp_cPko(int b, unsigned int ub, char cb, char *q) { gcp[3] <<= 1; }
void sp_cPkp(int b, unsigned int ub, char cb, char *q) { gcp[3]++; }
void sp_cPkq(int b, unsigned int ub, char cb, char *q) { --gcp[3]; }
void sp_cPkr(int b, unsigned int ub, char cb, char *q) { gc3 = gcp[3]++; }
void sp_cPks(int b, unsigned int ub, char cb, char *q) { gc3 = ++gcp[3]; }
void sp_cPkt(int b, unsigned int ub, char cb, char *q) { gc3 = gcp[3]--; }
void sp_cPKa(int b, unsigned int ub, char cb, char *q) { gcp[0x8001u] = 5; }
void sp_cPKb(int b, unsigned int ub, char cb, char *q) { gcp[0x8001u] = gc; }
void sp_cPKc(int b, unsigned int ub, char cb, char *q) { gcp[0x8001u] = gc + gc2; }
void sp_cPKd(int b, unsigned int ub, char cb, char *q) { gcp[0x8001u] = gc * gc2; }
void sp_cPKe(int b, unsigned int ub, char cb, char *q) { gcp[0x8001u] = rc(); }
void sp_cPKf(int b, unsigned int ub, char cb, char *q) { gcp[0x8001u] = gc >> cb; }
void sp_cPKg(int b, unsigned int ub, char cb, char *q) { gcp[0x8001u] = (gu ? gc : gc2); }
void sp_cPKh(int b, unsigned int ub, char cb, char *q) { gcp[0x8001u] = -gcb[2]; }
void sp_cPKi(int b, unsigned int ub, char cb, char *q) { gcp[0x8001u] = gc3 = gc + gc2; }
void sp_cPKj(int b, unsigned int ub, char cb, char *q) { gcp[0x8001u] = gc3 = 7; }
void sp_cPKk(int b, unsigned int ub, char cb, char *q) { gcp[0x8001u] += gc; }
void sp_cPKm(int b, unsigned int ub, char cb, char *q) { gcp[0x8001u] ^= gc + gc2; }
void sp_cPKn(int b, unsigned int ub, char cb, char *q) { gcp[0x8001u] -= 9; }
void sp_cPKo(int b, unsigned int ub, char cb, char *q) { gcp[0x8001u] <<= 1; }
void sp_cPKp(int b, unsigned int ub, char cb, char *q) { gcp[0x8001u]++; }
void sp_cPKq(int b, unsigned int ub, char cb, char *q) { --gcp[0x8001u]; }
void sp_cPKr(int b, unsigned int ub, char cb, char *q) { gc3 = gcp[0x8001u]++; }
void sp_cPKs(int b, unsigned int ub, char cb, char *q) { gc3 = ++gcp[0x8001u]; }
void sp_cPKt(int b, unsigned int ub, char cb, char *q) { gc3 = gcp[0x8001u]--; }
void sp_cPpa(int b, unsigned int ub, char cb, char *q) { gcp[b] = 5; }
void sp_cPpb(int b, unsigned int ub, char cb, char *q) { gcp[b] = gc; }
void sp_cPpc(int b, unsigned int ub, char cb, char *q) { gcp[b] = gc + gc2; }
void sp_cPpd(int b, unsigned int ub, char cb, char *q) { gcp[b] = gc * gc2; }
void sp_cPpe(int b, unsigned int ub, char cb, char *q) { gcp[b] = rc(); }
void sp_cPpf(int b, unsigned int ub, char cb, char *q) { gcp[b] = gc >> cb; }
void sp_cPpg(int b, unsigned int ub, char cb, char *q) { gcp[b] = (gu ? gc : gc2); }
void sp_cPph(int b, unsigned int ub, char cb, char *q) { gcp[b] = -gcb[2]; }
void sp_cPpi(int b, unsigned int ub, char cb, char *q) { gcp[b] = gc3 = gc + gc2; }
void sp_cPpj(int b, unsigned int ub, char cb, char *q) { gcp[b] = gc3 = 7; }
void sp_cPpk(int b, unsigned int ub, char cb, char *q) { gcp[b] += gc; }
void sp_cPpm(int b, unsigned int ub, char cb, char *q) { gcp[b] ^= gc + gc2; }
void sp_cPpn(int b, unsigned int ub, char cb, char *q) { gcp[b] -= 9; }
void sp_cPpo(int b, unsigned int ub, char cb, char *q) { gcp[b] <<= 1; }
void sp_cPpp(int b, unsigned int ub, char cb, char *q) { gcp[b]++; }
void sp_cPpq(int b, unsigned int ub, char cb, char *q) { --gcp[b]; }
void sp_cPpr(int b, unsigned int ub, char cb, char *q) { gc3 = gcp[b]++; }
void sp_cPps(int b, unsigned int ub, char cb, char *q) { gc3 = ++gcp[b]; }
void sp_cPpt(int b, unsigned int ub, char cb, char *q) { gc3 = gcp[b]--; }
void sp_cPca(int b, unsigned int ub, char cb, char *q) { gcp[cb] = 5; }
void sp_cPcc(int b, unsigned int ub, char cb, char *q) { gcp[cb] = gc + gc2; }
void sp_cPcd(int b, unsigned int ub, char cb, char *q) { gcp[cb] = gc * gc2; }
void sp_cPce(int b, unsigned int ub, char cb, char *q) { gcp[cb] = rc(); }
void sp_cPci(int b, unsigned int ub, char cb, char *q) { gcp[cb] = gc3 = gc + gc2; }
void sp_cPcj(int b, unsigned int ub, char cb, char *q) { gcp[cb] = gc3 = 7; }
void sp_cPck(int b, unsigned int ub, char cb, char *q) { gcp[cb] += gc; }
void sp_cPcm(int b, unsigned int ub, char cb, char *q) { gcp[cb] ^= gc + gc2; }
void sp_cPcp(int b, unsigned int ub, char cb, char *q) { gcp[cb]++; }
void sp_cPcr(int b, unsigned int ub, char cb, char *q) { gc3 = gcp[cb]++; }
void sp_cPla(int b, unsigned int ub, char cb, char *q) { int t = gi3; gcp[t] = 5; }
void sp_cPlb(int b, unsigned int ub, char cb, char *q) { int t = gi3; gcp[t] = gc; }
void sp_cPlc(int b, unsigned int ub, char cb, char *q) { int t = gi3; gcp[t] = gc + gc2; }
void sp_cPld(int b, unsigned int ub, char cb, char *q) { int t = gi3; gcp[t] = gc * gc2; }
void sp_cPle(int b, unsigned int ub, char cb, char *q) { int t = gi3; gcp[t] = rc(); }
void sp_cPlf(int b, unsigned int ub, char cb, char *q) { int t = gi3; gcp[t] = gc >> cb; }
void sp_cPlg(int b, unsigned int ub, char cb, char *q) { int t = gi3; gcp[t] = (gu ? gc : gc2); }
void sp_cPlh(int b, unsigned int ub, char cb, char *q) { int t = gi3; gcp[t] = -gcb[2]; }
void sp_cPli(int b, unsigned int ub, char cb, char *q) { int t = gi3; gcp[t] = gc3 = gc + gc2; }
void sp_cPlj(int b, unsigned int ub, char cb, char *q) { int t = gi3; gcp[t] = gc3 = 7; }
void sp_cPlk(int b, unsigned int ub, char cb, char *q) { int t = gi3; gcp[t] += gc; }
void sp_cPlm(int b, unsigned int ub, char cb, char *q) { int t = gi3; gcp[t] ^= gc + gc2; }
void sp_cPln(int b, unsigned int ub, char cb, char *q) { int t = gi3; gcp[t] -= 9; }
void sp_cPlo(int b, unsigned int ub, char cb, char *q) { int t = gi3; gcp[t] <<= 1; }
void sp_cPlp(int b, unsigned int ub, char cb, char *q) { int t = gi3; gcp[t]++; }
void sp_cPlq(int b, unsigned int ub, char cb, char *q) { int t = gi3; --gcp[t]; }
void sp_cPlr(int b, unsigned int ub, char cb, char *q) { int t = gi3; gc3 = gcp[t]++; }
void sp_cPls(int b, unsigned int ub, char cb, char *q) { int t = gi3; gc3 = ++gcp[t]; }
void sp_cPlt(int b, unsigned int ub, char cb, char *q) { int t = gi3; gc3 = gcp[t]--; }
void sp_cPna(int b, unsigned int ub, char cb, char *q) { gcp[-2] = 5; }
void sp_cPnc(int b, unsigned int ub, char cb, char *q) { gcp[-2] = gc + gc2; }
void sp_cPnd(int b, unsigned int ub, char cb, char *q) { gcp[-2] = gc * gc2; }
void sp_cPne(int b, unsigned int ub, char cb, char *q) { gcp[-2] = rc(); }
void sp_cPni(int b, unsigned int ub, char cb, char *q) { gcp[-2] = gc3 = gc + gc2; }
void sp_cPnj(int b, unsigned int ub, char cb, char *q) { gcp[-2] = gc3 = 7; }
void sp_cPnk(int b, unsigned int ub, char cb, char *q) { gcp[-2] += gc; }
void sp_cPnm(int b, unsigned int ub, char cb, char *q) { gcp[-2] ^= gc + gc2; }
void sp_cPnp(int b, unsigned int ub, char cb, char *q) { gcp[-2]++; }
void sp_cPnr(int b, unsigned int ub, char cb, char *q) { gc3 = gcp[-2]++; }
void sp_cQka(int b, unsigned int ub, char cb, char *q) { q[3] = 5; }
void sp_cQkb(int b, unsigned int ub, char cb, char *q) { q[3] = gc; }
void sp_cQkc(int b, unsigned int ub, char cb, char *q) { q[3] = gc + gc2; }
void sp_cQkd(int b, unsigned int ub, char cb, char *q) { q[3] = gc * gc2; }
void sp_cQke(int b, unsigned int ub, char cb, char *q) { q[3] = rc(); }
void sp_cQkf(int b, unsigned int ub, char cb, char *q) { q[3] = gc >> cb; }
void sp_cQkg(int b, unsigned int ub, char cb, char *q) { q[3] = (gu ? gc : gc2); }
void sp_cQkh(int b, unsigned int ub, char cb, char *q) { q[3] = -gcb[2]; }
void sp_cQki(int b, unsigned int ub, char cb, char *q) { q[3] = gc3 = gc + gc2; }
void sp_cQkj(int b, unsigned int ub, char cb, char *q) { q[3] = gc3 = 7; }
void sp_cQkk(int b, unsigned int ub, char cb, char *q) { q[3] += gc; }
void sp_cQkm(int b, unsigned int ub, char cb, char *q) { q[3] ^= gc + gc2; }
void sp_cQkn(int b, unsigned int ub, char cb, char *q) { q[3] -= 9; }
void sp_cQko(int b, unsigned int ub, char cb, char *q) { q[3] <<= 1; }
void sp_cQkp(int b, unsigned int ub, char cb, char *q) { q[3]++; }
void sp_cQkq(int b, unsigned int ub, char cb, char *q) { --q[3]; }
void sp_cQkr(int b, unsigned int ub, char cb, char *q) { gc3 = q[3]++; }
void sp_cQks(int b, unsigned int ub, char cb, char *q) { gc3 = ++q[3]; }
void sp_cQkt(int b, unsigned int ub, char cb, char *q) { gc3 = q[3]--; }
void sp_cQKa(int b, unsigned int ub, char cb, char *q) { q[0x8001u] = 5; }
void sp_cQKb(int b, unsigned int ub, char cb, char *q) { q[0x8001u] = gc; }
void sp_cQKc(int b, unsigned int ub, char cb, char *q) { q[0x8001u] = gc + gc2; }
void sp_cQKd(int b, unsigned int ub, char cb, char *q) { q[0x8001u] = gc * gc2; }
void sp_cQKe(int b, unsigned int ub, char cb, char *q) { q[0x8001u] = rc(); }
void sp_cQKf(int b, unsigned int ub, char cb, char *q) { q[0x8001u] = gc >> cb; }
void sp_cQKg(int b, unsigned int ub, char cb, char *q) { q[0x8001u] = (gu ? gc : gc2); }
void sp_cQKh(int b, unsigned int ub, char cb, char *q) { q[0x8001u] = -gcb[2]; }
void sp_cQKi(int b, unsigned int ub, char cb, char *q) { q[0x8001u] = gc3 = gc + gc2; }
void sp_cQKj(int b, unsigned int ub, char cb, char *q) { q[0x8001u] = gc3 = 7; }
void sp_cQKk(int b, unsigned int ub, char cb, char *q) { q[0x8001u] += gc; }
void sp_cQKm(int b, unsigned int ub, char cb, char *q) { q[0x8001u] ^= gc + gc2; }
void sp_cQKn(int b, unsigned int ub, char cb, char *q) { q[0x8001u] -= 9; }
void sp_cQKo(int b, unsigned int ub, char cb, char *q) { q[0x8001u] <<= 1; }
void sp_cQKp(int b, unsigned int ub, char cb, char *q) { q[0x8001u]++; }
void sp_cQKq(int b, unsigned int ub, char cb, char *q) { --q[0x8001u]; }
void sp_cQKr(int b, unsigned int ub, char cb, char *q) { gc3 = q[0x8001u]++; }
void sp_cQKs(int b, unsigned int ub, char cb, char *q) { gc3 = ++q[0x8001u]; }
void sp_cQKt(int b, unsigned int ub, char cb, char *q) { gc3 = q[0x8001u]--; }
void sp_cQpa(int b, unsigned int ub, char cb, char *q) { q[b] = 5; }
void sp_cQpb(int b, unsigned int ub, char cb, char *q) { q[b] = gc; }
void sp_cQpc(int b, unsigned int ub, char cb, char *q) { q[b] = gc + gc2; }
void sp_cQpd(int b, unsigned int ub, char cb, char *q) { q[b] = gc * gc2; }
void sp_cQpe(int b, unsigned int ub, char cb, char *q) { q[b] = rc(); }
void sp_cQpf(int b, unsigned int ub, char cb, char *q) { q[b] = gc >> cb; }
void sp_cQpg(int b, unsigned int ub, char cb, char *q) { q[b] = (gu ? gc : gc2); }
void sp_cQph(int b, unsigned int ub, char cb, char *q) { q[b] = -gcb[2]; }
void sp_cQpi(int b, unsigned int ub, char cb, char *q) { q[b] = gc3 = gc + gc2; }
void sp_cQpj(int b, unsigned int ub, char cb, char *q) { q[b] = gc3 = 7; }
void sp_cQpk(int b, unsigned int ub, char cb, char *q) { q[b] += gc; }
void sp_cQpm(int b, unsigned int ub, char cb, char *q) { q[b] ^= gc + gc2; }
void sp_cQpn(int b, unsigned int ub, char cb, char *q) { q[b] -= 9; }
void sp_cQpo(int b, unsigned int ub, char cb, char *q) { q[b] <<= 1; }
void sp_cQpp(int b, unsigned int ub, char cb, char *q) { q[b]++; }
void sp_cQpq(int b, unsigned int ub, char cb, char *q) { --q[b]; }
void sp_cQpr(int b, unsigned int ub, char cb, char *q) { gc3 = q[b]++; }
void sp_cQps(int b, unsigned int ub, char cb, char *q) { gc3 = ++q[b]; }
void sp_cQpt(int b, unsigned int ub, char cb, char *q) { gc3 = q[b]--; }
void sp_cQca(int b, unsigned int ub, char cb, char *q) { q[cb] = 5; }
void sp_cQcc(int b, unsigned int ub, char cb, char *q) { q[cb] = gc + gc2; }
void sp_cQcd(int b, unsigned int ub, char cb, char *q) { q[cb] = gc * gc2; }
void sp_cQce(int b, unsigned int ub, char cb, char *q) { q[cb] = rc(); }
void sp_cQci(int b, unsigned int ub, char cb, char *q) { q[cb] = gc3 = gc + gc2; }
void sp_cQcj(int b, unsigned int ub, char cb, char *q) { q[cb] = gc3 = 7; }
void sp_cQck(int b, unsigned int ub, char cb, char *q) { q[cb] += gc; }
void sp_cQcm(int b, unsigned int ub, char cb, char *q) { q[cb] ^= gc + gc2; }
void sp_cQcp(int b, unsigned int ub, char cb, char *q) { q[cb]++; }
void sp_cQcr(int b, unsigned int ub, char cb, char *q) { gc3 = q[cb]++; }
void sp_cQna(int b, unsigned int ub, char cb, char *q) { q[-2] = 5; }
void sp_cQnc(int b, unsigned int ub, char cb, char *q) { q[-2] = gc + gc2; }
void sp_cQnd(int b, unsigned int ub, char cb, char *q) { q[-2] = gc * gc2; }
void sp_cQne(int b, unsigned int ub, char cb, char *q) { q[-2] = rc(); }
void sp_cQni(int b, unsigned int ub, char cb, char *q) { q[-2] = gc3 = gc + gc2; }
void sp_cQnj(int b, unsigned int ub, char cb, char *q) { q[-2] = gc3 = 7; }
void sp_cQnk(int b, unsigned int ub, char cb, char *q) { q[-2] += gc; }
void sp_cQnm(int b, unsigned int ub, char cb, char *q) { q[-2] ^= gc + gc2; }
void sp_cQnp(int b, unsigned int ub, char cb, char *q) { q[-2]++; }
void sp_cQnr(int b, unsigned int ub, char cb, char *q) { gc3 = q[-2]++; }
void sp_cSka(int b, unsigned int ub, char cb, char *q) { gps->mca[3] = 5; }
void sp_cSkb(int b, unsigned int ub, char cb, char *q) { gps->mca[3] = gc; }
void sp_cSkc(int b, unsigned int ub, char cb, char *q) { gps->mca[3] = gc + gc2; }
void sp_cSkd(int b, unsigned int ub, char cb, char *q) { gps->mca[3] = gc * gc2; }
void sp_cSke(int b, unsigned int ub, char cb, char *q) { gps->mca[3] = rc(); }
void sp_cSkf(int b, unsigned int ub, char cb, char *q) { gps->mca[3] = gc >> cb; }
void sp_cSkg(int b, unsigned int ub, char cb, char *q) { gps->mca[3] = (gu ? gc : gc2); }
void sp_cSkh(int b, unsigned int ub, char cb, char *q) { gps->mca[3] = -gcb[2]; }
void sp_cSki(int b, unsigned int ub, char cb, char *q) { gps->mca[3] = gc3 = gc + gc2; }
void sp_cSkj(int b, unsigned int ub, char cb, char *q) { gps->mca[3] = gc3 = 7; }
void sp_cSkk(int b, unsigned int ub, char cb, char *q) { gps->mca[3] += gc; }
void sp_cSkm(int b, unsigned int ub, char cb, char *q) { gps->mca[3] ^= gc + gc2; }
void sp_cSkn(int b, unsigned int ub, char cb, char *q) { gps->mca[3] -= 9; }
void sp_cSko(int b, unsigned int ub, char cb, char *q) { gps->mca[3] <<= 1; }
void sp_cSkp(int b, unsigned int ub, char cb, char *q) { gps->mca[3]++; }
void sp_cSkq(int b, unsigned int ub, char cb, char *q) { --gps->mca[3]; }
void sp_cSkr(int b, unsigned int ub, char cb, char *q) { gc3 = gps->mca[3]++; }
void sp_cSks(int b, unsigned int ub, char cb, char *q) { gc3 = ++gps->mca[3]; }
void sp_cSkt(int b, unsigned int ub, char cb, char *q) { gc3 = gps->mca[3]--; }
void sp_cSpa(int b, unsigned int ub, char cb, char *q) { gps->mca[b] = 5; }
void sp_cSpb(int b, unsigned int ub, char cb, char *q) { gps->mca[b] = gc; }
void sp_cSpc(int b, unsigned int ub, char cb, char *q) { gps->mca[b] = gc + gc2; }
void sp_cSpd(int b, unsigned int ub, char cb, char *q) { gps->mca[b] = gc * gc2; }
void sp_cSpe(int b, unsigned int ub, char cb, char *q) { gps->mca[b] = rc(); }
void sp_cSpf(int b, unsigned int ub, char cb, char *q) { gps->mca[b] = gc >> cb; }
void sp_cSpg(int b, unsigned int ub, char cb, char *q) { gps->mca[b] = (gu ? gc : gc2); }
void sp_cSph(int b, unsigned int ub, char cb, char *q) { gps->mca[b] = -gcb[2]; }
void sp_cSpi(int b, unsigned int ub, char cb, char *q) { gps->mca[b] = gc3 = gc + gc2; }
void sp_cSpj(int b, unsigned int ub, char cb, char *q) { gps->mca[b] = gc3 = 7; }
void sp_cSpk(int b, unsigned int ub, char cb, char *q) { gps->mca[b] += gc; }
void sp_cSpm(int b, unsigned int ub, char cb, char *q) { gps->mca[b] ^= gc + gc2; }
void sp_cSpn(int b, unsigned int ub, char cb, char *q) { gps->mca[b] -= 9; }
void sp_cSpo(int b, unsigned int ub, char cb, char *q) { gps->mca[b] <<= 1; }
void sp_cSpp(int b, unsigned int ub, char cb, char *q) { gps->mca[b]++; }
void sp_cSpq(int b, unsigned int ub, char cb, char *q) { --gps->mca[b]; }
void sp_cSpr(int b, unsigned int ub, char cb, char *q) { gc3 = gps->mca[b]++; }
void sp_cSps(int b, unsigned int ub, char cb, char *q) { gc3 = ++gps->mca[b]; }
void sp_cSpt(int b, unsigned int ub, char cb, char *q) { gc3 = gps->mca[b]--; }
void sp_cD_a(int b, unsigned int ub, char cb, char *q) { *gcp = 5; }
void sp_cD_b(int b, unsigned int ub, char cb, char *q) { *gcp = gc; }
void sp_cD_c(int b, unsigned int ub, char cb, char *q) { *gcp = gc + gc2; }
void sp_cD_d(int b, unsigned int ub, char cb, char *q) { *gcp = gc * gc2; }
void sp_cD_e(int b, unsigned int ub, char cb, char *q) { *gcp = rc(); }
void sp_cD_f(int b, unsigned int ub, char cb, char *q) { *gcp = gc >> cb; }
void sp_cD_g(int b, unsigned int ub, char cb, char *q) { *gcp = (gu ? gc : gc2); }
void sp_cD_h(int b, unsigned int ub, char cb, char *q) { *gcp = -gcb[2]; }
void sp_cD_i(int b, unsigned int ub, char cb, char *q) { *gcp = gc3 = gc + gc2; }
void sp_cD_j(int b, unsigned int ub, char cb, char *q) { *gcp = gc3 = 7; }
void sp_cD_k(int b, unsigned int ub, char cb, char *q) { *gcp += gc; }
void sp_cD_m(int b, unsigned int ub, char cb, char *q) { *gcp ^= gc + gc2; }
void sp_cD_n(int b, unsigned int ub, char cb, char *q) { *gcp -= 9; }
void sp_cD_o(int b, unsigned int ub, char cb, char *q) { *gcp <<= 1; }
void sp_cD_p(int b, unsigned int ub, char cb, char *q) { *gcp++; }
void sp_cD_q(int b, unsigned int ub, char cb, char *q) { --*gcp; }
void sp_cD_r(int b, unsigned int ub, char cb, char *q) { gc3 = *gcp++; }
void sp_cD_s(int b, unsigned int ub, char cb, char *q) { gc3 = ++*gcp; }
void sp_cD_t(int b, unsigned int ub, char cb, char *q) { gc3 = *gcp--; }
void sp_cE_a(int b, unsigned int ub, char cb, char *q) { *q = 5; }
void sp_cE_b(int b, unsigned int ub, char cb, char *q) { *q = gc; }
void sp_cE_c(int b, unsigned int ub, char cb, char *q) { *q = gc + gc2; }
void sp_cE_d(int b, unsigned int ub, char cb, char *q) { *q = gc * gc2; }
void sp_cE_e(int b, unsigned int ub, char cb, char *q) { *q = rc(); }
void sp_cE_f(int b, unsigned int ub, char cb, char *q) { *q = gc >> cb; }
void sp_cE_g(int b, unsigned int ub, char cb, char *q) { *q = (gu ? gc : gc2); }
void sp_cE_h(int b, unsigned int ub, char cb, char *q) { *q = -gcb[2]; }
void sp_cE_i(int b, unsigned int ub, char cb, char *q) { *q = gc3 = gc + gc2; }
void sp_cE_j(int b, unsigned int ub, char cb, char *q) { *q = gc3 = 7; }
void sp_cE_k(int b, unsigned int ub, char cb, char *q) { *q += gc; }
void sp_cE_m(int b, unsigned int ub, char cb, char *q) { *q ^= gc + gc2; }
void sp_cE_n(int b, unsigned int ub, char cb, char *q) { *q -= 9; }
void sp_cE_o(int b, unsigned int ub, char cb, char *q) { *q <<= 1; }
void sp_cE_p(int b, unsigned int ub, char cb, char *q) { *q++; }
void sp_cE_q(int b, unsigned int ub, char cb, char *q) { --*q; }
void sp_cE_r(int b, unsigned int ub, char cb, char *q) { gc3 = *q++; }
void sp_cE_s(int b, unsigned int ub, char cb, char *q) { gc3 = ++*q; }
void sp_cE_t(int b, unsigned int ub, char cb, char *q) { gc3 = *q--; }
void sp_iAka(int b, unsigned int ub, char cb, int *q) { gia[3] = 5; }
void sp_iAkb(int b, unsigned int ub, char cb, int *q) { gia[3] = gi; }
void sp_iAkc(int b, unsigned int ub, char cb, int *q) { gia[3] = gi + gi2; }
void sp_iAkd(int b, unsigned int ub, char cb, int *q) { gia[3] = gi * gi2; }
void sp_iAke(int b, unsigned int ub, char cb, int *q) { gia[3] = ri(); }
void sp_iAkf(int b, unsigned int ub, char cb, int *q) { gia[3] = gi >> cb; }
void sp_iAkg(int b, unsigned int ub, char cb, int *q) { gia[3] = (gu ? gi : gi2); }
void sp_iAkh(int b, unsigned int ub, char cb, int *q) { gia[3] = -gib[2]; }
void sp_iAki(int b, unsigned int ub, char cb, int *q) { gia[3] = gi3 = gi + gi2; }
void sp_iAkj(int b, unsigned int ub, char cb, int *q) { gia[3] = gi3 = 7; }
void sp_iAkk(int b, unsigned int ub, char cb, int *q) { gia[3] += gi; }
void sp_iAkm(int b, unsigned int ub, char cb, int *q) { gia[3] ^= gi + gi2; }
void sp_iAkn(int b, unsigned int ub, char cb, int *q) { gia[3] -= 9; }
void sp_iAko(int b, unsigned int ub, char cb, int *q) { gia[3] <<= 1; }
void sp_iAkp(int b, unsigned int ub, char cb, int *q) { gia[3]++; }
void sp_iAkq(int b, unsigned int ub, char cb, int *q) { --gia[3]; }
void sp_iAkr(int b, unsigned int ub, char cb, int *q) { gi3 = gia[3]++; }
void sp_iAks(int b, unsigned int ub, char cb, int *q) { gi3 = ++gia[3]; }
void sp_iAkt(int b, unsigned int ub, char cb, int *q) { gi3 = gia[3]--; }
void sp_iAKa(int b, unsigned int ub, char cb, int *q) { gia[0x8001u] = 5; }
void sp_iAKb(int b, unsigned int ub, char cb, int *q) { gia[0x8001u] = gi; }
void sp_iAKc(int b, unsigned int ub, char cb, int *q) { gia[0x8001u] = gi + gi2; }
void sp_iAKd(int b, unsigned int ub, char cb, int *q) { gia[0x8001u] = gi * gi2; }
void sp_iAKe(int b, unsigned int ub, char cb, int *q) { gia[0x8001u] = ri(); }
void sp_iAKf(int b, unsigned int ub, char cb, int *q) { gia[0x8001u] = gi >> cb; }
void sp_iAKg(int b, unsigned int ub, char cb, int *q) { gia[0x8001u] = (gu ? gi : gi2); }
void sp_iAKh(int b, unsigned int ub, char cb, int *q) { gia[0x8001u] = -gib[2]; }
void sp_iAKi(int b, unsigned int ub, char cb, int *q) { gia[0x8001u] = gi3 = gi + gi2; }
void sp_iAKj(int b, unsigned int ub, char cb, int *q) { gia[0x8001u] = gi3 = 7; }
void sp_iAKk(int b, unsigned int ub, char cb, int *q) { gia[0x8001u] += gi; }
void sp_iAKm(int b, unsigned int ub, char cb, int *q) { gia[0x8001u] ^= gi + gi2; }
void sp_iAKn(int b, unsigned int ub, char cb, int *q) { gia[0x8001u] -= 9; }
void sp_iAKo(int b, unsigned int ub, char cb, int *q) { gia[0x8001u] <<= 1; }
void sp_iAKp(int b, unsigned int ub, char cb, int *q) { gia[0x8001u]++; }
void sp_iAKq(int b, unsigned int ub, char cb, int *q) { --gia[0x8001u]; }
void sp_iAKr(int b, unsigned int ub, char cb, int *q) { gi3 = gia[0x8001u]++; }
void sp_iAKs(int b, unsigned int ub, char cb, int *q) { gi3 = ++gia[0x8001u]; }
void sp_iAKt(int b, unsigned int ub, char cb, int *q) { gi3 = gia[0x8001u]--; }
void sp_iApa(int b, unsigned int ub, char cb, int *q) { gia[b] = 5; }
void sp_iApb(int b, unsigned int ub, char cb, int *q) { gia[b] = gi; }
void sp_iApc(int b, unsigned int ub, char cb, int *q) { gia[b] = gi + gi2; }
void sp_iApd(int b, unsigned int ub, char cb, int *q) { gia[b] = gi * gi2; }
void sp_iApe(int b, unsigned int ub, char cb, int *q) { gia[b] = ri(); }
void sp_iApf(int b, unsigned int ub, char cb, int *q) { gia[b] = gi >> cb; }
void sp_iApg(int b, unsigned int ub, char cb, int *q) { gia[b] = (gu ? gi : gi2); }
void sp_iAph(int b, unsigned int ub, char cb, int *q) { gia[b] = -gib[2]; }
void sp_iApi(int b, unsigned int ub, char cb, int *q) { gia[b] = gi3 = gi + gi2; }
void sp_iApj(int b, unsigned int ub, char cb, int *q) { gia[b] = gi3 = 7; }
void sp_iApk(int b, unsigned int ub, char cb, int *q) { gia[b] += gi; }
void sp_iApm(int b, unsigned int ub, char cb, int *q) { gia[b] ^= gi + gi2; }
void sp_iApn(int b, unsigned int ub, char cb, int *q) { gia[b] -= 9; }
void sp_iApo(int b, unsigned int ub, char cb, int *q) { gia[b] <<= 1; }
void sp_iApp(int b, unsigned int ub, char cb, int *q) { gia[b]++; }
void sp_iApq(int b, unsigned int ub, char cb, int *q) { --gia[b]; }
void sp_iApr(int b, unsigned int ub, char cb, int *q) { gi3 = gia[b]++; }
void sp_iAps(int b, unsigned int ub, char cb, int *q) { gi3 = ++gia[b]; }
void sp_iApt(int b, unsigned int ub, char cb, int *q) { gi3 = gia[b]--; }
void sp_iAua(int b, unsigned int ub, char cb, int *q) { gia[ub] = 5; }
void sp_iAuc(int b, unsigned int ub, char cb, int *q) { gia[ub] = gi + gi2; }
void sp_iAud(int b, unsigned int ub, char cb, int *q) { gia[ub] = gi * gi2; }
void sp_iAue(int b, unsigned int ub, char cb, int *q) { gia[ub] = ri(); }
void sp_iAui(int b, unsigned int ub, char cb, int *q) { gia[ub] = gi3 = gi + gi2; }
void sp_iAuj(int b, unsigned int ub, char cb, int *q) { gia[ub] = gi3 = 7; }
void sp_iAuk(int b, unsigned int ub, char cb, int *q) { gia[ub] += gi; }
void sp_iAum(int b, unsigned int ub, char cb, int *q) { gia[ub] ^= gi + gi2; }
void sp_iAup(int b, unsigned int ub, char cb, int *q) { gia[ub]++; }
void sp_iAur(int b, unsigned int ub, char cb, int *q) { gi3 = gia[ub]++; }
void sp_iAca(int b, unsigned int ub, char cb, int *q) { gia[cb] = 5; }
void sp_iAcc(int b, unsigned int ub, char cb, int *q) { gia[cb] = gi + gi2; }
void sp_iAcd(int b, unsigned int ub, char cb, int *q) { gia[cb] = gi * gi2; }
void sp_iAce(int b, unsigned int ub, char cb, int *q) { gia[cb] = ri(); }
void sp_iAci(int b, unsigned int ub, char cb, int *q) { gia[cb] = gi3 = gi + gi2; }
void sp_iAcj(int b, unsigned int ub, char cb, int *q) { gia[cb] = gi3 = 7; }
void sp_iAck(int b, unsigned int ub, char cb, int *q) { gia[cb] += gi; }
void sp_iAcm(int b, unsigned int ub, char cb, int *q) { gia[cb] ^= gi + gi2; }
void sp_iAcp(int b, unsigned int ub, char cb, int *q) { gia[cb]++; }
void sp_iAcr(int b, unsigned int ub, char cb, int *q) { gi3 = gia[cb]++; }
void sp_iAla(int b, unsigned int ub, char cb, int *q) { int t = gi3; gia[t] = 5; }
void sp_iAlb(int b, unsigned int ub, char cb, int *q) { int t = gi3; gia[t] = gi; }
void sp_iAlc(int b, unsigned int ub, char cb, int *q) { int t = gi3; gia[t] = gi + gi2; }
void sp_iAld(int b, unsigned int ub, char cb, int *q) { int t = gi3; gia[t] = gi * gi2; }
void sp_iAle(int b, unsigned int ub, char cb, int *q) { int t = gi3; gia[t] = ri(); }
void sp_iAlf(int b, unsigned int ub, char cb, int *q) { int t = gi3; gia[t] = gi >> cb; }
void sp_iAlg(int b, unsigned int ub, char cb, int *q) { int t = gi3; gia[t] = (gu ? gi : gi2); }
void sp_iAlh(int b, unsigned int ub, char cb, int *q) { int t = gi3; gia[t] = -gib[2]; }
void sp_iAli(int b, unsigned int ub, char cb, int *q) { int t = gi3; gia[t] = gi3 = gi + gi2; }
void sp_iAlj(int b, unsigned int ub, char cb, int *q) { int t = gi3; gia[t] = gi3 = 7; }
void sp_iAlk(int b, unsigned int ub, char cb, int *q) { int t = gi3; gia[t] += gi; }
void sp_iAlm(int b, unsigned int ub, char cb, int *q) { int t = gi3; gia[t] ^= gi + gi2; }
void sp_iAln(int b, unsigned int ub, char cb, int *q) { int t = gi3; gia[t] -= 9; }
void sp_iAlo(int b, unsigned int ub, char cb, int *q) { int t = gi3; gia[t] <<= 1; }
void sp_iAlp(int b, unsigned int ub, char cb, int *q) { int t = gi3; gia[t]++; }
void sp_iAlq(int b, unsigned int ub, char cb, int *q) { int t = gi3; --gia[t]; }
void sp_iAlr(int b, unsigned int ub, char cb, int *q) { int t = gi3; gi3 = gia[t]++; }
void sp_iAls(int b, unsigned int ub, char cb, int *q) { int t = gi3; gi3 = ++gia[t]; }
void sp_iAlt(int b, unsigned int ub, char cb, int *q) { int t = gi3; gi3 = gia[t]--; }
void sp_iAga(int b, unsigned int ub, char cb, int *q) { gia[gi2] = 5; }
void sp_iAgc(int b, unsigned int ub, char cb, int *q) { gia[gi2] = gi + gi2; }
void sp_iAgd(int b, unsigned int ub, char cb, int *q) { gia[gi2] = gi * gi2; }
void sp_iAge(int b, unsigned int ub, char cb, int *q) { gia[gi2] = ri(); }
void sp_iAgi(int b, unsigned int ub, char cb, int *q) { gia[gi2] = gi3 = gi + gi2; }
void sp_iAgj(int b, unsigned int ub, char cb, int *q) { gia[gi2] = gi3 = 7; }
void sp_iAgk(int b, unsigned int ub, char cb, int *q) { gia[gi2] += gi; }
void sp_iAgm(int b, unsigned int ub, char cb, int *q) { gia[gi2] ^= gi + gi2; }
void sp_iAgp(int b, unsigned int ub, char cb, int *q) { gia[gi2]++; }
void sp_iAgr(int b, unsigned int ub, char cb, int *q) { gi3 = gia[gi2]++; }
void sp_iUka(int b, unsigned int ub, char cb, int *q) { giu[3] = 5; }
void sp_iUkb(int b, unsigned int ub, char cb, int *q) { giu[3] = gi; }
void sp_iUkc(int b, unsigned int ub, char cb, int *q) { giu[3] = gi + gi2; }
void sp_iUkd(int b, unsigned int ub, char cb, int *q) { giu[3] = gi * gi2; }
void sp_iUke(int b, unsigned int ub, char cb, int *q) { giu[3] = ri(); }
void sp_iUkf(int b, unsigned int ub, char cb, int *q) { giu[3] = gi >> cb; }
void sp_iUkg(int b, unsigned int ub, char cb, int *q) { giu[3] = (gu ? gi : gi2); }
void sp_iUkh(int b, unsigned int ub, char cb, int *q) { giu[3] = -gib[2]; }
void sp_iUki(int b, unsigned int ub, char cb, int *q) { giu[3] = gi3 = gi + gi2; }
void sp_iUkj(int b, unsigned int ub, char cb, int *q) { giu[3] = gi3 = 7; }
void sp_iUkk(int b, unsigned int ub, char cb, int *q) { giu[3] += gi; }
void sp_iUkm(int b, unsigned int ub, char cb, int *q) { giu[3] ^= gi + gi2; }
void sp_iUkn(int b, unsigned int ub, char cb, int *q) { giu[3] -= 9; }
void sp_iUko(int b, unsigned int ub, char cb, int *q) { giu[3] <<= 1; }
void sp_iUkp(int b, unsigned int ub, char cb, int *q) { giu[3]++; }
void sp_iUkq(int b, unsigned int ub, char cb, int *q) { --giu[3]; }
void sp_iUkr(int b, unsigned int ub, char cb, int *q) { gi3 = giu[3]++; }
void sp_iUks(int b, unsigned int ub, char cb, int *q) { gi3 = ++giu[3]; }
void sp_iUkt(int b, unsigned int ub, char cb, int *q) { gi3 = giu[3]--; }
void sp_iUKa(int b, unsigned int ub, char cb, int *q) { giu[0x8001u] = 5; }
void sp_iUKb(int b, unsigned int ub, char cb, int *q) { giu[0x8001u] = gi; }
void sp_iUKc(int b, unsigned int ub, char cb, int *q) { giu[0x8001u] = gi + gi2; }
void sp_iUKd(int b, unsigned int ub, char cb, int *q) { giu[0x8001u] = gi * gi2; }
void sp_iUKe(int b, unsigned int ub, char cb, int *q) { giu[0x8001u] = ri(); }
void sp_iUKf(int b, unsigned int ub, char cb, int *q) { giu[0x8001u] = gi >> cb; }
void sp_iUKg(int b, unsigned int ub, char cb, int *q) { giu[0x8001u] = (gu ? gi : gi2); }
void sp_iUKh(int b, unsigned int ub, char cb, int *q) { giu[0x8001u] = -gib[2]; }
void sp_iUKi(int b, unsigned int ub, char cb, int *q) { giu[0x8001u] = gi3 = gi + gi2; }
void sp_iUKj(int b, unsigned int ub, char cb, int *q) { giu[0x8001u] = gi3 = 7; }
void sp_iUKk(int b, unsigned int ub, char cb, int *q) { giu[0x8001u] += gi; }
void sp_iUKm(int b, unsigned int ub, char cb, int *q) { giu[0x8001u] ^= gi + gi2; }
void sp_iUKn(int b, unsigned int ub, char cb, int *q) { giu[0x8001u] -= 9; }
void sp_iUKo(int b, unsigned int ub, char cb, int *q) { giu[0x8001u] <<= 1; }
void sp_iUKp(int b, unsigned int ub, char cb, int *q) { giu[0x8001u]++; }
void sp_iUKq(int b, unsigned int ub, char cb, int *q) { --giu[0x8001u]; }
void sp_iUKr(int b, unsigned int ub, char cb, int *q) { gi3 = giu[0x8001u]++; }
void sp_iUKs(int b, unsigned int ub, char cb, int *q) { gi3 = ++giu[0x8001u]; }
void sp_iUKt(int b, unsigned int ub, char cb, int *q) { gi3 = giu[0x8001u]--; }
void sp_iUpa(int b, unsigned int ub, char cb, int *q) { giu[b] = 5; }
void sp_iUpb(int b, unsigned int ub, char cb, int *q) { giu[b] = gi; }
void sp_iUpc(int b, unsigned int ub, char cb, int *q) { giu[b] = gi + gi2; }
void sp_iUpd(int b, unsigned int ub, char cb, int *q) { giu[b] = gi * gi2; }
void sp_iUpe(int b, unsigned int ub, char cb, int *q) { giu[b] = ri(); }
void sp_iUpf(int b, unsigned int ub, char cb, int *q) { giu[b] = gi >> cb; }
void sp_iUpg(int b, unsigned int ub, char cb, int *q) { giu[b] = (gu ? gi : gi2); }
void sp_iUph(int b, unsigned int ub, char cb, int *q) { giu[b] = -gib[2]; }
void sp_iUpi(int b, unsigned int ub, char cb, int *q) { giu[b] = gi3 = gi + gi2; }
void sp_iUpj(int b, unsigned int ub, char cb, int *q) { giu[b] = gi3 = 7; }
void sp_iUpk(int b, unsigned int ub, char cb, int *q) { giu[b] += gi; }
void sp_iUpm(int b, unsigned int ub, char cb, int *q) { giu[b] ^= gi + gi2; }
void sp_iUpn(int b, unsigned int ub, char cb, int *q) { giu[b] -= 9; }
void sp_iUpo(int b, unsigned int ub, char cb, int *q) { giu[b] <<= 1; }
void sp_iUpp(int b, unsigned int ub, char cb, int *q) { giu[b]++; }
void sp_iUpq(int b, unsigned int ub, char cb, int *q) { --giu[b]; }
void sp_iUpr(int b, unsigned int ub, char cb, int *q) { gi3 = giu[b]++; }
void sp_iUps(int b, unsigned int ub, char cb, int *q) { gi3 = ++giu[b]; }
void sp_iUpt(int b, unsigned int ub, char cb, int *q) { gi3 = giu[b]--; }
void sp_iUca(int b, unsigned int ub, char cb, int *q) { giu[cb] = 5; }
void sp_iUcc(int b, unsigned int ub, char cb, int *q) { giu[cb] = gi + gi2; }
void sp_iUcd(int b, unsigned int ub, char cb, int *q) { giu[cb] = gi * gi2; }
void sp_iUce(int b, unsigned int ub, char cb, int *q) { giu[cb] = ri(); }
void sp_iUci(int b, unsigned int ub, char cb, int *q) { giu[cb] = gi3 = gi + gi2; }
void sp_iUcj(int b, unsigned int ub, char cb, int *q) { giu[cb] = gi3 = 7; }
void sp_iUck(int b, unsigned int ub, char cb, int *q) { giu[cb] += gi; }
void sp_iUcm(int b, unsigned int ub, char cb, int *q) { giu[cb] ^= gi + gi2; }
void sp_iUcp(int b, unsigned int ub, char cb, int *q) { giu[cb]++; }
void sp_iUcr(int b, unsigned int ub, char cb, int *q) { gi3 = giu[cb]++; }
void sp_iPka(int b, unsigned int ub, char cb, int *q) { gip[3] = 5; }
void sp_iPkb(int b, unsigned int ub, char cb, int *q) { gip[3] = gi; }
void sp_iPkc(int b, unsigned int ub, char cb, int *q) { gip[3] = gi + gi2; }
void sp_iPkd(int b, unsigned int ub, char cb, int *q) { gip[3] = gi * gi2; }
void sp_iPke(int b, unsigned int ub, char cb, int *q) { gip[3] = ri(); }
void sp_iPkf(int b, unsigned int ub, char cb, int *q) { gip[3] = gi >> cb; }
void sp_iPkg(int b, unsigned int ub, char cb, int *q) { gip[3] = (gu ? gi : gi2); }
void sp_iPkh(int b, unsigned int ub, char cb, int *q) { gip[3] = -gib[2]; }
void sp_iPki(int b, unsigned int ub, char cb, int *q) { gip[3] = gi3 = gi + gi2; }
void sp_iPkj(int b, unsigned int ub, char cb, int *q) { gip[3] = gi3 = 7; }
void sp_iPkk(int b, unsigned int ub, char cb, int *q) { gip[3] += gi; }
void sp_iPkm(int b, unsigned int ub, char cb, int *q) { gip[3] ^= gi + gi2; }
void sp_iPkn(int b, unsigned int ub, char cb, int *q) { gip[3] -= 9; }
void sp_iPko(int b, unsigned int ub, char cb, int *q) { gip[3] <<= 1; }
void sp_iPkp(int b, unsigned int ub, char cb, int *q) { gip[3]++; }
void sp_iPkq(int b, unsigned int ub, char cb, int *q) { --gip[3]; }
void sp_iPkr(int b, unsigned int ub, char cb, int *q) { gi3 = gip[3]++; }
void sp_iPks(int b, unsigned int ub, char cb, int *q) { gi3 = ++gip[3]; }
void sp_iPkt(int b, unsigned int ub, char cb, int *q) { gi3 = gip[3]--; }
void sp_iPKa(int b, unsigned int ub, char cb, int *q) { gip[0x8001u] = 5; }
void sp_iPKb(int b, unsigned int ub, char cb, int *q) { gip[0x8001u] = gi; }
void sp_iPKc(int b, unsigned int ub, char cb, int *q) { gip[0x8001u] = gi + gi2; }
void sp_iPKd(int b, unsigned int ub, char cb, int *q) { gip[0x8001u] = gi * gi2; }
void sp_iPKe(int b, unsigned int ub, char cb, int *q) { gip[0x8001u] = ri(); }
void sp_iPKf(int b, unsigned int ub, char cb, int *q) { gip[0x8001u] = gi >> cb; }
void sp_iPKg(int b, unsigned int ub, char cb, int *q) { gip[0x8001u] = (gu ? gi : gi2); }
void sp_iPKh(int b, unsigned int ub, char cb, int *q) { gip[0x8001u] = -gib[2]; }
void sp_iPKi(int b, unsigned int ub, char cb, int *q) { gip[0x8001u] = gi3 = gi + gi2; }
void sp_iPKj(int b, unsigned int ub, char cb, int *q) { gip[0x8001u] = gi3 = 7; }
void sp_iPKk(int b, unsigned int ub, char cb, int *q) { gip[0x8001u] += gi; }
void sp_iPKm(int b, unsigned int ub, char cb, int *q) { gip[0x8001u] ^= gi + gi2; }
void sp_iPKn(int b, unsigned int ub, char cb, int *q) { gip[0x8001u] -= 9; }
void sp_iPKo(int b, unsigned int ub, char cb, int *q) { gip[0x8001u] <<= 1; }
void sp_iPKp(int b, unsigned int ub, char cb, int *q) { gip[0x8001u]++; }
void sp_iPKq(int b, unsigned int ub, char cb, int *q) { --gip[0x8001u]; }
void sp_iPKr(int b, unsigned int ub, char cb, int *q) { gi3 = gip[0x8001u]++; }
void sp_iPKs(int b, unsigned int ub, char cb, int *q) { gi3 = ++gip[0x8001u]; }
void sp_iPKt(int b, unsigned int ub, char cb, int *q) { gi3 = gip[0x8001u]--; }
void sp_iPpa(int b, unsigned int ub, char cb, int *q) { gip[b] = 5; }
void sp_iPpb(int b, unsigned int ub, char cb, int *q) { gip[b] = gi; }
void sp_iPpc(int b, unsigned int ub, char cb, int *q) { gip[b] = gi + gi2; }
void sp_iPpd(int b, unsigned int ub, char cb, int *q) { gip[b] = gi * gi2; }
void sp_iPpe(int b, unsigned int ub, char cb, int *q) { gip[b] = ri(); }
void sp_iPpf(int b, unsigned int ub, char cb, int *q) { gip[b] = gi >> cb; }
void sp_iPpg(int b, unsigned int ub, char cb, int *q) { gip[b] = (gu ? gi : gi2); }
void sp_iPph(int b, unsigned int ub, char cb, int *q) { gip[b] = -gib[2]; }
void sp_iPpi(int b, unsigned int ub, char cb, int *q) { gip[b] = gi3 = gi + gi2; }
void sp_iPpj(int b, unsigned int ub, char cb, int *q) { gip[b] = gi3 = 7; }
void sp_iPpk(int b, unsigned int ub, char cb, int *q) { gip[b] += gi; }
void sp_iPpm(int b, unsigned int ub, char cb, int *q) { gip[b] ^= gi + gi2; }
void sp_iPpn(int b, unsigned int ub, char cb, int *q) { gip[b] -= 9; }
void sp_iPpo(int b, unsigned int ub, char cb, int *q) { gip[b] <<= 1; }
void sp_iPpp(int b, unsigned int ub, char cb, int *q) { gip[b]++; }
void sp_iPpq(int b, unsigned int ub, char cb, int *q) { --gip[b]; }
void sp_iPpr(int b, unsigned int ub, char cb, int *q) { gi3 = gip[b]++; }
void sp_iPps(int b, unsigned int ub, char cb, int *q) { gi3 = ++gip[b]; }
void sp_iPpt(int b, unsigned int ub, char cb, int *q) { gi3 = gip[b]--; }
void sp_iPca(int b, unsigned int ub, char cb, int *q) { gip[cb] = 5; }
void sp_iPcc(int b, unsigned int ub, char cb, int *q) { gip[cb] = gi + gi2; }
void sp_iPcd(int b, unsigned int ub, char cb, int *q) { gip[cb] = gi * gi2; }
void sp_iPce(int b, unsigned int ub, char cb, int *q) { gip[cb] = ri(); }
void sp_iPci(int b, unsigned int ub, char cb, int *q) { gip[cb] = gi3 = gi + gi2; }
void sp_iPcj(int b, unsigned int ub, char cb, int *q) { gip[cb] = gi3 = 7; }
void sp_iPck(int b, unsigned int ub, char cb, int *q) { gip[cb] += gi; }
void sp_iPcm(int b, unsigned int ub, char cb, int *q) { gip[cb] ^= gi + gi2; }
void sp_iPcp(int b, unsigned int ub, char cb, int *q) { gip[cb]++; }
void sp_iPcr(int b, unsigned int ub, char cb, int *q) { gi3 = gip[cb]++; }
void sp_iPla(int b, unsigned int ub, char cb, int *q) { int t = gi3; gip[t] = 5; }
void sp_iPlb(int b, unsigned int ub, char cb, int *q) { int t = gi3; gip[t] = gi; }
void sp_iPlc(int b, unsigned int ub, char cb, int *q) { int t = gi3; gip[t] = gi + gi2; }
void sp_iPld(int b, unsigned int ub, char cb, int *q) { int t = gi3; gip[t] = gi * gi2; }
void sp_iPle(int b, unsigned int ub, char cb, int *q) { int t = gi3; gip[t] = ri(); }
void sp_iPlf(int b, unsigned int ub, char cb, int *q) { int t = gi3; gip[t] = gi >> cb; }
void sp_iPlg(int b, unsigned int ub, char cb, int *q) { int t = gi3; gip[t] = (gu ? gi : gi2); }
void sp_iPlh(int b, unsigned int ub, char cb, int *q) { int t = gi3; gip[t] = -gib[2]; }
void sp_iPli(int b, unsigned int ub, char cb, int *q) { int t = gi3; gip[t] = gi3 = gi + gi2; }
void sp_iPlj(int b, unsigned int ub, char cb, int *q) { int t = gi3; gip[t] = gi3 = 7; }
void sp_iPlk(int b, unsigned int ub, char cb, int *q) { int t = gi3; gip[t] += gi; }
void sp_iPlm(int b, unsigned int ub, char cb, int *q) { int t = gi3; gip[t] ^= gi + gi2; }
void sp_iPln(int b, unsigned int ub, char cb, int *q) { int t = gi3; gip[t] -= 9; }
void sp_iPlo(int b, unsigned int ub, char cb, int *q) { int t = gi3; gip[t] <<= 1; }
void sp_iPlp(int b, unsigned int ub, char cb, int *q) { int t = gi3; gip[t]++; }
void sp_iPlq(int b, unsigned int ub, char cb, int *q) { int t = gi3; --gip[t]; }
void sp_iPlr(int b, unsigned int ub, char cb, int *q) { int t = gi3; gi3 = gip[t]++; }
void sp_iPls(int b, unsigned int ub, char cb, int *q) { int t = gi3; gi3 = ++gip[t]; }
void sp_iPlt(int b, unsigned int ub, char cb, int *q) { int t = gi3; gi3 = gip[t]--; }
void sp_iPna(int b, unsigned int ub, char cb, int *q) { gip[-2] = 5; }
void sp_iPnc(int b, unsigned int ub, char cb, int *q) { gip[-2] = gi + gi2; }
void sp_iPnd(int b, unsigned int ub, char cb, int *q) { gip[-2] = gi * gi2; }
void sp_iPne(int b, unsigned int ub, char cb, int *q) { gip[-2] = ri(); }
void sp_iPni(int b, unsigned int ub, char cb, int *q) { gip[-2] = gi3 = gi + gi2; }
void sp_iPnj(int b, unsigned int ub, char cb, int *q) { gip[-2] = gi3 = 7; }
void sp_iPnk(int b, unsigned int ub, char cb, int *q) { gip[-2] += gi; }
void sp_iPnm(int b, unsigned int ub, char cb, int *q) { gip[-2] ^= gi + gi2; }
void sp_iPnp(int b, unsigned int ub, char cb, int *q) { gip[-2]++; }
void sp_iPnr(int b, unsigned int ub, char cb, int *q) { gi3 = gip[-2]++; }
void sp_iQka(int b, unsigned int ub, char cb, int *q) { q[3] = 5; }
void sp_iQkb(int b, unsigned int ub, char cb, int *q) { q[3] = gi; }
void sp_iQkc(int b, unsigned int ub, char cb, int *q) { q[3] = gi + gi2; }
void sp_iQkd(int b, unsigned int ub, char cb, int *q) { q[3] = gi * gi2; }
void sp_iQke(int b, unsigned int ub, char cb, int *q) { q[3] = ri(); }
void sp_iQkf(int b, unsigned int ub, char cb, int *q) { q[3] = gi >> cb; }
void sp_iQkg(int b, unsigned int ub, char cb, int *q) { q[3] = (gu ? gi : gi2); }
void sp_iQkh(int b, unsigned int ub, char cb, int *q) { q[3] = -gib[2]; }
void sp_iQki(int b, unsigned int ub, char cb, int *q) { q[3] = gi3 = gi + gi2; }
void sp_iQkj(int b, unsigned int ub, char cb, int *q) { q[3] = gi3 = 7; }
void sp_iQkk(int b, unsigned int ub, char cb, int *q) { q[3] += gi; }
void sp_iQkm(int b, unsigned int ub, char cb, int *q) { q[3] ^= gi + gi2; }
void sp_iQkn(int b, unsigned int ub, char cb, int *q) { q[3] -= 9; }
void sp_iQko(int b, unsigned int ub, char cb, int *q) { q[3] <<= 1; }
void sp_iQkp(int b, unsigned int ub, char cb, int *q) { q[3]++; }
void sp_iQkq(int b, unsigned int ub, char cb, int *q) { --q[3]; }
void sp_iQkr(int b, unsigned int ub, char cb, int *q) { gi3 = q[3]++; }
void sp_iQks(int b, unsigned int ub, char cb, int *q) { gi3 = ++q[3]; }
void sp_iQkt(int b, unsigned int ub, char cb, int *q) { gi3 = q[3]--; }
void sp_iQKa(int b, unsigned int ub, char cb, int *q) { q[0x8001u] = 5; }
void sp_iQKb(int b, unsigned int ub, char cb, int *q) { q[0x8001u] = gi; }
void sp_iQKc(int b, unsigned int ub, char cb, int *q) { q[0x8001u] = gi + gi2; }
void sp_iQKd(int b, unsigned int ub, char cb, int *q) { q[0x8001u] = gi * gi2; }
void sp_iQKe(int b, unsigned int ub, char cb, int *q) { q[0x8001u] = ri(); }
void sp_iQKf(int b, unsigned int ub, char cb, int *q) { q[0x8001u] = gi >> cb; }
void sp_iQKg(int b, unsigned int ub, char cb, int *q) { q[0x8001u] = (gu ? gi : gi2); }
void sp_iQKh(int b, unsigned int ub, char cb, int *q) { q[0x8001u] = -gib[2]; }
void sp_iQKi(int b, unsigned int ub, char cb, int *q) { q[0x8001u] = gi3 = gi + gi2; }
void sp_iQKj(int b, unsigned int ub, char cb, int *q) { q[0x8001u] = gi3 = 7; }
void sp_iQKk(int b, unsigned int ub, char cb, int *q) { q[0x8001u] += gi; }
void sp_iQKm(int b, unsigned int ub, char cb, int *q) { q[0x8001u] ^= gi + gi2; }
void sp_iQKn(int b, unsigned int ub, char cb, int *q) { q[0x8001u] -= 9; }
void sp_iQKo(int b, unsigned int ub, char cb, int *q) { q[0x8001u] <<= 1; }
void sp_iQKp(int b, unsigned int ub, char cb, int *q) { q[0x8001u]++; }
void sp_iQKq(int b, unsigned int ub, char cb, int *q) { --q[0x8001u]; }
void sp_iQKr(int b, unsigned int ub, char cb, int *q) { gi3 = q[0x8001u]++; }
void sp_iQKs(int b, unsigned int ub, char cb, int *q) { gi3 = ++q[0x8001u]; }
void sp_iQKt(int b, unsigned int ub, char cb, int *q) { gi3 = q[0x8001u]--; }
void sp_iQpa(int b, unsigned int ub, char cb, int *q) { q[b] = 5; }
void sp_iQpb(int b, unsigned int ub, char cb, int *q) { q[b] = gi; }
void sp_iQpc(int b, unsigned int ub, char cb, int *q) { q[b] = gi + gi2; }
void sp_iQpd(int b, unsigned int ub, char cb, int *q) { q[b] = gi * gi2; }
void sp_iQpe(int b, unsigned int ub, char cb, int *q) { q[b] = ri(); }
void sp_iQpf(int b, unsigned int ub, char cb, int *q) { q[b] = gi >> cb; }
void sp_iQpg(int b, unsigned int ub, char cb, int *q) { q[b] = (gu ? gi : gi2); }
void sp_iQph(int b, unsigned int ub, char cb, int *q) { q[b] = -gib[2]; }
void sp_iQpi(int b, unsigned int ub, char cb, int *q) { q[b] = gi3 = gi + gi2; }
void sp_iQpj(int b, unsigned int ub, char cb, int *q) { q[b] = gi3 = 7; }
void sp_iQpk(int b, unsigned int ub, char cb, int *q) { q[b] += gi; }
void sp_iQpm(int b, unsigned int ub, char cb, int *q) { q[b] ^= gi + gi2; }
void sp_iQpn(int b, unsigned int ub, char cb, int *q) { q[b] -= 9; }
void sp_iQpo(int b, unsigned int ub, char cb, int *q) { q[b] <<= 1; }
void sp_iQpp(int b, unsigned int ub, char cb, int *q) { q[b]++; }
void sp_iQpq(int b, unsigned int ub, char cb, int *q) { --q[b]; }
void sp_iQpr(int b, unsigned int ub, char cb, int *q) { gi3 = q[b]++; }
void sp_iQps(int b, unsigned int ub, char cb, int *q) { gi3 = ++q[b]; }
void sp_iQpt(int b, unsigned int ub, char cb, int *q) { gi3 = q[b]--; }
void sp_iQca(int b, unsigned int ub, char cb, int *q) { q[cb] = 5; }
void sp_iQcc(int b, unsigned int ub, char cb, int *q) { q[cb] = gi + gi2; }
void sp_iQcd(int b, unsigned int ub, char cb, int *q) { q[cb] = gi * gi2; }
void sp_iQce(int b, unsigned int ub, char cb, int *q) { q[cb] = ri(); }
void sp_iQci(int b, unsigned int ub, char cb, int *q) { q[cb] = gi3 = gi + gi2; }
void sp_iQcj(int b, unsigned int ub, char cb, int *q) { q[cb] = gi3 = 7; }
void sp_iQck(int b, unsigned int ub, char cb, int *q) { q[cb] += gi; }
void sp_iQcm(int b, unsigned int ub, char cb, int *q) { q[cb] ^= gi + gi2; }
void sp_iQcp(int b, unsigned int ub, char cb, int *q) { q[cb]++; }
void sp_iQcr(int b, unsigned int ub, char cb, int *q) { gi3 = q[cb]++; }
void sp_iQna(int b, unsigned int ub, char cb, int *q) { q[-2] = 5; }
void sp_iQnc(int b, unsigned int ub, char cb, int *q) { q[-2] = gi + gi2; }
void sp_iQnd(int b, unsigned int ub, char cb, int *q) { q[-2] = gi * gi2; }
void sp_iQne(int b, unsigned int ub, char cb, int *q) { q[-2] = ri(); }
void sp_iQni(int b, unsigned int ub, char cb, int *q) { q[-2] = gi3 = gi + gi2; }
void sp_iQnj(int b, unsigned int ub, char cb, int *q) { q[-2] = gi3 = 7; }
void sp_iQnk(int b, unsigned int ub, char cb, int *q) { q[-2] += gi; }
void sp_iQnm(int b, unsigned int ub, char cb, int *q) { q[-2] ^= gi + gi2; }
void sp_iQnp(int b, unsigned int ub, char cb, int *q) { q[-2]++; }
void sp_iQnr(int b, unsigned int ub, char cb, int *q) { gi3 = q[-2]++; }
void sp_iSka(int b, unsigned int ub, char cb, int *q) { gps->mia[3] = 5; }
void sp_iSkb(int b, unsigned int ub, char cb, int *q) { gps->mia[3] = gi; }
void sp_iSkc(int b, unsigned int ub, char cb, int *q) { gps->mia[3] = gi + gi2; }
void sp_iSkd(int b, unsigned int ub, char cb, int *q) { gps->mia[3] = gi * gi2; }
void sp_iSke(int b, unsigned int ub, char cb, int *q) { gps->mia[3] = ri(); }
void sp_iSkf(int b, unsigned int ub, char cb, int *q) { gps->mia[3] = gi >> cb; }
void sp_iSkg(int b, unsigned int ub, char cb, int *q) { gps->mia[3] = (gu ? gi : gi2); }
void sp_iSkh(int b, unsigned int ub, char cb, int *q) { gps->mia[3] = -gib[2]; }
void sp_iSki(int b, unsigned int ub, char cb, int *q) { gps->mia[3] = gi3 = gi + gi2; }
void sp_iSkj(int b, unsigned int ub, char cb, int *q) { gps->mia[3] = gi3 = 7; }
void sp_iSkk(int b, unsigned int ub, char cb, int *q) { gps->mia[3] += gi; }
void sp_iSkm(int b, unsigned int ub, char cb, int *q) { gps->mia[3] ^= gi + gi2; }
void sp_iSkn(int b, unsigned int ub, char cb, int *q) { gps->mia[3] -= 9; }
void sp_iSko(int b, unsigned int ub, char cb, int *q) { gps->mia[3] <<= 1; }
void sp_iSkp(int b, unsigned int ub, char cb, int *q) { gps->mia[3]++; }
void sp_iSkq(int b, unsigned int ub, char cb, int *q) { --gps->mia[3]; }
void sp_iSkr(int b, unsigned int ub, char cb, int *q) { gi3 = gps->mia[3]++; }
void sp_iSks(int b, unsigned int ub, char cb, int *q) { gi3 = ++gps->mia[3]; }
void sp_iSkt(int b, unsigned int ub, char cb, int *q) { gi3 = gps->mia[3]--; }
void sp_iSpa(int b, unsigned int ub, char cb, int *q) { gps->mia[b] = 5; }
void sp_iSpb(int b, unsigned int ub, char cb, int *q) { gps->mia[b] = gi; }
void sp_iSpc(int b, unsigned int ub, char cb, int *q) { gps->mia[b] = gi + gi2; }
void sp_iSpd(int b, unsigned int ub, char cb, int *q) { gps->mia[b] = gi * gi2; }
void sp_iSpe(int b, unsigned int ub, char cb, int *q) { gps->mia[b] = ri(); }
void sp_iSpf(int b, unsigned int ub, char cb, int *q) { gps->mia[b] = gi >> cb; }
void sp_iSpg(int b, unsigned int ub, char cb, int *q) { gps->mia[b] = (gu ? gi : gi2); }
void sp_iSph(int b, unsigned int ub, char cb, int *q) { gps->mia[b] = -gib[2]; }
void sp_iSpi(int b, unsigned int ub, char cb, int *q) { gps->mia[b] = gi3 = gi + gi2; }
void sp_iSpj(int b, unsigned int ub, char cb, int *q) { gps->mia[b] = gi3 = 7; }
void sp_iSpk(int b, unsigned int ub, char cb, int *q) { gps->mia[b] += gi; }
void sp_iSpm(int b, unsigned int ub, char cb, int *q) { gps->mia[b] ^= gi + gi2; }
void sp_iSpn(int b, unsigned int ub, char cb, int *q) { gps->mia[b] -= 9; }
void sp_iSpo(int b, unsigned int ub, char cb, int *q) { gps->mia[b] <<= 1; }
void sp_iSpp(int b, unsigned int ub, char cb, int *q) { gps->mia[b]++; }
void sp_iSpq(int b, unsigned int ub, char cb, int *q) { --gps->mia[b]; }
void sp_iSpr(int b, unsigned int ub, char cb, int *q) { gi3 = gps->mia[b]++; }
void sp_iSps(int b, unsigned int ub, char cb, int *q) { gi3 = ++gps->mia[b]; }
void sp_iSpt(int b, unsigned int ub, char cb, int *q) { gi3 = gps->mia[b]--; }
void sp_iD_a(int b, unsigned int ub, char cb, int *q) { *gip = 5; }
void sp_iD_b(int b, unsigned int ub, char cb, int *q) { *gip = gi; }
void sp_iD_c(int b, unsigned int ub, char cb, int *q) { *gip = gi + gi2; }
void sp_iD_d(int b, unsigned int ub, char cb, int *q) { *gip = gi * gi2; }
void sp_iD_e(int b, unsigned int ub, char cb, int *q) { *gip = ri(); }
void sp_iD_f(int b, unsigned int ub, char cb, int *q) { *gip = gi >> cb; }
void sp_iD_g(int b, unsigned int ub, char cb, int *q) { *gip = (gu ? gi : gi2); }
void sp_iD_h(int b, unsigned int ub, char cb, int *q) { *gip = -gib[2]; }
void sp_iD_i(int b, unsigned int ub, char cb, int *q) { *gip = gi3 = gi + gi2; }
void sp_iD_j(int b, unsigned int ub, char cb, int *q) { *gip = gi3 = 7; }
void sp_iD_k(int b, unsigned int ub, char cb, int *q) { *gip += gi; }
void sp_iD_m(int b, unsigned int ub, char cb, int *q) { *gip ^= gi + gi2; }
void sp_iD_n(int b, unsigned int ub, char cb, int *q) { *gip -= 9; }
void sp_iD_o(int b, unsigned int ub, char cb, int *q) { *gip <<= 1; }
void sp_iD_p(int b, unsigned int ub, char cb, int *q) { *gip++; }
void sp_iD_q(int b, unsigned int ub, char cb, int *q) { --*gip; }
void sp_iD_r(int b, unsigned int ub, char cb, int *q) { gi3 = *gip++; }
void sp_iD_s(int b, unsigned int ub, char cb, int *q) { gi3 = ++*gip; }
void sp_iD_t(int b, unsigned int ub, char cb, int *q) { gi3 = *gip--; }
void sp_iE_a(int b, unsigned int ub, char cb, int *q) { *q = 5; }
void sp_iE_b(int b, unsigned int ub, char cb, int *q) { *q = gi; }
void sp_iE_c(int b, unsigned int ub, char cb, int *q) { *q = gi + gi2; }
void sp_iE_d(int b, unsigned int ub, char cb, int *q) { *q = gi * gi2; }
void sp_iE_e(int b, unsigned int ub, char cb, int *q) { *q = ri(); }
void sp_iE_f(int b, unsigned int ub, char cb, int *q) { *q = gi >> cb; }
void sp_iE_g(int b, unsigned int ub, char cb, int *q) { *q = (gu ? gi : gi2); }
void sp_iE_h(int b, unsigned int ub, char cb, int *q) { *q = -gib[2]; }
void sp_iE_i(int b, unsigned int ub, char cb, int *q) { *q = gi3 = gi + gi2; }
void sp_iE_j(int b, unsigned int ub, char cb, int *q) { *q = gi3 = 7; }
void sp_iE_k(int b, unsigned int ub, char cb, int *q) { *q += gi; }
void sp_iE_m(int b, unsigned int ub, char cb, int *q) { *q ^= gi + gi2; }
void sp_iE_n(int b, unsigned int ub, char cb, int *q) { *q -= 9; }
void sp_iE_o(int b, unsigned int ub, char cb, int *q) { *q <<= 1; }
void sp_iE_p(int b, unsigned int ub, char cb, int *q) { *q++; }
void sp_iE_q(int b, unsigned int ub, char cb, int *q) { --*q; }
void sp_iE_r(int b, unsigned int ub, char cb, int *q) { gi3 = *q++; }
void sp_iE_s(int b, unsigned int ub, char cb, int *q) { gi3 = ++*q; }
void sp_iE_t(int b, unsigned int ub, char cb, int *q) { gi3 = *q--; }
void sp_lAka(int b, unsigned int ub, char cb, long *q) { gla[3] = 5; }
void sp_lAkb(int b, unsigned int ub, char cb, long *q) { gla[3] = gl; }
void sp_lAkc(int b, unsigned int ub, char cb, long *q) { gla[3] = gl + gl2; }
void sp_lAkd(int b, unsigned int ub, char cb, long *q) { gla[3] = gl * gl2; }
void sp_lAke(int b, unsigned int ub, char cb, long *q) { gla[3] = rl(); }
void sp_lAkf(int b, unsigned int ub, char cb, long *q) { gla[3] = gl >> cb; }
void sp_lAkg(int b, unsigned int ub, char cb, long *q) { gla[3] = (gu ? gl : gl2); }
void sp_lAkh(int b, unsigned int ub, char cb, long *q) { gla[3] = -glb[2]; }
void sp_lAki(int b, unsigned int ub, char cb, long *q) { gla[3] = gl3 = gl + gl2; }
void sp_lAkj(int b, unsigned int ub, char cb, long *q) { gla[3] = gl3 = 7; }
void sp_lAkk(int b, unsigned int ub, char cb, long *q) { gla[3] += gl; }
void sp_lAkm(int b, unsigned int ub, char cb, long *q) { gla[3] ^= gl + gl2; }
void sp_lAkn(int b, unsigned int ub, char cb, long *q) { gla[3] -= 9; }
void sp_lAko(int b, unsigned int ub, char cb, long *q) { gla[3] <<= 1; }
void sp_lAkp(int b, unsigned int ub, char cb, long *q) { gla[3]++; }
void sp_lAkq(int b, unsigned int ub, char cb, long *q) { --gla[3]; }
void sp_lAkr(int b, unsigned int ub, char cb, long *q) { gl3 = gla[3]++; }
void sp_lAks(int b, unsigned int ub, char cb, long *q) { gl3 = ++gla[3]; }
void sp_lAkt(int b, unsigned int ub, char cb, long *q) { gl3 = gla[3]--; }
void sp_lAKa(int b, unsigned int ub, char cb, long *q) { gla[0x8001u] = 5; }
void sp_lAKb(int b, unsigned int ub, char cb, long *q) { gla[0x8001u] = gl; }
void sp_lAKc(int b, unsigned int ub, char cb, long *q) { gla[0x8001u] = gl + gl2; }
void sp_lAKd(int b, unsigned int ub, char cb, long *q) { gla[0x8001u] = gl * gl2; }
void sp_lAKe(int b, unsigned int ub, char cb, long *q) { gla[0x8001u] = rl(); }
void sp_lAKf(int b, unsigned int ub, char cb, long *q) { gla[0x8001u] = gl >> cb; }
void sp_lAKg(int b, unsigned int ub, char cb, long *q) { gla[0x8001u] = (gu ? gl : gl2); }
void sp_lAKh(int b, unsigned int ub, char cb, long *q) { gla[0x8001u] = -glb[2]; }
void sp_lAKi(int b, unsigned int ub, char cb, long *q) { gla[0x8001u] = gl3 = gl + gl2; }
void sp_lAKj(int b, unsigned int ub, char cb, long *q) { gla[0x8001u] = gl3 = 7; }
void sp_lAKk(int b, unsigned int ub, char cb, long *q) { gla[0x8001u] += gl; }
void sp_lAKm(int b, unsigned int ub, char cb, long *q) { gla[0x8001u] ^= gl + gl2; }
void sp_lAKn(int b, unsigned int ub, char cb, long *q) { gla[0x8001u] -= 9; }
void sp_lAKo(int b, unsigned int ub, char cb, long *q) { gla[0x8001u] <<= 1; }
void sp_lAKp(int b, unsigned int ub, char cb, long *q) { gla[0x8001u]++; }
void sp_lAKq(int b, unsigned int ub, char cb, long *q) { --gla[0x8001u]; }
void sp_lAKr(int b, unsigned int ub, char cb, long *q) { gl3 = gla[0x8001u]++; }
void sp_lAKs(int b, unsigned int ub, char cb, long *q) { gl3 = ++gla[0x8001u]; }
void sp_lAKt(int b, unsigned int ub, char cb, long *q) { gl3 = gla[0x8001u]--; }
void sp_lApa(int b, unsigned int ub, char cb, long *q) { gla[b] = 5; }
void sp_lApb(int b, unsigned int ub, char cb, long *q) { gla[b] = gl; }
void sp_lApc(int b, unsigned int ub, char cb, long *q) { gla[b] = gl + gl2; }
void sp_lApd(int b, unsigned int ub, char cb, long *q) { gla[b] = gl * gl2; }
void sp_lApe(int b, unsigned int ub, char cb, long *q) { gla[b] = rl(); }
void sp_lApf(int b, unsigned int ub, char cb, long *q) { gla[b] = gl >> cb; }
void sp_lApg(int b, unsigned int ub, char cb, long *q) { gla[b] = (gu ? gl : gl2); }
void sp_lAph(int b, unsigned int ub, char cb, long *q) { gla[b] = -glb[2]; }
void sp_lApi(int b, unsigned int ub, char cb, long *q) { gla[b] = gl3 = gl + gl2; }
void sp_lApj(int b, unsigned int ub, char cb, long *q) { gla[b] = gl3 = 7; }
void sp_lApk(int b, unsigned int ub, char cb, long *q) { gla[b] += gl; }
void sp_lApm(int b, unsigned int ub, char cb, long *q) { gla[b] ^= gl + gl2; }
void sp_lApn(int b, unsigned int ub, char cb, long *q) { gla[b] -= 9; }
void sp_lApo(int b, unsigned int ub, char cb, long *q) { gla[b] <<= 1; }
void sp_lApp(int b, unsigned int ub, char cb, long *q) { gla[b]++; }
void sp_lApq(int b, unsigned int ub, char cb, long *q) { --gla[b]; }
void sp_lApr(int b, unsigned int ub, char cb, long *q) { gl3 = gla[b]++; }
void sp_lAps(int b, unsigned int ub, char cb, long *q) { gl3 = ++gla[b]; }
void sp_lApt(int b, unsigned int ub, char cb, long *q) { gl3 = gla[b]--; }
void sp_lAua(int b, unsigned int ub, char cb, long *q) { gla[ub] = 5; }
void sp_lAuc(int b, unsigned int ub, char cb, long *q) { gla[ub] = gl + gl2; }
void sp_lAud(int b, unsigned int ub, char cb, long *q) { gla[ub] = gl * gl2; }
void sp_lAue(int b, unsigned int ub, char cb, long *q) { gla[ub] = rl(); }
void sp_lAui(int b, unsigned int ub, char cb, long *q) { gla[ub] = gl3 = gl + gl2; }
void sp_lAuj(int b, unsigned int ub, char cb, long *q) { gla[ub] = gl3 = 7; }
void sp_lAuk(int b, unsigned int ub, char cb, long *q) { gla[ub] += gl; }
void sp_lAum(int b, unsigned int ub, char cb, long *q) { gla[ub] ^= gl + gl2; }
void sp_lAup(int b, unsigned int ub, char cb, long *q) { gla[ub]++; }
void sp_lAur(int b, unsigned int ub, char cb, long *q) { gl3 = gla[ub]++; }
void sp_lAca(int b, unsigned int ub, char cb, long *q) { gla[cb] = 5; }
void sp_lAcc(int b, unsigned int ub, char cb, long *q) { gla[cb] = gl + gl2; }
void sp_lAcd(int b, unsigned int ub, char cb, long *q) { gla[cb] = gl * gl2; }
void sp_lAce(int b, unsigned int ub, char cb, long *q) { gla[cb] = rl(); }
void sp_lAci(int b, unsigned int ub, char cb, long *q) { gla[cb] = gl3 = gl + gl2; }
void sp_lAcj(int b, unsigned int ub, char cb, long *q) { gla[cb] = gl3 = 7; }
void sp_lAck(int b, unsigned int ub, char cb, long *q) { gla[cb] += gl; }
void sp_lAcm(int b, unsigned int ub, char cb, long *q) { gla[cb] ^= gl + gl2; }
void sp_lAcp(int b, unsigned int ub, char cb, long *q) { gla[cb]++; }
void sp_lAcr(int b, unsigned int ub, char cb, long *q) { gl3 = gla[cb]++; }
void sp_lAla(int b, unsigned int ub, char cb, long *q) { int t = gi3; gla[t] = 5; }
void sp_lAlb(int b, unsigned int ub, char cb, long *q) { int t = gi3; gla[t] = gl; }
void sp_lAlc(int b, unsigned int ub, char cb, long *q) { int t = gi3; gla[t] = gl + gl2; }
void sp_lAld(int b, unsigned int ub, char cb, long *q) { int t = gi3; gla[t] = gl * gl2; }
void sp_lAle(int b, unsigned int ub, char cb, long *q) { int t = gi3; gla[t] = rl(); }
void sp_lAlf(int b, unsigned int ub, char cb, long *q) { int t = gi3; gla[t] = gl >> cb; }
void sp_lAlg(int b, unsigned int ub, char cb, long *q) { int t = gi3; gla[t] = (gu ? gl : gl2); }
void sp_lAlh(int b, unsigned int ub, char cb, long *q) { int t = gi3; gla[t] = -glb[2]; }
void sp_lAli(int b, unsigned int ub, char cb, long *q) { int t = gi3; gla[t] = gl3 = gl + gl2; }
void sp_lAlj(int b, unsigned int ub, char cb, long *q) { int t = gi3; gla[t] = gl3 = 7; }
void sp_lAlk(int b, unsigned int ub, char cb, long *q) { int t = gi3; gla[t] += gl; }
void sp_lAlm(int b, unsigned int ub, char cb, long *q) { int t = gi3; gla[t] ^= gl + gl2; }
void sp_lAln(int b, unsigned int ub, char cb, long *q) { int t = gi3; gla[t] -= 9; }
void sp_lAlo(int b, unsigned int ub, char cb, long *q) { int t = gi3; gla[t] <<= 1; }
void sp_lAlp(int b, unsigned int ub, char cb, long *q) { int t = gi3; gla[t]++; }
void sp_lAlq(int b, unsigned int ub, char cb, long *q) { int t = gi3; --gla[t]; }
void sp_lAlr(int b, unsigned int ub, char cb, long *q) { int t = gi3; gl3 = gla[t]++; }
void sp_lAls(int b, unsigned int ub, char cb, long *q) { int t = gi3; gl3 = ++gla[t]; }
void sp_lAlt(int b, unsigned int ub, char cb, long *q) { int t = gi3; gl3 = gla[t]--; }
void sp_lAga(int b, unsigned int ub, char cb, long *q) { gla[gi2] = 5; }
void sp_lAgc(int b, unsigned int ub, char cb, long *q) { gla[gi2] = gl + gl2; }
void sp_lAgd(int b, unsigned int ub, char cb, long *q) { gla[gi2] = gl * gl2; }
void sp_lAge(int b, unsigned int ub, char cb, long *q) { gla[gi2] = rl(); }
void sp_lAgi(int b, unsigned int ub, char cb, long *q) { gla[gi2] = gl3 = gl + gl2; }
void sp_lAgj(int b, unsigned int ub, char cb, long *q) { gla[gi2] = gl3 = 7; }
void sp_lAgk(int b, unsigned int ub, char cb, long *q) { gla[gi2] += gl; }
void sp_lAgm(int b, unsigned int ub, char cb, long *q) { gla[gi2] ^= gl + gl2; }
void sp_lAgp(int b, unsigned int ub, char cb, long *q) { gla[gi2]++; }
void sp_lAgr(int b, unsigned int ub, char cb, long *q) { gl3 = gla[gi2]++; }
void sp_lUka(int b, unsigned int ub, char cb, long *q) { glu[3] = 5; }
void sp_lUkb(int b, unsigned int ub, char cb, long *q) { glu[3] = gl; }
void sp_lUkc(int b, unsigned int ub, char cb, long *q) { glu[3] = gl + gl2; }
void sp_lUkd(int b, unsigned int ub, char cb, long *q) { glu[3] = gl * gl2; }
void sp_lUke(int b, unsigned int ub, char cb, long *q) { glu[3] = rl(); }
void sp_lUkf(int b, unsigned int ub, char cb, long *q) { glu[3] = gl >> cb; }
void sp_lUkg(int b, unsigned int ub, char cb, long *q) { glu[3] = (gu ? gl : gl2); }
void sp_lUkh(int b, unsigned int ub, char cb, long *q) { glu[3] = -glb[2]; }
void sp_lUki(int b, unsigned int ub, char cb, long *q) { glu[3] = gl3 = gl + gl2; }
void sp_lUkj(int b, unsigned int ub, char cb, long *q) { glu[3] = gl3 = 7; }
void sp_lUkk(int b, unsigned int ub, char cb, long *q) { glu[3] += gl; }
void sp_lUkm(int b, unsigned int ub, char cb, long *q) { glu[3] ^= gl + gl2; }
void sp_lUkn(int b, unsigned int ub, char cb, long *q) { glu[3] -= 9; }
void sp_lUko(int b, unsigned int ub, char cb, long *q) { glu[3] <<= 1; }
void sp_lUkp(int b, unsigned int ub, char cb, long *q) { glu[3]++; }
void sp_lUkq(int b, unsigned int ub, char cb, long *q) { --glu[3]; }
void sp_lUkr(int b, unsigned int ub, char cb, long *q) { gl3 = glu[3]++; }
void sp_lUks(int b, unsigned int ub, char cb, long *q) { gl3 = ++glu[3]; }
void sp_lUkt(int b, unsigned int ub, char cb, long *q) { gl3 = glu[3]--; }
void sp_lUKa(int b, unsigned int ub, char cb, long *q) { glu[0x8001u] = 5; }
void sp_lUKb(int b, unsigned int ub, char cb, long *q) { glu[0x8001u] = gl; }
void sp_lUKc(int b, unsigned int ub, char cb, long *q) { glu[0x8001u] = gl + gl2; }
void sp_lUKd(int b, unsigned int ub, char cb, long *q) { glu[0x8001u] = gl * gl2; }
void sp_lUKe(int b, unsigned int ub, char cb, long *q) { glu[0x8001u] = rl(); }
void sp_lUKf(int b, unsigned int ub, char cb, long *q) { glu[0x8001u] = gl >> cb; }
void sp_lUKg(int b, unsigned int ub, char cb, long *q) { glu[0x8001u] = (gu ? gl : gl2); }
void sp_lUKh(int b, unsigned int ub, char cb, long *q) { glu[0x8001u] = -glb[2]; }
void sp_lUKi(int b, unsigned int ub, char cb, long *q) { glu[0x8001u] = gl3 = gl + gl2; }
void sp_lUKj(int b, unsigned int ub, char cb, long *q) { glu[0x8001u] = gl3 = 7; }
void sp_lUKk(int b, unsigned int ub, char cb, long *q) { glu[0x8001u] += gl; }
void sp_lUKm(int b, unsigned int ub, char cb, long *q) { glu[0x8001u] ^= gl + gl2; }
void sp_lUKn(int b, unsigned int ub, char cb, long *q) { glu[0x8001u] -= 9; }
void sp_lUKo(int b, unsigned int ub, char cb, long *q) { glu[0x8001u] <<= 1; }
void sp_lUKp(int b, unsigned int ub, char cb, long *q) { glu[0x8001u]++; }
void sp_lUKq(int b, unsigned int ub, char cb, long *q) { --glu[0x8001u]; }
void sp_lUKr(int b, unsigned int ub, char cb, long *q) { gl3 = glu[0x8001u]++; }
void sp_lUKs(int b, unsigned int ub, char cb, long *q) { gl3 = ++glu[0x8001u]; }
void sp_lUKt(int b, unsigned int ub, char cb, long *q) { gl3 = glu[0x8001u]--; }
void sp_lUpa(int b, unsigned int ub, char cb, long *q) { glu[b] = 5; }
void sp_lUpb(int b, unsigned int ub, char cb, long *q) { glu[b] = gl; }
void sp_lUpc(int b, unsigned int ub, char cb, long *q) { glu[b] = gl + gl2; }
void sp_lUpd(int b, unsigned int ub, char cb, long *q) { glu[b] = gl * gl2; }
void sp_lUpe(int b, unsigned int ub, char cb, long *q) { glu[b] = rl(); }
void sp_lUpf(int b, unsigned int ub, char cb, long *q) { glu[b] = gl >> cb; }
void sp_lUpg(int b, unsigned int ub, char cb, long *q) { glu[b] = (gu ? gl : gl2); }
void sp_lUph(int b, unsigned int ub, char cb, long *q) { glu[b] = -glb[2]; }
void sp_lUpi(int b, unsigned int ub, char cb, long *q) { glu[b] = gl3 = gl + gl2; }
void sp_lUpj(int b, unsigned int ub, char cb, long *q) { glu[b] = gl3 = 7; }
void sp_lUpk(int b, unsigned int ub, char cb, long *q) { glu[b] += gl; }
void sp_lUpm(int b, unsigned int ub, char cb, long *q) { glu[b] ^= gl + gl2; }
void sp_lUpn(int b, unsigned int ub, char cb, long *q) { glu[b] -= 9; }
void sp_lUpo(int b, unsigned int ub, char cb, long *q) { glu[b] <<= 1; }
void sp_lUpp(int b, unsigned int ub, char cb, long *q) { glu[b]++; }
void sp_lUpq(int b, unsigned int ub, char cb, long *q) { --glu[b]; }
void sp_lUpr(int b, unsigned int ub, char cb, long *q) { gl3 = glu[b]++; }
void sp_lUps(int b, unsigned int ub, char cb, long *q) { gl3 = ++glu[b]; }
void sp_lUpt(int b, unsigned int ub, char cb, long *q) { gl3 = glu[b]--; }
void sp_lUca(int b, unsigned int ub, char cb, long *q) { glu[cb] = 5; }
void sp_lUcc(int b, unsigned int ub, char cb, long *q) { glu[cb] = gl + gl2; }
void sp_lUcd(int b, unsigned int ub, char cb, long *q) { glu[cb] = gl * gl2; }
void sp_lUce(int b, unsigned int ub, char cb, long *q) { glu[cb] = rl(); }
void sp_lUci(int b, unsigned int ub, char cb, long *q) { glu[cb] = gl3 = gl + gl2; }
void sp_lUcj(int b, unsigned int ub, char cb, long *q) { glu[cb] = gl3 = 7; }
void sp_lUck(int b, unsigned int ub, char cb, long *q) { glu[cb] += gl; }
void sp_lUcm(int b, unsigned int ub, char cb, long *q) { glu[cb] ^= gl + gl2; }
void sp_lUcp(int b, unsigned int ub, char cb, long *q) { glu[cb]++; }
void sp_lUcr(int b, unsigned int ub, char cb, long *q) { gl3 = glu[cb]++; }
void sp_lPka(int b, unsigned int ub, char cb, long *q) { glp[3] = 5; }
void sp_lPkb(int b, unsigned int ub, char cb, long *q) { glp[3] = gl; }
void sp_lPkc(int b, unsigned int ub, char cb, long *q) { glp[3] = gl + gl2; }
void sp_lPkd(int b, unsigned int ub, char cb, long *q) { glp[3] = gl * gl2; }
void sp_lPke(int b, unsigned int ub, char cb, long *q) { glp[3] = rl(); }
void sp_lPkf(int b, unsigned int ub, char cb, long *q) { glp[3] = gl >> cb; }
void sp_lPkg(int b, unsigned int ub, char cb, long *q) { glp[3] = (gu ? gl : gl2); }
void sp_lPkh(int b, unsigned int ub, char cb, long *q) { glp[3] = -glb[2]; }
void sp_lPki(int b, unsigned int ub, char cb, long *q) { glp[3] = gl3 = gl + gl2; }
void sp_lPkj(int b, unsigned int ub, char cb, long *q) { glp[3] = gl3 = 7; }
void sp_lPkk(int b, unsigned int ub, char cb, long *q) { glp[3] += gl; }
void sp_lPkm(int b, unsigned int ub, char cb, long *q) { glp[3] ^= gl + gl2; }
void sp_lPkn(int b, unsigned int ub, char cb, long *q) { glp[3] -= 9; }
void sp_lPko(int b, unsigned int ub, char cb, long *q) { glp[3] <<= 1; }
void sp_lPkp(int b, unsigned int ub, char cb, long *q) { glp[3]++; }
void sp_lPkq(int b, unsigned int ub, char cb, long *q) { --glp[3]; }
void sp_lPkr(int b, unsigned int ub, char cb, long *q) { gl3 = glp[3]++; }
void sp_lPks(int b, unsigned int ub, char cb, long *q) { gl3 = ++glp[3]; }
void sp_lPkt(int b, unsigned int ub, char cb, long *q) { gl3 = glp[3]--; }
void sp_lPKa(int b, unsigned int ub, char cb, long *q) { glp[0x8001u] = 5; }
void sp_lPKb(int b, unsigned int ub, char cb, long *q) { glp[0x8001u] = gl; }
void sp_lPKc(int b, unsigned int ub, char cb, long *q) { glp[0x8001u] = gl + gl2; }
void sp_lPKd(int b, unsigned int ub, char cb, long *q) { glp[0x8001u] = gl * gl2; }
void sp_lPKe(int b, unsigned int ub, char cb, long *q) { glp[0x8001u] = rl(); }
void sp_lPKf(int b, unsigned int ub, char cb, long *q) { glp[0x8001u] = gl >> cb; }
void sp_lPKg(int b, unsigned int ub, char cb, long *q) { glp[0x8001u] = (gu ? gl : gl2); }
void sp_lPKh(int b, unsigned int ub, char cb, long *q) { glp[0x8001u] = -glb[2]; }
void sp_lPKi(int b, unsigned int ub, char cb, long *q) { glp[0x8001u] = gl3 = gl + gl2; }
void sp_lPKj(int b, unsigned int ub, char cb, long *q) { glp[0x8001u] = gl3 = 7; }
void sp_lPKk(int b, unsigned int ub, char cb, long *q) { glp[0x8001u] += gl; }
void sp_lPKm(int b, unsigned int ub, char cb, long *q) { glp[0x8001u] ^= gl + gl2; }
void sp_lPKn(int b, unsigned int ub, char cb, long *q) { glp[0x8001u] -= 9; }
void sp_lPKo(int b, unsigned int ub, char cb, long *q) { glp[0x8001u] <<= 1; }
void sp_lPKp(int b, unsigned int ub, char cb, long *q) { glp[0x8001u]++; }
void sp_lPKq(int b, unsigned int ub, char cb, long *q) { --glp[0x8001u]; }
void sp_lPKr(int b, unsigned int ub, char cb, long *q) { gl3 = glp[0x8001u]++; }
void sp_lPKs(int b, unsigned int ub, char cb, long *q) { gl3 = ++glp[0x8001u]; }
void sp_lPKt(int b, unsigned int ub, char cb, long *q) { gl3 = glp[0x8001u]--; }
void sp_lPpa(int b, unsigned int ub, char cb, long *q) { glp[b] = 5; }
void sp_lPpb(int b, unsigned int ub, char cb, long *q) { glp[b] = gl; }
void sp_lPpc(int b, unsigned int ub, char cb, long *q) { glp[b] = gl + gl2; }
void sp_lPpd(int b, unsigned int ub, char cb, long *q) { glp[b] = gl * gl2; }
void sp_lPpe(int b, unsigned int ub, char cb, long *q) { glp[b] = rl(); }
void sp_lPpf(int b, unsigned int ub, char cb, long *q) { glp[b] = gl >> cb; }
void sp_lPpg(int b, unsigned int ub, char cb, long *q) { glp[b] = (gu ? gl : gl2); }
void sp_lPph(int b, unsigned int ub, char cb, long *q) { glp[b] = -glb[2]; }
void sp_lPpi(int b, unsigned int ub, char cb, long *q) { glp[b] = gl3 = gl + gl2; }
void sp_lPpj(int b, unsigned int ub, char cb, long *q) { glp[b] = gl3 = 7; }
void sp_lPpk(int b, unsigned int ub, char cb, long *q) { glp[b] += gl; }
void sp_lPpm(int b, unsigned int ub, char cb, long *q) { glp[b] ^= gl + gl2; }
void sp_lPpn(int b, unsigned int ub, char cb, long *q) { glp[b] -= 9; }
void sp_lPpo(int b, unsigned int ub, char cb, long *q) { glp[b] <<= 1; }
void sp_lPpp(int b, unsigned int ub, char cb, long *q) { glp[b]++; }
void sp_lPpq(int b, unsigned int ub, char cb, long *q) { --glp[b]; }
void sp_lPpr(int b, unsigned int ub, char cb, long *q) { gl3 = glp[b]++; }
void sp_lPps(int b, unsigned int ub, char cb, long *q) { gl3 = ++glp[b]; }
void sp_lPpt(int b, unsigned int ub, char cb, long *q) { gl3 = glp[b]--; }
void sp_lPca(int b, unsigned int ub, char cb, long *q) { glp[cb] = 5; }
void sp_lPcc(int b, unsigned int ub, char cb, long *q) { glp[cb] = gl + gl2; }
void sp_lPcd(int b, unsigned int ub, char cb, long *q) { glp[cb] = gl * gl2; }
void sp_lPce(int b, unsigned int ub, char cb, long *q) { glp[cb] = rl(); }
void sp_lPci(int b, unsigned int ub, char cb, long *q) { glp[cb] = gl3 = gl + gl2; }
void sp_lPcj(int b, unsigned int ub, char cb, long *q) { glp[cb] = gl3 = 7; }
void sp_lPck(int b, unsigned int ub, char cb, long *q) { glp[cb] += gl; }
void sp_lPcm(int b, unsigned int ub, char cb, long *q) { glp[cb] ^= gl + gl2; }
void sp_lPcp(int b, unsigned int ub, char cb, long *q) { glp[cb]++; }
void sp_lPcr(int b, unsigned int ub, char cb, long *q) { gl3 = glp[cb]++; }
void sp_lPla(int b, unsigned int ub, char cb, long *q) { int t = gi3; glp[t] = 5; }
void sp_lPlb(int b, unsigned int ub, char cb, long *q) { int t = gi3; glp[t] = gl; }
void sp_lPlc(int b, unsigned int ub, char cb, long *q) { int t = gi3; glp[t] = gl + gl2; }
void sp_lPld(int b, unsigned int ub, char cb, long *q) { int t = gi3; glp[t] = gl * gl2; }
void sp_lPle(int b, unsigned int ub, char cb, long *q) { int t = gi3; glp[t] = rl(); }
void sp_lPlf(int b, unsigned int ub, char cb, long *q) { int t = gi3; glp[t] = gl >> cb; }
void sp_lPlg(int b, unsigned int ub, char cb, long *q) { int t = gi3; glp[t] = (gu ? gl : gl2); }
void sp_lPlh(int b, unsigned int ub, char cb, long *q) { int t = gi3; glp[t] = -glb[2]; }
void sp_lPli(int b, unsigned int ub, char cb, long *q) { int t = gi3; glp[t] = gl3 = gl + gl2; }
void sp_lPlj(int b, unsigned int ub, char cb, long *q) { int t = gi3; glp[t] = gl3 = 7; }
void sp_lPlk(int b, unsigned int ub, char cb, long *q) { int t = gi3; glp[t] += gl; }
void sp_lPlm(int b, unsigned int ub, char cb, long *q) { int t = gi3; glp[t] ^= gl + gl2; }
void sp_lPln(int b, unsigned int ub, char cb, long *q) { int t = gi3; glp[t] -= 9; }
void sp_lPlo(int b, unsigned int ub, char cb, long *q) { int t = gi3; glp[t] <<= 1; }
void sp_lPlp(int b, unsigned int ub, char cb, long *q) { int t = gi3; glp[t]++; }
void sp_lPlq(int b, unsigned int ub, char cb, long *q) { int t = gi3; --glp[t]; }
void sp_lPlr(int b, unsigned int ub, char cb, long *q) { int t = gi3; gl3 = glp[t]++; }
void sp_lPls(int b, unsigned int ub, char cb, long *q) { int t = gi3; gl3 = ++glp[t]; }
void sp_lPlt(int b, unsigned int ub, char cb, long *q) { int t = gi3; gl3 = glp[t]--; }
void sp_lPna(int b, unsigned int ub, char cb, long *q) { glp[-2] = 5; }
void sp_lPnc(int b, unsigned int ub, char cb, long *q) { glp[-2] = gl + gl2; }
void sp_lPnd(int b, unsigned int ub, char cb, long *q) { glp[-2] = gl * gl2; }
void sp_lPne(int b, unsigned int ub, char cb, long *q) { glp[-2] = rl(); }
void sp_lPni(int b, unsigned int ub, char cb, long *q) { glp[-2] = gl3 = gl + gl2; }
void sp_lPnj(int b, unsigned int ub, char cb, long *q) { glp[-2] = gl3 = 7; }
void sp_lPnk(int b, unsigned int ub, char cb, long *q) { glp[-2] += gl; }
void sp_lPnm(int b, unsigned int ub, char cb, long *q) { glp[-2] ^= gl + gl2; }
void sp_lPnp(int b, unsigned int ub, char cb, long *q) { glp[-2]++; }
void sp_lPnr(int b, unsigned int ub, char cb, long *q) { gl3 = glp[-2]++; }
void sp_lQka(int b, unsigned int ub, char cb, long *q) { q[3] = 5; }
void sp_lQkb(int b, unsigned int ub, char cb, long *q) { q[3] = gl; }
void sp_lQkc(int b, unsigned int ub, char cb, long *q) { q[3] = gl + gl2; }
void sp_lQkd(int b, unsigned int ub, char cb, long *q) { q[3] = gl * gl2; }
void sp_lQke(int b, unsigned int ub, char cb, long *q) { q[3] = rl(); }
void sp_lQkf(int b, unsigned int ub, char cb, long *q) { q[3] = gl >> cb; }
void sp_lQkg(int b, unsigned int ub, char cb, long *q) { q[3] = (gu ? gl : gl2); }
void sp_lQkh(int b, unsigned int ub, char cb, long *q) { q[3] = -glb[2]; }
void sp_lQki(int b, unsigned int ub, char cb, long *q) { q[3] = gl3 = gl + gl2; }
void sp_lQkj(int b, unsigned int ub, char cb, long *q) { q[3] = gl3 = 7; }
void sp_lQkk(int b, unsigned int ub, char cb, long *q) { q[3] += gl; }
void sp_lQkm(int b, unsigned int ub, char cb, long *q) { q[3] ^= gl + gl2; }
void sp_lQkn(int b, unsigned int ub, char cb, long *q) { q[3] -= 9; }
void sp_lQko(int b, unsigned int ub, char cb, long *q) { q[3] <<= 1; }
void sp_lQkp(int b, unsigned int ub, char cb, long *q) { q[3]++; }
void sp_lQkq(int b, unsigned int ub, char cb, long *q) { --q[3]; }
void sp_lQkr(int b, unsigned int ub, char cb, long *q) { gl3 = q[3]++; }
void sp_lQks(int b, unsigned int ub, char cb, long *q) { gl3 = ++q[3]; }
void sp_lQkt(int b, unsigned int ub, char cb, long *q) { gl3 = q[3]--; }
void sp_lQKa(int b, unsigned int ub, char cb, long *q) { q[0x8001u] = 5; }
void sp_lQKb(int b, unsigned int ub, char cb, long *q) { q[0x8001u] = gl; }
void sp_lQKc(int b, unsigned int ub, char cb, long *q) { q[0x8001u] = gl + gl2; }
void sp_lQKd(int b, unsigned int ub, char cb, long *q) { q[0x8001u] = gl * gl2; }
void sp_lQKe(int b, unsigned int ub, char cb, long *q) { q[0x8001u] = rl(); }
void sp_lQKf(int b, unsigned int ub, char cb, long *q) { q[0x8001u] = gl >> cb; }
void sp_lQKg(int b, unsigned int ub, char cb, long *q) { q[0x8001u] = (gu ? gl : gl2); }
void sp_lQKh(int b, unsigned int ub, char cb, long *q) { q[0x8001u] = -glb[2]; }
void sp_lQKi(int b, unsigned int ub, char cb, long *q) { q[0x8001u] = gl3 = gl + gl2; }
void sp_lQKj(int b, unsigned int ub, char cb, long *q) { q[0x8001u] = gl3 = 7; }
void sp_lQKk(int b, unsigned int ub, char cb, long *q) { q[0x8001u] += gl; }
void sp_lQKm(int b, unsigned int ub, char cb, long *q) { q[0x8001u] ^= gl + gl2; }
void sp_lQKn(int b, unsigned int ub, char cb, long *q) { q[0x8001u] -= 9; }
void sp_lQKo(int b, unsigned int ub, char cb, long *q) { q[0x8001u] <<= 1; }
void sp_lQKp(int b, unsigned int ub, char cb, long *q) { q[0x8001u]++; }
void sp_lQKq(int b, unsigned int ub, char cb, long *q) { --q[0x8001u]; }
void sp_lQKr(int b, unsigned int ub, char cb, long *q) { gl3 = q[0x8001u]++; }
void sp_lQKs(int b, unsigned int ub, char cb, long *q) { gl3 = ++q[0x8001u]; }
void sp_lQKt(int b, unsigned int ub, char cb, long *q) { gl3 = q[0x8001u]--; }
void sp_lQpa(int b, unsigned int ub, char cb, long *q) { q[b] = 5; }
void sp_lQpb(int b, unsigned int ub, char cb, long *q) { q[b] = gl; }
void sp_lQpc(int b, unsigned int ub, char cb, long *q) { q[b] = gl + gl2; }
void sp_lQpd(int b, unsigned int ub, char cb, long *q) { q[b] = gl * gl2; }
void sp_lQpe(int b, unsigned int ub, char cb, long *q) { q[b] = rl(); }
void sp_lQpf(int b, unsigned int ub, char cb, long *q) { q[b] = gl >> cb; }
void sp_lQpg(int b, unsigned int ub, char cb, long *q) { q[b] = (gu ? gl : gl2); }
void sp_lQph(int b, unsigned int ub, char cb, long *q) { q[b] = -glb[2]; }
void sp_lQpi(int b, unsigned int ub, char cb, long *q) { q[b] = gl3 = gl + gl2; }
void sp_lQpj(int b, unsigned int ub, char cb, long *q) { q[b] = gl3 = 7; }
void sp_lQpk(int b, unsigned int ub, char cb, long *q) { q[b] += gl; }
void sp_lQpm(int b, unsigned int ub, char cb, long *q) { q[b] ^= gl + gl2; }
void sp_lQpn(int b, unsigned int ub, char cb, long *q) { q[b] -= 9; }
void sp_lQpo(int b, unsigned int ub, char cb, long *q) { q[b] <<= 1; }
void sp_lQpp(int b, unsigned int ub, char cb, long *q) { q[b]++; }
void sp_lQpq(int b, unsigned int ub, char cb, long *q) { --q[b]; }
void sp_lQpr(int b, unsigned int ub, char cb, long *q) { gl3 = q[b]++; }
void sp_lQps(int b, unsigned int ub, char cb, long *q) { gl3 = ++q[b]; }
void sp_lQpt(int b, unsigned int ub, char cb, long *q) { gl3 = q[b]--; }
void sp_lQca(int b, unsigned int ub, char cb, long *q) { q[cb] = 5; }
void sp_lQcc(int b, unsigned int ub, char cb, long *q) { q[cb] = gl + gl2; }
void sp_lQcd(int b, unsigned int ub, char cb, long *q) { q[cb] = gl * gl2; }
void sp_lQce(int b, unsigned int ub, char cb, long *q) { q[cb] = rl(); }
void sp_lQci(int b, unsigned int ub, char cb, long *q) { q[cb] = gl3 = gl + gl2; }
void sp_lQcj(int b, unsigned int ub, char cb, long *q) { q[cb] = gl3 = 7; }
void sp_lQck(int b, unsigned int ub, char cb, long *q) { q[cb] += gl; }
void sp_lQcm(int b, unsigned int ub, char cb, long *q) { q[cb] ^= gl + gl2; }
void sp_lQcp(int b, unsigned int ub, char cb, long *q) { q[cb]++; }
void sp_lQcr(int b, unsigned int ub, char cb, long *q) { gl3 = q[cb]++; }
void sp_lQna(int b, unsigned int ub, char cb, long *q) { q[-2] = 5; }
void sp_lQnc(int b, unsigned int ub, char cb, long *q) { q[-2] = gl + gl2; }
void sp_lQnd(int b, unsigned int ub, char cb, long *q) { q[-2] = gl * gl2; }
void sp_lQne(int b, unsigned int ub, char cb, long *q) { q[-2] = rl(); }
void sp_lQni(int b, unsigned int ub, char cb, long *q) { q[-2] = gl3 = gl + gl2; }
void sp_lQnj(int b, unsigned int ub, char cb, long *q) { q[-2] = gl3 = 7; }
void sp_lQnk(int b, unsigned int ub, char cb, long *q) { q[-2] += gl; }
void sp_lQnm(int b, unsigned int ub, char cb, long *q) { q[-2] ^= gl + gl2; }
void sp_lQnp(int b, unsigned int ub, char cb, long *q) { q[-2]++; }
void sp_lQnr(int b, unsigned int ub, char cb, long *q) { gl3 = q[-2]++; }
void sp_lSka(int b, unsigned int ub, char cb, long *q) { gps->mla[3] = 5; }
void sp_lSkb(int b, unsigned int ub, char cb, long *q) { gps->mla[3] = gl; }
void sp_lSkc(int b, unsigned int ub, char cb, long *q) { gps->mla[3] = gl + gl2; }
void sp_lSkd(int b, unsigned int ub, char cb, long *q) { gps->mla[3] = gl * gl2; }
void sp_lSke(int b, unsigned int ub, char cb, long *q) { gps->mla[3] = rl(); }
void sp_lSkf(int b, unsigned int ub, char cb, long *q) { gps->mla[3] = gl >> cb; }
void sp_lSkg(int b, unsigned int ub, char cb, long *q) { gps->mla[3] = (gu ? gl : gl2); }
void sp_lSkh(int b, unsigned int ub, char cb, long *q) { gps->mla[3] = -glb[2]; }
void sp_lSki(int b, unsigned int ub, char cb, long *q) { gps->mla[3] = gl3 = gl + gl2; }
void sp_lSkj(int b, unsigned int ub, char cb, long *q) { gps->mla[3] = gl3 = 7; }
void sp_lSkk(int b, unsigned int ub, char cb, long *q) { gps->mla[3] += gl; }
void sp_lSkm(int b, unsigned int ub, char cb, long *q) { gps->mla[3] ^= gl + gl2; }
void sp_lSkn(int b, unsigned int ub, char cb, long *q) { gps->mla[3] -= 9; }
void sp_lSko(int b, unsigned int ub, char cb, long *q) { gps->mla[3] <<= 1; }
void sp_lSkp(int b, unsigned int ub, char cb, long *q) { gps->mla[3]++; }
void sp_lSkq(int b, unsigned int ub, char cb, long *q) { --gps->mla[3]; }
void sp_lSkr(int b, unsigned int ub, char cb, long *q) { gl3 = gps->mla[3]++; }
void sp_lSks(int b, unsigned int ub, char cb, long *q) { gl3 = ++gps->mla[3]; }
void sp_lSkt(int b, unsigned int ub, char cb, long *q) { gl3 = gps->mla[3]--; }
void sp_lSpa(int b, unsigned int ub, char cb, long *q) { gps->mla[b] = 5; }
void sp_lSpb(int b, unsigned int ub, char cb, long *q) { gps->mla[b] = gl; }
void sp_lSpc(int b, unsigned int ub, char cb, long *q) { gps->mla[b] = gl + gl2; }
void sp_lSpd(int b, unsigned int ub, char cb, long *q) { gps->mla[b] = gl * gl2; }
void sp_lSpe(int b, unsigned int ub, char cb, long *q) { gps->mla[b] = rl(); }
void sp_lSpf(int b, unsigned int ub, char cb, long *q) { gps->mla[b] = gl >> cb; }
void sp_lSpg(int b, unsigned int ub, char cb, long *q) { gps->mla[b] = (gu ? gl : gl2); }
void sp_lSph(int b, unsigned int ub, char cb, long *q) { gps->mla[b] = -glb[2]; }
void sp_lSpi(int b, unsigned int ub, char cb, long *q) { gps->mla[b] = gl3 = gl + gl2; }
void sp_lSpj(int b, unsigned int ub, char cb, long *q) { gps->mla[b] = gl3 = 7; }
void sp_lSpk(int b, unsigned int ub, char cb, long *q) { gps->mla[b] += gl; }
void sp_lSpm(int b, unsigned int ub, char cb, long *q) { gps->mla[b] ^= gl + gl2; }
void sp_lSpn(int b, unsigned int ub, char cb, long *q) { gps->mla[b] -= 9; }
void sp_lSpo(int b, unsigned int ub, char cb, long *q) { gps->mla[b] <<= 1; }
void sp_lSpp(int b, unsigned int ub, char cb, long *q) { gps->mla[b]++; }
void sp_lSpq(int b, unsigned int ub, char cb, long *q) { --gps->mla[b]; }
void sp_lSpr(int b, unsigned int ub, char cb, long *q) { gl3 = gps->mla[b]++; }
void sp_lSps(int b, unsigned int ub, char cb, long *q) { gl3 = ++gps->mla[b]; }
void sp_lSpt(int b, unsigned int ub, char cb, long *q) { gl3 = gps->mla[b]--; }
void sp_lD_a(int b, unsigned int ub, char cb, long *q) { *glp = 5; }
void sp_lD_b(int b, unsigned int ub, char cb, long *q) { *glp = gl; }
void sp_lD_c(int b, unsigned int ub, char cb, long *q) { *glp = gl + gl2; }
void sp_lD_d(int b, unsigned int ub, char cb, long *q) { *glp = gl * gl2; }
void sp_lD_e(int b, unsigned int ub, char cb, long *q) { *glp = rl(); }
void sp_lD_f(int b, unsigned int ub, char cb, long *q) { *glp = gl >> cb; }
void sp_lD_g(int b, unsigned int ub, char cb, long *q) { *glp = (gu ? gl : gl2); }
void sp_lD_h(int b, unsigned int ub, char cb, long *q) { *glp = -glb[2]; }
void sp_lD_i(int b, unsigned int ub, char cb, long *q) { *glp = gl3 = gl + gl2; }
void sp_lD_j(int b, unsigned int ub, char cb, long *q) { *glp = gl3 = 7; }
void sp_lD_k(int b, unsigned int ub, char cb, long *q) { *glp += gl; }
void sp_lD_m(int b, unsigned int ub, char cb, long *q) { *glp ^= gl + gl2; }
void sp_lD_n(int b, unsigned int ub, char cb, long *q) { *glp -= 9; }
void sp_lD_o(int b, unsigned int ub, char cb, long *q) { *glp <<= 1; }
void sp_lD_p(int b, unsigned int ub, char cb, long *q) { *glp++; }
void sp_lD_q(int b, unsigned int ub, char cb, long *q) { --*glp; }
void sp_lD_r(int b, unsigned int ub, char cb, long *q) { gl3 = *glp++; }
void sp_lD_s(int b, unsigned int ub, char cb, long *q) { gl3 = ++*glp; }
void sp_lD_t(int b, unsigned int ub, char cb, long *q) { gl3 = *glp--; }
void sp_lE_a(int b, unsigned int ub, char cb, long *q) { *q = 5; }
void sp_lE_b(int b, unsigned int ub, char cb, long *q) { *q = gl; }
void sp_lE_c(int b, unsigned int ub, char cb, long *q) { *q = gl + gl2; }
void sp_lE_d(int b, unsigned int ub, char cb, long *q) { *q = gl * gl2; }
void sp_lE_e(int b, unsigned int ub, char cb, long *q) { *q = rl(); }
void sp_lE_f(int b, unsigned int ub, char cb, long *q) { *q = gl >> cb; }
void sp_lE_g(int b, unsigned int ub, char cb, long *q) { *q = (gu ? gl : gl2); }
void sp_lE_h(int b, unsigned int ub, char cb, long *q) { *q = -glb[2]; }
void sp_lE_i(int b, unsigned int ub, char cb, long *q) { *q = gl3 = gl + gl2; }
void sp_lE_j(int b, unsigned int ub, char cb, long *q) { *q = gl3 = 7; }
void sp_lE_k(int b, unsigned int ub, char cb, long *q) { *q += gl; }
void sp_lE_m(int b, unsigned int ub, char cb, long *q) { *q ^= gl + gl2; }
void sp_lE_n(int b, unsigned int ub, char cb, long *q) { *q -= 9; }
void sp_lE_o(int b, unsigned int ub, char cb, long *q) { *q <<= 1; }
void sp_lE_p(int b, unsigned int ub, char cb, long *q) { *q++; }
void sp_lE_q(int b, unsigned int ub, char cb, long *q) { --*q; }
void sp_lE_r(int b, unsigned int ub, char cb, long *q) { gl3 = *q++; }
void sp_lE_s(int b, unsigned int ub, char cb, long *q) { gl3 = ++*q; }
void sp_lE_t(int b, unsigned int ub, char cb, long *q) { gl3 = *q--; }
