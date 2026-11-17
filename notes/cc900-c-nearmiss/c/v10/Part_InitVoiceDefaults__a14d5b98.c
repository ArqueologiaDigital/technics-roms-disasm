/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_10m234.c (2026-11-16-88-p6-r16)
   sha256 a14d5b9875a3772ce22dc600dd5adedc4f5307fe7f6b2c262d17aaa5ab17334a (tar-sha256); compiled at -O3 -Xr */
extern void Part_WriteByte();
extern void Part_WriteWord();
extern unsigned char Boot_ReadFDCStatus(void);
extern unsigned char SeqStatus_CheckBit2(void);
void Part_InitVoiceDefaults(unsigned char a)
{
  unsigned int i;
  Part_WriteByte(a, 0, 0x5a);
  Part_WriteByte(a, 1, 0x5a);
  Part_WriteByte(a, 2, 0x5a);
  Part_WriteByte(a, 3, 0x5a);
  Part_WriteByte(a, 4, 0);
  Part_WriteByte(a, 5, 1);
  Part_WriteByte(a, 6, 8);
  Part_WriteByte(a, 7, 0);
  Part_WriteByte(a, 8, Boot_ReadFDCStatus());
  Part_WriteWord(a, 0x14, 0);
  Part_WriteWord(a, 0x16, 0x100);
  Part_WriteWord(a, 0x18, 0x2e);
  Part_WriteWord(a, 0x1a, 0x520);
  i = 0;
  do { Part_WriteByte(a, i + 0x42, 0); i++; } while (i < 12);
  if (SeqStatus_CheckBit2() == 0) Part_WriteByte(a, 0xbd, 0);
  else Part_WriteByte(a, 0xbd, 0xff);
}
