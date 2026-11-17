/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m14a.c (2026-11-16-27-p6-m14)
   sha256 e95e51a66b0871648f791559c6c0341da30001311638b392e5f82ec7a0ca5142 (name+funcs); compiled at -Xr */
extern unsigned char SndParam_LogCurve128[], CHORD_DECAY_TIMER;
unsigned char SndParam_CompactLookupStub(unsigned char i) { return SndParam_LogCurve128[i]; }
