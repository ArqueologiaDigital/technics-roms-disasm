/* lane_p6 helper N, round 9, form a: module 264 (ui/drawbar_panel_ui.s), retry of p6_N_8m264a (p6-r52 Xr: +5).
   DemoMenu_WorkspaceReturn: the ROM loads the table base 0x247ce as an immediate into XBC and adds the doubled
   index into it (`ld xbc,imm; add xbc,xwa`), V4.23 added the constant to the index.  Form a: lane_hd's
   converted-pointer spelling -- the extern word table ram_247ce indexed through `(void *)` with a long index.
   cc900-options: -O3 -Xr
*/

extern unsigned int ram_247ce[];
extern unsigned int ram_247e0;
extern unsigned int ram_247e2;
extern unsigned int ram_247e4;
extern unsigned int ram_247e6;
extern unsigned int ram_247e8;
extern unsigned int ram_247ea;

/* cc900-data: DemoMenu_WorkspaceReturn 1 = DemoMenu_DescriptorFunc_CaseTable */
unsigned int DemoMenu_WorkspaceReturn(unsigned int i)
{
	if (i <= 8)
		return *(unsigned int *)(void *)(ram_247ce + (unsigned long)i);
	switch (i) {
	case 9: return ram_247e0;
	case 10: return ram_247e2;
	case 11: return ram_247e4;
	case 12: return ram_247e6;
	case 13: return ram_247e8;
	case 14: return ram_247ea;
	}
	return 0;
}
