/* helper W, round 21r2, module 234 (sequencer/sequencer_engine.s), form a: one-spot retries of run r62
   (p6_U_21r1m234b, first difference at +0).
   Part_ReadVoiceWord / Part_WriteVoiceWord / Part_ReadVoiceBit7: the ROM widens A first (`extz wa`) and then works on
   C in place (mul c, 3; dec 3, c; add c, 0xd1).  Earlier forms either computed c in a statement before the call
   (extz wa lands after it) or as one folded expression (A copied to DE, `add a, 206`).  Here the whole update of c
   is a comma expression inside the call's second argument, so the first argument is evaluated first and c is
   updated in place in three unfolded steps.
   Part_ReadWord_Indexed: the ROM keeps the 0x78 base in DE and the byte offset in L; U's form b had them the other
   way round (HL / E).  Here the byte local is declared before the word local. */
/* cc900-module: Part_ReadByteDirect Part_ReadWord Part_WriteWord */

extern unsigned int Part_ReadWord(unsigned int, unsigned int);
extern void Part_WriteWord(unsigned int, unsigned int, unsigned int);
extern unsigned char Part_ReadByteDirect(unsigned int, unsigned int);

unsigned int Part_ReadWord_Indexed(unsigned char a, unsigned char c)
{
  unsigned char o;
  unsigned int k;
  k = 0x78;
  o = c + c - 2;
  k += o;
  return Part_ReadWord(a, k);
}

void Part_WriteVoiceWord(unsigned char a, unsigned char c, unsigned int v)
{
  Part_WriteWord(a, (c *= 3, c -= 3, c += 0xd1), v);
}

unsigned int Part_ReadVoiceWord(unsigned char a, unsigned char c)
{
  return Part_ReadWord(a, (c *= 3, c -= 3, c += 0xd1));
}

unsigned char Part_ReadVoiceBit7(unsigned char a, unsigned char c)
{
  return Part_ReadByteDirect(a, (c *= 3, c -= 3, c += 0xd0)) & 0x80;
}
