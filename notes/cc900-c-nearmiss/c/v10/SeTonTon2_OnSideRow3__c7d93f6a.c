/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sound_editor_ui_m0.c (2026-11-19-92-p6-r57)
   sha256 c7d93f6a790c2532ab437973621f3de346642688ec71d7501141927852450910 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void SeMenu_SelectPartAndRedraw(int, int, int);
void SeTonTon2_OnSideRow3(unsigned char a)
{
	if (a != 0)
		SeMenu_SelectPartAndRedraw(35, 2, 1);
}
