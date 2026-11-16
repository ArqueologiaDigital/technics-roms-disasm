/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void sendCOMM(int, int);
extern unsigned char __near ram_e197;
extern unsigned char __near ram_e2d6[];
extern unsigned char __near ram_e2b8[];
extern unsigned char __near ram_e2c2[];
extern unsigned char __near ram_e2cc[];

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

unsigned char Param_SignExtendRetu_Block4(unsigned char a, unsigned char c)
{
  ram_e2c2[0] = 0x2b; ram_e2c2[1] = 0x30; ram_e2c2[2] = 0x7f; ram_e2c2[3] = 0x22; ram_e2c2[4] = 0; ram_e2c2[5] = 0; ram_e2c2[6] = 2;
  ram_e197++;
  ram_e2c2[7] = ram_e197 & 0x7f;
  ram_e2c2[8] = a; ram_e2c2[9] = c;
  sendCOMM(3, 10);
  return ram_e2c2[7];
}

unsigned char SubCPU_RequestShortSoundName(unsigned char a, unsigned char c)
{
  ram_e2cc[0] = 0x2b; ram_e2cc[1] = 0x30; ram_e2cc[2] = 0x7f; ram_e2cc[3] = 0x24; ram_e2cc[4] = 0; ram_e2cc[5] = 0; ram_e2cc[6] = 2;
  ram_e197++;
  ram_e2cc[7] = ram_e197 & 0x7f;
  ram_e2cc[8] = a; ram_e2cc[9] = c;
  sendCOMM(3, 10);
  return ram_e2cc[7];
}
