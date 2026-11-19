/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_7m280a.c (2026-11-19-56-p6-r51)
   sha256 b9ee784e3005921c228fcf7bb354b8efafab59795434273c319ec5c53b866fd2 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void ExtData_SetTlvField(unsigned int);
extern void SwbtWr_FlushAndAppendParams(void);
extern void SndParam_WriteLookupAndStore(void);
extern void ExtData_Tag43_SetByte1Fields(void);
extern unsigned char __near EXTDATA_TLV_OFFSET;
void ExtData_ToneParam_CheckMode(void)
{
	SndParam_WriteLookupAndStore();
	switch (EXTDATA_TLV_OFFSET) {
	case 1:
		ExtData_Tag43_SetByte1Fields();
		break;
	default:
		return;
	case 0:
		ExtData_SetTlvField(128);
		SwbtWr_FlushAndAppendParams();
		break;
	}
}
