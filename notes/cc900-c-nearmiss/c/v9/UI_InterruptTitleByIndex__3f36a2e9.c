/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_control_panel.c (2026-11-16-55-p6-r10)
   sha256 3f36a2e93db1252b0b2b0cfae809628b1676015fa0270cd8d6e042ba2988ee8b (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
void UI_InterruptTitleByIndex(unsigned char i)
{
	DeleteEvent(-1L, 0x1c00016L);
	ApPostEvent(-1L, 0x1c00016L, 0x1a00000L + i);
}
