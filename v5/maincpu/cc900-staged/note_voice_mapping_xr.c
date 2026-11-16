/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
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
extern unsigned long __near ram_cef4;
extern unsigned long __near ram_cef8;
extern unsigned long __near ram_cefc;
extern unsigned long __near ram_cf00;
extern unsigned long __near ram_cf04;
extern unsigned int __near ram_cf08;
extern unsigned int __near ram_cf0a;
extern unsigned int __near ram_cf0c;
extern unsigned int __near ram_cf0e;
extern unsigned int __near ram_cf10[];
extern unsigned int __near ram_cf50[];
extern unsigned int __near ram_cf90[];

void COMM_SendDataReturn(void)
{
  int i;
  ram_cef4 = 0xffffffff; ram_cef8 = 0xffffffff; ram_cefc = 0xffffffff; ram_cf00 = 0xffffffff; ram_cf04 = 0xffffffff;
  ram_cf08 = 0xffff; ram_cf0a = 0xffff; ram_cf0c = 0xffff; ram_cf0e = 0xffff;
  i = 0;
  if (i <= 24) do {
    ram_cf10[i] = 0xffff;
    ram_cf50[i] = 0xffff;
    ram_cf90[i] = 0xffff;
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

extern unsigned int __near ram_cfe8;
extern unsigned int __near ram_cfea;
extern unsigned int __near ram_cfec;
extern unsigned char __near ram_cfee[];
extern unsigned int __near ram_d7ee;
extern unsigned int __near ram_d7f0;
extern unsigned int __near ram_d7f2;
extern unsigned char __near ram_d7f4[];
extern unsigned int __near ram_dff4;
extern unsigned int __near ram_dff6;
extern unsigned int __near ram_dff8;
extern unsigned char __near ram_dffa[];

int MidiRingBuf_WriteByte(unsigned char a)
{
  int r;
  if (ram_dff8 == 0) r = -1;
  else {
    ram_dffa[ram_dff4] = a;
    ram_dff8--;
    if (ram_dff4 == 127) ram_dff4 = 0; else ram_dff4++;
    r = 0;
  }
  return r;
}

int RingBuffer_ReadByte(void)
{
  int r;
  if (ram_cfe8 == ram_cfea) r = -1;
  else {
    r = ram_cfee[ram_cfea];
    ram_cfec++;
    if (ram_cfea == 2047) ram_cfea = 0; else ram_cfea++;
  }
  return r;
}


int StoreAndAdvance_LoadDRAM(void)
{
  int r;
  if (ram_dff4 == ram_dff6) r = -1;
  else {
    r = ram_dffa[ram_dff6];
    ram_dff8++;
    if (ram_dff6 == 127) ram_dff6 = 0; else ram_dff6++;
  }
  return r;
}

int SysexRingBuf_ReadByte(void)
{
  int r;
  if (ram_d7ee == ram_d7f0) r = -1;
  else {
    r = ram_d7f4[ram_d7f0];
    ram_d7f2++;
    if (ram_d7f0 == 2047) ram_d7f0 = 0; else ram_d7f0++;
  }
  return r;
}

int SysexRingBuf_WriteByte(unsigned char a)
{
  int r;
  if (ram_d7f2 == 0) r = -1;
  else {
    ram_d7f4[ram_d7ee] = a;
    ram_d7f2--;
    if (ram_d7ee == 2047) ram_d7ee = 0; else ram_d7ee++;
    r = 0;
  }
  return r;
}
