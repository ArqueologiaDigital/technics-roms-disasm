/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/audio_control_engine_m280.c (2026-11-16-122-p6-r24-staged)
   sha256 759f1126584ceda70b0d84377bd45e7b998164c6535d22c5b6dc7010299e5a5e (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void SwbtWr_FlushAndAppendParams(void);
extern void ExtData_ToggleTlvBits(unsigned int);
void ExtData_ToggleReverbIllusionOnOff(void)
{
	ExtData_ToggleTlvBits(192);
	SwbtWr_FlushAndAppendParams();
}
