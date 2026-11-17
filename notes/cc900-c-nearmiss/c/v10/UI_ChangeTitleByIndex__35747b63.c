/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/ui_control_panel_m270.c (2026-11-16-68-p6-r12)
   sha256 35747b63d11cd2bc1a6662e50e58574a339968045e80a6e87ffd3e6f989c1da7 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void DeleteEvent(long, long);
extern long ApPostEvent(long, long, long);
void UI_ChangeTitleByIndex(unsigned char i)
{
	DeleteEvent(-1L, 0x1c00015L);
	ApPostEvent(-1L, 0x1c00015L, 0x1a00000L + i);
}
