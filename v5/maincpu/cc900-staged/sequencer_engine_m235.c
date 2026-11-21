/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

#define EVT_PARA_DRAW 0x1c0000fL
extern unsigned char __near CURRENT_TITLE;
extern long __near SEQ_SCREEN_OBJECT;
extern unsigned char __near SEQ_SONG;
extern unsigned char __near ram_26ee;
extern unsigned char __near ram_26f0;
extern unsigned int __near SQEDT_MDEL_FROM;
extern unsigned int __near SQEDT_MDEL_LAST;
extern unsigned int __near SQEDT_MERS_FROM;
extern unsigned int __near SQEDT_MERS_LAST;
extern unsigned int __near SQEDT_MCP_FROM;
extern unsigned int __near SQEDT_MCP_LAST;
extern unsigned int __near SQEDT_MINS_FROM;
extern unsigned int __near SQEDT_MINS_LAST;
extern unsigned int __near ram_f1d9;
extern unsigned int __near ram_f1de;
extern unsigned int __near ram_f1e4;
extern unsigned int __near ram_f1ec;
extern void ApDeliveryEvent(long, long, long);
extern void SeqData_CopyBlockWithLookup(void);
extern void SeqPart_CountActiveVoices(unsigned int);
extern void SeqData_CopyBlock2K(unsigned int, unsigned char *);
extern void SeqEvent_MainHandler(void); void SeqEvent_MainHandler(void);
extern void PartCtrl_RefreshWordPeriodic(void);
extern unsigned int __near ram_2574;
extern unsigned int __near SEQ_BEAT_COUNT;
extern unsigned char SeqEvent_AccumulateQueue(void);

/* cc900-data: SeqEvent_MainHandler 1 = SeqEvent_MainHandler_CaseTable */
void SeqEvent_MainHandler(void);

void SeqEvent_MainHandler(void)
{
	switch (CURRENT_TITLE) {
	case 0x90:
		SeqData_CopyBlockWithLookup();
		SeqPart_CountActiveVoices(SEQ_SONG);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x1eL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x1fL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x20L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x21L);
		break;
	case 0x9f:
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 1L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 2L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0xaL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0xbL);
		break;
	case 0x9e:
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 1L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 2L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 5L);
		break;
	case 0x9d:
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 1L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 2L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 4L);
		break;
	case 0xa3:
		SQEDT_MDEL_LAST = SQEDT_MDEL_FROM + ram_f1d9 - 1;
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 1L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 2L);
		break;
	case 0xa1:
		SQEDT_MERS_LAST = SQEDT_MERS_FROM + ram_f1de - 1;
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 1L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 2L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 6L);
		break;
	case 0x9c:
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 1L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 2L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 7L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 8L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 9L);
		break;
	case 0x9b:
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0xcL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0xdL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0xeL);
		break;
	case 0xa2:
		SQEDT_MCP_LAST = SQEDT_MCP_FROM + ram_f1ec - 1;
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0xfL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x10L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x11L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x12L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x13L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x14L);
		break;
	case 0xa4:
		SQEDT_MINS_LAST = SQEDT_MINS_FROM + ram_f1e4 - 1;
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x15L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x16L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x17L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x18L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x19L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x1aL);
		break;
	case 0x91:
	case 0xa8:
		SeqData_CopyBlock2K(ram_26ee, (unsigned char *)0x2842L);
		SeqData_CopyBlock2K(ram_26f0, (unsigned char *)0x2852L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x1bL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x1cL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x1dL);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0x1eL);
		break;
	default:
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 1L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 2L);
		ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 3L);
		break;
	}
}

unsigned char SeqEvent_AccumulateQueue(void)
{
  unsigned char r;
  PartCtrl_RefreshWordPeriodic();
  ram_2574++;
  if (ram_2574 > SEQ_BEAT_COUNT)
    r = 1;
  else
    r = 0;
  return r;
}
