/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_e197;
extern unsigned char __near ram_e2b8[];
extern unsigned char __near ram_e2d6[];

unsigned char SndParam_LookupPartIndex(unsigned char a, unsigned char c)
{
  ram_e2d6[0] = 0x2b; ram_e2d6[1] = 0x30; ram_e2d6[2] = 0x7f; ram_e2d6[3] = 0x27; ram_e2d6[4] = 0; ram_e2d6[5] = 0; ram_e2d6[6] = 2;
  ram_e197++;
  ram_e2d6[7] = ram_e197 & 0x7f;
  ram_e2d6[8] = a; ram_e2d6[9] = c;
  sendCOMM(3, 10);
  return ram_e2d6[7];
}

unsigned char SubCPU_RequestSoundName(unsigned char a, unsigned char c)
{
  ram_e2b8[0] = 0x2b; ram_e2b8[1] = 0x30; ram_e2b8[2] = 0x7f; ram_e2b8[3] = 0x20; ram_e2b8[4] = 0; ram_e2b8[5] = 0; ram_e2b8[6] = 2;
  ram_e197++;
  ram_e2b8[7] = ram_e197 & 0x7f;
  ram_e2b8[8] = a; ram_e2b8[9] = c;
  sendCOMM(3, 10);
  return ram_e2b8[7];
}

extern unsigned char __near ram_e35a;
extern unsigned char __near ram_e357;
extern unsigned char __near ram_e358;
extern unsigned char __near ram_e359;
extern unsigned char __near ram_e353;
extern unsigned char __near ram_e354;

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
