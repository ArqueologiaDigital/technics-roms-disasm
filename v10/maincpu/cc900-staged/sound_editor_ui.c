/* Functions of audio/sound_editor_ui.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeM_CWU_S3H11(int, int, unsigned char *);
extern void SeMenu_GetEntryCount(unsigned char *);
extern void SeMenu_GetGroupFirstToneIndex(int, int, unsigned int *);
extern void SeMenu_SendToneIndex(int, int, unsigned int);
extern void SeMenu_InitDisplayField_Alt();
extern void SeMenu_GetToneIndex(int, unsigned int *);
extern void SeMenu_GetWordEntryCount(unsigned int *);
extern void SeWrtSnd_SetupNamingPage_Join(void);
extern void SeWrtSnd_SetupNamingPage_Join2(void);
extern void SeWrtSnd_SetupNamingPage_Join3(void);
extern void SeWrtSnd_SetupNamingPage_Join5(void);
extern void SeWrtSnd_SetupNamingPage_Join6(void);
extern void SeWrtSnd_SetupNamingPage_Join7(void);
extern void SeWrtSnd_SetupNamingPage_Join8(void);
extern void SeWrtSnd_ClearName_Join(void);
extern void SeWrtSnd_OnColumn1(unsigned char a);
extern void SeWrtSnd_OnColumn2(unsigned char a);
extern void SeWrtSnd_OnColumn3(unsigned char a);
extern void SeWrtSnd_OnColumn4(unsigned char a);
extern void SeWrtSnd_OnColumn5(unsigned char a);
extern void SeWrtSnd_OnColumn6(unsigned char a);
extern void SeWrtSnd_OnColumn8(unsigned char a);
extern void SeWrtSnd_OnSideRow2(unsigned char a);
extern void SeTonHyb1_OnColumn2(unsigned char a);
extern void SeTonHyb1_OnColumn3(unsigned char a);

void SeTonHyb1_OnColumn2(unsigned char a)
{
	unsigned char idx;
	unsigned char n;
	unsigned char part;
	unsigned char p;
	unsigned int tone;

	SeMenu_LoadPartParam(0, &p);
	SeMenu_ValidatePartNumber(&part);
	SeM_CWU_S3H11(1, p, &idx);
	SeMenu_GetEntryCount(&n);
	if ((a & 0x7f) == 0) {
		if (idx >= (unsigned char)(n - 1))
			return;
		idx++;
	} else {
		if (idx == 0)
			return;
		idx--;
	}
	SeMenu_GetGroupFirstToneIndex(1, idx, &tone);
	SeMenu_SendToneIndex(part, p, tone);
	SeMenu_InitDisplayField_Alt(part, p, 16);
	SeMenu_BindDialToColumn(2);
}

void SeTonHyb1_OnColumn3(unsigned char a)
{
	unsigned char part;
	unsigned char p;
	unsigned int idx;
	unsigned int cnt;

	SeMenu_LoadPartParam(0, &p);
	SeMenu_ValidatePartNumber(&part);
	SeMenu_GetToneIndex(p, &idx);
	SeMenu_GetWordEntryCount(&cnt);
	if ((a & 0x7f) == 0) {
		if (idx >= cnt - 1)
			return;
		idx++;
	} else {
		if (idx == 0)
			return;
		idx--;
	}
	SeMenu_SendToneIndex(part, p, idx);
	SeMenu_InitDisplayField_Alt(part, p, 16);
	SeMenu_BindDialToColumn(3);
}

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
