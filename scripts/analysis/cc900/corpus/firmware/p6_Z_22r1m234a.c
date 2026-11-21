/* helper Z, round 22r1, module 234 (sequencer/sequencer_engine.s), form a: Part_ReadWord_Indexed.  At -O3 -Xr run
   r64's form p6_W_21r2m234a built the key directly in BC, the callee's argument register (`ld e, c; ldw bc, 0x78`,
   like the built Part_WriteWord_Indexed); the ROM builds it in DE (`ldw de, 0x78; ld l, c; add l, c; dec 2, l;
   extz hl; add de, hl; extz wa; ld bc, de`), i.e. the key is not coalesced with the argument.  Here the key is a
   signed int local passed to the unsigned parameter: the no-op conversion is meant to keep it in a register of its
   own.  Form b: the callee's prototype takes signed ints, the key stays unsigned. */
/* cc900-module: Part_ReadWord */

extern unsigned int Part_ReadWord(unsigned int, unsigned int);

unsigned int Part_ReadWord_Indexed(unsigned char a, unsigned char c)
{
  int k;
  k = 0x78;
  k += (unsigned char)(c + c - 2);
  return Part_ReadWord(a, k);
}
