/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_18a.c (2026-11-16-128-p6-r27)
   sha256 bfae7c1ad0d072c4e30669eb5a779d2b54efb3a420a174f7146b44fe63e33bb8 (tar-sha256); compiled at -O3 -Xr */
struct rec8 { unsigned int w; unsigned char b[6]; };
extern struct rec8 __near ram_2338[];
extern unsigned char __near ram_1db6[];
#define REC_2338 ((struct rec8 *)ram_2338)
#define NOTE9_1DB6 ((unsigned char *)ram_1db6)
extern unsigned char __near ram_231a;
extern void SeqData_SetErrorCode(unsigned char);
extern unsigned char __near ram_1db4;
extern void NoteMap_RemoveHeadEntry(unsigned int);
extern void NotePool_InsertEntry(unsigned char);
unsigned char SeqNote_SetupVoice(unsigned char a, unsigned char *p)
{
  register unsigned char s;
  unsigned char n;
  unsigned int w;
  unsigned char *e;
  s = ram_1db4;
  if (s == 0xff) return 1;
  if (a == 0) SeqData_SetErrorCode(0x0d);
  if (s >= 0x40) SeqData_SetErrorCode(0x0e);
  NoteMap_RemoveHeadEntry(s);
  w = REC_2338[(unsigned char)(a - 1)].w;
  n = REC_2338[(unsigned char)(a - 1)].b[1];
  n += p[4];
  if (n >= 0x60) { n -= 0x60; w++; }
  w += p[5];
  if (a == 0x11) a = ram_231a;
  if (n > 0x60) SeqData_SetErrorCode(0x0f);
  e = NOTE9_1DB6 + (int)s * 9;
  e[4] = p[0];
  e[5] = n;
  e[6] = p[2];
  e[7] = 0;
  e[8] = a - 1;
  *(unsigned int *)(e + 2) = w;
  NotePool_InsertEntry(s);
  return 0;
}
