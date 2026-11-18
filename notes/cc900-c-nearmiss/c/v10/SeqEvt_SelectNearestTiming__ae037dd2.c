/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_21c.c (2026-11-18-1-p6-r33)
   sha256 ae037dd2d8f5c0252176e54e2510e03e43d75db452c4d53f45c42f3399663c27 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near ram_25a0;
extern unsigned char __near ram_25a2;
extern unsigned int __near ram_25a4;
extern unsigned char __near ram_25a6;
extern unsigned int __near ram_25a8;
extern unsigned char __near ram_25aa;
extern unsigned int __near ram_25b8;
extern unsigned int __near ram_25ba;
extern unsigned int __near ram_25bc;
extern unsigned int __near ram_25be;
extern unsigned char __near ram_25c2;
extern unsigned int __near ram_2598;
extern unsigned int __near ram_259a;
extern unsigned int __near ram_259c;
extern unsigned int __near ram_259e;
extern void SeqStep_HandleNoteOverflow(unsigned int);
extern unsigned char VoiceAlloc_TestBitHigh(void);
extern void SeqTiming_CompareAndUpdateState(void);
unsigned char SeqEvt_SelectNearestTiming(void)
{
  unsigned int q, p;
  p = ram_25a4;
  if (p == 0xffff && ram_25a8 == 0xffff) {
    SeqStep_HandleNoteOverflow(ram_25c2);
    return 0xff;
  }
  q = ram_25a8;
  if (p == q && ram_25a6 == ram_25aa) goto equal;
  if (p < q || (p == q && ram_25a6 < ram_25aa)) {
    ram_25a0 = p;
    ram_25a2 = ram_25a6;
    ram_25ba = ram_25b8;
    ram_25b8 = ram_25bc;
    goto apply0;
  }
  ram_25a0 = q;
  ram_25a2 = ram_25aa;
  ram_25ba = ram_25b8;
  ram_25b8 = ram_25be;
  goto apply1;
equal:
  if ((p != 0 || ram_25a6 != 0) && VoiceAlloc_TestBitHigh() != 0x0f) goto first;
  ram_25a0 = ram_25a8;
  ram_25a2 = ram_25aa;
  ram_25ba = ram_25b8;
  ram_25b8 = ram_25be;
apply0:
  SeqTiming_CompareAndUpdateState();
  SEQ_DATA_BLOCK = ram_2598;
  SEQ_DATA_OFFSET = ram_259c;
  return 0;
first:
  ram_25a0 = ram_25a4;
  ram_25a2 = ram_25a6;
  ram_25ba = ram_25b8;
  ram_25b8 = ram_25bc;
apply1:
  SeqTiming_CompareAndUpdateState();
  SEQ_DATA_BLOCK = ram_259a;
  SEQ_DATA_OFFSET = ram_259e;
  return 1;
}
