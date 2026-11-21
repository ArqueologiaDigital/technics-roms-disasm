/* helper U, round 21r1, module 2, form b: TaskSched_DelayTicks as run r59's best (an int local for the target)
   with the loop written as a do-while (the ROM tests at the head only). */

extern volatile int __near SYSTEM_TIMESTAMP;

void TaskSched_DelayTicks(unsigned int t)
{
  int e = (t >> 1) + SYSTEM_TIMESTAMP;
  do
    ;
  while (e > SYSTEM_TIMESTAMP);
}
