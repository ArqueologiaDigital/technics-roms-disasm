/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: MIDI_SendControlChange SubCPU_SendSystemRecord */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void MIDI_SendCmdPacket(unsigned char *);
extern void MIDI_PostSendStub(void);
extern void MIDI_SendSysExCmd(unsigned char);
extern void MIDI_SendSysExCmd(unsigned char cmd);

void MIDI_SendSysExCmd(unsigned char cmd)
{
  unsigned char b[5];
  b[0] = 4; b[1] = 0xf0; b[2] = 0x50; b[3] = 0x87; b[4] = cmd;
  MIDI_SendCmdPacket(b);
  MIDI_PostSendStub();
}
