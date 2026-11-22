/* lane_p6 helper S, round 31r1: sequencer/sequencer_engine.s (module 234), form c.
   Part_ValidateVoiceChannel alone, with a prototype (unsigned char part number in A).
   cc900-options: -O3 -Xr
*/
/* cc900-module: PartCtrl_TestBit7 Part_ReadVoiceBit7 Part_ReadVoiceWord */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern void Part_ValidateVoiceChannel(unsigned char a);

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
