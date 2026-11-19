/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/semenu_routines_m0.c (2026-11-19-92-p6-r57)
   sha256 d21354b54e3bb5171c3b07a984a8f81dd0ec305cdeb581ca6fd4d7378cbaaec2 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeAPE_J12=SeMenu_ApplyPartEdit_AltStore_Join12 */
extern void SeMenu_LoadPartParam(int, unsigned char *);
extern void SeMenu_SwitchToValueStep(int, unsigned char *);
extern unsigned char SeMenu_StepParamFieldAndSend(int, int, int, int, unsigned char *);
extern void SeMenu_BindDialToColumn(int col);
extern void SeMenu_ValidatePartNumber(unsigned char *part);
extern void SeMenu_DrawPitFilEnvGraph(void);
void SeAPE_J12(unsigned char a, unsigned char c, unsigned char e)
{
	unsigned char v;
	unsigned char part;
	unsigned char buf[12];
	unsigned char blk;
	unsigned char id;

	SeMenu_ValidatePartNumber(&part);
	SeMenu_LoadPartParam(0, &v);
	if (v == 0) {
		blk = 10;
		SeMenu_LoadPartParam(10, buf);
		buf[6] = 255;
		buf[7] = 0;
		buf[8] = 50;
		buf[9] = 206;
		id = c;
	} else {
		blk = 7;
		SeMenu_LoadPartParam(7, buf);
		buf[6] = 127;
		buf[7] = 0;
		buf[8] = 100;
		buf[9] = 0;
		id = e;
	}
	SeMenu_SwitchToValueStep(a, &buf[10]);
	SeMenu_StepParamFieldAndSend(55, blk, part, id, buf);
	SeMenu_DrawPitFilEnvGraph();
	SeMenu_BindDialToColumn(5);
}
