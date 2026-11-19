/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_14m152a.c (2026-11-19-92-p6-r57)
   sha256 22c7b9a48171c72ebec27ce931d00035feba8eb9fe66fe2fd75f038fbcd9b8ea (tar-sha256); compiled at -Xr
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
