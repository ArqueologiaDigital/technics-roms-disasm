/* Phase 6, lane_p6 helper M, round 6, module 128 (display/scoop_editor_data.s), form d: the LPF+Q page's column
   stubs.  Each widens the column switch (extz wa) and passes two int constants to a body that reads byte
   parameters (A, C, E): the bodies are called without a prototype (K&R declarations here), which gives the
   ROM's int arguments.  OnColumn3 / OnColumn4 end in a jump to the body right after them (V4.23's tail call,
   jr); OnColumn2 calls SeMenu_EditFilterResonance and jumps to SeMenu_DrawFilterGraph(0, 0). */
/* cc900-module: SeFilLpq1_OnColumn3_Join21 SeFilLpq1_OnColumn4_Join22 SeMenu_EditFilterResonance */
/* (module_calls.py v10 prints Join21 and EditFilterResonance; Join22 is added by hand: OnColumn4's jr to it has
   displacement 0 and the script counts Join22 as part of OnColumn4's extent.  Drop it if the build refuses.) */

extern void SeMenu_EditFilterResonance();
extern void SeFilLpq1_OnColumn3_Join21();
extern void SeFilLpq1_OnColumn4_Join22();
extern void SeMenu_DrawFilterGraph();
extern void SeFilLpq1_OnColumn2(unsigned char a);
extern void SeFilLpq1_OnColumn3(unsigned char a);
extern void SeFilLpq1_OnColumn4(unsigned char a);

void SeFilLpq1_OnColumn2(unsigned char a)
{
	SeMenu_EditFilterResonance(a, 2, 48);
	SeMenu_DrawFilterGraph(0, 0);
}

void SeFilLpq1_OnColumn3(unsigned char a)
{
	SeFilLpq1_OnColumn3_Join21(a, 3, 48);
}

void SeFilLpq1_OnColumn4(unsigned char a)
{
	SeFilLpq1_OnColumn4_Join22(a, 4, 48);
}
