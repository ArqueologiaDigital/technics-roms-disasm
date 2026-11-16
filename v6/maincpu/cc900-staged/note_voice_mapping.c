/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/




extern unsigned char __near ram_e29a;
extern unsigned char __near ram_e297;
extern unsigned char __near ram_e298;
extern unsigned char __near ram_e299;
extern unsigned char __near ram_e293;

void COMM_SendEqualizerOnOff(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e29a != c) { ram_e29a = c; SendCOMM_VariableLengthPacket((unsigned char *)0xe29a, 37, 1); }
}

void COMM_SendFadeLevel(unsigned char a)
{
  if (ram_e293 != a) { ram_e293 = a; SendCOMM_VariableLengthPacket((unsigned char *)0xe293, 6, 1); }
}


void SendPartDataBlock_ClearByte(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e297 != c) { ram_e297 = c; SendCOMM_VariableLengthPacket((unsigned char *)0xe297, 0x21, 1); }
}

void SendPartDataBlock_ClearByte2(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e298 != c) { ram_e298 = c; SendCOMM_VariableLengthPacket((unsigned char *)0xe298, 0x22, 1); }
}

void SendPartDataBlock_ClearByte3(unsigned char a)
{
  unsigned char c = 0;
  if (a != 0) c = 1;
  if (ram_e299 != c) { ram_e299 = c; SendCOMM_VariableLengthPacket((unsigned char *)0xe299, 0x24, 1); }
}

void SndParam_ApplyVoiceValue(unsigned char *r)
{
  unsigned char *q;
  if (r[5] != 0x0f) {
    int h = SndParam_LookupViaEncode(r[5], 0x20);
    q = r + 4;
    r[3] = r[2];
    if (h == 0x78) *q = 0x78; else *q = r[1];
  } else {
    r[3] = r[2];
    r[4] = 0x78;
  }
}
