/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned int __near ram_258e;
extern unsigned int __near ram_2594;
extern unsigned int __near ram_2596;
extern unsigned char __near SEQ_PART_LOOP;
extern unsigned int __near ram_2598;
extern unsigned int __near ram_259c;
extern unsigned int __near ram_259a;
extern unsigned int __near ram_259e;
extern unsigned int __near ram_2590;
extern unsigned int __near ram_25a0;
extern unsigned int __near ram_25a4;
extern unsigned int __near ram_25a8;
extern unsigned int __near ram_25b0;
extern unsigned int __near ram_25ac;
extern unsigned char __near ram_2592;
extern unsigned char __near ram_25a2;
extern unsigned char __near ram_25a6;
extern unsigned char __near ram_25aa;
extern unsigned char __near ram_25b2;
extern unsigned char __near ram_25ae;
extern unsigned int __near ram_25b4;
extern unsigned int __near ram_25b6;
extern unsigned int __near ram_25b8;
extern unsigned int __near ram_25bc;
extern unsigned int __near ram_25be;
extern unsigned int __near ram_25ba;
extern unsigned char __near ram_0437;
extern unsigned char __near ram_0436;
extern void SeqScan_InitAllStateVars(void);

void SeqScan_InitAllStateVars(void)
{
  unsigned int w;
  unsigned char b;

  ram_258e = 0;
  ram_2594 = 0;
  ram_2596 = 0;
  SEQ_PART_LOOP = 0;
  ram_2598 = 0;
  ram_259c = 0;
  ram_259a = 0;
  ram_259e = 0;
  w = ram_2590;
  ram_25a0 = w;
  ram_25a4 = w;
  ram_25a8 = w;
  ram_25b0 = w;
  ram_25ac = w;
  b = ram_2592;
  ram_25a2 = b;
  ram_25a6 = b;
  ram_25aa = b;
  ram_25b2 = b;
  ram_25ae = b;
  w = ram_25b4;
  ram_25b6 = w;
  ram_25b8 = w;
  ram_25bc = w;
  ram_25be = w;
  ram_25ba = w;
  ram_0437 = 0xff;
  ram_0436 = 0xff;
}
