/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sound_editor_ui_m0.c (2026-11-19-92-p6-r57)
   sha256 c7d93f6a790c2532ab437973621f3de346642688ec71d7501141927852450910 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_SendPartToneIndex(int, unsigned int);
extern void SeMenu_InitDisplayField();
extern void SeMenu_GetToneIndex(int, unsigned int *);
extern void SeMenu_GetWordEntryCount(unsigned int *);
void SeTonTon1_OnColumn3(unsigned char a)
{
	unsigned char p;
	unsigned int idx;
	unsigned int cnt;

	SeMenu_LoadPartParam(0, &p);
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
	SeMenu_SendPartToneIndex(p, idx);
	SeMenu_InitDisplayField(p, 16);
	SeMenu_BindDialToColumn(3);
}
