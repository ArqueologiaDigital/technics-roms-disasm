/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_18c.c (2026-11-16-128-p6-r27)
   sha256 6d81222a6f622e82cb5417bddd6e151e5f40b646fe2fe8fd7831a84ce05eebf5 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_2576[];
extern unsigned int __near ram_2556[];
extern volatile unsigned char __near SEQ_PART_LOOP;
extern volatile unsigned char __near ram_2587;
extern unsigned int __near ram_258e;
void SeqScan_StoreResultB(void)
{
  ram_2576[SEQ_PART_LOOP] = ram_2587;
  ram_2556[(int)SEQ_PART_LOOP] = ram_258e;
}
