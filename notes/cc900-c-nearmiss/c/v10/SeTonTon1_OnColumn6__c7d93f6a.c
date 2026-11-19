/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sound_editor_ui_m0.c (2026-11-19-92-p6-r57)
   sha256 c7d93f6a790c2532ab437973621f3de346642688ec71d7501141927852450910 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_StoreParamByte(int, int);
void SeTonTon1_OnColumn6(unsigned char a)
{
	unsigned char t;
	unsigned char buf[12];
	unsigned char *p;
	unsigned char blk;

	SeMenu_LoadPartParam(0, &t);
	blk = t * 3;
	blk--;
	SeMenu_LoadPartParam(blk, buf);
	p = buf;
	p[6] = 127;
	p[7] = 0;
	p[8] = 127;
	p[9] = 0;
	SeMenu_SwitchToValueStep(a, p + 10);
	if (SeMenu_StepParamFieldAndSend(34, blk, t, 23, buf) == 1)
		SeMenu_StoreParamByte(t, buf[3]);
	SeMenu_BindDialToColumn(6);
}
