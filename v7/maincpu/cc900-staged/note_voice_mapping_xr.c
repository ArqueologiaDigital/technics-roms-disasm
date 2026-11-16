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
extern unsigned long __near ram_cf18;
extern unsigned long __near ram_cf1c;
extern unsigned long __near ram_cf20;
extern unsigned long __near ram_cf24;
extern unsigned long __near ram_cf28;
extern unsigned int __near ram_cf2c;
extern unsigned int __near ram_cf2e;
extern unsigned int __near ram_cf30;
extern unsigned int __near ram_cf32;
extern unsigned int __near ram_cf34[];
extern unsigned int __near ram_cf74[];
extern unsigned int __near ram_cfb4[];

void COMM_SendDataReturn(void)
{
  int i;
  ram_cf18 = 0xffffffff; ram_cf1c = 0xffffffff; ram_cf20 = 0xffffffff; ram_cf24 = 0xffffffff; ram_cf28 = 0xffffffff;
  ram_cf2c = 0xffff; ram_cf2e = 0xffff; ram_cf30 = 0xffff; ram_cf32 = 0xffff;
  i = 0;
  if (i <= 24) do {
    ram_cf34[i] = 0xffff;
    ram_cf74[i] = 0xffff;
    ram_cfb4[i] = 0xffff;
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

extern unsigned int __near ram_d00c;
extern unsigned int __near ram_d00e;
extern unsigned int __near ram_d010;
extern unsigned char __near ram_d012[];
extern unsigned int __near ram_d812;
extern unsigned int __near ram_d814;
extern unsigned int __near ram_d816;
extern unsigned char __near ram_d818[];
extern unsigned int __near ram_e018;
extern unsigned int __near ram_e01a;
extern unsigned int __near ram_e01c;
extern unsigned char __near ram_e01e[];

int MidiRingBuf_WriteByte(unsigned char a)
{
  int r;
  if (ram_e01c == 0) r = -1;
  else {
    ram_e01e[ram_e018] = a;
    ram_e01c--;
    if (ram_e018 == 127) ram_e018 = 0; else ram_e018++;
    r = 0;
  }
  return r;
}

int RingBuffer_ReadByte(void)
{
  int r;
  if (ram_d00c == ram_d00e) r = -1;
  else {
    r = ram_d012[ram_d00e];
    ram_d010++;
    if (ram_d00e == 2047) ram_d00e = 0; else ram_d00e++;
  }
  return r;
}

int RingBuffer_WriteByte(unsigned char a)
{
  int r;
  if (ram_d010 == 0) r = -1;
  else {
    ram_d012[ram_d00c] = a;
    ram_d010--;
    if (ram_d00c == 2047) ram_d00c = 0; else ram_d00c++;
    r = 0;
  }
  return r;
}

int StoreAndAdvance_LoadDRAM(void)
{
  int r;
  if (ram_e018 == ram_e01a) r = -1;
  else {
    r = ram_e01e[ram_e01a];
    ram_e01c++;
    if (ram_e01a == 127) ram_e01a = 0; else ram_e01a++;
  }
  return r;
}

int SysexRingBuf_ReadByte(void)
{
  int r;
  if (ram_d812 == ram_d814) r = -1;
  else {
    r = ram_d818[ram_d814];
    ram_d816++;
    if (ram_d814 == 2047) ram_d814 = 0; else ram_d814++;
  }
  return r;
}

int SysexRingBuf_WriteByte(unsigned char a)
{
  int r;
  if (ram_d816 == 0) r = -1;
  else {
    ram_d818[ram_d812] = a;
    ram_d816--;
    if (ram_d812 == 2047) ram_d812 = 0; else ram_d812++;
    r = 0;
  }
  return r;
}
