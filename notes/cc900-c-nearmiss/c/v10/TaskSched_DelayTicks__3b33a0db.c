/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/system_handlers_m2.c (2026-11-21-8-p6-r63)
   sha256 3b33a0db573a991b6e472f3a10e2a03601732357c4a458ae98e6350fa718a79a (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern volatile int __near SYSTEM_TIMESTAMP;
void TaskSched_DelayTicks(unsigned int t)
{
  t >>= 1;
  t += SYSTEM_TIMESTAMP;
  do
    ;
  while ((int)t > SYSTEM_TIMESTAMP);
}
