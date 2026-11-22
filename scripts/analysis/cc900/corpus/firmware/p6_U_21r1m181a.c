/* helper U, round 21r1, module 181 (ui/ui_playback_modes.s), form a: all sixteen PartParam_Handler_NN.  Run r59
   (p6_R_20r1m181c) differed at +0: `extz wa` and `ld bc, N` where the ROM passes A untouched and loads C only
   (lane_sub's spelling (c): the callee's parameters plain char), and a tail `jp` where the ROM keeps
   `call; ret`.  Form a: plain char parameters and the final callee __cdecl (does V4.23 keep call + ret for a
   cdecl callee?).  Form b: plain char only. */

extern void Part_LookupParam(char, char);
extern void __cdecl Part_ValidateAndActivate(void);

void PartParam_Handler_00(char a) { Part_LookupParam(a, 0x00); Part_ValidateAndActivate(); }
void PartParam_Handler_01(char a) { Part_LookupParam(a, 0x01); Part_ValidateAndActivate(); }
void PartParam_Handler_02(char a) { Part_LookupParam(a, 0x02); Part_ValidateAndActivate(); }
void PartParam_Handler_03(char a) { Part_LookupParam(a, 0x03); Part_ValidateAndActivate(); }
void PartParam_Handler_04(char a) { Part_LookupParam(a, 0x04); Part_ValidateAndActivate(); }
void PartParam_Handler_05(char a) { Part_LookupParam(a, 0x05); Part_ValidateAndActivate(); }
void PartParam_Handler_06(char a) { Part_LookupParam(a, 0x06); Part_ValidateAndActivate(); }
void PartParam_Handler_07(char a) { Part_LookupParam(a, 0x07); Part_ValidateAndActivate(); }
void PartParam_Handler_08(char a) { Part_LookupParam(a, 0x08); Part_ValidateAndActivate(); }
void PartParam_Handler_09(char a) { Part_LookupParam(a, 0x09); Part_ValidateAndActivate(); }
void PartParam_Handler_0A(char a) { Part_LookupParam(a, 0x0a); Part_ValidateAndActivate(); }
void PartParam_Handler_0B(char a) { Part_LookupParam(a, 0x0b); Part_ValidateAndActivate(); }
void PartParam_Handler_0C(char a) { Part_LookupParam(a, 0x0c); Part_ValidateAndActivate(); }
void PartParam_Handler_0D(char a) { Part_LookupParam(a, 0x0d); Part_ValidateAndActivate(); }
void PartParam_Handler_0E(char a) { Part_LookupParam(a, 0x0e); Part_ValidateAndActivate(); }
void PartParam_Handler_0F(char a) { Part_LookupParam(a, 0x0f); Part_ValidateAndActivate(); }
