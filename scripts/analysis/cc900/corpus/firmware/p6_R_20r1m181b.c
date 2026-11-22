/* Helper R, round 1 of 2026-11-20: module 181, form b: the final callee declared without a prototype (K&R), in case
   V4.23 keeps `call; ret` for an unprototyped callee. */

extern void Part_LookupParam(unsigned char, unsigned char);
extern void Part_ValidateAndActivate();

void PartParam_Handler_00(unsigned char a) { Part_LookupParam(a, 0x00); Part_ValidateAndActivate(); }
void PartParam_Handler_02(unsigned char a) { Part_LookupParam(a, 0x02); Part_ValidateAndActivate(); }
void PartParam_Handler_04(unsigned char a) { Part_LookupParam(a, 0x04); Part_ValidateAndActivate(); }
void PartParam_Handler_06(unsigned char a) { Part_LookupParam(a, 0x06); Part_ValidateAndActivate(); }
void PartParam_Handler_08(unsigned char a) { Part_LookupParam(a, 0x08); Part_ValidateAndActivate(); }
void PartParam_Handler_0A(unsigned char a) { Part_LookupParam(a, 0x0a); Part_ValidateAndActivate(); }
void PartParam_Handler_0C(unsigned char a) { Part_LookupParam(a, 0x0c); Part_ValidateAndActivate(); }
void PartParam_Handler_0E(unsigned char a) { Part_LookupParam(a, 0x0e); Part_ValidateAndActivate(); }
