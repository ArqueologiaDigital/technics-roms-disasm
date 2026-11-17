/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_m14b.c (2026-11-16-27-p6-m14)
   sha256 db98ed0200421131f622a7ff2d6c8fa1d3b5c01a46d97763b3d7f0a2affcb6df (name+funcs); compiled at -Xr */
extern unsigned char SndParam_LogCurve128[], CHORD_DECAY_TIMER;
int SndParam_CompactLookupStub(unsigned char i) { unsigned char v = SndParam_LogCurve128[i]; return v; }
