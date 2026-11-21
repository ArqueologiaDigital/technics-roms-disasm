/* helper Z, round 22r1, module 234 (sequencer/sequencer_engine.s), form b: Part_ReadWord_Indexed, as form a but
   the key unsigned and Part_ReadWord declared with signed int parameters (the conversion moved to the call). */
/* cc900-module: Part_ReadWord */

extern unsigned int Part_ReadWord(int, int);

unsigned int Part_ReadWord_Indexed(unsigned char a, unsigned char c)
{
  unsigned int k;
  k = 0x78;
  k += (unsigned char)(c + c - 2);
  return Part_ReadWord(a, k);
}
