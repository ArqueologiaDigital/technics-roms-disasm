/* lane_p6 helper S, round 31r1: sequencer/sequencer_engine.s (module 235), form a.
   SeqScan_InitAllStateVars: clears the scan counters and copies the start position (word 0x2590 / byte 0x2592) and
   the word 0x25b4 into the scan state cells.  Form b: chained assignments.
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
  ram_258e = 0;
  ram_2594 = 0;
  ram_2596 = 0;
  SEQ_PART_LOOP = 0;
  ram_2598 = 0;
  ram_259c = 0;
  ram_259a = 0;
  ram_259e = 0;
  ram_25ac = ram_25b0 = ram_25a8 = ram_25a4 = ram_25a0 = ram_2590;
  ram_25ae = ram_25b2 = ram_25aa = ram_25a6 = ram_25a2 = ram_2592;
  ram_25ba = ram_25be = ram_25bc = ram_25b8 = ram_25b6 = ram_25b4;
  ram_0437 = 0xff;
  ram_0436 = 0xff;
}
