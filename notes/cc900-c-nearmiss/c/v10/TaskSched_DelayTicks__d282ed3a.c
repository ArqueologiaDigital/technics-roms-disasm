/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m2b.c (2026-11-21-7-p6-r62)
   sha256 d282ed3ada259ff0efbb42a73aec77577f0a6fd0764df37856cba096d2ad5c07 (tar-sha256); compiled at -O3 -Xr */
extern volatile int __near SYSTEM_TIMESTAMP;
void TaskSched_DelayTicks(unsigned int t)
{
  int e = (t >> 1) + SYSTEM_TIMESTAMP;
  do
    ;
  while (e > SYSTEM_TIMESTAMP);
}
