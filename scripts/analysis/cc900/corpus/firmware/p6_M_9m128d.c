/* Phase 6, lane_p6 helper M, round 9, module 128 (display/scoop_editor_data.s), form d: the HPF+Q page's column
   and side-row stubs (the shape of the matched SeFilLpq1_OnColumn2/3/4): widen the switch and either call an
   edit body then jump to SeMenu_DrawFilterGraph(1, 0), or tail-jump (jrl) to the LPF+Q page's shared bodies with
   int arguments (bodies called without a prototype: K&R declarations). */
/* cc900-module: SeFilLpq1_OnColumn3_Join21 SeFilLpq1_OnColumn4_Join22 SeFilLpq1_OnColumn4_Join23 SeFilLpq1_OnColumn4_Join24 SeFilLpq1_OnColumn4_Join25 SeFilLpq1_OnColumn4_Join26 SeFilLpq1_OnColumn4_Join27 SeFilLpq1_OnColumn4_Join28 SeFilLpq1_OnSideRow4_Join30 SeMenu_EditFilterCutoff SeMenu_EditFilterResonance */

extern void SeMenu_EditFilterCutoff();
extern void SeMenu_EditFilterResonance();
extern void SeMenu_DrawFilterGraph();
extern void SeFilLpq1_OnColumn3_Join21();
extern void SeFilLpq1_OnColumn4_Join22();
extern void SeFilLpq1_OnColumn4_Join23();
extern void SeFilLpq1_OnColumn4_Join24();
extern void SeFilLpq1_OnColumn4_Join25();
extern void SeFilLpq1_OnColumn4_Join26();
extern void SeFilLpq1_OnColumn4_Join27();
extern void SeFilLpq1_OnColumn4_Join28();
extern void SeFilLpq1_OnSideRow4_Join30();
extern void SeFilHpq1_OnColumn1(unsigned char a);
extern void SeFilHpq1_OnColumn2(unsigned char a);
extern void SeFilHpq1_OnColumn3(unsigned char a);
extern void SeFilHpq1_OnColumn4(unsigned char a);
extern void SeFilHpq1_OnColumn6(unsigned char a);
extern void SeFilHpq1_OnColumn7(unsigned char a);
extern void SeFilHpq1_OnColumn8(unsigned char a);
extern void SeFilHpq1_OnSideRow1(unsigned char a);
extern void SeFilHpq1_OnSideRow2(unsigned char a);
extern void SeFilHpq1_OnSideRow3(unsigned char a);
extern void SeFilHpq1_OnSideRow5(unsigned char a);

void SeFilHpq1_OnColumn1(unsigned char a)
{
	SeMenu_EditFilterCutoff(a, 1, 49);
	SeMenu_DrawFilterGraph(1, 0);
}

void SeFilHpq1_OnColumn2(unsigned char a)
{
	SeMenu_EditFilterResonance(a, 2, 49);
	SeMenu_DrawFilterGraph(1, 0);
}

void SeFilHpq1_OnColumn3(unsigned char a)
{
	SeFilLpq1_OnColumn3_Join21(a, 3, 49);
}

void SeFilHpq1_OnColumn4(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join22(a, 4, 49);
}

void SeFilHpq1_OnColumn6(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join23(a);
}

void SeFilHpq1_OnColumn7(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join24(a);
}

void SeFilHpq1_OnColumn8(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join25(a);
}

void SeFilHpq1_OnSideRow1(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join26(a);
}

void SeFilHpq1_OnSideRow2(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join27(a);
}

void SeFilHpq1_OnSideRow3(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join28(a);
}

void SeFilHpq1_OnSideRow5(unsigned char a)
{
	SeFilLpq1_OnSideRow4_Join30(a);
}
