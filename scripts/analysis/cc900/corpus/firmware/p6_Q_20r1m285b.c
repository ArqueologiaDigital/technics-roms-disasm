/* helper Q, round 20r1, module 285, form b: the wait as do-while with the start time copied each pass. */

extern volatile int __near SYSTEM_TIMESTAMP;

void MidiStream_Delay25Ticks(void)
{
  int t;
  int d;
  t = SYSTEM_TIMESTAMP;
  do
    d = SYSTEM_TIMESTAMP - t;
  while (d < 25);
}
