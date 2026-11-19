/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_14m152a.c (2026-11-19-92-p6-r57)
   sha256 22c7b9a48171c72ebec27ce931d00035feba8eb9fe66fe2fd75f038fbcd9b8ea (tar-sha256); compiled at -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_SendToneIndex(int, int, unsigned int);
extern void SeMenu_InitDisplayField_Alt();
extern void SeMenu_GetToneIndex(int, unsigned int *);
extern void SeMenu_GetWordEntryCount(unsigned int *);
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
