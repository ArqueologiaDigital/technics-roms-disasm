/* Helper R, round 1 of 2026-11-20: module 181 (ui/ui_playback_modes.s), the even PartParam_Handler_NN (helper Q has the
   odd ones).  The ROM ends them `call; call; ret` with no condition, where V4.23 is known to write a tail jump for a
   final call: forms a / b / c test what keeps the call.  Form a: full prototypes. */

extern void Part_LookupParam(unsigned char, unsigned char);
extern void Part_ValidateAndActivate(void);

void PartParam_Handler_00(unsigned char a) { Part_LookupParam(a, 0x00); Part_ValidateAndActivate(); }
void PartParam_Handler_02(unsigned char a) { Part_LookupParam(a, 0x02); Part_ValidateAndActivate(); }
void PartParam_Handler_04(unsigned char a) { Part_LookupParam(a, 0x04); Part_ValidateAndActivate(); }
void PartParam_Handler_06(unsigned char a) { Part_LookupParam(a, 0x06); Part_ValidateAndActivate(); }
void PartParam_Handler_08(unsigned char a) { Part_LookupParam(a, 0x08); Part_ValidateAndActivate(); }
void PartParam_Handler_0A(unsigned char a) { Part_LookupParam(a, 0x0a); Part_ValidateAndActivate(); }
void PartParam_Handler_0C(unsigned char a) { Part_LookupParam(a, 0x0c); Part_ValidateAndActivate(); }
void PartParam_Handler_0E(unsigned char a) { Part_LookupParam(a, 0x0e); Part_ValidateAndActivate(); }
