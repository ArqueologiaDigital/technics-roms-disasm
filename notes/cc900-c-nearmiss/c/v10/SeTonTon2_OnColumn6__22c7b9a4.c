/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_14m152a.c (2026-11-19-92-p6-r57)
   sha256 22c7b9a48171c72ebec27ce931d00035feba8eb9fe66fe2fd75f038fbcd9b8ea (tar-sha256); compiled at -O3 -Xr */
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void SeMenu_ApplyPartEdit(int);
void SeTonTon2_OnColumn6(unsigned char a)
{
	unsigned char part;
	unsigned char v;
	unsigned char step;
	unsigned char blk;
	unsigned char dir;
	unsigned char t;

	&blk;
	SeMenu_ValidatePartNumber(&part);
	blk = part + 5;
	SeMenu_SwitchToValueStep(a, &step);
	dir = a & 0x7f;
	SeMenu_LoadPartParam(blk, &v);
	v &= 0x7f;
	if (dir == 0) {
		if (v >= 127)
			return;
		v += step;
		if (v >= 127)
			v = 127;
	} else {
		if (v == 0)
			return;
		t = v + step;
		v = t;
		if ((signed char)t < 0)
			v = 0;
	}
	SeMenu_StorePartParam(blk, v);
	SeMenu_RegisterElement_Extended(part, 1, &v, 127);
	SeMenu_ApplyPartEdit(part);
	blk = part + 11;
	SeTitle_DrawField(35, blk);
	SeMenu_BindDialToColumn(6);
}
