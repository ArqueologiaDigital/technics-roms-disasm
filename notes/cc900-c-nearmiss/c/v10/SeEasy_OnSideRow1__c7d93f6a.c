/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sound_editor_ui_m0.c (2026-11-19-92-p6-r57)
   sha256 c7d93f6a790c2532ab437973621f3de346642688ec71d7501141927852450910 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeM_CWU_S3H14=SeMenu_CopyWriteUpdate_Step3_Helper14 */
extern void SeMenu_SendEvent(int title, int refresh);
#define TT_SEWRTMEM  0x3e
extern void SeM_CWU_S3H14(int);
void SeEasy_OnSideRow1(unsigned char a)
{
	if (a != 0) {
		SeM_CWU_S3H14(0);
		SeMenu_SendEvent(TT_SEWRTMEM, 0);
	}
}
