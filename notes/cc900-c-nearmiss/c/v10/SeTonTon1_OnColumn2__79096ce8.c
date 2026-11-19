/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_13m152a.c (2026-11-19-83-p6-r56)
   sha256 79096ce836227de2ba8486e9940bda9297d86c4371b139b1283c81267b96f5ef (tar-sha256); compiled at -Xr
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
