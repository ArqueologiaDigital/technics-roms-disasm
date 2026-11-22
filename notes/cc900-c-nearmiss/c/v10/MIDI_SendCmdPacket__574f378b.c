/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m302a.c (2026-11-21-2-p6-r58)
   sha256 574f378b2046f0f66acbc3f8b8a1a99a0d5d4e293201820fc1e502892b0a7887 (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_d090[];
extern void sendCOMM(int, int, unsigned char *);
void MIDI_SendCmdPacket(unsigned char *p)
{
  int i;
  for (i = 0; i < p[0]; i++)
    ram_d090[i] = p[i + 1];
  sendCOMM(0, p[0], (unsigned char *)0xd090L);
}
