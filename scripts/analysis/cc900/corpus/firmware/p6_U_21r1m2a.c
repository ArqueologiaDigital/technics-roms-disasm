/* helper U, round 21r1, module 2, form a: TaskSched_DelayTicks.  The ROM adds the timestamp from memory and tests
   at the loop's head only (cp; jr gt to itself): a do-while on the empty body, the target in the parameter. */

extern volatile int __near SYSTEM_TIMESTAMP;

void TaskSched_DelayTicks(unsigned int t)
{
  t >>= 1;
  t += SYSTEM_TIMESTAMP;
  do
    ;
  while ((int)t > SYSTEM_TIMESTAMP);
}
