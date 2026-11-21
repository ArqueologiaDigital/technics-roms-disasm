/* helper Q, round 20r1, module 285 (midi/midi_dispatch_handlers.s): part record lookup, 25-tick wait. */

typedef unsigned char *ucp;
typedef ucp *ucpp;

extern ucpp __near PART_RECORD_PTRS;
extern volatile int __near SYSTEM_TIMESTAMP;

unsigned char *Part_LookupByIndex(unsigned char i)
{
  return PART_RECORD_PTRS[i];
}

void MidiStream_Delay25Ticks(void)
{
  int t;
  t = SYSTEM_TIMESTAMP;
  while (SYSTEM_TIMESTAMP - t < 25)
    ;
}
