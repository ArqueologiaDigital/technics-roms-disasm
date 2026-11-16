/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   This part of the file was compiled without -O, the rest of it with -O.
   cc900-options: -Xr
*/
struct pair { unsigned char a, b; };
int LinkVoiceSlots_LoadReg(struct pair *p, unsigned char c) { if (p[c].b == c) return 0; return 1; }

struct lnk { unsigned char a, b; };
extern unsigned long __near ram_cfb4;
extern unsigned long __near ram_cfb8;
extern unsigned long __near ram_cfbc;
extern unsigned long __near ram_cfc0;
extern unsigned long __near ram_cfc4;
extern unsigned int __near ram_cfc8;
extern unsigned int __near ram_cfca;
extern unsigned int __near ram_cfcc;
extern unsigned int __near ram_cfce;
extern unsigned int __near ram_cfd0[];
extern unsigned int __near ram_d010[];
extern unsigned int __near ram_d050[];

void COMM_SendDataReturn(void)
{
  int i;
  ram_cfb4 = 0xffffffff; ram_cfb8 = 0xffffffff; ram_cfbc = 0xffffffff; ram_cfc0 = 0xffffffff; ram_cfc4 = 0xffffffff;
  ram_cfc8 = 0xffff; ram_cfca = 0xffff; ram_cfcc = 0xffff; ram_cfce = 0xffff;
  i = 0;
  if (i <= 24) do {
    ram_cfd0[i] = 0xffff;
    ram_d010[i] = 0xffff;
    ram_d050[i] = 0xffff;
    i++;
  } while (i <= 24);
}

void NoteMap_LinkVoiceSlots(struct lnk *lk, unsigned char c, unsigned char e)
{
  lk[c].b = lk[e].b;
  lk[c].a = e;
  lk[lk[e].b].a = c;
  lk[e].b = c;
}

void NoteMap_SwapVoiceLinks(struct lnk *lk, unsigned char c)
{
  lk[lk[c].a].b = lk[c].b;
  lk[lk[c].b].a = lk[c].a;
}

extern unsigned int __near ram_d0a8;
extern unsigned int __near ram_d0aa;
extern unsigned int __near ram_d0ac;
extern unsigned char __near ram_d0ae[];
extern unsigned int __near ram_d8ae;
extern unsigned int __near ram_d8b0;
extern unsigned int __near ram_d8b2;
extern unsigned char __near ram_d8b4[];
extern unsigned int __near ram_e0b4;
extern unsigned int __near ram_e0b6;
extern unsigned int __near ram_e0b8;
extern unsigned char __near ram_e0ba[];

int MidiRingBuf_WriteByte(unsigned char a)
{
  int r;
  if (ram_e0b8 == 0) r = -1;
  else {
    ram_e0ba[ram_e0b4] = a;
    ram_e0b8--;
    if (ram_e0b4 == 127) ram_e0b4 = 0; else ram_e0b4++;
    r = 0;
  }
  return r;
}

int RingBuffer_ReadByte(void)
{
  int r;
  if (ram_d0a8 == ram_d0aa) r = -1;
  else {
    r = ram_d0ae[ram_d0aa];
    ram_d0ac++;
    if (ram_d0aa == 2047) ram_d0aa = 0; else ram_d0aa++;
  }
  return r;
}

int RingBuffer_WriteByte(unsigned char a)
{
  int r;
  if (ram_d0ac == 0) r = -1;
  else {
    ram_d0ae[ram_d0a8] = a;
    ram_d0ac--;
    if (ram_d0a8 == 2047) ram_d0a8 = 0; else ram_d0a8++;
    r = 0;
  }
  return r;
}

int StoreAndAdvance_LoadDRAM(void)
{
  int r;
  if (ram_e0b4 == ram_e0b6) r = -1;
  else {
    r = ram_e0ba[ram_e0b6];
    ram_e0b8++;
    if (ram_e0b6 == 127) ram_e0b6 = 0; else ram_e0b6++;
  }
  return r;
}

int SysexRingBuf_ReadByte(void)
{
  int r;
  if (ram_d8ae == ram_d8b0) r = -1;
  else {
    r = ram_d8b4[ram_d8b0];
    ram_d8b2++;
    if (ram_d8b0 == 2047) ram_d8b0 = 0; else ram_d8b0++;
  }
  return r;
}

int SysexRingBuf_WriteByte(unsigned char a)
{
  int r;
  if (ram_d8b2 == 0) r = -1;
  else {
    ram_d8b4[ram_d8ae] = a;
    ram_d8b2--;
    if (ram_d8ae == 2047) ram_d8ae = 0; else ram_d8ae++;
    r = 0;
  }
  return r;
}
