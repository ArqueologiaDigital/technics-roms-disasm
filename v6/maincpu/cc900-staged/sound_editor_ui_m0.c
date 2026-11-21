/* Functions of audio/sound_editor_ui.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void SeMenu_SetSoundBank(int);
extern void SeMenu_SetPatchBank(int);
extern void AccWrap_PlayModeDispatch(void);
extern void SeMenu_SetEditEnable(int);
extern void SeMenu_OrPartConfig(int);
extern void SeMenu_SetConfirmState(int);
extern void SeMenu_ClearDisplayBuffer(void);
extern void InitializeSeMenuDefaults(void);

void InitializeSeMenuDefaults(void)
{
	SeMenu_SetSoundBank(0);
	SeMenu_SetPatchBank(0);
	AccWrap_PlayModeDispatch();
	SeMenu_SetEditEnable(1);
	SeMenu_OrPartConfig(1);
	SeMenu_SetConfirmState(0);
	SeMenu_ClearDisplayBuffer();
}
