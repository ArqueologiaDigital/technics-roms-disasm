/* Functions of audio/semenu_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit). */
extern unsigned char ram_20c33, ram_20c35, ram_20bf3[];
extern unsigned char __near SEQ_RTMCFG;
int SeMenu_CheckObjEnabled(unsigned char a) { int r = -1; if (ram_20c33 == a) r = 0; return r; }
int SeMenu_CheckObjValid(unsigned char a) { int r = -1; if (ram_20c35 == a) r = 0; return r; }
void SeMenu_SetEditEnable(unsigned char a) { if (a == 1) SEQ_RTMCFG |= 0x04; else SEQ_RTMCFG &= ~0x04; }
void SeMenu_SetNameBufferChar(unsigned char i, unsigned char c) { if (i > 15) return; ram_20bf3[i] = c; }
