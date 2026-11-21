/* Phase 6, lane_p6 helper S, round 2 of 2026-11-20, module 129 (audio/semenu_routines.s), form a: first probe of
   SePitPit1_OnColumn6 (no earlier attempt), in the matched SePitPit1_OnColumn4's spelling (p6_M_14m129a.c).
   Read from the hand assembly: mode = part parameter 13 (+16), idx (+14), buf[12] (+2); mode 1 steps the table
   index (parameter 14, masked to 31, buf[0] from the 32-byte table GUI_DisplayStructData_0x1342, range 31 / 0 /
   12 / 0) and on a change stores the mapped value (GUI_DisplayStructData_0x1362[buf[3]]) and re-registers field
   19; modes 2 / 3 / other load block 15 / 16 into buf (range 15, 0 or 4, 10, 6) and step it with
   SeMenu_StepParamFieldAndSend(39, blk, 0, id, buf), blk / id (15 / 41 or 16 / 42) homed in QIZH / QIZL; both
   paths end in SeMenu_BindDialToColumn(6).  Form a: blk declared before id (QIZH = blk in the ROM, as the matched
   Column4's single blk).
*/
/* (no module-local callee: scripts/analysis/cc900/module_calls.py v10) */

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
extern void SePitPit1_OnColumn6(unsigned char a);

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
