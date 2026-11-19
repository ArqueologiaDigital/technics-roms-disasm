/* lane_p6 helper N, round 8, form a: module 264 (ui/drawbar_panel_ui.s), new function.
   DemoMenu_WorkspaceReturn: the demo menu's workspace word i: 0..8 from the word table at 0x247ce (a constant
   pointer: the ROM loads it with `ld xbc,imm`), 9..14 from the cells 0x247e0 .. 0x247ea through a switch (offset
   table DemoMenu_DescriptorFunc_CaseTable, cc900-data), else 0.
   cc900-options: -O3 -Xr
*/

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
		return ((unsigned int *)0x247ceL)[i];
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
