/* helper Q, round 20r1, module 302 (audio/note_voice_mapping.s): copy a length-prefixed MIDI packet to 0xd090 and
   send it (the built MIDI_Send* of module 301 call it). */

extern unsigned char __near ram_d090[];
extern void sendCOMM(int, int, unsigned char *);

void MIDI_SendCmdPacket(unsigned char *p)
{
  int i;
  for (i = 0; i < p[0]; i++)
    ram_d090[i] = p[i + 1];
  sendCOMM(0, p[0], (unsigned char *)0xd090L);
}
