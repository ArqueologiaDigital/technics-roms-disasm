/* helper W, round 21r2, module 234, form b: as form a, but the first argument widened into a word local BEFORE c is
   updated (the ROM's `extz wa` first), c updated by statements; Part_ReadWord_Indexed in the spelling of its built
   sibling Part_WriteWord_Indexed (`k += (unsigned char)(c + c - 2)`, cc900/sequencer_engine_m234_f.c). */
/* cc900-module: Part_ReadByteDirect Part_ReadWord Part_WriteWord */

extern unsigned int Part_ReadWord(unsigned int, unsigned int);
extern void Part_WriteWord(unsigned int, unsigned int, unsigned int);
extern unsigned char Part_ReadByteDirect(unsigned int, unsigned int);

unsigned int Part_ReadWord_Indexed(unsigned char a, unsigned char c)
{
  unsigned int k;
  k = 0x78;
  k += (unsigned char)(c + c - 2);
  return Part_ReadWord(a, k);
}

void Part_WriteVoiceWord(unsigned char a, unsigned char c, unsigned int v)
{
  unsigned int s;
  s = a;
  c *= 3;
  c -= 3;
  c += 0xd1;
  Part_WriteWord(s, c, v);
}

unsigned int Part_ReadVoiceWord(unsigned char a, unsigned char c)
{
  unsigned int s;
  s = a;
  c *= 3;
  c -= 3;
  c += 0xd1;
  return Part_ReadWord(s, c);
}

unsigned char Part_ReadVoiceBit7(unsigned char a, unsigned char c)
{
  unsigned int s;
  s = a;
  c *= 3;
  c -= 3;
  c += 0xd0;
  return Part_ReadByteDirect(s, c) & 0x80;
}
