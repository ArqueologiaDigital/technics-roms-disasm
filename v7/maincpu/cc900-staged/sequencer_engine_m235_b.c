/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

#define EVT_PARA_DRAW 0x1c0000fL
extern void ApDeliveryEvent(long, long, long);
extern long __near SEQ_SCREEN_OBJECT;
extern unsigned char __near ram_296a;
extern unsigned char __near ram_2788;
extern void NoteEditSy_SendGateCmd(void);
extern void NoteEditSy_SendScrollCmd1(void);
extern void NoteEditSy_SendScrollCmd5(void);
#define EVT_GRAPH_DRAW 0x1c80004L
extern void NoteEditSy_SendWidgetCmd0(void);
extern void NoteEditSy_SendWidgetCmd2(void);
extern unsigned char __near ram_2742;
extern void NoteEditSy_SendWidgetCmd3or4(void);

void NoteEditSy_SendGateCmd(void)
{
  ram_296a = ram_2788;
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 4L);
}

void NoteEditSy_SendScrollCmd1(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 1L);
}

void NoteEditSy_SendScrollCmd5(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 5L);
}

void NoteEditSy_SendWidgetCmd0(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 0L);
}

void NoteEditSy_SendWidgetCmd2(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 2L);
}

void NoteEditSy_SendWidgetCmd3or4(void)
{
  long d = 3;
  if (ram_2742 & 1) d = 4;
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, d);
}
