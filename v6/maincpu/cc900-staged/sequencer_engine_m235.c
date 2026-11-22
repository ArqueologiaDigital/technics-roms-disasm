/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned int __near ram_2574;
extern unsigned int __near ram_257a;
extern unsigned int __near ram_257c;
extern unsigned char __near SEQ_PART_LOOP;
extern unsigned int __near ram_257e;
extern unsigned int __near ram_2582;
extern unsigned int __near ram_2580;
extern unsigned int __near ram_2584;
extern unsigned int __near ram_2576;
extern unsigned int __near ram_2586;
extern unsigned int __near ram_258a;
extern unsigned int __near ram_258e;
extern unsigned int __near ram_2596;
extern unsigned int __near ram_2592;
extern unsigned char __near ram_2578;
extern unsigned char __near ram_2588;
extern unsigned char __near ram_258c;
extern unsigned char __near ram_2590;
extern unsigned char __near ram_2598;
extern unsigned char __near ram_2594;
extern unsigned int __near ram_259a;
extern unsigned int __near ram_259c;
extern unsigned int __near ram_259e;
extern unsigned int __near ram_25a2;
extern unsigned int __near ram_25a4;
extern unsigned int __near ram_25a0;
extern unsigned char __near ram_437;
extern unsigned char __near ram_436;
extern void SeqScan_InitAllStateVars(void);

void SeqScan_InitAllStateVars(void)
{
  unsigned int w;
  unsigned char b;

  ram_2574 = 0;
  ram_257a = 0;
  ram_257c = 0;
  SEQ_PART_LOOP = 0;
  ram_257e = 0;
  ram_2582 = 0;
  ram_2580 = 0;
  ram_2584 = 0;
  w = ram_2576;
  ram_2586 = w;
  ram_258a = w;
  ram_258e = w;
  ram_2596 = w;
  ram_2592 = w;
  b = ram_2578;
  ram_2588 = b;
  ram_258c = b;
  ram_2590 = b;
  ram_2598 = b;
  ram_2594 = b;
  w = ram_259a;
  ram_259c = w;
  ram_259e = w;
  ram_25a2 = w;
  ram_25a4 = w;
  ram_25a0 = w;
  ram_437 = 0xff;
  ram_436 = 0xff;
}
