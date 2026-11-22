/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_20r2m129a.c (2026-11-21-5-p6-r60)
   sha256 ecb5f4e33cecbae0de1edbade70c67a9152a2da39e8d52ffb3da4768fc76318c (tar-sha256); compiled at -O3 -XS -Xr */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_StorePartParam(int, int);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamField(unsigned char *f);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_RegisterElement_Extended(int, int, unsigned char *, unsigned int);
extern void __cdecl SeTitle_DrawField(int, int);
extern void SeMenu_BindDialToColumn(int col);
extern unsigned char GUI_DisplayStructData_0x1342[];
extern unsigned char GUI_DisplayStructData_0x1362[];
void SePitPit1_OnColumn6(unsigned char a)
{
	unsigned char mode;
	unsigned char idx;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;
	unsigned char id;

	SeMenu_LoadPartParam(13, &mode);
	if (mode == 1) {
		SeMenu_LoadPartParam(14, &idx);
		idx &= 31;
		p = buf;
		p[0] = GUI_DisplayStructData_0x1342[idx];
		p[6] = 31;
		p[7] = 0;
		p[8] = 12;
		p[9] = 0;
		SeMenu_SwitchToValueStep(a, p + 10);
		if (SeMenu_StepParamField(buf) == 1) {
			idx = GUI_DisplayStructData_0x1362[buf[3]];
			SeMenu_StorePartParam(14, idx);
			SeMenu_RegisterElement_Extended(0, 19, &idx, 31);
			SeTitle_DrawField(39, 14);
		}
	} else {
		if (mode == 2) {
			blk = 15;
			id = 41;
			SeMenu_LoadPartParam(blk, buf);
			p = buf;
			p[6] = 15;
			p[7] = 0;
			p[8] = 10;
		} else {
			blk = 16;
			id = 42;
			SeMenu_LoadPartParam(blk, buf);
			p = buf;
			p[6] = 15;
			if (mode == 3)
				p[7] = 4;
			else
				p[7] = 0;
			p[8] = 10;
		}
		p[9] = 6;
		SeMenu_SwitchToValueStep(a, &buf[10]);
		SeMenu_StepParamFieldAndSend(39, blk, 0, id, buf);
	}
	SeMenu_BindDialToColumn(6);
}
