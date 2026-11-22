/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_31r1m234a.c (2026-11-22-15-p6-r82)
   sha256 3ddde394a4993165edee333112471ace959021765f953d4d0f03349c977e0073 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned char __near ACC_RUN_FLAGS;
extern unsigned char __near ram_1d90;
extern unsigned char __near ram_11f4;
extern unsigned char __near ram_1d5e;
extern unsigned char __near ram_1da0;
extern void SeqRestart_CheckAndDispatch(void);
extern void BitMapOut_PrepareAndRender(int);
extern void SeqPlay_AllocBuffersAndInit(void);
extern void SeqPlay_CheckStartConditions(void);
void SeqPlay_HandleVoiceReassign(void)
{
  unsigned char f;

  if ((SEQ_CONTROL_FLAGS & 0x04) && !(PANEL_STYLE[5] & 0x30)) {
    SeqRestart_CheckAndDispatch();
    f = SEQ_CONTROL_FLAGS;
    f &= ~0x04;
    f |= 0x10;
    SEQ_CONTROL_FLAGS = f;
  }
  if (ram_1d90 != 0 && !(ACC_TRANSPORT_STATE & 0x04) && !(SEQ_TRANSPORT_STATE & 0x14)) {
    ram_11f4 = 0;
    BitMapOut_PrepareAndRender(0);
    ram_1d90 = 0;
  }
  if ((SEQ_CONTROL_FLAGS & 0x10) && !(ACC_TRANSPORT_STATE & 0x04) && !(SEQ_TRANSPORT_STATE & 0x14)
      && ram_1d5e == 0 && !(ACC_RUN_FLAGS & 0x02)) {
    SeqPlay_AllocBuffersAndInit();
    SEQ_CONTROL_FLAGS &= ~0x10;
  }
  if (ram_1da0 == 0) return;
  if (SEQ_TRANSPORT_STATE & 0x1c) return;
  SeqPlay_CheckStartConditions();
  ram_1da0 = 0;
}
