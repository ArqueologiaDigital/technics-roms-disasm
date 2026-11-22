/* helper Q, round 20r1, module 288 (midi/midi_dispatch_handlers.s): sound-mode reverb / chorus type, arpeggio queue
   re-init. */
/* cc900-module: ArpQueue_InitBuffer */

struct mq;
struct tmpl16;
typedef struct mq *mqp;
typedef struct tmpl16 *tp16;

extern unsigned char ram_340f8;
extern unsigned char ram_340f9;
extern unsigned char __near ram_b7ec;
extern mqp __near MIDISEQ_ACTIVE_BLOCK_PTR;
extern tp16 __near MIDISEQ_ACTIVE_BUF_PTR;
extern void SndParam_ApplyAndSync(void);
extern void ArpQueue_InitBuffer(struct mq *q, struct tmpl16 *t);

void SoundMode_SetReverbType(void)
{
  switch (ram_340f8) {
  default:
    ram_b7ec = 128;
    break;
  case 1:
    ram_b7ec = 155;
    break;
  case 2:
    ram_b7ec = 156;
    break;
  case 3:
    ram_b7ec = 157;
    break;
  }
  SndParam_ApplyAndSync();
}

void SoundMode_SetChorusType(void)
{
  switch (ram_340f9) {
  case 1:
    ram_b7ec = 91;
    break;
  case 2:
    ram_b7ec = 92;
    break;
  case 3:
    ram_b7ec = 93;
    break;
  default:
    return;
  }
  SndParam_ApplyAndSync();
}

void MidiSeq_ReinitCurrentBuffer(void)
{
  ArpQueue_InitBuffer(MIDISEQ_ACTIVE_BLOCK_PTR, MIDISEQ_ACTIVE_BUF_PTR);
}
