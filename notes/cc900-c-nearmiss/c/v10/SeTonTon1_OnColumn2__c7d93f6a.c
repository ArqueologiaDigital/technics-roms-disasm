/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sound_editor_ui_m0.c (2026-11-19-92-p6-r57)
   sha256 c7d93f6a790c2532ab437973621f3de346642688ec71d7501141927852450910 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeM_CWU_S3H11=SeMenu_CopyWriteUpdate_Step3_Helper11 */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeM_CWU_S3H11(int, int, unsigned char *);
extern void SeMenu_GetEntryCount(unsigned char *);
extern void SeMenu_GetGroupFirstToneIndex(int, int, unsigned int *);
extern void SeMenu_SendPartToneIndex(int, unsigned int);
extern void SeMenu_InitDisplayField();
void SeTonTon1_OnColumn2(unsigned char a)
{
	unsigned char idx;
	unsigned char n;
	unsigned char p;
	unsigned int tone;

	SeMenu_LoadPartParam(0, &p);
	SeM_CWU_S3H11(0, p, &idx);
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
	SeMenu_GetGroupFirstToneIndex(0, idx, &tone);
	SeMenu_SendPartToneIndex(p, tone);
	SeMenu_InitDisplayField(p, 16);
	SeMenu_BindDialToColumn(2);
}
