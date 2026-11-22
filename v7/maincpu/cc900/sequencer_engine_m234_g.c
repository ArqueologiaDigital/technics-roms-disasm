/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Part_ReadByteDirect Part_ReadWord Part_WriteWord */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char Part_ReadByteDirect(unsigned int, unsigned int);
extern unsigned char Part_ReadVoiceBit7(unsigned char a, unsigned char c);
extern unsigned int Part_ReadWord(unsigned int, unsigned int);
extern unsigned int Part_ReadVoiceWord(unsigned char a, unsigned char c);
extern void Part_WriteWord(unsigned int, unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned char a, unsigned char c, unsigned int v);

unsigned char Part_ReadVoiceBit7(unsigned char a, unsigned char c)
{
  return Part_ReadByteDirect(a, (c *= 3, c -= 3, c += 0xd0)) & 0x80;
}

unsigned int Part_ReadVoiceWord(unsigned char a, unsigned char c)
{
  return Part_ReadWord(a, (c *= 3, c -= 3, c += 0xd1));
}

void Part_WriteVoiceWord(unsigned char a, unsigned char c, unsigned int v)
{
  Part_WriteWord(a, (c *= 3, c -= 3, c += 0xd1), v);
}
