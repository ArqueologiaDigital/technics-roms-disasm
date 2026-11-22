/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m2a.c (2026-11-21-7-p6-r62)
   sha256 8534a69421eaa250531b715b01198f892b9192ddb914dd52202a85cd48f0dd25 (tar-sha256); compiled at -Xr */
extern volatile int __near SYSTEM_TIMESTAMP;
void TaskSched_DelayTicks(unsigned int t)
{
  t >>= 1;
  t += SYSTEM_TIMESTAMP;
  do
    ;
  while ((int)t > SYSTEM_TIMESTAMP);
}
