/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void SendCOMM_VariableLengthPacket(unsigned char *, int, int);
extern unsigned char __near ram_e35a;
extern unsigned char __near ram_e353;
extern unsigned char __near ram_e354;
extern unsigned char __near ram_e357;
extern unsigned char __near ram_e358;
extern unsigned char __near ram_e359;

void COMM_SendEqualizerOnOff(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e35a != c) { ram_e35a = c; SendCOMM_VariableLengthPacket((unsigned char *)0xe35a, 37, 1); }
}

void COMM_SendFadeLevel(unsigned char a)
{
  if (ram_e353 != a) { ram_e353 = a; SendCOMM_VariableLengthPacket((unsigned char *)0xe353, 6, 1); }
}

void COMM_SendMicVolume(unsigned char a)
{
  if (ram_e354 != a) { ram_e354 = a; SendCOMM_VariableLengthPacket((unsigned char *)0xe354, 7, 1); }
}

void SendPartDataBlock_ClearByte(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e357 != c) { ram_e357 = c; SendCOMM_VariableLengthPacket((unsigned char *)0xe357, 0x21, 1); }
}

void SendPartDataBlock_ClearByte2(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e358 != c) { ram_e358 = c; SendCOMM_VariableLengthPacket((unsigned char *)0xe358, 0x22, 1); }
}

void SendPartDataBlock_ClearByte3(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e359 != c) { ram_e359 = c; SendCOMM_VariableLengthPacket((unsigned char *)0xe359, 0x24, 1); }
}
