/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_31r1m234c.c (2026-11-22-15-p6-r82)
   sha256 b0c39b47c944bafe8f9317cf2f10734a8e7b603bd555e9332984a7880bfcec83 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
void Part_ValidateVoiceChannel(unsigned char a)
{
  unsigned int b;

  if (Part_ReadVoiceBit7(0, a) == 0) {
    SEQ_ERROR_CODE = 1;
    return;
  }
  b = Part_ReadVoiceWord(0, a);
  if (b == 0xffff) {
    SEQ_ERROR_CODE = 2;
    return;
  }
  if (b > 0x4d8) {
    SEQ_ERROR_CODE = 10;
    return;
  }
  if (PartCtrl_TestBit7(b) == 0) {
    SEQ_ERROR_CODE = 11;
    return;
  }
  SEQ_DATA_BLOCK = b;
  SEQ_DATA_OFFSET = 5;
  SEQ_ERROR_CODE = 0;
}
