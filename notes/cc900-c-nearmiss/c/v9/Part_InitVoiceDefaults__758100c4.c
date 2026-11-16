/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sequencer_engine_m234.c (2026-11-16-103-p6-r20-staged)
   sha256 758100c4373458630d00e94f6652821de045a1dfe8fd684083a520809cd65253 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void Part_WriteByte();
extern void Part_WriteWord();
extern unsigned char Boot_ReadFDCStatus(void);
extern unsigned char SeqStatus_CheckBit2(void);
void Part_InitVoiceDefaults(unsigned char a)
{
  unsigned int i;
  unsigned char r;
  Part_WriteByte(a, 0, 0x5a);
  Part_WriteByte(a, 1, 0x5a);
  Part_WriteByte(a, 2, 0x5a);
  Part_WriteByte(a, 3, 0x5a);
  Part_WriteByte(a, 4, 0);
  Part_WriteByte(a, 5, 1);
  Part_WriteByte(a, 6, 8);
  Part_WriteByte(a, 7, 0);
  r = Boot_ReadFDCStatus();
  Part_WriteByte(a, 8, r);
  Part_WriteWord(a, 0x14, 0);
  Part_WriteWord(a, 0x16, 0x100);
  Part_WriteWord(a, 0x18, 0x2e);
  Part_WriteWord(a, 0x1a, 0x520);
  i = 0;
  do { Part_WriteByte(a, i + 0x42, 0); i++; } while (i < 12);
  if (SeqStatus_CheckBit2() == 0) Part_WriteByte(a, 0xbd, 0);
  else Part_WriteByte(a, 0xbd, 0xff);
}
