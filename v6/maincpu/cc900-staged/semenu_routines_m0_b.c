/* Functions of audio/semenu_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void SeAPE_J8();
extern void SePitEnv1_OnColumn1(unsigned char a);
extern void SeAPE_J9();
extern void SePitEnv1_OnColumn2(unsigned char a);
extern void SeAPE_J10();
extern void SePitEnv1_OnColumn3(unsigned char a);
extern void SeAPE_J11();
extern void SePitEnv1_OnColumn4(unsigned char a);
extern void SeAPE_J12();
extern void SePitEnv1_OnColumn5(unsigned char a);
extern void SeAPE_J13();
extern void SePitEnv1_OnColumn6(unsigned char a);
extern void SeAPE_J14();
extern void SePitEnv1_OnColumn7(unsigned char a);
#define TT_SEPITENV1 0x28
extern void SeAPE_J7();
extern void SeMenu_SendEvent(int title, int refresh);
extern unsigned char SeMenu_SelectPartIfEnabled(int p);
extern void SePitEnv1_OnSideRow4(unsigned char a);
extern void SePitEnv1_OnSideRow5(unsigned char a);
extern void SeAPE_J15();
extern void SePitEnv2_OnColumn2(unsigned char a);
extern void SeAPE_J16();
extern void SePitEnv2_OnColumn3(unsigned char a);
extern void SeAPE_J17();
extern void SePitEnv2_OnColumn4(unsigned char a);
extern void SeAPE_J19();
extern void SePitEnv2_OnColumn7(unsigned char a);
extern void SeAPE_J20();
extern void SePitEnv2_OnColumn8(unsigned char a);
extern void SeAPE_J();
extern void SePitLfo1_OnColumn3(unsigned char a);
extern void SeAPE_J2();
extern void SePitLfo1_OnColumn4(unsigned char a);
extern void SeAPE_J3();
extern void SePitLfo1_OnColumn5(unsigned char a);
extern void SeAPE_J4();
extern void SePitLfo1_OnColumn6(unsigned char a);
extern void SeAPE_J5();
extern void SePitLfo1_OnColumn7(unsigned char a);
extern void SeAPE_J6();
extern void SePitLfo1_OnColumn8(unsigned char a);

/* cc900-name: SeAPE_J8=SeMenu_ApplyPartEdit_AltStore_Join8 */
void SePitEnv1_OnColumn1(unsigned char a) { SeAPE_J8(a, 9, 0); }

/* cc900-name: SeAPE_J9=SeMenu_ApplyPartEdit_AltStore_Join9 */
void SePitEnv1_OnColumn2(unsigned char a) { SeAPE_J9(a, 10, 0); }

/* cc900-name: SeAPE_J10=SeMenu_ApplyPartEdit_AltStore_Join10 */
void SePitEnv1_OnColumn3(unsigned char a) { SeAPE_J10(a, 8, 11); }

/* cc900-name: SeAPE_J11=SeMenu_ApplyPartEdit_AltStore_Join11 */
void SePitEnv1_OnColumn4(unsigned char a) { SeAPE_J11(a, 12, 0); }

/* cc900-name: SeAPE_J12=SeMenu_ApplyPartEdit_AltStore_Join12 */
void SePitEnv1_OnColumn5(unsigned char a) { SeAPE_J12(a, 16, 13); }

/* cc900-name: SeAPE_J13=SeMenu_ApplyPartEdit_AltStore_Join13 */
void SePitEnv1_OnColumn6(unsigned char a) { SeAPE_J13(a, 14, 0); }

/* cc900-name: SeAPE_J14=SeMenu_ApplyPartEdit_AltStore_Join14 */
void SePitEnv1_OnColumn7(unsigned char a) { SeAPE_J14(a, 7, 15); }

/* cc900-name: SeAPE_J7=SeMenu_ApplyPartEdit_AltStore_Join7 */
void SePitEnv1_OnSideRow4(unsigned char a)
{
	if (a == 0)
		SeAPE_J7(0);
	else if (SeMenu_SelectPartIfEnabled(3) != 0)
		SeMenu_SendEvent(TT_SEPITENV1, 1);
}

/* cc900-name: SeAPE_J7=SeMenu_ApplyPartEdit_AltStore_Join7 */
void SePitEnv1_OnSideRow5(unsigned char a)
{
	if (a == 0)
		SeAPE_J7(1);
	else if (SeMenu_SelectPartIfEnabled(4) != 0)
		SeMenu_SendEvent(TT_SEPITENV1, 1);
}

/* cc900-name: SeAPE_J15=SeMenu_ApplyPartEdit_AltStore_Join15 */
void SePitEnv2_OnColumn2(unsigned char a) { SeAPE_J15(a, 20); }

/* cc900-name: SeAPE_J16=SeMenu_ApplyPartEdit_AltStore_Join16 */
void SePitEnv2_OnColumn3(unsigned char a) { SeAPE_J16(a, 21); }

/* cc900-name: SeAPE_J17=SeMenu_ApplyPartEdit_AltStore_Join17 */
void SePitEnv2_OnColumn4(unsigned char a) { SeAPE_J17(a, 22); }

/* cc900-name: SeAPE_J19=SeMenu_ApplyPartEdit_AltStore_Join19 */
void SePitEnv2_OnColumn7(unsigned char a) { SeAPE_J19(a, 17); }

/* cc900-name: SeAPE_J20=SeMenu_ApplyPartEdit_AltStore_Join20 */
void SePitEnv2_OnColumn8(unsigned char a) { SeAPE_J20(a, 18); }

/* cc900-name: SeAPE_J=SeMenu_ApplyPartEdit_AltStore_Join */
void SePitLfo1_OnColumn3(unsigned char a) { SeAPE_J(a, 1); }

/* cc900-name: SeAPE_J2=SeMenu_ApplyPartEdit_AltStore_Join2 */
void SePitLfo1_OnColumn4(unsigned char a) { SeAPE_J2(a, 1); }

/* cc900-name: SeAPE_J3=SeMenu_ApplyPartEdit_AltStore_Join3 */
void SePitLfo1_OnColumn5(unsigned char a) { SeAPE_J3(a, 1); }

/* cc900-name: SeAPE_J4=SeMenu_ApplyPartEdit_AltStore_Join4 */
void SePitLfo1_OnColumn6(unsigned char a) { SeAPE_J4(a, 1); }

/* cc900-name: SeAPE_J5=SeMenu_ApplyPartEdit_AltStore_Join5 */
void SePitLfo1_OnColumn7(unsigned char a) { SeAPE_J5(a, 1); }

/* cc900-name: SeAPE_J6=SeMenu_ApplyPartEdit_AltStore_Join6 */
void SePitLfo1_OnColumn8(unsigned char a) { SeAPE_J6(a, 1); }
