/* helper Q, round 20r1, module 280 (audio/audio_control_engine.s): TLV payload pointer by tag. */

extern unsigned char *PanelTlv_PayloadByTag[];

unsigned char *PanelTlv_PayloadOfTag(unsigned char t)
{
  return PanelTlv_PayloadByTag[t];
}
