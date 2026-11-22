/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m2a.c (2026-11-21-3-p6-r59)
   sha256 ff27d5e75c370376ec3182fa770ee61513dad2372d1b0567f6f6047909bd18d2 (tar-sha256); compiled at -O3 -Xr */
extern volatile int __near SYSTEM_TIMESTAMP;
void TaskSched_DelayTicks(unsigned int t)
{
  int e = (t >> 1) + SYSTEM_TIMESTAMP;
  while (e > SYSTEM_TIMESTAMP)
    ;
}
