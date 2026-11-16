/* Functions of core/14_dsp_control_routines.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function at -Xr (notes/cc900-c-subcpu-2026-11-16/);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   cc900-options: -Xr */
extern long DSP_OscParamCurve[];

long DSP_ParamFetch_Op61Table(int x, unsigned long i) { return DSP_OscParamCurve[i]; }
