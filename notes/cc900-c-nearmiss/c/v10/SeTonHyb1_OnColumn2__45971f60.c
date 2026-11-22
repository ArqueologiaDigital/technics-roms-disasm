/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sound_editor_ui_m0.c (2026-11-21-2-p6-r58)
   sha256 45971f6044708c2f71e9705e4cbb9392e800497033fda8c2c562d0709bbd36a0 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeM_CWU_S3H11=SeMenu_CopyWriteUpdate_Step3_Helper11 */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeM_CWU_S3H11(int, int, unsigned char *);
extern void SeMenu_GetEntryCount(unsigned char *);
extern void SeMenu_GetGroupFirstToneIndex(int, int, unsigned int *);
extern void SeMenu_SendToneIndex(int, int, unsigned int);
extern void SeMenu_InitDisplayField_Alt();
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
