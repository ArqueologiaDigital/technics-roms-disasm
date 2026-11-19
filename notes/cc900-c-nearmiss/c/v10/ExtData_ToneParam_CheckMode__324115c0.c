/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_7m280b.c (2026-11-19-56-p6-r51)
   sha256 324115c0cc2866a4b3bdc820ef436574687772b12cb1f53f9d1b634ac89c3d32 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern void ExtData_SetTlvField(unsigned int);
extern void SwbtWr_FlushAndAppendParams(void);
extern void SndParam_WriteLookupAndStore(void);
extern void ExtData_Tag43_SetByte1Fields(void);
extern unsigned char __near EXTDATA_TLV_OFFSET;
void ExtData_ToneParam_CheckMode(void)
{
	unsigned char o;

	SndParam_WriteLookupAndStore();
	o = EXTDATA_TLV_OFFSET;
	if (o == 1)
		goto one;
	if (o != 0)
		return;
	goto zero;
one:
	ExtData_Tag43_SetByte1Fields();
	return;
zero:
	ExtData_SetTlvField(128);
	SwbtWr_FlushAndAppendParams();
}
