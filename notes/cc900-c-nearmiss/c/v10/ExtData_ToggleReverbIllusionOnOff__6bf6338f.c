/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_16m280.c (2026-11-16-118-p6-r23)
   sha256 6bf6338fbbed8d6bcd013a8635ca32f27aed9f7df8b40232433034617c50829a (tar-sha256); compiled at -O3 -XS -Xr */
extern void SwbtWr_FlushAndAppendParams(void);
extern void ExtData_ToggleTlvBits(unsigned int);
void ExtData_ToggleReverbIllusionOnOff(void)
{
	ExtData_ToggleTlvBits(192);
	SwbtWr_FlushAndAppendParams();
}
