/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

#define EVT_SET_PARAM 0x1e0003bL
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_GRAPH_DRAW 0x1c80004L
extern void ApDeliveryEvent(long, long, long);
extern long __near SEQ_SCREEN_OBJECT;
extern unsigned char __near ram_2742;
extern unsigned char __near ram_296a;
extern unsigned char __near ram_2788;
extern void SetVisible(long, unsigned int);
extern void Part_ClearAllVoiceChannels(void);
extern void Part_UnlinkVoiceFromChain(void);
extern unsigned char SEQ_SONG_SLOTS[];
extern long FileIO_WriteByte_Impl(void *, long);

void AppEvent_SendVoiceUpdate(long v)
{
  ApDeliveryEvent(0x810003L, EVT_SET_PARAM, v);
}

void NoteEditSy_ScrollCase1(long v)
{
  ApDeliveryEvent(0x87000dL, EVT_SET_PARAM, v);
}

void NoteEditSy_ScrollReset(long v)
{
  ApDeliveryEvent(0x850006L, EVT_SET_PARAM, v);
}

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

void SeqIndicator_HideBoth(void)
{
  SetVisible(0x850013L, 0);
  SetVisible(0x850014L, 0);
}

void SeqLoadPre(void)
{
  Part_ClearAllVoiceChannels();
  Part_UnlinkVoiceFromChain();
}

void SeqSave_WriteBlockToFile(unsigned char a)
{
  FileIO_WriteByte_Impl((void *)(SEQ_SONG_SLOTS + ((unsigned long)a << 11)), 0x800L);
}
