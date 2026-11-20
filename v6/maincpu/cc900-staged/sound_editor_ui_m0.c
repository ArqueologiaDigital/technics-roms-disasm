/* Functions of audio/sound_editor_ui.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeWrtSnd_ClearName_Join SeWrtSnd_SetupNamingPage_Join SeWrtSnd_SetupNamingPage_Join2 SeWrtSnd_SetupNamingPage_Join3 SeWrtSnd_SetupNamingPage_Join5 SeWrtSnd_SetupNamingPage_Join6 SeWrtSnd_SetupNamingPage_Join7 SeWrtSnd_SetupNamingPage_Join8 */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeWrtSnd_SetupNamingPage_Join6(void);
extern void SeWrtSnd_OnColumn1(unsigned char a);
extern void SeWrtSnd_SetupNamingPage_Join7(void);
extern void SeWrtSnd_OnColumn2(unsigned char a);
extern void SeWrtSnd_SetupNamingPage_Join8(void);
extern void SeWrtSnd_OnColumn3(unsigned char a);
extern void SeWrtSnd_SetupNamingPage_Join(void);
extern void SeWrtSnd_OnColumn4(unsigned char a);
extern void SeWrtSnd_SetupNamingPage_Join2(void);
extern void SeWrtSnd_OnColumn5(unsigned char a);
extern void SeWrtSnd_SetupNamingPage_Join3(void);
extern void SeWrtSnd_OnColumn6(unsigned char a);
extern void SeWrtSnd_SetupNamingPage_Join5(void);
extern void SeWrtSnd_OnColumn8(unsigned char a);
extern void SeWrtSnd_ClearName_Join(void);
extern void SeWrtSnd_OnSideRow2(unsigned char a);

/* cc900-name: SeM_CWU_S3H11=SeMenu_CopyWriteUpdate_Step3_Helper11 */


void SeWrtSnd_OnColumn1(unsigned char a) { SeWrtSnd_SetupNamingPage_Join6(); }

void SeWrtSnd_OnColumn2(unsigned char a) { SeWrtSnd_SetupNamingPage_Join7(); }

void SeWrtSnd_OnColumn3(unsigned char a) { SeWrtSnd_SetupNamingPage_Join8(); }

void SeWrtSnd_OnColumn4(unsigned char a) { SeWrtSnd_SetupNamingPage_Join(); }

void SeWrtSnd_OnColumn5(unsigned char a) { SeWrtSnd_SetupNamingPage_Join2(); }

void SeWrtSnd_OnColumn6(unsigned char a) { SeWrtSnd_SetupNamingPage_Join3(); }

void SeWrtSnd_OnColumn8(unsigned char a) { SeWrtSnd_SetupNamingPage_Join5(); }

void SeWrtSnd_OnSideRow2(unsigned char a)
{
	if (a != 0)
		return;
	SeWrtSnd_ClearName_Join();
}
