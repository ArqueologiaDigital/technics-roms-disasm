/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_31r1m234b.c (2026-11-22-15-p6-r82)
   sha256 65ea17413f69445a8af095e334481ac23cb2be8adb8f4f148cf17fd2b92ea87a (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near ram_f218[];
extern unsigned int __near ram_f1f8[];
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern unsigned char SeqData_ReadNextByte(void);
extern void Part_ValidateVoiceChannel(unsigned int);
void Part_ValidateAndSetupVoiceChannel(unsigned char a)
{
  unsigned char e;
  unsigned char o;
  unsigned int b;

  Part_ValidateVoiceChannel(a);
  e = SEQ_ERROR_CODE;
  if (e != 0) {
    if (e == 1)
      SEQ_ERROR_CODE = 0;
    return;
  }
  SEQ_ERROR_CODE = 0;
  o = ram_f218[(unsigned char)(a - 1)];
  if (o >= 5) {
    b = ram_f1f8[(unsigned char)(a - 1)];
    if (b > 0x4d8) {
      SEQ_ERROR_CODE = 10;
      return;
    }
    if (PartCtrl_TestBit7(b) != 0) {
      SEQ_DATA_BLOCK = b;
      SEQ_DATA_OFFSET = o;
      if (SeqData_ReadNextByte() == 0x84)
        SEQ_ERROR_CODE = 6;
      return;
    }
  }
  SEQ_ERROR_CODE = 11;
}
